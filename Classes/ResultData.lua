---@class CraftSim
local CraftSim = select(2, ...)


local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ResultData")

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

    self.expectedQuality = 1
    self.expectedQualityConcentration = 1

    ---@type ItemMixin?
    self.expectedItem = nil

    ---@type ItemMixin?
    self.expectedItemConcentration = nil

    --- Considering Multicraft and Multicraft Extra Item Bonus
    ---@type number
    self.expectedYieldPerCraft = 0

    self:UpdatePossibleResultItems()
end

--- Updates based on reagentData
function CraftSim.ResultData:UpdatePossibleResultItems()
    local recipeData = self.recipeData

    self.itemsByQuality = {}
    local craftingReagentInfoTbl = recipeData.reagentData:GetCraftingReagentInfoTbl()


    if recipeData.isEnchantingRecipe and recipeData.baseOperationInfo then
        local craftingDataID = self.recipeData.baseOperationInfo.craftingDataID
        if not CraftSim.ENCHANT_RECIPE_DATA[craftingDataID] then
            print("CraftSim: Enchant Recipe Missing in Data: " .. recipeData.recipeID .. "/" .. craftingDataID)
            return
        end
        local itemIDs = {
            CraftSim.ENCHANT_RECIPE_DATA[craftingDataID].q1,
            CraftSim.ENCHANT_RECIPE_DATA[craftingDataID].q2,
            CraftSim.ENCHANT_RECIPE_DATA[craftingDataID].q3,
        }

        for _, itemID in pairs(itemIDs) do
            table.insert(self.itemsByQuality, Item:CreateFromItemID(itemID))
        end
        -- only for quality supporting gear, non quality gear would be the toylike Scepter of Spectacle: Air for example
    elseif recipeData.isGear and recipeData.supportsQualities then
        local itemLinks = CraftSim.UTIL:GetDifferentQualitiesByCraftingReagentTbl(recipeData.recipeID,
            craftingReagentInfoTbl, recipeData.allocationItemGUID, recipeData.maxQuality)

        for _, itemLink in pairs(itemLinks) do
            table.insert(self.itemsByQuality, Item:CreateFromItemLink(itemLink))
        end
    else
        print("fetching quality ids itemids:", false, true)
        local itemIDs = CraftSim.UTIL:GetDifferentQualityIDsByCraftingReagentTbl(recipeData.recipeID,
            craftingReagentInfoTbl, recipeData.allocationItemGUID)
        for _, itemID in pairs(itemIDs) do
            print("itemID: " .. itemID)
            table.insert(self.itemsByQuality, Item:CreateFromItemID(itemID))
        end
    end

    if self.itemsByQuality[1] and self.itemsByQuality[2] and not recipeData.supportsQualities then
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

--- Returns true if either the given quality or any higher quality than it is craftable
---@param qualityID any
---@return boolean craftable
---@return boolean concentrationOnly reachable only with concentration
function CraftSim.ResultData:IsMinimumQualityReachable(qualityID)
    if not self.recipeData.supportsQualities then
        return true, false
    end

    local reachable = qualityID <= self.expectedQualityConcentration
    local concentrationOnly = self.expectedQuality < self.expectedQualityConcentration and
        qualityID == self.expectedQualityConcentration

    return reachable, concentrationOnly
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

    self.expectedYieldPerCraft = self.recipeData.baseItemAmount +
        (select(2, CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)) * professionStats.multicraft:GetPercent(true))

    -- special case for no quality results. Needed for expectedCrafts and such
    if not recipeData.supportsQualities then
        self.expectedQuality = 1
        self.expectedQualityConcentration = 1
        self.expectedItem = self.itemsByQuality[1]
        self.expectedItemConcentration = self.expectedItem
        return
    end

    self.expectedQuality = expectedQualityBySkill(professionStats.skill.value, recipeData.maxQuality,
        professionStats.recipeDifficulty.value)

    --- if crafter is concentrating the quality is upped by one or max
    self.expectedQualityConcentration = math.min(self.expectedQuality + 1, recipeData.maxQuality)
    if recipeData.concentrating then
        self.expectedQuality = self.expectedQualityConcentration
    end

    self.expectedItem = self.itemsByQuality[self.expectedQuality]
    self.expectedItemConcentration = self.itemsByQuality[self.expectedQualityConcentration]
end

--- returns the expected number of crafts to craft a given amount of items
---@param amount number how many items of the given quality
---@return number expectedCrafts for given yield for given quality
function CraftSim.ResultData:GetExpectedCraftsForYield(amount)
    if self.expectedYieldPerCraft > 0 then
        return amount / self.expectedYieldPerCraft
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
            "expectedQualityConcentration: " .. tostring(self.expectedQualityConcentration),
            "expectedItem: " .. tostring(self.expectedItem and self.expectedItem:GetItemLink()),
            "expectedItemConcentration: " ..
            tostring(self.expectedItemConcentration and self.expectedItemConcentration:GetItemLink()),
            "expectedItemConcentration: " ..
            tostring(self.expectedItemConcentration and self.expectedItemConcentration:GetItemLink()),
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
---@field expectedQualityConcentration number
---@field expectedItemLink? string
---@field expectedItemLinkConcentration? string
---@field expectedYieldPerCraft number

--- Make sure that the items are loaded before serializing or the links are empty
function CraftSim.ResultData:Serialize()
    local serialized = {}
    serialized.itemLinksByQuality = CraftSim.GUTIL:Map(self.itemsByQuality, function(item)
        return item:GetItemLink()
    end)
    serialized.expectedQuality = self.expectedQuality
    serialized.expectedQualityConcentration = self.expectedQualityConcentration
    serialized.expectedItemLink = (self.expectedItem and self.expectedItem:GetItemLink()) or nil
    serialized.expectedItemLinkConcentration = (self.expectedItemConcentration and self.expectedItemConcentration:GetItemLink()) or
        nil

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
    deserialized.expectedQualityConcentration = tonumber(serializedResultData.expectedQualityConcentration)
    deserialized.expectedItem = (serializedResultData.expectedItemLink and deserialized.itemsByQuality[deserialized.expectedQuality]) or
        nil
    deserialized.expectedItemConcentration = (serializedResultData.expectedItemLinkConcentration and deserialized.itemsByQuality[deserialized.expectedQualityConcentration]) or
        nil
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
    jb:Add("expectedQualityConcentration", self.expectedQualityConcentration)
    jb:Add("expectedItem",
        (self.expectedItem and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItem:GetItemLink())) or nil)
    jb:Add("expectedItemConcentration",
        (self.expectedItemConcentration and CraftSim.GUTIL:GetItemStringFromLink(self.expectedItemConcentration:GetItemLink())) or
        nil)
    jb:End()
    return jb.json
end
