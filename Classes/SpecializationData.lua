---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.SpecializationData")

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SpecializationData : CraftSim.CraftSimObject
---@overload fun(recipeData:CraftSim.RecipeData?):CraftSim.SpecializationData
CraftSim.SpecializationData = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.SpecializationData:new(recipeData)
    if not recipeData then
        return
    end
    self.recipeData = recipeData
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.maxProfessionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.NodeData[]
    self.nodeData = {}

    self.isGatheringProfession = CraftSim.CONST.GATHERING_PROFESSIONS
        [recipeData.professionData.professionInfo.profession]

    if recipeData.isOldWorldRecipe or not recipeData:IsCrafter() or self.isGatheringProfession then
        return
    end
    self.isImplemented = recipeData:IsSpecializationInfoImplemented()

    local profession = recipeData.professionData.professionInfo.profession
    local expansionID = recipeData.professionData.expansionID

    local professionSpecData = CraftSim.SPECIALIZATION_DATA.NODE_DATA[expansionID][profession]
    local recipeMapping = professionSpecData.recipeMapping

    local recipePerks = recipeMapping[recipeData.recipeID]

    local professionNodeData = professionSpecData.nodeData

    local nodePerkMap = {}

    for _, perkID in ipairs(recipePerks or {}) do
        local perkData = professionNodeData[perkID]
        local baseNodeID = perkData.nodeID
        -- perks have max rank 1, base nodes have max rank > 1
        if perkData.maxRank == 1 then
            nodePerkMap[baseNodeID] = nodePerkMap[baseNodeID] or {}
            tinsert(nodePerkMap[baseNodeID], perkID)
        end
    end

    for nodeID, perks in pairs(nodePerkMap or {}) do
        local baseNodeData = professionNodeData[nodeID]
        local perkMap = {}
        for _, perkID in ipairs(perks) do
            perkMap[perkID] = professionNodeData[perkID]
            if not perkMap[perkID] then
                error("CraftSim Error: No Data mapped for perk: " .. tostring(perkID))
            end
        end
        if not baseNodeData then
            -- if not mapped then get the basic info for that node via api
            local nodeInfo = C_Traits.GetNodeInfo(recipeData.professionData.configID, nodeID)
            baseNodeData = {
                nodeID = nodeID,
                maxRank = nodeInfo.maxRanks - 1
            }
        end

        tinsert(self.nodeData, CraftSim.NodeData(recipeData, baseNodeData, perkMap))
    end

    self:UpdateRanks()
    self:UpdateProfessionStats()
end

function CraftSim.SpecializationData:GetExtraValues()
    local extraValues = CraftSim.ProfessionStats()

    extraValues.multicraft.extraValues = CopyTable(self.professionStats.multicraft.extraValues)
    extraValues.resourcefulness.extraValues = CopyTable(self.professionStats.resourcefulness.extraValues)
    extraValues.ingenuity.extraValues = CopyTable(self.professionStats.ingenuity.extraValues)
    extraValues.craftingspeed.extraValues = CopyTable(self.professionStats.craftingspeed.extraValues)

    return extraValues
end

function CraftSim.SpecializationData:UpdateRanks()
    for _, nodeData in pairs(self.nodeData) do
        nodeData:UpdateRank()
    end
end

function CraftSim.SpecializationData:UpdateProfessionStats()
    self.professionStats:Clear()
    self.maxProfessionStats:Clear()
    for _, nodeData in pairs(self.nodeData) do
        nodeData:Update()
        if nodeData.active then
            self.professionStats:add(nodeData.professionStats)
        end
        self.maxProfessionStats:add(nodeData.maxProfessionStats)
    end
end

function CraftSim.SpecializationData:Debug()
    local debugLines = {}

    for _, nodeData in pairs(self.nodeData) do
        local lines = nodeData:Debug()
        lines = GUTIL:Map(lines, function(line)
            return "-" .. line
        end)

        debugLines = GUTIL:Concat({ debugLines, lines })
    end

    table.insert(debugLines, "Stats from Specializations:")

    local lines = self.professionStats:Debug()
    lines = GUTIL:Map(lines, function(line) return "-" .. line end)

    debugLines = GUTIL:Concat({ debugLines, lines })

    return debugLines
end

---@return CraftSim.SpecializationData
function CraftSim.SpecializationData:Copy()
    -- create a new based on same recipeData, then adapt nodeRanks
    local copy = CraftSim.SpecializationData(self.recipeData)

    copy.professionStats:Clear()

    for nodeIndex, nodeDataB in pairs(self.nodeData) do
        local nodeDataA = copy.nodeData[nodeIndex]
        nodeDataA.rank = nodeDataB.rank
        nodeDataA.active = nodeDataB.active
        nodeDataA:UpdateProfessionStats()
        copy.professionStats:add(nodeDataA.professionStats)
    end

    return copy
end

function CraftSim.SpecializationData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("isImplemented", self.isImplemented)
    jb:AddList("nodeData", self.nodeData)
    jb:Add("professionStats", self.professionStats, true)
    jb:End()
    return jb.json
end

---@class CraftSim.SpecializationData.Serialized
---@field nodeData CraftSim.NodeData.Serialized[]
---@field professionStats CraftSim.ProfessionStats.Serialized
---@field maxProfessionStats CraftSim.ProfessionStats.Serialized

---@return CraftSim.SpecializationData.Serialized
function CraftSim.SpecializationData:Serialize()
    ---@type CraftSim.SpecializationData.Serialized
    local serializedData = {
        nodeData = GUTIL:Map(self.nodeData, function(nodeData)
            return nodeData:Serialize()
        end),
        professionStats = self.professionStats:Serialize(),
        maxProfessionStats = self.maxProfessionStats:Serialize(),
    }
    return serializedData
end

---@param serializedData CraftSim.SpecializationData.Serialized
---@return CraftSim.SpecializationData
function CraftSim.SpecializationData:Deserialize(serializedData, recipeData)
    local specializationData = CraftSim.SpecializationData()
    self.isImplemented = recipeData:IsSpecializationInfoImplemented()
    specializationData.professionStats = CraftSim.ProfessionStats:Deserialize(serializedData.professionStats)
    specializationData.maxProfessionStats = CraftSim.ProfessionStats:Deserialize(serializedData.maxProfessionStats)

    specializationData.nodeData = GUTIL:Map(serializedData.nodeData, function(nodeDataSerialized)
        return CraftSim.NodeData:Deserialize(nodeDataSerialized, recipeData)
    end)

    return specializationData
end
