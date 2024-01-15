---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.NodeData
---@overload fun(recipeData: CraftSim.RecipeData?, nodeName: string?, nodeRulesData: table?, parentNode:CraftSim.NodeData?): CraftSim.NodeData
CraftSim.NodeData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

---@param recipeData CraftSim.RecipeData?
---@param nodeName string
---@param nodeRulesData table
---@param parentNode CraftSim.NodeData
function CraftSim.NodeData:new(recipeData, nodeName, nodeRulesData, parentNode)
    self.affectsRecipe = false
    if not recipeData then
        return
    end
    self.parentNode         = parentNode
    self.recipeData         = recipeData
    ---@type CraftSim.NodeData[]
    self.childNodes         = {}
    self.nodeName           = nodeName
    ---@type number
    self.nodeID             = nodeRulesData[1].nodeID
    ---@type CraftSim.ProfessionStats
    self.professionStats    = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.maxProfessionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.NodeRule[]
    self.nodeRules          = {}

    self.configID           = C_ProfSpecs.GetConfigIDForSkillLine(self.recipeData.professionData.skillLineID)
    local nodeInfo          = C_Traits.GetNodeInfo(self.configID, self.nodeID)
    self.entryIDs           = nodeInfo.entryIDs
    self.entryInfos         = GUTIL:Map(self.entryIDs, function(entryID)
        return C_Traits.GetEntryInfo(self.configID, entryID)
    end)
    local definitionInfos   = GUTIL:Map(self.entryInfos, function(entryInfo)
        return C_Traits.GetDefinitionInfo(entryInfo.definitionID)
    end)
    if definitionInfos[1] then
        self.icon = definitionInfos[1].overrideIcon
    end

    self.perkInfos = C_ProfSpecs.GetPerksForPath(self.nodeID)

    if (nodeInfo) then
        self.active = nodeInfo.activeRank > 0
        self.rank = nodeInfo.activeRank - 1
        self.maxRank = nodeInfo.maxRanks - 1
    else
        self.active = false
        self.rank = 0
        self.maxRank = 0
    end

    table.foreach(nodeRulesData, function(_, nodeRuleData)
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
        lines = GUTIL:Map(lines, function(line) return "-" .. line end)

        debugLines = GUTIL:Concat({ debugLines, lines })
    end
    return debugLines
end

function CraftSim.NodeData:UpdateAffectance()
    for _, nodeRule in pairs(self.nodeRules) do
        nodeRule:UpdateAffectance()
    end
    -- if at least one rule node of the node affects the recipe, the node affects the recipe
    self.affectsRecipe = GUTIL:Count(self.nodeRules, function(nr) return nr.affectsRecipe end) > 0

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
end

---@return string
function CraftSim.NodeData:GetTooltipText()
    local header = GUTIL:IconToText(self.icon, 30, 30) .. " " .. self.nodeName
    local tooltipText = header ..
        "\n\n" .. GUTIL:ColorizeText(tostring(C_ProfSpecs.GetDescriptionForPath(self.nodeID)), GUTIL.COLORS.WHITE)
    for _, perkInfo in ipairs(self.perkInfos) do
        local unlockRank = C_ProfSpecs.GetUnlockRankForPerk(perkInfo.perkID)
        local rankText = "Rank " .. unlockRank .. ":\n"
        local perkDescription = C_ProfSpecs.GetDescriptionForPerk(perkInfo.perkID)

        if self.rank >= unlockRank then
            rankText = GUTIL:ColorizeText(rankText, GUTIL.COLORS.GREEN)
            perkDescription = GUTIL:ColorizeText(perkDescription, GUTIL.COLORS.WHITE)
        else
            rankText = GUTIL:ColorizeText(rankText, GUTIL.COLORS.GREY)
            perkDescription = GUTIL:ColorizeText(perkDescription, GUTIL.COLORS.GREY)
        end
        tooltipText = tooltipText .. "\n\n" .. rankText .. perkDescription
    end

    tooltipText = tooltipText ..
        "\n\nTotal Stats from Talent:\n" ..
        GUTIL:ColorizeText(self.professionStats:GetTooltipText(self.maxProfessionStats), GUTIL.COLORS.WHITE)

    return tooltipText
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
    jb:AddList("childNodeIDs", GUTIL:Map(self.childNodes, function(cn) return cn.nodeID end), true)
    jb:End()
    return jb.json
end

---@class CraftSim.NodeData.Serialized
---@field nodeID number
---@field parentNodeID number
---@field childNodes CraftSim.NodeData.Serialized[]
---@field nodeName string
---@field configID number
---@field entryIDs number[]
---@field entryInfos TraitEntryInfo[]
---@field icon number
---@field perkInfos SpecPerkInfo[]
---@field active boolean
---@field rank number
---@field maxRank number
---@field affectsRecipe boolean

---@return CraftSim.NodeData.Serialized
function CraftSim.NodeData:Serialize()
    ---@type CraftSim.NodeData.Serialized
    local serializedData = {}
    serializedData.nodeID = self.nodeID
    if self.parentNode then
        serializedData.parentNodeID = self.parentNode.nodeID
    end
    serializedData.nodeName = self.nodeName
    serializedData.configID = self.configID
    serializedData.entryIDs = CopyTable(self.entryIDs)
    serializedData.entryInfos = CopyTable(self.entryInfos)
    serializedData.icon = self.icon
    serializedData.perkInfos = CopyTable(self.perkInfos)
    serializedData.active = self.active
    serializedData.rank = self.rank
    serializedData.maxRank = self.maxRank
    serializedData.affectsRecipe = self.affectsRecipe

    return serializedData
end

---@param serializedData CraftSim.NodeData.Serialized
---@param recipeData CraftSim.RecipeData
---@param nodeIDMap table<number, CraftSim.NodeData>
---@param professionRuleNodes table<string, table>
---@return CraftSim.NodeData
function CraftSim.NodeData:Deserialize(serializedData, recipeData, nodeIDMap, professionRuleNodes)
    local nodeData = CraftSim.NodeData()
    nodeData.professionStats = CraftSim.ProfessionStats()
    nodeData.maxProfessionStats = CraftSim.ProfessionStats()
    nodeData.nodeID = serializedData.nodeID
    nodeIDMap[serializedData.nodeID] = nodeData
    nodeData.recipeData = recipeData
    nodeData.nodeName = serializedData.nodeName
    nodeData.configID = serializedData.configID
    nodeData.entryIDs = serializedData.entryIDs
    nodeData.entryInfos = serializedData.entryInfos
    nodeData.icon = serializedData.icon
    nodeData.perkInfos = serializedData.perkInfos
    nodeData.active = serializedData.active
    nodeData.rank = serializedData.rank
    nodeData.maxRank = serializedData.maxRank
    nodeData.affectsRecipe = serializedData.affectsRecipe
    nodeData.nodeRules = {}

    local ruleNodes = GUTIL:Filter(professionRuleNodes, function(n) return n.nodeID == nodeData.nodeID end)

    for _, ruleNode in pairs(ruleNodes) do
        local nodeRule = CraftSim.NodeRule(recipeData, ruleNode, nodeData)
        table.insert(nodeData.nodeRules, nodeRule) -- no need to serialize/deserialize nodeRules, just built again
    end

    nodeData:UpdateAffectance()

    return nodeData
end
