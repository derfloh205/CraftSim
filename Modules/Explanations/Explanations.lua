---@class CraftSim
local CraftSim = select(2, ...)

local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.EXPLANATIONS : CraftSim.Module
CraftSim.EXPLANATIONS = {}

CraftSim.MODULES:RegisterModule("MODULE_EXPLANATIONS", CraftSim.EXPLANATIONS, {
    label = L("CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL"),
    tooltip = L("CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP"),
})

---@type GGUI.Frame
CraftSim.EXPLANATIONS.frame = nil
