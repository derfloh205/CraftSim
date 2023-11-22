CraftSimAddonName, CraftSim = ...

CraftSim.ENGINEERING_DATA = {}

CraftSim.ENGINEERING_DATA.NODE_IDS = {
    OPTIMIZED_EFFICIENCY = 50993,
    PIECES_PARTS = 50992,
    SCRAPPER = 50991,
    GENERALIST = 50990,
    EXPLOSIVES = 50894,
    CREATION = 50893,
    SHORT_FUSE = 50892,
    EZ_THRO = 50891,
    FUNCTION_OVER_FORM = 50929,
    GEAR = 50928,
    GEARS_FOR_GEAR = 50927,
    UTILITY = 50926,
    MECHANICAL_MIND = 50956,
    INVENTIONS = 50955,
    NOVELTIES = 50954
}

CraftSim.ENGINEERING_DATA.NODES = function()
    return {
        -- Optimized Efficiency
        {
            name = "Optimized Efficiency",
            nodeID = 50993
        },
        {
            name = "Pieces Parts",
            nodeID = 50992
        },
        {
            name = "Scrapper",
            nodeID = 50991
        },
        {
            name = "Generalist",
            nodeID = 50990
        },
        -- Explosives
        {
            name = "Explosives",
            nodeID = 50894
        },
        {
            name = "Creation",
            nodeID = 50893
        },
        {
            name = "Short Fuse",
            nodeID = 50892
        },
        {
            name = "EZ-Thro",
            nodeID = 50891
        },
        -- Function Over Form
        {
            name = "Function Over Form",
            nodeID = 50929
        },
        {
            name = "Gear",
            nodeID = 50928
        },
        {
            name = "Gears for Gear",
            nodeID = 50927
        },
        {
            name = "Utility",
            nodeID = 50926
        },
        -- Mechanical Mind
        {
            name = "Mechanical Mind",
            nodeID = 50956
        },
        {
            name = "Inventions",
            nodeID = 50955
        },
        {
            name = "Novelties",
            nodeID = 50954
        },
    }
end

function CraftSim.ENGINEERING_DATA:GetData()
    return {
        OPTIMIZED_EFFICIENCY_1 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            equalsSkill = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        OPTIMIZED_EFFICIENCY_2 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            threshold = 0,
            craftingspeedBonusFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        OPTIMIZED_EFFICIENCY_3 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            threshold = 10,
            inspiration = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        OPTIMIZED_EFFICIENCY_4 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            threshold = 20,
            multicraft = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        OPTIMIZED_EFFICIENCY_5 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            threshold = 25,
            inspiration = 25,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        OPTIMIZED_EFFICIENCY_6 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            threshold = 35,
            inspiration = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        OPTIMIZED_EFFICIENCY_7 = {
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
            nodeID = 50993,
            threshold = 40,
            inspirationBonusSkillFactor = 0.20,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        PIECES_PARTS_1 = {
            nodeID = 50992,
            equalsResourcefulness = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PARTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PARTS
                }
            },
        },
        PIECES_PARTS_2 = {
            nodeID = 50992,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PARTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PARTS
                }
            },
        },
        PIECES_PARTS_3 = {
            nodeID = 50992,
            threshold = 10,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PARTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PARTS
                }
            },
        },
        PIECES_PARTS_4 = {
            nodeID = 50992,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PARTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PARTS
                }
            },
        },
        PIECES_PARTS_5 = {
            nodeID = 50992,
            threshold = 25,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PARTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PARTS
                }
            },
        },
        SCRAPPER_1 = {
            nodeID = 50991,
            equalsResourcefulnessExtraItemsFactor = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SCRAPPER_2 = {
            nodeID = 50991,
            threshold = 5,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SCRAPPER_3 = {
            nodeID = 50991,
            threshold = 15,
            inspiration = 5,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SCRAPPER_4 = {
            nodeID = 50991,
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        SCRAPPER_5 = {
            nodeID = 50991,
            threshold = 35,
            resourcefulness = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_1 = {
            nodeID = 50990,
            equalsSkill = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_2 = {
            nodeID = 50990,
            threshold = 0,
            craftingspeedBonusFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_3 = {
            nodeID = 50990,
            threshold = 5,
            multicraft = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_4 = {
            nodeID = 50990,
            threshold = 10,
            multicraft = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_5 = {
            nodeID = 50990,
            threshold = 15,
            resourcefulness = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_6 = {
            nodeID = 50990,
            threshold = 20,
            resourcefulness = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_7 = {
            nodeID = 50990,
            threshold = 25,
            craftingspeedBonusFactor = 0.10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_8 = {
            nodeID = 50990,
            threshold = 30,
            multicraft = 10,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_9 = {
            nodeID = 50990,
            threshold = 40,
            resourcefulness = 15,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        EXPLOSIVES_1 = {
            childNodeIDs = {"CREATION_1", "SHORT_FUSE_1", "EZ_THRO_1"},
            nodeID = 50894,
            equalsSkill = true,
        },
        EXPLOSIVES_2 = {
            childNodeIDs = {"CREATION_1", "SHORT_FUSE_1", "EZ_THRO_1"},
            nodeID = 50894,
            threshold = 25,
            resourcefulness = 10,
        },
        CREATION_1 = {
            nodeID = 50893,
            equalsResourcefulness = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.EXPLOSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER_BOMB_CRATES
                }
            },
        },
        CREATION_2 = {
            nodeID = 50893,
            threshold = 0,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.EXPLOSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER_BOMB_CRATES
                }
            },
        },
        CREATION_3 = {
            nodeID = 50893,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.EXPLOSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER_BOMB_CRATES
                }
            },
        },
        CREATION_4 = {
            nodeID = 50893,
            threshold = 10,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.EXPLOSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER_BOMB_CRATES
                }
            },
        },
        CREATION_5 = {
            nodeID = 50893,
            threshold = 15,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.EXPLOSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER_BOMB_CRATES
                }
            },
        },
        CREATION_6 = {
            nodeID = 50893,
            threshold = 20,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.EXPLOSIVES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.EXPLOSIVES_AND_DEVICES,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER_BOMB_CRATES
                }
            },
        },
        SHORT_FUSE_1 = {
            nodeID = 50892,
            equalsSkill = true,
            exceptionRecipeIDs = {
                382343, -- gravitational displacer
                382323, -- grease grenade
                382322, -- primal deconstruction charge
                382330, -- creature combustion canister
                382354, -- suspiciously ticking crate
                382333, -- sticky warp grenade
                382353, -- I.W.I.N button mk10
            },
        },
        SHORT_FUSE_2 = {
            nodeID = 50892,
            threshold = 10,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                382343, -- gravitational displacer
                382323, -- grease grenade
                382322, -- primal deconstruction charge
                382330, -- creature combustion canister
                382354, -- suspiciously ticking crate
                382333, -- sticky warp grenade
                382353, -- I.W.I.N button mk10
            },
        },
        SHORT_FUSE_3 = {
            nodeID = 50892,
            threshold = 20,
            multicraft = 20,
            exceptionRecipeIDs = {
                382343, -- gravitational displacer
                382323, -- grease grenade
                382322, -- primal deconstruction charge
                382330, -- creature combustion canister
                382354, -- suspiciously ticking crate
                382333, -- sticky warp grenade
                382353, -- I.W.I.N button mk10
            },
        },
        SHORT_FUSE_4 = {
            nodeID = 50892,
            threshold = 25,
            inspiration = 25,
            exceptionRecipeIDs = {
                382343, -- gravitational displacer
                382323, -- grease grenade
                382322, -- primal deconstruction charge
                382330, -- creature combustion canister
                382354, -- suspiciously ticking crate
                382333, -- sticky warp grenade
                382353, -- I.W.I.N button mk10
            },
        },
        EZ_THRO_1 = {
            nodeID = 50891,
            equalsSkill = true,
            exceptionRecipeIDs = {
                382355, -- ez-thro creature combustion canister
                382356, -- ez-thro gravitational displacer
                386670, -- ez-thro grease grenade
                382357, -- ez-thro primal deconstruction charge
                382358, -- suspiciously silent crate
            },
        },
        EZ_THRO_2 = {
            nodeID = 50891,
            threshold = 5,
            skill = 5,
            exceptionRecipeIDs = {
                382355, -- ez-thro creature combustion canister
                382356, -- ez-thro gravitational displacer
                386670, -- ez-thro grease grenade
                382357, -- ez-thro primal deconstruction charge
                382358, -- suspiciously silent crate
            },
        },
        EZ_THRO_3 = {
            nodeID = 50891,
            threshold = 10,
            resourcefulness = 10,
            exceptionRecipeIDs = {
                382355, -- ez-thro creature combustion canister
                382356, -- ez-thro gravitational displacer
                386670, -- ez-thro grease grenade
                382357, -- ez-thro primal deconstruction charge
                382358, -- suspiciously silent crate
            },
        },
        EZ_THRO_4 = {
            nodeID = 50891,
            threshold = 20,
            multicraft = 20,
            exceptionRecipeIDs = {
                382355, -- ez-thro creature combustion canister
                382356, -- ez-thro gravitational displacer
                386670, -- ez-thro grease grenade
                382357, -- ez-thro primal deconstruction charge
                382358, -- suspiciously silent crate
            },
        },
        EZ_THRO_5 = {
            nodeID = 50891,
            threshold = 25,
            inspiration = 25,
            exceptionRecipeIDs = {
                382355, -- ez-thro creature combustion canister
                382356, -- ez-thro gravitational displacer
                386670, -- ez-thro grease grenade
                382357, -- ez-thro primal deconstruction charge
                382358, -- suspiciously silent crate
            },
        },
        FUNCTION_OVER_FORM_1 = {
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
            nodeID = 50929,
            equalsSkill = true,
        },
        FUNCTION_OVER_FORM_2 = {
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
            nodeID = 50929,
            threshold = 0,
            craftingspeedBonusFactor = 0.10,
        },
        FUNCTION_OVER_FORM_3 = {
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
            nodeID = 50929,
            threshold = 20,
            resourcefulness = 10,
        },
        FUNCTION_OVER_FORM_4 = {
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
            nodeID = 50929,
            threshold = 25,
            skill = 5,
        },
        FUNCTION_OVER_FORM_5 = {
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
            nodeID = 50929,
            threshold = 35,
            inspiration = 25,
        },
        FUNCTION_OVER_FORM_6 = {
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
            nodeID = 50929,
            threshold = 40,
            skill = 10,
        },
        GEAR_1 = {
            nodeID = 50928,
            equalsInspiration = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.GOGGLES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.GUNS
                }
            },
        },
        GEAR_2 = {
            nodeID = 50928,
            threshold = 5,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.GOGGLES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.GUNS
                }
            },
        },
        GEAR_3 = {
            nodeID = 50928,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.GOGGLES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.GUNS
                }
            },
        },
        GEAR_4 = {
            nodeID = 50928,
            threshold = 30,
            inspiration = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.GOGGLES] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.ARMOR] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.PLATE,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.CLOTH,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MAIL,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.LEATHER
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.WEAPONS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.GUNS
                }
            },
        },
        GEARS_FOR_GEAR_1 = {
            nodeID = 50927,
            equalsInspiration = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.ENGINEERING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MINING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.FISHING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.JEWELCRAFTING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TAILORING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.COGWHEELS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.OPTIONAL_REAGENTS
                }
            },
        },
        GEARS_FOR_GEAR_2 = {
            nodeID = 50927,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.ENGINEERING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MINING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.FISHING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.JEWELCRAFTING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TAILORING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.COGWHEELS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.OPTIONAL_REAGENTS
                }
            },
        },
        GEARS_FOR_GEAR_3 = {
            nodeID = 50927,
            threshold = 25,
            multicraft = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.PROFESSION_EQUIPMENT] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.ENGINEERING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.MINING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.FISHING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.JEWELCRAFTING,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TAILORING
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.COGWHEELS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.OPTIONAL_REAGENTS
                },
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.OPTIONAL_REAGENTS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.BLACKSMITHING.OPTIONAL_REAGENTS
                }
            },
        },
        UTILITY_1 = {
            nodeID = 50926,
            equalsMulticraft = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.SCOPES_AND_AMMO] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TWO_HANDED_WEAPON,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER2
                }
            },
        },
        UTILITY_2 = {
            nodeID = 50926,
            threshold = 5,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.SCOPES_AND_AMMO] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TWO_HANDED_WEAPON,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER2
                }
            },
        },
        UTILITY_3 = {
            nodeID = 50926,
            threshold = 15,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.SCOPES_AND_AMMO] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TWO_HANDED_WEAPON,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER2
                }
            },
        },
        UTILITY_4 = {
            nodeID = 50926,
            threshold = 25,
            multicraft = 20,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.SCOPES_AND_AMMO] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.TWO_HANDED_WEAPON,
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER2
                }
            },
        },
        MECHANICAL_MIND_1 = {
            childNodeIDs = {"INVENTIONS_1", "NOVELTIES_1"},
            nodeID = 50956,
            equalsSkill = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        INVENTIONS_1 = {
            nodeID = 50955,
            equalsSkill = true,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.TINKERS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER
                }
            },
        },
        INVENTIONS_2 = {
            nodeID = 50955,
            threshold = 10,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.TINKERS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER
                }
            },
        },
        INVENTIONS_3 = {
            nodeID = 50955,
            threshold = 15,
            inspiration = 25,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.TINKERS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER
                }
            },
        },
        INVENTIONS_4 = {
            nodeID = 50955,
            threshold = 25,
            resourcefulness = 10,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.TINKERS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER
                }
            },
        },
        INVENTIONS_5 = {
            nodeID = 50955,
            threshold = 35,
            skill = 5,
            idMapping = {
                [CraftSim.CONST.RECIPE_CATEGORIES.ENGINEERING.TINKERS] = {
                    CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ENGINEERING.OTHER
                }
            },
        },
        NOVELTIES_1 = {
            nodeID = 50954,
            equalsInspirationBonusSkillFactor = true,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
    }
end