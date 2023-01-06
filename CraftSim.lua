addonName, CraftSim = ...

CraftSim.MAIN = CreateFrame("Frame", "CraftSimAddon")
CraftSim.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
CraftSim.MAIN:RegisterEvent("ADDON_LOADED")
CraftSim.MAIN:RegisterEvent("PLAYER_LOGIN")

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
	modulesSpecInfo = true,
	transparencyMaterials = 1,
	transparencyStatWeights = 1,
	transparencyTopGear = 1,
	transparencyCostOverview = 1,
	transparencySpecInfo = 1,

	-- specData Refactor
	blacksmithingEnabled = true,
	alchemyEnabled = true,
}

CraftSimCollapsedFrames = CraftSimCollapsedFrames or {}

CraftSim.MAIN.currentRecipeInfo = nil
CraftSim.MAIN.currentRecipeData = nil

local function print(text, recursive) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.MAIN, recursive)
end

function CraftSim.MAIN:handleCraftSimOptionsUpdates()
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
		CraftSimOptions.transparencySpecInfo = CraftSimOptions.transparencySpecInfo or 1
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
		if CraftSimOptions.modulesSpecInfo == nil then
			CraftSimOptions.modulesSpecInfo = true
		end
		if CraftSimOptions.blacksmithingEnabled == nil then
			CraftSimOptions.blacksmithingEnabled = true
		end
		if CraftSimOptions.alchemyEnabled == nil then
			CraftSimOptions.alchemyEnabled = true
		end
	end
end

local hookedEvent = false

-- CraftSim.MAIN.ErrorHandler = function(errorMsg)
-- 	local log = tostring(errorMsg) .. "callStack: " .. debugstack(2, 3, 2)
-- 	CraftSim.FRAME:ShowError(log, "CraftSim Error")
-- 	print(CraftSim.UTIL:ColorizeText(log, CraftSim.CONST.COLORS.RED), CraftSim.CONST.DEBUG_IDS.ERROR)
-- end

function CraftSim.MAIN:TriggerModulesErrorSafe(isInit)
	local success, errorMsg = pcall(CraftSim.MAIN.TriggerModulesByRecipeType, self, isInit)

	if not success then
		CraftSim.FRAME:ShowError(tostring(errorMsg), "CraftSim Error")
		print(CraftSim.UTIL:ColorizeText(tostring(errorMsg), CraftSim.CONST.COLORS.RED), CraftSim.CONST.DEBUG_IDS.ERROR)
	end
end

function CraftSim.MAIN:HookToEvent()
	if hookedEvent then
		return
	end
	hookedEvent = true

	local function Update(self)
		CraftSim.MAIN:TriggerModulesErrorSafe(false)
	end

	local function Init(self, recipeInfo)
		CraftSim.MAIN.currentRecipeInfo = recipeInfo
		
		if recipeInfo then
			CraftSim.MAIN:TriggerModulesErrorSafe(true)
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
function CraftSim.MAIN:ADDON_LOADED(addon_name)
	if addon_name == addonName then
		CraftSim.LOCAL:Init()

		CraftSim.FRAME:InitStatWeightFrame()
		CraftSim.FRAME:InitGearSimFrame()
		CraftSim.FRAME:InitCostOverviewFrame()
		CraftSim.FRAME:InitBestAllocationsFrame()
		CraftSim.FRAME:InitProfitDetailsFrame()
		CraftSim.FRAME:InitSpecInfoFrame()
		CraftSim.FRAME:InitWarningFrame()
		CraftSim.FRAME:InitOneTimeNoteFrame()
		CraftSim.FRAME:InitDebugFrame()
		CraftSim.SIMULATION_MODE:Init()
		CraftSim.TOOLTIP:Init()
		CraftSim.MAIN:HookToEvent()
		CraftSim.MAIN:handleCraftSimOptionsUpdates()
		CraftSim.MAIN:HookToProfessionsFrame()
		CraftSim.FRAME:HandleAuctionatorOverlaps()
		CraftSim.ACCOUNTSYNC:Init()
	end
end

function CraftSim.MAIN:HandleCollapsedFrameSave()
	for _, frameID in pairs(CraftSim.CONST.FRAMES) do
		if CraftSimCollapsedFrames[frameID] then
			local frame = CraftSim.FRAME:GetFrame(frameID)
			frame.collapse(frame)
		end
	end
end

local professionFrameHooked = false
function CraftSim.MAIN:HookToProfessionsFrame()
	if professionFrameHooked then
		return
	end
	professionFrameHooked = true

	ProfessionsFrame:HookScript("OnShow", 
   function()
		CraftSim.MAIN.lastRecipeID = nil
		if CraftSimOptions.openLastRecipe then
			C_Timer.After(1, function() 
				local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
				local professionInfo = ProfessionsFrame:GetProfessionInfo()
				local professionFullName = professionInfo.professionName
				local profession = professionInfo.parentProfessionName
				if CraftSim.OPTIONS.lastOpenRecipeID[profession] then
					C_TradeSkillUI.OpenRecipe(CraftSim.OPTIONS.lastOpenRecipeID[profession])
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
		CraftSim.OPTIONS.lastOpenRecipeID[profession] = recipeInfo.recipeID
	end
   end)
end

function CraftSim.MAIN:PLAYER_LOGIN()
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

		if command == "pricedebug" then
			CraftSimOptions.priceDebug = not CraftSimOptions.priceDebug
			print("Craftsim: Toggled price debug mode: " .. tostring(CraftSimOptions.priceDebug))

			if CraftSimOptions.priceDebug then
				CraftSim.PRICE_API = CraftSimDEBUG_PRICE_API
			else
				CraftSim.PRICE_APIS:InitAvailablePriceAPI()
			end
		elseif command == "news" then
			CraftSim.FRAME:ShowOneTimeInfo(true)
		elseif command == "debug" then
			CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG):Show()
		else 
			-- open options if any other command or no command is given
			InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
		end
	end

	CraftSim.PRICE_API:InitPriceSource()
	CraftSim.OPTIONS:InitOptionsFrame()
	CraftSim.MAIN:HandleCollapsedFrameSave()

	-- show one time note
	CraftSim.FRAME:ShowOneTimeInfo()
end

local debugTest = true
function CraftSim.MAIN:TriggerModulesByRecipeType(isInit)
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
	local expansionName = professionInfo.expansionName
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm

	if not expansionName == "Dragon Isles" then
		return nil
	end

	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() then
		return nil
	end

	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm
    local recipeInfo = CraftSim.MAIN.currentRecipeInfo or schematicForm:GetRecipeInfo()

	if not recipeInfo then
		--print("no recipeInfo found.. try again soon?")
		return
	end

    local recipeType = CraftSim.UTIL:GetRecipeType(recipeInfo)
    --print("trigger by recipeType.. " .. tostring(recipeType))

	-- if init or recraft, turn sim mode off
	if isInit or recipeType == CraftSim.CONST.RECIPE_TYPES.RECRAFT then
		CraftSim.SIMULATION_MODE.isActive = false
		CraftSim.SIMULATION_MODE.toggleButton:SetChecked(false)
	end

	local recipeData = nil 
	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		recipeData = CraftSim.SIMULATION_MODE.recipeData
		CraftSim.MAIN.currentRecipeData = CraftSim.SIMULATION_MODE.recipeData
	else
		recipeData = CraftSim.DATAEXPORT:exportRecipeData()
	end

	if debugTest then
		recipeData = nil
		debugTest = false
	end

	local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeType)
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
	local showSpecInfo = false

	if recipeData and priceData then
		CraftSim.DATAEXPORT:UpdateTooltipData(recipeData)

		if recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.SINGLE then
			-- show everything
			showMaterialAllocation = true
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.ENCHANT then
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
			-- show everything except material allocation and total cost overview
			showTopGear = true
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_ITEM then
			-- show crafting costs and highest material allocation
			showCostOverview = true
			showCostOverviewCraftingCostsOnly = true
			showMaterialAllocation = true
			-- also show top gear cause we have different modes now
			showTopGear = true
			showSimulationMode = true
			showSpecInfo = true
			-- show for override usages
			showStatweights = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
			-- show nothing
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.RECRAFT then
			-- show nothing? Depends..
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.GATHERING then
			-- show nothing maybe later some top gear for gathering
		end
	end

	showMaterialAllocation = showMaterialAllocation and CraftSimOptions.modulesMaterials 
	-- temporary disable for recipes with only one required qualitity reagent
	showMaterialAllocation = showMaterialAllocation and recipeData and recipeData.numReagentsWithQuality > 1
	showStatweights = showStatweights and CraftSimOptions.modulesStatWeights
	showTopGear = showTopGear and CraftSimOptions.modulesTopGear
	showCostOverview = showCostOverview and CraftSimOptions.modulesCostOverview
	showSpecInfo = showSpecInfo and CraftSimOptions.modulesSpecInfo and recipeData and recipeData.specNodeData

	if recipeData and recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_ITEM and recipeType ~= CraftSim.CONST.RECIPE_TYPES.GATHERING and recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION and recipeType ~= CraftSim.CONST.RECIPE_TYPES.RECRAFT then
		CraftSim.FRAME:UpdateStatDetailsByExtraItemFactors(recipeData)
	end

	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO), showSpecInfo)
	if recipeData and showSpecInfo then
		CraftSim.FRAME:FillSpecInfoFrame(recipeData)
	end

	-- do not show simulation possibility on salvaging for now
	showSimulationMode = showSimulationMode and recipeData and not recipeData.isSalvageRecipe
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.toggleButton, showSimulationMode)
	CraftSim.FRAME:ToggleSimModeFrames() -- show sim mode frames depending if active or not
	if CraftSim.SIMULATION_MODE.isActive and recipeData then -- recipeData could still be nil here if e.g. in a gathering recipe
		-- update simulationframe recipedata by inputs and the frontend
		-- since recipeData is a reference here to the recipeData in the simulationmode, 
		-- the recipeData that is used in the below modules should also be the modified one!
		CraftSim.SIMULATION_MODE:UpdateSimulationMode()
	end

	showMaterialAllocation = showMaterialAllocation and recipeData.hasReagentsWithQuality
	CraftSim.FRAME:ToggleFrame(CraftSimReagentHintFrame, showMaterialAllocation)
	if showMaterialAllocation then
		CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeType, priceData)
	end

	CraftSim.FRAME:ToggleFrame(CraftSimDetailsFrame, showStatweights)
	if showStatweights then
		local statWeights = CraftSim.STATS:getProfessionStatWeightsForCurrentRecipe(recipeData, priceData)
		if statWeights ~= CraftSim.CONST.ERROR.NO_PRICE_DATA then
			CraftSim.FRAME:UpdateStatWeightFrameText(priceData, statWeights)
		end
	end

	CraftSim.FRAME:ToggleFrame(CraftSimSimFrame, showTopGear)
	if showTopGear then
		CraftSim.GEARSIM:SimulateBestProfessionGearCombination(recipeData, recipeType, priceData)
	end

	CraftSim.FRAME:ToggleFrame(CraftSimCostOverviewFrame, showCostOverview)
	if showCostOverview then
		CraftSim.COSTOVERVIEW:CalculateCostOverview(recipeData, recipeType, priceData, false )--showCostOverviewCraftingCostsOnly)
	end
end
