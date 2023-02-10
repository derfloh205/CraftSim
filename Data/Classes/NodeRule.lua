_, CraftSim = ...

---@class CraftSim.NodeRule
---@field nodeData CraftSim.NodeData
---@field threshold number
---@field professionStats CraftSim.ProfessionStats
---@field equalsSkill boolean
---@field equalsMulticraft boolean
---@field equalsInspiration boolean
---@field equalsResourcefulness boolean
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