---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint("BUFFDATA")

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.CRAFT_BUFFS : Frame
CraftSim.CRAFT_BUFFS = GUTIL:CreateRegistreeForEvents({ "COMBAT_LOG_EVENT_UNFILTERED" })

--- Buffs created by this method do not have a recipeData reference!
---@param profession Enum.Profession
---@return CraftSim.Buff[] professionBuffs
function CraftSim.CRAFT_BUFFS:GetRecipeScanBuffsByProfessionID(profession)
    local buffs = {}

    --- general

    table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateIncenseBuff())
    tAppendAll(buffs, CraftSim.CRAFT_BUFFS:CreateQuickPhialBuffs())

    --- Alchemy
    if profession == Enum.Profession.Alchemy then
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateAlchemicallyInspiredBuff())
    end

    if profession == Enum.Profession.Cooking then
        -- cooking hat toy
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateChefsHatBuff())
    end

    --- enchanting
    if profession == Enum.Profession.Enchanting then
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterFireBuff())
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterFrostBuff())
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterEarthBuff())
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterAirBuff())
        table.insert(buffs, CraftSim.CRAFT_BUFFS:CreateElementalShatterOrderBuff())
    end

    return buffs
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff incense
function CraftSim.CRAFT_BUFFS:CreateIncenseBuff(recipeData)
    local incenseStats = CraftSim.ProfessionStats()
    incenseStats.inspiration:addValue(20)
    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.INSPIRATION_INCENSE, incenseStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff alchemicallyInspired
function CraftSim.CRAFT_BUFFS:CreateAlchemicallyInspiredBuff(recipeData)
    local alchemicallyInspiredStats = CraftSim.ProfessionStats()
    alchemicallyInspiredStats.inspiration:addValue(20)
    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ALCHEMICALLY_INSPIRED, alchemicallyInspiredStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff chefsHat
function CraftSim.CRAFT_BUFFS:CreateChefsHatBuff(recipeData)
    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.CHEFS_HAT, CraftSim.ProfessionStats(), nil, nil, nil,
        L(CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP))
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff elementalShatter
function CraftSim.CRAFT_BUFFS:CreateElementalShatterFireBuff(recipeData)
    local shatterStats = CraftSim.ProfessionStats()
    shatterStats.skill:addValue(25)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_FIRE, shatterStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff elementalShatter
function CraftSim.CRAFT_BUFFS:CreateElementalShatterFrostBuff(recipeData)
    local shatterStats = CraftSim.ProfessionStats()
    shatterStats.skill:addValue(25)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_FROST, shatterStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff elementalShatter
function CraftSim.CRAFT_BUFFS:CreateElementalShatterEarthBuff(recipeData)
    local shatterStats = CraftSim.ProfessionStats()
    shatterStats.skill:addValue(25)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_EARTH, shatterStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff elementalShatter
function CraftSim.CRAFT_BUFFS:CreateElementalShatterAirBuff(recipeData)
    local shatterStats = CraftSim.ProfessionStats()
    shatterStats.skill:addValue(25)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_AIR, shatterStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff elementalShatter
function CraftSim.CRAFT_BUFFS:CreateElementalShatterOrderBuff(recipeData)
    local shatterStats = CraftSim.ProfessionStats()
    shatterStats.skill:addValue(25)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ELEMENTAL_SHATTER_ORDER, shatterStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff[] quickPhialBuffs
function CraftSim.CRAFT_BUFFS:CreateQuickPhialBuffs(recipeData)
    local buffs = {}
    -- quick phial 1
    local quickPhialQ1Stats = CraftSim.ProfessionStats()
    quickPhialQ1Stats.craftingspeed:SetValueByPercent(0.18)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ1Stats, 1, {
        index = 1,
        value = 18
    }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q1))

    -- quick phial 2
    local quickPhialQ2Stats = CraftSim.ProfessionStats()
    quickPhialQ2Stats.craftingspeed:SetValueByPercent(0.24)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ2Stats, 2, {
        index = 1,
        value = 24
    }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q2))

    -- quick phial 3
    local quickPhialQ3Stats = CraftSim.ProfessionStats()
    quickPhialQ3Stats.craftingspeed:SetValueByPercent(0.30)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS, quickPhialQ3Stats, 3, {
        index = 1,
        value = 30
    }, CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS_SPELL_Q3))

    return buffs
end

function CraftSim.CRAFT_BUFFS:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, _, sourceName = CombatLogGetCurrentEventInfo()
    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REMOVED" then
        if ProfessionsFrame:IsVisible() then
            local playerName = UnitName("player")
            if sourceName == playerName then
                local auraID = select(12, CombatLogGetCurrentEventInfo())
                print("Buff changed: " .. tostring(auraID))
                if tContains(CraftSim.CONST.BUFF_IDS, auraID) then
                    if CraftSim.INIT.currentRecipeID then
                        local isWorkOrder = ProfessionsFrame.OrdersPage:IsVisible()
                        if isWorkOrder then
                            CraftSim.INIT:TriggerModuleUpdate(false)
                        else
                            CraftSim.INIT:TriggerModuleUpdate(false)
                        end
                    end
                end
            end
        end
    end
end
