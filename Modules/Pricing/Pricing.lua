---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.PRICING : CraftSim.Module
CraftSim.PRICING = {}

CraftSim.MODULES:RegisterModule("MODULE_PRICING", CraftSim.PRICING, {
    label = L("CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL"),
    tooltip = L("CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP"),
})

GUTIL:RegisterCustomEvents(CraftSim.PRICING, {
    "CRAFTSIM_RECIPE_DATA_UPDATED",
})

---@param recipeData CraftSim.RecipeData
function CraftSim.PRICING:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    self:UpdateDisplay(recipeData)
end
