---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.SPECIALIZATION_DATA
CraftSim.SPECIALIZATION_DATA = {}
CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT = {}
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN = {}
CraftSim.SPECIALIZATION_DATA.MIDNIGHT = {}

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.INIT : Frame
CraftSim.INIT = GUTIL:CreateRegistreeForEvents {
	"ADDON_LOADED",
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"TRADE_SKILL_FAVORITES_CHANGED",
}

GUTIL:RegisterCustomEvents(CraftSim.INIT, {
	"CRAFTSIM_OPEN_RECIPE_INFO_UPDATED",
	"CRAFTSIM_PROFESSION_READY",
	"CRAFTSIM_RECIPE_INFO_READY"
})

CraftSim.INIT.FRAMES = {}

---@type number?
CraftSim.INIT.visibleRecipeID = nil
CraftSim.INIT.initialLogin = false
CraftSim.INIT.isReloadingUI = false

local Logger = CraftSim.DEBUG:RegisterLogger("Init")

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

	local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
	CraftSim.PRE_CRAFT_BUFF_GATE:OnPlayerEnteringWorld(initialLogin, isReloadingUI)

	-- load craft queue
	CraftSim.CRAFTQ:InitializeCraftQueue()
end

---@param recipeInfo TradeSkillRecipeInfo?
function CraftSim.INIT:CRAFTSIM_OPEN_RECIPE_INFO_UPDATED(recipeInfo)
	-- if init turn sim mode off
	if CraftSim.SIMULATION_MODE.isActive then
		CraftSim.SIMULATION_MODE.isActive = false
		CraftSim.SIMULATION_MODE.UI.WORKORDER.toggleButton:SetChecked(false)
		CraftSim.SIMULATION_MODE.UI.NO_WORKORDER.toggleButton:SetChecked(false)
	end

	if recipeInfo and recipeInfo.recipeID then
		Logger:LogDebug("OpenRecipeChanged: {recipeID}", tostring(recipeInfo.recipeID))
		CraftSim.INIT.visibleRecipeID = recipeInfo.recipeID

		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
		local professionRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

		CraftSim.INIT:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs,
			professionInfo.profession)
		CraftSim.INIT:InitializeVisibleRecipeID(true)

		local recipeID = recipeInfo.recipeID

		-- this should happen exactly once on the first open recipe when a profession opened fresh after a client start
		-- otherwise it just always fizzles
		-- its better than to wait for multicraft stat each frame because this can actually happen in the same frame
		GUTIL:WaitForEvent("CRAFTING_DETAILS_UPDATE", function()
			if recipeID == CraftSim.INIT.visibleRecipeID then
				Logger:LogDebug("Multicraft Info Loaded")
				--CraftSim.INIT:InitializeVisibleRecipeID(true)
			end
		end, 1)
	end
end

local hookedEvent = false

local freshLoginRecall = true
local lastCallTime = 0
function CraftSim.INIT:InitializeVisibleRecipeID(isInit)
	local callTime = GetTime()
	if lastCallTime == callTime then
		Logger:LogVerbose("SAME FRAME, RETURN")
		return
	else
		Logger:LogVerbose("NEW FRAME, CONTINUE")
	end

	Logger:LogVerbose("lastCallTime: " .. tostring(lastCallTime))
	Logger:LogVerbose("callTime: " .. tostring(callTime))

	lastCallTime = callTime

	-- show or hide module windows based on window context and individual rules per module
	CraftSim.MODULES:UpdateVisibilityByContext()

	-- if freshLoginRecall and isInit then
	-- 	-- hide all frames to reduce flicker on fresh login recall
	-- 	freshLoginRecall = false

	-- 	-- hack to make frames appear after fresh login, when some info has not loaded yet although should have after blizzards' Init call
	-- 	C_Timer.After(0.1, function()
	-- 		CraftSim.INIT:InitializeVisibleRecipeID(true)
	-- 	end)
	-- 	return
	-- end

	-- Poll until profession data dependencies are ready, then trigger event for all listeners
	GUTIL:WaitFor(function()
		return self:IsProfessionReady()
	end, function()
		--CraftSim.MODULES:Update()
		-- if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_AUTO_UPDATE_MOXIE_VALUES") then
		-- 	CraftSim.CRAFTQ.UI:AutoUpdatePatronMoxieValuesFromSurplus()
		-- end
		-- do not do this all in the same frame to ease performance
		--RunNextFrame(CraftSim.RECIPE_SCAN.UpdateProfessionListByCache)
		GUTIL:TriggerCustomEvent("CRAFTSIM_PROFESSION_READY")
	end)
end

function CraftSim.INIT:CRAFTSIM_PROFESSION_READY()
	-- Poll until current recipe info of visibleRecipeID is available, then trigger event for all listeners
	GUTIL:WaitFor(function()
		local recipeID = CraftSim.INIT.visibleRecipeID
		if recipeID then
			local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
			return recipeInfo ~= nil and recipeInfo.categoryID
		end
		return false
	end, function()
		GUTIL:TriggerCustomEvent("CRAFTSIM_RECIPE_INFO_READY",
			C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.visibleRecipeID))
	end)
end

function CraftSim.INIT:CRAFTSIM_RECIPE_INFO_READY()
	-- build recipe data for the currently visible recipe and trigger update for all listeners
	CraftSim.DEBUG:StartProfiling("Build Visible RecipeData")
	local recipeData = CraftSim.MODULES:GetRecipeDataFromVisibleRecipe()
	CraftSim.DEBUG:StopProfiling("Build Visible RecipeData")

	if recipeData then
		CraftSim.MODULES.recipeData = recipeData
		GUTIL:TriggerCustomEvent("CRAFTSIM_RECIPE_DATA_READY", recipeData)
	end
end

function CraftSim.INIT:HookToEvents()
	if hookedEvent then
		return
	end
	hookedEvent = true

	local function OpenRecipeAllocationUpdated(self)
		if CraftSim.INIT.visibleRecipeID then
			GUTIL:TriggerCustomEvent("CRAFTSIM_OPEN_RECIPE_ALLOCATION_UPDATED", CraftSim.INIT.visibleRecipeID)
		end
	end

	local function OpenRecipeInfoUpdated(self, recipeInfo)
		if not self:IsVisible() then
			Logger:LogDebug("not visible, return")
			return
		end

		GUTIL:TriggerCustomEvent("CRAFTSIM_OPEN_RECIPE_INFO_UPDATED", recipeInfo)
	end

	local hookFrame = ProfessionsFrame.CraftingPage.SchematicForm
	local hookFrame2 = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm
	hooksecurefunc(hookFrame, "Init", OpenRecipeInfoUpdated)
	hooksecurefunc(hookFrame2, "Init", OpenRecipeInfoUpdated)

	-- events that update the current recipe's reagents should only update the modules' uis but not trigger a full recheck of the visible recipe
	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, OpenRecipeAllocationUpdated)
	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified,
		OpenRecipeAllocationUpdated)

	hookFrame2:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified,
		OpenRecipeAllocationUpdated)
	hookFrame2:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified,
		OpenRecipeAllocationUpdated)

	local recipeTab = ProfessionsFrame.TabSystem.tabs[1]
	local craftingOrderTab = ProfessionsFrame.TabSystem.tabs[3]

	recipeTab:HookScript("OnClick", OpenRecipeInfoUpdated)
	craftingOrderTab:HookScript("OnClick", OpenRecipeInfoUpdated)
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
	---@param onCraftData CraftSim.OnCraftData
	local function OnCraft(onCraftData)
		if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() then
			return
		end

		---@type CraftSim.RecipeData
		local recipeData
		-- if craftsim did not call the api and we do not have reagents, use the one from the gui
		-- still need to check if craft comes from different source (other addons for example)
		if not CraftSim.CRAFTQ.CraftSimCalledCraftRecipe and CraftSim.MODULES.recipeData and CraftSim.MODULES.recipeData.recipeID == onCraftData.recipeID then
			-- craft was most probably started via default gui craft button
			Logger:LogDebug("api was called via default gui")
			recipeData = CraftSim.MODULES.recipeData:Copy()
		else
			-- if it does not match with current recipe data, create a new one based on the data forwarded to the crafting api
			recipeData = onCraftData:CreateRecipeData()
			recipeData.craftListID = CraftSim.CRAFTQ.currentlyCraftedCraftListID
		end

		CraftSim.CRAFTQ:SetCraftedRecipeData(recipeData, onCraftData.amount, onCraftData.itemTargetLocation,
			onCraftData.isEnchant)
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
			local orderData = C_CraftingOrders.GetClaimedOrder()
			OnCraft(CraftSim.OnCraftData {
				recipeID = orderData.spellID,
				amount = 1,
				isRecraft = true,
				itemGUID = itemGUID,
				orderData = orderData,
				craftingReagentInfoTbl = craftingReagentTbl or {},
				concentrating = applyConcentration,
				callerData = {
					api = "RecraftRecipeForOrder",
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
		CraftSim.DEBUG:Init()
		CraftSim.DB:Init()
		CraftSim.INIT:InitializeMinimapButton()

		CraftSim.LOCAL:Init()

		CraftSim.GGUI:InitializePopup({
			backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
			sizeX = 300,
			sizeY = 300,
			title = "CraftSim Popup",
		})

		CraftSim.DEBUG.UI:Init()

		CraftSim.PRICE_API:InitPriceSource()
		CraftSim.INVENTORY_API:InitInventorySource()
		CraftSim.FRAME:InitNewsUI()

		-- Modules

		CraftSim.MODULES:Init()

		-- CraftSim.RECIPE_INFO.UI:Init()
		-- CraftSim.EXPLANATIONS.UI:Init()
		-- CraftSim.TOPGEAR.UI:Init()
		-- CraftSim.REAGENT_OPTIMIZATION.UI:Init()
		-- CraftSim.SPECIALIZATION_INFO.UI:Init()
		-- CraftSim.SPECIALIZATION_INFO.UI:HookSpecNodeTooltips()
		-- CraftSim.SIMULATION_MODE.UI:Init()
		-- CraftSim.RECIPE_SCAN.UI:Init()
		-- CraftSim.CRAFT_LOG.UI:Init()
		-- CraftSim.STATISTICS.UI:Init()
		-- CraftSim.CUSTOMER_HISTORY.UI:Init()
		-- CraftSim.CUSTOMER_HISTORY:Init()
		-- CraftSim.PRICING.UI:Init()
		-- CraftSim.SUPPORTERS.UI:Init()
		-- CraftSim.CRAFTQ.UI:Init()
		-- CraftSim.CRAFT_BUFFS.UI:Init()
		-- CraftSim.COOLDOWNS.UI:Init()
		-- CraftSim.CONCENTRATION_TRACKER.UI:Init() -- done
		-- CraftSim.DISENCHANT.UI:Init() -- done

		CraftSim.INIT:HookToEvents()
		CraftSim.INIT:HookToProfessionsFrame()
		CraftSim.INIT:HookToConcentrationButtons()
		CraftSim.INIT:HookToProfessionUnlearnedFunction()
		CraftSim.INIT:HandleAuctionatorHooks()
		CraftSim.INIT:InitCraftRecipeHooks()

		CraftSim.ITEM_TOOLTIPS:HookItemTooltips()

		CraftSim.CONTROL_PANEL.UI:Init()
		CraftSim.INIT:InitStaticPopups()

		CraftSim.OPTIONS:Init()

		CraftSim.MODULES:RestorePositions()
	end
end

function CraftSim.INIT:HandleAuctionatorHooks()
	if Auctionator then ---@diagnostic disable-line: undefined-global
		---@diagnostic disable-next-line: undefined-global
		Auctionator.API.v1.RegisterForDBUpdate(CraftSimAddonName, function()
			Logger:LogDebug("Auctionator DB Update")
			CraftSim.INIT:InitializeVisibleRecipeID(false)
		end)
	end
end

local professionFrameHooked = false
local craftingOrdersPreloadedThisSession = {}
function CraftSim.INIT:HookToProfessionsFrame()
	if professionFrameHooked then
		return
	end
	professionFrameHooked = true

	ProfessionsFrame:HookScript("OnShow",
		function()
			CraftSim.MODULES:ShowRecipeIndependentModules()

			--CraftSim.DEBUG:StartProfiling("Update Customer History")
			--CraftSim.CUSTOMER_HISTORY.UI:UpdateDisplay()
			--CraftSim.DEBUG:StopProfiling("Update Customer History")
			--CraftSim.CRAFTQ.UI:UpdateDisplay()
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

			-- Force-load crafting orders on the first ProfessionFrame open after login.
			-- Blizzard only fetches orders when OrdersPage:OnShow() fires (tab 3 click).
			-- Clicking tab 3 then immediately back to tab 1 within the same RunNextFrame
			RunNextFrame(function()
				local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
				local professionID = professionInfo and professionInfo.professionID or nil
				-- triggers the server request without any visible UI flicker.
				if professionID and (not craftingOrdersPreloadedThisSession[professionID]
						and C_CraftingOrders.ShouldShowCraftingOrderTab()
						and ProfessionsFrame.isCraftingOrdersTabEnabled) then
					if ProfessionsFrame:IsVisible() and ProfessionsFrame.CraftingPage:IsVisible() then
						craftingOrdersPreloadedThisSession[professionID] = true
						ProfessionsFrame:GetTabButton(3):Click() -- 3 is Crafting Orders Tab; triggers OrdersPage:OnShow() → order load
						ProfessionsFrame:GetTabButton(1):Click() -- 1 is Crafting Tab; switch back
					end
					local ms = CraftSim.DEBUG:StopProfiling("Preload Crafting Orders")
					Logger:LogDebug("Preloaded crafting orders in " .. ms .. " ms")
					GUTIL:TriggerCustomEvent("CRAFTSIM_CRAFTING_ORDERS_PRELOADED")
				end
			end)
		end)

	local function refreshAddWorkOrdersButtonDeferred()
		RunNextFrame(function()
			if CraftSim.CRAFTQ.frame and CraftSim.CRAFTQ.frame:IsVisible() then
				CraftSim.MODULES:RefreshAddWorkOrdersButtonState()
			end
		end)
	end

	if ProfessionsFrame.OrdersPage then
		ProfessionsFrame.OrdersPage:HookScript("OnShow", refreshAddWorkOrdersButtonDeferred)
	end
	local craftingOrdersTab = ProfessionsFrame.TabSystem and ProfessionsFrame.TabSystem.tabs[3]
	if craftingOrdersTab then
		craftingOrdersTab:HookScript("OnClick", refreshAddWorkOrdersButtonDeferred)
	end

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
		CraftSim.MODULES:Update()
	end)

	ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details.CraftingChoicesContainer
		.ConcentrateContainer
		.ConcentrateToggleButton:HookScript("OnClick", function()
		CraftSim.MODULES:Update()
	end)
end

function CraftSim.INIT:PLAYER_LOGIN()
	CraftSim.SLASH:Init()

	-- show one time note
	if CraftSim.DB.OPTIONS:Get("SHOW_NEWS") then
		CraftSim.NEWS:ShowNews(false)
	end
end

function CraftSim_OnAddonCompartmentClick()
	Settings.OpenToCategory(CraftSim.OPTIONS.category:GetID())
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
			Settings.OpenToCategory(CraftSim.OPTIONS.category:GetID())
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
	Logger:LogDebug("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

	CraftSim.DEBUG:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
	for _, recipeID in ipairs(professionRecipeIDs) do
		local concentrating = false
		C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, nil, concentrating)
	end

	CraftSim.DEBUG:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

	CraftSim.DB.MULTICRAFT_PRELOAD:Save(professionID, true)
end

function CraftSim.INIT:IsProfessionReady()
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
	local profession = professionInfo and professionInfo.profession or nil
	local profession_available = profession ~= nil
	local tradeSkillRdy = C_TradeSkillUI.IsTradeSkillReady()
	local operationInfosPreloaded = profession_available and CraftSim.DB.MULTICRAFT_PRELOAD:Get(profession)
	return profession_available and tradeSkillRdy and operationInfosPreloaded
end
