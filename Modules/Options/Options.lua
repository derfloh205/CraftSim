---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI

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
            clickCallback = function(_, _, value)
                CraftSim.PRICE_APIS:SwitchAPIByAddonName(value)
                CraftSimOptions.priceSource = value
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

    local materialSuggestionTransparencySlider = CraftSim.FRAME:CreateSlider("CraftSimMaterialSlider",
        L(CraftSim.CONST.TEXT.OPTIONS_MODULES_TRANSPARENCY) .. "\n ", ModulesTab.content,
        ModulesTab.content,
        "TOP", "TOP", -15, -50, 100, 10, "HORIZONTAL",
        0, 1, CraftSimOptions.transparencyMaterials, -- get from options..
        "0", "1",
        function(self, value)
            GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS):SetTransparency(value)
            CraftSimOptions.transparencyMaterials = value
        end)
    GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS):SetTransparency(CraftSimOptions
        .transparencyMaterials)

    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_MODULES_MATERIALS),
        ModulesTab.content, materialSuggestionTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)

    local CraftSimDetailsTransparencySlider = CraftSim.FRAME:CreateSlider("CraftSimDetailsSlider",
        "", ModulesTab.content, materialSuggestionTransparencySlider,
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL",
        0, 1, CraftSimOptions.transparencyStatWeights, -- get from options..
        "0", "1",
        function(self, value)
            GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS):SetTransparency(value)
            CraftSimOptions.transparencyStatWeights = value
        end)

    GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS):SetTransparency(CraftSimOptions
        .transparencyStatWeights)
    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT),
        ModulesTab.content, CraftSimDetailsTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)


    local CraftSimTopGearTransparencySlider = CraftSim.FRAME:CreateSlider("CraftSimTopGearSlider",
        "", ModulesTab.content, CraftSimDetailsTransparencySlider,
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL",
        0, 1, CraftSimOptions.transparencyTopGear, -- get from options..
        "0", "1",
        function(self, value)
            GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR):SetTransparency(value)
            CraftSimOptions.transparencyTopGear = value
        end)
    GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR):SetTransparency(CraftSimOptions
        .transparencyTopGear)
    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR),
        ModulesTab.content, CraftSimTopGearTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)


    local CraftSimCostOverviewTransparencySlider = CraftSim.FRAME:CreateSlider("CraftSimCostOverviewSlider",
        "", ModulesTab.content, CraftSimTopGearTransparencySlider,
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL",
        0, 1, CraftSimOptions.transparencyCostOverview, -- get from options..
        "0", "1",
        function(self, value)
            CraftSim.PRICE_DETAILS.frame:SetTransparency(value)
            CraftSimOptions.transparencyCostOverview = value
        end)
    CraftSim.PRICE_DETAILS.frame:SetTransparency(CraftSimOptions.transparencyCostOverview)
    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW),
        ModulesTab.content, CraftSimCostOverviewTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)

    local specInfoTransparencySlider = CraftSim.FRAME:CreateSlider("CraftSimSpecInfoSlider",
        "", ModulesTab.content, CraftSimCostOverviewTransparencySlider,
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL",
        0, 1, CraftSimOptions.transparencySpecInfo, -- get from options..
        "0", "1",
        function(self, value)
            GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO):SetTransparency(value)
            CraftSimOptions.transparencySpecInfo = value
        end)
    GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO):SetTransparency(CraftSimOptions
        .transparencySpecInfo)
    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO),
        ModulesTab.content, specInfoTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)

    local historyMaxSizeInput = GGUI.NumericInput {
        parent = ModulesTab.content, anchorParent = specInfoTransparencySlider,
        anchorA = "TOP", anchorB = "TOP", label = "Max history entries per client",
        offsetY = -40, sizeX = 85, sizeY = 10, initialValue = CraftSimOptions.maxHistoryEntriesPerClient, allowDecimals = false, minValue = 1,
        onNumberValidCallback = function(numberInput)
            local value = tonumber(numberInput.currentValue)
            CraftSimOptions.maxHistoryEntriesPerClient = value
        end, borderAdjustHeight = 0.6, borderWidth = 30,
    }
    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE),
        ModulesTab.content, historyMaxSizeInput.textInput.frame, "LEFT", "RIGHT", 20, 0, 1, nil)

    local skillBreakpointsCheckbox = CraftSim.FRAME:CreateCheckbox(
        " " .. L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET),
        L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP),
        "breakPointOffset",
        ProfitCalculationTab.content,
        ProfitCalculationTab.content,
        "TOP",
        "TOP",
        -90,
        -50)

    local customMulticraftConstantInput = CraftSim.FRAME:CreateInput("CraftSimOptionsInputMulticraftConstant",
        ProfitCalculationTab.content, skillBreakpointsCheckbox, "TOPLEFT", "BOTTOMLEFT", 10, -10, 100, 25,
        CraftSimOptions.customMulticraftConstant,
        function()
            CraftSimOptions.customMulticraftConstant = CraftSimOptionsInputMulticraftConstant:GetText()
        end)

    CraftSim.FRAME:CreateText(L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT),
        ProfitCalculationTab.content, customMulticraftConstantInput, "LEFT", "RIGHT", 5, 0)

    CraftSim.FRAME:CreateHelpIcon(
        L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION),
        ProfitCalculationTab.content, customMulticraftConstantInput, "RIGHT", "LEFT", -5, 0)

    local customResourcefulnessConstantInput = CraftSim.FRAME:CreateInput("CraftSimOptionsInputResourcefulnessConstant",
        ProfitCalculationTab.content, customMulticraftConstantInput, "TOPLEFT", "BOTTOMLEFT", 0, -10, 100, 25,
        CraftSimOptions.customResourcefulnessConstant,
        function()
            CraftSimOptions.customResourcefulnessConstant = CraftSimOptionsInputResourcefulnessConstant:GetText()
        end)

    CraftSim.FRAME:CreateText(
        L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT),
        ProfitCalculationTab.content, customResourcefulnessConstantInput, "LEFT", "RIGHT", 5, 0)

    CraftSim.FRAME:CreateHelpIcon(
        L(CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION),
        ProfitCalculationTab.content, customResourcefulnessConstantInput, "RIGHT", "LEFT", -5, 0)


    local precentProfitCheckbox = CraftSim.FRAME:CreateCheckbox(
        " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT),
        L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP),
        "showProfitPercentage",
        GeneralTab.content,
        GeneralTab.content,
        "TOP",
        "TOP",
        -90,
        -90)

    local openLastRecipeCheckbox = CraftSim.FRAME:CreateCheckbox(
        " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE),
        L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP),
        "openLastRecipe",
        GeneralTab.content,
        precentProfitCheckbox,
        "TOPLEFT",
        "BOTTOMLEFT",
        0,
        0)

    local showNewsCheckbox = CraftSim.FRAME:CreateCheckbox(
        " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX),
        L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP),
        "optionsShowNews",
        GeneralTab.content,
        openLastRecipeCheckbox,
        "TOPLEFT",
        "BOTTOMLEFT",
        0,
        0)

    local hideMinimapButtonCheckbox = CraftSim.FRAME:CreateCheckbox(
        " " .. L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX),
        L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP),
        "optionsHideMinimapButton",
        GeneralTab.content,
        showNewsCheckbox,
        "TOPLEFT",
        "BOTTOMLEFT",
        0,
        0,
        function(checked)
            if checked then
                CraftSim.LibIcon:Hide("CraftSim")
            else
                CraftSim.LibIcon:Show("CraftSim")
            end
        end)

    local supportedPriceSources = GeneralTab.content:CreateFontString('priceSources', 'OVERLAY', 'GameFontNormal')
    supportedPriceSources:SetPoint("TOP", 0, -200)
    supportedPriceSources:SetText(L(CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES) ..
        "\n\n" .. table.concat(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS, "\n"))

    local enableGarbageCollectWhenCraftingCB = CraftSim.FRAME:CreateCheckbox(
        " " .. L(CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM),
        L(CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP),
        "craftGarbageCollectEnabled",
        CraftingTab.content,
        CraftingTab.content,
        "TOP",
        "TOP",
        -90,
        -50)

    local garbageCollectCraftsInput = CraftSim.FRAME:CreateInput("CraftSimGarbageCollectCraftsInput", CraftingTab
        .content, enableGarbageCollectWhenCraftingCB, "TOPLEFT", "BOTTOMLEFT", 10, -10, 100, 25,
        CraftSimOptions.craftGarbageCollectCrafts,
        function()
            local number = CraftSim.UTIL:ValidateNumberInput(CraftSimGarbageCollectCraftsInput, false)
            CraftSimOptions.craftGarbageCollectCrafts = number
        end)

    CraftSim.FRAME:CreateText("Crafts", CraftingTab.content, garbageCollectCraftsInput, "LEFT", "RIGHT", 5, 0)

    CraftingTab.content.flashTaskBarCD = GGUI.Checkbox {
        parent = CraftingTab.content, anchorParent = enableGarbageCollectWhenCraftingCB, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetX = 0, offsetY = -50,
        initialValue = CraftSimOptions.craftQueueFlashTaskbarOnCraftFinished,
        label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL),
        tooltip = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP),
        clickCallback = function(_, checked)
            CraftSimOptions.craftQueueFlashTaskbarOnCraftFinished = checked
        end
    }

    InterfaceOptions_AddCategory(self.optionsPanel)
end

function CraftSim.OPTIONS:InitTSMTab(TSMTab)
    local expressionSizeX = 300
    local expressionSizeY = 50

    local tsmMaterialsPriceExpression = CreateFrame("EditBox", "CraftSimTSMPriceExpressionMaterials", TSMTab.content,
        "InputBoxTemplate")
    tsmMaterialsPriceExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, 0)
    tsmMaterialsPriceExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmMaterialsPriceExpression:SetAutoFocus(false) -- dont automatically focus
    tsmMaterialsPriceExpression:SetFontObject("ChatFontNormal")
    tsmMaterialsPriceExpression:SetText(CraftSimOptions.tsmPriceKeyMaterials)
    tsmMaterialsPriceExpression:SetScript("OnEscapePressed", function() tsmMaterialsPriceExpression:ClearFocus() end)
    tsmMaterialsPriceExpression:SetScript("OnEnterPressed", function() tsmMaterialsPriceExpression:ClearFocus() end)
    tsmMaterialsPriceExpression:SetScript("OnTextChanged", function()
        local expression = tsmMaterialsPriceExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoMaterials:SetText(CraftSim.GUTIL:ColorizeText(
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION), CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoMaterials:SetText(CraftSim.GUTIL:ColorizeText(
                L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))
            CraftSimOptions.tsmPriceKeyMaterials = tsmMaterialsPriceExpression:GetText()
        end
    end)

    GGUI.Button({
        parent = TSMTab.content,
        anchorParent = tsmMaterialsPriceExpression,
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -10,
        offsetY = 1,
        sizeX = 15,
        sizeY = 20,
        adjustWidth = true,
        label = L(CraftSim.CONST.TEXT.OPTIONS_TSM_RESET),
        clickCallback = function()
            tsmMaterialsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local tsmExpressionTitleMaterials = TSMTab.content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    tsmExpressionTitleMaterials:SetPoint("BOTTOMLEFT", tsmMaterialsPriceExpression, "TOPLEFT", 0, -10)
    tsmExpressionTitleMaterials:SetText("TSM Crafting Materials Price Expression")

    local validationInfoMaterials = TSMTab.content:CreateFontString('CraftSimTSMStringValidationInfoMaterials', 'OVERLAY',
        'GameFontNormal')
    validationInfoMaterials:SetPoint("LEFT", tsmMaterialsPriceExpression, "RIGHT", 5, 0)
    validationInfoMaterials:SetText(CraftSim.GUTIL:ColorizeText(
        L(CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION), CraftSim.GUTIL.COLORS.GREEN))

    local tsmItemsPriceExpression = CreateFrame("EditBox", "CraftSimTSMPriceExpressionItems", TSMTab.content,
        "InputBoxTemplate")
    tsmItemsPriceExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, -80)
    tsmItemsPriceExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmItemsPriceExpression:SetAutoFocus(false) -- dont automatically focus
    tsmItemsPriceExpression:SetFontObject("ChatFontNormal")
    tsmItemsPriceExpression:SetText(CraftSimOptions.tsmPriceKeyItems)
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
            CraftSimOptions.tsmPriceKeyItems = tsmItemsPriceExpression:GetText()
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
end
