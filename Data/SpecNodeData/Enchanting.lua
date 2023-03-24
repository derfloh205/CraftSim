_, CraftSim = ...

CraftSim.ENCHANTING_DATA = {}

CraftSim.ENCHANTING_DATA.NODE_IDS = {
    ENCHANTMENT = 64143,
    PRIMAL = 64142,
    MATERIAL_MANIPULATION = 64136,
    BURNING = 64141,
    EARTHEN = 64140,
    SOPHIC = 64139,
    FROZEN = 64138,
    WAFTING = 64137,
    ADAPTIVE = 64135,
    ARTISTRY = 64134,
    MAGICAL_REINFORCEMENT = 64133,
    INSIGHT_OF_THE_BLUE = 68402,
    DRACONIC_DISENCHANTMENT = 68401,
    PRIMAL_EXTRACTION = 68400,
    RODS_RUNES_AND_RUSES = 68445,
    RODS_AND_WANDS = 68444,
    ILLUSORY_GOODS = 68443,
    RESOURCEFUL_WRIT = 68442,
    INSPIRED_DEVOTION = 68441
}

CraftSim.ENCHANTING_DATA.NODES = function()
    return {
        -- Enchantment
        {
            name = "Enchantment",
            nodeID = 64143
        },
        {
            name = "Primal",
            nodeID = 64142
        },
        {
            name = "Material Manipulation",
            nodeID = 64136
        },
        {
            name = "Burning",
            nodeID = 64141
        },
        {
            name = "Earthen",
            nodeID = 64140
        },
        {
            name = "Sophic",
            nodeID = 64139
        },
        {
            name = "Frozen",
            nodeID = 64138
        },
        {
            name = "Wafting",
            nodeID = 64137
        },
        {
            name = "Adaptive",
            nodeID = 64135
        },
        {
            name = "Artistry",
            nodeID = 64134
        },
        {
            name = "Magical Reinforcement",
            nodeID = 64133
        },
        -- Insight of the Blue
        {
            name = "Insight of the Blue",
            nodeID = 68402
        },
        {
            name = "Draconic Disenchantment",
            nodeID = 68401
        },
        {
            name = "Primal Extraction",
            nodeID = 68400
        },

        -- Rods, Runes and Ruses
        {
            name = "Rods, Runes and Ruses",
            nodeID = 68445
        },
        {
            name = "Rods and Wands",
            nodeID = 68444
        },
        {
            name = "Illusory Goods",
            nodeID = 68443
        },
        {
            name = "Resourceful Writ",
            nodeID = 68442
        },
        {
            name = "Inspired Devotion",
            nodeID = 68441
        },
    }
end

function CraftSim.ENCHANTING_DATA:GetData()
    return {
        ENCHANTMENT_1 = {
            nodeID = 64143,
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
        },
        PRIMAL_1 = {
            nodeID = 64142,
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
        },
        MATERIAL_MANIPULATION_1 = {
            nodeID = 64136,
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
        },
        BURNING_1 = {
            nodeID = 64141,
        },
        EARTHEN_1 = {
            nodeID = 64140,
        },
        SOPHIC_1 = {
            nodeID = 64139,
        },
        FROZEN_1 = {
            nodeID = 64138,
        },
        WAFTING_1 = {
            nodeID = 64137,
        },
        ADAPTIVE_1 = {
            nodeID = 64135,
        },
        ARTISTRY_1 = {
            nodeID = 64134,
        },
        MAGICAL_REINFORCEMENT_1 = {
            nodeID = 64133,
        },
        INSIGHT_OF_THE_BLUE_1 = {
            nodeID = 68402,
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
        },
        DRACONIC_DISENCHANTMENT_1 = {
            nodeID = 68401,
        },
        PRIMAL_EXTRACTION_1 = {
            nodeID = 68400,
        },
        RODS_RUNES_AND_RUSES_1 = {
            nodeID = 68445,
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
        },
        RODS_AND_WANDS_1 = {
            nodeID = 68444,
        },
        ILLUSORY_GOODS_1 = {
            nodeID = 68443,
        },
        INSPIRED_DEVOTION_1 = {
            nodeID = 68441,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_2 = {
            nodeID = 68441,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_3 = {
            nodeID = 68441,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_4 = {
            nodeID = 68441,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
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