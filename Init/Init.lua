---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

CraftSim.LibCompress = LibStub:GetLibrary("LibCompress")
CraftSim.LibIcon = LibStub("LibDBIcon-1.0")

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.INIT : Frame
CraftSim.INIT = GUTIL:CreateRegistreeForEvents { "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD" }

CraftSim.INIT.FRAMES = {}

---@type CraftSim.RecipeData?
CraftSim.INIT.currentRecipeData = nil
---@type number?
CraftSim.INIT.currentRecipeID = nil
CraftSim.INIT.initialLogin = false
CraftSim.INIT.isReloadingUI = false

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.INIT)
function CraftSim.INIT:PLAYER_ENTERING_WORLD(initialLogin, isReloadingUI)
	CraftSim.INIT.initialLogin = initialLogin
	CraftSim.INIT.isReloadingUI = isReloadingUI

	-- for any processes that may only happen once a session e.g.
	if initialLogin then
		-- Clear Preview IDs upon fresh session
		CraftSim.CUSTOMER_SERVICE:ClearPreviewIDs()
		-- clear post loaded multicraft professions
		CraftSim.DB.MULTICRAFT_PRELOAD:ClearAll()
	end

	-- load craft queue
	CraftSim.CRAFTQ:InitializeCraftQueue()
end

local hookedEvent = false

local freshLoginRecall = true
local lastCallTime = 0
function CraftSim.INIT:TriggerModuleUpdate(isInit)
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

	CraftSim.INIT:HideAllModules(true)

	if freshLoginRecall and isInit then
		-- hide all frames to reduce flicker on fresh login recall
		freshLoginRecall = false
		-- hack to make frames appear after fresh login, when some info has not loaded yet although should have after blizzards' Init call
		C_Timer.After(0.1, function()
			CraftSim.INIT:TriggerModuleUpdate(true)
		end)
		return
	end

	GUTIL:WaitFor(function()
		if C_TradeSkillUI.IsTradeSkillReady() then
			local recipeID = CraftSim.INIT.currentRecipeID
			if recipeID then
				local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
				return recipeInfo ~= nil and recipeInfo.categoryID
			end
		end
		return false
	end, function()
		CraftSim.DEBUG:StartProfiling("MODULES UPDATE")
		CraftSim.INIT:TriggerModulesByRecipeType()
		-- do not do this all in the same frame to ease performance
		RunNextFrame(CraftSim.RECIPE_SCAN.UpdateProfessionListByCache)
		CraftSim.DEBUG:StopProfiling("MODULES UPDATE")
	end)
end

function CraftSim.INIT:HookToEvent()
	if hookedEvent then
		return
	end
	hookedEvent = true

	local function Update(self)
		if CraftSim.INIT.currentRecipeID then
			print("Update: " .. tostring(CraftSim.INIT.currentRecipeID))
			CraftSim.INIT:TriggerModuleUpdate(false)
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
			CraftSim.INIT.currentRecipeID = recipeInfo.recipeID

			local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
			local professionRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

			CraftSim.INIT:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs,
				professionInfo.profession)
			CraftSim.INIT:TriggerModuleUpdate(true)

			local recipeID = recipeInfo.recipeID

			-- this should happen exactly once on the first open recipe when a profession opened fresh after a client start
			-- otherwise it just always fizzles
			-- its better than to wait for multicraft stat each frame because this can actually happen in the same frame
			GUTIL:WaitForEvent("CRAFTING_DETAILS_UPDATE", function()
				if recipeID == CraftSim.INIT.currentRecipeID then
					print("Multicraft Info Loaded")
					CraftSim.INIT:TriggerModuleUpdate(true)
				end
			end, 1)
		else
			print("Hide all frames recipeInfo nil")
			CraftSim.INIT:HideAllModules()
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

function CraftSim.INIT:InitStaticPopups()
	StaticPopupDialogs["CRAFT_SIM_ACCEPT_NO_PRICESOURCE_WARNING"] = {
		text = "Are you sure you do not want to be reminded to get a price source?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function(self, data1, data2)
			CraftSim.DB.OPTIONS:Save("PRICE_SOURCE_REMINDER_DISABLED", true)
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
end

function CraftSim.INIT:InitCraftRecipeHooks()
	---@param recipeID number
	---@param amount number?
	---@param craftingReagentInfoTbl CraftingReagentInfo[]?
	---@param itemTarget ItemLocationMixin?
	local function OnCraft(recipeID, amount, craftingReagentInfoTbl, itemTarget)
		-- create a recipeData instance with given info and forward it to the corresponding modules
		-- isRecraft and isWorkOrder is omitted cause cant know here
		-- but recrafts have different reagents.. so they wont be recognized by comparison anyway
		-- and if its work order or not is not important for CraftResult records (I hope?)
		-- If it is important I could just check if the work order frame is open because there is no way a player starts a work order craft without it open!
		-- conclusion: use work order page to check if its a work order and use (if available) the current main recipeData to check if its a recraft
		-- new take: problem when recraft recipe is open and crafting in queue.. then it thinks its a recraft... so for now its just always false..
		local isRecraft = false

		local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

		---@type CraftSim.RecipeData
		local recipeData
		-- if craftsim did not call the api and we do not have reagents, set it by gui
		if not CraftSim.CRAFTQ.CraftSimCalledCraftRecipe then
			--- craft was most probably started via default gui craft button...
			print("api was called via gui")
			if CraftSim.INIT.currentRecipeData then
				isRecraft = CraftSim.INIT.currentRecipeData.isRecraft
			end
			-- this means recraft and work order stuff is important
			recipeData = CraftSim.RecipeData(recipeID, isRecraft, CraftSim.UTIL:IsWorkOrder())

			recipeData:SetAllReagentsBySchematicForm()
			-- assume non df recipe or recipe without quality reagents that are all set (cause otherwise crafting would not be possible)
		else
			print("api was called via craftsim")
			-- started via craftsim craft queue
			recipeData = CraftSim.RecipeData(recipeID, isRecraft, CraftSim.UTIL:IsWorkOrder())
			recipeData:SetReagentsByCraftingReagentInfoTbl(craftingReagentInfoTbl)
			recipeData:SetNonQualityReagentsMax()
		end

		recipeData:SetEquippedProfessionGearSet()

		recipeData:Update() -- is this necessary? check again if there are performance problems with that

		print("CraftRecipe Hook: ")
		print(recipeData.reagentData, true)

		CraftSim.CRAFT_RESULTS:OnCraftRecipe(recipeData)
		CraftSim.CRAFTQ:OnCraftRecipe(recipeData, amount or 1, itemTarget)
	end
	local function OnRecraft()
		if CraftSim.INIT.currentRecipeData then
			CraftSim.CRAFT_RESULTS:OnCraftRecipe(CraftSim.INIT.currentRecipeData)
		end
	end
	hooksecurefunc(C_TradeSkillUI, "CraftRecipe", OnCraft)
	hooksecurefunc(C_TradeSkillUI, "CraftEnchant", OnCraft)
	hooksecurefunc(C_TradeSkillUI, "RecraftRecipe", OnRecraft)
	hooksecurefunc(C_TradeSkillUI, "RecraftRecipeForOrder", OnRecraft)
	hooksecurefunc(C_TradeSkillUI, "CraftSalvage", CraftSim.CRAFT_RESULTS.OnCraftSalvage)
end

function CraftSim.INIT:ADDON_LOADED(addon_name)
	if addon_name == CraftSimAddonName then
		CraftSim.DB:Init()
		CraftSim.INIT:InitializeMinimapButton()

		CraftSim.LOCAL:Init()

		CraftSim.GGUI:InitializePopup({
			backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
			sizeX = 300,
			sizeY = 300,
			title = "CraftSim Popup",
			frameID = CraftSim.CONST.FRAMES.POPUP,
		})

		CraftSim.DEBUG.FRAMES:Init()

		CraftSim.PRICE_API:InitPriceSource()


		CraftSim.AVERAGEPROFIT.FRAMES:Init()
		CraftSim.EXPLANATIONS.FRAMES:Init()
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
		CraftSim.COST_OPTIMIZATION.FRAMES:Init()
		CraftSim.SUPPORTERS.FRAMES:Init()
		CraftSim.CRAFTQ.FRAMES:Init()
		CraftSim.CRAFT_BUFFS.FRAMES:Init()
		CraftSim.COOLDOWNS.FRAMES:Init()

		CraftSim.INIT:HookToEvent()
		CraftSim.INIT:HookToProfessionsFrame()
		CraftSim.INIT:HandleAuctionatorHooks()
		CraftSim.INIT:InitCraftRecipeHooks()

		CraftSim.CONTROL_PANEL.FRAMES:Init()
		CraftSim.INIT:InitStaticPopups()


		CraftSim.CUSTOMER_SERVICE:Init()
		CraftSim.CUSTOMER_HISTORY:Init()

		CraftSim.OPTIONS:Init()


		CraftSim.FRAME:RestoreModulePositions()
	end
end

function CraftSim.INIT:HandleAuctionatorHooks()
	---@diagnostic disable-next-line: undefined-global
	if Auctionator then
		Auctionator.API.v1.RegisterForDBUpdate(CraftSimAddonName, function()
			print("Auctionator DB Update")
			CraftSim.INIT:TriggerModuleUpdate(false)
		end)
	end
end

local professionFrameHooked = false
function CraftSim.INIT:HookToProfessionsFrame()
	if professionFrameHooked then
		return
	end
	professionFrameHooked = true

	ProfessionsFrame:HookScript("OnShow",
		function()
			CraftSim.CUSTOMER_HISTORY.FRAMES:UpdateDisplay()
			CraftSim.INIT.lastRecipeID = nil
			if CraftSim.DB.OPTIONS:Get("OPEN_LAST_RECIPE") then
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

function CraftSim.INIT:PLAYER_LOGIN()
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
			local priceDebug = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.PRICE_DEBUG)
			priceDebug = not priceDebug
			CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.PRICE_DEBUG, priceDebug)
			print("Craftsim: Toggled price debug mode: " .. tostring(priceDebug))

			if priceDebug then
				CraftSim.PRICE_API = CraftSimNO_PRICE_API
			else
				CraftSim.PRICE_APIS:InitAvailablePriceAPI()
			end
		elseif command == "news" then
			CraftSim.NEWS:ShowNews(true)
		elseif command == "debug" then
			CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG):Show()
		elseif command == "export" then
			if CraftSim.INIT.currentRecipeData then
				local json = CraftSim.INIT.currentRecipeData:GetJSON()
				CraftSim.UTIL:KethoEditBox_Show(json)
			end
		elseif command == "resetdb" then
			CraftSimDB = nil
			C_UI.Reload()
		else
			-- open options if any other command or no command is given
			InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
		end
	end

	-- show one time note
	if CraftSim.DB.OPTIONS:Get("SHOW_NEWS") then
		CraftSim.NEWS:ShowNews()
	end
end

function CraftSim.INIT:HideAllModules(keepControlPanel)
	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.AVERAGE_PROFIT)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
	-- hide control panel and return
	if not keepControlPanel then
		CraftSim.CONTROL_PANEL.frame:Hide()
	end
	-- hide all modules
	CraftSim.RECIPE_SCAN.frame:Hide()
	CraftSim.CRAFTQ.frame:Hide()
	CraftSim.CRAFT_BUFFS.frame:Hide()
	CraftSim.CRAFT_BUFFS.frameWO:Hide()
	CraftSim.COOLDOWNS.frame:Hide()
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
	CraftSim.COST_OPTIMIZATION.frame:Hide()
	CraftSim.COST_OPTIMIZATION.frameWO:Hide()
	materialOptimizationFrame:Hide()
	materialOptimizationFrameWO:Hide()
	-- hide sim mode toggle button
	CraftSim.SIMULATION_MODE.FRAMES.WORKORDER.toggleButton:Hide()
	CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER.toggleButton:Hide()
	CraftSim.EXPLANATIONS.frame:Hide()
	CraftSim.STATISTICS.FRAMES:SetVisible(false)
end

function CraftSim.INIT:TriggerModulesByRecipeType()
	if not ProfessionsFrame:IsVisible() then
		return
	end

	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.AVERAGE_PROFIT)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
	local craftBuffsFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_BUFFS)
	local craftBuffsFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_BUFFS_WORKORDER)
	local cooldownsFrame = CraftSim.COOLDOWNS.frame

	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		CraftSim.INIT:HideAllModules()
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()

	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.currentRecipeID)

	if not recipeInfo or recipeInfo.isGatheringRecipe then
		-- hide all modules
		CraftSim.INIT:HideAllModules(true)
		return
	end

	local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

	print("Export Mode: " .. tostring(exportMode))

	---@type CraftSim.RecipeData
	local recipeData = nil
	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		---@type CraftSim.RecipeData
		recipeData = CraftSim.SIMULATION_MODE.recipeData
		CraftSim.INIT.currentRecipeData = CraftSim.SIMULATION_MODE.recipeData
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

			CraftSim.INIT.currentRecipeData = recipeData
		end
	end

	-- subrecipe optimization
	recipeData:SetSubRecipeCostsUsage(CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_AUTOMATIC_SUB_RECIPE_OPTIMIZATION"))
	if recipeData.subRecipeCostsEnabled then
		CraftSim.DEBUG:StartProfiling("OptimizeSubRecipes")
		recipeData:OptimizeSubRecipes({
			optimizeGear = true, -- TODO: Option to toggle, maybe general, maybe per sub recipe?
			optimizeReagents = true,
		})
		CraftSim.DEBUG:StopProfiling("OptimizeSubRecipes")
	end

	local showReagentOptimization = false
	local showAverageProfit = false
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
	local showCostOptimization = true
	local showCraftQueue = true
	local showCraftBuffs = true
	local showCooldowns = true
	local showExplanations = true
	local showStatistics = true

	if recipeData.supportsCraftingStats then
		showAverageProfit = true
		showTopGear = true
	end

	if recipeData.hasQualityReagents then
		showReagentOptimization = true
	end

	if not recipeData.isCooking and not recipeData.isOldWorldRecipe then
		showSpecInfo = true
	end
	showSimulationMode = not recipeData.isOldWorldRecipe

	showReagentOptimization = showReagentOptimization and CraftSim.DB.OPTIONS:Get("MODULE_REAGENT_OPTIMIZATION")
	showAverageProfit = showAverageProfit and CraftSim.DB.OPTIONS:Get("MODULE_AVERAGE_PROFIT")
	showTopGear = showTopGear and CraftSim.DB.OPTIONS:Get("MODULE_TOP_GEAR")
	showCostOverview = showCostOverview and CraftSim.DB.OPTIONS:Get("MODULE_COST_OVERVIEW")
	showSpecInfo = showSpecInfo and CraftSim.DB.OPTIONS:Get("MODULE_SPEC_INFO")
	showPriceOverride = showPriceOverride and CraftSim.DB.OPTIONS:Get("MODULE_PRICE_OVERRIDE")
	showRecipeScan = showRecipeScan and CraftSim.DB.OPTIONS:Get("MODULE_RECIPE_SCAN")
	showCraftResults = showCraftResults and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_RESULTS")
	showCustomerService = showCustomerService and CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_SERVICE")
	showCustomerHistory = showCustomerHistory and CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_HISTORY")
	showCostOptimization = showCostOptimization and CraftSim.DB.OPTIONS:Get("MODULE_COST_OPTIMIZATION")
	showCraftQueue = showCraftQueue and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_QUEUE")
	showCraftBuffs = showCraftBuffs and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_BUFFS")
	showCooldowns = showCooldowns and CraftSim.DB.OPTIONS:Get("MODULE_COOLDOWNS")
	showExplanations = showExplanations and CraftSim.DB.OPTIONS:Get("MODULE_EXPLANATIONS")
	showStatistics = showStatistics and CraftSim.DB.OPTIONS:Get("MODULE_STATISTICS")

	CraftSim.FRAME:ToggleFrame(CraftSim.RECIPE_SCAN.frame, showRecipeScan)
	CraftSim.FRAME:ToggleFrame(CraftSim.CRAFTQ.frame, showCraftQueue)
	CraftSim.FRAME:ToggleFrame(CraftSim.EXPLANATIONS.frame, showExplanations)
	CraftSim.FRAME:ToggleFrame(craftResultsFrame, showCraftResults)
	CraftSim.FRAME:ToggleFrame(customerServiceFrame, showCustomerService)
	CraftSim.FRAME:ToggleFrame(customerHistoryFrame, showCustomerHistory)
	CraftSim.FRAME:ToggleFrame(cooldownsFrame, showCooldowns)

	if showCooldowns then
		CraftSim.COOLDOWNS.FRAMES:UpdateDisplay()
	end

	-- update CraftQ Display (e.g. cause of profession gear changes)
	CraftSim.CRAFTQ.FRAMES:UpdateDisplay()

	-- Simulation Mode (always update first because it changes recipeData based on simMode inputs)
	showSimulationMode = (showSimulationMode and recipeData and not recipeData.isSalvageRecipe) or false
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.FRAMES.WORKORDER.toggleButton,
		showSimulationMode and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER.toggleButton,
		showSimulationMode and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility() -- show sim mode frames depending if active or not
	if CraftSim.SIMULATION_MODE.isActive and recipeData then
		-- update simulationframe recipedata by inputs and the frontend
		-- since recipeData is a reference here to the recipeData in the simulationmode,
		-- the recipeData that is used in the below modules should also be the modified one!
		CraftSim.SIMULATION_MODE:UpdateSimulationMode()
	end

	-- Cost Optimization Module
	CraftSim.FRAME:ToggleFrame(CraftSim.COST_OPTIMIZATION.frame,
		showCostOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.COST_OPTIMIZATION.frameWO,
		showCostOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCostOptimization then
		CraftSim.COST_OPTIMIZATION:UpdateDisplay(recipeData, exportMode)
	end

	if recipeData and showCraftResults then
		CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeData.recipeID)
	end

	-- AverageProfit Module
	CraftSim.FRAME:ToggleFrame(averageProfitFrame,
		showAverageProfit and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(averageProfitFrameWO,
		showAverageProfit and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showAverageProfit then
		local statWeights = CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData)

		if statWeights then
			CraftSim.AVERAGEPROFIT.FRAMES:UpdateDisplay(statWeights, recipeData.priceData.craftingCosts)
		end
	end

	-- Statistics Module
	CraftSim.STATISTICS.FRAMES:SetVisible(showStatistics, exportMode)
	if recipeData and showStatistics then
		CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
	end

	-- Price Details Module
	CraftSim.FRAME:ToggleFrame(CraftSim.PRICE_DETAILS.frame,
		showCostOverview and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.PRICE_DETAILS.frameWO,
		showCostOverview and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCostOverview then
		CraftSim.PRICE_DETAILS:UpdateDisplay(recipeData, exportMode)
	end


	-- Price Override Module
	CraftSim.FRAME:ToggleFrame(priceOverrideFrame,
		showPriceOverride and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(priceOverrideFrameWO,
		showPriceOverride and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showPriceOverride then
		CraftSim.PRICE_OVERRIDE.FRAMES:UpdateDisplay(recipeData, exportMode)
	end

	-- Material Optimization Module
	CraftSim.FRAME:ToggleFrame(materialOptimizationFrame,
		showReagentOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(materialOptimizationFrameWO,
		showReagentOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showReagentOptimization then
		CraftSim.DEBUG:StartProfiling("Reagent Optimization")
		local optimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData)
		CraftSim.REAGENT_OPTIMIZATION.FRAMES:UpdateReagentDisplay(recipeData, optimizationResult, exportMode)
		CraftSim.DEBUG:StopProfiling("Reagent Optimization")
	end

	-- Top Gear Module
	CraftSim.FRAME:ToggleFrame(topgearFrame, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(topgearFrameWO, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showTopGear then
		CraftSim.TOPGEAR.FRAMES:UpdateModeDropdown(recipeData, exportMode)
		if CraftSim.DB.OPTIONS:Get("TOP_GEAR_AUTO_UPDATE") then
			CraftSim.DEBUG:StartProfiling("Top Gear")
			CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
			CraftSim.DEBUG:StopProfiling("Top Gear")
		else
			local isCooking = recipeData.professionID == Enum.Profession.Cooking
			CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(recipeData, true, exportMode)
		end
	end

	-- SpecInfo Module
	CraftSim.FRAME:ToggleFrame(specInfoFrame,
		showSpecInfo and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(specInfoFrameWO,
		showSpecInfo and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showSpecInfo then
		CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
	end

	-- CraftBuffs Module
	CraftSim.FRAME:ToggleFrame(craftBuffsFrame,
		showCraftBuffs and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(craftBuffsFrameWO,
		showCraftBuffs and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCraftBuffs then
		CraftSim.CRAFT_BUFFS.FRAMES:UpdateDisplay(recipeData, exportMode)
	end

	CraftSim.INIT.lastRecipeID = CraftSim.INIT.currentRecipeID
end

function CraftSim_OnAddonCompartmentClick()
	InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
end

function CraftSim.INIT:InitializeMinimapButton()
	local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("CraftSimLDB", {
		type = "data source",
		--tooltip = "CraftSim",
		label = "CraftSim",
		tocname = "CraftSim",
		icon = "Interface\\Addons\\CraftSim\\Media\\Images\\craftsim",
		OnClick = function()
			-- local historyFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.HISTORY_FRAME)
			InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
		end,
	})

	CraftSim.LibIcon:Register("CraftSim", ldb, CraftSim.DB.OPTIONS:Get("LIB_ICON_DB"))

	RunNextFrame(function()
		if CraftSim.DB.OPTIONS:Get("MINIMAP_BUTTON_HIDE") then
			CraftSim.LibIcon:Hide("CraftSim")
		end
	end)
end

--- Since Multicraft seems to be missing on operationInfo on the first call after a fresh login, and seems to be loaded in after the first call,
--- trigger it for all recipes on purpose when the profession is opened the first time in this session
function CraftSim.INIT:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs, professionID)
	if not professionID then return end
	if CraftSim.DB.MULTICRAFT_PRELOAD:Get(professionID) then return end
	if not professionRecipeIDs then
		return
	end
	print("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

	CraftSim.DEBUG:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
	for _, recipeID in ipairs(professionRecipeIDs) do
		C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {})
	end

	CraftSim.DEBUG:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

	CraftSim.DB.MULTICRAFT_PRELOAD:Save(professionID, true)
end
