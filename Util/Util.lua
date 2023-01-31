AddonName, CraftSim = ...

CraftSim.UTIL = {}

local inspirationFactor = 0.001
local multicraftFactor = 0.0009
local resourcefulnessFactor = 0.00111
local craftingspeedFactor = 0.002

function CraftSim.UTIL:GetInspirationStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / inspirationFactor
end

function CraftSim.UTIL:GetCraftingSpeedStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / craftingspeedFactor
end

function CraftSim.UTIL:GetMulticraftStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / multicraftFactor
end

function CraftSim.UTIL:GetResourcefulnessStatByPercent(percent) 
    if percent == nil then 
        return 0 
    end
    return percent / resourcefulnessFactor
end

function CraftSim.UTIL:GetInspirationPercentByStat(stat) 
    return stat * inspirationFactor
end

function CraftSim.UTIL:GetCraftingSpeedPercentByStat(stat)
    return stat * craftingspeedFactor
end

function CraftSim.UTIL:GetMulticraftPercentByStat(stat) 
    return stat * multicraftFactor
end

function CraftSim.UTIL:GetResourcefulnessPercentByStat(stat) 
    return stat * resourcefulnessFactor
end

function CraftSim.UTIL:round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

function CraftSim.UTIL:GetItemIDByLink(hyperlink)
    local _, _, foundID = string.find(hyperlink, "item:(%d+)")
    return tonumber(foundID)
end

function CraftSim.UTIL:ContinueOnAllItemsLoaded(itemList, callback) 
		local itemsToLoad = #itemList
        if itemsToLoad == 0 then
            callback()
        end
		local itemLoaded = function ()
			itemsToLoad = itemsToLoad - 1
			CraftSim_DEBUG:print("util: loaded items left: " .. itemsToLoad, CraftSim.CONST.DEBUG_IDS.MAIN)
	
			if itemsToLoad <= 0 then
				CraftSim_DEBUG:print("util: all items loaded, call callback", CraftSim.CONST.DEBUG_IDS.MAIN)
				callback()
			end
		end

		if itemsToLoad >= 1 then
			for _, itemToLoad in pairs(itemList) do
				itemToLoad:ContinueOnItemLoad(itemLoaded)
			end
		end
end

function CraftSim.UTIL:EquipItemByLink(link)
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

function CraftSim.UTIL:IsMyVersionHigher(versionB)
    local versionA = GetAddOnMetadata(AddonName, "Version") or ""
    local subVersionsA = strsplittable(".", versionA)
    local subVersionsB = strsplittable(".", versionB)

    -- TODO: refactor recursively to get rid of this abomination
    if subVersionsA[1] and subVersionsB[1] then
        print(subVersionsA[1] .. " < " .. subVersionsB[1] .. "?")
        if subVersionsA[1] < subVersionsB[1] then
            return false
        elseif subVersionsA[1] > subVersionsB[1] then
            return true
        end

        if subVersionsA[2] and subVersionsB[2] then
            print(subVersionsA[2] .. " < " .. subVersionsB[2] .. "?")
            if subVersionsA[2] < subVersionsB[2] then
                return false
            elseif subVersionsA[2] > subVersionsB[2] then
                return true
            end

            if subVersionsA[3] and subVersionsB[3] then
                print(subVersionsA[3] .. " < " .. subVersionsB[3] .. "?")
                if subVersionsA[3] < subVersionsB[3] then
                    return false
                elseif subVersionsA[3] > subVersionsB[3] then
                    return true
                end

                if subVersionsA[4] and subVersionsB[4] then
                    print(subVersionsA[4] .. " < " .. subVersionsB[4] .. "?")
                    if subVersionsA[4] < subVersionsB[4] then
                        return false
                    elseif subVersionsA[4] > subVersionsB[4] then
                        return true
                    end
                else
                    if subVersionsB[4] then
                        return false
                    end
                end
            else
                if subVersionsB[3] then
                    return false
                end
            end
        else
            if subVersionsB[2] then
                return false
            end
        end
    else
        if subVersionsB[1] then
            return false
        end
    end

    return true
end

-- thx ketho forum guy
function CraftSim.UTIL:KethoEditBox_Show(text)
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

function CraftSim.UTIL:isItemSoulbound(itemID)
    local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemID) 
    return bindType == CraftSim.CONST.BINDTYPES.SOULBOUND
end

function CraftSim.UTIL:GetQualityIconAsText(qualityID, sizeX, sizeY, offsetX, offsetY)
    return CreateAtlasMarkup("Professions-Icon-Quality-Tier" .. qualityID, sizeX, sizeY, offsetX, offsetY)
end

function CraftSim.UTIL:GetRecipeType(recipeInfo) -- the raw info
    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false)
    if recipeInfo.isEnchantingRecipe then
        return CraftSim.CONST.RECIPE_TYPES.ENCHANT
    elseif schematicInfo.hasGatheringOperationInfo then
        return CraftSim.CONST.RECIPE_TYPES.GATHERING
    elseif recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil then -- its gear
        local itemID = schematicInfo.outputItemID
		if CraftSim.UTIL:isItemSoulbound(itemID) then
            return CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR
        else
            return CraftSim.CONST.RECIPE_TYPES.GEAR
        end
	elseif recipeInfo.supportsQualities then
        if not recipeInfo.qualityItemIDs and not recipeInfo.qualityIlvlBonuses then
            return CraftSim.CONST.RECIPE_TYPES.NO_ITEM
        elseif schematicInfo.quantityMin > 1 or schematicInfo.quantityMax > 1 then
            return CraftSim.CONST.RECIPE_TYPES.MULTIPLE
        elseif schematicInfo.quantityMin == 1 and schematicInfo.quantityMax == 1 then
            return CraftSim.CONST.RECIPE_TYPES.SINGLE
        end
    elseif not recipeInfo.supportsQualities then
        if schematicInfo.quantityMin > 1 or schematicInfo.quantityMax > 1 then
            return CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE
        elseif schematicInfo.quantityMin == 1 and schematicInfo.quantityMax == 1 then
            return CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE
        end
    end
end



-- for debug purposes
function CraftSim.UTIL:PrintTable(t, debugID, recursive)
    for k, v in pairs(t) do
        if not recursive or type(v) ~= "table" then
            CraftSim_DEBUG:print(tostring(k) .. ": " .. tostring(v), debugID, false)
        elseif type(v) == "table" then
            CraftSim_DEBUG:print(tostring(k) .. ": ", debugID, false)
            CraftSim.UTIL:PrintTable(v, debugID, recursive)
        end

    end
end

function CraftSim.UTIL:Count(t, func)
    local count = 0
    for _, v in pairs(t) do
        if func(v) then
            count = count + 1
        end
    end

    return count
end

function CraftSim.UTIL:Sort(t, compFunc)
    local sorted = {}
    for _, item in pairs(t) do
        if sorted[1] == nil then
            table.insert(sorted, item)
        else
            local sortedCopy = CopyTable(sorted)
            local inserted = false
            for sortedIndex, sortedItem in pairs(sortedCopy) do
                if compFunc(item, sortedItem) then
                    table.insert(sorted, sortedIndex, item)
                    inserted = true
                    break
                end
            end

            if not inserted then
                table.insert(sorted, item)
            end
        end
    end

    return sorted
end

function CraftSim.UTIL:ValidateNumberInput(inputBox, allowNegative)
    local inputNumber = inputBox:GetNumber()
    local inputText = inputBox:GetText()

    if inputText == "" then
        return 0 -- otherwise its treated as 1
    end

    if inputText == "-" then
        -- User is in the process of writing a negative number
        return 0
    end

    if (not allowNegative and inputNumber < 0) or (inputNumber == 0 and inputText ~= "0") then
        inputNumber = 0
        if inputText ~= "" then
            inputBox:SetText(inputNumber)
        end
    end

    return inputNumber
end

function CraftSim.UTIL:WrapText(text, width)
    local char_pattern = ".[\128-\191]*"  -- for UTF-8 texts
    -- local char_pattern = "."           -- for 1-byte encodings
    
    local function wrap(text, width)
       local tail, lines = text.." ", {}
       while tail do
          lines[#lines + 1], tail = tail
             :gsub("^%s+", "")
             :gsub(char_pattern, "\0%0\0", width)
             :gsub("%z%z", "")
             :gsub("(%S)%z(%s)", "%1%2\0")
             :gsub("^(%z[^\r\n%z]*)%f[%s](%Z*)%z(.*)$", "%1\0%2%3")
             :match"^%z(%Z+)%z(.*)$"
       end
       return table.concat(lines, "\n")
    end

    return wrap(text, width)
end

function CraftSim.UTIL:IsSpecImplemented(professionID)

    if professionID == Enum.Profession.Blacksmithing and not CraftSimOptions.blacksmithingEnabled or
       professionID == Enum.Profession.Jewelcrafting and not CraftSimOptions.jewelcraftingEnabled or
       professionID == Enum.Profession.Leatherworking and not CraftSimOptions.leatherworkingEnabled or
       professionID == Enum.Profession.Alchemy and not CraftSimOptions.alchemyEnabled then
        return false
    end

    return tContains(CraftSim.CONST.IMPLEMENTED_SKILL_BUILD_UP(), professionID)
end

function CraftSim.UTIL:GetExportModeByVisibility()
    return (ProfessionsFrame.OrdersPage.OrderView.OrderDetails:IsVisible() and CraftSim.CONST.EXPORT_MODE.WORK_ORDER) or CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER
end

function CraftSim.UTIL:FormatMoney(copperValue, useColor, percentRelativeTo)
    local absValue = abs(copperValue)
    local minusText = ""
    local color = CraftSim.CONST.COLORS.GREEN
    local percentageText = ""

    if percentRelativeTo then
        local oneP = percentRelativeTo / 100
        local percent = CraftSim.UTIL:round(copperValue / oneP, 0)

        if oneP == 0 then
            percent = 0
        end

        percentageText = " (" .. percent .. "%)"
    end

    if copperValue < 0 then
        minusText = "-"
        color = CraftSim.CONST.COLORS.RED
    end

    if useColor then
        return CraftSim.UTIL:ColorizeText(minusText .. GetCoinTextureString(absValue, 10) .. percentageText, color)
    else
        return minusText .. GetCoinTextureString(absValue, 10) .. percentageText
    end
end

function CraftSim.UTIL:SetDebugPrint(debugID)
    local function print(text, recursive, l) -- override
        if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
            CraftSim_DEBUG:print(text, debugID, recursive, l)
        else
            print(text)
        end
    end

    return print
end

function CraftSim.UTIL:CollectGarbageAtThreshold(kbThreshold)
    local kbUsed = collectgarbage("count")
    print("kbUsed" .. tostring(kbUsed))
    if kbUsed >= kbThreshold then
        collectgarbage("collect")
    end
end

function CraftSim.UTIL:CreateRegistreeForEvents(events)
    local registree = CreateFrame("Frame", nil)
    registree:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
    for _, event in pairs(events) do
        registree:RegisterEvent(event)
    end
    return registree
end

function CraftSim.UTIL:FilterTable(t, filterFunc)
    local filtered = {}
    for k, v in pairs(t) do
        if filterFunc(v) then
            table.insert(filtered, v)
        end
    end
    return filtered
end

function CraftSim.UTIL:Map(t, mapFunc)
    local mapped = {}
    for k, v in pairs(t) do
        table.insert(mapped, mapFunc(v, k))
    end
    return mapped
end

function CraftSim.UTIL:Find(t, findFunc)
    for k, v in pairs(t) do
        if findFunc(v) then
            return v, k
        end
    end

    return false
end

function CraftSim.UTIL:GetMoneyValuesFromCopper(copperValue, formatString)
    local gold = CraftSim.UTIL:round(copperValue/10000)
    local silver = CraftSim.UTIL:round(copperValue/100000)
    local copper = CraftSim.UTIL:round(copperValue/10000000)

    if not formatString then
        return gold, silver, copper
    else
        return gold .. "g " .. silver .. "s " .. copper .. "c"
    end
end


function CraftSim.UTIL:FoldTable(t, foldFunction, startAtZero)
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

function CraftSim.UTIL:FormatFactorToPercent(factor)
    local percentText = CraftSim.UTIL:round((factor % 1) * 100)
    return "+" .. percentText .. "%"
end

function CraftSim.UTIL:GreyOutByCondition(text, condition)
    if condition then
        CraftSim.UTIL:ColorizeText(text, CraftSim.CONST.COLORS.GREY)
    else
        return text
    end
end

function CraftSim.UTIL:ColorizeText(text, color)
    local startLine = "\124"
    local endLine = "\124r"
    return startLine .. color .. text .. endLine
end
function CraftSim.UTIL:IconToText(iconPath, height) 
    return "\124T" .. iconPath .. ":" .. height .. "\124t"
end

-- from stackoverflow: 
-- https://stackoverflow.com/questions/9079853/lua-print-integer-as-a-binary
function CraftSim.UTIL:toBits(num, bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

function CraftSim.UTIL:HashTable(t)
    local serializedData = CraftSim.ACCOUNTSYNC:Serialize(data)
	local compressedData, compressError = LibCompress:Compress(serializedData)
    return compressedData
end

local profilings = {}
function CraftSim.UTIL:StartProfiling(label)
    local time = debugprofilestop();
    profilings[label] = time
end

function CraftSim.UTIL:StopProfiling(label)
    local time = debugprofilestop()
    local diff = time - profilings[label]
    profilings[label] = nil
    CraftSim_DEBUG:print("Elapsed Time for " .. label .. ": " .. CraftSim.UTIL:round(diff) .. " ms", CraftSim.CONST.DEBUG_IDS.PROFILING)
end

