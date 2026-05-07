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
    ---@type table<string, CraftSim.PrecraftCondition>
    self.conditionMap = {}
    ---@type CraftSim.PrecraftCondition[]
    self.failedConditions = {}
    ---@type CraftSim.PrecraftCondition?
    self.topFailedCondition = nil
end

---@param condition CraftSim.PrecraftCondition
function CraftSim.PrecraftConditionSet:appendStoredCondition(condition)
    tinsert(self.storedConditions, condition)
    self.conditionMap[condition.id] = condition
end

function CraftSim.PrecraftConditionSet:clearStoredConditions()
    wipe(self.storedConditions)
    wipe(self.conditionMap)
    wipe(self.failedConditions)
    self.topFailedCondition = nil
end

---@return CraftSim.PrecraftCondition[]
function CraftSim.PrecraftConditionSet:GetConditionList()
    return self.storedConditions
end

---@param conditionID string
---@return CraftSim.PrecraftCondition?
function CraftSim.PrecraftConditionSet:GetCondition(conditionID)
    return self.conditionMap[conditionID]
end

function CraftSim.PrecraftConditionSet:BuildFailedConditionCache()
    self.failedConditions = CraftSim.GUTIL:Filter(self.storedConditions, function(condition)
        return not condition.isMet
    end)
    table.sort(self.failedConditions, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    self.topFailedCondition = self.failedConditions[1]
end

---@return CraftSim.PrecraftCondition[]
function CraftSim.PrecraftConditionSet:GetFailedConditions()
    return self.failedConditions
end

---@return CraftSim.PrecraftCondition?
function CraftSim.PrecraftConditionSet:GetTopFailedCondition()
    return self.topFailedCondition
end

---@param conditionIDs string[]
---@return boolean
function CraftSim.PrecraftConditionSet:AreConditionsMet(conditionIDs)
    return CraftSim.GUTIL:Every(conditionIDs, function(conditionID)
        local condition = self.conditionMap[conditionID]
        return condition and condition.isMet or false
    end)
end

