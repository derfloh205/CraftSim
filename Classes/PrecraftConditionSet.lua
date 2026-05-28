---@class CraftSim
local CraftSim = select(2, ...)

local tinsert = tinsert or table.insert

--- Snapshot of recipe/craftability inputs written during `Evaluate` and read by conditions and UI.
---@class CraftSim.PrecraftConditionSet.EvalContext
---@field learned boolean
---@field notOnCooldown boolean
---@field canCraftOnce boolean
---@field recipeDisabled boolean
---@field recipeDisabledReason string?
---@field gearEquipped boolean
---@field correctProfessionOpen boolean
---@field craftAbleAmount number

---@param ev CraftSim.PrecraftConditionSet.EvalContext
local function resetEvalContext(ev)
    ev.learned = false
    ev.notOnCooldown = true
    ev.canCraftOnce = false
    ev.recipeDisabled = false
    ev.recipeDisabledReason = nil
    ev.gearEquipped = false
    ev.correctProfessionOpen = false
    ev.craftAbleAmount = 0
end

--- Ordered collection of precraft conditions (same idea as CraftSim.ProfessionStats:GetStatList).
---@class CraftSim.PrecraftConditionSet : CraftSim.CraftSimObject
---@field evalContext CraftSim.PrecraftConditionSet.EvalContext
---@field allowedToCraft boolean
CraftSim.PrecraftConditionSet = CraftSim.CraftSimObject:extend()

---@param craftQueueItem? CraftSim.CraftQueueItem
function CraftSim.PrecraftConditionSet:new(craftQueueItem)
    ---@type CraftSim.CraftQueueItem?
    self.craftQueueItem = craftQueueItem
    ---@type CraftSim.PrecraftCondition[]
    self.conditions = {}
    ---@type table<string, CraftSim.PrecraftCondition>
    self.conditionMap = {}
    ---@type CraftSim.PrecraftCondition?
    self.topFailedCondition = nil
    ---@type CraftSim.PrecraftConditionSet.EvalContext
    self.evalContext = {}
    resetEvalContext(self.evalContext)
    self.allowedToCraft = false
end

---@return CraftSim.PrecraftConditionSet.EvalContext
function CraftSim.PrecraftConditionSet:GetEvalContext()
    return self.evalContext
end

function CraftSim.PrecraftConditionSet:GetCraftAbleAmount()
    return self.evalContext.craftAbleAmount
end

function CraftSim.PrecraftConditionSet:IsLearned()
    return self.evalContext.learned
end

--- True when `CanCraft(1)` yields quantity > 0 (reagents OK for at least one craft).
function CraftSim.PrecraftConditionSet:HasReagentsForOneCraft()
    return self.evalContext.canCraftOnce
end

function CraftSim.PrecraftConditionSet:IsProfessionGearEquipped()
    return self.evalContext.gearEquipped
end

function CraftSim.PrecraftConditionSet:IsCorrectProfessionOpen()
    return self.evalContext.correctProfessionOpen
end

function CraftSim.PrecraftConditionSet:IsNotOnCooldown()
    return self.evalContext.notOnCooldown
end

function CraftSim.PrecraftConditionSet:IsRecipeDisabled()
    return self.evalContext.recipeDisabled
end

---@return string?
function CraftSim.PrecraftConditionSet:GetRecipeDisabledReason()
    return self.evalContext.recipeDisabledReason
end

function CraftSim.PrecraftConditionSet:IsAllowedToCraft()
    return self.allowedToCraft
end

---@return number
function CraftSim.PrecraftConditionSet:GetQueueActionRank()
    local IDS = CraftSim.PRE_CRAFT_CONDITION_IDS
    local cqi = self.craftQueueItem

    if self:IsAllowedToCraft() then
        return 1
    end

    if not cqi or not cqi:IsCrafter() or not self:IsCorrectProfessionOpen() then
        return 4
    end

    local failedConditions = self:GetFailedConditions()
    if #failedConditions ~= 1 then
        return 4
    end

    local topFailed = failedConditions[1]
    if topFailed.id == IDS.PROFESSION_TOOLS and not self:IsProfessionGearEquipped() then
        return 2
    end

    if topFailed.id == IDS.PRE_CRAFT_ACTION then
        local pcbgData = cqi.pcbgData
        if pcbgData and pcbgData.needsStep and pcbgData.canCast and pcbgData.recipeData then
            return 3
        end
    end

    return 4
end

---@param condition CraftSim.PrecraftCondition
function CraftSim.PrecraftConditionSet:appendCondition(condition)
    tinsert(self.conditions, condition)
    self.conditionMap[condition.id] = condition
end

function CraftSim.PrecraftConditionSet:clearConditions()
    wipe(self.conditions)
    wipe(self.conditionMap)
    self.topFailedCondition = nil
end

---@return CraftSim.PrecraftCondition[]
function CraftSim.PrecraftConditionSet:GetConditions()
    return self.conditions
end

---@param conditionID CraftSim.PRE_CRAFT_CONDITION_IDS
---@return CraftSim.PrecraftCondition?
function CraftSim.PrecraftConditionSet:GetCondition(conditionID)
    return self.conditionMap[conditionID]
end

function CraftSim.PrecraftConditionSet:BuildFailedConditionCache()
    local top, topPri = nil, nil
    for _, condition in ipairs(self.conditions) do
        if not condition.isMet then
            local p = condition.priority or 0
            if not topPri or p > topPri then
                topPri = p
                top = condition
            end
        end
    end
    self.topFailedCondition = top
end

---@return CraftSim.PrecraftCondition[]
function CraftSim.PrecraftConditionSet:GetFailedConditions()
    local failed = CraftSim.GUTIL:Filter(self.conditions, function(condition)
        return not condition.isMet
    end)
    table.sort(failed, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    return failed
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
    self:appendCondition(condition)
end

---@return boolean
function CraftSim.PrecraftConditionSet:CanClaimWorkOrder()
    local IDS = CraftSim.PRE_CRAFT_CONDITION_IDS
    return self:AreConditionsMet({
        IDS.LEARNED,
        IDS.COOLDOWN,
        IDS.REAGENTS,
        IDS.RECIPE_REQUIREMENTS,
        IDS.WORK_ORDER_MIN_QUALITY,
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
    local ev = self.evalContext

    ev.learned = craftQueueItem.recipeData.learned

    craftQueueItem.pcbgData.gateId = nil
    craftQueueItem.pcbgData.needsStep = false
    craftQueueItem.pcbgData.canCast = false
    craftQueueItem.pcbgData.dueToLoginStale = false
    craftQueueItem.pcbgData.dueToMissingBuff = false
    craftQueueItem.pcbgData.recipeData = nil
    CraftSim.PRE_CRAFT_BUFF_GATE:ApplyGatesToCraftQueueItem(craftQueueItem)

    self:clearConditions()

    self:AddEvaluatedCondition({
        id = IDS.IS_CRAFTER,
        priority = PRIORITY.IS_CRAFTER,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, cqi)
            condition.isMet = cqi:IsCrafter()
            condition.reason = condition.isMet and nil or "Alt Character"
        end,
    })

    if not craftQueueItem:IsCrafter() then
        ev.craftAbleAmount = 0
        ev.canCraftOnce = false
        ev.recipeDisabled = false
        ev.recipeDisabledReason = nil
        ev.gearEquipped = false
        ev.correctProfessionOpen = false
        ev.notOnCooldown = true
        self.allowedToCraft = false
        self:BuildFailedConditionCache()
        return
    end

    ev.recipeDisabled, ev.recipeDisabledReason = craftQueueItem.recipeData:GetTradeSkillDisabledRecipeState()
    local _, craftAbleAmount = craftQueueItem.recipeData:CanCraft(1)
    ev.craftAbleAmount = craftAbleAmount
    ev.canCraftOnce = craftAbleAmount > 0
    ev.gearEquipped = craftQueueItem.recipeData.professionGearSet:IsEquipped() or false
    ev.correctProfessionOpen = craftQueueItem.recipeData:IsProfessionOpen() or false
    ev.notOnCooldown = not craftQueueItem.recipeData:OnCooldown()

    self:AddEvaluatedCondition({
        id = IDS.LEARNED,
        priority = PRIORITY.LEARNED,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, _)
            condition.isMet = ev.learned
            condition.reason = condition.isMet and nil or "Not Learned"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.COOLDOWN,
        priority = PRIORITY.COOLDOWN,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, _)
            condition.isMet = ev.notOnCooldown
            condition.reason = condition.isMet and nil or "On Cooldown"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.REAGENTS,
        priority = PRIORITY.REAGENTS,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, _)
            condition.isMet = ev.canCraftOnce
            condition.reason = condition.isMet and nil or "Missing Reagents"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.RECIPE_REQUIREMENTS,
        priority = PRIORITY.RECIPE_REQUIREMENTS,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, _)
            condition.isMet = not ev.recipeDisabled
            condition.reason = condition.isMet and nil or (ev.recipeDisabledReason or "Missing requirement")
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.WORK_ORDER_MIN_QUALITY,
        priority = PRIORITY.WORK_ORDER_MIN_QUALITY,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, cqi)
            local orderData = cqi.recipeData.orderData
            if not orderData or not orderData.minQuality then
                condition.isMet = true
                condition.reason = nil
            else
                condition.isMet = cqi.recipeData.resultData.expectedQuality >= orderData.minQuality
                condition.reason = condition.isMet and nil or "Below minimum quality"
            end
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.PROFESSION_OPEN,
        priority = PRIORITY.PROFESSION_OPEN,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, _)
            condition.isMet = ev.correctProfessionOpen
            condition.reason = condition.isMet and nil or "Wrong Profession"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.PROFESSION_TOOLS,
        priority = PRIORITY.PROFESSION_TOOLS,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, _)
            condition.isMet = ev.gearEquipped
            condition.reason = condition.isMet and nil or "Wrong Profession Tools"
        end,
    })
    self:AddEvaluatedCondition({
        id = IDS.PRE_CRAFT_ACTION,
        priority = PRIORITY.PRE_CRAFT_ACTION,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(condition, cqi)
            condition.isMet = not cqi.pcbgData.needsStep
            condition.reason = condition.isMet and nil or "Pre-craft action required"
        end,
    })

    self:BuildFailedConditionCache()
    self.allowedToCraft = CraftSim.GUTIL:Every(self:GetConditions(), function(condition)
        return (not condition.blocksCraft) or condition.isMet
    end)
end
