---@class CraftSim
local CraftSim = select(2, ...)

local tinsert = tinsert or table.insert

--- Ordered collection of precraft conditions (same idea as CraftSim.ProfessionStats:GetStatList).
--- Item rows use a list on CraftSim.CraftQueueItem; user-wide state uses CraftSim.PrecraftUserConditions.
---@class CraftSim.PrecraftConditionSet : CraftSim.CraftSimObject
CraftSim.PrecraftConditionSet = CraftSim.CraftSimObject:extend()

function CraftSim.PrecraftConditionSet:new()
    ---@type CraftSim.PrecraftCondition[]
    self.storedConditions = {}
end

---@param condition CraftSim.PrecraftCondition
function CraftSim.PrecraftConditionSet:appendStoredCondition(condition)
    tinsert(self.storedConditions, condition)
end

function CraftSim.PrecraftConditionSet:clearStoredConditions()
    wipe(self.storedConditions)
end

---@return CraftSim.PrecraftCondition[]
function CraftSim.PrecraftConditionSet:GetConditionList()
    return self.storedConditions
end
