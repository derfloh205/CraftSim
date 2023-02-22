AddonName, CraftSim = ...

CraftSim.INSCRIPTION_DATA = {}

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
         RUNE_MASTERY_1 = {
            nodeID = 34835,
            childNodeIDs = {},
         },
         INFINITE_DISCOVERY_1 = {
            nodeID = 34833,
         },
         UNDERSTANDING_FLORA_1 = {
            nodeID = 34832,
         },
         FLAWLESS_INKS_1 = {
            nodeID = 34831,
         },
         ARCHIVING_1 = {
            nodeID = 43535,
         },
         DARKMOON_MYSTERIES_1 = {
            nodeID = 43534,
         },
         FIRE_1 = {
            nodeID = 43533,
         },
         FROST_1 = {
            nodeID = 43532,
         },
         AIR_1 = {
            nodeID = 43531,
         },
         EARTH_1 = {
            nodeID = 43530,
         },
         SHARED_KNOWLEDGE_1 = {
            nodeID = 43529,
         },
         CONTRACTS_AND_MISSIVES_1 = {
            nodeID = 43528,
         },
         DRACONIC_TREATISES_1 = {
            nodeID = 43527,
         },
         SCALE_SIGILS_1 = {
            nodeID = 43526,
         },
         AZURESCALE_SIGIL_1 = {
            nodeID = 43525,
         },
         EMBERSCALE_SIGIL_1 = {
            nodeID = 43524,
         },
         SAGESCALE_SIGIL_1 = {
            nodeID = 43523,
         },
         BRONZESCALE_SIGIL_1 = {
            nodeID = 43522,
         },
         JETSCALE_SIGIL_1 = {
            nodeID = 43521,
         },
         RUNEBINDING_1 = {
            nodeID = 34893,
         },
         WOODCARVING_1 = {
            nodeID = 34892,
         },
         PROFESSION_TOOLS_1 = {
            nodeID = 34891,
         },
         STAVES_1 = {
            nodeID = 34890,
         },
         RUNIC_SCRIPTURE_1 = {
            nodeID = 34889,
         },
         CODEXES_1 = {
            nodeID = 34888,
         },
         VANTUS_RUNES_1 = {
            nodeID = 34887,
         },
        FAUNA_RUNES_1 = {
            nodeID = 34886,
        },

        PERFECT_PRACTICE_1 = {
            nodeID = 34834,
            threshold = 0,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_2 = {
            nodeID = 34834,
            threshold = 10,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_3 = {
            nodeID = 34834,
            threshold = 20,
            resourcefulnessExtraItemsFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PERFECT_PRACTICE_4 = {
            nodeID = 34834,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        FLAWLESS_INKS = {
            nodeID = 34831,
            threshold = 20,
            multicraftExtraItemsFactor = 0.50,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.INSCRIPTION.INKS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.INSCRIPTION.INKS
                }
            },
        }
    }
end