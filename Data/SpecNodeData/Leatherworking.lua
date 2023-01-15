addonName, CraftSim = ...

CraftSim.LEATHERWORKING_DATA = {}

CraftSim.LEATHERWORKING_DATA.NODES = function()
    return {
        -- Leatherworking Discipline
        {
            name = "Leatherworking Discipline",
            nodeID = 31184
        },
        {
            name = "Shear Mastery of Leather",
            nodeID = 31183
        },
        {
            name = "Awl Inspiring Works",
            nodeID = 31182
        },
        {
            name = "Bonding and Stitching",
            nodeID = 31181
        },
        {
            name = "Curing and Tanning",
            nodeID = 31180
        },
        -- Leather Armor Crafting
        {
            name = "Leather Armor Crafting",
            nodeID = 28546
        },
        {
            name = "Shaped Leather Armor",
            nodeID = 28545
        },
        {
            name = "Embroidered Leather Armor",
            nodeID = 28540
        },
        {
            name = "Chestpieces",
            nodeID = 28544
        },
        {
            name = "Helms",
            nodeID = 28543
        },
        {
            name = "Shoulderpads",
            nodeID = 28542
        },
        {
            name = "Wristwraps",
            nodeID = 28541
        },
        {
            name = "Legguards",
            nodeID = 28539
        },
        {
            name = "Gloves",
            nodeID = 28538
        },
        {
            name = "Belts",
            nodeID = 28537
        },
        {
            name = "Boots",
            nodeID = 28536
        },
        -- Mail Armor Crafting
        {
            name = "Mail Armor Crafting",
            nodeID = 28438
        },
        {
            name = "Large Mail",
            nodeID = 28437
        },
        {
            name = "Intricate Mail",
            nodeID = 28432
        },
        {
            name = "Mail Shirts",
            nodeID = 28436
        },
        {
            name = "Mail Helms",
            nodeID = 28434
        },
        {
            name = "Shoulderguards",
            nodeID = 28429
        },
        {
            name = "Bracers",
            nodeID = 28433
        },
        {
            name = "Greaves",
            nodeID = 28435
        },
        {
            name = "Gauntlets",
            nodeID = 28431
        },
        {
            name = "Belts",
            nodeID = 28428
        },
        {
            name = "Boots",
            nodeID = 28430
        },
        -- Primordial Leatherworking
        {
            name = "Primordial Leatherworking",
            nodeID = 31146
        },
        {
            name = "Elemental Mastery",
            nodeID = 31145
        },
        {
            name = "Bestial Primacy",
            nodeID = 31144
        },
        {
            name = "Decaying Grasp",
            nodeID = 31143
        }
    }
end

-- Helpers for quick look/access
-- resourcefulnessExtraItemsFactor = 0.05,
-- inspirationBonusSkillFactor = 0.05,
-- craftingspeedBonusFactor = 0.15,
-- multicraftExtraItemsFactor = 0.50,
-- skill = 3,
-- inspiration = 10,
-- resourcefulness = 10,
-- multicraft = 20,
-- equalsResourcefulness = true,
-- equalsInspiration = true,
-- equalsSkill = true,

function CraftSim.LEATHERWORKING_DATA:GetData()
    return {
        SHEAR_MASTERY_1 = {
            nodeID = 31183,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_2 = {
            nodeID = 31183,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_3 = {
            nodeID = 31183,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_4 = {
            nodeID = 31183,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BONDING_AND_STITCHING = {
            nodeID = 31181,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS
                }
            },
        },
        CURING_AND_TANNING = {
            nodeID = 31180,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMORKITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMORKITS
                }
            },
        }
    }
end
