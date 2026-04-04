---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.COOLDOWNS : Frame
CraftSim.COOLDOWNS = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT" })

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Cooldowns")

CraftSim.COOLDOWNS.isUpdatingTimers = false

function CraftSim.COOLDOWNS:TRADE_SKILL_ITEM_CRAFTED_RESULT()
    if CraftSim.COOLDOWNS.UI and CraftSim.COOLDOWNS.UI.OnTradeSkillItemCrafted then
        CraftSim.COOLDOWNS.UI:OnTradeSkillItemCrafted()
    end
end

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
