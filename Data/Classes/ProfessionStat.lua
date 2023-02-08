_, CraftSim = ...

---@class CraftSim.ProfessionStat
---@field name string
---@field value number
---@field percentMod? number
---@field extraFactor? number
---@field extraValue? number

CraftSim.ProfessionStat = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

function CraftSim.ProfessionStat:new(name, value, percentMod)
    print("Creating Stat: " .. tostring(name))
    self.name = name
    self.value = value
    self.percentMod = percentMod
    self.extraFactor = 0
    self.extraValue = 0
end

function CraftSim.ProfessionStat:GetPercent()
    if self.percentMod then
        return self.value * self.percentMod
    else
        error("CraftSim ProfessionStat: No Percent Mod set: " .. tostring(self.name))
    end
end