---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.OPTIONS
CraftSim.OPTIONS = {}

CraftSim.OPTIONS.lastOpenRecipeID = {}

--- Blizzard Settings: one vertical list under AddOns (native checkboxes / sliders / dropdown).
--- TSM block uses `CraftSimSettingsTsmPanelTemplate` (`CraftSimOptionsTsm.xml`) via `CreatePanelInitializer`.
function CraftSim.OPTIONS:Init()
    CraftSim.OPTIONS.optionsPanel = nil

    local GO = CraftSim.CONST.GENERAL_OPTIONS
    local DEF = CraftSim.CONST.GENERAL_OPTIONS_DEFAULTS
    local mainCategory = Settings.RegisterVerticalLayoutCategory(L("OPTIONS_TITLE"))
    CraftSim.OPTIONS.category = mainCategory

    local function regSection(title, tooltip)
        Settings.RegisterInitializer(mainCategory, CreateSettingsListSectionHeaderInitializer(title, tooltip))
    end

    ---@param varId string Unique Settings variable id
    ---@param optKey CraftSim.GENERAL_OPTIONS
    ---@param onChanged? fun(value: boolean)
    local function proxyBool(varId, optKey, label, tooltip, onChanged)
        local def = DEF[optKey]
        local s = Settings.RegisterProxySetting(mainCategory, varId, Settings.VarType.Boolean, label, def,
            function()
                return CraftSim.DB.OPTIONS:Get(optKey)
            end,
            function(v)
                CraftSim.DB.OPTIONS:Save(optKey, v)
            end)
        if onChanged then
            s:SetValueChangedCallback(function(_, v)
                onChanged(v)
            end)
        end
        Settings.CreateCheckbox(mainCategory, s, tooltip)
    end

    ---@param varId string
    ---@param optKey CraftSim.GENERAL_OPTIONS
    ---@param valueRoundDecimals number? Rounds DB + slider value; `SetLabelFormatter(Right, fn)` formats the live label
    --- (see `CreateMinimalSliderFormatter`: passing a function is the custom formatter path).
    local function proxySlider(varId, optKey, label, tooltip, minV, maxV, step, valueRoundDecimals)
        local def = DEF[optKey]
        local defOut = valueRoundDecimals and GUTIL:Round(def, valueRoundDecimals) or def
        local s = Settings.RegisterProxySetting(mainCategory, varId, Settings.VarType.Number, label, defOut,
            function()
                local v = CraftSim.DB.OPTIONS:Get(optKey)
                return valueRoundDecimals and GUTIL:Round(v, valueRoundDecimals) or v
            end,
            function(v)
                local out = valueRoundDecimals and GUTIL:Round(v, valueRoundDecimals) or v
                CraftSim.DB.OPTIONS:Save(optKey, out)
            end)
        local opts = Settings.CreateSliderOptions(minV, maxV, step)
        if valueRoundDecimals ~= nil then
            opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(v)
                local r = GUTIL:Round(v, valueRoundDecimals)
                if valueRoundDecimals <= 0 then
                    return string.format("%d", r)
                end
                return string.format("%." .. tostring(valueRoundDecimals) .. "f", r)
            end)
        else
            opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
        end
        Settings.CreateSlider(mainCategory, s, opts, tooltip)
    end

    -- General
    regSection(L("OPTIONS_GENERAL_TAB"), nil)

    local priceAddons = CraftSim.PRICE_APIS:GetAvailablePriceSourceAddons()
    if #priceAddons > 1 then
        local supportedTooltip = L("OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES") ..
            "\n\n" .. table.concat(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS, "\n")
        local defaultSource = CraftSim.PRICE_API.name or priceAddons[1]
        local ddSetting = Settings.RegisterProxySetting(mainCategory, "CraftSimOpt_PRICE_SOURCE", Settings.VarType
            .String,
            L("OPTIONS_GENERAL_PRICE_SOURCE"), defaultSource,
            function()
                return CraftSim.PRICE_API.name
            end,
            function(v)
                CraftSim.PRICE_APIS:SwitchAPIByAddonName(v)
                CraftSim.DB.OPTIONS:Save(GO.PRICE_SOURCE, v)
            end)
        local function priceDropdownOptions()
            local t = {}
            for _, n in ipairs(priceAddons) do
                t[#t + 1] = { controlType = Settings.ControlType.Radio, label = n, text = n, value = n }
            end
            return t
        end
        Settings.CreateDropdown(mainCategory, ddSetting, priceDropdownOptions, supportedTooltip)
    elseif #priceAddons == 1 then
        Settings.RegisterInitializer(mainCategory, CreateSettingsListSectionHeaderInitializer(
            L("OPTIONS_GENERAL_CURRENT_PRICE_SOURCE") .. " " .. tostring(CraftSim.PRICE_API.name), nil))
    else
        Settings.RegisterInitializer(mainCategory, CreateSettingsListSectionHeaderInitializer(
            L("OPTIONS_GENERAL_NO_PRICE_SOURCE"), nil))
    end

    proxyBool("CraftSimOpt_SHOW_PROFIT_PERCENTAGE", GO.SHOW_PROFIT_PERCENTAGE,
        L("OPTIONS_GENERAL_SHOW_PROFIT"),
        L("OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP"))
    proxyBool("CraftSimOpt_OPEN_LAST_RECIPE", GO.OPEN_LAST_RECIPE, L("OPTIONS_GENERAL_REMEMBER_LAST_RECIPE"),
        L("OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP"))
    proxyBool("CraftSimOpt_SHOW_NEWS", GO.SHOW_NEWS, L("OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX"),
        L("OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP"))
    proxyBool("CraftSimOpt_MINIMAP_BUTTON_HIDE", GO.MINIMAP_BUTTON_HIDE,
        L("OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX"),
        L("OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP"), function(v)
            if v then
                CraftSim.LibIcon:Hide("CraftSim")
            else
                CraftSim.LibIcon:Show("CraftSim")
            end
        end)
    proxyBool("CraftSimOpt_MONEY_FORMAT_USE_TEXTURES", GO.MONEY_FORMAT_USE_TEXTURES,
        L("OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX") .. GUTIL:FormatMoney(123456789, nil, nil, true, true),
        L("OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP"))
    proxyBool("CraftSimOpt_ALLOW_GATHERING_QUEUEABLE", GO.CRAFTQUEUE_ALLOW_GATHERING_RECIPES,
        L("OPTIONS_GENERAL_ALLOW_GATHERING_QUEUEABLE"),
        L("OPTIONS_GENERAL_ALLOW_GATHERING_QUEUEABLE_TOOLTIP"))

    -- Modules
    regSection(L("OPTIONS_MODULES_TAB"), nil)
    proxySlider("CraftSimOpt_CUSTOMER_HISTORY_MAX", GO.CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT,
        L("OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT"),
        L("OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE"), 1, 1000, 1, 0)

    -- Profit calculation
    regSection(L("OPTIONS_PROFIT_CALCULATION_TAB"), nil)
    proxyBool("CraftSimOpt_QUALITY_BREAKPOINT_OFFSET", GO.QUALITY_BREAKPOINT_OFFSET,
        L("OPTIONS_PROFIT_CALCULATION_OFFSET"), L("OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP"))
    --- Step 0.01 with 2-decimal rounding matches tick math (avoids 0.600003-style float labels).
    proxySlider("CraftSimOpt_RESOURCEFULNESS", GO.PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT,
        L("OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT"),
        L("OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION"), 0, 1.0, 0.1, 1)

    -- Crafting
    regSection(L("OPTIONS_CRAFTING_TAB"), nil)
    proxyBool("CraftSimOpt_CRAFTING_GC_ENABLED", GO.CRAFTING_GARBAGE_COLLECTION_ENABLED, L("OPTIONS_PERFORMANCE_RAM"),
        L("OPTIONS_PERFORMANCE_RAM_TOOLTIP"))
    proxySlider("CraftSimOpt_CRAFTING_GC_CRAFTS", GO.CRAFTING_GARBAGE_COLLECTION_CRAFTS,
        L("OPTIONS_PERFORMANCE_RAM_CRAFTS"), L("OPTIONS_PERFORMANCE_RAM_TOOLTIP"), 0, 2000, 100, 0)
    proxyBool("CraftSimOpt_FLASH_TASKBAR", GO.CRAFTQUEUE_FLASH_TASKBAR_ON_CRAFT_FINISHED,
        L("CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL"), L("CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP"))
    -- Banking
    regSection(L("OPTIONS_BANKING_TAB"), nil)
    proxySlider("CraftSimOpt_BANKING_MAX_ITEMS_PER_FRAME", GO.BANKING_MAX_ITEMS_PER_FRAME,
        L("OPTIONS_BANKING_MAX_ITEMS_PER_FRAME"), L("OPTIONS_BANKING_MAX_ITEMS_PER_FRAME_TOOLTIP"), 1, 100, 1, 0)
    -- Tooltip
    regSection(L("OPTIONS_TOOLTIP_TAB"), nil)
    proxyBool("CraftSimOpt_SHOW_REGISTERED_CRAFTERS", GO.SHOW_REGISTERED_CRAFTERS_ITEM_TOOLTIP,
        L("OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS"), L("OPTIONS_TOOLTIP_SHOW_REGISTERED_CRAFTERS_HELP"))
    proxySlider("CraftSimOpt_REGISTERED_CRAFTERS_MAX", GO.REGISTERED_CRAFTERS_ITEM_TOOLTIP_MAX,
        L("OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX"), L("OPTIONS_TOOLTIP_REGISTERED_CRAFTERS_MAX_SUBLABEL"), 1, 50, 1, 0)

    -- TSM (embedded panel; `CraftSimOptionsInitTSMPanel` runs from template OnLoad)
    if select(2, C_AddOns.IsAddOnLoaded("TradeSkillMaster")) then
        regSection(L("OPTIONS_TSM_TAB"), L("OPTIONS_TSM_SECTION_TOOLTIP"))
        Settings.RegisterInitializer(mainCategory,
            Settings.CreatePanelInitializer("CraftSimSettingsTsmPanelTemplate", {}))
    end

    Settings.RegisterAddOnCategory(mainCategory)
end

function CraftSim.OPTIONS:InitTSMPanelFromTemplate(parent)
    local expressionSizeX = 300
    local expressionSizeY = 25
    --- Inset matches Settings list padding so rows are not clipped on the left.
    local insetX = 28

    local tsmExpressionTitleReagents = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tsmExpressionTitleReagents:SetPoint("TOPLEFT", parent, "TOPLEFT", insetX, -10)
    tsmExpressionTitleReagents:SetText("TSM Crafting Reagents Price Expression")

    local tsmReagentsPriceExpression = CreateFrame("EditBox", nil, parent,
        "InputBoxTemplate")
    tsmReagentsPriceExpression:SetPoint("TOPLEFT", tsmExpressionTitleReagents, "BOTTOMLEFT", 0, -6)
    tsmReagentsPriceExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmReagentsPriceExpression:SetAutoFocus(false) -- dont automatically focus
    tsmReagentsPriceExpression:SetFontObject("ChatFontNormal")
    tsmReagentsPriceExpression:SetText(CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_REAGENTS))
    tsmReagentsPriceExpression:SetScript("OnEscapePressed", function() tsmReagentsPriceExpression:ClearFocus() end)
    tsmReagentsPriceExpression:SetScript("OnEnterPressed", function() tsmReagentsPriceExpression:ClearFocus() end)
    tsmReagentsPriceExpression:SetScript("OnTextChanged", function()
        local expression = tsmReagentsPriceExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoReagents:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_INVALID_EXPRESSION"), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoReagents:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_REAGENTS,
                tsmReagentsPriceExpression:GetText())
        end
    end)

    local resetReagentsBtn = GGUI.Button({
        parent = parent,
        anchorParent = tsmReagentsPriceExpression,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 10,
        offsetY = 0,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L("OPTIONS_TSM_RESET"),
        clickCallback = function()
            tsmReagentsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local validationInfoReagents = parent:CreateFontString('CraftSimTSMStringValidationInfoReagents', 'OVERLAY',
        'GameFontNormal')
    validationInfoReagents:SetPoint("LEFT", resetReagentsBtn.frame, "RIGHT", 10, 0)
    validationInfoReagents:SetText(CraftSim.GUTIL:ColorizeText(
        L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))

    local tsmExpressionTitleItems = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tsmExpressionTitleItems:SetPoint("TOPLEFT", tsmReagentsPriceExpression, "BOTTOMLEFT", 0, -28)
    tsmExpressionTitleItems:SetText("TSM Crafted Items Price Expression")

    local tsmItemsPriceExpression = CreateFrame("EditBox", "CraftSimTSMPriceExpressionItems", parent,
        "InputBoxTemplate")
    tsmItemsPriceExpression:SetPoint("TOPLEFT", tsmExpressionTitleItems, "BOTTOMLEFT", 0, -6)
    tsmItemsPriceExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmItemsPriceExpression:SetAutoFocus(false) -- dont automatically focus
    tsmItemsPriceExpression:SetFontObject("ChatFontNormal")
    tsmItemsPriceExpression:SetText(CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_ITEMS))
    tsmItemsPriceExpression:SetScript("OnEscapePressed", function() tsmItemsPriceExpression:ClearFocus() end)
    tsmItemsPriceExpression:SetScript("OnEnterPressed", function() tsmItemsPriceExpression:ClearFocus() end)
    tsmItemsPriceExpression:SetScript("OnTextChanged", function()
        local expression = tsmItemsPriceExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoItems:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_INVALID_EXPRESSION"), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoItems:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_ITEMS,
                tsmItemsPriceExpression:GetText())
        end
    end)

    local resetItemsBtn = GGUI.Button({
        parent = parent,
        anchorParent = tsmItemsPriceExpression,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 10,
        offsetY = 0,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L("OPTIONS_TSM_RESET"),
        clickCallback = function()
            tsmItemsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local validationInfoItems = parent:CreateFontString('CraftSimTSMStringValidationInfoItems', 'OVERLAY',
        'GameFontNormal')
    validationInfoItems:SetPoint("LEFT", resetItemsBtn.frame, "RIGHT", 10, 0)
    validationInfoItems:SetText(CraftSim.GUTIL:ColorizeText(
        L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))

    local tsmExpressionTitleRestockItems = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tsmExpressionTitleRestockItems:SetPoint("TOPLEFT", tsmItemsPriceExpression, "BOTTOMLEFT", 0, -28)
    tsmExpressionTitleRestockItems:SetText("TSM Crafted Items Restock Qty Expression")

    local tsmRestockExpression = CreateFrame("EditBox", "CraftSimTSMRestockExpressionItems", parent,
        "InputBoxTemplate")
    tsmRestockExpression:SetPoint("TOPLEFT", tsmExpressionTitleRestockItems, "BOTTOMLEFT", 0, -6)
    tsmRestockExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmRestockExpression:SetAutoFocus(false) -- dont automatically focus
    tsmRestockExpression:SetFontObject("ChatFontNormal")
    tsmRestockExpression:SetText(CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.TSM_RESTOCK_KEY_ITEMS))
    tsmRestockExpression:SetScript("OnEscapePressed", function() tsmRestockExpression:ClearFocus() end)
    tsmRestockExpression:SetScript("OnEnterPressed", function() tsmRestockExpression:ClearFocus() end)
    tsmRestockExpression:SetScript("OnTextChanged", function()
        local expression = tsmRestockExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoRestockItems:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_INVALID_EXPRESSION"), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoRestockItems:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_RESTOCK_KEY_ITEMS,
                tsmRestockExpression:GetText())
        end
    end)

    local resetRestockBtn = GGUI.Button({
        parent = parent,
        anchorParent = tsmRestockExpression,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 10,
        offsetY = 0,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L("OPTIONS_TSM_RESET"),
        clickCallback = function()
            tsmRestockExpression:SetText("1")
        end
    })

    local validationInfoRestockItems = parent:CreateFontString('CraftSimTSMStringValidationInfoRestockItems',
        'OVERLAY',
        'GameFontNormal')
    validationInfoRestockItems:SetPoint("LEFT", resetRestockBtn.frame, "RIGHT", 10, 0)
    validationInfoRestockItems:SetText(CraftSim.GUTIL:ColorizeText(
        L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))

    -- =========================================================================
    -- TSM Enhanced: Deposit Cost Settings
    -- =========================================================================

    local sectionHeaderDeposit = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sectionHeaderDeposit:SetPoint("TOPLEFT", tsmRestockExpression, "BOTTOMLEFT", 0, -20)
    sectionHeaderDeposit:SetText(CraftSim.GUTIL:ColorizeText(L("OPTIONS_TSM_ENHANCED_HEADER"),
        CraftSim.GUTIL.COLORS.LEGENDARY))

    local depositEnabledCheckbox = GGUI.Checkbox {
        parent = parent, anchorParent = sectionHeaderDeposit,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -10,
        initialValue = CraftSim.DB.OPTIONS:Get("TSM_DEPOSIT_ENABLED"),
        label = " " .. L("OPTIONS_TSM_DEPOSIT_ENABLED_LABEL"),
        tooltip = L("OPTIONS_TSM_DEPOSIT_ENABLED_TOOLTIP"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("TSM_DEPOSIT_ENABLED", checked)
        end
    }

    local depositExpressionTitle = parent:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    depositExpressionTitle:SetPoint("TOPLEFT", depositEnabledCheckbox.frame, "BOTTOMLEFT", 0, -5)
    depositExpressionTitle:SetText(L("OPTIONS_TSM_DEPOSIT_EXPRESSION_LABEL"))

    local tsmDepositExpression = CreateFrame("EditBox", "CraftSimTSMDepositExpression", parent,
        "InputBoxTemplate")
    tsmDepositExpression:SetPoint("TOPLEFT", depositExpressionTitle, "BOTTOMLEFT", 0, -5)
    tsmDepositExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmDepositExpression:SetAutoFocus(false)
    tsmDepositExpression:SetFontObject("ChatFontNormal")
    tsmDepositExpression:SetText(CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.TSM_DEPOSIT_EXPRESSION))
    tsmDepositExpression:SetScript("OnEscapePressed", function() tsmDepositExpression:ClearFocus() end)
    tsmDepositExpression:SetScript("OnEnterPressed", function() tsmDepositExpression:ClearFocus() end)
    tsmDepositExpression:SetScript("OnTextChanged", function()
        local expression = tsmDepositExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoDeposit:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_INVALID_EXPRESSION"), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoDeposit:SetText(CraftSim.GUTIL:ColorizeText(
                L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_DEPOSIT_EXPRESSION,
                tsmDepositExpression:GetText())
            CraftSimTSM:ClearDepositCache()
        end
    end)

    local resetDepositBtn = GGUI.Button({
        parent = parent,
        anchorParent = tsmDepositExpression,
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 10,
        offsetY = 0,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L("OPTIONS_TSM_RESET"),
        clickCallback = function()
            tsmDepositExpression:SetText("vendorsell")
            CraftSimTSM:ClearDepositCache()
        end
    })

    local validationInfoDeposit = parent:CreateFontString('CraftSimTSMStringValidationInfoDeposit', 'OVERLAY',
        'GameFontNormal')
    validationInfoDeposit:SetPoint("LEFT", resetDepositBtn.frame, "RIGHT", 10, 0)
    validationInfoDeposit:SetText(CraftSim.GUTIL:ColorizeText(
        L("OPTIONS_TSM_VALID_EXPRESSION"), CraftSim.GUTIL.COLORS.GREEN))

    -- =========================================================================
    -- TSM Enhanced: Smart Restock Settings
    -- =========================================================================

    local smartRestockCheckbox = GGUI.Checkbox {
        parent = parent, anchorParent = tsmDepositExpression,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -8,
        initialValue = CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_ENABLED"),
        label = " " .. L("OPTIONS_TSM_SMART_RESTOCK_ENABLED_LABEL"),
        tooltip = L("OPTIONS_TSM_SMART_RESTOCK_ENABLED_TOOLTIP"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("TSM_SMART_RESTOCK_ENABLED", checked)
        end
    }

    local includeAltsCheckbox = GGUI.Checkbox {
        parent = parent, anchorParent = smartRestockCheckbox.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetX = 20, offsetY = -5,
        initialValue = CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_ALTS"),
        label = " " .. L("OPTIONS_TSM_SMART_RESTOCK_INCLUDE_ALTS_LABEL"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("TSM_SMART_RESTOCK_INCLUDE_ALTS", checked)
        end
    }

    GGUI.Checkbox {
        parent = parent, anchorParent = includeAltsCheckbox.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -5,
        initialValue = CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_WARBANK"),
        label = " " .. L("OPTIONS_TSM_SMART_RESTOCK_INCLUDE_WARBANK_LABEL"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("TSM_SMART_RESTOCK_INCLUDE_WARBANK", checked)
        end
    }
end

--- Global for `CraftSimOptionsTsm.xml` OnLoad; closes over this file's `CraftSim` table.
function CraftSimOptionsInitTSMPanel(frame)
    CraftSim.OPTIONS:InitTSMPanelFromTemplate(frame)
end
