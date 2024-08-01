---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.ENCHANTING_DATA = {
    SUPPLEMENTARY_SHATTERING_1 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 0,
        equalsIngenuity = 3,
        equalsIngenuityExtraConcentrationFactor = 0.02,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SUPPLEMENTARY_SHATTERING_2 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 10,
        equalsIngenuityExtraConcentrationFactor = 0.03,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SUPPLEMENTARY_SHATTERING_3 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 20,
        equalsIngenuityExtraConcentrationFactor = 0.05,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SUPPLEMENTARY_SHATTERING_4 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 0,
        multicraft = 15,
        resourcefulness = 15,
        ingenuity = 15,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE },
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SUPPLEMENTARY_SHATTERING_5 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 5,
        multicraft = 15,
        resourcefulness = 15,
        ingenuity = 15,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE },
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SUPPLEMENTARY_SHATTERING_6 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 25,
        multicraft = 15,
        resourcefulness = 15,
        ingenuity = 15,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE },
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SUPPLEMENTARY_SHATTERING_7 = {
        childNodeIDs = { "RESOURCEFUL_RESIDUE_1", "IMMACULATE_INGENUITY_1", "MAGNIFICENT_MULTICRAFTING_1" },
        nodeID = 100040,
        threshold = 30,
        multicraft = 30,
        resourcefulness = 30,
        ingenuity = 30,
        activationBuffIDs = { CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE },
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    RESOURCEFUL_RESIDUE_1 = {
        nodeID = 100039,
    },
    IMMACULATE_INGENUITY_1 = {
        nodeID = 100038,
    },
    MAGNIFICENT_MULTICRAFTING_1 = {
        nodeID = 100037,
    },

    DESIGNATED_DISENCHANTER_1 = {
        childNodeIDs = { "UNCOMMON_UTILITARIAN_1", "RARE_RESOURCING_1", "EPIC_ESCALATIONS_1" },
        nodeID = 99890,
    },
    UNCOMMON_UTILITARIAN_1 = {
        nodeID = 99889,
    },
    RARE_RESOURCING_1 = {
        nodeID = 99888,
    },
    EPIC_ESCALATIONS_1 = {
        nodeID = 99887,
    },

    EVERLASTING_ENCHANTMENTS_1 = {
        childNodeIDs = { "EARTHEN_ENHANCEMENTS_1", "ARATHOR_ALTERATIONS_1", "NERUBIEN_NOVELTIES_1" },
        nodeID = 100008,
    },
    EARTHEN_ENHANCEMENTS_1 = {
        childNodeIDs = { "WONDROUS_WEAPONS_1", "TERRIFIC_TOOLS_1", "BOLSTERED_BREASTPLATES_1" },
        nodeID = 100007,
    },
    WONDROUS_WEAPONS_1 = {
        nodeID = 100006,
    },
    TERRIFIC_TOOLS_1 = {
        nodeID = 100005,
    },
    BOLSTERED_BREASTPLATES_1 = {
        nodeID = 100004,
    },
    ARATHOR_ALTERATIONS_1 = {
        childNodeIDs = { "FORTIFIED_FLAMES_1", "ACCENTUATED_ACCESSORIES_1" },
        nodeID = 100003,
    },
    FORTIFIED_FLAMES_1 = {
        nodeID = 100002,
    },
    ACCENTUATED_ACCESSORIES_1 = {
        nodeID = 100001,
    },
    NERUBIEN_NOVELTIES_1 = {
        childNodeIDs = { "CURSED_CHANTS_1", "TERTIARY_TRIVIALITIES_1" },
        nodeID = 100000,
    },
    CURSED_CHANTS_1 = {
        nodeID = 99999,
    },
    TERTIARY_TRIVIALITIES_1 = {
        nodeID = 99998,
    },

    EPHEMERALS_ENRICHMENTS_AND_EQUIPMENT_1 = {
        childNodeIDs = { "DECEPTIVE_DECORATIONS_1", "EXQUISITE_EQUIPMENT_1", "MATERIAL_MAESTRO_1" },
        nodeID = 99940,
    },
    DECEPTIVE_DECORATIONS_1 = {
        nodeID = 99939,
    },
    EXQUISITE_EQUIPMENT_1 = {
        childNodeIDs = { "PROFESSIONAL_PRODUCTION_1", "COMBAT_CRAFTS_1" },
        nodeID = 99938,
    },
    PROFESSIONAL_PRODUCTION_1 = {
        nodeID = 99937,
    },
    COMBAT_CRAFTS_1 = {
        nodeID = 99936,
    },
    MATERIAL_MAESTRO_1 = {
        childNodeIDs = { "FINALIZED_FINISHERS_1", "OPTIMAL_OILS_1" },
        nodeID = 99935,
    },
    FINALIZED_FINISHERS_1 = {
        nodeID = 99934,
    },
    OPTIMAL_OILS_1 = {
        nodeID = 99933,
    },
}
