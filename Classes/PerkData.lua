---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)


---@class CraftSim.PerkData : CraftSim.CraftSimObject
---@overload fun(baseNode: CraftSim.NodeData?, perkID: number?, perkData: CraftSim.RawPerkData?) : CraftSim.PerkData
CraftSim.PerkData = CraftSim.CraftSimObject:extend()

---@param baseNode CraftSim.NodeData
---@param perkID number
---@param perkData CraftSim.RawPerkData
function CraftSim.PerkData:new(baseNode, perkID, perkData)
    if not baseNode then return end

    self.recipeData = baseNode.recipeData
    self.baseNode = baseNode
    self.perkID = perkID

    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()

    self.threshold = C_ProfSpecs.GetUnlockRankForPerk(perkID)
    self.active = false

    self.stat = perkData.stat
    self.stat_amount = perkData.stat_amount

    if not perkData.stat then return end

    local stat = perkData.stat
    local amount = perkData.stat_amount

    self.professionStats.skill.value = (stat == "skill" and amount) or 0
    self.professionStats.multicraft.value = (stat == "multicraft" and amount) or 0
    self.professionStats.resourcefulness.value = (stat == "resourcefulness" and amount) or 0
    self.professionStats.ingenuity.value = (stat == "ingenuity" and amount) or 0
    self.professionStats.craftingspeed.value = (stat == "craftingspeed" and amount) or 0

    self.professionStats.ingenuity.extraFactor = (stat == "ingenuityrefundincrease" and (amount / 100)) or 0
    self.professionStats.resourcefulness.extraFactor = (stat == "reagentssavedfromresourcefulness" and (amount / 100)) or
        0
    self.professionStats.multicraft.extraFactor = (stat == "additionalitemscraftedwithmulticraft" and (amount / 100)) or
        0

    self.unlocksReagentSlot = stat == "unlockreagentslot"
end

function CraftSim.PerkData:Update()
    self.active = self.baseNode.rank >= self.threshold
end

function CraftSim.PerkData:Debug()
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
        "equalsIngenuityExtraConcentrationFactor: " .. tostring(self.equalsIngenuityExtraConcentrationFactor),
    }
    local statLines = self.professionStats:Debug()
    statLines = CraftSim.GUTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.GUTIL:Concat({ debugLines, statLines })
    return debugLines
end

function CraftSim.PerkData:GetJSON(indent)
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
    jb:Add("equalsIngenuityExtraConcentrationFactor", self.equalsIngenuityExtraConcentrationFactor)
    jb:Add("equalsPhialExperimentationChanceFactor", self.equalsPhialExperimentationChanceFactor)
    jb:Add("equalsPotionExperimentationChanceFactor", self.equalsPotionExperimentationChanceFactor, true)
    jb:End()
    return jb.json
end

---@class CraftSim.PerkData.Serialized
---@field active boolean
---@field perkID number
---@field threshold number
---@field professionStats CraftSim.ProfessionStats.Serialized
---@field unlocksReagentSlot boolean
---@field equalsSkill boolean
---@field equalsMulticraft boolean
---@field equalsResourcefulness boolean
---@field equalsIngenuity boolean
---@field equalsResourcefulnessExtraItemsFactor boolean
---@field equalsIngenuityExtraConcentrationFactor boolean
---@field equalsCraftingspeed boolean
---@field stat string
---@field stat_amount number


---@return CraftSim.PerkData.Serialized
function CraftSim.PerkData:Serialize()
    ---@type CraftSim.PerkData.Serialized
    local serialized = {
        active = self.active,
        perkID = self.perkID,
        threshold = self.threshold,
        professionStats = self.professionStats:Serialize(),
        unlocksReagentSlot = self.unlocksReagentSlot,
        equalsSkill = self.equalsSkill,
        equalsMulticraft = self.equalsMulticraft,
        equalsResourcefulness = self.equalsResourcefulness,
        equalsIngenuity = self.equalsIngenuity,
        equalsResourcefulnessExtraItemsFactor = self.equalsResourcefulnessExtraItemsFactor,
        equalsCraftingspeed = self.equalsCraftingspeed,
        equalsIngenuityExtraConcentrationFactor = self.equalsIngenuityExtraConcentrationFactor,
        stat = self.stat,
        stat_amount = self.stat_amount,
    }

    return serialized
end

---@param baseNode CraftSim.NodeData
---@param serializedData CraftSim.PerkData.Serialized
---@return CraftSim.PerkData
function CraftSim.PerkData:Deserialize(baseNode, serializedData)
    local perkData = CraftSim.PerkData()
    perkData.baseNode = baseNode
    perkData.active = serializedData.active
    perkData.perkID = serializedData.perkID
    perkData.threshold = serializedData.threshold
    perkData.unlocksReagentSlot = self.unlocksReagentSlot
    perkData.equalsSkill = self.equalsSkill
    perkData.equalsMulticraft = self.equalsMulticraft
    perkData.equalsResourcefulness = self.equalsResourcefulness
    perkData.equalsIngenuity = self.equalsIngenuity
    perkData.equalsResourcefulnessExtraItemsFactor = self.equalsResourcefulnessExtraItemsFactor
    perkData.equalsCraftingspeed = self.equalsCraftingspeed
    perkData.equalsIngenuityExtraConcentrationFactor = self.equalsIngenuityExtraConcentrationFactor
    perkData.stat = self.stat
    perkData.stat_amount = self.stat_amount
    return perkData
end
