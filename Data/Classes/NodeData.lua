_, CraftSim = ...

---@class CraftSim.NodeData
---@field recipeData CraftSim.RecipeData
---@field nodeID number
---@field active boolean
---@field rank number
---@field maxRank number
---@field nodeName? string
---@field description? string
---@field affectsRecipe boolean
---@field professionStats CraftSim.ProfessionStats
---@field idMapping CraftSim.IDMapping
---@field parentNode? CraftSim.NodeData
---@field nodeRules CraftSim.NodeRule[]
---@field childNodes CraftSim.NodeData[]

CraftSim.NodeData = CraftSim.Object:extend()

---@param nodeRulesData table[]
function CraftSim.NodeData:new(recipeData, nodeRulesData, parentNode)
    if not recipeData then
        return
    end
    self.recipeData = recipeData
    self.parentNode = parentNode
    self.nodeID = nodeRulesData[1].nodeID
    self.professionStats = CraftSim.ProfessionStats()
    self.idMapping = CraftSim.IDMapping(self.recipeData, nodeRulesData[1].idMapping, nodeRulesData[1].exceptionRecipeIDs)
    self.nodeRules = {}
    self.childNodes = {}

    local configID = C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID)
    local nodeInfo = C_Traits.GetNodeInfo(configID, self.nodeID)

    self.active = nodeInfo.activeRank > 0
    self.rank = nodeInfo.activeRank - 1
    self.maxRank = nodeInfo.maxRanks - 1

    table.foreach(nodeRulesData, function (_, nodeRuleData)
        table.insert(self.nodeRules, CraftSim.NodeRule(nodeRuleData, self))
    end)
end

function CraftSim.NodeData:Debug()
    local debugLines = {
        "nodeName: " .. tostring(self.nodeName),
        "nodeID: " .. tostring(self.nodeID),
        "affectsRecipe: " .. tostring(self.affectsRecipe),
        "active: " .. tostring(self.active),
        "rank: " .. tostring(self.rank) .. " / " .. tostring(self.maxRank),
    }

    for _, childNode in pairs(self.childNodes) do
        local lines = childNode:Debug()
        lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)

        debugLines = CraftSim.UTIL:Concat({debugLines, lines})
    end
    return debugLines
end

function CraftSim.NodeData:UpdateAffectance()
    self.affectsRecipe = self.idMapping:AffectsRecipe()
end

function CraftSim.NodeData:UpdateProfessionStats()
    if not self.affectsRecipe or not self.active then
        return
    end

    self.professionStats:Clear()

    for _, nodeRule in pairs(self.nodeRules) do
        nodeRule:UpdateProfessionStatsByRank(self.rank)
        if self.rank >= nodeRule.threshold then
            
            self.professionStats:add(nodeRule.professionStats)
        end
    end
end

function CraftSim.NodeData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("nodeID", self.nodeID)
    jb:Add("active", self.active)
    jb:Add("rank", self.rank)
    jb:Add("maxRank", self.maxRank)
    jb:Add("nodeName", self.nodeName)
    jb:Add("affectsRecipe", self.affectsRecipe)
    jb:Add("professionStats", self.professionStats)
    jb:Add("idMapping", self.idMapping)
    jb:Add("parentNodeID", (self.parentNode and self.parentNode.nodeID) or nil)
    jb:AddList("nodeRules", self.nodeRules)
    jb:AddList("childNodeIDs", CraftSim.GUTIL:Map(self.childNodes, function(cn) return cn.nodeID end), true)
    jb:End()
    return jb.json
end