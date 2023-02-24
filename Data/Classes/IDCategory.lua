_, CraftSim = ...

---@class CraftSim.IDCategory
---@field categoryID number
---@field subtypeIDs number[]

CraftSim.IDCategory = CraftSim.Object:extend()

---@params categoryID number
---@params subtypeIDs number[]
function CraftSim.IDCategory:new(categoryID, subtypeIDs)
    self.categoryID = categoryID
    self.subtypeIDs = subtypeIDs
end

---@param idCategory CraftSim.IDCategory
function CraftSim.IDCategory:Merge(idCategory)
    self.categoryID = idCategory.categoryID
    self.subtypeIDs = CraftSim.GUTIL:ToSet(CraftSim.GUTIL:Concat({idCategory.subtypeIDs, self.subtypeIDs}))
end