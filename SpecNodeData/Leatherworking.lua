CraftSimSPEC_NODE_DATA_LEATHERWORKING = {}

function CraftSimSPEC_NODE_DATA_LEATHERWORKING:GetData()
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
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS},
            subtypeIDs = {CraftSimCONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS},
        },
        CURING_AND_TANNING = {
            nodeID = 31180,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMORKITS},
            subtypeIDs = {CraftSimCONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMORKITS},
        }
    }
end