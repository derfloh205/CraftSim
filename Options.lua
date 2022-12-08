CraftSimOPTIONS = {}


function CraftSimOPTIONS:InitOptionsFrame()
    CraftSimOPTIONS.optionsPanel = CreateFrame("Frame")
	CraftSimOPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)
        CraftSimOPTIONS.optionsPanel.name = "CraftSim"
	local title = CraftSimOPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("CraftSim Options")

    local priceSourceAddons = CraftSimPriceAPIs:GetAvailablePriceSourceAddons()
    if #priceSourceAddons > 1 then
        CraftSimFRAME:initDropdownMenu("CraftSimPriceSourcesDropdown", CraftSimOPTIONS.optionsPanel, "Price Source", 0, -50, 200, priceSourceAddons, 
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
        local info = CraftSimOPTIONS.optionsPanel:CreateFontString('info', 'OVERLAY', 'GameFontNormal')
        info:SetPoint("TOP", 0, -50)
        info:SetText("Current Price Source: " .. tostring(CraftSimPriceAPI.name))
    else
        local warning = CraftSimOPTIONS.optionsPanel:CreateFontString('warning', 'OVERLAY', 'GameFontNormal')
        warning:SetPoint("TOP", 0, -50)
        warning:SetText("No Supported Price Source Addon loaded!")
    end
	
    -- if tsm is loaded
    if IsAddOnLoaded("TradeSkillMaster") then
        local tsmPriceKeys = {"DBRecent", "DBMarket", "DBMinbuyout"}
        CraftSimFRAME:initDropdownMenu("CraftSimTSMPriceSourceDropdown", CraftSimOPTIONS.optionsPanel ,"TSM Price Source Key", 0, -100, 200, tsmPriceKeys, 
        function(arg1) 
            CraftSimOptions.tsmPriceKey = arg1
        end, CraftSimOptions.tsmPriceKey)

        if CraftSimPriceAPI.name == "TradeSkillMaster" then
            CraftSimTSMPriceSourceDropdown:Show()
        else
            CraftSimTSMPriceSourceDropdown:Hide()
        end
    end

    local supportedPriceSources = CraftSimOPTIONS.optionsPanel:CreateFontString('priceSources', 'OVERLAY', 'GameFontNormal')
    supportedPriceSources:SetPoint("TOP", 0, -200)
    supportedPriceSources:SetText("Supported Price Sources:\n\n" .. table.concat(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS, "\n"))
    
	InterfaceOptions_AddCategory(self.optionsPanel)
end