CraftSimSPEC_NODE_DATA_ALCHEMY = {}

function CraftSimSPEC_NODE_DATA_ALCHEMY:GetData()
    return {
        PHIAL_BATCHPRODUCTION = {
            nodeID = 22478,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.ELEMENTAL_BOTH},
            subtypeIDs = {CraftSimCONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS},
        },
        POTION_BATCHPRODUCTION = {
            nodeID = 19482,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.ELEMENTAL_BOTH},
            subtypeIDs = {CraftSimCONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS},
        },
        CHEMICAL_SYNTHESIS = {
            nodeID = 19537,
            threshold = 40,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE},
            subtypeIDs = {CraftSimCONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT, CraftSimCONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE},
        },
        RESOURCEFUL_ROUTINES_1 = {
            nodeID = 19535,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        RESOURCEFUL_ROUTINES_2 = {
            nodeID = 19535,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        RESOURCEFUL_ROUTINES_3 = {
            nodeID = 19535,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        RESOURCEFUL_ROUTINES_4 = {
            nodeID = 19535,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        }
    }
end