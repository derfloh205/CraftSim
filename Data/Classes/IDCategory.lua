---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.IDCategory : CraftSim.CraftSimObject
CraftSim.IDCategory = CraftSim.CraftSimObject:extend()

---@param categoryID number
---@param subtypeIDs number[]
function CraftSim.IDCategory:new(categoryID, subtypeIDs)
    self.categoryID = categoryID
    self.subtypeIDs = subtypeIDs
end

---@param idCategory CraftSim.IDCategory
function CraftSim.IDCategory:Merge(idCategory)
    self.categoryID = idCategory.categoryID
    self.subtypeIDs = CraftSim.GUTIL:ToSet(CraftSim.GUTIL:Concat({ idCategory.subtypeIDs, self.subtypeIDs }))
end
