_, CraftSim = ...

---@class CraftSim.ReagentData
---@field requiredReagents CraftSim.Reagent[]
-- TODO: possible optionals and so on
-- TODO: active optionals and so on

CraftSim.ReagentData = CraftSim.Object:extend()

function CraftSim.ReagentData:new(schematicInfo)
    self.requiredReagents = {}

    for index, reagentSlotSchematic in pairs(schematicInfo.reagentSlotSchematics) do
        local reagentType = reagentSlotSchematic.reagentType
        -- for now only consider the required reagents
        if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then

            table.insert(self.requiredReagents, CraftSim.Reagent(reagentSlotSchematic))
        
        -- elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL then
        --     currentOptionalReagent = CraftSim.DATAEXPORT:AddOptionalReagentByExportMode(reagentSlotSchematic, exportMode, recipeData.optionalReagents, reagentType, schematicReagentSlots, currentOptionalReagent)
        -- elseif reagentType == CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT then
        --     currentFinishingReagent = CraftSim.DATAEXPORT:AddOptionalReagentByExportMode(reagentSlotSchematic, exportMode, recipeData.finishingReagents, reagentType, schematicReagentSlots, currentFinishingReagent)
        end
    end
end