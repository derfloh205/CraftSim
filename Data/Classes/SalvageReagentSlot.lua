_, CraftSim = ...

---@class CraftSim.SalvageReagentSlot
---@field possibleItems ItemMixin[]
---@field activeItem? ItemMixin

CraftSim.SalvageReagentSlot = CraftSim.Object:extend()

function CraftSim.SalvageReagentSlot:new(recipeData)
    self.possibleItems = {}
    local itemIDs = C_TradeSkillUI.GetSalvagableItemIDs(recipeData.recipeID)
    if itemIDs then
        self.possibleItems = CraftSim.UTIL:Map(itemIDs, function(itemID) return Item:CreateFromItemID(itemID) end)
    end
end

function CraftSim.SalvageReagentSlot:SetItem(itemID)
    local item = CraftSim.UTIL:Find(self.possibleItems, function(item) return item:GetItemID() == itemID end)

    if not item then
        error("Error CraftSim.SalvageReagentSlot: Trying to set item which is not in possible salvage item list")
    end

    self.activeItem = item
end