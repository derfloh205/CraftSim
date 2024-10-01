---@class CraftSim
local CraftSim = select(2, ...)

CraftSimAPI = {}

---Fetch a CraftSim.RecipeData instance for a recipe
---@param options CraftSim.RecipeData.ConstructorOptions
---@return CraftSim.RecipeData recipeData
function CraftSimAPI:GetRecipeData(options)
    return CraftSim.RecipeData(options)
end

---Fetch the currently open CraftSim.RecipeData instance (or the last one opened if profession window was closed)
---@return CraftSim.RecipeData | nil
function CraftSimAPI:GetOpenRecipeData()
    return CraftSim.INIT.currentRecipeData
end

---Get the whole CraftSim addon table for whatever reason. Have Fun!
function CraftSimAPI:GetCraftSim()
    return CraftSim
end
