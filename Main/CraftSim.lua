CraftSimAddonName, CraftSim = ...

CraftSim.MAIN = CreateFrame("Frame", "CraftSimAddon")
CraftSim.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
CraftSim.MAIN:RegisterEvent("ADDON_LOADED")
CraftSim.MAIN:RegisterEvent("PLAYER_LOGIN")
CraftSim.MAIN:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
CraftSim.MAIN:RegisterEvent("PLAYER_ENTERING_WORLD")

CraftSim.MAIN.FRAMES = {}

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
	optionsShowNews = true,

	-- modules
	modulesMaterials = true,
	modulesStatWeights = true,
	modulesTopGear = true,
	modulesPriceDetails = true,
	modulesSpecInfo = true,
	modulesPriceOverride = false,
	modulesRecipeScan = false,
	modulesCraftResults = false,
	modulesCustomerService = false,
	modulesCustomerHistory = false,
	modulesCostDetails = false,

	transparencyMaterials = 1,
	transparencyStatWeights = 1,
	transparencyTopGear = 1,
	transparencyCostOverview = 1,
	transparencySpecInfo = 1,
	maxHistoryEntriesPerClient = 200,

	-- recipeScan
	recipeScanIncludeSoulbound = false,
	recipeScanIncludeGear = false,
	recipeScanIncludeNotLearned = false,
	recipeScanOptimizeProfessionTools = false,

	-- profit calc
	customMulticraftConstant = CraftSim.CONST.MULTICRAFT_CONSTANT,

	-- customer service module
	customerServiceRecipeWhisperFormat =
			"Highest Result: %gc\n" ..
            "with Inspiration: %ic (%insp)\n" ..
            "Crafting Costs: %cc\n" ..
            "%ccd\n",

	customerServiceAllowAutoResult = true,
	customerServiceActivePreviewIDs = {},

	-- crafting options
	craftGarbageCollectEnabled = true,
	craftGarbageCollectCrafts = 500,
}

CraftSimGGUIConfig = CraftSimGGUIConfig or {}

---@type CraftSim.RecipeData?
CraftSim.MAIN.currentRecipeData = nil
---@type number?
CraftSim.MAIN.currentRecipeID = nil
CraftSim.MAIN.initialLogin = false
CraftSim.MAIN.isReloadingUI = false

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.MAIN)
function CraftSim.MAIN:PLAYER_ENTERING_WORLD(initialLogin, isReloadingUI)
	CraftSim.MAIN.initialLogin = initialLogin
	CraftSim.MAIN.isReloadingUI = isReloadingUI

	-- for any processes that may only happen once a session e.g.
	if initialLogin then
		-- Clear Preview IDs upon fresh session
		CraftSim.CUSTOMER_SERVICE:ClearPreviewIDs()
	end
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
		CraftSimOptions.maxHistoryEntriesPerClient = CraftSimOptions.maxHistoryEntriesPerClient or 200
		CraftSimOptions.customerServiceActivePreviewIDs = CraftSimOptions.customerServiceActivePreviewIDs or {}
		CraftSimOptions.customerServiceRecipeWhisperFormat = CraftSimOptions.customerServiceRecipeWhisperFormat or
		("Highest Result: %gc\n" ..
		"with Inspiration: %ic (%insp)\n" ..
		"Crafting Costs: %cc\n" ..
		"%ccd")
		CraftSimOptions.craftGarbageCollectCrafts = CraftSimOptions.craftGarbageCollectCrafts or 500
		CraftSimOptions.customMulticraftConstant = CraftSimOptions.customMulticraftConstant or CraftSim.CONST.MULTICRAFT_CONSTANT
		CraftSimOptions.customResourcefulnessConstant = CraftSimOptions.customResourcefulnessConstant or CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR
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
		if CraftSimOptions.modulesPriceDetails == nil then
			CraftSimOptions.modulesPriceDetails = true
		end
		if CraftSimOptions.modulesSpecInfo == nil then
			CraftSimOptions.modulesSpecInfo = true
		end
		if CraftSimOptions.customerServiceAllowAutoResult == nil then
			CraftSimOptions.customerServiceAllowAutoResult = true
		end
		if CraftSimOptions.craftGarbageCollectEnabled == nil then
			CraftSimOptions.craftGarbageCollectEnabled = true
		end
		if CraftSimOptions.optionsShowNews == nil then
			CraftSimOptions.optionsShowNews = true
		end
	end
end

local hookedEvent = false

local freshLoginRecall = true
local lastCallTime = 0
function CraftSim.MAIN:TriggerModulesErrorSafe(isInit)

	local callTime = GetTime()
	if lastCallTime == callTime then
		print("SAME FRAME, RETURN")
		return
	else
		print("NEW FRAME, CONTINUE")
	end

	print("lastCallTime: " .. tostring(lastCallTime))
	print("callTime: " .. tostring(callTime))

	lastCallTime = callTime

	if freshLoginRecall and isInit then
		freshLoginRecall = false
		-- hack to make frames appear after fresh login, when some info has not loaded yet although should have after blizzards' Init call
		C_Timer.After(0.1, function()
			CraftSim.MAIN:TriggerModulesErrorSafe(true)
		end)
	end

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
		-- if init turn sim mode off
		if CraftSim.SIMULATION_MODE.isActive then
			CraftSim.SIMULATION_MODE.isActive = false
			CraftSim.SIMULATION_MODE.FRAMES.WORKORDER.toggleButton:SetChecked(false)
			CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER.toggleButton:SetChecked(false)
		end

		if recipeInfo then
			print("Init: " .. tostring(recipeInfo.recipeID))
			CraftSim.MAIN.currentRecipeID = recipeInfo.recipeID

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

			CraftSim.CACHE:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs, professionInfo.profession)
			CraftSim.MAIN:TriggerModulesErrorSafe(true)
			CraftSim.CACHE:BuildRecipeMap(professionInfo, recipeInfo.recipeID)
		else
			print("Hide all frames recipeInfo nil")
			CraftSim.MAIN:HideAllFrames()
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
	StaticPopupDialogs["CRAFT_SIM_ACCEPT_NO_PRICESOURCE_WARNING"] = {
		text = "Are you sure you do not want to be reminded to get a price source?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function(self, data1, data2)
			CraftSimOptions.doNotRemindPriceSource = true
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
end

function CraftSim.MAIN:ADDON_LOADED(addon_name)
	if addon_name == CraftSimAddonName then
		CraftSim.LOCAL:Init()
		CraftSim.MAIN:handleCraftSimOptionsUpdates()

		CraftSim.FRAME:InitDebugFrame()
		CraftSim.AVERAGEPROFIT.FRAMES:Init()
		CraftSim.AVERAGEPROFIT.FRAMES:InitExplanation()
		CraftSim.TOPGEAR.FRAMES:Init()
		CraftSim.PRICE_DETAILS.FRAMES:Init()
		CraftSim.REAGENT_OPTIMIZATION.FRAMES:Init()
		CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
		CraftSim.FRAME:InitOneTimeNoteFrame()
		CraftSim.SIMULATION_MODE.FRAMES:Init()
		CraftSim.SIMULATION_MODE.FRAMES:InitSpecModifier()
		CraftSim.PRICE_OVERRIDE.FRAMES:Init()
		CraftSim.RECIPE_SCAN.FRAMES:Init()
		CraftSim.CRAFT_RESULTS.FRAMES:Init()
		CraftSim.STATISTICS.FRAMES:Init()
		CraftSim.CUSTOMER_SERVICE.FRAMES:Init()
		CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreview()
		CraftSim.CUSTOMER_HISTORY.FRAMES:Init()
		CraftSim.CRAFTDATA.FRAMES:Init()
		CraftSim.COST_DETAILS.FRAMES:Init()
		CraftSim.SUPPORTERS.FRAMES:Init()

		CraftSim.TOOLTIP:Init()
		CraftSim.MAIN:HookToEvent()
		CraftSim.MAIN:HookToProfessionsFrame()
		CraftSim.FRAME:HandleAuctionatorOverlaps()
		CraftSim.MAIN:HandleAuctionatorHooks()
		CraftSim.ACCOUNTSYNC:Init()


		CraftSim.CONTROL_PANEL.FRAMES:Init()
		CraftSim.MAIN:InitStaticPopups()
		CraftSim.GGUI:InitializePopup({
			backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
			sizeX=300, sizeY=300, title="CraftSim Popup", frameID=CraftSim.CONST.FRAMES.POPUP,
		})

		CraftSim.CUSTOMER_SERVICE:Init()
		CraftSim.CUSTOMER_HISTORY:Init()
		CraftSim.CRAFTDATA:Init()

		CraftSim.FRAME:RestoreModulePositions()
	end
end

function CraftSim.MAIN:HandleAuctionatorHooks()
---@diagnostic disable-next-line: undefined-global
	if Auctionator then
		Auctionator.API.v1.RegisterForDBUpdate(CraftSimAddonName, function()
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
			CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.DEBUG):Show()
		elseif command == "export" then
			if CraftSim.MAIN.currentRecipeData then
				local json = CraftSim.MAIN.currentRecipeData:GetJSON()
				CraftSim.UTIL:KethoEditBox_Show(json)
			end
		else
			-- open options if any other command or no command is given
			InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
		end
	end

	CraftSim.PRICE_API:InitPriceSource()
	CraftSim.OPTIONS:Init()
	--CraftSim.MAIN:HandleCollapsedFrameSave()

	-- show one time note
	if CraftSimOptions.optionsShowNews then
		CraftSim.FRAME:ShowOneTimeInfo()
	end
end

function CraftSim.MAIN:HideAllFrames(keepControlPanel)
	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)
	-- hide control panel and return
	if not keepControlPanel then
		CraftSim.CONTROL_PANEL.frame:Hide()
	end
	-- hide all modules
	CraftSim.RECIPE_SCAN.frame:Hide()
	craftResultsFrame:Hide()
	customerServiceFrame:Hide()
	customerHistoryFrame:Hide()
	priceOverrideFrame:Hide()
	priceOverrideFrameWO:Hide()
	specInfoFrame:Hide()
	specInfoFrameWO:Hide()
	averageProfitFrame:Hide()
	averageProfitFrameWO:Hide()
	topgearFrame:Hide()
	topgearFrameWO:Hide()
	CraftSim.PRICE_DETAILS.frame:Hide()
	CraftSim.PRICE_DETAILS.frameWO:Hide()
	CraftSim.COST_DETAILS.frame:Hide()
	CraftSim.COST_DETAILS.frameWO:Hide()
	materialOptimizationFrame:Hide()
	materialOptimizationFrameWO:Hide()
	CraftSim.CRAFTDATA.frame:Hide()
	-- hide sim mode toggle button
	CraftSim.SIMULATION_MODE.FRAMES.WORKORDER.toggleButton:Hide()
	CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER.toggleButton:Hide()
end

function CraftSim.MAIN:TriggerModulesByRecipeType(isInit)
	if not ProfessionsFrame:IsVisible() then
		return
	end

	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)

	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		CraftSim.MAIN:HideAllFrames()
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()

    local recipeInfo =  C_TradeSkillUI.GetRecipeInfo(CraftSim.MAIN.currentRecipeID)

	if not recipeInfo or recipeInfo.isGatheringRecipe then
		print("gathering recipe: hide frames")
		-- hide all modules
		CraftSim.MAIN:HideAllFrames(true)
		return
	end

	local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

	print("Export Mode: " .. tostring(exportMode))

	local recipeData = nil
	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		recipeData = CraftSim.SIMULATION_MODE.recipeData
		CraftSim.MAIN.currentRecipeData = CraftSim.SIMULATION_MODE.recipeData
	else
		local schematicForm = CraftSim.UTIL:GetSchematicFormByVisibility()

		if not schematicForm then
			print("CraftSim MAIN: No SchematicForm Visible")
			return
		end
		-- set recraft based on visibility
		local currentTransaction = schematicForm:GetTransaction()
		if not currentTransaction then
			print("CraftSim MAIN: SchematicForm without transaction!")
			return
		end
		local isRecraft = currentTransaction:GetRecraftAllocation() ~= nil
		local isWorkOrder = CraftSim.UTIL:IsWorkOrder()

		recipeData = CraftSim.RecipeData(recipeInfo.recipeID, isRecraft, isWorkOrder)

		if recipeData then
			-- Set Reagents based on visibleFrame and load equipped profession gear set
			recipeData:SetAllReagentsBySchematicForm()
			recipeData:SetEquippedProfessionGearSet()

			CraftSim.MAIN.currentRecipeData = recipeData
		end
	end

    local showMaterialOptimization = false
    local showStatweights = false
    local showTopGear = false
	local showSimulationMode = false
	local showSpecInfo = false

	-- always on modules
    local showCostOverview = true
	local showPriceOverride = true
	local showCraftResults = true
	local showRecipeScan = true
	local showCustomerService = true
	local showCustomerHistory = true
	local showCraftData = true
	local showCostDetails = true


	if recipeData.supportsCraftingStats then
		showStatweights = true
		showTopGear = true
	end

	if recipeData.hasQualityReagents then
		showMaterialOptimization = true
	end

	if not recipeData.isCooking and not recipeData.isOldWorldRecipe then
		showSpecInfo = true
	end
	showSimulationMode = not recipeData.isOldWorldRecipe


	showMaterialOptimization = showMaterialOptimization and CraftSimOptions.modulesMaterials
	showStatweights = showStatweights and CraftSimOptions.modulesStatWeights
	showTopGear = showTopGear and CraftSimOptions.modulesTopGear
	showCostOverview = showCostOverview and CraftSimOptions.modulesPriceDetails
	showSpecInfo = showSpecInfo and CraftSimOptions.modulesSpecInfo
	showPriceOverride = showPriceOverride and CraftSimOptions.modulesPriceOverride
	showRecipeScan = showRecipeScan and CraftSimOptions.modulesRecipeScan
	showCraftResults = showCraftResults and CraftSimOptions.modulesCraftResults
	showCustomerService = showCustomerService and CraftSimOptions.modulesCustomerService
	showCustomerHistory = showCustomerHistory and CraftSimOptions.modulesCustomerHistory
	showCraftData = showCraftData and CraftSimOptions.modulesCraftData
	showCostDetails = showCostDetails and CraftSimOptions.modulesCostDetails

	CraftSim.FRAME:ToggleFrame(CraftSim.RECIPE_SCAN.frame, showRecipeScan)
	CraftSim.FRAME:ToggleFrame(craftResultsFrame, showCraftResults)
	CraftSim.FRAME:ToggleFrame(customerServiceFrame, showCustomerService)
	CraftSim.FRAME:ToggleFrame(customerHistoryFrame, showCustomerHistory)



	-- Simulation Mode (always update first because it changes recipeData based on simMode inputs)
	showSimulationMode = showSimulationMode and recipeData and not recipeData.isSalvageRecipe
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.FRAMES.WORKORDER.toggleButton,showSimulationMode and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER.toggleButton, showSimulationMode and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility() -- show sim mode frames depending if active or not
	if CraftSim.SIMULATION_MODE.isActive and recipeData then
		-- update simulationframe recipedata by inputs and the frontend
		-- since recipeData is a reference here to the recipeData in the simulationmode,
		-- the recipeData that is used in the below modules should also be the modified one!
		CraftSim.SIMULATION_MODE:UpdateSimulationMode()
	end

	CraftSim.FRAME:ToggleFrame(CraftSim.COST_DETAILS.frame, showCostDetails and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.COST_DETAILS.frameWO, showCostDetails and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCostDetails then
		CraftSim.COST_DETAILS:UpdateDisplay(recipeData, exportMode)
	end

	if recipeData and showCraftResults then
		CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeData.recipeID)
	end

	CraftSim.FRAME:ToggleFrame(CraftSim.CRAFTDATA.frame, showCraftData)
	if showCraftData then
		CraftSim.CRAFTDATA.FRAMES:UpdateDisplay(recipeData)
	end

	-- AverageProfit Module
	CraftSim.FRAME:ToggleFrame(averageProfitFrame, showStatweights and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(averageProfitFrameWO, showStatweights and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showStatweights then
		local statWeights = CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData)

		if statWeights then
			CraftSim.AVERAGEPROFIT.FRAMES:UpdateDisplay(statWeights, recipeData.priceData.craftingCosts, exportMode)
		end

		CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
	end

	-- Cost Overview Module
	CraftSim.FRAME:ToggleFrame(CraftSim.PRICE_DETAILS.frame, showCostOverview and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.PRICE_DETAILS.frameWO, showCostOverview and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCostOverview then
		CraftSim.PRICE_DETAILS:UpdateDisplay(recipeData, exportMode)
	end


	-- Price Override Module
	CraftSim.FRAME:ToggleFrame(priceOverrideFrame, showPriceOverride and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(priceOverrideFrameWO, showPriceOverride and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showPriceOverride then
		CraftSim.PRICE_OVERRIDE.FRAMES:UpdateDisplay(recipeData, exportMode)
	end

	-- Material Optimization Module
	CraftSim.FRAME:ToggleFrame(materialOptimizationFrame, showMaterialOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(materialOptimizationFrameWO, showMaterialOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showMaterialOptimization then
		CraftSim.UTIL:StartProfiling("Reagent Optimization")
		local optimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, CraftSimOptions.materialSuggestionInspirationThreshold)
		CraftSim.REAGENT_OPTIMIZATION.FRAMES:UpdateReagentDisplay(recipeData, optimizationResult, exportMode)
		CraftSim.UTIL:StopProfiling("Reagent Optimization")
	end

	-- Top Gear Module
	CraftSim.FRAME:ToggleFrame(topgearFrame, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(topgearFrameWO, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showTopGear then
		CraftSim.TOPGEAR.FRAMES:UpdateModeDropdown(recipeData, exportMode)
		if CraftSimOptions.topGearAutoUpdate then
			CraftSim.UTIL:StartProfiling("Top Gear")
			CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
			CraftSim.UTIL:StopProfiling("Top Gear")
		else
			local isCooking = recipeData.professionID == Enum.Profession.Cooking
			CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(recipeData, true, exportMode)
		end
	end

	-- SpecInfo Module
	CraftSim.FRAME:ToggleFrame(specInfoFrame, showSpecInfo and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(specInfoFrameWO, showSpecInfo and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showSpecInfo then
		CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
	end
end

function CraftSim_OnAddonCompartmentClick()
	InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
end
