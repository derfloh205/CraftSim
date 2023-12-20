---@class CraftSim
local CraftSim = select(2, ...)

CraftSimAPI = {}

---Fetch a CraftSim.RecipeData instance for a recipeID
---@param recipeID number
---@param isRecraft? boolean optional
---@return CraftSim.RecipeData recipeData
function CraftSimAPI:GetRecipeData(recipeID, isRecraft)
    return CraftSim.RecipeData(recipeID, isRecraft)
end

---Fetch the currently open CraftSim.RecipeData instance (or the last one opened if profession window was closed)
---@return CraftSim.RecipeData | nil
function CraftSimAPI:GetOpenRecipeData()
    return CraftSim.MAIN.currentRecipeData
end