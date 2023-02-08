_, CraftSim = ...

---@class CraftSim.Reagent
---@field hasQuality boolean
---@field requiredQuantity number
---@field dataSlotIndex number
---@field items CraftSim.ReagentItem[]

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

CraftSim.Reagent = CraftSim.Object:extend()

function CraftSim.Reagent:new(reagentSlotSchematic)
    self.requiredQuantity = reagentSlotSchematic.quantityRequired
    self.dataSlotIndex = reagentSlotSchematic.dataSlotIndex

    if #reagentSlotSchematic.reagents > 1 then
        self.hasQuality = true
    end

    self.items = {}
    for _, itemInfo in pairs(reagentSlotSchematic.reagents) do
        local reagentItem = CraftSim.ReagentItem(itemInfo.itemID)
        table.insert(self.items, reagentItem)
    end
end
