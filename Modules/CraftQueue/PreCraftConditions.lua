---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.PreCraftConditions
---@field CONDITION_IDS table<string, string>
---@field CONDITION_PRIORITY table<string, number>
---@field AddEvaluatedCondition fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem, options: CraftSim.PrecraftCondition.Options)
---@field BuildFailedConditionCache fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem)
---@field AreConditionsMet fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem, conditionIDs: string[]): boolean
---@field GetConditionDebugSignature fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem): string
---@field DebugLogConditionStateIfChanged fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem)
---@field CanClaimWorkOrder fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem): boolean
---@field Evaluate fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem)
---@field MarkQueueListEvaluate fun(self: CraftSim.PreCraftConditions)
---@field InvalidateUserContext fun(self: CraftSim.PreCraftConditions)
---@field EnsureUserContextForCurrentPass fun(self: CraftSim.PreCraftConditions)
---@field userConditions CraftSim.PrecraftUserConditions
CraftSim.PRE_CRAFT_CONDITIONS = CraftSim.PRE_CRAFT_CONDITIONS or {}

---@type CraftSim.PreCraftConditions
local PCC = CraftSim.PRE_CRAFT_CONDITIONS
local Logger = CraftSim.DEBUG:RegisterLogger("CraftQueue.PreCraftConditions")

PCC.CONDITION_IDS = {
    LEARNED = "LEARNED",
    COOLDOWN = "COOLDOWN",
    IS_CRAFTER = "IS_CRAFTER",
    REAGENTS = "REAGENTS",
    RECIPE_REQUIREMENTS = "RECIPE_REQUIREMENTS",
    FORM_STATE = "FORM_STATE",
    PROFESSION_OPEN = "PROFESSION_OPEN",
    PROFESSION_TOOLS = "PROFESSION_TOOLS",
    PRE_CRAFT_GATE = "PRE_CRAFT_GATE",
}

PCC.CONDITION_PRIORITY = {
    IS_CRAFTER = 1000,
    LEARNED = 900,
    COOLDOWN = 800,
    RECIPE_REQUIREMENTS = 100,
    FORM_STATE = 95,
    REAGENTS = 90,
    PROFESSION_OPEN = 50,
    PROFESSION_TOOLS = 40,
    PRE_CRAFT_GATE = 30,
}

--- IDs whose evaluation reads CraftSim.PRE_CRAFT_CONDITIONS.userConditions (one Refresh per queue pass).
PCC.USER_CONDITION_IDS = {
    PCC.CONDITION_IDS.FORM_STATE,
}

--- Everything else is derived from the specific CraftSim.CraftQueueItem / RecipeData row.
PCC.ITEM_CONDITION_IDS = {
    PCC.CONDITION_IDS.IS_CRAFTER,
    PCC.CONDITION_IDS.LEARNED,
    PCC.CONDITION_IDS.COOLDOWN,
    PCC.CONDITION_IDS.REAGENTS,
    PCC.CONDITION_IDS.RECIPE_REQUIREMENTS,
    PCC.CONDITION_IDS.PROFESSION_OPEN,
    PCC.CONDITION_IDS.PROFESSION_TOOLS,
    PCC.CONDITION_IDS.PRE_CRAFT_GATE,
}

--- Bump at the start of a full queue list evaluation so user-scoped context refreshes once before row work.
function PCC:MarkQueueListEvaluate()
    self.queueListEvaluatePassId = (self.queueListEvaluatePassId or 0) + 1
end

--- Clears user-context signature so the next refresh re-reads player state (e.g. shapeshift).
function PCC:InvalidateUserContext()
    if self.userConditions then
        self.userConditions:GetContext():Invalidate()
    end
    self.userContextRefreshedThroughPassId = nil
end

--- Refreshes PrecraftUserConditions when the queue pass id has changed since the last refresh.
--- When no pass has been marked (nil), refresh each call; PrecraftUserContext still skips work if inputs unchanged.
function PCC:EnsureUserContextForCurrentPass()
    self.userConditions = self.userConditions or CraftSim.PrecraftUserConditions()
    local passId = self.queueListEvaluatePassId
    if passId == nil then
        self.userConditions:Refresh()
        return
    end
    if self.userContextRefreshedThroughPassId == passId then
        return
    end
    self.userConditions:Refresh()
    self.userContextRefreshedThroughPassId = passId
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@param options CraftSim.PrecraftCondition.Options
function PCC:AddEvaluatedCondition(craftQueueItem, options)
    local condition = CraftSim.PrecraftCondition(options)
    condition:Evaluate(craftQueueItem)
    craftQueueItem:AddCondition(condition)
end

---@param craftQueueItem CraftSim.CraftQueueItem
function PCC:BuildFailedConditionCache(craftQueueItem)
    craftQueueItem.failedConditions = GUTIL:Filter(craftQueueItem.conditions, function(condition)
        return not condition.isMet
    end)
    table.sort(craftQueueItem.failedConditions, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    craftQueueItem.topFailedCondition = craftQueueItem.failedConditions[1]
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@param conditionIDs string[]
---@return boolean
function PCC:AreConditionsMet(craftQueueItem, conditionIDs)
    return GUTIL:Every(conditionIDs, function(conditionID)
        local condition = craftQueueItem.conditionMap[conditionID]
        return condition and condition.isMet or false
    end)
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@return string
function PCC:GetConditionDebugSignature(craftQueueItem)
    local failed = GUTIL:Map(craftQueueItem.failedConditions, function(condition)
        return string.format("%s(%s)", tostring(condition.id), tostring(condition.reason or ""))
    end)
    return table.concat({
        tostring(craftQueueItem.allowedToCraft),
        tostring(craftQueueItem.craftAbleAmount),
        table.concat(failed, "|"),
    }, "::")
end

---@param craftQueueItem CraftSim.CraftQueueItem
function PCC:DebugLogConditionStateIfChanged(craftQueueItem)
    local signature = self:GetConditionDebugSignature(craftQueueItem)
    if craftQueueItem.lastPrecraftConditionDebugSignature == signature then
        return
    end
    craftQueueItem.lastPrecraftConditionDebugSignature = signature

    local top = craftQueueItem.topFailedCondition
    local topReason = top and (top.reason or top.id) or "none"
    local topID = top and top.id or "none"
    local msg = string.format(
        "[PrecraftCondition] %s | allowed=%s | craftAbleAmount=%s | topFail=%s (%s)",
        tostring(craftQueueItem.recipeData.recipeName),
        tostring(craftQueueItem.allowedToCraft),
        tostring(craftQueueItem.craftAbleAmount),
        tostring(topID),
        tostring(topReason)
    )
    Logger:LogDebug(msg)
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@return boolean
function PCC:CanClaimWorkOrder(craftQueueItem)
    local IDS = self.CONDITION_IDS
    return self:AreConditionsMet(craftQueueItem, {
        IDS.LEARNED,
        IDS.COOLDOWN,
        IDS.REAGENTS,
        IDS.RECIPE_REQUIREMENTS,
        IDS.FORM_STATE,
    })
end

---@param craftQueueItem CraftSim.CraftQueueItem
function PCC:Evaluate(craftQueueItem)
    local IDS = self.CONDITION_IDS
    local PRIORITY = self.CONDITION_PRIORITY

    self:EnsureUserContextForCurrentPass()

    craftQueueItem.isCrafter = craftQueueItem:IsCrafter()
    craftQueueItem.learned = craftQueueItem.recipeData.learned

    craftQueueItem.pcbgData.gateId = nil
    craftQueueItem.pcbgData.needsStep = false
    craftQueueItem.pcbgData.canCast = false
    craftQueueItem.pcbgData.dueToLoginStale = false
    craftQueueItem.pcbgData.dueToMissingBuff = false
    craftQueueItem.pcbgData.recipeData = nil
    CraftSim.PRE_CRAFT_BUFF_GATE:ApplyGatesToCraftQueueItem(craftQueueItem)

    craftQueueItem:ResetConditions()

    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.IS_CRAFTER,
        priority = PRIORITY.IS_CRAFTER,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(self, cqi)
            self.isMet = cqi.isCrafter
            self.reason = self.isMet and nil or "Alt Character"
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
        self:BuildFailedConditionCache(craftQueueItem)
        self:DebugLogConditionStateIfChanged(craftQueueItem)
        return
    end

    craftQueueItem.recipeDisabled, craftQueueItem.recipeDisabledReason = craftQueueItem.recipeData:GetLiveDisabledState()
    local _, craftAbleAmount = craftQueueItem.recipeData:CanCraft(1)
    craftQueueItem.craftAbleAmount = craftAbleAmount
    craftQueueItem.canCraftOnce = craftAbleAmount > 0
    craftQueueItem.gearEquipped = craftQueueItem.recipeData.professionGearSet:IsEquipped() or false
    craftQueueItem.correctProfessionOpen = craftQueueItem.recipeData:IsProfessionOpen() or false
    craftQueueItem.notOnCooldown = not craftQueueItem.recipeData:OnCooldown()

    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.LEARNED,
        priority = PRIORITY.LEARNED,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(self, cqi)
            self.isMet = cqi.learned
            self.reason = self.isMet and nil or "Not Learned"
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.COOLDOWN,
        priority = PRIORITY.COOLDOWN,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(self, cqi)
            self.isMet = cqi.notOnCooldown
            self.reason = self.isMet and nil or "On Cooldown"
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.REAGENTS,
        priority = PRIORITY.REAGENTS,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(self, cqi)
            self.isMet = cqi.canCraftOnce
            self.reason = self.isMet and nil or "Missing Reagents"
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.RECIPE_REQUIREMENTS,
        priority = PRIORITY.RECIPE_REQUIREMENTS,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(self, cqi)
            self.isMet = not cqi.recipeDisabled
            self.reason = self.isMet and nil or (cqi.recipeDisabledReason or "Missing requirement")
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.FORM_STATE,
        priority = PRIORITY.FORM_STATE,
        blocksCraft = true,
        blocksClaim = true,
        evaluate = function(condition, cqi)
            local ctx = CraftSim.PRE_CRAFT_CONDITIONS.userConditions:GetContext()
            condition.isMet = ctx.formConditionMet
            condition.reason = ctx.formFailureReason
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.PROFESSION_OPEN,
        priority = PRIORITY.PROFESSION_OPEN,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(self, cqi)
            self.isMet = cqi.correctProfessionOpen
            self.reason = self.isMet and nil or "Wrong Profession"
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.PROFESSION_TOOLS,
        priority = PRIORITY.PROFESSION_TOOLS,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(self, cqi)
            self.isMet = cqi.gearEquipped
            self.reason = self.isMet and nil or "Wrong Profession Tools"
        end,
    })
    self:AddEvaluatedCondition(craftQueueItem, {
        id = IDS.PRE_CRAFT_GATE,
        priority = PRIORITY.PRE_CRAFT_GATE,
        blocksCraft = true,
        blocksClaim = false,
        evaluate = function(self, cqi)
            self.isMet = not cqi.pcbgData.needsStep
            self.reason = self.isMet and nil or "Pre-craft action required"
        end,
    })

    self:BuildFailedConditionCache(craftQueueItem)
    craftQueueItem.allowedToCraft = GUTIL:Every(craftQueueItem.conditions, function(condition)
        return (not condition.blocksCraft) or condition.isMet
    end)
    self:DebugLogConditionStateIfChanged(craftQueueItem)
end
