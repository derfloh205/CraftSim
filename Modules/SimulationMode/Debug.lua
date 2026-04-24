---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

local Logger = CraftSim.DEBUG:RegisterLogger("SimulationMode.Debug")

---@class CraftSim.SIMULATION_MODE.DEBUG : CraftSim.Module.Debug
CraftSim.SIMULATION_MODE.DEBUG = { label = "Simulation Mode" }

function CraftSim.SIMULATION_MODE.DEBUG:Inspect_Recipe_Data()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then
        Logger:LogError("No recipe data available for inspection.")
        return
    end

    CraftSim.DEBUG:InspectTable(recipeData, "Simulated Recipe Data", true)
end
