---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.PrecraftCondition
---@field id string
---@field priority number
---@field isMet boolean
---@field reason string?
---@field blocksCraft boolean
---@field blocksClaim boolean

---@class CraftSim.PreCraftConditions
---@field CONDITION_IDS table<string, string>
---@field CONDITION_PRIORITY table<string, number>
---@field AddCondition fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem, condition: CraftSim.PrecraftCondition)
---@field BuildFailedConditionCache fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem)
---@field AreConditionsMet fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem, conditionIDs: string[]): boolean
---@field GetConditionDebugSignature fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem): string
---@field DebugLogConditionStateIfChanged fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem)
---@field CanClaimWorkOrder fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem): boolean
---@field Evaluate fun(self: CraftSim.PreCraftConditions, craftQueueItem: CraftSim.CraftQueueItem)
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

---@param craftQueueItem CraftSim.CraftQueueItem
---@param condition CraftSim.PrecraftCondition
function PCC:AddCondition(craftQueueItem, condition)
    tinsert(craftQueueItem.conditions, condition)
    craftQueueItem.conditionMap[condition.id] = condition
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
    if craftQueueItem._lastConditionDebugSignature == signature then
        return
    end
    craftQueueItem._lastConditionDebugSignature = signature

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
    self:AddCondition(craftQueueItem, {
        id = IDS.IS_CRAFTER,
        priority = PRIORITY.IS_CRAFTER,
        isMet = craftQueueItem.isCrafter,
        reason = "Alt Character",
        blocksCraft = true,
        blocksClaim = false,
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

    -- Shapeshift gating only applies to Druids. Calling GetShapeshiftForm can behave oddly
    -- for other classes, so short-circuit early.
    local crafterClass = craftQueueItem.crafterData and craftQueueItem.crafterData.class
    local isDruid = crafterClass == "DRUID"
    local formConditionMet = true
    local formReason = rawget(_G, "ERR_CANT_DO_THAT_WHILE_SHAPESHIFTED") or "Must be in normal form"
    if isDruid and GetShapeshiftForm then
        -- In normal form GetShapeshiftForm() returns 0.
        local formID = GetShapeshiftForm()
        formConditionMet = formID == 0
    else
        formReason = "Not a Druid"
    end

    self:AddCondition(craftQueueItem, {
        id = IDS.LEARNED,
        priority = PRIORITY.LEARNED,
        isMet = craftQueueItem.learned,
        reason = "Not Learned",
        blocksCraft = true,
        blocksClaim = true,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.COOLDOWN,
        priority = PRIORITY.COOLDOWN,
        isMet = craftQueueItem.notOnCooldown,
        reason = "On Cooldown",
        blocksCraft = true,
        blocksClaim = true,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.REAGENTS,
        priority = PRIORITY.REAGENTS,
        isMet = craftQueueItem.canCraftOnce,
        reason = "Missing Reagents",
        blocksCraft = true,
        blocksClaim = true,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.RECIPE_REQUIREMENTS,
        priority = PRIORITY.RECIPE_REQUIREMENTS,
        isMet = not craftQueueItem.recipeDisabled,
        reason = craftQueueItem.recipeDisabledReason or "Missing requirement",
        blocksCraft = true,
        blocksClaim = true,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.FORM_STATE,
        priority = PRIORITY.FORM_STATE,
        isMet = formConditionMet,
        reason = formReason,
        blocksCraft = true,
        blocksClaim = true,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.PROFESSION_OPEN,
        priority = PRIORITY.PROFESSION_OPEN,
        isMet = craftQueueItem.correctProfessionOpen,
        reason = "Wrong Profession",
        blocksCraft = true,
        blocksClaim = false,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.PROFESSION_TOOLS,
        priority = PRIORITY.PROFESSION_TOOLS,
        isMet = craftQueueItem.gearEquipped,
        reason = "Wrong Profession Tools",
        blocksCraft = true,
        blocksClaim = false,
    })
    self:AddCondition(craftQueueItem, {
        id = IDS.PRE_CRAFT_GATE,
        priority = PRIORITY.PRE_CRAFT_GATE,
        isMet = not craftQueueItem.pcbgData.needsStep,
        reason = "Pre-craft action required",
        blocksCraft = true,
        blocksClaim = false,
    })

    self:BuildFailedConditionCache(craftQueueItem)
    craftQueueItem.allowedToCraft = GUTIL:Every(craftQueueItem.conditions, function(condition)
        return (not condition.blocksCraft) or condition.isMet
    end)
    self:DebugLogConditionStateIfChanged(craftQueueItem)
end
