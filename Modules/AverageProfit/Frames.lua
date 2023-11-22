CraftSimAddonName, CraftSim = ...

CraftSim.AVERAGEPROFIT.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT)

function CraftSim.AVERAGEPROFIT.FRAMES:Init()
    local sizeX = 320
    local sizeY = 120
    local offsetX = -10
    local offsetY = 30
    local frameNonWorkOrder = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm, 
        anchorParent=ProfessionsFrame,
        anchorA="BOTTOMRIGHT",anchorB="BOTTOMRIGHT",
        sizeX=sizeX,sizeY=sizeY,
        offsetX=offsetX,offsetY=offsetY,
        frameID=CraftSim.CONST.FRAMES.STAT_WEIGHTS, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesStatWeights"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local frameWorkOrder = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails, 
        anchorParent=ProfessionsFrame,
        anchorA="BOTTOMRIGHT",anchorB="BOTTOMRIGHT",
        sizeX=sizeX,sizeY=sizeY,
        offsetX=offsetX,offsetY=offsetY,
        frameID=CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE) .. " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesStatWeights"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local function createContent(frame, profitDetailsFrameID, statisticsFrameID)
        frame.content.breakdownButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.title.frame,anchorA="TOP",anchorB="TOP",
            offsetX= -60, offsetY=-15,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON), sizeX=15,sizeY=20,adjustWidth=true,
            clickCallback=function ()
                local profitDetailsFrame = CraftSim.FRAME:GetFrame(profitDetailsFrameID) 
                local isVisible = profitDetailsFrame:IsVisible()
                CraftSim.FRAME:ToggleFrame(profitDetailsFrame, not isVisible)
                frame.content.breakdownButton:SetText(isVisible and CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON) or not isVisible and CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON))
            end
        })

        frame.content.statisticsButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.breakdownButton.frame,anchorA="LEFT",anchorB="RIGHT",
            offsetX= 1,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON), sizeX=15,sizeY=20,adjustWidth=true,
            clickCallback=function() 
                local statisticsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, statisticsFrameID)
                local isVisible = statisticsFrame:IsVisible()
                CraftSim.FRAME:ToggleFrame(statisticsFrame, not isVisible)
                frame.content.statisticsButton:SetText(isVisible and CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON) or not isVisible and CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON))
            end
        })

        local textOffsetX = 30
        local textOffsetY= -50
        local textSpacingY = -2
        local titleWidth = 130
        local titleValueSpacingX = 20
        frame.content.profit = {}
        frame.content.inspiration = {}
        frame.content.multicraft = {}
        frame.content.resourcefulness = {}

        frame.content.profit.title = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content, offsetX=textOffsetX, offsetY=textOffsetY,
            anchorA="TOPLEFT", anchorB="TOPLEFT", fixedWidth=titleWidth, justifyOptions={type="H", align="RIGHT"},
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT),
        })
        frame.content.profit.value = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.profit.title.frame,
            anchorA="LEFT", anchorB="RIGHT", justifyOptions={type="H", align="LEFT"}
        })

        frame.content.inspiration.title = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.profit.title.frame, offsetY=textSpacingY,
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", fixedWidth=titleWidth, justifyOptions={type="H", align="RIGHT"},
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_LABEL)
        })
        frame.content.inspiration.value = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.inspiration.title.frame,
            anchorA="LEFT", anchorB="RIGHT", justifyOptions={type="H", align="LEFT"}, offsetX=titleValueSpacingX
        })

        frame.content.multicraft.title = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.inspiration.title.frame, offsetY=textSpacingY,
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", fixedWidth=titleWidth, justifyOptions={type="H", align="RIGHT"},
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL)
        })
        frame.content.multicraft.value = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.multicraft.title.frame,
            anchorA="LEFT", anchorB="RIGHT", justifyOptions={type="H", align="LEFT"}, offsetX=titleValueSpacingX
        })

        frame.content.resourcefulness.title = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.multicraft.title.frame, offsetY=textSpacingY,
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", fixedWidth=titleWidth, justifyOptions={type="H", align="RIGHT"},
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL)
        })
        frame.content.resourcefulness.value = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.resourcefulness.title.frame,
            anchorA="LEFT", anchorB="RIGHT", justifyOptions={type="H", align="LEFT"}, offsetX=titleValueSpacingX
        })
        
        frame:Hide()
    end

    createContent(frameNonWorkOrder, CraftSim.CONST.FRAMES.PROFIT_DETAILS, CraftSim.CONST.FRAMES.STATISTICS)
    createContent(frameWorkOrder, CraftSim.CONST.FRAMES.PROFIT_DETAILS_WORK_ORDER, CraftSim.CONST.FRAMES.STATISTICS_WORKORDER)

    
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
    if statWeights == nil then
        -- statweightFrame.content.statText:SetText("")
        -- statweightFrame.content.valueText:SetText("")
    else
        local statText = ""
        local valueText = ""

        if statWeights.averageProfit then
            local relativeValue = CraftSimOptions.showProfitPercentage and craftingCosts or nil
            statweightFrame.content.profit.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.averageProfit, true, relativeValue))
        else
            statweightFrame.content.profit.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
        end
        if statWeights.inspirationWeight then
            statweightFrame.content.inspiration.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.inspirationWeight))
        else
            statweightFrame.content.inspiration.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
        end
        if statWeights.multicraftWeight then
            statweightFrame.content.multicraft.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.multicraftWeight))
        else
            statweightFrame.content.multicraft.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
        end
        if statWeights.resourcefulnessWeight then
            statweightFrame.content.resourcefulness.value:SetText(CraftSim.GUTIL:FormatMoney(statWeights.resourcefulnessWeight))
        else
            statweightFrame.content.resourcefulness.value:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
        end
    end
end

function CraftSim.AVERAGEPROFIT.FRAMES:InitExplanation()
    
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimProfitDetailsFrame", 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_EXPLANATION_TITLE),
        CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS).frame,
        UIParent, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        1000, 
        600,
        CraftSim.CONST.FRAMES.PROFIT_DETAILS, false, true, "DIALOG")

    local frameWO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimProfitDetailsWOFrame", 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_EXPLANATION_TITLE), 
        CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER).frame,
        UIParent, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        1000, 
        600,
        CraftSim.CONST.FRAMES.PROFIT_DETAILS_WORK_ORDER, false, true, "DIALOG")


    local function createContent(frame, statweightFrameID)
        frameNO_WO.closeButton:HookScript("OnClick", function(self) 
            CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, statweightFrameID).content.breakdownButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON))
        end)

        frame:Hide()
        frame.content.profitExplanationTab = CraftSim.FRAME:CreateTab(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_TAB), frame.content, frame.title, "TOP", "BOTTOM", -50, -15, true, 900, 500, frame.content, frame.title, 0, -50)
        frame.content.hsvExplanationTab = CraftSim.FRAME:CreateTab(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_HSV_TAB), frame.content, frame.content.profitExplanationTab, "LEFT", "RIGHT", 0, 0, true, 900, 500, frame.content, frame.title, 0, -50)
        frame.content.profitExplanationTab.content.description = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION), 
        frame.content.profitExplanationTab.content, frame.content.profitExplanationTab.content, "TOPLEFT", "TOPLEFT", 0, -20, nil, nil, {type="H", value="LEFT"})
        frame.content.hsvExplanationTab.content.description = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_HSV), 
        frame.content.hsvExplanationTab.content, frame.content.hsvExplanationTab.content, "TOPLEFT", "TOPLEFT", 0, -20, nil, nil, {type="H", value="LEFT"})

        CraftSim.FRAME:InitTabSystem({frame.content.profitExplanationTab, frame.content.hsvExplanationTab})
    end

    createContent(frameNO_WO, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
    createContent(frameWO, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
end