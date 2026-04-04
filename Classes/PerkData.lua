---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.SpecializationData.NodeData.PerkData")


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
    self.raw_stats = perkData.stats or {}


    for stat, amount in pairs(self.raw_stats) do
        -- skill
        -- multicraft
        -- resourcefulness
        -- ingenuity
        -- craftingspeed
        if self.professionStats[stat] then
            self.professionStats[stat].value = amount or 0
        end
        if stat == "ingenuityrefundincrease" then
            self.professionStats.ingenuity:SetExtraValue((stat == "ingenuityrefundincrease" and (amount / 100)))
        elseif stat == "reduceconcentrationcost" then
            self.professionStats.ingenuity:SetExtraValue((stat == "reduceconcentrationcost" and (amount / 100)), 2)
        elseif stat == "reagentssavedfromresourcefulness" then
            self.professionStats.resourcefulness:SetExtraValue((stat == "reagentssavedfromresourcefulness" and (amount / 100)))
        elseif stat == "additionalitemscraftedwithmulticraft" then
            self.professionStats.multicraft:SetExtraValue((stat == "additionalitemscraftedwithmulticraft" and (amount / 100)))
        end
    end
end

function CraftSim.PerkData:Update()
    self.active = self.baseNode.rank >= self.threshold
end

function CraftSim.PerkData:Debug()
    local debugLines = {
        "perkID: " .. tostring(self.perkID),
        "threshold: " .. tostring(self.threshold),
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
    perkData.stat = self.stat
    perkData.stat_amount = self.stat_amount
    return perkData
end
