_, CraftSim = ...

---@class CraftSim.CraftQueue
CraftSim.CraftQueue = CraftSim.Object:extend()

function CraftSim.CraftQueue:new()
    ---@type CraftSim.CraftQueueItem[]
    self.craftItems = {}
end

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CraftQueue:AddRecipe(recipeData, amount)
    amount = amount or 1
    -- TODO: check if there is already a CraftQueueItem for the given recipeData configuration, if yes, add to amount, if not create new one
    -- via comparison - checkstring / checksum
    local craftItem = CraftSim.CraftQueueItem(recipeData, amount)
    
    table.insert(self.craftItems, craftItem)
end