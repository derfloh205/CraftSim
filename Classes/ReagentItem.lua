---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.ReagentItem : CraftSim.CraftSimObject
CraftSim.ReagentItem = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ReagentData.Reagent.ReagentItem")

---@param originalItemID ItemID
---@param qualityID QualityID?
function CraftSim.ReagentItem:new(originalItemID, qualityID)
    -- consider possible exception mappings
    local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[originalItemID]
    local itemID = alternativeItemID or originalItemID

    self.qualityID = qualityID
    --- how much of that reagentItem has been allocated for this recipe
    self.quantity = 0
    self.item = Item:CreateFromItemID(itemID)
    if alternativeItemID then
        self.originalItem = Item:CreateFromItemID(originalItemID)
    end
end

---@return CraftSim.ReagentListItem
function CraftSim.ReagentItem:GetAsReagentListItem()
    return {
        itemID = self.item:GetItemID(),
        quantity = self.quantity,
    }
end

function CraftSim.ReagentItem:Copy()
    local copy = nil
    if self.originalItem then
        copy = CraftSim.ReagentItem(self.originalItem:GetItemID(), self.qualityID)
    else
        copy = CraftSim.ReagentItem(self.item:GetItemID(), self.qualityID)
    end
    copy.quantity = self.quantity

    return copy
end

function CraftSim.ReagentItem:Debug()
    return {
        tostring(((self.item and (self.item:GetItemLink() or self.item:GetItemID())) or "None") .. " x " .. self
            .quantity),
    }
end

function CraftSim.ReagentItem:Clear()
    self.quantity = 0
end

--- returns wether the player has enough of the given required item's allocations (times the multiplier) for crafting
---@param multiplier number? default: 1
---@param crafterUID string
function CraftSim.ReagentItem:HasItem(multiplier, crafterUID)
    multiplier = multiplier or 1
    if not self.item then
        return false
    end
    -- only count the item actually used in the recipe (originalItem if we have one)
    -- in the case of e.g. rimefin tuna we want to count the non frosted one only (will be the original)
    local itemID = (self.originalItem and self.originalItem:GetItemID()) or self.item:GetItemID()
    local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
    return itemCount >= (self.quantity * multiplier)
end

---@class CraftSim.ReagentItem.Serialized
---@field qualityID number
---@field quantity number
---@field itemID number
---@field originalItemID number

function CraftSim.ReagentItem:Serialize()
    local serizalized = {}
    serizalized.qualityID = self.qualityID
    serizalized.quantity = self.quantity
    serizalized.itemID = self.item:GetItemID()
    serizalized.originalItemID = self.originalItem and self.originalItem:GetItemID()
    return serizalized
end

--- STATIC
---@param serializedReagentItem CraftSim.ReagentItem.Serialized
function CraftSim.ReagentItem:Deserialize(serializedReagentItem)
    local deserialized = CraftSim.ReagentItem(tonumber(serializedReagentItem.itemID),
        tonumber(serializedReagentItem.qualityID))
    deserialized.quantity = tonumber(serializedReagentItem.quantity)
    return deserialized
end

function CraftSim.ReagentItem:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("itemID", self.item:GetItemID(), true)
    jb:End()
    return jb.json
end

---@param recipeData CraftSim.RecipeData
---@return boolean
function CraftSim.ReagentItem:IsOrderReagentIn(recipeData)
    if not recipeData.orderData then return false end

    local orderItemIDs = GUTIL:Map(recipeData.orderData.reagents or {}, function(reagentInfo)
        return reagentInfo.reagent.itemID
    end)

    return tContains(orderItemIDs, self.item:GetItemID())
end

---@deprecated
---@param recipeData CraftSim.RecipeData
function CraftSim.ReagentItem:GetSkillContributionPerItem(recipeData)
    if self.qualityID <= 1 then
        return 0
    end

    local reagentWeight = CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(self.item:GetItemID())
    local weightList = {}
    for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
        if reagent.hasQuality then
            tinsert(weightList, CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(reagent.items[1].item:GetItemID()))
        end
    end

    local weightGCD = GUTIL:Fold(weightList, 0, function(a, b)
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    end)

    if weightGCD == 0 then
        weightGCD = 1
    end

    local relativeWeight = reagentWeight / weightGCD

    local reagentSkillContributionFactor = relativeWeight * (self.qualityID - 1)

    local skillContribution = recipeData.reagentsMaxSkillContribution * reagentSkillContributionFactor

    -- quality contribution Q1 = 0
    -- quality contribution Q2 = relative weight
    -- quality contribution Q3 = relative weight * 2

    return skillContribution
end
