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
CraftSim.INIT = GUTIL:CreateRegistreeForEvents { "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "TRADE_SKILL_FAVORITES_CHANGED" }

CraftSim.INIT.FRAMES = {}

---@type number?
CraftSim.INIT.visibleRecipeID = nil
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
function CraftSim.INIT:InitializeVisibleRecipeID(isInit)
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

	CraftSim.MODULES:Hide(true)

	if freshLoginRecall and isInit then
		-- hide all frames to reduce flicker on fresh login recall
		freshLoginRecall = false

		-- hack to make frames appear after fresh login, when some info has not loaded yet although should have after blizzards' Init call
		C_Timer.After(0.1, function()
			CraftSim.INIT:InitializeVisibleRecipeID(true)
		end)
		return
	end

	GUTIL:WaitFor(function()
		if C_TradeSkillUI.IsTradeSkillReady() then
			local recipeID = CraftSim.INIT.visibleRecipeID
			if recipeID then
				local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
				return recipeInfo ~= nil and recipeInfo.categoryID
			end
		end
		return false
	end, function()
		CraftSim.DEBUG:StartProfiling("MODULES UPDATE")
		CraftSim.MODULES:UpdateUI()
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

	local function UpdateUI(self)
		if CraftSim.INIT.visibleRecipeID then
			CraftSim.MODULES:UpdateUI()
		end
	end

	local function InitNewRecipeID(self, recipeInfo)
		print("InitNewRecipeID called")
		if not self:IsVisible() then
			print("not visible, return")
			return
		end
		-- if init turn sim mode off
		if CraftSim.SIMULATION_MODE.isActive then
			CraftSim.SIMULATION_MODE.isActive = false
			CraftSim.SIMULATION_MODE.UI.WORKORDER.toggleButton:SetChecked(false)
			CraftSim.SIMULATION_MODE.UI.NO_WORKORDER.toggleButton:SetChecked(false)
		end

		if recipeInfo and recipeInfo.recipeID then
			print("Init: " .. tostring(recipeInfo.recipeID))
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
					print("Multicraft Info Loaded")
					CraftSim.INIT:InitializeVisibleRecipeID(true)
				end
			end, 1)
		elseif recipeInfo == nil then
			print("Hide all frames recipeInfo nil")
			CraftSim.MODULES:Hide(true, true)
		else
			print("Updating UI without recipeID")
			CraftSim.MODULES:UpdateUI()
		end
	end

	local hookFrame = ProfessionsFrame.CraftingPage.SchematicForm
	local hookFrame2 = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm
	hooksecurefunc(hookFrame, "Init", InitNewRecipeID)
	hooksecurefunc(hookFrame2, "Init", InitNewRecipeID)

	-- events that update the current recipe's reagents should only update the modules' uis but not trigger a full recheck of the visible recipe
	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, UpdateUI)
	hookFrame:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, UpdateUI)

	hookFrame2:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, UpdateUI)
	hookFrame2:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, UpdateUI)

	local recipeTab = ProfessionsFrame.TabSystem.tabs[1]
	local craftingOrderTab = ProfessionsFrame.TabSystem.tabs[3]

	recipeTab:HookScript("OnClick", InitNewRecipeID)
	craftingOrderTab:HookScript("OnClick", InitNewRecipeID)
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
		if not CraftSim.CRAFTQ.CraftSimCalledCraftRecipe and CraftSim.MODULES.recipeData and CraftSim.MODULES.recipeData.recipeID == onCraftData.recipeID then
			-- craft was most probably started via default gui craft button
			print("api was called via default gui")
			recipeData = CraftSim.MODULES.recipeData:Copy()
		else
			-- if it does not match with current recipe data, create a new one based on the data forwarded to the crafting api
			recipeData = onCraftData:CreateRecipeData()
			recipeData.craftListID = CraftSim.CRAFTQ.currentlyCraftedCraftListID
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
		CraftSim.SPECIALIZATION_INFO.UI:HookSpecNodeTooltips()

		CraftSim.CONTROL_PANEL.UI:Init()
		CraftSim.INIT:InitStaticPopups()


		CraftSim.CUSTOMER_HISTORY:Init()

		CraftSim.OPTIONS:Init()


		CraftSim.FRAME:RestoreModulePositions()
	end
end

function CraftSim.INIT:HandleAuctionatorHooks()
	if Auctionator then ---@diagnostic disable-line: undefined-global
		---@diagnostic disable-next-line: undefined-global
		Auctionator.API.v1.RegisterForDBUpdate(CraftSimAddonName, function()
			print("Auctionator DB Update")
			CraftSim.INIT:InitializeVisibleRecipeID(false)
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
			-- Restore recipe-independent module visibility immediately,
			-- since SchematicForm:Init or tab OnClick may not fire
			-- (e.g. opening on the Crafting Orders tab with no order selected)
			if not (C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild()) then
				CraftSim.CONTROL_PANEL.frame:Show()
				CraftSim.CRAFTQ.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_QUEUE"))
				CraftSim.RECIPE_SCAN.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_RECIPE_SCAN"))
				CraftSim.CRAFT_LOG.logFrame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG"))
				CraftSim.CUSTOMER_HISTORY.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_HISTORY"))
				CraftSim.COOLDOWNS.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_COOLDOWNS"))
				CraftSim.CONCENTRATION_TRACKER.frame:SetVisible(true)
			end

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
		CraftSim.MODULES:UpdateUI()
	end)

	ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details.CraftingChoicesContainer
		.ConcentrateContainer
		.ConcentrateToggleButton:HookScript("OnClick", function()
		CraftSim.MODULES:UpdateUI()
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
			elseif CraftSim.MODULES.recipeData then
				local json = CraftSim.MODULES.recipeData:GetJSON()
				CraftSim.UTIL:ShowTextCopyBox(json)
			end
		elseif command == "resetdb" then
			if CraftSimDB then
				wipe(CraftSimDB)
			end
			C_UI.Reload()
		elseif command == "quickbuy" then
			CraftSim.CRAFTQ:AuctionatorQuickBuy()
		else
			-- open options if any other command or no command is given
			Settings.OpenToCategory(CraftSim.OPTIONS.category:GetID())
		end
	end

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
	print("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

	CraftSim.DEBUG:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
	for _, recipeID in ipairs(professionRecipeIDs) do
		local concentrating = false
		C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, nil, concentrating)
	end

	CraftSim.DEBUG:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

	CraftSim.DB.MULTICRAFT_PRELOAD:Save(professionID, true)
end
