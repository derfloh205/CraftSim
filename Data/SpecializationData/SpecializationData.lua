---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SPECIALIZATION_DATA
CraftSim.SPECIALIZATION_DATA = CraftSim.SPECIALIZATION_DATA

---@class CraftSim.RawPerkData
---@field nodeID number
---@field maxRank number
---@field stats? table<string, number> statname -> amount

---@class CraftSim.RawNodeData
---@field recipeMapping table<RecipeID, number[]>
---@field nodeData table<number, CraftSim.RawPerkData>


local print = CraftSim.DEBUG:RegisterDebugID("Data.SpecializationData")

---@type table<CraftSim.EXPANSION_IDS, table<Enum.Profession, CraftSim.RawNodeData>>
CraftSim.SPECIALIZATION_DATA.NODE_DATA = {
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
        [Enum.Profession.Alchemy] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.ALCHEMY_DATA,
        [Enum.Profession.Leatherworking] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.LEATHERWORKING_DATA,
        [Enum.Profession.Jewelcrafting] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.JEWELCRAFTING_DATA,
        [Enum.Profession.Enchanting] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.ENCHANTING_DATA,
        [Enum.Profession.Tailoring] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.TAILORING_DATA,
        [Enum.Profession.Inscription] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.INSCRIPTION_DATA,
        [Enum.Profession.Engineering] = CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.ENGINEERING_DATA
    },
}

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
        [Enum.Profession.Alchemy] = { "ALCHEMICAL_MASTERY_1", "FANTASTIC_FLASKS_1", "POTENT_POTIONS_1", "THAUMATURGY_1" },
        [Enum.Profession.Enchanting] = { "SUPPLEMENTARY_SHATTERING_1", "DESIGNATED_DISENCHANTER_1", "EVERLASTING_ENCHANTMENTS_1", "EPHEMERALS_ENRICHMENTS_AND_EQUIPMENT_1" },
        [Enum.Profession.Engineering] = { "ENGINEERED_EQUIPMENT_1", "DEVICES_1", "INVENTING_1" },
        [Enum.Profession.Inscription] = { "PURSUIT_OF_KNOWLEDGE_1", "PURSUIT_OF_PERFECTION_1", "CAREFUL_CARVINGS_1", "ARCHIVAL_ADDITIONS_1" },
        [Enum.Profession.Leatherworking] = { "LEARNED_LEATHERWORKER_1", "LUXURIOUS_LEATHERS_1", "CONCRETE_CHITIN_1", "FLAWLESS_FORTRES_1" },
        [Enum.Profession.Tailoring] = { "THREADS_OF_DEVOTION_1", "FROM_DAWN_UNTIL_DUSK_1", "QUALITY_FABRIC_1", "TEXTILE_TREASURES_1" },
        [Enum.Profession.Jewelcrafting] = { "GEMCUTTING_1", "JEWELRY_CRAFTING_1", "SHAPING_1" },
    },
}

-- used for e.g. craft buffs to determine trait dependend stats
---@param recipeData CraftSim.RecipeData
---@param nodeID number
---@param expansionID CraftSim.EXPANSION_IDS
---@param professionID Enum.Profession
function CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, nodeID, expansionID, professionID)
    local RawNodeDataList = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID][professionID].nodeData
    local rawBaseNodeData = RawNodeDataList[nodeID]
    local perkMap = {}
    for perkID, rawPerkData in pairs(RawNodeDataList) do
        if rawPerkData.nodeID == nodeID and rawPerkData.maxRank == 1 then
            perkMap[perkID] = rawPerkData
        end
    end

    if recipeData:IsCrafter() then
        local nodeData = CraftSim.NodeData(recipeData, rawBaseNodeData, perkMap)
        nodeData:UpdateRank()
        nodeData:Update()

        return nodeData
    else
        local crafterUID = recipeData:GetCrafterUID()
        local cachedSpecData = CraftSim.DB.CRAFTER:GetSpecializationData(crafterUID, recipeData)

        if not cachedSpecData then return end

        local nodeData = GUTIL:Find(cachedSpecData.nodeData, function(nData)
            return nData.nodeID == nodeID
        end)

        return nodeData
    end
end

---@param recipeData CraftSim.RecipeData
---@param nodeID number
---@return boolean affected
function CraftSim.SPECIALIZATION_DATA:IsRecipeDataAffectedByNodeID(recipeData, nodeID)
    local recipePerks = self.NODE_DATA[recipeData.professionData.expansionID]
        [recipeData.professionData.professionInfo.profession].recipeMapping

    if not recipePerks then return false end

    return tContains(recipePerks[recipeData.recipeID] or {}, nodeID)
end
