_, CraftSim = ...

---@class CraftSim.OptionalReagent
---@field item ItemMixin

CraftSim.OptionalReagent = CraftSim.Object:extend()

---@param craftingReagent CraftingReagent
function CraftSim.OptionalReagent:new(craftingReagent)
    self.item = Item:CreateFromItemID(craftingReagent.itemID)
end

function CraftSim.OptionalReagent:Debug()
    return {
        self.item:GetItemLink() or self.item:GetItemID()
    }
end