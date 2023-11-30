CraftSimAddonName, CraftSim = ...

CraftSim.TAILORING_DATA = {}

CraftSim.TAILORING_DATA.NODE_IDS = {
    TAILORING_MASTERY = 40008,
    CLOTH_COLLECTION = 40007,
    SPARING_SEWING = 40006,
    SHREWD_STITCHERY = 40005,
    TEXTILES = 40038,
    SPINNING = 40037,
    WEAVING = 40036,
    EMBROIDERY = 40035,
    DRACONIC_NEEDLEWORK = 40074,
    AZUREWEAVE_TAILORING = 40073,
    AZUREWEAVING = 40072,
    CRONOCLOTH_TAILORING = 40071,
    TIMEWEAVING = 40070,
    GARMENTCRAFTING = 40226,
    OUTERWEAR = 40222,
    GLOVES = 40221,
    FOOTWEAR = 40220,
    HATS = 40219,
    CLOAKS = 40218,
    OUTFITS = 40225,
    ROBES = 40224,
    LEGGINGS = 40223,
    EMBELLISHMENTS = 40217,
    MANTLES = 40216,
    ARMBANDS = 40215,
    BELTS = 40214
}

CraftSim.TAILORING_DATA.NODES = function()
    return {
        -- Tailoring Mastery
        {
            name = "Tailoring Mastery",
            nodeID = 40008
        },
        {
            name = "Cloth Collection",
            nodeID = 40007
        },
        {
            name = "Sparing Sewing",
            nodeID = 40006
        },
        {
            name = "Shrewd Stitchery",
            nodeID = 40005
        },
        -- Textiles
        {
            name = "Textiles",
            nodeID = 40038
        },
        {
            name = "Spinning",
            nodeID = 40037
        },
        {
            name = "Weaving",
            nodeID = 40036
        },
        {
            name = "Embroidery",
            nodeID = 40035
        },
        -- Draconic Needlework
        {
            name = "Draconic Needlework",
            nodeID = 40074
        },
        {
            name = "Azureweave Tailoring",
            nodeID = 40073
        },
        {
            name = "Azureweaving",
            nodeID = 40072
        },
        {
            name = "Chronocloth Tailoring",
            nodeID = 40071
        },
        {
            name = "Timeweaving",
            nodeID = 40070
        },
        -- Garmentcrafting
        {
            name = "Garmentcrafting",
            nodeID = 40226
        },
        {
            name = "Outerwear",
            nodeID = 40222
        },
        {
            name = "Gloves",
            nodeID = 40221
        },
        {
            name = "Footwear",
            nodeID = 40220
        },
        {
            name = "Hats",
            nodeID = 40219
        },
        {
            name = "Cloaks",
            nodeID = 40218
        },
        {
            name = "Outfits",
            nodeID = 40225
        },
        {
            name = "Robes",
            nodeID = 40224
        },
        {
            name = "Leggings",
            nodeID = 40223
        },
        {
            name = "Embellishments",
            nodeID = 40217
        },
        {
            name = "Mantles",
            nodeID = 40216
        },
        {
            name = "Armbands",
            nodeID = 40215
        },
        {
            name = "Belts",
            nodeID = 40214
        },
    }
end

function CraftSim.TAILORING_DATA:GetData()
    return {
        TAILORING_MASTERY_1 = { -- all mapped
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
            nodeID = 40008,
            equalsSkill = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TAILORING_MASTERY_2 = {
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
            nodeID = 40008,
            threshold = 0,
            skill = 3,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TAILORING_MASTERY_3 = {
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
            nodeID = 40008,
            threshold = 5,
            skill = 2,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TAILORING_MASTERY_4 = {
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
            nodeID = 40008,
            threshold = 15,
            skill = 3,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TAILORING_MASTERY_5 = {
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
            nodeID = 40008,
            threshold = 25,
            skill = 2,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TAILORING_MASTERY_6 = {
            childNodeIDs = {"CLOTH_COLLECTION_1", "SPARING_SEWING_1", "SHREWD_STITCHERY_1", },
            nodeID = 40008,
            threshold = 30,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        CLOTH_COLLECTION_1 = {
            nodeID = 40007,
        },
        SPARING_SEWING_1 = {
            nodeID = 40006,
            equalsResourcefulness = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_2 = {
            nodeID = 40006,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_3 = {
            nodeID = 40006,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_4 = {
            nodeID = 40006,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_5 = {
            nodeID = 40006,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_6 = {
            nodeID = 40006,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_7 = {
            nodeID = 40006,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SPARING_SEWING_8 = {
            nodeID = 40006,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_1 = {
            nodeID = 40005,
            equalsInspiration = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_2 = {
            nodeID = 40005,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_3 = {
            nodeID = 40005,
            threshold = 5,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_4 = {
            nodeID = 40005,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_5 = {
            nodeID = 40005,
            threshold = 15,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_6 = {
            nodeID = 40005,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_7 = {
            nodeID = 40005,
            threshold = 25,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SHREWD_STITCHERY_8 = {
            nodeID = 40005,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        TEXTILES_1 = { -- spinning mapped, waeving mapped, embroidery mapped 
            childNodeIDs = {"SPINNING_1", "WEAVING_1", "EMBROIDERY_1", },
            nodeID = 40038,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        TEXTILES_2 = {
            childNodeIDs = {"SPINNING_1", "WEAVING_1", "EMBROIDERY_1", },
            nodeID = 40038,
            threshold = 0,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        TEXTILES_3 = {
            childNodeIDs = {"SPINNING_1", "WEAVING_1", "EMBROIDERY_1", },
            nodeID = 40038,
            threshold = 10,
            craftingspeed = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        TEXTILES_4 = {
            childNodeIDs = {"SPINNING_1", "WEAVING_1", "EMBROIDERY_1", },
            nodeID = 40038,
            threshold = 20,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        SPINNING_1 = {
            nodeID = 40037,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                }
            },
        },
        SPINNING_2 = {
            nodeID = 40037,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                }
            },
        },
        SPINNING_3 = {
            nodeID = 40037,
            threshold = 10,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                }
            },
        },
        SPINNING_4 = {
            nodeID = 40037,
            threshold = 15,
            craftingspeed = 15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                }
            },
        },
        SPINNING_5 = {
            nodeID = 40037,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                }
            },
        },
        SPINNING_6 = {
            nodeID = 40037,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.UNRAVELLING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.UNRAVELLING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.SPELLTHREAD] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.SPELLTHREAD
                }
            },
        },
        WEAVING_1 = {
            nodeID = 40036,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                }
            },
        },
        WEAVING_2 = {
            nodeID = 40036,
            threshold = 0,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                }
            },
        },
        WEAVING_3 = {
            nodeID = 40036,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                }
            },
        },
        WEAVING_4 = {
            nodeID = 40036,
            threshold = 10,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                }
            },
        },
        WEAVING_5 = {
            nodeID = 40036,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                }
            },
        },
        WEAVING_6 = {
            nodeID = 40036,
            threshold = 20,
            multicraft = 40,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CLOTH_BOLTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.CLOTH_BOLTS
                }
            },
        },
        EMBROIDERY_1 = {
            nodeID = 40035,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        EMBROIDERY_2 = {
            nodeID = 40035,
            threshold = 0,
            resourcefulness = 15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        EMBROIDERY_3 = {
            nodeID = 40035,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        EMBROIDERY_4 = {
            nodeID = 40035,
            threshold = 10,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        EMBROIDERY_5 = {
            nodeID = 40035,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        EMBROIDERY_6 = {
            nodeID = 40035,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        EMBROIDERY_7 = {
            nodeID = 40035,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.FINISHING_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.FINISHING_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.BAGS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BAG,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.REAGENT_BAG
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.ASSORTED_EMBROIDERY] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.BANDAGES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.TOYS_AND_BANNERS
                }
            },
        },
        DRACONIC_NEEDLEWORK_1 = { -- azure mapped, chrono mapped
            childNodeIDs = {"AZUREWEAVE_TAILORING_1", "CHRONOCLOTH_TAILORING_1"},
            nodeID = 40074,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                -- azure
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
                -- chrono
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        DRACONIC_NEEDLEWORK_2 = {
            childNodeIDs = {"AZUREWEAVE_TAILORING_1", "CHRONOCLOTH_TAILORING_1"},
            nodeID = 40074,
            threshold = 5,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                -- azure
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
                -- chrono
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        DRACONIC_NEEDLEWORK_3 = {
            childNodeIDs = {"AZUREWEAVE_TAILORING_1", "CHRONOCLOTH_TAILORING_1"},
            nodeID = 40074,
            threshold = 10,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                -- azure
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
                -- chrono
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        DRACONIC_NEEDLEWORK_4 = {
            childNodeIDs = {"AZUREWEAVE_TAILORING_1", "CHRONOCLOTH_TAILORING_1"},
            nodeID = 40074,
            threshold = 20,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                -- azure
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
                -- chrono
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        DRACONIC_NEEDLEWORK_5 = {
            childNodeIDs = {"AZUREWEAVE_TAILORING_1", "CHRONOCLOTH_TAILORING_1"},
            nodeID = 40074,
            threshold = 25,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                -- azure
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
                -- chrono
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        AZUREWEAVE_TAILORING_1 = { -- azure mapped
            childNodeIDs = {"AZUREWEAVING_1"},
            nodeID = 40073,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
            },
        },
        AZUREWEAVE_TAILORING_2 = {
            childNodeIDs = {"AZUREWEAVING_1"},
            nodeID = 40073,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
            },
        },
        AZUREWEAVE_TAILORING_3 = {
            childNodeIDs = {"AZUREWEAVING_1"},
            nodeID = 40073,
            threshold = 20,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
            },
        },
        AZUREWEAVE_TAILORING_4 = {
            childNodeIDs = {"AZUREWEAVING_1"},
            nodeID = 40073,
            threshold = 25,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.AZUREWEAVE_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
                376541, -- Blue Silken Lining
                376546, -- Dragoncloth Tailoring Vestments
                376539, -- Frozen Spellthread
                376529, -- Azureweave Expedition Pack
                376568, -- Cold Cushion
            },
        },
        AZUREWEAVING_1 = {
            nodeID = 40072,
            equalsSkill = true,
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
            }
        },
        AZUREWEAVING_2 = {
            nodeID = 40072,
            threshold = 5,
            multicraft = 10,
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
            }
        },
        AZUREWEAVING_3 = {
            nodeID = 40072,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
            }
        },
        AZUREWEAVING_4 = {
            nodeID = 40072,
            threshold = 15,
            multicraft = 10,
            exceptionRecipeIDs = {
                376556, -- Azureweave Bolt
            }
        },
        CHRONOCLOTH_TAILORING_1 = { -- time mapped
            childNodeIDs = {"TIMEWEAVING_1"},
            nodeID = 40071,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                -- chrono
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        CHRONOCLOTH_TAILORING_2 = {
            childNodeIDs = {"TIMEWEAVING_1"},
            nodeID = 40071,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        CHRONOCLOTH_TAILORING_3 = {
            childNodeIDs = {"TIMEWEAVING_1"},
            nodeID = 40071,
            threshold = 20,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        CHRONOCLOTH_TAILORING_4 = {
            childNodeIDs = {"TIMEWEAVING_1"},
            nodeID = 40071,
            threshold = 25,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.TAILORING.CHRONOCLOTH_ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.TAILORING.ARMOR
                }
            },
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
                376542, -- Bronzed Grip Wrappings
                376546, -- Dragoncloth Tailoring Vestments
                376540, -- Temporal Spellthread
                376561, -- Chronocloth Reagent Bag
                376567, -- Cushion of Time Travel
            },
        },
        TIMEWEAVING_1 = {
            nodeID = 40070,
            equalsSkill = true,
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
            }
        },
        TIMEWEAVING_2 = {
            nodeID = 40070,
            threshold = 5,
            multicraft = 10,
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
            }
        },
        TIMEWEAVING_3 = {
            nodeID = 40070,
            threshold = 10,
            skill = 5,
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
            }
        },
        TIMEWEAVING_4 = {
            nodeID = 40070,
            threshold = 15,
            multicraft = 10,
            exceptionRecipeIDs = {
                376557, -- Chronocloth Bolt
            }
        },
        GARMENTCRAFTING_1 = { -- ow mapped, outfits mapped, embelishments mapped
            childNodeIDs = {"OUTERWEAR_1", "OUTFITS_1", "EMBELLISHMENTS_1"},
            nodeID = 40226,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
                ---- outfits
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
                --- embelishments
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        GARMENTCRAFTING_2 = {
            childNodeIDs = {"OUTERWEAR_1", "OUTFITS_1", "EMBELLISHMENTS_1"},
            nodeID = 40226,
            threshold = 0,
            skill = 10,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
                ---- outfits
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
                --- embelishments
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        GARMENTCRAFTING_3 = {
            childNodeIDs = {"OUTERWEAR_1", "OUTFITS_1", "EMBELLISHMENTS_1"},
            nodeID = 40226,
            threshold = 10,
            inspiration = 5,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
                ---- outfits
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
                --- embelishments
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        GARMENTCRAFTING_4 = {
            childNodeIDs = {"OUTERWEAR_1", "OUTFITS_1", "EMBELLISHMENTS_1"},
            nodeID = 40226,
            threshold = 20,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
                ---- outfits
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
                --- embelishments
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        GARMENTCRAFTING_5 = {
            childNodeIDs = {"OUTERWEAR_1", "OUTFITS_1", "EMBELLISHMENTS_1"},
            nodeID = 40226,
            threshold = 30,
            inspiration = 10,
            resourcefulness = 10,
            craftingspeedBonusFactor = 0.15,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
                ---- outfits
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
                --- embelishments
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        OUTERWEAR_1 = { -- gloves mapped, footwear mapped, hats mapped, cloaks mapped
            childNodeIDs = {"GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1"},
            nodeID = 40222,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        OUTERWEAR_2 = {
            childNodeIDs = {"GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1"},
            nodeID = 40222,
            threshold = 5,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        OUTERWEAR_3 = {
            childNodeIDs = {"GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1"},
            nodeID = 40222,
            threshold = 15,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        OUTERWEAR_4 = {
            childNodeIDs = {"GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1"},
            nodeID = 40222,
            threshold = 35,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        OUTERWEAR_5 = {
            childNodeIDs = {"GLOVES_1", "FOOTWEAR_1", "HATS_1", "CLOAKS_1"},
            nodeID = 40222,
            threshold = 45,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        GLOVES_1 = {
            nodeID = 40221,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- gloves
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
            },
        },
        GLOVES_2 = {
            nodeID = 40221,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                395813, -- (Rare) Surveyor's Seasoned Gloves
                376513, -- (Epic) Vibrant Wildercloth Handwraps
                376503, -- (Epic Chrono) Chronocloth Gloves
                376522, -- (Green) Crimson Combatant's Wildercloth Gloves
            },
        },
        FOOTWEAR_1 = {
            nodeID = 40220,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- footwear
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
            },
        },
        FOOTWEAR_2 = {
            nodeID = 40220,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                376508, -- (Rare) Surveyor's Cloth Treads
                376512, -- (Epic) Vibrant Wildercloth Slippers
                376501, -- (Epic Azure) Azureweave Slippers
                376496, -- (Epic Azure) Blue Dragon Soles
                376521, -- (Green) Crimson Combatant's Wildercloth Treads
            },
        },
        HATS_1 = {
            nodeID = 40219,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- hats
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
            },
        },
        HATS_2 = {
            nodeID = 40219,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                -- Armor
                395807, -- (Rare) Surveyor's Seasoned Hood
                376514, -- (Epic) Vibrant Wildercloth Headcover
                376492, -- (Epic Chrono) Hood of Surging Time
                376523, -- (Green) Crimson Combatant's Wildercloth Hood

                -- Profession Equipment
                -- Cooking
                376548, -- (Rare) Master's Wildercloth Chef's Hat
                376547, -- (Green) Wildercloth Chef's Hat
                -- Enchanting
                376550, -- (Rare) Master's Wildercloth Enchanter's Hat
                376549, -- (Green) Wildercloth Enchanter's Hat
                -- Fishing
                376552, -- (Rare) Master's Wildercloth Fishing Cap
                376551, -- (Green) Wildercloth Fishing Cap
                -- Herbalism
                376554, -- (Rare) Master's Wildercloth Gardening Hat
                376553, -- (Green) Wildercloth Gardening Hat
            },
        },
        CLOAKS_1 = {
            nodeID = 40218,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- cloaks
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        CLOAKS_2 = {
            nodeID = 40218,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                376506, -- (Rare) Surveyor's Tailored Cloak
                376510, -- (Epic) Vibrant Wildercloth Shawl
                376519, -- (Green) Crimson Combatant's Wildercloth Cloak
            },
        },
        OUTFITS_1 = { -- robes mapped, leggings mapped
            childNodeIDs = {"ROBES_1", "LEGGINGS_1"},
            nodeID = 40225,
            equalsSkill = true,
            exceptionRecipeIDs = {
                ---- outfits
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        OUTFITS_2 = {
            childNodeIDs = {"ROBES_1", "LEGGINGS_1"},
            nodeID = 40225,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        OUTFITS_3 = {
            childNodeIDs = {"ROBES_1", "LEGGINGS_1"},
            nodeID = 40225,
            threshold = 15,
            inspiration = 10,
            exceptionRecipeIDs = {
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        OUTFITS_4 = {
            childNodeIDs = {"ROBES_1", "LEGGINGS_1"},
            nodeID = 40225,
            threshold = 25,
            skill = 5,
            exceptionRecipeIDs = {
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        OUTFITS_5 = {
            childNodeIDs = {"ROBES_1", "LEGGINGS_1"},
            nodeID = 40225,
            threshold = 35,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        ROBES_1 = {
            nodeID = 40224,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- robes
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
            },
        },
        ROBES_2 = {
            nodeID = 40224,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                -- Armor
                376507, -- (Rare) Surveyor's Cloth Robe
                376511, -- (Epic) Vibrant Wildercloth Vestments
                376500, -- (Epic Azure) Azureweave Robe
                376520, -- (Green) Crimson Combatant's Wildercloth Tunic

                -- Profession Equipment
                -- Tailoring
                376546, -- (Epic) Dragoncloth Tailoring Vestments
                376545, -- (Green) Wildercloth Tailor's Coat
                -- Alchemy
                376544, -- (Rare) Master's Wildercloth Alchemist's Robe
                376543, -- (Green) Wildercloth Alchemist's Robe
            },
        },
        LEGGINGS_1 = {
            nodeID = 40223,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- leggings
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        LEGGINGS_2 = {
            nodeID = 40223,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                395814, -- (Rare) Surveyor's Seasoned Pants
                376515, -- (Epic) Vibrant Wildercloth Slacks
                376504, -- (Epic Chrono) Chronocloth Leggings
                376495, -- (Epic Chrono) Infurious Legwraps of Possibility
                376524, -- (Green) Crimson Combatant's Wildercloth Leggings
            },
        },
        EMBELLISHMENTS_1 = { -- mantles mapped, armbands mapped, belts mapped
            childNodeIDs = {"MANTLES_1", "ARMBANDS_1", "BELTS_1"},
            nodeID = 40217,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --- embelishments
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        EMBELLISHMENTS_2 = {
            childNodeIDs = {"MANTLES_1", "ARMBANDS_1", "BELTS_1"},
            nodeID = 40217,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        EMBELLISHMENTS_3 = {
            childNodeIDs = {"MANTLES_1", "ARMBANDS_1", "BELTS_1"},
            nodeID = 40217,
            threshold = 15,
            inspiration = 10,
            exceptionRecipeIDs = {
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        EMBELLISHMENTS_4 = {
            childNodeIDs = {"MANTLES_1", "ARMBANDS_1", "BELTS_1"},
            nodeID = 40217,
            threshold = 25,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        EMBELLISHMENTS_5 = {
            childNodeIDs = {"MANTLES_1", "ARMBANDS_1", "BELTS_1"},
            nodeID = 40217,
            threshold = 35,
            skill = 5,
            exceptionRecipeIDs = {
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
        MANTLES_1 = {
            nodeID = 40216,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- mantles
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
            },
        },
        MANTLES_2 = {
            nodeID = 40216,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                395815, -- (Rare) Surveyor's Seasoned Shoulders
                376516, -- (Epic) Vibrant Wildercloth Shoulderspikes
                376493, -- (Epic Azure) Amice of the Blue
                376502, -- (Epic Azure) Azureweave Mantle
                376525, -- (Green) Crimson Combatant's Wildercloth Shoulderpads
            },
        },
        ARMBANDS_1 = {
            nodeID = 40215,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- armbands
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
            },
        },
        ARMBANDS_2 = {
            nodeID = 40215,
            threshold = 5,
            skill = 10,
            exceptionRecipeIDs = {
                376509, -- (Rare) Surveyor's Cloth Bands
                376518, -- (Epic) Vibrant Wildercloth Wristwraps
                376497, -- (Epic Chrono) Allied Wristguards of Time Dilation
                376527, -- (Green) Crimson Combatant's Wildercloth Bands
            },
        },
        BELTS_1 = {
            nodeID = 40214,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- belts
                395809, -- (Rare) Surveyor's Seasoned Cord
                376517, -- (Epic) Vibrant Widercloth Girdle)
                376494, -- (Epic Azure) Infurious Binding of Gesticulation
                376505, -- (Epic Chrono) Chronocloth Sash
                376526, -- (Green) Crimson Combatant's Wildercloth Sash
            },
        },
    }
end