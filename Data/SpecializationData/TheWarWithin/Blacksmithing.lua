---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.BLACKSMITHING_DATA =
{
    -- EVER BURNING FORGE
    EVER_BURNING_FORGE_1 = {
        childNodeIDs = { "IMAGINATIVE_FORESIGHT_1", "DISCERNING_DISCIPLINE_1", "GRACIOUS_FORGING_1" },
        nodeID = 99267,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMAGINATIVE_FORESIGHT_1 = {
        nodeID = 99266,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DISCERNING_DISCIPLINE_1 = {
        nodeID = 99265,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GRACIOUS_FORGING_1 = {
        nodeID = 99264,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    -- MEANS OF PRODUCTION
    MEANS_OF_PRODUCTION_1 = {
        childNodeIDs = { "TOOLS_OF_THE_TRADE_1", "STONEWORK_1", "FORTUITOUS_FORGES_1" },
        nodeID = 99589,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    TOOLS_OF_THE_TRADE_1 = {
        childNodeIDs = { "TRADE_TOOLS_1", "TRADE_ACCESSORIES_1" },
        nodeID = 99588,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    TRADE_TOOLS_1 = {
        nodeID = 99587,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    TRADE_ACCESSORIES_1 = {
        nodeID = 99586,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    STONEWORK_1 = {
        childNodeIDs = { "WEAPON_STONES_1", "TOOL_ENHANCEMENT_1" },
        nodeID = 99585,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    WEAPON_STONES_1 = {
        nodeID = 99584,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    TOOL_ENHANCEMENT_1 = {
        nodeID = 99583,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    FORTUITOUS_FORGES_1 = {
        childNodeIDs = { "FRAME_WORKS_1", "ALLOYS_1" },
        nodeID = 99582,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    FRAME_WORKS_1 = {
        nodeID = 99581,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    ALLOYS_1 = {
        nodeID = 99580,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    -- WEAPON SMITHING
    WEAPON_SMITHING_1 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 99453,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    BLADES_1 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 99452,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SHORT_BLADES_1 = {
        nodeID = 99451,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    LONG_BLADES_1 = {
        nodeID = 99450,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HAFTED_1 = {
        childNodeIDs = { "MACES_1", "AXES_AND_POLEARMS_1" },
        nodeID = 99449,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    MACES_1 = {
        nodeID = 99448,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    AXES_AND_POLEARMS_1 = {
        nodeID = 99447,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    -- ARMOR SMITHING
    ARMOR_SMITHING_1 = {
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 99239,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    LARGE_PLATE_ARMOR_1 = {
        childNodeIDs = { "BREASTPLATES_1", "GREAVES_1", "SHIELDS_1" },
        nodeID = 99238,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    BREASTPLATES_1 = {
        nodeID = 99237,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GREAVES_1 = {
        nodeID = 99236,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SHIELDS_1 = {
        nodeID = 99235,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SCULPTED_ARMOR_1 = {
        childNodeIDs = { "HELMS_1", "PAULDRONS_1", "SABATONS_1" },
        nodeID = 99234,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HELMS_1 = {
        nodeID = 99233,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    PAULDRONS_1 = {
        nodeID = 99232,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SABATONS_1 = {
        nodeID = 99231,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    FINE_ARMOR_1 = {
        childNodeIDs = { "BELTS_1", "VAMBRACES_1", "GAUNTLETS_1" },
        nodeID = 99230,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    BELTS_1 = {
        nodeID = 99229,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    VAMBRACES_1 = {
        nodeID = 99228,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GAUNTLETS_1 = {
        nodeID = 99227,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
}
