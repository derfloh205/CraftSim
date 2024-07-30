---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.BLACKSMITHING_DATA =
{
    -- EVER BURNING FORGE
    EVER_BURNING_FORGE_1 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        threshold = 0,
        equalsIngenuity = 3,
        equalsMulticraft = 3,
        equalsResourcefulness = 3,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        concentrationLessUsageFactor = 0.1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EVER_BURNING_FORGE_2 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        threshold = 0,
        concentrationLessUsageFactor = 0.1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EVER_BURNING_FORGE_3 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        threshold = 5,
        concentrationLessUsageFactor = 0.1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EVER_BURNING_FORGE_4 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        threshold = 15,
        concentrationLessUsageFactor = 0.1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EVER_BURNING_FORGE_5 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        threshold = 25,
        concentrationLessUsageFactor = 0.1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EVER_BURNING_FORGE_6 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        threshold = 35,
        concentrationLessUsageFactor = 0.1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_1 = {
        nodeID = 99266,
        threshold = 0,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        equalsIngenuity = 3,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_2 = {
        nodeID = 99266,
        threshold = 0,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        ingenuity = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_3 = {
        nodeID = 99266,
        threshold = 5,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        ingenuity = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_4 = {
        nodeID = 99266,
        threshold = 10,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        ingenuity = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_5 = {
        nodeID = 99266,
        threshold = 15,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        ingenuity = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_6 = {
        nodeID = 99266,
        threshold = 20,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        ingenuity = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_1 = {
        nodeID = 99265,
        threshold = 0,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        equalsResourcefulness = 3,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_2 = {
        nodeID = 99265,
        threshold = 0,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        resourcefulness = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_3 = {
        nodeID = 99265,
        threshold = 5,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        resourcefulness = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_4 = {
        nodeID = 99265,
        threshold = 10,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        resourcefulness = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_5 = {
        nodeID = 99265,
        threshold = 15,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        resourcefulness = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_6 = {
        nodeID = 99265,
        threshold = 20,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        resourcefulness = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_1 = {
        nodeID = 99264,
        threshold = 0,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        equalsMulticraft = 3,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_2 = {
        nodeID = 99264,
        threshold = 0,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        multicraft = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_3 = {
        nodeID = 99264,
        threshold = 5,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        multicraft = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_4 = {
        nodeID = 99264,
        threshold = 10,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        multicraft = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_5 = {
        nodeID = 99264,
        threshold = 15,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        multicraft = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_6 = {
        nodeID = 99264,
        threshold = 20,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION },
        multicraft = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    -- MEANS OF PRODUCTION
    MEANS_OF_PRODUCTION_1 = {
        childNodeIDs = { "TOOLS_OF_THE_TRADE_1", "STONEWORK_1", "FORTUITOUS_FORGES_1" },
        nodeID = 99589,
        threshold = 0,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    MEANS_OF_PRODUCTION_2 = {
        childNodeIDs = { "TOOLS_OF_THE_TRADE_1", "STONEWORK_1", "FORTUITOUS_FORGES_1" },
        nodeID = 99589,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    MEANS_OF_PRODUCTION_3 = {
        childNodeIDs = { "TOOLS_OF_THE_TRADE_1", "STONEWORK_1", "FORTUITOUS_FORGES_1" },
        nodeID = 99589,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    MEANS_OF_PRODUCTION_13 = {
        childNodeIDs = { "TOOLS_OF_THE_TRADE_1", "STONEWORK_1", "FORTUITOUS_FORGES_1" },
        nodeID = 99589,
        threshold = 25,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_1 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 0,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_2 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_3 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_4 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_5 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 20,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_6 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 25,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TOOLS_OF_THE_TRADE_7 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        threshold = 30,
        ingenuity = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    TRADE_TOOLS_1 = {
        nodeID = 99587,
        threshold = 0,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionToolType
            },
        },
    },
    TRADE_TOOLS_2 = {
        nodeID = 99587,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionToolType
            },
        },
    },
    TRADE_TOOLS_3 = {
        nodeID = 99587,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionToolType
            },
        },
    },
    TRADE_TOOLS_4 = {
        nodeID = 99587,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionToolType
            },
        },
    },
    TRADE_ACCESSORIES_1 = {
        nodeID = 99586,
        threshold = 0,
        skill = 5,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionGearType
            },
        },
    },
    TRADE_ACCESSORIES_2 = {
        nodeID = 99586,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionGearType
            },
        },
    },
    TRADE_ACCESSORIES_3 = {
        nodeID = 99586,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionGearType
            },
        },
    },
    TRADE_ACCESSORIES_4 = {
        nodeID = 99586,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.PROFESSION_EQUIPMENT] = {
                Enum.InventoryType.IndexProfessionGearType
            },
        },
    },
    STONEWORK_1 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    STONEWORK_2 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    STONEWORK_3 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    STONEWORK_4 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    STONEWORK_5 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        threshold = 20,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    STONEWORK_6 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        threshold = 25,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    WEAPON_STONES_1 = {
        nodeID = 99584,
        threshold = 0,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- weapon stones
            450287, -- ironclaw weightstone
            450285, -- ironclaw whetstone
        },
    },
    WEAPON_STONES_2 = {
        nodeID = 99584,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            -- weapon stones
            450287, -- ironclaw weightstone
            450285, -- ironclaw whetstone
        },
    },
    WEAPON_STONES_3 = {
        nodeID = 99584,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            -- weapon stones
            450287, -- ironclaw weightstone
            450285, -- ironclaw whetstone
        },
    },
    WEAPON_STONES_4 = {
        nodeID = 99584,
        threshold = 15,
        skill = 10,
        exceptionRecipeIDs = {
            -- weapon stones
            450287, -- ironclaw weightstone
            450285, -- ironclaw whetstone
        },
    },
    TOOL_ENHANCEMENT_1 = {
        nodeID = 99583,
        threshold = 0,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- tool stones
            450286, -- ironclaw razorstone
        },
    },
    TOOL_ENHANCEMENT_2 = {
        nodeID = 99583,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            -- tool stones
            450286, -- ironclaw razorstone
        },
    },
    TOOL_ENHANCEMENT_3 = {
        nodeID = 99583,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            -- tool stones
            450286, -- ironclaw razorstone
        },
    },
    TOOL_ENHANCEMENT_4 = {
        nodeID = 99583,
        threshold = 15,
        skill = 10,
        exceptionRecipeIDs = {
            -- tool stones
            450286, -- ironclaw razorstone
        },
    },
    FORTUITOUS_FORGES_1 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FORTUITOUS_FORGES_2 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FORTUITOUS_FORGES_3 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 10,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FORTUITOUS_FORGES_4 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 15,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FORTUITOUS_FORGES_5 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 20,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FORTUITOUS_FORGES_6 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 25,
        multicraft = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FORTUITOUS_FORGES_7 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        threshold = 30,
        multicraft = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FRAME_WORKS_1 = {
        nodeID = 99581,
        threshold = 0,
        equalsSkill = 0,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FRAME_WORKS_2 = {
        nodeID = 99581,
        threshold = 5,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FRAME_WORKS_3 = {
        nodeID = 99581,
        threshold = 10,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    FRAME_WORKS_4 = {
        nodeID = 99581,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.FRAMEWORKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    ALLOYS_1 = {
        nodeID = 99580,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    ALLOYS_2 = {
        nodeID = 99580,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    ALLOYS_3 = {
        nodeID = 99580,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    ALLOYS_4 = {
        nodeID = 99580,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },

    -- WEAPON SMITHING
    WEAPON_SMITHING_1 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 0,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
            -- TODO: "Big Profession Tools" - All Profession Tools listed in learned/unlearned seem not to be affected
        },
    },
    WEAPON_SMITHING_2 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    WEAPON_SMITHING_3 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    WEAPON_SMITHING_4 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 15,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    WEAPON_SMITHING_5 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 20,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    WEAPON_SMITHING_6 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 25,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    WEAPON_SMITHING_7 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        threshold = 30,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
            },
        },
    },
    BLADES_1 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,
        threshold = 0,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    BLADES_2 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    BLADES_3 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    BLADES_4 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,
        threshold = 15,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    BLADES_5 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,
        threshold = 20,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    SHORT_BLADES_1 = {
        nodeID = 99451,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    SHORT_BLADES_2 = {
        nodeID = 99451,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    SHORT_BLADES_3 = {
        nodeID = 99451,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    SHORT_BLADES_4 = {
        nodeID = 99451,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    SHORT_BLADES_5 = {
        nodeID = 99451,
        threshold = 20,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
            },
        },
    },
    LONG_BLADES_1 = {
        nodeID = 99450,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
            },
        },
    },
    LONG_BLADES_2 = {
        nodeID = 99450,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
            },
        },
    },
    LONG_BLADES_3 = {
        nodeID = 99450,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
            },
        },
    },
    LONG_BLADES_4 = {
        nodeID = 99450,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
            },
        },
    },
    LONG_BLADES_5 = {
        nodeID = 99450,
        threshold = 20,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
            },
        },
    },
    HAFTED_1 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,
        threshold = 0,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    HAFTED_2 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    HAFTED_3 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    HAFTED_4 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,
        threshold = 15,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    HAFTED_5 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,
        threshold = 20,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    MACES_1 = {
        nodeID = 99448,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
            },
        },
    },
    MACES_2 = {
        nodeID = 99448,
        threshold = 5,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
            },
        },
    },
    MACES_3 = {
        nodeID = 99448,
        threshold = 10,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
            },
        },
    },
    MACES_4 = {
        nodeID = 99448,
        threshold = 20,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
            },
        },
    },
    AXES_AND_POLEARMS_1 = {
        nodeID = 99447,
        threshold = 0,
        equalsSkill = 1,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    AXES_AND_POLEARMS_2 = {
        nodeID = 99447,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    AXES_AND_POLEARMS_3 = {
        nodeID = 99447,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    AXES_AND_POLEARMS_4 = {
        nodeID = 99447,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },
    AXES_AND_POLEARMS_5 = {
        nodeID = 99447,
        threshold = 20,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.THE_WAR_WITHIN.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
            },
        },
    },

    -- ARMOR SMITHING
    ARMOR_SMITHING_1 = {
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 99239,

    },
    LARGE_PLATE_ARMOR_1 = {
        childNodeIDs = { "BREASTPLATES_1", "GREAVES_1", "SHIELDS_1" },
        nodeID = 99238,

    },
    BREASTPLATES_1 = {
        nodeID = 99237,

    },
    GREAVES_1 = {
        nodeID = 99236,

    },
    SHIELDS_1 = {
        nodeID = 99235,

    },
    SCULPTED_ARMOR_1 = {
        childNodeIDs = { "HELMS_1", "PAULDRONS_1", "SABATONS_1" },
        nodeID = 99234,

    },
    HELMS_1 = {
        nodeID = 99233,

    },
    PAULDRONS_1 = {
        nodeID = 99232,

    },
    SABATONS_1 = {
        nodeID = 99231,

    },
    FINE_ARMOR_1 = {
        childNodeIDs = { "BELTS_1", "VAMBRACES_1", "GAUNTLETS_1" },
        nodeID = 99230,

    },
    BELTS_1 = {
        nodeID = 99229,

    },
    VAMBRACES_1 = {
        nodeID = 99228,

    },
    GAUNTLETS_1 = {
        nodeID = 99227,

    },
}
