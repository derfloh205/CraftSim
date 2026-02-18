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
    [CraftSim.CONST.EXPANSION_IDS.MIDNIGHT] = {
        [Enum.Profession.Blacksmithing] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.BLACKSMITHING_DATA,
        [Enum.Profession.Alchemy] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.ALCHEMY_DATA,
        [Enum.Profession.Leatherworking] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.LEATHERWORKING_DATA,
        [Enum.Profession.Jewelcrafting] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.JEWELCRAFTING_DATA,
        [Enum.Profession.Enchanting] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.ENCHANTING_DATA,
        [Enum.Profession.Tailoring] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.TAILORING_DATA,
        [Enum.Profession.Inscription] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.INSCRIPTION_DATA,
        [Enum.Profession.Engineering] = CraftSim.SPECIALIZATION_DATA.MIDNIGHT.ENGINEERING_DATA
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
