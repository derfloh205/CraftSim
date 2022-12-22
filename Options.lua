CraftSimOPTIONS = {}

CraftSimOPTIONS.lastOpenRecipeID = {}
function CraftSimOPTIONS:InitOptionsFrame()
    CraftSimOPTIONS.optionsPanel = CreateFrame("Frame", "CraftSimOptionsPanel")
    
	CraftSimOPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)
        CraftSimOPTIONS.optionsPanel.name = "CraftSim"
	local title = CraftSimOPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("CraftSim Options")

    local contentPanelsOffsetY = -70
    local tabExtraWidth = 15

    local generalTab = CreateFrame("Button", "CraftSimOptionsGeneralTab", CraftSimOPTIONS.optionsPanel, "UIPanelButtonTemplate")
    generalTab.canBeEnabled = true
    generalTab:SetText("General")
    generalTab:SetSize(generalTab:GetTextWidth() + tabExtraWidth, 30)
    generalTab:SetPoint("TOPLEFT", CraftSimOPTIONS.optionsPanel, "TOPLEFT", 0, -50)


    generalTab.content = CreateFrame("Frame", nil, CraftSimOPTIONS.optionsPanel)
    generalTab.content:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    generalTab.content:SetSize(300, 350)
    generalTab.canBeEnabled = true

    local tooltipTab = CreateFrame("Button", "CraftSimOptionsTooltipTab", CraftSimOPTIONS.optionsPanel, "UIPanelButtonTemplate")
    tooltipTab:SetText("Tooltip")
    tooltipTab:SetSize(tooltipTab:GetTextWidth() + tabExtraWidth, 30)
    tooltipTab:SetPoint("LEFT", generalTab, "RIGHT", 0, 0)

    tooltipTab.content = CreateFrame("Frame", nil, CraftSimOPTIONS.optionsPanel)
    tooltipTab.content:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    tooltipTab.content:SetSize(300, 350)
    tooltipTab.canBeEnabled = true

    local TSMTab = CreateFrame("Button", "CraftSimOptionsTSMTab", CraftSimOPTIONS.optionsPanel, "UIPanelButtonTemplate")
    TSMTab:SetText("TSM")
    TSMTab:SetSize(TSMTab:GetTextWidth() + tabExtraWidth, 30)
    TSMTab:SetPoint("LEFT", tooltipTab, "RIGHT", 0, 0)

    TSMTab.content = CreateFrame("Frame", nil, CraftSimOPTIONS.optionsPanel)
    TSMTab.content:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    TSMTab.content:SetSize(300, 350)

    TSMTab:SetEnabled(IsAddOnLoaded("TradeSkillMaster"))
    TSMTab.canBeEnabled = IsAddOnLoaded("TradeSkillMaster")

    local AccountSyncTab = CreateFrame("Button", "CraftSimOptionsAccountSyncTab", CraftSimOPTIONS.optionsPanel, "UIPanelButtonTemplate")
    AccountSyncTab:SetText("Account Sync")
    AccountSyncTab:SetSize(AccountSyncTab:GetTextWidth() + tabExtraWidth, 30)
    AccountSyncTab:SetPoint("LEFT", TSMTab, "RIGHT", 0, 0)

    AccountSyncTab.content = CreateFrame("Frame", nil, CraftSimOPTIONS.optionsPanel)
    AccountSyncTab.content:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    AccountSyncTab.content:SetSize(300, 350)
    AccountSyncTab.canBeEnabled = true

    local ModulesTab = CreateFrame("Button", "CraftSimOptionsModulesTab", CraftSimOPTIONS.optionsPanel, "UIPanelButtonTemplate")
    ModulesTab:SetText("Modules")
    ModulesTab:SetSize(ModulesTab:GetTextWidth() + tabExtraWidth, 30)
    ModulesTab:SetPoint("LEFT", AccountSyncTab, "RIGHT", 0, 0)

    ModulesTab.content = CreateFrame("Frame", nil, CraftSimOPTIONS.optionsPanel)
    ModulesTab.content:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    ModulesTab.content:SetSize(300, 350)
    ModulesTab.canBeEnabled = true

    local tsmPriceKeys = {"DBRecent", "DBMarket", "DBMinbuyout"}
    CraftSimFRAME:initDropdownMenu("CraftSimTSMPriceSourceDropdownMaterials", TSMTab.content, TSMTab.content ,"TSM Price Source Key Materials", 0, -50, 200, tsmPriceKeys, 
    function(arg1) 
        CraftSimOptions.tsmPriceKeyMaterials = arg1
    end, CraftSimOptions.tsmPriceKeyMaterials)

    CraftSimFRAME:initDropdownMenu("CraftSimTSMPriceSourceDropdownCraftedItems", TSMTab.content, TSMTab.content ,"TSM Price Source Key Crafted Items", 0, -100, 200, tsmPriceKeys, 
    function(arg1) 
        CraftSimOptions.tsmPriceKeyItems = arg1
    end, CraftSimOptions.tsmPriceKeyItems)

    

    CraftSimFRAME:InitTabSystem({generalTab, tooltipTab, TSMTab, AccountSyncTab, ModulesTab})

    local priceSourceAddons = CraftSimPriceAPIs:GetAvailablePriceSourceAddons()
    if #priceSourceAddons > 1 then
        CraftSimFRAME:initDropdownMenu("CraftSimPriceSourcesDropdown", generalTab.content, generalTab.content, "Price Source", 0, -50, 200, priceSourceAddons, 
        function(arg1) 
            CraftSimPriceAPIs:SwitchAPIByAddonName(arg1)
            CraftSimOptions.priceSource = arg1
        end, CraftSimPriceAPI.name)
    elseif #priceSourceAddons == 1 then
        local info = generalTab.content:CreateFontString('info', 'OVERLAY', 'GameFontNormal')
        info:SetPoint("TOP", 0, -50)
        info:SetText("Current Price Source: " .. tostring(CraftSimPriceAPI.name))
    else
        local warning = generalTab.content:CreateFontString('warning', 'OVERLAY', 'GameFontNormal')
        warning:SetPoint("TOP", 0, -50)
        warning:SetText("No Supported Price Source Addon loaded!")
    end

    local materialSuggestionCheckbox = CraftSimFRAME:CreateCheckbox(" Material Suggestion", 
     "Activate the module that suggest the cheapest materials to reach the highest quality/inspiration threshold",
     "modulesMaterials", 
     ModulesTab.content, 
     ModulesTab.content, 
     "TOP", 
     "TOP", 
     -90, 
     -50)


    local materialSuggestionTransparencySlider =  CraftSimFRAME:CreateSlider("CraftSimMaterialSlider", 
        "Transparency\n ", materialSuggestionCheckbox, materialSuggestionCheckbox, 
        "RIGHT", "LEFT", -15, 2, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyMaterials, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.MATERIALS):SetTransparency(value)
            CraftSimOptions.transparencyMaterials = value
        end)
        CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.MATERIALS):SetTransparency(CraftSimOptions.transparencyMaterials)

    local statWeightsCheckbox = CraftSimFRAME:CreateCheckbox(" Average Profit and Statweights", 
     "Activate the module that shows the average profit based on your profession stats and the profit stat weights",
     "modulesStatWeights", 
     ModulesTab.content, 
     materialSuggestionCheckbox, 
     "TOP", 
     "TOP", 
     0, 
     -20)

    local CraftSimDetailsTransparencySlider =  CraftSimFRAME:CreateSlider("CraftSimDetailsSlider", 
        "", ModulesTab.content, materialSuggestionTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyStatWeights, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.STAT_WEIGHTS):SetTransparency(value)
            CraftSimOptions.transparencyStatWeights = value
        end)
    CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.STAT_WEIGHTS):SetTransparency(CraftSimOptions.transparencyStatWeights)

     local topGearCheckbox = CraftSimFRAME:CreateCheckbox(" Top Gear", 
     "Activate the module that shows the best available profession gear combination based on the selected mode",
     "modulesTopGear", 
     ModulesTab.content, 
     statWeightsCheckbox, 
     "TOP", 
     "TOP", 
     0, 
     -20)

    local CraftSimTopGearTransparencySlider =  CraftSimFRAME:CreateSlider("CraftSimTopGearSlider", 
        "", ModulesTab.content, CraftSimDetailsTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyTopGear, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.TOP_GEAR):SetTransparency(value)
            CraftSimOptions.transparencyTopGear = value
        end)
    CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.TOP_GEAR):SetTransparency(CraftSimOptions.transparencyTopGear)

     local costOverviewCheckbox = CraftSimFRAME:CreateCheckbox(" Cost Overview", 
     "Activate the module that shows a crafting cost and sell profit overview by resulting quality",
     "modulesCostOverview", 
     ModulesTab.content, 
     topGearCheckbox, 
     "TOP", 
     "TOP", 
     0, 
     -20)

    local CraftSimCostOverviewTransparencySlider =  CraftSimFRAME:CreateSlider("CraftSimCostOverviewSlider", 
        "", ModulesTab.content, CraftSimTopGearTransparencySlider, 
        "TOP", "TOP", 0, -20, 100, 10, "HORIZONTAL", 
        0, 1, CraftSimOptions.transparencyCostOverview, -- get from options..
        "0", "1", 
        function(self, value)
            CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.COST_OVERVIEW):SetTransparency(value)
            CraftSimCostOverviewFrame:SetTransparency(value)
            CraftSimOptions.transparencyCostOverview = value
        end)
        CraftSimFRAME:GetFrame(CraftSimCONST.FRAMES.COST_OVERVIEW):SetTransparency(CraftSimOptions.transparencyCostOverview)

     local skillBreakpointsCheckbox = CraftSimFRAME:CreateCheckbox(" Offset Skill Breakpoints by 1", 
     "The material combination suggestion will try to reach the breakpoint + 1 instead of matching the exact skill required",
     "breakPointOffset", 
     generalTab.content, 
     generalTab.content, 
     "TOP", 
     "TOP", 
     -90, 
     -80)

    -- local autoVellumCheckBox = CraftSimFRAME:CreateCheckbox(" Auto Assign Enchanting Vellum", 
    -- "Always put enchanting vellum as the target enchanting item",
    -- "autoAssignVellum", 
    -- generalTab.content, 
    -- skillBreakpointsCheckbox, 
    -- "TOP", 
    -- "TOP", 
    -- 0, 
    -- -20)

    local precentProfitCheckbox = CraftSimFRAME:CreateCheckbox(" Show Profit Percentage", 
    "Show the percentage of profit to crafting costs besides the gold value",
    "showProfitPercentage", 
    generalTab.content, 
    skillBreakpointsCheckbox, 
    "TOP", 
    "TOP", 
    0, 
    -20)


    local openLastRecipeCheckbox = CraftSimFRAME:CreateCheckbox(" Remember Last Recipe", 
    "Reopen last selected recipe when opening the crafting window",
    "openLastRecipe", 
    generalTab.content, 
    precentProfitCheckbox, 
    "TOP", 
    "TOP", 
    0, 
    -20)

    local resetFramesButton = CreateFrame("Button", "CraftSimResetFramesButton", generalTab.content, "UIPanelButtonTemplate")
	resetFramesButton:SetPoint("TOP", openLastRecipeCheckbox, "TOP", 90, -30)	
	resetFramesButton:SetText("Reset Frame Positions")
	resetFramesButton:SetSize(resetFramesButton:GetTextWidth() + 20, 25)
    resetFramesButton:SetScript("OnClick", function(self) 
        CraftSimFRAME:ResetFrames()
    end)

    local detailedTooltips = CraftSimFRAME:CreateCheckbox(" Detailed Last Crafting Information", 
    "Show the complete breakdown of your last used material combination in an item tooltip",
    "detailedCraftingInfoTooltip", 
    tooltipTab.content, 
    tooltipTab.content, 
    "TOP", 
    "TOP", 
    -90, 
    -50)

    local characterNameInput = CreateFrame("EditBox", "CraftSimSyncCharacterInput", AccountSyncTab.content, "UIPanelButtonTemplate")
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

    local sendingProgress = characterNameInput:CreateFontString("CraftSimAccountSyncSendingProgress", 'OVERLAY', 'GameFontNormal')
    sendingProgress:SetPoint("LEFT", characterNameInput, "RIGHT", 5, 0)
    sendingProgress:SetText("")

    local accountSyncButton = CreateFrame("Button", "CraftSimAccountSyncButton", AccountSyncTab.content, "UIPanelButtonTemplate")
	accountSyncButton:SetPoint("TOPRIGHT", characterNameInput, "TOPRIGHT", 0, -30)	
	accountSyncButton:SetText("Synchronize Tooltip Data")
	accountSyncButton:SetSize(accountSyncButton:GetTextWidth() + 20, 25)
    accountSyncButton:SetScript("OnClick", function(self) 
        CraftSimAccountSync:SynchronizeAccounts()
    end)

    local optionsSyncButton = CreateFrame("Button", "CraftSimOptionsSyncButton", AccountSyncTab.content, "UIPanelButtonTemplate")
	optionsSyncButton:SetPoint("TOPRIGHT", accountSyncButton, "TOPRIGHT", 0, -30)	
	optionsSyncButton:SetText("Synchronize Options")
	optionsSyncButton:SetSize(optionsSyncButton:GetTextWidth() + 20, 25)
    optionsSyncButton:SetScript("OnClick", function(self) 
        CraftSimAccountSync:SynchronizeOptions()
    end)

    local supportedPriceSources = generalTab.content:CreateFontString('priceSources', 'OVERLAY', 'GameFontNormal')
    supportedPriceSources:SetPoint("TOP", 0, -200)
    supportedPriceSources:SetText("Supported Price Sources:\n\n" .. table.concat(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS, "\n"))
    
	InterfaceOptions_AddCategory(self.optionsPanel)
end