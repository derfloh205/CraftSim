---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.PRICE_DETAILS = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_DETAILS)

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.PRICE_DETAILS:UpdateDisplay(recipeData, exportMode)
    CraftSim.PRICE_DETAILS.UI:UpdateDisplay(recipeData, exportMode)
end
