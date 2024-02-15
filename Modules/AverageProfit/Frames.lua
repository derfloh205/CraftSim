---@class CraftSim
local CraftSim = select(2, ...)

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
    local frameNonWorkOrder = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.STAT_WEIGHTS,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("modulesStatWeights"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    local frameWorkOrder = CraftSim.GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        anchorParent = ProfessionsFrame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetX = offsetX,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE) ..
            " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("modulesStatWeights"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    local function createContent(frame)
        local textOffsetX = 30
        local textOffsetY = -50
        local textSpacingY = -2
        local titleWidth = 130
        local titleValueSpacingX = 20
        frame.content.profit = {}
        frame.content.inspiration = {}
        frame.content.multicraft = {}
        frame.content.resourcefulness = {}

        frame.content.profit.title = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content,
            offsetX = textOffsetX,
            offsetY = textOffsetY,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            fixedWidth = titleWidth,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT),
        })
        frame.content.profit.value = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.profit.title.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            justifyOptions = { type = "H", align = "LEFT" }
        })

        frame.content.inspiration.title = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.profit.title.frame,
            offsetY = textSpacingY,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            fixedWidth = titleWidth,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_LABEL)
        })
        frame.content.inspiration.value = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.inspiration.title.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            justifyOptions = { type = "H", align = "LEFT" },
            offsetX = titleValueSpacingX
        })

        frame.content.multicraft.title = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.inspiration.title.frame,
            offsetY = textSpacingY,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            fixedWidth = titleWidth,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL)
        })
        frame.content.multicraft.value = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.multicraft.title.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            justifyOptions = { type = "H", align = "LEFT" },
            offsetX = titleValueSpacingX
        })

        frame.content.resourcefulness.title = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.multicraft.title.frame,
            offsetY = textSpacingY,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            fixedWidth = titleWidth,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL)
        })
        frame.content.resourcefulness.value = CraftSim.GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.resourcefulness.title.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            justifyOptions = { type = "H", align = "LEFT" },
            offsetX = titleValueSpacingX
        })

        frame:Hide()
    end

    createContent(frameNonWorkOrder)
    createContent(frameWorkOrder)
end

---@param statWeights CraftSim.Statweights
---@param exportMode number
function CraftSim.AVERAGEPROFIT.FRAMES:UpdateDisplay(statWeights, craftingCosts, exportMode)
    local statweightFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        statweightFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
    else
        statweightFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
    end
    if statWeights ~= nil then
        local statText = ""
        local valueText = ""

        if statWeights.averageProfit then
            local relativeValue = CraftSimOptions.showProfitPercentage and craftingCosts or nil
            statweightFrame.content.profit.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.averageProfit, true,
                relativeValue))
        else
            statweightFrame.content.profit.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
        end
        if statWeights.inspirationWeight then
            statweightFrame.content.inspiration.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.inspirationWeight))
        else
            statweightFrame.content.inspiration.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS
                .GREY))
        end
        if statWeights.multicraftWeight then
            statweightFrame.content.multicraft.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.multicraftWeight))
        else
            statweightFrame.content.multicraft.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
        end
        if statWeights.resourcefulnessWeight then
            statweightFrame.content.resourcefulness.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights
                .resourcefulnessWeight))
        else
            statweightFrame.content.resourcefulness.value:SetText(CraftSim.GUTIL:ColorizeText("-",
                CraftSim.GUTIL.COLORS.GREY))
        end
    end
end
