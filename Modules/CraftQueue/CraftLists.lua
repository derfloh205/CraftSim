---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.CRAFT_LISTS
CraftSim.CRAFT_LISTS = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.CraftLists")

--- Returns a sort-priority comparator for smart cooldown / soulbound triage.
--- Concentrating recipes always outrank non-concentrating ones.
--- Among concentrating items, sort by concentration value (from GetConcentrationValue()).
--- Among non-concentrating items, sort by average profit.
---@param a CraftSim.CraftQueueItem
---@param b CraftSim.CraftQueueItem
---@return boolean aBeforeB
local function sortBySmartPriority(a, b)
    local aRd, bRd = a.recipeData, b.recipeData
    if aRd.concentrating ~= bRd.concentrating then
        return aRd.concentrating -- true sorts before false
    end
    if aRd.concentrating then
        local aVal = aRd:GetConcentrationValue()
        local bVal = bRd:GetConcentrationValue()
        return aVal > bVal
    else
        return (aRd.averageProfitCached or 0) > (bRd.averageProfitCached or 0)
    end
end

--- After all lists have been queued, apply smart triage so that cooldown charges
--- and limited soulbound finishing reagents are assigned to the highest-value
--- queue entries first (concentration crafts take priority, then by value).
--- Entries that receive zero allocation are removed from the queue.
function CraftSim.CRAFT_LISTS:ApplySmartQueueing()
    local craftQueue = CraftSim.CRAFTQ.craftQueue
    if not craftQueue then return end

    -- ── Smart Cooldown Queueing ──────────────────────────────────────────────
    -- Group cooldown-recipe CQIs by crafterUID:recipeID (ignoring craftListID).
    ---@type table<string, CraftSim.CraftQueueItem[]>
    local cooldownGroups = {}
    for _, cqi in ipairs(craftQueue.craftQueueItems) do
        if cqi.recipeData.cooldownData.isCooldownRecipe then
            local key = cqi.recipeData:GetCrafterUID() .. ":" .. cqi.recipeData.recipeID
            cooldownGroups[key] = cooldownGroups[key] or {}
            tinsert(cooldownGroups[key], cqi)
        end
    end

    local toRemove = {}
    for _, group in pairs(cooldownGroups) do
        if #group > 1 then
            -- Determine available charges from the first item (all share the same recipe)
            local availableCharges = group[1].recipeData.cooldownData:GetCurrentCharges() or 0
            table.sort(group, sortBySmartPriority)
            for _, cqi in ipairs(group) do
                if availableCharges <= 0 then
                    tinsert(toRemove, cqi)
                else
                    local assigned = math.min(cqi.amount, availableCharges)
                    availableCharges = availableCharges - assigned
                    if assigned == 0 then
                        tinsert(toRemove, cqi)
                    else
                        cqi.amount = assigned
                    end
                end
            end
        end
    end

    -- ── Smart Soulbound Finisher Queueing ────────────────────────────────────
    -- Group CQIs that use a soulbound finishing reagent by crafterUID:recipeID:itemID.
    ---@type table<string, {items: CraftSim.CraftQueueItem[], perCraft: number, owned: number}>
    local soulboundGroups = {}
    for _, cqi in ipairs(craftQueue.craftQueueItems) do
        local sbItemID, perCraft = cqi.recipeData:GetSoulboundFinishingReagentInfo()
        if sbItemID then
            local crafterUID = cqi.recipeData:GetCrafterUID()
            local key = crafterUID .. ":" .. cqi.recipeData.recipeID .. ":" .. sbItemID
            if not soulboundGroups[key] then
                local owned = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, sbItemID, true) or 0
                soulboundGroups[key] = { items = {}, perCraft = perCraft or 1, owned = owned }
            end
            tinsert(soulboundGroups[key].items, cqi)
        end
    end

    for _, group in pairs(soulboundGroups) do
        if #group.items > 1 then
            local availableSoulbound = math.floor(group.owned / group.perCraft)
            table.sort(group.items, sortBySmartPriority)
            for _, cqi in ipairs(group.items) do
                if availableSoulbound <= 0 then
                    tinsert(toRemove, cqi)
                else
                    local assigned = math.min(cqi.amount, availableSoulbound)
                    availableSoulbound = availableSoulbound - assigned
                    if assigned == 0 then
                        tinsert(toRemove, cqi)
                    else
                        cqi.amount = assigned
                    end
                end
            end
        end
    end

    -- Perform removals (deduplicated to avoid double-removal crashes)
    local removed = {}
    for _, cqi in ipairs(toRemove) do
        if not removed[cqi] then
            removed[cqi] = true
            craftQueue:Remove(cqi)
        end
    end
end

--- Queue all craft lists that are selected for queue by the current character
---@param crafterUID? CrafterUID
function CraftSim.CRAFT_LISTS:QueueSelectedLists(crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    print("QueueSelectedLists called with crafterUID: " .. crafterUID)
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

    local function finishQueue()
        -- Triage cooldown charges and soulbound finishing reagents across all queued lists
        CraftSim.CRAFT_LISTS:ApplySmartQueueing()
        if queueListsButton then
            queueListsButton:SetStatus("Ready")
        end
        CraftSim.CRAFTQ.UI:UpdateDisplay()
        -- auto shopping list is a general CraftQueue option
        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST")
            and CraftSim.CRAFTQ.CreateAuctionatorShoppingList then
            CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
        end
    end

    local listIndex = 1

    local function processNextList()
        if listIndex > #selectedLists then
            finishQueue()
            return
        end

        local list = selectedLists[listIndex]
        listIndex = listIndex + 1

        print("Queueing list: " .. list.name)

        CraftSim.CRAFT_LISTS:QueueList(list, crafterUID, processNextList)
    end

    processNextList()
end

--- Queue a single craft list
---@param list CraftSim.CraftList
---@param crafterUID? CrafterUID
---@param finally? function called after all recipes in the list are queued
function CraftSim.CRAFT_LISTS:QueueList(list, crafterUID, finally)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    if not list or not list.recipeIDs or #list.recipeIDs == 0 then
        if finally then finally() end
        return
    end

    local options = list.options or CraftSim.DB.CRAFT_LISTS.DefaultOptions()

    local playerCrafterData = CraftSim.UTIL:GetPlayerCrafterData()

    ---@type CraftSim.RecipeData[]
    local optimizedRecipes = {}

    local queueListsButton = CraftSim.CRAFTQ.frame and
        CraftSim.CRAFTQ.frame.content and
        CraftSim.CRAFTQ.frame.content.queueTab and
        CraftSim.CRAFTQ.frame.content.queueTab.content and
        CraftSim.CRAFTQ.frame.content.queueTab.content.queueCraftListsButton --[[@as GGUI.Button?]]

    local function finalizeList()
        if options.enableConcentration and options.smartConcentrationQueuing then
            ---@type table<CrafterUID, table<number, CraftSim.RecipeData[]>>
            local crafterUIDProfessionMap = {}

            -- need to map per crafter and per skillline id cause they are all individual concentration currencies
            for _, recipeData in ipairs(optimizedRecipes) do
                if recipeData.concentrating and recipeData.concentrationCost > 0 then
                    local professionSkillLineID = recipeData.professionData.skillLineID
                    local crafterUID = recipeData:GetCrafterUID()
                    crafterUIDProfessionMap[crafterUID] = crafterUIDProfessionMap[crafterUID] or {}
                    crafterUIDProfessionMap[crafterUID][professionSkillLineID] = crafterUIDProfessionMap[crafterUID][professionSkillLineID] or {}
                    tinsert(crafterUIDProfessionMap[crafterUID][professionSkillLineID], recipeData)
                end
            end

            for crafterUID, professionMap in pairs(crafterUIDProfessionMap) do
                for professionSkillLineID, recipeDataList in pairs(professionMap) do
                    local concentrationData = recipeDataList[1].concentrationData
                    table.sort(recipeDataList,
                        function(recipeDataA, recipeDataB)
                            return recipeDataA:GetConcentrationValue() > recipeDataB:GetConcentrationValue()
                        end)
                    local currentConcentration = concentrationData and concentrationData:GetCurrentAmount() or 0
                    for _, recipeData in ipairs(recipeDataList) do
                        if recipeData.concentrationCost > 0 then
                            local concentrationCosts = recipeData.concentrationCost
                            if options.offsetConcentrationCraftAmount then
                                local ingenuityChance = recipeData.professionStats.ingenuity:GetPercent(true)
                                local ingenuityRefund = 0.5 + recipeData.professionStats.ingenuity:GetExtraValue()
                                concentrationCosts = concentrationCosts -
                                    (concentrationCosts * ingenuityChance * ingenuityRefund)
                            end
                            local queueableAmount = math.floor(currentConcentration / concentrationCosts)
                            -- Full cost required for at least one craft; adjusted cost is only for expected count.
                            if currentConcentration < recipeData.concentrationCost then
                                queueableAmount = 0
                            end
                            if queueableAmount > 0 then
                                local offsetAmount = tonumber(options.offsetQueueAmount) or 0
                                local totalAmount = queueableAmount + offsetAmount

                                -- if its a cd recipe, always queue current charge amount at maximum
                                if recipeData.cooldownData.isCooldownRecipe then
                                    totalAmount = math.min(totalAmount, recipeData.cooldownData:GetCurrentCharges())
                                end

                                CraftSim.CRAFTQ:AddRecipe {
                                    recipeData = recipeData,
                                    amount = totalAmount,
                                    splitSoulboundFinishingReagent = options.includeSoulboundFinishingReagents,
                                }

                                -- Update last crafting cost DB if option is enabled
                                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST") then
                                    CraftSim.DB.LAST_CRAFTING_COST:Save(recipeData)
                                end

                                currentConcentration = currentConcentration - (concentrationCosts * queueableAmount)
                                break
                            end
                        end
                    end
                end
            end

            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end
    end

    ---@param frameDistributor GUTIL.FrameDistributor
    ---@param recipeID RecipeID
    local function processRecipe(frameDistributor, recipeID)
        --- Prefer live API for the logged-in character so flags like isGatheringRecipe stay current (craft lists
        --- otherwise keep the first cached snapshot, which breaks gathering-profession journal crafts).
        local recipeInfo
        if CraftSim.UTIL:GetPlayerCrafterUID() == crafterUID then
            recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            if recipeInfo then
                CraftSim.DB.CRAFTER:SaveRecipeInfo(crafterUID, recipeID, recipeInfo)
            end
        end
        if not recipeInfo then
            recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, recipeID)
        end
        if not recipeInfo then
            frameDistributor:Continue()
            return
        end

        local gatheringJournalCraft = recipeInfo and recipeInfo.isGatheringRecipe and
            CraftSim.UTIL:IsSchematicCraftWithRequiredReagents(recipeID)
        if not recipeInfo or recipeInfo.isDummyRecipe or
            (recipeInfo.isGatheringRecipe and not gatheringJournalCraft)
            or recipeInfo.isRecraft or recipeInfo.isSalvageRecipe then
            if not recipeInfo then
                print("Failed to get recipe info for recipeID: " .. recipeID, false, false, 1)
            else
                print("Skipping unsupported recipe (dummy/gathering/recraft/salvage): " .. recipeInfo.name .. " (recipeID: " .. recipeID .. ")", false, false, 1)
            end
            frameDistributor:Continue()
            return
        end

        -- Skip unlearned recipes unless enableUnlearned option is set
        if not options.enableUnlearned and not recipeInfo.learned then
            print("Skipping unlearned recipe: " .. recipeInfo.name, false, false, 1)
            frameDistributor:Continue()
            return
        end

        print("Processing recipe: " .. recipeInfo.name .. " (crafterUID: " .. crafterUID .. ")")

        local recipeData = CraftSim.RecipeData { recipeID = recipeID, crafterData = playerCrafterData }

        if not recipeData then
            print("Failed to create RecipeData", false, false, 1)
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
        if reagentAllocation == "OPTIMIZE_MOST_PROFITABLE" then
            optimizeReagentOptions = { highestProfit = true }
        else
            local targetQuality = tonumber(string.match(reagentAllocation, "^OPTIMIZE_TARGET_(%d+)$"))
            if targetQuality then
                optimizeReagentOptions = { maxQuality = targetQuality }
            end
        end

        if recipeData.supportsQualities and options.enableConcentration then
            recipeData.concentrating = true
        end
        recipeData:Update()

        -- check if recipeData is on cooldown, and skip if it is
        if recipeData:OnCooldown() then
            print("Skipping recipe on cooldown: " .. recipeData.recipeName)
            frameDistributor:Continue()
            return
        end

        local iconSize = 15
        local recipeIcon = GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize)
        local professionIcon = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[recipeData.professionData.professionInfo.profession], iconSize, iconSize)
        local bagIcon = CreateAtlasMarkup("Banker", iconSize, iconSize)
        local concentrationIcon = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, iconSize, iconSize)

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
            optimizeFinishingReagentsOptions = options.optimizeFinishingReagents and {
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
            } or nil,
            finally = function()
                if options.enableConcentration and options.smartConcentrationQueuing then
                    tinsert(optimizedRecipes, recipeData)
                else
                    local offsetAmount = tonumber(options.offsetQueueAmount) or 0
                    local totalAmount = 1 + offsetAmount

                    -- Use TSM restock expression if enabled and available
                    if options.useTSMRestockExpression and TSM_API
                        and recipeData.resultData and recipeData.resultData.expectedItem then
                        local itemLink = recipeData.resultData.expectedItem:GetItemLink()
                        if itemLink then
                            local tsmItemString = TSM_API.ToItemString(itemLink)
                            if tsmItemString then
                                local tsmAmount = TSM_API.GetCustomPriceValue(
                                    options.tsmRestockExpression or "1",
                                    tsmItemString) or 0
                                totalAmount = tsmAmount + offsetAmount
                            end
                        end
                    end

                    -- if its a cd recipe, always queue maximum based on charges
                    if recipeData.cooldownData.isCooldownRecipe then
                        totalAmount = recipeData.cooldownData:GetCurrentCharges()
                    end
                    CraftSim.CRAFTQ:AddRecipe {
                        recipeData = recipeData,
                        amount = totalAmount,
                        splitSoulboundFinishingReagent = options.includeSoulboundFinishingReagents,
                    }
                    CraftSim.CRAFTQ.UI:UpdateDisplay()

                    -- Update last crafting cost DB if option is enabled
                    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_UPDATE_LAST_CRAFTING_COST") then
                        CraftSim.DB.LAST_CRAFTING_COST:Save(recipeData)
                    end
                end
                frameDistributor:Continue()
            end,
        }
    end

    GUTIL.FrameDistributor {
        iterationTable = list.recipeIDs,
        iterationsPerFrame = 1,
        maxIterations = 1000,
        finally = function()
            finalizeList()
            if finally then finally() end
        end,
        continue = function(frameDistributor, _, recipeID)
            processRecipe(frameDistributor, recipeID)
        end,
    }:Continue()
end
