-- TODO: Localization Differences?
-- TODO: error message when no price source is available! Like show the window but with error message
-- TODO: error message when no full price data is available
-- TODO: more error handling
-- TODO: ignore gathering recipes
-- TODO: FEATURE(?): when not full price data is available, assume/extrapolate prices based on basePrice and quality ? but inform user, maybe even on demand with button
-- TODO: FEATURE: suggest or even auto equip most profitable profession gear combo for recipe (maybe on button click?)
-- TODO: FEATURE: integrate knapsack problem to solve best reagent configuration

local addon = CreateFrame("Frame", "CraftSimAddon")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")

local hookedToDetailsFrame = false
-- this should cover the case of switching to a frame that does not show the details like recrafting, from a frame that does
function addon:HookToDetailsHide()
	if hookedToDetailsFrame then
		return
	end
	hookedToDetailsFrame = true
	ProfessionsFrame.CraftingPage.SchematicForm.Details:HookScript("OnHide", function(self)
		CraftSimFRAME:ToggleFrames(false)
	end)
end

local hookedEvent = false
function addon:HookToEvent()
	if hookedEvent then
		return
	end
	hookedEvent = true

	-- hook to the "SetStats" function of the Details panel
	-- this makes the most sense cause we only really need to calculate again when the stats of the recipe are changed
	-- and all reagents change some stats (like difficulty or quality at least)
	-- it is also fired when a recipe is opened or changed
	-- it is also fired multi times when a reagent is changed but like 5 or 6 times at most, this should not be a performance problem
	-- TODO: check if there are any reagents that impact profit and do not change a stat??
	-- Note: OnShow also 'works', it triggers but there is no recipe info yet, so we need something that also triggers and comes after OnShow..
	hooksecurefunc(ProfessionsFrame.CraftingPage.SchematicForm.Details, "SetStats", function(self)
		--print("Details: SetStats")
		addon:UpdateStatWeights()
		CraftSimGEARSIM:SimulateBestProfessionGearCombination()
	end)
end

function addon:UpdateStatWeights()
	CraftSimFRAME:ToggleFrames(true)
	local statWeights = CraftSimSTATS:getProfessionStatWeightsForCurrentRecipe()
	if statWeights == CraftSimCONST.ERROR.NO_PRICE_DATA or statWeights == CraftSimCONST.ERROR.NO_RECIPE_DATA then
		CraftSimFRAME:ToggleFrames(false)
	else
		CraftSimFRAME:UpdateStatWeightFrameText(statWeights)
	end
end

local priceApiLoaded = false
function addon:ADDON_LOADED(addon_name)
	if addon_name == 'CraftSim' then
		CraftSimFRAME:InitStatWeightFrame()
		CraftSimFRAME:InitGearSimFrame()
		addon:HookToEvent()
		addon:HookToDetailsHide()
		--print("load craftsim")
	end
	if not priceApiLoaded then
		if CraftSimPriceAPIs.DEBUG then
			CraftSimPriceAPI = CraftSimDEBUG_PRICE_API
			priceApiLoaded = true
			print("load debug prices")
		elseif CraftSimPriceAPIs:IsPriceApiAddonLoaded() or CraftSimPriceAPIs:IsAddonPriceApiAddon(addon_name) then
			--print("load price api")
			CraftSimPriceAPIs:InitAvailablePriceAPI()
			priceApiLoaded = true
		end
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
				--CraftSimUTIL:KethoEditBox_Show(CraftSimDATAEXPORT:getExportString())
				--KethoEditBoxEditBox:HighlightText()
				-- TODO: refactor to work with new recipeData format
			else
				print("CRAFTSIM ERROR: No Recipe Opened")
			end
		end
	end
end

