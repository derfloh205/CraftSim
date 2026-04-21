---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SPECIALIZATION_INFO : CraftSim.Module
CraftSim.SPECIALIZATION_INFO = {}

CraftSim.MODULES:RegisterModule("MODULE_SPEC_INFO", CraftSim.SPECIALIZATION_INFO)

GUTIL:RegisterCustomEvents(CraftSim.SPECIALIZATION_INFO, {
    "CRAFTSIM_PROFESSION_INITIALIZED",
    "CRAFTSIM_OPEN_RECIPE_INFO_UPDATED",
    "CRAFTSIM_RECIPE_DATA_UPDATED",
    "CRAFTSIM_SIMULATION_MODE_ENABLED",
    "CRAFTSIM_SIMULATION_MODE_DISABLED",
    "CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED",
})

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_PROFESSION_INITIALIZED()
    self.UI:Update()
end

---@param recipeInfo TradeSkillRecipeInfo?
function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_OPEN_RECIPE_INFO_UPDATED(recipeInfo)
    -- Don't clear stored state from open-recipe hook churn; only re-evaluate visibility by current UI context.
    -- Actual clears are driven by explicit nil recipe data or failed recipe-data initialization.
    self.UI:UpdateRecipeData()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    if not recipeData then
        self.UI:ClearStoredRecipeAndRefreshVisibility()
        return
    end

    self.UI:UpdateRecipeData(recipeData)
end

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_SIMULATION_MODE_ENABLED()
    self.UI:UpdateSimulationMode(true, CraftSim.SIMULATION_MODE.recipeData)
end

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_SIMULATION_MODE_DISABLED()
    self.UI:UpdateSimulationMode(false)
end

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED()
    if not self.UI.simulationModeEnabled then
        return
    end
    self.UI:UpdateRecipeData()
end
