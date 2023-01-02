addonName, CraftSim = ...

CraftSim.JEWELCRAFTING_DATA = {}

function CraftSim.JEWELCRAFTING_DATA:GetData()
    return {
        SAVING_SLIVERS_1 = {
            nodeID = 81119,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SAVING_SLIVERS_2 = {
            nodeID = 81119,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SAVING_SLIVERS_3 = {
            nodeID = 81119,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SAVING_SLIVERS_4 = {
            nodeID = 81119,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        }
    }
end