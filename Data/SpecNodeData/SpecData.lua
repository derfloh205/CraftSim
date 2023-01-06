addonName, CraftSim = ...

CraftSim.SPEC_DATA = {}

local function print(text, recursive) -- override
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SPECDATA, recursive)
end

local debugActive = false
function CraftSim.SPEC_DATA:GetIDsFromChildNodes(nodeData, ruleNodes)
    local IDs = {
        idMapping = nodeData.idMapping or {},
        exceptionRecipeIDs = nodeData.exceptionRecipeIDs or {}
    }

    -- add from childs
    local childNodeIDs = nodeData.childNodeIDs
    if childNodeIDs then
        for _, childNodeID in pairs(childNodeIDs) do
            local childNoteData = ruleNodes[childNodeID]

            local childIDs = CraftSim.SPEC_DATA:GetIDsFromChildNodes(childNoteData, ruleNodes)
    
            if debugActive then
                print("my ids before: ")
                print(IDs, true)
                print("childIDs: ")
                print(childIDs, true)
            end
            for categoryID, subtypeIDs in pairs(childIDs.idMapping or {}) do
                if not IDs.idMapping[categoryID] then
                    if debugActive then
                        print("no key found, add: " .. tostring(categoryID))
                    end
                    IDs.idMapping[categoryID] = subtypeIDs
                else
                    if debugActive then
                        print("key found, check subtypes: " .. #subtypeIDs)
                        print(subtypeIDs, true)
                    end
                    for _, subtypeID in pairs(subtypeIDs) do
                        if not tContains(IDs.idMapping[categoryID], subtypeID) then
                            if debugActive then
                                print("no subtype found, add: " .. tostring(subtypeID))
                            end
                            table.insert(IDs.idMapping[categoryID], subtypeID)
                        end
                    end
                end
            end

            for _, exceptionID in pairs(childIDs.exceptionRecipeIDs or {}) do
                if not tContains(IDs.exceptionRecipeIDs, exceptionID) then
                    table.insert(IDs.exceptionRecipeIDs, exceptionID)
                end
            end

            if debugActive then
                print("my ids now:")
                print(IDs, true)
            end
        end

        return IDs
    end

    return IDs
end

function CraftSim.SPEC_DATA:affectsRecipeByIDs(recipeData, IDs)
    -- an exception always matches
    if IDs.exceptionRecipeIDs and tContains(IDs.exceptionRecipeIDs, recipeData.recipeID) then
        return true
    end
    -- if it matches all categories it matches all items
    if IDs.idMapping[CraftSim.CONST.RECIPE_CATEGORIES.ALL] then
        return true
    end
    
    local matchesByTypes = false
    -- for all categories check if its subtypes contain the recipesubtype or all
    -- if the specific categoryID to subtypeIDs combination matches it matches
    for categoryID, subtypeIDs in pairs(IDs.idMapping) do
        if recipeData.categoryID == categoryID then
            if tContains(subtypeIDs, CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL) then
                return true
            elseif tContains(subtypeIDs, recipeData.subtypeID) then
                return true
            end
        end
    end

    return false
end

function CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes, singleNodeID, printDebug)
    local specNodeData = recipeData.specNodeData

    local stats = {	
        inspiration = 0,
        inspirationBonusSkillFactor = 1,
        multicraft = 0,
        multicraftExtraItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessExtraItemsFactor = 1,
        craftingspeed = 0,
        craftingspeedBonusFactor = 1,
        skill = 0,

        -- special
        phialExperimentationChanceFactor = 1,
        potionExperimentationChanceFactor = 1,
    }

    local debugPrinted = false
    if not singleNodeID then
        recipeData.specNodeData.affectedNodes = {}
    end

    for name, nodeData in pairs(ruleNodes) do 
        local nodeInfo = specNodeData[nodeData.nodeID]

        if not singleNodeID or (singleNodeID and singleNodeID == nodeData.nodeID) then

            if not nodeInfo then
                error("CraftSim Error: Node ID not implemented: " .. tostring(nodeData.nodeID))
            end

            -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
            -- only increase if the current recipe has a matching category AND Subtype (like weapons -> one handed axes)
            local nodeRank = nodeInfo.activeRank
            local nodeActualValue = nodeInfo.activeRank - 1
    
            -- fetch all subtypeIDs, categoryIDs and exceptionRecipeIDs recursively
            if nodeData.nodeID == 23727 then
                debugActive = true
            end
            local IDs = CraftSim.SPEC_DATA:GetIDsFromChildNodes(nodeData, ruleNodes)
            debugActive = false
            
            
            local nodeAffectsRecipe = nodeRank > 0 and CraftSim.SPEC_DATA:affectsRecipeByIDs(recipeData, IDs)
            
            if (nodeAffectsRecipe or nodeData.debug) and not singleNodeID then
                local containsNode = CraftSim.UTIL:Find(recipeData.specNodeData.affectedNodes, function(node) 
                    return node.nodeID == nodeData.nodeID
                end)
                if not containsNode then
                    --print("add node to affected: " .. tostring(nodeData.nodeID))
                    local nodeStats = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes, nodeData.nodeID, false)
                    table.insert(recipeData.specNodeData.affectedNodes, {
                        nodeID = nodeData.nodeID,
                        nodeRank = nodeRank,
                        maxRanks = nodeInfo.maxRanks,
                        nodeActualValue = nodeActualValue,
                        nodeStats = nodeStats,
                    })
                end
            end
    
            if printDebug and not debugPrinted then
                debugPrinted = true
                -- debug
                print("CHECK NODE: " .. tostring(nodeData.nodeID))
                print("-- Affected: " .. tostring(nodeAffectsRecipe))
                print("-- categoryID: " .. tostring(recipeData.categoryID))
                print("-- subtypeID: " .. tostring(recipeData.subtypeID))
                print(tostring(IDs.exceptionRecipeIDs) .. " and " .. "contains " .. tostring(IDs.exceptionRecipeIDs) .. ", " .. tostring(recipeData.recipeID))
                print("-- IDs: ")
                print(IDs.idMapping, true)
                print(IDs.exceptionRecipeIDs, true)
            end
            if nodeInfo and (nodeAffectsRecipe or nodeData.debug) then
                if nodeData.threshold and (nodeInfo.activeRank - 1) >= nodeData.threshold then
                    -- ThresholdNode
                    -- Stack additively..
                    stats.multicraftExtraItemsFactor = stats.multicraftExtraItemsFactor + (nodeData.multicraftExtraItemsFactor or 0)
                    stats.resourcefulnessExtraItemsFactor = stats.resourcefulnessExtraItemsFactor + (nodeData.resourcefulnessExtraItemsFactor or 0)
                    stats.craftingspeedBonusFactor = stats.craftingspeedBonusFactor + (nodeData.craftingspeedBonusFactor or 0)
                    stats.inspirationBonusSkillFactor = stats.inspirationBonusSkillFactor + (nodeData.inspirationBonusSkillFactor or 0)
                    stats.phialExperimentationChanceFactor = stats.phialExperimentationChanceFactor + (nodeData.phialExperimentationChanceFactor or 0)
                    stats.potionExperimentationChanceFactor = stats.potionExperimentationChanceFactor + (nodeData.potionExperimentationChanceFactor or 0)
    
                    stats.skill = stats.skill + (nodeData.skill or 0)
                    stats.inspiration = stats.inspiration + (nodeData.inspiration or 0)
                    stats.multicraft = stats.multicraft + (nodeData.multicraft or 0)
                    stats.resourcefulness = stats.resourcefulness + (nodeData.resourcefulness or 0)
                    stats.craftingspeed = stats.craftingspeed + (nodeData.craftingspeed or 0)
                elseif nodeData.equalsSkill and nodeRank > 0 then
                    stats.skill = stats.skill + nodeActualValue
                elseif nodeData.equalsMulticraft and nodeRank > 0 then
                    stats.multicraft = stats.multicraft + nodeActualValue
                elseif nodeData.equalsInspiration and nodeRank > 0 then
                    stats.inspiration = stats.inspiration + nodeActualValue
                elseif nodeData.equalsResourcefulness and nodeRank > 0 then
                    stats.resourcefulness = stats.resourcefulness + nodeActualValue
                elseif nodeData.equalsCraftingspeed and nodeRank > 0 then
                    stats.craftingspeed = stats.craftingspeed + nodeActualValue
                elseif nodeData.equalsResourcefulnessExtraItemsFactor and nodeRank > 0 then
                    stats.resourcefulnessExtraItemsFactor = stats.resourcefulnessExtraItemsFactor + nodeActualValue*0.01 
                elseif nodeData.equalsPhialExperimentationChanceFactor and nodeRank > 0 then
                    stats.phialExperimentationChanceFactor = stats.phialExperimentationChanceFactor + nodeActualValue*0.01
                elseif nodeData.equalsPotionExperimentationChanceFactor and nodeRank > 0 then
                    stats.potionExperimentationChanceFactor = stats.potionExperimentationChanceFactor + nodeActualValue*0.01
                end
            end
        end
    end
    
    return stats
end

-- LEGACY.. remove when other ready
function CraftSim.SPEC_DATA:GetExtraItemFactors(recipeData, ruleNodes)
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(skillLineID)

    local extraItemFactors = {
        multicraftExtraItemsFactor = 1,
        resourcefulnessExtraItemsFactor = 1
    }

    for thresholdName, nodeData in pairs(ruleNodes) do 
        --print("getting nodeinfo: " .. tostring(configID))
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeData.nodeID)
        -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
        -- only increase if the current recipe has a matching category (like whetstone -> stonework, then only stonework marked nodes are relevant)
        -- or if categoryID of nodeData is nil which means its for the whole profession
        -- or if its debugged
        if nodeData and nodeData.categoryIDs and nodeData.threshold and nodeInfo and (nodeData.debug or (tContains(nodeData.categoryIDs, recipeData.categoryID) or #nodeData.categoryIDs == 0) and (nodeInfo.activeRank - 1) >= nodeData.threshold) then
            -- they stack multiplicatively
            extraItemFactors.multicraftExtraItemsFactor = extraItemFactors.multicraftExtraItemsFactor * (1 + (nodeData.multicraftExtraItemsFactor or 0))
            extraItemFactors.resourcefulnessExtraItemsFactor = extraItemFactors.resourcefulnessExtraItemsFactor * (1 + (nodeData.resourcefulnessExtraItemsFactor or 0))
        end
    end
    return extraItemFactors
end

function CraftSim.SPEC_DATA:GetSpecExtraItemFactorsByRecipeData(recipeData)
    local defaultFactors = {
        multicraftExtraItemsFactor = 1,
        resourcefulnessExtraItemsFactor = 1
    }

    local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[recipeData.professionID]
    if ruleNodes == nil then
        --print("Profession specs not considered: " .. recipeData.professionID)
        return defaultFactors
    end

    return CraftSim.SPEC_DATA:GetExtraItemFactors(recipeData, ruleNodes)
end

-- its a function so craftsimConst can be accessed (otherwise nil cause not yet initialized)
CraftSim.SPEC_DATA.RULE_NODES = function() 
    return {
    [Enum.Profession.Blacksmithing] =  CraftSim.BLACKSMITHING_DATA:GetData(),
    [Enum.Profession.Alchemy] = CraftSim.ALCHEMY_DATA:GetData(),
    [Enum.Profession.Leatherworking] = CraftSim.LEATHERWORKING_DATA:GetData(),
    [Enum.Profession.Jewelcrafting] = CraftSim.JEWELCRAFTING_DATA:GetData(),
    [Enum.Profession.Enchanting] = CraftSim.ENCHANTING_DATA:GetData(),
    [Enum.Profession.Tailoring] = CraftSim.TAILORING_DATA:GetData(),
    [Enum.Profession.Inscription] = CraftSim.INSCRIPTION_DATA:GetData()
} end

function CraftSim.SPEC_DATA:GetNodes(professionID)
    if professionID == Enum.Profession.Blacksmithing then
        return CraftSim.BLACKSMITHING_DATA.NODES()
    elseif professionID == Enum.Profession.Alchemy then
        return CraftSim.ALCHEMY_DATA.NODES()
    else
        error("CraftSim Error: No nodes found for profession id: " .. tostring(professionID))
        return {}
    end
end