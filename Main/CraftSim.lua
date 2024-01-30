---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

CraftSim.LibCompress = LibStub:GetLibrary("LibCompress")
CraftSim.LibIcon = LibStub("LibDBIcon-1.0")

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.MAIN : Frame
CraftSim.MAIN = CreateFrame("Frame", "CraftSimAddon")
CraftSim.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
CraftSim.MAIN:RegisterEvent("ADDON_LOADED")
CraftSim.MAIN:RegisterEvent("PLAYER_LOGIN")
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
	topGearAutoUpdate = false,
	optionsShowNews = true,
	optionsHideMinimapButton = false,

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
	modulesCraftQueue = false,
	modulesCraftBuffs = true,
	modulesCooldowns = false,

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
	recipeScanOnlyFavorites = false,
	recipeScanOptimizeProfessionTools = false,
	recipeScanScanMode = nil,
	recipeScanFilteredExpansions = nil,
	recipeScanAltProfessions = nil,
	recipeScanImportAllProfessions = false,

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

	-- craft queue
	craftQueueGeneralRestockProfitMarginThreshold = 0,
	craftQueueGeneralRestockRestockAmount = 1,
	craftQueueGeneralRestockSaleRateThreshold = 0,
	craftQueueRestockPerRecipeOptions = {},
	craftQueueShoppingListPerCharacter = false,
	craftQueueFlashTaskbarOnCraftFinished = true,
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
		-- clear post loaded multicraft professions
		wipe(CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions)
	end

	-- load craft queue
	CraftSim.CRAFTQ:InitializeCraftQueue()
end

function CraftSim.MAIN:HandleCraftSimOptionsUpdates()
	if CraftSimOptions then
		CraftSimOptions.tsmPriceKey = nil
		CraftSimOptions.tsmPriceKeyMaterials = CraftSimOptions.tsmPriceKeyMaterials or
			CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION
		CraftSimOptions.tsmPriceKeyItems = CraftSimOptions.tsmPriceKeyItems or
			CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION
		CraftSimOptions.topGearMode = CraftSimOptions.topGearMode or "Top Profit"
		CraftSimOptions.breakPointOffset = CraftSimOptions.breakPointOffset or false
		CraftSimOptions.autoAssignVellum = CraftSimOptions.autoAssignVellum or false
		CraftSimOptions.showProfitPercentage = CraftSimOptions.showProfitPercentage or false
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
		CraftSimOptions.customMulticraftConstant = CraftSimOptions.customMulticraftConstant or
			CraftSim.CONST.MULTICRAFT_CONSTANT
		CraftSimOptions.customResourcefulnessConstant = CraftSimOptions.customResourcefulnessConstant or
			CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR
		CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold = CraftSimOptions
			.craftQueueGeneralRestockProfitMarginThreshold or 0
		CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold = CraftSimOptions
			.craftQueueGeneralRestockSaleRateThreshold or 0
		CraftSimOptions.craftQueueGeneralRestockRestockAmount = CraftSimOptions.craftQueueGeneralRestockRestockAmount or
			1
		CraftSimOptions.craftQueueRestockPerRecipeOptions = CraftSimOptions.craftQueueRestockPerRecipeOptions or {}
		CraftSimOptions.customerHistoryAutoPurgeInterval = CraftSimOptions.customerHistoryAutoPurgeInterval or 2
		CraftSimOptions.customerHistoryAutoPurgeLastPurge = CraftSimOptions.customerHistoryAutoPurgeLastPurge or nil
		CraftSimOptions.recipeScanFilteredExpansions = CraftSimOptions.recipeScanFilteredExpansions or {
			[CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT] = true,
		}
		CraftSimOptions.recipeScanIncludedProfessions = CraftSimOptions.recipeScanIncludedProfessions or {}
		CraftSimOptions.recipeScanScanMode = CraftSimOptions.recipeScanScanMode or
			CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE
		CraftSimOptions.recipeScanImportAllProfessions = CraftSimOptions.recipeScanImportAllProfessions or false
		CraftSimOptions.craftQueueShoppingListPerCharacter = CraftSimOptions.craftQueueShoppingListPerCharacter or false

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
		if CraftSimOptions.modulesCraftBuffs == nil then
			CraftSimOptions.modulesCraftBuffs = true
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
		if CraftSimOptions.craftQueueFlashTaskbarOnCraftFinished == nil then
			CraftSimOptions.craftQueueFlashTaskbarOnCraftFinished = true
		end
	end

	-- old data removal
	if CraftSimCraftData then
		CraftSimCraftData = nil
	end
end

local hookedEvent = false

local freshLoginRecall = true
local lastCallTime = 0
function CraftSim.MAIN:TriggerModuleUpdate(isInit)
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

	CraftSim.MAIN:HideAllModules(true)

	if freshLoginRecall and isInit then
		-- hide all frames to reduce flicker on fresh login recall
		freshLoginRecall = false
		-- hack to make frames appear after fresh login, when some info has not loaded yet although should have after blizzards' Init call
		C_Timer.After(0.1, function()
			CraftSim.MAIN:TriggerModuleUpdate(true)
		end)
		return
	end

	GUTIL:WaitFor(function()
		if C_TradeSkillUI.IsTradeSkillReady() then
			local recipeID = CraftSim.MAIN.currentRecipeID
			if recipeID then
				local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
				return recipeInfo ~= nil and recipeInfo.categoryID
			end
		end
		return false
	end, function()
		CraftSim.UTIL:StartProfiling("MODULES UPDATE")
		CraftSim.MAIN:TriggerModulesByRecipeType()
		-- do not do this all in the same frame to ease performance
		RunNextFrame(CraftSim.RECIPE_SCAN.UpdateProfessionListByCache)
		CraftSim.UTIL:StopProfiling("MODULES UPDATE")
	end)
end

function CraftSim.MAIN:HookToEvent()
	if hookedEvent then
		return
	end
	hookedEvent = true

	local function Update(self)
		if CraftSim.MAIN.currentRecipeID then
			print("Update: " .. tostring(CraftSim.MAIN.currentRecipeID))
			CraftSim.MAIN:TriggerModuleUpdate(false)
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
			local professionRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

			CraftSim.CACHE.RECIPE_DATA:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs,
				professionInfo.profession)
			CraftSim.MAIN:TriggerModuleUpdate(true)

			local recipeID = recipeInfo.recipeID

			-- this should happen exactly once on the first open recipe when a profession opened fresh after a client start
			-- otherwise it just always fizzles
			-- its better than to wait for multicraft stat each frame because this can actually happen in the same frame
			GUTIL:WaitForEvent("CRAFTING_DETAILS_UPDATE", function()
				if recipeID == CraftSim.MAIN.currentRecipeID then
					print("Multicraft Info Loaded")
					CraftSim.MAIN:TriggerModuleUpdate(true)
				end
			end, 1)
		else
			print("Hide all frames recipeInfo nil")
			CraftSim.MAIN:HideAllModules()
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
		preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
end

function CraftSim.MAIN:InitCraftRecipeHooks()
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
		-- if CraftSim.MAIN.currentRecipeData then
		-- 	isRecraft = CraftSim.MAIN.currentRecipeData.isRecraft
		-- end

		local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

		---@type CraftSim.RecipeData
		local recipeData
		-- if craftsim did not call the api and we do not have reagents, set it by gui
		if not CraftSim.CRAFTQ.CraftSimCalledCraftRecipe then
			--- craft was most probably started via default gui craft button...
			print("api was called via gui")
			if CraftSim.MAIN.currentRecipeData then
				isRecraft = CraftSim.MAIN.currentRecipeData.isRecraft
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
	hooksecurefunc(C_TradeSkillUI, "CraftRecipe", OnCraft)
	hooksecurefunc(C_TradeSkillUI, "CraftEnchant", OnCraft)
	hooksecurefunc(C_TradeSkillUI, "CraftSalvage", CraftSim.CRAFT_RESULTS.OnCraftSalvage)
end

function CraftSim.MAIN:ADDON_LOADED(addon_name)
	if addon_name == CraftSimAddonName then
		CraftSim.MAIN:HandleCraftSimOptionsUpdates()
		CraftSim.CACHE:HandleCraftSimCacheUpdates()
		CraftSim.MAIN:InitializeMinimapButton()

		CraftSim.LOCAL:Init()
		CraftSim.FRAME:InitDebugFrame()
		CraftSim.GGUI:InitializePopup({
			backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
			sizeX = 300,
			sizeY = 300,
			title = "CraftSim Popup",
			frameID = CraftSim.CONST.FRAMES.POPUP,
		})
		CraftSim.PRICE_API:InitPriceSource()


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
		CraftSim.COST_DETAILS.FRAMES:Init()
		CraftSim.SUPPORTERS.FRAMES:Init()
		CraftSim.CRAFTQ.FRAMES:Init()
		CraftSim.CRAFT_BUFFS.FRAMES:Init()
		CraftSim.COOLDOWNS.FRAMES:Init()

		CraftSim.TOOLTIP:Init()
		CraftSim.MAIN:HookToEvent()
		CraftSim.MAIN:HookToProfessionsFrame()
		CraftSim.MAIN:HandleAuctionatorHooks()
		CraftSim.MAIN:InitCraftRecipeHooks()
		CraftSim.ACCOUNTSYNC:Init()


		CraftSim.CONTROL_PANEL.FRAMES:Init()
		CraftSim.MAIN:InitStaticPopups()


		CraftSim.CUSTOMER_SERVICE:Init()
		CraftSim.CUSTOMER_HISTORY:Init()

		CraftSim.OPTIONS:Init()


		CraftSim.FRAME:RestoreModulePositions()
	end
end

function CraftSim.MAIN:HandleAuctionatorHooks()
	---@diagnostic disable-next-line: undefined-global
	if Auctionator then
		Auctionator.API.v1.RegisterForDBUpdate(CraftSimAddonName, function()
			print("Auctionator DB Update")
			CraftSim.MAIN:TriggerModuleUpdate(false)
		end)
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
			CraftSim.CUSTOMER_HISTORY.FRAMES:UpdateDisplay()
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
			CraftSim.NEWS:ShowNews(true)
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

	-- show one time note
	if CraftSimOptions.optionsShowNews then
		CraftSim.NEWS:ShowNews()
	end
end

function CraftSim.MAIN:HideAllModules(keepControlPanel)
	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES,
		CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES,
		CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES,
		CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)
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
	CraftSim.COST_DETAILS.frame:Hide()
	CraftSim.COST_DETAILS.frameWO:Hide()
	materialOptimizationFrame:Hide()
	materialOptimizationFrameWO:Hide()
	-- hide sim mode toggle button
	CraftSim.SIMULATION_MODE.FRAMES.WORKORDER.toggleButton:Hide()
	CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER.toggleButton:Hide()
end

function CraftSim.MAIN:TriggerModulesByRecipeType()
	if not ProfessionsFrame:IsVisible() then
		return
	end

	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES,
		CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES,
		CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES,
		CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)
	local craftBuffsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_BUFFS)
	local craftBuffsFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_BUFFS_WORKORDER)
	local cooldownsFrame = CraftSim.COOLDOWNS.frame

	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		CraftSim.MAIN:HideAllModules()
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()

	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.MAIN.currentRecipeID)

	if not recipeInfo or recipeInfo.isGatheringRecipe then
		-- hide all modules
		CraftSim.MAIN:HideAllModules(true)
		return
	end

	local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

	print("Export Mode: " .. tostring(exportMode))

	---@type CraftSim.RecipeData
	local recipeData = nil
	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		---@type CraftSim.RecipeData
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
	local showCostDetails = true
	local showCraftQueue = true
	local showCraftBuffs = true
	local showCooldowns = true


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
	showCostDetails = showCostDetails and CraftSimOptions.modulesCostDetails
	showCraftQueue = showCraftQueue and CraftSimOptions.modulesCraftQueue
	showCraftBuffs = showCraftBuffs and CraftSimOptions.modulesCraftBuffs
	showCooldowns = showCooldowns and CraftSimOptions.modulesCooldowns

	CraftSim.FRAME:ToggleFrame(CraftSim.RECIPE_SCAN.frame, showRecipeScan)
	CraftSim.FRAME:ToggleFrame(CraftSim.CRAFTQ.frame, showCraftQueue)
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

	CraftSim.FRAME:ToggleFrame(CraftSim.COST_DETAILS.frame,
		showCostDetails and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.COST_DETAILS.frameWO,
		showCostDetails and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCostDetails then
		CraftSim.COST_DETAILS:UpdateDisplay(recipeData, exportMode)
	end

	if recipeData and showCraftResults then
		CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeData.recipeID)
	end

	-- AverageProfit Module
	CraftSim.FRAME:ToggleFrame(averageProfitFrame,
		showStatweights and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(averageProfitFrameWO,
		showStatweights and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showStatweights then
		local statWeights = CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData)

		if statWeights then
			CraftSim.AVERAGEPROFIT.FRAMES:UpdateDisplay(statWeights, recipeData.priceData.craftingCosts, exportMode)
		end

		CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
	end

	-- Cost Overview Module
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
		showMaterialOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(materialOptimizationFrameWO,
		showMaterialOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showMaterialOptimization then
		CraftSim.UTIL:StartProfiling("Reagent Optimization")
		local optimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData)
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
end

function CraftSim_OnAddonCompartmentClick()
	InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
end

function CraftSim.MAIN:InitializeMinimapButton()
	local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("CraftSimLDB", {
		type = "data source",
		--tooltip = "CraftSim",
		label = "CraftSim",
		tocname = "CraftSim",
		icon = "Interface\\Addons\\CraftSim\\Media\\Images\\craftsim",
		OnClick = function()
			-- local historyFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.HISTORY_FRAME)
			InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
		end,
	})

	CraftSimLibIconDB = CraftSimLibIconDB or {}

	CraftSim.LibIcon:Register("CraftSim", ldb, CraftSimLibIconDB)

	RunNextFrame(function()
		if CraftSimOptions.optionsHideMinimapButton then
			CraftSim.LibIcon:Hide("CraftSim")
		end
	end)
end
