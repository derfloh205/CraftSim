_, CraftSim = ...

CraftSimAPI = {}

---Fetch a CraftSim.RecipeData instance for a recipeID
---@param recipeID number
---@param isRecraft? boolean optional
---@return CraftSim.RecipeData recipeData
function CraftSimAPI:GetRecipeData(recipeID, isRecraft)
    return CraftSim.RecipeData(recipeID, isRecraft)
end