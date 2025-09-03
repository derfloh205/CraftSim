---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.ProfessionGearSet : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData) : CraftSim.ProfessionGearSet
CraftSim.ProfessionGearSet = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
function CraftSim.ProfessionGearSet:new(recipeData)
    self.professionID = recipeData.professionData.professionInfo.profession
    self.recipeData = recipeData
    self.professionGearSlots = self.professionID and C_TradeSkillUI.GetProfessionSlots(self.professionID) or {}
    self.isCooking = recipeData.isCooking
    if not self.isCooking then
        ---@type CraftSim.ProfessionGear?
        self.gear1 = CraftSim.ProfessionGear()
    end
    ---@type CraftSim.ProfessionGear
    self.gear2 = CraftSim.ProfessionGear()
    ---@type CraftSim.ProfessionGear
    self.tool = CraftSim.ProfessionGear()
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
end

function CraftSim.ProfessionGearSet:LoadCurrentEquippedSet()
    local crafterUID = self.recipeData:GetCrafterUID()

    if self.recipeData:IsCrafter() then
        if self.isCooking then
            local tool = GetInventoryItemLink("player", self.professionGearSlots[1])
            local gear2 = GetInventoryItemLink("player", self.professionGearSlots[2])
            self.tool:SetItem(tool)
            self.gear2:SetItem(gear2)
        else
            local tool = GetInventoryItemLink("player", self.professionGearSlots[1])
            local gear1 = GetInventoryItemLink("player", self.professionGearSlots[2])
            local gear2 = GetInventoryItemLink("player", self.professionGearSlots[3])
            self.tool:SetItem(tool)
            self.gear1:SetItem(gear1)
            self.gear2:SetItem(gear2)
        end

        CraftSim.DB.CRAFTER:SaveProfessionGearEquipped(crafterUID, self.professionID, self)
    else
        local equippedGearSerialized = CraftSim.DB.CRAFTER:GetProfessionGearEquipped(crafterUID, self.professionID)
        if equippedGearSerialized then
            self:LoadSerialized(equippedGearSerialized)
        end
    end

    self:UpdateProfessionStats()
end

---@param serializedData CraftSim.ProfessionGearSet.Serialized
function CraftSim.ProfessionGearSet:LoadSerialized(serializedData)
    if self.isCooking then
        self.tool = CraftSim.ProfessionGear:Deserialize(serializedData.tool)
        self.gear2 = CraftSim.ProfessionGear:Deserialize(serializedData.gear2)
    else
        self.tool = CraftSim.ProfessionGear:Deserialize(serializedData.tool)
        self.gear1 = CraftSim.ProfessionGear:Deserialize(serializedData.gear1)
        self.gear2 = CraftSim.ProfessionGear:Deserialize(serializedData.gear2)
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

---@return CraftSim.ProfessionGear[]
function CraftSim.ProfessionGearSet:GetProfessionGearList()
    if self.isCooking then
        return { self.tool, self.gear2 }
    else
        return { self.tool, self.gear1, self.gear2 }
    end
end

function CraftSim.ProfessionGearSet:GetProfessionGearListOrderedRight()
    if self.isCooking then
        return { self.tool, self.gear2 }
    else
        return { self.tool, self.gear2, self.gear1 }
    end
end

function CraftSim.ProfessionGearSet:Equals(professionGearSet)
    if self.recipeData.recipeID ~= professionGearSet.recipeData.recipeID then
        return false
    end
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
    local equippedSet = CraftSim.ProfessionGearSet(self.recipeData)
    equippedSet:LoadCurrentEquippedSet()

    return self:Equals(equippedSet)
end

function CraftSim.ProfessionGearSet:Equip()
    CraftSim.TOPGEAR.IsEquipping = true
    CraftSim.TOPGEAR:UnequipProfessionItems(self.professionID)
    C_Timer.After(1, function()
        for index, professionGear in ipairs(self:GetProfessionGearList()) do
            if professionGear.item then
                CraftSim.GUTIL:EquipItemByLink(professionGear.item:GetItemLink())
                EquipPendingItem(0)
            end
        end

        CraftSim.TOPGEAR.IsEquipping = false
    end)
end

function CraftSim.ProfessionGearSet:Copy()
    local copy = CraftSim.ProfessionGearSet(self.recipeData)
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
        debugLines = CraftSim.GUTIL:Concat({ debugLines, toolLines })
        local gearLines = self.gear2:Debug()
        gearLines[1] = "-Gear: " .. gearLines[1]
        debugLines = CraftSim.GUTIL:Concat({ debugLines, gearLines })
    else
        local toolLines = self.tool:Debug()
        toolLines[1] = "-Tool: " .. toolLines[1]
        debugLines = CraftSim.GUTIL:Concat({ debugLines, toolLines })
        local gearLines = self.gear1:Debug()
        gearLines[1] = "-Gear: " .. gearLines[1]
        debugLines = CraftSim.GUTIL:Concat({ debugLines, gearLines })
        local gearLines2 = self.gear2:Debug()
        gearLines2[1] = "-Gear2: " .. gearLines2[1]
        debugLines = CraftSim.GUTIL:Concat({ debugLines, gearLines2 })
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

---@class CraftSim.ProfessionGearSet.Serialized
---@field profession Enum.Profession
---@field isCooking boolean
---@field gear1 CraftSim.ProfessionGear.Serialized
---@field gear2 CraftSim.ProfessionGear.Serialized
---@field tool CraftSim.ProfessionGear.Serialized

---@return CraftSim.ProfessionGearSet.Serialized
function CraftSim.ProfessionGearSet:Serialize()
    ---@type CraftSim.ProfessionGearSet.Serialized
    local serializedData = {
        profession = self.professionID,
        isCooking = self.isCooking,
        gear1 = self.gear1 and self.gear1:Serialize(),
        gear2 = self.gear2 and self.gear2:Serialize(),
        tool = self.tool and self.tool:Serialize(),
    }
    return serializedData
end

---@param serializedData CraftSim.ProfessionGearSet.Serialized
---@return CraftSim.ProfessionGearSet
function CraftSim.ProfessionGearSet:Deserialize(serializedData, recipeData)
    local professionGearSet = CraftSim.ProfessionGearSet(recipeData)
    if professionGearSet.isCooking then
        professionGearSet.gear2 = CraftSim.ProfessionGear:Deserialize(serializedData.gear2)
        professionGearSet.tool = CraftSim.ProfessionGear:Deserialize(serializedData.tool)
    else
        professionGearSet.gear1 = CraftSim.ProfessionGear:Deserialize(serializedData.gear1)
        professionGearSet.gear2 = CraftSim.ProfessionGear:Deserialize(serializedData.gear2)
        professionGearSet.tool = CraftSim.ProfessionGear:Deserialize(serializedData.tool)
    end

    professionGearSet:UpdateProfessionStats()

    return professionGearSet
end
