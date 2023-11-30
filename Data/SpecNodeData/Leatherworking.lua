CraftSimAddonName, CraftSim = ...

CraftSim.LEATHERWORKING_DATA = {}

CraftSim.LEATHERWORKING_DATA.NODE_IDS = {
    LEATHERWORKING_DISCIPLINE = 31184,
    SHEAR_MASTERY_OF_LEATHER = 31183,
    AWL_INSPIRING_WORKS = 31182,
    BONDING_AND_STITCHING = 31181,
    CURING_AND_TANNING = 31180,
    LEATHER_ARMOR_CRAFTING = 28546,
    SHAPED_LEATHER_ARMOR = 28545,
    EMBROIDERED_LEATHER_ARMOR = 28540,
    CHESTPIECES = 28544,
    HELMS = 28543,
    SHOULDERPADS = 28542,
    WRISTWRAPS = 28541,
    LEGGUARDS = 28539,
    GLOVES = 28538,
    LEATHER_BELTS = 28537,
    LEATHER_BOOTS = 28536,
    MAIL_ARMOR_CRAFTING = 28438,
    LARGE_MAIL = 28437,
    INTRICATE_MAIL = 28432,
    MAIL_SHIRTS = 28436,
    MAIL_HELMS = 28434,
    SHOULDERGUARDS = 28429,
    BRACES = 28433,
    GREAVES = 28435,
    GAUNTLETS = 28431,
    MAIL_BELTS = 28428,
    MAIL_BOOTS = 28430,
    PRIMORDIAL_LEATHERWORKING = 31146,
    ELEMENTAL_MASTERY = 31145,
    BESTIAL_PRIMACY = 31144,
    DECAYING_GRASPS = 31143
}

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

function CraftSim.LEATHERWORKING_DATA:GetData()
    return {
        -- LEATHERWORKING DISCIPLINE
        LEATHERWORKING_DISCIPLINE_1 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            equalsSkill = true,
	    idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        LEATHERWORKING_DISCIPLINE_2 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 0,
            skill = 5,
	    idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        LEATHERWORKING_DISCIPLINE_3 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 10,
            skill = 5,
	    idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        LEATHERWORKING_DISCIPLINE_4 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 20,
            skill = 10,
	    idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        LEATHERWORKING_DISCIPLINE_5 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 30,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.20,
	    idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_1 = {
            nodeID = 31183,
            equalsResourcefulness = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_2 = {
            nodeID = 31183,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_3 = {
            nodeID = 31183,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_4 = {
            nodeID = 31183,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_5 = {
            nodeID = 31183,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_6 = {
            nodeID = 31183,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_7 = {
            nodeID = 31183,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHEAR_MASTERY_OF_LEATHER_8 = {
            nodeID = 31183,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_1 = {
            nodeID = 31182,
            equalsInspiration = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_2 = {
            nodeID = 31182,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_3 = {
            nodeID = 31182,
            threshold = 5,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_4 = {
            nodeID = 31182,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_5 = {
            nodeID = 31182,
            threshold = 15,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_6 = {
            nodeID = 31182,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_7 = {
            nodeID = 31182,
            threshold = 25,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        AWL_INSPIRING_WORKS_8 = {
            nodeID = 31182,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BONDING_AND_STITCHING_1 = {
            nodeID = 31181,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ALCHEMY,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.SKINNING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BLACKSMITHING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.HERBALISM,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHERWORKING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.JEWELCRAFTING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ENGINEERING,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
        },
        BONDING_AND_STITCHING_2 = {
            nodeID = 31181,
            threshold = 0,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS,
                },
            },
        },
        BONDING_AND_STITCHING_3 = {
            nodeID = 31181,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ALCHEMY,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.SKINNING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BLACKSMITHING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.HERBALISM,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHERWORKING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.JEWELCRAFTING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ENGINEERING,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
        },
        BONDING_AND_STITCHING_4 = {
            nodeID = 31181,
            threshold = 10,
            multicraft = 40,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS,
                },
            },
        },
        BONDING_AND_STITCHING_5 = {
            nodeID = 31181,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ALCHEMY,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.SKINNING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BLACKSMITHING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.HERBALISM,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHERWORKING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.JEWELCRAFTING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ENGINEERING,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
        },
        BONDING_AND_STITCHING_6 = {
            nodeID = 31181,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS,
                },
            },
        },
        CURING_AND_TANNING_1 = {
            nodeID = 31180,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL,
                },
		        [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER_REAGENTS,
                },
		        [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.OPTIONAL_REAGENTS,
                },
            },
        },
        CURING_AND_TANNING_2 = {
            nodeID = 31180,
            threshold = 0,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL,
                },
            },
        },
        CURING_AND_TANNING_3 = {
            nodeID = 31180,
            threshold = 5,
            inspiration =10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL,
                },
		        [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER_REAGENTS,
                },
		        [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.OPTIONAL_REAGENTS,
                },
            },
        },
        CURING_AND_TANNING_4 = {
            nodeID = 31180,
            threshold = 10,
            multicraft = 40,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL,
                },
            },
        },
        CURING_AND_TANNING_5 = {
            nodeID = 31180,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL,
                },
		        [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER_REAGENTS,
                },
		        [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.OPTIONAL_REAGENTS,
                },
            },
        },
        CURING_AND_TANNING_6 = {
            nodeID = 31180,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL,
                },
            },
        },
        -- Primordial Leatherworking 
        PRIMORDIAL_LEATHERWORKING_1 = { -- mapped
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        PRIMORDIAL_LEATHERWORKING_2 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 0,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        PRIMORDIAL_LEATHERWORKING_3 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 5,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        PRIMORDIAL_LEATHERWORKING_4 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 15,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        PRIMORDIAL_LEATHERWORKING_5 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 25,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        PRIMORDIAL_LEATHERWORKING_6 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 35,
            craftingspeedBonusFactor = 0.15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        ELEMENTAL_MASTERY_1 = {
            nodeID = 31145,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
            },
        },
        ELEMENTAL_MASTERY_2 = {
            nodeID = 31145,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
            },
        },
        ELEMENTAL_MASTERY_3 = {
            nodeID = 31145,
            threshold = 10,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
            },
        },
        ELEMENTAL_MASTERY_4 = {
            nodeID = 31145,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
            },
        },
        ELEMENTAL_MASTERY_5 = {
            nodeID = 31145,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
		        375161, -- Frosted Armor Kit
            },
        },
        BESTIAL_PRIMACY_1 = {
            nodeID = 31144,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
            exceptionRecipeIDs = {
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
            },
        },
        BESTIAL_PRIMACY_2 = {
            nodeID = 31144,
            threshold = 0,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
            exceptionRecipeIDs = {
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
            },
        },
        BESTIAL_PRIMACY_3 = {
            nodeID = 31144,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
            exceptionRecipeIDs = {
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
            },
        },
        BESTIAL_PRIMACY_4 = {
            nodeID = 31144,
            threshold = 10,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
            exceptionRecipeIDs = {
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
            },
        },
        BESTIAL_PRIMACY_5 = {
            nodeID = 31144,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.BESTIAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.BOWS,
                },
            },
            exceptionRecipeIDs = {
                375180, -- Infurious Scales
                375176, -- Infurious Hide
                375159, -- Fang Adornments
		        375162, -- Fierce Armor Kit
            },
        },
        DECAYING_GRASP_1 = {
            nodeID = 31143,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        DECAYING_GRASP_2 = {
            nodeID = 31143,
            threshold = 0,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        DECAYING_GRASP_3 = {
            nodeID = 31143,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        DECAYING_GRASP_4 = {
            nodeID = 31143,
            threshold = 10,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        DECAYING_GRASP_5 = {
            nodeID = 31143,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DECAYED_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375179, -- Frostbite Scales
                375173, -- Stonecrust Hide
                375160, -- Toxified Armor Patch
		        375199, -- Witherrot Tome
            },
        },
        -- Leather Armor Crafting 
        LEATHER_ARMOR_CRAFTING_1 = { --mapped
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- shaped leather armor
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
                --- embroidered leather armor
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },   
        },
        LEATHER_ARMOR_CRAFTING_2 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 5,
            inspiration = 5,
            exceptionRecipeIDs = {
                --- shaped leather armor
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
                --- embroidered leather armor
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },   
        },
        LEATHER_ARMOR_CRAFTING_3 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 15,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                --- shaped leather armor
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
                --- embroidered leather armor
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },   
        },
        LEATHER_ARMOR_CRAFTING_4 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 25,
            inspiration = 5,
            exceptionRecipeIDs = {
                --- shaped leather armor
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
                --- embroidered leather armor
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },   
        },
        LEATHER_ARMOR_CRAFTING_5 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 30,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.10,
            exceptionRecipeIDs = {
                --- shaped leather armor
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
                --- embroidered leather armor
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },   
        },
        SHAPED_LEATHER_ARMOR_1 = { -- mapped
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- shaped leather armor
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        SHAPED_LEATHER_ARMOR_2 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            threshold = 5,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        SHAPED_LEATHER_ARMOR_3 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            threshold = 15,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        SHAPED_LEATHER_ARMOR_4 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            threshold = 25,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- chest
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        CHESTPIECES_1 = {
            nodeID = 28544,
            equalsSkill = true,
            exceptionRecipeIDs = {
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
            },
        },
        CHESTPIECES_2 = {
            nodeID = 28544,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
            },
        },
        CHESTPIECES_3 = {
            nodeID = 28544,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
            },
        },
        CHESTPIECES_4 = {
            nodeID = 28544,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                375105, -- (Rare) Pioneer's Leather Tunic
                375109, -- (Epic) Life-bound Chestpiece
                375144, -- (Epic Bestial) Allied heartwarming Fur Coat
                375127, -- (Green Bestial) Crimson Combatant's Resilient Chestpiece
            },
        },
        HELMS_1 = {
            nodeID = 28543,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- helms
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
            },
        },
        HELMS_2 = {
            nodeID = 28543,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
            },
        },
        HELMS_3 = {
            nodeID = 28543,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
            },
        },
        HELMS_4 = {
            nodeID = 28543,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395864, -- (Rare) Pioneer's Practiced Cowl
                375112, -- (Epic) Life-bound Cap
                375197, -- (Epic Elemental) Flaring Cowl
                375148, -- (Epic Bestial) Infurious Spirit's Hood
                375126, -- (Green Bestial) Crimson Combatant's Resilient Mask
            },
        },
        SHOULDERPADS_1 = {
            nodeID = 28542,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- shoulder
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
            },
        },
        SHOULDERPADS_2 = {
            nodeID = 28542,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
            },
        },
        SHOULDERPADS_3 = {
            nodeID = 28542,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
            },
        },
        SHOULDERPADS_4 = {
            nodeID = 28542,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395868, -- (Rare) Pioneer's Practiced Shoulderpads
                375114, -- (Epic) Life-bound Shoulderpads
                375129, -- (Green Bestial) Crimson Combatant's Resilient Shoulderpads
            },
        },
        WRISTWRAPS_1 = {
            nodeID = 28541,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- wrist
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        WRISTWRAPS_2 = {
            nodeID = 28541,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        WRISTWRAPS_3 = {
            nodeID = 28541,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        WRISTWRAPS_4 = {
            nodeID = 28541,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                375104, -- (Rare) Pioneer's Leather Wristguards
                375116, -- (Epic) Life-bound Bindings
                375145, -- (Epic Elemental) Old Spirit's Wristwraps
                375132, -- (Green Bestial) Crimson Combatant's Resilient Wristwraps
            },
        },
        EMBROIDERED_LEATHER_ARMOR_1 = { -- mapped
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- embroidered leather armor
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        EMBROIDERED_LEATHER_ARMOR_2 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            threshold = 5,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        EMBROIDERED_LEATHER_ARMOR_3 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            threshold = 15,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        EMBROIDERED_LEATHER_ARMOR_4 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            threshold = 25,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        LEGGUARDS_1 = {
            nodeID = 28539,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- legs
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
            },
        },
        LEGGUARDS_2 = {
            nodeID = 28539,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
            },
        },
        LEGGUARDS_3 = {
            nodeID = 28539,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
            },
        },
        LEGGUARDS_4 = {
            nodeID = 28539,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395867, -- (Rare) Pioneer's Practiced Leggins
                375113, -- (Epic) Life-bound Trousers
                375128, -- (Green Bestial) Crimson Combatant's Resilient Trousers
            },
        },
        GLOVES_1 = {
            nodeID = 28538,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- gloves
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
            },
        },
        GLOVES_2 = {
            nodeID = 28538,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
            },
        },
        GLOVES_3 = {
            nodeID = 28538,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
            },
        },
        GLOVES_4 = {
            nodeID = 28538,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395865, -- (Rare) Pioneer's Practiced Gloves
                375111, -- (Epic) Life-bound Gloves
                375146, -- (Epic Elemental) Snowball Makers
                375130, -- (Green Bestial) Crimson Combatant's Resilient Gloves
            },
        },
        LEATHER_BELTS_1 = {
            nodeID = 28537,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- belts
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
            },
        },
        LEATHER_BELTS_2 = {
            nodeID = 28537,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
            },
        },
        LEATHER_BELTS_3 = {
            nodeID = 28537,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
            },
        },
        LEATHER_BELTS_4 = {
            nodeID = 28537,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395863, -- (Rare) Pioneer's Practiced Belt
                375115, -- (Epic) Life-bound Belt
                375147, -- (Epic Elemental) String of Spiritual Knick-Knacks
                375133, -- (Green Bestial) Crimson Combatant's Resilient Belt
            },
        },
        LEATHER_BOOTS_1 = {
            nodeID = 28536,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- boots
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        LEATHER_BOOTS_2 = {
            nodeID = 28536,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        LEATHER_BOOTS_3 = {
            nodeID = 28536,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        LEATHER_BOOTS_4 = {
            nodeID = 28536,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                375103, -- (Rare) Pioneer's Leather Boots
                375110, -- (Epic) Life-bound Boots
                375149, -- (Epic Bestial) Infurious Footwraps of Indemnity
                375131, -- (Green Bestial) Crimson Combatant's Resilient Boots
                375142, -- (Epic Decayed) Slimy Expulsion Boots
                375143, -- (Epic Decayed) Toxic Thorn Footwraps
            },
        },
        -- Mail Armor Crafting
        MAIL_ARMOR_CRAFTING_1 = { --mapped
            childNodeIDs = {"LARGE_MAIL_1", "INTRICATE_MAIL_1"},
            nodeID = 28438,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- large mail
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
                --- intricate mail
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_ARMOR_CRAFTING_2 = {
            childNodeIDs = {"LARGE_MAIL_1", "INTRICATE_MAIL_1"},
            nodeID = 28438,
            threshold = 5,
            inspiration = 5,
            exceptionRecipeIDs = {
                --- large mail
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
                --- intricate mail
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_ARMOR_CRAFTING_3 = {
            childNodeIDs = {"LARGE_MAIL_1", "INTRICATE_MAIL_1"},
            nodeID = 28438,
            threshold = 15,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                --- large mail
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
                --- intricate mail
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_ARMOR_CRAFTING_4 = {
            childNodeIDs = {"LARGE_MAIL_1", "INTRICATE_MAIL_1"},
            nodeID = 28438,
            threshold = 25,
            inspiration = 5,
            exceptionRecipeIDs = {
                --- large mail
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
                --- intricate mail
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_ARMOR_CRAFTING_5 = {
            childNodeIDs = {"LARGE_MAIL_1", "INTRICATE_MAIL_1"},
            nodeID = 28438,
            threshold = 30,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.10,
            exceptionRecipeIDs = {
                --- large mail
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
                --- intricate mail
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        LARGE_MAIL_1 = { -- mapped
            childNodeIDs = {"MAIL_SHIRTS_1", "MAIL_HELMS_1", "SHOULDERGUARDS_1", "BRACERS_1"},
            nodeID = 28437,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- large mail
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        LARGE_MAIL_2 = {
            childNodeIDs = {"MAIL_SHIRTS_1", "MAIL_HELMS_1", "SHOULDERGUARDS_1", "BRACERS_1"},
            nodeID = 28437,
            threshold = 5,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        LARGE_MAIL_3 = {
            childNodeIDs = {"MAIL_SHIRTS_1", "MAIL_HELMS_1", "SHOULDERGUARDS_1", "BRACERS_1"},
            nodeID = 28437,
            threshold = 15,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        LARGE_MAIL_4 = {
            childNodeIDs = {"MAIL_SHIRTS_1", "MAIL_HELMS_1", "SHOULDERGUARDS_1", "BRACERS_1"},
            nodeID = 28437,
            threshold = 25,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs  
            },
        },
        MAIL_SHIRTS_1 = {
            nodeID = 28436,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- chest
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
            },
        },
        MAIL_SHIRTS_2 = {
            nodeID = 28436,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
            },
        },
        MAIL_SHIRTS_3 = {
            nodeID = 28436,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
            },
        },
        MAIL_SHIRTS_4 = {
            nodeID = 28436,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                375108, -- (Rare) Trailblazer's Scale Vest
                375117, -- (Epic) Flame-Touched Chainmail
                375135, -- (Green Bestial) Crimson Combatant's Adamant Chainmail
            },
        },
        MAIL_HELMS_1 = {
            nodeID = 28434,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- helms
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
            },
        },
        MAIL_HELMS_2 = {
            nodeID = 28434,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
            },
        },
        MAIL_HELMS_3 = {
            nodeID = 28434,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
            },
        },
        MAIL_HELMS_4 = {
            nodeID = 28434,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395839, -- (Rare) Trailblazer's Toughened Coif
                375120, -- (Epic) Flame-Touched Helmet
                375156, -- (Epic Bestial) Infurious Chainhelm Protector
                375134, -- (Green Bestial) Crimson Combatant's Adamant Cowl
            },
        },
        SHOULDERGUARDS_1 = {
            nodeID = 28429,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- shoulders
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
            },
        },
        SHOULDERGUARDS_2 = {
            nodeID = 28429,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
            },
        },
        SHOULDERGUARDS_3 = {
            nodeID = 28429,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
            },
        },
        SHOULDERGUARDS_4 = {
            nodeID = 28429,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395851, -- (Rare) Trailblazer's Toughened Spikes
                375122, -- (Epic) Flame-Touched Spaulders
                375153, -- (Epic Elemental) Ancestor's Dew Drippers
                375137, -- (Green Bestial) Crimson Combatant's Adamant Epauletters
            },
        },
        BRACERS_1 = {
            nodeID = 28433,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- bracers
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        BRACERS_2 = {
            nodeID = 28433,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        BRACERS_3 = {
            nodeID = 28433,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        BRACERS_4 = {
            nodeID = 28433,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                375107, -- (Rare) Trailblazer's Scale Bracers
                375124, -- (Epic) Flame-Touched Cuffs
                375140, -- (Green Bestial) Crimson Combatant's Adamant Cuffs
            },
        },
        INTRICATE_MAIL_1 = { -- mapped
            childNodeIDs = {"GREAVES_1", "GAUNTLETS_1", "MAIL_BELTS_1", "MAIL_BOOTS_1"},
            nodeID = 28432,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- intricate mail
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        INTRICATE_MAIL_2 = {
            childNodeIDs = {"GREAVES_1", "GAUNTLETS_1", "MAIL_BELTS_1", "MAIL_BOOTS_1"},
            nodeID = 28432,
            threshold = 5,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        INTRICATE_MAIL_3 = {
            childNodeIDs = {"GREAVES_1", "GAUNTLETS_1", "MAIL_BELTS_1", "MAIL_BOOTS_1"},
            nodeID = 28432,
            threshold = 15,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        INTRICATE_MAIL_4 = {
            childNodeIDs = {"GREAVES_1", "GAUNTLETS_1", "MAIL_BELTS_1", "MAIL_BOOTS_1"},
            nodeID = 28432,
            threshold = 25,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        GREAVES_1 = {
            nodeID = 28435,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- greaves
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
            },
        },
        GREAVES_2 = {
            nodeID = 28435,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
            },
        },
        GREAVES_3 = {
            nodeID = 28435,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
            },
        },
        GREAVES_4 = {
            nodeID = 28435,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395847, -- (Rare) Trailblazer's Toughened Legguards
                375121, -- (Epic) Flame-Touched Legguards
                375157, -- (Epic Bestial) Allied Legguards of Sansok Khan
                375136, -- (Green Bestial) Crimson Combatant's Adamant Leggins
            },
        },
        GAUNTLETS_1 = {
            nodeID = 28431,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- gauntlets
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
            },
        },
        GAUNTLETS_2 = {
            nodeID = 28431,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
            },
        },
        GAUNTLETS_3 = {
            nodeID = 28431,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
            },
        },
        GAUNTLETS_4 = {
            nodeID = 28431,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395845, -- (Rare) Trailblazer's Toughened Grips
                375119, -- (Epic) Flame-Touched Handguards
                375154, -- (Epic Elemental) Scale Rein Grips
                375138, -- (Green Bestial) Crimson Combatant's Adamant Gauntlets
            },
        },
        MAIL_BELTS_1 = {
            nodeID = 28428,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- belts
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
            },
        },
        MAIL_BELTS_2 = {
            nodeID = 28428,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
            },
        },
        MAIL_BELTS_3 = {
            nodeID = 28428,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
            },
        },
        MAIL_BELTS_4 = {
            nodeID = 28428,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                395844, -- (Rare) Trailblazer's Toughened Chainbelt
                375123, -- (Epic) Flame-Touched Chain
                375152, -- (Epic Elemental) Wind Spirit's Lasso
                375141, -- (Green Bestial) Crimson Combatant's Adamant Gridle
            },
        },
        MAIL_BOOTS_1 = {
            nodeID = 28430,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- boots
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_BOOTS_2 = {
            nodeID = 28430,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_BOOTS_3 = {
            nodeID = 28430,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
        MAIL_BOOTS_4 = {
            nodeID = 28430,
            threshold = 15,
            skill = 10,
            exceptionRecipeIDs = {
                375106, -- (Rare) Trailblazer's Scale Boots
                375118, -- (Epic) Flame-Touched Treads
                375155, -- (Epic Bestial) Infurious Boots of Reprieve
                375139, -- (Green Bestial) Crimson Combatant's Adamant Treads
                375151, -- (Epic Decayed) Acidic Hailstone Treads
                375150, -- (Epic Decayed) Venom-Steeped Stompers
            },
        },
    }
end
