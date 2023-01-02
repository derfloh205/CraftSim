addonName, CraftSim = ...

CraftSim.INSCRIPTION_DATA = {}

function CraftSim.INSCRIPTION_DATA:GetData()
    return {
        PERFECT_PRACTICE_1 = {
            nodeID = 34834,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        PERFECT_PRACTICE_2 = {
            nodeID = 34834,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        PERFECT_PRACTICE_3 = {
            nodeID = 34834,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        PERFECT_PRACTICE_4 = {
            nodeID = 34834,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        FLAWLESS_INKS = {
            nodeID = 34831,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION},
            subtypeIDs = {CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.INK}
        }
    }
end