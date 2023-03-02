_, CraftSim = ...

---@class CraftSim.ProfessionGearSet
CraftSim.ProfessionGearSet = CraftSim.Object:extend()

---@param professionID number
function CraftSim.ProfessionGearSet:new(professionID)
    self.professionID = professionID
    self.professionGearSlots = C_TradeSkillUI.GetProfessionSlots(professionID)
    if professionID ~= Enum.Profession.Cooking then
        ---@type CraftSim.ProfessionGear?
        self.gear1 = CraftSim.ProfessionGear()
        self.isCooking = false
    else
        self.isCooking = true
    end
    ---@type CraftSim.ProfessionGear
    self.gear2 = CraftSim.ProfessionGear()
    ---@type CraftSim.ProfessionGear
    self.tool = CraftSim.ProfessionGear()
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
end

function CraftSim.ProfessionGearSet:LoadCurrentEquippedSet()

    if self.isCooking then
        self.tool:SetItem(GetInventoryItemLink("player", self.professionGearSlots[1]))
        self.gear2:SetItem(GetInventoryItemLink("player", self.professionGearSlots[2]))
    else
        self.tool:SetItem(GetInventoryItemLink("player", self.professionGearSlots[1]))
        self.gear1:SetItem(GetInventoryItemLink("player", self.professionGearSlots[2]))
        self.gear2:SetItem(GetInventoryItemLink("player", self.professionGearSlots[3]))
    end

    self:UpdateProfessionStats()
end

function CraftSim.ProfessionGearSet:UpdateProfessionStats()
    self.professionStats:Clear()
    if self.isCooking then
        self.professionStats:add(self.gear2.professionStats)
        self.professionStats:add(self.tool.professionStats)
    else
        self.professionStats:add(self.gear1.professionStats)
        self.professionStats:add(self.gear2.professionStats)
        self.professionStats:add(self.tool.professionStats)
    end
end

function CraftSim.ProfessionGearSet:GetProfessionGearList()
    if self.isCooking then
        return {self.tool, self.gear2}
    else
        return {self.tool, self.gear1, self.gear2}
    end
end

function CraftSim.ProfessionGearSet:Equals(professionGearSet)
    if self.isCooking ~= professionGearSet.isCooking then
        return false
    end

    if not self.isCooking then
        local toolA = self.tool
        local gear1A = self.gear1
        local gear2A = self.gear2
        local toolB = professionGearSet.tool
        local gear1B = professionGearSet.gear1
        local gear2B = professionGearSet.gear2
    
        local existsGear1 = gear1A.item == nil and (gear1B.item == nil or gear2B.item == nil)
        if not existsGear1 then
            existsGear1 = (gear1B.item and gear1B:Equals(gear1A)) or (gear2B.item and gear2B:Equals(gear1A))
        end
    
        local existsGear2 = gear2A.item == nil and (gear1B.item == nil or gear2B.item == nil)
        if not existsGear2 then
            existsGear2 = (gear1B.item and gear1B:Equals(gear2A)) or (gear2B.item and gear2B:Equals(gear2A))
        end
    
        local existsTool = toolA.item == nil and toolB.item == nil
        if not existsTool then
            existsTool = toolB.item and toolB:Equals(toolA)
        end
    
        if existsGear1 and existsGear2 and existsTool then
            return true
        end
    
        return false
    else
        local toolA = self.tool
        local gear2A = self.gear2
        local toolB = professionGearSet.tool
        local gear2B = professionGearSet.gear2
    
        local existsGear = gear2A.item == nil and gear2B.item == nil
        if not existsGear then
            existsGear = gear2B.item and gear2B:Equals(gear2A)
        end
    
        local existsTool = toolA.item == nil and toolB.item == nil
        if not existsTool then
            existsTool = toolB.item and toolB:Equals(toolA)
        end
    
        if existsGear and existsTool then
            return true
        end
    
        return false
    end
end

function CraftSim.ProfessionGearSet:IsEquipped()
    local equippedSet = CraftSim.ProfessionGearSet(self.professionID)
    equippedSet:LoadCurrentEquippedSet()

    return self:Equals(equippedSet)
end

function CraftSim.ProfessionGearSet:Equip()
    CraftSim.TOPGEAR.IsEquipping = true
    CraftSim.TOPGEAR:UnequipProfessionItems(self.professionID)
    C_Timer.After(1, function ()
        for _, professionGear in pairs(self:GetProfessionGearList()) do
            if professionGear.item then
                CraftSim.GUTIL:EquipItemByLink(professionGear.item:GetItemLink())
                EquipPendingItem(0)
            end
        end

        CraftSim.TOPGEAR.IsEquipping = false
    end)
end

function CraftSim.ProfessionGearSet:Copy()
    local copy = CraftSim.ProfessionGearSet(self.professionID)
    copy.professionStats = self.professionStats:Copy()
    if self.gear1 then
        copy.gear1 = self.gear1:Copy()
    end
    copy.gear2 = self.gear2:Copy()
    copy.tool = self.tool:Copy()

    copy:UpdateProfessionStats()

    return copy
end

function CraftSim.ProfessionGearSet:Debug()
    local debugLines = {}

    if self.isCooking then
        local toolLines = self.tool:Debug()
        toolLines[1] = "-Tool: " .. toolLines[1]
        debugLines = CraftSim.GUTIL:Concat({debugLines, toolLines})
        local gearLines = self.gear2:Debug()
        gearLines[1] = "-Gear: " .. gearLines[1]
        debugLines = CraftSim.GUTIL:Concat({debugLines, gearLines})
    else
        local toolLines = self.tool:Debug()
        toolLines[1] = "-Tool: " .. toolLines[1]
        debugLines = CraftSim.GUTIL:Concat({debugLines, toolLines})
        local gearLines = self.gear1:Debug()
        gearLines[1] = "-Gear: " .. gearLines[1]
        debugLines = CraftSim.GUTIL:Concat({debugLines, gearLines})
        local gearLines2 = self.gear2:Debug()
        gearLines2[1] = "-Gear2: " .. gearLines2[1]
        debugLines = CraftSim.GUTIL:Concat({debugLines, gearLines2})

    end

    return debugLines
end

function CraftSim.ProfessionGearSet:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("professionID", self.professionID)
    jb:AddList("professionGearSlots", self.professionGearSlots)
    jb:Add("isCooking", self.isCooking)
    if self.isCooking then
        jb:Add("gear2", self.gear2)
    else
        jb:Add("gear1", self.gear1)
        jb:Add("gear2", self.gear2)
    end
    jb:Add("tool", self.tool)
    jb:Add("professionStats", self.professionStats, true)
    jb:End()
    return jb.json
end

