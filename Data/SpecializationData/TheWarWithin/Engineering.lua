---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.ENGINEERING_DATA = {
    ENGINEERED_EQUIPMENT_1 = {
        childNodeIDs = { "CALIBRATED_CHAOS_1", "INVENTORS_NECESSITIES_1" },
        nodeID = 100765,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    CALIBRATED_CHAOS_1 = {
        childNodeIDs = { "GUNS_1", "BRACERS_1" },
        nodeID = 100764,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GUNS_1 = {
        nodeID = 100763,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    BRACERS_1 = {
        nodeID = 100762,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    INVENTORS_NECESSITIES_1 = {
        childNodeIDs = { "PROFESSION_GEAR_1", "GOGGLES_1" },
        nodeID = 100761,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    PROFESSION_GEAR_1 = {
        nodeID = 100760,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    GOGGLES_1 = {
        nodeID = 100759,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    DEVICES_1 = {
        childNodeIDs = { "EXPLOSIVES_1", "TINKERS_1" },
        nodeID = 100791,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    EXPLOSIVES_1 = {
        nodeID = 100790,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    TINKERS_1 = {
        nodeID = 100789,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },

    INVENTING_1 = {
        childNodeIDs = { "INGENIOUS_1", "PARTS_1", "SCRAPPER_1" },
        nodeID = 100843,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    INGENIOUS_1 = {
        nodeID = 100842,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    PARTS_1 = {
        childNodeIDs = { "OVERCLOCKED_COGWHEEL_1", "SERRATED_COGWHEEL_1", "ADJUSTABLE_COGWHEEL_1", "IMPECCABLE_COGWHEEL_1" },
        nodeID = 100841,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    OVERCLOCKED_COGWHEEL_1 = {
        nodeID = 100840,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SERRATED_COGWHEEL_1 = {
        nodeID = 100839,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    ADJUSTABLE_COGWHEEL_1 = {
        nodeID = 100838,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    IMPECCABLE_COGWHEEL_1 = {
        nodeID = 100837,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SCRAPPER_1 = {
        nodeID = 100836,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
}
