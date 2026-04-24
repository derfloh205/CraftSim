---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.SPECIALIZATION_INFO : CraftSim.Module
CraftSim.SPECIALIZATION_INFO = {}

CraftSim.MODULES:RegisterModule("MODULE_SPEC_INFO", CraftSim.SPECIALIZATION_INFO,
    {
        label = "CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL",
        tooltip = "CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP"
    })

GUTIL:RegisterCustomEvents(CraftSim.SPECIALIZATION_INFO, {
    "CRAFTSIM_RECIPE_DATA_UPDATED",
})

---@param recipeData CraftSim.RecipeData
function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    self.UI:Update(recipeData)
end
