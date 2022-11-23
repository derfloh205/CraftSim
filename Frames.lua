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
	frame.statText:SetPoint("LEFT", frame, "LEFT", 30, -5)

	frame.valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.valueText:SetPoint("CENTER", frame, "CENTER", 25, -5)
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
            valueText = valueText .. CraftSimUTIL:round(statWeights.meanProfit, 2) .. "\n"
        end
        if statWeights.inspiration then
            statText = statText .. "Inspiration:" .. "\n"
            valueText = valueText .. CraftSimUTIL:round(statWeights.inspiration, 3) .. "\n"
        end
        if statWeights.multicraft then
            statText = statText .. "Multicraft:" .. "\n"
            valueText = valueText .. CraftSimUTIL:round(statWeights.multicraft, 3) .. "\n"
        end
        if statWeights.resourcefulness then
            statText = statText .. "Resourcefulness:"
            valueText = valueText .. CraftSimUTIL:round(statWeights.resourcefulness, 3)
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
	frame:SetPoint("RIGHT",  ProfessionsFrame.CraftingPage.SchematicForm.NineSlice.TopRightCorner, 200, 25)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	frame:SetSize(200, 110)

	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("CENTER", frame, "CENTER", 0, 37)
	frame.title:SetText("CraftSim Top Gear")

	frame.mainText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.mainText:SetPoint("LEFT", frame, "LEFT", 30, -5)

    frame.gear1Icon = CraftSimFRAME:CreateIcon(frame, -60, 0, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.gear2Icon = CraftSimFRAME:CreateIcon(frame,  -10, 0, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)
    frame.toolIcon = CraftSimFRAME:CreateIcon(frame, 50, 0, CraftSimCONST.EMPTY_SLOT_TEXTURE, 40, 40)

	frame:Show()
end

function CraftSimFRAME:ShowComboItemIcons(professionGearCombo)
    local iconButtons = {CraftSimSimFrame.toolIcon, CraftSimSimFrame.gear1Icon, CraftSimSimFrame.gear2Icon}
    for index, iconButton in pairs(iconButtons) do
        if not professionGearCombo[index].isEmptySlot then
            local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(professionGearCombo[index].itemLink) 
            iconButton:SetNormalTexture(itemTexture)
            iconButton:SetScript("OnEnter", function(self) 
                --print("mouse entered")
				GameTooltip:SetHyperlink(professionGearCombo[index].itemLink)
                --GameTooltip:SetOwner(UIParent, "ANCHOR_NONE");
                GameTooltip:ClearAllPoints()
	            GameTooltip:SetPoint("CENTER", iconButton, "CENTER", -150, 0); -- TODO: get mouse position
				GameTooltip:Show();
            end)
            iconButton:SetScript("OnLeave", function(self) 
                --print("mouse left")
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

function CraftSimFRAME:ToggleFrames(visible)
    if visible then
        print("show frames")
        CraftSimSimFrame:Show()
        CraftSimDetailsFrame:Show()
    else
        print("hide frames")
        CraftSimSimFrame:Hide()
        CraftSimDetailsFrame:Hide()
    end
end

