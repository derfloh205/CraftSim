---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SalvageReagentSlot : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData): CraftSim.SalvageReagentSlot
CraftSim.SalvageReagentSlot = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.SalvageReagentSlot:new(recipeData)
    ---@type ItemMixin[]
    self.possibleItems = {}
    local itemIDs = C_TradeSkillUI.GetSalvagableItemIDs(recipeData.recipeID)
    if itemIDs then
        self.possibleItems = CraftSim.GUTIL:Map(itemIDs, function(itemID) return Item:CreateFromItemID(itemID) end)
        self.requiredQuantity = 0
    end

    self.activeItem = nil
    self.recipeData = recipeData
end

---@return ItemMixin activeItem
function CraftSim.SalvageReagentSlot:SetCheapestItem()
    local cheapestItem = GUTIL:Fold(self.possibleItems, self.possibleItems[1], function(cheapest, item)
        local cheapestItemID = cheapest:GetItemID()
        local itemID = item:GetItemID()
        local cheapestPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(cheapestItemID, true)
        local itemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true)
        if itemPrice < cheapestPrice then
            return item
        else
            return cheapest
        end
    end)
    self.activeItem = cheapestItem
    return self.activeItem
end

---@return ItemMixin activeItem
function CraftSim.SalvageReagentSlot:SetCheapestOwnedItem()
    local ownedItems = GUTIL:Filter(self.possibleItems, function(item)
        return C_Item.GetItemCount(item:GetItemID(), true, false, true, true) > 0
    end)

    if #ownedItems == 0 then
        return self:SetCheapestItem()
    end

    local cheapestOwnedItem = GUTIL:Fold(ownedItems, ownedItems[1], function(cheapest, item)
        local cheapestItemID = cheapest:GetItemID()
        local itemID = item:GetItemID()
        local cheapestPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(cheapestItemID, true)
        local itemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true)
        if itemPrice < cheapestPrice then
            return item
        else
            return cheapest
        end
    end)

    self.activeItem = cheapestOwnedItem
    return self.activeItem
end

---@param itemID number
function CraftSim.SalvageReagentSlot:SetItem(itemID)
    local item = CraftSim.GUTIL:Find(self.possibleItems, function(item) return item:GetItemID() == itemID end)

    if not item then
        error("Error CraftSim.SalvageReagentSlot: Trying to set item which is not in possible salvage item list")
    end
    ---@type ItemMixin?
    self.activeItem = item
end

function CraftSim.SalvageReagentSlot:Debug()
    local debugLines = {
        'activeItem: ' .. (self.activeItem and (self.activeItem:GetItemLink() or self.activeItem:GetItemID()) or "None"),
        'Possible Salvage Items: ',
    }

    for _, item in pairs(self.possibleItems) do
        table.insert(debugLines, "-" .. (item:GetItemLink() or item:GetItemID()))
    end

    return debugLines
end

function CraftSim.SalvageReagentSlot:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    local itemList = {}
    for _, item in pairs(self.possibleItems) do
        table.insert(itemList, {
            itemID = item:GetItemID(),
            itemLink = item:GetItemLink()
        })
    end
    jb:AddList("possibleReagents", itemList)
    if self.activeItem then
        jb:Add("activeItemID", self.activeItem:GetItemID())
    else
        jb:Add("activeItemID", nil)
    end
    jb:Add("requiredQuantity", self.requiredQuantity, true)
    jb:End()
    return jb.json
end

---@return CraftSim.SalvageReagentSlot
function CraftSim.SalvageReagentSlot:Copy()
    local copy = CraftSim.SalvageReagentSlot(self.recipeData)
    copy.activeItem = self.recipeData.reagentData.salvageReagentSlot.activeItem
    copy.requiredQuantity = self.requiredQuantity
    return copy
end
