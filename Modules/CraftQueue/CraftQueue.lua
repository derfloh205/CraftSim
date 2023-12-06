_, CraftSim = ...

CraftSim.CRAFTQ = {}

---@type CraftSim.CraftQueue
CraftSim.CRAFTQ.craftQueue = nil

---@type CraftSim.CraftQueueItem | nil
CraftSim.CRAFTQ.currentlyCraftedQueueItem = nil

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CRAFTQ:AddRecipe(recipeData, amount)
    amount = amount or 1

    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})
    CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, amount)

    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CraftQueue({})
    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
end

function CraftSim.CRAFTQ:ImportRecipeScan()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})
    local profitableRecipes = CraftSim.GUTIL:Filter(CraftSim.RECIPE_SCAN.currentResults, 
    ---@param recipeData CraftSim.RecipeData
    function (recipeData)
        if recipeData.averageProfitCached then
            return recipeData.averageProfitCached > 0
        else
            return false
        end
    end)
    for _, recipeData in pairs(profitableRecipes) do
        CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, 1) -- TODO: make configureable per recipe, maybe via tsm string? as option or some fixed stuff
    end

    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()    
end