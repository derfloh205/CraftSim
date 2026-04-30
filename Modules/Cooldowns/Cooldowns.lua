---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.COOLDOWNS : CraftSim.Module
CraftSim.COOLDOWNS = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT" })

CraftSim.MODULES:RegisterModule("MODULE_COOLDOWNS", CraftSim.COOLDOWNS, {
    label = L("CONTROL_PANEL_MODULES_COOLDOWNS_LABEL"),
    tooltip = L("CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP"),
})

GUTIL:RegisterCustomEvents(CraftSim.COOLDOWNS,
    {
        "CRAFTSIM_PROFESSION_OPENED",
        "CRAFTSIM_RECIPE_DATA_UPDATED",
        "CRAFTSIM_MODULE_CLOSED"
    })

local Logger = CraftSim.DEBUG:RegisterLogger("Cooldowns")

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

function CraftSim.COOLDOWNS:CRAFTSIM_PROFESSION_OPENED(_, selectedTab, _, _)
    if selectedTab == CraftSim.CONST.PROFESSIONS_TAB.SPEC_INFO then
        self.UI:Update()
        self:StartTimerUpdate()
    end
end

function CraftSim.COOLDOWNS:CRAFTSIM_RECIPE_DATA_UPDATED()
    self.UI:Update()
    self:StartTimerUpdate()
end

---@param moduleID CraftSim.ModuleID
function CraftSim.COOLDOWNS:CRAFTSIM_MODULE_CLOSED(moduleID)
    if self.moduleID == moduleID then
        self:StopTimerUpdate()
    end
end
