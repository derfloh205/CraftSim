-- TODO: Localization Differences?
-- TODO: parse from inscription description the skill bonus that is applied upon proc OR calculate with specs in mind

local REAGENT_TYPE = {
	OPTIONAL = 0,
	REQUIRED = 1,
	FINISHING_REAGENT = 2
}

local addon = CreateFrame("Frame", "CraftSimAddon")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")


function addon:ADDON_LOADED(addon_name)
	if addon_name ~= 'CraftSim' then
		return
	end
end

function addon:getExportString()
	local exportData = addon:exportRecipeData()
	-- now digest into an export string
	if exportData == nil then
		return "CraftSim does only work with Dragonflight profession recipes"
	end
	local exportString = ""
	for property, value in pairs(exportData) do
		exportString = exportString .. tostring(property) .. "," .. tostring(value) .. "\n"
	end
	return exportString
end

function addon:PLAYER_LOGIN()
	SLASH_CRAFTSIM1 = "/craftsim"
	SLASH_CRAFTSIM2 = "/crafts"
	SLASH_CRAFTSIM3 = "/simcc"
	SlashCmdList["CRAFTSIM"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if ProfessionsFrame:IsVisible() and ProfessionsFrame.CraftingPage:IsVisible() then
			print("CRAFTSIM: Export Data")
			addon:KethoEditBox_Show(addon:getExportString())
			KethoEditBoxEditBox:HighlightText()
		else
			print("CRAFTSIM ERROR: No Recipe Opened")
		end


	end
end

-- thx ketho forum guy
function addon:KethoEditBox_Show(text)
    if not KethoEditBox then
        local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)
        
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = { left = 8, right = 6, top = 8, bottom = 8 },
        })
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
        
        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)
        
        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
        
        -- EditBox
        local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(true) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        sf:SetScrollChild(eb)
        
        -- Resizable
        f:SetResizable(true)
        
        local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)
        
        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        
        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() -- more noticeable
            end
        end)
        rb:SetScript("OnMouseUp", function(self, button)
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth(sf:GetWidth())
        end)
        f:Show()
    end
    
    if text then
        KethoEditBoxEditBox:SetText(text)
    end
    KethoEditBox:Show()
end

function addon:getIDFromItemLink(itemLink)
	return string.find(itemLink, 'item:(%d+)')
end

function addon:exportRecipeData()
	local recipeData = {}

	local professionInfo = ProfessionsFrame.professionInfo
	local professionFullName = professionInfo.professionName
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm

	if not string.find(professionFullName, "Dragon Isles") then
		return nil
	end

	recipeData.profession = professionInfo.parentProfessionName
	local recipeInfo = schematicForm:GetRecipeInfo()
	local details = schematicForm.Details
	local operationInfo = details.operationInfo
	local bonusStats = operationInfo.bonusStats

	local recipeReagents = {}
	for k, currentSlot in pairs(C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false).reagentSlotSchematics) do
		local reagents = currentSlot.reagents
		local reagentType = currentSlot.reagentType
		-- for now only consider the required reagents
		if reagentType ~= REAGENT_TYPE.REQUIRED then
			break
		end
		recipeReagents[k] = {
			required = currentSlot.quantityRequired,
			differentQualities = reagentType == REAGENT_TYPE.REQUIRED and currentSlot.reagents[2] ~= nil,
			reagentType = currentSlot.reagentType
		}

		if reagentType == REAGENT_TYPE.REQUIRED and currentSlot.reagents[2] ~= nil then
			recipeReagents[k].itemsInfo = {}
			for i, reagent in pairs(reagents) do
				table.insert(recipeReagents[k].itemsInfo, {
					itemID = reagent.itemID
				})
			end
		else 
			recipeReagents[k].itemID = currentSlot.reagents[1].itemID
		end
		
	end
	for reagentIndex, reagentData in pairs(recipeReagents) do
		recipeData["reagent" .. reagentIndex .. "Name"] = name
		recipeData["reagent" .. reagentIndex .. "Required"] = reagentData.required
		if reagentData.differentQualities then
			recipeData["reagent" .. reagentIndex .. "q1ID"] = reagentData.itemsInfo[1].itemID
			recipeData["reagent" .. reagentIndex .. "q2ID"] = reagentData.itemsInfo[2].itemID
			recipeData["reagent" .. reagentIndex .. "q3ID"] = reagentData.itemsInfo[3].itemID
		else
			recipeData["reagent" .. reagentIndex .. "ID"] = itemID
		end
	end
	

	for k, statInfo in pairs(bonusStats) do
		local statName = statInfo.bonusStatName
		recipeData[statName .. "Value"] = statInfo.bonusStatValue
		recipeData[statName .. "Description"] = statInfo.ratingDescription
		recipeData[statName .. "Percent"] = statInfo.ratingPct
		if statName == 'Inspiration' then
			-- matches a row of numbers coming after the % character and any characters in between plus a space, should hopefully match in every localization...
			local _, _, bonusSkill = string.find(statInfo.ratingDescription, "%%.* (%d+)") 
			recipeData[statName .. "SkillBonus"] = bonusSkill
			print("inspirationbonusskill: " .. tostring(bonusSkill))
		end
	end

	recipeData["expectedQuality"] = details.craftingQuality
	recipeData["maxQuality"] = details.maxQuality
	recipeData["baseItemAmount"] = schematicForm.OutputIcon.Count:GetText()

	return recipeData
end