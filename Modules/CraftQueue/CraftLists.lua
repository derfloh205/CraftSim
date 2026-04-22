---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.CRAFT_LISTS
CraftSim.CRAFT_LISTS = {}

local Logger = CraftSim.DEBUG:RegisterLogger("CraftLists")

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

--- Performs global triage of all scan entries collected across every selected craft list,
--- then queues the winning combinations.
---
--- Replaces the former per-list finalizeList() + post-process ApplySmartQueueing() approach.
---
--- Pass order:
---   1. Global SBF allocation – for each SBF item, entries are sorted by their WITH-SBF
---      priority and SBF uses are assigned to the highest-value recipes across all lists.
---   2. Global smart concentration queueing – for entries in lists that have
---      smartConcentrationQueuing enabled, entries are grouped by crafter+profession and
---      sorted by the *effective* (post-SBF) concentration value.  Only the top-ranked
---      recipe per group receives concentration; all others in the group are dropped.
---      This step runs BEFORE cooldown triage so that concentration-limited craft counts
---      (stored in entryOverrideAmount) are known when cooldown charges are distributed.
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

    -- ── Step 2: Global Smart Concentration Queueing ──────────────────────────
    -- Runs BEFORE cooldown triage so that concentration-limited craft counts are
    -- already in entryOverrideAmount when the cooldown step distributes charges.
    -- This ensures charges freed by concentration limits (e.g. a concentrating entry
    -- can only use 3 of 5 available cooldown charges) are redistributed to other
    -- entries sharing the same cooldown instead of being silently discarded.
    --
    -- Only applies to entries from lists that have smartConcentrationQueuing enabled.
    -- Entries are grouped globally by crafterUID:professionSkillLineID so that
    -- concentration is shared across craft lists (not allocated per-list).
    ---@type table<string, { currentAmount: number, entries: { entry: CraftSim.CRAFT_LISTS.ScanEntry, rd: CraftSim.RecipeData }[] }>
    local concentrationGroups = {}

    for _, entry in ipairs(allScanEntries) do
        local opts = entry.options
        if opts.enableConcentration and opts.smartConcentrationQueuing then
            local rd = entryEffectiveRD[entry]
            if rd.concentrating and rd.concentrationCost and rd.concentrationCost > 0 then
                local key = entry.crafterUID .. ":" .. rd.professionData.skillLineID
                if not concentrationGroups[key] then
                    concentrationGroups[key] = {
                        currentAmount = (rd.concentrationData and rd.concentrationData:GetCurrentAmount()) or 0,
                        entries = {},
                    }
                end
                tinsert(concentrationGroups[key].entries, { entry = entry, rd = rd })
            end
        end
    end

    for _, group in pairs(concentrationGroups) do
        -- Sort by effective concentration value (post SBF allocation).
        table.sort(group.entries, function(a, b)
            return a.rd:GetConcentrationValue() > b.rd:GetConcentrationValue()
        end)
        local currentConcentration = group.currentAmount
        local picked = false
        for _, item in ipairs(group.entries) do
            local entry = item.entry
            local rd = item.rd
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

            if not picked and queueableAmount > 0 then
                -- Cap SBF crafts to the concentration-limited amount.
                local sbfCrafts = entrySbfCrafts[entry] or 0
                if sbfCrafts > queueableAmount then
                    entrySbfCrafts[entry] = queueableAmount
                end
                entryOverrideAmount[entry] = queueableAmount
                currentConcentration = currentConcentration - (concentrationCost * queueableAmount)
                picked = true
            else
                -- smartConcentrationQueuing: only one recipe per profession gets queued.
                skipEntry[entry] = true
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
                elseif assigned < committed then
                    entryOverrideAmount[entry] = assigned
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
            local profitableOk = not opts.onlyProfitable
                or not effectiveRD.averageProfitCached
                or effectiveRD.averageProfitCached > 0

            if profitableOk then
                local sbfCrafts = entrySbfCrafts[entry] or 0
                local totalAmount = entryOverrideAmount[entry] or entry.maxQueueAmount or 1
                local noSbfCrafts = math.max(0, totalAmount - sbfCrafts)

                -- Queue the with-SBF portion.
                if sbfCrafts > 0 then
                    CraftSim.CRAFTQ.craftQueue:AddRecipe({
                        recipeData = entry.recipeData,
                        amount = sbfCrafts,
                    })
                end

                -- Queue the without-SBF portion using the dedicated no-SBF recipe data when available.
                if noSbfCrafts > 0 then
                    local noSbfRD = (sbfCrafts > 0 and entry.recipeDataNoSBF) or effectiveRD
                    CraftSim.CRAFTQ.craftQueue:AddRecipe({
                        recipeData = noSbfRD,
                        amount = noSbfCrafts,
                    })
                end

                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST") then
                    CraftSim.DB.LAST_CRAFTING_COST:Save(entry.recipeData)
                end
            else
                Logger:LogDebug("Skipping non-profitable recipe: " .. effectiveRD.recipeName)
            end
        end
    end

    CraftSim.CRAFTQ.UI:UpdateDisplay()
end

--- Build a tooltip text string summarizing a craft list's optimization and restock options
---@param list CraftSim.CraftList
---@return string
function CraftSim.CRAFT_LISTS:BuildOptionsTooltipText(list)
    local options = list.options or CraftSim.DB.CRAFT_LISTS.DefaultOptions()
    local lines = {}
    local function yn(v) return v and f.g("Yes") or f.r("No") end

    table.insert(lines, L("CRAFT_LISTS_OPTIONS_TOOLTIP_HEADER"))
    table.insert(lines, "  " .. L("CRAFT_LISTS_OPTIONS_ENABLE_CONCENTRATION") .. ": " .. yn(options.enableConcentration))
    table.insert(lines,
        "  " .. L("CRAFT_LISTS_OPTIONS_OPTIMIZE_CONCENTRATION") .. ": " .. yn(options.optimizeConcentration))
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

    local allLists = CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)
    local selectedLists = GUTIL:Filter(allLists, function(list)
        return CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, list.id)
    end)

    if #selectedLists == 0 then
        return
    end

    local queueListsButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsButton --[[@as GGUI.Button?]]

    if queueListsButton then
        queueListsButton:SetEnabled(false)
    end

    ---@type CraftSim.CRAFT_LISTS.ScanEntry[]
    local allScanEntries = {}

    local function finishQueue()
        -- Global triage: SBF allocation, cooldown triage, smart concentration, then queue.
        CraftSim.CRAFT_LISTS:TriageAndQueue(allScanEntries)
        if queueListsButton then
            queueListsButton:SetStatus("Ready")
        end
        CraftSim.CRAFTQ.UI:Update()
        CraftSim.CRAFTQ:CreateAutoShoppingListAfterQueue()
    end

    local listIndex = 1

    local function processNextList()
        if listIndex > #selectedLists then
            finishQueue()
            return
        end

        local list = selectedLists[listIndex]
        listIndex = listIndex + 1

        Logger:LogDebug("Scanning list: " .. list.name)

        CraftSim.CRAFT_LISTS:ScanList(list, crafterUID, allScanEntries, processNextList)
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
function CraftSim.CRAFT_LISTS:ScanList(list, crafterUID, allScanEntries, finally)
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

        -- baseline the queue amount is the maximum possible
        queueAmount = recipeMaxQueueAmount

        -- reduce queue amount by current inventory if option is set
        -- (this subtracts the number of RESULT items already owned, not reagents)
        if options.subtractInventory then
            local itemID = recipeData.resultData.expectedItem:GetItemID()
            local itemLink = recipeData.resultData.expectedItem:GetItemLink()
            if itemID or itemLink then
                local owned = CraftSim.INVENTORY_SOURCE:GetInventoryCount(itemLink or itemID,
                    options.includeAltInventory) or 0
                queueAmount = math.max(0, queueAmount - owned)
            end
        end

        return queueAmount
    end

    ---@param frameDistributor GUTIL.FrameDistributor
    ---@param recipeEntry CraftSim.CraftListRecipeEntry
    local function processRecipe(frameDistributor, recipeEntry)
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
                    queueListsButton:SetText(string.format(" %s %s %s - %.0f%%",
                        professionIcon,
                        recipeIcon,
                        bagIcon,
                        progress))
                end
            end,
        } or nil

        recipeData:Optimize {
            optimizeReagentOptions = optimizeReagentOptions,
            optimizeConcentration = options.optimizeConcentration,
            optimizeConcentrationProgressCallback = function(progress)
                if queueListsButton then
                    queueListsButton:SetText(string.format(" %s %s %s - %.0f%%",
                        professionIcon,
                        recipeIcon,
                        concentrationIcon,
                        progress))
                end
            end,
            optimizeGear = options.optimizeProfessionTools,
            optimizeFinishingReagentsOptions = finishingOptsWithSBF,
            finally = function()
                -- Apply onlyProfitable against the WITH-SBF version (best-case scenario).
                -- If SBF turns out to be unavailable, the effective (no-SBF) profit is checked
                -- again during TriageAndQueue before the entry is actually queued.
                if options.onlyProfitable and recipeData.averageProfitCached and recipeData.averageProfitCached <= 0 then
                    Logger:LogDebug("Skipping non-profitable recipe: " .. recipeData.recipeName)
                    frameDistributor:Continue()
                    return
                end

                if targetQuality and recipeData.resultData.expectedQuality < targetQuality then
                    Logger:LogDebug("Skipping not targetQuality: " .. recipeData.recipeName)
                    frameDistributor:Continue()
                    return
                end
                local maxQueueAmount = getMaxQueueAmount(recipeData, recipeEntry)
                Logger:LogDebug("maxQueueAmount for recipe " ..
                recipeData.recipeName .. ": " .. (maxQueueAmount or "nil"))

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
