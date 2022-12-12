CraftSimOPTIONS = {}


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

    local TSMTab = CreateFrame("Button", "CraftSimOptionsTSMTab", CraftSimOPTIONS.optionsPanel, "UIPanelButtonTemplate")
    TSMTab:SetText("TSM")
    TSMTab:SetSize(TSMTab:GetTextWidth() + tabExtraWidth, 30)
    TSMTab:SetPoint("LEFT", generalTab, "RIGHT", 0, 0)

    TSMTab.content = CreateFrame("Frame", nil, CraftSimOPTIONS.optionsPanel)
    TSMTab.content:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, "TOP", 0, contentPanelsOffsetY)
    TSMTab.content:SetSize(300, 350)

    local tsmPriceKeys = {"DBRecent", "DBMarket", "DBMinbuyout"}
        CraftSimFRAME:initDropdownMenu("CraftSimTSMPriceSourceDropdown", TSMTab.content ,"TSM Price Source Key", 0, -50, 200, tsmPriceKeys, 
        function(arg1) 
            CraftSimOptions.tsmPriceKey = arg1
        end, CraftSimOptions.tsmPriceKey)

    TSMTab:SetEnabled(IsAddOnLoaded("TradeSkillMaster"))
    TSMTab.canBeEnabled = IsAddOnLoaded("TradeSkillMaster")

    CraftSimFRAME:InitTabSystem({generalTab, TSMTab})

    local priceSourceAddons = CraftSimPriceAPIs:GetAvailablePriceSourceAddons()
    if #priceSourceAddons > 1 then
        CraftSimFRAME:initDropdownMenu("CraftSimPriceSourcesDropdown", generalTab.content, "Price Source", 0, -50, 200, priceSourceAddons, 
        function(arg1) 
            CraftSimPriceAPIs:SwitchAPIByAddonName(arg1)
            CraftSimOptions.priceSource = arg1
            if arg1 == "TradeSkillMaster" and CraftSimTSMPriceSourceDropdown then
                CraftSimTSMPriceSourceDropdown:Show()
            else
                CraftSimTSMPriceSourceDropdown:Hide()
            end
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
	autoVellumCheckBox:SetPoint("TOP", checkButton, 0, -40)
	autoVellumCheckBox.Text:SetText(" Auto Assign Enchanting Vellum")
    autoVellumCheckBox.tooltip = "Always put enchanting vellum as the target enchanting item"
	-- there already is an existing OnClick script that plays a sound, hook it
    autoVellumCheckBox:SetChecked(CraftSimOptions.autoAssignVellum)
	autoVellumCheckBox:HookScript("OnClick", function(_, btn, down)
		local checked = autoVellumCheckBox:GetChecked()
		CraftSimOptions.autoAssignVellum = checked
	end)

    local supportedPriceSources = generalTab.content:CreateFontString('priceSources', 'OVERLAY', 'GameFontNormal')
    supportedPriceSources:SetPoint("TOP", 0, -200)
    supportedPriceSources:SetText("Supported Price Sources:\n\n" .. table.concat(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS, "\n"))
    
	InterfaceOptions_AddCategory(self.optionsPanel)
end