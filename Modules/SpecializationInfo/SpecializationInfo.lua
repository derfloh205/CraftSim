---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SPECIALIZATION_INFO : CraftSim.Module
CraftSim.SPECIALIZATION_INFO = {}

CraftSim.MODULES:RegisterModule("MODULE_SPEC_INFO", CraftSim.SPECIALIZATION_INFO)

GUTIL:RegisterCustomEvents(CraftSim.SPECIALIZATION_INFO, {
    "CRAFTSIM_RECIPE_DATA_UPDATED",
})

---@param recipeData CraftSim.RecipeData
function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    self.UI:UpdateRecipeData(recipeData)
end

