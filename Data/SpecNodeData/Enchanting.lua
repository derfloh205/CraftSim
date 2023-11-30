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
        ENCHANTMENT_1 = { -- primal mapped, material mapped
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
            nodeID = 64143,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        ENCHANTMENT_2 = {
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
            nodeID = 64143,
            threshold = 0,
            skill = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        ENCHANTMENT_3 = {
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
            nodeID = 64143,
            threshold = 5,
            inspiration = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        ENCHANTMENT_4 = {
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
            nodeID = 64143,
            threshold = 15,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        ENCHANTMENT_5 = {
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
            nodeID = 64143,
            threshold = 25,
            inspiration = 5,
            craftingspeedBonusFactor = 0.10,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        ENCHANTMENT_6 = {
            childNodeIDs = {"PRIMAL_1", "MATERIAL_MANIPULATION_1"},
            nodeID = 64143,
            threshold = 30,
            skill = 10,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        PRIMAL_1 = { -- burning mapped, earthen mapped, sophic mapped, frozen mapped, wafting mapped
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_2 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 5,
            inspiration = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_3 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 15,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_4 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 25,
            skill = 5,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_5 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 30,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_6 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 40,
            skill = 10,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_7 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 45,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        PRIMAL_8 = {
            childNodeIDs = {"BURNING_1", "EARTHEN_1", "SOPHIC_1", "FROZEN_1", "WAFTING_1"},
            nodeID = 64142,
            threshold = 50,
            craftingspeedBonusFactor = 0.10,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        MATERIAL_MANIPULATION_1 = { -- adaptive mapped, artistry mapped, magical mapped
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_2 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 0,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_3 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_4 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 15,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_5 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_6 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 30,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_7 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 35,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MATERIAL_MANIPULATION_8 = {
            childNodeIDs = {"ADAPTIVE_1", "ARTISTRY_1", "MAGICAL_REINFORCEMENT_1"},
            nodeID = 64136,
            threshold = 40,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK,
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        BURNING_1 = {
            nodeID = 64141,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- Burning
                389547, -- Burning Devotion
                389537, -- Burning Writ
            },
        },
        BURNING_2 = {
            nodeID = 64141,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                389547, -- Burning Devotion
                389537, -- Burning Writ
            },
        },
        EARTHEN_1 = {
            nodeID = 64140,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- earthen
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
            },
        },
        EARTHEN_2 = {
            nodeID = 64140,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                389549, -- Earthen Devotion
                389540, -- Earthen Writ
            },
        },
        SOPHIC_1 = {
            nodeID = 64139,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- sophic
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
            },
        },
        SOPHIC_2 = {
            nodeID = 64139,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                389550, -- Sophic Devotion
                389542, -- Sophic Writ
            },
        },
        FROZEN_1 = {
            nodeID = 64138,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- frozen
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
            },
        },
        FROZEN_2 = {
            nodeID = 64138,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                389551, -- Frozen Devotion
                389543, -- Frozen Writ
            },
        },
        WAFTING_1 = {
            nodeID = 64137,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- wafting
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        WAFTING_2 = {
            nodeID = 64137,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                389558, -- Wafting Devotion
                389546, -- Wafting Writ
            },
        },
        ADAPTIVE_1 = {
            nodeID = 64135,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- adaptive
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                }
            },
        },
        ADAPTIVE_2 = {
            nodeID = 64135,
            threshold = 5,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                }
            },
        },
        ADAPTIVE_3 = {
            nodeID = 64135,
            threshold = 15,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                }
            },
        },
        ADAPTIVE_4 = {
            nodeID = 64135,
            threshold = 25,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                }
            },
        },
        ADAPTIVE_5 = {
            nodeID = 64135,
            threshold = 30,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                }
            },
        },
        ARTISTRY_1 = {
            nodeID = 64134,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- artistry
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                },
            },
        },
        ARTISTRY_2 = {
            nodeID = 64134,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        ARTISTRY_3 = {
            nodeID = 64134,
            threshold = 10,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        ARTISTRY_4 = {
            nodeID = 64134,
            threshold = 20,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        ARTISTRY_5 = {
            nodeID = 64134,
            threshold = 25,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        ARTISTRY_6 = {
            nodeID = 64134,
            threshold = 30,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        MAGICAL_REINFORCEMENT_1 = {
            nodeID = 64133,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- magical
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MAGICAL_REINFORCEMENT_2 = {
            nodeID = 64133,
            threshold = 5,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MAGICAL_REINFORCEMENT_3 = {
            nodeID = 64133,
            threshold = 10,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MAGICAL_REINFORCEMENT_4 = {
            nodeID = 64133,
            threshold = 15,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MAGICAL_REINFORCEMENT_5 = {
            nodeID = 64133,
            threshold = 25,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        MAGICAL_REINFORCEMENT_6 = {
            nodeID = 64133,
            threshold = 30,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                }
            },
        },
        INSIGHT_OF_THE_BLUE_1 = { -- draconic mapped, primal mapped
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
        },
        INSIGHT_OF_THE_BLUE_2 = {
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
            threshold = 5,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic, primal
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        INSIGHT_OF_THE_BLUE_3 = {
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
            threshold = 15,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        INSIGHT_OF_THE_BLUE_4 = {
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        INSIGHT_OF_THE_BLUE_5 = {
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
            threshold = 30,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        INSIGHT_OF_THE_BLUE_6 = {
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
            threshold = 40,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        INSIGHT_OF_THE_BLUE_7 = {
            childNodeIDs = {"DRACONIC_DISENCHANTMENT_1", "PRIMAL_EXTRACTION_1"},
            nodeID = 68402,
            threshold = 45,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        DRACONIC_DISENCHANTMENT_1 = {
            nodeID = 68401,
            -- gives extraitems when disenchanting
        },
        DRACONIC_DISENCHANTMENT_2 = {
            nodeID = 68401,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    -- draconic
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        DRACONIC_DISENCHANTMENT_3 = {
            nodeID = 68401,
            threshold = 15,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        DRACONIC_DISENCHANTMENT_4 = {
            nodeID = 68401,
            threshold = 25,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        DRACONIC_DISENCHANTMENT_5 = {
            nodeID = 68401,
            threshold = 35,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        PRIMAL_EXTRACTION_1 = {
            nodeID = 68400,
            -- more rousing elements
        },
        PRIMAL_EXTRACTION_2 = {
            nodeID = 68400,
            threshold = 5,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        PRIMAL_EXTRACTION_3 = {
            nodeID = 68400,
            threshold = 15,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        PRIMAL_EXTRACTION_4 = {
            nodeID = 68400,
            threshold = 25,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        PRIMAL_EXTRACTION_5 = {
            nodeID = 68400,
            threshold = 30,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        PRIMAL_EXTRACTION_6 = {
            nodeID = 68400,
            threshold = 35,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CLOAK_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CLOAK
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.CHEST_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.CHEST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BRACER_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WRIST
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.BOOT_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FEET
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RING_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.FINGER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.WEAPON_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WEAPON
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.PROFESSION_TOOL_ENCHANTMENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.PROFESSION_TOOL
                }
            },
        },
        RODS_RUNES_AND_RUSES_1 = { -- mapped all 
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            equalsSkill = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_RUNES_AND_RUSES_2 = {
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            threshold = 0,
            craftingspeedBonusFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_RUNES_AND_RUSES_3 = {
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            threshold = 5,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_RUNES_AND_RUSES_4 = {
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            threshold = 15,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_RUNES_AND_RUSES_5 = {
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            threshold = 25,
            craftingspeedBonusFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_RUNES_AND_RUSES_6 = {
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            threshold = 35,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_RUNES_AND_RUSES_7 = {
            childNodeIDs = {"RODS_AND_WANDS_1", "ILLUSORY_GOODS_1", "RESOURCEFUL_WRIT_1", "INSPIRED_DEVOTION_1"},
            nodeID = 68445,
            threshold = 40,
            skill = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RODS_AND_WANDS_1 = {
            nodeID = 68444,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    -- rods and wands
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        RODS_AND_WANDS_2 = {
            nodeID = 68444,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        RODS_AND_WANDS_3 = {
            nodeID = 68444,
            threshold = 15,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        RODS_AND_WANDS_4 = {
            nodeID = 68444,
            threshold = 25,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        RODS_AND_WANDS_5 = {
            nodeID = 68444,
            threshold = 35,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        RODS_AND_WANDS_6 = {
            nodeID = 68444,
            threshold = 40,
            skill = 15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        RODS_AND_WANDS_7 = {
            nodeID = 68444,
            threshold = 45,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.RODS_AND_WANDS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.RODS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.WANDS
                }
            },
        },
        ILLUSORY_GOODS_1 = {
            nodeID = 68443,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.ILLUSORY_GOODS] = {
                    -- illusory goods
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSIONS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSORY_ADORNMENTS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.SCEPTERS
                },
            },
        },
        ILLUSORY_GOODS_2 = {
            nodeID = 68443,
            threshold = 0,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.ILLUSORY_GOODS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSIONS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSORY_ADORNMENTS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.SCEPTERS
                }
            },
        },
        ILLUSORY_GOODS_3 = {
            nodeID = 68443,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.ILLUSORY_GOODS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSIONS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSORY_ADORNMENTS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.SCEPTERS
                }
            },
        },
        ILLUSORY_GOODS_4 = {
            nodeID = 68443,
            threshold = 15,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.ILLUSORY_GOODS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSIONS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSORY_ADORNMENTS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.SCEPTERS
                }
            },
        },
        ILLUSORY_GOODS_5 = {
            nodeID = 68443,
            threshold = 25,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENCHANTING.ILLUSORY_GOODS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSIONS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.ILLUSORY_ADORNMENTS,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENCHANTING.SCEPTERS
                }
            },
        },
        INSPIRED_DEVOTION_1 = {
            nodeID = 68441,
            equalsInspiration = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_2 = {
            nodeID = 68441,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_3 = {
            nodeID = 68441,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                -- Ring Devotions
                389292, -- Crit
                389293, -- Haste
                389294, -- Mastery
                389295, -- Vers
                -- Bracer Devotions 
                389301, -- Avoidance
                389303, -- Leech
                389304, -- Speed
                -- Weapon Devotions
                389547, -- Burning
                389549, -- Earthen
                389551, -- Frozen
                389550, -- Sophic
                389558, -- Wafting
            },
        },
        INSPIRED_DEVOTION_4 = {
            nodeID = 68441,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_5 = {
            nodeID = 68441,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                -- Ring Devotions
                389292, -- Crit
                389293, -- Haste
                389294, -- Mastery
                389295, -- Vers
                -- Bracer Devotions
                389301, -- Avoidance
                389303, -- Leech
                389304, -- Speed
                -- Weapon Devotions
                389547, -- Burning
                389549, -- Earthen
                389551, -- Frozen
                389550, -- Sophic
                389558, -- Wafting
            },
        },
        INSPIRED_DEVOTION_6 = {
            nodeID = 68441,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRED_DEVOTION_7 = {
            nodeID = 68441,
            threshold = 25,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- Ring Devotions
                389292, -- Crit
                389293, -- Haste
                389294, -- Mastery
                389295, -- Vers
                -- Bracer Devotions
                389301, -- Avoidance
                389303, -- Leech
                389304, -- Speed
                -- Weapon Devotions
                389547, -- Burning
                389549, -- Earthen
                389551, -- Frozen
                389550, -- Sophic
                389558, -- Wafting
            },
        },
        INSPIRED_DEVOTION_8 = {
            nodeID = 68441,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_1 = {
            nodeID = 68442,
            equalsResourcefulness = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_2 = {
            nodeID = 68442,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_3 = {
            nodeID = 68442,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                -- Cloak Writs
                389397, -- Avoidance
                389398, -- Leech
                389400, -- Speed
                -- Bracer Writs
                389297, -- Avoidance
                389298, -- Leech
                389300, -- Speed
                -- Ring Writs
                388930, -- Crit
                389135, -- Haste
                389136, -- Mastery
                389151, -- Vers
                -- Weapon Writs
                389537, -- Burning
                389540, -- Earthen
                389543, -- Frozen
                389542, -- Sophic
                389546, -- Wafting
            },
        },
        RESOURCEFUL_WRIT_4 = {
            nodeID = 68442,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_5 = {
            nodeID = 68442,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                -- Cloak Writs
                389397, -- Avoidance
                389398, -- Leech
                389400, -- Speed
                -- Bracer Writs
                389297, -- Avoidance
                389298, -- Leech
                389300, -- Speed
                -- Ring Writs
                388930, -- Crit
                389135, -- Haste
                389136, -- Mastery
                389151, -- Vers
                -- Weapon Writs
                389537, -- Burning
                389540, -- Earthen
                389543, -- Frozen
                389542, -- Sophic
                389546, -- Wafting
            },
        },
        RESOURCEFUL_WRIT_6 = {
            nodeID = 68442,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_WRIT_7 = {
            nodeID = 68442,
            threshold = 25,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- Cloak Writs
                389397, -- Avoidance
                389398, -- Leech
                389400, -- Speed
                -- Bracer Writs
                389297, -- Avoidance
                389298, -- Leech
                389300, -- Speed
                -- Ring Writs
                388930, -- Crit
                389135, -- Haste
                389136, -- Mastery
                389151, -- Vers
                -- Weapon Writs
                389537, -- Burning
                389540, -- Earthen
                389543, -- Frozen
                389542, -- Sophic
                389546, -- Wafting
            },
        },
        RESOURCEFUL_WRIT_8 = {
            nodeID = 68442,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        }
    }
end