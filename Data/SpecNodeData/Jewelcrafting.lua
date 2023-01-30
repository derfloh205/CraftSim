AddonName, CraftSim = ...

CraftSim.JEWELCRAFTING_DATA = {}

CraftSim.JEWELCRAFTING_DATA.NODES = function()
    return {
        -- Toolset Mastery
        {
            name = "Toolset Mastery",
            nodeID = 28672
        },
        {
            name = "Saving Slivers",
            nodeID = 81119
        },
        {
            name = "Brilliant Baubling",
            nodeID = 81118
        },
        -- Faceting
        {
            name = "Faceting",
            nodeID = 28660
        },
        {
            name = "Air",
            nodeID = 28659
        },
        {
            name = "Earth",
            nodeID = 28658
        },
        {
            name = "Fire",
            nodeID = 28657
        },
        {
            name = "Frost",
            nodeID = 28656
        },
        -- Setting
        {
            name = "Setting",
            nodeID = 28728
        },
        {
            name = "Jewelry",
            nodeID = 28727
        },
        {
            name = "Carving",
            nodeID = 28724
        },
        {
            name = "Necklaces",
            nodeID = 28726
        },
        {
            name = "Rings",
            nodeID = 28725
        },
        {
            name = "Idols",
            nodeID = 28723
        },
        {
            name = "Stone",
            nodeID = 28722
        },
        {
            name = "Enterprising",
            nodeID = 28610
        },
        {
            name = "Prospecting",
            nodeID = 28609
        },
        {
            name = "Extravagancies",
            nodeID = 28608
        },
        {
            name = "Glassware",
            nodeID = 28607
        },
    }
end

function CraftSim.JEWELCRAFTING_DATA:GetData()
    return {
        TOOLSET_MASTERY_1 = {
            childNodeIDs = {"SAVING_SLIVERS_1", "BRILLIANT_BAUBLING_1"},
            equalsSkill = true,
            nodeID = 28672,
        },
        TOOLSET_MASTERY_2 = {
            childNodeIDs = {"SAVING_SLIVERS_1", "BRILLIANT_BAUBLING_1"},
            threshold = 0,
            craftingspeedBonusFactor = 0.10,
            nodeID = 28672,
        },
        TOOLSET_MASTERY_3 = {
            childNodeIDs = {"SAVING_SLIVERS_1", "BRILLIANT_BAUBLING_1"},
            threshold = 5,
            skill = 3,
            nodeID = 28672
        },
        TOOLSET_MASTERY_4 = {
            childNodeIDs = {"SAVING_SLIVERS_1", "BRILLIANT_BAUBLING_1"},
            threshold = 15,
            skill = 4,
            nodeID = 28672
        },
        TOOLSET_MASTERY_5 = {
            childNodeIDs = {"SAVING_SLIVERS_1", "BRILLIANT_BAUBLING_1"},
            threshold = 25,
            skill = 3,
            nodeID = 28672
        },
        TOOLSET_MASTERY_6 = {
            childNodeIDs = {"SAVING_SLIVERS_1", "BRILLIANT_BAUBLING_1"},
            threshold = 30,
            inspiration = 10,
            resourcefulness = 10,
            craftingspeedBonusFactor = 0.10,
            nodeID = 28672,
        },
        SAVING_SLIVERS_1 = {
            nodeID = 81119,
            equalsResourcefulness = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_2 = {
            nodeID = 81119,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_3 = {
            nodeID = 81119,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_4 = {
            nodeID = 81119,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_5 = {
            nodeID = 81119,
            threshold = 15,
            resourcefulness = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_6 = {
            nodeID = 81119,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_7 = {
            nodeID = 81119,
            threshold = 25,
            resourcefulness = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SAVING_SLIVERS_8 = {
            nodeID = 81119,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_1 = {
            nodeID = 81118,
            equalsInspiration = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_2 = {
            nodeID = 81118,
            threshold = 5,
            inspiration = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_3 = {
            nodeID = 81118,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_4 = {
            nodeID = 81118,
            threshold = 15,
            inspiration = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_5 = {
            nodeID = 81118,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_6 = {
            nodeID = 81118,
            threshold = 25,
            inspiration = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        BRILLIANT_BAUBLING_7 = {
            nodeID = 81118,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        
        FACETING_1 = {
            nodeID = 28660,
            childNodeIDs = {"AIR_1", "EARTH_1", "FIRE_1", "FROST_1"},
            equalsSkill = true,
        },
        FACETING_2 = {
            nodeID = 28660,
            threshold = 5,
            inspiration = 5,
            childNodeIDs = {"AIR_1", "EARTH_1", "FIRE_1", "FROST_1"},
        },
        FACETING_3 = {
            nodeID = 28660,
            threshold = 15,
            resourcefulness = 5,
            childNodeIDs = {"AIR_1", "EARTH_1", "FIRE_1", "FROST_1"},
        },
        FACETING_4 = {
            nodeID = 28660,
            threshold = 25,
            multicraft = 20,
            childNodeIDs = {"AIR_1", "EARTH_1", "FIRE_1", "FROST_1"},
        },
        FACETING_5 = {
            nodeID = 28660,
            threshold = 35,
            skill = 5,
            childNodeIDs = {"AIR_1", "EARTH_1", "FIRE_1", "FROST_1"},
        },
        FACETING_6 = {
            nodeID = 28660,
            threshold = 40,
            craftingspeedBonusFactor = 0.10,
            childNodeIDs = {"AIR_1", "EARTH_1", "FIRE_1", "FROST_1"},
        },
        AIR_1 = {
            nodeID = 28659,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.AIR_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374467, -- Primalist Air
            },
            equalsSkill = true,
        },
        AIR_2 = {
            nodeID = 28659,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.AIR_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374467, -- Primalist Air
            },
            threshold = 5,
            skill = 5,
        },
        AIR_3 = {
            nodeID = 28659,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.AIR_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374467, -- Primalist Air
            },
            threshold = 15,
            skill = 5,
        },
        AIR_4 = {
            nodeID = 28659,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.AIR_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374467, -- Primalist Air
            },
            threshold = 25,
            skill = 5,
        },
        AIR_5 = {
            nodeID = 28659,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.AIR_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374467, -- Primalist Air
            },
            threshold = 35,
            skill = 5,
        },

        EARTH_1 = {
            nodeID = 28658,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EARTH_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374468, -- Primalist Earth
            },
            equalsSkill = true,
        },
        EARTH_2 = {
            nodeID = 28658,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EARTH_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374468, -- Primalist Earth
            },
            threshold = 5,
            skill = 5,
        },
        EARTH_3 = {
            nodeID = 28658,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EARTH_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374468, -- Primalist Earth
            },
            threshold = 15,
            skill = 5,
        },
        EARTH_4 = {
            nodeID = 28658,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EARTH_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374468, -- Primalist Earth
            },
            threshold = 25,
            skill = 5,
        },
        EARTH_5 = {
            nodeID = 28658,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EARTH_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374468, -- Primalist Earth
            },
            threshold = 35,
            skill = 5,
        },

        FIRE_1 = {
            nodeID = 28657,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FIRE_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374465, -- Primalist Fire
            },
            equalsSkill = true,
        },
        FIRE_2 = {
            nodeID = 28657,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FIRE_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374465, -- Primalist Fire
            },
            threshold = 5,
            skill = 5,
        },
        FIRE_3 = {
            nodeID = 28657,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FIRE_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374465, -- Primalist Fire
            },
            threshold = 15,
            skill = 5,
        },
        FIRE_4 = {
            nodeID = 28657,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FIRE_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374465, -- Primalist Fire
            },
            threshold = 25,
            skill = 5,
        },
        FIRE_5 = {
            nodeID = 28657,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FIRE_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374465, -- Primalist Fire
            },
            threshold = 35,
            skill = 5,
        },
        FROST_1 = {
            nodeID = 28656,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FROST_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374470, -- Primalist Frost
            },
            equalsSkill = true,
        },
        FROST_2 = {
            nodeID = 28656,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FROST_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374470, -- Primalist Frost
            },
            threshold = 5,
            skill = 5,
        },
        FROST_3 = {
            nodeID = 28656,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FROST_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374470, -- Primalist Frost
            },
            threshold = 15,
            skill = 5,
        },
        FROST_4 = {
            nodeID = 28656,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FROST_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374470, -- Primalist Frost
            },
            threshold = 25,
            skill = 5,
        },
        FROST_5 = {
            nodeID = 28656,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.FROST_GEMS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.GEMS
                }
            },
            exceptionRecipeIDs = {
                374470, -- Primalist Frost
            },
            threshold = 35,
            skill = 5,
        },
        -- Setting
        SETTING_1 = {
            childNodeIDs = {"JEWELRY_1", "CARVING_1"},
            nodeID = 28728,
            equalsSkill = true,
        },
        SETTING_2 = {
            childNodeIDs = {"JEWELRY_1", "CARVING_1"},
            nodeID = 28728,
            threshold = 5,
            inspiration = 5,

        },
        SETTING_3 = {
            childNodeIDs = {"JEWELRY_1", "CARVING_1"},
            nodeID = 28728,
            threshold = 15,
            resourcefulness = 5,
        },
        SETTING_4 = {
            childNodeIDs = {"JEWELRY_1", "CARVING_1"},
            nodeID = 28728,
            threshold = 25,
            inspiration = 5,
        },
        JEWELRY_1 = {
            childNodeIDs = {"NECKLACES_1", "RINGS_1"},
            nodeID = 28727,
            equalsSkill = true,
        },
        JEWELRY_2 = {
            childNodeIDs = {"NECKLACES_1", "RINGS_1"},
            nodeID = 28727,
            threshold = 0,
            resourcefulness = 5,
        },
        JEWELRY_3 = {
            childNodeIDs = {"NECKLACES_1", "RINGS_1"},
            nodeID = 28727,
            threshold = 5,
            skill = 5,
        },
        CARVING_1 = {
            childNodeIDs = {"IDOLS_1", "STONE_1"},
            nodeID = 28724,
            equalsSkill = true,
        },
        CARVING_2 = {
            childNodeIDs = {"IDOLS_1", "STONE_1"},
            nodeID = 28724,
            threshold = 0,
            resourcefulness = 5,
        },
        CARVING_3 = {
            childNodeIDs = {"IDOLS_1", "STONE_1"},
            nodeID = 28724,
            threshold = 5,
            skill = 5,
        },
        CARVING_4 = {
            childNodeIDs = {"IDOLS_1", "STONE_1"},
            nodeID = 28724,
            threshold = 15,
            skill = 5,
        },
        CARVING_5 = {
            childNodeIDs = {"IDOLS_1", "STONE_1"},
            nodeID = 28724,
            threshold = 25,
            resourcefulness = 5,
        },
        NECKLACES_1 = {
            nodeID = 28726,
            exceptionRecipeIDs = {
                -- necks
                374501,
                374499,
                394621,
                374495,
                374496,
                374494
            },
            equalsSkill = true,
        },
        NECKLACES_2 = {
            nodeID = 28726,
            exceptionRecipeIDs = {
                -- necks
                374501,
                374499,
                394621,
                374495,
                374496,
                374494
            },
            threshold = 5,
            skill = 5,
        },
        NECKLACES_3 = {
            nodeID = 28726,
            exceptionRecipeIDs = {
                -- necks
                374501,
                374499,
                394621,
                374495,
                374496,
                374494
            },
            threshold = 10,
            skill = 5,
        },
        NECKLACES_4 = {
            nodeID = 28726,
            exceptionRecipeIDs = {
                -- necks
                374501,
                374499,
                394621,
                374495,
                374496,
                374494
            },
            threshold = 20,
            skill = 5,
        },
        NECKLACES_5 = {
            nodeID = 28726,
            exceptionRecipeIDs = {
                -- necks
                374501,
                374499,
                394621,
                374495,
                374496,
                374494
            },
            threshold = 25,
            inspiration = 10,
        },
        RINGS_1 = {
            nodeID = 28725,
            exceptionRecipeIDs = {
                -- rings
                374498,
                374479,
                376233,
            },
            equalsSkill = true,
        },
        RINGS_2 = {
            nodeID = 28725,
            exceptionRecipeIDs = {
                -- rings
                374498,
                374479,
                376233,
            },
            threshold = 5,
            skill = 5,

        },
        RINGS_3 = {
            nodeID = 28725,
            exceptionRecipeIDs = {
                -- rings
                374498,
                374479,
                376233,
            },
            threshold = 10,
            skill = 5,
        },
        RINGS_4 = {
            nodeID = 28725,
            exceptionRecipeIDs = {
                -- rings
                374498,
                374479,
                376233,
            },
            threshold = 20,
            skill = 5,
        },
        RINGS_5 = {
            nodeID = 28725,
            exceptionRecipeIDs = {
                -- rings
                374498,
                374479,
                376233,
            },
            threshold = 25,
            inspiration = 10,
        },
        IDOLS_1 = {
            nodeID = 28723,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.TRINKETS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.MISC
                }
            },
            equalsSkill = true,
        },
        IDOLS_2 = {
            nodeID = 28723,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.TRINKETS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.MISC
                }
            },
            threshold = 5,
            skill = 5,
        },
        IDOLS_3 = {
            nodeID = 28723,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.TRINKETS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.MISC
                }
            },
            threshold = 10,
            inspiration = 5,
        },
        IDOLS_4 = {
            nodeID = 28723,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.TRINKETS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.MISC
                }
            },
            threshold = 15,
            resourcefulness = 5,
        },
        IDOLS_5 = {
            nodeID = 28723,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.TRINKETS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.MISC
                }
            },
            threshold = 20,
            inspiration = 5,
        },
        IDOLS_6 = {
            nodeID = 28723,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.TRINKETS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.JEWELCRAFTING.MISC
                }
            },
            threshold = 25,
            skill = 5,
        },

        STONE_1 = {
            nodeID = 28722,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.STATUES_AND_CARVING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
            equalsSkill = true,
        },
        STONE_2 = {
            nodeID = 28722,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.STATUES_AND_CARVING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
            threshold = 0,
            multicraft = 20,
        },
        STONE_3 = {
            nodeID = 28722,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.STATUES_AND_CARVING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
            threshold = 5,
            skill = 5,
        },
        STONE_4 = {
            nodeID = 28722,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.STATUES_AND_CARVING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
            threshold = 10,
            multicraft = 20,
        },
        STONE_5 = {
            nodeID = 28722,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.STATUES_AND_CARVING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
            threshold = 20,
            skill = 5,
        },
        STONE_6 = {
            nodeID = 28722,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.STATUES_AND_CARVING] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
            threshold = 25,
            resourcefulness = 5,
        },
        ENTERPRISING_1 = {
            nodeID = 28610,
            childNodeIDs = {"PROSPECTING_1", "EXTRAVAGANCIES_1", "GLASSWARE_1"},
            equalsSkill = true,
        },
        ENTERPRISING_2 = {
            nodeID = 28610,
            childNodeIDs = {"PROSPECTING_1", "EXTRAVAGANCIES_1", "GLASSWARE_1"},
            threshold = 5,
            inspiration = 5,
        },
        ENTERPRISING_3 = {
            nodeID = 28610,
            childNodeIDs = {"PROSPECTING_1", "EXTRAVAGANCIES_1", "GLASSWARE_1"},
            threshold = 25,
            resourcefulness = 5,
        },
        PROSPECTING_1 = {
            nodeID = 28609,
            equalsSkill = true,
            exceptionRecipeIDs = {
                374627, -- prospecting
            }
        },
        PROSPECTING_2 = {
            nodeID = 28609,
            exceptionRecipeIDs = {
                374627, -- prospecting
            },
            threshold = 5,
            craftingspeedBonusFactor = 0.15,
        },
        PROSPECTING_3 = {
            nodeID = 28609,
            exceptionRecipeIDs = {
                374627, -- prospecting
            },
            threshold = 15,
            inspiration = 5,
        },
        PROSPECTING_4 = {
            nodeID = 28609,
            exceptionRecipeIDs = {
                374627, -- prospecting
            },
            threshold = 25,
            craftingspeedBonusFactor = 0.25,
        },
        EXTRAVAGANCIES_1 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            equalsSkill = true,
        },
        EXTRAVAGANCIES_2 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            threshold = 5,
            inspiration = 5,
        },
        EXTRAVAGANCIES_3 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            threshold = 10,
            resourcefulness = 5,
        },
        EXTRAVAGANCIES_4 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            threshold = 15,
            multicraft = 20,
        },
        EXTRAVAGANCIES_5 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            threshold = 20,
            resourcefulness = 5,
        },
        EXTRAVAGANCIES_6 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            threshold = 25,
            inspiration = 10,
        },
        EXTRAVAGANCIES_7 = {
            nodeID = 28608,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.PROFESSION_EQUIP] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            threshold = 30,
            skill = 5,

        },
        GLASSWARE_1 = {
            nodeID = 28607,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EXTRA_GLASSWARES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                -- prisms
                374525,
                374518,
            },
            equalsSkill = true,
        },
        GLASSWARE_2 = {
            nodeID = 28607,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EXTRA_GLASSWARES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                -- prisms
                374525,
                374518,
            },
            threshold = 5,
            multicraft = 10,
        },
        GLASSWARE_3 = {
            nodeID = 28607,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EXTRA_GLASSWARES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                -- prisms
                374525,
                374518,
            },
            threshold = 15,
            resourcefulness = 5,
        },
        GLASSWARE_4 = {
            nodeID = 28607,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EXTRA_GLASSWARES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                -- prisms
                374525,
                374518,
            },
            threshold = 30,
            resourcefulness = 5,
        },
        GLASSWARE_5 = {
            nodeID = 28607,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.JEWELCRAFTING.EXTRA_GLASSWARES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                -- prisms
                374525,
                374518,
            },
            threshold = 40,
            multicraft = 10, 
        },
    }
end
