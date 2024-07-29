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

    },
    TOOLS_OF_THE_TRADE_1 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,

    },
    TRADE_TOOLS_1 = {
        nodeID = 99587,

    },
    TRADE_ACCESSORIES_1 = {
        nodeID = 99586,

    },
    STONEWORK_1 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,

    },
    WEAPON_STONES_1 = {
        nodeID = 99584,

    },
    TOOL_ENHANCEMENT_1 = {
        nodeID = 99583,

    },
    FORTUITOUS_FORGES_1 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,

    },
    FRAME_WORKS_1 = {
        nodeID = 99581,

    },
    ALLOYS_1 = {
        nodeID = 99580,

    },

    -- WEAPON SMITHING
    WEAPON_SMITHING_1 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,

    },
    BLADES_1 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,

    },
    SHORT_BLADES_1 = {
        nodeID = 99451,

    },
    LONG_BLADES_1 = {
        nodeID = 99450,

    },
    HAFTED_1 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,

    },
    MACES_1 = {
        nodeID = 99448,

    },
    AXES_AND_POLEARMS_1 = {
        nodeID = 99447,

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
