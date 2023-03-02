_, CraftSim = ...
local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@class CraftSim.Reagent
CraftSim.Reagent = CraftSim.Object:extend()

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
        itemID = qualityReagentItem.item:GetItemID(),
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
            itemID = reagentItem.item:GetItemID(),
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
        table.foreach(self.items, function (_, reagentItem)
            debugLines = CraftSim.GUTIL:Concat({debugLines, reagentItem:Debug()})
        end)
    else
        debugLines = CraftSim.GUTIL:Concat({debugLines, self.items[1]:Debug()})
    end

    return debugLines
end

function CraftSim.Reagent:Clear()
    table.foreach(self.items, function (_, reagentItem)
        reagentItem:Clear()
    end)
end

function CraftSim.Reagent:HasItems()
    for _, reagentItem in pairs(self.items) do
        local hasItems = reagentItem:HasItem()
        if not hasItems then
            return false
        end
    end

    return true
end

function CraftSim.Reagent:SetCheapestQualityMax()
    if self.hasQuality then
        local itemPriceQ1 = CraftSim.PRICEDATA:GetMinBuyoutByItemID(self.items[1].item:GetItemID(), true)
        local itemPriceQ2 = CraftSim.PRICEDATA:GetMinBuyoutByItemID(self.items[2].item:GetItemID(), true)
        local itemPriceQ3 = CraftSim.PRICEDATA:GetMinBuyoutByItemID(self.items[3].item:GetItemID(), true)

        local cheapest = math.min(itemPriceQ1, itemPriceQ2, itemPriceQ3)

        self:Clear()

        if itemPriceQ1 == cheapest then
            self.items[1].quantity = self.requiredQuantity
        elseif itemPriceQ2 == cheapest then
            self.items[2].quantity = self.requiredQuantity
        elseif itemPriceQ3 == cheapest then
            self.items[3].quantity = self.requiredQuantity
        end
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
    serialized.items = CraftSim.GUTIL:Map(self.items, function (reagentItem)
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
    reagent.items = CraftSim.GUTIL:Map(serializedReagent.items, function (serializedReagentItem)
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