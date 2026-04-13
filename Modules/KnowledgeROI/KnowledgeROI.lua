---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.KNOWLEDGE_ROI
CraftSim.KNOWLEDGE_ROI = {}

---@type GGUI.Frame
CraftSim.KNOWLEDGE_ROI.frame = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.KnowledgeROI")

--- Calculates the ROI of the next knowledge point for every unfinished
--- specialization node that affects the given recipe.
---
--- For each node we:
---   1. Copy recipeData
---   2. Find the matching nodeData in the copy's SpecializationData
---   3. Bump rank +1 and re-calculate stats + profit
---   4. Compute profitDelta = newProfit - baseProfit  (ROI of that 1 point)
---
--- Returns a list sorted by descending roiPerPoint.
---@param recipeData CraftSim.RecipeData
---@return CraftSim.KnowledgeROI.NodeResult[]
function CraftSim.KNOWLEDGE_ROI:CalculateForRecipe(recipeData)
    ---@type CraftSim.KnowledgeROI.NodeResult[]
    local results = {}

    if not recipeData.specializationData or not recipeData.supportsCraftingStats then
        return results
    end

    local baseProfit = CraftSim.CALC:GetAverageProfit(recipeData)

    for nodeIndex, nodeData in ipairs(recipeData.specializationData.nodeData) do
        -- Only calculate for nodes that have remaining ranks and provide stats for this recipe
        if nodeData.rank < nodeData.maxRank and nodeData:HasRelevantStats(recipeData) then
            local result = self:SimulateNodeRankIncrease(recipeData, nodeIndex, nodeData, baseProfit)
            if result then
                tinsert(results, result)
            end
        end
    end

    -- Sort by ROI per point descending
    table.sort(results, function(a, b)
        return a.roiPerPoint > b.roiPerPoint
    end)

    return results
end

--- Simulates bumping one node's rank by 1 and returns the profit delta.
---@param recipeData CraftSim.RecipeData
---@param nodeIndex number index in specializationData.nodeData
---@param nodeData CraftSim.NodeData
---@param baseProfit number
---@return CraftSim.KnowledgeROI.NodeResult?
function CraftSim.KNOWLEDGE_ROI:SimulateNodeRankIncrease(recipeData, nodeIndex, nodeData, baseProfit)
    -- Deep copy recipe data
    local simRecipeData = recipeData:Copy()
    if not simRecipeData.specializationData then return nil end

    local simNodeData = simRecipeData.specializationData.nodeData[nodeIndex]
    if not simNodeData then return nil end

    -- Bump rank by 1
    simNodeData.rank = simNodeData.rank + 1
    simNodeData:Update()

    -- Recalculate SpecializationData profession stats
    simRecipeData.specializationData:UpdateProfessionStats()
    -- Recalculate recipe stats and profit
    simRecipeData:Update()
    local newProfit = CraftSim.CALC:GetAverageProfit(simRecipeData)

    local profitDelta = newProfit - baseProfit

    -- Compute how many remaining ranks and total remaining ROI estimate
    -- (linear approximation for remaining points)
    local remainingRanks = nodeData.maxRank - nodeData.rank
    local totalEstimatedROI = profitDelta * remainingRanks

    ---@type CraftSim.KnowledgeROI.NodeResult
    local result = {
        nodeID = nodeData.nodeID,
        nodeName = nodeData:GetName() or ("Node " .. nodeData.nodeID),
        nodeIcon = nodeData.icon,
        currentRank = nodeData.rank,
        maxRank = nodeData.maxRank,
        remainingRanks = remainingRanks,
        baseProfit = baseProfit,
        projectedProfit = newProfit,
        roiPerPoint = profitDelta,
        totalEstimatedROI = totalEstimatedROI,
    }

    return result
end

--- Full-scan: calculate ROI across all known recipes for the current profession.
--- Uses the recipeMapping from the static specialization data to determine
--- which recipes are affected by which nodes.
---
--- This is the expensive operation that produces the canonical "Knowledge Path"
--- ranking — it considers every recipe, not just the one currently visible.
---
---@param recipeData CraftSim.RecipeData base recipe to extract profession context from
---@param progressCallback? fun(progress: number, total: number)
---@return CraftSim.KnowledgeROI.FullScanResult[]
function CraftSim.KNOWLEDGE_ROI:FullProfessionScan(recipeData, progressCallback)
    CraftSim.DEBUG:StartProfiling("KnowledgeROI.FullProfessionScan")

    ---@type CraftSim.KnowledgeROI.FullScanResult[]
    local results = {}

    local profession = recipeData.professionData.professionInfo.profession
    local expansionID = recipeData.professionData.expansionID
    local profData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
    if not profData or not profData[profession] then
        CraftSim.DEBUG:StopProfiling("KnowledgeROI.FullProfessionScan")
        return results
    end

    local specData = profData[profession]
    local recipeMapping = specData.recipeMapping
    local nodeDataMap = specData.nodeData

    -- Build inverse map: baseNodeID -> {recipeIDs}
    ---@type table<number, table<RecipeID, boolean>>
    local nodeToRecipes = {}
    for recipeID, perkIDs in pairs(recipeMapping) do
        for _, perkID in ipairs(perkIDs) do
            local perkEntry = nodeDataMap[perkID]
            if perkEntry then
                local baseNodeID = perkEntry.nodeID
                nodeToRecipes[baseNodeID] = nodeToRecipes[baseNodeID] or {}
                nodeToRecipes[baseNodeID][recipeID] = true
            end
        end
    end

    -- Collect all unique base node IDs that have remaining ranks
    ---@type table<number, CraftSim.RawPerkData>
    local baseNodes = {}
    for perkID, perkEntry in pairs(nodeDataMap) do
        if perkEntry.base and perkEntry.maxRank and perkEntry.maxRank > 0 then
            baseNodes[perkID] = perkEntry
        end
    end

    -- Get cached recipe IDs for this profession
    local crafterUID = recipeData:GetCrafterUID()
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(crafterUID, profession) or {}
    local cachedRecipeSet = {}
    for _, rid in ipairs(cachedRecipeIDs) do
        cachedRecipeSet[rid] = true
    end

    local total = GUTIL:Count(baseNodes)
    local progress = 0

    for baseNodeID, baseNodeEntry in pairs(baseNodes) do
        progress = progress + 1
        if progressCallback then
            progressCallback(progress, total)
        end

        -- Get current rank from the API
        local configID = C_ProfSpecs.GetConfigIDForSkillLine(recipeData.professionData.skillLineID)
        local nodeInfo = C_Traits.GetNodeInfo(configID, baseNodeID)
        local currentRank = nodeInfo and nodeInfo.activeRank and (nodeInfo.activeRank - 1) or -1

        if currentRank >= 0 and currentRank < baseNodeEntry.maxRank then
            local affectedRecipeIDs = nodeToRecipes[baseNodeID]
            if affectedRecipeIDs then
                local totalDelta = 0
                local recipeImpacts = {}

                for recipeID in pairs(affectedRecipeIDs) do
                    -- Only consider recipes the player actually knows
                    if cachedRecipeSet[recipeID] then
                        local ok, delta, impact = pcall(self.CalculateRecipeNodeDelta, self, recipeID, recipeData,
                            baseNodeID, currentRank)
                        if ok and delta and delta ~= 0 then
                            totalDelta = totalDelta + delta
                            if impact then
                                tinsert(recipeImpacts, impact)
                            end
                        end
                    end
                end

                if totalDelta ~= 0 then
                    -- Sort recipe impacts by profit delta descending
                    table.sort(recipeImpacts, function(a, b)
                        return a.profitDelta > b.profitDelta
                    end)

                    local remainingRanks = baseNodeEntry.maxRank - currentRank

                    ---@type CraftSim.KnowledgeROI.FullScanResult
                    local result = {
                        nodeID = baseNodeID,
                        nodeName = self:GetNodeName(baseNodeID, recipeData) or ("Node " .. baseNodeID),
                        nodeIcon = baseNodeEntry.icon,
                        currentRank = currentRank,
                        maxRank = baseNodeEntry.maxRank,
                        remainingRanks = remainingRanks,
                        roiPerPoint = totalDelta,
                        totalEstimatedROI = totalDelta * remainingRanks,
                        affectedRecipeCount = #recipeImpacts,
                        topRecipes = recipeImpacts,
                    }
                    tinsert(results, result)
                end
            end
        end
    end

    -- Sort by ROI per point descending
    table.sort(results, function(a, b)
        return a.roiPerPoint > b.roiPerPoint
    end)

    -- Cache results
    self:CacheFullScanResults(crafterUID, results, profession, expansionID)

    CraftSim.DEBUG:StopProfiling("KnowledgeROI.FullProfessionScan")
    return results
end

--- Calculate the profit delta for a single recipe when bumping one specific node.
---@param recipeID RecipeID
---@param contextRecipeData CraftSim.RecipeData provides profession data context
---@param targetNodeID number the base node ID to bump
---@param currentRank number current rank of the node
---@return number profitDelta
---@return CraftSim.KnowledgeROIRecipeImpact? impact
function CraftSim.KNOWLEDGE_ROI:CalculateRecipeNodeDelta(recipeID, contextRecipeData, targetNodeID, currentRank)
    -- Create recipe data for this recipe
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if not recipeInfo then return 0, nil end
    if recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then return 0, nil end

    local ok, simRecipe = pcall(CraftSim.RecipeData, {
        recipeID = recipeID,
        crafterData = contextRecipeData.crafterData,
    })
    if not ok or not simRecipe then return 0, nil end
    if not simRecipe.supportsCraftingStats then return 0, nil end
    if not simRecipe.specializationData then return 0, nil end

    -- Base profit
    local baseProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    -- Find the target node in this recipe's spec data and bump its rank
    local found = false
    for _, nodeData in ipairs(simRecipe.specializationData.nodeData) do
        if nodeData.nodeID == targetNodeID then
            if nodeData.rank >= nodeData.maxRank then return 0, nil end
            nodeData.rank = nodeData.rank + 1
            nodeData:Update()
            found = true
            break
        end
    end
    if not found then return 0, nil end

    simRecipe.specializationData:UpdateProfessionStats()
    simRecipe:Update()
    local newProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    local delta = newProfit - baseProfit

    ---@type CraftSim.KnowledgeROIRecipeImpact
    local impact = {
        recipeID = recipeID,
        recipeName = recipeInfo.name or ("Recipe " .. recipeID),
        currentProfit = baseProfit,
        projectedProfit = newProfit,
        profitDelta = delta,
        weeklyEstimate = 0, -- placeholder for future CraftLog integration
    }

    return delta, impact
end

--- Get the display name for a specialization node.
---@param nodeID number
---@param recipeData CraftSim.RecipeData
---@return string?
function CraftSim.KNOWLEDGE_ROI:GetNodeName(nodeID, recipeData)
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(recipeData.professionData.skillLineID)
    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
    if nodeInfo and nodeInfo.entryIDs then
        local entryInfos = GUTIL:Map(nodeInfo.entryIDs, function(entryID)
            return C_Traits.GetEntryInfo(configID, entryID)
        end)
        local definitionInfos = GUTIL:Map(entryInfos, function(entryInfo)
            return C_Traits.GetDefinitionInfo(entryInfo.definitionID)
        end)
        if definitionInfos[1] then
            return definitionInfos[1].overrideName
        end
    end
    return nil
end

--- Caches the full scan results into the DB for later retrieval.
---@param crafterUID CrafterUID
---@param results CraftSim.KnowledgeROI.FullScanResult[]
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
function CraftSim.KNOWLEDGE_ROI:CacheFullScanResults(crafterUID, results, profession, expansionID)
    for _, result in ipairs(results) do
        ---@type CraftSim.KnowledgeROIEntry
        local entry = {
            nodeID = result.nodeID,
            nodeName = result.nodeName,
            profession = profession,
            expansionID = expansionID,
            currentRank = result.currentRank,
            maxRank = result.maxRank,
            roiPerPoint = result.roiPerPoint,
            totalRemainingROI = result.totalEstimatedROI,
            affectedRecipes = result.topRecipes or {},
            lastUpdated = time(),
        }
        CraftSim.DB.KNOWLEDGE_ROI:Save(crafterUID, result.nodeID, entry)
    end
end


--- @class CraftSim.KnowledgeROI.NodeResult
--- @field nodeID number
--- @field nodeName string
--- @field nodeIcon number?
--- @field currentRank number
--- @field maxRank number
--- @field remainingRanks number
--- @field baseProfit number
--- @field projectedProfit number
--- @field roiPerPoint number gold delta per knowledge point
--- @field totalEstimatedROI number linear estimate for all remaining ranks

--- @class CraftSim.KnowledgeROI.FullScanResult
--- @field nodeID number
--- @field nodeName string
--- @field nodeIcon number?
--- @field currentRank number
--- @field maxRank number
--- @field remainingRanks number
--- @field roiPerPoint number total profit delta across all affected recipes
--- @field totalEstimatedROI number
--- @field affectedRecipeCount number
--- @field topRecipes CraftSim.KnowledgeROIRecipeImpact[]

--- @class CraftSim.KnowledgeROI.PathStep
--- @field step number sequential step number (1, 2, 3, ...)
--- @field nodeID number
--- @field nodeName string
--- @field nodeIcon number?
--- @field rankBefore number rank before this investment
--- @field rankAfter number rank after this investment
--- @field maxRank number
--- @field roiPerPoint number profit delta for this single step
--- @field cumulativeROI number cumulative total profit after all steps so far


--- Returns the number of unspent knowledge points for the given recipe's profession.
--- Uses C_ProfSpecs.GetCurrencyInfoForSkillLine which provides numAvailable + currencyName.
---@param recipeData CraftSim.RecipeData
---@return number availablePoints
---@return string? currencyName
function CraftSim.KNOWLEDGE_ROI:GetAvailableKnowledgePoints(recipeData)
    local skillLineID = recipeData.professionData.skillLineID
    if not skillLineID or skillLineID == 0 then return 0, nil end

    local ok, currencyInfo = pcall(C_ProfSpecs.GetCurrencyInfoForSkillLine, skillLineID)
    if not ok or not currencyInfo then return 0, nil end

    return currencyInfo.numAvailable or 0, currencyInfo.currencyName
end


--- Greedy algorithm: given N available knowledge points, compute the optimal
--- sequence of node investments that maximizes cumulative profit.
---
--- Algorithm:
--- 1. Runs a full profession scan to get initial node ROI values at current ranks
--- 2. For each available point, picks the node with highest roiPerPoint
--- 3. Virtually bumps that node's rank and recalculates its ROI for the next iteration
--- 4. Returns an ordered roadmap of PathStep entries
---
--- Only the selected node is recalculated each iteration (lazy recalc). Cross-node
--- profit dependencies are ignored for performance — this is a standard greedy heuristic.
---
---@param recipeData CraftSim.RecipeData
---@param numPoints number how many points to plan
---@param progressCallback? fun(phase: string, progress: number, total: number)
---@return CraftSim.KnowledgeROI.PathStep[]
function CraftSim.KNOWLEDGE_ROI:CalculateOptimalPath(recipeData, numPoints, progressCallback)
    CraftSim.DEBUG:StartProfiling("KnowledgeROI.OptimalPath")

    if numPoints <= 0 then
        CraftSim.DEBUG:StopProfiling("KnowledgeROI.OptimalPath")
        return {}
    end

    -- Phase 1: Run full scan to get initial node ROIs
    if progressCallback then progressCallback("scan", 0, 1) end
    local scanResults = self:FullProfessionScan(recipeData, function(progress, total)
        if progressCallback then progressCallback("scan", progress, total) end
    end)

    if #scanResults == 0 then
        CraftSim.DEBUG:StopProfiling("KnowledgeROI.OptimalPath")
        return {}
    end

    -- Build mapping context for recalculations
    local profession = recipeData.professionData.professionInfo.profession
    local expansionID = recipeData.professionData.expansionID
    local profData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
    if not profData or not profData[profession] then
        CraftSim.DEBUG:StopProfiling("KnowledgeROI.OptimalPath")
        return {}
    end

    local specData = profData[profession]
    local recipeMapping = specData.recipeMapping
    local nodeDataMap = specData.nodeData

    ---@type table<number, table<RecipeID, boolean>>
    local nodeToRecipes = {}
    for recipeID, perkIDs in pairs(recipeMapping) do
        for _, perkID in ipairs(perkIDs) do
            local perkEntry = nodeDataMap[perkID]
            if perkEntry then
                local baseNodeID = perkEntry.nodeID
                nodeToRecipes[baseNodeID] = nodeToRecipes[baseNodeID] or {}
                nodeToRecipes[baseNodeID][recipeID] = true
            end
        end
    end

    local crafterUID = recipeData:GetCrafterUID()
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(crafterUID, profession) or {}
    local cachedRecipeSet = {}
    for _, rid in ipairs(cachedRecipeIDs) do
        cachedRecipeSet[rid] = true
    end

    -- Build working state from scan results
    ---@type table<number, {nodeID: number, nodeName: string, nodeIcon: number?, currentRank: number, maxRank: number, roiPerPoint: number, needsRecalc: boolean}>
    local nodeStates = {}
    for _, result in ipairs(scanResults) do
        nodeStates[result.nodeID] = {
            nodeID = result.nodeID,
            nodeName = result.nodeName,
            nodeIcon = result.nodeIcon,
            currentRank = result.currentRank,
            maxRank = result.maxRank,
            roiPerPoint = result.roiPerPoint,
            needsRecalc = false,
        }
    end

    -- Phase 2: Greedy loop
    ---@type CraftSim.KnowledgeROI.PathStep[]
    local path = {}
    local cumulativeROI = 0

    for step = 1, numPoints do
        if progressCallback then progressCallback("optimize", step, numPoints) end

        -- Recalculate any nodes flagged from previous iteration
        for nodeID, state in pairs(nodeStates) do
            if state.needsRecalc and state.currentRank < state.maxRank then
                state.roiPerPoint = self:RecalculateNodeROIAtVirtualRank(
                    nodeID, state.currentRank, recipeData, nodeToRecipes, cachedRecipeSet)
                state.needsRecalc = false
            end
        end

        -- Find node with highest positive ROI
        local bestNodeID = nil
        local bestROI = 0
        for nodeID, state in pairs(nodeStates) do
            if state.currentRank < state.maxRank and state.roiPerPoint > bestROI then
                bestROI = state.roiPerPoint
                bestNodeID = nodeID
            end
        end

        -- Stop if no positive-ROI node remains
        if not bestNodeID then break end

        local state = nodeStates[bestNodeID]
        cumulativeROI = cumulativeROI + bestROI

        ---@type CraftSim.KnowledgeROI.PathStep
        local pathStep = {
            step = step,
            nodeID = bestNodeID,
            nodeName = state.nodeName,
            nodeIcon = state.nodeIcon,
            rankBefore = state.currentRank,
            rankAfter = state.currentRank + 1,
            maxRank = state.maxRank,
            roiPerPoint = bestROI,
            cumulativeROI = cumulativeROI,
        }
        tinsert(path, pathStep)

        -- Virtually bump rank; flag for recalculation next iteration
        state.currentRank = state.currentRank + 1
        if state.currentRank < state.maxRank then
            state.needsRecalc = true
        end
    end

    CraftSim.DEBUG:StopProfiling("KnowledgeROI.OptimalPath")
    return path
end


--- Recalculate a node's ROI at a virtual rank (after the greedy algo has
--- virtually spent one or more points on it).
---
--- Sums the profit-delta across all affected known recipes for the transition
--- from virtualCurrentRank → virtualCurrentRank + 1.
---@param nodeID number
---@param virtualCurrentRank number
---@param contextRecipeData CraftSim.RecipeData
---@param nodeToRecipes table<number, table<RecipeID, boolean>>
---@param cachedRecipeSet table<RecipeID, boolean>
---@return number totalDelta
function CraftSim.KNOWLEDGE_ROI:RecalculateNodeROIAtVirtualRank(nodeID, virtualCurrentRank, contextRecipeData, nodeToRecipes, cachedRecipeSet)
    local affectedRecipeIDs = nodeToRecipes[nodeID]
    if not affectedRecipeIDs then return 0 end

    local totalDelta = 0
    for recipeID in pairs(affectedRecipeIDs) do
        if cachedRecipeSet[recipeID] then
            local ok, delta = pcall(self.CalculateRecipeNodeDeltaAtVirtualRank, self,
                recipeID, contextRecipeData, nodeID, virtualCurrentRank)
            if ok and delta and delta ~= 0 then
                totalDelta = totalDelta + delta
            end
        end
    end

    return totalDelta
end


--- Compute the profit delta for a single recipe when bumping a node from
--- virtualCurrentRank → virtualCurrentRank + 1.
---
--- Unlike CalculateRecipeNodeDelta (Phase 1), this function overrides the
--- node to a virtual rank before simulating the bump, allowing evaluation
--- of future states where multiple points have already been virtually spent.
---@param recipeID RecipeID
---@param contextRecipeData CraftSim.RecipeData
---@param targetNodeID number
---@param virtualCurrentRank number
---@return number profitDelta
function CraftSim.KNOWLEDGE_ROI:CalculateRecipeNodeDeltaAtVirtualRank(recipeID, contextRecipeData, targetNodeID, virtualCurrentRank)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if not recipeInfo then return 0 end
    if recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then return 0 end

    local ok, simRecipe = pcall(CraftSim.RecipeData, {
        recipeID = recipeID,
        crafterData = contextRecipeData.crafterData,
    })
    if not ok or not simRecipe then return 0 end
    if not simRecipe.supportsCraftingStats or not simRecipe.specializationData then return 0 end

    -- Find target node and set to virtual current rank
    local found = false
    for _, nodeData in ipairs(simRecipe.specializationData.nodeData) do
        if nodeData.nodeID == targetNodeID then
            if virtualCurrentRank >= nodeData.maxRank then return 0 end
            nodeData.rank = virtualCurrentRank
            nodeData:Update()
            found = true
            break
        end
    end
    if not found then return 0 end

    -- Profit at virtual current rank
    simRecipe.specializationData:UpdateProfessionStats()
    simRecipe:Update()
    local baseProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    -- Bump to virtualCurrentRank + 1 on the same RecipeData instance
    for _, nodeData in ipairs(simRecipe.specializationData.nodeData) do
        if nodeData.nodeID == targetNodeID then
            nodeData.rank = virtualCurrentRank + 1
            nodeData:Update()
            break
        end
    end

    simRecipe.specializationData:UpdateProfessionStats()
    simRecipe:Update()
    local newProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    return newProfit - baseProfit
end
