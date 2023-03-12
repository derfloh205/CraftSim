_, CraftSim = ...

---@class CraftSim.IDCategory
CraftSim.IDCategory = CraftSim.Object:extend()

---@param categoryID number
---@param subtypeIDs number[]
function CraftSim.IDCategory:new(categoryID, subtypeIDs)
    self.categoryID = categoryID
    self.subtypeIDs = subtypeIDs
end

---@param idCategory CraftSim.IDCategory
function CraftSim.IDCategory:Merge(idCategory)
    self.categoryID = idCategory.categoryID
    self.subtypeIDs = CraftSim.GUTIL:ToSet(CraftSim.GUTIL:Concat({idCategory.subtypeIDs, self.subtypeIDs}))
end