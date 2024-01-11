---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.BuffData
---@overload fun(recipeData: CraftSim.RecipeData): CraftSim.BuffData
CraftSim.BuffData = CraftSim.Object:extend()

local debug = true

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.BUFFDATA)

---@param recipeData CraftSim.RecipeData
function CraftSim.BuffData:new(recipeData)
    self.recipeData = recipeData
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type table<number, CraftSim.Buff>
    self.buffs = {}
    self:CreateBuffsByRecipeData()
end

function CraftSim.BuffData:CreateBuffsByRecipeData()
    -- by professionID
    if self.recipeData.supportsInspiration then
        --- General Buffs
        local incenseStats = CraftSim.ProfessionStats()
        incenseStats.inspiration:addValue(20)
        table.insert(self.buffs, CraftSim.Buff(CraftSim.CONST.BUFF_IDS.INSPIRATION_INCENSE, incenseStats))

        --- Alchemy
        if debug or self.recipeData.professionData.professionInfo.professionID == Enum.Profession.Alchemy then
            local alchemicallyInspiredStats = CraftSim.ProfessionStats()
            alchemicallyInspiredStats.inspiration:addValue(20)
            table.insert(self.buffs, CraftSim.Buff(CraftSim.CONST.BUFF_IDS.ALCHEMICALLY_INSPIRED, alchemicallyInspiredStats))
        end
    end

    if self.recipeData.supportsCraftingspeed then
        --- General
        -- quick phial 1
        local quickPhialQ1Stats = CraftSim.ProfessionStats()
        quickPhialQ1Stats.craftingspeed:SetValueByPercent(0.18)

        table.insert(self.buffs, CraftSim.Buff(CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ1Stats, 1, {
            index = 1,
            value = 18
        }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q1))

        -- quick phial 2
        local quickPhialQ2Stats = CraftSim.ProfessionStats()
        quickPhialQ2Stats.craftingspeed:SetValueByPercent(0.24)

        table.insert(self.buffs, CraftSim.Buff(CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ2Stats, 2, {
            index = 1,
            value = 24
        }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q2))

        -- quick phial 3
        local quickPhialQ3Stats = CraftSim.ProfessionStats()
        quickPhialQ3Stats.craftingspeed:SetValueByPercent(0.30)

        table.insert(self.buffs, CraftSim.Buff(CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ3Stats, 3, {
            index = 1,
            value = 30
        }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q3))
    end
end

function CraftSim.BuffData:Update()

    print("Update Buffs...")
    --- check for current buffs and adapt professionStats
    self.professionStats:Clear()

    for _, buff in pairs(self.buffs) do
        buff:Update()
        if buff.active then
            print("Active Buff: " .. tostring(buff.name))
            self.professionStats:add(buff.professionStats)
        end
    end

    -- if inspirationIncense then
    --     self.incenseActive = true
    --     self.professionStats.inspiration:addValue(20)
    -- end
    
    -- if quickPhial then
    --     self.quickHandsActive = true
    --     self.professionStats.craftingspeed:SetValueByPercent(quickPhial.points[1])
    -- end
    
    -- if alchemicallyInspired then
    --     self.alchemicallyInspiredActive = true
    --     self.professionStats.inspiration:addValue(20)
    -- end
end

function CraftSim.BuffData:Debug()
    local debugLines = {
        "Buffs: ",
    }

    local statLines = GUTIL:Map(self.buffs, function (buff)
        return buff:Debug()
    end)
    statLines = CraftSim.GUTIL:Map(statLines, function(line) return "-" .. line end)
    debugLines = CraftSim.GUTIL:Concat({debugLines, statLines})

    return debugLines
end


function CraftSim.BuffData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("professionStats", self.professionStats)
    jb:AddList("buffs", self.buffs, true)
    jb:End()
    return jb.json
end