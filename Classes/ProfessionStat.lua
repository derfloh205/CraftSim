---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.ProfessionStat : CraftSim.CraftSimObject
---@overload fun(name: string?, value: number?, percentMod: number?): CraftSim.ProfessionStat
CraftSim.ProfessionStat = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.ProfessionsStats.ProfessionStat")

---@param name string
---@param value number?
---@param percentMod number?
function CraftSim.ProfessionStat:new(name, value, percentMod)
    self.name = name
    self.value = value or 0
    self.percentMod = percentMod or 0
    ---@type number[]
    self.extraValues = {} -- for special values like extra items from multicraft or concentration saved and so on
end

---@param index? number default: 1
---@return number extraValue default: 0
function CraftSim.ProfessionStat:GetExtraValue(index)
    return self.extraValues[index or 1] or 0
end

---@param value number
---@param index number? default: 1
function CraftSim.ProfessionStat:SetExtraValue(value, index)
    self.extraValues[index or 1] = value or 0
end

function CraftSim.ProfessionStat:GetPercent(decimal)
    if self.percentMod then
        if not decimal then
            return self.value * self.percentMod * 100
        else
            return self.value * self.percentMod
        end
    else
        error("CraftSim ProfessionStat: No Percent Mod set: " .. tostring(self.name))
    end
end

---@param percent number as decimal e.g. 0.20
function CraftSim.ProfessionStat:SetValueByPercent(percent)
    self.value = percent / self.percentMod
end

function CraftSim.ProfessionStat:Clear()
    self.value = 0
    wipe(self.extraValues)
end

---@param value number
function CraftSim.ProfessionStat:addValue(value)
    self.value = self.value + value
end

---@param extraValue number
---@param index? number default: 1
function CraftSim.ProfessionStat:addExtraValue(extraValue, index)
    index = index or 1
    self:SetExtraValue(self:GetExtraValue(index) + extraValue, index)
end

---@param extraValue number
---@param index? number default: 1
function CraftSim.ProfessionStat:subtractExtraValue(extraValue, index)
    index = index or 1
    self:SetExtraValue(self:GetExtraValue(index) - extraValue, index)
end

---@param professionStat CraftSim.ProfessionStat
function CraftSim.ProfessionStat:addExtraValues(professionStat)
    for index, extraValue in pairs(professionStat.extraValues) do
        self:addExtraValue(extraValue, index)
    end
end

---@param value number
function CraftSim.ProfessionStat:subtractValue(value)
    self.value = self.value - value
end

---@param professionStat CraftSim.ProfessionStat
function CraftSim.ProfessionStat:subtractExtraValues(professionStat)
    for index, extraValue in pairs(professionStat.extraValues) do
        self:subtractExtraValue(extraValue, index)
    end
end

function CraftSim.ProfessionStat:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("name", self.name)
    jb:Add("value", self.value)
    jb:Add("percentMod", self.percentMod)
    jb:AddList("extraValues", self.extraValues, true)
    jb:End()
    return jb.json
end

---@class CraftSim.ProfessionStat.Serialized
---@field name string
---@field value number
---@field percentMod number
---@field extraValues number[]

---@return CraftSim.ProfessionStat.Serialized
function CraftSim.ProfessionStat:Serialize()
    ---@type CraftSim.ProfessionStat.Serialized
    local serializedData = {
        name = self.name,
        value = self.value,
        extraValues = self.extraValues,
        percentMod = self.percentMod,
    }
    return serializedData
end

---@param serializedData CraftSim.ProfessionStat.Serialized
function CraftSim.ProfessionStat:Deserialize(serializedData)
    local professionStat = CraftSim.ProfessionStat()
    professionStat.name = serializedData.name
    professionStat.value = serializedData.value
    professionStat.percentMod = serializedData.percentMod
    professionStat.extraValues = serializedData.extraValues or {}

    return professionStat
end
