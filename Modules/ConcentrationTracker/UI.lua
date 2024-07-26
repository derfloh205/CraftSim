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
    local sizeX = 220
    local sizeY = 40
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
        scale = 1,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.CONCENTRATION_TRACKER,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })

    local function createContent(frame)
        ---@class CraftSim.CONCENTRATION_TRACKER.FRAME : GGUI.Frame
        frame = frame

        ---@class CraftSim.CONCENTRATION_TRACKER.FRAME.CONTENT : Frame
        local content = frame.content

        local textScale = 0.9

        content.slash = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -5 } },
            text = "/", scale = 1.2,
        }

        content.value = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content.slash.frame, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -1 } },
            justifyOptions = { type = "H", align = "LEFT" },
            text = "0", scale = 1.2,
        }

        content.maxValue = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content.slash.frame, anchorA = "LEFT", anchorB = "RIGHT" } },
            justifyOptions = { type = "H", align = "RIGHT" },
            text = "0", scale = 1.2,
        }

        content.maxTimer = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content, anchorA = "BOTTOM", anchorB = "BOTTOM", offsetY = 5 } },
            justifyOptions = { type = "H", align = "LEFT" }, scale = textScale,
        }

        content.concentrationIcon = GGUI.Icon {
            parent = content, anchorParent = content,
            anchorA = "LEFT", anchorB = "LEFT", sizeX = 30, sizeY = 30, offsetX = 5,
            texturePath = 5747318 }
    end

    createContent(CraftSim.CONCENTRATION_TRACKER.frame)
end

function CraftSim.CONCENTRATION_TRACKER.UI:UpdateDisplay()
    local concentrationData = CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    if not concentrationData then return end

    local content = CraftSim.CONCENTRATION_TRACKER.frame.content --[[@as CraftSim.CONCENTRATION_TRACKER.FRAME.CONTENT]]

    content.value:SetText(math.floor(concentrationData:GetCurrentAmount()))
    content.maxValue:SetText(concentrationData.maxQuantity)

    local formattedDateText, isReady = concentrationData:GetFormattedDateMax()

    if not isReady then
        content.maxTimer:SetText(f.g("(" .. formattedDateText .. ")"))
    else
        content.maxTimer:SetText(f.g("Concentration Full"))
    end
end
