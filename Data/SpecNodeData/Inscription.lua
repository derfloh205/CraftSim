AddonName, CraftSim = ...

CraftSim.INSCRIPTION_DATA = {}

function CraftSim.INSCRIPTION_DATA:GetData()
    return {
        PERFECT_PRACTICE_1 = {
            nodeID = 34834,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_2 = {
            nodeID = 34834,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_3 = {
            nodeID = 34834,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_4 = {
            nodeID = 34834,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        FLAWLESS_INKS = {
            nodeID = 34831,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.INKS
                }
            },
        }
    }
end