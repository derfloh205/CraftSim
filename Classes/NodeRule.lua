---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)


---@class CraftSim.NodeRule : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData?, nodeRuleData: table, nodeData: CraftSim.NodeData):CraftSim.NodeRule
CraftSim.NodeRule = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData?
---@param nodeRuleData table
---@param nodeData CraftSim.NodeData
function CraftSim.NodeRule:new(recipeData, nodeRuleData, nodeData)
    self.affectsRecipe = false
    if not recipeData then
        return
    end
    self.nodeData = nodeData
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    self.threshold = nodeRuleData.threshold or -42 -- dont ask why 42

    ---@type CraftSim.IDMapping
    self.idMapping = CraftSim.IDMapping(recipeData, nodeRuleData.idMapping, nodeRuleData.exceptionRecipeIDs)

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
    self.equalsInspirationBonusSkillFactor = nodeRuleData.equalsInspirationBonusSkillFactor or false
    self.equalsResourcefulness = nodeRuleData.equalsResourcefulness or false
    self.equalsCraftingspeed = nodeRuleData.equalsCraftingspeed or false
    self.equalsResourcefulnessExtraItemsFactor = nodeRuleData.equalsResourcefulnessExtraItemsFactor or false
    self.equalsPhialExperimentationChanceFactor = nodeRuleData.equalsPhialExperimentationChanceFactor or false
    self.equalsPotionExperimentationChanceFactor = nodeRuleData.equalsPotionExperimentationChanceFactor or false
end

function CraftSim.NodeRule:UpdateAffectance()
    self.affectsRecipe = self.idMapping:AffectsRecipe()
    print(self.nodeData.nodeName .. "-Rule affects recipe: " .. tostring(self.affectsRecipe))
end

---@param rank number
function CraftSim.NodeRule:UpdateProfessionStatsByRank(rank)
    -- only if I affect the recipe
    if not self.affectsRecipe then
        return
    end

    -- DEBUG
    if self.nodeData.nodeName == "Curing and Tanning" then
        print("updating curing and tanning node rule stats with rank: " .. tostring(rank))
    end

    if self.equalsSkill then
        self.professionStats.skill.value = math.max(0, rank)
    end

    if self.equalsMulticraft then
        self.professionStats.multicraft.value = math.max(0, rank)
    end

    if self.equalsInspiration then
        self.professionStats.inspiration.value = math.max(0, rank)
    end

    if self.equalsInspirationBonusSkillFactor then
        self.professionStats.inspiration.extraFactor = math.max(0, rank * 0.01)
    end

    if self.equalsResourcefulness then
        self.professionStats.resourcefulness.value = math.max(0, rank)
    end

    if self.equalsCraftingspeed then
        self.professionStats.craftingspeed.value = math.max(0, rank)
    end

    if self.equalsResourcefulnessExtraItemsFactor then
        self.professionStats.resourcefulness.extraFactor = math.max(0, rank * 0.01)
    end

    if self.equalsPhialExperimentationChanceFactor then
        self.professionStats.phialExperimentationFactor.extraFactor = math.max(0, rank * 0.01)
    end

    if self.equalsPotionExperimentationChanceFactor then
        self.professionStats.potionExperimentationFactor.extraFactor = math.max(0, rank * 0.01)
    end

    if self.nodeData.nodeName == "Curing and Tanning" then
        print("NodeRule: Rule stats after updating rule: ")
        print(self.professionStats, true, nil, 1)
    end
end

function CraftSim.NodeRule:Debug()
    local debugLines = {
        "nodeID: " .. tostring(self.nodeData.nodeID),
        "affectsRecipe: " .. tostring(self.affectsRecipe),
        "threshold: " .. tostring(self.threshold),
        "equalsSkill: " .. tostring(self.equalsSkill),
        "equalsMulticraft: " .. tostring(self.equalsMulticraft),
        "equalsInspiration: " .. tostring(self.equalsInspiration),
        "equalsResourcefulness: " .. tostring(self.equalsResourcefulness),
        "equalsCraftingspeed: " .. tostring(self.equalsCraftingspeed),
        "equalsResourcefulnessExtraItemsFactor: " .. tostring(self.equalsResourcefulnessExtraItemsFactor),
    }
    local statLines = self.professionStats:Debug()
    statLines = CraftSim.GUTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.GUTIL:Concat({ debugLines, statLines })
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
    jb:Add("equalsCraftingspeed", self.equalsCraftingspeed)
    jb:Add("equalsResourcefulnessExtraItemsFactor", self.equalsResourcefulnessExtraItemsFactor)
    jb:Add("equalsPhialExperimentationChanceFactor", self.equalsPhialExperimentationChanceFactor)
    jb:Add("equalsPotionExperimentationChanceFactor", self.equalsPotionExperimentationChanceFactor, true)
    jb:End()
    return jb.json
end
