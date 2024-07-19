---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.JEWELCRAFTING_DATA = {
    GEM_CUTTING_1 = {
        childNodeIDs = { "EMERALD_1", "ONYX_1", "RUBY_1", "SAPPHIRE_1" },
        nodeID = 98614,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
}
