---@class CraftSim.ReagentListItem
---@field itemID number
---@field quantity number

_, CraftSim = ...

CraftSim.ReagentListItem = CraftSim.Object:extend()

function CraftSim.ReagentListItem:new(itemID, quantity)
    self.itemID = itemID
    self.quantity = quantity
end