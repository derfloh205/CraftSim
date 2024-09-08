---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CONCENTRATION_TRACKER
CraftSim.CONCENTRATION_TRACKER = CraftSim.CONCENTRATION_TRACKER

---@type CraftSim.CONCENTRATION_TRACKER.FRAME
CraftSim.CONCENTRATION_TRACKER.frame = nil

---@type CraftSim.CONCENTRATION_TRACKER.TOOLTIP_FRAME
CraftSim.CONCENTRATION_TRACKER.tooltipFrame = nil

---@class CraftSim.CONCENTRATION_TRACKER.UI
CraftSim.CONCENTRATION_TRACKER.UI = {}

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

local print = CraftSim.DEBUG:SetDebugPrint("CONCENTRATION_TRACKER")

function CraftSim.CONCENTRATION_TRACKER.UI:Init()
    self:InitTooltipFrame()

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
        tooltipOptions = {
            anchor = "ANCHOR_BOTTOM",
            frame = CraftSim.CONCENTRATION_TRACKER.tooltipFrame.content,
            frameUpdateCallback = function(tooltipFrame)
                CraftSim.CONCENTRATION_TRACKER.UI:UpdateTooltipFrame(tooltipFrame)
            end
        }
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
            parent = content, anchorPoints = { { anchorParent = content, anchorA = "BOTTOM", anchorB = "BOTTOM", offsetY = 6 } },
            justifyOptions = { type = "H", align = "LEFT" }, scale = textScale,
        }

        content.concentrationIcon = GGUI.Icon {
            parent = content, anchorParent = content,
            anchorA = "LEFT", anchorB = "LEFT", sizeX = 30, sizeY = 30, offsetX = 5,
            texturePath = CraftSim.CONST.CONCENTRATION_ICON }
    end

    createContent(CraftSim.CONCENTRATION_TRACKER.frame)
end

function CraftSim.CONCENTRATION_TRACKER.UI.InitTooltipFrame()
    local sizeX = 330
    local sizeY = 40
    local offsetX = 0
    local offsetY = 0
    ---@class CraftSim.CONCENTRATION_TRACKER.TOOLTIP_FRAME : GGUI.Frame
    CraftSim.CONCENTRATION_TRACKER.tooltipFrame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "CENTER",
        anchorB = "CENTER",
        sizeX = sizeX,
        sizeY = sizeY,
        scale = 0.9,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.CONCENTRATION_TRACKER_TOOLTIP_FRAME,
        title = L("CONCENTRATION_TRACKER_TITLE"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = "TOOLTIP",
        frameLevel = 99,
        hide = true,
    })

    ---@class CraftSim.CONCENTRATION_TRACKER.TOOLTIP_FRAME.CONTENT : Frame
    local content = CraftSim.CONCENTRATION_TRACKER.tooltipFrame.content

    content.concentrationList = GGUI.FrameList {
        columnOptions = {
            {
                label = "Crafter",
                width = 160,
            },
            {
                label = "Current",
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = "Max",
                width = 100,
                justifyOptions = { type = "H", align = "CENTER" },
            }
        },
        rowHeight = 15,
        parent = content, anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -20 } },
        rowConstructor = function(columns, row)
            local crafterProfessionColumn = columns[1]
            local concentrationColumn = columns[2]
            local maxedColumn = columns[3]

            crafterProfessionColumn.text = GGUI.Text {
                parent = crafterProfessionColumn, anchorPoints = { { anchorParent = crafterProfessionColumn, anchorA = "LEFT", anchorB = "LEFT" } },
                justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9,
            }
            concentrationColumn.text = GGUI.Text {
                parent = concentrationColumn, anchorPoints = { { anchorParent = concentrationColumn, anchorA = "CENTER", anchorB = "CENTER" } },
                justifyOptions = { type = "H", align = "CENTER" }, scale = 0.9,
            }
            maxedColumn.text = GGUI.Text {
                parent = maxedColumn, anchorPoints = { { anchorParent = maxedColumn, anchorA = "CENTER", anchorB = "CENTER" } },
                justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9, fixedWidth = 90,
            }
        end,
        autoAdjustHeight = true,
        disableScrolling = true,
        hideScrollbar = true,
        autoAdjustHeightCallback = function(newHeight)
            CraftSim.CONCENTRATION_TRACKER.tooltipFrame.content:SetSize(sizeX, newHeight + 10)
        end
    }
end

---@param content CraftSim.CONCENTRATION_TRACKER.TOOLTIP_FRAME.CONTENT | Frame
function CraftSim.CONCENTRATION_TRACKER.UI:UpdateTooltipFrame(content)
    content.concentrationList:Remove()

    local crafterUIDs = CraftSim.DB.CRAFTER:GetCrafterUIDs()
    local crafterConcentrationTable = {}
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local openExpansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)

    for _, crafterUID in ipairs(crafterUIDs) do
        local professionDataList = CraftSim.DB.CRAFTER:GetConcentrationDataListForExpansion(crafterUID, openExpansionID)
        for profession, serializedData in pairs(professionDataList) do
            crafterConcentrationTable[crafterUID] = crafterConcentrationTable[crafterUID] or {}

            if serializedData then
                tinsert(crafterConcentrationTable[crafterUID], {
                    profession = profession,
                    expansionID = openExpansionID,
                    serializedData = serializedData
                })
            end
        end
    end

    for crafterUID, professionConcentrationDataList in pairs(crafterConcentrationTable) do
        for _, professionConcentrationData in ipairs(professionConcentrationDataList) do
            content.concentrationList:Add(function(row, columns)
                local crafterProfessionColumn = columns[1]
                local concentrationColumn = columns[2]
                local maxedColumn = columns[3]

                local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
                local professionIcon = CraftSim.CONST.PROFESSION_ICONS[professionConcentrationData.profession]
                crafterProfessionColumn.text:SetText(GUTIL:IconToText(professionIcon, 15, 15) ..
                    " " .. f.class(crafterUID, crafterClass))

                local concentrationData = CraftSim.ConcentrationData:Deserialize(professionConcentrationData
                    .serializedData)

                concentrationColumn.text:SetText(math.floor(concentrationData:GetCurrentAmount()))

                local formattedMaxDate, isReady = concentrationData:GetFormattedDateMax()

                if not isReady then
                    maxedColumn.text:SetText(f.bb(formattedMaxDate))
                else
                    maxedColumn.text:SetText(f.g("MAX"))
                end
            end)
        end
    end

    content.concentrationList:UpdateDisplay()
end

function CraftSim.CONCENTRATION_TRACKER.UI:UpdateDisplay()
    local concentrationData = CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    if not concentrationData or not concentrationData.currencyID then return end

    local content = CraftSim.CONCENTRATION_TRACKER.frame.content --[[@as CraftSim.CONCENTRATION_TRACKER.FRAME.CONTENT]]

    content.value:SetText(math.floor(concentrationData:GetCurrentAmount()))
    content.maxValue:SetText(concentrationData.maxQuantity)

    local formattedDateText, isReady = concentrationData:GetFormattedDateMax()

    if not isReady then
        content.maxTimer:SetText(f.bb("Max: " .. formattedDateText))
    else
        content.maxTimer:SetText(f.g("Concentration Full"))
    end
end
