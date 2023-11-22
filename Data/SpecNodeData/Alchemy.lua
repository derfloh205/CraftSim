CraftSimAddonName, CraftSim = ...

CraftSim.ALCHEMY_DATA = {}

CraftSim.ALCHEMY_DATA.NODE_IDS = {
    ALCHEMICAL_THEORY = 19539,
    TRANSMUTATION = 19538,
    CHEMICAL_SYNTHESIS = 19537,
    DECAYOLOGY = 19536,
    RESOURCEFUL_ROUTINES = 19535,
    INSPIRING_AMBIENCE = 19534,
    PHIAL_MASTERY = 22483,
    FROST_FORMULATED_PHIALS = 22482,
    AIR_FORMULATED_PHIALS = 22481,
    PHIAL_LORE = 22480,
    PHIAL_EXPERIMENTATION = 22479,
    PHIAL_BATCH_PRODUCTION = 22478,
    POTION_MASTERY = 19487,
    FROST_FORMULATED_POTIONS = 19486,
    AIR_FORMULATED_POTIONS = 19485,
    POTION_LORE = 19484,
    POTION_EXPERIMENTATION = 19483,
    POTION_BATCH_PRODUCTION = 19482
}

CraftSim.ALCHEMY_DATA.NODES = function()
    return {
        -- Alchemical Theory
        {
            name = "Alchemical Theory",
            nodeID = 19539
        },
        {
            name = "Transmutation",
            nodeID = 19538
        },
        {
            name = "Chemical Synthesis",
            nodeID = 19537
        },
        {
            name = "Decayology",
            nodeID = 19536
        },
        {
            name = "Resourceful Routines",
            nodeID = 19535
        },
        {
            name = "Inspiring Ambience",
            nodeID = 19534
        },
        -- Phial Mastery
        {
            name = "Phial Mastery",
            nodeID = 22483
        },
        {
            name = "Frost-Formulated Phials",
            nodeID = 22482
        },
        {
            name = "Air-Formulated Phials",
            nodeID = 22481
        },
        {
            name = "Phial Lore",
            nodeID = 22480
        },
        {
            name = "Phial Experimentation",
            nodeID = 22479
        },
        {
            name = "Batch Production",
            nodeID = 22478
        },
        -- Potion Mastery
        {
            name = "Potion Mastery",
            nodeID = 19487
        },
        {
            name = "Frost-Formulated Potions",
            nodeID = 19486
        },
        {
            name = "Air-Formulated Potions",
            nodeID = 19485
        },
        {
            name = "Potion Lore",
            nodeID = 19484
        },
        {
            name = "Potion Experimentation",
            nodeID = 19483
        },
        {
            name = "Batch Production",
            nodeID = 19482
        },
    }
end

function CraftSim.ALCHEMY_DATA:GetData()
    return {
        -- Alchemical Theory
        ALCHEMICAL_THEORY_1 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            equalsSkill = true,
        },
        ALCHEMICAL_THEORY_2 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            threshold = 0,
            inspiration = 5,
        },
        ALCHEMICAL_THEORY_3 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            threshold = 10,
            resourcefulness = 5,
        },
        ALCHEMICAL_THEORY_4 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            threshold = 20,
            craftingspeedBonusFactor = 0.10,
        },
        ALCHEMICAL_THEORY_5 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            threshold = 30,
            inspiration = 5,
        },
        ALCHEMICAL_THEORY_6 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            threshold = 40,
            resourcefulness = 5,
        },
        ALCHEMICAL_THEORY_7 = {
            childNodeIDs = {"TRANSMUTATION_1", "CHEMICAL_SYNTHESIS_1", "DECAYOLOGY_1", "RESOURCEFUL_ROUTINES_1", "INSPIRING_AMBIENCE_1"},
            nodeID = 19539,
            threshold = 50,
            inspiration = 15,
            resourcefulness = 15,
            craftingspeedBonusFactor = 0.15,
        },
        TRANSMUTATION_1 = {
            nodeID = 19538,
            equalsResourcefulness = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.TRANSMUTATIONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ELEMENTAL
                }
            },
        },
        TRANSMUTATION_2 = {
            nodeID = 19538,
            threshold = 0,
            resourcefulness = (0.05 / CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS), 
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.TRANSMUTATIONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ELEMENTAL
                }
            },
        },
        TRANSMUTATION_3 = {
            nodeID = 19538,
            threshold = 5,
            resourcefulness = (0.05 / CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS), 
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.TRANSMUTATIONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ELEMENTAL
                }
            },
        },
        TRANSMUTATION_4 = {
            nodeID = 19538,
            threshold = 15,
            resourcefulness = (0.15 / CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS), 
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.TRANSMUTATIONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ELEMENTAL
                }
            },
        },
        CHEMICAL_SYNTHESIS_1 = {
            nodeID = 19537,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },
        },
        CHEMICAL_SYNTHESIS_2 = {
            nodeID = 19537,
            threshold = 0,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },      
        },
        CHEMICAL_SYNTHESIS_3 = {
            nodeID = 19537,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },   
        },
        CHEMICAL_SYNTHESIS_4 = {
            nodeID = 19537,
            threshold = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },    
            },
        CHEMICAL_SYNTHESIS_5 = {
            nodeID = 19537,
            threshold = 15,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },    
            },
        CHEMICAL_SYNTHESIS_6 = {
            nodeID = 19537,
            threshold = 20,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },      
            },
        CHEMICAL_SYNTHESIS_7 = {
            nodeID = 19537,
            threshold = 25,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },    
            },
        CHEMICAL_SYNTHESIS_8 = {
            nodeID = 19537,
            threshold = 30,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },     
            },
        CHEMICAL_SYNTHESIS_9 = {
            nodeID = 19537,
            threshold = 40,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.FINISHING_REAGENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.FINISHING_REAGENT
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OPTIONAL_REAGENTS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.INCENSE] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.INCENSE
                }
            },     
            },
        DECAYOLOGY_1 = {
            nodeID = 19536,
            equalsSkill = true,
            exceptionRecipeIDs = {
                            370521, -- air potion
                370536, -- frost potion
                370525, -- frost potion
                370528, -- frost potion
                370457, -- frost phial
                370456, -- frost phial
                370714, -- decay transmutation
            },
        },
        DECAYOLOGY_2 = {
            nodeID = 19536,
            threshold = 5,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                370521, -- air potion
                370536, -- frost potion
                370525, -- frost potion
                370528, -- frost potion
                370457, -- frost phial
                370456, -- frost phial
                370714, -- decay transmutation
            },
        },
        DECAYOLOGY_3 = {
            nodeID = 19536,
            threshold = 15,
            inspiration = 10,
            exceptionRecipeIDs = {
                370521, -- air potion
                370536, -- frost potion
                370525, -- frost potion
                370528, -- frost potion
                370457, -- frost phial
                370456, -- frost phial
                370714, -- decay transmutation
            },
        },
        DECAYOLOGY_4 = {
            nodeID = 19536,
            threshold = 25,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                370521, -- air potion
                370536, -- frost potion
                370525, -- frost potion
                370528, -- frost potion
                370457, -- frost phial
                370456, -- frost phial
                370714, -- decay transmutation
            },
        },
        RESOURCEFUL_ROUTINES_1 = {
            nodeID = 19535,
            equalsResourcefulness = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_2 = {
            nodeID = 19535,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_3 = {
            nodeID = 19535,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_4 = {
            nodeID = 19535,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_5 = {
            nodeID = 19535,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_6 = {
            nodeID = 19535,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_7 = {
            nodeID = 19535,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RESOURCEFUL_ROUTINES_8 = {
            nodeID = 19535,
            threshold = 25,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_1 = {
            nodeID = 19534,
            equalsInspiration = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_2 = {
            nodeID = 19534,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_3 = {
            nodeID = 19534,
            threshold = 5,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_4 = {
            nodeID = 19534,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_5 = {
            nodeID = 19534,
            threshold = 15,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_6 = {
            nodeID = 19534,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_7 = {
            nodeID = 19534,
            threshold = 25,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INSPIRING_AMBIENCE_8 = {
            nodeID = 19534,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        -- Phial Mastery
        PHIAL_MASTERY_1 = {
            childNodeIDs = {"FROST_PHIALS_1", "PHIAL_LORE_1", "AIR_PHIALS_1"},
            nodeID = 22483,
            equalsSkill = true,
        },
        PHIAL_MASTERY_2 = {
            childNodeIDs = {"FROST_PHIALS_1", "PHIAL_LORE_1", "AIR_PHIALS_1"},
            nodeID = 22483,
            threshold = 5,
            inspiration = 5,
        },
        PHIAL_MASTERY_3 = {
            childNodeIDs = {"FROST_PHIALS_1", "PHIAL_LORE_1", "AIR_PHIALS_1"},
            nodeID = 22483,
            threshold = 25,
            resourcefulness = 5,
        },
        PHIAL_LORE_1 = {
            childNodeIDs = {"PHIAL_EXPERIMENTATION_1", "PHIAL_BATCH_PRODUCTION_1"},
            nodeID = 22480,
            equalsSkill = true,
            exceptionRecipeIDs = {
                370676, -- phial trinket
            },
        },
        PHIAL_LORE_2 = {
            childNodeIDs = {"PHIAL_EXPERIMENTATION_1", "PHIAL_BATCH_PRODUCTION_1"},
            nodeID = 22480,
            threshold = 0,
            skill = 5,
            exceptionRecipeIDs = {
                370676, -- phial trinket
            },
        },
        PHIAL_LORE_3 = {
            childNodeIDs = {"PHIAL_EXPERIMENTATION_1", "PHIAL_BATCH_PRODUCTION_1"},
            nodeID = 22480,
            threshold = 5,
            inspiration = 5,
            exceptionRecipeIDs = {
                370676, -- phial trinket
            },
        },
        PHIAL_LORE_4 = {
            childNodeIDs = {"PHIAL_EXPERIMENTATION_1", "PHIAL_BATCH_PRODUCTION_1"},
            nodeID = 22480,
            threshold = 15,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                370676, -- phial trinket
            },
        },
        FROST_PHIALS_1 = {
            nodeID = 22482,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        FROST_PHIALS_2 = {
            nodeID = 22482,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        FROST_PHIALS_3 = {
            nodeID = 22482,
            threshold = 10,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        FROST_PHIALS_4 = {
            nodeID = 22482,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        FROST_PHIALS_5 = {
            nodeID = 22482,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        FROST_PHIALS_6 = {
            nodeID = 22482,
            threshold = 25,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        AIR_PHIALS_1 = {
            nodeID = 22481,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        AIR_PHIALS_2 = {
            nodeID = 22481,
            threshold = 5,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        AIR_PHIALS_3 = {
            nodeID = 22481,
            threshold = 10,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        AIR_PHIALS_4 = {
            nodeID = 22481,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        AIR_PHIALS_5 = {
            nodeID = 22481,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        AIR_PHIALS_6 = {
            nodeID = 22481,
            threshold = 25,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }
            },
            exceptionRecipeIDs = {
                406106, -- phial cauldron
            }
        },
        PHIAL_EXPERIMENTATION_1 = {
            nodeID = 22479,
            equalsPhialExperimentationChanceFactor = true,
            exceptionRecipeIDs = {
                370746, -- basic
                370747, -- advanced
            }
        },
        PHIAL_EXPERIMENTATION_2 = {
            nodeID = 22479,
            threshold = 0,
            phialExperimentationChanceFactor = 0.10,
            exceptionRecipeIDs = {
                370746, -- basic
                370747, -- advanced
            }
        },
        PHIAL_EXPERIMENTATION_3 = {
            nodeID = 22479,
            threshold = 5,
            phialExperimentationChanceFactor = 0.05,
            exceptionRecipeIDs = {
                370746, -- basic
                370747, -- advanced
            }
        },
        PHIAL_EXPERIMENTATION_4 = {
            nodeID = 22479,
            threshold = 15,
            phialExperimentationChanceFactor = 0.05,
            exceptionRecipeIDs = {
                370746, -- basic
                370747, -- advanced
            }
        },
        PHIAL_BATCH_PRODUCTION_1 = {
            nodeID = 22478,
            equalsMulticraft = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370746, -- basic
                370747, -- advanced
                406106, -- phial cauldron
            },
        },
        PHIAL_BATCH_PRODUCTION_2 = {
            nodeID = 22478,
            threshold = 0,
            multicraft = 60,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                },  
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370746, -- basic
                370747, -- advanced
                406106, -- phial cauldron
            },
        },
        PHIAL_BATCH_PRODUCTION_3 = {
            nodeID = 22478,
            threshold = 5,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370746, -- basic
                370747, -- advanced
                406106, -- phial cauldron
            },
        },
        PHIAL_BATCH_PRODUCTION_4 = {
            nodeID = 22478,
            threshold = 10,
            multicraft = 60,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370746, -- basic
                370747, -- advanced
                406106, -- phial cauldron
            },
        },
        PHIAL_BATCH_PRODUCTION_5 = {
            nodeID = 22478,
            threshold = 15,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370746, -- basic
                370747, -- advanced
                406106, -- phial cauldron
            },
        },
        PHIAL_BATCH_PRODUCTION_6 = {
            nodeID = 22478,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.PHIALS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
                }, 
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370746, -- basic
                370747, -- advanced
                406106, -- phial cauldron
            },
        },

        -- Potion Mastery
        POTION_MASTERY_1 = {
            childNodeIDs = {"FROST_POTIONS_1", "POTION_LORE_1", "AIR_POTIONS_1"},
            nodeID = 19487,
            equalsSkill = true,
        },
        POTION_MASTERY_2 = {
            childNodeIDs = {"FROST_POTIONS_1", "POTION_LORE_1", "AIR_POTIONS_1"},
            nodeID = 19487,
            threshold = 5,
            inspiration = 5,
        },
        POTION_MASTERY_3 = {
            childNodeIDs = {"FROST_POTIONS_1", "POTION_LORE_1", "AIR_POTIONS_1"},
            nodeID = 19487,
            threshold = 25,
            resourcefulness = 5,
        },
        POTION_LORE_1 = {
            childNodeIDs = {"POTION_EXPERIMENTATION_1", "POTION_BATCH_PRODUCTION_1"},
            nodeID = 19484,
            equalsSkill = true,
            exceptionRecipeIDs = {
                370677, -- potion trinket
            },
        },
        POTION_LORE_2 = {
            childNodeIDs = {"POTION_EXPERIMENTATION_1", "POTION_BATCH_PRODUCTION_1"},
            nodeID = 19484,
            threshold = 0,
            skill = 5,
            exceptionRecipeIDs = {
                370677, -- potion trinket
            },
        },
        POTION_LORE_3 = {
            childNodeIDs = {"POTION_EXPERIMENTATION_1", "POTION_BATCH_PRODUCTION_1"},
            nodeID = 19484,
            threshold = 5,
            inspiration = 5,
            exceptionRecipeIDs = {
                370677, -- potion trinket
            },
        },
        POTION_LORE_4 = {
            childNodeIDs = {"POTION_EXPERIMENTATION_1", "POTION_BATCH_PRODUCTION_1"},
            nodeID = 19484,
            threshold = 15,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                370677, -- potion trinket
            },
        },
        FROST_POTIONS_1 = {
            nodeID = 19486,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        FROST_POTIONS_2 = {
            nodeID = 19486,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        FROST_POTIONS_3 = {
            nodeID = 19486,
            threshold = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        FROST_POTIONS_4 = {
            nodeID = 19486,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        FROST_POTIONS_5 = {
            nodeID = 19486,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        AIR_POTIONS_1 = {
            nodeID = 19485,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        AIR_POTIONS_2 = {
            nodeID = 19485,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        AIR_POTIONS_3 = {
            nodeID = 19485,
            threshold = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        AIR_POTIONS_4 = {
            nodeID = 19485,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        AIR_POTIONS_5 = {
            nodeID = 19485,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = {
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        POTION_EXPERIMENTATION_1 = {
            nodeID = 19483,
            equalsPotionExperimentationChanceFactor = true,
            exceptionRecipeIDs = {
                370743, -- basic
                370745, -- advanced
            }
        },
        POTION_EXPERIMENTATION_2 = {
            nodeID = 19483,
            threshold = 0,
            potionExperimentationChanceFactor = 0.10,
            exceptionRecipeIDs = {
                370743, -- basic
                370745, -- advanced
            }
        },
        POTION_EXPERIMENTATION_3 = {
            nodeID = 19483,
            threshold = 5,
            potionExperimentationChanceFactor = 0.05,
            exceptionRecipeIDs = {
                370743, -- basic
                370745, -- advanced
            }
        },
        POTION_EXPERIMENTATION_4 = {
            nodeID = 19483,
            threshold = 15,
            potionExperimentationChanceFactor = 0.05,
            exceptionRecipeIDs = {
                370743, -- basic
                370745, -- advanced
            }
        },
        POTION_BATCH_PRODUCTION_1 = {
            nodeID = 19482,
            equalsMulticraft = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370743, -- basic
                370745, -- advanced
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        POTION_BATCH_PRODUCTION_2 = {
            nodeID = 19482,
            threshold = 0,
            multicraft = 60,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370743, -- basic
                370745, -- advanced
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        POTION_BATCH_PRODUCTION_3 = {
            nodeID = 19482,
            threshold = 5,
            craftingspeedBonusFactor = 0.20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370743, -- basic
                370745, -- advanced
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        POTION_BATCH_PRODUCTION_4 = {
            nodeID = 19482,
            threshold = 15,
            multicraft = 60,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370743, -- basic
                370745, -- advanced
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
        POTION_BATCH_PRODUCTION_5 = {
            nodeID = 19482,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.FROST] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.POTIONS.AIR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }, 
                [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.ELEMENTAL_BOTH] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
                }
            },
            exceptionRecipeIDs = { -- the crafting speed effects experimentations
                370743, -- basic
                370745, -- advanced
                370672, -- ultimate power cauldron
                370668, -- power cauldron
                370673, -- pooka cauldron
            },
        },
    }
end