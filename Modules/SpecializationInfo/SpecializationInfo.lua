---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SPECIALIZATION_INFO : CraftSim.Module
CraftSim.SPECIALIZATION_INFO = {}

CraftSim.MODULES:RegisterModule("MODULE_SPEC_INFO", CraftSim.SPECIALIZATION_INFO)

GUTIL:RegisterCustomEvents(CraftSim.SPECIALIZATION_INFO, {
    "CRAFTSIM_PROFESSION_INITIALIZED",
    "CRAFTSIM_RECIPE_DATA_UPDATED",
    "CRAFTSIM_SIMULATION_MODE_ENABLED",
    "CRAFTSIM_SIMULATION_MODE_DISABLED",
    "CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED",
})

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_PROFESSION_INITIALIZED()
    self.UI:Update()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    if not recipeData then
        return
    end

    self.UI:Update()
end

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_SIMULATION_MODE_ENABLED()
    self.UI:Update()
end

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_SIMULATION_MODE_DISABLED()
    self.UI:Update()
end

function CraftSim.SPECIALIZATION_INFO:CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED()
    self.UI:Update()
end
