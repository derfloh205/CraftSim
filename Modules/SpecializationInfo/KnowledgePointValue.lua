---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.KNOWLEDGE_POINT_VALUE
CraftSim.KNOWLEDGE_POINT_VALUE = {}

---@type GGUI.Frame
CraftSim.KNOWLEDGE_POINT_VALUE.frame = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.SpecializationInfo.KnowledgePointValue")

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
---@return CraftSim.KnowledgePointValue.NodeResult[]
function CraftSim.KNOWLEDGE_POINT_VALUE:CalculateForRecipe(recipeData)
    ---@type CraftSim.KnowledgePointValue.NodeResult[]
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
---@return CraftSim.KnowledgePointValue.NodeResult?
function CraftSim.KNOWLEDGE_POINT_VALUE:SimulateNodeRankIncrease(recipeData, nodeIndex, nodeData, baseProfit)
    -- Deep copy recipe data
    local simRecipeData = recipeData:Copy()
    if not simRecipeData.specializationData then return nil end

    local simNodeData = simRecipeData.specializationData.nodeData[nodeIndex]
    if not simNodeData then return nil end

    -- Capture stats BEFORE rank bump
    local oldStats = simNodeData.professionStats:Copy()

    -- Bump rank to maxRank (full investment simulation)
    -- Simulating full investment captures ALL quality threshold crossings
    -- and perk unlocks, giving accurate total ROI for the entire node.
    simNodeData.rank = simNodeData.maxRank
    simNodeData:Update()

    -- Apply the stat DELTA directly to recipe professionStats.
    -- We cannot use simRecipeData:Update() because RecipeData:UpdateProfessionStats()
    -- rebuilds stats from baseProfessionStats (API frozen at current ranks) and only
    -- adds specData:GetExtraValues(). The spec base stat contribution (skill, multicraft
    -- value, etc.) is baked into baseProfessionStats, so bumping a node has no effect.
    local newStats = simNodeData.professionStats
    simRecipeData.professionStats.skill:addValue(newStats.skill.value - oldStats.skill.value)
    simRecipeData.professionStats.multicraft:addValue(newStats.multicraft.value - oldStats.multicraft.value)
    simRecipeData.professionStats.resourcefulness:addValue(newStats.resourcefulness.value - oldStats.resourcefulness.value)
    simRecipeData.professionStats.ingenuity:addValue(newStats.ingenuity.value - oldStats.ingenuity.value)
    simRecipeData.professionStats.craftingspeed:addValue(newStats.craftingspeed.value - oldStats.craftingspeed.value)

    -- Apply extraValues delta
    local oldResExtra = oldStats.resourcefulness:GetExtraValue()
    local newResExtra = newStats.resourcefulness:GetExtraValue()
    if newResExtra ~= oldResExtra then
        simRecipeData.professionStats.resourcefulness:SetExtraValue(
            simRecipeData.professionStats.resourcefulness:GetExtraValue() + (newResExtra - oldResExtra))
    end
    local oldIngExtra = oldStats.ingenuity:GetExtraValue()
    local newIngExtra = newStats.ingenuity:GetExtraValue()
    if newIngExtra ~= oldIngExtra then
        simRecipeData.professionStats.ingenuity:SetExtraValue(
            simRecipeData.professionStats.ingenuity:GetExtraValue() + (newIngExtra - oldIngExtra))
    end

    -- Recalculate result and price with modified stats (do NOT call simRecipeData:Update())
    simRecipeData.resultData:Update()
    simRecipeData.priceData:Update()
    local newProfit = CraftSim.CALC:GetAverageProfit(simRecipeData)

    -- profitDelta is the TOTAL delta from investing ALL remaining ranks
    local profitDelta = newProfit - baseProfit
    local remainingRanks = nodeData.maxRank - nodeData.rank

    ---@type CraftSim.KnowledgePointValue.NodeResult
    local result = {
        nodeID = nodeData.nodeID,
        nodeName = nodeData:GetName() or ("Node " .. nodeData.nodeID),
        nodeIcon = nodeData.icon,
        currentRank = nodeData.rank,
        maxRank = nodeData.maxRank,
        remainingRanks = remainingRanks,
        baseProfit = baseProfit,
        projectedProfit = newProfit,
        roiPerPoint = remainingRanks > 0 and (profitDelta / remainingRanks) or 0,
        totalEstimatedROI = profitDelta,
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
---@return CraftSim.KnowledgePointValue.FullScanResult[]
function CraftSim.KNOWLEDGE_POINT_VALUE:FullProfessionScan(recipeData, progressCallback)
    CraftSim.DEBUG:StartProfiling("KnowledgePointValue.FullProfessionScan")

    ---@type CraftSim.KnowledgePointValue.FullScanResult[]
    local results = {}

    local profession = recipeData.professionData.professionInfo.profession
    local expansionID = recipeData.professionData.expansionID
    local profData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
    if not profData or not profData[profession] then
        CraftSim.DEBUG:StopProfiling("KnowledgePointValue.FullProfessionScan")
        return results
    end

    local specData = profData[profession]
    local recipeMapping = specData.recipeMapping
    local nodeDataMap = specData.nodeData

    -- Build inverse map: baseNodeID -> {recipeIDs}
    ---@type table<number, table<RecipeID, boolean>>
    local nodeToRecipes = {}
    local recipeMappingCount = 0
    for recipeID, perkIDs in pairs(recipeMapping) do
        recipeMappingCount = recipeMappingCount + 1
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

    print("FullScan: profession=" .. tostring(profession) .. " expansion=" .. tostring(expansionID))
    print("FullScan: recipeMapping=" .. recipeMappingCount .. " entries, nodeToRecipes=" .. GUTIL:Count(nodeToRecipes) .. " base nodes, baseNodes=" .. GUTIL:Count(baseNodes))

    -- Get cached recipe IDs for this profession
    local crafterUID = recipeData:GetCrafterUID()
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(crafterUID, profession) or {}
    local cachedRecipeSet = {}
    for _, rid in ipairs(cachedRecipeIDs) do
        cachedRecipeSet[rid] = true
    end
    -- Fallback: if no cached recipe IDs (user never did a Recipe Scan), use all recipes from the static mapping
    if not next(cachedRecipeSet) then
        for recipeID in pairs(recipeMapping) do
            cachedRecipeSet[recipeID] = true
        end
    end

    local configID = C_ProfSpecs.GetConfigIDForSkillLine(recipeData.professionData.skillLineID)
    -- C_ProfSpecs can return 0 when the profession tree has not loaded yet.
    -- Convert that to nil because 0 is truthy in Lua, but it is not a valid configID for C_Traits.
    if configID == 0 then configID = nil end

    print("FullScan: configID=" .. tostring(configID) .. " skillLineID=" .. tostring(recipeData.professionData.skillLineID))
    print("FullScan: cachedRecipeIDs=" .. GUTIL:Count(cachedRecipeSet) .. " recipes")

    local total = GUTIL:Count(baseNodes)
    local progress = 0

    for baseNodeID, baseNodeEntry in pairs(baseNodes) do
        progress = progress + 1
        if progressCallback then
            progressCallback(progress, total)
        end

        -- Get current rank from the API; fallback to 0 if API unavailable
        local nodeInfo = configID and C_Traits.GetNodeInfo(configID, baseNodeID)
        local currentRank
        if nodeInfo and nodeInfo.activeRank then
            currentRank = nodeInfo.activeRank - 1 -- CraftSim convention: activeRank 0 = rank -1 (uninvested)
        else
            currentRank = 0 -- Assume uninvested when API unavailable
        end

        if currentRank < baseNodeEntry.maxRank then
            local affectedRecipeIDs = nodeToRecipes[baseNodeID]

            local affectedCount = affectedRecipeIDs and GUTIL:Count(affectedRecipeIDs) or 0
            print("FullScan node #" .. progress .. ": id=" .. baseNodeID ..
                " rank=" .. currentRank .. "/" .. baseNodeEntry.maxRank ..
                " recipes=" .. affectedCount)

            if affectedRecipeIDs then
                local totalDelta = 0
                local recipeImpacts = {}
                local recipesErrored = 0

                for recipeID in pairs(affectedRecipeIDs) do
                    if cachedRecipeSet[recipeID] then
                        local ok, delta, impact = pcall(self.CalculateRecipeNodeDelta, self, recipeID, recipeData,
                            baseNodeID, currentRank)
                        if not ok then
                            recipesErrored = recipesErrored + 1
                            if recipesErrored <= 2 then
                                print("FullScan ERROR recipe " .. recipeID .. " node " .. baseNodeID .. ": " .. tostring(delta))
                            end
                        elseif delta and delta ~= 0 then
                            totalDelta = totalDelta + delta
                            if impact then
                                tinsert(recipeImpacts, impact)
                            end
                        end
                    end
                end

                if recipesErrored > 0 then
                    print("FullScan node #" .. progress .. ": " .. recipesErrored .. " recipe errors")
                end

                -- Include node even if totalDelta is 0; shows investable nodes with neutral ROI
                -- Sort recipe impacts by profit delta descending
                table.sort(recipeImpacts, function(a, b)
                    return a.profitDelta > b.profitDelta
                end)

                local remainingRanks = baseNodeEntry.maxRank - math.max(0, currentRank)

                ---@type CraftSim.KnowledgePointValue.FullScanResult
                local result = {
                    nodeID = baseNodeID,
                    nodeName = self:GetNodeName(baseNodeID, recipeData) or ("Node " .. baseNodeID),
                    nodeIcon = baseNodeEntry.icon,
                    currentRank = currentRank,
                    maxRank = baseNodeEntry.maxRank,
                    remainingRanks = remainingRanks,
                    roiPerPoint = remainingRanks > 0 and (totalDelta / remainingRanks) or 0,
                    totalEstimatedROI = totalDelta,
                    affectedRecipeCount = #recipeImpacts,
                    topRecipes = recipeImpacts,
                }
                tinsert(results, result)
            end
        end
    end

    -- Sort by ROI per point descending
    table.sort(results, function(a, b)
        return a.roiPerPoint > b.roiPerPoint
    end)

    -- Cache results
    self:CacheFullScanResults(crafterUID, results, profession, expansionID)

    local nonZeroCount = 0
    for _, r in ipairs(results) do
        if r.roiPerPoint ~= 0 then nonZeroCount = nonZeroCount + 1 end
    end
    print("FullScan DONE: " .. #results .. " total results, " .. nonZeroCount .. " with non-zero ROI")

    CraftSim.DEBUG:StopProfiling("KnowledgePointValue.FullProfessionScan")
    return results
end


--- Async version of FullProfessionScan using GUTIL.FrameDistributor to avoid UI freezes.
--- Distributes node processing across frames (iterationsPerFrame nodes per frame tick).
---@param recipeData CraftSim.RecipeData
---@param onProgress fun(progress: number, total: number)
---@param onComplete fun(results: CraftSim.KnowledgePointValue.FullScanResult[])
---@param iterationsPerFrame? number default 3
function CraftSim.KNOWLEDGE_POINT_VALUE:FullProfessionScanAsync(recipeData, onProgress, onComplete, iterationsPerFrame)
    ---@type CraftSim.KnowledgePointValue.FullScanResult[]
    local results = {}

    local profession = recipeData.professionData.professionInfo.profession
    local expansionID = recipeData.professionData.expansionID
    local profData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
    if not profData or not profData[profession] then
        onComplete(results)
        return
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

    ---@type table<number, CraftSim.RawPerkData>
    local baseNodes = {}
    for perkID, perkEntry in pairs(nodeDataMap) do
        if perkEntry.base and perkEntry.maxRank and perkEntry.maxRank > 0 then
            baseNodes[perkID] = perkEntry
        end
    end

    local crafterUID = recipeData:GetCrafterUID()
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(crafterUID, profession) or {}
    local cachedRecipeSet = {}
    for _, rid in ipairs(cachedRecipeIDs) do
        cachedRecipeSet[rid] = true
    end
    if not next(cachedRecipeSet) then
        for recipeID in pairs(recipeMapping) do
            cachedRecipeSet[recipeID] = true
        end
    end

    local configID = C_ProfSpecs.GetConfigIDForSkillLine(recipeData.professionData.skillLineID)
    if configID == 0 then configID = nil end

    local total = GUTIL:Count(baseNodes)

    GUTIL.FrameDistributor {
        iterationTable = baseNodes,
        iterationsPerFrame = iterationsPerFrame or 3,
        finally = function()
            table.sort(results, function(a, b)
                return a.roiPerPoint > b.roiPerPoint
            end)
            self:CacheFullScanResults(crafterUID, results, profession, expansionID)
            onComplete(results)
        end,
        continue = function(frameDistributor, baseNodeID, baseNodeEntry, currentIteration, progress)
            if onProgress then
                onProgress(currentIteration, total)
            end

            local nodeInfo = configID and C_Traits.GetNodeInfo(configID, baseNodeID)
            local currentRank
            if nodeInfo and nodeInfo.activeRank then
                currentRank = nodeInfo.activeRank - 1
            else
                currentRank = 0
            end

            if currentRank < baseNodeEntry.maxRank then
                local affectedRecipeIDs = nodeToRecipes[baseNodeID]
                if affectedRecipeIDs then
                    local totalDelta = 0
                    local recipeImpacts = {}

                    for recipeID in pairs(affectedRecipeIDs) do
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

                    table.sort(recipeImpacts, function(a, b)
                        return a.profitDelta > b.profitDelta
                    end)

                    local remainingRanks = baseNodeEntry.maxRank - math.max(0, currentRank)

                    tinsert(results, {
                        nodeID = baseNodeID,
                        nodeName = self:GetNodeName(baseNodeID, recipeData) or ("Node " .. baseNodeID),
                        nodeIcon = baseNodeEntry.icon,
                        currentRank = currentRank,
                        maxRank = baseNodeEntry.maxRank,
                        remainingRanks = remainingRanks,
                        roiPerPoint = remainingRanks > 0 and (totalDelta / remainingRanks) or 0,
                        totalEstimatedROI = totalDelta,
                        affectedRecipeCount = #recipeImpacts,
                        topRecipes = recipeImpacts,
                    })
                end
            end

            frameDistributor:Continue()
        end,
    }:Continue()
end


--- Calculate the profit delta for a single recipe when bumping one specific node.
---@param recipeID RecipeID
---@param contextRecipeData CraftSim.RecipeData provides profession data context
---@param targetNodeID number the base node ID to bump
---@param currentRank number current rank of the node
---@return number profitDelta
---@return CraftSim.KnowledgePointValueRecipeImpact? impact
function CraftSim.KNOWLEDGE_POINT_VALUE:CalculateRecipeNodeDelta(recipeID, contextRecipeData, targetNodeID, currentRank)
    -- Create recipe data for this recipe
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if not recipeInfo then return 0, nil end
    if recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then return 0, nil end

    local ok, simRecipe = pcall(CraftSim.RecipeData, {
        recipeID = recipeID,
        crafterData = contextRecipeData.crafterData,
    })
    if not ok or not simRecipe then
        print("  RecipeData creation failed for " .. recipeID .. ": " .. tostring(simRecipe))
        return 0, nil
    end
    if not simRecipe.supportsCraftingStats then return 0, nil end
    if not simRecipe.specializationData then return 0, nil end

    -- Base profit
    local baseProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    -- Find the target node in this recipe's spec data and bump its rank.
    -- Key insight: RecipeData:UpdateProfessionStats() fetches spec contribution
    -- from baseProfessionStats (Blizzard API, frozen at current ranks) and only
    -- adds specData:GetExtraValues() (percentages). So bumping a node's rank and
    -- calling recipe:Update() has NO effect on the recipe's professionStats.
    -- Instead, we must manually apply the stat DELTA from the rank increase.
    local targetNode = nil
    for _, nodeData in ipairs(simRecipe.specializationData.nodeData) do
        if nodeData.nodeID == targetNodeID then
            targetNode = nodeData
            break
        end
    end
    if not targetNode then return 0, nil end
    if targetNode.rank >= targetNode.maxRank then return 0, nil end

    -- Capture stats BEFORE rank bump
    local oldStats = targetNode.professionStats:Copy()

    -- Bump rank to maxRank (full investment simulation)
    -- Simulating full investment captures ALL quality threshold crossings
    -- and perk unlocks across the entire node's remaining ranks.
    targetNode.rank = targetNode.maxRank
    targetNode:Update()

    -- Calculate stat delta from full investment (current rank -> maxRank)
    local newStats = targetNode.professionStats
    local dSkill = newStats.skill.value - oldStats.skill.value
    local dMulticraft = newStats.multicraft.value - oldStats.multicraft.value
    local dResourcefulness = newStats.resourcefulness.value - oldStats.resourcefulness.value
    local dIngenuity = newStats.ingenuity.value - oldStats.ingenuity.value
    local dCraftingSpeed = newStats.craftingspeed.value - oldStats.craftingspeed.value

    -- Apply stat delta directly to the recipe's professionStats
    -- (bypassing UpdateProfessionStats which would reset from API baseProfessionStats)
    simRecipe.professionStats.skill:addValue(dSkill)
    simRecipe.professionStats.multicraft:addValue(dMulticraft)
    simRecipe.professionStats.resourcefulness:addValue(dResourcefulness)
    simRecipe.professionStats.ingenuity:addValue(dIngenuity)
    simRecipe.professionStats.craftingspeed:addValue(dCraftingSpeed)

    -- Also apply extraValues delta (resourcefulness extra items factor, ingenuity concentration factor)
    local oldResExtra = oldStats.resourcefulness:GetExtraValue()
    local newResExtra = newStats.resourcefulness:GetExtraValue()
    if newResExtra ~= oldResExtra then
        simRecipe.professionStats.resourcefulness:SetExtraValue(
            simRecipe.professionStats.resourcefulness:GetExtraValue() + (newResExtra - oldResExtra))
    end
    local oldIngExtra = oldStats.ingenuity:GetExtraValue()
    local newIngExtra = newStats.ingenuity:GetExtraValue()
    if newIngExtra ~= oldIngExtra then
        simRecipe.professionStats.ingenuity:SetExtraValue(
            simRecipe.professionStats.ingenuity:GetExtraValue() + (newIngExtra - oldIngExtra))
    end

    -- Recalculate result data and prices with the modified stats (do NOT call simRecipe:Update())
    simRecipe.resultData:Update()
    simRecipe.priceData:Update()
    local newProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    local delta = newProfit - baseProfit

    ---@type CraftSim.KnowledgePointValueRecipeImpact
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
function CraftSim.KNOWLEDGE_POINT_VALUE:GetNodeName(nodeID, recipeData)
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(recipeData.professionData.skillLineID)
    if configID == 0 then configID = nil end
    if not configID then return nil end
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
---@param results CraftSim.KnowledgePointValue.FullScanResult[]
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
function CraftSim.KNOWLEDGE_POINT_VALUE:CacheFullScanResults(crafterUID, results, profession, expansionID)
    for _, result in ipairs(results) do
        ---@type CraftSim.KnowledgePointValueEntry
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
        CraftSim.DB.KNOWLEDGE_POINT_VALUE:Save(crafterUID, result.nodeID, entry)
    end
end


--- @class CraftSim.KnowledgePointValue.NodeResult
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

--- @class CraftSim.KnowledgePointValue.FullScanResult
--- @field nodeID number
--- @field nodeName string
--- @field nodeIcon number?
--- @field currentRank number
--- @field maxRank number
--- @field remainingRanks number
--- @field roiPerPoint number total profit delta across all affected recipes
--- @field totalEstimatedROI number
--- @field affectedRecipeCount number
--- @field topRecipes CraftSim.KnowledgePointValueRecipeImpact[]

--- @class CraftSim.KnowledgePointValue.PathStep
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
function CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
    local skillLineID = recipeData.professionData.skillLineID
    if not skillLineID or skillLineID == 0 then return 0, nil end

    local ok, currencyInfo = pcall(C_ProfSpecs.GetCurrencyInfoForSkillLine, skillLineID)
    if not ok or not currencyInfo then return 0, nil end

    return currencyInfo.numAvailable or 0, currencyInfo.currencyName
end


--- Track whether we already notified this session (per profession)
---@type table<Enum.Profession, boolean>
CraftSim.KNOWLEDGE_POINT_VALUE.notifiedThisSession = {}

--- Check for unspent knowledge points and notify the player once per session per profession.
--- Called from ProfessionsFrame OnShow hook.
function CraftSim.KNOWLEDGE_POINT_VALUE:CheckAndNotifyUnspentPoints()
    if not CraftSim.DB.OPTIONS:Get("MODULE_KNOWLEDGE_POINT_VALUE") then return end

    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then return end
    if not recipeData.specializationData or not recipeData.supportsCraftingStats then return end

    local profession = recipeData.professionData.professionInfo.profession
    if not profession or self.notifiedThisSession[profession] then return end

    local availPts, currencyName = self:GetAvailableKnowledgePoints(recipeData)
    if availPts <= 0 then return end

    self.notifiedThisSession[profession] = true

    local profName = recipeData.professionData.professionInfo.professionName or "Profession"
    local GUTIL = CraftSim.GUTIL
    local f = GUTIL:GetFormatter()

    -- Check for saved weekly plan with recommendation
    local crafterUID = recipeData:GetCrafterUID()
    local plan = CraftSim.DB.KNOWLEDGE_POINT_VALUE:GetWeeklyPlan(crafterUID, profession)
    local bestHint = ""
    if plan and plan.topNodeName then
        bestHint = " - Best: " .. plan.topNodeName
    end

    CraftSim.DEBUG:SystemPrint(
        f.l("CraftSim Knowledge Point Value: ") ..
        f.bb(profName) .. ": " ..
        GUTIL:ColorizeText(tostring(availPts), GUTIL.COLORS.GREEN) ..
        " unspent knowledge point" .. (availPts > 1 and "s" or "") ..
        bestHint ..
        " - Open " .. f.l("Knowledge Point Value") .. " panel to optimize!"
    )
end


--- Saves the optimal path as a weekly plan in the DB.
---@param recipeData CraftSim.RecipeData
---@param path CraftSim.KnowledgePointValue.PathStep[]
---@param availablePoints number
function CraftSim.KNOWLEDGE_POINT_VALUE:SaveWeeklyPlan(recipeData, path, availablePoints)
    local crafterUID = recipeData:GetCrafterUID()
    local profession = recipeData.professionData.professionInfo.profession
    if not crafterUID or not profession then return end

    local totalGain = 0
    local topNodeName = nil
    if #path > 0 then
        totalGain = path[#path].cumulativeROI or 0
        topNodeName = path[1].nodeName
    end

    ---@type CraftSim.KnowledgePointValue.WeeklyPlan
    local plan = {
        path = path,
        availablePoints = availablePoints,
        totalGain = totalGain,
        profession = profession,
        savedAt = time(),
        topNodeName = topNodeName,
    }

    CraftSim.DB.KNOWLEDGE_POINT_VALUE:SaveWeeklyPlan(crafterUID, profession, plan)
end


--- Returns the saved weekly plan for the current crafter/profession, if fresh enough.
--- Plans older than 3 days are considered stale and ignored.
---@param recipeData CraftSim.RecipeData
---@return CraftSim.KnowledgePointValue.WeeklyPlan?
function CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedWeeklyPlan(recipeData)
    local crafterUID = recipeData:GetCrafterUID()
    local profession = recipeData.professionData.professionInfo.profession
    if not crafterUID or not profession then return nil end

    local plan = CraftSim.DB.KNOWLEDGE_POINT_VALUE:GetWeeklyPlan(crafterUID, profession)
    if not plan then return nil end

    -- Stale check: 3 days
    local age = time() - (plan.savedAt or 0)
    if age > 3 * 24 * 60 * 60 then return nil end

    return plan
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
---@return CraftSim.KnowledgePointValue.PathStep[]
function CraftSim.KNOWLEDGE_POINT_VALUE:CalculateOptimalPath(recipeData, numPoints, progressCallback)
    CraftSim.DEBUG:StartProfiling("KnowledgePointValue.OptimalPath")

    if numPoints <= 0 then
        CraftSim.DEBUG:StopProfiling("KnowledgePointValue.OptimalPath")
        return {}
    end

    -- Phase 1: Run full scan to get initial node ROIs
    if progressCallback then progressCallback("scan", 0, 1) end
    local scanResults = self:FullProfessionScan(recipeData, function(progress, total)
        if progressCallback then progressCallback("scan", progress, total) end
    end)

    if #scanResults == 0 then
        CraftSim.DEBUG:StopProfiling("KnowledgePointValue.OptimalPath")
        return {}
    end

    -- Build mapping context for recalculations
    local profession = recipeData.professionData.professionInfo.profession
    local expansionID = recipeData.professionData.expansionID
    local profData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
    if not profData or not profData[profession] then
        CraftSim.DEBUG:StopProfiling("KnowledgePointValue.OptimalPath")
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
    -- Fallback: if no cached recipe IDs, use all recipes from the static mapping
    if not next(cachedRecipeSet) then
        for recipeID in pairs(recipeMapping) do
            cachedRecipeSet[recipeID] = true
        end
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
    ---@type CraftSim.KnowledgePointValue.PathStep[]
    local path = {}
    local cumulativeROI = 0

    for step = 1, numPoints do
        if progressCallback then progressCallback("optimize", step, numPoints) end

        -- Recalculate any nodes flagged from previous iteration
        for nodeID, state in pairs(nodeStates) do
            if state.needsRecalc and state.currentRank < state.maxRank then
                local fullDelta = self:RecalculateNodeROIAtVirtualRank(
                    nodeID, state.currentRank, recipeData, nodeToRecipes, cachedRecipeSet)
                local remaining = state.maxRank - state.currentRank
                state.roiPerPoint = remaining > 0 and (fullDelta / remaining) or 0
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

        ---@type CraftSim.KnowledgePointValue.PathStep
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

    CraftSim.DEBUG:StopProfiling("KnowledgePointValue.OptimalPath")
    return path
end


--- Async version of CalculateOptimalPath using FrameDistributor.
--- Phase 1 (scan) uses FullProfessionScanAsync, Phase 2 (greedy) distributes steps across frames.
---@param recipeData CraftSim.RecipeData
---@param numPoints number
---@param onProgress fun(phase: string, progress: number, total: number)
---@param onComplete fun(path: CraftSim.KnowledgePointValue.PathStep[])
function CraftSim.KNOWLEDGE_POINT_VALUE:CalculateOptimalPathAsync(recipeData, numPoints, onProgress, onComplete)
    if numPoints <= 0 then
        onComplete({})
        return
    end

    -- Phase 1: Async full scan
    if onProgress then onProgress("scan", 0, 1) end

    self:FullProfessionScanAsync(recipeData,
        function(progress, total)
            if onProgress then onProgress("scan", progress, total) end
        end,
        function(scanResults)
            if #scanResults == 0 then
                onComplete({})
                return
            end

            -- Build mapping context for recalculations
            local profession = recipeData.professionData.professionInfo.profession
            local expansionID = recipeData.professionData.expansionID
            local profData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID]
            if not profData or not profData[profession] then
                onComplete({})
                return
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
            if not next(cachedRecipeSet) then
                for recipeID in pairs(recipeMapping) do
                    cachedRecipeSet[recipeID] = true
                end
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

            -- Phase 2: Greedy loop via FrameDistributor (1 step per frame)
            local path = {}
            local cumulativeROI = 0
            -- Build a simple number-indexed table for FrameDistributor iteration
            local steps = {}
            for i = 1, numPoints do steps[i] = i end

            GUTIL.FrameDistributor {
                iterationTable = steps,
                iterationsPerFrame = 1,
                finally = function()
                    onComplete(path)
                end,
                continue = function(frameDistributor, _, step)
                    if onProgress then onProgress("optimize", step, numPoints) end

                    -- Recalculate flagged nodes
                    for nodeID, state in pairs(nodeStates) do
                        if state.needsRecalc and state.currentRank < state.maxRank then
                            local fullDelta = self:RecalculateNodeROIAtVirtualRank(
                                nodeID, state.currentRank, recipeData, nodeToRecipes, cachedRecipeSet)
                            local remaining = state.maxRank - state.currentRank
                            state.roiPerPoint = remaining > 0 and (fullDelta / remaining) or 0
                            state.needsRecalc = false
                        end
                    end

                    -- Find best node
                    local bestNodeID = nil
                    local bestROI = 0
                    for nodeID, state in pairs(nodeStates) do
                        if state.currentRank < state.maxRank and state.roiPerPoint > bestROI then
                            bestROI = state.roiPerPoint
                            bestNodeID = nodeID
                        end
                    end

                    if not bestNodeID then
                        frameDistributor:Break()
                        return
                    end

                    local state = nodeStates[bestNodeID]
                    cumulativeROI = cumulativeROI + bestROI

                    tinsert(path, {
                        step = step,
                        nodeID = bestNodeID,
                        nodeName = state.nodeName,
                        nodeIcon = state.nodeIcon,
                        rankBefore = state.currentRank,
                        rankAfter = state.currentRank + 1,
                        maxRank = state.maxRank,
                        roiPerPoint = bestROI,
                        cumulativeROI = cumulativeROI,
                    })

                    state.currentRank = state.currentRank + 1
                    if state.currentRank < state.maxRank then
                        state.needsRecalc = true
                    end

                    frameDistributor:Continue()
                end,
            }:Continue()
        end
    )
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
function CraftSim.KNOWLEDGE_POINT_VALUE:RecalculateNodeROIAtVirtualRank(nodeID, virtualCurrentRank, contextRecipeData, nodeToRecipes, cachedRecipeSet)
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
function CraftSim.KNOWLEDGE_POINT_VALUE:CalculateRecipeNodeDeltaAtVirtualRank(recipeID, contextRecipeData, targetNodeID, virtualCurrentRank)
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    if not recipeInfo then return 0 end
    if recipeInfo.isGatheringRecipe or recipeInfo.isDummyRecipe then return 0 end

    local ok, simRecipe = pcall(CraftSim.RecipeData, {
        recipeID = recipeID,
        crafterData = contextRecipeData.crafterData,
    })
    if not ok or not simRecipe then return 0 end
    if not simRecipe.supportsCraftingStats or not simRecipe.specializationData then return 0 end

    -- Find target node and set to virtual current rank, then compute delta
    -- Same stat-delta approach as CalculateRecipeNodeDelta: we cannot use
    -- simRecipe:Update() because baseProfessionStats already includes current
    -- spec contribution from the API. We must apply the incremental delta manually.
    local targetNode = nil
    for _, nodeData in ipairs(simRecipe.specializationData.nodeData) do
        if nodeData.nodeID == targetNodeID then
            targetNode = nodeData
            break
        end
    end
    if not targetNode then return 0 end
    if virtualCurrentRank >= targetNode.maxRank then return 0 end

    -- First: set node to virtual rank and apply delta from (actual rank → virtual rank)
    local actualRankStats = targetNode.professionStats:Copy()

    targetNode.rank = virtualCurrentRank
    targetNode:Update()
    local virtualRankStats = targetNode.professionStats:Copy()

    -- Apply delta (actual → virtual) to get professionStats at virtual rank
    simRecipe.professionStats.skill:addValue(virtualRankStats.skill.value - actualRankStats.skill.value)
    simRecipe.professionStats.multicraft:addValue(virtualRankStats.multicraft.value - actualRankStats.multicraft.value)
    simRecipe.professionStats.resourcefulness:addValue(virtualRankStats.resourcefulness.value - actualRankStats.resourcefulness.value)
    simRecipe.professionStats.ingenuity:addValue(virtualRankStats.ingenuity.value - actualRankStats.ingenuity.value)
    simRecipe.professionStats.craftingspeed:addValue(virtualRankStats.craftingspeed.value - actualRankStats.craftingspeed.value)

    local oldResExtra = actualRankStats.resourcefulness:GetExtraValue()
    local vResExtra = virtualRankStats.resourcefulness:GetExtraValue()
    if vResExtra ~= oldResExtra then
        simRecipe.professionStats.resourcefulness:SetExtraValue(
            simRecipe.professionStats.resourcefulness:GetExtraValue() + (vResExtra - oldResExtra))
    end
    local oldIngExtra = actualRankStats.ingenuity:GetExtraValue()
    local vIngExtra = virtualRankStats.ingenuity:GetExtraValue()
    if vIngExtra ~= oldIngExtra then
        simRecipe.professionStats.ingenuity:SetExtraValue(
            simRecipe.professionStats.ingenuity:GetExtraValue() + (vIngExtra - oldIngExtra))
    end

    -- Get base profit at virtual rank
    simRecipe.resultData:Update()
    simRecipe.priceData:Update()
    local baseProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    -- Now bump to maxRank (full investment from virtual rank) and apply delta
    local preStats = targetNode.professionStats:Copy()
    targetNode.rank = targetNode.maxRank
    targetNode:Update()
    local postStats = targetNode.professionStats

    simRecipe.professionStats.skill:addValue(postStats.skill.value - preStats.skill.value)
    simRecipe.professionStats.multicraft:addValue(postStats.multicraft.value - preStats.multicraft.value)
    simRecipe.professionStats.resourcefulness:addValue(postStats.resourcefulness.value - preStats.resourcefulness.value)
    simRecipe.professionStats.ingenuity:addValue(postStats.ingenuity.value - preStats.ingenuity.value)
    simRecipe.professionStats.craftingspeed:addValue(postStats.craftingspeed.value - preStats.craftingspeed.value)

    local preResExtra = preStats.resourcefulness:GetExtraValue()
    local postResExtra = postStats.resourcefulness:GetExtraValue()
    if postResExtra ~= preResExtra then
        simRecipe.professionStats.resourcefulness:SetExtraValue(
            simRecipe.professionStats.resourcefulness:GetExtraValue() + (postResExtra - preResExtra))
    end
    local preIngExtra = preStats.ingenuity:GetExtraValue()
    local postIngExtra = postStats.ingenuity:GetExtraValue()
    if postIngExtra ~= preIngExtra then
        simRecipe.professionStats.ingenuity:SetExtraValue(
            simRecipe.professionStats.ingenuity:GetExtraValue() + (postIngExtra - preIngExtra))
    end

    simRecipe.resultData:Update()
    simRecipe.priceData:Update()
    local newProfit = CraftSim.CALC:GetAverageProfit(simRecipe)

    return newProfit - baseProfit
end
