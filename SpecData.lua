CraftSimSPECDATA = {}

function CraftSimSPECDATA:GetExtraItemFactors(recipeData, relevantNodes)
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(skillLineID)

    local extraItemFactors = {
        multicraftExtraItemsFactor = 1,
        resourcefulnessExtraItemsFactor = 1
    }

    for thresholdName, nodeData in pairs(relevantNodes) do 
        --print("getting nodeinfo: " .. tostring(configID))
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeData.nodeID)
        -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
        -- only increase if the current recipe has a matching category (like whetstone -> stonework, then only stonework marked nodes are relevant)
        -- or if categoryID of nodeData is nil which means its for the whole profession
        -- or if its debugged
        if nodeInfo and (nodeData.debug or (tContains(nodeData.categoryIDs, recipeData.categoryID) or #nodeData.categoryIDs == 0) and (nodeInfo.activeRank - 1) >= nodeData.threshold) then
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
    local relevantNodes = CraftSimSPECDATA.RELEVANT_NODES()[recipeData.professionID]
    if relevantNodes == nil then
        --print("Profession specs not considered: " .. recipeData.professionID)
        return defaultFactors
    end

    return CraftSimSPECDATA:GetExtraItemFactors(recipeData, relevantNodes)
end

-- its a function so craftsimConst can be accessed (otherwise nil cause not yet initialized)
CraftSimSPECDATA.RELEVANT_NODES = function() return {
    [Enum.Profession.Blacksmithing] =  {
        STONEWORK = {
            nodeID = 23762,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.BLACKSMITHING.STONEWORK}
        },
        SMELTING = {
            nodeID = 23761,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.BLACKSMITHING.SMELTING}
        },
        SAFETY_SMITHING_1 = {
            nodeID = 42827,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {}, -- applies to everything,
        },
        SAFETY_SMITHING_2 = {
            nodeID = 42827,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {} -- applies to everything
        },
        SAFETY_SMITHING_3 = {
            nodeID = 42827,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {} -- applies to everything
        },
        SAFETY_SMITHING_4 = {
            nodeID = 42827,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {} -- applies to everything
        }
    },
    [Enum.Profession.Alchemy] = {
        PHIAL_BATCHPRODUCTION = {
            nodeID = 22478,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            -- TODO: how to distinquish between elemental potion/phial?
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.ELEMENTAL_BOTH},
        },
        POTION_BATCHPRODUCTION = {
            nodeID = 19482,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            -- TODO: how to distinquish between elemental potion/phial?
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.ELEMENTAL_BOTH},
        },
        CHEMICAL_SYNTHESIS = {
            nodeID = 19537,
            threshold = 40,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE}
        },
        RESOURCEFUL_ROUTINES_1 = {
            nodeID = 19535,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {}
        },
        RESOURCEFUL_ROUTINES_2 = {
            nodeID = 19535,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        RESOURCEFUL_ROUTINES_3 = {
            nodeID = 19535,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        RESOURCEFUL_ROUTINES_4 = {
            nodeID = 19535,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {}
        }
    },
    [Enum.Profession.Leatherworking] = {
        SHEAR_MASTERY_1 = {
            nodeID = 31183,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {}
        },
        SHEAR_MASTERY_2 = {
            nodeID = 31183,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        SHEAR_MASTERY_3 = {
            nodeID = 31183,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        SHEAR_MASTERY_4 = {
            nodeID = 31183,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {}
        },
        BONDING_AND_STITCHING = {
            nodeID = 31181,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS}
        },
        CURING_AND_TANNING = {
            nodeID = 31180,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMORKITS}
        }
    },
    [Enum.Profession.Jewelcrafting] = {
        SAVING_SLIVERS_1 = {
            nodeID = 81119,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {}
        },
        SAVING_SLIVERS_2 = {
            nodeID = 81119,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        SAVING_SLIVERS_3 = {
            nodeID = 81119,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        SAVING_SLIVERS_4 = {
            nodeID = 81119,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {}
        }
    },
    [Enum.Profession.Enchanting] = {
        RESOURCEFUL_WRIT_1 = {
            nodeID = 68442,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {} -- TODO: is this really for everything?
        },
        RESOURCEFUL_WRIT_2 = {
            nodeID = 68442,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        RESOURCEFUL_WRIT_3 = {
            nodeID = 68442,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        RESOURCEFUL_WRIT_4 = {
            nodeID = 68442,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {}
        }
    },
    [Enum.Profession.Tailoring] = {
        SPARING_SEWING_1 = {
            nodeID = 40006,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {}
        },
        SPARING_SEWING_2 = {
            nodeID = 40006,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        SPARING_SEWING_3 = {
            nodeID = 40006,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        SPARING_SEWING_4 = {
            nodeID = 40006,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {}
        }
    },
    [Enum.Profession.Inscription] = {
        PERFECT_PRACTICE_1 = {
            nodeID = 34834,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {}
        },
        PERFECT_PRACTICE_2 = {
            nodeID = 34834,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        PERFECT_PRACTICE_3 = {
            nodeID = 34834,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {}
        },
        PERFECT_PRACTICE_4 = {
            nodeID = 34834,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {}
        },
        FLAWLESS_INKS = {
            nodeID = 34831,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.INSCRIPTION.INK}
        }
    }
} end