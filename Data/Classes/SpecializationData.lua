_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

---@class CraftSim.SpecializationData
CraftSim.SpecializationData = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.SpecializationData:new(recipeData)
    if not recipeData then
        return
    end
    self.recipeData = recipeData
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.NodeData
    self.nodeData = {}

    self.isImplemented = CraftSim.UTIL:IsSpecImplemented(recipeData.professionData.professionInfo.profession)

    if recipeData.isOldWorldRecipe then
        return
    end

    local nodeNameData = CraftSim.SPEC_DATA:GetNodes(recipeData.professionData.professionInfo.profession)
    local professionRuleNodes = CraftSim.SPEC_DATA:RULE_NODES()[recipeData.professionData.professionInfo.profession]

    local nodeIDs = CraftSim.GUTIL:ToSet(CraftSim.GUTIL:Map(nodeNameData, function (nameData) return nameData.nodeID end))

    for _, nodeID in pairs(nodeIDs) do
        local ruleNodes = CraftSim.GUTIL:Filter(professionRuleNodes, function (n) return n.nodeID == nodeID end)
        local nodeName = CraftSim.GUTIL:Find(nodeNameData, function(nnd) return nnd.nodeID == nodeID end).name
        local nodeData = CraftSim.NodeData(self.recipeData, nodeName, ruleNodes)


        nodeData:UpdateAffectance()
        nodeData:UpdateProfessionStats()

        print("@node: " .. nodeName .. " affects: " .. tostring(nodeData.affectsRecipe))

        table.insert(self.nodeData, nodeData)
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
        lines = CraftSim.GUTIL:Map(lines, function (line)
            return "-" .. line
        end)

        debugLines = CraftSim.GUTIL:Concat({debugLines, lines})
    end

    table.insert(debugLines, "Stats from Specializations:")

    local lines = self.professionStats:Debug()
    lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)

    debugLines = CraftSim.GUTIL:Concat({debugLines, lines})

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
    table.foreach(self.numNodesPerLayer, function (index, value)
        local listString = "["
        table.foreach(value, function (index, v)
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