---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

CraftSim.UTIL = {}

CraftSim.UTIL.frameLevel = 100

local print = CraftSim.DEBUG:RegisterDebugID("Util")

function CraftSim.UTIL:NextFrameLevel()
    local frameLevel = CraftSim.UTIL.frameLevel
    CraftSim.UTIL.frameLevel = CraftSim.UTIL.frameLevel + 50
    return frameLevel
end

---@param orderType Enum.CraftingOrderType
---@return string
function CraftSim.UTIL:GetOrderTypeText(orderType)
    local orderTypeText = CreateAtlasMarkup("Professions-Crafting-Orders-Icon", 15, 15)

    if orderType == Enum.CraftingOrderType.Npc then
        orderTypeText = string.format("%s %s", orderTypeText, f.bb("NPC"))
    elseif orderType == Enum.CraftingOrderType.Guild then
        orderTypeText = string.format("%s %s", orderTypeText, f.g("Guild"))
    elseif orderType == Enum.CraftingOrderType.Personal then
        orderTypeText = string.format("%s %s", orderTypeText, f.bb("Pers."))
    elseif orderType == Enum.CraftingOrderType.Public then
        orderTypeText = string.format("%s %s", orderTypeText, f.b("Public"))
    end

    return orderTypeText
end

-- thx ketho forum guy
function CraftSim.UTIL:ShowTextCopyBox(text)
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

---@return CraftSim.EXPORT_MODE
function CraftSim.UTIL:GetExportModeByVisibility()
    return (ProfessionsFrame.OrdersPage.OrderView.OrderDetails:IsVisible() and CraftSim.CONST.EXPORT_MODE.WORK_ORDER) or
        CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER
end

--- used for e.g. phial of bountiful seasons
---@return number season 0 -> winter, 1 -> spring, 2 -> summer, 3 -> fall
function CraftSim.UTIL:GetCurrentSeason()
    -- Get the current in-game date
    local month, day = tonumber(date("%m")), tonumber(date("%d"))

    -- Determine the season based on the month and day
    if (month == 12 and day >= 21) or (month >= 1 and month < 3) or (month == 3 and day < 20) then
        return 0
    elseif (month == 3 and day >= 20) or (month >= 4 and month < 6) or (month == 6 and day < 21) then
        return 1
    elseif (month == 6 and day >= 21) or (month >= 7 and month < 9) or (month == 9 and day < 23) then
        return 2
    elseif (month == 9 and day >= 23) or (month >= 10 and month < 12) or (month == 12 and day < 21) then
        return 3
    end

    return 2
end

function CraftSim.UTIL:IsWorkOrder()
    return ProfessionsFrame.OrdersPage.OrderView.OrderDetails:IsVisible()
end

---@param skillLineID number
---@return CraftSim.EXPANSION_IDS expansionID
function CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    local skillLineIDMap = CraftSim.CONST.TRADESKILLLINEIDS

    for _, expansionData in pairs(skillLineIDMap) do
        for expansionID, _skillLineID in pairs(expansionData) do
            if _skillLineID == skillLineID then
                return expansionID
            end
        end
    end

    return 0 -- sometimes happens if not yet initialized
end

function CraftSim.UTIL:ExportRecipeIDsForExpacCSV()
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local expansionID = self:GetExpansionIDBySkillLineID(skillLineID)

    local recipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()

    local text = "SpellID"
    for _, recipeID in ipairs(recipeIDs or {}) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        text = text .. "\n" .. recipeID
    end
    return text
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

---@param recipeID number
function CraftSim.UTIL:IsTWWRecipe(recipeID)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if recipeInfo then
        local professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)
        if not professionInfo.profession then
            print("No Profession loaded yet?", false, true)
            print(professionInfo, true)
        end

        -- do not use C_TradeSkillUI.IsRecipeInSkillLine because its not using cached data..
        local IsTWWRecipe = professionInfo.professionID ==
            CraftSim.CONST.TRADESKILLLINEIDS[professionInfo.profession][CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN]
        return IsTWWRecipe
    end

    return false
end

---@param baseYield number
function CraftSim.UTIL:GetMulticraftConstantByBaseYield(baseYield)
    local mcConstants = CraftSim.DB.OPTIONS:Get("PROFIT_CALCULATION_MULTICRAFT_CONSTANTS")
    return mcConstants[baseYield] or mcConstants.DEFAULT
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

---@param costConstant number
---@param playerSkill number
---@param skillStart number
---@param skillEnd number
---@param skillCurveValueStart number
---@param skillCurveValueEnd number
---@param lessConcentrationUsageFactors number[]
---@param noRounding boolean?
---@return number concentrationCost
function CraftSim.UTIL:CalculateConcentrationCost(costConstant, playerSkill, skillStart, skillEnd, skillCurveValueStart,
                                                  skillCurveValueEnd, lessConcentrationUsageFactors, noRounding)
    local skillDifference = math.abs(skillEnd - skillStart)
    local valueDifference = math.abs(skillCurveValueStart - skillCurveValueEnd) -- can go up or down
    local skillValueStep = valueDifference / skillDifference

    local playerSkillDifference = math.abs(playerSkill - skillStart)
    local playerSkillCurveValueDifference = playerSkillDifference * skillValueStep

    local playerSkillCurveValue
    if skillCurveValueStart < skillCurveValueEnd then
        playerSkillCurveValue = skillCurveValueStart + playerSkillCurveValueDifference
    else
        playerSkillCurveValue = skillCurveValueStart - playerSkillCurveValueDifference
    end

    local concentrationCost = (playerSkillCurveValue * costConstant)
    local factorSubtraction = GUTIL:Fold(lessConcentrationUsageFactors or {}, 0, function(foldValue, nextFactor)
        return foldValue + concentrationCost * nextFactor
    end)

    if noRounding then
        return concentrationCost - factorSubtraction
    else
        return CraftSim.GUTIL:Round(concentrationCost - factorSubtraction)
    end
end

---@param recipeDifficulty number
---@param curveConstantData CraftSim.UTIL.FindBracketData
---@param nextCurveConstantData CraftSim.UTIL.FindBracketData
---@return number curveConstant
function CraftSim.UTIL:CalculateCurveConstant(recipeDifficulty, curveConstantData, nextCurveConstantData)
    if not nextCurveConstantData then return curveConstantData.data end
    local difficultyDifference = math.abs(nextCurveConstantData.index - curveConstantData.index)
    local valueDifference = math.abs(nextCurveConstantData.data - curveConstantData.data)
    local difficultyValueStep = (difficultyDifference > 0 and valueDifference / difficultyDifference) or 0

    if difficultyValueStep == 0 then
        return curveConstantData.data
    end

    local recipeDifficultyDifference = math.abs(recipeDifficulty - curveConstantData.index)
    local recipeDifficultyConstantDifference = recipeDifficultyDifference * difficultyValueStep

    local recipeDifficultyConstant
    if curveConstantData.data < nextCurveConstantData.data then
        recipeDifficultyConstant = curveConstantData.data + recipeDifficultyConstantDifference
    else
        recipeDifficultyConstant = curveConstantData.data - recipeDifficultyConstantDifference
    end

    return recipeDifficultyConstant
end

---@class CraftSim.UTIL.FindBracketData
---@field index number
---@field data any

--- for tables with sorted number indices, find the data that lies at start of a gap based on given value
---@generic T
---@param indexValue number value to search for
---@param t table<number, any> table containing the data with numbered indices
---@return CraftSim.UTIL.FindBracketData?, CraftSim.UTIL.FindBracketData?
function CraftSim.UTIL:FindBracketData(indexValue, t)
    local dataList = {}
    for index, data in pairs(t) do
        tinsert(dataList, { index = index, data = data })
    end
    table.sort(dataList, function(a, b)
        return a.index < b.index
    end)

    -- find bracket
    for i, data in ipairs(dataList) do
        local indexStart = data.index
        if indexValue >= indexStart then
            local nextData = dataList[i + 1]
            local indexEnd = (nextData and nextData.index)

            if not indexEnd then return data, nil end

            if indexValue <= indexEnd then
                return data, nextData
            end
        end
    end

    return nil, nil
end

function CraftSim.UTIL:IsBetaBuild()
    local build = select(1, GetBuildInfo())

    return build == CraftSim.CONST.CURRENT_BETA_BUILD
end

--- for buff bag detection
---@param itemID number bag itemID
function CraftSim.UTIL:CheckIfBagIsEquipped(itemID)
    -- There are 5 bag slots
    for bagSlot = 0, 5 do
        local equippedBagID = GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(bagSlot + 1))
        if equippedBagID == itemID then
            return true
        end
    end
    return false
end

-- encode a string to base64
---@param str string string to encore
function CraftSim.UTIL:atob(str)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    return ((str:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#str % 3 + 1])
end

--- wrapper to use the money format use texture option
---@param copperValue number
---@param useColor? boolean -- colors the numbers green if positive and red if negative
---@param percentRelativeTo number? if included: will be treated as 100% and a % value in relation to the coppervalue will be added
function CraftSim.UTIL:FormatMoney(copperValue, useColor, percentRelativeTo)
    return GUTIL:FormatMoney(copperValue, useColor, percentRelativeTo, true,
        CraftSim.DB.OPTIONS:Get("MONEY_FORMAT_USE_TEXTURES"))
end

---@param profession Enum.Profession
function CraftSim.UTIL:IsProfessionLearned(profession)
    local learnedProfessions = { GetProfessions() };

    local skillLineIDs = GUTIL:Map(learnedProfessions, function(professionIndex)
        return select(7, GetProfessionInfo(professionIndex))
    end)

    if GUTIL:Some(skillLineIDs, function(skillLineID)
            local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
            return info and info.profession == profession
        end) then
        return true
    end

    return false
end
