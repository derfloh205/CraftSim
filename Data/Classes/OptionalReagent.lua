_, CraftSim = ...


---@class CraftSim.OptionalReagent
CraftSim.OptionalReagent = CraftSim.Object:extend()

---@param craftingReagent CraftingReagent
function CraftSim.OptionalReagent:new(craftingReagent)
    self.item = Item:CreateFromItemID(craftingReagent.itemID)
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    local stats = CraftSim.OPTIONAL_REAGENT_DATA[craftingReagent.itemID]

    if stats then
        self.qualityID = stats.qualityID
        self.professionStats.recipeDifficulty.value = stats.recipeDifficulty or 0
        self.professionStats.skill.value = stats.skill or 0

        self.professionStats.inspiration.value = stats.inspiration or 0
        self.professionStats.inspiration.extraFactor = stats.inspirationBonusSkillFactor or 0

        self.professionStats.multicraft.value = stats.multicraft or 0

        self.professionStats.resourcefulness.value = stats.resourcefulness or 0
        self.professionStats.resourcefulness.extraFactor = stats.resourcefulnessExtraItemsFactor or 0

        self.professionStats.craftingspeed.extraFactor = stats.craftingspeedBonusFactor or 0
    end
end

function CraftSim.OptionalReagent:Debug()
    return {
        self.item:GetItemLink() or self.item:GetItemID()
    }
end

function CraftSim.OptionalReagent:Copy()
    local copy = CraftSim.OptionalReagent({itemID = self.item:GetItemID()})
    return copy
end

---@class CraftSim.OptionalReagent.Serialized
---@field qualityID number
---@field itemID number

function CraftSim.OptionalReagent:Serialize()
    local serialized = {}
    serialized.qualityID = self.qualityID
    serialized.itemID = self.item:GetItemID()
    return serialized
end

---STATIC: Deserializes an optionalReagent
---@param serializedOptionalReagent CraftSim.OptionalReagent.Serialized
---@return CraftSim.OptionalReagent
function CraftSim.OptionalReagent:Deserialize(serializedOptionalReagent)
    serializedOptionalReagent.itemID = tonumber(serializedOptionalReagent.itemID) or 0
    serializedOptionalReagent.qualityID = tonumber(serializedOptionalReagent.qualityID) or 0
    return CraftSim.OptionalReagent(serializedOptionalReagent) -- as it builds from itemID only its fine
end

function CraftSim.OptionalReagent:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("professionStats", self.professionStats)
    jb:Add("qualityID", self.qualityID)
    jb:Add("itemID", self.item:GetItemID())
    jb:End()
    return jb.json
end