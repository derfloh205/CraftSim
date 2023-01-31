AddonName, CraftSim = ...

CraftSim.MAIN = CreateFrame("Frame", "CraftSimAddon")
CraftSim.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
CraftSim.MAIN:RegisterEvent("ADDON_LOADED")
CraftSim.MAIN:RegisterEvent("PLAYER_LOGIN")
CraftSim.MAIN:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

CraftSimOptions = CraftSimOptions or {
	priceDebug = false,
	priceSource = nil,
	tsmPriceKeyMaterials = "first(DBRecent, DBMinbuyout)",
	tsmPriceKeyItems = "first(DBRecent, DBMinbuyout)",
	topGearMode = "Top Profit",
	breakPointOffset = false,
	autoAssignVellum = false,
	showProfitPercentage = false,
	detailedCraftingInfoTooltip = true,
	syncTarget = nil,
	openLastRecipe = true,
	materialSuggestionInspirationThreshold = false,
	topGearAutoUpdate = false,

	-- modules
	modulesMaterials = true,
	modulesStatWeights = true,
	modulesTopGear = true,
	modulesCostOverview = true,
	modulesSpecInfo = true,
	modulesPriceOverride = false,
	modulesRecipeScan = false,
	modulesCraftResults = false,
	modulesCustomerService = false,

	transparencyMaterials = 1,
	transparencyStatWeights = 1,
	transparencyTopGear = 1,
	transparencyCostOverview = 1,
	transparencySpecInfo = 1,

	-- specData
	blacksmithingEnabled = false,
	alchemyEnabled = false,
	jewelcraftingEnabled = false,
	leatherworkingEnabled = false,

	-- recipeScan
	recipeScanIncludeSoulbound = false,
	recipeScanIncludeGear = false,
	recipeScanIncludeNotLearned = false,
	recipeScanOptimizeProfessionTools = false,

	-- profit calc

	-- customer service module
	customerServiceAutoReplyCommand = "!craft",
	customerServiceEnableAutoReply = false,
	customerServiceAutoReplyFormat =
			"Highest Result: %gc\n" ..
            "with Inspiration: %ic (%insp)\n" ..
            "Crafting Costs: %cc\n" ..
            "%ccd\n",

	customerServiceAllowAutoResult = true,
	customerServiceActivePreviewIDs = {},
}

CraftSimCollapsedFrames = CraftSimCollapsedFrames or {}

CraftSim.MAIN.currentRecipeData = nil
CraftSim.MAIN.currentRecipeID = nil

local function print(text, recursive) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.MAIN, recursive)
end

function CraftSim.MAIN:COMBAT_LOG_EVENT_UNFILTERED(event)
	local _, subEvent, _, _, sourceName = CombatLogGetCurrentEventInfo()
	if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REMOVED" then
		if ProfessionsFrame:IsVisible() then
			local playerName = UnitName("player")
			if sourceName == playerName then
				local auraID = select(12, CombatLogGetCurrentEventInfo())
				print("Buff changed: " .. tostring(auraID))
				if tContains(CraftSim.CONST.BUFF_IDS, auraID) then
					if CraftSim.MAIN.currentRecipeID then
						local isWorkOrder = ProfessionsFrame.OrdersPage:IsVisible()
						if isWorkOrder then
							CraftSim.MAIN:TriggerModulesErrorSafe(false, CraftSim.MAIN.currentRecipeID, CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
						else
							CraftSim.MAIN:TriggerModulesErrorSafe(false, CraftSim.MAIN.currentRecipeID, CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
						end
					end
				end
			end
		end
	end
end

function CraftSim.MAIN:handleCraftSimOptionsUpdates()
	if CraftSimOptions then
		CraftSimOptions.tsmPriceKey = nil
		CraftSimOptions.tsmPriceKeyMaterials = CraftSimOptions.tsmPriceKeyMaterials or CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION
		CraftSimOptions.tsmPriceKeyItems = CraftSimOptions.tsmPriceKeyItems or CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION
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
		CraftSimOptions.customerServiceActivePreviewIDs = CraftSimOptions.customerServiceActivePreviewIDs or {}
		CraftSimOptions.customerServiceAutoReplyCommand = CraftSimOptions.customerServiceAutoReplyCommand or "!craft"
		CraftSimOptions.customerServiceAutoReplyFormat = CraftSimOptions.customerServiceAutoReplyFormat or
																		("Highest Result: %gc\n" ..
																		"with Inspiration: %ic (%insp)\n" ..
																		"Crafting Costs: %cc\n" ..
																		"%ccd")
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
		if CraftSimOptions.customerServiceAllowAutoResult == nil then
			CraftSimOptions.customerServiceAllowAutoResult = true
		end
	end
end

local hookedEvent = false

local freshLoginRecall = true
function CraftSim.MAIN:TriggerModulesErrorSafe(isInit)

	if freshLoginRecall and isInit then
		freshLoginRecall = false
		-- hack to make frames appear after fresh login, when some info has not loaded yet although should have after blizzards' Init call
		C_Timer.After(0.1, function() 
			CraftSim.MAIN:TriggerModulesErrorSafe(true)
		end)
	end

	-- local success, errorMsg = pcall(CraftSim.MAIN.TriggerModulesByRecipeType, self, isInit)

	-- if not success then
	-- 	CraftSim.FRAME:ShowError(tostring(errorMsg), "CraftSim Error")
	-- 	print(CraftSim.UTIL:ColorizeText(tostring(errorMsg), CraftSim.CONST.COLORS.RED), CraftSim.CONST.DEBUG_IDS.ERROR)
	-- end
	CraftSim.UTIL:StartProfiling("MODULES UPDATE")
	CraftSim.MAIN:TriggerModulesByRecipeType(isInit)
	CraftSim.UTIL:StopProfiling("MODULES UPDATE")
end

function CraftSim.MAIN:HookToEvent()
	if hookedEvent then
		return
	end
	hookedEvent = true

	local function Update(self)
		if CraftSim.MAIN.currentRecipeID then
			print("Update: " .. tostring(CraftSim.MAIN.currentRecipeID))
			CraftSim.MAIN:TriggerModulesErrorSafe(false)
		end
	end

	
	local function Init(self, recipeInfo)
		if not self:IsVisible() then
			return
		end
		print("recipeinfo", false, true)
		print(recipeInfo)
		-- if init turn sim mode off
		if CraftSim.SIMULATION_MODE.isActive then
			CraftSim.SIMULATION_MODE.isActive = false
			CraftSim.SIMULATION_MODE.toggleButton:SetChecked(false)
		end
		
		if recipeInfo then
			print("Init: " .. tostring(recipeInfo.recipeID))
			CraftSim.MAIN.currentRecipeID = recipeInfo.recipeID
			CraftSim.MAIN:TriggerModulesErrorSafe(true)

			local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
			local professionRecipeIDs = CraftSim.CACHE:GetCacheEntryByVersion(CraftSimRecipeIDs, professionInfo.profession)
			if not professionRecipeIDs then
				-- TODO: put somewhere other than main
				local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
				-- filter out non dragonflight professions???
				if professionInfo.profession then
					CraftSim.CACHE:AddCacheEntryByVersion(CraftSimRecipeIDs, professionInfo.profession, recipeIDs)
				end
			end
		else
			--print("loading recipeInfo..")
		end
	end

	local hookFrame = ProfessionsFrame.CraftingPage.SchematicForm
	local hookFrame2 = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm
	hooksecurefunc(hookFrame, "Init", Init)
	hooksecurefunc(hookFrame2, "Init", Init)

	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, Update)
	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, Update)

	hookFrame2:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, Update)
	hookFrame2:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, Update)

	local recipeTab = ProfessionsFrame.TabSystem.tabs[1]
	local craftingOrderTab = ProfessionsFrame.TabSystem.tabs[3]

	recipeTab:HookScript("OnClick", Update)
	craftingOrderTab:HookScript("OnClick", Update)
	
end

function CraftSim.MAIN:InitStaticPopups()
	StaticPopupDialogs["CRAFT_SIM_ACCEPT_TOOLTIP_SYNC"] = {
        text = "Incoming Craft Sim Account Sync: Do you accept?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function(self, data1, data2)
            CraftSim.ACCOUNTSYNC:HandleIncomingSync(data1, data2)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
      }

	StaticPopupDialogs["CRAFT_SIM_ACCEPT_NO_PRICESOURCE_WARNING"] = {
	text = "Are you sure you do not want to be reminded to get a price source?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(self, data1, data2)
		CraftSimOptions.doNotRemindPriceSource = true
		CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.WARNING):Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
end

local priceApiLoaded = false
function CraftSim.MAIN:ADDON_LOADED(addon_name)
	if addon_name == AddonName then
		CraftSim.LOCAL:Init()
		CraftSim.MAIN:handleCraftSimOptionsUpdates()

		CraftSim.FRAME:InitDebugFrame()
		CraftSim.AVERAGEPROFIT.FRAMES:Init()
		CraftSim.AVERAGEPROFIT.FRAMES:InitExplanation()
		CraftSim.TOPGEAR.FRAMES:Init()
		CraftSim.COSTOVERVIEW.FRAMES:Init()
		CraftSim.REAGENT_OPTIMIZATION.FRAMES:Init()
		CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
		CraftSim.FRAME:InitWarningFrame()
		CraftSim.FRAME:InitOneTimeNoteFrame()
		CraftSim.SIMULATION_MODE.FRAMES:Init()
		CraftSim.SIMULATION_MODE.FRAMES:InitSpecModifier()
		CraftSim.PRICE_OVERRIDE.FRAMES:Init()
		CraftSim.RECIPE_SCAN.FRAMES:Init()
		CraftSim.CRAFT_RESULTS.FRAMES:Init()
		CraftSim.STATISTICS.FRAMES:Init()
		CraftSim.CUSTOMER_SERVICE.FRAMES:Init()
		CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreview()

		CraftSim.TOOLTIP:Init()
		CraftSim.MAIN:HookToEvent()
		CraftSim.MAIN:HookToProfessionsFrame()
		CraftSim.FRAME:HandleAuctionatorOverlaps()
		CraftSim.MAIN:HandleAuctionatorHooks()
		CraftSim.ACCOUNTSYNC:Init()
		

		CraftSim.CONTROL_PANEL.FRAMES:Init()
		CraftSim.MAIN:InitStaticPopups()

		CraftSim.CUSTOMER_SERVICE:Init()
	end
end

function CraftSim.MAIN:HandleAuctionatorHooks()
---@diagnostic disable-next-line: undefined-global
	if Auctionator then
		Auctionator.API.v1.RegisterForDBUpdate(AddonName, function() 
			print("Auctionator DB Update")
			CraftSim.MAIN:TriggerModulesErrorSafe(false)
		end)
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
	if profession and recipeInfo then
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
		elseif command == "export" then
			local exportString = CraftSim.DATAEXPORT:GetExportString()
			CraftSim.UTIL:KethoEditBox_Show(exportString)
		else 
			-- open options if any other command or no command is given
			InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
		end
	end

	CraftSim.PRICE_API:InitPriceSource()
	CraftSim.OPTIONS:Init()
	CraftSim.MAIN:HandleCollapsedFrameSave()

	-- show one time note
	CraftSim.FRAME:ShowOneTimeInfo()
end

local debugTest = true
function CraftSim.MAIN:TriggerModulesByRecipeType(isInit)
	if not ProfessionsFrame:IsVisible() then
		return
	end

	local controlPanel = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CONTROL_PANEL)
	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		-- hide control panel and return
		controlPanel:Hide()
		return nil
	end

	controlPanel:Show()

    local recipeInfo =  C_TradeSkillUI.GetRecipeInfo(CraftSim.MAIN.currentRecipeID)

	if not recipeInfo then
		--print("no recipeInfo found.. try again soon?")
		return
	end

	local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

	print("Export Mode: " .. tostring(exportMode))

	local recipeData = nil 
	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		recipeData = CraftSim.SIMULATION_MODE.recipeData
		CraftSim.MAIN.currentRecipeData = CraftSim.SIMULATION_MODE.recipeData
	else
		recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeInfo.recipeID, exportMode)
	end

	if debugTest then
		recipeData = nil
		debugTest = false
	end

	local recipeType = recipeData and recipeData.recipeType
    --print("trigger by recipeType.. " .. tostring(recipeType))

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
	local showSimulationMode = false
	local showSpecInfo = false
	local showPriceOverride = false
	
	-- always on modules
	local showCraftResults = true
	local showRecipeScan = true
	local showCustomerService = true

	if recipeData and priceData then
		--CraftSim.DATAEXPORT:UpdateTooltipData(recipeData)
		-- TODO: on demand

		if recipeData.isRecraft then
			-- show everything
			showMaterialAllocation = true
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
			showPriceOverride = true
			showCraftResults = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.SINGLE then
			-- show everything
			showMaterialAllocation = true
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
			showPriceOverride = true
			showCraftResults = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.ENCHANT then
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
			showPriceOverride = true
			showCraftResults = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
			-- show everything except material allocation and total cost overview
			showTopGear = true
			showCostOverview = true
			showStatweights = true
			showSimulationMode = true
			showSpecInfo = true
			showPriceOverride = true
			showCraftResults = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_ITEM then
			-- show crafting costs and highest material allocation
			showCostOverview = true
			showMaterialAllocation = true
			-- also show top gear cause we have different modes now
			showTopGear = true
			showSimulationMode = true
			showSpecInfo = true
			showStatweights = true
			showPriceOverride = true
			showCraftResults = true
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
			-- show nothing
		elseif recipeType == CraftSim.CONST.RECIPE_TYPES.GATHERING then
			-- show nothing maybe later some top gear for gathering
		end
	end

	showMaterialAllocation = showMaterialAllocation and CraftSimOptions.modulesMaterials 
	-- temporary disable for recipes with only one required qualitity reagent
	--showMaterialAllocation = showMaterialAllocation and recipeData and recipeData.numReagentsWithQuality > 1
	showStatweights = showStatweights and CraftSimOptions.modulesStatWeights
	showTopGear = showTopGear and CraftSimOptions.modulesTopGear
	showCostOverview = showCostOverview and CraftSimOptions.modulesCostOverview
	showSpecInfo = showSpecInfo and CraftSimOptions.modulesSpecInfo
	showPriceOverride = showPriceOverride and CraftSimOptions.modulesPriceOverride
	showRecipeScan = showRecipeScan and CraftSimOptions.modulesRecipeScan
	showCraftResults = showCraftResults and CraftSimOptions.modulesCraftResults
	showCustomerService = showCustomerService and CraftSimOptions.modulesCustomerService
	
	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.RECIPE_SCAN), showRecipeScan)
	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS), showCraftResults)
	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CUSTOMER_SERVICE), showCustomerService)

	if recipeData and showCraftResults then
		CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeData.recipeID)
	end

	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE), showPriceOverride and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER), showPriceOverride and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showPriceOverride then
		CraftSim.PRICE_OVERRIDE.FRAMES:UpdateFrames(recipeData, exportMode)
	end

	if recipeData and recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_ITEM and recipeType ~= CraftSim.CONST.RECIPE_TYPES.GATHERING and recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
		CraftSim.FRAME:UpdateStatDetailsByExtraItemFactors(recipeData)
	end

	CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO), showSpecInfo and recipeData and recipeData.specNodeData)
	if recipeData and showSpecInfo and recipeData.specNodeData then
		CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
	end

	-- do not show simulation possibility on salvaging for now
	showSimulationMode = showSimulationMode and recipeData and not recipeData.isSalvageRecipe
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.toggleButton, showSimulationMode)
	CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility() -- show sim mode frames depending if active or not
	if CraftSim.SIMULATION_MODE.isActive and recipeData then -- recipeData could still be nil here if e.g. in a gathering recipe
		-- update simulationframe recipedata by inputs and the frontend
		-- since recipeData is a reference here to the recipeData in the simulationmode, 
		-- the recipeData that is used in the below modules should also be the modified one!
		CraftSim.SIMULATION_MODE:UpdateSimulationMode()
	end

	showMaterialAllocation = showMaterialAllocation and recipeData.hasReagentsWithQuality
	local materialOptimizationFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.MATERIALS)
	local materialOptimizationWOFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(materialOptimizationFrame, showMaterialAllocation and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(materialOptimizationWOFrame, showMaterialAllocation and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if showMaterialAllocation then
		CraftSim.UTIL:StartProfiling("Reagent Optimization")
		CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeType, priceData, exportMode)
		CraftSim.UTIL:StopProfiling("Reagent Optimization")
	end

	CraftSim.FRAME:ToggleFrame(CraftSimDetailsFrame, showStatweights and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSimDetailsWOFrame, showStatweights and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if showStatweights then
		local statWeights = CraftSim.AVERAGEPROFIT:getProfessionStatWeightsForCurrentRecipe(recipeData, priceData, exportMode)
		if statWeights ~= CraftSim.CONST.ERROR.NO_PRICE_DATA then
			CraftSim.AVERAGEPROFIT.FRAMES:UpdateAverageProfitDisplay(priceData, statWeights, exportMode)
			CraftSim.STATISTICS.FRAMES:UpdateStatistics(recipeData, priceData)
		end
	end

	CraftSim.FRAME:ToggleFrame(CraftSimSimFrame, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSimSimWOFrame, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showTopGear then
		CraftSim.TOPGEAR.FRAMES:UpdateModeDropdown(exportMode)
		if CraftSimOptions.topGearAutoUpdate then
			CraftSim.UTIL:StartProfiling("Top Gear")
			CraftSim.TOPGEAR:SimulateBestProfessionGearCombination(recipeData, recipeData.recipeType, priceData, exportMode)
			CraftSim.UTIL:StopProfiling("Top Gear")
		else
			local isCooking = recipeData.professionID == Enum.Profession.Cooking
			CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(isCooking, true, exportMode)
		end
	end

	CraftSim.FRAME:ToggleFrame(CraftSimCostOverviewFrame, showCostOverview and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSimCostOverviewWOFrame, showCostOverview and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if showCostOverview then
		CraftSim.COSTOVERVIEW:CalculateCostOverview(recipeData, recipeType, priceData, false, exportMode)
	end
end
