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
---@deprecated
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

-- Global

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff chefsHat
function CraftSim.CRAFT_BUFFS:CreateChefsHatBuff(recipeData)
    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.CHEFS_HAT, CraftSim.ProfessionStats(), nil, nil, nil,
        L(CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP))
end

-- TWW

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff everburningIgnition
function CraftSim.CRAFT_BUFFS:CreateEverburningIgnitionBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    --- EverburningForge Traits
    local nodeIDs = { 99267, 99266, 99265, 99264 }

    for _, nodeID in ipairs(nodeIDs) do
        local nodeData = CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, nodeID,
            CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN, Enum.Profession.Blacksmithing)
        buffStats:add(nodeData.professionStats)
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateWeaversTutelageBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()

    buffStats.craftingspeed:SetValueByPercent(0.2)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.WEAVERS_TUTELAGE, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff potionSpillOverBuff
function CraftSim.CRAFT_BUFFS:CreatePotionSpillOverBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    local potionBulkProductionNodeID = 99040
    local nodeData = CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, potionBulkProductionNodeID, 10,
        Enum.Profession.Alchemy)
    local isDouble = nodeData.rank >= 25

    if isDouble then
        buffStats.ingenuity:addValue(24)
        buffStats.multicraft:addValue(24)
        buffStats.resourcefulness:addValue(24)
    else
        buffStats.ingenuity:addValue(12)
        buffStats.multicraft:addValue(12)
        buffStats.resourcefulness:addValue(12)
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.POTION_SPILL_OVER, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff flaskSpillOverBuff
function CraftSim.CRAFT_BUFFS:CreateFlaskSpillOverBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    local bulkProductionNodeID = 98952
    local nodeData = CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, bulkProductionNodeID, 10,
        Enum.Profession.Alchemy)
    local isDouble = nodeData.rank >= 25

    if isDouble then
        buffStats.ingenuity:addValue(24)
        buffStats.multicraft:addValue(24)
        buffStats.resourcefulness:addValue(24)
    else
        buffStats.ingenuity:addValue(12)
        buffStats.multicraft:addValue(12)
        buffStats.resourcefulness:addValue(12)
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.FLASK_SPILL_OVER, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff phialSpillOverBuff
function CraftSim.CRAFT_BUFFS:CreatePhialSpillOverBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    local bulkProductionNodeID = 98951
    local nodeData = CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, bulkProductionNodeID, 10,
        Enum.Profession.Alchemy)
    local isDouble = nodeData.rank >= 25

    if isDouble then
        buffStats.ingenuity:addValue(24)
        buffStats.multicraft:addValue(24)
        buffStats.resourcefulness:addValue(24)
    else
        buffStats.ingenuity:addValue(12)
        buffStats.multicraft:addValue(12)
        buffStats.resourcefulness:addValue(12)
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_SPILL_OVER, buffStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff shatteringEssence
function CraftSim.CRAFT_BUFFS:CreateShatteringEssenceBuff(recipeData)
    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE, CraftSim.ProfessionStats())
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff[] phialBuffs
function CraftSim.CRAFT_BUFFS:CreatePhialOfBountifulSeasonsBuffs(recipeData)
    local buffs = {}
    -- phial 1
    local q1Stats = CraftSim.ProfessionStats()
    q1Stats.resourcefulness:addValue(84)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS, q1Stats, 1, {
        index = 1,
        value = 84
    }, nil, nil, 212314))

    -- phial 2
    local q2Stats = CraftSim.ProfessionStats()
    q2Stats.resourcefulness:addValue(106)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS, q2Stats, 2, {
        index = 1,
        value = 106,
    }, nil, nil, 212315))

    -- phial 3
    local q3Stats = CraftSim.ProfessionStats()
    q3Stats.resourcefulness:addValue(135)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS, q3Stats, 3, {
        index = 1,
        value = 135,
    }, nil, nil, 212316))

    return buffs
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff[] phialBuffs
function CraftSim.CRAFT_BUFFS:CreatePhialOfAmbidexterityBuffs(recipeData)
    local buffs = {}
    -- phial 1
    local q1Stats = CraftSim.ProfessionStats()
    q1Stats.craftingspeed:SetValueByPercent(0.05)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_AMBIDEXTERITY, q1Stats, 1, {
        index = 1,
        value = 5
    }, nil, nil, 212311))

    -- phial 2
    local q2Stats = CraftSim.ProfessionStats()
    q2Stats.craftingspeed:SetValueByPercent(0.1)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_AMBIDEXTERITY, q2Stats, 2, {
        index = 1,
        value = 10,
    }, nil, nil, 212312))

    -- phial 3
    local q3Stats = CraftSim.ProfessionStats()
    q3Stats.craftingspeed:SetValueByPercent(0.15)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_AMBIDEXTERITY, q3Stats, 3, {
        index = 1,
        value = 15,
    }, nil, nil, 212313))

    return buffs
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff[] phialBuffs
function CraftSim.CRAFT_BUFFS:CreatePhialOfConcentratedIngenuityBuffs(recipeData)
    local buffs = {}
    -- phial 1
    local q1Stats = CraftSim.ProfessionStats()
    q1Stats.ingenuity:addValue(84)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_CONCENTRATED_INGENUITY, q1Stats, 1, {
        index = 1,
        value = 84
    }, nil, nil, 212305))

    -- phial 2
    local q2Stats = CraftSim.ProfessionStats()
    q2Stats.ingenuity:addValue(106)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_CONCENTRATED_INGENUITY, q2Stats, 2, {
        index = 1,
        value = 106,
    }, nil, nil, 212306))

    -- phial 3
    local q3Stats = CraftSim.ProfessionStats()
    q3Stats.ingenuity:addValue(135)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_CONCENTRATED_INGENUITY, q3Stats, 3, {
        index = 1,
        value = 135,
    }, nil, nil, 212307))

    return buffs
end

-- DRAGONFLIGHT

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

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff incenseBuff
function CraftSim.CRAFT_BUFFS:CreateIncenseBuff(recipeData)
    local incenseStats = CraftSim.ProfessionStats()
    incenseStats.ingenuity:addValue(20)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.SAGACIOUS_INCENSE, incenseStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff alchemicallyInspiredBuff
function CraftSim.CRAFT_BUFFS:CreateAlchemicallyInspiredBuff(recipeData)
    local stats = CraftSim.ProfessionStats()
    stats.ingenuity:addValue(20)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.ALCHEMICALLY_INSPIRED, stats, nil, nil, nil,
        "Whenever you achieve a major breakthrough in experimentation\ngain +20 Ingenuity for 4 hours for all Alchemy crafts.")
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
