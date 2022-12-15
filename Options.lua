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

    local tsmPriceKeys = {"DBRecent", "DBMarket", "DBMinbuyout"}
    CraftSimFRAME:initDropdownMenu("CraftSimTSMPriceSourceDropdownMaterials", TSMTab.content ,"TSM Price Source Key Materials", 0, -50, 200, tsmPriceKeys, 
    function(arg1) 
        CraftSimOptions.tsmPriceKeyMaterials = arg1
    end, CraftSimOptions.tsmPriceKeyMaterials)

    CraftSimFRAME:initDropdownMenu("CraftSimTSMPriceSourceDropdownCraftedItems", TSMTab.content ,"TSM Price Source Key Crafted Items", 0, -100, 200, tsmPriceKeys, 
    function(arg1) 
        CraftSimOptions.tsmPriceKeyItems = arg1
    end, CraftSimOptions.tsmPriceKeyItems)

    

    CraftSimFRAME:InitTabSystem({generalTab, tooltipTab, TSMTab, AccountSyncTab})

    local priceSourceAddons = CraftSimPriceAPIs:GetAvailablePriceSourceAddons()
    if #priceSourceAddons > 1 then
        CraftSimFRAME:initDropdownMenu("CraftSimPriceSourcesDropdown", generalTab.content, "Price Source", 0, -50, 200, priceSourceAddons, 
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
	

    local checkButton = CreateFrame("CheckButton", nil, generalTab.content, "ChatConfigCheckButtonTemplate")
	checkButton:SetPoint("TOP", generalTab.content, -90, -80)
	checkButton.Text:SetText(" Offset Skill Breakpoints by 1")
    checkButton.tooltip = "The material combination suggestion will try to reach the breakpoint + 1 instead of matching the exact skill required"
	-- there already is an existing OnClick script that plays a sound, hook it
    checkButton:SetChecked(CraftSimOptions.breakPointOffset)
	checkButton:HookScript("OnClick", function(_, btn, down)
		local checked = checkButton:GetChecked()
		CraftSimOptions.breakPointOffset = checked
	end)

    local autoVellumCheckBox = CreateFrame("CheckButton", nil, generalTab.content, "ChatConfigCheckButtonTemplate")
	autoVellumCheckBox:SetPoint("TOP", checkButton, 0, -20)
	autoVellumCheckBox.Text:SetText(" Auto Assign Enchanting Vellum")
    autoVellumCheckBox.tooltip = "Always put enchanting vellum as the target enchanting item"
	-- there already is an existing OnClick script that plays a sound, hook it
    autoVellumCheckBox:SetChecked(CraftSimOptions.autoAssignVellum)
	autoVellumCheckBox:HookScript("OnClick", function(_, btn, down)
		local checked = autoVellumCheckBox:GetChecked()
		CraftSimOptions.autoAssignVellum = checked
	end)

    local precentProfitCheckbox = CreateFrame("CheckButton", nil, generalTab.content, "ChatConfigCheckButtonTemplate")
	precentProfitCheckbox:SetPoint("TOP", autoVellumCheckBox, 0, -20)
	precentProfitCheckbox.Text:SetText(" Show Profit Percentage")
    precentProfitCheckbox.tooltip = "Show the percentage of profit to crafting costs besides the gold value"
	-- there already is an existing OnClick script that plays a sound, hook it
    precentProfitCheckbox:SetChecked(CraftSimOptions.showProfitPercentage)
	precentProfitCheckbox:HookScript("OnClick", function(_, btn, down)
		local checked = precentProfitCheckbox:GetChecked()
		CraftSimOptions.showProfitPercentage = checked
	end)

    local openLastRecipeCheckbox = CreateFrame("CheckButton", nil, generalTab.content, "ChatConfigCheckButtonTemplate")
	openLastRecipeCheckbox:SetPoint("TOP", precentProfitCheckbox, 0, -20)
	openLastRecipeCheckbox.Text:SetText(" Remember Last Recipe")
    openLastRecipeCheckbox.tooltip = "Reopen last selected recipe when opening the crafting window"
	-- there already is an existing OnClick script that plays a sound, hook it
    openLastRecipeCheckbox:SetChecked(CraftSimOptions.openLastRecipe)
	openLastRecipeCheckbox:HookScript("OnClick", function(_, btn, down)
		local checked = openLastRecipeCheckbox:GetChecked()
		CraftSimOptions.openLastRecipe = checked
	end)

    local resetFramesButton = CreateFrame("Button", "CraftSimResetFramesButton", generalTab.content, "UIPanelButtonTemplate")
	resetFramesButton:SetPoint("TOP", openLastRecipeCheckbox, "TOP", 90, -30)	
	resetFramesButton:SetText("Reset Frame Positions")
	resetFramesButton:SetSize(resetFramesButton:GetTextWidth() + 20, 25)
    resetFramesButton:SetScript("OnClick", function(self) 
        CraftSimFRAME:ResetFrames()
    end)

    local detailedTooltips = CreateFrame("CheckButton", nil, tooltipTab.content, "ChatConfigCheckButtonTemplate")
	detailedTooltips:SetPoint("TOP", tooltipTab.content, -90, -50)
	detailedTooltips.Text:SetText(" Detailed Last Crafting Information")
    detailedTooltips.tooltip = "Show the complete breakdown of your last used material combination in an item tooltip"
	-- there already is an existing OnClick script that plays a sound, hook it
    detailedTooltips:SetChecked(CraftSimOptions.detailedCraftingInfoTooltip)
	detailedTooltips:HookScript("OnClick", function(_, btn, down)
		local checked = detailedTooltips:GetChecked()
		CraftSimOptions.detailedCraftingInfoTooltip = checked
	end)

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