---@class CraftSim
local CraftSim = select(2, ...)


local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@class CraftSim.ResultData : CraftSim.CraftSimObject
CraftSim.ResultData = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.ResultData:new(recipeData)
    if not recipeData then
        return
    end
    self.recipeData = recipeData
    ---@type ItemMixin[]
    self.itemsByQuality = {}
    self.canUpgradeQuality = false
    self.canUpgradeInspiration = false
    self.canUpgradeHSV = false
    self.canUpgradeInspirationHSV = false
    self.expectedQuality = 1
    self.expectedQualityUpgrade = 1
    self.expectedQualityInspiration = 1
    self.expectedQualityHSV = 1
    self.expectedQualityInspirationHSV = 1
    self.expectedQualityInspirationHSVSkip = 1

    ---@type CraftSim.HSVInfo
    self.hsvInfo = nil

    ---@type ItemMixin?
    self.expectedItemInspiration = nil

    ---@type ItemMixin?
    self.expectedItemHSV = nil

    ---@type ItemMixin?
    self.expectedItemInspirationHSV = nil

    ---@type ItemMixin?
    self.expectedItemUpgrade = nil

    self.chanceUpgrade = 0
    self.chanceInspiration = 0
    self.chanceHSV = 0
    self.chanceInspirationHSV = 0

    ---@type number[]
    self.chanceByQuality = {}

    --- E.g: if q1 = 70% and q2 = 30%, chance for min q1 is 100%
    ---@type number[]
    self.chancebyMinimumQuality = {}



    ---@type number[] if an item is unreachable the expected crafts are nil
    self.expectedCraftsByQuality = {}

    --- E.g: expected crafts to get at least the given quality (similar to chance by minQuality)
    ---@type number[] if an item is unreachable the expected crafts are nil
    self.expectedCraftsByMinimumQuality = {}

    --- Considering Multicraft and Multicraft Extra Item Bonus
    ---@type number
    self.expectedYieldPerCraft = 0

    --- Per craft
    ---@type number[]
    self.expectedYieldByQuality = {}

    --- Per craft
    ---@type number[]
    self.expectedYieldByMinimumQuality = {}

    self:UpdatePossibleResultItems()
end

--- Updates based on reagentData
function CraftSim.ResultData:UpdatePossibleResultItems()
    local recipeData = self.recipeData

    -- TODO: only need to update possible list for gear as everything else is static
    self.itemsByQuality = {}
    local craftingReagentInfoTbl = recipeData.reagentData:GetCraftingReagentInfoTbl()

    if recipeData.isEnchantingRecipe then
        if not CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID] then
            print("CraftSim: Enchant Recipe Missing in Data: " .. recipeData.recipeID)
            return
        end
        local itemIDs = {
            CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q1,
            CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q2,
            CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q3,
        }

        for _, itemID in pairs(itemIDs) do
            table.insert(self.itemsByQuality, Item:CreateFromItemID(itemID))
        end
    elseif recipeData.isGear then
        local itemLinks = CraftSim.UTIL:GetDifferentQualitiesByCraftingReagentTbl(recipeData.recipeID,
            craftingReagentInfoTbl, recipeData.allocationItemGUID, recipeData.maxQuality)

        for _, itemLink in pairs(itemLinks) do
            table.insert(self.itemsByQuality, Item:CreateFromItemLink(itemLink))
        end
    else
        local itemIDs = CraftSim.UTIL:GetDifferentQualityIDsByCraftingReagentTbl(recipeData.recipeID,
            craftingReagentInfoTbl, recipeData.allocationItemGUID)
        for _, itemID in pairs(itemIDs) do
            table.insert(self.itemsByQuality, Item:CreateFromItemID(itemID))
        end
    end

    if not recipeData.isGear and self.itemsByQuality[1] and self.itemsByQuality[2] then
        if self.itemsByQuality[1]:GetItemID() == self.itemsByQuality[2]:GetItemID() then
            self.itemsByQuality = { self.itemsByQuality[1] } -- force one of an item (illustrious insight e.g. has always 3 items in it for whatever reason)
        end
    end

    if not recipeData.isGear then
        local crafterUID = recipeData:GetCrafterUID()
        -- if not gear update -> itemRecipeDB
        for qualityID, item in ipairs(self.itemsByQuality) do
            local itemID = item:GetItemID()
            CraftSim.DB.ITEM_RECIPE:Add(recipeData.recipeID, qualityID, itemID, crafterUID)
        end
    end
end

--- Returns true if the chance to craft this exact quality is higher than 0
---@param qualityID number
---@return boolean craftable
function CraftSim.ResultData:IsQualityReachable(qualityID)
    if not self.recipeData.supportsQualities then
        return true
    end

    local craftingChance = self.chanceByQuality[qualityID]

    if not craftingChance then
        return false
    end

    return craftingChance > 0
end

--- Returns true if either the given quality or any higher quality than it is craftable
---@param qualityID any
---@return boolean craftable
function CraftSim.ResultData:IsMinimumQualityReachable(qualityID)
    if not self.recipeData.supportsQualities then
        return true
    end

    for currentQualityID = qualityID, self.recipeData.maxQuality do
        local craftingChance = self.chanceByQuality[currentQualityID]
        if craftingChance and craftingChance > 0 then
            return true
        end
    end

    return false
end

--- Updates based on professionStats and reagentData
function CraftSim.ResultData:Update()
    local recipeData = self.recipeData

    if recipeData.isGear then
        self:UpdatePossibleResultItems()
    end

    -- based on stats predict the resulting items if there are any

    if #self.itemsByQuality == 0 then
        print("ResultData: No OutputItems")
        return
    end

    -- TODO: new util function? V2 ?
    local function expectedQualityBySkill(skill, maxQuality, recipeDifficulty)
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(maxQuality, recipeDifficulty,
            CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET"))
        local expectedQuality = 1

        for _, threshold in pairs(thresholds) do
            if skill >= threshold then
                expectedQuality = expectedQuality + 1
            end
        end

        return expectedQuality
    end

    local professionStats = self.recipeData.professionStats

    local expectedItemYieldPerCraft = CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)

    -- special case for no quality results. Needed for expectedCrafts and such
    if not recipeData.supportsQualities or not recipeData.supportsInspiration then
        self.expectedQuality = 1
        self.expectedItem = self.itemsByQuality[1]
        self.expectedCraftsByQuality = { 1 }
        self.expectedCraftsByMinimumQuality = { 1 }
        self.chanceByQuality = { 1 }
        self.chancebyMinimumQuality = { 1 }
        self.expectedYieldByQuality = { expectedItemYieldPerCraft }
        self.expectedYieldByMinimumQuality = { expectedItemYieldPerCraft }
        return
    end

    self.expectedQuality = expectedQualityBySkill(professionStats.skill.value, recipeData.maxQuality,
        professionStats.recipeDifficulty.value)

    self.expectedItem = self.itemsByQuality[self.expectedQuality]

    local hsvInfo = CraftSim.CALC:GetHSVInfo(self.recipeData)

    self.hsvInfo = hsvInfo

    local skillInspiration = professionStats.skill.value + professionStats.inspiration:GetExtraValueByFactor()
    local qualityInspiration = expectedQualityBySkill(skillInspiration, recipeData.maxQuality,
        professionStats.recipeDifficulty.value)

    local qualityHSV = self.expectedQuality
    local qualityInspirationHSV = qualityInspiration
    local qualityInspirationHSVSkip = qualityInspiration

    if hsvInfo.chanceNextQuality > 0 then
        if hsvInfo.nextQualityWithInspirationOnly then
            qualityInspirationHSV = self.expectedQuality + 1
        else
            qualityHSV = self.expectedQuality + 1
        end
    end
    if hsvInfo.canSkipQualityWithInspiration then
        qualityInspirationHSVSkip = self.expectedQuality + 2
    end

    -- case #1
    -- expected = 1
    -- qualityHSV = 1
    -- qualityInspiration = 1
    -- expectedQualityWithInspirationAndHSV = 1
    --> qualityInspirationHSV = 1
    --> qualityInspirationHSVSkip = 1

    -- case #2
    -- expected = 1
    -- qualityHSV = 1
    -- qualityInspiration = 2
    -- expectedQualityWithInspirationAndHSV = 2
    --> qualityInspirationHSV = 2
    --> qualityInspirationHSVSkip = 2

    -- case #3
    -- expected = 1
    -- qualityHSV = 1
    -- qualityInspiration = 1
    -- expectedQualityWithInspirationAndHSV = 2
    --> qualityInspirationHSV = 2
    --> qualityInspirationHSVSkip = 2

    -- case #4
    -- expected = 1
    -- qualityHSV = 1
    -- qualityInspiration = 2
    -- expectedQualityWithInspirationAndHSV = 2
    --> qualityInspirationHSV = 2
    --> qualityInspirationHSVSkip = 2

    -- case #5
    -- expected = 1
    -- qualityHSV = 2
    -- qualityInspiration = 2
    -- expectedQualityWithInspirationAndHSV = 2
    --> qualityInspirationHSV = 2
    --> qualityInspirationHSVSkip = 2

    -- case #6
    -- expected = 1
    -- qualityHSV = 2
    -- qualityInspiration = 2
    -- expectedQualityWithInspirationAndHSV = 3
    --> qualityInspirationHSV = 2
    --> qualityInspirationHSVSkip = 3

    -- TODO: rename to highest quality Upgrade
    self.expectedQualityUpgrade = math.max(self.expectedQuality, qualityInspiration, qualityHSV, qualityInspirationHSV,
        qualityInspirationHSVSkip)
    self.expectedQualityInspiration = qualityInspiration
    self.expectedQualityHSV = qualityHSV
    self.expectedQualityInspirationHSV = qualityInspirationHSV
    self.expectedQualityInspirationHSVSkip = qualityInspirationHSVSkip

    self.canUpgradeQuality = self.expectedQuality < self.expectedQualityUpgrade
    self.canUpgradeInspiration = self.expectedQuality < self.expectedQualityInspiration
    self.canUpgradeHSV = self.expectedQuality < self.expectedQualityHSV
    self.canUpgradeInspirationHSV = self.expectedQuality < self.expectedQualityInspirationHSV
    self.canUpgradeInspirationHSVSkip = self.expectedQuality < self.expectedQualityInspirationHSVSkip

    self.expectedItemInspiration = self.itemsByQuality[qualityInspiration]
    self.expectedItemHSV = self.itemsByQuality[qualityHSV]
    self.expectedItemInspirationHSV = self.itemsByQuality[qualityInspirationHSV]
    self.expectedItemInspirationHSVSkip = self.itemsByQuality[qualityInspirationHSVSkip]
    self.expectedItemUpgrade = self.itemsByQuality[self.expectedQualityUpgrade]

    self.chanceInspiration = self.recipeData.professionStats.inspiration:GetPercent(true)
    self.chanceHSV = self.hsvInfo.chanceNextQuality
    self.chanceInspirationHSV = self.hsvInfo.chanceNextQuality * self.chanceInspiration
    self.chanceInspirationHSVSkip = self.hsvInfo.chanceSkipQuality * self.chanceInspiration

    wipe(self.expectedCraftsByQuality)
    wipe(self.chanceByQuality)

    for quality = 1, self.recipeData.maxQuality, 1 do
        if quality < self.expectedQuality then
            self.chanceByQuality[quality] = 0
        else
            -- can either be one quality above expected or two qualities above expected
            if quality == self.expectedQuality + 1 then
                if quality ~= qualityHSV and quality == qualityInspiration then
                    -- just reachable by inspiration
                    self.chanceByQuality[quality] = self.chanceInspiration
                elseif quality == qualityHSV and quality == qualityInspiration then
                    -- reachable by hsv or inspiration or both
                    self.chanceByQuality[quality] =
                        self.hsvInfo.chanceNextQuality * self.chanceInspiration +
                        (1 - self.hsvInfo.chanceNextQuality) * self.chanceInspiration +
                        self.hsvInfo.chanceNextQuality * (1 - self.chanceInspiration)
                elseif quality == qualityHSV and quality ~= qualityInspiration then
                    -- if we get the quality via hsv but inspiration alone skips it
                    self.chanceByQuality[quality] = self.hsvInfo.chanceNextQuality
                elseif quality ~= qualityHSV and quality ~= qualityInspiration and quality == qualityInspirationHSV then
                    -- only reachable with hsv and inspiration together
                    self.chanceByQuality[quality] = self.chanceInspirationHSV
                else
                    -- if none of the above holds, chance to reach the quality is 0
                    self.chanceByQuality[quality] = 0
                end
            elseif quality == self.expectedQuality + 2 then
                if quality == qualityInspiration then
                    -- inspiration skips us directly to this quality, then its just the inspiration chance
                    self.chanceByQuality[quality] = self.chanceInspiration
                elseif quality == qualityInspirationHSVSkip then
                    -- we can only reach the quality with inspiration and hsv skip chance
                    self.chanceByQuality[quality] = self.chanceInspirationHSVSkip
                else
                    -- if none of the above holds, chance to reach the quality is 0
                    self.chanceByQuality[quality] = 0
                end
            else
                self.chanceByQuality[quality] = 0
            end

            if self.expectedQualityUpgrade == quality then
                self.chanceUpgrade = self.chanceByQuality[quality]
            end
        end
        if self.chanceByQuality[quality] > 0 then
            self.expectedCraftsByQuality[quality] = 1 / self.chanceByQuality[quality]
        end
    end

    -- set the chance for the expected quality as the remaining chance
    self.chanceByQuality[self.expectedQuality] = 1
    if self.expectedQuality + 1 <= self.recipeData.maxQuality then
        self.chanceByQuality[self.expectedQuality] = self.chanceByQuality
            [self.expectedQuality] - self.chanceByQuality
            [self.expectedQuality + 1]
        if self.expectedQuality + 2 <= self.recipeData.maxQuality then
            self.chanceByQuality[self.expectedQuality] = self.chanceByQuality
                [self.expectedQuality] -
                self.chanceByQuality[self.expectedQuality + 2]
        end
    end

    if self.expectedQualityUpgrade == self.expectedQuality then
        self.chanceUpgrade = self.chanceByQuality[self.expectedQuality]
    end

    if self.chanceByQuality[self.expectedQuality] > 0 then
        self.expectedCraftsByQuality[self.expectedQuality] = 1 / self.chanceByQuality[self.expectedQuality]
    end

    -- chances for min quality is based on chancebyquality
    -- expected crafts by minquality is based on chancebyminquality

    for quality = 1, self.recipeData.maxQuality, 1 do
        local minChanceSum = 0
        for q = quality, self.recipeData.maxQuality, 1 do
            local chanceForQuality = self.chanceByQuality[q] or 0
            minChanceSum = minChanceSum + chanceForQuality
        end

        self.chancebyMinimumQuality[quality] = minChanceSum
        if minChanceSum > 0 then
            self.expectedCraftsByMinimumQuality[quality] = 1 / minChanceSum
        end
    end

    -- expected yield per quality
    wipe(self.expectedYieldByQuality)
    wipe(self.expectedYieldByMinimumQuality)

    for quality = 1, self.recipeData.maxQuality, 1 do
        local chance = self.chanceByQuality[quality]
        local chanceMin = self.chancebyMinimumQuality[quality]
        if chance > 0 then
            self.expectedYieldByQuality[quality] = chance * expectedItemYieldPerCraft
        else
            self.expectedYieldByQuality[quality] = 0
        end

        if chanceMin > 0 then
            self.expectedYieldByMinimumQuality[quality] = chanceMin * expectedItemYieldPerCraft
        else
            self.expectedYieldByMinimumQuality[quality] = 0
        end
    end
end

--- returns the expected number of crafts to craft a given amount of items of the given quality
---@param amount number how many items of the given quality
---@param qualityID number quality to be crafted
---@return number expectedCrafts for given yield for given quality
function CraftSim.ResultData:GetExpectedCraftsForYieldByQuality(amount, qualityID)
    local expectedYieldForQuality = self.expectedYieldByQuality[qualityID] or 0
    if expectedYieldForQuality > 0 then
        return amount / expectedYieldForQuality
    else
        return 0
    end
end

--- returns the expected number of crafts to craft a given amount of items of the given minimum quality
---@param amount number how many items of the given quality or higher
---@param qualityID number minimum quality to be crafted
---@return number expectedCrafts for given yield for given quality or higher
function CraftSim.ResultData:GetExpectedCraftsForYieldByMinimumQuality(amount, qualityID)
    local expectedYieldForQualityOrHigher = self.expectedYieldByMinimumQuality[qualityID] or 0
    if expectedYieldForQualityOrHigher > 0 then
        return amount / expectedYieldForQualityOrHigher
    else
        return 0
    end
end

function CraftSim.ResultData:Debug()
    local debugLines = {}
    for q, item in pairs(self.itemsByQuality) do
        table.insert(debugLines, "Possible Result Q" .. q .. " " .. (item:GetItemLink() or item:GetItemID()))
    end
    for q, chance in pairs(self.chanceByQuality) do
        table.insert(debugLines, "Q" .. q .. " Chance: " .. chance * 100 .. " %")
    end
    return CraftSim.GUTIL:Concat({ debugLines,
        {
            "expectedQuality: " .. tostring(self.expectedQuality),
            "expectedQualityUpgrade: " .. tostring(self.expectedQualityUpgrade),
            "expectedQualityInspiration: " .. tostring(self.expectedQualityInspiration),
            "expectedQualityHSV: " .. tostring(self.expectedQualityHSV),
            "expectedQualityInspirationHSV: " .. tostring(self.expectedQualityInspirationHSV),
            "expectedQualityInspirationHSVSkip: " .. tostring(self.expectedQualityInspirationHSVSkip),
            "expectedItem: " .. tostring(self.expectedItem and self.expectedItem:GetItemLink()),
            "expectedItemUpgrade: " .. tostring(self.expectedItemUpgrade and self.expectedItemUpgrade:GetItemLink()),
            "canUpgradeQuality: " .. tostring(self.canUpgradeQuality),
            "expectedItemInspiration: " ..
            tostring(self.expectedItemInspiration and self.expectedItemInspiration:GetItemLink()),
            "expectedItemHSV: " .. tostring(self.expectedItemHSV and self.expectedItemHSV:GetItemLink()),
            "expectedItemInspirationHSV: " ..
            tostring(self.expectedItemInspirationHSV and self.expectedItemInspirationHSV:GetItemLink()),
            "expectedItemInspirationHSVSkip: " ..
            tostring(self.expectedItemInspirationHSVSkip and self.expectedItemInspirationHSVSkip:GetItemLink()),
            "chanceUpgrade: " .. tostring(self.chanceUpgrade * 100) .. "%",
            "chanceInspiration: " .. tostring(self.chanceInspiration * 100) .. "%",
            "chanceHSV: " .. tostring(self.chanceHSV * 100) .. "%",
            "chanceInspirationHSV: " .. tostring(self.chanceInspirationHSV * 100) .. "%",
            "chanceInspirationHSVSkip: " .. tostring(self.chanceInspirationHSVSkip * 100) .. "%",
        }
    })
end

function CraftSim.ResultData:Copy(recipeData)
    local copy = CraftSim.ResultData(recipeData)
    return copy
end

---@class CraftSim.ResultData.Serialized
---@field itemLinksByQuality string[]
---@field expectedQuality number
---@field expectedQualityInspiration number
---@field expectedQualityHSV number
---@field expectedQualityInspirationHSV number
---@field expectedQualityUpgrade number
---@field canUpgradeQuality boolean
---@field expectedItemLink? string
---@field expectedItemLinkUpgrade? string
---@field expectedItemLinkInspiration? string
---@field expectedItemLinkHSV? string
---@field expectedItemLinkInspirationHSV? string
---@field chanceUpgrade number
---@field chanceInspiration number
---@field chanceHSV number
---@field chanceInspirationHSV number
---@field chanceByQuality number[]
---@field chancebyMinimumQuality number[]
---@field expectedCraftsByQuality number[]
---@field expectedCraftsByMinimumQuality number[]
---@field expectedYieldPerCraft number

--- Make sure that the items are loaded before serializing or the links are empty
function CraftSim.ResultData:Serialize()
    local serialized = {}
    serialized.itemLinksByQuality = CraftSim.GUTIL:Map(self.itemsByQuality, function(item)
        return item:GetItemLink()
    end)
    serialized.expectedQuality = self.expectedQuality
    serialized.expectedQualityInspiration = self.expectedQualityInspiration
    serialized.expectedQualityHSV = self.expectedQualityHSV
    serialized.expectedQualityInspirationHSV = self.expectedQualityInspirationHSV
    serialized.expectedQualityUpgrade = self.expectedQualityUpgrade
    serialized.canUpgradeQuality = self.canUpgradeQuality
    serialized.expectedItemLink = (self.expectedItem and self.expectedItem:GetItemLink()) or nil
    serialized.expectedItemLinkUpgrade = (self.expectedItemUpgrade and self.expectedItemUpgrade:GetItemLink()) or nil
    serialized.expectedItemLinkInspiration = (self.expectedItemInspiration and self.expectedItemInspiration:GetItemLink()) or
        nil
    serialized.expectedItemLinkHSV = (self.expectedItemHSV and self.expectedItemHSV:GetItemLink()) or nil
    serialized.expectedItemLinkInspirationHSV = (self.expectedItemInspirationHSV and self.expectedItemInspirationHSV:GetItemLink()) or
        nil
    serialized.chanceUpgrade = self.chanceUpgrade
    serialized.chanceInspiration = self.chanceInspiration
    serialized.chanceHSV = self.chanceHSV
    serialized.chanceInspirationHSV = self.chanceInspirationHSV
    serialized.chanceByQuality = CopyTable(self.chanceByQuality or {})
    serialized.chancebyMinimumQuality = CopyTable(self.chancebyMinimumQuality or {})
    serialized.expectedCraftsByQuality = CopyTable(self.expectedCraftsByQuality or {})
    serialized.expectedCraftsByMinimumQuality = CopyTable(self.expectedCraftsByMinimumQuality or {})
    serialized.expectedYieldPerCraft = self.expectedYieldPerCraft
    return serialized
end

--- Will not contain a reference to a recipeData instance
---@param serializedResultData CraftSim.ResultData.Serialized
---@return CraftSim.ResultData
function CraftSim.ResultData:Deserialize(serializedResultData)
    local deserialized = CraftSim.ResultData()
    deserialized.itemsByQuality = CraftSim.GUTIL:Map(serializedResultData.itemLinksByQuality, function(itemLink)
        return Item:CreateFromItemLink(itemLink)
    end)
    deserialized.expectedQuality = tonumber(serializedResultData.expectedQuality)
    deserialized.expectedQualityInspiration = tonumber(serializedResultData.expectedQualityInspiration)
    deserialized.expectedQualityHSV = tonumber(serializedResultData.expectedQualityHSV)
    deserialized.expectedQualityInspirationHSV = tonumber(serializedResultData.expectedQualityInspirationHSV)
    deserialized.expectedQualityUpgrade = tonumber(serializedResultData.expectedQualityUpgrade)
    deserialized.chanceUpgrade = tonumber(serializedResultData.chanceUpgrade)
    deserialized.chanceInspiration = tonumber(serializedResultData.chanceInspiration)
    deserialized.chanceHSV = tonumber(serializedResultData.chanceHSV)
    deserialized.chanceInspirationHSV = tonumber(serializedResultData.chanceInspirationHSV)
    deserialized.canUpgradeQuality = not not serializedResultData.canUpgradeQuality
    deserialized.expectedItem = (serializedResultData.expectedItemLink and deserialized.itemsByQuality[deserialized.expectedQuality]) or
        nil
    deserialized.expectedItemUpgrade = (serializedResultData.expectedItemLinkUpgrade and deserialized.itemsByQuality[deserialized.expectedQualityUpgrade]) or
        nil
    deserialized.expectedItemInspiration = (serializedResultData.expectedItemLinkInspiration and deserialized.itemsByQuality[deserialized.expectedQualityInspiration]) or
        nil
    deserialized.expectedItemHSV = (serializedResultData.expectedItemLinkHSV and deserialized.itemsByQuality[deserialized.expectedQualityHSV]) or
        nil
    deserialized.expectedItemInspirationHSV = (serializedResultData.expectedItemLinkInspirationHSV and deserialized.itemsByQuality[deserialized.expectedQualityInspirationHSV]) or
        nil
    deserialized.chanceByQuality = serializedResultData.chanceByQuality or {}
    deserialized.chancebyMinimumQuality = serializedResultData.chancebyMinimumQuality or {}
    deserialized.expectedCraftsByQuality = serializedResultData.expectedCraftsByQuality or {}
    deserialized.expectedCraftsByMinimumQuality = serializedResultData.expectedCraftsByMinimumQuality or {}
    deserialized.expectedYieldPerCraft = serializedResultData.expectedYieldPerCraft
    return deserialized
end

function CraftSim.ResultData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    local itemList = {}
    table.foreach(self.itemsByQuality, function(_, item)
        table.insert(itemList, tostring(CraftSim.GUTIL:GetItemStringFromLink(item:GetItemLink())))
    end)

    jb:AddList("itemsByQuality", itemList)
    jb:Add("expectedQuality", self.expectedQuality)
    jb:Add("expectedQualityInspiration", self.expectedQualityInspiration)
    jb:Add("expectedQualityHSV", self.expectedQualityHSV)
    jb:Add("expectedQualityInspirationHSV", self.expectedQualityInspirationHSV)
    jb:Add("expectedQualityUpgrade", self.expectedQualityUpgrade)
    jb:Add("expectedItem",
        (self.expectedItem and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItem:GetItemLink())) or nil)
    jb:Add("expectedItemUpgrade",
        (self.expectedItemUpgrade and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItemUpgrade:GetItemLink())) or
        nil)
    jb:Add("expectedItemInspiration",
        (self.expectedItemInspiration and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItemInspiration:GetItemLink())) or
        nil)
    jb:Add("expectedItemHSV",
        (self.expectedItemHSV and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItemHSV:GetItemLink())) or nil)
    jb:Add("expectedItemInspirationHSV",
        (self.expectedItemInspirationHSV and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItemInspirationHSV:GetItemLink())) or
        nil)
    jb:Add("canUpgradeQuality", self.canUpgradeQuality)
    jb:Add("canUpgradeInspiration", self.canUpgradeInspiration)
    jb:Add("canUpgradeHSV", self.canUpgradeHSV)
    jb:Add("canUpgradeInspirationHSV", self.canUpgradeInspirationHSV, true)
    jb:End()
    return jb.json
end
