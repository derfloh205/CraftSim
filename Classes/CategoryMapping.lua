---@class CraftSim
local CraftSim = select(2, ...)

---@class CategoryMapping : CraftSim.CraftSimObject
CraftSim.CategoryMapping = CraftSim.CraftSimObject:extend()

---@param categoryID number
---@param subIDs number|string|table[]
function CraftSim.CategoryMapping:new(categoryID, subIDs)
    self.categoryID = categoryID
    self.subIDs = subIDs
end
