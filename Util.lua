CraftSimUTIL = {}

local inspirationFactor = 0.001
local multicraftFactor = 0.0009
local resourcefulnessFactor = 0.00111
local craftingspeedFactor = 0.002

function CraftSimUTIL:GetInspirationStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / inspirationFactor
end

function CraftSimUTIL:GetCraftingSpeedStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / craftingspeedFactor
end

function CraftSimUTIL:GetMulticraftStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / multicraftFactor
end

function CraftSimUTIL:GetResourcefulnessStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / resourcefulnessFactor
end

function CraftSimUTIL:GetInspirationPercentByStat(stat) 
    return stat * inspirationFactor
end

function CraftSimUTIL:GetCraftingSpeedPercentByStat(stat)
    return stat * craftingspeedFactor
end

function CraftSimUTIL:GetMulticraftPercentByStat(stat) 
    return stat * multicraftFactor
end

function CraftSimUTIL:GetResourcefulnessPercentByStat(stat) 
    return stat * resourcefulnessFactor
end

function CraftSimUTIL:round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

function CraftSimUTIL:GetItemIDByLink(hyperlink)
    local _, _, foundID = string.find(hyperlink, "item:(%d+)")
    return tonumber(foundID)
end

function CraftSimUTIL:EquipItemByLink(link)
	for bag=BANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		for slot=1,C_Container.GetContainerNumSlots(bag) do
			local item = C_Container.GetContainerItemLink(bag, slot)
			if item and item == link then
				if CursorHasItem() or CursorHasMoney() or CursorHasSpell() then ClearCursor() end
				C_Container.PickupContainerItem(bag, slot)
				AutoEquipCursorItem()
				return true
			end
		end
	end
end

-- thx ketho forum guy
function CraftSimUTIL:KethoEditBox_Show(text)
    if not KethoEditBox then
        local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)
        
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = { left = 8, right = 6, top = 8, bottom = 8 },
        })
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
        
        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)
        
        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
        
        -- EditBox
        local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(true) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        sf:SetScrollChild(eb)
        
        -- Resizable
        f:SetResizable(true)
        
        local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)
        
        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        
        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() -- more noticeable
            end
        end)
        rb:SetScript("OnMouseUp", function(self, button)
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth(sf:GetWidth())
        end)
        f:Show()
    end
    
    if text then
        KethoEditBoxEditBox:SetText(text)
    end
    KethoEditBox:Show()
end

function CraftSimUTIL:isItemSoulbound(itemID)
    local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemID) 
    return bindType == CraftSimCONST.BINDTYPES.SOULBOUND
end

function CraftSimUTIL:GetRecipeType(recipeInfo) -- the raw info
    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false)
    if recipeInfo.isRecraft then
        return CraftSimCONST.RECIPE_TYPES.RECRAFT
    elseif schematicInfo.hasGatheringOperationInfo then
        return CraftSimCONST.RECIPE_TYPES.GATHERING
    elseif recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil then -- its gear
        local itemID = schematicInfo.outputItemID
		if CraftSimUTIL:isItemSoulbound(itemID) then
            return CraftSimCONST.RECIPE_TYPES.SOULBOUND_GEAR
        else
            return CraftSimCONST.RECIPE_TYPES.GEAR
        end
	elseif recipeInfo.supportsQualities then
        if not recipeInfo.qualityItemIDs and not recipeInfo.qualityIlvlBonuses then
            return CraftSimCONST.RECIPE_TYPES.NO_ITEM
        elseif schematicInfo.quantityMin > 1 or schematicInfo.quantityMax > 1 then
            return CraftSimCONST.RECIPE_TYPES.MULTIPLE
        elseif schematicInfo.quantityMin == 1 and schematicInfo.quantityMax == 1 then
            return CraftSimCONST.RECIPE_TYPES.SINGLE
        end
    elseif not recipeInfo.supportsQualities then
        if schematicInfo.quantityMin > 1 or schematicInfo.quantityMax > 1 then
            return CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE
        elseif schematicInfo.quantityMin == 1 and schematicInfo.quantityMax == 1 then
            return CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE
        end
    end
end



-- for debug purposes
function CraftSimUTIL:PrintTable(t, recursive)
    for k, v in pairs(t) do
        if not recursive or type(v) ~= "table" then
            print(tostring(k) .. ": " .. tostring(v))
        elseif type(v) == "table" then
            print(tostring(k) .. ": ")
            CraftSimUTIL:PrintTable(v, recursive)
        end

    end
end

function CraftSimUTIL:FormatMoney(copperValue)
    local absValue = abs(copperValue)
    local minusText = ""

    if copperValue < 0 then
        minusText = "-"
    end

    return minusText .. GetCoinTextureString(absValue)
end

function CraftSimUTIL:FilterTable(t, filterFunc)
    local filtered = {}
    for k, v in pairs(t) do
        if filterFunc(v) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

function CraftSimUTIL:FoldTable(t, foldFunction, startAtZero)
    local foldedValue = nil
    if #t < 2 and not startAtZero then
        return t[1]
    elseif #t < 1 and startAtZero then
        return t[0]
    end

    local startIndex = 1
    if startAtZero then
        startIndex = 0
    end
    for index = startIndex, #t, 1 do
        --print("folding.. current Value: " .. foldedValue)
        if foldedValue == nil then
            foldedValue = foldFunction(t[startIndex], t[startIndex + 1])
        elseif index < #t then
            foldedValue = foldFunction(foldedValue, t[index+1])
        end
    end

    return foldedValue
end