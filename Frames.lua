addonName, CraftSim = ...

CraftSim.FRAME = {}

CraftSim.FRAME.frames = {}

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
        ProfessionsFrame.CraftingPage.SchematicForm.Details, 
        "TOP", 
        "BOTTOM", 
        0, 
        19, 
        270, 
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
            statText = statText .. "Ø Profit:" .. "\n"
            local relativeValue = CraftSimOptions.showProfitPercentage and priceData.craftingCostPerCraft or nil
            valueText = valueText .. CraftSimUTIL:FormatMoney(statWeights.meanProfit, true, relativeValue) .. "\n"
        end
        if statWeights.inspiration then
            statText = statText .. "Inspiration:" .. "\n"
            valueText = valueText .. CraftSimUTIL:FormatMoney(statWeights.inspiration) .. "\n"
        end
        if statWeights.multicraft then
            statText = statText .. "Multicraft:" .. "\n"
            valueText = valueText .. CraftSimUTIL:FormatMoney(statWeights.multicraft) .. "\n"
        end
        if statWeights.resourcefulness then
            statText = statText .. "Resourcefulness:"
            valueText = valueText .. CraftSimUTIL:FormatMoney(statWeights.resourcefulness)
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

function CraftSim.FRAME:InitPriceDataWarningFrame()	
    
	-- TODO: price data warning frame.. utilize something similar to the ketho editbox...
    
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
        CraftSim.MAIN:TriggerModulesByRecipeType() -- TODO: if this is not performant enough, try to only recalc the material stuff not all, lazy solution for now
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
    hasItems = hasItems or CraftSimSIMULATION_MODE.isActive
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
        materialFrame.content.allocateButton:SetEnabled(CraftSimSIMULATION_MODE.isActive)
        if CraftSimSIMULATION_MODE.isActive then
            materialFrame.content.allocateButton:SetText("Assign")
            materialFrame.content.allocateButton:SetScript("OnClick", function(self) 
                -- uncheck best quality box if checked
                local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
                if bestQBox:GetChecked() then
                    bestQBox:Click()
                end
                CraftSimREAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
            end)
        else
            materialFrame.content.allocateText:Show()
            materialFrame.content.allocateButton:Hide()
            if hasItems then
                materialFrame.content.allocateText:SetText(CraftSimUTIL:ColorizeText("Materials available", CraftSim.CONST.COLORS.GREEN))
            else
                materialFrame.content.allocateText:SetText(CraftSimUTIL:ColorizeText("Materials missing", CraftSim.CONST.COLORS.RED))
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

function CraftSim.FRAME:InitCostOverviewFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimCostOverviewFrame", 
        "CraftSim Cost Overview", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        CraftSimSimFrame, 
        "TOP", 
        "BOTTOM", 
        0, 
        10, 
        250, 
        270,
        CraftSim.CONST.FRAMES.COST_OVERVIEW)

    local contentOffsetY = -20
    local textSpacingY = -20

    frame.content.minCraftingCostsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.minCraftingCostsTitle:SetPoint("TOP", frame.title, "TOP", 0, textSpacingY)
    frame.content.minCraftingCostsTitle:SetText("Min Crafting Costs")

    frame.content.minCraftingCosts = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.minCraftingCosts:SetPoint("TOP", frame.content.minCraftingCostsTitle, "TOP", 0, textSpacingY)
    frame.content.minCraftingCosts:SetText("???")

    frame.content.craftingCostsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.craftingCostsTitle:SetPoint("TOP", frame.content.minCraftingCosts, "TOP", 0, textSpacingY)
    frame.content.craftingCostsTitle:SetText("Current Crafting Costs")
    frame.content.craftingCostsTitle.SwitchAnchor = function(newAnchor) 
        frame.content.craftingCostsTitle:SetPoint("TOP", newAnchor, "TOP", 0, textSpacingY)
    end

    frame.content.craftingCosts = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.craftingCosts:SetPoint("TOP", frame.content.craftingCostsTitle, "TOP", 0, textSpacingY)
    frame.content.craftingCosts:SetText("???")
    

    frame.content.resultProfitsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.resultProfitsTitle:SetPoint("TOP", frame.content.craftingCosts, "TOP", 0, textSpacingY - 10)
    frame.content.resultProfitsTitle:SetText("Profit By Quality")

    local function createProfitFrame(offsetY, parent, newHookFrame)
        local profitFrame = CreateFrame("frame", nil, parent)
        profitFrame:SetSize(parent:GetWidth(), 25)
        profitFrame:SetPoint("TOP", newHookFrame, "TOP", 0, offsetY)
        profitFrame.icon = CraftSim.FRAME:CreateQualityIcon(profitFrame, 20, 20, profitFrame, "CENTER", "CENTER", -75, 0)

        profitFrame.text = profitFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        profitFrame.text:SetPoint("LEFT", profitFrame.icon, "LEFT", 30, 0)
        profitFrame.text:SetText("???")

        profitFrame:Hide()
        return profitFrame
    end

    local baseY = -20
    local profitFramesSpacingY = -20
    frame.content.profitFrames = {}
    table.insert(frame.content.profitFrames, createProfitFrame(baseY, frame.content, frame.content.resultProfitsTitle))
    table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY, frame.content, frame.content.resultProfitsTitle))
    table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*2, frame.content, frame.content.resultProfitsTitle))
    table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*3, frame.content, frame.content.resultProfitsTitle))
    table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*4, frame.content, frame.content.resultProfitsTitle))
    

	frame:Hide()
end

function CraftSim.FRAME:FillCostOverview(craftingCosts, minCraftingCosts, profitPerQuality, currentQuality)
    local costOverviewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.COST_OVERVIEW)
    if craftingCosts == minCraftingCosts then
        costOverviewFrame.content.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))
        costOverviewFrame.content.craftingCostsTitle.SwitchAnchor(costOverviewFrame.title)
        costOverviewFrame.content.minCraftingCosts:Hide()
        costOverviewFrame.content.minCraftingCostsTitle:Hide()
    else
        costOverviewFrame.content.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))
        costOverviewFrame.content.minCraftingCosts:SetText(CraftSimUTIL:FormatMoney(minCraftingCosts))
        costOverviewFrame.content.craftingCostsTitle.SwitchAnchor(costOverviewFrame.content.minCraftingCosts)
        costOverviewFrame.content.minCraftingCosts:Show()
        costOverviewFrame.content.minCraftingCostsTitle:Show()
    end

    CraftSim.FRAME:ToggleFrame(costOverviewFrame.content.resultProfitsTitle, #profitPerQuality > 0)

    for index, profitFrame in pairs(costOverviewFrame.content.profitFrames) do
        if profitPerQuality[index] ~= nil then
            profitFrame.icon.SetQuality(currentQuality + index - 1)
            local relativeValue = CraftSimOptions.showProfitPercentage and craftingCosts or nil
            profitFrame.text:SetText(CraftSimUTIL:FormatMoney(profitPerQuality[index], true, relativeValue))
            profitFrame:Show()
        else
            profitFrame:Hide()
        end
    end
end

function CraftSim.FRAME:UpdateProfitDetails(recipeData, calculationData)
    -- print("calcData:")
    -- CraftSimUTIL:PrintTable(calculationData, true)
    local profitDetailsFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS)

    profitDetailsFrame.content.craftingCostValue:SetText(CraftSimUTIL:FormatMoney(calculationData.craftingCostPerCraft))

    local profitCalculationText = "(((M_AI_1 * M_AV_1 + M_AI_2 * M_AV_2) + (I_I_1 * I_V_1 + I_I_2 * I_V_2)) * 0.95) - CCC - MCS = " .. CraftSimUTIL:FormatMoney(calculationData.meanProfit, true)
    profitDetailsFrame.content.averageProfitValue:SetText(profitCalculationText)


    local isMaxQuality = recipeData.expectedQuality == recipeData.maxQuality

    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.resourcefulnessInfo, calculationData.resourcefulness)
    if calculationData.resourcefulness then
        profitDetailsFrame.content.resourcefulnessInfo.averageSavedCostsValue:SetText(CraftSimUTIL:FormatMoney(calculationData.resourcefulness.averageSavedCosts))
    end

    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo, calculationData.multicraft)
    if calculationData.multicraft then
        profitDetailsFrame.content.multicraftInfo.currentQualityIcon.SetQuality(recipeData.expectedQuality)
        profitDetailsFrame.content.multicraftInfo.currentQualityIcon2.SetQuality(recipeData.expectedQuality)
        
        profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetText(CraftSimUTIL:round(calculationData.multicraft.averageMulticraftItemsCurrent, 3))
        profitDetailsFrame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetText(CraftSimUTIL:FormatMoney(calculationData.multicraft.averageMulticraftCurrentValue))
        
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.higherQualityIcon, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.higherQualityIcon2, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalHigherQualityValue, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle.helper, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, not isMaxQuality)
        CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle.helper, not isMaxQuality)
        if not recipeData.result.isNoQuality and not isMaxQuality then
            profitDetailsFrame.content.multicraftInfo.higherQualityIcon.SetQuality(recipeData.expectedQuality + 1)
            profitDetailsFrame.content.multicraftInfo.higherQualityIcon2.SetQuality(recipeData.expectedQuality + 1)
            profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetText(CraftSimUTIL:round(calculationData.multicraft.averageMulticraftItemsHigher, 3))
            profitDetailsFrame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetText(CraftSimUTIL:FormatMoney(calculationData.multicraft.averageMulticraftHigherValue))
        end
    end
    
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo, calculationData.inspiration)
    profitDetailsFrame.content.inspirationInfo.currentQualityIcon.SetQuality(recipeData.expectedQuality)
    profitDetailsFrame.content.inspirationInfo.currentQualityIcon2.SetQuality(recipeData.expectedQuality)

    profitDetailsFrame.content.inspirationInfo.averageCurrentQualityItemsValue:SetText(CraftSimUTIL:round(calculationData.inspiration.averageInspirationItemsCurrent, 3))
    profitDetailsFrame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(calculationData.inspiration.inspirationItemsValueCurrent))

    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.higherQualityIcon, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.higherQualityIcon2, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsValue, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsValue, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsTitle, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsTitle.helper, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsTitle, not isMaxQuality)
    CraftSim.FRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsTitle.helper, not isMaxQuality)
    if  not recipeData.result.isNoQuality and not isMaxQuality then
        profitDetailsFrame.content.inspirationInfo.higherQualityIcon.SetQuality(recipeData.expectedQuality + 1)
        profitDetailsFrame.content.inspirationInfo.higherQualityIcon2.SetQuality(recipeData.expectedQuality + 1)
        
        profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsValue:SetText(CraftSimUTIL:round(calculationData.inspiration.averageInspirationItemsHigher or 0, 3))
        profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(calculationData.inspiration.inspirationItemsValueHigher or 0))
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
        CraftSim.CONST.FRAMES.PROFIT_DETAILS)

    frame:SetFrameStrata("HIGH")
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
        CraftSimUTIL:ColorizeText("The Ø value of additional items from multicraft considering inspiration and multicraft proccing together\n", blue) ..
        CraftSimUTIL:ColorizeText("+\n", green) ..
        CraftSimUTIL:ColorizeText("The worth of the Ø number of items gained per quality based on your inspiration\n", blue) ..
        CraftSimUTIL:ColorizeText("*\n", red) .. CraftSimUTIL:ColorizeText("0.95\n", red) .. CraftSimUTIL:ColorizeText("(5% auction house cut)\n", blue) .. 
        CraftSimUTIL:ColorizeText("-\n", red) ..
        CraftSimUTIL:ColorizeText("The total crafting costs based on the materials and their quality you currently selected\n", blue) ..
        CraftSimUTIL:ColorizeText("-\n", red) ..
        CraftSimUTIL:ColorizeText("The sum of the Ø material cost saved from resourcefulness\n\n", blue) ..
        "If you do not have enough of a material, CraftSim assumes the cheapest quality of a material\n(Does not have not be the lowest quality)")

    local descriptionHeight = frame.content.description:GetNumLines() * frame.content.description:GetLineHeight()


    frame.content.craftingCostTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.craftingCostTitle:SetPoint("TOP", frame.content.description, "TOP", 0, - (descriptionHeight + 15))
	frame.content.craftingCostTitle:SetText("Current Crafting Costs (CCC)")
	frame.content.craftingCostTitle:SetTextScale(headerScale)

    frame.content.craftingCostValue = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.craftingCostValue:SetPoint("TOP", frame.content.craftingCostTitle, "TOP", 0, -20)
	frame.content.craftingCostValue:SetText(CraftSimUTIL:FormatMoney(0))

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
	frame.content.resourcefulnessInfo.averageSavedCostsValue:SetText(CraftSimUTIL:FormatMoney(1234789))


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
	frame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetText(CraftSimUTIL:FormatMoney(0))
    
    frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalCurrentQualityValue, "TOP", 0, segmentOffsetY)
	frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle:SetText("Ø Additional Value (M_AIV_2)")
    frame.content.multicraftInfo.higherQualityIcon2 = CraftSim.FRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, "LEFT", "RIGHT", 0, 0)
    frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP), 
    frame.content.multicraftInfo, frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, 
    "RIGHT", "LEFT", 0, 0)

    frame.content.multicraftInfo.averageAdditionalHigherQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetText(CraftSimUTIL:FormatMoney(0))

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
	frame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(0))
    
    frame.content.inspirationInfo.valueByHigherQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.valueByHigherQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.valueByCurrentQualityItemsValue, "TOP", 0, segmentOffsetY)
	frame.content.inspirationInfo.valueByHigherQualityItemsTitle:SetText("Ø Value (I_V_2)")
    frame.content.inspirationInfo.higherQualityIcon2 = CraftSim.FRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.valueByHigherQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
    frame.content.inspirationInfo.valueByHigherQualityItemsTitle.helper = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP), 
    frame.content.inspirationInfo, frame.content.inspirationInfo.valueByHigherQualityItemsTitle, 
    "RIGHT", "LEFT", 0, 0)


    frame.content.inspirationInfo.valueByHigherQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.valueByHigherQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.valueByHigherQualityItemsTitle, "TOP", 0, -20)
	frame.content.inspirationInfo.valueByHigherQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(0))

    frame.content.hideButton = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.hideButton:SetPoint("BOTTOM", frame.content, "BOTTOM", 0, 20)	
	frame.content.hideButton:SetText("Close")
	frame.content.hideButton:SetSize(frame.content.hideButton:GetTextWidth()+15, 25)
    frame.content.hideButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_DETAILS), false)
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS).content.breakdownButton:SetText("Show Explanation")
    end)
end

function CraftSim.FRAME:InitGearSimFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimSimFrame", 
        "CraftSim Top Gear", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CloseButton, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -5, 
        3, 
        250, 
        300,
        CraftSim.CONST.FRAMES.TOP_GEAR)

    local contentOffsetY = -20
    local iconsOffsetY = 80
    frame.content.gear1Icon = CraftSim.FRAME:CreateIcon(frame.content, -45, contentOffsetY + iconsOffsetY, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.content.gear2Icon = CraftSim.FRAME:CreateIcon(frame.content,  -0, contentOffsetY + iconsOffsetY, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.content.toolIcon = CraftSim.FRAME:CreateIcon(frame.content, 50, contentOffsetY + iconsOffsetY, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40)

    frame.content.equipButton = CreateFrame("Button", "CraftSimTopGearEquipButton", frame.content, "UIPanelButtonTemplate")
	frame.content.equipButton:SetSize(50, 25)
	frame.content.equipButton:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY + 40)	
	frame.content.equipButton:SetText("Equip")
    frame.content.equipButton:SetScript("OnClick", function(self) 
        CraftSim.GEARSIM:EquipTopGear()
    end)

    frame.content.simModeDropdown = 
    CraftSim.FRAME:initDropdownMenu("CraftSimTopGearSimMode", frame.content, frame.title, "", 0, contentOffsetY, 120, {"Placeholder"}, function(arg1) 
        CraftSimOptions.topGearMode = arg1
        CraftSim.GEARSIM:SimulateBestProfessionGearCombination(CraftSimTopGearSimMode.recipeData, CraftSimTopGearSimMode.recipeType, CraftSimTopGearSimMode.priceData)
    end, "Placeholder")
    frame.content.profitText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.profitText:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY + 10)

    frame.content.statDiff = CreateFrame("frame", nil, frame.content)
    frame.content.statDiff:SetSize(200, 100)
    frame.content.statDiff:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY - 50)

    local statTxtSpacingY = -15
    frame.content.statDiff.inspiration = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.statDiff.inspiration:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*1)
    frame.content.statDiff.inspiration:SetText("Inspiration: ")

    frame.content.statDiff.multicraft = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.statDiff.multicraft:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*2)
    frame.content.statDiff.multicraft:SetText("Multicraft: ")

    frame.content.statDiff.resourcefulness = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.statDiff.resourcefulness:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*3)
    frame.content.statDiff.resourcefulness:SetText("Resourcefulness: ")

    frame.content.statDiff.craftingspeed = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.statDiff.craftingspeed:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*4)
    frame.content.statDiff.craftingspeed:SetText("Crafting Speed: ")

    frame.content.statDiff.skill = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.statDiff.skill:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*5)
    frame.content.statDiff.skill:SetText("Skill: ")

    frame.content.statDiff.quality = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.statDiff.quality:SetPoint("TOP", frame.content.statDiff, "TOP", -5, statTxtSpacingY*6)
    frame.content.statDiff.quality:SetText("Quality: ")

    frame.content.statDiff.qualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content, 20, 20, frame.content.statDiff.quality, "LEFT", "RIGHT", 3, 0)

	frame:Hide()
end

function CraftSim.FRAME:ShowComboItemIcons(professionGearCombo, isCooking)
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    local iconButtons = {topGearFrame.content.toolIcon, topGearFrame.content.gear1Icon, topGearFrame.content.gear2Icon}
    for _, button in pairs(iconButtons) do
        button:Hide() -- only to consider cooking ...
    end
    if isCooking then
        iconButtons = {topGearFrame.content.toolIcon, topGearFrame.content.gear2Icon}
    end

    for index, iconButton in pairs(iconButtons) do
        iconButton:Show()
        if not professionGearCombo[index].isEmptySlot then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(professionGearCombo[index].itemLink) 
            iconButton:SetNormalTexture(itemTexture)
            iconButton:SetScript("OnEnter", function(self) 
                local itemName, ItemLink = GameTooltip:GetItem()
                GameTooltip:SetOwner(topGearFrame.content, "ANCHOR_RIGHT");
                if ItemLink ~= professionGearCombo[index].itemLink then
                    -- to not set it again and hide the tooltip..
                    GameTooltip:SetHyperlink(professionGearCombo[index].itemLink)
                end
				GameTooltip:Show();
            end)
            iconButton:SetScript("OnLeave", function(self) 
                GameTooltip:Hide();
            end)
        else
            -- show empty slot texture?
            iconButton:SetNormalTexture(CraftSim.CONST.EMPTY_SLOT_TEXTURE)
            iconButton:SetScript("OnEnter", nil)
            iconButton:SetScript("OnLeave", nil)
        end
    end
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
    return sign .. CraftSimUTIL:round(statDiff, roundTo) .. suffix
end

function CraftSim.FRAME:FillSimResultData(bestSimulation, topGearMode, isCooking)
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    CraftSim.FRAME:ShowComboItemIcons(bestSimulation.combo, isCooking)
    if not CraftSim.GEARSIM.IsEquipping then
        topGearFrame.currentCombo = bestSimulation.combo
    end
    -- TODO: maybe show in red or smth if negative
    if topGearMode == CraftSim.CONST.GEAR_SIM_MODES.PROFIT then
        topGearFrame.content.profitText:SetText("Ø Profit Difference\n".. CraftSimUTIL:FormatMoney(bestSimulation.profitDiff, true))
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT then
        topGearFrame.content.profitText:SetText("New Multicraft\n".. CraftSimUTIL:round(bestSimulation.multicraftPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        topGearFrame.content.profitText:SetText("New Crafting Speed\n".. CraftSimUTIL:round(bestSimulation.craftingspeedPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        topGearFrame.content.profitText:SetText("New Resourcefulness\n".. CraftSimUTIL:round(bestSimulation.resourcefulnessPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION then
        topGearFrame.content.profitText:SetText("New Inspiration\n".. CraftSimUTIL:round(bestSimulation.inspirationPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.SKILL then
        topGearFrame.content.profitText:SetText("New Skill\n".. bestSimulation.skill)
    else
        topGearFrame.content.profitText:SetText("Unhandled Sim Mode")
    end
    CraftSimTopGearEquipButton:SetEnabled(true)

    local inspirationBonusSkillText = ""
    if bestSimulation.statDiff.inspirationBonusskill then
        local prefix = "+" or ("-" and bestSimulation.statDiff.inspirationBonusskill < 0)
        inspirationBonusSkillText = " (" .. prefix .. CraftSimUTIL:round(bestSimulation.statDiff.inspirationBonusskill, 0) .. " Bonus)"
    end

    topGearFrame.content.statDiff.inspiration:SetText("Inspiration: " .. CraftSim.FRAME:FormatStatDiffpercentText(bestSimulation.statDiff.inspiration, 2, "%") .. inspirationBonusSkillText)
    topGearFrame.content.statDiff.multicraft:SetText("Multicraft: " .. CraftSim.FRAME:FormatStatDiffpercentText(bestSimulation.statDiff.multicraft, 2, "%"))
    topGearFrame.content.statDiff.resourcefulness:SetText("Resourcefulness: " .. CraftSim.FRAME:FormatStatDiffpercentText(bestSimulation.statDiff.resourcefulness, 2, "%"))
    topGearFrame.content.statDiff.craftingspeed:SetText("Crafting Speed: " .. CraftSim.FRAME:FormatStatDiffpercentText(bestSimulation.statDiff.craftingspeed, 2, "%"))
    topGearFrame.content.statDiff.skill:SetText("Skill: " .. CraftSim.FRAME:FormatStatDiffpercentText(bestSimulation.statDiff.skill, 0))

    if CraftSimTopGearSimMode.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE and CraftSimTopGearSimMode.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
        topGearFrame.content.statDiff.qualityIcon.SetQuality(bestSimulation.modifiedRecipeData.expectedQuality)
        topGearFrame.content.statDiff.quality:Show()
        topGearFrame.content.statDiff.qualityIcon:Show()
    else
        topGearFrame.content.statDiff.quality:Hide()
        topGearFrame.content.statDiff.qualityIcon:Hide()
    end

end

function CraftSim.FRAME:ClearResultData(isCooking)
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    if not isCooking then
        CraftSim.FRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    else
        CraftSim.FRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    end

    CraftSimTopGearEquipButton:SetEnabled(false)
    topGearFrame.content.profitText:SetText("Top Gear equipped")

    topGearFrame.content.statDiff.inspiration:SetText("")
    topGearFrame.content.statDiff.multicraft:SetText("")
    topGearFrame.content.statDiff.resourcefulness:SetText("")
    topGearFrame.content.statDiff.craftingspeed:SetText("")
    topGearFrame.content.statDiff.skill:SetText("")
    topGearFrame.content.statDiff.quality:Hide()
    topGearFrame.content.statDiff.qualityIcon:Hide()
end

function CraftSim.FRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

function CraftSim.FRAME:initDropdownMenu(frameName, parent, anchorFrame, label, offsetX, offsetY, width, list, clickCallback, defaultValue)
	local dropDown = CreateFrame("Frame", frameName, parent, "UIDropDownMenuTemplate")
    dropDown.clickCallback = clickCallback
	dropDown:SetPoint("TOP", anchorFrame, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, width)
	
	CraftSim.FRAME:initializeDropdown(dropDown, list, defaultValue)

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)
	dd_title:SetText(label)
    return dropDown
end

function CraftSim.FRAME:initializeDropdown(dropDown, list, defaultValue)
	UIDropDownMenu_Initialize(dropDown, function(self) 
		for k, v in pairs(list) do
			name = v
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(self, arg1, arg2, checked) 
                UIDropDownMenu_SetText(dropDown, arg1)
                dropDown.clickCallback(arg1)
            end

			info.text = name
			info.arg1 = info.text
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
    local materialFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.MATERIALS)
    local costOverviewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.COST_OVERVIEW)
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    local statweightFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS)
    materialFrame:ClearAllPoints()
    costOverviewFrame:ClearAllPoints()
    topGearFrame:ClearAllPoints()
    statweightFrame:ClearAllPoints()
    materialFrame:SetPoint("TOP",  ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, "BOTTOM", 0, 0)
    costOverviewFrame:SetPoint("TOP",  topGearFrame, "BOTTOM", 0, 10)
    topGearFrame:SetPoint("TOPLEFT",  ProfessionsFrame.CloseButton, "TOPRIGHT", -5, 3)
    statweightFrame:SetPoint("TOP",  ProfessionsFrame.CraftingPage.SchematicForm.Details, "BOTTOM", 0, 19)
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
	frame.collapseButton:SetSize(frame.collapseButton:GetTextWidth() + 15, 20)
    frame.collapse = function(self) 
        frame.collapsed = true
        CraftSimCollapsedFrames[frameID] = true
        -- make smaller and hide content, only show frameTitle
        frame:SetSize(originalX, 40)
        frame.collapseButton:SetText("+")
        frame.content:Hide()
    end

    frame.decollapse = function(self) 
        -- restore
        frame.collapsed = false
        CraftSimCollapsedFrames[frameID] = false
        frame.collapseButton:SetText("-")
        frame:SetSize(originalX, originalY)
        frame.content:Show()
    end

    frame.collapseButton:SetScript("OnClick", function(self) 
        if frame.collapsed then
            frame.decollapse()
        else
            frame.collapse()
        end
    end)
end

function CraftSim.FRAME:CreateCraftSimFrame(name, title, parent, anchorFrame, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, frameID)
    local hookFrame = CreateFrame("frame", nil, parent)
    hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    local frame = CreateFrame("frame", name, hookFrame, "BackdropTemplate")
    frame.hookFrame = hookFrame
    hookFrame:SetSize(sizeX, sizeY)
    frame:SetSize(sizeX, sizeY)

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
	
    frame.content = CreateFrame("frame", nil, frame)
    frame.content:SetPoint("TOP", frame, "TOP")
    frame.content:SetSize(sizeX, sizeY)


    CraftSim.FRAME.frames[frameID] = name
    return frame
end

--multicraftBonusItemsFactor = 1,
-- resourcefulnessBonusItemsFactor = 1

function CraftSim.FRAME:UpdateStatDetailsByExtraItemFactors(recipeData)
    local lines = ProfessionsFrame.CraftingPage.SchematicForm.Details.statLinePool
	local activeObjects = lines.activeObjects
    -- TODO: update tooltips of statlines to explain the extra item stuff to save space
	for statLine, _ in pairs(activeObjects) do 
		if string.find(statLine.LeftLabel:GetText(), "Multicraft") and (recipeData.extraItemFactors.multicraftBonusItemsFactor or 0) > 1 then
			local baseText = "Multicraft "
			local formatted = CraftSimUTIL:FormatFactorToPercent(recipeData.extraItemFactors.multicraftBonusItemsFactor)
			local text = baseText .. CraftSimUTIL:ColorizeText("" .. formatted .. " Items", CraftSim.CONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
		if string.find(statLine.LeftLabel:GetText(), "Resourcefulness") and (recipeData.extraItemFactors.resourcefulnessBonusItemsFactor or 0) > 1 then
			local baseText = "Resourcefulness " 
			local formatted = CraftSimUTIL:FormatFactorToPercent(recipeData.extraItemFactors.resourcefulnessBonusItemsFactor)
			local text = baseText .. CraftSimUTIL:ColorizeText("" .. formatted .. " Items", CraftSim.CONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
	end
end

function CraftSim.FRAME:CreateCheckbox(label, description, optionName, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local checkBox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
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
    helpButton:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)	
    helpButton:SetText("?")
    helpButton:SetSize(helpButton:GetTextWidth() + 15, 15)

    helpButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:ClearLines() 
        GameTooltip:SetText(text)
        GameTooltip:Show()
    end)
    helpButton:SetScript("OnLeave", function(self) 
        GameTooltip:Hide()
    end)

    return helpButton
end

function CraftSim.FRAME:InitSimModeFrames()
    -- BUTTON
    local toggleButton = CreateFrame("Button", "CraftSimSimModeToggleButton", ProfessionsFrame.CraftingPage.SchematicForm, "UIPanelButtonTemplate")
    toggleButton:SetPoint("BOTTOM", ProfessionsFrame.CraftingPage.SchematicForm.Details, "TOP", 0, 0)	
    toggleButton:SetText("Simulation Mode: Off")
    toggleButton:SetSize(toggleButton:GetTextWidth() + 15, 20)
    toggleButton:SetScript("OnClick", function(self) 
        CraftSimSIMULATION_MODE.isActive = not CraftSimSIMULATION_MODE.isActive
        toggleButton:SetText(CraftSimSIMULATION_MODE.isActive and "Simulation Mode: On" or "Simulation Mode: Off")
        local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
        if bestQBox:GetChecked() and CraftSimSIMULATION_MODE.isActive then
            bestQBox:Click()
        end
        if CraftSimSIMULATION_MODE.isActive then
            CraftSimSIMULATION_MODE:InitializeSimulationMode(CraftSim.MAIN.currentRecipeData)
        end

        CraftSim.MAIN:TriggerModulesByRecipeType()
    end)

    toggleButton:Hide()

    -- REAGENT OVERWRITE FRAMES
    local reagentOverwriteFrame = CreateFrame("frame", nil, ProfessionsFrame.CraftingPage.SchematicForm)
    reagentOverwriteFrame:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.SchematicForm.Reagents, "TOPLEFT", -40, -35)
    reagentOverwriteFrame:SetSize(200, 400)
    reagentOverwriteFrame:Hide()

    local baseX = 10
    local inputOffsetX = 25

    reagentOverwriteFrame.qualityIcon1 = CraftSim.FRAME:CreateQualityIcon(reagentOverwriteFrame, 20, 20, reagentOverwriteFrame, "TOP", "TOP", baseX - 15, 15, 1)
    reagentOverwriteFrame.qualityIcon2 = CraftSim.FRAME:CreateQualityIcon(reagentOverwriteFrame, 20, 20, reagentOverwriteFrame, "TOP", "TOP", baseX+inputOffsetX - 15, 15, 2)
    reagentOverwriteFrame.qualityIcon3 = CraftSim.FRAME:CreateQualityIcon(reagentOverwriteFrame, 20, 20, reagentOverwriteFrame, "TOP", "TOP", baseX+inputOffsetX*2 - 15, 15, 3)

    reagentOverwriteFrame.reagentOverwriteInputs = {}

    local offsetY = -45

    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.FRAME:CreateSimModeReagentOverwriteFrame(reagentOverwriteFrame, 0, 0, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.FRAME:CreateSimModeReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.FRAME:CreateSimModeReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*2, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.FRAME:CreateSimModeReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*3, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.FRAME:CreateSimModeReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*4, baseX, inputOffsetX))

    CraftSimSIMULATION_MODE.reagentOverwriteFrame = reagentOverwriteFrame

    -- DETAILS FRAME
    local simModeDetailsFrame = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimSimModeDetailsFrame", 
        "CraftSim Details", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm.Details, 
        "TOP", 
        "TOP", 
        0, 
        0, 
        270, 
        300, 
        CraftSim.CONST.FRAMES.CRAFTING_DETAILS)

        local offsetY = -20
        local modOffsetX = 20
        local valueOffsetX = -5
        local valueOffsetY = 0.5

        -- recipe difficulty
        simModeDetailsFrame.content.recipeDifficultyTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.recipeDifficultyTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content, "TOPLEFT", 20, offsetY - 20)
        simModeDetailsFrame.content.recipeDifficultyTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL))
        simModeDetailsFrame.content.recipeDifficultyTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.recipeDifficultyTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.recipeDifficultyMod = CreateFrame("EditBox", "CraftSimSimModeRecipeDifficultyModInput", simModeDetailsFrame.content, "UIPanelButtonTemplate")
        simModeDetailsFrame.content.recipeDifficultyMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RECIPE_DIFFICULTY
        simModeDetailsFrame.content.recipeDifficultyMod:SetPoint("TOPRIGHT", simModeDetailsFrame.content, "TOPRIGHT", modOffsetX - 30, offsetY - 20 + 3.5)
        simModeDetailsFrame.content.recipeDifficultyMod:SetSize(30, 20)
        simModeDetailsFrame.content.recipeDifficultyMod:SetAutoFocus(false) -- dont automatically focus
        simModeDetailsFrame.content.recipeDifficultyMod:SetFontObject("ChatFontNormal")
        simModeDetailsFrame.content.recipeDifficultyMod:SetText(0)
        simModeDetailsFrame.content.recipeDifficultyMod:SetScript("OnEscapePressed", function() simModeDetailsFrame.content.recipeDifficultyMod:ClearFocus() end)
        simModeDetailsFrame.content.recipeDifficultyMod:SetScript("OnEnterPressed", function() simModeDetailsFrame.content.recipeDifficultyMod:ClearFocus() end)
        simModeDetailsFrame.content.recipeDifficultyMod:SetScript("OnTextChanged", CraftSimSIMULATION_MODE.OnStatModifierChanged)

        simModeDetailsFrame.content.recipeDifficultyValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.recipeDifficultyValue:SetPoint("RIGHT", simModeDetailsFrame.content.recipeDifficultyMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.recipeDifficultyValue:SetText("0")

        -- Inspiration
        simModeDetailsFrame.content.inspirationTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.inspirationTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.recipeDifficultyTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.inspirationTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_LABEL))
        simModeDetailsFrame.content.inspirationTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.inspirationTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.inspirationMod = CreateFrame("EditBox", "CraftSimSimModeInspirationModInput", simModeDetailsFrame.content, "UIPanelButtonTemplate")
        simModeDetailsFrame.content.inspirationMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_INSPIRATION
        simModeDetailsFrame.content.inspirationMod:SetPoint("TOPRIGHT", simModeDetailsFrame.content.recipeDifficultyMod, "TOPRIGHT", 0, offsetY)
        simModeDetailsFrame.content.inspirationMod:SetSize(30, 20)
        simModeDetailsFrame.content.inspirationMod:SetAutoFocus(false) -- dont automatically focus
        simModeDetailsFrame.content.inspirationMod:SetFontObject("ChatFontNormal")
        simModeDetailsFrame.content.inspirationMod:SetText(0)
        simModeDetailsFrame.content.inspirationMod:SetScript("OnEscapePressed", function() simModeDetailsFrame.content.inspirationMod:ClearFocus() end)
        simModeDetailsFrame.content.inspirationMod:SetScript("OnEnterPressed", function() simModeDetailsFrame.content.inspirationMod:ClearFocus() end)
        simModeDetailsFrame.content.inspirationMod:SetScript("OnTextChanged", CraftSimSIMULATION_MODE.OnStatModifierChanged)

        simModeDetailsFrame.content.inspirationValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.inspirationValue:SetPoint("RIGHT", simModeDetailsFrame.content.inspirationMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.inspirationValue:SetText("0")

        -- Multicraft
        simModeDetailsFrame.content.multicraftTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.multicraftTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.inspirationTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.multicraftTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL))
        simModeDetailsFrame.content.multicraftTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.multicraftTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.multicraftMod = CreateFrame("EditBox", "CraftSimSimModeMulticraftModInput", simModeDetailsFrame.content, "UIPanelButtonTemplate")
        simModeDetailsFrame.content.multicraftMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_MULTICRAFT
        simModeDetailsFrame.content.multicraftMod:SetPoint("TOPRIGHT", simModeDetailsFrame.content.inspirationMod, "TOPRIGHT", 0, offsetY)
        simModeDetailsFrame.content.multicraftMod:SetSize(30, 20)
        simModeDetailsFrame.content.multicraftMod:SetAutoFocus(false) -- dont automatically focus
        simModeDetailsFrame.content.multicraftMod:SetFontObject("ChatFontNormal")
        simModeDetailsFrame.content.multicraftMod:SetText(0)
        simModeDetailsFrame.content.multicraftMod:SetScript("OnEscapePressed", function() simModeDetailsFrame.content.multicraftMod:ClearFocus() end)
        simModeDetailsFrame.content.multicraftMod:SetScript("OnEnterPressed", function() simModeDetailsFrame.content.multicraftMod:ClearFocus() end)
        simModeDetailsFrame.content.multicraftMod:SetScript("OnTextChanged", CraftSimSIMULATION_MODE.OnStatModifierChanged)

        simModeDetailsFrame.content.multicraftValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.multicraftValue:SetPoint("RIGHT", simModeDetailsFrame.content.multicraftMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.multicraftValue:SetText("0")

        -- Resourcefulness
        simModeDetailsFrame.content.resourcefulnessTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.multicraftTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.resourcefulnessTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL))
        simModeDetailsFrame.content.resourcefulnessTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.resourcefulnessTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.resourcefulnessMod = CreateFrame("EditBox", "CraftSimSimModeResourcefulnessModInput", simModeDetailsFrame.content, "UIPanelButtonTemplate")
        simModeDetailsFrame.content.resourcefulnessMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RESOURCEFULNESS
        simModeDetailsFrame.content.resourcefulnessMod:SetPoint("TOPRIGHT", simModeDetailsFrame.content.multicraftMod, "TOPRIGHT", 0, offsetY)
        simModeDetailsFrame.content.resourcefulnessMod:SetSize(30, 20)
        simModeDetailsFrame.content.resourcefulnessMod:SetAutoFocus(false) -- dont automatically focus
        simModeDetailsFrame.content.resourcefulnessMod:SetFontObject("ChatFontNormal")
        simModeDetailsFrame.content.resourcefulnessMod:SetText(0)
        simModeDetailsFrame.content.resourcefulnessMod:SetScript("OnEscapePressed", function() simModeDetailsFrame.content.resourcefulnessMod:ClearFocus() end)
        simModeDetailsFrame.content.resourcefulnessMod:SetScript("OnEnterPressed", function() simModeDetailsFrame.content.resourcefulnessMod:ClearFocus() end)
        simModeDetailsFrame.content.resourcefulnessMod:SetScript("OnTextChanged", CraftSimSIMULATION_MODE.OnStatModifierChanged)

        simModeDetailsFrame.content.resourcefulnessValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessValue:SetPoint("RIGHT", simModeDetailsFrame.content.resourcefulnessMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.resourcefulnessValue:SetText("0")

        -- skill

        simModeDetailsFrame.content.baseSkillTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.resourcefulnessTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.baseSkillTitle:SetText("Skill:")

        simModeDetailsFrame.content.baseSkillMod = CreateFrame("EditBox", "CraftSimSimModeSkillModInput", simModeDetailsFrame.content, "UIPanelButtonTemplate")
        simModeDetailsFrame.content.baseSkillMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_SKILL
        simModeDetailsFrame.content.baseSkillMod:SetPoint("TOPRIGHT", simModeDetailsFrame.content.resourcefulnessMod, "TOPRIGHT", 0 , offsetY)
        simModeDetailsFrame.content.baseSkillMod:SetSize(30, 20)
        simModeDetailsFrame.content.baseSkillMod:SetAutoFocus(false) -- dont automatically focus
        simModeDetailsFrame.content.baseSkillMod:SetFontObject("ChatFontNormal")
        simModeDetailsFrame.content.baseSkillMod:SetText(0)
        simModeDetailsFrame.content.baseSkillMod:SetScript("OnEscapePressed", function() simModeDetailsFrame.content.baseSkillMod:ClearFocus() end)
        simModeDetailsFrame.content.baseSkillMod:SetScript("OnEnterPressed", function() simModeDetailsFrame.content.baseSkillMod:ClearFocus() end)
        simModeDetailsFrame.content.baseSkillMod:SetScript("OnTextChanged", CraftSimSIMULATION_MODE.OnStatModifierChanged)

        simModeDetailsFrame.content.baseSkillValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillValue:SetPoint("RIGHT", simModeDetailsFrame.content.baseSkillMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.baseSkillValue:SetText("0")

        -- reagent skill

        simModeDetailsFrame.content.reagentSkillIncreaseTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.baseSkillTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetText("Material Quality Bonus:")
        simModeDetailsFrame.content.reagentSkillIncreaseTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.reagentSkillIncreaseTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.reagentSkillIncreaseValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetPoint("TOP", simModeDetailsFrame.content.baseSkillMod, "TOP", valueOffsetX - 5, offsetY - 5)
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetText("0")

        simModeDetailsFrame.content.qualityFrame = CreateFrame("frame", nil, simModeDetailsFrame.content)
        simModeDetailsFrame.content.qualityFrame:SetSize(230, 200)
        simModeDetailsFrame.content.qualityFrame:SetPoint("TOP", simModeDetailsFrame.content, "TOP", 0, offsetY*9)
        local qualityFrame = simModeDetailsFrame.content.qualityFrame
        qualityFrame.currentQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityTitle:SetPoint("TOPLEFT", qualityFrame, "TOPLEFT", 0, 0)
        qualityFrame.currentQualityTitle:SetText("Expected Quality:")

        qualityFrame.currentQualityIcon = CraftSim.FRAME:CreateQualityIcon(qualityFrame, 25, 25, qualityFrame, "TOPRIGHT", "TOPRIGHT", 0, 5)

        qualityFrame.currentQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityThreshold:SetPoint("RIGHT", qualityFrame.currentQualityIcon, "LEFT", -5, 0)
        qualityFrame.currentQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityTitle:SetPoint("TOPLEFT", qualityFrame.currentQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityTitle:SetText("Next Quality:")

        qualityFrame.nextQualityIcon = CraftSim.FRAME:CreateQualityIcon(qualityFrame, 25, 25, qualityFrame.currentQualityIcon, "TOP", "TOP", 0, offsetY)

        qualityFrame.nextQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityThreshold:SetPoint("RIGHT", qualityFrame.nextQualityIcon, "LEFT", -5, 0)
        qualityFrame.nextQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityMissingSkillTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillTitle:SetPoint("TOPLEFT", qualityFrame.nextQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillTitle:SetText("Missing Skill:")

        qualityFrame.nextQualityMissingSkillValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityThreshold, "TOPRIGHT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillValue:SetText("???")

        qualityFrame.nextQualityMissingSkillInspiration = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillInspiration:SetPoint("TOPLEFT", qualityFrame.nextQualityMissingSkillTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillInspiration:SetText("Missing Skill (Inspiration):")

        qualityFrame.nextQualityMissingSkillInspirationValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillInspirationValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityMissingSkillValue, "TOPRIGHT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillInspirationValue:SetText("???")

         -- warning
        -- simModeDetailsFrame.content.warningText = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        -- simModeDetailsFrame.content.warningText:SetPoint("BOTTOM", simModeDetailsFrame.content, "BOTTOM", 0, 30)
        -- simModeDetailsFrame.content.warningText:SetText(CraftSimUTIL:ColorizeText("~ WORK IN PROGRESS ~", CraftSim.CONST.COLORS.RED))


        CraftSimSIMULATION_MODE.craftingDetailsFrame = simModeDetailsFrame
end

function CraftSim.FRAME:CreateSimModeReagentOverwriteFrame(reagentOverwriteFrame, offsetX, offsetY, baseX, inputOffsetX)
    local overwriteInput = CreateFrame("frame", nil, reagentOverwriteFrame)
    overwriteInput:SetPoint("TOP", reagentOverwriteFrame, "TOP", offsetX, offsetY)
    overwriteInput:SetSize(50, 50)
    
    overwriteInput.icon = CraftSim.FRAME:CreateIcon(overwriteInput, 0, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40, "RIGHT", "LEFT")
    -- overwriteInput.reagentName = overwriteInput:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	-- overwriteInput.reagentName:SetPoint("BOTTOMLEFT", overwriteInput.icon, "BOTTOMRIGHT", 5, 5)
	-- overwriteInput.reagentName:SetText("Test")

    overwriteInput.inputq1 = CraftSim.FRAME:CreateSimModeOverWriteInput(overwriteInput, baseX, 1)
    overwriteInput.inputq2 = CraftSim.FRAME:CreateSimModeOverWriteInput(overwriteInput, baseX+inputOffsetX, 2)
    overwriteInput.inputq3 = CraftSim.FRAME:CreateSimModeOverWriteInput(overwriteInput, baseX+inputOffsetX*2, 3)

    overwriteInput.requiredQuantity = overwriteInput:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	overwriteInput.requiredQuantity:SetPoint("LEFT", overwriteInput.inputq3, "RIGHT", 5, 0)
	overwriteInput.requiredQuantity:SetText("/ 99")

    return overwriteInput
end

function CraftSim.FRAME:CreateSimModeOverWriteInput(overwriteInputFrame, offsetX, qualityID)
    local inputBox = CreateFrame("EditBox", nil, overwriteInputFrame, "UIPanelButtonTemplate")
    inputBox.qualityID = qualityID
    inputBox:SetPoint("LEFT", overwriteInputFrame.icon, "RIGHT", offsetX , 0)
    inputBox:SetSize(20, 20)
    inputBox:SetAutoFocus(false) -- dont automatically focus
    inputBox:SetFontObject("ChatFontNormal")
    inputBox:SetText(0)
    inputBox:SetScript("OnEscapePressed", function() inputBox:ClearFocus() end)
    inputBox:SetScript("OnEnterPressed", function() inputBox:ClearFocus() end)
    inputBox:SetScript("OnTextChanged", CraftSimSIMULATION_MODE.OnInputAllocationChanged)
    return inputBox
end

function CraftSim.FRAME:InitilizeSimModeReagentOverwrites()
    -- reagent overwrites
    for index, inputFrame in pairs(CraftSimSIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
        local reagentData = CraftSimSIMULATION_MODE.recipeData and CraftSimSIMULATION_MODE.recipeData.reagents[index] or nil

        CraftSim.FRAME:ToggleFrame(inputFrame, CraftSimSIMULATION_MODE.isActive and reagentData)

        if reagentData then
            --inputFrame.reagentName:SetText(reagentData.name)
            inputFrame.requiredQuantity:SetText("/ " .. reagentData.requiredQuantity)
            CraftSim.FRAME:ToggleFrame(inputFrame.inputq2, reagentData.differentQualities)
            CraftSim.FRAME:ToggleFrame(inputFrame.inputq3, reagentData.differentQualities)
            inputFrame.inputq1.reagentIndex = index
            inputFrame.inputq2.reagentIndex = index
            inputFrame.inputq3.reagentIndex = index

            inputFrame.isActive = true


            local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(reagentData.itemsInfo[1].itemID)
            inputFrame.icon:SetNormalTexture(itemData.itemTexture)
            inputFrame.icon:SetScript("OnEnter", function(self) 
                local itemName, ItemLink = GameTooltip:GetItem()
                GameTooltip:SetOwner(inputFrame, "ANCHOR_RIGHT");
                if ItemLink ~= itemData.link then
                    -- to not set it again and hide the tooltip..
                    GameTooltip:SetHyperlink(itemData.link)
                end
                GameTooltip:Show();
            end)
            inputFrame.icon:SetScript("OnLeave", function(self) 
                GameTooltip:Hide();
            end)
        else
            inputFrame.icon:SetScript("OnEnter", nil)
            inputFrame.icon:SetScript("OnLeave", nil)
            inputFrame.isActive = false
        end
    end
end

function CraftSim.FRAME:ToggleSimModeFrames()
    -- frame visiblities
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Reagents, not CraftSimSIMULATION_MODE.isActive)

    -- only if recipe has optionalReagents
    local hasOptionalReagents = ProfessionsFrame.CraftingPage.SchematicForm.reagentSlots[0] ~= nil
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, not CraftSimSIMULATION_MODE.isActive and hasOptionalReagents)

    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.reagentOverwriteFrame, CraftSimSIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Details, not CraftSimSIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame, CraftSimSIMULATION_MODE.isActive)

    local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
    CraftSim.FRAME:ToggleFrame(bestQBox, not CraftSimSIMULATION_MODE.isActive)
    
    -- also toggle the blizzard create all buttons and so on so that a user does not get the idea to press create when in sim mode..
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateAllButton, not CraftSimSIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateMultipleInputBox, not CraftSimSIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateButton, not CraftSimSIMULATION_MODE.isActive)
end

function CraftSim.FRAME:UpdateSimModeStatDisplay()
    -- stat details
    local reagentSkillIncrease = CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSimSIMULATION_MODE.recipeData)
    local recipeDifficultyMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeRecipeDifficultyModInput)  
    local skillMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeSkillModInput)  
    local fullRecipeDifficulty = CraftSimSIMULATION_MODE.baseRecipeDifficulty + recipeDifficultyMod 
    CraftSimSIMULATION_MODE.craftingDetailsFrame.content.recipeDifficultyValue:SetText(fullRecipeDifficulty .. " (" .. CraftSimSIMULATION_MODE.baseRecipeDifficulty .. "+" .. recipeDifficultyMod  .. ")")
    CraftSimSIMULATION_MODE.craftingDetailsFrame.content.baseSkillValue:SetText(CraftSimSIMULATION_MODE.recipeData.stats.skill .. " (" .. CraftSimSIMULATION_MODE.baseSkill .. "+" .. reagentSkillIncrease .. "+" .. skillMod ..")")
    -- I assume its always from base..? Wouldnt make sense to give the materials more skill contribution if you artificially make the recipe harder
    local maxReagentSkillIncrease = CraftSimUTIL:round(0.25 * CraftSimSIMULATION_MODE.baseRecipeDifficulty)
    CraftSimSIMULATION_MODE.craftingDetailsFrame.content.reagentSkillIncreaseValue:SetText(CraftSimSIMULATION_MODE.reagentSkillIncrease .. " / " .. maxReagentSkillIncrease)

    -- Inspiration Display
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.inspirationTitle, CraftSimSIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.inspirationTitle.helper, CraftSimSIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.inspirationValue, CraftSimSIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.inspirationMod, CraftSimSIMULATION_MODE.recipeData.stats.inspiration)
    if CraftSimSIMULATION_MODE.recipeData.stats.inspiration then
        local inspirationDiff = CraftSimSIMULATION_MODE.recipeData.stats.inspiration.value - CraftSimSIMULATION_MODE.baseInspiration.value
        local percentText = CraftSimUTIL:round(CraftSimSIMULATION_MODE.recipeData.stats.inspiration.percent, 0) .. "%"
        CraftSimSIMULATION_MODE.craftingDetailsFrame.content.inspirationValue:SetText(CraftSimSIMULATION_MODE.recipeData.stats.inspiration.value .. " (" .. CraftSimSIMULATION_MODE.baseInspiration.value .."+"..inspirationDiff .. ") " .. percentText)
    end

    -- Multicraft Display
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.multicraftTitle, CraftSimSIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.multicraftTitle.helper, CraftSimSIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.multicraftValue, CraftSimSIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.multicraftMod, CraftSimSIMULATION_MODE.recipeData.stats.multicraft)
    if CraftSimSIMULATION_MODE.recipeData.stats.multicraft then
        local multicraftDiff = CraftSimSIMULATION_MODE.recipeData.stats.multicraft.value - CraftSimSIMULATION_MODE.baseMulticraft.value
        local percentText = CraftSimUTIL:round(CraftSimSIMULATION_MODE.recipeData.stats.multicraft.percent, 0) .. "%"
        CraftSimSIMULATION_MODE.craftingDetailsFrame.content.multicraftValue:SetText(CraftSimSIMULATION_MODE.recipeData.stats.multicraft.value .. " (" .. CraftSimSIMULATION_MODE.baseMulticraft.value .."+"..multicraftDiff .. ") " .. percentText)
    end

    -- Resourcefulness Display
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessTitle, CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessTitle.helper, CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessValue, CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSimSIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessMod, CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness)
    if CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness then
        local resourcefulnessDiff = CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.value - CraftSimSIMULATION_MODE.baseResourcefulness.value
        local percentText = CraftSimUTIL:round(CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.percent, 0) .. "%"
        CraftSimSIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessValue:SetText(CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.value .. " (" .. CraftSimSIMULATION_MODE.baseResourcefulness.value .."+"..resourcefulnessDiff .. ") " .. percentText)
    end

    local qualityFrame = CraftSimSIMULATION_MODE.craftingDetailsFrame.content.qualityFrame
    CraftSim.FRAME:ToggleFrame(qualityFrame, not CraftSimSIMULATION_MODE.recipeData.result.isNoQuality)
    if not CraftSimSIMULATION_MODE.recipeData.result.isNoQuality then
        --print("getting thresholds with difficulty: " .. CraftSimSIMULATION_MODE.recipeData.recipeDifficulty)
        local thresholds = CraftSimSTATS:GetQualityThresholds(CraftSimSIMULATION_MODE.recipeData.maxQuality, CraftSimSIMULATION_MODE.recipeData.recipeDifficulty, CraftSimOptions.breakPointOffset)
        qualityFrame.currentQualityIcon.SetQuality(CraftSimSIMULATION_MODE.recipeData.expectedQuality)
        qualityFrame.currentQualityThreshold:SetText("> " .. (thresholds[CraftSimSIMULATION_MODE.recipeData.expectedQuality - 1] or 0))
        
        local hasNextQuality = CraftSimSIMULATION_MODE.recipeData.expectedQuality < CraftSimSIMULATION_MODE.recipeData.maxQuality
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityIcon, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityThreshold, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityTitle, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillTitle, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillInspiration, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillValue, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillInspirationValue, hasNextQuality)
        if hasNextQuality then
            local nextQualityThreshold = thresholds[CraftSimSIMULATION_MODE.recipeData.expectedQuality]
            local missingSkill = nextQualityThreshold - CraftSimSIMULATION_MODE.recipeData.stats.skill
            local missingSkillInspiration = nextQualityThreshold - (CraftSimSIMULATION_MODE.recipeData.stats.skill + CraftSimSIMULATION_MODE.recipeData.stats.inspiration.bonusskill)
            missingSkill = missingSkill > 0 and missingSkill or 0
            missingSkillInspiration = missingSkillInspiration > 0 and missingSkillInspiration or 0
            qualityFrame.nextQualityMissingSkillValue:SetText(missingSkill)
            local missinSkillText = CraftSimUTIL:ColorizeText(missingSkillInspiration, 
            missingSkillInspiration == 0 and CraftSim.CONST.COLORS.GREEN or CraftSim.CONST.COLORS.RED)
            qualityFrame.nextQualityMissingSkillInspirationValue:SetText(missinSkillText)
            qualityFrame.nextQualityIcon.SetQuality(CraftSimSIMULATION_MODE.recipeData.expectedQuality + 1)
            qualityFrame.nextQualityThreshold:SetText("> " .. thresholds[CraftSimSIMULATION_MODE.recipeData.expectedQuality])
        end
    end
end