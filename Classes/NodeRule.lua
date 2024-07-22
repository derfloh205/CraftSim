---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)


---@class CraftSim.NodeRule : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData?, nodeRuleData: table, nodeData: CraftSim.NodeData):CraftSim.NodeRule
CraftSim.NodeRule = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData?
---@param nodeRuleData CraftSim.SPECIALIZATION_DATA.RULE_DATA
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
    self.idMapping = CraftSim.IDMapping(recipeData, nodeRuleData.idMapping, nodeRuleData.exceptionRecipeIDs,
        nodeRuleData.affectedReagentIDs)

    self.professionStats.skill.value = nodeRuleData.skill or 0
    self.professionStats.multicraft.value = nodeRuleData.multicraft or 0
    self.professionStats.resourcefulness.value = nodeRuleData.resourcefulness or 0
    self.professionStats.ingenuity.value = nodeRuleData.ingenuity or 0
    self.professionStats.craftingspeed.value = nodeRuleData.craftingspeed or 0

    self.professionStats.multicraft.extraFactor = nodeRuleData.multicraftExtraItemsFactor or 0
    self.professionStats.resourcefulness.extraFactor = nodeRuleData.resourcefulnessExtraItemsFactor or 0

    self.equalsSkill = nodeRuleData.equalsSkill or 0
    self.equalsMulticraft = nodeRuleData.equalsMulticraft or 0
    self.equalsResourcefulness = nodeRuleData.equalsResourcefulness or 0
    self.equalsIngenuity = nodeRuleData.equalsIngenuity or 0
    self.equalsCraftingspeed = nodeRuleData.equalsCraftingspeed or 0
    self.equalsResourcefulnessExtraItemsFactor = nodeRuleData.equalsResourcefulnessExtraItemsFactor or 0
    self.equalsPhialExperimentationChanceFactor = nodeRuleData.equalsPhialExperimentationChanceFactor or 0
    self.equalsPotionExperimentationChanceFactor = nodeRuleData.equalsPotionExperimentationChanceFactor or 0
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

    if self.equalsSkill > 0 then
        self.professionStats.skill.value = math.max(0, rank * self.equalsSkill)
    end

    if self.equalsMulticraft > 0 then
        self.professionStats.multicraft.value = math.max(0, rank * self.equalsMulticraft)
    end

    if self.equalsResourcefulness > 0 then
        self.professionStats.resourcefulness.value = math.max(0, rank * self.equalsResourcefulness)
    end

    if self.equalsIngenuity > 0 then
        self.professionStats.ingenuity.value = math.max(0, rank * self.equalsIngenuity)
    end

    if self.equalsCraftingspeed > 0 then
        self.professionStats.craftingspeed.value = math.max(0, rank * self.equalsCraftingspeed)
    end

    if self.equalsResourcefulnessExtraItemsFactor > 0 then
        self.professionStats.resourcefulness.extraFactor = math.max(0, rank * self.equalsResourcefulnessExtraItemsFactor)
    end

    if self.equalsPhialExperimentationChanceFactor > 0 then
        self.professionStats.phialExperimentationFactor.extraFactor = math.max(0,
            rank * self.equalsPhialExperimentationChanceFactor)
    end

    if self.equalsPotionExperimentationChanceFactor > 0 then
        self.professionStats.potionExperimentationFactor.extraFactor = math.max(0,
            rank * self.equalsPotionExperimentationChanceFactor)
    end
end

function CraftSim.NodeRule:Debug()
    local debugLines = {
        "nodeID: " .. tostring(self.nodeData.nodeID),
        "affectsRecipe: " .. tostring(self.affectsRecipe),
        "threshold: " .. tostring(self.threshold),
        "equalsSkill: " .. tostring(self.equalsSkill),
        "equalsMulticraft: " .. tostring(self.equalsMulticraft),
        "equalsResourcefulness: " .. tostring(self.equalsResourcefulness),
        "equalsIngenuity: " .. tostring(self.equalsIngenuity),
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
    jb:Add("equalsResourcefulness", self.equalsResourcefulness)
    jb:Add("equalsIngenuity", self.equalsIngenuity)
    jb:Add("equalsCraftingspeed", self.equalsCraftingspeed)
    jb:Add("equalsResourcefulnessExtraItemsFactor", self.equalsResourcefulnessExtraItemsFactor)
    jb:Add("equalsPhialExperimentationChanceFactor", self.equalsPhialExperimentationChanceFactor)
    jb:Add("equalsPotionExperimentationChanceFactor", self.equalsPotionExperimentationChanceFactor, true)
    jb:End()
    return jb.json
end
