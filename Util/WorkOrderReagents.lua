---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.WORK_ORDER_REAGENTS
CraftSim.WORK_ORDER_REAGENTS = {}

--[[
  Work-order reagent policy (NPC patron and personal share these rules).

  Case BYO  (reagentState=None):
    Nothing is escrowed. order.reagents may still list a shopping list — ignore for strip/shopping.

  Case SOME (reagentState=Some):
    Customer escrowed some mats. Strip/skip those; crafter provides the rest.

  Case ALL  (reagentState=All):
    Customer escrowed all required mats. Strip escrowed rows; only crafter optionals remain.

  Required mats vs optionals use DIFFERENT ownership rules on purpose:

  Required (quality / non-quality reagents):
    Customer-provided only when an item is actually escrowed (itemID + qty > 0).
    Do NOT use empty Customer dataSlotIndex — that wrongly marks crafter mats
    (e.g. Peerless Plumage on SOME) as NPC-provided.

  Optionals (missive / embellishment / finishing / selectable):
    Customer owns the slot when source=Customer (even if empty), or when an
    item/currency is escrowed into that slot. Empty Customer slots must not
    become crafter shopping requirements.
]]

---@alias CraftSim.WorkOrderReagentCase "byo"|"some"|"all"

--- Classify how reagents are provided on a work order.
---@param orderData CraftingOrderInfo?
---@return CraftSim.WorkOrderReagentCase
function CraftSim.WORK_ORDER_REAGENTS:GetCase(orderData)
    if not orderData then
        return "byo"
    end
    local state = orderData.reagentState
    if state == Enum.CraftingOrderReagentsType.All then
        return "all"
    end
    if state == Enum.CraftingOrderReagentsType.Some then
        return "some"
    end
    return "byo"
end

--- Canonical CraftingReagent on a Blizzard order.reagents entry.
---@param reagentInfo table?
---@return CraftingReagent?
function CraftSim.WORK_ORDER_REAGENTS:GetCraftingReagent(reagentInfo)
    if not reagentInfo then
        return nil
    end
    if reagentInfo.reagentInfo and reagentInfo.reagentInfo.reagent then
        return reagentInfo.reagentInfo.reagent
    end
    if reagentInfo.reagent then
        if reagentInfo.reagent.reagent
            and (reagentInfo.reagent.reagent.itemID or reagentInfo.reagent.reagent.currencyID) then
            return reagentInfo.reagent.reagent
        end
        if reagentInfo.reagent.itemID or reagentInfo.reagent.currencyID then
            return reagentInfo.reagent
        end
    end
    return nil
end

--- Normalize an order.reagents row. Pass recipeData when slotIndex→dataSlotIndex resolve is needed.
---@param reagentInfo table?
---@param recipeData CraftSim.RecipeData?
---@return { dataSlotIndex: number?, itemID: number?, currencyID: number?, slotIndex: number? }
function CraftSim.WORK_ORDER_REAGENTS:GetDescriptor(reagentInfo, recipeData)
    if not reagentInfo then
        return { dataSlotIndex = nil, itemID = nil, currencyID = nil, slotIndex = nil }
    end

    local slotIndex = reagentInfo.slotIndex
    local craftingReagent = self:GetCraftingReagent(reagentInfo)
    local itemID = craftingReagent and craftingReagent.itemID
    local currencyID = craftingReagent and craftingReagent.currencyID
    if itemID == 0 then itemID = nil end
    if currencyID == 0 then currencyID = nil end

    local dataSlotIndex = reagentInfo.dataSlotIndex
        or (reagentInfo.reagentInfo and reagentInfo.reagentInfo.dataSlotIndex)
        or (reagentInfo.reagent and reagentInfo.reagent.dataSlotIndex)

    if not dataSlotIndex and slotIndex and recipeData and recipeData.recipeSchematic then
        local schematicSlot = recipeData.recipeSchematic.reagentSlotSchematics[slotIndex]
        dataSlotIndex = schematicSlot and schematicSlot.dataSlotIndex
    end

    return { dataSlotIndex = dataSlotIndex, itemID = itemID, currencyID = currencyID, slotIndex = slotIndex }
end

---@param reagentInfo table?
---@return number?
local function RowQuantity(reagentInfo)
    if not reagentInfo then
        return nil
    end
    return (reagentInfo.reagentInfo and reagentInfo.reagentInfo.quantity) or reagentInfo.quantity
end

--- Row-level escrow check used by optionals and strip keys.
--- Customer source (even empty) OR Any/missing with a real supplied item/currency (qty > 0).
---@param reagentInfo table?
---@param orderData CraftingOrderInfo?
---@param recipeData CraftSim.RecipeData?
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:IsEscrowedRow(reagentInfo, orderData, recipeData)
    if not reagentInfo or not orderData then
        return false
    end
    if self:GetCase(orderData) == "byo" then
        return false
    end

    local source = reagentInfo.source
    if source == Enum.CraftingOrderReagentSource.Crafter
        or source == Enum.CraftingOrderReagentSource.None then
        return false
    end

    if source == Enum.CraftingOrderReagentSource.Customer then
        return true
    end

    -- Any / missing: only when something was actually supplied (NPC SOME often uses Any).
    local d = self:GetDescriptor(reagentInfo, recipeData)
    if not d.itemID and not d.currencyID then
        return false
    end
    local quantity = RowQuantity(reagentInfo)
    if quantity ~= nil and quantity <= 0 then
        return false
    end
    return true
end

--- Required-mat escrow: item must be present with qty > 0 (no empty Customer-slot shortcut).
---@param reagentInfo table?
---@param orderData CraftingOrderInfo?
---@param recipeData CraftSim.RecipeData?
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:IsEscrowedRequiredRow(reagentInfo, orderData, recipeData)
    if not self:IsEscrowedRow(reagentInfo, orderData, recipeData) then
        return false
    end
    local d = self:GetDescriptor(reagentInfo, recipeData)
    if not d.itemID then
        return false
    end
    local quantity = RowQuantity(reagentInfo)
    if quantity ~= nil and quantity <= 0 then
        return false
    end
    return true
end

--- True when this itemID is an escrowed required mat on the order.
---@param itemID number?
---@param orderData CraftingOrderInfo?
---@param recipeData CraftSim.RecipeData?
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:IsCustomerRequiredItem(itemID, orderData, recipeData)
    if not itemID or not orderData then
        return false
    end
    for _, reagentInfo in ipairs(orderData.reagents or {}) do
        if self:IsEscrowedRequiredRow(reagentInfo, orderData, recipeData) then
            local d = self:GetDescriptor(reagentInfo, recipeData)
            if d.itemID == itemID then
                return true
            end
        end
    end
    return false
end

--- True when the customer owns this optional/finishing/selectable dataSlotIndex (even if empty).
---@param dataSlotIndex number?
---@param orderData CraftingOrderInfo?
---@param recipeData CraftSim.RecipeData?
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:IsCustomerOptionalSlot(dataSlotIndex, orderData, recipeData)
    if not dataSlotIndex or not orderData then
        return false
    end
    if self:GetCase(orderData) == "byo" then
        return false
    end
    for _, reagentInfo in ipairs(orderData.reagents or {}) do
        if self:IsEscrowedRow(reagentInfo, orderData, recipeData) then
            local d = self:GetDescriptor(reagentInfo, recipeData)
            if d.dataSlotIndex == dataSlotIndex then
                return true
            end
        end
    end
    return false
end

--- True when this optional item/currency is escrowed on the order.
---@param itemID number?
---@param currencyID number?
---@param orderData CraftingOrderInfo?
---@param recipeData CraftSim.RecipeData?
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:IsCustomerOptionalReagent(itemID, currencyID, orderData, recipeData)
    if not orderData or (not itemID and not currencyID) then
        return false
    end
    for _, reagentInfo in ipairs(orderData.reagents or {}) do
        if self:IsEscrowedRow(reagentInfo, orderData, recipeData) then
            local d = self:GetDescriptor(reagentInfo, recipeData)
            if itemID and d.itemID == itemID then
                return true
            end
            if currencyID and d.currencyID == currencyID then
                return true
            end
        end
    end
    return false
end

--- Crafter must provide this required reagent slot (shopping / HasEnough / costs).
---@param reagent CraftSim.Reagent
---@param recipeData CraftSim.RecipeData
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:ShouldCrafterProvideRequired(reagent, recipeData)
    if not recipeData or not recipeData.orderData or not reagent then
        return true
    end
    return not GUTIL:Some(reagent.items, function(reagentItem)
        local item = reagentItem.item
        return item and self:IsCustomerRequiredItem(item:GetItemID(), recipeData.orderData, recipeData)
    end)
end

--- Crafter must provide this optional/finishing/selectable slot.
---@param dataSlotIndex number?
---@param activeItemID number?
---@param activeCurrencyID number?
---@param recipeData CraftSim.RecipeData
---@return boolean
function CraftSim.WORK_ORDER_REAGENTS:ShouldCrafterProvideOptional(dataSlotIndex, activeItemID, activeCurrencyID,
                                                                  recipeData)
    if not recipeData or not recipeData.orderData then
        return true
    end
    if self:IsCustomerOptionalSlot(dataSlotIndex, recipeData.orderData, recipeData) then
        return false
    end
    if self:IsCustomerOptionalReagent(activeItemID, activeCurrencyID, recipeData.orderData, recipeData) then
        return false
    end
    return true
end

--- Keys for craft-tbl stripping (SOME/ALL). dataSlotIndex only for explicit Customer source.
---@param orderData CraftingOrderInfo?
---@param recipeData CraftSim.RecipeData?
---@return table<number, boolean> dataSlotIndexSet
---@return table<number, boolean> itemIDSet
---@return table<number, boolean> currencyIDSet
function CraftSim.WORK_ORDER_REAGENTS:GetEscrowStripKeys(orderData, recipeData)
    ---@type table<number, boolean>
    local dataSlotIndexSet = {}
    ---@type table<number, boolean>
    local itemIDSet = {}
    ---@type table<number, boolean>
    local currencyIDSet = {}

    if not orderData or self:GetCase(orderData) == "byo" then
        return dataSlotIndexSet, itemIDSet, currencyIDSet
    end

    for _, reagentInfo in ipairs(orderData.reagents or {}) do
        if self:IsEscrowedRow(reagentInfo, orderData, recipeData) then
            local d = self:GetDescriptor(reagentInfo, recipeData)
            if d.dataSlotIndex
                and reagentInfo.source == Enum.CraftingOrderReagentSource.Customer then
                dataSlotIndexSet[d.dataSlotIndex] = true
            end
            if d.itemID then
                itemIDSet[d.itemID] = true
            end
            if d.currencyID then
                currencyIDSet[d.currencyID] = true
            end
        end
    end

    return dataSlotIndexSet, itemIDSet, currencyIDSet
end
