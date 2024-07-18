---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.SPECIALIZATION_DATA
CraftSim.SPECIALIZATION_DATA = {}

---@class CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER
---@field GetData fun(): CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER.DATA
---@field NODE_IDS table<string, number>
---@field NODES CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER.NODES

---@class CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER.DATA

---@class CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER.NODES


---@type CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER[]
CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT = {}
---@type CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER[]
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN = {}
local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

-- its a function so craftsimConst can be accessed (otherwise nil cause not yet initialized)
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@return CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER.DATA
function CraftSim.SPECIALIZATION_DATA:GetData(profession, expansionID)
    ---@type table<CraftSim.EXPANSION_IDS, table<Enum.Profession, CraftSim.SPECIALIZATION_DATA.DATA_PROVIDER>>
    local dataProviderMap = {
        [CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT] = {
            [Enum.Profession.Blacksmithing] = CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.BLACKSMITHING_DATA,
            [Enum.Profession.Alchemy] = CraftSim.ALCHEMY_DATA,
            [Enum.Profession.Leatherworking] = CraftSim.LEATHERWORKING_DATA,
            [Enum.Profession.Jewelcrafting] = CraftSim.JEWELCRAFTING_DATA,
            [Enum.Profession.Enchanting] = CraftSim.ENCHANTING_DATA,
            [Enum.Profession.Tailoring] = CraftSim.TAILORING_DATA,
            [Enum.Profession.Inscription] = CraftSim.INSCRIPTION_DATA,
            [Enum.Profession.Engineering] = CraftSim.ENGINEERING_DATA
        },
        [CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN] = {
            [Enum.Profession.Blacksmithing] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.BLACKSMITHING_DATA,
            [Enum.Profession.Alchemy] = CraftSim.ALCHEMY_DATA,
            [Enum.Profession.Leatherworking] = CraftSim.LEATHERWORKING_DATA,
            [Enum.Profession.Jewelcrafting] = CraftSim.JEWELCRAFTING_DATA,
            [Enum.Profession.Enchanting] = CraftSim.ENCHANTING_DATA,
            [Enum.Profession.Tailoring] = CraftSim.TAILORING_DATA,
            [Enum.Profession.Inscription] = CraftSim.INSCRIPTION_DATA,
            [Enum.Profession.Engineering] = CraftSim.ENGINEERING_DATA
        },
    }
    local dataProvider = dataProviderMap[expansionID][profession]
    return dataProvider:GetData()
end

---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@return string[]
function CraftSim.SPECIALIZATION_DATA:GetBaseRuleNodes(profession, expansionID)
    local map = {
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
            [Enum.Profession.Blacksmithing] = { "ARMOR_SMITHING_1", "WEAPON_SMITHING_1", "SPECIALITY_SMITHING_1", "HAMMER_CONTROL_1" },
            [Enum.Profession.Alchemy] = { "POTION_MASTERY_1", "PHIAL_MASTERY_1", "ALCHEMICAL_THEORY_1" },
            [Enum.Profession.Leatherworking] = { "LEATHERWORKING_DISCIPLINE_1", "LEATHER_ARMOR_CRAFTING_1", "MAIL_ARMOR_CRAFTING_1", "PRIMORDIAL_LEATHERWORKING_1" },
            [Enum.Profession.Jewelcrafting] = { "TOOLSET_MASTERY_1", "FACETING_1", "SETTING_1", "ENTERPRISING_1" },
            [Enum.Profession.Enchanting] = { "ENCHANTMENT_1", "INSIGHT_OF_THE_BLUE_1", "RODS_RUNES_AND_RUSES_1" },
            [Enum.Profession.Tailoring] = { "TAILORING_MASTERY_1", "TEXTILES_1", "DRACONIC_NEEDLEWORK_1", "GARMENTCRAFTING_1" },
            [Enum.Profession.Inscription] = { "RUNE_MASTERY_1", "ARCHIVING_1", "RUNEBINDING_1" },
            [Enum.Profession.Engineering] = { "OPTIMIZED_EFFICIENCY_1", "EXPLOSIVES_1", "FUNCTION_OVER_FORM_1", "MECHANICAL_MIND_1" },
        },
    }
    return map[expansionID][profession]
end

function CraftSim.SPECIALIZATION_DATA:GetNodes(professionID)
    if professionID == Enum.Profession.Alchemy then
        return CraftSim.ALCHEMY_DATA.NODES()
    elseif professionID == Enum.Profession.Blacksmithing then
        return CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.BLACKSMITHING_DATA.NODES()
    elseif professionID == Enum.Profession.Enchanting then
        return CraftSim.ENCHANTING_DATA.NODES()
    elseif professionID == Enum.Profession.Inscription then
        return CraftSim.INSCRIPTION_DATA.NODES()
    elseif professionID == Enum.Profession.Jewelcrafting then
        return CraftSim.JEWELCRAFTING_DATA.NODES()
    elseif professionID == Enum.Profession.Leatherworking then
        return CraftSim.LEATHERWORKING_DATA.NODES()
    elseif professionID == Enum.Profession.Tailoring then
        return CraftSim.TAILORING_DATA.NODES()
    elseif professionID == Enum.Profession.Engineering then
        return CraftSim.ENGINEERING_DATA.NODES()
    elseif professionID == Enum.Profession.Cooking then
        return {}
    else
        print("CraftSim SpecData: No nodes found for profession id: " .. tostring(professionID))
        return {}
    end
end
