---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.BUFFDATA)

---@class CraftSim.Buff
---@overload fun(recipeData: CraftSim.RecipeData, buffID: CraftSim.BuffID, professionStats:CraftSim.ProfessionStats, qualityID: number?, valuePointData: CraftSim.Buff.ValuePointData?, displayBuffID: number?, customTooltip: string?): CraftSim.Buff
CraftSim.Buff = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param buffID CraftSim.BuffID
---@param professionStats CraftSim.ProfessionStats
---@param qualityID number?
---@param valuePointData CraftSim.Buff.ValuePointData?
---@param displayBuffID number? if the buff to display is a different one than the one to recognize the aura
---@param customTooltip string?
function CraftSim.Buff:new(recipeData, buffID, professionStats, qualityID, valuePointData, displayBuffID, customTooltip)
    ---@type CraftSim.ProfessionStats
    self.professionStats = professionStats
    local spellInfo = { GetSpellInfo(buffID) }
    local qualityIcon = ""
    self.valuePointData = valuePointData
    self.qualityID = qualityID
    self.recipeData = recipeData
    if self.qualityID then
        qualityIcon = " " .. GUTIL:GetQualityIconString(self.qualityID, 20, 20)
    end
    self.name = spellInfo[1] .. qualityIcon
    self.buffID = buffID
    self.displayBuffID = displayBuffID or buffID
    self.active = false
    self.customTooltip = customTooltip
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

    if self.valuePointData then
        self.active = auraData.points[self.valuePointData.index] == self.valuePointData.value
    end
end

--- returns a unique id as string for this buff and its quality
---@return string uuid
function CraftSim.Buff:GetUID()
    return self.buffID .. ":" .. (self.qualityID or 0)
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
