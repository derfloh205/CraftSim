_, CraftSim = ...


---@class CraftSim.NodeData
CraftSim.NodeData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

---@param nodeRulesData table[]
---@param recipeData CraftSim.RecipeData
---@param parentNode CraftSim.NodeData
function CraftSim.NodeData:new(recipeData, nodeName, nodeRulesData, parentNode)
    self.affectsRecipe = false
    if not recipeData then
        return
    end
    self.parentNode = parentNode
    self.recipeData = recipeData
    ---@type CraftSim.NodeData[]
    self.childNodes = {}
    self.nodeName = nodeName
    ---@type number
    self.nodeID = nodeRulesData[1].nodeID
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.maxProfessionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.NodeRule[]
    self.nodeRules = {}

    local configID = C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID)
    local nodeInfo = C_Traits.GetNodeInfo(configID, self.nodeID)

    if (nodeInfo) then
        self.active = nodeInfo.activeRank > 0
        self.rank = nodeInfo.activeRank - 1
        self.maxRank = nodeInfo.maxRanks - 1
    else
        self.active = false
        self.rank = 0
        self.maxRank = 0
    end

    table.foreach(nodeRulesData, function (_, nodeRuleData)
        table.insert(self.nodeRules, CraftSim.NodeRule(self.recipeData, nodeRuleData, self))
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

        debugLines = CraftSim.GUTIL:Concat({debugLines, lines})
    end
    return debugLines
end

function CraftSim.NodeData:UpdateAffectance()
    for _, nodeRule in pairs(self.nodeRules) do
        nodeRule:UpdateAffectance()
    end
    -- if at least one rule node of the node affects the recipe, the node affects the recipe
    self.affectsRecipe = CraftSim.GUTIL:Count(self.nodeRules, function (nr) return nr.affectsRecipe end) > 0

    if self.affectsRecipe and self.rank > -1 then
        self.active = true
    end
end

function CraftSim.NodeData:UpdateProfessionStats()
    

    -- always clear stats even if not affected or active
    -- this is important so that stats change to 0 when its not active anymore in the simulator!
    self.professionStats:Clear()
    self.maxProfessionStats:Clear()
    if not self.affectsRecipe then
        return
    end

    --- DEBUG
    if self.nodeName == "Curing and Tanning" then
        print("NodeData: Update Stats of Node: " .. self.nodeName)
    end

    for i, nodeRule in pairs(self.nodeRules) do       
        -- only use rules that affect the recipe
        if nodeRule.affectsRecipe then
            -- for maxProfessionStats always use max rank
            nodeRule:UpdateProfessionStatsByRank(self.maxRank)
            self.maxProfessionStats:add(nodeRule.professionStats)

            -- then do it again for actual rank if its active
            nodeRule:UpdateProfessionStatsByRank(self.rank)
            if self.rank >= nodeRule.threshold then
                self.professionStats:add(nodeRule.professionStats)
            end
        end
    end

    --- DEBUG
    if self.nodeName == "Curing and Tanning" then
        print("NodeData: Stats from node after update: ")
        print(self.professionStats, true, nil, 1)
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