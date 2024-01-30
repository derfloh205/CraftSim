---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT", "COMMODITY_PURCHASE_SUCCEEDED" })

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
local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

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

    -- hook onto auction buy confirm function
    hooksecurefunc(C_AuctionHouse, "ConfirmCommoditiesPurchase", function(itemID, quantity)
        CraftSim.CRAFTQ:OnConfirmCommoditiesPurchase(itemID, quantity)
    end)
end

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CRAFTQ:AddRecipe(recipeData, amount)
    amount = amount or 1

    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()
    CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, amount)

    CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue:ClearAll()
    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ.ImportRecipeScanFilter(recipeData) -- . accessor instead of : is on purpose here
    local f = CraftSim.UTIL:GetFormatter()
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
                (CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold or 0)
        end
        local saleRateReached = CraftSim.CRAFTQ:CheckSaleRateThresholdForRecipe(recipeData, nil,
            CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold)
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
    if not CraftSimOptions.recipeScanImportAllProfessions then
        ---@type CraftSim.RecipeData[]
        local filteredRecipes = GUTIL:Filter(selectedRow.currentResults, CraftSim.CRAFTQ.ImportRecipeScanFilter)
        for _, recipeData in pairs(filteredRecipes) do
            local restockOptions = CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)
            local restockAmount = tonumber(CraftSimOptions.craftQueueGeneralRestockRestockAmount)
            if restockOptions.enabled then
                restockAmount = restockOptions.restockAmount

                for qualityID, use in pairs(restockOptions.restockPerQuality) do
                    if use then
                        local item = recipeData.resultData.itemsByQuality[qualityID]
                        if item then
                            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(item:GetItemID(), true,
                                false, true,
                                recipeData:GetCrafterUID())
                            restockAmount = restockAmount - itemCount
                        end
                    end
                end
            end

            if restockAmount > 0 then
                CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, restockAmount)
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
                    local restockAmount = tonumber(CraftSimOptions.craftQueueGeneralRestockRestockAmount)
                    if restockOptions.enabled then
                        restockAmount = restockOptions.restockAmount

                        for qualityID, use in pairs(restockOptions.restockPerQuality) do
                            if use then
                                local item = recipeData.resultData.itemsByQuality[qualityID]
                                if item then
                                    local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(item:GetItemID(),
                                        true, false,
                                        true, recipeData:GetCrafterUID())
                                    restockAmount = restockAmount - itemCount
                                end
                            end
                        end
                    end

                    if restockAmount > 0 then
                        CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, restockAmount)
                    end
                end

                CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
            end, function()
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

function CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
    if CraftSimOptions.craftQueueShoppingListPerCharacter then
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

    for crafterUID, _ in pairs(CraftSimRecipeDataCache.cachedRecipeIDs) do
        CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
            " " .. tostring(crafterUID))
    end
end

function CraftSim.CRAFTQ.CreateAuctionatorShoppingListPerCharacter()
    print("CraftSim.CRAFTQ:CreateAuctionatorShoppingListPerCharacter", false, true)

    CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()

    CraftSim.UTIL:StartProfiling("CreateAuctionatorShoppingListPerCharacter")
    local reagentMapPerCharacter = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        local crafterUID = craftQueueItem.recipeData:GetCrafterUID()
        reagentMapPerCharacter[crafterUID] = reagentMapPerCharacter[crafterUID] or {}
        for _, reagent in pairs(requiredReagents) do
            if reagent.hasQuality then
                for qualityID, reagentItem in pairs(reagent.items) do
                    reagentMapPerCharacter[crafterUID][reagentItem.item:GetItemID()] = reagentMapPerCharacter
                        [crafterUID][reagentItem.item:GetItemID()] or {
                            itemName = reagentItem.item:GetItemName(),
                            qualityID = nil,
                            quantity = 0
                        }
                    reagentMapPerCharacter[crafterUID][reagentItem.item:GetItemID()].quantity = reagentMapPerCharacter
                        [crafterUID][reagentItem.item:GetItemID()]
                        .quantity + (reagentItem.quantity * craftQueueItem.amount)
                    reagentMapPerCharacter[crafterUID][reagentItem.item:GetItemID()].qualityID = qualityID
                end
            else
                local reagentItem = reagent.items[1]
                reagentMapPerCharacter[crafterUID][reagentItem.item:GetItemID()] = reagentMapPerCharacter[crafterUID]
                    [reagentItem.item:GetItemID()] or {
                        itemName = reagentItem.item:GetItemName(),
                        qualityID = nil,
                        quantity = 0
                    }
                reagentMapPerCharacter[crafterUID][reagentItem.item:GetItemID()].quantity = reagentMapPerCharacter
                    [crafterUID][reagentItem.item:GetItemID()].quantity +
                    (reagentItem.quantity * craftQueueItem.amount)
                print("reagentMap Build: " .. tostring(reagentItem.item:GetItemLink()))
                print("quantity: " .. tostring(reagentMapPerCharacter[crafterUID][reagentItem.item:GetItemID()].quantity))
            end
        end
        local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
        for _, optionalReagent in pairs(activeReagents) do
            if not GUTIL:isItemSoulbound(optionalReagent.item:GetItemID()) then
                reagentMapPerCharacter[crafterUID][optionalReagent.item:GetItemID()] = reagentMapPerCharacter
                    [crafterUID][optionalReagent.item:GetItemID()] or {
                        itemName = optionalReagent.item:GetItemName(),
                        qualityID = optionalReagent.qualityID,
                        quantity = 0
                    }
                reagentMapPerCharacter[crafterUID][optionalReagent.item:GetItemID()].quantity = reagentMapPerCharacter
                    [crafterUID][optionalReagent.item:GetItemID()]
                    .quantity + craftQueueItem.amount
            end
        end
    end

    for crafterUID, reagentMap in pairs(reagentMapPerCharacter) do
        --- convert to Auctionator Search Strings and deduct item count
        local searchStrings = GUTIL:Map(reagentMap, function(info, itemID)
            if GUTIL:isItemSoulbound(itemID) then
                return nil
            end

            local itemCount = CraftSim.CACHE.ITEM_COUNT:Get(itemID, true, false, true, crafterUID)
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


    CraftSim.UTIL:StopProfiling("CreateAuctionatorShoppingListPerCharacter")
end

function CraftSim.CRAFTQ.CreateAuctionatorShoppingListAll()
    print("CraftSim.CRAFTQ:CreateAuctionatorShoppingList", false, true)

    CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()

    CraftSim.UTIL:StartProfiling("CreateAuctionatorShopping")
    local reagentMap = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if reagent.hasQuality then
                for qualityID, reagentItem in pairs(reagent.items) do
                    reagentMap[reagentItem.item:GetItemID()] = reagentMap[reagentItem.item:GetItemID()] or {
                        itemName = reagentItem.item:GetItemName(),
                        qualityID = nil,
                        quantity = 0
                    }
                    reagentMap[reagentItem.item:GetItemID()].quantity = reagentMap[reagentItem.item:GetItemID()]
                        .quantity + (reagentItem.quantity * craftQueueItem.amount)
                    reagentMap[reagentItem.item:GetItemID()].qualityID = qualityID
                end
            else
                local reagentItem = reagent.items[1]
                reagentMap[reagentItem.item:GetItemID()] = reagentMap[reagentItem.item:GetItemID()] or {
                    itemName = reagentItem.item:GetItemName(),
                    qualityID = nil,
                    quantity = 0
                }
                reagentMap[reagentItem.item:GetItemID()].quantity = reagentMap[reagentItem.item:GetItemID()].quantity +
                    (reagentItem.quantity * craftQueueItem.amount)
                print("reagentMap Build: " .. tostring(reagentItem.item:GetItemLink()))
                print("quantity: " .. tostring(reagentMap[reagentItem.item:GetItemID()].quantity))
            end
        end
        local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
        for _, optionalReagent in pairs(activeReagents) do
            if not GUTIL:isItemSoulbound(optionalReagent.item:GetItemID()) then
                reagentMap[optionalReagent.item:GetItemID()] = reagentMap[optionalReagent.item:GetItemID()] or {
                    itemName = optionalReagent.item:GetItemName(),
                    qualityID = optionalReagent.qualityID,
                    quantity = 0
                }
                reagentMap[optionalReagent.item:GetItemID()].quantity = reagentMap[optionalReagent.item:GetItemID()]
                    .quantity + craftQueueItem.amount
            end
        end
    end

    local crafterUIDs = GUTIL:Map(CraftSim.CRAFTQ.craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)

    --- convert to Auctionator Search Strings and deduct item count (of all crafters total)
    local searchStrings = GUTIL:Map(reagentMap, function(info, itemID)
        if GUTIL:isItemSoulbound(itemID) then
            return nil
        end
        -- subtract the total item count of all crafter's cached inventory
        local totalItemCount = GUTIL:Fold(crafterUIDs, 0, function(itemCount, crafterUID)
            local itemCountForCrafter = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(itemID, true, false, true,
                crafterUID)
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

    CraftSim.UTIL:StopProfiling("CreateAuctionatorShopping")
end

function CraftSim.CRAFTQ:TRADE_SKILL_ITEM_CRAFTED_RESULT()
    print("onCraftResult")
    if CraftSim.CRAFTQ.currentlyCraftedRecipeData then
        print("have recipeData, now decrement")
        -- decrement by one and refresh list
        local newAmount = CraftSim.CRAFTQ.craftQueue:SetAmount(CraftSim.CRAFTQ.currentlyCraftedRecipeData, -1, true)
        if newAmount and newAmount <= 0 and CraftSimOptions.craftQueueFlashTaskbarOnCraftFinished then
            FlashClientIcon()
        end
        CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
    end
end

--- only for craft queue display update's flash cache
function CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(itemID, bank, uses, reagentbank, crafterUID)
    local itemCount = (CraftSim.CRAFTQ.itemCountCache and CraftSim.CRAFTQ.itemCountCache[itemID]) or nil
    if not itemCount then
        itemCount = CraftSim.CACHE.ITEM_COUNT:Get(itemID, bank, uses, reagentbank, crafterUID)
    end
    return itemCount
end

---@param itemName string
---@param qualityID number | string?
---@param quantity number?
---@return string auctionatorShoppingListItemString
function CraftSim.CRAFTQ:GetAuctionatorShoppingListItemString(itemName, qualityID, quantity)
    return '"' .. itemName .. '"' .. ';;0;0;0;0;0;0;0;0;;' .. (qualityID or '#') .. ';;' .. (quantity or '')
end

---@return string name
---@return number | nil qualityID
---@return number | nil quantity
function CraftSim.CRAFTQ:ParseAuctionatorShoppingListItemString(itemString)
    local name, qualityID, quantity = itemString:match('"([^"]+)";;0;0;0;0;0;0;0;0;;(%S+);;(%d+)$')
    if qualityID == '#' then
        qualityID = nil
    else
        qualityID = tonumber(qualityID)
    end
    if quantity == '' then
        quantity = nil
    else
        quantity = tonumber(quantity)
    end
    return name, qualityID, quantity
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
    CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID] = CraftSimOptions.craftQueueRestockPerRecipeOptions
        [recipeID] or {}
    return {
        enabled = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID].enabled or false,
        profitMarginThreshold = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID].profitMarginThreshold or 0,
        restockAmount = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID].restockAmount or 1,
        restockPerQuality = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID].restockPerQuality or {},
        saleRateThreshold = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID].saleRateThreshold or 0,
        saleRatePerQuality = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeID].saleRatePerQuality or {}
    }
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
        if CraftSim.MAIN.currentRecipeData then
            recipeData = CraftSim.MAIN.currentRecipeData
        end
    end

    if not recipeData then
        return
    end

    -- needs to be a copy or we modify it when we edit it in the queue..
    CraftSim.CRAFTQ:AddRecipe(recipeData:Copy())
end

function CraftSim.CRAFTQ:OnRecipeEditSave()
    -- TODO
    print("OnRecipeEditSave")
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)

    editRecipeFrame:Hide()
end
