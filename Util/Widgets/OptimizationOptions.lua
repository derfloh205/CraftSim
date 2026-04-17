---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---Which standard optimization options to show on this button.
---Use CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS values as field names.
---@class CraftSim.WIDGETS.OptimizationOptions.ShowOptions
---@field ENABLE_CONCENTRATION boolean?           show "Enable Concentration" checkbox
---@field REAGENT_ALLOCATION boolean?             show "Reagent Allocation" radio sub-menu
---@field AUTOSELECT_TOP_PROFIT_QUALITY boolean?  show "Autoselect Top Profit Quality" checkbox (hidden when recipe does not support qualities)
---@field OPTIMIZE_PROFESSION_TOOLS boolean?      show "Optimize Profession Tools" checkbox
---@field OPTIMIZE_CONCENTRATION boolean?         show "Optimize Concentration" checkbox (hidden when recipe does not support qualities)
---@field OPTIMIZE_FINISHING_REAGENTS boolean?    show "Optimize Finishing Reagents" checkbox
---@field INCLUDE_SOULBOUND_FINISHING_REAGENTS boolean? show "Include Soulbound Finishing Reagents" sub-option (only visible when OPTIMIZE_FINISHING_REAGENTS is also shown)
---@field ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS boolean? show "Only Highest Quality Soulbound Finishing Reagents" sub-option (only visible when OPTIMIZE_FINISHING_REAGENTS is also shown)
---@field FINISHING_REAGENTS_ALGORITHM boolean?  show "Finishing Reagents Algorithm" radio sub-menu (only visible when OPTIMIZE_FINISHING_REAGENTS is also shown)

---Default values for each option key when no stored value exists.
---Use CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS values as field names.
---@class CraftSim.WIDGETS.OptimizationOptions.Defaults
---@field ENABLE_CONCENTRATION boolean?
---@field REAGENT_ALLOCATION string?              one of CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION
---@field AUTOSELECT_TOP_PROFIT_QUALITY boolean?
---@field OPTIMIZE_PROFESSION_TOOLS boolean?
---@field OPTIMIZE_CONCENTRATION boolean?
---@field OPTIMIZE_FINISHING_REAGENTS boolean?
---@field INCLUDE_SOULBOUND_FINISHING_REAGENTS boolean?
---@field ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS boolean?
---@field FINISHING_REAGENTS_ALGORITHM string?     one of CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM

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

---Reagent allocation mode values.
---@enum CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION
CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION = {
    Q1                     = "Q1",
    Q2                     = "Q2",
    Q3                     = "Q3",
    OPTIMIZE               = "OPTIMIZE",
    OPTIMIZE_HIGHEST       = "OPTIMIZE_HIGHEST",
    OPTIMIZE_MOST_PROFITABLE = "OPTIMIZE_MOST_PROFITABLE",
    OPTIMIZE_TARGET_1      = "OPTIMIZE_TARGET_1",
    OPTIMIZE_TARGET_2      = "OPTIMIZE_TARGET_2",
    OPTIMIZE_TARGET_3      = "OPTIMIZE_TARGET_3",
    OPTIMIZE_TARGET_4      = "OPTIMIZE_TARGET_4",
    OPTIMIZE_TARGET_5      = "OPTIMIZE_TARGET_5",
}

---DB key names for each individual optimization option value.
---@enum CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS = {
    ENABLE_CONCENTRATION                 = "ENABLE_CONCENTRATION",
    REAGENT_ALLOCATION                   = "REAGENT_ALLOCATION",
    AUTOSELECT_TOP_PROFIT_QUALITY        = "AUTOSELECT_TOP_PROFIT_QUALITY",
    OPTIMIZE_PROFESSION_TOOLS            = "OPTIMIZE_PROFESSION_TOOLS",
    OPTIMIZE_CONCENTRATION               = "OPTIMIZE_CONCENTRATION",
    OPTIMIZE_FINISHING_REAGENTS          = "OPTIMIZE_FINISHING_REAGENTS",
    INCLUDE_SOULBOUND_FINISHING_REAGENTS = "INCLUDE_SOULBOUND_FINISHING_REAGENTS",
    ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS = "ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS",
    FINISHING_REAGENTS_ALGORITHM         = "FINISHING_REAGENTS_ALGORITHM",
}

---Algorithm mode values for finishing reagent optimization.
---@enum CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM
CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM = {
    SIMPLE      = "SIMPLE",
    PERMUTATION = "PERMUTATION",
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

    local RA   = CraftSim.WIDGETS.OptimizationOptions.REAGENT_ALLOCATION
    local KEYS = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
    local FA   = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM

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
        if showOptions[KEYS.ENABLE_CONCENTRATION] then
            rootDescription:CreateCheckbox(
                L("RECIPE_SCAN_ENABLE_CONCENTRATION"),
                function() return getOption(KEYS.ENABLE_CONCENTRATION) end,
                function() saveOption(KEYS.ENABLE_CONCENTRATION, not getOption(KEYS.ENABLE_CONCENTRATION)) end)
        end

        -- Reagent Allocation radio sub-menu
        if showOptions[KEYS.REAGENT_ALLOCATION] then
            local sub = rootDescription:CreateButton(L("RECIPE_SCAN_REAGENT_ALLOCATION"))

            sub:CreateRadio(
                L("RECIPE_SCAN_REAGENT_ALLOCATION_Q1") ..
                " " .. GUTIL:GetQualityIconString(1, 20, 20) .. " | " .. GUTIL:GetQualityIconStringSimplified(1, 20, 20),
                function() return getOption(KEYS.REAGENT_ALLOCATION) == RA.Q1 end,
                function() saveOption(KEYS.REAGENT_ALLOCATION, RA.Q1) return MenuResponse.Refresh end)

            sub:CreateRadio(
                L("RECIPE_SCAN_REAGENT_ALLOCATION_Q2") ..
                " " .. GUTIL:GetQualityIconString(2, 20, 20) .. " | " .. GUTIL:GetQualityIconStringSimplified(2, 20, 20),
                function() return getOption(KEYS.REAGENT_ALLOCATION) == RA.Q2 end,
                function() saveOption(KEYS.REAGENT_ALLOCATION, RA.Q2) return MenuResponse.Refresh end)

            sub:CreateRadio(
                L("RECIPE_SCAN_REAGENT_ALLOCATION_Q3") .. " " .. GUTIL:GetQualityIconString(3, 20, 20),
                function() return getOption(KEYS.REAGENT_ALLOCATION) == RA.Q3 end,
                function() saveOption(KEYS.REAGENT_ALLOCATION, RA.Q3) return MenuResponse.Refresh end)

            -- Optimize sub-submenu
            local optimizeSub = sub:CreateButton(L("RECIPE_SCAN_MODE_OPTIMIZE"))

            optimizeSub:CreateRadio(
                L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_HIGHEST"),
                function()
                    local ra = getOption(KEYS.REAGENT_ALLOCATION) or RA.OPTIMIZE_HIGHEST
                    return ra == RA.OPTIMIZE_HIGHEST or ra == RA.OPTIMIZE
                end,
                function() saveOption(KEYS.REAGENT_ALLOCATION, RA.OPTIMIZE_HIGHEST) return MenuResponse.Refresh end)

            optimizeSub:CreateRadio(
                L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_OPTIMIZE_MOST_PROFITABLE"),
                function() return getOption(KEYS.REAGENT_ALLOCATION) == RA.OPTIMIZE_MOST_PROFITABLE end,
                function() saveOption(KEYS.REAGENT_ALLOCATION, RA.OPTIMIZE_MOST_PROFITABLE) return MenuResponse.Refresh end)

            -- Target Quality sub-submenu
            local targetQualityButton = optimizeSub:CreateButton(
                L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION_TARGET_QUALITY"))

            for i = 1, 5 do
                local qualityID = i
                local allocationValue = RA["OPTIMIZE_TARGET_" .. qualityID]
                local qualityLabel = GUTIL:GetQualityIconString(qualityID, 20, 20)
                if qualityID <= 2 then
                    qualityLabel = qualityLabel .. " | " .. GUTIL:GetQualityIconStringSimplified(qualityID, 20, 20)
                end
                targetQualityButton:CreateRadio(
                    qualityLabel,
                    function() return getOption(KEYS.REAGENT_ALLOCATION) == allocationValue end,
                    function() saveOption(KEYS.REAGENT_ALLOCATION, allocationValue) return MenuResponse.Refresh end)
            end
        end

        -- Autoselect Top Profit Quality (quality-gated)
        if showOptions[KEYS.AUTOSELECT_TOP_PROFIT_QUALITY] and supportsQualities then
            rootDescription:CreateCheckbox(
                L("RECIPE_SCAN_AUTOSELECT_TOP_PROFIT"),
                function() return getOption(KEYS.AUTOSELECT_TOP_PROFIT_QUALITY) end,
                function() saveOption(KEYS.AUTOSELECT_TOP_PROFIT_QUALITY, not getOption(KEYS.AUTOSELECT_TOP_PROFIT_QUALITY)) end)
        end

        -- Optimize Profession Tools
        if showOptions[KEYS.OPTIMIZE_PROFESSION_TOOLS] then
            rootDescription:CreateCheckbox(
                L("OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS"),
                function() return getOption(KEYS.OPTIMIZE_PROFESSION_TOOLS) end,
                function() saveOption(KEYS.OPTIMIZE_PROFESSION_TOOLS, not getOption(KEYS.OPTIMIZE_PROFESSION_TOOLS)) end)
        end

        -- Optimize Concentration (quality-gated)
        if showOptions[KEYS.OPTIMIZE_CONCENTRATION] and supportsQualities then
            rootDescription:CreateCheckbox(
                L("RECIPE_SCAN_OPTIMIZE_CONCENTRATION"),
                function() return getOption(KEYS.OPTIMIZE_CONCENTRATION) end,
                function() saveOption(KEYS.OPTIMIZE_CONCENTRATION, not getOption(KEYS.OPTIMIZE_CONCENTRATION)) end)
        end

        -- Optimize Finishing Reagents (+ optional algorithm sub-menu + optional soulbound sub-option)
        if showOptions[KEYS.OPTIMIZE_FINISHING_REAGENTS] then
            rootDescription:CreateCheckbox(
                L("RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS"),
                function() return getOption(KEYS.OPTIMIZE_FINISHING_REAGENTS) end,
                function() saveOption(KEYS.OPTIMIZE_FINISHING_REAGENTS, not getOption(KEYS.OPTIMIZE_FINISHING_REAGENTS)) end)

            if showOptions[KEYS.FINISHING_REAGENTS_ALGORITHM] then
                local algorithmSub = rootDescription:CreateButton(
                    L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_ALGORITHM"))

                local simpleRadio = algorithmSub:CreateRadio(
                    L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE"),
                    function() return getOption(KEYS.FINISHING_REAGENTS_ALGORITHM) ~= FA.PERMUTATION end,
                    function() saveOption(KEYS.FINISHING_REAGENTS_ALGORITHM, FA.SIMPLE) return MenuResponse.Refresh end)
                simpleRadio:SetTooltip(function(tooltip, _)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_SIMPLE_TOOLTIP"))
                end)

                local permutationRadio = algorithmSub:CreateRadio(
                    L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION"),
                    function() return getOption(KEYS.FINISHING_REAGENTS_ALGORITHM) == FA.PERMUTATION end,
                    function() saveOption(KEYS.FINISHING_REAGENTS_ALGORITHM, FA.PERMUTATION) return MenuResponse.Refresh end)
                permutationRadio:SetTooltip(function(tooltip, _)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("OPTIMIZATION_OPTIONS_FINISHING_REAGENTS_PERMUTATION_TOOLTIP"))
                end)

                if showOptions[KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS] then
                    local includeSBCB = algorithmSub:CreateCheckbox(
                        L("OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS"),
                        function() return getOption(KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS) end,
                        function()
                            saveOption(KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS,
                                not getOption(KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS))
                        end)
                    includeSBCB:SetTooltip(function(tooltip, _)
                        GameTooltip_AddInstructionLine(tooltip,
                            "If enabled, CraftSim will suggest soulbound finishing reagents during optimization")
                    end)
                end

                if showOptions[KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS] then
                    local onlyHighestSBCB = algorithmSub:CreateCheckbox(
                        L("OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS"),
                        function() return getOption(KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS) end,
                        function()
                            saveOption(KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS,
                                not getOption(KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS))
                        end)
                    onlyHighestSBCB:SetTooltip(function(tooltip, _)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("OPTIMIZATION_OPTIONS_ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS_TOOLTIP"))
                    end)
                end
            end

            if showOptions[KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS] and not showOptions[KEYS.FINISHING_REAGENTS_ALGORITHM] then
                -- Fallback: show at root level when algorithm submenu is not shown
                local includeSBCB = rootDescription:CreateCheckbox(
                    L("OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS"),
                    function() return getOption(KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS) end,
                    function()
                        saveOption(KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS,
                            not getOption(KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS))
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
