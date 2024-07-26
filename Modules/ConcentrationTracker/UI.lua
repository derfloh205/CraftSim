---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CONCENTRATION_TRACKER
CraftSim.CONCENTRATION_TRACKER = CraftSim.CONCENTRATION_TRACKER

---@type CraftSim.CONCENTRATION_TRACKER.FRAME
CraftSim.CONCENTRATION_TRACKER.frame = nil

---@class CraftSim.CONCENTRATION_TRACKER.UI
CraftSim.CONCENTRATION_TRACKER.UI = {}

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

local print = CraftSim.DEBUG:SetDebugPrint("CONCENTRATION_TRACKER")

function CraftSim.CONCENTRATION_TRACKER.UI:Init()
    local sizeX = 200
    local sizeY = 100
    local offsetX = 0
    local offsetY = 0
    ---@class CraftSim.CONCENTRATION_TRACKER.FRAME : GGUI.Frame
    CraftSim.CONCENTRATION_TRACKER.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.ConcentrationDisplay,
        anchorParent = ProfessionsFrame.CraftingPage.ConcentrationDisplay,
        anchorA = "CENTER",
        anchorB = "CENTER",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.CONCENTRATION_TRACKER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE),
        collapseable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        --onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })
end
