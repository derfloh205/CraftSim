---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT", "COMMODITY_PURCHASE_SUCCEEDED",
    "NEW_RECIPE_LEARNED", "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED", "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED" })

---@type CraftSim.CraftQueue
CraftSim.CRAFTQ.craftQueue = nil

---@type CraftSim.RecipeData | nil
CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil

--- used to check if CraftSim was the one calling the C_TradeSkillUI.CraftRecipe api function
CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false

--- used to cache player item counts during sorting and recalculation of craft queue
--- if canCraft and such functions are not called by craftqueue it should be nil
CraftSim.CRAFTQ.itemCountCache = nil

local systemPrint = print
local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

--- cache for OnConfirmCommoditiesPurchase -> COMMODITY_PURCHASE_SUCCEEDED flow
---@class CraftSim.CraftQueue.purchasedItem
---@field item ItemMixin?
---@field quantity number
CraftSim.CRAFTQ.purchasedItem = nil

---@param itemID number
---@param boughtQuantity number
function CraftSim.CRAFTQ:OnConfirmCommoditiesPurchase(itemID, boughtQuantity)
    if not select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
        return -- do not need if Auctionator not loaded
    end

    CraftSim.CRAFTQ.purchasedItem = {
        item = Item:CreateFromItemID(itemID),
        quantity = boughtQuantity
    }
end

function CraftSim.CRAFTQ:COMMODITY_PURCHASE_SUCCEEDED()
    if not select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
        return -- do not need if Auctionator not loaded
    end

    if not Auctionator.API.v1.ConvertToSearchString then
        return -- if Auctionator is not up to date, do nothing
    end
    if CraftSim.CRAFTQ.purchasedItem then
        GUTIL:ContinueOnAllItemsLoaded({ CraftSim.CRAFTQ.purchasedItem.item }, function()
            local purchasedItem = CraftSim.CRAFTQ.purchasedItem
            print("commodity purchase successfull")
            print("item: " .. tostring(purchasedItem.item:GetItemLink()))
            print("quantity: " .. tostring(purchasedItem.quantity))

            local success
            local result
            local shoppingListName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME
            success, result = pcall(Auctionator.API.v1.GetShoppingListItems, addonName,
                shoppingListName)
            if not success then
                --print("Error calling GetShoppingListItems:\n" .. tostring(result))
                -- probably shopping list not existing
                -- try getting character specific shopping list
                shoppingListName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
                    " " .. CraftSim.UTIL:GetPlayerCrafterUID()
                success, result = pcall(Auctionator.API.v1.GetShoppingListItems, addonName,
                    shoppingListName)

                if not success then
                    -- no shopping list exists to deduct items from
                    return
                end
            end

            local itemQualityID = GUTIL:GetQualityIDFromLink(purchasedItem.item:GetItemLink())
            local searchTerms = {
                searchString = purchasedItem.item:GetItemName(),
                isExact = true,
                tier = itemQualityID,
            }
            local searchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerms)
            local oldSearchString = GUTIL:Find(result, function(r)
                return GUTIL:StringStartsWith(r, searchString)
            end)
            if not oldSearchString then
                print("item could not be found in shopping list")
                return
            end

            local oldTerms = Auctionator.API.v1.ConvertFromSearchString(addonName, oldSearchString)

            -- modify original line by updated quantity
            local newQuantity = oldTerms.quantity - purchasedItem.quantity

            if newQuantity > 0 then
                searchTerms.quantity = newQuantity
                local newSearchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerms)
                -- adapt
                Auctionator.API.v1.AlterShoppingListItem(addonName, shoppingListName,
                    oldSearchString, newSearchString)
            else
                -- remove
                Auctionator.API.v1.DeleteShoppingListItem(addonName, shoppingListName,
                    oldSearchString)
            end

            CraftSim.CRAFTQ.purchasedItem = nil -- reset
        end)
    end
end

function CraftSim.CRAFTQ:CRAFTINGORDERS_CLAIMED_ORDER_UPDATED()
    self.UI:UpdateDisplay()
end

function CraftSim.CRAFTQ:CRAFTINGORDERS_CLAIMED_ORDER_REMOVED()
    self.UI:UpdateDisplay()
end

function CraftSim.CRAFTQ:QueuePatronOrders()
    local profession = C_TradeSkillUI.GetChildProfessionInfo().profession
    if C_TradeSkillUI.IsNearProfessionSpellFocus(profession) then
        local request = {
            orderType = Enum.CraftingOrderType.Npc,
            searchFavorites = false,
            initialNonPublicSearch = false,
            primarySort = {
                sortType = Enum.CraftingOrderSortType.ItemName,
                reversed = false,
            },
            secondarySort = {
                sortType = Enum.CraftingOrderSortType.MaxTip,
                reversed = false,
            },
            forCrafter = true,
            offset = 0,
            profession = profession,
            ---@diagnostic disable-next-line: redundant-parameter
            callback = C_FunctionContainers.CreateCallback(function(result)
                if result == Enum.CraftingOrderResult.Ok then
                    local orders = C_CraftingOrders.GetCrafterOrders()
                    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
                    if claimedOrder then
                        tinsert(orders, claimedOrder)
                    end

                    local queuePatronOrdersButton = CraftSim.CRAFTQ.frame.content.queueTab.content
                        .addPatronOrdersButton --[[@as GGUI.Button]]
                    queuePatronOrdersButton:SetEnabled(false)

                    GUTIL.FrameDistributor {
                        iterationTable = orders,
                        iterationsPerFrame = 1,
                        maxIterations = 100,
                        finally = function()
                            queuePatronOrdersButton:SetText(L(CraftSim.CONST.TEXT
                                .CRAFT_QUEUE_ADD_PATRON_ORDERS_BUTTON_LABEL))
                            queuePatronOrdersButton:SetEnabled(true)
                        end,
                        continue = function(distributor, _, order, _, progress)
                            queuePatronOrdersButton:SetText(string.format("%.0f%%", progress))

                            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(order.spellID)
                            if recipeInfo and recipeInfo.learned then
                                local recipeData = CraftSim.RecipeData({ recipeID = order.spellID })

                                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_IGNORE_SPARK_RECIPES") then
                                    if recipeData.reagentData:HasSparkSlot() then
                                        if recipeData.reagentData.sparkReagentSlot.activeReagent then
                                            if not recipeData.reagentData.sparkReagentSlot.activeReagent:IsOrderReagentIn(recipeData) then
                                                distributor:Continue()
                                                return
                                            end
                                        end
                                    end
                                end

                                recipeData:SetOrder(order)

                                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_ONLY") then
                                    if recipeData.orderData and recipeData.orderData.npcOrderRewards then
                                        local hasKnowledgeReward = GUTIL:Some(recipeData.orderData.npcOrderRewards,
                                            function(reward)
                                                local itemID = GUTIL:GetItemIDByLink(reward.itemLink)
                                                return tContains(CraftSim.CONST.PATRON_ORDERS_KNOWLEDGE_REWARD_ITEMS,
                                                    itemID)
                                            end)
                                        if not hasKnowledgeReward then
                                            distributor:Continue()
                                            return
                                        end
                                    end
                                end

                                recipeData:SetCheapestQualityReagentsMax() -- considers patron reagents
                                recipeData:Update()

                                local function queueRecipe()
                                    local allowConcentration = CraftSim.DB.OPTIONS:Get(
                                        "CRAFTQUEUE_PATRON_ORDERS_ALLOW_CONCENTRATION")
                                    local forceConcentration = CraftSim.DB.OPTIONS:Get(
                                        "CRAFTQUEUE_PATRON_ORDERS_FORCE_CONCENTRATION")
                                    -- TODO: allow queuing with concentration and concentration optimization in queue options
                                    -- check if the min quality is reached, if not do not queue
                                    if recipeData.resultData.expectedQuality >= order.minQuality then
                                        CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData }
                                    end

                                    if (forceConcentration or allowConcentration) and
                                        recipeData.resultData.expectedQualityConcentration == order.minQuality then
                                        -- use concentration to reach and then queue
                                        recipeData.concentrating = true
                                        recipeData:Update()
                                        CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData }
                                    end

                                    distributor:Continue()
                                end
                                -- try to optimize for target quality
                                if order.minQuality then
                                    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_FORCE_CONCENTRATION") then
                                        RunNextFrame(
                                            function()
                                                recipeData:OptimizeReagents({
                                                    maxQuality = math.max(order.minQuality - 1, 1)
                                                })
                                                queueRecipe()
                                            end
                                        )
                                    else
                                        RunNextFrame(
                                            function()
                                                recipeData:OptimizeReagents({
                                                    maxQuality = order.minQuality
                                                })
                                                queueRecipe()
                                            end
                                        )
                                    end
                                else
                                    queueRecipe()
                                end
                            else
                                distributor:Continue()
                            end
                        end
                    }:Continue()
                end
            end),
        }
        C_CraftingOrders.RequestCrafterOrders(request)
    end
end

function CraftSim.CRAFTQ:InitializeCraftQueue()
    -- load from Saved Variables
    CraftSim.CRAFTQ.craftQueue = CraftSim.CraftQueue()

    CraftSim.CRAFTQ.craftQueue:RestoreFromDB()

    -- hook onto auction buy confirm function
    hooksecurefunc(C_AuctionHouse, "ConfirmCommoditiesPurchase", function(itemID, quantity)
        CraftSim.CRAFTQ:OnConfirmCommoditiesPurchase(itemID, quantity)
    end)
end

---@param options CraftSim.CraftQueueItem.Options
function CraftSim.CRAFTQ:AddRecipe(options)
    options = options or {}

    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()
    CraftSim.CRAFTQ.craftQueue:AddRecipe({
        recipeData = options.recipeData,
        amount = options.amount,
    })

    CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue:ClearAll()
    CraftSim.CRAFTQ.UI:UpdateDisplay()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ.ImportRecipeScanFilter(recipeData) -- . accessor instead of : is on purpose here
    local f = GUTIL:GetFormatter()
    print("Filtering: " .. tostring(recipeData.recipeName), false, true)
    if not recipeData.learned then
        print(f.r("Not learned"))
        return false
    end

    local restockOptions = CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)

    recipeData.concentrating = CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION")
    recipeData:Update() -- update recipe before importing


    if not restockOptions.enabled then
        print("restockOptions.disabled")
        -- use general options
        local profitThresholdReached = false
        if recipeData.relativeProfitCached then
            profitThresholdReached = recipeData.relativeProfitCached >=
                (CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_PROFIT_MARGIN_THRESHOLD") or 0)
        end
        local saleRateReached = CraftSim.CRAFTQ:CheckSaleRateThresholdForRecipe(recipeData, nil,
            CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_SALE_RATE_THRESHOLD"))
        print("profitThresholdReached: " .. tostring(profitThresholdReached))
        print("saleRateReached: " .. tostring(saleRateReached))
        print("relativeProfitCached: " .. tostring(recipeData.relativeProfitCached))
        local include = profitThresholdReached and saleRateReached
        if include then
            print(f.g("include"))
        else
            print(f.r("not include"))
        end
        return include
    end
    print("restockOptions.enabled")
    local profitMarginReached = false

    -- else use recipe specific restock options to filter
    if recipeData.relativeProfitCached then
        profitMarginReached = recipeData.relativeProfitCached >= (restockOptions.profitMarginThreshold)
    end

    local saleRateReached = CraftSim.CRAFTQ:CheckSaleRateThresholdForRecipe(recipeData, restockOptions
        .saleRatePerQuality, restockOptions.saleRateThreshold)

    print("profitMarginReached: " .. tostring(profitMarginReached))
    print("saleRateReached: " .. tostring(saleRateReached))
    print("relativeProfitCached: " .. tostring(recipeData.relativeProfitCached))

    local include = profitMarginReached and saleRateReached
    if include then
        print(f.g("include"))
    else
        print(f.r("not include"))
    end
    return include
end

function CraftSim.CRAFTQ:ImportRecipeScan()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()
    local recipeScanTabContent = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    local professionList = recipeScanTabContent.professionList
    local selectedRow = professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    if not selectedRow then return end -- nil check .. who knows..
    if not CraftSim.DB.OPTIONS:Get("RECIPESCAN_IMPORT_ALL_PROFESSIONS") then
        ---@type CraftSim.RecipeData[]
        local filteredRecipes = GUTIL:Filter(selectedRow.currentResults, CraftSim.CRAFTQ.ImportRecipeScanFilter)
        for _, recipeData in pairs(filteredRecipes) do
            local restockOptions = CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)
            local restockAmount = CraftSim.CRAFTQ:GetRestockQuantity(recipeData.resultData.expectedItem)

            if restockOptions.enabled then
                restockAmount = restockOptions.restockAmount

                for qualityID, use in pairs(restockOptions.restockPerQuality) do
                    if use then
                        local item = recipeData.resultData.itemsByQuality[qualityID]
                        if item then
                            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(recipeData:GetCrafterUID(),
                                item:GetItemID())
                            restockAmount = restockAmount - itemCount
                        end
                    end
                end
            end

            if restockAmount > 0 then
                if recipeData.cooldownData.isCooldownRecipe then
                    local charges = recipeData.cooldownData:GetCurrentCharges()
                    if charges > 0 then
                        CraftSim.CRAFTQ.craftQueue:AddRecipe({
                            recipeData = recipeData,
                            amount = math.min(restockAmount,
                                charges)
                        })
                    end
                else
                    CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = recipeData, amount = restockAmount })
                end
            end
        end

        CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
    else
        local queueTab = CraftSim.CRAFTQ.frame.content.queueTab --[[@as CraftSim.CraftQueue.QueueTab]]
        local importButton = queueTab.content.importRecipeScanButton
        local numImportProfessions = GUTIL:Count(professionList.activeRows,
            function(row) return row.columns[1].checkbox:GetChecked() end)
        GUTIL:FrameDistributedIteration(professionList.activeRows,
            ---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
            function(_, row, counter)
                --- update button
                local checkBoxColumn = row.columns[1] --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.CHECKBOX_COLUMN]]
                if not checkBoxColumn.checkbox:GetChecked() then
                    return
                end

                importButton:SetText("Importing: " .. tostring(counter) .. "/" .. tostring(numImportProfessions), 15,
                    true)
                importButton:SetEnabled(false)

                ---@type CraftSim.RecipeData[]
                local filteredRecipes = GUTIL:Filter(row.currentResults, CraftSim.CRAFTQ.ImportRecipeScanFilter)
                for _, recipeData in pairs(filteredRecipes) do
                    local restockOptions = CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)
                    local restockAmount = CraftSim.CRAFTQ:GetRestockQuantity(recipeData.resultData.expectedItem)

                    if restockOptions.enabled then
                        restockAmount = restockOptions.restockAmount

                        for qualityID, use in pairs(restockOptions.restockPerQuality) do
                            if use then
                                local item = recipeData.resultData.itemsByQuality[qualityID]
                                if item then
                                    local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(
                                        recipeData:GetCrafterUID(), item:GetItemID())
                                    restockAmount = restockAmount - itemCount
                                end
                            end
                        end
                    end

                    if restockAmount > 0 then
                        if recipeData.cooldownData.isCooldownRecipe then
                            local charges = recipeData.cooldownData:GetCurrentCharges()
                            if charges > 0 then
                                CraftSim.CRAFTQ.craftQueue:AddRecipe({
                                    recipeData = recipeData,
                                    amount = math.min(
                                        restockAmount, charges)
                                })
                            end
                        else
                            CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = recipeData, amount = restockAmount })
                        end
                    end
                end

                CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
            end, function()
                -- finally update all subrecipes and update display one last time
                CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
                importButton:SetStatus("Ready")
            end)
    end
end

---@param recipeData CraftSim.RecipeData
---@param amount number
---@param enchantItemTargetOrRecipeLevel ItemLocationMixin|number?
function CraftSim.CRAFTQ:OnCraftRecipe(recipeData, amount, enchantItemTargetOrRecipeLevel)
    -- find the current queue item and set it to currentlyCraftedQueueItem
    -- if an enchant was crafted that was not on a vellum, ignore
    if enchantItemTargetOrRecipeLevel and type(enchantItemTargetOrRecipeLevel) ~= "number" and enchantItemTargetOrRecipeLevel:IsValid() then
        if C_Item.GetItemID(enchantItemTargetOrRecipeLevel) ~= CraftSim.CONST.ENCHANTING_VELLUM_ID then
            CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil
            return
        end
    end
    print("OnCraftRecipe", false, true)
    CraftSim.CRAFTQ.currentlyCraftedRecipeData = recipeData
end

function CraftSim.CRAFTQ:GetNonSoulboundAlternativeItemID(itemID)
    if GUTIL:isItemSoulbound(itemID) then
        -- if item is soulbound check if there is non soulbound alternative item
        local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID]
        if alternativeItemID and not GUTIL:isItemSoulbound(alternativeItemID) then
            print("Found non soulbound alt item: " .. tostring(alternativeItemID))
            return alternativeItemID
        else
            return nil
        end
    end
    return itemID
end

--- depricate as soon as there is an api for it
function CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(listName)
    local listExists = Auctionator.Shopping.ListManager:GetIndexForName(listName)
    if listExists then
        Auctionator.Shopping.ListManager:Delete(listName)
    end
end

function CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()
    -- delete the general shopping list if it exists
    CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME)
    -- delete , if existing, all shoppinglists for cached crafterUIDS
    local crafterUIDs = CraftSim.DB.CRAFTER:GetCrafterUIDs()
    for _, crafterUID in pairs(crafterUIDs) do
        CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
            " " .. tostring(crafterUID))
    end
end

function CraftSim.CRAFTQ.CreateAuctionatorShoppingList()
    print("CraftSim.CRAFTQ:CreateAuctionatorShoppingList", false, true)

    CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()

    CraftSim.DEBUG:StartProfiling("CreateAuctionatorShopping")
    local reagentMap = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if not reagent:IsOrderReagentIn(craftQueueItem.recipeData) then
                if reagent.hasQuality then
                    for qualityID, reagentItem in pairs(reagent.items) do
                        local itemID = reagentItem.item:GetItemID()
                        print("Shopping List Creation: Item: " .. (reagentItem.item:GetItemLink() or ""))
                        local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                        if not isSelfCrafted then
                            reagentMap[itemID] = reagentMap[itemID] or {
                                itemName = reagentItem.item:GetItemName(),
                                qualityID = nil,
                                quantity = 0
                            }
                            reagentMap[itemID].quantity = reagentMap[itemID]
                                .quantity + (reagentItem.quantity * craftQueueItem.amount)
                            reagentMap[itemID].qualityID = qualityID
                        end
                    end
                else
                    local reagentItem = reagent.items[1]
                    local itemID = reagentItem.item:GetItemID()
                    local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                    if not isSelfCrafted then
                        reagentMap[itemID] = reagentMap[itemID] or {
                            itemName = reagentItem.item:GetItemName(),
                            qualityID = nil,
                            quantity = 0
                        }
                        reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                            (reagentItem.quantity * craftQueueItem.amount)
                        print("reagentMap Build: " .. tostring(reagentItem.item:GetItemLink()))
                        print("quantity: " .. tostring(reagentMap[itemID].quantity))
                    end
                end
            end
        end
        local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
        local quantityMap = {} -- ugly hack.. TODO refactor
        if craftQueueItem.recipeData.reagentData:HasSparkSlot() then
            if craftQueueItem.recipeData.reagentData.sparkReagentSlot.activeReagent then
                tinsert(activeReagents, craftQueueItem.recipeData.reagentData.sparkReagentSlot.activeReagent)
                quantityMap[craftQueueItem.recipeData.reagentData.sparkReagentSlot.activeReagent.item:GetItemID()] =
                    craftQueueItem.recipeData.reagentData.sparkReagentSlot.maxQuantity or 1
            end
        end
        for _, optionalReagent in pairs(activeReagents) do
            local itemID = optionalReagent.item:GetItemID()
            local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
            local isOrderReagent = optionalReagent:IsOrderReagentIn(craftQueueItem.recipeData)
            local qualityID = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID)
            if not isOrderReagent and not isSelfCrafted and not GUTIL:isItemSoulbound(itemID) then
                reagentMap[itemID] = reagentMap[itemID] or {
                    itemName = optionalReagent.item:GetItemName(),
                    qualityID = qualityID,
                    quantity = quantityMap[itemID] or 1
                }
                reagentMap[itemID].quantity = reagentMap[itemID]
                    .quantity * craftQueueItem.amount
            end
        end
    end

    local crafterUIDs = GUTIL:Map(CraftSim.CRAFTQ.craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)

    local crafterUIDs = GUTIL:ToSet(crafterUIDs)

    --- convert to Auctionator Search Strings and deduct item count (of all crafters total)
    local searchStrings = GUTIL:Map(reagentMap, function(info, itemID)
        itemID = CraftSim.CRAFTQ:GetNonSoulboundAlternativeItemID(itemID)
        if not itemID then
            return nil
        end
        -- subtract the total item count of all crafter's cached inventory
        local totalItemCount = GUTIL:Fold(crafterUIDs, 0, function(itemCount, crafterUID)
            local itemCountForCrafter = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
            return itemCount + itemCountForCrafter
        end)

        print("total item count " .. itemID .. "-> " .. totalItemCount)

        local searchTerm = {
            searchString = info.itemName,
            tier = info.qualityID,
            quantity = math.max(info.quantity - (tonumber(totalItemCount) or 0), 0),
            isExact = true,
        }
        if searchTerm.quantity == 0 then
            return nil -- do not put into table
        end
        local searchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerm)
        return searchString
    end)
    Auctionator.API.v1.CreateShoppingList(addonName, CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME, searchStrings)

    CraftSim.DEBUG:StopProfiling("CreateAuctionatorShopping")
end

function CraftSim.CRAFTQ:TRADE_SKILL_ITEM_CRAFTED_RESULT()
    print("onCraftResult")
    if CraftSim.CRAFTQ.currentlyCraftedRecipeData then
        CraftSim.CRAFTQ.craftQueue:OnRecipeCrafted(CraftSim.CRAFTQ.currentlyCraftedRecipeData)
    end
end

--- TODO: need exception for enchant vellum to not be fetched from the bank!
--- only for craft queue display update's flash cache
---@param crafterUID CrafterUID
---@param itemID number
function CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
    local itemCount = (CraftSim.CRAFTQ.itemCountCache and CraftSim.CRAFTQ.itemCountCache[itemID]) or nil
    if not itemCount then
        itemCount = CraftSim.ITEM_COUNT:Get(crafterUID, itemID)
    end
    return itemCount
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ:IsRecipeQueueable(recipeData)
    return
        not recipeData.isRecraft and
        not recipeData.isSalvageRecipe and
        not recipeData.isBaseRecraftRecipe and
        recipeData.resultData.itemsByQuality[1] and -- needs at least one result?
        not recipeData.isAlchemicalExperimentation
end

---@class CraftSim.CraftQueue.RestockRecipeOption
---@field enabled boolean,
---@field profitMarginThreshold number,
---@field restockAmount number,
---@field restockPerQuality table<number, boolean>,
---@field saleRateThreshold number,
---@field saleRatePerQuality table<number, boolean>

---@param recipeID number
---@return CraftSim.CraftQueue.RestockRecipeOption
function CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeID)
    local restockPerRecipeOptions = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_PER_RECIPE_OPTIONS")
    restockPerRecipeOptions[recipeID] = restockPerRecipeOptions
        [recipeID] or {}

    restockPerRecipeOptions[recipeID].enabled = restockPerRecipeOptions[recipeID].enabled or false
    restockPerRecipeOptions[recipeID].profitMarginThreshold = restockPerRecipeOptions[recipeID].profitMarginThreshold or
        0
    restockPerRecipeOptions[recipeID].restockAmount = restockPerRecipeOptions[recipeID].restockAmount or 1
    restockPerRecipeOptions[recipeID].restockPerQuality = restockPerRecipeOptions[recipeID].restockPerQuality or {}
    restockPerRecipeOptions[recipeID].saleRateThreshold = restockPerRecipeOptions[recipeID].saleRateThreshold or 0
    restockPerRecipeOptions[recipeID].saleRatePerQuality = restockPerRecipeOptions[recipeID].saleRatePerQuality or {}

    return restockPerRecipeOptions[recipeID]
end

-- Function to determine the restock quantity for a given expected item.
--
-- This function retrieves the default restock amount from the database options.
-- If a custom restock key for TSM (TradeSkillMaster) is specified, it attempts to get the restock amount
-- using the TSM API based on the expected item's link. If a valid restock amount is found, it returns that value.
-- Otherwise, it falls back to the default restock amount.
--
---@param expectedItem ItemMixin The item for which the restock quantity is being determined.
---@return number restockAmount Restock quantity for the given expected item.
function CraftSim.CRAFTQ:GetRestockQuantity(expectedItem)
    local defaultRestockAmount = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT") or 1
    local tsmExpressionEnabled = CraftSim.DB.OPTIONS:Get("TSM_RESTOCK_KEY_ITEMS_ENABLED")
    if tsmExpressionEnabled and TSM_API and expectedItem and CraftSim.DB.OPTIONS:Get("TSM_RESTOCK_KEY_ITEMS") ~= "" then
        local restockAmount = TSM_API.GetCustomPriceValue(CraftSim.DB.OPTIONS:Get("TSM_RESTOCK_KEY_ITEMS"),
            TSM_API.ToItemString(expectedItem:GetItemLink()))
        if restockAmount ~= nil then
            return restockAmount
        else
            return defaultRestockAmount
        end
    else
        return defaultRestockAmount
    end
end

---@param recipeData CraftSim.RecipeData
---@param usedQualitiesTable table<number, boolean>?
---@param saleRateThreshold number
---@private
function CraftSim.CRAFTQ:CheckSaleRateThresholdForRecipe(recipeData, usedQualitiesTable, saleRateThreshold)
    usedQualitiesTable = usedQualitiesTable or { true, true, true, true, true }
    local allOff = not GUTIL:Some(usedQualitiesTable, function(v) return v end)
    if allOff then
        print("No quality checked -> sale rate true")
        return true -- if nothing is checked for an individual sale rate check then its just true
    end
    if not select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[1])) then
        print("tsm not loaded -> sale rate true")
        return true -- always true if TSM is not loaded
    end
    for qualityID, checkQuality in pairs(usedQualitiesTable or {}) do
        local item = recipeData.resultData.itemsByQuality[qualityID]
        if item and checkQuality then
            print("check sale rate for q" .. qualityID .. ": " .. tostring(checkQuality))
            -- return true if any item has a sale rate over the threshold
            local itemSaleRate = CraftSimTSM:GetItemSaleRate(item:GetItemLink())
            print("itemSaleRate: " .. tostring(itemSaleRate))
            print("saleRateThreshold: " .. tostring(saleRateThreshold))
            if itemSaleRate >= saleRateThreshold then
                print("sale reate reached for quality: " .. tostring(qualityID))
                return true
            end
        end
    end
    print("sale rate not reached")
    return false
end

--- Called OnMouseDown by the AddCurrentRecipeButt
---@param mouseButton MouseButton
function CraftSim.CRAFTQ:AddOpenRecipe(mouseButton)
    local recipeData
    if CraftSim.SIMULATION_MODE.isActive then
        if CraftSim.SIMULATION_MODE.recipeData then
            recipeData = CraftSim.SIMULATION_MODE.recipeData:Copy() -- need a copy or changes in simulation mode just overwrite it
        end
    else
        if CraftSim.INIT.currentRecipeData then
            recipeData = CraftSim.INIT.currentRecipeData
        end
    end

    if not recipeData then
        return
    end

    local queueButton
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        queueButton = CraftSim.CRAFTQ.queueRecipeButton
    else
        queueButton = CraftSim.CRAFTQ.queueRecipeButtonWO
    end

    if mouseButton == "LeftButton" then
        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
    elseif mouseButton == "RightButton" then
        --- Give more Options for queuing
        if recipeData.orderData then
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                if recipeData.orderData.minQuality then
                    rootDescription:CreateButton("Optimize " .. f.bb("Minimum Quality") .. " + Queue", function()
                        local recipeData = recipeData:Copy()
                        recipeData:OptimizeReagents({
                            highestProfit = false,
                            maxQuality = recipeData.orderData.minQuality,
                        })

                        if recipeData.resultData.expectedQuality < recipeData.orderData.minQuality then
                            CraftSim.DEBUG:SystemPrint(f.l("CraftSim: " ..
                                f.r("Could not reach minimum quality for work order. Recipe not queued.")))
                            CraftSim.DEBUG:SystemPrint(f.l("CraftSim: " ..
                                f.bb("Highest Quality: " ..
                                    GUTIL:GetQualityIconString(recipeData.resultData.expectedQuality, 20, 20))))
                        else
                            CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                        end
                    end)
                else
                    rootDescription:CreateButton("Optimize " .. f.g("Top Profit") .. " + Queue", function()
                        local recipeData = recipeData:Copy()
                        recipeData:OptimizeReagents({
                            highestProfit = true,
                            maxQuality = recipeData.maxQuality,
                        })
                        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                    end)
                end
            end)
        else
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                rootDescription:CreateButton("Optimize " .. f.bb("Max Quality") .. " + Queue", function()
                    local recipeData = recipeData:Copy()
                    recipeData:OptimizeReagents({
                        highestProfit = false,
                        maxQuality = recipeData.maxQuality,
                    })
                    CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                end)
                rootDescription:CreateButton("Optimize " .. f.g("Top Profit") .. " + Queue", function()
                    local recipeData = recipeData:Copy()
                    recipeData:OptimizeReagents({
                        highestProfit = true,
                        maxQuality = recipeData.maxQuality,
                    })
                    CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                end)
                if recipeData.supportsQualities then
                    rootDescription:CreateButton("Optimize " .. f.gold("Concentration Value") .. " + Queue", function()
                        queueButton:SetEnabled(false)
                        local recipeData = recipeData:Copy()
                        if not recipeData.concentrating then
                            recipeData.concentrating = true
                            recipeData:Update()
                        end
                        recipeData:OptimizeReagents({
                            highestProfit = true,
                            maxQuality = recipeData.maxQuality,
                        })
                        recipeData:OptimizeConcentration({
                            frameDistributedCallback = function()
                                CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                                queueButton:SetEnabled(true)
                                queueButton:SetText("+ CraftQueue")
                            end,
                            progressUpdateCallback = function(progress)
                                queueButton:SetText(string.format("%.0f%%", progress))
                            end
                        })
                    end)
                end
            end)
        end
    end
end

function CraftSim.CRAFTQ:AddFirstCrafts()
    local openRecipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
    local currentSkillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()

    local firstCraftRecipeIDs = GUTIL:Map(openRecipeIDs or {}, function(recipeID)
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.learned and recipeInfo.firstCraft then
            return recipeID
        end

        return nil
    end)

    GUTIL.FrameDistributor {
        iterationsPerFrame = 2,
        iterationTable = firstCraftRecipeIDs,
        continue = function(frameDistributor, _, recipeID, _, _)
            local recipeData = CraftSim.RecipeData({ recipeID = recipeID })
            local isSkillLine = recipeData.professionData.skillLineID == currentSkillLineID
            local ignoreAcuity = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
            local usesAcuity = recipeData.reagentData:HasOneOfReagents({ CraftSim.CONST.ITEM_IDS.CURRENCY
                .ARTISANS_ACUITY })
            local queueRecipe = isSkillLine and (not ignoreAcuity or not usesAcuity)
            if queueRecipe then
                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES") then
                    if recipeData.reagentData:HasSparkSlot() then
                        frameDistributor:Continue()
                        return
                    end
                end

                recipeData.reagentData:SetReagentsMaxByQuality(1)
                self:AddRecipe({ recipeData = recipeData })
                frameDistributor:Continue()
            end
        end
    }:Continue()
end

function CraftSim.CRAFTQ:OnRecipeEditSave()
    print("OnRecipeEditSave")
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)

    editRecipeFrame:Hide()
end

---@param recipeID RecipeID
function CraftSim.CRAFTQ:NEW_RECIPE_LEARNED(recipeID)
    -- if craftQueue has items from this crafter, update learned status and recipeInfo, and queue list
    for _, craftQueueItem in ipairs(self.craftQueue.craftQueueItems) do
        local recipeData = craftQueueItem.recipeData
        if recipeData:IsCrafter() and recipeData.recipeID == recipeID then
            -- recipe was learned, update
            recipeData.recipeInfo.learned = true
            recipeData.learned = true
            CraftSim.DB.CRAFTER:SaveRecipeInfo(recipeData:GetCrafterUID(), recipeData.recipeID, recipeData
                .recipeInfo)
        end
    end

    self.UI:UpdateDisplay()
end
