CraftSimSPEC_NODE_DATA_TAILORING = {}

function CraftSimSPEC_NODE_DATA_TAILORING:GetData()
    return {
        SPARING_SEWING_1 = {
            nodeID = 40006,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SPARING_SEWING_2 = {
            nodeID = 40006,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SPARING_SEWING_3 = {
            nodeID = 40006,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        },
        SPARING_SEWING_4 = {
            nodeID = 40006,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            categoryIDs = {},
            subtypeIDs = {} -- applies to everything
        }
    }
end