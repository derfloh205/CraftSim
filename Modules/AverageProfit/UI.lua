---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.AVERAGEPROFIT
CraftSim.AVERAGEPROFIT = CraftSim.AVERAGEPROFIT

---@class CraftSim.AVERAGEPROFIT.UI
CraftSim.AVERAGEPROFIT.UI = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.AverageProfit.UI")

function CraftSim.AVERAGEPROFIT.UI:Init()
    local sizeX = 320
    local sizeY = 110
    local offsetX = -10
    local offsetY = 30
    CraftSim.AVERAGEPROFIT.frame = GGUI.Frame({
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
            " " .. GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SOURCE_COLUMN_WO), GUTIL.COLORS.GREY),
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
            anchorA = "TOP", anchorB = "TOP", offsetY = -30, scale = 0.95,
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

        frame.content.priceOverrideWarning = GGUI.Texture {
            atlas = "Ping_Chat_Warning",
            sizeX = 25, sizeY = 25,
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT",
            offsetX = 15, offsetY = -8,
            tooltipOptions = {
                anchor = "ANCHOR_CURSOR_RIGHT",
                text = f.l("Price Overrides Active"),
            },
        }

        frame:Hide()
    end

    createContent(CraftSim.AVERAGEPROFIT.frame)
    createContent(CraftSim.AVERAGEPROFIT.frameWO)
end

---@param recipeData CraftSim.RecipeData
---@param statWeights CraftSim.Statweights
function CraftSim.AVERAGEPROFIT.UI:UpdateDisplay(recipeData, statWeights)
    local averageProfitFrame = self:GetFrameByExportMode()
    local showProfitPercentage = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE")

    local craftingCosts = recipeData.priceData.craftingCosts

    local priceOverrideWarningIcon = averageProfitFrame.content.priceOverrideWarning --[[@as GGUI.Texture]]
    priceOverrideWarningIcon:SetVisible(recipeData.priceData:PriceOverridesActive())

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
                CraftSim.UTIL:FormatMoney(statWeights.averageProfit, true, relativeValue),
                f.white(f.bb("Average") .. " profit per craft considering your crafting stats"))
        end
        if statWeights.multicraftWeight then
            addToList(L(CraftSim.CONST.TEXT.MULTICRAFT_LABEL), CraftSim.UTIL:FormatMoney(statWeights.multicraftWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Multicraft")))
        end
        if statWeights.resourcefulnessWeight then
            addToList(L(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL),
                CraftSim.UTIL:FormatMoney(statWeights.resourcefulnessWeight),
                f.white("Profit increase " .. f.l("per point ") .. f.bb("Resourcefulness")))
        end
        if statWeights.concentrationWeight then
            addToList(L(CraftSim.CONST.TEXT.CONCENTRATION_LABEL),
                CraftSim.UTIL:FormatMoney(statWeights.concentrationWeight),
                f.white("Profit " .. f.l("per point ") .. f.bb("Concentration")) .. " considering " .. f.bb("Ingenuity"))
        end
    end

    profitList:UpdateDisplay()
end

---@return GGUI.Frame
function CraftSim.AVERAGEPROFIT.UI:GetFrameByExportMode()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        return CraftSim.AVERAGEPROFIT.frameWO
    else
        return CraftSim.AVERAGEPROFIT.frame
    end
end
