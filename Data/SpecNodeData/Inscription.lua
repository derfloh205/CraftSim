CraftSimAddonName, CraftSim = ...

CraftSim.INSCRIPTION_DATA = {}

CraftSim.INSCRIPTION_DATA.NODE_IDS = {
    RUNE_MASTERY = 34835,
    PERFECT_PRACTICE = 34834,
    INFINITE_DISCOVERY = 34833,
    UNDERSTANDING_FLORA = 34832,
    FLAWLESS_INKS = 34831,
    ARCHIVING = 43535,
    DARKMOON_MYSTERIES = 43534,
    FIRE = 43533,
    FROST = 43532,
    AIR = 43531,
    EARTH = 43530,
    SHARED_KNOWLEDGE = 43529,
    CONTRACTS_AND_MISSIVES = 43528,
    DRACONIC_TREATISES = 43527,
    SCALE_SIGILS = 43526,
    AZURSCALE_SIGIL = 43525,
    EMBERSCALE_SIGIL = 43524,
    SAGESCALE_SIGIL = 43523,
    BRONZESCALE_SIGIL = 43522,
    JETSCALE_SIGIL = 43521,
    RUNEBINDING = 34893,
    WOODCARVING = 34892,
    PROFESSION_TOOLS = 34891,
    STAVES = 34890,
    RUNIC_SCRIPTURE = 34889,
    CODEXES = 34888,
    VANTUS_RUNES = 34887,
    FAUNA_RUNES = 34886
}

CraftSim.INSCRIPTION_DATA.NODES = function()
    return {
        -- Rune Mastery
        {
            name = "Rune Mastery",
            nodeID = 34835
        },
        {
            name = "Perfect Practice",
            nodeID = 34834
        },
        {
            name = "Infinite Discovery",
            nodeID = 34833
        },
        {
            name = "Understanding Flora",
            nodeID = 34832
        },
        {
            name = "Flawless Inks",
            nodeID = 34831
        },
        -- Archiving
        {
            name = "Archiving",
            nodeID = 43535
        },
        {
            name = "Darkmoon Mysteries",
            nodeID = 43534
        },
        {
            name = "Fire",
            nodeID = 43533
        },
        {
            name = "Frost",
            nodeID = 43532
        },
        {
            name = "Air",
            nodeID = 43531
        },
        {
            name = "Earth",
            nodeID = 43530
        },
        {
            name = "Shared Knowledge",
            nodeID = 43529
        },
        {
            name = "Contracts and Missives",
            nodeID = 43528
        },
        {
            name = "Draconic Treatises",
            nodeID = 43527
        },
        {
            name = "Scale Sigils",
            nodeID = 43526
        },
        {
            name = "Azurescale Sigil",
            nodeID = 43525
        },
        {
            name = "Emberscale Sigil",
            nodeID = 43524
        },
        {
            name = "Sagescale Sigil",
            nodeID = 43523
        },
        {
            name = "Bronzescale Sigil",
            nodeID = 43522
        },
        {
            name = "Jetscale Sigil",
            nodeID = 43521
        },
        -- Runebinding
        {
            name = "Runebinding",
            nodeID = 34893
        },
        {
            name = "Woodcarving",
            nodeID = 34892
        },
        {
            name = "Profession Tools",
            nodeID = 34891
        },
        {
            name = "Staves",
            nodeID = 34890
        },
        {
            name = "Runic Scripture",
            nodeID = 34889
        },
        {
            name = "Codexes",
            nodeID = 34888
        },
        {
            name = "Vantus Runes",
            nodeID = 34887
        },
        {
            name = "Fauna Runes",
            nodeID = 34886
        }
    }
end

function CraftSim.INSCRIPTION_DATA:GetData()
    return {
        RUNE_MASTERY_1 = { -- all mapped
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            equalsSkill = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RUNE_MASTERY_2 = {
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            threshold = 0,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RUNE_MASTERY_3 = {
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            threshold = 5,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RUNE_MASTERY_4 = {
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            threshold = 15,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RUNE_MASTERY_5 = {
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            threshold = 25,
            skill = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RUNE_MASTERY_6 = {
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            threshold = 35,
            inspiration = 10,
            resourcefulness = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        RUNE_MASTERY_7 = {
            childNodeIDs = {"PERFECT_PRACTICE_1", "INFINITE_DISCOVERY_1", "UNDERSTANDING_FLORA_1", "FLAWLESS_INKS_1"},
            nodeID = 34835,
            threshold = 40,
            inspiration = 10,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_1 = {
            nodeID = 34834,
            equalsResourcefulness = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_2 = {
            nodeID = 34834,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_3 = {
            nodeID = 34834,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_4 = {
            nodeID = 34834,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_5 = {
            nodeID = 34834,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_6 = {
            nodeID = 34834,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_7 = {
            nodeID = 34834,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_8 = {
            nodeID = 34834,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_1 = {
            nodeID = 34833,
            equalsInspiration = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_2 = {
            nodeID = 34833,
            threshold = 0,
            inspirationBonusSkillFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_3 = {
            nodeID = 34833,
            threshold = 5,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_4 = {
            nodeID = 34833,
            threshold = 10,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_5 = {
            nodeID = 34833,
            threshold = 15,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_6 = {
            nodeID = 34833,
            threshold = 20,
            inspirationBonusSkillFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_7 = {
            nodeID = 34833,
            threshold = 25,
            inspiration = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INFINITE_DISCOVERY_8 = {
            nodeID = 34833,
            threshold = 30,
            inspirationBonusSkillFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        UNDERSTANDING_FLORA_1 = {
            nodeID = 34832,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION_ESSENTIALS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.MILLING
                }
            }
        },
        UNDERSTANDING_FLORA_2 = {
            nodeID = 34832,
            threshold = 0,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION_ESSENTIALS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.MILLING
                }
            }
        },
        UNDERSTANDING_FLORA_3 = {
            nodeID = 34832,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION_ESSENTIALS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.MILLING
                }
            }
        },
        UNDERSTANDING_FLORA_4 = {
            nodeID = 34832,
            threshold = 10,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION_ESSENTIALS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.MILLING
                }
            }
        },
        UNDERSTANDING_FLORA_5 = {
            nodeID = 34832,
            threshold = 15,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION_ESSENTIALS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.MILLING
                }
            }
        },
        UNDERSTANDING_FLORA_6 = {
            nodeID = 34832,
            threshold = 20,
            resourcefulness = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INSCRIPTION_ESSENTIALS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.MILLING
                }
            }
        },
        FLAWLESS_INKS_1 = {
            nodeID = 34831,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        FLAWLESS_INKS_2 = {
            nodeID = 34831,
            threshold = 0,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        FLAWLESS_INKS_3 = {
            nodeID = 34831,
            threshold = 5,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        FLAWLESS_INKS_4 = {
            nodeID = 34831,
            threshold = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        FLAWLESS_INKS_5 = {
            nodeID = 34831,
            threshold = 15,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        FLAWLESS_INKS_6 = {
            nodeID = 34831,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        ARCHIVING_1 = { -- dm mapped, sk mapped, ss mapped
            childNodeIDs = {"DARKMOON_MYSTERIES_1", "SHARED_KNOWLEDGE_1", "SCALE_SIGILS_1"},
            nodeID = 43535,
            equalsSkill = true,
            idMapping = {
                -- dm mysteries
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                },
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                --- dm mysteries
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
                -- scale sigils
                383533, -- Azurescale Sigil
                383535, -- Emberscale Sigil
                383534, -- Sagescale Sigil
                383536, -- Bronzescale Sigil
                383538, -- Jetscale Sigil
            },
        },
        ARCHIVING_2 = {
            childNodeIDs = {"DARKMOON_MYSTERIES_1", "SHARED_KNOWLEDGE_1", "SCALE_SIGILS_1"},
            nodeID = 43535,
            threshold = 5,
            inspiration = 5,
            idMapping = {
                -- dm mysteries
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                },
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                --- dm mysteries
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
                -- scale sigils
                383533, -- Azurescale Sigil
                383535, -- Emberscale Sigil
                383534, -- Sagescale Sigil
                383536, -- Bronzescale Sigil
                383538, -- Jetscale Sigil
            },
        },
        ARCHIVING_3 = {
            childNodeIDs = {"DARKMOON_MYSTERIES_1", "SHARED_KNOWLEDGE_1", "SCALE_SIGILS_1"},
            nodeID = 43535,
            threshold = 15,
            resourcefulness = 5,
            idMapping = {
                -- dm mysteries
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                },
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                --- dm mysteries
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
                -- scale sigils
                383533, -- Azurescale Sigil
                383535, -- Emberscale Sigil
                383534, -- Sagescale Sigil
                383536, -- Bronzescale Sigil
                383538, -- Jetscale Sigil
            },
        },
        ARCHIVING_4 = {
            childNodeIDs = {"DARKMOON_MYSTERIES_1", "SHARED_KNOWLEDGE_1", "SCALE_SIGILS_1"},
            nodeID = 43535,
            threshold = 25,
            inspiration = 5,
            craftingspeedBonusFactor = 0.05,
            idMapping = {
                -- dm mysteries
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                },
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
            exceptionRecipeIDs = {
                --- dm mysteries
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
                -- scale sigils
                383533, -- Azurescale Sigil
                383535, -- Emberscale Sigil
                383534, -- Sagescale Sigil
                383536, -- Bronzescale Sigil
                383538, -- Jetscale Sigil
            },
        },
        DARKMOON_MYSTERIES_1 = { -- fire mapped, frost mapped, air mapped, earth mapped
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            equalsSkill = true,
            idMapping = {
                -- dm mysteries
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                }
            },
            exceptionRecipeIDs = {
                --- dm mysteries
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        DARKMOON_MYSTERIES_2 = {
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        DARKMOON_MYSTERIES_3 = {
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            threshold = 15,
            skill = 5,
            exceptionRecipeIDs = {
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        DARKMOON_MYSTERIES_4 = {
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            threshold = 20,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                }
            },
        },
        DARKMOON_MYSTERIES_5 = {
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            threshold = 25,
            inspiration = 10,
            craftingspeedBonusFactor = 0.10,
            exceptionRecipeIDs = {
                --fire
                383325, -- Darkmoon Deck Box: Inferno
                -- frost
                383767, -- Darkmoon Deck Box: Rime
                --air
                383770, -- Darkmoon Deck Box: Dance
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        DARKMOON_MYSTERIES_6 = {
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            threshold = 30,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                }
            },
        },
        DARKMOON_MYSTERIES_7 = {
            childNodeIDs = {"FIRE_1", "FROST_1", "AIR_1", "EARTH_1"},
            nodeID = 43534,
            threshold = 40,
            multicraft = 40,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MYSTERIES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.BUNDLE_O_CARDS
                }
            },
        },
        FIRE_1 = {
            nodeID = 43533,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --fire
                383325, -- Darkmoon Deck Box: Inferno
            },
        },
        FIRE_2 = {
            nodeID = 43533,
            threshold = 15,
            skill = 5,
            exceptionRecipeIDs = {
                383325, -- Darkmoon Deck Box: Inferno
            },
        },
        FIRE_3 = {
            nodeID = 43533,
            threshold = 25,
            skill = 10,
            exceptionRecipeIDs = {
                383325, -- Darkmoon Deck Box: Inferno
            },
        },
        FROST_1 = {
            nodeID = 43532,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- frost
                383767, -- Darkmoon Deck Box: Rime
            },
        },
        FROST_2 = {
            nodeID = 43532,
            threshold = 15,
            skill = 5,
            exceptionRecipeIDs = {
                383767, -- Darkmoon Deck Box: Rime
            },
        },
        FROST_3 = {
            nodeID = 43532,
            threshold = 25,
            skill = 10,
            exceptionRecipeIDs = {
                383767, -- Darkmoon Deck Box: Rime
            },
        },
        AIR_1 = {
            nodeID = 43531,
            equalsSkill = true,
            exceptionRecipeIDs = {
                --air
                383770, -- Darkmoon Deck Box: Dance
            },
        },
        AIR_2 = {
            nodeID = 43531,
            threshold = 15,
            skill = 5,
            exceptionRecipeIDs = {
                383770, -- Darkmoon Deck Box: Dance
            },
        },
        AIR_3 = {
            nodeID = 43531,
            threshold = 25,
            skill = 10,
            exceptionRecipeIDs = {
                383770, -- Darkmoon Deck Box: Dance
            },
        },
        EARTH_1 = {
            nodeID = 43530,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- earth
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        EARTH_2 = {
            nodeID = 43530,
            threshold = 15,
            skill = 5,
            exceptionRecipeIDs = {
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        EARTH_3 = {
            nodeID = 43530,
            threshold = 25,
            skill = 10,
            exceptionRecipeIDs = {
                383772, -- Darkmoon Deck Box: Watcher
            },
        },
        SHARED_KNOWLEDGE_1 = { -- c and m mapped, dt mapped
            childNodeIDs = {"CONTRACTS_AND_MISSIVES_1", "DRACONIC_TREATISES_1"},
            nodeID = 43529,
            equalsResourcefulness = true,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
            },
        },
        SHARED_KNOWLEDGE_2 = {
            childNodeIDs = {"CONTRACTS_AND_MISSIVES_1", "DRACONIC_TREATISES_1"},
            nodeID = 43529,
            threshold = 0,
            resourcefulness = 5,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        SHARED_KNOWLEDGE_3 = {
            childNodeIDs = {"CONTRACTS_AND_MISSIVES_1", "DRACONIC_TREATISES_1"},
            nodeID = 43529,
            threshold = 5,
            resourcefulness = 5,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        SHARED_KNOWLEDGE_4 = {
            childNodeIDs = {"CONTRACTS_AND_MISSIVES_1", "DRACONIC_TREATISES_1"},
            nodeID = 43529,
            threshold = 15,
            resourcefulness = 5,
            multicraft = 10,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        SHARED_KNOWLEDGE_5 = {
            childNodeIDs = {"CONTRACTS_AND_MISSIVES_1", "DRACONIC_TREATISES_1"},
            nodeID = 43529,
            threshold = 25,
            resourcefulness = 5,
            craftingspeedBonusFactor = 0.05,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        SHARED_KNOWLEDGE_6 = {
            childNodeIDs = {"CONTRACTS_AND_MISSIVES_1", "DRACONIC_TREATISES_1"},
            nodeID = 43529,
            threshold = 30,
            resourcefulness = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        CONTRACTS_AND_MISSIVES_1 = {
            nodeID = 43528,
            equalsSkill = true,
            idMapping = {
                -- contracts and missives
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        CONTRACTS_AND_MISSIVES_2 = {
            nodeID = 43528,
            threshold = 0,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        CONTRACTS_AND_MISSIVES_3 = {
            nodeID = 43528,
            threshold = 5,
            inspiration = 5,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        CONTRACTS_AND_MISSIVES_4 = {
            nodeID = 43528,
            threshold = 10,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        CONTRACTS_AND_MISSIVES_5 = {
            nodeID = 43528,
            threshold = 15,
            inspiration = 5,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        CONTRACTS_AND_MISSIVES_6 = {
            nodeID = 43528,
            threshold = 20,
            inspiration = 10,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CONTRACTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.CRAFTING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.GATHERING_TOOL_MISSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        DRACONIC_TREATISES_1 = {
            nodeID = 43527,
            equalsResourcefulness = true,
            idMapping = {
                -- draconic treatises
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        DRACONIC_TREATISES_2 = {
            nodeID = 43527,
            threshold = 5,
            resourcefulness = 5,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        DRACONIC_TREATISES_3 = {
            nodeID = 43527,
            threshold = 10,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        DRACONIC_TREATISES_4 = {
            nodeID = 43527,
            threshold = 15,
            resourcefulness = 5,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        DRACONIC_TREATISES_5 = {
            nodeID = 43527,
            threshold = 20,
            resourcefulness = 10,
            craftingspeedBonusFactor = 0.05,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.DRACONIC_TREATISES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        SCALE_SIGILS_1 = { -- all mapped
            childNodeIDs = {"AZURESCALE_SIGIL_1", "EMBERSCALE_SIGIL_1", "SAGESCALE_SIGIL_1", "BRONZESCALE_SIGIL_1", "JETSCALE_SIGIL_1"},
            nodeID = 43526,
            equalsSkill = true,
            exceptionRecipeIDs = {
                -- scale sigils
                383533, -- Azurescale Sigil
                383535, -- Emberscale Sigil
                383534, -- Sagescale Sigil
                383536, -- Bronzescale Sigil
                383538, -- Jetscale Sigil
            },
        },
        AZURESCALE_SIGIL_1 = {
            nodeID = 43525,
            equalsSkill = true,
            exceptionRecipeIDs = {
                383533, -- Azurescale Sigil
            },
        },
        AZURESCALE_SIGIL_2 = {
            nodeID = 43525,
            threshold = 5,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                383533, -- Azurescale Sigil
            },
        },
        AZURESCALE_SIGIL_3 = {
            nodeID = 43525,
            threshold = 10,
            inspiration = 5,
            exceptionRecipeIDs = {
                383533, -- Azurescale Sigil
            },
        },
        EMBERSCALE_SIGIL_1 = {
            nodeID = 43524,
            equalsSkill = true,
            exceptionRecipeIDs = {
                383535, -- Emberscale Sigil
            },
        },
        EMBERSCALE_SIGIL_2 = {
            nodeID = 43524,
            threshold = 5,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                383535, -- Emberscale Sigil
            },
        },
        EMBERSCALE_SIGIL_3 = {
            nodeID = 43524,
            threshold = 10,
            inspiration = 5,
            exceptionRecipeIDs = {
                383535, -- Emberscale Sigil
            },
        },
        SAGESCALE_SIGIL_1 = {
            nodeID = 43523,
            equalsSkill = true,
            exceptionRecipeIDs = {
                383534, -- Sagescale Sigil
            },
        },
        SAGESCALE_SIGIL_2 = {
            nodeID = 43523,
            threshold = 5,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                383534, -- Sagescale Sigil
            },
        },
        SAGESCALE_SIGIL_3 = {
            nodeID = 43523,
            threshold = 10,
            inspiration = 5,
            exceptionRecipeIDs = {
                383534, -- Sagescale Sigil
            },
        },
        BRONZESCALE_SIGIL_1 = {
            nodeID = 43522,
            equalsSkill = true,
            exceptionRecipeIDs = {
                383536, -- Bronzescale Sigil
            },
        },
        BRONZESCALE_SIGIL_2 = {
            nodeID = 43522,
            threshold = 5,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                383536, -- Bronzescale Sigil
            },
        },
        BRONZESCALE_SIGIL_3 = {
            nodeID = 43522,
            threshold = 10,
            inspiration = 5,
            exceptionRecipeIDs = {
                383536, -- Bronzescale Sigil
            },
        },
        JETSCALE_SIGIL_1 = {
            nodeID = 43521,
            equalsSkill = true,
            exceptionRecipeIDs = {
                383538, -- Jetscale Sigil
            },
        },
        JETSCALE_SIGIL_2 = {
            nodeID = 43521,
            threshold = 5,
            resourcefulness = 5,
            exceptionRecipeIDs = {
                383538, -- Jetscale Sigil
            },
        },
        JETSCALE_SIGIL_3 = {
            nodeID = 43521,
            threshold = 10,
            inspiration = 5,
            exceptionRecipeIDs = {
                383538, -- Jetscale Sigil
            },
        },
        RUNEBINDING_1 = { -- woodcarving mapped, rs mapped
            childNodeIDs = {"WOODCARVING_1", "RUNIC_SCRIPTURE_1"},
            nodeID = 34893,
            equalsSkill = true,
            idMapping = {
                --- woodcarving
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    -- staves
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES,
                    -- codexes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNEBINDING_2 = {
            childNodeIDs = {"WOODCARVING_1", "RUNIC_SCRIPTURE_1"},
            nodeID = 34893,
            threshold = 5,
            resourcefulness = 5,
            idMapping = {
                --- woodcarving
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    -- staves
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES,
                    -- codexes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNEBINDING_3 = {
            childNodeIDs = {"WOODCARVING_1", "RUNIC_SCRIPTURE_1"},
            nodeID = 34893,
            threshold = 15,
            resourcefulness = 5,
            idMapping = {
                --- woodcarving
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    -- staves
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES,
                    -- codexes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNEBINDING_4 = {
            childNodeIDs = {"WOODCARVING_1", "RUNIC_SCRIPTURE_1"},
            nodeID = 34893,
            threshold = 25,
            inspiration = 5,
            idMapping = {
                --- woodcarving
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    -- staves
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES,
                    -- codexes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNEBINDING_5 = {
            childNodeIDs = {"WOODCARVING_1", "RUNIC_SCRIPTURE_1"},
            nodeID = 34893,
            threshold = 30,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                --- woodcarving
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    -- staves
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES,
                    -- codexes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        WOODCARVING_1 = { -- tools mapped, staves mapped
            childNodeIDs = {"PROFESSION_TOOLS_1", "STAVES_1"},
            nodeID = 34892,
            equalsSkill = true,
            idMapping = {
                --- woodcarving
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- staves
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        WOODCARVING_2 = {
            childNodeIDs = {"PROFESSION_TOOLS_1", "STAVES_1"},
            nodeID = 34892,
            threshold = 5,
            inspiration = 5,
            idMapping = {
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- staves
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        WOODCARVING_3 = {
            childNodeIDs = {"PROFESSION_TOOLS_1", "STAVES_1"},
            nodeID = 34892,
            threshold = 15,
            inspiration = 5,
            idMapping = {
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- staves
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        WOODCARVING_4 = {
            childNodeIDs = {"PROFESSION_TOOLS_1", "STAVES_1"},
            nodeID = 34892,
            threshold = 25,
            inspiration = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- staves
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        WOODCARVING_5 = {
            childNodeIDs = {"PROFESSION_TOOLS_1", "STAVES_1"},
            nodeID = 34892,
            threshold = 30,
            skill = 10,
            idMapping = {
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                },
                -- staves
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        PROFESSION_TOOLS_1 = {
            nodeID = 34891,
            equalsSkill = true,
            idMapping = {
                -- prof tools
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        PROFESSION_TOOLS_2 = {
            nodeID = 34891,
            threshold = 0,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        PROFESSION_TOOLS_3 = {
            nodeID = 34891,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        PROFESSION_TOOLS_4 = {
            nodeID = 34891,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL
                }
            },
        },
        STAVES_1 = {
            nodeID = 34890,
            equalsSkill = true,
            idMapping = {
                -- staves
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        STAVES_2 = {
            nodeID = 34890,
            threshold = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        STAVES_3 = {
            nodeID = 34890,
            threshold = 15,
            inspiration = 10,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        STAVES_4 = {
            nodeID = 34890,
            threshold = 20,
            skill = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        STAVES_5 = {
            nodeID = 34890,
            threshold = 30,
            inspiration = 15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.STAVES
                }
            },
        },
        RUNIC_SCRIPTURE_1 = { -- codexes mapped, vr mapped, fauna runes mapped
            childNodeIDs = {"CODEXES_1", "VANTUS_RUNES_1", "FAUNA_RUNES_1"},
            nodeID = 34889,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    -- codexes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNIC_SCRIPTURE_2 = {
            childNodeIDs = {"CODEXES_1", "VANTUS_RUNES_1", "FAUNA_RUNES_1"},
            nodeID = 34889,
            threshold = 5,
            inspiration = 5,
            idMapping = {
                -- codexes
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNIC_SCRIPTURE_3 = {
            childNodeIDs = {"CODEXES_1", "VANTUS_RUNES_1", "FAUNA_RUNES_1"},
            nodeID = 34889,
            threshold = 15,
            inspiration = 10,
            idMapping = {
                -- codexes
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNIC_SCRIPTURE_4 = {
            childNodeIDs = {"CODEXES_1", "VANTUS_RUNES_1", "FAUNA_RUNES_1"},
            nodeID = 34889,
            threshold = 25,
            inspiration = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                -- codexes
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        RUNIC_SCRIPTURE_5 = {
            childNodeIDs = {"CODEXES_1", "VANTUS_RUNES_1", "FAUNA_RUNES_1"},
            nodeID = 34889,
            threshold = 30,
            skill = 10,
            idMapping = {
                -- codexes
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES,
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                },
            },
        },
        CODEXES_1 = {
            nodeID = 34888,
            equalsSkill = true,
            idMapping = {
                -- codexes
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                }
            },
        },
        CODEXES_2 = {
            nodeID = 34888,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                }
            },
        },
        CODEXES_3 = {
            nodeID = 34888,
            threshold = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                }
            },
        },
        CODEXES_4 = {
            nodeID = 34888,
            threshold = 15,
            inspiration = 15,
            resourcefulness = 15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                }
            },
        },
        CODEXES_5 = {
            nodeID = 34888,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                }
            },
        },
        CODEXES_6 = {
            nodeID = 34888,
            threshold = 30,
            inspiration = 15,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.OFFHANDS
                }
            },
        },
        VANTUS_RUNES_1 = {
            nodeID = 34887,
            equalsResourcefulness = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- vantus runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES
                },
            },
        },
        VANTUS_RUNES_2 = {
            nodeID = 34887,
            threshold = 0,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES
                }
            },
        },
        VANTUS_RUNES_3 = {
            nodeID = 34887,
            threshold = 5,
            resourcefulness = 5,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES
                }
            },
        },
        VANTUS_RUNES_4 = {
            nodeID = 34887,
            threshold = 10,
            resourcefulness = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES
                }
            },
        },
        VANTUS_RUNES_5 = {
            nodeID = 34887,
            threshold = 15,
            multicraft = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES
                }
            },
        },
        VANTUS_RUNES_6 = {
            nodeID = 34887,
            threshold = 20,
            craftingspeedBonusFactor = 0.20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.VANTUS_RUNES
                }
            },
        },
        FAUNA_RUNES_1 = {
            nodeID = 34886,
            equalsResourcefulness = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    -- fauna runes
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                }
            },
        },
        FAUNA_RUNES_2 = {
            nodeID = 34886,
            threshold = 0,
            resourcefulness = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                }
            },
        },
        FAUNA_RUNES_3 = {
            nodeID = 34886,
            threshold = 5,
            resourcefulness = 5,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                }
            },
        },
        FAUNA_RUNES_4 = {
            nodeID = 34886,
            threshold = 10,
            resourcefulness = 10,
            inspiration = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                }
            },
        },
        FAUNA_RUNES_5 = {
            nodeID = 34886,
            threshold = 15,
            multicraft = 10,
            craftingspeedBonusFactor = 0.10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                }
            },
        },
        FAUNA_RUNES_6 = {
            nodeID = 34886,
            threshold = 20,
            craftingspeedBonusFactor = 0.20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.RUNES_AND_SIGILS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.FAUNA_RUNES
                }
            },
        },
    }
end