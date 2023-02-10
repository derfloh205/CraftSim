_, CraftSim = ...

---@class CraftSim.NodeRule
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
function CraftSim.NodeRule:new(nodeRuleData)
    
end