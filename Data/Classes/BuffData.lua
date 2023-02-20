_, CraftSim = ...

---@class CraftSim.BuffData
---@field professionStats CraftSim.ProfessionStats
---@field incenseActive boolean
---@field alchemicallyInspiredActive boolean
---@field quickHandsActive boolean

CraftSim.BuffData = CraftSim.Object:extend()

function CraftSim.BuffData:new()
    self.professionStats = CraftSim.ProfessionStats()
    self.incenseActive = false
    self.quickHandsActive = false
    self.alchemicallyInspiredActive = false
end

function CraftSim.BuffData:Update()
    --- check for current buffs and adapt professionStats
	local inspirationIncense = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.INSPIRATION_INCENSE)
	local quickPhial = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS)
	local alchemicallyInspired = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.ALCHEMICALLY_INSPIRED)

    self.professionStats:Clear()

    if inspirationIncense then
        self.incenseActive = true
        self.professionStats.inspiration:addValue(20)
    end
    
    if quickPhial then
        self.quickHandsActive = true
        self.professionStats.craftingspeed:SetValueByPercent(quickPhial.points[1])
    end
    
    if alchemicallyInspired then
        self.alchemicallyInspiredActive = true
        self.professionStats.inspiration:addValue(20)
    end
end

function CraftSim.BuffData:Debug()
    local debugLines = {
        "Incense: " .. tostring(self.incenseActive),
        "QuickHands: " .. tostring(self.quickHandsActive),
        "Alchemically Inspired: " .. tostring(self.alchemicallyInspiredActive),
    }

    local statLines = self.professionStats:Debug()
    statLines = CraftSim.UTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.UTIL:Concat({debugLines, statLines})

    return debugLines
end