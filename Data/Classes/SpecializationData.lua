_, CraftSim = ...

---@class CraftSim.SpecializationData
---@field recipeData CraftSim.RecipeData
---@field isImplemented boolean
---@field nodeData CraftSim.NodeData[]
---@field baseNodeData CraftSim.NodeData[]
---@field numNodesPerLayer number[][]
---@field professionStats CraftSim.ProfessionStats

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA_OOP)

CraftSim.SpecializationData = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.SpecializationData:new(recipeData)
    if not recipeData then
        return
    end
    self.recipeData = recipeData
    self.professionStats = CraftSim.ProfessionStats()
    self.baseNodeData = {}
    self.nodeData = {}
    self.numNodesPerLayer = {}

    self.isImplemented = CraftSim.UTIL:IsSpecImplemented(recipeData.professionData.professionInfo.profession)

    if not self.isImplemented then
        return
    end

    local nodeNameData = CraftSim.SPEC_DATA:GetNodes(recipeData.professionData.professionInfo.profession)
    local professionRuleNodes = CraftSim.SPEC_DATA:RULE_NODES()[recipeData.professionData.professionInfo.profession]
    local baseRuleNodes = CraftSim.SPEC_DATA:BASE_RULE_NODES()[recipeData.professionData.professionInfo.profession]


    local baseRuleNodeIDs = CraftSim.UTIL:Map(baseRuleNodes, function (nameID)
        local ruleNode = professionRuleNodes[nameID]
        if ruleNode then
            return ruleNode.nodeID
        end
    end)

    baseRuleNodeIDs = CraftSim.UTIL:ToSet(baseRuleNodeIDs)

    -- Should contain the ids of the base nodes now
    -- parse data into objects recursively

    local baseNodeIndex = 1
    local function parseNode(nodeID, parentNodeData, layer)
        local ruleNodes = CraftSim.UTIL:FilterTable(professionRuleNodes, function (n) return n.nodeID == nodeID end)
        local nodeData = CraftSim.NodeData(self.recipeData, ruleNodes, parentNodeData)
        nodeData.nodeName = CraftSim.UTIL:Find(nodeNameData, function (nodeNameEntry) return nodeNameEntry.nodeID == nodeID end).name
        local childNodeNameIDs = ruleNodes[1].childNodeIDs

        for _, childNodeNameID in pairs(childNodeNameIDs or {}) do
            local childNodeID = professionRuleNodes[childNodeNameID].nodeID
            local childNodeData = parseNode(childNodeID, nodeData, layer + 1)
            table.insert(nodeData.childNodes, childNodeData)
            nodeData.idMapping:Merge(childNodeData.idMapping)
        end

        nodeData:UpdateAffectance()
        nodeData:UpdateProfessionStats()

        self.professionStats:add(nodeData.professionStats)

        self.numNodesPerLayer[baseNodeIndex] = (self.numNodesPerLayer[baseNodeIndex] or {})
        self.numNodesPerLayer[baseNodeIndex][layer] = (self.numNodesPerLayer[baseNodeIndex][layer] or 0) + 1

        table.insert(self.nodeData, nodeData)

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
        lines = CraftSim.UTIL:Map(lines, function (line)
            return "-" .. line
        end)

        debugLines = CraftSim.UTIL:Concat({debugLines, lines})
    end

    table.insert(debugLines, "Stats from Specializations:")

    local lines = self.professionStats:Debug()
    lines = CraftSim.UTIL:Map(lines, function(line) return "-" .. line end)

    debugLines = CraftSim.UTIL:Concat({debugLines, lines})

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