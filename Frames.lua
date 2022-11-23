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
	frame:Show()
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

function CraftSimFRAME:CreateIcon(parent, offsetX, offsetY, texture, sizeX, sizeY)
    local newIcon = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    newIcon:SetPoint("CENTER", parent, "CENTER", offsetX, offsetY)
	newIcon:SetSize(sizeX, sizeY)
	newIcon:SetNormalFontObject("GameFontNormalLarge")
	newIcon:SetHighlightFontObject("GameFontHighlightLarge")
	newIcon:SetNormalTexture(texture)
    return newIcon
end

function CraftSimFRAME:InitGearSimFrame()
    local frame = CreateFrame("frame", "CraftSimSimFrame", ProfessionsFrame.CraftingPage.SchematicForm, "BackdropTemplate")
	frame:SetPoint("TOPRIGHT",  ProfessionsFrame.CraftingPage.SchematicForm.Details, 230, -5)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(200, 170)
    local contentOffsetY = -60
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
        CraftSimGEARSIM:EquipBestCombo()
    end)

    frame.profitText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.profitText:SetPoint("CENTER", frame, "CENTER", 0, contentOffsetY + 10)

	frame:Show()
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

function CraftSimFRAME:FillSimResultData(bestSimulation)
    CraftSimFRAME:ShowComboItemIcons(bestSimulation.combo)
    CraftSimSimFrame.currentCombo = bestSimulation.combo
    -- TODO: maybe show in red or smth if negative
    CraftSimSimFrame.profitText:SetText("Profit Difference\n".. CraftSimUTIL:FormatMoney(bestSimulation.profitDiff))
    CraftSimTopGearEquipButton:SetEnabled(true)
end

function CraftSimFRAME:ClearResultData()
    CraftSimFRAME:ShowComboItemIcons({{isEmptySlot = true}, {isEmptySlot = true}, {isEmptySlot = true}})
    CraftSimTopGearEquipButton:SetEnabled(false)
    CraftSimSimFrame.profitText:SetText("Top Gear equipped")
end

function CraftSimFRAME:ToggleFrames(visible)
    if visible then
        --print("show frames")
        CraftSimSimFrame:Show()
        CraftSimDetailsFrame:Show()
    else
        --print("hide frames")
        CraftSimSimFrame:Hide()
        CraftSimDetailsFrame:Hide()
    end
end

