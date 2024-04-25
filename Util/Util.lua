---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

CraftSim.UTIL = {}

CraftSim.UTIL.frameLevel = 100

local inspirationFactor = 0.001
local multicraftFactor = 0.0009
local resourcefulnessFactor = 0.00111
local craftingspeedFactor = 0.002

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.UTIL)

function CraftSim.UTIL:NextFrameLevel()
    local frameLevel = CraftSim.UTIL.frameLevel
    CraftSim.UTIL.frameLevel = CraftSim.UTIL.frameLevel + 50
    return frameLevel
end

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
    local versionA = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version") or ""
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
    local char_pattern = ".[\128-\191]*" -- for UTF-8 texts
    -- local char_pattern = "."           -- for 1-byte encodings

    local function wrap(text, width)
        local tail, lines = text .. " ", {}
        while tail do
            lines[#lines + 1], tail = tail
                :gsub("^%s+", "")
                :gsub(char_pattern, "\0%0\0", width)
                :gsub("%z%z", "")
                :gsub("(%S)%z(%s)", "%1%2\0")
                :gsub("^(%z[^\r\n%z]*)%f[%s](%Z*)%z(.*)$", "%1\0%2%3")
                :match "^%z(%Z+)%z(.*)$"
        end
        return table.concat(lines, "\n")
    end

    return wrap(text, width)
end

function CraftSim.UTIL:IsSpecImplemented(professionID)
    return tContains(CraftSim.CONST.IMPLEMENTED_SKILL_BUILD_UP(), professionID)
end

function CraftSim.UTIL:GetExportModeByVisibility()
    return (ProfessionsFrame.OrdersPage.OrderView.OrderDetails:IsVisible() and CraftSim.CONST.EXPORT_MODE.WORK_ORDER) or
        CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER
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

local playerCrafterDataCached = nil
---@return CraftSim.CrafterData
function CraftSim.UTIL:GetPlayerCrafterData()
    -- utilize cache to speed up api calls
    if playerCrafterDataCached then return playerCrafterDataCached end

    local name, realm = UnitNameUnmodified("player")
    realm = realm or GetNormalizedRealmName()
    ---@type CraftSim.CrafterData
    local crafterData = {
        name = name,
        realm = realm,
        class = select(2, UnitClass("player")),
    }

    playerCrafterDataCached = crafterData

    return crafterData
end

---@param crafterData CraftSim.CrafterData
---@return string crafterUID
function CraftSim.UTIL:GetCrafterUIDFromCrafterData(crafterData)
    return crafterData.name .. "-" .. crafterData.realm
end

---@param crafterUID CrafterUID
---@return CraftSim.CrafterData? crafterData nil if not fully cached
function CraftSim.UTIL:GetCrafterDataFromCrafterUID(crafterUID)
    local name, realm = strsplit("-", crafterUID)
    local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)

    if name and realm and crafterClass then
        ---@type CraftSim.CrafterData
        local crafterData = {
            name = name,
            realm = realm,
            class = crafterClass,
        }
        return crafterData
    end
end

---@return string crafterUID
function CraftSim.UTIL:GetPlayerCrafterUID()
    return CraftSim.UTIL:GetCrafterUIDFromCrafterData(CraftSim.UTIL:GetPlayerCrafterData())
end

function CraftSim.UTIL:GetSchematicFormByVisibility()
    if ProfessionsFrame.CraftingPage.SchematicForm:IsVisible() then
        return ProfessionsFrame.CraftingPage.SchematicForm
    elseif ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:IsVisible() then
        return ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm
    end
end

function CraftSim.UTIL:GetDifferentQualityIDsByCraftingReagentTbl(recipeID, craftingReagentInfoTbl, allocationItemGUID)
    local qualityIDs = {}
    for i = 1, 3, 1 do
        local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, craftingReagentInfoTbl,
            allocationItemGUID, i)
        table.insert(qualityIDs, outputItemData.itemID)
    end
    return qualityIDs
end

--- without using recipeData
---@param recipeID number
function CraftSim.UTIL:IsDragonflightRecipe(recipeID)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if recipeInfo then
        local professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)
        if not professionInfo.profession then
            print("No Profession loaded yet?", false, true)
            print(professionInfo, true)
        end

        -- do not use C_TradeSkillUI.IsRecipeInSkillLine because its not using cached data..
        local IsDragonflightRecipe = professionInfo.professionID ==
            CraftSim.CONST.TRADESKILLLINEIDS[professionInfo.profession][CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT]
        return IsDragonflightRecipe
    end

    return false
end

function CraftSim.UTIL:GetDifferentQualitiesByCraftingReagentTbl(recipeID, craftingReagentInfoTbl, allocationItemGUID,
                                                                 maxQuality)
    local linksByQuality = {}
    local max = 8
    if maxQuality then
        max = 3 + maxQuality
    end
    for i = 4, max, 1 do
        local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, craftingReagentInfoTbl, -- seems to also work if character does not have the profession!
            allocationItemGUID, i)
        table.insert(linksByQuality, outputItemData.hyperlink)
    end
    return linksByQuality
end

---@return fun(ID: CraftSim.LOCALIZATION_IDS): string
function CraftSim.UTIL:GetLocalizer()
    return function(ID)
        return CraftSim.LOCAL:GetText(ID)
    end
end
