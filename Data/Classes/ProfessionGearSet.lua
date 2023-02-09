_, CraftSim = ...

---@class CraftSim.ProfessionGearSet
---@field professionID number
---@field professionGearSlots string[]
---@field isCooking boolean
---@field gear1? CraftSim.ProfessionGear
---@field gear2 CraftSim.ProfessionGear
---@field tool CraftSim.ProfessionGear
---@field professionStats CraftSim.ProfessionStats

CraftSim.ProfessionGearSet = CraftSim.Object:extend()

---@params professionID number
function CraftSim.ProfessionGearSet:new(professionID)
    self.professionID = professionID
    self.professionGearSlots = C_TradeSkillUI.GetProfessionSlots(professionID)
    if professionID ~= Enum.Profession.Cooking then
        self.gear1 = CraftSim.ProfessionGear()
        self.isCooking = false
    else
        self.isCooking = true
    end
    self.gear2 = CraftSim.ProfessionGear()
    self.tool = CraftSim.ProfessionGear()
    self.professionStats = CraftSim.ProfessionStats()
end

function CraftSim.ProfessionGearSet:LoadCurrentEquippedSet()

    if self.isCooking then
        self.gear2:SetItem(GetInventoryItemLink("player", self.professionGearSlots[1]))
        self.tool:SetItem(GetInventoryItemLink("player", self.professionGearSlots[2]))
    else
        self.gear1:SetItem(GetInventoryItemLink("player", self.professionGearSlots[1]))
        self.gear2:SetItem(GetInventoryItemLink("player", self.professionGearSlots[2]))
        self.tool:SetItem(GetInventoryItemLink("player", self.professionGearSlots[3]))
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

