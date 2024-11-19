---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.COOLDOWNS
CraftSim.COOLDOWNS = {}

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Cooldowns")

CraftSim.COOLDOWNS.isUpdatingTimers = false

function CraftSim.COOLDOWNS:StartTimerUpdate()
    -- prevent duplicate timer updates
    if not CraftSim.COOLDOWNS.isUpdatingTimers then
        CraftSim.COOLDOWNS.isUpdatingTimers = true
        CraftSim.COOLDOWNS:PeriodicTimerUpdate()
    end
end

function CraftSim.COOLDOWNS:StopTimerUpdate()
    CraftSim.COOLDOWNS.isUpdatingTimers = false
end

function CraftSim.COOLDOWNS:PeriodicTimerUpdate()
    if not CraftSim.COOLDOWNS.isUpdatingTimers then return end
    CraftSim.COOLDOWNS.UI:UpdateTimers()
    C_Timer.After(1, CraftSim.COOLDOWNS.PeriodicTimerUpdate)
end

---@return CraftSim.EXPANSION_IDS[]
function CraftSim.COOLDOWNS:GetIncludedExpansions()
    local expansionIDs = {}

    for expansionID, included in pairs(CraftSim.DB.OPTIONS:Get("COOLDOWNS_FILTERED_EXPANSIONS") or {}) do
        if included then
            tinsert(expansionIDs, expansionID)
        end
    end

    return expansionIDs
end
