---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.BuffData.Buff")

---@class CraftSim.Buff : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, buffID: CraftSim.BuffID, professionStats:CraftSim.ProfessionStats, qualityID: number?, valuePointData: CraftSim.Buff.ValuePointData?, displayBuffID: number?, customTooltip: string?, displayItemID: number?): CraftSim.Buff
CraftSim.Buff = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param buffID CraftSim.BuffID
---@param professionStats CraftSim.ProfessionStats
---@param qualityID number?
---@param valuePointData CraftSim.Buff.ValuePointData?
---@param displayBuffID number? if the buff to display is a different one than the one to recognize the aura
---@param customTooltip string?
function CraftSim.Buff:new(recipeData, buffID, professionStats, qualityID, valuePointData, displayBuffID, customTooltip,
                           displayItemID)
    ---@type CraftSim.ProfessionStats
    self.professionStats = professionStats
    self.baseProfessionStats = professionStats:Copy()
    local spellInfo = C_Spell.GetSpellInfo(buffID)
    local qualityIcon = ""
    self.valuePointData = valuePointData
    self.qualityID = qualityID
    self.recipeData = recipeData
    if self.qualityID then
        qualityIcon = " " .. GUTIL:GetQualityIconString(self.qualityID, 20, 20)
    end
    self.name = spellInfo.name .. qualityIcon
    self.buffID = buffID
    self.displayBuffID = displayBuffID or buffID
    self.displayItemID = displayItemID
    self.active = false
    self.customTooltip = customTooltip
    self.showItemTooltip = false
    self.stacks = 1
end

---@class CraftSim.Buff.ValuePointData
---@field index number
---@field value number

function CraftSim.Buff:Update()
    --- check for current buff
    local auraData = C_UnitAuras.GetPlayerAuraBySpellID(self.buffID)

    if not auraData then
        self.active = false
        return
    end

    self.active = true
    self.stacks = math.max(1, auraData.applications)

    if self.valuePointData then
        self.active = (auraData.points[self.valuePointData.index] / self.stacks) == self.valuePointData.value
    end

    -- update stats (for stackable buffs)
    self.professionStats:Clear()

    for _ = 1, self.stacks do
        self.professionStats:add(self.baseProfessionStats)
    end
end

--- returns a unique id as string for this buff and its quality
---@return string uuid
function CraftSim.Buff:GetUID()
    return (self.buffID or self.name) .. ":" .. (self.qualityID or 0)
end

function CraftSim.Buff:Debug()
    local debugLines = {
        "Name: " .. tostring(self.name),
        "Active: " .. tostring(self.active),
        "ProfessionStats: ",
    }

    local statLines = self.professionStats:Debug()
    statLines = CraftSim.GUTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.GUTIL:Concat({ debugLines, statLines })

    return debugLines
end

function CraftSim.Buff:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("name", self.name)
    jb:Add("active", self.active)
    jb:Add("professionStats", self.professionStats)
    jb:End()
    return jb.json
end

-- bag buffs..

---@class CraftSim.BagBuff : CraftSim.Buff
---@overload fun(recipeData: CraftSim.RecipeData, bagItemID: ItemID, professionStats:CraftSim.ProfessionStats): CraftSim.Buff
CraftSim.BagBuff = CraftSim.Buff:extend()

---@param recipeData CraftSim.RecipeData
---@param bagItemID ItemID
---@param professionStats CraftSim.ProfessionStats
function CraftSim.BagBuff:new(recipeData, bagItemID, professionStats)
    self.professionStats = professionStats
    self.baseProfessionStats = professionStats:Copy()
    self.recipeData = recipeData
    self.displayItemID = bagItemID
    self.active = false
    self.stacks = 1
    self.showItemTooltip = true
    self.name = select(1, C_Item.GetItemInfo(bagItemID)) or "BagBuff"
end

function CraftSim.BagBuff:Update()
    self.active = CraftSim.UTIL:CheckIfBagIsEquipped(self.displayItemID)
end
