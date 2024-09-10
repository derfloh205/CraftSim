---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.RELOAD_PROMPT
CraftSim.RELOAD_PROMPT = CraftSim.RELOAD_PROMPT

---@class CraftSim.RELOAD_PROMPT.UI
CraftSim.RELOAD_PROMPT.UI = {}

function CraftSim.RELOAD_PROMPT.UI:Init()
    local sizeX = 300
    local sizeY = 100

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    CraftSim.RELOAD_PROMPT.frame = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = UIParent,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.RELOAD_PROMPT,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_RELOAD_PROMPT),
        collapseable = false,
        closeable = true,
        moveable = false,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        frame:Hide()
        frame.content.description = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -40,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RELOAD_PROMPT)
        })

        frame.content.reloadButton = CraftSim.GGUI.Button({
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RELOAD),
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetX = 0,
            offsetY = -60,
            sizeX = 15,
            sizeY = 25,
            adjustWidth = true,
            clickCallback = function()
                ReloadUI()
            end
        })
    end

    createContent(CraftSim.RELOAD_PROMPT.frame)
end
