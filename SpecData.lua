addonName, CraftSim = ...

CraftSim.SPEC_DATA = {}

function CraftSim.SPEC_DATA:GetIDsFromChildNodes(nodeData, relevantNodes)
    local IDs = {
        subtypeIDs = nodeData.subtypeIDs or {},
        categoryIDs = nodeData.categoryIDs or {},
        expectionRecipeIDs = nodeData.expectionRecipeIDs or {}
    }

    -- add from childs
    local childNodeIDs = nodeData.childNodeIDs
    if childNodeIDs then
        for _, childNodeID in pairs(childNodeIDs) do
            local childNoteData = relevantNodes[childNodeID]

            local childIDs = CraftSim.SPEC_DATA:GetIDsFromChildNodes(childNoteData, relevantNodes)
    
            for _, subtypeID in pairs(childIDs.subtypeIDs) do
                table.insert(IDs.subtypeIDs, subtypeID)
            end
            for _, categoryID in pairs(childIDs.categoryIDs) do
                table.insert(IDs.categoryIDs, categoryID)
            end
            for _, expectionID in pairs(childIDs.expectionRecipeIDs) do
                table.insert(IDs.expectionRecipeIDs, expectionID)
            end
        end

        return IDs
    end

    return IDs
end

function CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, relevantNodes)
    local specNodeData = recipeData.specNodeData

    local stats = {	
        inspiration = 0,
        inspirationBonusSkillFactor = 1,
        multicraft = 0,
        multicraftBonusItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessBonusItemsFactor = 1,
        craftingspeed = 0,
        craftingspeedBonusFactor = 1,
        skill = 0
    }

    for name, nodeData in pairs(relevantNodes) do 
        --local nodeInfo = C_Traits.GetNodeInfo(configID, nodeData.nodeID)
        local nodeInfo = specNodeData[nodeData.nodeID]

        if not nodeInfo then
            error("CraftSim Error: Node ID not implemented: " .. tostring(nodeData.nodeID))
        end
        -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
        -- only increase if the current recipe has a matching category AND Subtype (like weapons -> one handed axes)
        local nodeRank = nodeInfo.activeRank
        local nodeActualValue = nodeInfo.activeRank - 1

        -- fetch all subtypeIDs, categoryIDs and expectionRecipeIDs recursively
        local IDs = CraftSim.SPEC_DATA:GetIDsFromChildNodes(nodeData, relevantNodes)

        local isCategoryID = #IDs.categoryIDs == 0 or tContains(IDs.categoryIDs, recipeData.categoryID)
        local isSubtypeID = #IDs.subtypeIDs == 0 or tContains(IDs.subtypeIDs, recipeData.subtypeID)
        local isException = IDs.exceptionRecipeIDs and tContains(IDs.expectionRecipeIDs, recipeData.recipeID)
        local nodeAffectsRecipe = isSubtypeID and isCategoryID
        -- sometimes the category and subcategory can still not uniquely determine ..
        nodeAffectsRecipe = nodeAffectsRecipe or isException

        if nodeData.nodeID == 42828 then
            -- debug
            print("node affected: " .. tostring(nodeAffectsRecipe))
            print("isCategoryID: " .. tostring(isCategoryID))
            print("isSubtypeID: " .. tostring(isSubtypeID))
            print("isException " .. tostring(isException))
            print("ids: ")
            CraftSim.UTIL:PrintTable(IDs)
        end
        if nodeInfo and (nodeAffectsRecipe or nodeData.debug) then
            if nodeData.threshold and (nodeInfo.activeRank - 1) >= nodeData.threshold then
                -- ThresholdNode
                -- Stack multiplicatively (?)
                stats.multicraftBonusItemsFactor = stats.multicraftBonusItemsFactor * (1 + (nodeData.multicraftBonusItemsFactor or 0))
                stats.resourcefulnessBonusItemsFactor = stats.resourcefulnessBonusItemsFactor * (1 + (nodeData.resourcefulnessBonusItemsFactor or 0))
                stats.craftingspeedBonusFactor = stats.craftingspeedBonusFactor * (1 + (nodeData.craftingspeedBonusFactor or 0))
                stats.inspirationBonusSkillFactor = stats.inspirationBonusSkillFactor * (1 + (nodeData.inspirationBonusSkillFactor or 0))

                stats.skill = stats.skill + (nodeData.skill or 0)
                stats.inspiration = stats.inspiration + (nodeData.inspiration or 0)
                stats.multicraft = stats.multicraft + (nodeData.multicraft or 0)
                stats.resourcefulness = stats.resourcefulness + (nodeData.resourcefulness or 0)
                stats.craftingspeed = stats.craftingspeed + (nodeData.craftingspeed or 0)
            elseif nodeData.equalsSkill then
                print("equals skill node rule: " .. nodeData.nodeID)
                print("node equals skill, add " .. tostring(nodeActualValue))
                stats.skill = stats.skill + nodeActualValue
            elseif nodeData.equalsMulticraft then
                stats.multicraft = stats.multicraft + nodeActualValue
            elseif nodeData.equalsInspiration then
                stats.inspiration = stats.inspiration + nodeActualValue
            elseif nodeData.equalsResourcefulness then
                stats.resourcefulness = stats.resourcefulness + nodeActualValue
            elseif nodeData.equalsCraftingspeed then
                stats.craftingspeed = stats.craftingspeed + nodeActualValue
            end
        end
    end
    
    return stats
end

-- LEGACY.. remove when other ready
function CraftSim.SPEC_DATA:GetExtraItemFactors(recipeData, relevantNodes)
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(skillLineID)

    local extraItemFactors = {
        multicraftBonusItemsFactor = 1,
        resourcefulnessBonusItemsFactor = 1
    }

    for thresholdName, nodeData in pairs(relevantNodes) do 
        --print("getting nodeinfo: " .. tostring(configID))
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeData.nodeID)
        -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
        -- only increase if the current recipe has a matching category (like whetstone -> stonework, then only stonework marked nodes are relevant)
        -- or if categoryID of nodeData is nil which means its for the whole profession
        -- or if its debugged
        if nodeData and nodeData.categoryIDs and nodeData.threshold and nodeInfo and (nodeData.debug or (tContains(nodeData.categoryIDs, recipeData.categoryID) or #nodeData.categoryIDs == 0) and (nodeInfo.activeRank - 1) >= nodeData.threshold) then
            -- they stack multiplicatively
            extraItemFactors.multicraftBonusItemsFactor = extraItemFactors.multicraftBonusItemsFactor * (1 + (nodeData.multicraftBonusItemsFactor or 0))
            extraItemFactors.resourcefulnessBonusItemsFactor = extraItemFactors.resourcefulnessBonusItemsFactor * (1 + (nodeData.resourcefulnessBonusItemsFactor or 0))
        end
    end
    return extraItemFactors
end

function CraftSim.SPEC_DATA:GetSpecExtraItemFactorsByRecipeData(recipeData)
    local defaultFactors = {
        multicraftExtraItemsFactor = 1,
        resourcefulnessExtraItemsFactor = 1
    }

    local relevantNodes = CraftSim.SPEC_DATA.RELEVANT_NODES()[recipeData.professionID]
    if relevantNodes == nil then
        --print("Profession specs not considered: " .. recipeData.professionID)
        return defaultFactors
    end

    return CraftSim.SPEC_DATA:GetExtraItemFactors(recipeData, relevantNodes)
end

-- its a function so craftsimConst can be accessed (otherwise nil cause not yet initialized)
-- TODO: use if else if performance relevant
CraftSim.SPEC_DATA.RELEVANT_NODES = function() 
    return {
    [Enum.Profession.Blacksmithing] =  CraftSim.BLACKSMITHING_DATA:GetData(),
    [Enum.Profession.Alchemy] = CraftSim.ALCHEMY_DATA:GetData(),
    [Enum.Profession.Leatherworking] = CraftSim.LEATHERWORKING_DATA:GetData(),
    [Enum.Profession.Jewelcrafting] = CraftSim.JEWELCRAFTING_DATA:GetData(),
    [Enum.Profession.Enchanting] = CraftSim.ENCHANTING_DATA:GetData(),
    [Enum.Profession.Tailoring] = CraftSim.TAILORING_DATA:GetData(),
    [Enum.Profession.Inscription] = CraftSim.INSCRIPTION_DATA:GetData()
} end