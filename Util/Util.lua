CraftSimAddonName, CraftSim = ...

CraftSim.UTIL = {}

local inspirationFactor = 0.001
local multicraftFactor = 0.0009
local resourcefulnessFactor = 0.00111
local craftingspeedFactor = 0.002

function CraftSim.UTIL:SetDebugPrint(debugID)
    local function print(text, recursive, l, level)
        if CraftSim_DEBUG and CraftSim.GGUI.GetFrame and CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.DEBUG) then
            CraftSim_DEBUG:print(text, debugID, recursive, l, level)
        else
            print(text)
        end
    end

    return print
end

function CraftSim.UTIL:SystemPrint(text)
    print(text)
end

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.UTIL) 

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

function CraftSim.UTIL:IsMyVersionHigher(versionB)
    local versionA = GetAddOnMetadata(CraftSimAddonName, "Version") or ""
    local subVersionsA = strsplittable(".", versionA)
    local subVersionsB = strsplittable(".", versionB)

    -- TODO: refactor recursively to get rid of this abomination
    if subVersionsA[1] and subVersionsB[1] then
        if subVersionsA[1] < subVersionsB[1] then
            return false
        elseif subVersionsA[1] > subVersionsB[1] then
            return true
        end

        if subVersionsA[2] and subVersionsB[2] then
            if subVersionsA[2] < subVersionsB[2] then
                return false
            elseif subVersionsA[2] > subVersionsB[2] then
                return true
            end

            if subVersionsA[3] and subVersionsB[3] then
                if subVersionsA[3] < subVersionsB[3] then
                    return false
                elseif subVersionsA[3] > subVersionsB[3] then
                    return true
                end

                if subVersionsA[4] and subVersionsB[4] then
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
        KethoEditBoxEditBox:HighlightText(0, KethoEditBoxEditBox:GetNumLetters())
    end
    KethoEditBox:Show()
end

-- for debug purposes
function CraftSim.UTIL:PrintTable(t, debugID, recursive, level)
    level = level or 0
    local levelString = ""
    for i = 1, level, 1 do
        levelString = levelString .. "-"
    end

    if t.Debug then
        for _, line in pairs(t:Debug()) do
            CraftSim_DEBUG:print(levelString .. tostring(line), debugID, false)
        end
        return
    end

    for k, v in pairs(t) do
        if type(v) == 'function' then
            CraftSim_DEBUG:print(levelString .. tostring(k) .. ": function", debugID, false)
        elseif not recursive or type(v) ~= "table" then
            CraftSim_DEBUG:print(levelString .. tostring(k) .. ": " .. tostring(v), debugID, false)
        elseif type(v) == "table" then
            CraftSim_DEBUG:print(levelString .. tostring(k) .. ": ", debugID, false)
            CraftSim.UTIL:PrintTable(v, debugID, recursive, level + 1)
        end

    end
end

function CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemString)
    local linkLevel, specializationID = string.match(itemString, "item:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:(%d+):(%d+)")
    local bonusIDString = linkLevel .. ":" .. specializationID

    return string.gsub(itemString, bonusIDString, "")
end

--> built into GGUI
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
    return tContains(CraftSim.CONST.IMPLEMENTED_SKILL_BUILD_UP(), professionID)
end

function CraftSim.UTIL:GetExportModeByVisibility()
    return (ProfessionsFrame.OrdersPage.OrderView.OrderDetails:IsVisible() and CraftSim.CONST.EXPORT_MODE.WORK_ORDER) or CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER
end

function CraftSim.UTIL:IsWorkOrder()
    return ProfessionsFrame.OrdersPage.OrderView.OrderDetails:IsVisible()
end

function CraftSim.UTIL:FormatFactorToPercent(factor)
    local percentText = CraftSim.GUTIL:Round((factor % 1) * 100)
    return "+" .. percentText .. "%"
end

function CraftSim.UTIL:GreyOutByCondition(text, condition)
    if condition then
        CraftSim.GUTIL:ColorizeText(text, CraftSim.GUTIL.COLORS.GREY)
    else
        return text
    end
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
    CraftSim_DEBUG:print("Elapsed Time for " .. label .. ": " .. CraftSim.GUTIL:Round(diff) .. " ms", CraftSim.CONST.DEBUG_IDS.PROFILING)
end

function CraftSim.UTIL:GetFormatter()
    local b = CraftSim.GUTIL.COLORS.DARK_BLUE
    local bb = CraftSim.GUTIL.COLORS.BRIGHT_BLUE
    local g = CraftSim.GUTIL.COLORS.GREEN
    local grey = CraftSim.GUTIL.COLORS.GREY
    local r = CraftSim.GUTIL.COLORS.RED
    local l = CraftSim.GUTIL.COLORS.LEGENDARY
    local e = CraftSim.GUTIL.COLORS.EPIC
    local patreon = CraftSim.GUTIL.COLORS.PATREON
    local c = function(text, color) 
        return CraftSim.GUTIL:ColorizeText(text, color)
    end
    local p = "\n" .. CraftSim.GUTIL:GetQualityIconString(1, 15, 15) .. " "
    local s = "\n" .. CraftSim.GUTIL:GetQualityIconString(2, 15, 15) .. " "
    local P = "\n" .. CraftSim.GUTIL:GetQualityIconString(3, 15, 15) .. " "
    local a = "\n     "

    local formatter = {}
    formatter.b = function (text)
        return c(text, b)
    end
    formatter.bb = function (text)
        return c(text, bb)
    end
    formatter.g = function (text)
        return c(text, g)
    end
    formatter.r = function (text)
        return c(text, r)
    end
    formatter.l = function (text)
        return c(text, l)
    end
    formatter.e = function (text)
        return c(text, e)
    end
    formatter.grey = function (text)
        return c(text, grey)
    end
    formatter.patreon = function (text)
        return c(text, patreon)
    end
    formatter.p = p
    formatter.s = s
    formatter.P = P
    formatter.a = a
    formatter.m = function (m)
        return CraftSim.GUTIL:FormatMoney(m, true)
    end
    formatter.mw = function (m)
        return CraftSim.GUTIL:FormatMoney(m)
    end

    formatter.i = function (i, h, w)
        return CraftSim.GUTIL:IconToText(i, h, w)
    end

    formatter.cm = function(i, s) 
        return CraftSim.MEDIA:GetAsTextIcon(i, s)
    end

    return formatter
end

function CraftSim.UTIL:GetSchematicFormByVisibility()
    if ProfessionsFrame.CraftingPage.SchematicForm:IsVisible() then
        return ProfessionsFrame.CraftingPage.SchematicForm
    elseif ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:IsVisible() then
        return ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm
    end
end

function CraftSim.UTIL:HasProfession(professionID)
    local skilllineids = C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    local professionsChecked = 0
    for _, id in pairs(skilllineids) do
    
        local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(id)

        if info.maxSkillLevel > 0 then
            professionsChecked = professionsChecked + 1
            if info.profession == professionID then
                return true
            end

            -- doesnt make sense to check more than the max learned professions per character
            if professionsChecked >= 5 then
                return false
            end
        end
        
        if info.profession == professionID and info.maxSkillLevel > 0 then
            return true
        end
    end
end
