---@class CraftSim
local CraftSim = select(2, ...)
local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.Reagent")

local GUTIL = CraftSim.GUTIL

---@class CraftSim.Reagent : CraftSim.CraftSimObject
CraftSim.Reagent = CraftSim.CraftSimObject:extend()

---@param reagentSlotSchematic CraftingReagentSlotSchematic
function CraftSim.Reagent:new(reagentSlotSchematic)
    if not reagentSlotSchematic then
        return
    end
    self.requiredQuantity = reagentSlotSchematic.quantityRequired
    self.dataSlotIndex = reagentSlotSchematic.dataSlotIndex

    if #reagentSlotSchematic.reagents > 1 then
        self.hasQuality = true
    end

    ---@type CraftSim.ReagentItem[]
    self.items = {}
    for qualityID, itemInfo in pairs(reagentSlotSchematic.reagents) do
        local reagentItem = CraftSim.ReagentItem(itemInfo.itemID, qualityID)
        table.insert(self.items, reagentItem)
    end
end

---@param qualityID number
---@param maxQuantity? boolean
---@param customQuantity? number
---@return CraftingReagentInfo?
function CraftSim.Reagent:GetCraftingReagentInfoByQuality(qualityID, maxQuantity, customQuantity)
    maxQuantity = maxQuantity or false

    if not self.hasQuality then
        return nil
    end

    local qualityReagentItem = CraftSim.GUTIL:Find(self.items, function(i) return i.qualityID == qualityID end)

    if not qualityReagentItem then
        return nil
    end

    local quantity = qualityReagentItem.quantity

    if maxQuantity then
        quantity = self.requiredQuantity
    elseif customQuantity then
        quantity = math.min(customQuantity, self.requiredQuantity)
    end

    return {
        reagent = {
            itemID = qualityReagentItem.item:GetItemID(),
            currencyID = qualityReagentItem.currencyID,
        },
        quantity = quantity,
        dataSlotIndex = self.dataSlotIndex
    }
end

---@return CraftingReagentInfo[]
function CraftSim.Reagent:GetCraftingReagentInfos()
    local craftingReagentInfos = {}

    if not self.hasQuality then
        return {} -- if we would add such reagents to an operationInfo call, it will return nil..
    end
    for _, reagentItem in pairs(self.items) do
        table.insert(craftingReagentInfos, {
            reagent = {
                itemID = reagentItem.item:GetItemID(),
                currencyID = reagentItem.currencyID,
            },
            quantity = reagentItem.quantity,
            dataSlotIndex = self.dataSlotIndex
        })
    end

    return craftingReagentInfos
end

---@return CraftSim.ReagentListItem[]
function CraftSim.Reagent:GetReagentItemList()
    local reagentItemList = {}
    for _, item in pairs(self.items) do
        table.insert(reagentItemList, item:GetAsReagentListItem())
    end

    return reagentItemList
end

---@return CraftSim.Reagent
function CraftSim.Reagent:Copy()
    local copy = CraftSim.Reagent()

    copy.hasQuality = self.hasQuality
    copy.requiredQuantity = self.requiredQuantity
    copy.dataSlotIndex = self.dataSlotIndex

    copy.items = CraftSim.GUTIL:Map(self.items, function(i) return i:Copy() end)

    return copy
end

function CraftSim.Reagent:Debug()
    local debugLines = {
        "hasQuality: " .. tostring(self.hasQuality),
        "requiredQuantity: " .. tostring(self.requiredQuantity),
        "dataSlotIndex: " .. tostring(self.dataSlotIndex),
    }

    if self.hasQuality then
        for _, reagentItem in ipairs(self.items) do
            debugLines = CraftSim.GUTIL:Concat({ debugLines, reagentItem:Debug() })
        end
    else
        debugLines = CraftSim.GUTIL:Concat({ debugLines, self.items[1]:Debug() })
    end

    return debugLines
end

function CraftSim.Reagent:Clear()
    for _, reagentItem in pairs(self.items) do
        reagentItem:Clear()
    end
end

--- returns the total quantity of all qualities
---@return number totalQuantity
function CraftSim.Reagent:GetTotalQuantity()
    local total = 0
    for _, reagentItem in pairs(self.items) do
        total = total + reagentItem.quantity
    end
    return total
end

--- returns wether the player has enough of the given required item's allocations (times the multiplier)
---@param multiplier number? default: 1
---@param crafterUID CrafterUID?
function CraftSim.Reagent:HasItems(multiplier, crafterUID)
    multiplier = multiplier or 1

    -- check if the player owns enough of each allocated items's quantity and sum up the allocated quantities
    local totalQuantity = 0
    for _, reagentItem in pairs(self.items) do
        local hasItems = reagentItem:HasItem(multiplier, crafterUID)
        totalQuantity = totalQuantity + reagentItem.quantity
        if not hasItems then
            return false
        end
    end

    -- check if the allocated quantity is enough to satisfy the required quantity (times multiplier)
    totalQuantity = totalQuantity * multiplier
    local requiredQuantity = self.requiredQuantity * multiplier
    local hasRequiredTotalQuantity = totalQuantity >= requiredQuantity

    return hasRequiredTotalQuantity
end

--- check how many times the player can fulfill the allocated item quantity
---@param crafterUID CrafterUID
function CraftSim.Reagent:HasQuantityXTimes(crafterUID)
    local currentMinTimes = math.huge

    local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ReagentData.Reagent.HasQuantityXTimes")
    for q, reagentItem in pairs(self.items) do
        if reagentItem.quantity > 0 then
            -- use original item if available
            local itemID = (reagentItem.originalItem and reagentItem.originalItem:GetItemID()) or
                reagentItem.item:GetItemID()
            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
            local itemFitCount = math.floor(itemCount / reagentItem.quantity)
            currentMinTimes = math.min(itemFitCount, currentMinTimes)
        end
    end

    return currentMinTimes
end

---@param considerSubCrafts boolean?
function CraftSim.Reagent:SetCheapestQualityMax(considerSubCrafts)
    if self.hasQuality then
        local itemPrices = {}
        local cheapestQuality = 1
        local cheapest = math.huge
        for i = 1, 3 do
            if self.items[i] then
                itemPrices[i] = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(self.items[i].item:GetItemID(), true, false,
                    considerSubCrafts)
                if itemPrices[i] < cheapest then
                    cheapest = itemPrices[i]
                    cheapestQuality = i
                end
            end
        end


        self:Clear()

        self.items[cheapestQuality].quantity = self.requiredQuantity
    else
        self.items[1].quantity = self.requiredQuantity
    end
end

---@class CraftSim.Reagent.Serialized
---@field hasQuality boolean
---@field requiredQuantity number
---@field dataSlotIndex number
---@field items CraftSim.ReagentItem.Serialized[]

function CraftSim.Reagent:Serialize()
    local serialized = {}
    serialized.hasQuality = self.hasQuality
    serialized.requiredQuantity = self.requiredQuantity
    serialized.dataSlotIndex = self.dataSlotIndex
    serialized.items = CraftSim.GUTIL:Map(self.items, function(reagentItem)
        return reagentItem:Serialize()
    end)
    return serialized
end

---STATIC: Deserializes a serialized reagent into a reagent
---@param serializedReagent CraftSim.Reagent.Serialized
---@return CraftSim.Reagent
function CraftSim.Reagent:Deserialize(serializedReagent)
    local reagent = CraftSim.Reagent()
    reagent.hasQuality = not not serializedReagent.hasQuality
    reagent.requiredQuantity = tonumber(serializedReagent.requiredQuantity)
    reagent.dataSlotIndex = tonumber(serializedReagent.dataSlotIndex)
    reagent.items = CraftSim.GUTIL:Map(serializedReagent.items, function(serializedReagentItem)
        return CraftSim.ReagentItem:Deserialize(serializedReagentItem)
    end)
    return reagent
end

function CraftSim.Reagent:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("hasQuality", self.hasQuality)
    jb:Add("requiredQuantity", self.requiredQuantity)
    jb:Add("dataSlotIndex", self.dataSlotIndex)
    jb:AddList("items", self.items, true)
    jb:End()
    return jb.json
end

---@param recipeData CraftSim.RecipeData
---@return boolean
function CraftSim.Reagent:IsOrderReagentIn(recipeData)
    if not recipeData.orderData then return false end

    local orderItemIDs = GUTIL:Map(recipeData.orderData.reagents or {}, function(reagentInfo)
        return CraftSim.RecipeData.GetItemIDFromReagentInfo(reagentInfo, recipeData)
    end)

    local isOrderReagent = GUTIL:Some(self.items, function(reagentItem)
        return tContains(orderItemIDs, reagentItem.item:GetItemID())
    end)

    return isOrderReagent
end
