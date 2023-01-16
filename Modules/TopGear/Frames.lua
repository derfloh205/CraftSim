addonName, CraftSim = ...

CraftSim.TOPGEAR.FRAMES = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.FRAMES, recursive, l)
    else
        print(text)
    end
end

function CraftSim.TOPGEAR.FRAMES:Init()
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
        CraftSim.TOPGEAR:EquipTopGear()
    end)

    frame.content.simulateButton = CraftSim.FRAME:CreateButton(
        "Simulate Top Gear", frame.content, frame.content.equipButton, "CENTER", "CENTER", 0, 0, 5, 25, true, function(self) 
            local priceData = CraftSim.PRICEDATA:GetPriceData(CraftSim.MAIN.currentRecipeData, CraftSim.MAIN.currentRecipeData.recipeType)
            CraftSim.TOPGEAR:SimulateBestProfessionGearCombination(CraftSim.MAIN.currentRecipeData, CraftSim.MAIN.currentRecipeData.recipeType, priceData)
        end)
    

    frame.content.simModeDropdown = 
    CraftSim.FRAME:initDropdownMenu("CraftSimTopGearSimMode", frame.content, frame.title, "", 0, contentOffsetY, 120, {"Placeholder"}, function(arg1) 
        CraftSimOptions.topGearMode = arg1
        CraftSim.TOPGEAR:SimulateBestProfessionGearCombination(CraftSimTopGearSimMode.recipeData, CraftSimTopGearSimMode.recipeType, CraftSimTopGearSimMode.priceData)
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

function CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(professionGearCombo, isCooking)
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

function CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplay(bestSimulation, topGearMode, isCooking)
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(bestSimulation.combo, isCooking)
    if not CraftSim.TOPGEAR.IsEquipping then
        topGearFrame.currentCombo = bestSimulation.combo
    end
    -- TODO: maybe show in red or smth if negative
    if topGearMode == CraftSim.CONST.GEAR_SIM_MODES.PROFIT then
        topGearFrame.content.profitText:SetText("Ø Profit Difference\n".. CraftSim.UTIL:FormatMoney(bestSimulation.profitDiff, true))
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT then
        topGearFrame.content.profitText:SetText("New Multicraft\n".. CraftSim.UTIL:round(bestSimulation.multicraftPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        topGearFrame.content.profitText:SetText("New Crafting Speed\n".. CraftSim.UTIL:round(bestSimulation.craftingspeedPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        topGearFrame.content.profitText:SetText("New Resourcefulness\n".. CraftSim.UTIL:round(bestSimulation.resourcefulnessPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION then
        topGearFrame.content.profitText:SetText("New Inspiration\n".. CraftSim.UTIL:round(bestSimulation.inspirationPercent, 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.SKILL then
        topGearFrame.content.profitText:SetText("New Skill\n".. bestSimulation.skill)
    else
        topGearFrame.content.profitText:SetText("Unhandled Sim Mode")
    end
    CraftSimTopGearEquipButton:SetEnabled(true)
    CraftSimTopGearEquipButton:Show()
    topGearFrame.content.simulateButton:Hide()

    local inspirationBonusSkillText = ""
    if bestSimulation.statDiff.inspirationBonusskill then
        local prefix = "+" or ("-" and bestSimulation.statDiff.inspirationBonusskill < 0)
        inspirationBonusSkillText = " (" .. prefix .. CraftSim.UTIL:round(bestSimulation.statDiff.inspirationBonusskill, 0) .. " Bonus)"
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

function CraftSim.TOPGEAR.FRAMES:UpdateModeDropdown()
    if not CraftSim.MAIN.currentRecipeData then
        return
    end
    local recipeData = CraftSim.MAIN.currentRecipeData
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)

    local availableModes = CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndType(recipeData, recipeType)
    if #availableModes > 0 and not tContains(availableModes, CraftSimOptions.topGearMode) then
        CraftSimOptions.topGearMode = availableModes[1]
    end
    
    CraftSim.FRAME:initializeDropdown(topGearFrame.content.simModeDropdown, availableModes, CraftSimOptions.topGearMode)
end

function CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(isCooking, isClear)
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    if not isCooking then
        CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    else
        CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons({{isEmptySlot = true}, {isEmptySlot = true}}, isCooking)
    end

    CraftSimTopGearEquipButton:SetEnabled(false)
    topGearFrame.content.profitText:SetText(isClear and "" or "Top Gear equipped")

    CraftSim.FRAME:ToggleFrame(topGearFrame.content.simulateButton, isClear)
    CraftSim.FRAME:ToggleFrame(CraftSimTopGearEquipButton, not isClear)

    topGearFrame.content.statDiff.inspiration:SetText("")
    topGearFrame.content.statDiff.multicraft:SetText("")
    topGearFrame.content.statDiff.resourcefulness:SetText("")
    topGearFrame.content.statDiff.craftingspeed:SetText("")
    topGearFrame.content.statDiff.skill:SetText("")
    topGearFrame.content.statDiff.quality:Hide()
    topGearFrame.content.statDiff.qualityIcon:Hide()
end