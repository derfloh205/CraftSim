addonName, CraftSim = ...

CraftSim.ALCHEMY_DATA = {}

function CraftSim.ALCHEMY_DATA:GetData()
    return {
        PHIAL_BATCHPRODUCTION = {
            nodeID = 22478,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.ELEMENTAL_BOTH},
            subtypeIDs = {CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS},
        },
        POTION_BATCHPRODUCTION = {
            nodeID = 19482,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.ELEMENTAL_BOTH},
            subtypeIDs = {CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS},
        },
        CHEMICAL_SYNTHESIS = {
            nodeID = 19537,
            threshold = 40,
            multicraftExtraItemsFactor = 0.50,
            categoryIDs = {CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE},
            subtypeIDs = {CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT, CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE},
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