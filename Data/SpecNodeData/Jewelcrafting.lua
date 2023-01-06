addonName, CraftSim = ...

CraftSim.JEWELCRAFTING_DATA = {}

function CraftSim.JEWELCRAFTING_DATA:GetData()
    return {
        SAVING_SLIVERS_1 = {
            nodeID = 81119,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_2 = {
            nodeID = 81119,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_3 = {
            nodeID = 81119,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_4 = {
            nodeID = 81119,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        }
    }
end