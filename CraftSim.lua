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

CraftSimOptions = CraftSimOptions or {
	priceDebug = false
}

local hookedToDetailsFrame = false
-- this should cover the case of switching to a frame that does not show the details like recrafting, from a frame that does
function addon:HookToDetailsHide()
	if hookedToDetailsFrame then
		return
	end
	hookedToDetailsFrame = true
	ProfessionsFrame.CraftingPage.SchematicForm.Details:HookScript("OnHide", function(self)
		addon:TriggerModulesByRecipeType()
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
		addon:TriggerModulesByRecipeType()
	end)
end

local priceApiLoaded = false
function addon:ADDON_LOADED(addon_name)
	if addon_name == 'CraftSim' then
		CraftSimFRAME:InitStatWeightFrame()
		CraftSimFRAME:InitGearSimFrame()
		CraftSimFRAME:InitPriceDataWarningFrame()
		CraftSimFRAME:InitBestAllocationsFrame()
		CraftSimFRAME:InitCostOverviewFrame()
		addon:HookToEvent()
		addon:HookToDetailsHide()
		--print("load craftsim")
	end
	if not priceApiLoaded then
		if CraftSimOptions.priceDebug then
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

		if command == "pricedebug" then
			CraftSimOptions.priceDebug = not CraftSimOptions.priceDebug
			print("Craftsim: Toggled price debug mode: " .. tostring(CraftSimOptions.priceDebug))

			if CraftSimOptions.priceDebug then
				CraftSimPriceAPI = CraftSimDEBUG_PRICE_API
			else
				CraftSimPriceAPIs:InitAvailablePriceAPI()
			end
		end

		if command == "convert" then
			CraftSimDATAEXPORT:ConvertData()
		end
	end
end

function addon:TriggerModulesByRecipeType()
    local professionInfo = ProfessionsFrame.professionInfo
	local professionFullName = professionInfo.professionName
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm
    local recipeInfo = schematicForm:GetRecipeInfo()


    if not string.find(professionFullName, "Dragon Isles") then -- TODO: factor in other localizations
		return
	end

    local recipeType = CraftSimUTIL:GetRecipeType(recipeInfo)
    --print("trigger by recipeType.. " .. tostring(recipeType))

	local recipeData = CraftSimDATAEXPORT:exportRecipeData()

	local priceData = CraftSimPRICEDATA:GetPriceData(recipeData, recipeType)
    -- when to see what?
    -- top gear: everything that is sellable!
    -- stat weights: everything that is sellable!
    -- Cost overview: crafting costs -> always!
    -- Cost overview: profit per quality -> everything that is sellable!
    -- Material allocation highest reachable quality with min costs -> always
    -- Material allocation most profitable allocation -> everything that is sellable

    local showMaterialAllocation = false
    local showStatweights = false
    local showTopGear = false
    local showCostOverview = false
    local showCostOverviewCraftingCostsOnly = false

    -- TODO: in specific situations, show some modules but hide the others..
    -- TODO: maybe use a switch here?
	if recipeData and priceData then
		if recipeType == CraftSimCONST.RECIPE_TYPES.GEAR or recipeType == CraftSimCONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSimCONST.RECIPE_TYPES.SINGLE then
			-- show everything
			showMaterialAllocation = true
			showTopGear = true
			showCostOverview = true
			showStatweights = true
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
			-- show everything except material allocation and total cost overview
			showTopGear = true
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
			showStatweights = true
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.SOULBOUND_GEAR or recipeType == CraftSimCONST.RECIPE_TYPES.NO_ITEM then
			-- show crafting costs and highest material allocation
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
			showMaterialAllocation = true
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
			-- show nothing
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.RECRAFT then
			-- show nothing? Depends..
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.GATHERING then
			-- show nothing maybe later some top gear for gathering
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_ITEM then
			-- show crafting costs
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
		end
	end

	showMaterialAllocation = showMaterialAllocation and recipeData.hasReagentsWithQuality
    CraftSimFRAME:ToggleFrame(CraftSimReagentHintFrame, showMaterialAllocation)
    if showMaterialAllocation then
        CraftSimREAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeType, priceData)
    end

    CraftSimFRAME:ToggleFrame(CraftSimDetailsFrame, showStatweights)
    if showStatweights then
        local statWeights = CraftSimSTATS:getProfessionStatWeightsForCurrentRecipe(recipeData, priceData)
        if statWeights ~= CraftSimCONST.ERROR.NO_PRICE_DATA then
            CraftSimFRAME:UpdateStatWeightFrameText(statWeights)
        end
    end

    CraftSimFRAME:ToggleFrame(CraftSimSimFrame, showTopGear)
    if showTopGear then
        CraftSimGEARSIM:SimulateBestProfessionGearCombination(recipeData, recipeType, priceData)
    end

    CraftSimFRAME:ToggleFrame(CraftSimCostOverviewFrame, showCostOverview)
    if showCostOverview then
        CraftSimCOSTS:CalculateCostOverview(recipeData, recipeType, priceData, showCostOverviewCraftingCostsOnly)
    end
end
