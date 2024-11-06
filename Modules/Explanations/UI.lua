---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.EXPLANATIONS
CraftSim.EXPLANATIONS = CraftSim.EXPLANATIONS

---@class CraftSim.EXPLANATIONS.UI
CraftSim.EXPLANATIONS.UI = {}

function CraftSim.EXPLANATIONS.UI:Init()
    CraftSim.EXPLANATIONS.frame = GGUI.Frame {
        title = L(CraftSim.CONST.TEXT.EXPLANATIONS_TITLE),
        parent = ProfessionsFrame, anchorParent = ProfessionsFrame,
        sizeX = 1000, sizeY = 600,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"), frameTable = CraftSim.INIT.FRAMES,
        frameID = CraftSim.CONST.FRAMES.EXPLANATIONS, moveable = true, closeable = true, collapseable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_EXPLANATIONS"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    }

    local function createContent(frame)
        frame:Hide()
        frame.content.profitExplanationTab = GGUI.BlizzardTab {
            parent = frame.content, anchorParent = frame.content,
            sizeX = 900, sizeY = 500,
            top = true, initialTab = true,
            buttonOptions = {
                offsetY = -5,
                label = L(CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB),
            },
        }

        frame.content.profitExplanationTab.content.description = GGUI.Text {
            parent = frame.content.profitExplanationTab.content, anchorParent = frame.content.profitExplanationTab.content,
            text = L(CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION), anchorA = "TOPLEFT", anchorB = "TOPLEFT",
            offsetY = -20, justifyOptions = { type = "H", align = "LEFT" }, wrap = true
        }


        GGUI.BlizzardTabSystem { frame.content.profitExplanationTab }
    end

    createContent(CraftSim.EXPLANATIONS.frame)
end
