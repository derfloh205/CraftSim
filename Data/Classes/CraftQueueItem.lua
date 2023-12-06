_, CraftSim = ...

---@class CraftSim.CraftQueueItem
CraftSim.CraftQueueItem = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CraftQueueItem:new(recipeData, amount)
    ---@type CraftSim.RecipeData
    self.recipeData = recipeData
    ---@type number
    self.amount = amount or 1
end