addonName, CraftSim = ...

CraftSim.FRAME = {}

CraftSim.FRAME.frames = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.FRAMES, recursive, l)
    else
        print(text)
    end
end

function CraftSim.FRAME:GetFrame(frameID)
    local frameName = CraftSim.FRAME.frames[frameID]
    if not frameName then
        error("CraftSim Error: Frame not found: " .. tostring(frameID))
    end
    return _G[frameName]
end

function CraftSim.FRAME:InitStatWeightFrame()
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

function CraftSim.FRAME:UpdateStatWeightFrameText(priceData, statWeights)
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

function CraftSim.FRAME:CreateIcon(parent, offsetX, offsetY, texture, sizeX, sizeY, anchorA, anchorB)
    if anchorA == nil then
        anchorA = "CENTER"
    end
    if anchorB == nil then
        anchorB = "CENTER"
    end
    local newIcon = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    newIcon:SetPoint(anchorA, parent, anchorB, offsetX, offsetY)
	newIcon:SetSize(sizeX, sizeY)
	newIcon:SetNormalFontObject("GameFontNormalLarge")
	newIcon:SetHighlightFontObject("GameFontHighlightLarge")
	newIcon:SetNormalTexture(texture)
    return newIcon
end

function CraftSim.FRAME:InitBestAllocationsFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimReagentHintFrame", 
        "CraftSim Min Cost Material", 
        ProfessionsFrame.CraftingPage.SchematicForm, 
        CraftSimCostOverviewFrame, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -10, 
        0, 
        270, 
        250,
        CraftSim.CONST.FRAMES.MATERIALS)

    local contentOffsetY = -15

    frame.content.inspirationCheck = CreateFrame("CheckButton", nil, frame.content, "ChatConfigCheckButtonTemplate")
	frame.content.inspirationCheck:SetPoint("TOP", frame.title, -90, -20)
	frame.content.inspirationCheck.Text:SetText(" Reach Inspiration Breakpoint")
    frame.content.inspirationCheck.tooltip = "Try to reach the skill breakpoint where an inspiration proc upgrades to the next higher quality with the cheapest material combination"
    frame.content.inspirationCheck:SetChecked(CraftSimOptions.materialSuggestionInspirationThreshold)
	frame.content.inspirationCheck:HookScript("OnClick", function(_, btn, down)
		local checked = frame.content.inspirationCheck:GetChecked()
		CraftSimOptions.materialSuggestionInspirationThreshold = checked
        CraftSim.MAIN:TriggerModulesErrorSafe() -- TODO: if this is not performant enough, try to only recalc the material stuff not all, lazy solution for now
	end)

    frame.content.qualityText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.qualityText:SetPoint("TOP", frame.title, "TOP", 0, -45)
	frame.content.qualityText:SetText("Reachable Quality: ")

    frame.content.qualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content, 25, 25, frame.content.qualityText, "LEFT", "RIGHT", 3, 0)

    frame.content.allocateButton = CreateFrame("Button", "CraftSimMaterialAllocateButton", frame.content, "UIPanelButtonTemplate")
	frame.content.allocateButton:SetSize(50, 25)
	frame.content.allocateButton:SetPoint("TOP", frame.content.qualityText, "TOP", 0, -20)	
	frame.content.allocateButton:SetText("Assign")

    frame.content.allocateText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.allocateText:SetPoint("TOP", frame.content.qualityText, "TOP", 0, -20)	
	frame.content.allocateText:SetText("")

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.infoText:SetPoint("CENTER", frame.content, "CENTER", 0, 0)
    frame.content.infoText.NoCombinationFound = "No combination found \nto increase quality"
    frame.content.infoText.SameCombination = "Best combination assigned"
	frame.content.infoText:SetText(frame.content.infoText.NoCombinationFound)

    local iconsOffsetY = -30
    local iconsSpacingY = 25

    frame.content.reagentFrames = {}
    frame.content.reagentFrames.rows = {}
    frame.content.reagentFrames.numReagents = 0
    local baseX = -20
    local iconSize = 30
    table.insert(frame.content.reagentFrames.rows, CraftSim.FRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSim.FRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSim.FRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*2, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSim.FRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*3, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSim.FRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*4, iconSize))

    frame:Hide()
end

function CraftSim.FRAME:CreateReagentFrame(parent, hookFrame, y, iconSize)
    local reagentFrame = CreateFrame("frame", nil, parent)
    reagentFrame:SetSize(parent:GetWidth(), iconSize)
    reagentFrame:SetPoint("TOP", hookFrame, "TOP", 0, y)
    
    local qualityIconSize = 20
    local qualityIconX = 3
    local qualityIconY = -3

    local qualityAmountTextX = 5
    local qualityAmountTextSpacingX = 40

    local reagentRowOffsetX = 40
    local reagentIconsOffsetX = 70

    reagentFrame.q1Icon = reagentFrame:CreateTexture()
    reagentFrame.q1Icon:SetSize(25, 25)
    reagentFrame.q1Icon:SetPoint("LEFT", reagentFrame, "LEFT", reagentRowOffsetX, 0)

    reagentFrame.q2Icon = reagentFrame:CreateTexture()
    reagentFrame.q2Icon:SetSize(25, 25)
    reagentFrame.q2Icon:SetPoint("LEFT", reagentFrame, "LEFT", reagentRowOffsetX + reagentIconsOffsetX, 0)

    reagentFrame.q3Icon = reagentFrame:CreateTexture()
    reagentFrame.q3Icon:SetSize(25, 25)
    reagentFrame.q3Icon:SetPoint("LEFT", reagentFrame, "LEFT", reagentRowOffsetX + reagentIconsOffsetX*2, 0)
    
    reagentFrame.q1qualityIcon = CraftSim.FRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q1Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 1)
    reagentFrame.q2qualityIcon = CraftSim.FRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q2Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 2)
    reagentFrame.q3qualityIcon = CraftSim.FRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q3Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 3)

    reagentFrame.q1text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q1text:SetPoint("LEFT", reagentFrame.q1Icon, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q1text:SetText("x ?")

    reagentFrame.q2text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q2text:SetPoint("LEFT", reagentFrame.q2Icon, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q2text:SetText("x ?")

    reagentFrame.q3text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q3text:SetPoint("LEFT", reagentFrame.q3Icon, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q3text:SetText("x ?")

    reagentFrame:Hide()
    return reagentFrame
end

-- DEBUG
function CraftSim.FRAME:ShowBestReagentAllocation(recipeData, recipeType, priceData, bestAllocation, hasItems, isSameAllocation)
    local materialFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.MATERIALS)
    hasItems = hasItems or CraftSim.SIMULATION_MODE.isActive
    if bestAllocation == nil or isSameAllocation then
        materialFrame.content.infoText:Show()
        if isSameAllocation then
            materialFrame.content.infoText:SetText(materialFrame.content.infoText.SameCombination)
        else
            materialFrame.content.infoText:SetText(materialFrame.content.infoText.NoCombinationFound)
        end

        materialFrame.content.qualityIcon:Hide()
        materialFrame.content.qualityText:Hide()
        materialFrame.content.allocateButton:Hide()

        for i = 1, 5, 1 do
            materialFrame.content.reagentFrames.rows[i]:Hide()
        end

        return
    else
        materialFrame.content.allocateText:Hide()
        materialFrame.content.infoText:Hide()
        materialFrame.content.qualityIcon:Show()
        materialFrame.content.qualityText:Show()
        materialFrame.content.allocateButton:Show()
        materialFrame.content.allocateButton:SetEnabled(CraftSim.SIMULATION_MODE.isActive)
        if CraftSim.SIMULATION_MODE.isActive then
            materialFrame.content.allocateButton:SetText("Assign")
            materialFrame.content.allocateButton:SetScript("OnClick", function(self) 
                -- uncheck best quality box if checked
                local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
                if bestQBox:GetChecked() then
                    bestQBox:Click()
                end
                CraftSim.REAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
            end)
        else
            materialFrame.content.allocateText:Show()
            materialFrame.content.allocateButton:Hide()
            if hasItems then
                materialFrame.content.allocateText:SetText(CraftSim.UTIL:ColorizeText("Materials available", CraftSim.CONST.COLORS.GREEN))
            else
                materialFrame.content.allocateText:SetText(CraftSim.UTIL:ColorizeText("Materials missing", CraftSim.CONST.COLORS.RED))
            end
        end
        materialFrame.content.allocateButton:SetSize(materialFrame.content.allocateButton:GetTextWidth() + 15, 25)
    end
    materialFrame.content.qualityIcon.SetQuality(bestAllocation.qualityReached)
    for frameIndex = 1, 5, 1 do
        local allocation = bestAllocation.allocations[frameIndex]
        if allocation ~= nil then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(allocation.allocations[1].itemID) 
            materialFrame.content.reagentFrames.rows[frameIndex].q1Icon:SetTexture(itemTexture)
            materialFrame.content.reagentFrames.rows[frameIndex].q2Icon:SetTexture(itemTexture)
            materialFrame.content.reagentFrames.rows[frameIndex].q3Icon:SetTexture(itemTexture)
            materialFrame.content.reagentFrames.rows[frameIndex].q1text:SetText(allocation.allocations[1].allocations)
            materialFrame.content.reagentFrames.rows[frameIndex].q2text:SetText(allocation.allocations[2].allocations)
            materialFrame.content.reagentFrames.rows[frameIndex].q3text:SetText(allocation.allocations[3].allocations)

            materialFrame.content.reagentFrames.rows[frameIndex]:Show()
        else
            materialFrame.content.reagentFrames.rows[frameIndex]:Hide()
        end
        
    end
end

function CraftSim.FRAME:UpdateProfitDetails(recipeData, calculationData)
    local profitDetailsFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS)
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

function CraftSim.FRAME:InitProfitDetailsFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame(
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
        CraftSim.CONST.FRAMES.PROFIT_DETAILS, false, 0, 0, "DIALOG")

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
        CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS), false)
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS).content.breakdownButton:SetText("Show Explanation")
    end)
end

function CraftSim.FRAME:FormatStatDiffpercentText(statDiff, roundTo, suffix)
    if statDiff == nil then
        statDiff = 0
    end
    local sign = "+"
    if statDiff < 0 then
        sign = ""
    end
    if suffix == nil then
        suffix = ""
    end
    return sign .. CraftSim.UTIL:round(statDiff, roundTo) .. suffix
end

function CraftSim.FRAME:GetProfessionEquipSlots()
    if ProfessionsFrame.CraftingPage.Prof0Gear0Slot:IsVisible() then
        return CraftSim.CONST.PROFESSION_INV_SLOTS[1]
    elseif ProfessionsFrame.CraftingPage.Prof1Gear0Slot:IsVisible() then
        return CraftSim.CONST.PROFESSION_INV_SLOTS[2]
    elseif ProfessionsFrame.CraftingPage.CookingGear0Slot:IsVisible() then
        return CraftSim.CONST.PROFESSION_INV_SLOTS[3]
    else
        --print("no profession tool slot visible.. what is going on?")
        return {}
    end
end

function CraftSim.FRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

function CraftSim.FRAME:initDropdownMenu(frameName, parent, anchorFrame, label, offsetX, offsetY, width, list, clickCallback, defaultValue, byData)
	local dropDown = CreateFrame("Frame", frameName, parent, "UIDropDownMenuTemplate")
    dropDown.clickCallback = clickCallback
	dropDown:SetPoint("TOP", anchorFrame, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, width)
	
    if byData then
        CraftSim.FRAME:initializeDropdownByData(dropDown, list, defaultValue)
    else
        CraftSim.FRAME:initializeDropdown(dropDown, list, defaultValue)
    end

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)

    dropDown.SetLabel = function(label) 
        dd_title:SetText(label)
    end

    dropDown.SetLabel(label)

    return dropDown
end

function CraftSim.FRAME:initializeDropdownByData(dropDown, list, defaultValue)
	UIDropDownMenu_Initialize(dropDown, function(self) 
		for k, v in pairs(list) do
            label = v.label
            value = v.value
			local info = UIDropDownMenu_CreateInfo()
            --print("init dropdown by data label: " .. tostring(label))
            --print("init dropdown by data value: " .. tostring(value))
			info.func = function(self, arg1, arg2, checked) 
                UIDropDownMenu_SetText(dropDown, self.value) -- value should contain the selected text..
                dropDown.clickCallback(dropDown, arg1)
            end
			info.text = label
			info.arg1 = value
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetText(dropDown, defaultValue)
end

function CraftSim.FRAME:initializeDropdown(dropDown, list, defaultValue)
	UIDropDownMenu_Initialize(dropDown, function(self) 
		for k, v in pairs(list) do
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(self, arg1, arg2, checked) 
                UIDropDownMenu_SetText(dropDown, arg1)
                dropDown.clickCallback(arg1)
            end
			info.text = v
			info.arg1 = v
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetText(dropDown, defaultValue)
end

function CraftSim.FRAME:CreateQualityIcon(frame, x, y, anchorFrame, anchorSelf, anchorParent, offsetX, offsetY, initialQuality)
    initialQuality = initialQuality or 1
    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(x, y)
    icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    icon:SetAtlas("Professions-Icon-Quality-Tier" .. initialQuality)
    icon:SetPoint(anchorSelf, anchorFrame, anchorParent, offsetX, offsetY)

    icon.SetQuality = function(qualityID) 
        if qualityID > 5 then
            qualityID = 5
        end
        icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
        icon:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
    end

    return icon
end

function CraftSim.FRAME:InitTabSystem(tabs)
    if #tabs == 0 then
        return
    end
    -- show first tab
    for _, tab in pairs(tabs) do
        tab:SetScript("OnClick", function(self) 
            for _, otherTab in pairs(tabs) do
                otherTab.content:Hide()
                otherTab:SetEnabled(otherTab.canBeEnabled)
            end
            tab.content:Show()
            tab:SetEnabled(false)
        end)
        tab.content:Hide()
    end
    tabs[1].content:Show()
    tabs[1]:SetEnabled(false)
end

function CraftSim.FRAME:makeFrameMoveable(frame)
	frame.hookFrame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, button)
		frame.hookFrame:StartMoving()
		end)
		frame:SetScript("OnMouseUp", function(self, button)
		frame.hookFrame:StopMovingOrSizing()
		end)
end

function CraftSim.FRAME:ResetFrames()
    for _, frameName in pairs(CraftSim.FRAME.frames) do
        local frame = _G[frameName]
        frame.hookFrame:ClearAllPoints()
        frame.resetPosition()
    end
end

local hooked = false
function CraftSim.FRAME:HandleAuctionatorOverlaps()
    if hooked then
        return
    end
    hooked = true
    if IsAddOnLoaded("Auctionator") then
        Auctionator.CraftingInfo._InitializeProfessionsFrame = Auctionator.CraftingInfo.InitializeProfessionsFrame
        Auctionator.CraftingInfo.InitializeProfessionsFrame = function(self) 
            Auctionator.CraftingInfo:_InitializeProfessionsFrame()
            AuctionatorCraftingInfoProfessionsFrame.SearchButton:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, "TOPLEFT", 0, 25)
        end
    end
end

function CraftSim.FRAME:MakeCollapsable(frame, originalX, originalY, frameID)
    frame.collapsed = false
    frame.collapseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.collapseButton:SetPoint("TOP", frame, "TOPRIGHT", -20, -10)	
	frame.collapseButton:SetText("-")
    frame.originalX = originalX -- so it can be modified later
    frame.originalY = originalY
	frame.collapseButton:SetSize(frame.collapseButton:GetTextWidth() + 15, 20)
    frame.collapse = function(self) 
        frame.collapsed = true
        CraftSimCollapsedFrames[frameID] = true
        -- make smaller and hide content, only show frameTitle
        frame:SetSize(self.originalX, 40)
        frame.collapseButton:SetText("+")
        frame.content:Hide()
        if frame.scrollFrame then
            frame.scrollFrame:Hide()
        end
    end

    frame.decollapse = function(self) 
        -- restore
        frame.collapsed = false
        CraftSimCollapsedFrames[frameID] = false
        frame.collapseButton:SetText("-")
        frame:SetSize(self.originalX, self.originalY)
        frame.content:Show()
        if frame.scrollFrame then
            frame.scrollFrame:Show()
        end
    end

    frame.collapseButton:SetScript("OnClick", function(self) 
        if frame.collapsed then
            frame:decollapse()
        else
            frame:collapse()
        end
    end)
end

function CraftSim.FRAME:CreateCraftSimFrame(name, title, parent, anchorFrame, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, 
    frameID, scrollable, scrollFrameWidthModX, scrollFrameWidthModY, frameStrata)
    local hookFrame = CreateFrame("frame", nil, parent)
    hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    local frame = CreateFrame("frame", name, hookFrame, "BackdropTemplate")
    frame.hookFrame = hookFrame
    hookFrame:SetSize(sizeX, sizeY)
    frame:SetSize(sizeX, sizeY)
    frame:SetFrameStrata(frameStrata or "HIGH")
    frame:SetFrameLevel(frameID) -- Prevent wierd overlap of craftsim frames

    frame.resetPosition = function() 
        hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -15)
	frame.title:SetText(title)
    
    frame:SetPoint("TOP",  hookFrame, "TOP", 0, 0)
	--frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		--bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})

    frame:SetBackdropColor(0, 0, 0 , 1)

    frame.SetTransparency = function(self, transparency) 
        frame:SetBackdropColor(0, 0, 0 , transparency)
    end

    CraftSim.FRAME:MakeCollapsable(frame, sizeX, sizeY, frameID)
    CraftSim.FRAME:makeFrameMoveable(frame)

    if scrollable then
        
        -- scrollframe
        frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        frame.scrollFrame.scrollChild = CreateFrame("frame")
        local scrollFrame = frame.scrollFrame
        local scrollChild = scrollFrame.scrollChild
        local offX = scrollFrameWidthModX or -70
        local offY = scrollFrameWidthModY or -50
        scrollFrame:SetSize(frame:GetWidth() + offX, frame:GetHeight() + offY)
        scrollFrame:SetPoint("TOP", frame.title, "TOP", 0, -20)
        scrollFrame:SetScrollChild(scrollFrame.scrollChild)
        scrollChild:SetWidth(scrollFrame:GetWidth() - 5)
        scrollChild:SetHeight(1) -- ??

        frame.content = scrollChild

        frame.UpdateSize = function(x, y) 
            frame:SetSize(x, y)
            scrollFrame:SetSize(frame:GetWidth() + offX, frame:GetHeight() + offY)
            scrollChild:SetWidth(scrollFrame:GetWidth() - 5)
        end
    else
        frame.content = CreateFrame("frame", nil, frame)
        frame.content:SetPoint("TOP", frame, "TOP")
        frame.content:SetSize(sizeX, sizeY)
    end
    
    CraftSim.FRAME.frames[frameID] = name
    return frame
end

function CraftSim.FRAME:UpdateStatDetailsByExtraItemFactors(recipeData)
    local lines = ProfessionsFrame.CraftingPage.SchematicForm.Details.statLinePool
	local activeObjects = lines.activeObjects

    local specData = recipeData.specNodeData

    local multicraftExtraItemsFactor = 1
    local resourcefulnessExtraItemsFactor = 1

    if specData then
        multicraftExtraItemsFactor = recipeData.stats.multicraft ~= nil and recipeData.stats.multicraft.bonusItemsFactor
        resourcefulnessExtraItemsFactor = recipeData.stats.resourcefulness ~= nil and recipeData.stats.resourcefulness.bonusItemsFactor
    else
        multicraftExtraItemsFactor = recipeData.extraItemFactors.multicraftExtraItemsFactor
        resourcefulnessExtraItemsFactor = recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
    end
    
	for statLine, _ in pairs(activeObjects) do 
        local multicraftText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT)
        local resourcefulnessText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS)
		if string.find(statLine.LeftLabel:GetText(), multicraftText) and (multicraftExtraItemsFactor or 0) > 1 then
			local baseText = multicraftText .. " "
			local formatted = CraftSim.UTIL:FormatFactorToPercent(multicraftExtraItemsFactor)
			local text = baseText .. CraftSim.UTIL:ColorizeText("" .. formatted .. " Items", CraftSim.CONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
		if string.find(statLine.LeftLabel:GetText(), resourcefulnessText) and (resourcefulnessExtraItemsFactor or 0) > 1 then
			local baseText = resourcefulnessText .. " " 
			local formatted = CraftSim.UTIL:FormatFactorToPercent(resourcefulnessExtraItemsFactor)
			local text = baseText .. CraftSim.UTIL:ColorizeText("" .. formatted .. " Items", CraftSim.CONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
	end
end

function CraftSim.FRAME:CreateCheckboxCustomCallback(label, description, initialValue, clickCallback, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local checkBox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkBox:SetHitRectInsets(0, 0, 0, 0); -- see https://wowpedia.fandom.com/wiki/API_Frame_SetHitRectInsets
	checkBox:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
	checkBox.Text:SetText(label)
    checkBox.tooltip = description
	-- there already is an existing OnClick script that plays a sound, hook it
    checkBox:SetChecked(false)
	checkBox:HookScript("OnClick", function() 
        clickCallback(checkBox) -- "self"
    end)

    if initialValue then
        checkBox:Click()
    end

    return checkBox
end

function CraftSim.FRAME:CreateCheckbox(label, description, optionName, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local checkBox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkBox:SetHitRectInsets(0, 0, 0, 0); -- see https://wowpedia.fandom.com/wiki/API_Frame_SetHitRectInsets
	checkBox:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
	checkBox.Text:SetText(label)
    checkBox.tooltip = description
	-- there already is an existing OnClick script that plays a sound, hook it
    checkBox:SetChecked(CraftSimOptions[optionName])
	checkBox:HookScript("OnClick", function(_, btn, down)
		local checked = checkBox:GetChecked()
		CraftSimOptions[optionName] = checked
	end)

    return checkBox
end

function CraftSim.FRAME:CreateSlider(name, label, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, orientation, min, max, initialValue, lowText, highText, updateCallback)
    local newSlider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    newSlider:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    newSlider:SetSize(sizeX, sizeY)
    newSlider:SetOrientation(orientation)
    newSlider:SetMinMaxValues(min, max)
    newSlider:SetValue(initialValue)
    _G[newSlider:GetName() .. 'Low']:SetText(lowText)        -- Sets the left-side slider text (default is "Low").
    _G[newSlider:GetName() .. 'High']:SetText(highText)     -- Sets the right-side slider text (default is "High").
    _G[newSlider:GetName() .. 'Text']:SetText(label)       -- Sets the "title" text (top-centre of slider).

    newSlider:SetScript("OnValueChanged", updateCallback)

    return newSlider
end

function CraftSim.FRAME:CreateHelpIcon(text, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local helpButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    helpButton.tooltipText = text
    helpButton:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)	
    helpButton:SetText("?")
    helpButton:SetSize(helpButton:GetTextWidth() + 15, 15)

    helpButton.SetTooltipText = function(newText) 
        helpButton.tooltipText = newText
    end

    helpButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:ClearLines() 
        GameTooltip:SetText(self.tooltipText)
        GameTooltip:Show()
    end)
    helpButton:SetScript("OnLeave", function(self) 
        GameTooltip:Hide()
    end)

    return helpButton
end

function CraftSim.FRAME:InitDebugFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimDebugFrame", "CraftSim Debug", 
    UIParent, 
    UIParent, 
    "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, 400, 400, CraftSim.CONST.FRAMES.DEBUG, true)
    CraftSim.FRAME:ToggleFrame(frame, CraftSimOptions.debugVisible)

    frame:HookScript("OnShow", function() CraftSimOptions.debugVisible = true end)
    frame:HookScript("OnHide", function() CraftSimOptions.debugVisible = false end)

    frame.content.debugBox = CreateFrame("EditBox", nil, frame.content)
    frame.content.debugBox:SetPoint("TOP", frame.content, "TOP", 0, -20)
    frame.content.debugBox:SetText("")
    frame.content.debugBox:SetWidth(frame.content:GetWidth() - 15)
    frame.content.debugBox:SetHeight(20)
    frame.content.debugBox:SetMultiLine(true)
    frame.content.debugBox:SetAutoFocus(false)
    frame.content.debugBox:SetFontObject("ChatFontNormal")
    frame.content.debugBox:SetScript("OnEscapePressed", function() frame.content.debugBox:ClearFocus() end)
    frame.content.debugBox:SetScript("OnEnterPressed", function() frame.content.debugBox:ClearFocus() end)

    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.closeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -9)	
	frame.closeButton:SetText("Close")
	frame.closeButton:SetSize(frame.closeButton:GetTextWidth()+5, 20)
    frame.closeButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG), false)
    end)

    frame.addDebug = function(debugOutput, debugID, printLabel) 
        if frame:IsVisible() then -- to not make it too bloated over time
            local currentOutput = frame.content.debugBox:GetText()
            if printLabel then
                frame.content.debugBox:SetText(currentOutput .. "\n\n- " .. debugID .. ":\n" .. tostring(debugOutput))
            else
                frame.content.debugBox:SetText(currentOutput .. "\n" .. tostring(debugOutput))
            end
        end
    end

    local controlPanel = CraftSim.FRAME:CreateCraftSimFrame("CraftSimDebugControlFrame", "Debug Control", 
    frame, 
    frame, 
    "TOPRIGHT", "TOPLEFT", 10, 0, 300, 400, CraftSim.CONST.FRAMES.DEBUG_CONTROL, true)

    controlPanel.content.clearButton = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.clearButton:SetPoint("TOP", controlPanel.title, "TOP", 0, -20)	
	controlPanel.content.clearButton:SetText("Clear")
	controlPanel.content.clearButton:SetSize(controlPanel.content.clearButton:GetTextWidth()+15, 25)
    controlPanel.content.clearButton:SetScript("OnClick", function(self) 
        frame.content.debugBox:SetText("")
    end)

    controlPanel.content.nodeDebugInput = CraftSim.FRAME:CreateInput(
        "CraftSimDebugNodeIDInput", controlPanel.content, controlPanel.content.clearButton, 
        "TOP", "TOP", -50, -25, 120, 20, "", function() end)

    controlPanel.content.debugNodeButton = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.debugNodeButton:SetPoint("LEFT", controlPanel.content.nodeDebugInput, "RIGHT", 10, 0)	
	controlPanel.content.debugNodeButton:SetText("Debug Node")
	controlPanel.content.debugNodeButton:SetSize(controlPanel.content.debugNodeButton:GetTextWidth()+15, 25)
    controlPanel.content.debugNodeButton:SetScript("OnClick", function(self) 
        local nodeIdentifier = CraftSimDebugNodeIDInput:GetText()
        CraftSim_DEBUG:CheckSpecNode(nodeIdentifier)
    end)

    controlPanel.content.compareData = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.compareData:SetPoint("TOPLEFT", controlPanel.content.nodeDebugInput, "TOPLEFT", -5, -25)	
	controlPanel.content.compareData:SetText("Compare UI/Spec Data")
	controlPanel.content.compareData:SetSize(controlPanel.content.compareData:GetTextWidth()+15, 25)
    controlPanel.content.compareData:SetScript("OnClick", function(self) 
        CraftSim_DEBUG:CompareStatData()
    end)

    local checkBoxOffsetY = -2
    controlPanel.content.checkBoxID_MAIN = CraftSim.FRAME:CreateCheckbox(
        " MAIN", "Enable MAIN Output", "enableDebugID_MAIN", controlPanel.content, controlPanel.content.nodeDebugInput, "TOPLEFT", "TOPLEFT", -5, checkBoxOffsetY - 55)
    
    local lastHook = controlPanel.content.checkBoxID_MAIN
    for _, debugID in pairs(CraftSim.CONST.DEBUG_IDS) do
        if debugID ~= CraftSim.CONST.DEBUG_IDS.MAIN then
            controlPanel.content["checkboxID_" .. debugID] = CraftSim.FRAME:CreateCheckbox(
        " " .. debugID, "Enable "..debugID.." Output", "enableDebugID_" .. debugID, controlPanel.content, lastHook, "TOPLEFT", "BOTTOMLEFT", 0, checkBoxOffsetY)
        lastHook = controlPanel.content["checkboxID_" .. debugID]
        end
    end

    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
end

function CraftSim.FRAME:InitWarningFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimWarningFrame", 
    CraftSim.UTIL:ColorizeText("CraftSim Warning", CraftSim.CONST.COLORS.RED), 
    UIParent, 
    UIParent, 
    "CENTER", "CENTER", 0, 0, 500, 500, CraftSim.CONST.FRAMES.WARNING, true)

    frame.content.warningText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.warningText:SetPoint("TOP", frame.content, "TOP", 0, -20)
    frame.content.warningText:SetText("No Warning")

    frame.content.errorBox = CreateFrame("EditBox", nil, frame.content)
    frame.content.errorBox:SetPoint("TOP", frame.content, "TOP", 0, -20)
    frame.content.errorBox:SetText("No Warning")
    frame.content.errorBox:SetWidth(frame.content:GetWidth() - 15)
    frame.content.errorBox:SetHeight(20)
    frame.content.errorBox:SetMultiLine(true)
    frame.content.errorBox:SetAutoFocus(false)
    frame.content.errorBox:SetFontObject("ChatFontNormal")
    
    frame.content.errorBox:SetScript("OnEscapePressed", function() frame.content.errorBox:ClearFocus() end)
    frame.content.errorBox:SetScript("OnEnterPressed", function() frame.content.errorBox:ClearFocus() end)

    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.closeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -9)	
	frame.closeButton:SetText("Close")
	frame.closeButton:SetSize(frame.closeButton:GetTextWidth()+15, 20)
    frame.closeButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.WARNING), false)
    end)

    frame.content.warningText:Hide()
    frame.content.errorBox:Hide()

    frame.showWarning = function(warningText, optionalTitle) 
        optionalTitle = optionalTitle or "CraftSim Warning"
        local wrapped = CraftSim.UTIL:WrapText(warningText, 50)
        frame.title:SetText(CraftSim.UTIL:ColorizeText(optionalTitle, CraftSim.CONST.COLORS.RED))
        frame.content.warningText:SetText(wrapped)
        frame.content.warningText:Show()
        frame.content.errorBox:Hide()
        frame.content.errorBox:SetText("")
        frame:Raise()
        frame:Show()
    end

    frame.showError = function(errorText, optionalTitle) 
        optionalTitle = optionalTitle or "CraftSim Warning"
        frame.title:SetText(CraftSim.UTIL:ColorizeText(optionalTitle, CraftSim.CONST.COLORS.RED))
        frame.content.errorBox:SetText(errorText)
        frame.content.errorBox:Show()
        frame.content.warningText:Hide()
        frame.content.warningText:SetText("")
        frame:Raise()
        frame:Show()
    end

    frame:Hide()
end

function CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
    if type(frame) == "table" and frame.SetHyperlinksEnabled and not frame.enabledLinks then -- prevent inf loop by references
        frame.enabledLinks = true
        frame:SetHyperlinksEnabled(true)
        frame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)

        for possibleFrame1, possibleFrame2 in pairs(frame) do
            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(possibleFrame1)
            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(possibleFrame2)
        end
    end
end

function CraftSim.FRAME:InitOneTimeNoteFrame()
    local currentVersion = GetAddOnMetadata(addonName, "Version")

    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimOneTimeNoteFrame", 
    CraftSim.UTIL:ColorizeText("CraftSim What's New? (" .. currentVersion .. ")", CraftSim.CONST.COLORS.GREEN), 
    UIParent, 
    UIParent, 
    "CENTER", "CENTER", 0, 0, 500, 300, CraftSim.CONST.FRAMES.INFO, true)

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.infoText:SetPoint("TOP", frame.content, "TOP", 0, -30)
    frame.content.infoText:SetText("No Info")

    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.closeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -9)	
	frame.closeButton:SetText("Close")
	frame.closeButton:SetSize(frame.closeButton:GetTextWidth()+5, 20)
    frame.closeButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.INFO), false)
    end)

    frame.showInfo = function(infoText) 
        frame.content.infoText:SetText(infoText)
        frame:Show()
    end

    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
    frame:Hide()
end

function CraftSim.FRAME:ShowOneTimeInfo(force)
    local infoText = CraftSim.NEWS:GET_NEWS()
    local versionID = CraftSim.CONST.currentInfoVersionID
    if CraftSimOptions.infoVersionID == versionID and not CraftSim.CONST.debugInfoText and not force then
        return
    end

    CraftSimOptions.infoVersionID = versionID

    local infoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.INFO)
    -- resize
    infoFrame.UpdateSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
    infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
    infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
    infoFrame.showInfo(infoText)
end

function CraftSim.FRAME:ShowWarning(warningText, optionalTitle)
    local warningFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.WARNING)
    warningFrame.showWarning(warningText, optionalTitle)
end

function CraftSim.FRAME:ShowError(errorText, optionalTitle)
    local warningFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.WARNING)
    warningFrame.showError(errorText, optionalTitle)
end

function CraftSim.FRAME:InitSpecInfoFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimSpecInfoFrame", 
    "CraftSim Specialization Info", 
    ProfessionsFrame.CraftingPage.SchematicForm, 
    CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR), 
    "TOPLEFT", "TOPRIGHT", -10, 0, 250, 300, CraftSim.CONST.FRAMES.SPEC_INFO)

    -- TODO: possible scrollframe?

    frame:Hide()

    frame.content.nodeLines = {}
    local function createNodeLine(parent, anchorParent, offsetY)
        local nodeLine = CreateFrame("frame", nil, parent)
        nodeLine:SetSize(frame.content:GetWidth(), 25)
        nodeLine:SetPoint("TOP", anchorParent, "TOP", 0, offsetY)

        nodeLine.statTooltip = CraftSim.FRAME:CreateHelpIcon("No data", nodeLine, nodeLine, "LEFT", "LEFT", 20, 0)

        nodeLine.nodeName = nodeLine:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nodeLine.nodeName:SetPoint("LEFT", nodeLine.statTooltip, "RIGHT", 10, 0)
        nodeLine.nodeName:SetText("NodeName")
        return nodeLine
    end
    -- TODO: how many do I need?
    local baseY = -20
    local nodeLineSpacingY = -20
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title, baseY))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*2))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*3))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*4))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*5))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*6))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*7))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*8))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*9))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*10))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*11))
end

function CraftSim.FRAME:FillSpecInfoFrame(recipeData)
    local professionID = recipeData.professionID

    local professionNodes = CraftSim.SPEC_DATA:GetNodes(professionID)

    
    local specInfoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)
    if recipeData.specNodeData and recipeData.specNodeData.affectedNodes and #recipeData.specNodeData.affectedNodes > 0 then
        --print("Affecting Nodes: " .. tostring(#recipeData.specNodeData.affectedNodes))
        for nodeLineIndex, nodeLine in pairs(specInfoFrame.content.nodeLines) do
            local affectedNode = recipeData.specNodeData.affectedNodes[nodeLineIndex]

            if affectedNode then
                local nodeNameData = CraftSim.UTIL:FilterTable(professionNodes, function(node) 
                    return affectedNode.nodeID == node.nodeID
                end)[1]

                local nodeName = nodeNameData.name

                nodeLine.nodeName:SetText(nodeName .. " (" .. tostring(affectedNode.nodeActualValue) .. "/" .. tostring(affectedNode.maxRanks-1) .. ")")

                local nodeStats = affectedNode.nodeStats

                local tooltipText = "This node grants you following stats for this recipe:\n\n"

                for statName, statValue in pairs(nodeStats) do
                    local translatedStatName = CraftSim.LOCAL:TranslateStatName(statName)
                    local includeStat = statValue > 0
                    local isPercent = false
                    if string.match(statName, "Factor")  then
                        isPercent = true
                        if statValue == 1 then
                            includeStat = false
                        end
                    end 
                    if includeStat then
                        if isPercent then
                            local displayValue = CraftSim.UTIL:FormatFactorToPercent(statValue)
                            tooltipText = tooltipText .. tostring(translatedStatName) .. ": " .. tostring(displayValue) .. "\n"
                        else
                            tooltipText = tooltipText .. tostring(translatedStatName) .. ": +" .. tostring(statValue) .. "\n"
                        end
                    end
                end

                nodeLine.statTooltip.SetTooltipText(tooltipText)
                nodeLine:Show()
            else
                nodeLine:Hide()
            end
        end
    elseif recipeData.specNodeData and recipeData.specNodeData.affectedNodes and #recipeData.specNodeData.affectedNodes == 0 then
        --specInfoFrame.content.nodeList:SetText("Recipe not affected by specializations")
    else
        --specInfoFrame.content.nodeList:SetText("Profession not implemented yet")
    end
end

function CraftSim.FRAME:CreateGoldInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, onTextChangedCallback)
    local goldInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
        goldInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        goldInput:SetSize(sizeX, sizeY)
        goldInput:SetAutoFocus(false) -- dont automatically focus
        goldInput:SetFontObject("ChatFontNormal")
        goldInput:SetText(initialValue)
        goldInput:SetScript("OnEscapePressed", function() goldInput:ClearFocus() end)
        goldInput:SetScript("OnEnterPressed", function() goldInput:ClearFocus() end)
        goldInput:SetScript("OnTextChanged", function(self) 
            local moneyValue = goldInput.getMoneyValue()
            onTextChangedCallback(moneyValue)
        end)

        goldInput.getMoneyValue = function()
            local inputText = goldInput:GetNumber()
            local totalCopper = inputText*10000

            --print("total value: " .. CraftSim.UTIL:FormatMoney(totalCopper))  
            return totalCopper
        end


    return goldInput
end

function CraftSim.FRAME:CreateInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, onTextChangedCallback)
    local numericInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
        numericInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        numericInput:SetSize(sizeX, sizeY)
        numericInput:SetAutoFocus(false) -- dont automatically focus
        numericInput:SetFontObject("ChatFontNormal")
        numericInput:SetText(initialValue)
        numericInput:SetScript("OnEscapePressed", function() numericInput:ClearFocus() end)
        numericInput:SetScript("OnEnterPressed", function() numericInput:ClearFocus() end)
        if onTextChangedCallback then
            numericInput:SetScript("OnTextChanged", onTextChangedCallback)
        end


    return numericInput
end


function CraftSim.FRAME:CreateNumericInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, allowNegative, onTextChangedCallback)
    local numericInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
        numericInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        numericInput:SetSize(sizeX, sizeY)
        numericInput:SetAutoFocus(false) -- dont automatically focus
        numericInput:SetFontObject("ChatFontNormal")
        numericInput:SetText(initialValue)
        numericInput:SetScript("OnEscapePressed", function() numericInput:ClearFocus() end)
        numericInput:SetScript("OnEnterPressed", function() numericInput:ClearFocus() end)
        numericInput:SetScript("OnTextChanged", onTextChangedCallback)

    -- blizzard's NumericInputSpinnerTemplate is ugly and not configurable enough, so I make my own duh!

    local buttonWidth = 5
    local buttonHeight = sizeY / 2 - 1
    local buttonOffsetX = 0
    local buttonOffsetY = -1
    numericInput.plusButton = CreateFrame("Button", nil, numericInput, "UIPanelButtonTemplate")
    numericInput.plusButton:SetPoint("TOPLEFT", numericInput, "TOPRIGHT", buttonOffsetX, buttonOffsetY)	
    numericInput.plusButton:SetText("+")
    numericInput.plusButton:SetSize(numericInput.plusButton:GetTextWidth() + buttonWidth, buttonHeight) -- make it smol
    numericInput.plusButton:SetScript("OnClick", function(self) 
        local currentValue = CraftSim.UTIL:ValidateNumberInput(numericInput, allowNegative)
        numericInput:SetText(currentValue + 1)
        onTextChangedCallback(numericInput, true) -- is the input "self" now? .. yes it is :D
    end)

    numericInput.minusButton = CreateFrame("Button", nil, numericInput, "UIPanelButtonTemplate")
    numericInput.minusButton:SetPoint("TOP", numericInput.plusButton, "BOTTOM", 0, 0)	
    numericInput.minusButton:SetText("-")
    numericInput.minusButton:SetSize(numericInput.minusButton:GetTextWidth() + buttonWidth, buttonHeight) -- make it smol
    numericInput.minusButton:SetScript("OnClick", function(self) 
        local currentValue = CraftSim.UTIL:ValidateNumberInput(numericInput, allowNegative)
        numericInput:SetText(currentValue - 1)
        onTextChangedCallback(numericInput, true) -- is the input "self" now? .. yes it is :D
    end)

    return numericInput
end