_, CraftSim = ...

---@class CraftSim.ProfessionStat
CraftSim.ProfessionStat = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@param name string
---@param value number?
---@param percentMod number?
function CraftSim.ProfessionStat:new(name, value, percentMod)
    self.name = name
    self.value = value or 0
    self.percentMod = percentMod or 0
    self.extraFactor = 0
    self.extraValue = 0
    self.extraValueAfterFactor = 0
end

---@param multiplicative boolean e.g. False: 0.5 or True: 1.5
function CraftSim.ProfessionStat:GetExtraFactor(multiplicative)
    if not multiplicative then
        return self.extraFactor
    else
        return self.extraFactor + 1
    end
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
    self.extraFactor = 0
    self.extraValue = 0
    self.extraValueAfterFactor = 0
end

-- Used by Inspiration only
function CraftSim.ProfessionStat:GetExtraValueByFactor()
    return (self.extraValue*(1+self.extraFactor)) + self.extraValueAfterFactor
end

---@param value number
function CraftSim.ProfessionStat:addValue(value)
    self.value = self.value + value
end
---@param factor number
function CraftSim.ProfessionStat:addFactor(factor)
    self.extraFactor = self.extraFactor + factor
end
---@param extraValue number
function CraftSim.ProfessionStat:addExtraValue(extraValue)
    self.extraValue = self.extraValue + extraValue
end
---@param extraValueAfterFactor number
function CraftSim.ProfessionStat:addExtraValueAfterFactor(extraValueAfterFactor)
    self.extraValueAfterFactor = self.extraValueAfterFactor + extraValueAfterFactor
end
---@param value number
function CraftSim.ProfessionStat:subtractValue(value)
    self.value = self.value - value
end
---@param factor number
function CraftSim.ProfessionStat:subtractFactor(factor)
    self.extraFactor = self.extraFactor - factor
end
---@param extraValue number
function CraftSim.ProfessionStat:subtractExtraValue(extraValue)
    self.extraValue = self.extraValue - extraValue
end
---@param extraValueAfterFactor number
function CraftSim.ProfessionStat:subtractExtraValueAfterFactor(extraValueAfterFactor)
    self.extraValueAfterFactor = self.extraValueAfterFactor - extraValueAfterFactor
end

function CraftSim.ProfessionStat:GetJSON(indent)
	indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("name", self.name)
    jb:Add("value", self.value)
    jb:Add("percentMod", self.percentMod)
    jb:Add("extraFactor", self.extraFactor)
    jb:Add("extraValue", self.extraValue)
    jb:Add("extraValueAfterFactor", self.extraValueAfterFactor, true)
    jb:End()
    return jb.json
end