---@class CraftSim
local CraftSim = select(2, ...)

---@class Craftsim.Modules
CraftSim.MODULES = {}

---@alias CraftSim.ModuleID
---| "MODULE_REAGENT_OPTIMIZATION"
---| "MODULE_CONCENTRATION_TRACKER"
---| "MODULE_RECIPE_INFO"
---| "MODULE_AVERAGE_PROFIT"
---| "MODULE_TOP_GEAR"
---| "MODULE_COST_OVERVIEW"
---| "MODULE_SPEC_INFO"
---| "MODULE_PRICE_OVERRIDE"
---| "MODULE_RECIPE_SCAN"
---| "MODULE_CRAFT_LOG"
---| "MODULE_CUSTOMER_HISTORY"
---| "MODULE_PRICING"
---| "MODULE_CRAFT_QUEUE"
---| "MODULE_CRAFT_BUFFS"
---| "MODULE_COOLDOWNS"
---| "MODULE_EXPLANATIONS"
---| "MODULE_STATISTICS"
---| "MODULE_DISENCHANT"
---| "MODULE_CONTROL_PANEL"
---| "MODULE_SIMULATION_MODE"
---| "MODULE_PATCH_NOTES"

---@class CraftSim.Module.ControlPanelData
---@field label CraftSim.LOCALIZATION_IDS
---@field tooltip CraftSim.LOCALIZATION_IDS
---@field sortOrder? number

---@class CraftSim.Module.UI
---@field module CraftSim.Module
---@field Init fun(self: CraftSim.Module.UI)
---@field Update fun(self: CraftSim.Module.UI, ...: any)
---@field VisibleByContext? fun(self: CraftSim.Module.UI): boolean -- if not provided, true

---@class CraftSim.Module.Debug
---@field module CraftSim.Module
---@field label? string

---@class CraftSim.Module
---@field moduleID CraftSim.ModuleID
---@field controlPanelData CraftSim.Module.ControlPanelData?
---@field isControlPanelModule boolean
---@field frame GGUI.Frame
---@field UI CraftSim.Module.UI
---@field DEBUG CraftSim.Module.Debug?

---@type table<CraftSim.ModuleID, CraftSim.Module>
CraftSim.MODULES.modules = {}

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

GUTIL:RegisterCustomEvents(CraftSim.MODULES, {
	"CRAFTSIM_MODULE_CLOSED",
	"CRAFTSIM_MODULE_MINIMIZED",
	"CRAFTSIM_MODULE_MAXIMIZED",
})

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@type CraftSim.RecipeData?
CraftSim.MODULES.recipeData = nil

local Logger = CraftSim.DEBUG:RegisterLogger("Modules")

---@param moduleID CraftSim.ModuleID
---@param module CraftSim.Module
---@param controlPanelData CraftSim.Module.ControlPanelData? -- if provided, module will be added to the control panel with the given data
function CraftSim.MODULES:RegisterModule(moduleID, module, controlPanelData)
	CraftSim.MODULES.modules[moduleID] = module
	module.moduleID = moduleID
	module.controlPanelData = controlPanelData
	module.isControlPanelModule = controlPanelData ~= nil

	Logger:LogDebug("Registering Module: {module} data: {data}", moduleID, module.controlPanelData)
end

function CraftSim.MODULES:Init()
	for moduleID, module in pairs(CraftSim.MODULES.modules) do
		Logger:LogDebug("Initializing Module UI: {module}", moduleID)
		-- Inject module reference into UI if there is one
		if module.UI then
			module.UI.module = module
			module.UI:Init()
		end

		if module.DEBUG then
			module.DEBUG.module = module
		end

		-- TODO: create globally named ggui native anchor frames to be saved and restored to
		if module.frame and module.frame.RestoreSavedConfig then
			--module.frame:RestoreSavedConfig()
		end
	end
end

function CraftSim.MODULES:UpdateModuleVisibility(module)
	if module.UI.VisibleByContext then
		local visible = module.UI:VisibleByContext()
		if CraftSim.UTIL:IsWorkOrder() and module.frameWO then
			module.frameWO:SetVisible(visible)
		elseif module.frame then
			module.frame:SetVisible(visible)
		end
	end
end

--- ignores modules without VisibleByContext function, otherwise shows or hides modules based on it
--- requires such modules to have a GGUI.Frame assigned to module.frame
function CraftSim.MODULES:UpdateVisibilityByContext()
	for _, module in pairs(CraftSim.MODULES.modules) do
		self:UpdateModuleVisibility(module)
	end
end

-- TODO MODULE REFACTOR
---@deprecated
function CraftSim.MODULES:RestorePositions()
	-- local specInfoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	-- local specInfoFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	-- local averageProfitFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.AVERAGE_PROFIT)
	-- local averageProfitFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
	-- 	CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO)
	-- local topgearFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	-- local topgearFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	-- local reagentOptimizationFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES,
	-- 	CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
	-- local reagentOptimizationFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
	-- 	CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
	-- local debugFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG)
	-- local infoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.INFO)

	-- infoFrame:RestoreSavedConfig(UIParent)
	-- debugFrame:RestoreSavedConfig(UIParent)
	-- CraftSim.RECIPE_SCAN.frame:RestoreSavedConfig(ProfessionsFrame)
	-- CraftSim.CRAFT_LOG.logFrame:RestoreSavedConfig(UIParent)
	-- CraftSim.CRAFT_LOG.advFrame:RestoreSavedConfig(UIParent)
	-- CraftSim.CUSTOMER_HISTORY.frame:RestoreSavedConfig(ProfessionsFrame)
	-- specInfoFrame:RestoreSavedConfig(ProfessionsFrame)
	-- specInfoFrameWO:RestoreSavedConfig(ProfessionsFrame)
	-- averageProfitFrame:RestoreSavedConfig(ProfessionsFrame)
	-- averageProfitFrameWO:RestoreSavedConfig(ProfessionsFrame)
	-- topgearFrame:RestoreSavedConfig(ProfessionsFrame)
	-- topgearFrameWO:RestoreSavedConfig(ProfessionsFrame)
	-- CraftSim.PRICING.frame:RestoreSavedConfig(ProfessionsFrame)
	-- CraftSim.PRICING.frameWO:RestoreSavedConfig(ProfessionsFrame)
	-- reagentOptimizationFrame:RestoreSavedConfig(ProfessionsFrame)
	-- reagentOptimizationFrameWO:RestoreSavedConfig(ProfessionsFrame)
	-- CraftSim.CRAFTQ.frame:RestoreSavedConfig(ProfessionsFrame)
	-- local patronRewardValuesFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES,
	-- 	CraftSim.CONST.FRAMES.CRAFTQUEUE_PATRON_REWARD_VALUES)
	-- if patronRewardValuesFrame then
	-- 	patronRewardValuesFrame:RestoreSavedConfig(ProfessionsFrame)
	-- end

	-- CraftSim.CRAFT_BUFFS.frame:RestoreSavedConfig(ProfessionsFrame.CraftingPage)
	-- CraftSim.CRAFT_BUFFS.frameWO:RestoreSavedConfig(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
	-- CraftSim.STATISTICS.frameNO_WO:RestoreSavedConfig(ProfessionsFrame.CraftingPage)
	-- CraftSim.STATISTICS.frameWO:RestoreSavedConfig(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
	-- CraftSim.EXPLANATIONS.frame:RestoreSavedConfig(ProfessionsFrame)
	-- CraftSim.COOLDOWNS.frame:RestoreSavedConfig(ProfessionsFrame)

	-- CraftSim.CONCENTRATION_TRACKER.trackerFrame:RestoreSavedConfig(CraftSim.CONCENTRATION_TRACKER.frame.frame)
end

--- Shows recipe-independent modules based on saved options.
--- Called from ProfessionsFrame OnShow to ensure modules are visible even when
--- SchematicForm:Init or tab OnClick does not fire (e.g. opening on the Crafting Orders tab).
---@deprecated
function CraftSim.MODULES:ShowRecipeIndependentModules()
	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		return
	end

	CraftSim.CONTROL_PANEL.frame:Show()

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
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.initialRecipeID)

	if not recipeInfo then
		return nil
	end

	local schematicForm = CraftSim.UTIL:GetSchematicFormByContext()
	if not schematicForm then
		Logger:LogError("CraftSim MODULES: No SchematicForm Visible")
		return nil
	end

	-- On cold profession open, visibleRecipeID can lag behind the actually selected schematic recipe.
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(CraftSim.INIT.initialRecipeID)
	if not recipeInfo then
		recipeInfo = schematicForm:GetRecipeInfo()
	end
	if not recipeInfo or not recipeInfo.recipeID then
		return nil
	end

	local currentTransaction = schematicForm:GetTransaction()
	if not currentTransaction then
		Logger:LogError("CraftSim MODULES: SchematicForm without transaction!")
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

---@param module CraftSim.Module
function CraftSim.MODULES:MODULE_CLOSED(module)
	local modulesEnabled = CraftSim.DB.OPTIONS:Get("MODULES_ENABLED")
	modulesEnabled[module.moduleID] = false
end

---@param module CraftSim.Module
function CraftSim.MODULES:CRAFTSIM_MODULE_MINIMIZED(module)

end

--- Determine basic craftsim visibility for professionsframe dependent modules
---@return boolean
function CraftSim.MODULES:VisibleByContext()
	if not ProfessionsFrame:IsVisible() then
		return false
	end

	if C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging() or C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild() then
		Logger:LogDebug(
			"Hiding all modules because of crafting context (NPC crafting, Runeforging, Linked or Guild Recipe)")
		return false
	end


	return true
end

---@param module CraftSim.Module
---@return function closedCallback, function minimizedCallback, function maximizedCallback
function CraftSim.MODULES:GetModuleFrameStateCallbacks(module)
	return function()
		GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_CLOSED", module.moduleID)
	end, function()
		GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_MINIMIZED", module.moduleID)
	end, function()
		GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_MAXIMIZED", module.moduleID)
	end
end
