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
        CraftSimOPTIONS:initDropdownMenu("CraftSimPriceSourcesDropdown", "Price Source", 0, -50, priceSourceAddons, 
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
        CraftSimOPTIONS:initDropdownMenu("CraftSimTSMPriceSourceDropdown" ,"TSM Price Source Key", 0, -100, tsmPriceKeys, 
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

function CraftSimOPTIONS:initDropdownMenu(frameName, label, offsetX, offsetY, list, clickCallback, defaultValue)
	local dropDown = CreateFrame("Frame", frameName, CraftSimOPTIONS.optionsPanel, "UIDropDownMenuTemplate")
	dropDown:SetPoint("TOP", CraftSimOPTIONS.optionsPanel, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, 200) -- Use in place of dropDown:SetWidth
	
	CraftSimOPTIONS:initializeDropdown(dropDown, list, clickCallback, defaultValue)

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)
	dd_title:SetText(label)
end

function CraftSimOPTIONS:initializeDropdown(dropDown, list, clickCallback, defaultValue)
	UIDropDownMenu_Initialize(dropDown, function(self) 
		-- loop through possible tsm price strings and put them as option
		for k, v in pairs(list) do
			name = v
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(self, arg1, arg2, checked) 
                UIDropDownMenu_SetText(dropDown, arg1)
                clickCallback(arg1)
            end

			info.text = name
			info.arg1 = info.text
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetText(dropDown, defaultValue)
end