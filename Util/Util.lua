---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local LibCompress = CraftSim.LibCompress
local AceSerializer = CraftSim.AceSerializer
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

--- Profession id for the open Professions UI. Prefer GetChildProfessionInfo (crafting tab); fall back to
--- ProfessionsFrame.professionInfo (e.g. orders tab) so work-order actions still resolve a profession.
---@return number? profession
function CraftSim.UTIL:GetProfessionsFrameProfession()
    local child = C_TradeSkillUI.GetChildProfessionInfo()
    if child and child.profession then
        return child.profession
    end
    if ProfessionsFrame and ProfessionsFrame.professionInfo and ProfessionsFrame.professionInfo.profession then
        return ProfessionsFrame.professionInfo.profession
    end
    return nil
end

--- True when the player is in range of the crafting table / spell focus for the current professions frame profession.
---@return boolean
function CraftSim.UTIL:IsNearProfessionsFrameCraftingTable()
    local p = CraftSim.UTIL:GetProfessionsFrameProfession()
    return p ~= nil and C_TradeSkillUI.IsNearProfessionSpellFocus(p)
end

--- True when "Add work orders" should be clickable: at the profession table, or the Crafting Orders tab is allowed
--- and enabled by Blizzard while the Professions frame is open (with a profession we can resolve for API calls).
---@return boolean
function CraftSim.UTIL:ShouldEnableCraftQueueAddWorkOrdersButton()
    if CraftSim.UTIL:IsNearProfessionsFrameCraftingTable() then
        return true
    end
    if not ProfessionsFrame or not ProfessionsFrame:IsVisible() then
        return false
    end
    if not C_CraftingOrders.ShouldShowCraftingOrderTab() or not ProfessionsFrame.isCraftingOrdersTabEnabled then
        return false
    end
    return CraftSim.UTIL:GetProfessionsFrameProfession() ~= nil
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

---@param recipeExpansionID CraftSim.EXPANSION_IDS?
---@param itemID number?
---@param context string? debug context
---@return boolean isCompatible
function CraftSim.UTIL:IsItemExpansionCompatible(recipeExpansionID, itemID, context)
    if not itemID then
        return true
    end

    local itemName, _, _, _, _, _, _, _, _, _, _, _, _, _, itemExpacID = C_Item.GetItemInfo(itemID)
    print(string.format("IsItemExpansionCompatible(%s, %s): recipeExpansionID=%s, itemID=%s, itemExpacID=%s",
        tostring(context), tostring(itemName), tostring(recipeExpansionID), tostring(itemID), tostring(itemExpacID)))

    if not recipeExpansionID then
        return true
    end

    if not itemExpacID then
        -- item data not loaded yet, don't incorrectly exclude it
        return true
    end

    if recipeExpansionID == "BASE" then recipeExpansionID = 0 end

    return itemExpacID >= recipeExpansionID
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

---@param recipeID number
function CraftSim.UTIL:IsCurrentExpansionRecipe(recipeID)
    local currentExpansionID = GetExpansionLevel()
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

    if recipeInfo then
        local professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)
        if not professionInfo.profession then
            print("No Profession loaded yet?", false, true)
            print(professionInfo, true)
        end

        -- do not use C_TradeSkillUI.IsRecipeInSkillLine because its not using cached data..
        local isCurrentExpansionRecipe = professionInfo.professionID ==
            CraftSim.CONST.TRADESKILLLINEIDS[professionInfo.profession][currentExpansionID]
        return isCurrentExpansionRecipe
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

---@return fun(ID: CraftSim.LOCALIZATION_IDS | string): string
function CraftSim.UTIL:GetLocalizer()
    return function(ID)
        return CraftSim.LOCAL:GetText(ID)
    end
end

--- Clock icon + localized current/max charges. Same data path as Recipe Scan (`GetCooldownDataForRecipeCrafter`).
---@param recipeData CraftSim.RecipeData
---@return string
function CraftSim.UTIL:GetRecipeCooldownChargesInlineSuffix(recipeData)
    local cooldownData = recipeData:GetCooldownDataForRecipeCrafter()
    if not cooldownData or not cooldownData.isCooldownRecipe then
        return ""
    end
    local currentCharges = cooldownData:GetCurrentCharges()
    if currentCharges == nil then
        currentCharges = 0
    end
    local timeIcon = CreateAtlasMarkup(CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.COOLDOWN.texture, 13, 13)
    local fmt = CraftSim.LOCAL:GetText("RECIPE_COOLDOWN_CHARGES_INLINE")
    return " " .. timeIcon .. string.format(fmt, currentCharges, cooldownData.maxCharges)
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

--- wrapper to use the money format use texture option
---@param copperValue number
---@param useColor? boolean -- colors the numbers green if positive and red if negative
---@param percentRelativeTo number? if included: will be treated as 100% and a % value in relation to the coppervalue will be added
---@param showCopper? boolean -- whether to show copper value false by default
function CraftSim.UTIL:FormatMoney(copperValue, useColor, percentRelativeTo, showCopper)
    return GUTIL:FormatMoney(copperValue, useColor, percentRelativeTo, true,
        CraftSim.DB.OPTIONS:Get("MONEY_FORMAT_USE_TEXTURES"), showCopper)
end

--- Returns true if the item is grey/poor quality (cannot be sold on AH, vendor-only)
---@param itemID ItemID
---@return boolean
function CraftSim.UTIL:IsGreyItem(itemID)
    local rarity = select(3, C_Item.GetItemInfo(itemID))
    if rarity == nil then
        return false   -- item data not yet cached; treat as non-grey (safe fallback)
    end
    return rarity == 0 -- Enum.ItemQuality.Poor = 0
end

--- Returns the vendor sell price of an item (what you receive when selling to a vendor)
---@param itemID ItemID
---@return number vendorSellPrice
function CraftSim.UTIL:GetVendorSellPriceByItemID(itemID)
    local vendorSellPrice = select(11, C_Item.GetItemInfo(itemID))
    return vendorSellPrice or 0
end

--- Reference copper per unit for patron-order Manu Moxie (Craft Queue options). Tooltips always; also commission profit when CRAFTQUEUE_QUEUE_PATRON_ORDERS_INCLUDE_MOXIE_IN_PROFIT is enabled.
---@param currencyID number
---@return number copperPerUnit
function CraftSim.UTIL:GetPatronOrderMoxieCopperPerUnit(currencyID)
    local values = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_MOXIE_VALUES")
    if type(values) ~= "table" then
        return 0
    end
    return tonumber(values[currencyID]) or 0
end

--- Manu Moxie currency for the recipe's profession (API may omit `professionInfo.profession`; fall back via skill line).
---@param recipeData CraftSim.RecipeData
---@return number?
function CraftSim.UTIL:GetRecipeProfessionMoxieCurrencyID(recipeData)
    local pd = recipeData.professionData
    if not pd or not pd.professionInfo then
        return nil
    end
    local profession = pd.professionInfo.profession
    local mapped = profession and CraftSim.CONST.MOXIE_CURRENCY_ID_BY_PROFESSION[profession]
    if mapped then
        return mapped
    end
    local sid = pd.skillLineID
    if not sid then
        return nil
    end
    for prof, lines in pairs(CraftSim.CONST.TRADESKILLLINEIDS) do
        if type(prof) == "number" and type(lines) == "table" then
            local moxieID = CraftSim.CONST.MOXIE_CURRENCY_ID_BY_PROFESSION[prof]
            if moxieID then
                for _, lineID in pairs(lines) do
                    if lineID == sid then
                        return moxieID
                    end
                end
            end
        end
    end
    return nil
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

---@param itemLink string
---@return number? enchantID
function CraftSim.UTIL:GetEnchantIDFromItemLink(itemLink)
    if not itemLink or not itemLink:find("|Hitem:") then return nil end

    local parts = { strsplit(":", itemLink) }
    return tonumber(parts[4])
end

---@param table table
---@return string? encodedString in base64
function CraftSim.UTIL:EncodeTable(table)
    local serializedTable = AceSerializer:Serialize(table)
    local compressedData, compressError = LibCompress:Compress(serializedTable)

    if not compressedData then
        error("CraftSim: Failed to encode table: " .. tostring(compressError))
        return nil
    end
    return GUTIL:EncodeBase64(compressedData)
end

---@param string string base64 encoded string
---@return table?
function CraftSim.UTIL:DecodeTable(string)
    local decodedData = GUTIL:DecodeBase64(string)
    local decompressedData, decompressError = LibCompress:Decompress(decodedData)
    if not decompressedData then
        error("CraftSim: Failed to decode table: " .. tostring(decompressError))
        return nil
    end
    local success, deserializedTable = AceSerializer:Deserialize(decompressedData)
    if not success then
        error("CraftSim: Failed to deserialize table")
        return nil
    end
    return deserializedTable
end

---@param key string
---@return table layoutConfig
function CraftSim.UTIL:GetFrameListLayoutConfig(key)
    local layoutConfigs = CraftSim.DB.OPTIONS:Get("FRAME_LIST_LAYOUT_CONFIGS")

    layoutConfigs[key] = layoutConfigs[key] or {}

    return layoutConfigs[key]
end

function CraftSim.UTIL:DisenchantWarbankItem(itemID)
    if not C_SpellBook.ContainsAnyDisenchantSpell() then return end

    local itemLocation = GUTIL:GetItemLocationFromItemID(itemID)
    if not itemLocation then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "ItemID not found in bags or equipped: " .. itemID)
        return
    end
end

---@param isWarbank boolean
---@return ItemLocationMixin[]
function CraftSim.UTIL:GetFreeBankSlots(isWarbank)
    local startBagID = isWarbank and Enum.BagIndex.AccountBankTab_1 or Enum.BagIndex.CharacterBankTab_1
    local endBagID = isWarbank and Enum.BagIndex.AccountBankTab_5 or Enum.BagIndex.CharacterBankTab_6

    local freeSlots = {}

    for bag = startBagID, endBagID do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
            if not C_Container.GetContainerItemInfo(bag, slot) then
                table.insert(freeSlots, itemLocation)
            end
        end
    end

    return freeSlots
end

---@return ItemLocationMixin[]
function CraftSim.UTIL:GetFreeInventorySlots()
    local startBagID = Enum.BagIndex.Backpack
    local endBagID = Enum.BagIndex.Bag_4

    local freeSlots = {}
    for bag = startBagID, endBagID do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
            if not C_Container.GetContainerItemInfo(bag, slot) then
                table.insert(freeSlots, itemLocation)
            end
        end
    end

    return freeSlots
end

---@param itemInfo number | string itemID or itemLink
function CraftSim.UTIL:MoveItemIntoBank(itemInfo)
    -- check if warbank open
    local bankOpen = BankFrame.TabSystem:IsTabEnabled(1)
    local warbankOpen = BankFrame.TabSystem:IsTabEnabled(2)
    if not bankOpen and not warbankOpen then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "No bank open")
        return
    end

    -- fetch items based on itemInfo from inventory
    ---@type ItemMixin[]
    local items = {}
    for bag = Enum.BagIndex.Backpack, Enum.BagIndex.Bag_4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
            if itemLocation:IsValid() then
                local item = Item:CreateFromItemLocation(itemLocation)
                if item then
                    table.insert(items, item)
                end
            end
        end
    end

    GUTIL:ContinueOnAllItemsLoaded(items, function()
        local items = GUTIL:Filter(items, function(item)
            local itemID = item:GetItemID()
            local itemLink = item:GetItemLink()
            local itemName = item:GetItemName()

            -- 1) check if link matches 2) check if itemID matches 3) check if name contains given string for partial name search
            return itemLink == itemInfo or itemID == tonumber(itemInfo) or
                string.find(itemName, itemInfo, 1, true) ~= nil
        end)

        if #items == 0 then
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Item not found in bags: " .. tostring(itemInfo))
            return
        end

        local freeBankSlots = self:GetFreeBankSlots(warbankOpen)
        if #freeBankSlots == 0 then
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "No free bank slots available")
            return
        end

        -- start moving items to free slots

        local itemMoveCount = math.min(#items, #freeBankSlots)

        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") ..
            "Moving " .. itemMoveCount .. " items to " .. (warbankOpen and "warbank" or "bank"))

        -- it works within 1 frame.. but split it a bit just in case

        GUTIL.FrameDistributor {
            iterationTable = items,
            iterationsPerFrame = CraftSim.DB.OPTIONS:Get("BANKING_MAX_ITEMS_PER_FRAME"),
            maxIterations = itemMoveCount,
            finally = function()
                CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Finished moving items")
            end,
            continue = function(frameDistributor, key, _, _, _)
                local item = items[key]
                local freeSlot = freeBankSlots[key]

                -- inframe check if bank is still open
                if warbankOpen and not BankFrame.TabSystem:IsTabEnabled(2) then
                    CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Warbank closed, stopping move")
                    frameDistributor:Break()
                    return
                elseif bankOpen and not BankFrame.TabSystem:IsTabEnabled(1) then
                    CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Bank closed, stopping move")
                    frameDistributor:Break()
                    return
                end

                local bag, slot = item:GetItemLocation():GetBagAndSlot()

                ClearCursor()

                C_Container.PickupContainerItem(bag, slot)
                if GetCursorInfo() == "item" then
                    C_Container.PickupContainerItem(freeSlot:GetBagAndSlot())
                end
                ClearCursor()

                frameDistributor:Continue()
            end
        }:Continue()
    end)
end

---@param itemInfo number | string itemID or itemLink
function CraftSim.UTIL:MoveItemIntoInventory(itemInfo)
    -- check if warbank open
    local bankOpen = BankFrame.TabSystem:IsTabEnabled(1)
    local warbankOpen = BankFrame.TabSystem:IsTabEnabled(2)
    if not bankOpen and not warbankOpen then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "No bank open")
        return
    end

    -- fetch items based on itemInfo from bank
    local bagStart = warbankOpen and Enum.BagIndex.AccountBankTab_1 or Enum.BagIndex.CharacterBankTab_1
    local bagEnd = warbankOpen and Enum.BagIndex.AccountBankTab_5 or Enum.BagIndex.CharacterBankTab_6
    ---@type ItemMixin[]
    local items = {}
    for bag = bagStart, bagEnd do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
            if itemLocation:IsValid() then
                local item = Item:CreateFromItemLocation(itemLocation)
                if item then
                    table.insert(items, item)
                end
            end
        end
    end

    GUTIL:ContinueOnAllItemsLoaded(items, function()
        local items = GUTIL:Filter(items, function(item)
            local itemID = item:GetItemID()
            local itemLink = item:GetItemLink()
            local itemName = item:GetItemName()

            -- 1) check if link matches 2) check if itemID matches 3) check if name contains given string for partial name search
            return itemLink == itemInfo or itemID == tonumber(itemInfo) or
                string.find(itemName, itemInfo, 1, true) ~= nil
        end)

        if #items == 0 then
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Item not found in bags: " .. tostring(itemInfo))
            return
        end


        local freeInventorySlots = self:GetFreeInventorySlots()
        if #freeInventorySlots == 0 then
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "No free inventory slots available")
            return
        end

        -- start moving items to free slots

        local itemMoveCount = math.min(#items, #freeInventorySlots)

        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Moving " .. itemMoveCount .. " items to bags")
        -- it works within 1 frame.. but split it a bit just in case

        GUTIL.FrameDistributor {
            iterationTable = items,
            iterationsPerFrame = CraftSim.DB.OPTIONS:Get("BANKING_MAX_ITEMS_PER_FRAME"),
            maxIterations = itemMoveCount,
            finally = function()
                CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Finished moving items")
            end,
            continue = function(frameDistributor, key, _, _, _)
                local item = items[key]
                local freeSlot = freeInventorySlots[key]

                -- inframe check if bank is still open
                if warbankOpen and not BankFrame.TabSystem:IsTabEnabled(2) then
                    CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Warbank closed, stopping move")
                    frameDistributor:Break()
                    return
                elseif bankOpen and not BankFrame.TabSystem:IsTabEnabled(1) then
                    CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. "Bank closed, stopping move")
                    frameDistributor:Break()
                    return
                end

                local bag, slot = item:GetItemLocation():GetBagAndSlot()

                ClearCursor()

                C_Container.PickupContainerItem(bag, slot)
                if GetCursorInfo() == "item" then
                    C_Container.PickupContainerItem(freeSlot:GetBagAndSlot())
                end
                ClearCursor()

                frameDistributor:Continue()
            end
        }:Continue()
    end)
end
