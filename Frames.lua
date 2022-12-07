CraftSimFRAME = {}

function CraftSimFRAME:InitStatWeightFrame()
	local frame = CreateFrame("frame", "CraftSimDetailsFrame", ProfessionsFrame.CraftingPage.SchematicForm, "BackdropTemplate")
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
	frame.statText:SetPoint("LEFT", frame, "LEFT", 20, -5)

	frame.valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.valueText:SetPoint("CENTER", frame, "CENTER", 40, -8)
	frame:Hide()
end

function CraftSimFRAME:UpdateStatWeightFrameText(statWeights)
    if statWeights == nil then
        CraftSimDetailsFrame.statText:SetText("")
        CraftSimDetailsFrame.valueText:SetText("")
    else
        local statText = ""
        local valueText = ""

        if statWeights.meanProfit then
            statText = statText .. "Mean Profit:" .. "\n"
            valueText = valueText .. CraftSimUTIL:FormatMoney(statWeights.meanProfit) .. "\n"
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
    local frameOffsetY = 0
    if IsAddOnLoaded("Auctionator") then
        frameOffsetY = -30
        -- move a bit down to make space for auctionator info frame
    end
    frame:SetPoint("TOPLEFT",  ProfessionsFrame.CraftingPage.SchematicForm.Reagents, "BOTTOMLEFT", 0, frameOffsetY)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(250, 150)
    local contentOffsetY = -60
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, contentOffsetY + 117)
	frame.title:SetText("CS: Highest Quality Allocation (WIP)")

    -- frame.calculateButton = CreateFrame("Button", "CraftSimReagentHintButton", frame, "UIPanelButtonTemplate")
	-- frame.calculateButton:SetSize(70, 25)
	-- frame.calculateButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, contentOffsetY + 30)	
	-- frame.calculateButton:SetText("Calculate")
    -- frame.calculateButton:SetScript("OnClick", function(self) 
    --     CraftSimREAGENT_OPTIMIZATION:OptimizeReagentAllocation()
    -- end)

    frame.qualityText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.qualityText:SetPoint("TOP", frame, "TOP", 0, -35)
	frame.qualityText:SetText("Highest Quality: ")

    frame.qualityIcon = frame:CreateTexture(nil, "OVERLAY")
    frame.qualityIcon:SetSize(25, 25)
    frame.qualityIcon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    frame.qualityIcon:SetAtlas("Professions-Icon-Quality-Tier1")
    frame.qualityIcon:SetPoint("LEFT", frame.qualityText, "RIGHT", 3, 0)

    frame.qualityIcon.SetQuality = function(qualityID) 
        frame.qualityIcon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
        frame.qualityIcon:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
    end

    frame.notFoundText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.notFoundText:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.notFoundText:SetText("No combination found \nto increase quality")

    local iconsOffsetY = 40
    local iconsOffsetX = -40
    local iconsSpacingY = 25

    frame.reagentFrames = {}
    frame.reagentFrames.rows = {}
    frame.reagentFrames.numReagents = 0
    local baseX = -20
    local iconSize = 30
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, contentOffsetY + iconsOffsetY, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, contentOffsetY + iconsOffsetY + iconsSpacingY, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, contentOffsetY + iconsOffsetY + iconsSpacingY*2, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, contentOffsetY + iconsOffsetY + iconsSpacingY*3, iconSize))
    table.insert(frame.reagentFrames.rows, CraftSimFRAME:CreateReagentFrame(frame, contentOffsetY + iconsOffsetY + iconsSpacingY*4, iconSize))

    frame:Hide()
end

function CraftSimFRAME:CreateReagentFrame(parent, y, iconSize)
    local reagentFrame = CreateFrame("frame", nil, parent)
    reagentFrame:SetSize(parent:GetWidth(), iconSize)
    reagentFrame:SetPoint("CENTER", parent, "CENTER", 0, y)
    
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
    
    reagentFrame.q1qualityIcon = reagentFrame:CreateTexture(nil, "OVERLAY")
    reagentFrame.q1qualityIcon:SetSize(qualityIconSize, qualityIconSize)
    reagentFrame.q1qualityIcon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    reagentFrame.q1qualityIcon:SetAtlas("Professions-Icon-Quality-Tier1")
    reagentFrame.q1qualityIcon:SetPoint("CENTER", reagentFrame.q1Icon, "TOPLEFT", qualityIconX, qualityIconY)

    reagentFrame.q2qualityIcon = reagentFrame:CreateTexture(nil, "OVERLAY")
    reagentFrame.q2qualityIcon:SetSize(qualityIconSize, qualityIconSize)
    reagentFrame.q2qualityIcon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    reagentFrame.q2qualityIcon:SetAtlas("Professions-Icon-Quality-Tier2")
    reagentFrame.q2qualityIcon:SetPoint("CENTER", reagentFrame.q2Icon, "TOPLEFT", qualityIconX, qualityIconY)

    reagentFrame.q3qualityIcon = reagentFrame:CreateTexture(nil, "OVERLAY")
    reagentFrame.q3qualityIcon:SetSize(qualityIconSize, qualityIconSize)
    reagentFrame.q3qualityIcon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    reagentFrame.q3qualityIcon:SetAtlas("Professions-Icon-Quality-Tier3")
    reagentFrame.q3qualityIcon:SetPoint("CENTER", reagentFrame.q3Icon, "TOPLEFT", qualityIconX, qualityIconY)

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
function CraftSimFRAME:ShowBestReagentAllocation(bestAllocation)
    if bestAllocation == nil then
        CraftSimReagentHintFrame.notFoundText:Show()
        CraftSimReagentHintFrame.qualityIcon:Hide()
        CraftSimReagentHintFrame.qualityText:Hide()

        for i = 1, 5, 1 do
            CraftSimReagentHintFrame.reagentFrames.rows[i]:Hide()
        end

        return
    else
        CraftSimReagentHintFrame.notFoundText:Hide()
        CraftSimReagentHintFrame.qualityIcon:Show()
        CraftSimReagentHintFrame.qualityText:Show()
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
	frame:SetPoint("TOP",  CraftSimSimFrame, "BOTTOM", 0, 10)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(200, 250)
    local contentOffsetY = -20
    local textSpacingY = -20
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, contentOffsetY)
	frame.title:SetText("CraftSim Cost Overview")

    frame.craftingCostsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.craftingCostsTitle:SetPoint("TOP", frame.title, "TOP", 0, textSpacingY)
    frame.craftingCostsTitle:SetText("Crafting Costs")

    frame.craftingCosts = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.craftingCosts:SetPoint("TOP", frame.craftingCostsTitle, "TOP", 0, textSpacingY)
    frame.craftingCosts:SetText("???")

    frame.resultProfitsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.resultProfitsTitle:SetPoint("TOP", frame.craftingCosts, "TOP", 0, textSpacingY - 20)
    frame.resultProfitsTitle:SetText("Profit By Quality")

    local function createProfitFrame(offsetY, parent)
        local profitFrame = CreateFrame("frame", nil, parent)
        profitFrame:SetSize(parent:GetWidth(), 25)
        profitFrame:SetPoint("TOP", parent, "TOP", 0, offsetY)
        profitFrame.icon = profitFrame:CreateTexture(nil, "OVERLAY")
        profitFrame.icon:SetSize(20, 20)
        profitFrame.icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
        profitFrame.icon:SetAtlas("Professions-Icon-Quality-Tier1")
        profitFrame.icon:SetPoint("CENTER", profitFrame, "CENTER", -60, 0)
        profitFrame.icon.SetQuality = function(qualityID) 
            profitFrame.icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
            profitFrame.icon:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
        end

        profitFrame.text = profitFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        profitFrame.text:SetPoint("LEFT", profitFrame.icon, "LEFT", 30, 0)
        profitFrame.text:SetText("???")

        profitFrame:Hide()
        return profitFrame
    end

    local baseY = contentOffsetY - 100
    local profitFramesSpacingY = -20
    frame.profitFrames = {}
    table.insert(frame.profitFrames, createProfitFrame(baseY, frame))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY, frame))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*2, frame))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*3, frame))
    table.insert(frame.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*4, frame))
    

	frame:Hide()
end

function CraftSimFRAME:FillCostOverview(craftingCosts, profitPerQuality, currentQuality)
    CraftSimCostOverviewFrame.craftingCosts:SetText(CraftSimUTIL:FormatMoney(craftingCosts))

    CraftSimFRAME:ToggleFrame(CraftSimCostOverviewFrame.resultProfitsTitle, #profitPerQuality > 0)

    for index, profitFrame in pairs(CraftSimCostOverviewFrame.profitFrames) do
        if profitPerQuality[index] ~= nil then
            profitFrame.icon.SetQuality(currentQuality + index - 1)
            profitFrame.text:SetText(CraftSimUTIL:FormatMoney(profitPerQuality[index]))
            profitFrame:Show()
        else
            profitFrame:Hide()
        end
    end
end

function CraftSimFRAME:InitGearSimFrame()
    local frame = CreateFrame("frame", "CraftSimSimFrame", ProfessionsFrame.CraftingPage.SchematicForm, "BackdropTemplate")
	frame:SetPoint("TOPRIGHT",  ProfessionsFrame.CloseButton, 195, 3)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(200, 250)
    local contentOffsetY = -20
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, contentOffsetY + 117)
	frame.title:SetText("CraftSim Top Gear")
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
    frame.statDiff.multicraft:SetPoint("TOP", frame.statDiff, "TOP", -0, statTxtSpacingY*2)
    frame.statDiff.multicraft:SetText("Multicraft: ")

    frame.statDiff.resourcefulness = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.resourcefulness:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*3)
    frame.statDiff.resourcefulness:SetText("Resourcefulness: ")

    frame.statDiff.skill = frame.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.statDiff.skill:SetPoint("TOP", frame.statDiff, "TOP", 0, statTxtSpacingY*4)
    frame.statDiff.skill:SetText("Skill: ")

	frame:Hide()
end

function CraftSimFRAME:ShowComboItemIcons(professionGearCombo)
    local iconButtons = {CraftSimSimFrame.toolIcon, CraftSimSimFrame.gear1Icon, CraftSimSimFrame.gear2Icon}
    for index, iconButton in pairs(iconButtons) do
        if not professionGearCombo[index].isEmptySlot then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(professionGearCombo[index].itemLink) 
            iconButton:SetNormalTexture(itemTexture)
            iconButton:SetScript("OnEnter", function(self) 
				GameTooltip:SetHyperlink(professionGearCombo[index].itemLink)
                GameTooltip:ClearAllPoints()
                --GameTooltip:SetOwner(iconButton, "ANCHOR_TOP");
	            GameTooltip:SetPoint("BOTTOM", iconButton, "TOP", 0, 0);
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

function CraftSimFRAME:FillSimResultData(bestSimulation)
    CraftSimFRAME:ShowComboItemIcons(bestSimulation.combo)
    if not CraftSimGEARSIM.IsEquipping then
        CraftSimSimFrame.currentCombo = bestSimulation.combo
    end
    -- TODO: maybe show in red or smth if negative
    CraftSimSimFrame.profitText:SetText("Profit Difference / Craft\n".. CraftSimUTIL:FormatMoney(bestSimulation.profitDiff))
    CraftSimTopGearEquipButton:SetEnabled(true)

    CraftSimSimFrame.statDiff.inspiration:SetText("Inspiration: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.inspiration, 2, "%"))
    CraftSimSimFrame.statDiff.multicraft:SetText("Multicraft: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.multicraft, 2, "%"))
    CraftSimSimFrame.statDiff.resourcefulness:SetText("Resourcefulness: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.resourcefulness, 2, "%"))
    CraftSimSimFrame.statDiff.skill:SetText("Skill: " .. CraftSimFRAME:FormatStatDiffpercentText(bestSimulation.statDiff.skill, 0))
end

function CraftSimFRAME:ClearResultData()
    CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}})
    CraftSimTopGearEquipButton:SetEnabled(false)
    CraftSimSimFrame.profitText:SetText("Top Gear equipped")

    CraftSimSimFrame.statDiff.inspiration:SetText("")
    CraftSimSimFrame.statDiff.multicraft:SetText("")
    CraftSimSimFrame.statDiff.resourcefulness:SetText("")
    CraftSimSimFrame.statDiff.skill:SetText("")
end

function CraftSimFRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

