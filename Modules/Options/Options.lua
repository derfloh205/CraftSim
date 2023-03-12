AddonName, CraftSim = ...

CraftSim.OPTIONS = {}

CraftSim.OPTIONS.lastOpenRecipeID = {}
function CraftSim.OPTIONS:Init()
    CraftSim.OPTIONS.optionsPanel = CreateFrame("Frame", "CraftSimOptionsPanel")
    
	CraftSim.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)
        CraftSim.OPTIONS.optionsPanel.name = "CraftSim"
	local title = CraftSim.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("CraftSim Options")

    local contentPanelsOffsetY = -70
    local tabExtraWidth = 15

    local generalTab = CreateFrame("Button", "CraftSimOptionsGeneralTab", CraftSim.OPTIONS.optionsPanel, "UIPanelButtonTemplate")
    generalTab.canBeEnabled = true
    generalTab:SetText("General")
    generalTab:SetSize(generalTab:GetTextWidth() + tabExtraWidth, 30)
    generalTab:SetPoint("TOPLEFT", CraftSim.OPTIONS.optionsPanel, "TOPLEFT", 0, -50)


    generalTab.content = CreateFrame("Frame", nil, CraftSim.OPTIONS.optionsPanel)
    generalTab.content:SetPoint("TOP", CraftSim.OPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    generalTab.content:SetSize(300, 350)

    local tooltipTab = CreateFrame("Button", "CraftSimOptionsTooltipTab", CraftSim.OPTIONS.optionsPanel, "UIPanelButtonTemplate")
    tooltipTab:SetText("Tooltip")
    tooltipTab:SetSize(tooltipTab:GetTextWidth() + tabExtraWidth, 30)
    tooltipTab:SetPoint("LEFT", generalTab, "RIGHT", 0, 0)

    tooltipTab.content = CreateFrame("Frame", nil, CraftSim.OPTIONS.optionsPanel)
    tooltipTab.content:SetPoint("TOP", CraftSim.OPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    tooltipTab.content:SetSize(300, 350)
    tooltipTab.canBeEnabled = true
    tooltipTab:Hide()
    tooltipTab.content:Hide()

    local TSMTab = CreateFrame("Button", "CraftSimOptionsTSMTab", CraftSim.OPTIONS.optionsPanel, "UIPanelButtonTemplate")
    TSMTab:SetText("TSM")
    TSMTab:SetSize(TSMTab:GetTextWidth() + tabExtraWidth, 30)
    TSMTab:SetPoint("LEFT", generalTab, "RIGHT", 0, 0)

    TSMTab.content = CreateFrame("Frame", nil, CraftSim.OPTIONS.optionsPanel)
    TSMTab.content:SetPoint("TOP", CraftSim.OPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    TSMTab.content:SetSize(300, 350)

    TSMTab:SetEnabled(IsAddOnLoaded("TradeSkillMaster"))
    TSMTab.canBeEnabled = IsAddOnLoaded("TradeSkillMaster")

    local AccountSyncTab = CreateFrame("Button", "CraftSimOptionsAccountSyncTab", CraftSim.OPTIONS.optionsPanel, "UIPanelButtonTemplate")
    AccountSyncTab:SetText("Account Sync")
    AccountSyncTab:SetSize(AccountSyncTab:GetTextWidth() + tabExtraWidth, 30)
    AccountSyncTab:SetPoint("LEFT", TSMTab, "RIGHT", 0, 0)

    AccountSyncTab.content = CreateFrame("Frame", nil, CraftSim.OPTIONS.optionsPanel)
    AccountSyncTab.content:SetPoint("TOP", CraftSim.OPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    AccountSyncTab.content:SetSize(300, 350)
    AccountSyncTab.canBeEnabled = true
    AccountSyncTab:Hide()
    AccountSyncTab.content:Hide()

    local ModulesTab = CreateFrame("Button", "CraftSimOptionsModulesTab", CraftSim.OPTIONS.optionsPanel, "UIPanelButtonTemplate")
    ModulesTab:SetText("Modules")
    ModulesTab:SetSize(ModulesTab:GetTextWidth() + tabExtraWidth, 30)
    ModulesTab:SetPoint("LEFT", TSMTab, "RIGHT", 0, 0)

    ModulesTab.content = CreateFrame("Frame", nil, CraftSim.OPTIONS.optionsPanel)
    ModulesTab.content:SetPoint("TOP", CraftSim.OPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    ModulesTab.content:SetSize(300, 350)
    ModulesTab.canBeEnabled = true

    local ProfitCalculationTab = CreateFrame("Button", "CraftSimOptionsProfitCalculationTab", CraftSim.OPTIONS.optionsPanel, "UIPanelButtonTemplate")
    ProfitCalculationTab:SetText("Profit Calculation")
    ProfitCalculationTab:SetSize(ProfitCalculationTab:GetTextWidth() + tabExtraWidth, 30)
    ProfitCalculationTab:SetPoint("LEFT", ModulesTab, "RIGHT", 0, 0)

    ProfitCalculationTab.content = CreateFrame("Frame", nil, CraftSim.OPTIONS.optionsPanel)
    ProfitCalculationTab.content:SetPoint("TOP", CraftSim.OPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    ProfitCalculationTab.content:SetSize(300, 350)
    ProfitCalculationTab.canBeEnabled = true

    local CraftingTab = CraftSim.FRAME:CreateTab("Crafting", CraftSim.OPTIONS.optionsPanel, 
    ProfitCalculationTab, "LEFT", "RIGHT", 0, 0, true, 300, 350, CraftSim.OPTIONS.optionsPanel, CraftSim.OPTIONS.optionsPanel, 0, contentPanelsOffsetY)

    local expressionSizeX = 300
    local expressionSizeY = 50

    local tsmMaterialsPriceExpression = CreateFrame("EditBox", "CraftSimTSMPriceExpressionMaterials", TSMTab.content, "InputBoxTemplate")
    tsmMaterialsPriceExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, -50)
    tsmMaterialsPriceExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmMaterialsPriceExpression:SetMultiLine(true)
    tsmMaterialsPriceExpression:SetAutoFocus(false) -- dont automatically focus
    tsmMaterialsPriceExpression:SetFontObject("ChatFontNormal")
    tsmMaterialsPriceExpression:SetText(CraftSimOptions.tsmPriceKeyMaterials)
    tsmMaterialsPriceExpression:SetScript("OnEscapePressed", function() tsmMaterialsPriceExpression:ClearFocus() end)
    tsmMaterialsPriceExpression:SetScript("OnEnterPressed", function() tsmMaterialsPriceExpression:ClearFocus() end)
    tsmMaterialsPriceExpression:SetScript("OnTextChanged", function()
        local expression = tsmMaterialsPriceExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoMaterials:SetText(CraftSim.GUTIL:ColorizeText("Expression Invalid", CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoMaterials:SetText(CraftSim.GUTIL:ColorizeText("Expression Valid", CraftSim.GUTIL.COLORS.GREEN))
            CraftSimOptions.tsmPriceKeyMaterials = tsmMaterialsPriceExpression:GetText()
        end
    end)

    CraftSim.GGUI.Button({
        parent=TSMTab.content,anchorParent=tsmMaterialsPriceExpression,anchorA="RIGHT",anchorB="LEFT",offsetX=-10,offsetY=1,sizeX=15,sizeY=20,adjustWidth=true,
        label="Reset Default",
        clickCallback=function ()
            tsmMaterialsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local tsmExpressionTitleMaterials = TSMTab.content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    tsmExpressionTitleMaterials:SetPoint("BOTTOMLEFT", tsmMaterialsPriceExpression, "TOPLEFT",  0, 10)
    tsmExpressionTitleMaterials:SetText("TSM Crafting Materials Price Expression")

    local validationInfoMaterials = TSMTab.content:CreateFontString('CraftSimTSMStringValidationInfoMaterials', 'OVERLAY', 'GameFontNormal')
    validationInfoMaterials:SetPoint("TOPLEFT", tsmMaterialsPriceExpression, "TOPRIGHT",  5, 0)
    validationInfoMaterials:SetText(CraftSim.GUTIL:ColorizeText("Expression Valid", CraftSim.GUTIL.COLORS.GREEN))

    local tsmItemsPriceExpression = CreateFrame("EditBox", "CraftSimTSMPriceExpressionItems", TSMTab.content, "InputBoxTemplate")
    tsmItemsPriceExpression:SetPoint("TOP", TSMTab.content, "TOP", 0, -200)
    tsmItemsPriceExpression:SetSize(expressionSizeX, expressionSizeY)
    tsmItemsPriceExpression:SetMultiLine(true)
    tsmItemsPriceExpression:SetAutoFocus(false) -- dont automatically focus
    tsmItemsPriceExpression:SetFontObject("ChatFontNormal")
    tsmItemsPriceExpression:SetText(CraftSimOptions.tsmPriceKeyItems)
    tsmItemsPriceExpression:SetScript("OnEscapePressed", function() tsmItemsPriceExpression:ClearFocus() end)
    tsmItemsPriceExpression:SetScript("OnEnterPressed", function() tsmItemsPriceExpression:ClearFocus() end)
    tsmItemsPriceExpression:SetScript("OnTextChanged", function()
        local expression = tsmItemsPriceExpression:GetText()
        local isValid = TSM_API.IsCustomPriceValid(expression)
        if not isValid then
            CraftSimTSMStringValidationInfoItems:SetText(CraftSim.GUTIL:ColorizeText("Expression Invalid", CraftSim.GUTIL.COLORS.RED))
        else
            CraftSimTSMStringValidationInfoItems:SetText(CraftSim.GUTIL:ColorizeText("Expression Valid", CraftSim.GUTIL.COLORS.GREEN))
            CraftSimOptions.tsmPriceKeyItems = tsmItemsPriceExpression:GetText()
        end
    end)

    CraftSim.GGUI.Button({
        parent=TSMTab.content,anchorParent=tsmItemsPriceExpression,anchorA="RIGHT",anchorB="LEFT",offsetX=-10,offsetY=1,sizeX=15,sizeY=20,adjustWidth=true,
        label="Reset Default",
        clickCallback=function ()
            tsmItemsPriceExpression:SetText(CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION)
        end
    })

    local tsmExpressionTitleItems = TSMTab.content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    tsmExpressionTitleItems:SetPoint("BOTTOMLEFT", tsmItemsPriceExpression, "TOPLEFT",  0, 10)
    tsmExpressionTitleItems:SetText("TSM Crafted Items Price Expression")

    local validationInfoItems = TSMTab.content:CreateFontString('CraftSimTSMStringValidationInfoItems', 'OVERLAY', 'GameFontNormal')
    validationInfoItems:SetPoint("TOPLEFT", tsmItemsPriceExpression, "TOPRIGHT",  5, 0)
    validationInfoItems:SetText(CraftSim.GUTIL:ColorizeText("Expression Valid", CraftSim.GUTIL.COLORS.GREEN))

    CraftSim.FRAME:InitTabSystem({generalTab, tooltipTab, TSMTab, ModulesTab, ProfitCalculationTab, CraftingTab}) -- AccountSyncTab

    local priceSourceAddons = CraftSim.PRICE_APIS:GetAvailablePriceSourceAddons()
    if #priceSourceAddons > 1 then
        local priceSourceAddonsDropdownData = {}
        for _, priceSourceName in pairs(priceSourceAddons) do
            table.insert(priceSourceAddonsDropdownData, {
                label=priceSourceName,
                value=priceSourceName,
            })
        end
        CraftSim.OPTIONS.priceSourceDropdown = CraftSim.GGUI.Dropdown({
            parent=generalTab.content, anchorParent=generalTab.content, label="Price Source", anchorA="TOP", anchorB="TOP",
            offsetY=-50, width=200, initialData=priceSourceAddonsDropdownData, initialValue=CraftSim.PRICE_API.name,
            initialLabel=CraftSim.PRICE_API.name,
            clickCallback=function(_, _, value) 
                CraftSim.PRICE_APIS:SwitchAPIByAddonName(value)
                CraftSimOptions.priceSource = value
            end
        })
    elseif #priceSourceAddons == 1 then
        local info = generalTab.content:CreateFontString('info', 'OVERLAY', 'GameFontNormal')
        info:SetPoint("TOP", 0, -50)
        info:SetText("Current Price Source: " .. tostring(CraftSim.PRICE_API.name))
    else
        local warning = generalTab.content:CreateFontString('warning', 'OVERLAY', 'GameFontNormal')
        warning:SetPoint("TOP", 0, -50)
        warning:SetText("No Supported Price Source Addon loaded!")
    end

    local materialSuggestionTransparencySlider =  CraftSim.FRAME:CreateSlider("CraftSimMaterialSlider", 
        "Transparency\n ", ModulesTab.content, ModulesTab.content, 
        "TOP", "TOP", -15, -50, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyMaterials, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.MATERIALS):SetTransparency(value)
            CraftSimOptions.transparencyMaterials = value
        end)
    CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.MATERIALS):SetTransparency(CraftSimOptions.transparencyMaterials)

    CraftSim.FRAME:CreateText("Material Optimizing Module", 
    ModulesTab.content, materialSuggestionTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)

    local CraftSimDetailsTransparencySlider =  CraftSim.FRAME:CreateSlider("CraftSimDetailsSlider", 
        "", ModulesTab.content, materialSuggestionTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyStatWeights, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS):SetTransparency(value)
            CraftSimOptions.transparencyStatWeights = value
        end)

    CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS):SetTransparency(CraftSimOptions.transparencyStatWeights)
    CraftSim.FRAME:CreateText("Average Profit Module", 
    ModulesTab.content, CraftSimDetailsTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)


    local CraftSimTopGearTransparencySlider =  CraftSim.FRAME:CreateSlider("CraftSimTopGearSlider", 
        "", ModulesTab.content, CraftSimDetailsTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyTopGear, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR):SetTransparency(value)
            CraftSimOptions.transparencyTopGear = value
        end)
    CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR):SetTransparency(CraftSimOptions.transparencyTopGear)
    CraftSim.FRAME:CreateText("Top Gear Module", 
    ModulesTab.content, CraftSimTopGearTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)


    local CraftSimCostOverviewTransparencySlider =  CraftSim.FRAME:CreateSlider("CraftSimCostOverviewSlider", 
        "", ModulesTab.content, CraftSimTopGearTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyCostOverview, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSim.PRICE_DETAILS.frame:SetTransparency(value)
            CraftSimOptions.transparencyCostOverview = value
        end)
    CraftSim.PRICE_DETAILS.frame:SetTransparency(CraftSimOptions.transparencyCostOverview)
    CraftSim.FRAME:CreateText("Cost Overview Module", 
    ModulesTab.content, CraftSimCostOverviewTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)

    local specInfoTransparencySlider =  CraftSim.FRAME:CreateSlider("CraftSimSpecInfoSlider", 
        "", ModulesTab.content, CraftSimCostOverviewTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencySpecInfo, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO):SetTransparency(value)
            CraftSimOptions.transparencySpecInfo = value
        end)
    CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO):SetTransparency(CraftSimOptions.transparencySpecInfo)
    CraftSim.FRAME:CreateText("Specialization Info Module", 
    ModulesTab.content, specInfoTransparencySlider, "LEFT", "RIGHT", 10, 0, 1, nil)

     local skillBreakpointsCheckbox = CraftSim.FRAME:CreateCheckbox(" Offset Skill Breakpoints by 1", 
     "The material combination suggestion will try to reach the breakpoint + 1 instead of matching the exact skill required",
     "breakPointOffset", 
     ProfitCalculationTab.content, 
     ProfitCalculationTab.content, 
     "TOP", 
     "TOP", 
     -90, 
     -50)

    local customMulticraftConstantInput = CraftSim.FRAME:CreateInput("CraftSimOptionsInputMulticraftConstant", ProfitCalculationTab.content, skillBreakpointsCheckbox, "TOPLEFT", "BOTTOMLEFT", 10, -10, 100, 25, 
        CraftSimOptions.customMulticraftConstant, 
        function ()
            CraftSimOptions.customMulticraftConstant = CraftSimOptionsInputMulticraftConstant:GetText()
        end)

    CraftSim.FRAME:CreateText("Multicraft Constant", ProfitCalculationTab.content, customMulticraftConstantInput, "LEFT", "RIGHT", 5, 0)

    CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_CONSTANT_EXPLANATION), ProfitCalculationTab.content, customMulticraftConstantInput, "RIGHT", "LEFT", -5, 0)

    local customResourcefulnessConstantInput = CraftSim.FRAME:CreateInput("CraftSimOptionsInputResourcefulnessConstant", ProfitCalculationTab.content, customMulticraftConstantInput, "TOPLEFT", "BOTTOMLEFT", 0, -10, 100, 25, 
    CraftSimOptions.customResourcefulnessConstant, 
    function ()
        CraftSimOptions.customResourcefulnessConstant = CraftSimOptionsInputResourcefulnessConstant:GetText()
    end)

    CraftSim.FRAME:CreateText("Resourcefulness Constant", ProfitCalculationTab.content, customResourcefulnessConstantInput, "LEFT", "RIGHT", 5, 0)

    CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_CONSTANT_EXPLANATION), ProfitCalculationTab.content, customResourcefulnessConstantInput, "RIGHT", "LEFT", -5, 0)

    
    local precentProfitCheckbox = CraftSim.FRAME:CreateCheckbox(" Show Profit Percentage", 
    "Show the percentage of profit to crafting costs besides the gold value",
    "showProfitPercentage", 
    generalTab.content, 
    generalTab.content, 
    "TOP", 
    "TOP", 
    -90, 
    -90)


    local openLastRecipeCheckbox = CraftSim.FRAME:CreateCheckbox(" Remember Last Recipe", 
    "Reopen last selected recipe when opening the crafting window",
    "openLastRecipe", 
    generalTab.content, 
    precentProfitCheckbox, 
    "TOP", 
    "TOP", 
    0, 
    -20)

    local detailedTooltips = CraftSim.FRAME:CreateCheckbox(" Detailed Last Crafting Information", 
    "Show the complete breakdown of your last used material combination in an item tooltip",
    "detailedCraftingInfoTooltip", 
    tooltipTab.content, 
    tooltipTab.content, 
    "TOP", 
    "TOP", 
    -90, 
    -50)

    local characterNameInput = CreateFrame("EditBox", "CraftSimSyncCharacterInput", AccountSyncTab.content, "InputBoxTemplate")
    characterNameInput:SetPoint("TOP", AccountSyncTab.content, "TOP", 20, -50)
    characterNameInput:SetSize(100, 20)
    characterNameInput:SetAutoFocus(false) -- dont automatically focus
    characterNameInput:SetFontObject("ChatFontNormal")
    characterNameInput:SetText(CraftSimOptions.syncTarget or "")
    characterNameInput:SetScript("OnEscapePressed", function() characterNameInput:ClearFocus() end)
    characterNameInput:SetScript("OnEnterPressed", function() characterNameInput:ClearFocus() end)
    characterNameInput:SetScript("OnTextChanged", function() 
        CraftSimOptions.syncTarget = characterNameInput:GetText()
    end)

    local inputBoxDescription = characterNameInput:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    inputBoxDescription:SetPoint("RIGHT", characterNameInput, "LEFT", 0, 0)
    inputBoxDescription:SetText("Target Character: ")

    local sendingProgress = characterNameInput:CreateFontString("CraftSimACCOUNTSYNCSendingProgress", 'OVERLAY', 'GameFontNormal')
    sendingProgress:SetPoint("LEFT", characterNameInput, "RIGHT", 5, 0)
    sendingProgress:SetText("")

    -- local accountSyncButton = CreateFrame("Button", "CraftSimACCOUNTSYNCButton", AccountSyncTab.content, "UIPanelButtonTemplate")
	-- accountSyncButton:SetPoint("TOPRIGHT", characterNameInput, "TOPRIGHT", 0, -30)	
	-- accountSyncButton:SetText("Synchronize Tooltip Data")
	-- accountSyncButton:SetSize(accountSyncButton:GetTextWidth() + 20, 25)
    -- accountSyncButton:SetScript("OnClick", function(self) 
    --     CraftSim.ACCOUNTSYNC:SynchronizeAccounts()
    -- end)

    local optionsSyncButton = CraftSim.GGUI.Button({
        parent=AccountSyncTab.content, anchorParent=characterNameInput, anchorA="TOPRIGHT", anchorB="TOPRIGHT", offsetY=-30,
        sizeX=20,sizeY=25,adjustWidth=true,label="Synchronize Options",
        clickCallback=function ()
            CraftSim.ACCOUNTSYNC:SynchronizeOptions()
        end
    })

    local supportedPriceSources = generalTab.content:CreateFontString('priceSources', 'OVERLAY', 'GameFontNormal')
    supportedPriceSources:SetPoint("TOP", 0, -200)
    supportedPriceSources:SetText("Supported Price Sources:\n\n" .. table.concat(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS, "\n"))

     local enableGarbageCollectWhenCraftingCB = CraftSim.FRAME:CreateCheckbox(" Enable RAM cleanup while crafting", 
        "When enabled, CraftSim will clear your RAM every specified number of crafts from unused data to prevent memory from building up.\nMemory Build Up can also happen because of other addons and is not CraftSim specific.\nA cleanup will affect the whole WoW RAM Usage.",
    "craftGarbageCollectEnabled",
    CraftingTab.content, 
    CraftingTab.content,
    "TOP", 
    "TOP", 
    -90, 
    -50)

    local garbageCollectCraftsInput = CraftSim.FRAME:CreateInput("CraftSimGarbageCollectCraftsInput", CraftingTab.content, enableGarbageCollectWhenCraftingCB, "TOPLEFT", "BOTTOMLEFT", 10, -10, 100, 25, 
        CraftSimOptions.craftGarbageCollectCrafts, 
        function ()
            local number = CraftSim.UTIL:ValidateNumberInput(CraftSimGarbageCollectCraftsInput, false)
            CraftSimOptions.craftGarbageCollectCrafts = number
        end)

    CraftSim.FRAME:CreateText("Crafts", CraftingTab.content, garbageCollectCraftsInput, "LEFT", "RIGHT", 5, 0)
    
	InterfaceOptions_AddCategory(self.optionsPanel)
end