addonName, CraftSim = ...

CraftSim.AVERAGEPROFIT.FRAMES = {}

function CraftSim.AVERAGEPROFIT.FRAMES:Init()
    local frame = CraftSim.FRAME:CreateCraftSimFrame(
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
        CraftSim.CONST.FRAMES.STAT_WEIGHTS)

    frame.content.breakdownButton = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
    frame.content.breakdownButton:SetPoint("TOP", frame.title, "TOP", 0, -15)	
    frame.content.breakdownButton:SetText("Show Explanation")
    frame.content.breakdownButton:SetSize(frame.content.breakdownButton:GetTextWidth() + 15, 20)
    frame.content.breakdownButton:SetScript("OnClick", function(self) 
        local profitDetailsFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS)
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

function CraftSim.AVERAGEPROFIT.FRAMES:UpdateAverageProfitDisplay(priceData, statWeights)
    local statweightFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS)
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