_, CraftSim = ...

---@class CraftSim.SpecializationData
---@field recipeData CraftSim.RecipeData
---@field nodeData CraftSim.NodeData[]
---@field baseNodeData CraftSim.NodeData[]
---@field professionStats CraftSim.ProfessionStats

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA_OOP)

CraftSim.SpecializationData = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.SpecializationData:new(recipeData)
    self.recipeData = recipeData
    self.professionStats = CraftSim.ProfessionStats()
    self.baseNodeData = {}
    self.nodeData = {}

    local professionRuleNodes = CraftSim.SPEC_DATA:RULE_NODES()[recipeData.professionData.professionInfo.profession]
    local baseRuleNodes = CraftSim.SPEC_DATA:BASE_RULE_NODES()[recipeData.professionData.professionInfo.profession]

    local baseRuleNodeIDs = CraftSim.UTIL:Map(baseRuleNodes, function (nameID)
        return professionRuleNodes[nameID].nodeID
    end)

    baseRuleNodeIDs = CraftSim.UTIL:ToSet(baseRuleNodeIDs)

    -- Should contain the ids of the base nodes now
    -- parse data into objects recursively

    local function parseNode(nodeID, parentNodeData)
        local ruleNodes = CraftSim.UTIL:FilterTable(professionRuleNodes, function (n) return n.nodeID == nodeID end)
        local _, nodeNameID = CraftSim.UTIL:Find(professionRuleNodes, function(n) return n.nodeID == nodeID end)
        local nodeName = string.sub(nodeNameID, 1, string.find(nodeNameID, "_(%d+)") - 1)
        local nodeData = CraftSim.NodeData(self.recipeData, ruleNodes, parentNodeData)
        nodeData.nodeName = nodeName
        local childNodeNameIDs = ruleNodes[1].childNodeIDs

        for _, childNodeNameID in pairs(childNodeNameIDs or {}) do
            local childNodeID = professionRuleNodes[childNodeNameID].nodeID
            local childNodeData = parseNode(childNodeID, nodeData)
            table.insert(nodeData.childNodes, childNodeData)
            nodeData.idMapping:Merge(childNodeData.idMapping)
        end

        nodeData:UpdateAffectance()
        nodeData:UpdateProfessionStats()

        self.professionStats:add(nodeData.professionStats)

        return nodeData
    end

    for _, nodeID in pairs(baseRuleNodeIDs) do
        table.insert(self.baseNodeData, parseNode(nodeID, nil))
    end
end

function CraftSim.SpecializationData:GetExtraFactors()
    local extraFactors = CraftSim.ProfessionStats()

    extraFactors.inspiration.extraFactor = self.professionStats.inspiration.extraFactor
    extraFactors.multicraft.extraFactor = self.professionStats.multicraft.extraFactor
    extraFactors.resourcefulness.extraFactor = self.professionStats.resourcefulness.extraFactor

    return extraFactors
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