---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.BuffData
---@overload fun(recipeData: CraftSim.RecipeData): CraftSim.BuffData
CraftSim.BuffData = CraftSim.Object:extend()

local L = CraftSim.UTIL:GetLocalizer()

local debug = false

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
    print("create buffs by recipe data")

    -- by professionID and professionStats
    if self.recipeData.supportsInspiration then
        --- General Buffs
        local incenseStats = CraftSim.ProfessionStats()
        incenseStats.inspiration:addValue(20)
        table.insert(self.buffs, CraftSim.Buff(self.recipeData, CraftSim.CONST.BUFF_IDS.INSPIRATION_INCENSE, incenseStats))

        --- Alchemy
        if debug or self.recipeData.professionData.professionInfo.profession == Enum.Profession.Alchemy then
            local alchemicallyInspiredStats = CraftSim.ProfessionStats()
            alchemicallyInspiredStats.inspiration:addValue(20)
            table.insert(self.buffs, CraftSim.Buff(self.recipeData, CraftSim.CONST.BUFF_IDS.ALCHEMICALLY_INSPIRED, alchemicallyInspiredStats))
        end
    end

    if self.recipeData.supportsCraftingspeed then
        --- General
        -- quick phial 1
        local quickPhialQ1Stats = CraftSim.ProfessionStats()
        quickPhialQ1Stats.craftingspeed:SetValueByPercent(0.18)

        table.insert(self.buffs, CraftSim.Buff(self.recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ1Stats, 1, {
            index = 1,
            value = 18
        }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q1))

        -- quick phial 2
        local quickPhialQ2Stats = CraftSim.ProfessionStats()
        quickPhialQ2Stats.craftingspeed:SetValueByPercent(0.24)

        table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ2Stats, 2, {
            index = 1,
            value = 24
        }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q2))

        -- quick phial 3
        local quickPhialQ3Stats = CraftSim.ProfessionStats()
        quickPhialQ3Stats.craftingspeed:SetValueByPercent(0.30)

        table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ3Stats, 3, {
            index = 1,
            value = 30
        }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q3))
    end

    if self.recipeData.isCooking then
        -- cooking hat toy
        table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.CHEFS_HAT, CraftSim.ProfessionStats(), nil, nil, nil, 
        L(CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP)))
    end

    if self.recipeData.supportsQualities then
        print("create buffs for recipe supporting qualities")
        --- enchanting
        if self.recipeData.professionData.professionInfo.profession == Enum.Profession.Enchanting then
            local shatterStats = CraftSim.ProfessionStats()
            shatterStats.skill:addValue(25)

            print("create elemental shatter buffs")

            -- elemental shatter fire
            if self.recipeData.reagentData:HasOneOfReagents({190320, 190321}) then
                table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_FIRE, shatterStats))
            end

            -- elemental shatter frost
            if self.recipeData.reagentData:HasOneOfReagents({190328, 190329}) then
                table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_FROST, shatterStats))
            end

             -- elemental shatter earth
            if self.recipeData.reagentData:HasOneOfReagents({190316, 190315}) then
                table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_EARTH, shatterStats))
            end

            -- elemental shatter air
           if self.recipeData.reagentData:HasOneOfReagents({190326, 190327}) then
               table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_AIR, shatterStats))
           end

            -- elemental shatter order
           if self.recipeData.reagentData:HasOneOfReagents({391812, 190324}) then
               table.insert(self.buffs, CraftSim.Buff(self.recipeData,CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_ORDER, shatterStats))
           end
        end
    end
end

function CraftSim.BuffData:UpdateBuffs()
    for _, buff in pairs(self.buffs) do
        buff:Update()
    end
end

function CraftSim.BuffData:UpdateProfessionStats()
    --- check for current buffs and adapt professionStats
    self.professionStats:Clear()

    for _, buff in pairs(self.buffs) do
        if buff.active then
            self.professionStats:add(buff.professionStats)
        end
    end
end

function CraftSim.BuffData:Update()
    self:UpdateBuffs()
    self:UpdateProfessionStats()
end

---@param UIDToValueMap table<string, boolean> -- buffUID -> active
function CraftSim.BuffData:SetBuffsByUIDToValueMap(UIDToValueMap)
    for buffUID, active in pairs(UIDToValueMap) do
        self:SetBuffByUID(buffUID, active)
    end
end

---@param buffUID string
---@param active boolean
function CraftSim.BuffData:SetBuffByUID(buffUID, active)
    local buff = GUTIL:Find(self.buffs, function (buff)
        return buff:GetUID() == buffUID
    end)

    if buff then
        print("Setting " .. buff.name .. ": " .. tostring(active))
        buff.active = active
    end
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