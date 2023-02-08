_, CraftSim = ...

---@class CraftSim.ReagentItem
---@field quantity number
---@field item ItemMixin

CraftSim.ReagentItem = CraftSim.Object:extend()

function CraftSim.ReagentItem:new(itemID)
    self.quantity = 0
    self.item = Item:CreateFromItemID(itemID)
end