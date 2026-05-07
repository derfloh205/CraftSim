---@class CraftSim
local CraftSim = select(2, ...)

local tinsert = tinsert or table.insert

--- Ordered collection of precraft conditions (same idea as CraftSim.ProfessionStats:GetStatList).
---@class CraftSim.PrecraftConditionSet : CraftSim.CraftSimObject
CraftSim.PrecraftConditionSet = CraftSim.CraftSimObject:extend()

---@param craftQueueItem? CraftSim.CraftQueueItem
function CraftSim.PrecraftConditionSet:new(craftQueueItem)
    ---@type CraftSim.CraftQueueItem?
    self.craftQueueItem = craftQueueItem
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

---@param conditionID CraftSim.PRE_CRAFT_CONDITION_IDS
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

---@param conditionIDs CraftSim.PRE_CRAFT_CONDITION_IDS[]
---@return boolean
function CraftSim.PrecraftConditionSet:AreConditionsMet(conditionIDs)
    return CraftSim.GUTIL:Every(conditionIDs, function(conditionID)
        local condition = self.conditionMap[conditionID]
        return condition and condition.isMet or false
    end)
end

---@param options CraftSim.PrecraftCondition.Options
function CraftSim.PrecraftConditionSet:AddEvaluatedCondition(options)
    local condition = CraftSim.PrecraftCondition(options)
    condition:Evaluate(self.craftQueueItem)
    self:appendStoredCondition(condition)
end

---@return boolean
function CraftSim.PrecraftConditionSet:CanClaimWorkOrder()
    local IDS = CraftSim.PRE_CRAFT_CONDITION_IDS
    return self:AreConditionsMet({
        IDS.LEARNED,
        IDS.COOLDOWN,
        IDS.REAGENTS,
        IDS.RECIPE_REQUIREMENTS,
        IDS.FORM_STATE,
    })
end

function CraftSim.PrecraftConditionSet:Evaluate()
    local craftQueueItem = self.craftQueueItem
    if not craftQueueItem then
        return
    end

    local PCC = CraftSim.PRE_CRAFT_CONDITIONS
    local IDS = CraftSim.PRE_CRAFT_CONDITION_IDS
    local PRIORITY = PCC.CONDITION_PRIORITY

    craftQueueItem.isCrafter = craftQueueItem:IsCrafter()
    craftQueueItem.learned = craftQueueItem.recipeData.learned

    craftQueueItem.pcbgData.gateId = nil
    craftQueueItem.pcbgData.needsStep = false
    craftQueueItem.pcbgData.canCast = false
    craftQueueItem.pcbgData.dueToLoginStale = false
    craftQueueItem.pcbgData.dueToMissingBuff = false
    craftQueueItem.pcbgData.recipeData = nil
    CraftSim.PRE_CRAFT_BUFF_GATE:ApplyGatesToCraftQueueItem(craftQueueItem)

    self:clearStoredConditions()

    self:AddEvaluatedCondition({
        id = IDS.IS_CRAFTER,
        priority = PRIORITY.IS_CRAFTER,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, cqi)
            condition.isMet = cqi.isCrafter
            condition.reason = condition.isMet and nil or "Alt Character"
        end,
    })

    if not craftQueueItem.isCrafter then
        craftQueueItem.craftAbleAmount = 0
        craftQueueItem.canCraftOnce = false
        craftQueueItem.recipeDisabled = false
        craftQueueItem.recipeDisabledReason = nil
        craftQueueItem.gearEquipped = false
        craftQueueItem.correctProfessionOpen = false
        craftQueueItem.notOnCooldown = true
        craftQueueItem.allowedToCraft = false
        self:BuildFailedConditionCache()
        return
    end

    craftQueueItem.recipeDisabled, craftQueueItem.recipeDisabledReason = craftQueueItem.recipeData:GetLiveDisabledState()
    local _, craftAbleAmount = craftQueueItem.recipeData:CanCraft(1)
    craftQueueItem.craftAbleAmount = craftAbleAmount
    craftQueueItem.canCraftOnce = craftAbleAmount > 0
    craftQueueItem.gearEquipped = craftQueueItem.recipeData.professionGearSet:IsEquipped() or false
    craftQueueItem.correctProfessionOpen = craftQueueItem.recipeData:IsProfessionOpen() or false
    craftQueueItem.notOnCooldown = not craftQueueItem.recipeData:OnCooldown()

    self:AddEvaluatedCondition({
        id = IDS.LEARNED,
        priority = PRIORITY.LEARNED,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, cqi)
            condition.isMet = cqi.learned
            condition.reason = condition.isMet and nil or "Not Learned"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.COOLDOWN,
        priority = PRIORITY.COOLDOWN,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, cqi)
            condition.isMet = cqi.notOnCooldown
            condition.reason = condition.isMet and nil or "On Cooldown"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.REAGENTS,
        priority = PRIORITY.REAGENTS,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, cqi)
            condition.isMet = cqi.canCraftOnce
            condition.reason = condition.isMet and nil or "Missing Reagents"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.RECIPE_REQUIREMENTS,
        priority = PRIORITY.RECIPE_REQUIREMENTS,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, cqi)
            condition.isMet = not cqi.recipeDisabled
            condition.reason = condition.isMet and nil or (cqi.recipeDisabledReason or "Missing requirement")
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.FORM_STATE,
        priority = PRIORITY.FORM_STATE,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, _)
            condition.isMet, condition.reason = PCC:GetFormStateStatus()
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.PROFESSION_OPEN,
        priority = PRIORITY.PROFESSION_OPEN,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, cqi)
            condition.isMet = cqi.correctProfessionOpen
            condition.reason = condition.isMet and nil or "Wrong Profession"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.PROFESSION_TOOLS,
        priority = PRIORITY.PROFESSION_TOOLS,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, cqi)
            condition.isMet = cqi.gearEquipped
            condition.reason = condition.isMet and nil or "Wrong Profession Tools"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.PRE_CRAFT_GATE,
        priority = PRIORITY.PRE_CRAFT_GATE,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, cqi)
            condition.isMet = not cqi.pcbgData.needsStep
            condition.reason = condition.isMet and nil or "Pre-craft action required"
        end,
    })

    self:BuildFailedConditionCache()
    craftQueueItem.allowedToCraft = CraftSim.GUTIL:Every(self:GetConditionList(), function(condition)
        return (not condition.blocksCraft) or condition.isMet
    end)
end

