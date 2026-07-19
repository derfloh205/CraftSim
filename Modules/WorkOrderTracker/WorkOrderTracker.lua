---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.WORK_ORDER_TRACKER : CraftSim.Module
CraftSim.WORK_ORDER_TRACKER = GUTIL:CreateRegistreeForEvents({
    "NEW_RECIPE_LEARNED",
    "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED",
    "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED",
    "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE",
})

CraftSim.MODULES:RegisterModule("MODULE_WORK_ORDER_TRACKER", CraftSim.WORK_ORDER_TRACKER, {
    label = L("CONTROL_PANEL_MODULES_WORK_ORDER_TRACKER_LABEL"),
    tooltip = L("CONTROL_PANEL_MODULES_WORK_ORDER_TRACKER_TOOLTIP"),
    sortOrder = 12,
})

GUTIL:RegisterCustomEvents(CraftSim.WORK_ORDER_TRACKER, {
    "CRAFTSIM_CRAFTING_ORDERS_PRELOADED",
    "CRAFTSIM_CRAFTQUEUE_QUEUE_PROCESS_FINISHED",
})

local Logger = CraftSim.DEBUG:RegisterLogger("WorkOrderTracker")

CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY = {
    READY = "READY",
    NEEDS_RECIPE = "NEEDS_RECIPE",
    NEEDS_QUALITY = "NEEDS_QUALITY",
    NEEDS_REAGENTS = "NEEDS_REAGENTS",
    ON_COOLDOWN = "ON_COOLDOWN",
    IN_PROGRESS = "IN_PROGRESS",
    BLOCKED = "BLOCKED",
}

CraftSim.WORK_ORDER_TRACKER.TIME_BUCKET = {
    EXPIRED = "EXPIRED",
    LT_6H = "LT_6H",
    H_6_12 = "H_6_12",
    H_12_24 = "H_12_24",
    GT_24H = "GT_24H",
}

CraftSim.WORK_ORDER_TRACKER.isSnapshotting = false

---@param endTime number?
---@return number remainingSeconds
function CraftSim.WORK_ORDER_TRACKER:GetOrderRemainingSeconds(endTime)
    if not endTime then
        return 0
    end
    return math.max(endTime - C_CraftingOrders.GetCraftingOrderTime(), 0)
end

---@param orderSnapshot CraftSim.PatronWorkOrderSnapshot
---@return string bucket CraftSim.WORK_ORDER_TRACKER.TIME_BUCKET
---@return number remainingSeconds
function CraftSim.WORK_ORDER_TRACKER:GetTimeBucketForSnapshot(orderSnapshot)
    local endTime = orderSnapshot.isClaimed and orderSnapshot.claimEndTime or orderSnapshot.expirationTime
    local remaining = self:GetOrderRemainingSeconds(endTime)
    if remaining <= 0 then
        return self.TIME_BUCKET.EXPIRED, remaining
    end
    local hours = remaining / 3600
    if hours < 6 then
        return self.TIME_BUCKET.LT_6H, remaining
    end
    if hours < 12 then
        return self.TIME_BUCKET.H_6_12, remaining
    end
    if hours < 24 then
        return self.TIME_BUCKET.H_12_24, remaining
    end
    return self.TIME_BUCKET.GT_24H, remaining
end

---@param bucket string
---@return number sortRank lower = more urgent
function CraftSim.WORK_ORDER_TRACKER:GetTimeBucketSortRank(bucket)
    local ranks = {
        [self.TIME_BUCKET.EXPIRED] = 0,
        [self.TIME_BUCKET.LT_6H] = 1,
        [self.TIME_BUCKET.H_6_12] = 2,
        [self.TIME_BUCKET.H_12_24] = 3,
        [self.TIME_BUCKET.GT_24H] = 4,
    }
    return ranks[bucket] or 99
end

---@param bucket string
---@return string
function CraftSim.WORK_ORDER_TRACKER:GetTimeBucketLabel(bucket)
    local labels = {
        [self.TIME_BUCKET.EXPIRED] = L("WORK_ORDER_TRACKER_TIME_EXPIRED"),
        [self.TIME_BUCKET.LT_6H] = L("WORK_ORDER_TRACKER_TIME_LT_6H"),
        [self.TIME_BUCKET.H_6_12] = L("WORK_ORDER_TRACKER_TIME_6_12H"),
        [self.TIME_BUCKET.H_12_24] = L("WORK_ORDER_TRACKER_TIME_12_24H"),
        [self.TIME_BUCKET.GT_24H] = L("WORK_ORDER_TRACKER_TIME_GT_24H"),
    }
    return labels[bucket] or bucket
end

---@param craftability string
---@return string
function CraftSim.WORK_ORDER_TRACKER:GetCraftabilityLabel(craftability)
    local key = "WORK_ORDER_TRACKER_CRAFTABILITY_" .. craftability
    local localized = L(key)
    if localized == key then
        return craftability
    end
    return localized
end

--- Opens the patron order in the professions Crafting Orders tab when available.
---@param orderID number
---@param profession Enum.Profession
---@return boolean opened
function CraftSim.WORK_ORDER_TRACKER:TryOpenPatronOrder(orderID, profession)
    if not ProfessionsFrame or not ProfessionsFrame:IsVisible() then
        return false
    end
    if not C_CraftingOrders.ShouldShowCraftingOrderTab() or not ProfessionsFrame.isCraftingOrdersTabEnabled then
        return false
    end

    local openProfession = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not openProfession or openProfession ~= profession then
        return false
    end

    local orderForView
    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    if claimedOrder and claimedOrder.orderID == orderID then
        orderForView = claimedOrder
    else
        local crafterOrders = C_CraftingOrders.GetCrafterOrders()
        if crafterOrders then
            for _, order in ipairs(crafterOrders) do
                if order.orderID == orderID and order.orderType == Enum.CraftingOrderType.Npc then
                    orderForView = order
                    break
                end
            end
        end
    end

    if not orderForView then
        return false
    end

    if not ProfessionsFrame.OrdersPage:IsVisible() then
        ProfessionsFrame:GetTabButton(3):Click()
    end
    ProfessionsFrame.OrdersPage:ViewOrder(orderForView)
    return true
end

---@param orderSnapshot CraftSim.PatronWorkOrderSnapshot
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
function CraftSim.WORK_ORDER_TRACKER:NavigateToAcquisitionHint(orderSnapshot, profession, expansionID)
    if not orderSnapshot or not orderSnapshot.acquisitionHint then
        return
    end
    CraftSim.RECIPE_ACQUISITION:NavigateFromSnapshot(orderSnapshot, profession, expansionID)
end

---@param order CraftingOrderInfo
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@param isClaimed boolean
---@param onComplete fun(snapshot: CraftSim.PatronWorkOrderSnapshot)
function CraftSim.WORK_ORDER_TRACKER:EvaluatePatronOrder(order, profession, expansionID, isClaimed, onComplete)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(order.spellID)
    local recipeName = (recipeInfo and recipeInfo.name) or L("WORK_ORDER_TRACKER_UNKNOWN_RECIPE")

    ---@param craftability string
    ---@param craftabilityDetail string?
    ---@param expectedQuality number?
    ---@param recipeData CraftSim.RecipeData?
    local function buildSnapshot(craftability, craftabilityDetail, expectedQuality, recipeData)
        ---@type CraftSim.PatronWorkOrderSnapshot
        local snapshot = {
            orderID = order.orderID,
            spellID = order.spellID,
            recipeName = recipeName,
            profession = profession,
            expansionID = expansionID,
            minQuality = order.minQuality,
            expirationTime = order.expirationTime,
            claimEndTime = order.claimEndTime,
            isClaimed = isClaimed,
            craftability = craftability,
            craftabilityDetail = craftabilityDetail,
            expectedQuality = expectedQuality,
        }

        if craftability == self.CRAFTABILITY.NEEDS_RECIPE then
            CraftSim.RECIPE_ACQUISITION:EnrichSnapshotForNeedsRecipe(
                snapshot, order.spellID, recipeName, profession, expansionID)
        elseif craftability == self.CRAFTABILITY.NEEDS_QUALITY and recipeData then
            CraftSim.RECIPE_ACQUISITION:EnrichSnapshotForNeedsQuality(snapshot, recipeData)
        end

        onComplete(snapshot)
    end

    if not recipeInfo or not recipeInfo.learned then
        buildSnapshot(self.CRAFTABILITY.NEEDS_RECIPE, "Not Learned", nil, nil)
        return
    end

    local recipeData = CraftSim.RecipeData({ recipeID = order.spellID })
    recipeData:SetOrder(order)
    recipeData:SetCheapestQualityReagentsMax()
    recipeData:Update()

    local useConcentration = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_USE_CONCENTRATION")

    local function meetsMinQuality()
        local minQuality = order.minQuality
        if not minQuality or minQuality <= 0 then
            return true
        end
        if recipeData.resultData.expectedQuality >= minQuality then
            return true
        end
        if useConcentration and recipeData.concentrating
            and recipeData.resultData.expectedQualityConcentration >= minQuality then
            local concentrationData = recipeData.concentrationData
            return recipeData.concentrationCost > 0
                and concentrationData
                and concentrationData:CanAfford(recipeData.concentrationCost)
        end
        return false
    end

    local function finishEval()
        local minQuality = order.minQuality
        if useConcentration and minQuality and minQuality > 0 then
            if recipeData.resultData.expectedQuality < minQuality
                and recipeData.resultData.expectedQualityConcentration == minQuality then
                recipeData.concentrating = true
                recipeData:Update()
            end
        end

        local expectedQuality = recipeData.resultData.expectedQuality
        local craftQueueItem = CraftSim.CraftQueueItem({ recipeData = recipeData })
        craftQueueItem:CalculateCanCraft()

        if isClaimed then
            if craftQueueItem.precraftConditionData:IsAllowedToCraft() then
                buildSnapshot(self.CRAFTABILITY.IN_PROGRESS, L("WORK_ORDER_TRACKER_CRAFTABILITY_READY_TO_CRAFT"), expectedQuality, recipeData)
            else
                local failed = craftQueueItem:GetTopFailedCondition()
                buildSnapshot(self.CRAFTABILITY.BLOCKED, failed and failed.reason or nil, expectedQuality, recipeData)
            end
            return
        end

        if not meetsMinQuality() then
            buildSnapshot(self.CRAFTABILITY.NEEDS_QUALITY, "Below minimum quality", expectedQuality, recipeData)
            return
        end

        if craftQueueItem:CanClaimWorkOrder() then
            buildSnapshot(self.CRAFTABILITY.READY, nil, expectedQuality, recipeData)
            return
        end

        local failed = craftQueueItem:GetTopFailedCondition()
        local failedID = failed and failed.id
        local IDS = CraftSim.PRE_CRAFT_CONDITION_IDS

        if failedID == IDS.LEARNED then
            buildSnapshot(self.CRAFTABILITY.NEEDS_RECIPE, failed.reason, expectedQuality, recipeData)
        elseif failedID == IDS.WORK_ORDER_MIN_QUALITY then
            buildSnapshot(self.CRAFTABILITY.NEEDS_QUALITY, failed.reason, expectedQuality, recipeData)
        elseif failedID == IDS.REAGENTS then
            buildSnapshot(self.CRAFTABILITY.NEEDS_REAGENTS, failed.reason, expectedQuality, recipeData)
        elseif failedID == IDS.COOLDOWN then
            buildSnapshot(self.CRAFTABILITY.ON_COOLDOWN, failed.reason, expectedQuality, recipeData)
        else
            buildSnapshot(self.CRAFTABILITY.BLOCKED, failed and failed.reason or nil, expectedQuality, recipeData)
        end
    end

    if order.minQuality and order.minQuality > 0 then
        local maxQuality = useConcentration and math.max(order.minQuality - 1, 1) or order.minQuality
        recipeData:Optimize {
            optimizeGear = true,
            optimizeReagentOptions = {
                maxQuality = maxQuality,
            },
            finally = finishEval,
        }
    else
        recipeData:Optimize {
            optimizeGear = true,
            finally = finishEval,
        }
    end
end

---@param orders CraftingOrderInfo[]
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@param crafterUID CrafterUID
---@param onComplete? fun()
function CraftSim.WORK_ORDER_TRACKER:SnapshotFromOrders(orders, profession, expansionID, crafterUID, onComplete)
    local patronOrders = GUTIL:Filter(orders, function(order)
        return order.orderType == Enum.CraftingOrderType.Npc
    end)

    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    if claimedOrder and claimedOrder.orderType == Enum.CraftingOrderType.Npc then
        local alreadyIncluded = GUTIL:Find(patronOrders, function(order)
            return order.orderID == claimedOrder.orderID
        end)
        if not alreadyIncluded then
            tinsert(patronOrders, claimedOrder)
        end
    end

    local claimedOrderID = claimedOrder and claimedOrder.orderID
    patronOrders = GUTIL:Filter(patronOrders, function(order)
        local isClaimed = claimedOrderID ~= nil and order.orderID == claimedOrderID
        local endTime = isClaimed and order.claimEndTime or order.expirationTime
        return self:GetOrderRemainingSeconds(endTime) > 0
    end)

    if #patronOrders == 0 then
        CraftSim.DB.CRAFTER:SavePatronWorkOrders(crafterUID, profession, {
            lastSnapshotAt = GetTime(),
            orders = {},
        })
        self:PruneExpiredPatronWorkOrders()
        if onComplete then
            onComplete()
        end
        self:RefreshUIIfVisible()
        return
    end

    self.isSnapshotting = true
    local evaluatedOrders = {}

    GUTIL.FrameDistributor {
        iterationTable = patronOrders,
        iterationsPerFrame = 1,
        maxIterations = #patronOrders + 5,
        finally = function()
            ---@type table<number, CraftSim.PatronWorkOrderSnapshot>
            local ordersByID = {}
            for _, snapshot in ipairs(evaluatedOrders) do
                if not self:IsSnapshotExpired(snapshot) then
                    ordersByID[snapshot.orderID] = snapshot
                end
            end
            CraftSim.DB.CRAFTER:SavePatronWorkOrders(crafterUID, profession, {
                lastSnapshotAt = GetTime(),
                orders = ordersByID,
            })
            self:PruneExpiredPatronWorkOrders()
            self.isSnapshotting = false
            Logger:LogDebug("Snapshotted {count} patron work orders for {crafter}", #patronOrders, crafterUID)
            if onComplete then
                onComplete()
            end
            self:RefreshUIIfVisible()
        end,
        continue = function(distributor, _, order)
            local isClaimed = claimedOrderID ~= nil and order.orderID == claimedOrderID
            self:EvaluatePatronOrder(order, profession, expansionID, isClaimed, function(snapshot)
                tinsert(evaluatedOrders, snapshot)
                distributor:Continue()
            end)
        end,
    }:Continue()
end

function CraftSim.WORK_ORDER_TRACKER:RefreshUIIfVisible()
    if self.frame and self.frame:IsVisible() and self.UI and self.UI.UpdateDisplay then
        self.UI:UpdateDisplay()
    end
end

---@param onComplete? fun(success: boolean)
function CraftSim.WORK_ORDER_TRACKER:SnapshotCurrentProfession(onComplete)
    local profession = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not profession then
        if onComplete then
            onComplete(false)
        end
        return
    end

    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    if not expansionID then
        if onComplete then
            onComplete(false)
        end
        return
    end

    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local request = CraftSim.CRAFTQ:CreateWorkOrderListRequest(profession, Enum.CraftingOrderType.Npc)

    CraftSim.CRAFTQ:RequestCrafterOrdersWithRetry(request, function(result)
        if result ~= Enum.CraftingOrderResult.Ok then
            if onComplete then
                onComplete(false)
            end
            return
        end

        local orders = C_CraftingOrders.GetCrafterOrders() or {}
        self:SnapshotFromOrders(orders, profession, expansionID, crafterUID, function()
            if onComplete then
                onComplete(true)
            end
        end)
    end)
end

function CraftSim.WORK_ORDER_TRACKER:CRAFTSIM_CRAFTING_ORDERS_PRELOADED()
    if not CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_AUTO_SNAPSHOT") then
        return
    end
    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_AUTO_QUEUE")
        and CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS") then
        return
    end
    if not CraftSim.DB.OPTIONS:IsModuleEnabled(self.moduleID) then
        return
    end
    if self.isSnapshotting then
        return
    end

    C_Timer.After(0.5, function()
        if ProfessionsFrame and ProfessionsFrame:IsVisible() then
            self:SnapshotCurrentProfession()
        end
    end)
end

---@param queueType "WORK_ORDERS"|"FIRST_CRAFTS"|"CRAFT_LISTS"
function CraftSim.WORK_ORDER_TRACKER:CRAFTSIM_CRAFTQUEUE_QUEUE_PROCESS_FINISHED(queueType)
    if queueType ~= "work_orders" then
        return
    end
    if not CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_AUTO_SNAPSHOT") then
        return
    end
    if not self.pendingPatronOrdersFromQueue then
        return
    end

    local pending = self.pendingPatronOrdersFromQueue
    self.pendingPatronOrdersFromQueue = nil

    self:SnapshotFromOrders(
        pending.orders,
        pending.profession,
        pending.expansionID,
        pending.crafterUID
    )
end

---@param orders CraftingOrderInfo[]
---@param profession Enum.Profession
function CraftSim.WORK_ORDER_TRACKER:StagePatronOrdersFromQueue(orders, profession)
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    if not expansionID then
        return
    end

    self.pendingPatronOrdersFromQueue = {
        orders = orders,
        profession = profession,
        expansionID = expansionID,
        crafterUID = CraftSim.UTIL:GetPlayerCrafterUID(),
    }
end

function CraftSim.WORK_ORDER_TRACKER:NEW_RECIPE_LEARNED()
    local profession = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not profession then
        return
    end

    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local professionSnapshot = CraftSim.DB.CRAFTER:GetPatronWorkOrdersForProfession(crafterUID, profession)
    if not professionSnapshot or not professionSnapshot.orders then
        return
    end

    local hasOrders = false
    for _ in pairs(professionSnapshot.orders) do
        hasOrders = true
        break
    end
    if not hasOrders then
        return
    end

    self:SnapshotCurrentProfession()
end

function CraftSim.WORK_ORDER_TRACKER:CRAFTINGORDERS_CLAIMED_ORDER_UPDATED()
    self:UpdateClaimedOrderInCache()
end

function CraftSim.WORK_ORDER_TRACKER:CRAFTINGORDERS_CLAIMED_ORDER_REMOVED()
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    if self.lastClaimedOrderID then
        CraftSim.DB.CRAFTER:RemovePatronWorkOrder(crafterUID, self.lastClaimedOrderID)
        self.lastClaimedOrderID = nil
    end
    self:RefreshUIIfVisible()
end

function CraftSim.WORK_ORDER_TRACKER:CRAFTINGORDERS_FULFILL_ORDER_RESPONSE(result, orderID)
    if result == Enum.CraftingOrderResult.Ok and orderID then
        CraftSim.DB.CRAFTER:RemovePatronWorkOrder(CraftSim.UTIL:GetPlayerCrafterUID(), orderID)
        self:RefreshUIIfVisible()
    end
end

function CraftSim.WORK_ORDER_TRACKER:UpdateClaimedOrderInCache()
    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    if not claimedOrder or claimedOrder.orderType ~= Enum.CraftingOrderType.Npc then
        return
    end

    self.lastClaimedOrderID = claimedOrder.orderID

    local profession = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not profession then
        return
    end

    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    if not expansionID then
        return
    end

    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    self:EvaluatePatronOrder(claimedOrder, profession, expansionID, true, function(snapshot)
        if self:IsSnapshotExpired(snapshot) then
            CraftSim.DB.CRAFTER:RemovePatronWorkOrder(crafterUID, snapshot.orderID)
            self:RefreshUIIfVisible()
            return
        end

        local professionSnapshot = CraftSim.DB.CRAFTER:GetPatronWorkOrdersForProfession(crafterUID, profession)
        if not professionSnapshot then
            professionSnapshot = {
                lastSnapshotAt = GetTime(),
                orders = {},
            }
        end
        professionSnapshot.orders = professionSnapshot.orders or {}
        professionSnapshot.orders[snapshot.orderID] = snapshot
        professionSnapshot.lastSnapshotAt = GetTime()
        CraftSim.DB.CRAFTER:SavePatronWorkOrders(crafterUID, profession, professionSnapshot)
        self:RefreshUIIfVisible()
    end)
end

---@param orderSnapshot CraftSim.PatronWorkOrderSnapshot
---@return boolean
function CraftSim.WORK_ORDER_TRACKER:IsSnapshotExpired(orderSnapshot)
    local bucket = self:GetTimeBucketForSnapshot(orderSnapshot)
    return bucket == self.TIME_BUCKET.EXPIRED
end

---@return boolean removedAny
function CraftSim.WORK_ORDER_TRACKER:PruneExpiredPatronWorkOrders()
    local removedAny = false

    for _, entry in ipairs(CraftSim.DB.CRAFTER:GetAllPatronWorkOrderSnapshots()) do
        local crafterUID = entry.crafterUID
        local profession = entry.profession
        local snapshot = entry.snapshot
        local orders = snapshot.orders
        if orders then
            local changed = false
            for orderID, orderSnapshot in pairs(orders) do
                if self:IsSnapshotExpired(orderSnapshot) then
                    orders[orderID] = nil
                    changed = true
                    removedAny = true
                end
            end
            if changed then
                CraftSim.DB.CRAFTER:SavePatronWorkOrders(crafterUID, profession, snapshot)
            end
        end
    end

    return removedAny
end
