_, CraftSim = ...


---@class CraftSim.BuffData
CraftSim.BuffData = CraftSim.Object:extend()

function CraftSim.BuffData:new()
    ---@type CraftSim.ProfessionStats
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
    statLines = CraftSim.GUTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.GUTIL:Concat({debugLines, statLines})

    return debugLines
end


function CraftSim.BuffData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("professionStats", self.professionStats)
    jb:Add("incenseActive", self.incenseActive)
    jb:Add("alchemicallyInspiredActive", self.alchemicallyInspiredActive)
    jb:Add("quickHandsActive", self.quickHandsActive, true)
    jb:End()
    return jb.json
end