---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.REAGENT_SHOPPING
CraftSim.REAGENT_SHOPPING = {}

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Modules.ReagentShopping")

---@class CraftSim.REAGENT_SHOPPING.ShoppingListItem
---@field itemID number
---@field itemName string
---@field qualityID number?
---@field neededQuantity number
---@field inventoryQuantity number
---@field toBuyQuantity number
---@field isVendorItem boolean
---@field unitPrice number
---@field totalPrice number

---@type CraftSim.REAGENT_SHOPPING.ShoppingListItem[]
CraftSim.REAGENT_SHOPPING.shoppingList = {}

--- Builds a reagent map from the current craft queue, deducting inventory counts.
---@return CraftSim.REAGENT_SHOPPING.ShoppingListItem[]
function CraftSim.REAGENT_SHOPPING:BuildShoppingList()
    print("BuildShoppingList", false, true)

    local reagentMap = {}

    -- Build reagent map from craft queue items
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if not reagent:IsOrderReagentIn(craftQueueItem.recipeData) then
                if reagent.hasQuality then
                    for qualityID, reagentItem in pairs(reagent.items) do
                        local itemID = reagentItem.item:GetItemID()
                        local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                        if not isSelfCrafted then
                            reagentMap[itemID] = reagentMap[itemID] or {
                                itemName = reagentItem.item:GetItemName(),
                                qualityID = nil,
                                quantity = 0,
                            }
                            reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                                (reagentItem.quantity * craftQueueItem.amount)
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
                            quantity = 0,
                        }
                        reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                            (reagentItem.quantity * craftQueueItem.amount)
                    end
                end
            end
        end

        -- Handle optional reagents
        local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
        local quantityMap = {}
        if craftQueueItem.recipeData:HasRequiredSelectableReagent() then
            local slot = craftQueueItem.recipeData.reagentData.requiredSelectableReagentSlot
            if slot and slot:IsAllocated() and not slot:IsCurrency() and not slot:IsOrderReagentIn(craftQueueItem.recipeData) then
                tinsert(activeReagents, slot.activeReagent)
                quantityMap[slot.activeReagent.item:GetItemID()] = slot.maxQuantity or 1
            end
        end
        for _, optionalReagent in pairs(activeReagents) do
            if not optionalReagent:IsCurrency() then
                local itemID = optionalReagent.item:GetItemID()
                local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                local isOrderReagent = optionalReagent:IsOrderReagentIn(craftQueueItem.recipeData)
                local qualityID = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID)
                if not isOrderReagent and not isSelfCrafted and not GUTIL:isItemSoulbound(itemID) then
                    local allocatedQuantity = quantityMap[itemID] or 1
                    reagentMap[itemID] = reagentMap[itemID] or {
                        itemName = optionalReagent.item:GetItemName(),
                        qualityID = qualityID,
                        quantity = 0,
                    }
                    reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                        allocatedQuantity * craftQueueItem.amount
                end
            end
        end
    end

    -- Get unique crafter UIDs from queue
    local crafterUIDs = GUTIL:Map(CraftSim.CRAFTQ.craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)
    crafterUIDs = GUTIL:ToSet(crafterUIDs)

    -- Build shopping list with inventory deductions and pricing
    local shoppingList = {}
    for itemID, info in pairs(reagentMap) do
        itemID = CraftSim.CRAFTQ:GetNonSoulboundAlternativeItemID(itemID)
        if itemID then
            -- Total inventory count across all crafters (including warbank)
            local totalItemCount = GUTIL:Fold(crafterUIDs, 0, function(itemCount, crafterUID)
                local itemCountForCrafter = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
                return itemCount + itemCountForCrafter
            end)

            local toBuyQuantity = math.max(info.quantity - (tonumber(totalItemCount) or 0), 0)
            local unitPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true) or 0

            ---@type CraftSim.REAGENT_SHOPPING.ShoppingListItem
            local listItem = {
                itemID = itemID,
                itemName = info.itemName or "",
                qualityID = info.qualityID,
                neededQuantity = info.quantity,
                inventoryQuantity = tonumber(totalItemCount) or 0,
                toBuyQuantity = toBuyQuantity,
                isVendorItem = false,
                unitPrice = unitPrice,
                totalPrice = unitPrice * toBuyQuantity,
            }

            if toBuyQuantity > 0 then
                tinsert(shoppingList, listItem)
            end
        end
    end

    CraftSim.REAGENT_SHOPPING.shoppingList = shoppingList
    return shoppingList
end

--- Returns the total cost of all items in the current shopping list.
---@return number totalCost
function CraftSim.REAGENT_SHOPPING:GetTotalCost()
    local total = 0
    for _, item in pairs(CraftSim.REAGENT_SHOPPING.shoppingList) do
        total = total + item.totalPrice
    end
    return total
end

--- Removes a specific item from the shopping list by itemID.
---@param itemID number
function CraftSim.REAGENT_SHOPPING:RemoveItemFromList(itemID)
    CraftSim.REAGENT_SHOPPING.shoppingList = GUTIL:Filter(CraftSim.REAGENT_SHOPPING.shoppingList, function(item)
        return item.itemID ~= itemID
    end)
end

--- Creates an Auctionator shopping list from the current shopping list (export feature).
function CraftSim.REAGENT_SHOPPING:ExportToAuctionator()
    if not Auctionator then
        print("Auctionator not loaded, cannot export")
        return
    end

    local addonName = "CraftSim"
    local listName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME

    -- Delete existing list first
    CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(listName)

    local searchStrings = GUTIL:Map(CraftSim.REAGENT_SHOPPING.shoppingList, function(item)
        if item.toBuyQuantity <= 0 then return nil end
        local searchTerm = {
            searchString = item.itemName,
            tier = item.qualityID,
            quantity = item.toBuyQuantity,
            isExact = true,
        }
        return Auctionator.API.v1.ConvertToSearchString(addonName, searchTerm)
    end)

    if #searchStrings > 0 then
        Auctionator.API.v1.CreateShoppingList(addonName, listName, searchStrings)
    end
end

--- Returns only vendor-purchasable items from the shopping list.
---@return CraftSim.REAGENT_SHOPPING.ShoppingListItem[]
function CraftSim.REAGENT_SHOPPING:GetVendorItems()
    return GUTIL:Filter(CraftSim.REAGENT_SHOPPING.shoppingList, function(item)
        return item.isVendorItem
    end)
end

--- Returns only auction house items from the shopping list.
---@return CraftSim.REAGENT_SHOPPING.ShoppingListItem[]
function CraftSim.REAGENT_SHOPPING:GetAuctionHouseItems()
    return GUTIL:Filter(CraftSim.REAGENT_SHOPPING.shoppingList, function(item)
        return not item.isVendorItem
    end)
end

--- Clears the entire shopping list.
function CraftSim.REAGENT_SHOPPING:ClearList()
    wipe(CraftSim.REAGENT_SHOPPING.shoppingList)
end
