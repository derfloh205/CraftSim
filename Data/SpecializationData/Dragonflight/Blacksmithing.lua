---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.DRAGONFLIGHT.BLACKSMITHING_DATA = {
    -- HAMMER CONTROL
    HAMMER_CONTROL_1 = { -- mapped
        childNodeIDs = { "SAFETY_SMITHING_1", "POIGNANT_PLANS_1" },
        nodeID = 42828,
        equalsSkill = 1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HAMMER_CONTROL_2 = {
        childNodeIDs = { "SAFETY_SMITHING_1", "POIGNANT_PLANS_1" },
        nodeID = 42828,
        threshold = 0,
        craftingspeedBonusFactor = 0.15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HAMMER_CONTROL_3 = {
        childNodeIDs = { "SAFETY_SMITHING_1", "POIGNANT_PLANS_1" },
        nodeID = 42828,
        threshold = 5,
        skill = 3,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HAMMER_CONTROL_4 = {
        childNodeIDs = { "SAFETY_SMITHING_1", "POIGNANT_PLANS_1" },
        nodeID = 42828,
        threshold = 15,
        skill = 4,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HAMMER_CONTROL_5 = {
        childNodeIDs = { "SAFETY_SMITHING_1", "POIGNANT_PLANS_1" },
        nodeID = 42828,
        threshold = 25,
        skill = 3,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    HAMMER_CONTROL_6 = {
        childNodeIDs = { "SAFETY_SMITHING_1", "POIGNANT_PLANS_1" },
        nodeID = 42828,
        threshold = 30,
        craftingspeedBonusFactor = 0.10,
        resourcefulness = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SAFETY_SMITHING_1 = {
        nodeID = 42827,
        threshold = 0,
        resourcefulnessExtraItemsFactor = 0.05,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SAFETY_SMITHING_2 = {
        nodeID = 42827,
        threshold = 10,
        resourcefulnessExtraItemsFactor = 0.10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SAFETY_SMITHING_3 = {
        nodeID = 42827,
        threshold = 20,
        resourcefulnessExtraItemsFactor = 0.10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SAFETY_SMITHING_4 = {
        nodeID = 42827,
        threshold = 30,
        resourcefulnessExtraItemsFactor = 0.25,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    SAFETY_SMITHING_5 = {
        nodeID = 42827,
        equalsResourcefulness = 1,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_1 = {
        nodeID = 42826,

        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_2 = {
        nodeID = 42826,
        threshold = 0,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_3 = {
        nodeID = 42826,
        threshold = 5,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_4 = {
        nodeID = 42826,
        threshold = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_5 = {
        nodeID = 42826,
        threshold = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_6 = {
        nodeID = 42826,
        threshold = 20,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_7 = {
        nodeID = 42826,
        threshold = 25,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    POIGNANT_PLANS_8 = {
        nodeID = 42826,
        threshold = 30,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    -- Speciality Smithing
    SPECIALITY_SMITHING_1 = { -- tools mapped, stonework mapped, smelting mapped
        childNodeIDs = { "TOOLSMITHING_1", "STONEWORK_1", "SMELTING_1" },
        nodeID = 23765,
        equalsSkill = 1,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    SPECIALITY_SMITHING_2 = {
        childNodeIDs = { "TOOLSMITHING_1", "STONEWORK_1", "SMELTING_1" },
        nodeID = 23765,
        threshold = 0,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    SPECIALITY_SMITHING_3 = {
        childNodeIDs = { "TOOLSMITHING_1", "STONEWORK_1", "SMELTING_1" },
        nodeID = 23765,
        threshold = 10,
        resourcefulness = 5,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    SPECIALITY_SMITHING_4 = {
        childNodeIDs = { "TOOLSMITHING_1", "STONEWORK_1", "SMELTING_1" },
        nodeID = 23765,
        threshold = 20,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    SPECIALITY_SMITHING_5 = {
        childNodeIDs = { "TOOLSMITHING_1", "STONEWORK_1", "SMELTING_1" },
        nodeID = 23765,
        threshold = 25,
        craftingspeedBonusFactor = 0.2,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    SPECIALITY_SMITHING_6 = {
        childNodeIDs = { "TOOLSMITHING_1", "STONEWORK_1", "SMELTING_1" },
        nodeID = 23765,
        threshold = 30,
        resourcefulness = 5,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    TOOLSMITHING_1 = {
        nodeID = 23764,
        equalsSkill = 1,
        idMapping = {
            -- toolsmithing
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    TOOLSMITHING_2 = {
        nodeID = 23764,
        threshold = 0,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    TOOLSMITHING_3 = {
        nodeID = 23764,
        threshold = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    TOOLSMITHING_4 = {
        nodeID = 23764,
        threshold = 15,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    TOOLSMITHING_5 = {
        nodeID = 23764,
        threshold = 20,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    TOOLSMITHING_6 = {
        nodeID = 23764,
        threshold = 25,
        skill = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.BLACKSMITHING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.LEATHERWORKING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SKINNING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.TAILORING,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    STONEWORK_1 = {
        nodeID = 23762,
        equalsSkill = 1,
        idMapping = {
            -- stonework
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
        },
    },
    STONEWORK_2 = {
        nodeID = 23762,
        threshold = 0,
        multicraft = 20,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
        },
    },
    STONEWORK_3 = {
        nodeID = 23762,
        threshold = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
        },
    },
    STONEWORK_4 = {
        nodeID = 23762,
        threshold = 10,
        multicraft = 40,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
        },
    },
    STONEWORK_5 = {
        nodeID = 23762,
        threshold = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
        },
    },
    STONEWORK_6 = {
        nodeID = 23762,
        threshold = 20,
        multicraftExtraItemsFactor = 0.50,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.STONEWORK] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.STONEWORK
            },
        },
    },
    SMELTING_1 = {
        nodeID = 23761,
        equalsSkill = 1,
        idMapping = {
            -- smelting
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            },
        },
    },
    SMELTING_2 = {
        nodeID = 23761,
        threshold = 0,
        multicraft = 20,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            }
        },
    },
    SMELTING_3 = {
        nodeID = 23761,
        threshold = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            }
        },
    },
    SMELTING_4 = {
        nodeID = 23761,
        threshold = 10,
        multicraft = 20,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            }
        },
    },
    SMELTING_5 = {
        nodeID = 23761,
        threshold = 15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            }
        },
    },
    SMELTING_6 = {
        nodeID = 23761,
        threshold = 20,
        multicraftExtraItemsFactor = 0.50,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SMELTING] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.METAL_AND_STONE
            }
        },
    },
    -- Weapon Smithing
    WEAPON_SMITHING_1 = { -- blades mapped, hafted mapped
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 23727,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                --- blades
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
        },
        exceptionRecipeIDs = {
            -- blades
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
            -- hafted
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    WEAPON_SMITHING_2 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 23727,
        threshold = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                --- blades
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
        },
        exceptionRecipeIDs = {
            -- blades
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
            -- hafted
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    WEAPON_SMITHING_3 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 23727,
        threshold = 15,
        resourcefulness = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                --- blades
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
        },
        exceptionRecipeIDs = {
            -- blades
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
            -- hafted
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    WEAPON_SMITHING_4 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 23727,
        threshold = 25,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                --- blades
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
        },
        exceptionRecipeIDs = {
            -- blades
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
            -- hafted
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    WEAPON_SMITHING_5 = {
        childNodeIDs = { "BLADES_1", "HAFTED_1" },
        nodeID = 23727,
        threshold = 30,
        resourcefulness = 15,
        craftingspeedBonusFactor = 0.15,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                --- blades
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES,
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H,
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            },
        },
        exceptionRecipeIDs = {
            -- blades
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
            -- hafted
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    HAFTED_1 = { -- axes mapped, maces mapped
        childNodeIDs = { "AXES_1", "MACES_1" },
        nodeID = 23723,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- hafted
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
        exceptionRecipeIDs = {
            -- hafted
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        },
    },
    HAFTED_2 = {
        childNodeIDs = { "AXES_1", "MACES_1" },
        nodeID = 23723,
        threshold = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
        exceptionRecipeIDs = {
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        },
    },
    HAFTED_3 = {
        childNodeIDs = { "AXES_1", "MACES_1" },
        nodeID = 23723,
        threshold = 10,
        resourcefulness = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
        exceptionRecipeIDs = {
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        },
    },
    HAFTED_4 = {
        childNodeIDs = { "AXES_1", "MACES_1" },
        nodeID = 23723,
        threshold = 25,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H,
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
        exceptionRecipeIDs = {
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        },
    },
    AXES_1 = {
        nodeID = 23721,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                -- axes
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    AXES_2 = {
        nodeID = 23721,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    AXES_3 = {
        nodeID = 23721,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    AXES_4 = {
        nodeID = 23721,
        threshold = 20,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.POLEARM,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.AXE_2H
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MINING
            }
        },
    },
    MACES_1 = {
        nodeID = 23722,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- maces
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            }
        },
        exceptionRecipeIDs = {
            -- maces
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    MACES_2 = {
        nodeID = 23722,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            }
        },
        exceptionRecipeIDs = {
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    MACES_3 = {
        nodeID = 23722,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            }
        },
        exceptionRecipeIDs = {
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    MACES_4 = {
        nodeID = 23722,
        threshold = 20,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.MACE_1H
            }
        },
        exceptionRecipeIDs = {
            371372, -- epic hammer
            371412, -- blue hammer
        }
    },
    BLADES_1 = { -- short blades mapped, long blades mapped
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 23726,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            }
        },
        exceptionRecipeIDs = {
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    BLADES_2 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 23726,
        threshold = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            }
        },
        exceptionRecipeIDs = {
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    BLADES_3 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 23726,
        threshold = 15,
        resourcefulness = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            }
        },
        exceptionRecipeIDs = {
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    BLADES_4 = {
        childNodeIDs = { "SHORT_BLADES_1", "LONG_BLADES_1" },
        nodeID = 23726,
        threshold = 25,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST,
                -- long blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            }
        },
        exceptionRecipeIDs = {
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    SHORT_BLADES_1 = {
        nodeID = 23725,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                -- short blades
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST
            }
        },
        exceptionRecipeIDs = {
            -- short blades
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    SHORT_BLADES_2 = {
        nodeID = 23725,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST
            }
        },
        exceptionRecipeIDs = {
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    SHORT_BLADES_3 = {
        nodeID = 23725,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST
            }
        },
        exceptionRecipeIDs = {
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    SHORT_BLADES_4 = {
        nodeID = 23725,
        threshold = 20,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.DAGGERS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.FIST
            }
        },
        exceptionRecipeIDs = {
            371369, -- blue lw knife
            371367, -- blue sk knife
            371338, -- green lw knife
            371304, -- green sk knife
        }
    },
    LONG_BLADES_1 = {
        nodeID = 23724,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM
            }
        },
    },
    LONG_BLADES_2 = {
        nodeID = 23724,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM
            }
        },
    },
    LONG_BLADES_3 = {
        nodeID = 23724,
        threshold = 15,
        skill = 10,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM
            }
        },
    },
    LONG_BLADES_4 = {
        nodeID = 23724,
        threshold = 20,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.WEAPONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_1H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SWORDS_2H,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.WARGLAIVES
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.TOOLS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.HERBALISM
            }
        }
    },
    -- Armor Smithing
    ARMOR_SMITHING_1 = { -- large plate mapped, sculpted armor mapped, fine armor mapped
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 23912,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            --- large plate armor
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
            --- sculpted armor
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
            --- fine armor
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                --- large plate armor
                -- shields
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    ARMOR_SMITHING_2 = {
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 23912,
        threshold = 5,
        exceptionRecipeIDs = {
            --- large plate armor
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
            --- sculpted armor
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
            --- fine armor
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                --- large plate armor
                -- shields
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    ARMOR_SMITHING_3 = {
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 23912,
        threshold = 15,
        resourcefulness = 5,
        exceptionRecipeIDs = {
            --- large plate armor
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
            --- sculpted armor
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
            --- fine armor
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                --- large plate armor
                -- shields
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    ARMOR_SMITHING_4 = {
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 23912,
        threshold = 25,
        exceptionRecipeIDs = {
            --- large plate armor
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
            --- sculpted armor
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
            --- fine armor
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                --- large plate armor
                -- shields
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    ARMOR_SMITHING_5 = {
        childNodeIDs = { "LARGE_PLATE_ARMOR_1", "SCULPTED_ARMOR_1", "FINE_ARMOR_1" },
        nodeID = 23912,
        threshold = 30,
        resourcefulness = 15,
        craftingspeedBonusFactor = 0.15,
        exceptionRecipeIDs = {
            --- large plate armor
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
            --- sculpted armor
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
            --- fine armor
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                --- large plate armor
                -- shields
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    LARGE_PLATE_ARMOR_1 = { -- breastplates mapped, shields mapped, greaves mapped
        childNodeIDs = { "BREASTPLATES_1", "SHIELDS_1", "GREAVES_1" },
        nodeID = 23911,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            --- large plate armor
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                --- large plate armor
                -- shields
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    LARGE_PLATE_ARMOR_2 = {
        childNodeIDs = { "BREASTPLATES_1", "SHIELDS_1", "GREAVES_1" },
        nodeID = 23911,
        threshold = 5,
        exceptionRecipeIDs = {
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    LARGE_PLATE_ARMOR_3 = {
        childNodeIDs = { "BREASTPLATES_1", "SHIELDS_1", "GREAVES_1" },
        nodeID = 23911,
        threshold = 15,
        resourcefulness = 10,
        exceptionRecipeIDs = {
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    LARGE_PLATE_ARMOR_4 = {
        childNodeIDs = { "BREASTPLATES_1", "SHIELDS_1", "GREAVES_1" },
        nodeID = 23911,
        threshold = 25,
        exceptionRecipeIDs = {
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    BREASTPLATES_1 = {
        nodeID = 23910,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- breastplates
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
        },
    },
    BREASTPLATES_2 = {
        nodeID = 23910,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
        },
    },
    BREASTPLATES_3 = {
        nodeID = 23910,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
        },
    },
    BREASTPLATES_4 = {
        nodeID = 23910,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
        },
    },
    BREASTPLATES_5 = {
        nodeID = 23910,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            376618, -- pvp green breast
            395886, -- blue breast
            367608, -- epic breast
            367615, -- epic breast
        },
    },
    SHIELDS_1 = {
        nodeID = 23909,
        equalsSkill = 1,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    SHIELDS_2 = {
        nodeID = 23909,
        threshold = 5,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    SHIELDS_3 = {
        nodeID = 23909,
        threshold = 10,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    SHIELDS_4 = {
        nodeID = 23909,
        threshold = 15,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    SHIELDS_5 = {
        nodeID = 23909,
        threshold = 25,
        skill = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.BLACKSMITHING.DRAGONFLIGHT.SHIELDS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.SHIELDS
            }
        },
    },
    GREAVES_1 = {
        nodeID = 23908,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- greaves
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
    },
    GREAVES_2 = {
        nodeID = 23908,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
    },
    GREAVES_3 = {
        nodeID = 23908,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
    },
    GREAVES_4 = {
        nodeID = 23908,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
    },
    GREAVES_5 = {
        nodeID = 23908,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            376620, -- pvp green
            395881, -- blue
            367619, -- epic
            367604, -- epic
        },
    },
    SCULPTED_ARMOR_1 = { -- helms mapped, pauldrons mapped, sabatons mapped
        childNodeIDs = { "HELMS_1", "PAULDRONS_1", "SABATONS_1" },
        nodeID = 23907,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            --- sculpted armor
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SCULPTED_ARMOR_2 = {
        childNodeIDs = { "HELMS_1", "PAULDRONS_1", "SABATONS_1" },
        nodeID = 23907,
        threshold = 5,
        exceptionRecipeIDs = {
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SCULPTED_ARMOR_3 = {
        childNodeIDs = { "HELMS_1", "PAULDRONS_1", "SABATONS_1" },
        nodeID = 23907,
        threshold = 15,
        resourcefulness = 10,
        exceptionRecipeIDs = {
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SCULPTED_ARMOR_4 = {
        childNodeIDs = { "HELMS_1", "PAULDRONS_1", "SABATONS_1" },
        nodeID = 23907,
        threshold = 25,
        exceptionRecipeIDs = {
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    HELMS_1 = {
        nodeID = 23906,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- helms
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
        },
    },
    HELMS_2 = {
        nodeID = 23906,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
        },
    },
    HELMS_3 = {
        nodeID = 23906,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
        },
    },
    HELMS_4 = {
        nodeID = 23906,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
        },
    },
    HELMS_5 = {
        nodeID = 23906,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            376621, -- pvp green
            395883, -- blue
            367617, -- epic
            367605, -- epic
        },
    },
    PAULDRONS_1 = {
        nodeID = 23905,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- pauldrons
            395880, -- blue
            376622, -- pvp
            367603, -- epic
        },
    },
    PAULDRONS_2 = {
        nodeID = 23905,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            395880, -- blue
            376622, -- pvp
            367603, -- epic
        },
    },
    PAULDRONS_3 = {
        nodeID = 23905,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            395880, -- blue
            376622, -- pvp
            367603, -- epic
        },
    },
    PAULDRONS_4 = {
        nodeID = 23905,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            395880, -- blue
            376622, -- pvp
            367603, -- epic
        },
    },
    PAULDRONS_5 = {
        nodeID = 23905,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            395880, -- blue
            376622, -- pvp
            367603, -- epic
        },
    },
    SABATONS_1 = {
        nodeID = 23904,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- sabatons
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SABATONS_2 = {
        nodeID = 23904,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SABATONS_3 = {
        nodeID = 23904,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SABATONS_4 = {
        nodeID = 23904,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    SABATONS_5 = {
        nodeID = 23904,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            367610, -- blue
            376623, -- pvp
            367616, -- epic
            367607, -- epic
        },
    },
    FINE_ARMOR_1 = { -- belts mapped, vambraces mapped, gauntlets mapped
        childNodeIDs = { "BELTS_1", "VAMBRACES_1", "GAUNTLETS_1" },
        nodeID = 23903,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            --- fine armor
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    FINE_ARMOR_2 = {
        childNodeIDs = { "BELTS_1", "VAMBRACES_1", "GAUNTLETS_1" },
        nodeID = 23903,
        threshold = 5,
        exceptionRecipeIDs = {
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    FINE_ARMOR_3 = {
        childNodeIDs = { "BELTS_1", "VAMBRACES_1", "GAUNTLETS_1" },
        nodeID = 23903,
        threshold = 15,
        resourcefulness = 10,
        exceptionRecipeIDs = {
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    FINE_ARMOR_4 = {
        childNodeIDs = { "BELTS_1", "VAMBRACES_1", "GAUNTLETS_1" },
        nodeID = 23903,
        threshold = 25,
        exceptionRecipeIDs = {
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    BELTS_1 = {
        nodeID = 23902,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- belts
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
        },
    },
    BELTS_2 = {
        nodeID = 23902,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
        },
    },
    BELTS_3 = {
        nodeID = 23902,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
        },
    },
    BELTS_4 = {
        nodeID = 23902,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
        },
    },
    BELTS_5 = {
        nodeID = 23902,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            367611, -- blue
            376624, -- pvp
            367602, -- epic
            367618, -- epic
            408288, -- belt clasp
        },
    },
    VAMBRACES_1 = {
        nodeID = 23901,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- vambraces
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
        },
    },
    VAMBRACES_2 = {
        nodeID = 23901,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
        },
    },
    VAMBRACES_3 = {
        nodeID = 23901,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
        },
    },
    VAMBRACES_4 = {
        nodeID = 23901,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
        },
    },
    VAMBRACES_5 = {
        nodeID = 23901,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            367609, -- blue
            376617, -- pvp
            367614, -- epic
            367601, -- epic
        },
    },
    GAUNTLETS_1 = {
        nodeID = 23900,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            -- gauntlets
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    GAUNTLETS_2 = {
        nodeID = 23900,
        threshold = 5,
        skill = 5,
        exceptionRecipeIDs = {
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    GAUNTLETS_3 = {
        nodeID = 23900,
        threshold = 10,
        skill = 5,
        exceptionRecipeIDs = {
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    GAUNTLETS_4 = {
        nodeID = 23900,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
    GAUNTLETS_5 = {
        nodeID = 23900,
        threshold = 25,
        skill = 5,
        exceptionRecipeIDs = {
            395879, -- blue
            376619, -- pvp
            367606, -- epic
        },
    },
}
