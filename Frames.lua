CraftSimFRAME = {}

CraftSimFRAME.frames = {}

function CraftSimFRAME:GetFrame(frameID)
    local frameName = CraftSimFRAME.frames[frameID]
    if not frameName then
        error("CraftSim Error: Frame not found: " .. tostring(frameID))
    end
    return _G[frameName]
end

function CraftSimFRAME:InitStatWeightFrame()
    local frame = CraftSimFRAME:CreateCraftSimFrame(
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
        CraftSimCONST.FRAMES.STAT_WEIGHTS)

    frame.content.breakdownButton = CreateFrame("Button", "CraftSimMaterialAllocateButton", frame.content, "UIPanelButtonTemplate")
    frame.content.breakdownButton:SetPoint("TOP", frame.title, "TOP", 0, -15)	
    frame.content.breakdownButton:SetText("Show Details")
    frame.content.breakdownButton:SetSize(frame.content.breakdownButton:GetTextWidth() + 15, 20)
    frame.content.breakdownButton:SetScript("OnClick", function(self) 
        local profitDetailsFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.PROFIT_DETAILS)
        local isVisible = profitDetailsFrame:IsVisible()
        CraftSimFRAME:ToggleFrame(profitDetailsFrame, not isVisible)
        frame.content.breakdownButton:SetText(isVisible and "Show Details" or not isVisible and "Hide Details")
    end)

	frame.content.statText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.statText:SetPoint("LEFT", frame.content, "LEFT", 15, -20)

	frame.content.valueText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.valueText:SetPoint("RIGHT", frame.content, "RIGHT", -15, -20)
	frame:Hide()
end

function CraftSimFRAME:UpdateStatWeightFrameText(priceData, statWeights)
    local statweightFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.STAT_WEIGHTS)
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

function CraftSimFRAME:CreateIcon(parent, offsetX, offsetY, texture, sizeX, sizeY, anchorA, anchorB)
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

function CraftSimFRAME:InitPriceDataWarningFrame()	
    
	-- TODO: price data warning frame.. utilize something similar to the ketho editbox...
    
end

function CraftSimFRAME:InitBestAllocationsFrame()
    local frame = CraftSimFRAME:CreateCraftSimFrame(
        "CraftSimReagentHintFrame", 
        "CraftSim Min Cost Material", 
        ProfessionsFrame.CraftingPage.SchematicForm.Reagents, 
        CraftSimCostOverviewFrame, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -10, 
        0, 
        270, 
        250,
        CraftSimCONST.FRAMES.MATERIALS)

    local contentOffsetY = -15

    frame.content.inspirationCheck = CreateFrame("CheckButton", nil, frame.content, "ChatConfigCheckButtonTemplate")
	frame.content.inspirationCheck:SetPoint("TOP", frame.title, -90, -20)
	frame.content.inspirationCheck.Text:SetText(" Reach Inspiration Breakpoint")
    frame.content.inspirationCheck.tooltip = "Try to reach the skill breakpoint where an inspiration proc upgrades to the next higher quality with the cheapest material combination"
    frame.content.inspirationCheck:SetChecked(CraftSimOptions.materialSuggestionInspirationThreshold)
	frame.content.inspirationCheck:HookScript("OnClick", function(_, btn, down)
		local checked = frame.content.inspirationCheck:GetChecked()
		CraftSimOptions.materialSuggestionInspirationThreshold = checked
        CraftSimMAIN:TriggerModulesByRecipeType() -- TODO: if this is not performant enough, try to only recalc the material stuff not all, lazy solution for now
	end)

    frame.content.qualityText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.qualityText:SetPoint("TOP", frame.title, "TOP", 0, -45)
	frame.content.qualityText:SetText("Reachable Quality: ")

    frame.content.qualityIcon = CraftSimFRAME:CreateQualityIcon(frame.content, 25, 25, frame.content.qualityText, "LEFT", "RIGHT", 3, 0)

    frame.content.allocateButton = CreateFrame("Button", "CraftSimMaterialAllocateButton", frame.content, "UIPanelButtonTemplate")
	frame.content.allocateButton:SetSize(50, 25)
	frame.content.allocateButton:SetPoint("TOP", frame.content.qualityText, "TOP", 0, -20)	
	frame.content.allocateButton:SetText("Assign")

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
    table.insert(frame.content.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*2, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*3, iconSize))
    table.insert(frame.content.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*4, iconSize))

    frame:Hide()
end

function CraftSimFRAME:CreateReagentFrame(parent, hookFrame, y, iconSize)
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
    
    reagentFrame.q1qualityIcon = CraftSimFRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q1Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 1)
    reagentFrame.q2qualityIcon = CraftSimFRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q2Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 2)
    reagentFrame.q3qualityIcon = CraftSimFRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q3Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 3)

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
function CraftSimFRAME:ShowBestReagentAllocation(recipeData, recipeType, priceData, bestAllocation, hasItems, isSameAllocation)
    local materialFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.MATERIALS)
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
        materialFrame.content.infoText:Hide()
        materialFrame.content.qualityIcon:Show()
        materialFrame.content.qualityText:Show()
        materialFrame.content.allocateButton:Show()
        materialFrame.content.allocateButton:SetEnabled(hasItems)
        if hasItems then
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
            materialFrame.content.allocateButton:SetText("Missing materials")
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

function CraftSimFRAME:InitCostOverviewFrame()
    local frame = CraftSimFRAME:CreateCraftSimFrame(
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
        CraftSimCONST.FRAMES.COST_OVERVIEW)

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
        profitFrame.icon = CraftSimFRAME:CreateQualityIcon(profitFrame, 20, 20, profitFrame, "CENTER", "CENTER", -75, 0)

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

function CraftSimFRAME:FillCostOverview(craftingCosts, minCraftingCosts, profitPerQuality, currentQuality)
    local costOverviewFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.COST_OVERVIEW)
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

    CraftSimFRAME:ToggleFrame(costOverviewFrame.content.resultProfitsTitle, #profitPerQuality > 0)

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

function CraftSimFRAME:UpdateProfitDetails(recipeData, calculationData)
    print("calcData:")
    CraftSimUTIL:PrintTable(calculationData, true)
    local profitDetailsFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.PROFIT_DETAILS)

    profitDetailsFrame.content.averageProfitValue:SetText(CraftSimUTIL:FormatMoney(calculationData.meanProfit, true))

    local isMaxQuality = recipeData.expectedQuality == recipeData.maxQuality

    CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.resourcefulnessInfo, calculationData.resourcefulness)
    if calculationData.resourcefulness then
        profitDetailsFrame.content.resourcefulnessInfo.averageSavedCostsValue:SetText(CraftSimUTIL:FormatMoney(calculationData.resourcefulness.averageSavedCosts))
    end

    CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo, calculationData.multicraft)
    if calculationData.multicraft then
        profitDetailsFrame.content.multicraftInfo.currentQualityIcon.SetQuality(recipeData.expectedQuality)
        profitDetailsFrame.content.multicraftInfo.currentQualityIcon2.SetQuality(recipeData.expectedQuality)
        
        profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetText(calculationData.multicraft.averageMulticraftItemsCurrent)
        profitDetailsFrame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetText(CraftSimUTIL:FormatMoney(calculationData.multicraft.averageMulticraftCurrentValue))
        
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.higherQualityIcon, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.higherQualityIcon2, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalHigherQualityValue, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, not isMaxQuality)
        if not isMaxQuality then
            profitDetailsFrame.content.multicraftInfo.higherQualityIcon.SetQuality(recipeData.expectedQuality + 1)
            profitDetailsFrame.content.multicraftInfo.higherQualityIcon2.SetQuality(recipeData.expectedQuality + 1)
            profitDetailsFrame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetText(calculationData.multicraft.averageMulticraftItemsHigher)
            profitDetailsFrame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetText(CraftSimUTIL:FormatMoney(calculationData.multicraft.averageMulticraftHigherValue))
        end
    end
    
    CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo, calculationData.inspiration)
    if calculationData.inspiration then
        profitDetailsFrame.content.inspirationInfo.currentQualityIcon.SetQuality(recipeData.expectedQuality)
        profitDetailsFrame.content.inspirationInfo.currentQualityIcon2.SetQuality(recipeData.expectedQuality)
    
        profitDetailsFrame.content.inspirationInfo.averageCurrentQualityItemsValue:SetText(calculationData.inspiration.averageInspirationItemsCurrent)
        profitDetailsFrame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(calculationData.inspiration.inspirationItemsValueCurrent))

        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.higherQualityIcon, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.higherQualityIcon2, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsValue, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsValue, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsTitle, not isMaxQuality)
        CraftSimFRAME:ToggleFrame(profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsTitle, not isMaxQuality)
        if not isMaxQuality then
            profitDetailsFrame.content.inspirationInfo.higherQualityIcon.SetQuality(recipeData.expectedQuality + 1)
            profitDetailsFrame.content.inspirationInfo.higherQualityIcon2.SetQuality(recipeData.expectedQuality + 1)
            
            profitDetailsFrame.content.inspirationInfo.averageHigherQualityItemsValue:SetText(calculationData.inspiration.averageInspirationItemsHigher)
            profitDetailsFrame.content.inspirationInfo.valueByHigherQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(calculationData.inspiration.inspirationItemsValueHigher))
        end
    end
end

function CraftSimFRAME:InitProfitDetailsFrame()
    local frame = CraftSimFRAME:CreateCraftSimFrame(
        "CraftSimProfitDetailsFrame", 
        "CraftSim Profit Breakdown", 
        CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.STAT_WEIGHTS),
        UIParent, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        400, 
        700,
        CraftSimCONST.FRAMES.PROFIT_DETAILS)

    frame:SetFrameStrata("HIGH")
    frame:Hide()

    frame.content.averageProfitTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.averageProfitTitle:SetPoint("TOP", frame.title, "TOP", 0, -40)
	frame.content.averageProfitTitle:SetText("Ø Profit")

    frame.content.averageProfitValue = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.averageProfitValue:SetPoint("TOP", frame.content.averageProfitTitle, "TOP", 0, -20)
	frame.content.averageProfitValue:SetText(CraftSimUTIL:FormatMoney(123456789))

    frame.content.resourcefulnessInfo = CreateFrame("frame", nil, frame.content)
    frame.content.resourcefulnessInfo:SetPoint("TOP", frame.content.averageProfitValue, "TOP", 0, -30)
    frame.content.resourcefulnessInfo:SetSize(300, 100)
    frame.content.resourcefulnessInfo.resourcefulnessTitle = frame.content.resourcefulnessInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.resourcefulnessInfo.resourcefulnessTitle:SetPoint("TOP", frame.content.resourcefulnessInfo, "TOP", 0, -10)
	frame.content.resourcefulnessInfo.resourcefulnessTitle:SetText("Resourcefulness")

    frame.content.resourcefulnessInfo.averageSavedCostsTitle = frame.content.resourcefulnessInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.resourcefulnessInfo.averageSavedCostsTitle:SetPoint("TOP", frame.content.resourcefulnessInfo.resourcefulnessTitle, "TOP", 0, -20)
	frame.content.resourcefulnessInfo.averageSavedCostsTitle:SetText("Ø Material Costs Saved:")

    frame.content.resourcefulnessInfo.averageSavedCostsValue = frame.content.resourcefulnessInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.resourcefulnessInfo.averageSavedCostsValue:SetPoint("TOP", frame.content.resourcefulnessInfo.averageSavedCostsTitle, "TOP", 0, -20)
	frame.content.resourcefulnessInfo.averageSavedCostsValue:SetText(CraftSimUTIL:FormatMoney(1234789))


    frame.content.multicraftInfo = CreateFrame("frame", nil, frame.content)
    frame.content.multicraftInfo:SetPoint("TOP", frame.content.resourcefulnessInfo.averageSavedCostsValue, "TOP", 0, -30)
    frame.content.multicraftInfo:SetSize(300, 100)
    frame.content.multicraftInfo.multicraftTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.multicraftTitle:SetPoint("TOP", frame.content.multicraftInfo, "TOP", 0, -20)
	frame.content.multicraftInfo.multicraftTitle:SetText("Multicraft")

    frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.multicraftTitle, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle:SetText("Ø Additional Items")
    frame.content.multicraftInfo.currentQualityIcon = CraftSimFRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle, "LEFT", "RIGHT", 0, 0)
    
    frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityTitle, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue:SetText("3.5 PH")
    
    frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsCurrentQualityValue, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle:SetText("Ø Additional Value")
    frame.content.multicraftInfo.higherQualityIcon = CraftSimFRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle, "LEFT", "RIGHT", 0, 0)

    frame.content.multicraftInfo.averageAdditionalCurrentQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalValueCurrentQualityTitle, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalCurrentQualityValue:SetText(CraftSimUTIL:FormatMoney(123456789))

    frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalCurrentQualityValue, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle:SetText("Ø Additional Items")
    frame.content.multicraftInfo.currentQualityIcon2 = CraftSimFRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, "LEFT", "RIGHT", 0, 0)
    
    frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsHigherQualityTitle, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue:SetText("3.5 PH")
    
    frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalItemsHigherQualityValue, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle:SetText("Ø Additional Value")
    frame.content.multicraftInfo.higherQualityIcon2 = CraftSimFRAME:CreateQualityIcon(frame.content.multicraftInfo, 20, 20, frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, "LEFT", "RIGHT", 0, 0)

    frame.content.multicraftInfo.averageAdditionalHigherQualityValue = frame.content.multicraftInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalValueHigherQualityTitle, "TOP", 0, -20)
	frame.content.multicraftInfo.averageAdditionalHigherQualityValue:SetText(CraftSimUTIL:FormatMoney(123456789))

    frame.content.inspirationInfo = CreateFrame("frame", nil, frame.content)
    frame.content.inspirationInfo:SetPoint("TOP", frame.content.multicraftInfo.averageAdditionalHigherQualityValue, "TOP", 0, -30)
    frame.content.inspirationInfo:SetSize(300, 100)
    frame.content.inspirationInfo.inspirationTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.inspirationTitle:SetPoint("TOP", frame.content.inspirationInfo, "TOP", 0, -20)
	frame.content.inspirationInfo.inspirationTitle:SetText("Inspiration")

    frame.content.inspirationInfo.averageCurrentQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.averageCurrentQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.inspirationTitle, "TOP", 0, -20)
	frame.content.inspirationInfo.averageCurrentQualityItemsTitle:SetText("Ø Items")
    frame.content.inspirationInfo.currentQualityIcon = CraftSimFRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.averageCurrentQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
    
    frame.content.inspirationInfo.averageCurrentQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.averageCurrentQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.averageCurrentQualityItemsTitle, "TOP", 0, -20)
	frame.content.inspirationInfo.averageCurrentQualityItemsValue:SetText("0.6 PH")
    
    frame.content.inspirationInfo.averageHigherQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.averageHigherQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.averageCurrentQualityItemsValue, "TOP", 0, -20)
	frame.content.inspirationInfo.averageHigherQualityItemsTitle:SetText("Ø Items")
    frame.content.inspirationInfo.higherQualityIcon = CraftSimFRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.averageHigherQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
    
    frame.content.inspirationInfo.averageHigherQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.averageHigherQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.averageHigherQualityItemsTitle, "TOP", 0, -20)
	frame.content.inspirationInfo.averageHigherQualityItemsValue:SetText("0.4 PH")
    
    frame.content.inspirationInfo.valueByCurrentQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.valueByCurrentQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.averageHigherQualityItemsValue, "TOP", 0, -20)
	frame.content.inspirationInfo.valueByCurrentQualityItemsTitle:SetText("Ø Value")
    frame.content.inspirationInfo.currentQualityIcon2 = CraftSimFRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.valueByCurrentQualityItemsTitle, "LEFT", "RIGHT", 0, 0)
    
    frame.content.inspirationInfo.valueByCurrentQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.valueByCurrentQualityItemsTitle, "TOP", 0, -20)
	frame.content.inspirationInfo.valueByCurrentQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(123456789))
    
    frame.content.inspirationInfo.valueByHigherQualityItemsTitle = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.valueByHigherQualityItemsTitle:SetPoint("TOP", frame.content.inspirationInfo.valueByCurrentQualityItemsValue, "TOP", 0, -20)
	frame.content.inspirationInfo.valueByHigherQualityItemsTitle:SetText("Ø Value")
    frame.content.inspirationInfo.higherQualityIcon2 = CraftSimFRAME:CreateQualityIcon(frame.content.inspirationInfo, 20, 20, frame.content.inspirationInfo.valueByHigherQualityItemsTitle, "LEFT", "RIGHT", 0, 0)

    frame.content.inspirationInfo.valueByHigherQualityItemsValue = frame.content.inspirationInfo:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.inspirationInfo.valueByHigherQualityItemsValue:SetPoint("TOP", frame.content.inspirationInfo.valueByHigherQualityItemsTitle, "TOP", 0, -20)
	frame.content.inspirationInfo.valueByHigherQualityItemsValue:SetText(CraftSimUTIL:FormatMoney(123456789))

    frame.content.hideButton = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.hideButton:SetPoint("BOTTOM", frame.content, "BOTTOM", 0, 20)	
	frame.content.hideButton:SetText("Close")
	frame.content.hideButton:SetSize(frame.content.hideButton:GetTextWidth()+15, 25)
    frame.content.hideButton:SetScript("OnClick", function(self) 
        CraftSimFRAME:ToggleFrame(CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.PROFIT_DETAILS), false)
        CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.STAT_WEIGHTS).content.breakdownButton:SetText("Show Details")
    end)
end

function CraftSimFRAME:InitGearSimFrame()
    local frame = CraftSimFRAME:CreateCraftSimFrame(
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
        CraftSimCONST.FRAMES.TOP_GEAR)

    local contentOffsetY = -20
    local iconsOffsetY = 80
    frame.content.gear1Icon = CraftSimFRAME:CreateIcon(frame.content, -45, contentOffsetY + iconsOffsetY, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.content.gear2Icon = CraftSimFRAME:CreateIcon(frame.content,  -0, contentOffsetY + iconsOffsetY, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.content.toolIcon = CraftSimFRAME:CreateIcon(frame.content, 50, contentOffsetY + iconsOffsetY, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)

    frame.content.equipButton = CreateFrame("Button", "CraftSimTopGearEquipButton", frame.content, "UIPanelButtonTemplate")
	frame.content.equipButton:SetSize(50, 25)
	frame.content.equipButton:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY + 40)	
	frame.content.equipButton:SetText("Equip")
    frame.content.equipButton:SetScript("OnClick", function(self) 
        CraftSimGEARSIM:EquipTopGear()
    end)

    frame.content.simModeDropdown = 
    CraftSimFRAME:initDropdownMenu("CraftSimTopGearSimMode", frame.content, frame.title, "", 0, contentOffsetY, 120, {"Placeholder"}, function(arg1) 
        CraftSimOptions.topGearMode = arg1
        CraftSimGEARSIM:SimulateBestProfessionGearCombination(CraftSimTopGearSimMode.recipeData, CraftSimTopGearSimMode.recipeType, CraftSimTopGearSimMode.priceData)
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

    frame.content.statDiff.qualityIcon = CraftSimFRAME:CreateQualityIcon(frame.content, 20, 20, frame.content.statDiff.quality, "LEFT", "RIGHT", 3, 0)

	frame:Hide()
end

function CraftSimFRAME:ShowComboItemIcons(professionGearCombo, isCooking)
    local topGearFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.TOP_GEAR)
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
            iconButton:SetNormalTexture(CraftSimCONST.EMPTY_SLOT_TEXTURE)
            iconButton:SetScript("OnEnter", nil)
            iconButton:SetScript("OnLeave", nil)
        end
    end
end

function CraftSimFRAME:GetProfessionEquipSlots()
    if ProfessionsFrame.CraftingPage.Prof0Gear0Slot:IsVisible() then
        return CraftSimCONST.PROFESSION_INV_SLOTS[1]
    elseif ProfessionsFrame.CraftingPage.Prof1Gear0Slot:IsVisible() then
        return CraftSimCONST.PROFESSION_INV_SLOTS[2]
    elseif ProfessionsFrame.CraftingPage.CookingGear0Slot:IsVisible() then
        return CraftSimCONST.PROFESSION_INV_SLOTS[3]
    else
        --print("no profession tool slot visible.. what is going on?")
        return {}
    end
end

function CraftSimFRAME:FormatStatDiffpercentText(statDiff, roundTo, suffix)
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

function CraftSimFRAME:FillSimResultData(bestSimulation, topGearMode, isCooking)
    local topGearFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.TOP_GEAR)
    CraftSimFRAME:ShowComboItemIcons(bestSimulation.combo, isCooking)
    if not CraftSimGEARSIM.IsEquipping then
        topGearFrame.currentCombo = bestSimulation.combo
    end
    -- TODO: maybe show in red or smth if negative
    if topGearMode == CraftSimCONST.GEAR_SIM_MODES.PROFIT then
        topGearFrame.content.profitText:SetText("Ø Profit Difference\n".. CraftSimUTIL:FormatMoney(bestSimulation.profitDiff, true))
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.MULTICRAFT then
        topGearFrame.content.profitText:SetText("New Multicraft\n".. CraftSimUTIL:round(bestSimulation.multicraftPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        topGearFrame.content.profitText:SetText("New Crafting Speed\n".. CraftSimUTIL:round(bestSimulation.craftingspeedPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        topGearFrame.content.profitText:SetText("New Resourcefulness\n".. CraftSimUTIL:round(bestSimulation.resourcefulnessPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.INSPIRATION then
        topGearFrame.content.profitText:SetText("New Inspiration\n".. CraftSimUTIL:round(bestSimulation.inspirationPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.SKILL then
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

    topGearFrame.content.statDiff.inspiration:SetText("Inspiration: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.inspiration, 2, "%") .. inspirationBonusSkillText)
    topGearFrame.content.statDiff.multicraft:SetText("Multicraft: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.multicraft, 2, "%"))
    topGearFrame.content.statDiff.resourcefulness:SetText("Resourcefulness: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.resourcefulness, 2, "%"))
    topGearFrame.content.statDiff.craftingspeed:SetText("Crafting Speed: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.craftingspeed, 2, "%"))
    topGearFrame.content.statDiff.skill:SetText("Skill: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.skill, 0))

    if CraftSimTopGearSimMode.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE and CraftSimTopGearSimMode.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
        topGearFrame.content.statDiff.qualityIcon.SetQuality(bestSimulation.modifiedRecipeData.expectedQuality)
        topGearFrame.content.statDiff.quality:Show()
        topGearFrame.content.statDiff.qualityIcon:Show()
    else
        topGearFrame.content.statDiff.quality:Hide()
        topGearFrame.content.statDiff.qualityIcon:Hide()
    end

end

function CraftSimFRAME:ClearResultData(isCooking)
    local topGearFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.TOP_GEAR)
    if not isCooking then
        CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    else
        CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
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

function CraftSimFRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

function CraftSimFRAME:initDropdownMenu(frameName, parent, anchorFrame, label, offsetX, offsetY, width, list, clickCallback, defaultValue)
	local dropDown = CreateFrame("Frame", frameName, parent, "UIDropDownMenuTemplate")
    dropDown.clickCallback = clickCallback
	dropDown:SetPoint("TOP", anchorFrame, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, width)
	
	CraftSimFRAME:initializeDropdown(dropDown, list, defaultValue)

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)
	dd_title:SetText(label)
    return dropDown
end

function CraftSimFRAME:initializeDropdown(dropDown, list, defaultValue)
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

function CraftSimFRAME:CreateQualityIcon(frame, x, y, anchorFrame, anchorSelf, anchorParent, offsetX, offsetY, initialQuality)
    initialQuality = initialQuality or 1
    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(x, y)
    icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    icon:SetAtlas("Professions-Icon-Quality-Tier" .. initialQuality)
    icon:SetPoint(anchorSelf, anchorFrame, anchorParent, offsetX, offsetY)

    icon.SetQuality = function(qualityID) 
        icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
        icon:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
    end

    return icon
end

function CraftSimFRAME:InitTabSystem(tabs)
    if #tabs == 0 then
        return
    end
    -- show first tab
    for _, tab in pairs(tabs) do
        tab:SetScript("OnClick", function(self) 
            for _, otherTab in pairs(tabs) do
                otherTab.content:Hide()
                otherTab:SetEnabled(tab.canBeEnabled)
            end
            tab.content:Show()
            tab:SetEnabled(false)
        end)
        tab.content:Hide()
    end
    tabs[1].content:Show()
    tabs[1]:SetEnabled(false)
end

function CraftSimFRAME:makeFrameMoveable(frame)
	frame.hookFrame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, button)
		frame.hookFrame:StartMoving()
		end)
		frame:SetScript("OnMouseUp", function(self, button)
		frame.hookFrame:StopMovingOrSizing()
		end)
end

function CraftSimFRAME:ResetFrames()
    local materialFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.MATERIALS)
    local costOverviewFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.COST_OVERVIEW)
    local topGearFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.TOP_GEAR)
    local statweightFrame = CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.STAT_WEIGHTS)
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
function CraftSimFRAME:HandleAuctionatorOverlaps()
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

function CraftSimFRAME:MakeCollapsable(frame, originalX, originalY, frameID)
    frame.collapsed = false
    frame.collapseButton = CreateFrame("Button", "CraftSimMaterialAllocateButton", frame, "UIPanelButtonTemplate")
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

function CraftSimFRAME:CreateCraftSimFrame(name, title, parent, anchorFrame, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, frameID)
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

    CraftSimFRAME:MakeCollapsable(frame, sizeX, sizeY, frameID)
    CraftSimFRAME:makeFrameMoveable(frame)
	
    frame.content = CreateFrame("frame", nil, frame)
    frame.content:SetPoint("TOP", frame, "TOP")
    frame.content:SetSize(sizeX, sizeY)


    CraftSimFRAME.frames[frameID] = name
    return frame
end

function CraftSimFRAME:UpdateStatDetailsByExtraItemFactors(recipeData)
    local lines = ProfessionsFrame.CraftingPage.SchematicForm.Details.statLinePool
	local activeObjects = lines.activeObjects
    -- TODO: update tooltips of statlines to explain the extra item stuff to save space
	for statLine, _ in pairs(activeObjects) do 
		if string.find(statLine.LeftLabel:GetText(), "Multicraft") and recipeData.extraItemFactors.multicraftExtraItemsFactor > 1 then
			local baseText = "Multicraft "
			local formatted = CraftSimUTIL:FormatFactorToPercent(recipeData.extraItemFactors.multicraftExtraItemsFactor)
			local text = baseText .. CraftSimUTIL:ColorizeText("" .. formatted .. " Items", CraftSimCONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
		if string.find(statLine.LeftLabel:GetText(), "Resourcefulness") and recipeData.extraItemFactors.resourcefulnessExtraItemsFactor > 1 then
			local baseText = "Resourcefulness " 
			local formatted = CraftSimUTIL:FormatFactorToPercent(recipeData.extraItemFactors.resourcefulnessExtraItemsFactor)
			local text = baseText .. CraftSimUTIL:ColorizeText("" .. formatted .. " Items", CraftSimCONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
	end
end

function CraftSimFRAME:CreateCheckbox(label, description, optionName, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
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

function CraftSimFRAME:CreateSlider(name, label, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, orientation, min, max, initialValue, lowText, highText, updateCallback)
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