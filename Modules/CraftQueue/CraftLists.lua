---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.LOCAL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.CRAFT_LISTS
CraftSim.CRAFT_LISTS = {}

---@class CraftSim.CRAFT_LISTS.CONCENTRATION_ALLOCATION
CraftSim.CRAFT_LISTS.CONCENTRATION_ALLOCATION = {
    OFF = "OFF",
    SINGLE = "SINGLE",
    MULTI = "MULTI",
}

--- Unified concentration setting for craft list UI (maps to enableConcentration + concentrationAllocationMode).
---@class CraftSim.CRAFT_LISTS.CONCENTRATION_MODE
CraftSim.CRAFT_LISTS.CONCENTRATION_MODE = {
    DISABLED = "DISABLED",
    ENABLED = "ENABLED",
    SINGLE = "SINGLE",
    MULTI = "MULTI",
}

local CONC = CraftSim.CRAFT_LISTS.CONCENTRATION_ALLOCATION
local CONC_MODE = CraftSim.CRAFT_LISTS.CONCENTRATION_MODE

---@param options CraftSim.CraftList.Options?
---@return string
function CraftSim.CRAFT_LISTS:GetConcentrationMode(options)
    options = CraftSim.DB.CRAFT_LISTS.NormalizeListOptions(options)
    if not options.enableConcentration then
        return CONC_MODE.DISABLED
    end
    local allocationMode = options.concentrationAllocationMode or CONC.OFF
    if allocationMode == CONC.SINGLE then
        return CONC_MODE.SINGLE
    elseif allocationMode == CONC.MULTI then
        return CONC_MODE.MULTI
    end
    return CONC_MODE.ENABLED
end

---@param options CraftSim.CraftList.Options
---@param mode string
function CraftSim.CRAFT_LISTS:SetConcentrationMode(options, mode)
    if mode == CONC_MODE.DISABLED then
        options.enableConcentration = false
        options.concentrationAllocationMode = CONC.OFF
    elseif mode == CONC_MODE.ENABLED then
        options.enableConcentration = true
        options.concentrationAllocationMode = CONC.OFF
    elseif mode == CONC_MODE.SINGLE then
        options.enableConcentration = true
        options.concentrationAllocationMode = CONC.SINGLE
    elseif mode == CONC_MODE.MULTI then
        options.enableConcentration = true
        options.concentrationAllocationMode = CONC.MULTI
    end
end

local Logger = CraftSim.DEBUG:RegisterLogger("CraftLists")

---@param recipeData CraftSim.RecipeData
---@return number
local function GetEffectiveExpectedQuality(recipeData)
    if recipeData.concentrating and recipeData.resultData.expectedQualityConcentration then
        return recipeData.resultData.expectedQualityConcentration
    end
    return recipeData.resultData.expectedQuality
end

---@param recipeData CraftSim.RecipeData
---@param recipeEntry CraftSim.CraftListRecipeEntry?
---@return boolean
local function RecipeMeetsSupportedQualities(recipeData, recipeEntry)
    if not recipeData.isGear or not recipeData.supportsQualities then
        return true
    end
    local supported = recipeEntry and recipeEntry.supportedQualities
    if not CraftSim.DB.CRAFT_LISTS.IsAnySupportedQualityChecked(supported) then
        return true
    end
    return CraftSim.DB.CRAFT_LISTS.IsQualitySupported(GetEffectiveExpectedQuality(recipeData), supported)
end

---@param recipeData CraftSim.RecipeData
---@param recipeEntry CraftSim.CraftListRecipeEntry?
---@param includeAltInventory boolean?
---@return number
local function GetOwnedCountForRecipeEntry(recipeData, recipeEntry, includeAltInventory)
    local supported = recipeEntry and recipeEntry.supportedQualities
    if not recipeData.isGear
        or not recipeData.supportsQualities
        or not CraftSim.DB.CRAFT_LISTS.IsAnySupportedQualityChecked(supported) then
        local expectedItem = recipeData.resultData.expectedItem
        if not expectedItem then
            return 0
        end
        return CraftSim.INVENTORY_SOURCE:GetTradableInventoryCount(
            expectedItem:GetItemID() or expectedItem:GetItemLink(),
            includeAltInventory) or 0
    end

    local owned = 0
    local qualityItemLevels = CraftSim.INVENTORY_SOURCE:BuildQualityItemLevels(recipeData)
    for qualityID, item in pairs(recipeData.resultData.itemsByQuality) do
        if CraftSim.DB.CRAFT_LISTS.IsQualitySupported(qualityID, supported) and item then
            owned = owned + (CraftSim.INVENTORY_SOURCE:GetTradableInventoryCount(
                item:GetItemLink() or item:GetItemID(),
                includeAltInventory,
                qualityID,
                qualityItemLevels) or 0)
        end
    end
    return owned
end

--- Restock target is per selected gear quality. Returns crafts still needed across those qualities.
---@param recipeData CraftSim.RecipeData
---@param recipeEntry CraftSim.CraftListRecipeEntry?
---@param includeAltInventory boolean?
---@param restockPerQuality number
---@param subtractInventory boolean?
---@return number
local function GetRestockQueueAmountForRecipeEntry(recipeData, recipeEntry, includeAltInventory, restockPerQuality,
                                                  subtractInventory)
    local supported = recipeEntry and recipeEntry.supportedQualities
    local useQualitySplit = recipeData.isGear
        and recipeData.supportsQualities
        and CraftSim.DB.CRAFT_LISTS.IsAnySupportedQualityChecked(supported)

    if not useQualitySplit then
        local owned = GetOwnedCountForRecipeEntry(recipeData, recipeEntry, includeAltInventory)
        if owned >= restockPerQuality then
            return 0
        end
        if subtractInventory then
            return math.max(0, restockPerQuality - owned)
        end
        return restockPerQuality
    end

    local neededTotal = 0
    local ownedTotal = 0
    local queueAmount = 0
    local sharedItemID = nil
    local qualityItemLevels = CraftSim.INVENTORY_SOURCE:BuildQualityItemLevels(recipeData)

    for qualityID, item in pairs(recipeData.resultData.itemsByQuality) do
        if CraftSim.DB.CRAFT_LISTS.IsQualitySupported(qualityID, supported) and item then
            sharedItemID = item:GetItemID() or sharedItemID
            local owned = CraftSim.INVENTORY_SOURCE:GetTradableInventoryCount(
                item:GetItemLink() or item:GetItemID(),
                includeAltInventory,
                qualityID,
                qualityItemLevels) or 0
            neededTotal = neededTotal + restockPerQuality
            ownedTotal = ownedTotal + owned
            if owned < restockPerQuality then
                if subtractInventory then
                    queueAmount = queueAmount + (restockPerQuality - owned)
                else
                    queueAmount = queueAmount + restockPerQuality
                end
            end
        end
    end

    if neededTotal <= 0 then
        return 0
    end

    if ownedTotal >= neededTotal then
        return 0
    end

    -- Per-quality AH links can under-count; treat unscoped AH as a pool for the remaining deficit.
    if queueAmount > 0 and sharedItemID then
        local poolDeficit = neededTotal - ownedTotal
        local unscopedAH = CraftSim.INVENTORY_SOURCE:GetTradableAuctionCount(
            sharedItemID, includeAltInventory, nil, qualityItemLevels) or 0
        if unscopedAH >= poolDeficit then
            return 0
        end
        if subtractInventory then
            return math.max(0, poolDeficit - unscopedAH)
        end
    end

    return queueAmount
end

---@param recipeEntry CraftSim.CraftListRecipeEntry?
---@param recipeData CraftSim.RecipeData
---@param optimizeReagentOptions table?
---@return table?
local function ApplySupportedQualitiesToOptimizeOptions(recipeEntry, recipeData, optimizeReagentOptions)
    if not recipeData.isGear or not recipeData.supportsQualities then
        return optimizeReagentOptions
    end
    local supported = recipeEntry and recipeEntry.supportedQualities
    if not CraftSim.DB.CRAFT_LISTS.IsAnySupportedQualityChecked(supported) then
        return optimizeReagentOptions
    end
    local minQ, maxQ = nil, nil
    for qualityID = 1, recipeData.maxQuality do
        if supported[qualityID] then
            minQ = minQ and math.min(minQ, qualityID) or qualityID
            maxQ = maxQ and math.max(maxQ, qualityID) or qualityID
        end
    end
    if not minQ or not maxQ then
        return optimizeReagentOptions
    end
    return { minQuality = minQ, maxQuality = maxQ }
end

CraftSim.CRAFT_LISTS.isQueueingSelectedLists = false

---@param progress { total: number, count: number }?
---@return string
local function FormatRecipeQueueProgressSuffix(progress)
    if not progress or progress.total < 1 then
        return ""
    end
    return string.format(" (%d/%d)", progress.count, progress.total)
end

function CraftSim.CRAFT_LISTS:StopQueueSelectedLists()
    self.isQueueingSelectedLists = false
end

---@param running boolean
function CraftSim.CRAFT_LISTS:SetQueueCraftListsButtonState(running)
    local queueListsButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsButton --[[@as GGUI.Button?]]
    local queueListsCancelButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsCancelButton --[[@as Button?]]

    if not queueListsButton then
        return
    end

    if running then
        queueListsButton:SetStatus("Queueing")
    else
        queueListsButton:SetStatus("Ready")
    end

    if queueListsCancelButton then
        if running then
            if queueListsButton and queueListsButton.frame then
                queueListsCancelButton:SetFrameStrata(queueListsButton.frame:GetFrameStrata())
                queueListsCancelButton:SetFrameLevel(queueListsButton.frame:GetFrameLevel() + 20)
            end
            queueListsCancelButton:Show()
        else
            queueListsCancelButton:Hide()
        end
    end
end

---@param list CraftSim.CraftList
---@return CraftSim.CraftListRecipeEntry[]
local function GetRecipeEntries(list)
    if list.recipeEntries and #list.recipeEntries > 0 then
        return list.recipeEntries
    end
    local entries = {}
    for _, recipeID in ipairs(list.recipeIDs or {}) do
        tinsert(entries, {
            recipeID = recipeID,
            restockMaxAmount = 0,
        })
    end
    return entries
end

--- Represents a single recipe scan result collected from a craft list scan pass.
--- For lists with includeSoulboundFinishingReagents enabled, each recipe that uses a
--- soulbound finishing reagent is scanned twice: once optimized *with* SBF (recipeData)
--- and once optimized *without* SBF (recipeDataNoSBF).  The triage step then decides
--- which version is actually queued based on globally-available SBF counts.
---@class CraftSim.CRAFT_LISTS.ScanEntry
---@field list CraftSim.CraftList
---@field options CraftSim.CraftList.Options
---@field recipeEntry CraftSim.CraftListRecipeEntry
---@field crafterUID CrafterUID
---@field recipeData CraftSim.RecipeData primary recipe data (optimized with SBF when applicable)
---@field recipeDataNoSBF CraftSim.RecipeData? without-SBF alternative; only present when recipeData uses SBF and the list has includeSoulboundFinishingReagents enabled
---@field maxQueueAmount number? upper bound from restock / TSM options; nil means use 1 or concentration-limited amount

--- Compare two RecipeData objects by smart priority: concentrating beats non-concentrating;
--- among concentrating recipes sort by concentration value; among non-concentrating by profit.
---@param aRd CraftSim.RecipeData
---@param bRd CraftSim.RecipeData
---@return boolean aBeforeB
---@param rd CraftSim.RecipeData
---@param entry CraftSim.CRAFT_LISTS.ScanEntry
---@param currentConcentration number
---@return number queueableAmount
local function getConcentrationQueueableAmount(rd, entry, currentConcentration)
    local concentrationCost = rd.concentrationCost
    if entry.options.offsetConcentrationCraftAmount then
        local ingenuityChance = rd.professionStats.ingenuity:GetPercent(true)
        local ingenuityRefund = 0.5 + rd.professionStats.ingenuity:GetExtraValue()
        concentrationCost = concentrationCost -
            (concentrationCost * ingenuityChance * ingenuityRefund)
    end
    local queueableAmount = math.floor(currentConcentration / concentrationCost)
    -- Full cost required for at least one craft; adjusted cost is only for expected count.
    if currentConcentration < rd.concentrationCost then
        queueableAmount = 0
    end
    if entry.maxQueueAmount then
        queueableAmount = math.min(queueableAmount, entry.maxQueueAmount)
    end
    return queueableAmount
end

local function sortRecipeDataBySmartPriority(aRd, bRd)
    if aRd.concentrating ~= bRd.concentrating then
        return aRd.concentrating -- true sorts before false
    end
    if aRd.concentrating then
        return aRd:GetConcentrationValue() > bRd:GetConcentrationValue()
    else
        return (aRd.averageProfitCached or 0) > (bRd.averageProfitCached or 0)
    end
end

--- Re-assign how many crafts of an entry use soulbound finishing reagents after the
--- final queue amount is known (concentration / cooldown triage). Step 1 only sees
--- maxQueueAmount or 1, so MULTI concentration can commit far more crafts than SBF
--- allocation initially granted.
---@param entry CraftSim.CRAFT_LISTS.ScanEntry
---@param committedAmount number
---@param entrySbfCrafts table<CraftSim.CRAFT_LISTS.ScanEntry, number>
---@param sbfAvailable table<string, number>
---@param entryEffectiveRD table<CraftSim.CRAFT_LISTS.ScanEntry, CraftSim.RecipeData>
local function realignSbfCraftsForAmount(entry, committedAmount, entrySbfCrafts, sbfAvailable, entryEffectiveRD)
    committedAmount = math.max(0, committedAmount or 0)

    if not entry.options.includeSoulboundFinishingReagents then
        local sbfCrafts = entrySbfCrafts[entry] or 0
        if sbfCrafts > committedAmount then
            entrySbfCrafts[entry] = committedAmount
        end
        return
    end

    local sbfItemID = entry.recipeData:GetSoulboundFinishingReagentInfo()
    if not sbfItemID then
        return
    end

    local key = entry.crafterUID .. ":" .. sbfItemID
    local previousSbf = entrySbfCrafts[entry] or 0
    local pool = (sbfAvailable[key] or 0) + previousSbf
    local newSbfCrafts = math.min(pool, committedAmount)
    entrySbfCrafts[entry] = newSbfCrafts
    sbfAvailable[key] = pool - newSbfCrafts

    if newSbfCrafts > 0 then
        entryEffectiveRD[entry] = entry.recipeData
    else
        entryEffectiveRD[entry] = entry.recipeDataNoSBF or entry.recipeData
    end
end

--- Performs global triage of all scan entries collected across every selected craft list,
--- then queues the winning combinations.
---
--- Replaces the former per-list finalizeList() + post-process ApplySmartQueueing() approach.
---
--- Pass order:
---   1. Global SBF allocation – for each SBF item, entries are sorted by their WITH-SBF
---      priority and SBF uses are assigned to the highest-value recipes across all lists.
---   2. Global concentration allocation – for entries in lists with concentrationAllocationMode
---      SINGLE or MULTI, entries are grouped by crafter+profession and sorted by the *effective*
---      (post-SBF) concentration value. SINGLE queues only the first affordable recipe;
---      MULTI greedily queues multiple recipes until the pool is exhausted. OFF skips this step.
---      Runs BEFORE cooldown triage so concentration-limited craft counts (entryOverrideAmount)
---      are known when cooldown charges are distributed.
---   3. Cooldown triage – cooldown-recipe entries are sorted and capped to available
---      charges.  Because concentration limits are already reflected in entryOverrideAmount,
---      any charges freed by concentration can be redistributed to lower-priority entries
---      that share the same cooldown (e.g. a non-concentrating list for the same recipe).
---   4. Queue – resulting entries are added to the craft queue with the appropriate
---      with-SBF / without-SBF split.
---@param allScanEntries CraftSim.CRAFT_LISTS.ScanEntry[]
function CraftSim.CRAFT_LISTS:TriageAndQueue(allScanEntries)
    if not allScanEntries or #allScanEntries == 0 then return end

    -- ── Step 1: Global SBF Allocation ────────────────────────────────────────
    -- Determine available SBF uses (in crafts) per crafterUID:sbfItemID.
    ---@type table<string, number>  key = crafterUID:sbfItemID → remaining craft uses
    local sbfAvailable = {}
    for _, entry in ipairs(allScanEntries) do
        local rd = entry.recipeData
        if rd:IsUsingSoulboundFinishingReagent() then
            local sbfItemID, perCraft = rd:GetSoulboundFinishingReagentInfo()
            if sbfItemID then
                local key = entry.crafterUID .. ":" .. sbfItemID
                if not sbfAvailable[key] then
                    local owned = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(entry.crafterUID, sbfItemID, true) or 0
                    sbfAvailable[key] = math.floor(owned / (perCraft or 1))
                end
            end
        end
    end

    -- Group SBF entries by (crafterUID:sbfItemID), sort by WITH-SBF priority, then allocate.
    -- Note: only sbfItemID is needed for grouping here; perCraft was already used above.
    ---@type table<string, CraftSim.CRAFT_LISTS.ScanEntry[]>
    local sbfGroups = {}
    for _, entry in ipairs(allScanEntries) do
        local sbfItemID = entry.recipeData:GetSoulboundFinishingReagentInfo()
        if sbfItemID then
            local key = entry.crafterUID .. ":" .. sbfItemID
            sbfGroups[key] = sbfGroups[key] or {}
            tinsert(sbfGroups[key], entry)
        end
    end

    -- Per-entry: how many crafts receive SBF (remainder uses the without-SBF version).
    ---@type table<CraftSim.CRAFT_LISTS.ScanEntry, number>
    local entrySbfCrafts = {}
    for key, entries in pairs(sbfGroups) do
        table.sort(entries, function(a, b)
            return sortRecipeDataBySmartPriority(a.recipeData, b.recipeData)
        end)
        local available = sbfAvailable[key] or 0
        for _, entry in ipairs(entries) do
            local maxQty = entry.maxQueueAmount or 1
            local sbfCrafts = math.min(available, maxQty)
            entrySbfCrafts[entry] = sbfCrafts
            available = math.max(0, available - sbfCrafts)
        end
        sbfAvailable[key] = available
    end

    -- Resolve the effective RecipeData for each entry (post SBF allocation).
    ---@type table<CraftSim.CRAFT_LISTS.ScanEntry, CraftSim.RecipeData>
    local entryEffectiveRD = {}
    for _, entry in ipairs(allScanEntries) do
        local sbfCrafts = entrySbfCrafts[entry] or 0
        if sbfCrafts > 0 then
            entryEffectiveRD[entry] = entry.recipeData                          -- with SBF
        else
            entryEffectiveRD[entry] = entry.recipeDataNoSBF or entry.recipeData -- without SBF
        end
    end

    ---@type table<CraftSim.CRAFT_LISTS.ScanEntry, boolean>
    local skipEntry = {}
    ---@type table<CraftSim.CRAFT_LISTS.ScanEntry, number>
    local entryOverrideAmount = {}

    -- ── Step 2: Global Concentration Allocation ───────────────────────────────
    -- Runs BEFORE cooldown triage so that concentration-limited craft counts are
    -- already in entryOverrideAmount when the cooldown step distributes charges.
    --
    -- Only applies to entries from lists with concentrationAllocationMode SINGLE or MULTI.
    -- Entries are grouped globally by crafterUID:professionSkillLineID so that
    -- concentration is shared across craft lists (not allocated per-list).
    ---@type table<string, { currentAmount: number, entries: { entry: CraftSim.CRAFT_LISTS.ScanEntry, rd: CraftSim.RecipeData }[] }>
    local concentrationGroups = {}

    for _, entry in ipairs(allScanEntries) do
        local opts = entry.options
        local allocationMode = opts.concentrationAllocationMode or CONC.OFF
        if opts.enableConcentration and allocationMode ~= CONC.OFF then
            local rd = entryEffectiveRD[entry]
            if rd.concentrating and rd.concentrationCost and rd.concentrationCost > 0 then
                local key = entry.crafterUID .. ":" .. rd.professionData.skillLineID
                if not concentrationGroups[key] then
                    concentrationGroups[key] = {
                        currentAmount = (rd.concentrationData and rd.concentrationData:GetSpendableAmount()) or 0,
                        entries = {},
                    }
                end
                tinsert(concentrationGroups[key].entries, { entry = entry, rd = rd })
            end
        end
    end

    for _, group in pairs(concentrationGroups) do
        table.sort(group.entries, function(a, b)
            return a.rd:GetConcentrationValue() > b.rd:GetConcentrationValue()
        end)
        local currentConcentration = group.currentAmount
        local singleAllocated = false
        for _, item in ipairs(group.entries) do
            local entry = item.entry
            local rd = item.rd
            local allocationMode = entry.options.concentrationAllocationMode or CONC.OFF
            local queueableAmount = getConcentrationQueueableAmount(rd, entry, currentConcentration)

            local function allocateEntry()
                entryOverrideAmount[entry] = queueableAmount
                realignSbfCraftsForAmount(entry, queueableAmount, entrySbfCrafts, sbfAvailable, entryEffectiveRD)
                local concentrationCost = rd.concentrationCost
                if entry.options.offsetConcentrationCraftAmount then
                    local ingenuityChance = rd.professionStats.ingenuity:GetPercent(true)
                    local ingenuityRefund = 0.5 + rd.professionStats.ingenuity:GetExtraValue()
                    concentrationCost = concentrationCost -
                        (concentrationCost * ingenuityChance * ingenuityRefund)
                end
                currentConcentration = currentConcentration - (concentrationCost * queueableAmount)
            end

            if allocationMode == CONC.MULTI then
                if queueableAmount > 0 then
                    allocateEntry()
                else
                    skipEntry[entry] = true
                end
            elseif allocationMode == CONC.SINGLE then
                if singleAllocated or queueableAmount <= 0 then
                    skipEntry[entry] = true
                else
                    allocateEntry()
                    singleAllocated = true
                end
            end
        end
    end

    -- ── Step 3: Cooldown Triage ───────────────────────────────────────────────
    -- Runs AFTER concentration triage so concentration-reduced amounts are already
    -- reflected in entryOverrideAmount. Charges freed by concentration limits are
    -- redistributed to other entries that share the same cooldown (e.g. a
    -- non-concentrating craft list for the same cooldown recipe).
    --
    -- For shared cooldowns (e.g. alchemy transmutations), multiple recipe IDs share
    -- the same lockout.  Use cooldownData.sharedCD as the group key when present so
    -- that all recipes sharing a cooldown compete for the same pool of charges.
    ---@type table<string, CraftSim.CRAFT_LISTS.ScanEntry[]>
    local cooldownGroups = {}
    for _, entry in ipairs(allScanEntries) do
        local rd = entryEffectiveRD[entry]
        if rd.cooldownData and rd.cooldownData.isCooldownRecipe then
            local cdKey = rd.cooldownData.sharedCD or rd.recipeID
            local key = entry.crafterUID .. ":" .. cdKey
            cooldownGroups[key] = cooldownGroups[key] or {}
            tinsert(cooldownGroups[key], entry)
        end
    end

    for _, group in pairs(cooldownGroups) do
        table.sort(group, function(a, b)
            return sortRecipeDataBySmartPriority(entryEffectiveRD[a], entryEffectiveRD[b])
        end)
        local availableCharges = group[1].recipeData.cooldownData:GetCurrentCharges() or 0
        for _, entry in ipairs(group) do
            if skipEntry[entry] then
                -- Already excluded (e.g. lost concentration triage); don't count toward used charges.
            elseif availableCharges <= 0 then
                skipEntry[entry] = true
            else
                -- Use the concentration-limited amount if set, otherwise fall back to the
                -- list's own max.  This allows freed charges to flow to lower-priority entries.
                local committed = entryOverrideAmount[entry] or entry.maxQueueAmount or 1
                local assigned = math.min(committed, availableCharges)
                availableCharges = availableCharges - assigned
                if assigned == 0 then
                    skipEntry[entry] = true
                else
                    entryOverrideAmount[entry] = assigned
                    realignSbfCraftsForAmount(entry, assigned, entrySbfCrafts, sbfAvailable, entryEffectiveRD)
                end
            end
        end
    end

    -- ── Step 4: Queue All Results ─────────────────────────────────────────────
    for _, entry in ipairs(allScanEntries) do
        if not skipEntry[entry] then
            local opts = entry.options
            local effectiveRD = entryEffectiveRD[entry]

            -- Apply onlyProfitable filter against the *effective* (post-SBF) version.
            local profitableOk = true
            if opts.onlyProfitable then
                local profit = effectiveRD.averageProfitCached
                if opts.skipOwnedMaterialCosts then
                    profit = select(1, CraftSim.CRAFTQ:GetProfitWithOwnedMaterials(
                        effectiveRD,
                        entryOverrideAmount[entry] or entry.maxQueueAmount or 1,
                        { includeAlts = opts.includeAltInventory, consume = false }))
                end
                profitableOk = not profit or profit > 0
            end

            if profitableOk then
                if not RecipeMeetsSupportedQualities(effectiveRD, entry.recipeEntry) then
                    Logger:LogDebug("Skipping unsupported gear quality at queue time: " .. effectiveRD.recipeName)
                else
                    local sbfCrafts = entrySbfCrafts[entry] or 0
                    local totalAmount = entryOverrideAmount[entry] or entry.maxQueueAmount or 1
                    if totalAmount <= 0 then
                        Logger:LogDebug("Skipping recipe with no queue amount: " .. effectiveRD.recipeName)
                    else
                        local noSbfCrafts = math.max(0, totalAmount - sbfCrafts)

                        -- Queue the with-SBF portion.
                        if sbfCrafts > 0 then
                            CraftSim.CRAFTQ.craftQueue:AddRecipe({
                                recipeData = entry.recipeData,
                                amount = sbfCrafts,
                            })
                            if opts.skipOwnedMaterialCosts then
                                CraftSim.CRAFTQ:ConsumeOwnedReagentsFromPool(
                                    entry.crafterUID, entry.recipeData, sbfCrafts, opts.includeAltInventory)
                            end
                        end

                        -- Queue the without-SBF portion using the dedicated no-SBF recipe data when available.
                        if noSbfCrafts > 0 then
                            local noSbfRD = (sbfCrafts > 0 and entry.recipeDataNoSBF) or effectiveRD
                            CraftSim.CRAFTQ.craftQueue:AddRecipe({
                                recipeData = noSbfRD,
                                amount = noSbfCrafts,
                            })
                            if opts.skipOwnedMaterialCosts then
                                CraftSim.CRAFTQ:ConsumeOwnedReagentsFromPool(
                                    entry.crafterUID, noSbfRD, noSbfCrafts, opts.includeAltInventory)
                            end
                        end

                        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST") then
                            CraftSim.DB.LAST_CRAFTING_COST:Save(entry.recipeData)
                        end
                    end
                end
            else
                Logger:LogDebug("Skipping non-profitable recipe: " .. effectiveRD.recipeName)
            end
        end
    end

    CraftSim.CRAFTQ.UI:Update()
end

---@param mode string
---@return string
function CraftSim.CRAFT_LISTS:GetConcentrationModeLabel(mode)
    if mode == CONC_MODE.DISABLED then
        return L("CRAFT_LISTS_OPTIONS_CONCENTRATION_DISABLED")
    elseif mode == CONC_MODE.SINGLE then
        return L("CRAFT_LISTS_OPTIONS_CONCENTRATION_SINGLE")
    elseif mode == CONC_MODE.MULTI then
        return L("CRAFT_LISTS_OPTIONS_CONCENTRATION_MULTI")
    end
    return L("CRAFT_LISTS_OPTIONS_CONCENTRATION_ENABLED")
end

--- Build a tooltip text string summarizing a craft list's optimization and restock options
---@param list CraftSim.CraftList
---@return string
function CraftSim.CRAFT_LISTS:BuildOptionsTooltipText(list)
    local options = CraftSim.DB.CRAFT_LISTS.NormalizeListOptions(list.options)
    local lines = {}
    local function yn(v) return v and f.g("Yes") or f.r("No") end

    table.insert(lines, L("CRAFT_LISTS_OPTIONS_TOOLTIP_HEADER"))
    local concentrationMode = self:GetConcentrationMode(options)
    table.insert(lines,
        "  " ..
        L("CRAFT_LISTS_OPTIONS_CONCENTRATION") ..
        ": " .. f.bb(self:GetConcentrationModeLabel(concentrationMode)))
    if concentrationMode ~= CONC_MODE.DISABLED then
        table.insert(lines,
            "  " .. L("CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION") .. ": " .. yn(options.optimizeConcentration))
        if concentrationMode == CONC_MODE.SINGLE or concentrationMode == CONC_MODE.MULTI then
            table.insert(lines,
                "  " .. L("CRAFT_LISTS_OPTIONS_OFFSET_CONCENTRATION") .. ": " .. yn(options.offsetConcentrationCraftAmount))
        end
    end
    table.insert(lines, "  " .. L("CRAFT_LISTS_OPTIONS_OPTIMIZE_TOOLS") .. ": " .. yn(options.optimizeProfessionTools))
    table.insert(lines,
        "  " .. L("CRAFT_LISTS_OPTIONS_OPTIMIZE_FINISHING") .. ": " .. yn(options.optimizeFinishingReagents))
    table.insert(lines,
        "  " ..
        L("CRAFT_LISTS_OPTIONS_REAGENT_ALLOCATION") ..
        ": " .. f.bb(tostring(options.reagentAllocation or "OPTIMIZE_HIGHEST")))

    table.insert(lines, "")
    table.insert(lines, L("CRAFT_LISTS_OPTIONS_TOOLTIP_RESTOCK_HEADER"))
    table.insert(lines, "  " .. L("CRAFT_LISTS_OPTIONS_RESTOCK_AMOUNT") .. f.bb(tostring(options.restockAmount or 1)))
    table.insert(lines, "  " .. L("CRAFT_LISTS_OPTIONS_ENABLE_UNLEARNED") .. ": " .. yn(options.enableUnlearned))
    table.insert(lines, "  " .. L("CRAFT_LISTS_OPTIONS_ONLY_PROFITABLE") .. ": " .. yn(options.onlyProfitable))
    table.insert(lines,
        "  " .. L("CRAFT_LISTS_SKIP_OWNED_MATERIAL_COSTS_LABEL") .. ": " .. yn(options.skipOwnedMaterialCosts))

    return f.white(table.concat(lines, "\n"))
end

--- Queue all craft lists that are selected for queue by the current character.
--- Phase 1: all lists are *scanned* (no queuing) – for lists with
---   includeSoulboundFinishingReagents enabled every recipe is scanned twice
---   (with and without SBF) to allow accurate global triage.
--- Phase 2: TriageAndQueue performs global SBF + cooldown + smart-concentration
---   triage and then populates the craft queue.
---@param crafterUID? CrafterUID
function CraftSim.CRAFT_LISTS:QueueSelectedLists(crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    Logger:LogDebug("QueueSelectedLists called with crafterUID: " .. crafterUID)
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()
    self.isQueueingSelectedLists = true
    self:SetQueueCraftListsButtonState(true)

    local allLists = CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)
    local selectedLists = GUTIL:Filter(allLists, function(list)
        return CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, list.id)
    end)

    if #selectedLists == 0 then
        self.isQueueingSelectedLists = false
        self:SetQueueCraftListsButtonState(false)
        return
    end

    local useOwnedReagentPool = GUTIL:Some(selectedLists, function(list)
        local opts = CraftSim.DB.CRAFT_LISTS.NormalizeListOptions(list.options)
        return opts.skipOwnedMaterialCosts
    end)
    if useOwnedReagentPool then
        CraftSim.CRAFTQ:InitOwnedReagentPool()
    end

    ---@type { total: number, count: number }
    local recipeQueueProgress = { total = 0, count = 0 }
    for _, list in ipairs(selectedLists) do
        recipeQueueProgress.total = recipeQueueProgress.total + #GetRecipeEntries(list)
    end

    ---@type CraftSim.CRAFT_LISTS.ScanEntry[]
    local allScanEntries = {}

    ---@param cancelled boolean?
    local function finishQueue(cancelled)
        cancelled = cancelled == true
        -- Global triage: SBF allocation, cooldown triage, smart concentration, then queue.
        if not cancelled then
            CraftSim.CRAFT_LISTS:TriageAndQueue(allScanEntries)
        end
        self.isQueueingSelectedLists = false
        self:SetQueueCraftListsButtonState(false)
        CraftSim.CRAFTQ:ClearOwnedReagentPool()
        CraftSim.CRAFTQ.UI:Update()
        if not cancelled then
            CraftSim.CRAFTQ:TriggerQueueProcessFinishedEvent("craft_lists")
        end
    end

    local listIndex = 1

    local function processNextList()
        if not self.isQueueingSelectedLists then
            finishQueue(true)
            return
        end

        if listIndex > #selectedLists then
            finishQueue()
            return
        end

        local list = selectedLists[listIndex]
        listIndex = listIndex + 1

        Logger:LogDebug("Scanning list: " .. list.name)

        CraftSim.CRAFT_LISTS:ScanList(list, crafterUID, allScanEntries, processNextList, recipeQueueProgress)
    end

    processNextList()
end

--- Scan a single craft list, collecting optimized RecipeData into *allScanEntries* without
--- queuing anything.
---
--- For lists that have `includeSoulboundFinishingReagents` enabled, any recipe whose
--- optimised result uses a soulbound finishing reagent is also optimised a *second* time
--- without SBF.  Both the with-SBF and without-SBF RecipeData objects are stored in the
--- ScanEntry so that TriageAndQueue can make an accurate global allocation decision.
---
---@param list CraftSim.CraftList
---@param crafterUID? CrafterUID
---@param allScanEntries CraftSim.CRAFT_LISTS.ScanEntry[] entries are appended in-place
---@param finally? function called after all recipes in the list have been scanned
---@param recipeQueueProgress { total: number, count: number }? when set (e.g. multi-list queue), button text appends (n/total) while simulating
function CraftSim.CRAFT_LISTS:ScanList(list, crafterUID, allScanEntries, finally, recipeQueueProgress)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    local recipeEntries = list and GetRecipeEntries(list) or {}
    if not list or #recipeEntries == 0 then
        if finally then finally() end
        return
    end

    local options = list.options or CraftSim.DB.CRAFT_LISTS.DefaultOptions()

    local playerCrafterData = CraftSim.UTIL:GetPlayerCrafterData()

    local queueListsButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsButton --[[@as GGUI.Button?]]

    ---@param recipeData CraftSim.RecipeData
    ---@param recipeEntry CraftSim.CraftListRecipeEntry
    ---@return number? queueAmount
    local function getMaxQueueAmount(recipeData, recipeEntry)
        local offsetAmount = tonumber(options.offsetQueueAmount) or 0
        local queueAmount
        local recipeMaxQueueAmount

        if not recipeData.resultData or not recipeData.resultData.expectedItem then
            return nil
        end

        -- set maximum queue amount by cooldown charges if available
        if recipeData.cooldownData.isCooldownRecipe then
            local charges = recipeData.cooldownData:GetCurrentCharges() or 0
            recipeMaxQueueAmount = charges
        end

        -- if no other max is set, the max we want to queue is the cd charges or if no cd the offsetamount if its greater than 0, otherwise just queue 1
        if not options.useTSMRestockExpression and not (recipeEntry and recipeEntry.restockMaxAmount and recipeEntry.restockMaxAmount > 0) then
            return recipeMaxQueueAmount
        end

        -- adapt by TSM restock expression if enabled and available, otherwise use restockmaxamount if set
        if TSM_API and options.useTSMRestockExpression then
            local itemLink = recipeData.resultData.expectedItem:GetItemLink()
            if itemLink then
                local tsmItemString = TSM_API.ToItemString(itemLink)
                if tsmItemString then
                    local tsmAmount = TSM_API.GetCustomPriceValue(
                        options.tsmRestockExpression or "1",
                        tsmItemString) or 0
                    local maxTSMAmount = tsmAmount + offsetAmount
                    recipeMaxQueueAmount = recipeMaxQueueAmount and math.min(recipeMaxQueueAmount, maxTSMAmount) or
                        maxTSMAmount
                end
            end
        elseif recipeEntry and recipeEntry.restockMaxAmount and recipeEntry.restockMaxAmount > 0 then
            local maxRestockAmount = recipeEntry.restockMaxAmount + offsetAmount
            recipeMaxQueueAmount = recipeMaxQueueAmount and math.min(recipeMaxQueueAmount, maxRestockAmount) or
                maxRestockAmount
        end

        if not recipeMaxQueueAmount then
            return nil
        end

        return GetRestockQueueAmountForRecipeEntry(
            recipeData,
            recipeEntry,
            options.includeAltInventory,
            recipeMaxQueueAmount,
            options.subtractInventory)
    end

    ---@param frameDistributor GUTIL.FrameDistributor
    ---@param recipeEntry CraftSim.CraftListRecipeEntry
    local function processRecipe(frameDistributor, recipeEntry)
        if recipeQueueProgress then
            recipeQueueProgress.count = recipeQueueProgress.count + 1
            if queueListsButton then
                local suffix = FormatRecipeQueueProgressSuffix(recipeQueueProgress)
                if suffix ~= "" then
                    queueListsButton:SetText(L("CRAFT_LISTS_QUEUE_BUTTON_LABEL") .. suffix)
                end
            end
        end

        local recipeID = recipeEntry.recipeID
        -- Try Cache
        local recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, recipeID)
        if not recipeInfo and CraftSim.UTIL:GetPlayerCrafterUID() == crafterUID then
            -- fallback to global recipe info if crafter-specific info is not available for the current player
            recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            if recipeInfo then
                CraftSim.DB.CRAFTER:SaveRecipeInfo(crafterUID, recipeID, recipeInfo)
            else
                frameDistributor:Continue()
                return
            end
        end

        if not recipeInfo or recipeInfo.isDummyRecipe or recipeInfo.isGatheringRecipe
            or recipeInfo.isRecraft or recipeInfo.isSalvageRecipe then
            if not recipeInfo then
                Logger:LogDebug("Failed to get recipe info for recipeID: " .. recipeID, false, false, 1)
            else
                Logger:LogDebug(
                    "Skipping unsupported recipe (dummy/gathering/recraft/salvage): " ..
                    recipeInfo.name .. " (recipeID: " .. recipeID .. ")", false, false, 1)
            end
            frameDistributor:Continue()
            return
        end

        -- Skip unlearned recipes unless enableUnlearned option is set
        if not options.enableUnlearned and not recipeInfo.learned then
            Logger:LogDebug("Skipping unlearned recipe: " .. recipeInfo.name, false, false, 1)
            frameDistributor:Continue()
            return
        end

        Logger:LogDebug("Processing recipe: " .. recipeInfo.name .. " (crafterUID: " .. crafterUID .. ")")

        local recipeData = CraftSim.RecipeData { recipeID = recipeID, crafterData = playerCrafterData }

        if not recipeData then
            Logger:LogDebug("Failed to create RecipeData", false, false, 1)
            frameDistributor:Continue()
            return
        end

        recipeData.craftListID = list.id

        local reagentAllocation = options.reagentAllocation or "OPTIMIZE_HIGHEST"
        local SCAN_MODES = CraftSim.RECIPE_SCAN.SCAN_MODES
        if reagentAllocation == SCAN_MODES.Q1 then
            recipeData.reagentData:SetReagentsMaxByQuality(1)
        elseif reagentAllocation == SCAN_MODES.Q2 then
            recipeData.reagentData:SetReagentsMaxByQuality(2)
        elseif reagentAllocation == SCAN_MODES.Q3 then
            if recipeData:IsSimplifiedQualityRecipe() then
                recipeData.reagentData:SetReagentsMaxByQuality(2)
            else
                recipeData.reagentData:SetReagentsMaxByQuality(3)
            end
        else
            -- OPTIMIZE_* modes (and legacy "OPTIMIZE"): use cheapest quality as base for optimization
            recipeData:SetCheapestQualityReagentsMax()
        end

        -- Derive reagent optimize options from the allocation mode
        -- OPTIMIZE_HIGHEST and legacy "OPTIMIZE" leave optimizeReagentOptions as nil (default: optimize to highest quality)
        local optimizeReagentOptions = nil
        local targetQuality = nil
        if reagentAllocation == "OPTIMIZE_MOST_PROFITABLE" then
            optimizeReagentOptions = { highestProfit = true }
        else
            targetQuality = tonumber(string.match(reagentAllocation, "^OPTIMIZE_TARGET_(%d+)$"))
            if targetQuality then
                optimizeReagentOptions = { minQuality = targetQuality, maxQuality = targetQuality }
            end
        end
        optimizeReagentOptions = ApplySupportedQualitiesToOptimizeOptions(recipeEntry, recipeData, optimizeReagentOptions)

        if recipeData.supportsQualities and options.enableConcentration then
            recipeData.concentrating = true
        end
        recipeData:Update()

        -- check if recipeData is on cooldown, and skip if it is
        if recipeData:OnCooldown() then
            Logger:LogDebug("Skipping recipe on cooldown: " .. recipeData.recipeName)
            frameDistributor:Continue()
            return
        end

        local iconSize = 15
        local recipeIcon = GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize)
        local professionIcon = GUTIL:IconToText(
            CraftSim.CONST.PROFESSION_ICONS[recipeData.professionData.professionInfo.profession], iconSize, iconSize)
        local bagIcon = CreateAtlasMarkup("Banker", iconSize, iconSize)
        local concentrationIcon = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, iconSize, iconSize)

        -- Build the finishing-reagent optimisation options for the WITH-SBF pass.
        local finishingOptsWithSBF = options.optimizeFinishingReagents and {
            includeLocked = false,
            includeSoulbound = options.includeSoulboundFinishingReagents,
            onlyHighestQualitySoulbound = options.onlyHighestQualitySoulboundFinishingReagents,
            permutationBased = (options.finishingReagentsAlgorithm or "SIMPLE") == "PERMUTATION",
            progressUpdateCallback = function(progress)
                if queueListsButton then
                    queueListsButton:SetText(string.format(" %s %s %s - %.0f%%%s",
                        professionIcon,
                        recipeIcon,
                        bagIcon,
                        progress,
                        FormatRecipeQueueProgressSuffix(recipeQueueProgress)))
                end
            end,
        } or nil

        recipeData:Optimize {
            optimizeReagentOptions = optimizeReagentOptions,
            optimizeConcentration = options.optimizeConcentration,
            optimizeConcentrationProgressCallback = function(progress)
                if queueListsButton then
                    queueListsButton:SetText(string.format(" %s %s %s - %.0f%%%s",
                        professionIcon,
                        recipeIcon,
                        concentrationIcon,
                        progress,
                        FormatRecipeQueueProgressSuffix(recipeQueueProgress)))
                end
            end,
            optimizeGear = options.optimizeProfessionTools,
            optimizeFinishingReagentsOptions = finishingOptsWithSBF,
            finally = function()
                if not CraftSim.CRAFT_LISTS.isQueueingSelectedLists then
                    frameDistributor:Break()
                    return
                end

                -- Apply onlyProfitable against the WITH-SBF version (best-case scenario).
                -- If SBF turns out to be unavailable, the effective (no-SBF) profit is checked
                -- again during TriageAndQueue before the entry is actually queued.
                -- When skipOwnedMaterialCosts is on, onlyProfitable is deferred to triage (pool order unknown here).
                if options.onlyProfitable and not options.skipOwnedMaterialCosts
                    and recipeData.averageProfitCached and recipeData.averageProfitCached <= 0 then
                    Logger:LogDebug("Skipping non-profitable recipe: " .. recipeData.recipeName)
                    frameDistributor:Continue()
                    return
                end

                if targetQuality and recipeData.resultData.expectedQuality < targetQuality then
                    Logger:LogDebug("Skipping not targetQuality: " .. recipeData.recipeName)
                    frameDistributor:Continue()
                    return
                end
                if not RecipeMeetsSupportedQualities(recipeData, recipeEntry) then
                    Logger:LogDebug("Skipping unsupported gear quality: " .. recipeData.recipeName)
                    frameDistributor:Continue()
                    return
                end
                local maxQueueAmount = getMaxQueueAmount(recipeData, recipeEntry)
                Logger:LogDebug("maxQueueAmount for recipe " ..
                    recipeData.recipeName .. ": " .. (maxQueueAmount or "nil"))

                if maxQueueAmount ~= nil and maxQueueAmount <= 0 then
                    Logger:LogDebug("Skipping recipe at or above restock cap: " .. recipeData.recipeName)
                    frameDistributor:Continue()
                    return
                end

                -- If the recipe uses SBF and the list has the SBF option enabled,
                -- also produce a without-SBF version so that the triage step can compare
                -- the two correctly (e.g. for smart-concentration value ordering).
                local needsNoSBFScan = options.includeSoulboundFinishingReagents
                    and recipeData:IsUsingSoulboundFinishingReagent()

                if needsNoSBFScan then
                    -- Copy the optimised state, then re-optimise finishing reagents
                    -- with includeSoulbound = false to get the best non-SBF result.
                    local recipeDataNoSBF = recipeData:Copy()
                    recipeDataNoSBF.craftListID = list.id

                    -- Without-SBF finishing-reagent options (no progress callback needed).
                    local finishingOptsNoSBF = options.optimizeFinishingReagents and {
                        includeLocked = false,
                        includeSoulbound = false,
                        onlyHighestQualitySoulbound = false,
                        permutationBased = (options.finishingReagentsAlgorithm or "SIMPLE") == "PERMUTATION",
                    } or nil

                    recipeDataNoSBF:Optimize {
                        optimizeReagentOptions = optimizeReagentOptions,
                        optimizeConcentration = options.optimizeConcentration,
                        optimizeGear = options.optimizeProfessionTools,
                        optimizeFinishingReagentsOptions = finishingOptsNoSBF,
                        finally = function()
                            if not CraftSim.CRAFT_LISTS.isQueueingSelectedLists then
                                frameDistributor:Break()
                                return
                            end

                            tinsert(allScanEntries, {
                                list = list,
                                options = options,
                                recipeEntry = recipeEntry,
                                crafterUID = crafterUID,
                                recipeData = recipeData,
                                recipeDataNoSBF = recipeDataNoSBF,
                                maxQueueAmount = maxQueueAmount,
                            })
                            frameDistributor:Continue()
                        end,
                    }
                else
                    tinsert(allScanEntries, {
                        list = list,
                        options = options,
                        recipeEntry = recipeEntry,
                        crafterUID = crafterUID,
                        recipeData = recipeData,
                        recipeDataNoSBF = nil,
                        maxQueueAmount = maxQueueAmount,
                    })
                    frameDistributor:Continue()
                end
            end,
        }
    end

    GUTIL.FrameDistributor {
        iterationTable = recipeEntries,
        iterationsPerFrame = 1,
        maxIterations = 1000,
        finally = function()
            if finally then finally() end
        end,
        continue = function(frameDistributor, _, recipeEntry)
            processRecipe(frameDistributor, recipeEntry)
        end,
        cancel = function()
            return not CraftSim.CRAFT_LISTS.isQueueingSelectedLists
        end,
    }:Continue()
end

--- Queue a single craft list.
--- Uses ScanList followed by TriageAndQueue so that SBF, cooldown, and
--- smart-concentration triage is applied even for single-list queuing.
---@param list CraftSim.CraftList
---@param crafterUID? CrafterUID
---@param finally? function called after all recipes in the list are queued
function CraftSim.CRAFT_LISTS:QueueList(list, crafterUID, finally)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    ---@type CraftSim.CRAFT_LISTS.ScanEntry[]
    local scanEntries = {}

    CraftSim.CRAFT_LISTS:ScanList(list, crafterUID, scanEntries, function()
        CraftSim.CRAFT_LISTS:TriageAndQueue(scanEntries)
        if finally then finally() end
    end)
end
