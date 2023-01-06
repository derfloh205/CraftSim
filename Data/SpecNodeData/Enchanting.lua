addonName, CraftSim = ...

CraftSim.ENCHANTING_DATA = {}

function CraftSim.ENCHANTING_DATA:GetData()
    return {
        RESOURCEFUL_WRIT_1 = {
            nodeID = 68442,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_2 = {
            nodeID = 68442,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_3 = {
            nodeID = 68442,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_4 = {
            nodeID = 68442,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        }
    }
end