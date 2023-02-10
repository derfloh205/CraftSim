_, CraftSim = ...

---@class CraftSim.SalvageReagentSlot
---@field possibleItems ItemMixin[]
---@field activeItem? ItemMixin
---@field requiredQuantity number

CraftSim.SalvageReagentSlot = CraftSim.Object:extend()

function CraftSim.SalvageReagentSlot:new(recipeData)
    self.possibleItems = {}
    local itemIDs = C_TradeSkillUI.GetSalvagableItemIDs(recipeData.recipeID)
    if itemIDs then
        self.possibleItems = CraftSim.UTIL:Map(itemIDs, function(itemID) return Item:CreateFromItemID(itemID) end)
        self.requiredQuantity = 0
    end
end

function CraftSim.SalvageReagentSlot:SetItem(itemID)
    local item = CraftSim.UTIL:Find(self.possibleItems, function(item) return item:GetItemID() == itemID end)

    if not item then
        error("Error CraftSim.SalvageReagentSlot: Trying to set item which is not in possible salvage item list")
    end

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