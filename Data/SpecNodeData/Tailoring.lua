AddonName, CraftSim = ...

CraftSim.TAILORING_DATA = {}

CraftSim.TAILORING_DATA.NODES = function()
    return {
        -- Tailoring Mastery
        {
            name = "Tailoring Mastery",
            nodeID = 40008
        },
        {
            name = "Cloth Collection",
            nodeID = 40007
        },
        {
            name = "Sparing Sewing",
            nodeID = 40006
        },
        {
            name = "Shrewd Stitchery",
            nodeID = 40005
        },
        -- Textiles
        {
            name = "Textiles",
            nodeID = 40038
        },
        {
            name = "Spinning",
            nodeID = 40037
        },
        {
            name = "Weaving",
            nodeID = 40036
        },
        {
            name = "Embroidery",
            nodeID = 40035
        },
        -- Draconic Needlework
        {
            name = "Draconic Needlework",
            nodeID = 40074
        },
        {
            name = "Azureweave Tailoring",
            nodeID = 40073
        },
        {
            name = "Azureweaving",
            nodeID = 40072
        },
        {
            name = "Chronocloth Tailoring",
            nodeID = 40071
        },
        {
            name = "Timeweaving",
            nodeID = 40070
        },
        -- Garmentcrafting
        {
            name = "Garmentcrafting",
            nodeID = 40226
        },
        {
            name = "Outerwear",
            nodeID = 40222
        },
        {
            name = "Gloves",
            nodeID = 40221
        },
        {
            name = "Footwear",
            nodeID = 40220
        },
        {
            name = "Hats",
            nodeID = 40219
        },
        {
            name = "Cloaks",
            nodeID = 40218
        },
        {
            name = "Outfits",
            nodeID = 40225
        },
        {
            name = "Robes",
            nodeID = 40224
        },
        {
            name = "Leggings",
            nodeID = 40223
        },
        {
            name = "Embellishments",
            nodeID = 40217
        },
        {
            name = "Mantles",
            nodeID = 40216
        },
        {
            name = "Armbands",
            nodeID = 40215
        },
        {
            name = "Belts",
            nodeID = 40214
        },
    }
end

function CraftSim.TAILORING_DATA:GetData()
    return {
        TAILORING_MASTERY_1 = {
            nodeID = 40008,
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
        },
        CLOTH_COLLECTION_1 = {
            nodeID = 40007,
        },
        SHREWD_STITCHERY_1 = {
            nodeID = 40005,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_2 = {
            nodeID = 40005,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_3 = {
            nodeID = 40005,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_4 = {
            nodeID = 40005,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TEXTILES_1 = {
            nodeID = 40038,
            childNodeIDs = {"SPINNING_1", "WEAVING_1", "EMBROIDERY_1", },
        },
        SPINNING_1 = {
            nodeID = 40037,
        },
        WEAVING_1 = {
            nodeID = 40036,
        },
        EMBROIDERY_1 = {
            nodeID = 40035,
        },
        DRACONIC_NEEDLEWORK_1 = {
            nodeID = 40074,
            childNodeIDs = {"AZUREWEAVE_TAILORING_1", "CHRONOCLOTH_TAILORING_1"},
        },
        AZUREWEAVE_TAILORING_1 = {
            nodeID = 40073,
            childNodeIDs = {"AZUREWEAVING_1"},
        },
        AZUREWEAVING_1 = {
            nodeID = 40072,
        },
        CHRONOCLOTH_TAILORING_1 = {
            nodeID = 40071,
            childNodeIDs = {"TIMEWEAVING_1"},
        },
        TIMEWEAVING_1 = {
            nodeID = 40070,
        },
        GARMENTCRAFTING_1 = {
            nodeID = 40226,
            childNodeIDs = {"OUTERWEAR_1", "OUTFITS_1", "EMBELLISHMENTS_1"},
        },
        OUTERWEAR_1 = {
            nodeID = 40222,
            childNodeIDs = {"GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1"},
        },
        GLOVES_1 = {
            nodeID = 40221,
        },
        FOOTWEAR_1 = {
            nodeID = 40220,
        },
        HATS_1 = {
            nodeID = 40219,
        },
        CLOAKS_1 = {
            nodeID = 40218,
        },
        OUTFITS_1 = {
            nodeID = 40225,
            childNodeIDs = {"ROBES_1", "LEGGINGS_1"},
        },
        ROBES_1 = {
            nodeID = 40224,
        },
        LEGGINGS_1 = {
            nodeID = 40223,
        },
        EMBELLISHMENTS_1 = {
            nodeID = 40217,
            childNodeIDs = {"MANTLES_1", "ARMBANDS_1", "BELTS_1"},
        },
        MANTLES_1 = {
            nodeID = 40216,
        },
        ARMBANDS_1 = {
            nodeID = 40215,
        },
        BELTS_1 = {
            nodeID = 40214,
        },
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