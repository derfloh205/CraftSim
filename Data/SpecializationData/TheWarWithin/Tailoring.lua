---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.TAILORING_DATA = {
    THREADS_OF_DEVOTION_1 = {
        childNodeIDs = { "WEATHERING_WEAR_1", "WEIGHTED_GARMENTS_1", "MAKING_A_STATEMENT_1" },
        nodeID = 101801,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    WEATHERING_WEAR_1 = {
        childNodeIDs = { "GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1" },
        nodeID = 101800,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GLOVES_1 = {
        nodeID = 101799,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    FOOTWEAR_1 = {
        nodeID = 101798,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HATS_1 = {
        nodeID = 101797,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    CLOAKS_1 = {
        nodeID = 101796,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    WEIGHTED_GARMENTS_1 = {
        childNodeIDs = { "ROBES_1", "LEGGINGS_1" },
        nodeID = 101795,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    ROBES_1 = {
        nodeID = 101794,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    LEGGINGS_1 = {
        nodeID = 101793,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    MAKING_A_STATEMENT_1 = {
        childNodeIDs = { "MANTLES_1", "ARMBANDS_1", "BELTS_1" },
        nodeID = 101792,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    MANTLES_1 = {
        nodeID = 101791,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    ARMBANDS_1 = {
        nodeID = 101790,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    BELTS_1 = {
        nodeID = 101789,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    FROM_DAWN_UNTIL_DUSK_1 = {
        childNodeIDs = { "DAWNWEAVE_TAILORING_1", "DUSKWEAVE_TAILORING_1" },
        nodeID = 100306,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DAWNWEAVE_TAILORING_1 = {
        childNodeIDs = { "DAWNWEAVING_1" },
        nodeID = 100305,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DAWNWEAVING_1 = {
        nodeID = 100304,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DUSKWEAVE_TAILORING_1 = {
        childNodeIDs = { "DUSKWEAVING_1" },
        nodeID = 100303,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    DUSKWEAVING_1 = {
        nodeID = 100302,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    QUALITY_FABRIC_1 = {
        childNodeIDs = { "ADDITIONAL_EMBROIDERY_1", "SPELLTHREAD_1", "WEAVING_AND_UNRAVELING_1" },
        nodeID = 100907,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    ADDITIONAL_EMBROIDERY_1 = {
        nodeID = 100906,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SPELLTHREAD_1 = {
        nodeID = 100905,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    WEAVING_AND_UNRAVELING_1 = {
        nodeID = 100904,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    TEXTILE_TREASURES_1 = {
        childNodeIDs = { "THE_PERFECT_LOOP_1", "EXTRA_THREADS_1", "LESS_IS_MORE_1" },
        nodeID = 100939,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    THE_PERFECT_LOOP_1 = {
        nodeID = 100938,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EXTRA_THREADS_1 = {
        nodeID = 100937,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    LESS_IS_MORE_1 = {
        nodeID = 100936,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
}
