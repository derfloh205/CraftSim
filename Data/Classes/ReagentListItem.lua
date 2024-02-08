---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.ReagentListItem : CraftSim.CraftSimObject
CraftSim.ReagentListItem = CraftSim.CraftSimObject:extend()

---@param itemID number
---@param quantity number
function CraftSim.ReagentListItem:new(itemID, quantity)
    self.itemID = itemID
    self.quantity = quantity
end
