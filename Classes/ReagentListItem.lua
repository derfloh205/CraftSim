---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.ReagentListItem : CraftSim.CraftSimObject
CraftSim.ReagentListItem = CraftSim.CraftSimObject:extend()

---@param itemID ItemID
---@param quantity number
---@param currencyID CurrencyID?
function CraftSim.ReagentListItem:new(itemID, quantity, currencyID)
    self.itemID = itemID
    self.quantity = quantity
    self.currencyID = currencyID
end
