CraftSimAddonName, CraftSim = ...

CraftSim.SPEC_DATA = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

-- its a function so craftsimConst can be accessed (otherwise nil cause not yet initialized)
CraftSim.SPEC_DATA.RULE_NODES = function() 
    return {
    [Enum.Profession.Blacksmithing] =  CraftSim.BLACKSMITHING_DATA:GetData(),
    [Enum.Profession.Alchemy] = CraftSim.ALCHEMY_DATA:GetData(),
    [Enum.Profession.Leatherworking] = CraftSim.LEATHERWORKING_DATA:GetData(),
    [Enum.Profession.Jewelcrafting] = CraftSim.JEWELCRAFTING_DATA:GetData(),
    [Enum.Profession.Enchanting] = CraftSim.ENCHANTING_DATA:GetData(),
    [Enum.Profession.Tailoring] = CraftSim.TAILORING_DATA:GetData(),
    [Enum.Profession.Inscription] = CraftSim.INSCRIPTION_DATA:GetData(),
    [Enum.Profession.Engineering] = CraftSim.ENGINEERING_DATA:GetData()
} end
CraftSim.SPEC_DATA.BASE_RULE_NODES = function() 
    return {
    [Enum.Profession.Blacksmithing] =  {"ARMOR_SMITHING_1", "WEAPON_SMITHING_1", "SPECIALITY_SMITHING_1", "HAMMER_CONTROL_1"},
    [Enum.Profession.Alchemy] = {"POTION_MASTERY_1", "PHIAL_MASTERY_1", "ALCHEMICAL_THEORY_1"},
    [Enum.Profession.Leatherworking] = {"LEATHERWORKING_DISCIPLINE_1", "LEATHER_ARMOR_CRAFTING_1", "MAIL_ARMOR_CRAFTING_1", "PRIMORDIAL_LEATHERWORKING_1"},
    [Enum.Profession.Jewelcrafting] = {"TOOLSET_MASTERY_1", "FACETING_1", "SETTING_1", "ENTERPRISING_1"},
    [Enum.Profession.Enchanting] = {"ENCHANTMENT_1", "INSIGHT_OF_THE_BLUE_1", "RODS_RUNES_AND_RUSES_1"},
    [Enum.Profession.Tailoring] = {"TAILORING_MASTERY_1", "TEXTILES_1", "DRACONIC_NEEDLEWORK_1", "GARMENTCRAFTING_1"},
    [Enum.Profession.Inscription] = {"RUNE_MASTERY_1", "ARCHIVING_1", "RUNEBINDING_1"},
    [Enum.Profession.Engineering] = {"OPTIMIZED_EFFICIENCY_1", "EXPLOSIVES_1", "FUNCTION_OVER_FORM_1", "MECHANICAL_MIND_1"},
} end

function CraftSim.SPEC_DATA:GetNodes(professionID)
    if professionID == Enum.Profession.Alchemy then
        return CraftSim.ALCHEMY_DATA.NODES()
    elseif professionID == Enum.Profession.Blacksmithing then
            return CraftSim.BLACKSMITHING_DATA.NODES()
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