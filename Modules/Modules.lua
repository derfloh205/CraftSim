---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class Craftsim.Modules
CraftSim.MODULES = {}

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

local Logger = CraftSim.DEBUG:RegisterLogger("Modules")

---@type CraftSim.RecipeData?
CraftSim.MODULES.recipeData = nil

---@param keepControlPanel boolean?
---@param keepCraftQ boolean?
function CraftSim.MODULES:Hide(keepControlPanel, keepCraftQ)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
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
	if not keepCraftQ then
		CraftSim.CRAFTQ.frame:Hide()
	end
	local patronRewardValuesFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES,
		CraftSim.CONST.FRAMES.CRAFTQUEUE_PATRON_REWARD_VALUES)
	if patronRewardValuesFrame then
		patronRewardValuesFrame:Hide()
	end
	-- hide all modules
	CraftSim.RECIPE_SCAN.frame:Hide()
	CraftSim.CRAFT_BUFFS.frame:Hide()
	CraftSim.CRAFT_BUFFS.frameWO:Hide()
	CraftSim.COOLDOWNS.frame:Hide()
	CraftSim.CRAFT_LOG.logFrame:Hide()
	CraftSim.CRAFT_LOG.advFrame:Hide()
	CraftSim.CONCENTRATION_TRACKER.frame:Hide()
	customerHistoryFrame:Hide()
	specInfoFrame:Hide()
	specInfoFrameWO:Hide()
	averageProfitFrame:Hide()
	averageProfitFrameWO:Hide()
	topgearFrame:Hide()
	topgearFrameWO:Hide()
	CraftSim.PRICING.frame:Hide()
	CraftSim.PRICING.frameWO:Hide()
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

--- Shows recipe-independent modules based on saved options.
--- Called from ProfessionsFrame OnShow to ensure modules are visible even when
--- SchematicForm:Init or tab OnClick does not fire (e.g. opening on the Crafting Orders tab).
function CraftSim.MODULES:ShowRecipeIndependentModules()
	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()
	CraftSim.CRAFTQ.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_QUEUE"))
	CraftSim.RECIPE_SCAN.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_RECIPE_SCAN"))
	CraftSim.CRAFT_LOG.logFrame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG"))
	CraftSim.CUSTOMER_HISTORY.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_HISTORY"))
	CraftSim.COOLDOWNS.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_COOLDOWNS"))
	CraftSim.CONCENTRATION_TRACKER.frame:SetVisible(true)

	CraftSim.MODULES:RefreshAddWorkOrdersButtonState()
end

--- Updates only the Craft Queue "add work orders" enabled state (near table or Crafting Orders tab available).
function CraftSim.MODULES:RefreshAddWorkOrdersButtonState()
	-- do not alter state if we are currently in a queueing process
	if CraftSim.CRAFTQ.queuingWorkOrders then
		return
	end
	local craftQ = CraftSim.CRAFTQ.frame
	if not craftQ or not craftQ.content or not craftQ.content.queueTab or not craftQ.content.queueTab.content then
		return
	end
	local btn = craftQ.content.queueTab.content.addWorkOrdersButton
	if not btn then
		return
	end
	btn:SetEnabled(CraftSim.UTIL:ShouldEnableCraftQueueAddWorkOrdersButton())
end

---@return CraftSim.RecipeData? recipeData
function CraftSim.MODULES:GetRecipeDataFromVisibleRecipe()
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.visibleRecipeID)

	if not recipeInfo then
		return nil
	end

	local schematicForm = CraftSim.UTIL:GetSchematicFormByVisibility()
	if not schematicForm then
		Logger:LogDebug("CraftSim MODULES: No SchematicForm Visible")
		return nil
	end

	local currentTransaction = schematicForm:GetTransaction()
	if not currentTransaction then
		Logger:LogDebug("CraftSim MODULES: SchematicForm without transaction!")
		return nil
	end

	local isRecraft = currentTransaction:GetRecraftAllocation() ~= nil
	local isWorkOrder = CraftSim.UTIL:IsWorkOrder()

	local recipeData = CraftSim.RecipeData({
		recipeID = recipeInfo.recipeID,
		orderData = isWorkOrder and ProfessionsFrame.OrdersPage.OrderView.order,
		isRecraft = isRecraft,
	})

	if recipeData then
		-- Set Reagents based on visibleFrame and load equipped profession gear set
		recipeData:SetAllReagentsBySchematicForm()
		recipeData:SetConcentrationBySchematicForm()
		recipeData:SetEquippedProfessionGearSet()

		return recipeData
	end

	return nil
end

---@param moduleOption CraftSim.GENERAL_OPTIONS
function CraftSim.MODULES:HandleModuleClose(moduleOption)
	return function()
		CraftSim.DB.OPTIONS:Save(moduleOption, false)
	end
end

--- Recalculates and updates visibility of all modules based on the currently visible recipe and the options for the modules
function CraftSim.MODULES:UpdateUI()
	if not ProfessionsFrame:IsVisible() then
		return
	end

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
		Logger:LogDebug("Hiding all modules because of crafting context (NPC crafting, Runeforging, Linked or Guild Recipe)")
		CraftSim.MODULES:Hide()
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()
	CraftSim.CRAFTQ.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_QUEUE"))
	CraftSim.MODULES:RefreshAddWorkOrdersButtonState()

	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.visibleRecipeID)

	if not recipeInfo or recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then
		-- hide all modules
		CraftSim.MODULES:Hide(true, true)
		return
	end

	local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

	Logger:LogDebug("Export Mode: " .. tostring(exportMode))

	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		CraftSim.MODULES.recipeData = CraftSim.SIMULATION_MODE.recipeData
	else
		CraftSim.MODULES.recipeData = CraftSim.MODULES:GetRecipeDataFromVisibleRecipe()
	end

	local recipeData = CraftSim.MODULES.recipeData

	if not recipeData then
		Logger:LogDebug("No recipe data found for visible recipe!")
		CraftSim.MODULES:Hide(true, true)
		return
	end

	local showReagentOptimization = false
	local showAverageProfit = false
	local showTopGear = false
	local showSimulationMode = false
	local showSpecInfo = false

	-- always on modules
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
	showSpecInfo = showSpecInfo and CraftSim.DB.OPTIONS:Get("MODULE_SPEC_INFO")
	showRecipeScan = showRecipeScan and CraftSim.DB.OPTIONS:Get("MODULE_RECIPE_SCAN")
	showCraftResults = showCraftResults and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG")
	showCustomerHistory = showCustomerHistory and CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_HISTORY")
	showCostOptimization = showCostOptimization and CraftSim.DB.OPTIONS:Get("MODULE_PRICING")
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
	CraftSim.FRAME:ToggleFrame(CraftSim.PRICING.frame,
		showCostOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.PRICING.frameWO,
		showCostOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showCostOptimization then
		CraftSim.PRICING:UpdateDisplay(recipeData)
	end

	if recipeData and showCraftResults then
		CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(recipeData.recipeID)
	end

	-- AverageProfit (Recipe Info) Module
	CraftSim.FRAME:ToggleFrame(averageProfitFrame,
		showAverageProfit and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(averageProfitFrameWO,
		showAverageProfit and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showAverageProfit then
		local statWeights = CraftSim.RECIPE_INFO:CalculateStatWeights(recipeData)

		if statWeights then
			CraftSim.RECIPE_INFO.UI:UpdateDisplay(recipeData, statWeights)
		end
	end

	-- Statistics Module
	CraftSim.STATISTICS.UI:SetVisible(showStatistics, exportMode)
	if recipeData and showStatistics then
		CraftSim.STATISTICS.UI:UpdateDisplay(recipeData)
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

	CraftSim.INIT.lastRecipeID = CraftSim.INIT.visibleRecipeID
end
