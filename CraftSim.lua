-- TODO: Localization Differences?
-- TODO: error message when no price source is available! Like show the window but with error message
-- TODO: error message when no full price data is available
-- TODO: more error handling
-- TODO: ignore gathering recipes
-- TODO: FEATURE(?): when not full price data is available, assume/extrapolate prices based on basePrice and quality ? but inform user, maybe even on demand with button
-- TODO: FEATURE: suggest or even auto equip most profitable profession gear combo for recipe (maybe on button click?)
-- TODO: FEATURE: integrate knapsack problem to solve best reagent configuration

CraftSimMAIN = CreateFrame("Frame", "CraftSimAddon")
CraftSimMAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
CraftSimMAIN:RegisterEvent("ADDON_LOADED")
CraftSimMAIN:RegisterEvent("PLAYER_LOGIN")

CraftSimOptions = CraftSimOptions or {
	priceDebug = false,
	priceSource = nil,
	tsmPriceKeyMaterials = "DBMinbuyout",
	tsmPriceKeyItems = "DBMinbuyout",
	topGearMode = "Top Profit",
	breakPointOffset = false,
	autoAssignVellum = false,
	showProfitPercentage = false,
	detailedCraftingInfoTooltip = true,
	syncTarget = nil,
	openLastRecipe = true,
	materialSuggestionInspirationThreshold = false,
	modulesMaterials = true,
	modulesStatWeights = true,
	modulesTopGear = true,
	modulesCostOverview = true,
	transparencyMaterials = 1,
	transparencyStatWeights = 1,
	transparencyTopGear = 1,
	transparencyCostOverview = 1
}

CraftSimCollapsedFrames = CraftSimCollapsedFrames or {}

CraftSimMAIN.currentRecipeInfo = nil
CraftSimMAIN.currentRecipeData = nil

function CraftSimMAIN:handleCraftSimOptionsUpdates()
	if CraftSimOptions then
		CraftSimOptions.tsmPriceKey = nil
		CraftSimOptions.tsmPriceKeyMaterials = CraftSimOptions.tsmPriceKeyMaterials or "DBRecent"
		CraftSimOptions.tsmPriceKeyItems = CraftSimOptions.tsmPriceKeyItems or "DBMinbuyout"
		CraftSimOptions.topGearMode = CraftSimOptions.topGearMode or "Top Profit"
		CraftSimOptions.breakPointOffset = CraftSimOptions.breakPointOffset or false
		CraftSimOptions.autoAssignVellum = CraftSimOptions.autoAssignVellum or false
		CraftSimOptions.showProfitPercentage = CraftSimOptions.showProfitPercentage or false
		CraftSimOptions.materialSuggestionInspirationThreshold = CraftSimOptions.materialSuggestionInspirationThreshold or false
		CraftSimOptions.transparencyMaterials = CraftSimOptions.transparencyMaterials or 1
		CraftSimOptions.transparencyStatWeights = CraftSimOptions.transparencyStatWeights or 1
		CraftSimOptions.transparencyTopGear = CraftSimOptions.transparencyTopGear or 1
		CraftSimOptions.transparencyCostOverview = CraftSimOptions.transparencyCostOverview or 1
		if CraftSimOptions.detailedCraftingInfoTooltip == nil then
			CraftSimOptions.detailedCraftingInfoTooltip = true
		end
		if CraftSimOptions.openLastRecipe == nil then
			CraftSimOptions.openLastRecipe = true
		end
		if CraftSimOptions.modulesMaterials == nil then
			CraftSimOptions.modulesMaterials = true
		end
		if CraftSimOptions.modulesStatWeights == nil then
			CraftSimOptions.modulesStatWeights = true
		end
		if CraftSimOptions.modulesTopGear == nil then
			CraftSimOptions.modulesTopGear = true
		end
		if CraftSimOptions.modulesCostOverview == nil then
			CraftSimOptions.modulesCostOverview = true
		end
	end
end

local hookedToDetailsFrame = false
-- this should cover the case of switching to a frame that does not show the details like recrafting, from a frame that does
function CraftSimMAIN:HookToDetailsHide()
	if hookedToDetailsFrame then
		return
	end
	hookedToDetailsFrame = true
	ProfessionsFrame.CraftingPage.SchematicForm.Details:HookScript("OnHide", function(self)
		CraftSimMAIN:TriggerModulesByRecipeType()
	end)
end

local hookedEvent = false

function CraftSimMAIN:HookToEvent()
	if hookedEvent then
		return
	end
	hookedEvent = true

	local function Update(self)
		--print("updating..")
		CraftSimMAIN:TriggerModulesByRecipeType(false)
	end

	local function Init(self, recipeInfo)
		CraftSimMAIN.currentRecipeInfo = recipeInfo
		if recipeInfo then
			--print("got recipeInfo")
			CraftSimMAIN:TriggerModulesByRecipeType(true)
		else
			--print("loading recipeInfo..")
		end
	end

	local hookFrame = ProfessionsFrame.CraftingPage.SchematicForm
	hooksecurefunc(hookFrame, "Init", Init)

	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, Update)
	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, Update)
end

local priceApiLoaded = false
function CraftSimMAIN:ADDON_LOADED(addon_name)
	if addon_name == 'CraftSim' then
		CraftSimLOC:Init()

		CraftSimFRAME:InitStatWeightFrame()
		CraftSimFRAME:InitGearSimFrame()
		CraftSimFRAME:InitPriceDataWarningFrame()
		CraftSimFRAME:InitCostOverviewFrame()
		CraftSimFRAME:InitBestAllocationsFrame()
		CraftSimFRAME:InitProfitDetailsFrame()
		CraftSimSIMULATION_MODE:Init()
		CraftSimTOOLTIP:Init()
		CraftSimMAIN:HookToEvent()
		--CraftSimMAIN:HookToDetailsHide()
		CraftSimMAIN:handleCraftSimOptionsUpdates()
		CraftSimMAIN:HookToProfessionsFrame()
		CraftSimFRAME:HandleAuctionatorOverlaps()
		CraftSimAccountSync:Init()
	end
end

function CraftSimMAIN:HandleCollapsedFrameSave()
	if CraftSimCollapsedFrames[CraftSimCONST.FRAMES.MATERIALS] then
		CraftSimReagentHintFrame.collapse()
	end
	if CraftSimCollapsedFrames[CraftSimCONST.FRAMES.TOP_GEAR] then
		CraftSimSimFrame.collapse()
	end
	if CraftSimCollapsedFrames[CraftSimCONST.FRAMES.COST_OVERVIEW] then
		CraftSimCostOverviewFrame.collapse()
	end
	if CraftSimCollapsedFrames[CraftSimCONST.FRAMES.STAT_WEIGHTS] then
		CraftSimDetailsFrame.collapse()
	end
end

local professionFrameHooked = false
function CraftSimMAIN:HookToProfessionsFrame()
	if professionFrameHooked then
		return
	end
	professionFrameHooked = true

	ProfessionsFrame:HookScript("OnShow", 
   function()
		if CraftSimOptions.openLastRecipe then
			C_Timer.After(1, function() 
				local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
				local professionInfo = ProfessionsFrame:GetProfessionInfo()
				local professionFullName = professionInfo.professionName
				local profession = professionInfo.parentProfessionName
				if CraftSimOPTIONS.lastOpenRecipeID[profession] then
					C_TradeSkillUI.OpenRecipe(CraftSimOPTIONS.lastOpenRecipeID[profession])
				end
			end)
		end
   end)

   ProfessionsFrame.CraftingPage:HookScript("OnHide", 
   function()
	local professionInfo = ProfessionsFrame:GetProfessionInfo()
	local profession = professionInfo.parentProfessionName
	local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
	if profession then
		CraftSimOPTIONS.lastOpenRecipeID[profession] = recipeInfo.recipeID
	end
   end)
end

function CraftSimMAIN:PLAYER_LOGIN()
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

	CraftSimPriceAPI:InitPriceSource()
	CraftSimOPTIONS:InitOptionsFrame()
	CraftSimMAIN:HandleCollapsedFrameSave()
end

function CraftSimMAIN:TriggerModulesByRecipeType(isInit)
	if CraftSimREAGENT_OPTIMIZATION.TriggeredByVellumUpdate then
		CraftSimREAGENT_OPTIMIZATION.TriggeredByVellumUpdate = false
		return
	end

    local professionInfo = ProfessionsFrame.professionInfo
	local professionFullName = professionInfo.professionName
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm
    local recipeInfo = CraftSimMAIN.currentRecipeInfo or schematicForm:GetRecipeInfo()

	if not recipeInfo then
		print("no recipeInfo found.. try again soon?")
		return
	end

    if not string.find(professionFullName, "Dragon Isles") then -- TODO: factor in other localizations
		return
	end

    local recipeType = CraftSimUTIL:GetRecipeType(recipeInfo)
    --print("trigger by recipeType.. " .. tostring(recipeType))

	-- if init or recraft, turn sim mode off
	if isInit or recipeType == CraftSimCONST.RECIPE_TYPES.RECRAFT then
		CraftSimSIMULATION_MODE.isActive = false
		CraftSimSimModeToggleButton:SetText("Simulation Mode: Off")
	end

	local recipeData = nil 
	if CraftSimSIMULATION_MODE.isActive and CraftSimSIMULATION_MODE.recipeData then
		recipeData = CraftSimSIMULATION_MODE.recipeData
		CraftSimMAIN.currentRecipeData = CraftSimSIMULATION_MODE.recipeData
	else
		recipeData = CraftSimDATAEXPORT:exportRecipeData()
	end

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
	local showSimulationMode = false

	if recipeData and priceData then
		CraftSimDATAEXPORT:UpdateTooltipData(recipeData)
		CraftSimFRAME:UpdateStatDetailsByExtraItemFactors(recipeData)

		if recipeType == CraftSimCONST.RECIPE_TYPES.GEAR or recipeType == CraftSimCONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSimCONST.RECIPE_TYPES.SINGLE then
			-- show everything
			showMaterialAllocation = true
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.ENCHANT then
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true

			if CraftSimOptions.autoAssignVellum then
				CraftSimREAGENT_OPTIMIZATION:AutoAssignVellum(recipeData)
			end
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
			-- show everything except material allocation and total cost overview
			showTopGear = true
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
			showStatweights = true
			showSimulationMode = true
		elseif recipeType == CraftSimCONST.RECIPE_TYPES.SOULBOUND_GEAR or recipeType == CraftSimCONST.RECIPE_TYPES.NO_ITEM then
			-- show crafting costs and highest material allocation
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
			showMaterialAllocation = true
			-- also show top gear cause we have different modes now
			showTopGear = true
			showSimulationMode = true
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

	local showMaterialAllocation = showMaterialAllocation and CraftSimOptions.modulesMaterials
    local showStatweights = showStatweights and CraftSimOptions.modulesStatWeights
    local showTopGear = showTopGear and CraftSimOptions.modulesTopGear
    local showCostOverview = showCostOverview and CraftSimOptions.modulesCostOverview

	CraftSimFRAME:ToggleFrame(CraftSimSimModeToggleButton, showSimulationMode)
	CraftSimFRAME:ToggleSimModeFrames() -- show sim mode frames depending if active or not
	if CraftSimSIMULATION_MODE.isActive then
		-- update simulationframe recipedata by inputs and the frontend
		-- since recipeData is a reference here to the recipeData in the simulationmode, 
		-- the recipeData that is used in the below modules should also be the modified one!
		CraftSimSIMULATION_MODE:UpdateSimulationMode()
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
            CraftSimFRAME:UpdateStatWeightFrameText(priceData, statWeights)
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
