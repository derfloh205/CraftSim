---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.OPTIONS
CraftSim.OPTIONS = {}

CraftSim.OPTIONS.lastOpenRecipeID = {}
function CraftSim.OPTIONS:Init()
    ---@class CraftSim.OPTIONS.Panel : Frame
    CraftSim.OPTIONS.optionsPanel = CreateFrame("Frame", "CraftSimOptionsPanel")

    CraftSim.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
    end)
    CraftSim.OPTIONS.optionsPanel.name = "CraftSim"
    local title = CraftSim.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
    title:SetText(L(CraftSim.CONST.TEXT.OPTIONS_TITLE))

    local contentPanelsOffsetY = -70
    local tabContentSizeX = 650
    local tabContentSizeY = 500

    ---@class CraftSim.Options.ContentFrame : GGUI.Frame
    CraftSim.OPTIONS.optionsPanel.contentFrame = GGUI.Frame {
        parent = CraftSim.OPTIONS.optionsPanel,
        anchorParent = CraftSim.OPTIONS.optionsPanel,
        offsetY = -50,
        sizeX = tabContentSizeX, sizeY = tabContentSizeY,
        anchorA = "TOP", anchorB = "TOP",
        backdropOptions = CraftSim.CONST.BACKDROPS.OPTIONS_CONTENT_FRAME
    }

    local GeneralTab = GGUI.BlizzardTab {
        parent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame, anchorParent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame,
        offsetY = contentPanelsOffsetY, sizeX = tabContentSizeX, sizeY = tabContentSizeY,
        anchorA = "TOP", anchorB = "TOP", initialTab = true, top = true,
        buttonOptions = {
            label = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB),
            parent = CraftSim.OPTIONS.optionsPanel, anchorParent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame,
        },
    }
    local TSMTab
    if select(2, C_AddOns.IsAddOnLoaded("TradeSkillMaster")) then
        TSMTab = GGUI.BlizzardTab {
            parent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame, anchorParent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame,
            offsetY = contentPanelsOffsetY, sizeX = tabContentSizeX, sizeY = tabContentSizeY,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT", top = true,
            buttonOptions = {
                label = "TSM",
                parent = CraftSim.OPTIONS.optionsPanel, anchorParent = GeneralTab.button, anchorA = "LEFT", anchorB = "RIGHT",
            },
        }
        self:InitTSMTab(TSMTab)
    end
    local ModulesTab = GGUI.BlizzardTab {
        parent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame, anchorParent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame,
        offsetY = contentPanelsOffsetY, sizeX = tabContentSizeX, sizeY = tabContentSizeY,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", top = true,
        buttonOptions = {
            label = L(CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB),
            parent = CraftSim.OPTIONS.optionsPanel, anchorParent = (TSMTab and TSMTab.button) or GeneralTab.button, anchorA = "LEFT", anchorB = "RIGHT",
        },
    }

    local ProfitCalculationTab = GGUI.BlizzardTab {
        parent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame, anchorParent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame,
        offsetY = contentPanelsOffsetY, sizeX = tabContentSizeX, sizeY = tabContentSizeY,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", top = true,
        buttonOptions = {
            label = L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB),
            parent = CraftSim.OPTIONS.optionsPanel, anchorParent = ModulesTab.button, anchorA = "LEFT", anchorB = "RIGHT",
        },
    }

    local CraftingTab = GGUI.BlizzardTab {
        parent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame, anchorParent = CraftSim.OPTIONS.optionsPanel.contentFrame.frame,
        offsetY = contentPanelsOffsetY, sizeX = tabContentSizeX, sizeY = tabContentSizeY,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", top = true,
        buttonOptions = {
            label = L(CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB),
            parent = CraftSim.OPTIONS.optionsPanel, anchorParent = ProfitCalculationTab.button, anchorA = "LEFT", anchorB = "RIGHT",
        },
    }

    if TSMTab then
        GGUI.BlizzardTabSystem({ GeneralTab, TSMTab, ModulesTab, ProfitCalculationTab, CraftingTab })
    else
        GGUI.BlizzardTabSystem({ GeneralTab, ModulesTab, ProfitCalculationTab, CraftingTab })
    end

    local priceSourceAddons = CraftSim.PRICE_APIS:GetAvailablePriceSourceAddons()
    if #priceSourceAddons > 1 then
        local priceSourceAddonsDropdownData = {}
        for _, priceSourceName in pairs(priceSourceAddons) do
            table.insert(priceSourceAddonsDropdownData, {
                label = priceSourceName,
                value = priceSourceName,
            })
        end
        CraftSim.OPTIONS.priceSourceDropdown = GGUI.Dropdown({
            parent = GeneralTab.content,
            anchorParent = GeneralTab.content,
            label = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE),
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -50,
            width = 200,
            initialData = priceSourceAddonsDropdownData,
            initialValue = CraftSim.PRICE_API.name,
            initialLabel = CraftSim.PRICE_API.name,
            clickCallback = function(_, _, newPriceSource)
                CraftSim.PRICE_APIS:SwitchAPIByAddonName(newPriceSource)
                CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.PRICE_SOURCE, newPriceSource)
            end
        })
    elseif #priceSourceAddons == 1 then
        local info = GeneralTab.content:CreateFontString('info', 'OVERLAY', 'GameFontNormal')
        info:SetPoint("TOP", 0, -50)
        info:SetText(L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE) ..
            " " .. tostring(CraftSim.PRICE_API.name))
    else
        local warning = GeneralTab.content:CreateFontString('warning', 'OVERLAY', 'GameFontNormal')
        warning:SetPoint("TOP", 0, -50)
        warning:SetText(L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE))
    end


    GGUI.NumericInput {
        parent = ModulesTab.content, anchorParent = ModulesTab.content,
        anchorA = "TOP", anchorB = "TOP", label = L(CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT),
        offsetX = -30,
        offsetY = -20, sizeX = 85, sizeY = 10, initialValue = CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT"), allowDecimals = false, minValue = 1,
        onNumberValidCallback = function(numberInput)
            local value = tonumber(numberInput.currentValue)
            CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT", value)
        end, borderAdjustHeight = 0.7, borderWidth = 30,
        labelOptions = {
            text = L(CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE),
            parent = ModulesTab.content, anchorA = "LEFT", anchorB = "RIGHT",
            offsetX = 5,
        },
    }

    local skillBreakpointsCheckbox = GGUI.Checkbox {
        parent = ProfitCalculationTab.content, anchorParent = ProfitCalculationTab.content,
        anchorA = "TOP", anchorB = "TOP", offsetX = -90, offsetY = -50,
        initialValue = CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET"),
        label = L("OPTIONS_PROFIT_CALCULATION_OFFSET"),
        tooltip = L("OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("QUALITY_BREAKPOINT_OFFSET", checked)
        end
    }

    local customResourcefulnessConstantInput = CraftSim.FRAME:CreateInput("CraftSimOptionsInputResourcefulnessConstant",
        ProfitCalculationTab.content, customMulticraftConstantInput, "TOPLEFT", "BOTTOMLEFT", 0, -10, 100, 25,
        CraftSim.DB.OPTIONS:Get("PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT"),
        function()
            CraftSim.DB.OPTIONS:Save("PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT",
                tonumber(CraftSimOptionsInputResourcefulnessConstant:GetText()))
        end)

    CraftSim.FRAME:CreateText(
        L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT),
        ProfitCalculationTab.content, customResourcefulnessConstantInput, "LEFT", "RIGHT", 5, 0)

    CraftSim.FRAME:CreateHelpIcon(
        L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION),
        ProfitCalculationTab.content, customResourcefulnessConstantInput, "RIGHT", "LEFT", -5, 0)


    local percentProfitCheckbox = GGUI.Checkbox {
        label = " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT),
        tooltip = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE"),
        parent = GeneralTab.content, anchorParent = GeneralTab.content,
        anchorA = "TOP", anchorB = "TOP", offsetX = -90, offsetY = -90,
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("SHOW_PROFIT_PERCENTAGE", checked)
        end
    }

    local openLastRecipeCheckbox = GGUI.Checkbox {
        label = " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE),
        tooltip = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("OPEN_LAST_RECIPE"),
        parent = GeneralTab.content, anchorParent = percentProfitCheckbox.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("OPEN_LAST_RECIPE", checked)
        end
    }

    local showNewsCheckbox = GGUI.Checkbox {
        label = " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX),
        tooltip = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("SHOW_NEWS"),
        parent = GeneralTab.content, anchorParent = openLastRecipeCheckbox.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("SHOW_NEWS", checked)
        end
    }

    local hideMinimapButtonCheckbox = GGUI.Checkbox {
        label = " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX),
        tooltip = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("MINIMAP_BUTTON_HIDE"),
        parent = GeneralTab.content, anchorParent = showNewsCheckbox.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("MINIMAP_BUTTON_HIDE", checked)

            if checked then
                CraftSim.LibIcon:Hide("CraftSim")
            else
                CraftSim.LibIcon:Show("CraftSim")
            end
        end
    }

    local coinMoneyFormatDB = GGUI.Checkbox {
        label = " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX) .. GUTIL:FormatMoney(123456789, nil, nil, true, true),
        tooltip = L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("MONEY_FORMAT_USE_TEXTURES"),
        parent = GeneralTab.content, anchorParent = hideMinimapButtonCheckbox.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("MONEY_FORMAT_USE_TEXTURES", checked)
        end
    }

    local supportedPriceSources = GeneralTab.content:CreateFontString('priceSources', 'OVERLAY', 'GameFontNormal')
    supportedPriceSources:SetPoint("TOP", 0, -210)
    supportedPriceSources:SetText(L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES) ..
        "\n\n" .. table.concat(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS, "\n"))

    local enableGarbageCollectWhenCraftingCB = GGUI.Checkbox {
        parent = CraftingTab.content, anchorParent = CraftingTab.content,
        anchorA = "TOP", anchorB = "TOP", offsetX = -90, offsetY = -50,
        label = L("OPTIONS_PERFORMANCE_RAM"),
        tooltip = L("OPTIONS_PERFORMANCE_RAM_TOOLTIP"),
        initialValue = CraftSim.DB.OPTIONS:Get("CRAFTING_GARBAGE_COLLECTION_ENABLED"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("CRAFTING_GARBAGE_COLLECTION_ENABLED", checked)
        end
    }

    local garbageCollectCraftsInput = CraftSim.FRAME:CreateInput("CraftSimGarbageCollectCraftsInput", CraftingTab
        .content, enableGarbageCollectWhenCraftingCB.frame, "TOPLEFT", "BOTTOMLEFT", 10, -10, 100, 25,
        CraftSim.DB.OPTIONS:Get("CRAFTING_GARBAGE_COLLECTION_CRAFTS"),
        function()
            local number = CraftSim.UTIL:ValidateNumberInput(CraftSimGarbageCollectCraftsInput, false)
            CraftSim.DB.OPTIONS:Save("CRAFTING_GARBAGE_COLLECTION_CRAFTS", number)
        end)

    CraftSim.FRAME:CreateText(L("OPTIONS_PERFORMANCE_RAM_CRAFTS"), CraftingTab.content, garbageCollectCraftsInput, "LEFT",
        "RIGHT", 5, 0)

    CraftingTab.content.flashTaskBarCD = GGUI.Checkbox {
        parent = CraftingTab.content, anchorParent = enableGarbageCollectWhenCraftingCB.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetX = 0, offsetY = -50,
        initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FLASH_TASKBAR_ON_CRAFT_FINISHED"),
        label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL),
        tooltip = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_FLASH_TASKBAR_ON_CRAFT_FINISHED", checked)
        end
    }

    CraftSim.OPTIONS.category = Settings.RegisterCanvasLayoutCategory(self.optionsPanel, self.optionsPanel.name)
    CraftSim.OPTIONS.category.ID = self.optionsPanel.name
    Settings.RegisterAddOnCategory(CraftSim.OPTIONS.category)
end

function CraftSim.OPTIONS:InitTSMTab(TSMTab)
    local expressionSizeX = 300
    local expressionSizeY = 50

    local tsmReagentsPriceExpression = CreateFrame("EditBox", nil, TSMTab.content,
        "InputBoxTemplate")
    tsmReagentsPriceExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, 0)
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
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoReagents:SetText(CraftSim.GUTIL:ColorizeText(
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_REAGENTS,
                tsmReagentsPriceExpression:GetText())
        end
    end)

    GGUI.Button({
        parent = TSMTab.content,
        anchorParent = tsmReagentsPriceExpression,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -10,
        offsetY = 1,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L(CraftSim.CONST.TEXT.OPTIONS_TSM_RESET),
        clickCallback = function()
            tsmReagentsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local tsmExpressionTitleReagents = TSMTab.content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    tsmExpressionTitleReagents:SetPoint("BOTTOMLEFT", tsmReagentsPriceExpression, "TOPLEFT", 0, -10)
    tsmExpressionTitleReagents:SetText("TSM Crafting Reagents Price Expression")

    local validationInfoReagents = TSMTab.content:CreateFontString('CraftSimTSMStringValidationInfoReagents', 'OVERLAY',
        'GameFontNormal')
    validationInfoReagents:SetPoint("LEFT", tsmReagentsPriceExpression, "RIGHT", 5, 0)
    validationInfoReagents:SetText(CraftSim.GUTIL:ColorizeText(
        L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))

    local tsmItemsPriceExpression = CreateFrame("EditBox", "CraftSimTSMPriceExpressionItems", TSMTab.content,
        "InputBoxTemplate")
    tsmItemsPriceExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, -80)
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
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoItems:SetText(CraftSim.GUTIL:ColorizeText(
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_ITEMS,
                tsmItemsPriceExpression:GetText())
        end
    end)

    GGUI.Button({
        parent = TSMTab.content,
        anchorParent = tsmItemsPriceExpression,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -10,
        offsetY = 1,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L(CraftSim.CONST.TEXT.OPTIONS_TSM_RESET),
        clickCallback = function()
            tsmItemsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local tsmExpressionTitleItems = TSMTab.content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    tsmExpressionTitleItems:SetPoint("BOTTOMLEFT", tsmItemsPriceExpression, "TOPLEFT", 0, -10)
    tsmExpressionTitleItems:SetText("TSM Crafted Items Price Expression")

    local validationInfoItems = TSMTab.content:CreateFontString('CraftSimTSMStringValidationInfoItems', 'OVERLAY',
        'GameFontNormal')
    validationInfoItems:SetPoint("LEFT", tsmItemsPriceExpression, "RIGHT", 5, 0)
    validationInfoItems:SetText(CraftSim.GUTIL:ColorizeText(
        L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))

    -- Custom source for restock quantity
    local tsmRestockExpression = CreateFrame("EditBox", "CraftSimTSMRestockExpressionItems", TSMTab.content,
        "InputBoxTemplate")
    tsmRestockExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, -160)
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
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoRestockItems:SetText(CraftSim.GUTIL:ColorizeText(
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))
            CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.TSM_RESTOCK_KEY_ITEMS,
                tsmRestockExpression:GetText())
        end
    end)

    local tsmRestockDefaultButton = GGUI.Button({
        parent = TSMTab.content,
        anchorParent = tsmRestockExpression,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -10,
        offsetY = 1,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L(CraftSim.CONST.TEXT.OPTIONS_TSM_RESET),
        clickCallback = function()
            tsmRestockExpression:SetText("1")
        end
    })

    local tsmExpressionTitleRestockItems = TSMTab.content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    tsmExpressionTitleRestockItems:SetPoint("BOTTOMLEFT", tsmRestockExpression, "TOPLEFT", 0, -10)
    tsmExpressionTitleRestockItems:SetText("TSM Crafted Items Restock Qty Expression")

    local validationInfoItems = TSMTab.content:CreateFontString('CraftSimTSMStringValidationInfoRestockItems', 'OVERLAY',
        'GameFontNormal')
    validationInfoItems:SetPoint("LEFT", tsmRestockExpression, "RIGHT", 5, 0)
    validationInfoItems:SetText(CraftSim.GUTIL:ColorizeText(
        L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))
end
