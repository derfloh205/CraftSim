_, CraftSim = ...

---@class CraftSim.NodeRule
---@field nodeData CraftSim.NodeData
---@field threshold number
---@field professionStats CraftSim.ProfessionStats
---@field equalsSkill boolean
---@field equalsMulticraft boolean
---@field equalsInspiration boolean
---@field equalsResourcefulness boolean
---@field equalsResourcefulnessPercent boolean
---@field equalsCraftingspeed boolean
---@field equalsResourcefulnessExtraItemsFactor boolean
---@field equalsPhialExperimentationChanceFactor boolean
---@field equalsPotionExperimentationChanceFactor boolean

CraftSim.NodeRule = CraftSim.Object:extend()

---@param nodeRuleData table
function CraftSim.NodeRule:new(nodeRuleData, nodeData)
    self.nodeData = nodeData
    self.professionStats = CraftSim.ProfessionStats()
    self.threshold = nodeRuleData.threshold or -42 -- dont ask why 42

    
    self.professionStats.skill.value = nodeRuleData.skill or 0
    self.professionStats.inspiration.value = nodeRuleData.inspiration or 0
    self.professionStats.multicraft.value = nodeRuleData.multicraft or 0
    self.professionStats.resourcefulness.value = nodeRuleData.resourcefulness or 0
    self.professionStats.craftingspeed.value = nodeRuleData.craftingspeed or 0
    
    self.professionStats.inspiration.extraFactor = nodeRuleData.inspirationBonusSkillFactor or 0
    self.professionStats.multicraft.extraFactor = nodeRuleData.multicraftExtraItemsFactor or 0
    self.professionStats.resourcefulness.extraFactor = nodeRuleData.resourcefulnessExtraItemsFactor or 0
    
    self.equalsSkill = nodeRuleData.equalsSkill or false
    self.equalsMulticraft = nodeRuleData.equalsMulticraft or false
    self.equalsInspiration = nodeRuleData.equalsInspiration or false
    self.equalsResourcefulness = nodeRuleData.equalsResourcefulness or false
    self.equalsResourcefulnessPercent = nodeRuleData.equalsResourcefulnessPercent or false
    self.equalsCraftingspeed = nodeRuleData.equalsCraftingspeed or false
    self.equalsResourcefulnessExtraItemsFactor = nodeRuleData.equalsResourcefulnessExtraItemsFactor or false
    self.equalsPhialExperimentationChanceFactor = nodeRuleData.equalsPhialExperimentationChanceFactor or false
    self.equalsPotionExperimentationChanceFactor = nodeRuleData.equalsPotionExperimentationChanceFactor or false

    self:UpdateProfessionStatsByRank()
end

function CraftSim.NodeRule:UpdateProfessionStatsByRank()
    if self.equalsSkill then
        self.professionStats.skill.value = self.nodeData.rank
    end
    
    if self.equalsMulticraft then
        self.professionStats.multicraft.value = self.nodeData.rank
    end

    if self.equalsInspiration then
        self.professionStats.inspiration.value = self.nodeData.rank
    end

    if self.equalsResourcefulness then
        self.professionStats.resourcefulness.value = self.nodeData.rank
    end

    if self.equalsResourcefulnessPercent then
        self.professionStats.resourcefulness.value = self.nodeData.rank * ( 0.01 / CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS)
    end

    if self.equalsCraftingspeed then
        self.professionStats.craftingspeed.value = self.nodeData.rank
    end

    if self.equalsResourcefulnessExtraItemsFactor then
        self.professionStats.resourcefulness.extraFactor = self.nodeData.rank * 0.01
    end

    if self.equalsPhialExperimentationChanceFactor then
        self.professionStats.phialExperimentationFactor.extraFactor = self.nodeData.rank * 0.01
    end

    if self.equalsPotionExperimentationChanceFactor then
        self.professionStats.potionExperimentationFactor.extraFactor = self.nodeData.rank * 0.01
    end

end

function CraftSim.NodeRule:Debug()
    local debugLines = {
        "nodeID: " .. tostring(self.nodeData.nodeID),
        "threshold: " .. tostring(self.threshold),
        "equalsSkill: " .. tostring(self.equalsSkill),
        "equalsMulticraft: " .. tostring(self.equalsMulticraft),
        "equalsInspiration: " .. tostring(self.equalsInspiration),
        "equalsResourcefulness: " .. tostring(self.equalsResourcefulness),
        "equalsCraftingspeed: " .. tostring(self.equalsCraftingspeed),
        "equalsResourcefulnessExtraItemsFactor: " .. tostring(self.equalsResourcefulnessExtraItemsFactor),
    }
    local statLines = self.professionStats:Debug()
    statLines = CraftSim.UTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.UTIL:Concat({debugLines, statLines})
    return debugLines
end

function CraftSim.NodeRule:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("nodeID", self.nodeData.nodeID)
    jb:Add("threshold", self.threshold)
    jb:Add("professionStats", self.professionStats)
    jb:Add("equalsSkill", self.equalsSkill)
    jb:Add("equalsMulticraft", self.equalsMulticraft)
    jb:Add("equalsInspiration", self.equalsInspiration)
    jb:Add("equalsResourcefulness", self.equalsResourcefulness)
    jb:Add("equalsResourcefulnessPercent", self.equalsResourcefulnessPercent)
    jb:Add("equalsCraftingspeed", self.equalsCraftingspeed)
    jb:Add("equalsResourcefulnessExtraItemsFactor", self.equalsResourcefulnessExtraItemsFactor)
    jb:Add("equalsPhialExperimentationChanceFactor", self.equalsPhialExperimentationChanceFactor)
    jb:Add("equalsPotionExperimentationChanceFactor", self.equalsPotionExperimentationChanceFactor, true)
    jb:End()
    return jb.json
end