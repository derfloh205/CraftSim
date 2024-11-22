---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.SPECIALIZATION_DATA
CraftSim.SPECIALIZATION_DATA = {}
CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT = {}
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN = {}

CraftSim.LibCompress = LibStub:GetLibrary("LibCompress")
CraftSim.LibIcon = LibStub("LibDBIcon-1.0")

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.INIT : Frame
CraftSim.INIT = GUTIL:CreateRegistreeForEvents { "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "TRADE_SKILL_FAVORITES_CHANGED" }

CraftSim.INIT.FRAMES = {}

---@type CraftSim.RecipeData?
CraftSim.INIT.currentRecipeData = nil
---@type number?
CraftSim.INIT.currentRecipeID = nil
CraftSim.INIT.initialLogin = false
CraftSim.INIT.isReloadingUI = false

local print = CraftSim.DEBUG:RegisterDebugID("Init")

function CraftSim.INIT:TRADE_SKILL_FAVORITES_CHANGED(isFavoriteNow, recipeID)
	-- adapt cached values
	local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()

	if not professionInfo then return end

	local profession = professionInfo.profession

	if not profession then return end



	CraftSim.DB.CRAFTER:UpdateFavoriteRecipe(crafterUID, profession, recipeID, isFavoriteNow)
end

function CraftSim.INIT:PLAYER_ENTERING_WORLD(initialLogin, isReloadingUI)
	CraftSim.INIT.initialLogin = initialLogin
	CraftSim.INIT.isReloadingUI = isReloadingUI

	-- for any processes that may only happen once a session e.g.
	if initialLogin then
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

function CraftSim.INIT:HookToEvents()
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
			CraftSim.SIMULATION_MODE.UI.WORKORDER.toggleButton:SetChecked(false)
			CraftSim.SIMULATION_MODE.UI.NO_WORKORDER.toggleButton:SetChecked(false)
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
	local print = CraftSim.DEBUG:RegisterDebugID("Init.InitCraftRecipeHooks")

	---@param onCraftData CraftSim.OnCraftData
	local function OnCraft(onCraftData)
		if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() then
			return
		end

		---@type CraftSim.RecipeData
		local recipeData
		-- if craftsim did not call the api and we do not have reagents, use the one from the gui
		-- still need to check if craft comes from different source (other addons for example)
		if not CraftSim.CRAFTQ.CraftSimCalledCraftRecipe and CraftSim.INIT.currentRecipeData and CraftSim.INIT.currentRecipeData.recipeID == onCraftData.recipeID then
			-- craft was most probably started via default gui craft button
			print("api was called via default gui")
			recipeData = CraftSim.INIT.currentRecipeData:Copy()
		else
			-- if it does not match with current recipe data, create a new one based on the data forwarded to the crafting api
			recipeData = onCraftData:CreateRecipeData()
		end

		CraftSim.CRAFTQ:SetCraftedRecipeData(recipeData, onCraftData.amount, onCraftData.itemTargetLocation)
		CraftSim.CRAFT_LOG:SetCraftedRecipeData(recipeData)
	end

	hooksecurefunc(C_TradeSkillUI, "CraftRecipe",
		function(recipeID, amount, craftingReagentInfoTbl, recipeLevel, orderID, concentrating)
			OnCraft(CraftSim.OnCraftData {
				recipeID = recipeID,
				amount = amount or 1,
				craftingReagentInfoTbl = craftingReagentInfoTbl or {},
				recipeLevel = recipeLevel,
				orderData = orderID and C_CraftingOrders.GetClaimedOrder(),
				concentrating = concentrating,
				callerData = {
					api = "CraftRecipe",
					params = { recipeID, amount, craftingReagentInfoTbl, recipeLevel, orderID, concentrating },
				}
			})
		end)
	hooksecurefunc(C_TradeSkillUI, "CraftEnchant",
		function(recipeID, amount, craftingReagentInfoTbl, enchantItemLocation, concentrating)
			OnCraft(CraftSim.OnCraftData {
				recipeID = recipeID,
				amount = amount or 1,
				craftingReagentInfoTbl = craftingReagentInfoTbl or {},
				itemTargetLocation = enchantItemLocation,
				isEnchant = true,
				concentrating = concentrating,
				callerData = {
					api = "CraftEnchant",
					params = { recipeID, amount, craftingReagentInfoTbl, enchantItemLocation, concentrating },
				}
			})
		end)
	hooksecurefunc(C_TradeSkillUI, "RecraftRecipe",
		function(itemGUID, craftingReagentTbl, removedModifications, applyConcentration)
			OnCraft(CraftSim.OnCraftData {
				recipeID = select(1, C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID)),
				amount = 1,
				isRecraft = true,
				itemGUID = itemGUID,
				craftingReagentInfoTbl = craftingReagentTbl or {},
				concentrating = applyConcentration,
				callerData = {
					api = "RecraftRecipe",
					params = { itemGUID, craftingReagentTbl, removedModifications, applyConcentration },
				}
			})
		end)
	hooksecurefunc(C_TradeSkillUI, "RecraftRecipeForOrder",
		function(orderID, itemGUID, craftingReagentTbl, removedModifications, applyConcentration)
			OnCraft(CraftSim.OnCraftData {
				recipeID = select(1, C_TradeSkillUI.GetOriginalCraftRecipeID(itemGUID)),
				amount = 1,
				isRecraft = true,
				itemGUID = itemGUID,
				orderData = C_CraftingOrders.GetClaimedOrder(),
				craftingReagentInfoTbl = craftingReagentTbl or {},
				concentrating = applyConcentration,
				callerData = {
					api = "RecraftRecipe",
					params = { orderID, itemGUID, craftingReagentTbl, removedModifications, applyConcentration },
				}
			})
		end)
	hooksecurefunc(C_TradeSkillUI, "CraftSalvage",
		---@param recipeID RecipeID
		---@param amount number?
		---@param itemTargetLocation ItemLocationMixin
		---@param craftingReagentTbl CraftingReagentInfo[]?
		---@param applyConcentration boolean
		function(recipeID, amount, itemTargetLocation, craftingReagentTbl, applyConcentration)
			OnCraft(CraftSim.OnCraftData {
				recipeID = recipeID,
				amount = amount or 1,
				itemTargetLocation = itemTargetLocation,
				craftingReagentInfoTbl = craftingReagentTbl or {},
				concentrating = applyConcentration,
				callerData = {
					api = "CraftSalvage",
					params = { recipeID, amount, itemTargetLocation, craftingReagentTbl, applyConcentration },
				}
			})
		end)
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

		CraftSim.DEBUG.UI:Init()

		CraftSim.PRICE_API:InitPriceSource()


		CraftSim.AVERAGEPROFIT.UI:Init()
		CraftSim.EXPLANATIONS.UI:Init()
		CraftSim.TOPGEAR.UI:Init()
		CraftSim.PRICE_DETAILS.UI:Init()
		CraftSim.REAGENT_OPTIMIZATION.UI:Init()
		CraftSim.SPECIALIZATION_INFO.UI:Init()
		CraftSim.FRAME:InitOneTimeNoteFrame()
		CraftSim.SIMULATION_MODE.UI:Init()
		CraftSim.PRICE_OVERRIDE.UI:Init()
		CraftSim.RECIPE_SCAN.UI:Init()
		CraftSim.CRAFT_LOG.UI:Init()
		CraftSim.STATISTICS.UI:Init()
		CraftSim.CUSTOMER_HISTORY.UI:Init()
		CraftSim.COST_OPTIMIZATION.UI:Init()
		CraftSim.SUPPORTERS.UI:Init()
		CraftSim.CRAFTQ.UI:Init()
		CraftSim.CRAFT_BUFFS.UI:Init()
		CraftSim.COOLDOWNS.UI:Init()
		CraftSim.CONCENTRATION_TRACKER.UI:Init()

		CraftSim.INIT:HookToEvents()
		CraftSim.INIT:HookToProfessionsFrame()
		CraftSim.INIT:HookToConcentrationButtons()
		CraftSim.INIT:HookToProfessionUnlearnedFunction()
		CraftSim.INIT:HandleAuctionatorHooks()
		CraftSim.INIT:InitCraftRecipeHooks()

		CraftSim.CONTROL_PANEL.UI:Init()
		CraftSim.INIT:InitStaticPopups()


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
			CraftSim.DEBUG:StartProfiling("Update Customer History")
			CraftSim.CUSTOMER_HISTORY.UI:UpdateDisplay()
			CraftSim.DEBUG:StopProfiling("Update Customer History")
			CraftSim.CRAFTQ.UI:UpdateDisplay()
			CraftSim.INIT.lastRecipeID = nil
			if CraftSim.DB.OPTIONS:Get("OPEN_LAST_RECIPE") then
				C_Timer.After(1, function()
					local professionInfo = ProfessionsFrame:GetProfessionInfo()
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

function CraftSim.INIT:HookToProfessionUnlearnedFunction()
	-- will be base skill line id

	hooksecurefunc("AbandonSkill", function(skilllineID)
		local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skilllineID)
		if professionInfo then
			local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
			CraftSim.DEBUG:SystemPrint(f.l("CraftSim: " ..
				"Removing Cached Data for ") .. crafterUID .. " - " .. f.bb(professionInfo.professionName))
			local profession = professionInfo.profession

			CraftSim.DB.CRAFTER:RemoveCrafterProfessionData(crafterUID, profession)
		end
	end)
end

local concentrationButtonHooked = false
function CraftSim.INIT:HookToConcentrationButtons()
	if concentrationButtonHooked then
		return
	end
	concentrationButtonHooked = true

	ProfessionsFrame.CraftingPage.SchematicForm.Details.CraftingChoicesContainer.ConcentrateContainer
		.ConcentrateToggleButton:HookScript("OnClick", function()
		self:TriggerModulesByRecipeType()
	end)

	ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details.CraftingChoicesContainer
		.ConcentrateContainer
		.ConcentrateToggleButton:HookScript("OnClick", function()
		self:TriggerModulesByRecipeType()
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
			if rest == "recipeids" then
				local recipeIDs = CraftSim.UTIL:ExportRecipeIDsForExpacCSV()
				CraftSim.UTIL:ShowTextCopyBox(recipeIDs)
			elseif CraftSim.INIT.currentRecipeData then
				local json = CraftSim.INIT.currentRecipeData:GetJSON()
				CraftSim.UTIL:ShowTextCopyBox(json)
			end
		elseif command == "resetdb" then
			CraftSimDB = nil
			C_UI.Reload()
		elseif command == "quickbuy" then
			CraftSim.CRAFTQ:AuctionatorQuickBuy()
		else
			-- open options if any other command or no command is given
			Settings.OpenToCategory(CraftSim.OPTIONS.category.ID)
		end
	end

	-- show one time note
	if CraftSim.DB.OPTIONS:Get("SHOW_NEWS") then
		CraftSim.NEWS:ShowNews()
	end
end

function CraftSim.INIT:HideAllModules(keepControlPanel)
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
	local reagentOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
	local reagentOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
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
	CraftSim.CRAFT_LOG.logFrame:Hide()
	CraftSim.CRAFT_LOG.advFrame:Hide()
	CraftSim.CONCENTRATION_TRACKER.frame:Hide()
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
	reagentOptimizationFrame:Hide()
	reagentOptimizationFrameWO:Hide()
	-- hide sim mode toggle button
	CraftSim.SIMULATION_MODE.UI.WORKORDER.toggleButton:Hide()
	CraftSim.SIMULATION_MODE.UI.NO_WORKORDER.toggleButton:Hide()
	CraftSim.EXPLANATIONS.frame:Hide()
	CraftSim.STATISTICS.UI:SetVisible(false)

	CraftSim.CRAFTQ.queueRecipeButton:Hide()
	CraftSim.CRAFTQ.queueRecipeButtonWO:Hide()
	CraftSim.CRAFTQ.queueRecipeButtonOptions:Hide()
	CraftSim.CRAFTQ.queueRecipeButtonOptionsWO:Hide()
end

function CraftSim.INIT:TriggerModulesByRecipeType()
	if not ProfessionsFrame:IsVisible() then
		return
	end

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
	local reagentOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
	local reagentOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
	local craftBuffsFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_BUFFS)
	local craftBuffsFrameWO = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_BUFFS_WORKORDER)

	-- pre hide
	CraftSim.CRAFTQ.queueRecipeButton:Hide()
	CraftSim.CRAFTQ.queueRecipeButtonWO:Hide()
	CraftSim.CRAFTQ.queueRecipeButtonOptions:Hide()
	CraftSim.CRAFTQ.queueRecipeButtonOptionsWO:Hide()
	CraftSim.SIMULATION_MODE.UI.WORKORDER.toggleButton:Hide()
	CraftSim.SIMULATION_MODE.UI.NO_WORKORDER.toggleButton:Hide()

	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		CraftSim.INIT:HideAllModules()
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()
	CraftSim.CRAFTQ.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_QUEUE"))
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
	CraftSim.CRAFTQ.frame.content.queueTab.content.addWorkOrdersButton:SetEnabled(professionInfo and
		professionInfo.profession and C_TradeSkillUI
		.IsNearProfessionSpellFocus(professionInfo.profession))

	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.currentRecipeID)

	if not recipeInfo or recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then
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

		recipeData = CraftSim.RecipeData({
			recipeID = recipeInfo.recipeID,
			orderData = isWorkOrder and ProfessionsFrame.OrdersPage.OrderView.order,
			isRecraft = isRecraft,
		})

		if recipeData then
			-- Set Reagents based on visibleFrame and load equipped profession gear set
			recipeData:SetAllReagentsBySchematicForm()
			recipeData:SetConcentrationBySchematicForm()
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
	local showCustomerHistory = true
	local showCostOptimization = true
	local showCraftBuffs = true
	local showCooldowns = true
	local showExplanations = true
	local showStatistics = true
	local showConcentrationTracker = true

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
	showSimulationMode = not recipeData.isOldWorldRecipe and not recipeData.isBaseRecraftRecipe

	showReagentOptimization = showReagentOptimization and CraftSim.DB.OPTIONS:Get("MODULE_REAGENT_OPTIMIZATION")
	showAverageProfit = showAverageProfit and CraftSim.DB.OPTIONS:Get("MODULE_AVERAGE_PROFIT")
	showTopGear = showTopGear and CraftSim.DB.OPTIONS:Get("MODULE_TOP_GEAR")
	showCostOverview = showCostOverview and CraftSim.DB.OPTIONS:Get("MODULE_COST_OVERVIEW")
	showSpecInfo = showSpecInfo and CraftSim.DB.OPTIONS:Get("MODULE_SPEC_INFO")
	showPriceOverride = showPriceOverride and CraftSim.DB.OPTIONS:Get("MODULE_PRICE_OVERRIDE")
	showRecipeScan = showRecipeScan and CraftSim.DB.OPTIONS:Get("MODULE_RECIPE_SCAN")
	showCraftResults = showCraftResults and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG")
	showCustomerHistory = showCustomerHistory and CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_HISTORY")
	showCostOptimization = showCostOptimization and CraftSim.DB.OPTIONS:Get("MODULE_COST_OPTIMIZATION")
	showCraftBuffs = showCraftBuffs and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_BUFFS")
	showCooldowns = showCooldowns and CraftSim.DB.OPTIONS:Get("MODULE_COOLDOWNS")
	showExplanations = showExplanations and CraftSim.DB.OPTIONS:Get("MODULE_EXPLANATIONS")
	showStatistics = showStatistics and CraftSim.DB.OPTIONS:Get("MODULE_STATISTICS")

	CraftSim.RECIPE_SCAN.frame:SetVisible(showRecipeScan)
	CraftSim.EXPLANATIONS.frame:SetVisible(showExplanations)
	CraftSim.CRAFT_LOG.logFrame:SetVisible(showCraftResults)
	CraftSim.CRAFT_LOG.advFrame:SetVisible(CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SHOW_ADV_LOG"))
	CraftSim.CUSTOMER_HISTORY.frame:SetVisible(showCustomerHistory)
	CraftSim.COOLDOWNS.frame:SetVisible(showCooldowns)
	CraftSim.CONCENTRATION_TRACKER.frame:SetVisible(showConcentrationTracker)

	if showConcentrationTracker then
		CraftSim.CONCENTRATION_TRACKER.UI:UpdateDisplay()
	end

	if showCooldowns then
		CraftSim.COOLDOWNS.UI:UpdateDisplay()
	end

	-- update CraftQ Display (e.g. cause of profession gear changes)
	CraftSim.CRAFTQ.UI:UpdateDisplay()
	CraftSim.CRAFTQ.UI:UpdateAddOpenRecipeButton(recipeData)

	-- Simulation Mode (always update first because it changes recipeData based on simMode inputs)
	showSimulationMode = (showSimulationMode and recipeData and not recipeData.isSalvageRecipe) or false
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.UI.WORKORDER.toggleButton,
		showSimulationMode and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.UI.NO_WORKORDER.toggleButton,
		showSimulationMode and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.SIMULATION_MODE.UI:UpdateVisibility() -- show sim mode frames depending if active or not
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
		CraftSim.COST_OPTIMIZATION:UpdateDisplay(recipeData)
	end

	if recipeData and showCraftResults then
		CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(recipeData.recipeID)
	end

	-- AverageProfit Module
	CraftSim.FRAME:ToggleFrame(averageProfitFrame,
		showAverageProfit and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(averageProfitFrameWO,
		showAverageProfit and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showAverageProfit then
		local statWeights = CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData)

		if statWeights then
			CraftSim.AVERAGEPROFIT.UI:UpdateDisplay(recipeData, statWeights)
		end
	end

	-- Statistics Module
	CraftSim.STATISTICS.UI:SetVisible(showStatistics, exportMode)
	if recipeData and showStatistics then
		CraftSim.STATISTICS.UI:UpdateDisplay(recipeData)
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
		CraftSim.PRICE_OVERRIDE.UI:UpdateDisplay(recipeData, exportMode)
	end

	-- Reagent Optimization Module
	CraftSim.FRAME:ToggleFrame(reagentOptimizationFrame,
		showReagentOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(reagentOptimizationFrameWO,
		showReagentOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showReagentOptimization then
		CraftSim.DEBUG:StartProfiling("Reagent Optimization")
		local maxOptimizationQuality = CraftSim.DB.OPTIONS:Get(
			"REAGENT_OPTIMIZATION_RECIPE_MAX_OPTIMIZATION_QUALITY")[recipeData.recipeID] or recipeData.maxQuality

		local reagentOptimizedRecipeData = recipeData:Copy()
		reagentOptimizedRecipeData:OptimizeReagents {
			maxQuality = maxOptimizationQuality,
			highestProfit = CraftSim.DB.OPTIONS:Get("REAGENT_OPTIMIZATION_TOP_PROFIT_ENABLED")
		}
		CraftSim.REAGENT_OPTIMIZATION.UI:UpdateReagentDisplay(reagentOptimizedRecipeData)
		CraftSim.DEBUG:StopProfiling("Reagent Optimization")
	end

	-- Top Gear Module
	CraftSim.FRAME:ToggleFrame(topgearFrame, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(topgearFrameWO, showTopGear and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showTopGear then
		CraftSim.TOPGEAR.UI:UpdateModeDropdown(recipeData, exportMode)
		if CraftSim.DB.OPTIONS:Get("TOP_GEAR_AUTO_UPDATE") then
			CraftSim.DEBUG:StartProfiling("Top Gear")
			CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
			CraftSim.DEBUG:StopProfiling("Top Gear")
		else
			CraftSim.TOPGEAR.UI:ClearTopGearDisplay(recipeData, true, exportMode)
		end
	end

	-- SpecInfo Module
	CraftSim.FRAME:ToggleFrame(specInfoFrame,
		showSpecInfo and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(specInfoFrameWO,
		showSpecInfo and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showSpecInfo then
		CraftSim.SPECIALIZATION_INFO.UI:UpdateInfo(recipeData)
	end

	-- CraftBuffs Module
	CraftSim.FRAME:ToggleFrame(craftBuffsFrame,
		showCraftBuffs and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(craftBuffsFrameWO,
		showCraftBuffs and recipeData and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCraftBuffs then
		CraftSim.CRAFT_BUFFS.UI:UpdateDisplay(recipeData, exportMode)
	end

	CraftSim.INIT.lastRecipeID = CraftSim.INIT.currentRecipeID
end

function CraftSim_OnAddonCompartmentClick()
	Settings.OpenToCategory(CraftSim.OPTIONS.category.ID)
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
			Settings.OpenToCategory(CraftSim.OPTIONS.category.ID)
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
		local concentrating = false
		C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, nil, concentrating)
	end

	CraftSim.DEBUG:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

	CraftSim.DB.MULTICRAFT_PRELOAD:Save(professionID, true)
end
