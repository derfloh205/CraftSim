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

---Get the expected AH deposit cost for a recipe (requires TSM + option enabled).
---@param recipeData CraftSim.RecipeData
---@return number depositCost copper (0 if unavailable)
function CraftSimAPI:GetExpectedDeposit(recipeData)
    return CraftSim.TSM_ENHANCED:GetExpectedDeposit(recipeData)
end

---Get the smart restock amount for a recipe, subtracting existing inventory.
---@param recipeData CraftSim.RecipeData
---@return number needed items still required
---@return number target TSM restock target
---@return number owned total owned across tracked sources
function CraftSimAPI:GetSmartRestockAmount(recipeData)
    return CraftSim.TSM_ENHANCED:GetSmartRestockAmount(recipeData)
end
