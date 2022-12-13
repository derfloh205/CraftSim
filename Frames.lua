CraftSimFRAME = {}

function CraftSimFRAME:InitStatWeightFrame()
	local frame = CreateFrame("frame", "CraftSimDetailsFrame", ProfessionsFrame.CraftingPage.SchematicForm, "BackdropTemplate")
    CraftSimFRAME:makeFrameMoveable(frame)
	frame:SetPoint("BOTTOM",  ProfessionsFrame.CraftingPage.SchematicForm.Details, 0, -80)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(270, 100)

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 27)
	frame.title:SetText("CraftSim Statweights")

	frame.statText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.statText:SetPoint("LEFT", frame, "LEFT", 15, -5)

	frame.valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.valueText:SetPoint("RIGHT", frame, "RIGHT", -10, -5)
	frame:Hide()
end

function CraftSimFRAME:UpdateStatWeightFrameText(priceData, statWeights)
    if statWeights == nil then
        CraftSimDetailsFrame.statText:SetText("")
        CraftSimDetailsFrame.valueText:SetText("")
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
        CraftSimDetailsFrame.statText:SetText(statText)
        CraftSimDetailsFrame.valueText:SetText(valueText)
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
    local frame = CreateFrame("frame", "CraftSimReagentHintFrame", ProfessionsFrame.CraftingPage.SchematicForm.Reagents, "BackdropTemplate")

    CraftSimFRAME:makeFrameMoveable(frame)

    frame:SetPoint("TOP",  ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, "BOTTOM", 0, 0)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(270, 200)
    local contentOffsetY = -15
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, contentOffsetY)
	frame.title:SetText("Minimum cost to reach quality")

    frame.qualityText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.qualityText:SetPoint("TOP", frame.title, "TOP", 0, -20)
	frame.qualityText:SetText("Highest Quality: ")

    frame.qualityIcon = CraftSimFRAME:CreateQualityIcon(frame, 25, 25, frame.qualityText, "LEFT", "RIGHT", 3, 0)

    frame.allocateButton = CreateFrame("Button", "CraftSimMaterialAllocateButton", frame, "UIPanelButtonTemplate")
	frame.allocateButton:SetSize(50, 25)
	frame.allocateButton:SetPoint("TOP", frame.qualityText, "TOP", 0, -20)	
	frame.allocateButton:SetText("Assign")

    frame.infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.infoText:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.infoText.NoCombinationFound = "No combination found \nto increase quality"
    frame.infoText.SameCombination = "Best combination assigned"
	frame.infoText:SetText(frame.infoText.NoCombinationFound)

    local iconsOffsetY = -30
    local iconsSpacingY = 25

    frame.reagentFrames = {}
    frame.reagentFrames.rows = {}
    frame.reagentFrames.numReagents = 0
    local baseX = -20
    local iconSize = 30
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, frame.allocateButton, iconsOffsetY, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, frame.allocateButton, iconsOffsetY - iconsSpacingY, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, frame.allocateButton, iconsOffsetY - iconsSpacingY*2, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, frame.allocateButton, iconsOffsetY - iconsSpacingY*3, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, frame.allocateButton, iconsOffsetY - iconsSpacingY*4, iconSize))

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
        CraftSimReagentHintFrame.infoText:Show()
        if isSameAllocation then
            CraftSimReagentHintFrame.infoText:SetText(CraftSimReagentHintFrame.infoText.SameCombination)
        else
            CraftSimReagentHintFrame.infoText:SetText(CraftSimReagentHintFrame.infoText.NoCombinationFound)
        end

        CraftSimReagentHintFrame.qualityIcon:Hide()
        CraftSimReagentHintFrame.qualityText:Hide()
        CraftSimReagentHintFrame.allocateButton:Hide()

        for i = 1, 5, 1 do
            CraftSimReagentHintFrame.reagentFrames.rows[i]:Hide()
        end

        return
    else
        CraftSimReagentHintFrame.infoText:Hide()
        CraftSimReagentHintFrame.qualityIcon:Show()
        CraftSimReagentHintFrame.qualityText:Show()
        CraftSimReagentHintFrame.allocateButton:Show()
        CraftSimReagentHintFrame.allocateButton:SetEnabled(hasItems)
        if hasItems then
            CraftSimReagentHintFrame.allocateButton:SetText("Assign")
            CraftSimReagentHintFrame.allocateButton:SetScript("OnClick", function(self) 
                -- uncheck best quality box if checked
                local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
                if bestQBox:GetChecked() then
                    bestQBox:Click()
                end
                CraftSimREAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
            end)
        else
            CraftSimReagentHintFrame.allocateButton:SetText("Missing materials")
        end
        CraftSimReagentHintFrame.allocateButton:SetSize(CraftSimReagentHintFrame.allocateButton:GetTextWidth() + 15, 25)
    end
    CraftSimReagentHintFrame.qualityIcon.SetQuality(bestAllocation.qualityReached)
    for frameIndex = 1, 5, 1 do
        local allocation = bestAllocation.allocations[frameIndex]
        if allocation ~= nil then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(allocation.allocations[1].itemID) 
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex].q1Icon:SetTexture(itemTexture)
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex].q2Icon:SetTexture(itemTexture)
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex].q3Icon:SetTexture(itemTexture)
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex].q1text:SetText(allocation.allocations[1].allocations)
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex].q2text:SetText(allocation.allocations[2].allocations)
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex].q3text:SetText(allocation.allocations[3].allocations)

            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex]:Show()
        else
            CraftSimReagentHintFrame.reagentFrames.rows[frameIndex]:Hide()
        end
        
    end
end

function CraftSimFRAME:InitCostOverviewFrame()
    local frame = CreateFrame("frame", "CraftSimCostOverviewFrame", ProfessionsFrame.CraftingPage.SchematicForm, "BackdropTemplate")
    CraftSimFRAME:makeFrameMoveable(frame)
	frame:SetPoint("TOP",  CraftSimSimFrame, "BOTTOM", 0, 10)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(250, 270)
    local contentOffsetY = -20
    local textSpacingY = -20
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, contentOffsetY)
	frame.title:SetText("CraftSim Cost Overview")

    frame.minCraftingCostsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.minCraftingCostsTitle:SetPoint("TOP", frame.title, "TOP", 0, textSpacingY)
    frame.minCraftingCostsTitle:SetText("Min Crafting Costs")

    frame.minCraftingCosts = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.minCraftingCosts:SetPoint("TOP", frame.minCraftingCostsTitle, "TOP", 0, textSpacingY)
    frame.minCraftingCosts:SetText("???")

    frame.craftingCostsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.craftingCostsTitle:SetPoint("TOP", frame.minCraftingCosts, "TOP", 0, textSpacingY)
    frame.craftingCostsTitle:SetText("Current Crafting Costs")
    frame.craftingCostsTitle.SwitchAnchor = function(newAnchor) 
        frame.craftingCostsTitle:SetPoint("TOP", newAnchor, "TOP", 0, textSpacingY)
    end

    frame.craftingCosts = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.craftingCosts:SetPoint("TOP", frame.craftingCostsTitle, "TOP", 0, textSpacingY)
    frame.craftingCosts:SetText("???")
    

    frame.resultProfitsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.resultProfitsTitle:SetPoint("TOP", frame.craftingCosts, "TOP", 0, textSpacingY - 10)
    frame.resultProfitsTitle:SetText("Profit By Quality")

    local function createProfitFrame(offsetY, parent, hookFrame)
        local profitFrame = CreateFrame("frame", nil, parent)
        profitFrame:SetSize(parent:GetWidth(), 25)
        profitFrame:SetPoint("TOP", hookFrame, "TOP", 0, offsetY)
        profitFrame.icon = CraftSimFRAME:CreateQualityIcon(profitFrame, 20, 20, profitFrame, "CENTER", "CENTER", -75, 0)

        profitFrame.text = profitFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        profitFrame.text:SetPoint("LEFT", profitFrame.icon, "LEFT", 30, 0)
        profitFrame.text:SetText("???")

        profitFrame:Hide()
        return profitFrame
    end

    local baseY = -20
    local profitFramesSpacingY = -20
    frame.profitFrames = {}
    table.insert(frame.profitFrames, createProfitFrame(baseY, frame, frame.resultProfitsTitle))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY, frame, frame.resultProfitsTitle))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*2, frame, frame.resultProfitsTitle))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*3, frame, frame.resultProfitsTitle))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*4, frame, frame.resultProfitsTitle))
    

	frame:Hide()
end

function CraftSimFRAME:FillCostOverview(craftingCosts, minCraftingCosts, profitPerQuality, currentQuality)

    if craftingCosts == minCraftingCosts then
        CraftSimCostOverviewFrame.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))
        CraftSimCostOverviewFrame.craftingCostsTitle.SwitchAnchor(CraftSimCostOverviewFrame.title)
        CraftSimCostOverviewFrame.minCraftingCosts:Hide()
        CraftSimCostOverviewFrame.minCraftingCostsTitle:Hide()
    else
        CraftSimCostOverviewFrame.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))
        CraftSimCostOverviewFrame.minCraftingCosts:SetText(CraftSimUTIL:FormatMoney(minCraftingCosts))
        CraftSimCostOverviewFrame.craftingCostsTitle.SwitchAnchor(CraftSimCostOverviewFrame.minCraftingCosts)
        CraftSimCostOverviewFrame.minCraftingCosts:Show()
        CraftSimCostOverviewFrame.minCraftingCostsTitle:Show()
    end

    CraftSimFRAME:ToggleFrame(CraftSimCostOverviewFrame.resultProfitsTitle, #profitPerQuality > 0)

    for index, profitFrame in pairs(CraftSimCostOverviewFrame.profitFrames) do
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
    local frame = CreateFrame("frame", "CraftSimSimFrame", ProfessionsFrame.CraftingPage.SchematicForm, "BackdropTemplate")
    CraftSimFRAME:makeFrameMoveable(frame)
	frame:SetPoint("TOPLEFT",  ProfessionsFrame.CloseButton, "TOPRIGHT", -5, 3)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(250, 300)
    local contentOffsetY = -20
    local iconsOffsetY = 80
    frame.gear1Icon = CraftSimFRAME:CreateIcon(frame, -45, contentOffsetY + iconsOffsetY, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.gear2Icon = CraftSimFRAME:CreateIcon(frame,  -0, contentOffsetY + iconsOffsetY, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.toolIcon = CraftSimFRAME:CreateIcon(frame, 50, contentOffsetY + iconsOffsetY, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)

    frame.equipButton = CreateFrame("Button", "CraftSimTopGearEquipButton", frame, "UIPanelButtonTemplate")
	frame.equipButton:SetSize(50, 25)
	frame.equipButton:SetPoint("CENTER", frame, "CENTER", 0, contentOffsetY + 40)	
	frame.equipButton:SetText("Equip")
    frame.equipButton:SetScript("OnClick", function(self) 
        CraftSimGEARSIM:EquipTopGear()
    end)

    frame.simModeDropdown = 
    CraftSimFRAME:initDropdownMenu("CraftSimTopGearSimMode", frame, "CraftSim Top Gear", 0, contentOffsetY - 10, 120, {"Placeholder"}, function(arg1) 
        CraftSimOptions.topGearMode = arg1
        CraftSimGEARSIM:SimulateBestProfessionGearCombination(CraftSimTopGearSimMode.recipeData, CraftSimTopGearSimMode.recipeType, CraftSimTopGearSimMode.priceData)
    end, "Placeholder")
    frame.simModeDropdown.isSimModeDropdown = true
    frame.profitText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.profitText:SetPoint("CENTER", frame, "CENTER", 0, contentOffsetY + 10)

    frame.statDiff = CreateFrame("frame", nil, frame)
    frame.statDiff:SetSize(200, 100)
    frame.statDiff:SetPoint("CENTER", frame, "CENTER", 0, contentOffsetY - 50)

    local statTxtSpacingY = -15
    frame.statDiff.inspiration = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.inspiration:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*1)
    frame.statDiff.inspiration:SetText("Inspiration: ")

    frame.statDiff.multicraft = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.multicraft:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*2)
    frame.statDiff.multicraft:SetText("Multicraft: ")

    frame.statDiff.resourcefulness = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.resourcefulness:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*3)
    frame.statDiff.resourcefulness:SetText("Resourcefulness: ")

    frame.statDiff.craftingspeed = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.craftingspeed:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*4)
    frame.statDiff.craftingspeed:SetText("Crafting Speed: ")

    frame.statDiff.skill = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.skill:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*5)
    frame.statDiff.skill:SetText("Skill: ")

    frame.statDiff.quality = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.quality:SetPoint("TOP", frame.statDiff, "TOP", -5, statTxtSpacingY*6)
    frame.statDiff.quality:SetText("Quality: ")

    frame.statDiff.qualityIcon = CraftSimFRAME:CreateQualityIcon(frame, 20, 20, frame.statDiff.quality, "LEFT", "RIGHT", 3, 0)

	frame:Hide()
end

function CraftSimFRAME:ShowComboItemIcons(professionGearCombo)
    local iconButtons = {CraftSimSimFrame.toolIcon, CraftSimSimFrame.gear1Icon, CraftSimSimFrame.gear2Icon}
    for index, iconButton in pairs(iconButtons) do
        if not professionGearCombo[index].isEmptySlot then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(professionGearCombo[index].itemLink) 
            iconButton:SetNormalTexture(itemTexture)
            iconButton:SetScript("OnEnter", function(self) 
                local itemName, ItemLink = GameTooltip:GetItem()
                GameTooltip:SetOwner(CraftSimSimFrame, "ANCHOR_RIGHT");
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

function CraftSimFRAME:FillSimResultData(bestSimulation, topGearMode)
    CraftSimFRAME:ShowComboItemIcons(bestSimulation.combo)
    if not CraftSimGEARSIM.IsEquipping then
        CraftSimSimFrame.currentCombo = bestSimulation.combo
    end
    -- TODO: maybe show in red or smth if negative
    if topGearMode == CraftSimCONST.GEAR_SIM_MODES.PROFIT then
        CraftSimSimFrame.profitText:SetText("Ø Profit Difference\n".. CraftSimUTIL:FormatMoney(bestSimulation.profitDiff, true))
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.MULTICRAFT then
        CraftSimSimFrame.profitText:SetText("New Multicraft\n".. CraftSimUTIL:round(bestSimulation.multicraftPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        CraftSimSimFrame.profitText:SetText("New Crafting Speed\n".. CraftSimUTIL:round(bestSimulation.craftingspeedPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        CraftSimSimFrame.profitText:SetText("New Resourcefulness\n".. CraftSimUTIL:round(bestSimulation.resourcefulnessPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.INSPIRATION then
        CraftSimSimFrame.profitText:SetText("New Inspiration\n".. CraftSimUTIL:round(bestSimulation.inspirationPercent, 2) .. "%")
    elseif topGearMode == CraftSimCONST.GEAR_SIM_MODES.SKILL then
        CraftSimSimFrame.profitText:SetText("New Skill\n".. bestSimulation.skill)
    else
        CraftSimSimFrame.profitText:SetText("Unhandled Sim Mode")
    end
    CraftSimTopGearEquipButton:SetEnabled(true)

    CraftSimSimFrame.statDiff.inspiration:SetText("Inspiration: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.inspiration, 2, "%"))
    CraftSimSimFrame.statDiff.multicraft:SetText("Multicraft: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.multicraft, 2, "%"))
    CraftSimSimFrame.statDiff.resourcefulness:SetText("Resourcefulness: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.resourcefulness, 2, "%"))
    CraftSimSimFrame.statDiff.craftingspeed:SetText("Crafting Speed: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.craftingspeed, 2, "%"))
    CraftSimSimFrame.statDiff.skill:SetText("Skill: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.skill, 0))

    if CraftSimTopGearSimMode.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE and CraftSimTopGearSimMode.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
        CraftSimSimFrame.statDiff.qualityIcon.SetQuality(bestSimulation.modifiedRecipeData.expectedQuality)
        CraftSimSimFrame.statDiff.quality:Show()
        CraftSimSimFrame.statDiff.qualityIcon:Show()
    else
        CraftSimSimFrame.statDiff.quality:Hide()
        CraftSimSimFrame.statDiff.qualityIcon:Hide()
    end

end

function CraftSimFRAME:ClearResultData()
    CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}})
    CraftSimTopGearEquipButton:SetEnabled(false)
    CraftSimSimFrame.profitText:SetText("Top Gear equipped")

    CraftSimSimFrame.statDiff.inspiration:SetText("")
    CraftSimSimFrame.statDiff.multicraft:SetText("")
    CraftSimSimFrame.statDiff.resourcefulness:SetText("")
    CraftSimSimFrame.statDiff.craftingspeed:SetText("")
    CraftSimSimFrame.statDiff.skill:SetText("")
    CraftSimSimFrame.statDiff.quality:Hide()
    CraftSimSimFrame.statDiff.qualityIcon:Hide()
end

function CraftSimFRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

function CraftSimFRAME:initDropdownMenu(frameName, parent, label, offsetX, offsetY, width, list, clickCallback, defaultValue)
	local dropDown = CreateFrame("Frame", frameName, parent, "UIDropDownMenuTemplate")
    dropDown.clickCallback = clickCallback
	dropDown:SetPoint("TOP", parent, offsetX, offsetY)
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
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, button)
		self:StartMoving()
		end)
		frame:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing()
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