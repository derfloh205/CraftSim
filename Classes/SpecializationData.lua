---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SpecializationData : CraftSim.CraftSimObject
---@overload fun(recipeData:CraftSim.RecipeData):CraftSim.SpecializationData
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
    ---@type CraftSim.NodeData[]
    self.baseNodeData = {}     -- needed for spec sim tree buildup
    ---@type number[][]
    self.numNodesPerLayer = {} -- needed for spec sim tree buildup

    self.isImplemented = CraftSim.UTIL:IsSpecImplemented(recipeData.professionData.professionInfo.profession)
    self.isGatheringProfession = CraftSim.CONST.GATHERING_PROFESSIONS
        [recipeData.professionData.professionInfo.profession]

    if recipeData.isOldWorldRecipe or not recipeData:IsCrafter() or self.isGatheringProfession then
        return
    end

    local nodeNameData = CraftSim.SPEC_DATA:GetNodes(recipeData.professionData.professionInfo.profession)
    local professionRuleNodes = CraftSim.SPEC_DATA:RULE_NODES()[recipeData.professionData.professionInfo.profession]
    local baseRuleNodes = CraftSim.SPEC_DATA:BASE_RULE_NODES()[recipeData.professionData.professionInfo.profession]

    local baseRuleNodeIDs = GUTIL:Map(baseRuleNodes, function(nameID)
        local ruleNode = professionRuleNodes[nameID]
        if ruleNode then
            return ruleNode.nodeID
        end
    end)

    baseRuleNodeIDs = GUTIL:ToSet(baseRuleNodeIDs)

    local baseNodeIndex = 1
    local function parseNode(nodeID, parentNodeData, layer)
        local ruleNodes = GUTIL:Filter(professionRuleNodes, function(n) return n.nodeID == nodeID end)
        local nodeName = CraftSim.LOCAL:GetText(nodeID);

        if not nodeName then
            nodeName = GUTIL:Find(nodeNameData,
                function(nodeNameEntry) return nodeNameEntry.nodeID == nodeID end).name
        end
        local nodeData = CraftSim.NodeData(self.recipeData, nodeName, ruleNodes, parentNodeData)

        --- DEBUG
        if nodeData.nodeName == "Curing and Tanning" then
            print("@node: " .. nodeData.nodeName)
        end

        nodeData:UpdateAffectance()
        nodeData:UpdateProfessionStats()

        self.professionStats:add(nodeData.professionStats)
        self.maxProfessionStats:add(nodeData.maxProfessionStats)

        table.insert(self.nodeData, nodeData)

        local childNodeNameIDs = ruleNodes[1].childNodeIDs

        for _, childNodeNameID in pairs(childNodeNameIDs or {}) do
            local childNodeID = professionRuleNodes[childNodeNameID].nodeID
            local childNodeData = parseNode(childNodeID, nodeData, layer + 1)
            table.insert(nodeData.childNodes, childNodeData)
        end

        self.numNodesPerLayer[baseNodeIndex] = (self.numNodesPerLayer[baseNodeIndex] or {})
        self.numNodesPerLayer[baseNodeIndex][layer] = (self.numNodesPerLayer[baseNodeIndex][layer] or 0) + 1

        return nodeData
    end

    for _, nodeID in pairs(baseRuleNodeIDs) do
        table.insert(self.baseNodeData, parseNode(nodeID, nil, 1))
        baseNodeIndex = baseNodeIndex + 1
    end
end

function CraftSim.SpecializationData:GetExtraFactors()
    local extraFactors = CraftSim.ProfessionStats()

    extraFactors.inspiration.extraFactor = self.professionStats.inspiration.extraFactor
    extraFactors.multicraft.extraFactor = self.professionStats.multicraft.extraFactor
    extraFactors.resourcefulness.extraFactor = self.professionStats.resourcefulness.extraFactor

    return extraFactors
end

function CraftSim.SpecializationData:UpdateProfessionStats()
    self.professionStats:Clear()
    for _, nodeData in pairs(self.nodeData) do
        nodeData:UpdateProfessionStats()
        self.professionStats:add(nodeData.professionStats)
    end
end

function CraftSim.SpecializationData:Debug()
    local debugLines = {}

    for _, nodeData in pairs(self.baseNodeData) do
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
    local layernumlist = {}
    table.foreach(self.numNodesPerLayer, function(index, value)
        local listString = "["
        table.foreach(value, function(index, v)
            if index < #value then
                listString = listString .. v .. ","
            else
                listString = listString .. v
            end
        end)

        listString = listString .. "]"
        layernumlist[index] = listString
    end)
    jb:AddList("numNodesPerLayer", layernumlist)
    jb:Add("professionStats", self.professionStats, true)
    jb:End()
    return jb.json
end

---@class CraftSim.SpecializationData.Serialized
---@field numNodesPerLayer table<number, number>[]
---@field nodeData CraftSim.NodeData.Serialized[]
---@field baseNodeIDs table<number, number> -- to restore baseNodeIDs via nodeIDmap

---@return CraftSim.SpecializationData.Serialized
function CraftSim.SpecializationData:Serialize()
    ---@type CraftSim.SpecializationData.Serialized
    local serializedData = {}
    serializedData.numNodesPerLayer = CopyTable(self.numNodesPerLayer)
    serializedData.nodeData = GUTIL:Map(self.nodeData, function(nodeData)
        return nodeData:Serialize()
    end)
    serializedData.baseNodeIDs = GUTIL:Map(self.baseNodeData, function(nodeData)
        return nodeData.nodeID
    end)

    return serializedData
end

---@param serializedData CraftSim.SpecializationData.Serialized
---@return CraftSim.SpecializationData
function CraftSim.SpecializationData:Deserialize(serializedData, recipeData)
    local specializationData = CraftSim.SpecializationData()
    self.isImplemented = CraftSim.UTIL:IsSpecImplemented(recipeData.professionData.professionInfo.profession)
    specializationData.numNodesPerLayer = serializedData.numNodesPerLayer
    specializationData.professionStats = CraftSim.ProfessionStats()
    specializationData.maxProfessionStats = CraftSim.ProfessionStats()

    local nodeIDMap = {} -- to restore references
    local professionRuleNodes = CraftSim.SPEC_DATA:RULE_NODES()[recipeData.professionData.professionInfo.profession]

    specializationData.nodeData = GUTIL:Map(serializedData.nodeData, function(nodeDataSerialized)
        return CraftSim.NodeData:Deserialize(nodeDataSerialized, recipeData, nodeIDMap, professionRuleNodes)
    end)

    specializationData.baseNodeData = GUTIL:Map(serializedData.baseNodeIDs, function(nodeID)
        return nodeIDMap[nodeID]
    end)

    specializationData:UpdateProfessionStats()

    return specializationData
end
