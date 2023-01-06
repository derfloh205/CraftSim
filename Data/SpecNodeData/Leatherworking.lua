addonName, CraftSim = ...

CraftSim.LEATHERWORKING_DATA = {}

function CraftSim.LEATHERWORKING_DATA:GetData()
    return {
        SHEAR_MASTERY_1 = {
            nodeID = 31183,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SHEAR_MASTERY_2 = {
            nodeID = 31183,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SHEAR_MASTERY_3 = {
            nodeID = 31183,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SHEAR_MASTERY_4 = {
            nodeID = 31183,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        BONDING_AND_STITCHING = {
            nodeID = 31181,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS},
            subtypeIDs = {CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS},
        },
        CURING_AND_TANNING = {
            nodeID = 31180,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMORKITS},
            subtypeIDs = {CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMORKITS},
        }
    }
end