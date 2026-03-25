---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---Which standard optimization options to show on this button.
---@class CraftSim.WIDGETS.OptimizationOptions.ShowOptions
---@field enableConcentration boolean?           show "Enable Concentration" checkbox
---@field reagentAllocation boolean?             show "Reagent Allocation" radio sub-menu
---@field autoselectTopProfitQuality boolean?    show "Autoselect Top Profit Quality" checkbox (hidden when recipe does not support qualities)
---@field optimizeProfessionTools boolean?       show "Optimize Profession Tools" checkbox
---@field optimizeConcentration boolean?         show "Optimize Concentration" checkbox (hidden when recipe does not support qualities)
---@field optimizeFinishingReagents boolean?     show "Optimize Finishing Reagents" checkbox
---@field includeSoulboundFinishingReagents boolean? show "Include Soulbound Finishing Reagents" sub-option (only visible when optimizeFinishingReagents is also shown)

---Default values for each option key when no stored value exists.
---@class CraftSim.WIDGETS.OptimizationOptions.Defaults
---@field enableConcentration boolean?
---@field reagentAllocation string?              one of CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION
---@field autoselectTopProfitQuality boolean?
---@field optimizeProfessionTools boolean?
---@field optimizeConcentration boolean?
---@field optimizeFinishingReagents boolean?
---@field includeSoulboundFinishingReagents boolean?

---@class CraftSim.WIDGETS.OptimizationOptions.ConstructorOptions
---@field parent Frame
---@field anchorPoints GGUI.AnchorPoint[]
---@field isFilter boolean?                            use filter icon instead of options icon
---@field optimizationOptionsID string?                ID used to persist option values in CraftSim.DB.OPTIMIZATION_OPTIONS.
---                                                    Mutually exclusive with savedVariablesTable; provide at most one.
---@field savedVariablesTable table?                   alternative persistence: read/write directly to this table.
---                                                    Mutually exclusive with optimizationOptionsID; provide at most one.
---@field defaults CraftSim.WIDGETS.OptimizationOptions.Defaults? per-key default values
---@field showOptions CraftSim.WIDGETS.OptimizationOptions.ShowOptions which standard options to expose
---@field recipeDataProvider (fun(): CraftSim.RecipeData?)? optional provider called when the menu opens.
---                                                    When provided and returns nil, quality-gated options are hidden.
---                                                    When omitted, quality-gated options are always visible.
---@field additionalMenu (fun(ownerRegion: Region, rootDescription: any))? extra items appended after the standard options

---@class CraftSim.WIDGETS.OptimizationOptions : CraftSim.WIDGETS.OptionsButton
---@field getOption fun(key: string): any
---@field saveOption fun(key: string, value: any)
---@field optimizationOptionsID string?
---@overload fun(options: CraftSim.WIDGETS.OptimizationOptions.ConstructorOptions): CraftSim.WIDGETS.OptimizationOptions
CraftSim.WIDGETS.OptimizationOptions = CraftSim.WIDGETS.OptionsButton:extend()

---Reagent allocation mode values mirroring CraftSim.RECIPE_SCAN.SCAN_MODES.
---@enum CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION
CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION = {
    Q1       = "Q1",
    Q2       = "Q2",
    Q3       = "Q3",
    OPTIMIZE = "OPTIMIZE",
}

---@param options CraftSim.WIDGETS.OptimizationOptions.ConstructorOptions
function CraftSim.WIDGETS.OptimizationOptions:new(options)
    local showOptions    = options.showOptions or {}
    local defaultValues  = options.defaults or {}
    local optID          = options.optimizationOptionsID
    local svTable        = options.savedVariablesTable

    ---Read a stored option value, falling back to the per-key default.
    ---@param key string
    ---@return any
    local function getOption(key)
        if optID then
            return CraftSim.DB.OPTIMIZATION_OPTIONS:Get(optID, key, defaultValues[key])
        elseif svTable then
            local val = svTable[key]
            if val == nil then
                val = defaultValues[key]
            end
            return val
        end
        return defaultValues[key]
    end

    ---Persist a new option value.
    ---@param key string
    ---@param value any
    local function saveOption(key, value)
        if optID then
            CraftSim.DB.OPTIMIZATION_OPTIONS:Save(optID, key, value)
        elseif svTable then
            svTable[key] = value
        end
    end

    local RA = CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION

    local function buildMenu(ownerRegion, rootDescription)
        local recipeData = options.recipeDataProvider and options.recipeDataProvider()
        -- If a provider was given but returned nil (no active recipe), hide quality-gated options.
        -- If no provider was specified, always show them (caller shows all options unconditionally).
        local supportsQualities
        if options.recipeDataProvider then
            supportsQualities = (recipeData ~= nil) and recipeData.supportsQualities
        else
            supportsQualities = true
        end

        -- Enable Concentration
        if showOptions.enableConcentration then
            rootDescription:CreateCheckbox(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_ENABLE_CONCENTRATION),
                function() return getOption("enableConcentration") end,
                function() saveOption("enableConcentration", not getOption("enableConcentration")) end)
        end

        -- Reagent Allocation radio sub-menu
        if showOptions.reagentAllocation then
            local sub = rootDescription:CreateButton(L(CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION))

            sub:CreateRadio(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION_Q1) .. " " .. GUTIL:GetQualityIconString(1, 20, 20),
                function() return getOption("reagentAllocation") == RA.Q1 end,
                function() saveOption("reagentAllocation", RA.Q1) end)

            sub:CreateRadio(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION_Q2) .. " " .. GUTIL:GetQualityIconString(2, 20, 20),
                function() return getOption("reagentAllocation") == RA.Q2 end,
                function() saveOption("reagentAllocation", RA.Q2) end)

            sub:CreateRadio(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_REAGENT_ALLOCATION_Q3) .. " " .. GUTIL:GetQualityIconString(3, 20, 20),
                function() return getOption("reagentAllocation") == RA.Q3 end,
                function() saveOption("reagentAllocation", RA.Q3) end)

            sub:CreateRadio(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE),
                function() return getOption("reagentAllocation") == RA.OPTIMIZE end,
                function() saveOption("reagentAllocation", RA.OPTIMIZE) end)
        end

        -- Autoselect Top Profit Quality (quality-gated)
        if showOptions.autoselectTopProfitQuality and supportsQualities then
            rootDescription:CreateCheckbox(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_AUTOSELECT_TOP_PROFIT),
                function() return getOption("autoselectTopProfitQuality") end,
                function() saveOption("autoselectTopProfitQuality", not getOption("autoselectTopProfitQuality")) end)
        end

        -- Optimize Profession Tools
        if showOptions.optimizeProfessionTools then
            rootDescription:CreateCheckbox(
                L(CraftSim.CONST.TEXT.OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS),
                function() return getOption("optimizeProfessionTools") end,
                function() saveOption("optimizeProfessionTools", not getOption("optimizeProfessionTools")) end)
        end

        -- Optimize Concentration (quality-gated)
        if showOptions.optimizeConcentration and supportsQualities then
            rootDescription:CreateCheckbox(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_CONCENTRATION),
                function() return getOption("optimizeConcentration") end,
                function() saveOption("optimizeConcentration", not getOption("optimizeConcentration")) end)
        end

        -- Optimize Finishing Reagents (+ optional soulbound sub-option)
        if showOptions.optimizeFinishingReagents then
            rootDescription:CreateCheckbox(
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS),
                function() return getOption("optimizeFinishingReagents") end,
                function() saveOption("optimizeFinishingReagents", not getOption("optimizeFinishingReagents")) end)

            if showOptions.includeSoulboundFinishingReagents then
                local includeSBCB = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS),
                    function() return getOption("includeSoulboundFinishingReagents") end,
                    function()
                        saveOption("includeSoulboundFinishingReagents",
                            not getOption("includeSoulboundFinishingReagents"))
                    end)
                includeSBCB:SetTooltip(function(tooltip, _)
                    GameTooltip_AddInstructionLine(tooltip,
                        "If enabled, CraftSim will suggest soulbound finishing reagents during optimization")
                end)
            end
        end

        -- Additional custom menu items provided by the caller
        if options.additionalMenu then
            options.additionalMenu(ownerRegion, rootDescription)
        end
    end

    CraftSim.WIDGETS.OptimizationOptions.super.new(self, {
        parent       = options.parent,
        anchorPoints = options.anchorPoints,
        isFilter     = options.isFilter,
        menu         = buildMenu,
    })

    self.optimizationOptionsID = optID
    self.savedVariablesTable   = svTable
    self.getOption             = getOption
    self.saveOption            = saveOption
end
