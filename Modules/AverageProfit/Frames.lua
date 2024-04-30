---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.AVERAGEPROFIT
CraftSim.AVERAGEPROFIT = CraftSim.AVERAGEPROFIT

---@class CraftSim.AVERAGEPROFIT.FRAMES
CraftSim.AVERAGEPROFIT.FRAMES = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT)

function CraftSim.AVERAGEPROFIT.FRAMES:Init()
    local sizeX = 320
    local sizeY = 120
    local offsetX = -10
    local offsetY = 30
    CraftSim.AVERAGEPROFIT.frame = GGUI.Frame({
        debug = true,
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.AVERAGE_PROFIT,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })

    CraftSim.AVERAGEPROFIT.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE) ..
            " " .. GUTIL:ColorizeText("WO", GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_AVERAGE_PROFIT"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        raiseOnClick = true
    })

    local function createContent(frame)
        local moneyColumnWidth = 180
        frame.content.profitList = GGUI.FrameList {
            parent = frame.content, anchorParent = frame.content,
            anchorA = "TOP", anchorB = "TOP", offsetY = -30,
            sizeY = 100,
            rowHeight = 18,
            columnOptions = {
                {
                    width = 130, -- name
                },
                {
                    width = moneyColumnWidth, -- value
                }
            },
            hideScrollbar = true,
            selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE },
            rowConstructor = function(columns, row)
                local nameColumn = columns[1]
                local valueColumn = columns[2]

                nameColumn.text = GGUI.Text {
                    parent = nameColumn, anchorParent = nameColumn, anchorA = "RIGHT", anchorB = "RIGHT",
                    justifyOptions = { type = "H", align = "RIGHT" }
                }
                valueColumn.text = GGUI.Text {
                    parent = valueColumn, anchorParent = valueColumn, anchorA = "LEFT", anchorB = "LEFT",
                    justifyOptions = { type = "H", align = "LEFT" }, fixedWidth = moneyColumnWidth,
                }
            end
        }

        frame:Hide()
    end

    createContent(CraftSim.AVERAGEPROFIT.frame)
    createContent(CraftSim.AVERAGEPROFIT.frameWO)
end

---@param statWeights CraftSim.Statweights
function CraftSim.AVERAGEPROFIT.FRAMES:UpdateDisplay(statWeights, craftingCosts)
    local averageProfitFrame = self:GetFrameByExportMode()
    local showProfitPercentage = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE")

    local profitList = averageProfitFrame.content.profitList --[[@as GGUI.FrameList]]
    profitList:Remove()
    local function addToList(name, value, tooltip)
        profitList:Add(function(row, columns)
            local nameColumn = columns[1]
            local valueColumn = columns[2]

            nameColumn.text:SetText(name)
            valueColumn.text:SetText(value)

            if tooltip then
                row.tooltipOptions = {
                    anchor = "ANCHOR_CURSOR",
                    owner = row.frame,
                    text = tooltip,
                }
            else
                row.tooltipOptions = nil
            end
        end)
    end

    if statWeights ~= nil then
        if statWeights.averageProfit then
            local relativeValue = showProfitPercentage and craftingCosts or nil
            addToList(L(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT),
                f.mr(statWeights.averageProfit, relativeValue),
                f.white(f.bb("Average") .. " profit per craft considering your crafting stats"))
        end
        if statWeights.inspirationWeight then
            addToList(L(CraftSim.CONST.TEXT.INSPIRATION_LABEL), f.mw(statWeights.inspirationWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Inspiration")))
        end
        if statWeights.multicraftWeight then
            addToList(L(CraftSim.CONST.TEXT.MULTICRAFT_LABEL), f.mw(statWeights.multicraftWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Multicraft")))
        end
        if statWeights.resourcefulnessWeight then
            addToList(L(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL), f.mw(statWeights.resourcefulnessWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Resourcefulness")))
        end
    end

    profitList:UpdateDisplay()
end

---@return GGUI.Frame
function CraftSim.AVERAGEPROFIT.FRAMES:GetFrameByExportMode()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        return CraftSim.AVERAGEPROFIT.frameWO
    else
        return CraftSim.AVERAGEPROFIT.frame
    end
end
