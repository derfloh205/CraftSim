CraftSimAddonName, CraftSim = ...

CraftSim.PRICE_DETAILS = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_DETAILS)

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_DETAILS:UpdateDisplay(recipeData, exportMode)
    CraftSim.PRICE_DETAILS.FRAMES:UpdateDisplay(recipeData, exportMode)
end