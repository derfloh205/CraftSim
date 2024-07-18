---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.SPECIALIZATION_DATA
CraftSim.SPECIALIZATION_DATA = {}
CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT = {}
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN = {}

---@class CraftSim.SPECIALIZATION_DATA.RULE_DATA
---@field nodeID number


local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@return table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
function CraftSim.SPECIALIZATION_DATA:GetNodeData(profession, expansionID)
    ---@type table<CraftSim.EXPANSION_IDS, table<Enum.Profession, table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>>>
    local nodeDataMap = {
        [CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT] = {
            [Enum.Profession.Blacksmithing] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.BLACKSMITHING_DATA,
            [Enum.Profession.Alchemy] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.ALCHEMY_DATA,
            [Enum.Profession.Leatherworking] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.LEATHERWORKING_DATA,
            [Enum.Profession.Jewelcrafting] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.JEWELCRAFTING_DATA,
            [Enum.Profession.Enchanting] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.ENCHANTING_DATA,
            [Enum.Profession.Tailoring] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.TAILORING_DATA,
            [Enum.Profession.Inscription] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.INSCRIPTION_DATA,
            [Enum.Profession.Engineering] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.ENGINEERING_DATA
        },
        [CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN] = {
            [Enum.Profession.Blacksmithing] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.BLACKSMITHING_DATA,
            [Enum.Profession.Alchemy] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.ALCHEMY_DATA,
            [Enum.Profession.Leatherworking] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.LEATHERWORKING_DATA,
            [Enum.Profession.Jewelcrafting] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.JEWELCRAFTING_DATA,
            [Enum.Profession.Enchanting] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.ENCHANTING_DATA,
            [Enum.Profession.Tailoring] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.TAILORING_DATA,
            [Enum.Profession.Inscription] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.INSCRIPTION_DATA,
            [Enum.Profession.Engineering] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.ENGINEERING_DATA
        },
    }
    return nodeDataMap[expansionID][profession]
end

---@type table<CraftSim.EXPANSION_IDS, table<Enum.Profession, string[]>>
CraftSim.SPECIALIZATION_DATA.BASE_NODES = {
    [CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT] = {
        [Enum.Profession.Blacksmithing] = { "ARMOR_SMITHING_1", "WEAPON_SMITHING_1", "SPECIALITY_SMITHING_1", "HAMMER_CONTROL_1" },
        [Enum.Profession.Alchemy] = { "POTION_MASTERY_1", "PHIAL_MASTERY_1", "ALCHEMICAL_THEORY_1" },
        [Enum.Profession.Leatherworking] = { "LEATHERWORKING_DISCIPLINE_1", "LEATHER_ARMOR_CRAFTING_1", "MAIL_ARMOR_CRAFTING_1", "PRIMORDIAL_LEATHERWORKING_1" },
        [Enum.Profession.Jewelcrafting] = { "TOOLSET_MASTERY_1", "FACETING_1", "SETTING_1", "ENTERPRISING_1" },
        [Enum.Profession.Enchanting] = { "ENCHANTMENT_1", "INSIGHT_OF_THE_BLUE_1", "RODS_RUNES_AND_RUSES_1" },
        [Enum.Profession.Tailoring] = { "TAILORING_MASTERY_1", "TEXTILES_1", "DRACONIC_NEEDLEWORK_1", "GARMENTCRAFTING_1" },
        [Enum.Profession.Inscription] = { "RUNE_MASTERY_1", "ARCHIVING_1", "RUNEBINDING_1" },
        [Enum.Profession.Engineering] = { "OPTIMIZED_EFFICIENCY_1", "EXPLOSIVES_1", "FUNCTION_OVER_FORM_1", "MECHANICAL_MIND_1" },
    },
    [CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN] = {
        [Enum.Profession.Blacksmithing] = { "EVER_BURNING_FORGE_1", "MEANS_OF_PRODUCTION_1", "WEAPON_SMITHING_1", "ARMOR_SMITHING_1" },
        -- TODO
        [Enum.Profession.Alchemy] = { "POTION_MASTERY_1", "PHIAL_MASTERY_1", "ALCHEMICAL_THEORY_1" },
        [Enum.Profession.Leatherworking] = { "LEATHERWORKING_DISCIPLINE_1", "LEATHER_ARMOR_CRAFTING_1", "MAIL_ARMOR_CRAFTING_1", "PRIMORDIAL_LEATHERWORKING_1" },
        [Enum.Profession.Jewelcrafting] = { "TOOLSET_MASTERY_1", "FACETING_1", "SETTING_1", "ENTERPRISING_1" },
        [Enum.Profession.Enchanting] = { "ENCHANTMENT_1", "INSIGHT_OF_THE_BLUE_1", "RODS_RUNES_AND_RUSES_1" },
        [Enum.Profession.Tailoring] = { "TAILORING_MASTERY_1", "TEXTILES_1", "DRACONIC_NEEDLEWORK_1", "GARMENTCRAFTING_1" },
        [Enum.Profession.Inscription] = { "RUNE_MASTERY_1", "ARCHIVING_1", "RUNEBINDING_1" },
        [Enum.Profession.Engineering] = { "OPTIMIZED_EFFICIENCY_1", "EXPLOSIVES_1", "FUNCTION_OVER_FORM_1", "MECHANICAL_MIND_1" },
    },
}
