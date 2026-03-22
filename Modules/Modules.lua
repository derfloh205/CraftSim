---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class Craftsim.Modules
CraftSim.MODULES = {}

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

local print = CraftSim.DEBUG:RegisterDebugID("Modules")

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
	-- hide control panel and return
	if not keepControlPanel then
		CraftSim.CONTROL_PANEL.frame:Hide()
	end
	if not keepCraftQ then
		CraftSim.CRAFTQ.frame:Hide()
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
	-- hide merged Optimization module
	if CraftSim.OPTIMIZATION.frame then
		CraftSim.OPTIMIZATION.frame:Hide()
	end
	if CraftSim.OPTIMIZATION.frameWO then
		CraftSim.OPTIMIZATION.frameWO:Hide()
	end
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

---@return CraftSim.RecipeData? recipeData
function CraftSim.MODULES:GetRecipeDataFromVisibleRecipe()
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.visibleRecipeID)
    if not recipeInfo then
        return nil
    end

    local schematicForm = CraftSim.UTIL:GetSchematicFormByVisibility()
    if not schematicForm then
        print("CraftSim MODULES: No SchematicForm Visible")
        return nil
    end

    local currentTransaction = schematicForm:GetTransaction()
    if not currentTransaction then
        print("CraftSim MODULES: SchematicForm without transaction!")
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
        print("Hiding all modules because of crafting context (NPC crafting, Runeforging, Linked or Guild Recipe)")
		CraftSim.MODULES:Hide()
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()
	CraftSim.CRAFTQ.frame:SetVisible(CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_QUEUE"))
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
	CraftSim.CRAFTQ.frame.content.queueTab.content.addWorkOrdersButton:SetEnabled(professionInfo and
		professionInfo.profession and C_TradeSkillUI
		.IsNearProfessionSpellFocus(professionInfo.profession))

	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.visibleRecipeID)

	if not recipeInfo or recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then
		-- hide all modules
		CraftSim.MODULES:Hide(true, true)
		return
	end

	local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

	print("Export Mode: " .. tostring(exportMode))

	if CraftSim.SIMULATION_MODE.isActive and CraftSim.SIMULATION_MODE.recipeData then
		CraftSim.MODULES.recipeData = CraftSim.SIMULATION_MODE.recipeData
	else
		CraftSim.MODULES.recipeData = CraftSim.MODULES:GetRecipeDataFromVisibleRecipe()
	end

    local recipeData = CraftSim.MODULES.recipeData

    if not recipeData then
        print("No recipe data found for visible recipe!")
        CraftSim.MODULES:Hide(true, true) 
        return 
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

	-- Recipe capability flags (used to conditionally update sub-module tabs)
	local showReagentOptimization = recipeData.hasQualityReagents
	local showAverageProfit = false
	local showTopGear = false
	local showSimulationMode = false
	local showSpecInfo = false

	local showRecipeScan = true
	local showCraftResults = true
	local showCustomerHistory = true
	local showCraftBuffs = true
	local showCooldowns = true
	local showExplanations = true
	local showStatistics = true
	local showConcentrationTracker = true

	if recipeData.supportsCraftingStats then
		showAverageProfit = true
		showTopGear = true
	end

	if not recipeData.isCooking and not recipeData.isOldWorldRecipe then
		showSpecInfo = true
	end
	showSimulationMode = not recipeData.isOldWorldRecipe and not recipeData.isBaseRecraftRecipe

	showAverageProfit = showAverageProfit and CraftSim.DB.OPTIONS:Get("MODULE_AVERAGE_PROFIT")
	showSpecInfo = showSpecInfo and CraftSim.DB.OPTIONS:Get("MODULE_SPEC_INFO")
	showRecipeScan = showRecipeScan and CraftSim.DB.OPTIONS:Get("MODULE_RECIPE_SCAN")
	showCraftResults = showCraftResults and CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG")
	showCustomerHistory = showCustomerHistory and CraftSim.DB.OPTIONS:Get("MODULE_CUSTOMER_HISTORY")
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

	-- Optimization Module (merged: Price Details, Cost Optimization, Price Override, Reagent Optimization, Top Gear)
	local showOptimization = CraftSim.DB.OPTIONS:Get("MODULE_OPTIMIZATION")
	CraftSim.FRAME:ToggleFrame(CraftSim.OPTIMIZATION.frame,
		showOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
	CraftSim.FRAME:ToggleFrame(CraftSim.OPTIMIZATION.frameWO,
		showOptimization and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
	if recipeData and showOptimization then
		-- Price Details tab
		CraftSim.PRICE_DETAILS:UpdateDisplay(recipeData, exportMode)

		-- Cost Optimization tab
		CraftSim.COST_OPTIMIZATION:UpdateDisplay(recipeData)

		-- Price Override tab
		CraftSim.PRICE_OVERRIDE.UI:UpdateDisplay(recipeData, exportMode)

		-- Reagent Optimization tab (only if recipe has quality reagents)
		if showReagentOptimization then
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

		-- Top Gear tab (only if recipe supports crafting stats)
		if showTopGear then
			CraftSim.TOPGEAR.UI:UpdateModeDropdown(recipeData, exportMode)
			if CraftSim.DB.OPTIONS:Get("TOP_GEAR_AUTO_UPDATE") then
				CraftSim.DEBUG:StartProfiling("Top Gear")
				CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
				CraftSim.DEBUG:StopProfiling("Top Gear")
			else
				CraftSim.TOPGEAR.UI:ClearTopGearDisplay(recipeData, true, exportMode)
			end
		end
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

