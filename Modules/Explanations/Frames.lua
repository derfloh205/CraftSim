---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.EXPLANATIONS
CraftSim.EXPLANATIONS = CraftSim.EXPLANATIONS

---@class CraftSim.EXPLANATIONS.FRAMES
CraftSim.EXPLANATIONS.FRAMES = {}

function CraftSim.EXPLANATIONS.FRAMES:Init()
    CraftSim.EXPLANATIONS.frame = GGUI.Frame {
        title = L(CraftSim.CONST.TEXT.EXPLANATIONS_TITLE),
        parent = ProfessionsFrame, anchorParent = ProfessionsFrame,
        sizeX = 1000, sizeY = 600,
        frameConfigTable = CraftSimGGUIConfig, frameTable = CraftSim.INIT.FRAMES,
        frameID = CraftSim.CONST.FRAMES.EXPLANATIONS, moveable = true, closeable = true, collapseable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("modulesExplanations"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
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
        frame.content.hsvExplanationTab = GGUI.BlizzardTab {
            parent = frame.content, anchorParent = frame.content,
            sizeX = 900, sizeY = 500,
            top = true,
            buttonOptions = {
                anchorParent = frame.content.profitExplanationTab.button,
                anchorA = "LEFT", anchorB = "RIGHT",
                label = L(CraftSim.CONST.TEXT.EXPLANATIONS_HSV_TAB),
            },
        }

        frame.content.profitExplanationTab.content.description = GGUI.Text {
            parent = frame.content.profitExplanationTab.content, anchorParent = frame.content.profitExplanationTab.content,
            text = L(CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION), anchorA = "TOPLEFT", anchorB = "TOPLEFT",
            offsetY = -20, justifyOptions = { type = "H", align = "LEFT" }
        }


        frame.content.hsvExplanationTab.content.description = GGUI.Text {
            parent = frame.content.hsvExplanationTab.content, anchorParent = frame.content.hsvExplanationTab.content,
            offsetY = -20, justifyOptions = { type = "H", align = "LEFT" },
            text = L(CraftSim.CONST.TEXT.EXPLANATIONS_HSV_EXPLANATION)
        }

        GGUI.BlizzardTabSystem { frame.content.profitExplanationTab, frame.content.hsvExplanationTab }
    end

    createContent(CraftSim.EXPLANATIONS.frame)
end
