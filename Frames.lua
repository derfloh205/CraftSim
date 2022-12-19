CraftSimFRAME = {}

function CraftSimFRAME:InitStatWeightFrame()
    local frame = CraftSimFRAME:CreateCraftSimFrame(
        "CraftSimDetailsFrame", 
        "CraftSim Statweights", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm.Details, 
        "TOP", 
        "BOTTOM", 
        0, 
        0, 
        270, 
        100, 
        CraftSimCONST.FRAMES.STAT_WEIGHTS)

	frame.content.statText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.statText:SetPoint("LEFT", frame.content, "LEFT", 15, -5)

	frame.content.valueText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.content.valueText:SetPoint("RIGHT", frame.content, "RIGHT", -10, -5)
	frame:Hide()
end

function CraftSimFRAME:UpdateStatWeightFrameText(priceData, statWeights)
    if statWeights == nil then
        CraftSimDetailsFrame.content.statText:SetText("")
        CraftSimDetailsFrame.content.valueText:SetText("")
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
        CraftSimDetailsFrame.content.statText:SetText(statText)
        CraftSimDetailsFrame.content.valueText:SetText(valueText)
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
        ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, 
        "TOP", 
        "TOP", 
        0, 
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
    if bestAllocation == nil or isSameAllocation then
        CraftSimReagentHintFrame.content.infoText:Show()
        if isSameAllocation then
            CraftSimReagentHintFrame.content.infoText:SetText(CraftSimReagentHintFrame.content.infoText.SameCombination)
        else
            CraftSimReagentHintFrame.content.infoText:SetText(CraftSimReagentHintFrame.content.infoText.NoCombinationFound)
        end

        CraftSimReagentHintFrame.content.qualityIcon:Hide()
        CraftSimReagentHintFrame.content.qualityText:Hide()
        CraftSimReagentHintFrame.content.allocateButton:Hide()

        for i = 1, 5, 1 do
            CraftSimReagentHintFrame.content.reagentFrames.rows[i]:Hide()
        end

        return
    else
        CraftSimReagentHintFrame.content.infoText:Hide()
        CraftSimReagentHintFrame.content.qualityIcon:Show()
        CraftSimReagentHintFrame.content.qualityText:Show()
        CraftSimReagentHintFrame.content.allocateButton:Show()
        CraftSimReagentHintFrame.content.allocateButton:SetEnabled(hasItems)
        if hasItems then
            CraftSimReagentHintFrame.content.allocateButton:SetText("Assign")
            CraftSimReagentHintFrame.content.allocateButton:SetScript("OnClick", function(self) 
                -- uncheck best quality box if checked
                local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
                if bestQBox:GetChecked() then
                    bestQBox:Click()
                end
                CraftSimREAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
            end)
        else
            CraftSimReagentHintFrame.content.allocateButton:SetText("Missing materials")
        end
        CraftSimReagentHintFrame.content.allocateButton:SetSize(CraftSimReagentHintFrame.content.allocateButton:GetTextWidth() + 15, 25)
    end
    CraftSimReagentHintFrame.content.qualityIcon.SetQuality(bestAllocation.qualityReached)
    for frameIndex = 1, 5, 1 do
        local allocation = bestAllocation.allocations[frameIndex]
        if allocation ~= nil then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(allocation.allocations[1].itemID) 
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex].q1Icon:SetTexture(itemTexture)
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex].q2Icon:SetTexture(itemTexture)
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex].q3Icon:SetTexture(itemTexture)
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex].q1text:SetText(allocation.allocations[1].allocations)
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex].q2text:SetText(allocation.allocations[2].allocations)
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex].q3text:SetText(allocation.allocations[3].allocations)

            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex]:Show()
        else
            CraftSimReagentHintFrame.content.reagentFrames.rows[frameIndex]:Hide()
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

    if craftingCosts == minCraftingCosts then
        CraftSimCostOverviewFrame.content.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))
        CraftSimCostOverviewFrame.content.craftingCostsTitle.SwitchAnchor(CraftSimCostOverviewFrame.title)
        CraftSimCostOverviewFrame.content.minCraftingCosts:Hide()
        CraftSimCostOverviewFrame.content.minCraftingCostsTitle:Hide()
    else
        CraftSimCostOverviewFrame.content.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))
        CraftSimCostOverviewFrame.content.minCraftingCosts:SetText(CraftSimUTIL:FormatMoney(minCraftingCosts))
        CraftSimCostOverviewFrame.content.craftingCostsTitle.SwitchAnchor(CraftSimCostOverviewFrame.content.minCraftingCosts)
        CraftSimCostOverviewFrame.content.minCraftingCosts:Show()
        CraftSimCostOverviewFrame.content.minCraftingCostsTitle:Show()
    end

    CraftSimFRAME:ToggleFrame(CraftSimCostOverviewFrame.content.resultProfitsTitle, #profitPerQuality > 0)

    for index, profitFrame in pairs(CraftSimCostOverviewFrame.content.profitFrames) do
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
    frame.content.simModeDropdown.isSimModeDropdown = true
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
    local iconButtons = {CraftSimSimFrame.content.toolIcon, CraftSimSimFrame.content.gear1Icon, CraftSimSimFrame.content.gear2Icon}
    for _, button in pairs(iconButtons) do
        button:Hide() -- only to consider cooking ...
    end
    if isCooking then
        iconButtons = {CraftSimSimFrame.content.toolIcon, CraftSimSimFrame.content.gear2Icon}
    end

    for index, iconButton in pairs(iconButtons) do
        iconButton:Show()
        if not professionGearCombo[index].isEmptySlot then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(professionGearCombo[index].itemLink) 
            iconButton:SetNormalTexture(itemTexture)
            iconButton:SetScript("OnEnter", function(self) 
                local itemName, ItemLink = GameTooltip:GetItem()
                GameTooltip:SetOwner(CraftSimSimFrame.content, "ANCHOR_RIGHT");
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
    CraftSimFRAME:ShowComboItemIcons(bestSimulation.combo, isCooking)
    if not CraftSimGEARSIM.IsEquipping then
        CraftSimSimFrame.currentCombo = bestSimulation.combo
    end
    -- TODO: maybe show in red or smth if negative
    if topGearMode == CraftSimCONST.GEAR_SIM_MODES.PROFIT then
        CraftSimSimFrame.content.profitText:SetText("Ø Profit Difference\n".. CraftSimUTIL:FormatMoney(bestSimulation.profitDiff, true))
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.MULTICRAFT then
        CraftSimSimFrame.content.profitText:SetText("New Multicraft\n".. CraftSimUTIL:round(bestSimulation.multicraftPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        CraftSimSimFrame.content.profitText:SetText("New Crafting Speed\n".. CraftSimUTIL:round(bestSimulation.craftingspeedPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        CraftSimSimFrame.content.profitText:SetText("New Resourcefulness\n".. CraftSimUTIL:round(bestSimulation.resourcefulnessPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.INSPIRATION then
        CraftSimSimFrame.content.profitText:SetText("New Inspiration\n".. CraftSimUTIL:round(bestSimulation.inspirationPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.SKILL then
        CraftSimSimFrame.content.profitText:SetText("New Skill\n".. bestSimulation.skill)
    else
        CraftSimSimFrame.content.profitText:SetText("Unhandled Sim Mode")
    end
    CraftSimTopGearEquipButton:SetEnabled(true)

    local inspirationBonusSkillText = ""
    if bestSimulation.statDiff.inspirationBonusskill then
        local prefix = "+" or ("-" and bestSimulation.statDiff.inspirationBonusskill < 0)
        inspirationBonusSkillText = " (" .. prefix .. CraftSimUTIL:round(bestSimulation.statDiff.inspirationBonusskill, 0) .. " Bonus)"
    end

    CraftSimSimFrame.content.statDiff.inspiration:SetText("Inspiration: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.inspiration, 2, "%") .. inspirationBonusSkillText)
    CraftSimSimFrame.content.statDiff.multicraft:SetText("Multicraft: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.multicraft, 2, "%"))
    CraftSimSimFrame.content.statDiff.resourcefulness:SetText("Resourcefulness: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.resourcefulness, 2, "%"))
    CraftSimSimFrame.content.statDiff.craftingspeed:SetText("Crafting Speed: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.craftingspeed, 2, "%"))
    CraftSimSimFrame.content.statDiff.skill:SetText("Skill: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.skill, 0))

    if CraftSimTopGearSimMode.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE and CraftSimTopGearSimMode.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
        CraftSimSimFrame.content.statDiff.qualityIcon.SetQuality(bestSimulation.modifiedRecipeData.expectedQuality)
        CraftSimSimFrame.content.statDiff.quality:Show()
        CraftSimSimFrame.content.statDiff.qualityIcon:Show()
    else
        CraftSimSimFrame.content.statDiff.quality:Hide()
        CraftSimSimFrame.content.statDiff.qualityIcon:Hide()
    end

end

function CraftSimFRAME:ClearResultData(isCooking)
    if not isCooking then
        CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    else
        CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    end

    CraftSimTopGearEquipButton:SetEnabled(false)
    CraftSimSimFrame.content.profitText:SetText("Top Gear equipped")

    CraftSimSimFrame.content.statDiff.inspiration:SetText("")
    CraftSimSimFrame.content.statDiff.multicraft:SetText("")
    CraftSimSimFrame.content.statDiff.resourcefulness:SetText("")
    CraftSimSimFrame.content.statDiff.craftingspeed:SetText("")
    CraftSimSimFrame.content.statDiff.skill:SetText("")
    CraftSimSimFrame.content.statDiff.quality:Hide()
    CraftSimSimFrame.content.statDiff.qualityIcon:Hide()
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
    CraftSimReagentHintFrame:ClearAllPoints()
    CraftSimCostOverviewFrame:ClearAllPoints()
    CraftSimSimFrame:ClearAllPoints()
    CraftSimDetailsFrame:ClearAllPoints()

    CraftSimReagentHintFrame:SetPoint("TOP",  ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, "BOTTOM", 0, 0)
    CraftSimCostOverviewFrame:SetPoint("TOP",  CraftSimSimFrame, "BOTTOM", 0, 10)
    CraftSimSimFrame:SetPoint("TOPLEFT",  ProfessionsFrame.CloseButton, "TOPRIGHT", -5, 3)
    CraftSimDetailsFrame:SetPoint("BOTTOM",  ProfessionsFrame.CraftingPage.SchematicForm.Details, 0, -80)
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
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})

    CraftSimFRAME:MakeCollapsable(frame, sizeX, sizeY, frameID)
    CraftSimFRAME:makeFrameMoveable(frame)
	
    frame.content = CreateFrame("frame", nil, frame)
    frame.content:SetPoint("TOP", frame, "TOP")
    frame.content:SetSize(sizeX, sizeY)

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