_, CraftSim = ...

---@class CraftSim.ReagentData
---@field recipeData CraftSim.RecipeData
---@field requiredReagents CraftSim.Reagent[]
---@field optionalReagentSlots CraftSim.OptionalReagentSlot[]
---@field finishingReagentSlots CraftSim.OptionalReagentSlot[]
---@field salvageReagentSlot CraftSim.SalvageReagentSlot

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

CraftSim.ReagentData = CraftSim.Object:extend()

function CraftSim.ReagentData:new(recipeData, schematicInfo)
    self.recipeData = recipeData
    self.requiredReagents = {}
    self.optionalReagentSlots = {}
    self.finishingReagentSlots = {}
    self.salvageReagentSlot = CraftSim.SalvageReagentSlot(self.recipeData)

    for index, reagentSlotSchematic in pairs(schematicInfo.reagentSlotSchematics) do
        local reagentType = reagentSlotSchematic.reagentType
        -- for now only consider the required reagents
        if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then

            table.insert(self.requiredReagents, CraftSim.Reagent(reagentSlotSchematic))
        
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL then
            table.insert(self.optionalReagentSlots, CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic))
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT then
            table.insert(self.finishingReagentSlots, CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic))
        end
    end
end

---@return CraftingReagentInfo[]
function CraftSim.ReagentData:GetCraftingReagentInfoTbl()
    local craftingReagentInfoTbl = {}

    -- required
    for _, reagent in pairs(self.requiredReagents) do
        local craftingReagentInfos = reagent:GetCraftingReagentInfos()
        craftingReagentInfoTbl = CraftSim.UTIL:Concat({craftingReagentInfoTbl, craftingReagentInfos})
    end

    -- optional/finishing
    for _, slot in pairs(CraftSim.UTIL:Concat({self.optionalReagentSlots, self.finishingReagentSlots})) do
        local craftingReagentInfo = slot:GetCraftingReagentInfo()
        if craftingReagentInfo then
            table.insert(craftingReagentInfoTbl, craftingReagentInfo)
        end
    end

    return craftingReagentInfoTbl
end

---@param itemID number
function CraftSim.ReagentData:SetOptionalReagent(itemID)
    for _, slot in pairs(CraftSim.UTIL:Concat({self.optionalReagentSlots, self.finishingReagentSlots})) do
        local optionalReagent = CraftSim.UTIL:Find(slot.possibleReagents, 
            function (optionalReagent) 
                return optionalReagent.item:GetItemID() == itemID 
            end)

        if optionalReagent then
            slot.activeReagent = optionalReagent
            return
        end
    end

    print("Error: recipe does not support optional reagent: " .. tostring(itemID))
end

function CraftSim.ReagentData:ClearOptionalReagents()
    for _, slot in pairs(CraftSim.UTIL:Concat({self.optionalReagentSlots, self.finishingReagentSlots})) do
        slot.activeReagent = nil
    end
end

function CraftSim.ReagentData:Debug()
    local debugLines = {}
    for _, reagent in pairs(self.requiredReagents) do
        local q1 = reagent.items[1].quantity
        local q2 = 0
        local q3 = 0
        if reagent.hasQuality then
            q1 = reagent.items[1].quantity
            q2 = reagent.items[2].quantity  
            q3 = reagent.items[3].quantity
            table.insert(debugLines, (reagent.items[1].item:GetItemLink() or reagent.items[1].item:GetItemID()) .. " " .. q1 .. " | " .. q2 .. " | " .. q3 .. " / " .. reagent.requiredQuantity)
        else
            table.insert(debugLines, (reagent.items[1].item:GetItemLink() or reagent.items[1].item:GetItemID()) .. " " .. q1 .. " / " .. reagent.requiredQuantity)
        end
    end

    table.insert(debugLines, "Optional Reagent Slots: " .. tostring(#self.optionalReagentSlots))
    for i, slot in pairs(self.optionalReagentSlots) do
        debugLines = CraftSim.UTIL:Concat({debugLines, slot:Debug()})
    end
    table.insert(debugLines, "Finishing Reagent Slots: ".. tostring(#self.finishingReagentSlots))
    for i, slot in pairs(self.finishingReagentSlots) do
        debugLines = CraftSim.UTIL:Concat({debugLines, slot:Debug()})
    end

    return debugLines
end