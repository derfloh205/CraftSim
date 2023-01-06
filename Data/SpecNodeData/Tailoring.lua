addonName, CraftSim = ...

CraftSim.TAILORING_DATA = {}

function CraftSim.TAILORING_DATA:GetData()
    return {
        SPARING_SEWING_1 = {
            nodeID = 40006,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_2 = {
            nodeID = 40006,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_3 = {
            nodeID = 40006,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_4 = {
            nodeID = 40006,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        }
    }
end