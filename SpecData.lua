CraftSimSPECDATA = {}

-- its a function so craftsimConst can be accessed (otherwise nil cause not yet initialized)
CraftSimSPECDATA.RELEVANT_NODES = function() return {
    BLACKSMITHING =  {
        STONEWORK = {
            nodeID = 23762,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryID = CraftSimCONST.RECIPE_CATEGORIES.BLACKSMITHING.STONEWORK
        },
        SMELTING = {
            nodeID = 23761,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryID = CraftSimCONST.RECIPE_CATEGORIES.BLACKSMITHING.SMELTING
        },
        SAFETY_SMITHING_1 = {
            nodeID = 42827,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryID = nil, -- applies to everything,
            debug = false
        },
        SAFETY_SMITHING_2 = {
            nodeID = 42827,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryID = nil -- applies to everything
        },
        SAFETY_SMITHING_3 = {
            nodeID = 42827,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryID = nil -- applies to everything
        },
        SAFETY_SMITHING_4 = {
            nodeID = 42827,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryID = nil -- applies to everything
        }
    }
} end

function CraftSimSPECDATA:GetExtraItemFactors(recipeData, relevantNodes)
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(skillLineID)

    local extraItemFactors = {
        multicraftExtraItemsFactor = 1,
        resourcefulnessExtraItemsFactor = 1
    }

    for thresholdName, nodeData in pairs(relevantNodes) do 
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeData.nodeID)

        -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
        -- only increase if the current recipe has a matching category (like whetstone -> stonework, then only stonework marked nodes are relevant)
        -- or if categoryID of nodeData is nil which means its for the whole profession
        -- or if its debugged
        if nodeData.debug or (recipeData.categoryID == nodeData.categoryID or not nodeData.categoryID) and (nodeInfo.activeRank - 1) >= nodeData.threshold then
            -- they stack multiplicatively
            extraItemFactors.multicraftExtraItemsFactor = extraItemFactors.multicraftExtraItemsFactor * (1 + (nodeData.multicraftExtraItemsFactor or 0))
            extraItemFactors.resourcefulnessExtraItemsFactor = extraItemFactors.resourcefulnessExtraItemsFactor * (1 + (nodeData.resourcefulnessExtraItemsFactor or 0))
        end
    end
    return extraItemFactors
end

function CraftSimSPECDATA:GetSpecExtraItemFactorsByRecipeData(recipeData)
    local defaultFactors = {
        multicraftExtraItemsFactor = 1,
        resourcefulnessExtraItemsFactor = 1
    }

    -- TODO: All professions...
	if recipeData.professionID == Enum.Profession.Blacksmithing then
        return CraftSimSPECDATA:GetExtraItemFactors(recipeData, CraftSimSPECDATA.RELEVANT_NODES().BLACKSMITHING)
	end

    return defaultFactors
end