_, CraftSim = ...

---@class CraftSim.Reagent
---@field hasQuality boolean
---@field requiredQuantity number
---@field dataSlotIndex number
---@field items CraftSim.ReagentItem[]

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

CraftSim.Reagent = CraftSim.Object:extend()

function CraftSim.Reagent:new(reagentSlotSchematic)
    if not reagentSlotSchematic then
        return
    end
    self.requiredQuantity = reagentSlotSchematic.quantityRequired
    self.dataSlotIndex = reagentSlotSchematic.dataSlotIndex

    if #reagentSlotSchematic.reagents > 1 then
        self.hasQuality = true
    end

    self.items = {}
    for qualityID, itemInfo in pairs(reagentSlotSchematic.reagents) do
        local reagentItem = CraftSim.ReagentItem(itemInfo.itemID, qualityID)
        table.insert(self.items, reagentItem)
    end
end

---@param qualityID number
---@param maxQuantity? boolean
---@param customQuantity? number
---@return CraftingReagentInfo
function CraftSim.Reagent:GetCraftingReagentInfoByQuality(qualityID, maxQuantity, customQuantity)
    maxQuantity = maxQuantity or false

    local qualityReagentItem = CraftSim.UTIL:Find(self.items, function(i) return i.qualityID == qualityID end)

    if not qualityReagentItem then
        return {}
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

function CraftSim.Reagent:Copy()
    local copy = CraftSim.Reagent()

    copy.hasQuality = self.hasQuality
    copy.requiredQuantity = self.requiredQuantity
    copy.dataSlotIndex = self.dataSlotIndex

    copy.items = CraftSim.UTIL:Map(self.items, function(i) return i:Copy() end)

    return copy
end
