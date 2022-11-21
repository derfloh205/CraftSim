-- TODO: Localization Differences?
-- TODO: let statweight not work on bind at pickup items!
-- TODO: error message when no price source is available! Like show the window but with error message
-- TODO: error message when no full price data is available
-- TODO: more error handling
-- TODO: FEATURE(?): when not full price data is available, assume/extrapolate prices based on basePrice and quality ? but inform user, maybe even on demand with button
-- TODO: FEATURE: suggest or even auto equip most profitable profession gear combo for recipe (maybe on button click?)
-- TODO: FEATURE: integrate knapsack problem to solve best reagent configuration

local addon = CreateFrame("Frame", "CraftSimAddon")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")

local hookedToRecipeFrame = false

function addon:HookToRecipeFrame()
	if hookedToRecipeFrame then
		return
	end
	hookedToRecipeFrame = true
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm
	hooksecurefunc(schematicForm, "postInit", function(self) 
		--print("Refresh schematic form frame")
		CraftSimDetailsFrame:Show()
		local statWeights = CraftSimSTATS:getProfessionStatWeightsForCurrentRecipe()
		if statWeights == CraftSimCONST.ERROR.NO_PRICE_DATA or statWeights == CraftSimCONST.ERROR.NO_RECIPE_DATA then
			CraftSimDetailsFrame:Hide()
		else
			CraftSimUTIL:UpdateStatWeightFrameText(statWeights)
		end
	end)
end



function addon:InitStatWeightFrame()
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

function addon:ADDON_LOADED(addon_name)
	if addon_name == 'CraftSim' then
		addon:InitStatWeightFrame()
		addon:HookToRecipeFrame()
	end
	if addon_name == "TradeSkillMaster" then
		CraftSimPRICEDATA:InitAvailablePriceAPI()
	end
end

function addon:PLAYER_LOGIN()
	SLASH_CRAFTSIM1 = "/craftsim"
	SLASH_CRAFTSIM2 = "/crafts"
	SLASH_CRAFTSIM3 = "/simcc"
	SlashCmdList["CRAFTSIM"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then 
			return 
		end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "export" then
			if ProfessionsFrame:IsVisible() and ProfessionsFrame.CraftingPage:IsVisible() then
				print("CRAFTSIM: Export Data")
				CraftSimUTIL:KethoEditBox_Show(CraftSimDATAEXPORT:getExportString())
				KethoEditBoxEditBox:HighlightText()
			else
				print("CRAFTSIM ERROR: No Recipe Opened")
			end
		end
	end
end

