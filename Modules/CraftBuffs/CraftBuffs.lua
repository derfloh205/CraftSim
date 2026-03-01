---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftBuffs")

local L = CraftSim.UTIL:GetLocalizer()


---@class CraftSim.CRAFT_BUFFS : Frame
CraftSim.CRAFT_BUFFS = GUTIL:CreateRegistreeForEvents({ "UNIT_AURA" })

---@type number[]
CraftSim.CRAFT_BUFFS.activeBuffInstanceIds = {}

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

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateSeveredSatchelBuff(recipeData)
    return CraftSim.BagBuff(recipeData, CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.THE_SEVERED_SATCHEL,
        CraftSim.ProfessionStats())
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateConcoctorsClutchBuff(recipeData)
    return CraftSim.BagBuff(recipeData, CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.CONCOCTORS_CLUTCH,
        CraftSim.ProfessionStats())
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateDarkmoonDuffleBuff(recipeData)
    return CraftSim.BagBuff(recipeData, CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.DARKMOON_DUFFLE,
        CraftSim.ProfessionStats())
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateProdigysToolboxBuff(recipeData)
    return CraftSim.BagBuff(recipeData, CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.PRODIGYS_TOOLBOX,
        CraftSim.ProfessionStats())
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateJewelersPurseBuff(recipeData)
    return CraftSim.BagBuff(recipeData, CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.JEWELERS_PURSE,
        CraftSim.ProfessionStats())
end

-- Midnight
---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff shatteringEssence
function CraftSim.CRAFT_BUFFS:CreateShatteringEssenceBuffMidnight(recipeData)
    local buffStats = CraftSim.ProfessionStats()

    -- base stats
    buffStats.ingenuity:addValue(5)
    buffStats.multicraft:addValue(5)
    buffStats.resourcefulness:addValue(5)
    --- Shattering Essence Traits "Buff Perks"
    --- not coded into db2 so need to do it manually
    local buffPerkData = {
        {
            nodeID = 107616, -- Responsible Resources
            thresholds = {
                [5] = {
                    resourcefulness = 5,
                },
                [15] = {
                    resourcefulness = 10,
                },
                [25] = {
                    resourcefulness = 20,
                }
            },
        },
        {
            nodeID = 107615, -- Infinite Ingenuity
            thresholds = {
                [5] = {
                    ingenuity = 5,
                },
                [15] = {
                    ingenuity = 10,
                },
                [25] = {
                    ingenuity = 20,
                }
            },
        },
        {
            nodeID = 107614, -- Multicrafting Meticulously
            thresholds = {
                [5] = {
                    multicraft = 5,
                },
                [15] = {
                    multicraft = 10,
                },
                [25] = {
                    multicraft = 20,
                }
            },
        },
        {
            nodeID = 100037, -- Magnificient Multicrafting
            thresholds = {
                [5] = {
                    multicraft = 30,
                },
                [15] = {
                    multicraft = 30,
                },
                [25] = {
                    multicraft = 30,
                },
            },
        },
    }

    for _, buffData in ipairs(buffPerkData) do
        local nodeInfo = C_Traits.GetNodeInfo(recipeData.professionData.configID, buffData.nodeID)
        if nodeInfo then
            local rank = nodeInfo.activeRank - 1
            for threshold, stats in pairs(buffData.thresholds) do
                if rank >= threshold then
                    for stat, amount in pairs(stats) do
                        buffStats[stat]:addValue(amount)
                    end
                end
            end
        end
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE_MIDNIGHT, buffStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff[] phialBuffs
function CraftSim.CRAFT_BUFFS:CreateHaranirPhialOfIngenuityBuffs(recipeData)
    local buffs = {}
    -- phial 1
    local q1Stats = CraftSim.ProfessionStats()
    q1Stats.ingenuity:addValue(38)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.HARANIR_PHIAL_OF_INGENUITY, q1Stats, 1, {
        index = 1,
        value = 38
    }, nil, nil, 241313))

    -- phial 2
    local q2Stats = CraftSim.ProfessionStats()
    q2Stats.ingenuity:addValue(45)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.HARANIR_PHIAL_OF_INGENUITY, q2Stats, 2, {
        index = 1,
        value = 45,
    }, nil, nil, 241312))

    return buffs
end




-- TWW

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff everburningIgnition
function CraftSim.CRAFT_BUFFS:CreateEverburningIgnitionBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    --- EverburningForge Traits
    local nodeIDs = { 99267, 99266, 99265, 99264 }
    local everburningPerPointStats = CraftSim.ProfessionStats()
    everburningPerPointStats.ingenuity.value = 3
    everburningPerPointStats.resourcefulness.value = 3
    everburningPerPointStats.multicraft.value = 3

    for _, nodeID in ipairs(nodeIDs) do
        local nodeData = CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, nodeID,
            CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN, Enum.Profession.Blacksmithing)
        if nodeData then
            buffStats:add(nodeData.professionStats)

            if nodeID == 99267 then
                if nodeData.rank > 0 then
                    buffStats.ingenuity:addValue(15)
                    buffStats.resourcefulness:addValue(15)
                    buffStats.multicraft:addValue(15)
                end
                
                for i = 1, nodeData.rank, 1 do
                    buffStats:add(everburningPerPointStats)
                end
            end
        end
    end

    if CraftSim.UTIL:CheckIfBagIsEquipped(CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.IGNITION_SATCHEL) then
        buffStats.ingenuity:addValue(20)
        buffStats.resourcefulness:addValue(20)
        buffStats.multicraft:addValue(20)
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.EVERBURNING_IGNITION, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateWeaversTutelageBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()

    buffStats.craftingspeed:SetValueByPercent(0.15)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.WEAVERS_TUTELAGE, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateWeaversProdigyBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()

    buffStats.craftingspeed:SetValueByPercent(0.30)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.WEAVERS_PRODIGY, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateInventorsGuileBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()

    buffStats.multicraft:addValue(150)
    buffStats.ingenuity:addValue(150)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.INVENTORS_GUILE, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff potionSpillOverBuff
function CraftSim.CRAFT_BUFFS:CreatePotionSpillOverBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    local potionBulkProductionNodeID = 99040
    local nodeData = CraftSim.SPECIALIZATION_DATA:GetStaticNodeData(recipeData, potionBulkProductionNodeID, 10,
        Enum.Profession.Alchemy)
    local isDouble = nodeData and nodeData.rank >= 25

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
    local isDouble = nodeData and nodeData.rank >= 25

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
    local isDouble = nodeData and nodeData.rank >= 25

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

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateImprovedCiphersBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.craftingspeed:SetValueByPercent(0.02)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.IMPROVED_CIPHERS, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateImprovedMillingBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.craftingspeed:SetValueByPercent(0.02)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.IMPROVED_MILLING, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateImprovedInksBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.craftingspeed:SetValueByPercent(0.02)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.IMPROVED_INKS, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateImprovedContractsBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.craftingspeed:SetValueByPercent(0.02)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.IMPROVED_CONTRACTS, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateImprovedMissivesBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.craftingspeed:SetValueByPercent(0.02)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.IMPROVED_MISSIVES, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateImprovedVantusBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.craftingspeed:SetValueByPercent(0.02)

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.IMPROVED_VANTUS, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff buff
function CraftSim.CRAFT_BUFFS:CreateHideshapersWorkbagBuff(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    buffStats.resourcefulness:addValue(90)

    return CraftSim.BagBuff(recipeData, CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.HIDESHAPERS_WORKBAG, buffStats)
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Buff shatteringEssence
function CraftSim.CRAFT_BUFFS:CreateShatteringEssenceBuffTWW(recipeData)
    local buffStats = CraftSim.ProfessionStats()
    --- Shattering Essence Traits "Buff Perks"
    --- not coded into db2 so need to do it manually
    local buffPerkData = {
        {
            nodeID = 100040, -- Supplementary Shattering
            thresholds = {
                [0] = {
                    resourcefulness = 15,
                    ingenuity = 15,
                    multicraft = 15,
                },
                [5] = {
                    resourcefulness = 15,
                    ingenuity = 15,
                    multicraft = 15,
                },
                [25] = {
                    resourcefulness = 15,
                    ingenuity = 15,
                    multicraft = 15,
                },
                [30] = {
                    resourcefulness = 30,
                    ingenuity = 30,
                    multicraft = 30,
                },
            },
        },
        {
            nodeID = 100039, -- Resourceful Residue
            thresholds = {
                [5] = {
                    resourcefulness = 30,
                },
                [15] = {
                    resourcefulness = 30,
                },
                [25] = {
                    resourcefulness = 30,
                },
            },
        },
        {
            nodeID = 100038, -- Immaculate Ingenuity
            thresholds = {
                [5] = {
                    ingenuity = 30,
                },
                [15] = {
                    ingenuity = 30,
                },
                [25] = {
                    ingenuity = 30,
                },
            },
        },
        {
            nodeID = 100037, -- Magnificient Multicrafting
            thresholds = {
                [5] = {
                    multicraft = 30,
                },
                [15] = {
                    multicraft = 30,
                },
                [25] = {
                    multicraft = 30,
                },
            },
        },
    }

    for _, buffData in ipairs(buffPerkData) do
        local nodeInfo = C_Traits.GetNodeInfo(recipeData.professionData.configID, buffData.nodeID)
        if nodeInfo then
            local rank = nodeInfo.activeRank - 1
            for threshold, stats in pairs(buffData.thresholds) do
                if rank >= threshold then
                    for stat, amount in pairs(stats) do
                        buffStats[stat]:addValue(amount)
                    end
                end
            end
        end
    end

    if CraftSim.UTIL:CheckIfBagIsEquipped(CraftSim.CONST.ITEM_IDS.PROFESSION_BAGS.MAGICALLY_INFINITE_MESSENGER) then
        buffStats.ingenuity:addValue(20)
        buffStats.resourcefulness:addValue(20)
        buffStats.multicraft:addValue(20)
    end

    return CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE, buffStats)
end

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.Buff[] phialBuffs
function CraftSim.CRAFT_BUFFS:CreatePhialOfBountifulSeasonsBuffs(recipeData)
    local buffs = {}
    -- phial 1
    local q1Stats = CraftSim.ProfessionStats()
    q1Stats.resourcefulness:addValue(84)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS, q1Stats, 1, {
        index = 2,
        value = 84
    }, nil, nil, 212314))

    -- phial 2
    local q2Stats = CraftSim.ProfessionStats()
    q2Stats.resourcefulness:addValue(106)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS, q2Stats, 2, {
        index = 2,
        value = 106,
    }, nil, nil, 212315))

    -- phial 3
    local q3Stats = CraftSim.ProfessionStats()
    q3Stats.resourcefulness:addValue(135)

    table.insert(buffs, CraftSim.Buff(recipeData, CraftSim.CONST.BUFF_IDS.PHIAL_OF_BOUNTIFUL_SEASONS, q3Stats, 3, {
        index = 2,
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

function CraftSim.CRAFT_BUFFS:UNIT_AURA(unitTarget, info)
    if InCombatLockdown() then return end
    if unitTarget ~= "player" then return end

    local haveActiveBuffsChanged = false

    if info.isFullUpdate then
        -- Full update on login/reload: scan all tracked buffs directly
        local newActiveIds = {}
        for _, spellId in pairs(CraftSim.CONST.BUFF_IDS) do
            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellId)
            if auraData then
                tinsert(newActiveIds, auraData.auraInstanceID)
            end
        end

        -- Check if the active set actually changed
        if #newActiveIds ~= #self.activeBuffInstanceIds then
            haveActiveBuffsChanged = true
        else
            for _, id in ipairs(newActiveIds) do
                if not tContains(self.activeBuffInstanceIds, id) then
                    haveActiveBuffsChanged = true
                    break
                end
            end
        end

        self.activeBuffInstanceIds = newActiveIds

        if haveActiveBuffsChanged and CraftSim.INIT.currentRecipeID then
            CraftSim.INIT:TriggerModuleUpdate()
        end
        return
    end

	if info.addedAuras then
		for _, v in pairs(info.addedAuras) do
            local isTrackedBuff = (not issecretvalue or not issecretvalue(v.spellId)) and buffIdSet[tonumber(v.spellId)]
            local isAlreadyActive = tContains(self.activeBuffInstanceIds, v.auraInstanceID)
            if isTrackedBuff and not isAlreadyActive then
                tinsert(self.activeBuffInstanceIds, v.auraInstanceID)
                haveActiveBuffsChanged = true
            end
		end
    end

    -- Add buffs that are already active but did not exist in the table before (on login etc.)
    if info.updatedAuraInstanceIDs then
		for _, v in pairs(info.updatedAuraInstanceIDs) do
			local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unitTarget, v)
            if aura then
                local isTrackedBuff = (not issecretvalue or not issecretvalue(aura.spellId)) and buffIdSet[tonumber(aura.spellId)]
                local isAlreadyActive = tContains(self.activeBuffInstanceIds, aura.auraInstanceID)
                if isTrackedBuff and not isAlreadyActive then
                    tinsert(self.activeBuffInstanceIds, aura.auraInstanceID)
                    haveActiveBuffsChanged = true
                end
            end
		end
	end

    -- Remove buffs that are no longer active
    if info.removedAuraInstanceIDs then
		for _, v in pairs(info.removedAuraInstanceIDs) do
            tremove(self.activeBuffInstanceIds, tIndexOf(self.activeBuffInstanceIds, v))
            haveActiveBuffsChanged = true
        end
    end

    -- Trigger module update if the number of active buffs has changed and a recipe is selected
    if haveActiveBuffsChanged and CraftSim.INIT.currentRecipeID then
        CraftSim.INIT:TriggerModuleUpdate()
    end
end
