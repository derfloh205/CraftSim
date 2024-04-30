---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT", "COMMODITY_PURCHASE_SUCCEEDED",
    "NEW_RECIPE_LEARNED" })

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
        targetItemCountByQuality =
            options.targetItemCountByQuality
    })

    CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue:ClearAll()
    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
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
            local restockAmount = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT")
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
                if recipeData.cooldownData.isCooldownRecipe and not recipeData.cooldownData.isDayCooldown then
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

        CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
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
                    local restockAmount = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT")
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
                        if recipeData.cooldownData.isCooldownRecipe and not recipeData.cooldownData.isDayCooldown then
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

                CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
            end, function()
                -- finally update all subrecipes in target mode and update display one last time
                CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
                importButton:SetStatus("Ready")
            end)
    end
end

---@param recipeData CraftSim.RecipeData
---@param amount number
---@param enchantItemTarget ItemLocationMixin?
function CraftSim.CRAFTQ:OnCraftRecipe(recipeData, amount, enchantItemTarget)
    -- find the current queue item and set it to currentlyCraftedQueueItem
    -- if an enchant was crafted that was not on a vellum, ignore
    if enchantItemTarget and enchantItemTarget:IsValid() then
        if C_Item.GetItemID(enchantItemTarget) ~= CraftSim.CONST.ENCHANTING_VELLUM_ID then
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

function CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_SHOPPING_LIST_PER_CHARACTER") then
        CraftSim.CRAFTQ.CreateAuctionatorShoppingListPerCharacter()
    else
        CraftSim.CRAFTQ.CreateAuctionatorShoppingListAll()
    end
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

function CraftSim.CRAFTQ.CreateAuctionatorShoppingListPerCharacter()
    print("CraftSim.CRAFTQ:CreateAuctionatorShoppingListPerCharacter", false, true)

    CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()

    CraftSim.DEBUG:StartProfiling("CreateAuctionatorShoppingListPerCharacter")
    local reagentMapPerCharacter = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        if not CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_SHOPPING_LIST_TARGET_MODE") or craftQueueItem.targetMode then
            local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
            local crafterUID = craftQueueItem.recipeData:GetCrafterUID()
            reagentMapPerCharacter[crafterUID] = reagentMapPerCharacter[crafterUID] or {}
            for _, reagent in pairs(requiredReagents) do
                if reagent.hasQuality then
                    for qualityID, reagentItem in pairs(reagent.items) do
                        local itemID = reagentItem.item:GetItemID()
                        local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                        if not isSelfCrafted then
                            reagentMapPerCharacter[crafterUID][itemID] = reagentMapPerCharacter
                                [crafterUID][itemID] or {
                                    itemName = reagentItem.item:GetItemName(),
                                    qualityID = nil,
                                    quantity = 0
                                }
                            reagentMapPerCharacter[crafterUID][itemID].quantity = reagentMapPerCharacter
                                [crafterUID][itemID]
                                .quantity + (reagentItem.quantity * craftQueueItem.amount)
                            reagentMapPerCharacter[crafterUID][itemID].qualityID = qualityID
                        end
                    end
                else
                    local reagentItem = reagent.items[1]
                    local itemID = reagentItem.item:GetItemID()
                    local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                    if not isSelfCrafted then
                        reagentMapPerCharacter[crafterUID][itemID] = reagentMapPerCharacter
                            [crafterUID]
                            [itemID] or {
                                itemName = reagentItem.item:GetItemName(),
                                qualityID = nil,
                                quantity = 0
                            }
                        reagentMapPerCharacter[crafterUID][itemID].quantity = reagentMapPerCharacter
                            [crafterUID][itemID].quantity +
                            (reagentItem.quantity * craftQueueItem.amount)
                        print("reagentMap Build: " .. tostring(reagentItem.item:GetItemLink()))
                        print("quantity: " ..
                            tostring(reagentMapPerCharacter[crafterUID][itemID].quantity))
                    end
                end
            end
            local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
            for _, optionalReagent in pairs(activeReagents) do
                local itemID = optionalReagent.item:GetItemID()
                local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                if not isSelfCrafted and not GUTIL:isItemSoulbound(itemID) then
                    reagentMapPerCharacter[crafterUID][itemID] = reagentMapPerCharacter
                        [crafterUID][itemID] or {
                            itemName = optionalReagent.item:GetItemName(),
                            qualityID = optionalReagent.qualityID,
                            quantity = 0
                        }
                    reagentMapPerCharacter[crafterUID][itemID].quantity = reagentMapPerCharacter
                        [crafterUID][itemID]
                        .quantity + craftQueueItem.amount
                end
            end
        end
    end

    for crafterUID, reagentMap in pairs(reagentMapPerCharacter) do
        --- convert to Auctionator Search Strings and deduct item count
        local searchStrings = GUTIL:Map(reagentMap, function(info, itemID)
            itemID = CraftSim.CRAFTQ:GetNonSoulboundAlternativeItemID(itemID)
            if not itemID then
                return nil
            else
                info.itemName = select(1, C_Item.GetItemInfo(itemID)) -- 100% already loaded in this case when its used as alt item in ReagentItem
            end

            local itemCount = CraftSim.ITEM_COUNT:Get(crafterUID, itemID)
            local searchTerm = {
                searchString = info.itemName,
                tier = info.qualityID,
                quantity = math.max(info.quantity - itemCount, 0),
                isExact = true,
            }
            if searchTerm.quantity == 0 then
                return nil -- do not put into table
            end
            local searchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerm)
            return searchString
        end)
        Auctionator.API.v1.CreateShoppingList(addonName,
            CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME .. " " .. tostring(crafterUID),
            searchStrings)
    end


    CraftSim.DEBUG:StopProfiling("CreateAuctionatorShoppingListPerCharacter")
end

function CraftSim.CRAFTQ.CreateAuctionatorShoppingListAll()
    print("CraftSim.CRAFTQ:CreateAuctionatorShoppingList", false, true)

    CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()

    CraftSim.DEBUG:StartProfiling("CreateAuctionatorShopping")
    local reagentMap = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        if not CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_SHOPPING_LIST_TARGET_MODE") or craftQueueItem.targetMode then
            local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
            for _, reagent in pairs(requiredReagents) do
                if reagent.hasQuality then
                    for qualityID, reagentItem in pairs(reagent.items) do
                        local itemID = reagentItem.item:GetItemID()
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
            local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
            for _, optionalReagent in pairs(activeReagents) do
                local itemID = optionalReagent.item:GetItemID()
                local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                if not isSelfCrafted and not GUTIL:isItemSoulbound(itemID) then
                    reagentMap[itemID] = reagentMap[itemID] or {
                        itemName = optionalReagent.item:GetItemName(),
                        qualityID = optionalReagent.qualityID,
                        quantity = 0
                    }
                    reagentMap[itemID].quantity = reagentMap[itemID]
                        .quantity + craftQueueItem.amount
                end
            end
        end
    end

    local crafterUIDs = GUTIL:Map(CraftSim.CRAFTQ.craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)

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

--- Called by the AddCurrentRecipeButton
function CraftSim.CRAFTQ:AddOpenRecipe()
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

    CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
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

    self.FRAMES:UpdateDisplay()
end
