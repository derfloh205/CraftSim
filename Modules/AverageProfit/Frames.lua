AddonName, CraftSim = ...

CraftSim.AVERAGEPROFIT.FRAMES = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.FRAMES, recursive, l)
    else
        print(text)
    end
end

function CraftSim.AVERAGEPROFIT.FRAMES:Init()
    local frameNonWorkOrder = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimDetailsFrame", 
        "CraftSim Average Profit", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm, 
        "BOTTOMRIGHT", 
        "BOTTOMRIGHT", 
        0, 
        0, 
        320,
        120,
        CraftSim.CONST.FRAMES.STAT_WEIGHTS, false, true, nil, "modulesStatWeights")

    local frameWorkOrder = CraftSim.FRAME:CreateCraftSimFrame(
    "CraftSimDetailsWOFrame", 
    "CraftSim Average Profit " .. CraftSim.UTIL:ColorizeText("WO", CraftSim.CONST.COLORS.GREY), 
    ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
    ProfessionsFrame.OrdersPage.OrderView.OrderDetails, 
    "BOTTOMRIGHT", 
    "BOTTOMRIGHT", 
    0, 
    0, 
    320,
    120,
    CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER, false, true, nil, "modulesStatWeights")

    local function createContent(frame, profitDetailsFrameID)
        frame.content.breakdownButton = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
        frame.content.breakdownButton:SetPoint("TOP", frame.title, "TOP", 0, -15)	
        frame.content.breakdownButton:SetText("Show Explanation")
        frame.content.breakdownButton:SetSize(frame.content.breakdownButton:GetTextWidth() + 15, 20)
        frame.content.breakdownButton:SetScript("OnClick", function(self)
            local profitDetailsFrame = CraftSim.FRAME:GetFrame(profitDetailsFrameID) 
            local isVisible = profitDetailsFrame:IsVisible()
            CraftSim.FRAME:ToggleFrame(profitDetailsFrame, not isVisible)
            frame.content.breakdownButton:SetText(isVisible and "Show Explanation" or not isVisible and "Hide Explanation")
        end)
        

        frame.content.statText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statText:SetPoint("LEFT", frame.content, "LEFT", 15, -20)

        frame.content.valueText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.valueText:SetPoint("RIGHT", frame.content, "RIGHT", -15, -20)
        frame:Hide()
    end

    createContent(frameNonWorkOrder, CraftSim.CONST.FRAMES.PROFIT_DETAILS)
    createContent(frameWorkOrder, CraftSim.CONST.FRAMES.PROFIT_DETAILS_WORK_ORDER)

    
end

function CraftSim.AVERAGEPROFIT.FRAMES:UpdateAverageProfitDisplay(priceData, statWeights, exportMode)
    local statweightFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        statweightFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
    else
        statweightFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS)
    end
    if statWeights == nil then
        statweightFrame.content.statText:SetText("")
        statweightFrame.content.valueText:SetText("")
    else
        local statText = ""
        local valueText = ""

        if statWeights.meanProfit then
            statText = statText .. "Ø Profit / Craft:" .. "\n"
            local relativeValue = CraftSimOptions.showProfitPercentage and priceData.craftingCostPerCraft or nil
            valueText = valueText .. CraftSim.UTIL:FormatMoney(statWeights.meanProfit, true, relativeValue) .. "\n"
        end
        if statWeights.inspiration then
            statText = statText .. "Inspiration:" .. "\n"
            valueText = valueText .. CraftSim.UTIL:FormatMoney(statWeights.inspiration) .. "\n"
        end
        if statWeights.multicraft then
            statText = statText .. "Multicraft:" .. "\n"
            valueText = valueText .. CraftSim.UTIL:FormatMoney(statWeights.multicraft) .. "\n"
        end
        if statWeights.resourcefulness then
            statText = statText .. "Resourcefulness:"
            valueText = valueText .. CraftSim.UTIL:FormatMoney(statWeights.resourcefulness)
        end
        statweightFrame.content.statText:SetText(statText)
        statweightFrame.content.valueText:SetText(valueText)
    end
end

function CraftSim.AVERAGEPROFIT.FRAMES:UpdateExplanation(recipeData, calculationData, exportMode)
    local profitDetailsFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        profitDetailsFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS_WORK_ORDER)
    else
        profitDetailsFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS)
    end
    profitDetailsFrame.content.craftingCostValue:SetText(CraftSim.UTIL:FormatMoney(calculationData.craftingCostPerCraft))
    local profitCalculationText = "(((M_AI_1 * M_AV_1 + M_AI_2 * M_AV_2) + (I_I_1 * I_V_1 + I_I_2 * I_V_2)) * 0.95) - (CCC - MCS) = " .. CraftSim.UTIL:FormatMoney(calculationData.meanProfit, true)
    profitDetailsFrame.content.averageProfitValue:SetText(profitCalculationText)
    local isMaxQuality = recipeData.expectedQuality == recipeData.maxQuality
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.resourcefulnessInfo, calculationData.resourcefulness)
    if calculationData.resourcefulness then
        profitDetailsFrame.content.resourcefulnessInfo.averageSavedCostsValue:SetText(CraftSim.UTIL:FormatMoney(calculationData.resourcefulness.averageSavedCosts))
    end
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo, calculationData.multicraft)
    if calculationData.multicraft then
        profitDetailsFrame.content.multicraftInfo.currentQualityIcon.SetQuality(recipeData.expectedQuality)
        profitDetailsFrame.content.multicraftInfo.currentQualityIcon2.SetQuality(recipeData.expectedQuality)
        
        profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetText(CraftSim.UTIL:round(calculationData.multicraft.averageMulticraftItemsCurrent, 3))
        profitDetailsFrame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetText(CraftSim.UTIL:FormatMoney(calculationData.multicraft.averageMulticraftCurrentValue))
        
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.higherQualityIcon, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.higherQualityIcon2, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalHigherQualityValue, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle.helper, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle.helper, not isMaxQuality)
        if not recipeData.result.isNoQuality and not isMaxQuality then
            profitDetailsFrame.content.multicraftInfo.higherQualityIcon.SetQuality(calculationData.inspirationQuality)
            profitDetailsFrame.content.multicraftInfo.higherQualityIcon2.SetQuality(calculationData.inspirationQuality)
            profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetText(CraftSim.UTIL:round(calculationData.multicraft.averageMulticraftItemsHigher, 3))
            profitDetailsFrame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetText(CraftSim.UTIL:FormatMoney(calculationData.multicraft.averageMulticraftHigherValue))
        end
    end
    
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo, calculationData.inspiration)
    profitDetailsFrame.content.inspirationInfo.currentQualityIcon.SetQuality(recipeData.expectedQuality)
    profitDetailsFrame.content.inspirationInfo.currentQualityIcon2.SetQuality(recipeData.expectedQuality)
    profitDetailsFrame.content.inspirationInfo.averageCurrentQualityItemsValue:SetText(CraftSim.UTIL:round(calculationData.inspiration.averageInspirationItemsCurrent, 3))
    profitDetailsFrame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetText(CraftSim.UTIL:FormatMoney(calculationData.inspiration.inspirationItemsValueCurrent))
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.higherQualityIcon, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.higherQualityIcon2, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsValue, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsValue, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsTitle, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsTitle.helper, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsTitle, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsTitle.helper, not isMaxQuality)
    if  not recipeData.result.isNoQuality and not isMaxQuality then
        profitDetailsFrame.content.inspirationInfo.higherQualityIcon.SetQuality(calculationData.inspirationQuality)
        profitDetailsFrame.content.inspirationInfo.higherQualityIcon2.SetQuality(calculationData.inspirationQuality)
        
        profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsValue:SetText(CraftSim.UTIL:round(calculationData.inspiration.averageInspirationItemsHigher or 0, 3))
        profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsValue:SetText(CraftSim.UTIL:FormatMoney(calculationData.inspiration.inspirationItemsValueHigher or 0))
    end
end

function CraftSim.AVERAGEPROFIT.FRAMES:InitExplanation()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimProfitDetailsFrame", 
        "CraftSim Average Profit Explanation", 
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS),
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
        "CraftSim Average Profit Explanation", 
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER),
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
            CraftSim.FRAME:GetFrame(statweightFrameID).content.breakdownButton:SetText("Show Explanation")
        end)

        frame:Hide()
        local red = CraftSim.CONST.COLORS.RED
        local green = CraftSim.CONST.COLORS.GREEN
        local blue = CraftSim.CONST.COLORS.DARK_BLUE
        local headerScale = 1.2
        local segmentOffsetY = -30
        local contentToTitleOffsetY = -30
        frame.content.description = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.description:SetPoint("TOP", frame.title, "TOP", 0, -20)
        frame.content.description:SetText(
            "The Ø (Ø = Average) Profit is calculated by\n\n"..
            CraftSim.UTIL:ColorizeText("The Ø value of additional items from multicraft considering inspiration and multicraft proccing together\n", blue) ..
            CraftSim.UTIL:ColorizeText("+\n", green) ..
            CraftSim.UTIL:ColorizeText("The worth of the Ø number of items gained per quality based on your inspiration\n", blue) ..
            CraftSim.UTIL:ColorizeText("*\n", red) .. CraftSim.UTIL:ColorizeText("0.95\n", red) .. CraftSim.UTIL:ColorizeText("(5% auction house cut)\n", blue) .. 
            CraftSim.UTIL:ColorizeText("-\n", red) ..
            CraftSim.UTIL:ColorizeText("The total crafting costs based on the materials and their quality you currently selected\n", blue) ..
            CraftSim.UTIL:ColorizeText("-\n", red) ..
            CraftSim.UTIL:ColorizeText("The sum of the Ø material cost saved from resourcefulness\n\n", blue) ..
            "If you do not have enough of a material, CraftSim assumes the cheapest quality of a material\n(Does not have not be the lowest quality)")
        local descriptionHeight = frame.content.description:GetNumLines() * frame.content.description:GetLineHeight()
        frame.content.craftingCostTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.craftingCostTitle:SetPoint("TOP", frame.content.description, "TOP", 0, - (descriptionHeight + 15))
        frame.content.craftingCostTitle:SetText("Current Crafting Costs (CCC)")
        frame.content.craftingCostTitle:SetTextScale(headerScale)
        frame.content.craftingCostValue = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.craftingCostValue:SetPoint("TOP", frame.content.craftingCostTitle, "TOP", 0, -20)
        frame.content.craftingCostValue:SetText(CraftSim.UTIL:FormatMoney(0))
        frame.content.averageProfitTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.averageProfitTitle:SetPoint("TOP", frame.content.craftingCostValue, "TOP", 0, -30)
        frame.content.averageProfitTitle:SetText("Ø Profit")
        frame.content.averageProfitTitle:SetTextScale(headerScale)
        frame.content.averageProfitValue = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.averageProfitValue:SetPoint("TOP", frame.content.averageProfitTitle, "TOP", 0, -20)
        frame.content.averageProfitValue:SetText("1+1=2")
        frame.content.resourcefulnessInfo = CreateFrame("frame", nil, frame.content)
        frame.content.resourcefulnessInfo:SetPoint("TOP", frame.content.averageProfitValue, "TOP", 0, -30)
        frame.content.resourcefulnessInfo:SetSize(300, 100)
        frame.content.resourcefulnessInfo.resourcefulnessTitle = frame.content.resourcefulnessInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.resourcefulnessInfo.resourcefulnessTitle:SetPoint("TOP", frame.content.resourcefulnessInfo, "TOP", 0, 0)
        frame.content.resourcefulnessInfo.resourcefulnessTitle:SetText("Resourcefulness")
        frame.content.resourcefulnessInfo.resourcefulnessTitle:SetTextScale(headerScale)
        frame.content.resourcefulnessInfo.averageSavedCostsTitle = frame.content.resourcefulnessInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.resourcefulnessInfo.averageSavedCostsTitle:SetPoint("TOP", frame.content.resourcefulnessInfo.resourcefulnessTitle, "TOP", 0, contentToTitleOffsetY)
        frame.content.resourcefulnessInfo.averageSavedCostsTitle:SetText("Ø Material Costs Saved (MCS)")
        
        frame.content.resourcefulnessInfo.averageSavedCostsTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP), 
        frame.content.resourcefulnessInfo, frame.content.resourcefulnessInfo.averageSavedCostsTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.resourcefulnessInfo.averageSavedCostsValue = frame.content.resourcefulnessInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.resourcefulnessInfo.averageSavedCostsValue:SetPoint("TOP", frame.content.resourcefulnessInfo.averageSavedCostsTitle, "TOP", 0, -20)
        frame.content.resourcefulnessInfo.averageSavedCostsValue:SetText(CraftSim.UTIL:FormatMoney(1234789))
        frame.content.multicraftInfo = CreateFrame("frame", nil, frame.content)
        frame.content.multicraftInfo:SetPoint("TOPRIGHT", frame.content.resourcefulnessInfo, "TOPLEFT", 0, 0)
        frame.content.multicraftInfo:SetSize(300, 100)
        frame.content.multicraftInfo.multicraftTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.multicraftTitle:SetPoint("TOP", frame.content.multicraftInfo, "TOP", 0, 0)
        frame.content.multicraftInfo.multicraftTitle:SetText("Multicraft")
        frame.content.multicraftInfo.multicraftTitle:SetTextScale(headerScale)
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.multicraftTitle, "TOP", 0, contentToTitleOffsetY)
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle:SetText("Ø Additional Items (M_AI_1)")
        frame.content.multicraftInfo.currentQualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP), 
        frame.content.multicraftInfo, frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle, "TOP", 0, -20)
        frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetText("0")
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue, "TOP", 0, segmentOffsetY)
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle:SetText("Ø Additional Items (M_AI_2)")
        frame.content.multicraftInfo.higherQualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP), 
        frame.content.multicraftInfo, frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, "TOP", 0, -20)
        frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetText("0")
        frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue, "TOP", 0, segmentOffsetY)
        frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle:SetText("Ø Additional Value (M_AIV_1)")
        frame.content.multicraftInfo.currentQualityIcon2 = CraftSim.FRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP), 
        frame.content.multicraftInfo, frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalCurrentQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle, "TOP", 0, -20)
        frame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetText(CraftSim.UTIL:FormatMoney(0))
        
        frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalCurrentQualityValue, "TOP", 0, segmentOffsetY)
        frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle:SetText("Ø Additional Value (M_AIV_2)")
        frame.content.multicraftInfo.higherQualityIcon2 = CraftSim.FRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP), 
        frame.content.multicraftInfo, frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.multicraftInfo.averageAdditionalHigherQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, "TOP", 0, -20)
        frame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetText(CraftSim.UTIL:FormatMoney(0))
        frame.content.inspirationInfo = CreateFrame("frame", nil, frame.content)
        frame.content.inspirationInfo:SetPoint("TOPLEFT", frame.content.resourcefulnessInfo, "TOPRIGHT", 0, 0)
        frame.content.inspirationInfo:SetSize(300, 100)
        frame.content.inspirationInfo.inspirationTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.inspirationTitle:SetPoint("TOP", frame.content.inspirationInfo, "TOP", 0, 0)
        frame.content.inspirationInfo.inspirationTitle:SetText("Inspiration")
        frame.content.inspirationInfo.inspirationTitle:SetTextScale(headerScale)
        frame.content.inspirationInfo.averageCurrentQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.averageCurrentQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.inspirationTitle, "TOP", 0, contentToTitleOffsetY)
        frame.content.inspirationInfo.averageCurrentQualityItemsTitle:SetText("Ø Items (I_I_1)")
        frame.content.inspirationInfo.currentQualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.averageCurrentQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.inspirationInfo.averageCurrentQualityItemsTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP), 
        frame.content.inspirationInfo, frame.content.inspirationInfo.averageCurrentQualityItemsTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.inspirationInfo.averageCurrentQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.averageCurrentQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.averageCurrentQualityItemsTitle, "TOP", 0, -20)
        frame.content.inspirationInfo.averageCurrentQualityItemsValue:SetText("0")
        
        frame.content.inspirationInfo.averageHigherQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.averageHigherQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.averageCurrentQualityItemsValue, "TOP", 0, segmentOffsetY)
        frame.content.inspirationInfo.averageHigherQualityItemsTitle:SetText("Ø Items (I_I_2)")
        frame.content.inspirationInfo.higherQualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.averageHigherQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.inspirationInfo.averageHigherQualityItemsTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP), 
        frame.content.inspirationInfo, frame.content.inspirationInfo.averageHigherQualityItemsTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.inspirationInfo.averageHigherQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.averageHigherQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.averageHigherQualityItemsTitle, "TOP", 0, -20)
        frame.content.inspirationInfo.averageHigherQualityItemsValue:SetText("0")
        
        frame.content.inspirationInfo.valueByCurrentQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.valueByCurrentQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.averageHigherQualityItemsValue, "TOP", 0, segmentOffsetY)
        frame.content.inspirationInfo.valueByCurrentQualityItemsTitle:SetText("Ø Value (I_V_1)")
        frame.content.inspirationInfo.currentQualityIcon2 = CraftSim.FRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.valueByCurrentQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.inspirationInfo.valueByCurrentQualityItemsTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP), 
        frame.content.inspirationInfo, frame.content.inspirationInfo.valueByCurrentQualityItemsTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.inspirationInfo.valueByCurrentQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.valueByCurrentQualityItemsTitle, "TOP", 0, -20)
        frame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetText(CraftSim.UTIL:FormatMoney(0))
        
        frame.content.inspirationInfo.valueByHigherQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.valueByHigherQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.valueByCurrentQualityItemsValue, "TOP", 0, segmentOffsetY)
        frame.content.inspirationInfo.valueByHigherQualityItemsTitle:SetText("Ø Value (I_V_2)")
        frame.content.inspirationInfo.higherQualityIcon2 = CraftSim.FRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.valueByHigherQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
        frame.content.inspirationInfo.valueByHigherQualityItemsTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP), 
        frame.content.inspirationInfo, frame.content.inspirationInfo.valueByHigherQualityItemsTitle, 
        "RIGHT", "LEFT", 0, 0)
        frame.content.inspirationInfo.valueByHigherQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.inspirationInfo.valueByHigherQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.valueByHigherQualityItemsTitle, "TOP", 0, -20)
        frame.content.inspirationInfo.valueByHigherQualityItemsValue:SetText(CraftSim.UTIL:FormatMoney(0))
        frame.content.hideButton = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
        frame.content.hideButton:SetPoint("BOTTOM", frame.content, "BOTTOM", 0, 20)	
        frame.content.hideButton:SetText("Close")
        frame.content.hideButton:SetSize(frame.content.hideButton:GetTextWidth()+15, 25)
        frame.content.hideButton:SetScript("OnClick", function(self) 
            CraftSim.FRAME:ToggleFrame(frame, false)
            CraftSim.FRAME:GetFrame(statweightFrameID).content.breakdownButton:SetText("Show Explanation")
        end)
    end

    createContent(frameNO_WO, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
    createContent(frameWO, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
end