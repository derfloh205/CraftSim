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

function CraftSim.LEATHERWORKING_DATA:GetData()
    return {
        -- LEATHERWORKING DISCIPLINE
        LEATHERWORKING_DISCIPLINE_1 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            equalsSkill = true,
        },
        LEATHERWORKING_DISCIPLINE_2 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 0,
            skill = 5,
        },
        LEATHERWORKING_DISCIPLINE_3 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 10,
            skill = 5,
        },
        LEATHERWORKING_DISCIPLINE_4 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 20,
            skill = 10,
        },
        LEATHERWORKING_DISCIPLINE_4 = {
            childNodeIDs = {"SHEAR_MASTERY_OF_LEATHER_1", "AWL_INSPIRING_WORKS_1", "BONDING_AND_STITCHING_1", "CURING_AND_TANNING_1"},
            nodeID = 31184,
            threshold = 30,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.20,
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
                }
            },
        },
        BONDING_AND_STITCHING_2 = {
            nodeID = 31181,
            threshold = 0,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS,
                }
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
                }
            },
        },
        BONDING_AND_STITCHING_4 = {
            nodeID = 31181,
            threshold = 10,
            multicraft = 40,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS,
                }
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
                }
            },
        },
        BONDING_AND_STITCHING_6 = {
            nodeID = 31181,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.DRUMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.DRUMS,
                }
            },
        },
        CURING_AND_TANNING_1 = {
            nodeID = 31180,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.REAGENTS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMOR_KITS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.OPTIONAL_REAGENTS,
                }
            },
        },
        CURING_AND_TANNING_2 = {
            nodeID = 31180,
            threshold = 0,
            multicraft = 20,
            idMapping = {
               [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMOR_KITS,
                },
            },
        },
        CURING_AND_TANNING_3 = {
            nodeID = 31180,
            threshold = 5,
            inspiration =10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.REAGENTS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMOR_KITS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.OPTIONAL_REAGENTS,
                }
            },
        },
        CURING_AND_TANNING_4 = {
            nodeID = 31180,
            threshold = 10,
            multicraft = 40,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMOR_KITS,
                }
            },
        },
        CURING_AND_TANNING_5 = {
            nodeID = 31180,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.REAGENTS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMOR_KITS,
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.OPTIONAL_REAGENTS,
                }
            },
        },
        CURING_AND_TANNING_6 = {
            nodeID = 31180,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ARMOR_KITS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.ARMOR_KITS,
                }
            },
        },
        -- Primordial Leatherworking
        PRIMORDIAL_LEATHERWORKING_1 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            equalsSkill = true,
        },
        PRIMORDIAL_LEATHERWORKING_2 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 0,
            inspiration = 5,
        },
        PRIMORDIAL_LEATHERWORKING_3 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 5,
            resourcefulness = 5,
        },
        PRIMORDIAL_LEATHERWORKING_4 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 15,
            inspiration = 5,
        },
        PRIMORDIAL_LEATHERWORKING_5 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 25,
            resourcefulness = 5,
        },
        PRIMORDIAL_LEATHERWORKING_6 = {
            childNodeIDs = {"ELEMENTAL_MASTERY_1", "BESTIAL_PRIMACY_1", "DECAYING_GRASP_1"},
            nodeID = 31146,
            threshold = 35,
            craftingspeedBonusFactor = 0.15,
        },
        ELEMENTAL_MASTERY_1 = {
            nodeID = 31145,
            equalSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.LEATHERWORKING.ELEMENTAL_PATTERNS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.LEATHERWORKING.LEATHER,
                },
            },
            exceptionRecipeIDs = {
                375178, -- Earthshine Scales
                375174, -- Mireslush Hide
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
            },
        },
        BESTIAL_PRIMACY_1 = {
            nodeID = 31144,
            equalSkill = true,
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
            },
        },
        DECAYING_GRASP_1 = {
            nodeID = 31143,
            equalSkill = true,
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
            },
        },
        -- Leather Armor Crafting
        LEATHER_ARMOR_CRAFTING_1 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            equalsSkill = true,
        },
        LEATHER_ARMOR_CRAFTING_2 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 5,
            inspiration = 5,
        },
        LEATHER_ARMOR_CRAFTING_3 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 15,
            resourcefulness = 5,
        },
        LEATHER_ARMOR_CRAFTING_4 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 25,
            inspiration = 5,
        },
        LEATHER_ARMOR_CRAFTING_5 = {
            childNodeIDs = {"SHAPED_LEATHER_ARMOR_1", "EMBROIDERED_LEATHER_ARMOR_1"},
            nodeID = 28546,
            threshold = 30,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.10,
        },
        SHAPED_LEATHER_ARMOR_1 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            equalsSkill = true,
        },
        SHAPED_LEATHER_ARMOR_2 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            threshold = 5,
            inspiration = 10,
        },
        SHAPED_LEATHER_ARMOR_3 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            threshold = 15,
            resourcefulness = 10,
        },
        SHAPED_LEATHER_ARMOR_4 = {
            childNodeIDs = {"CHESTPIECES_1", "HELMS_1", "SHOULDERPADS_1", "WRISTWRAPS_1"},
            nodeID = 28545,
            threshold = 25,
            inspiration = 10,
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
            equalSkill = true,
            exceptionRecipeIDs = {
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
            equalSkill = true,
            exceptionRecipeIDs = {
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
            equalSkill = true,
            exceptionRecipeIDs = {
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
        EMBROIDERED_LEATHER_ARMOR_1 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            equalsSkill = true,
        },
        EMBROIDERED_LEATHER_ARMOR_2 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            threshold = 5,
            inspiration = 10,
        },
        EMBROIDERED_LEATHER_ARMOR_3 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            threshold = 15,
            resourcefulness = 10,
        },
        EMBROIDERED_LEATHER_ARMOR_4 = {
            childNodeIDs = {"LEGGUARDS_1", "GLOVES_1", "LEATHER_BELTS_1", "LEATHER_BOOTS_1"},
            nodeID = 28540,
            threshold = 25,
            inspiration = 10,
        },
        LEGGUARDS_1 = {
            nodeID = 28539,
            equalSkill = true,
            exceptionRecipeIDs = {
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
            equalSkill = true,
            exceptionRecipeIDs = {
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
            equalSkill = true,
            exceptionRecipeIDs = {
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
            equalSkill = true,
            exceptionRecipeIDs = {
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
