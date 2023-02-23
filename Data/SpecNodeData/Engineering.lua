AddonName, CraftSim = ...

CraftSim.ENGINEERING_DATA = {}

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
            nodeID = 50993,
            childNodeIDs = {"PIECES_PARTS_1", "SCRAPPER_1", "GENERALIST_1"},
        },
        PIECES_PARTS_1 = {
            nodeID = 50992,
        },
        SCRAPPER_1 = {
            nodeID = 50991,
            equalsResourcefulnessPercent = true,
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
            threshold = 30,
            resourcefulnessExtraItemsFactor = 0.05,
            idMapping = {[CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {}},
        },
        GENERALIST_1 = {
            nodeID = 50990,
        },
        EXPLOSIVES_1 = {
            nodeID = 50894,
            childNodeIDs = {"CREATION_1", "SHORT_FUSE_1", "EZ_THRO_1"},
        },
        CREATION_1 = {
            nodeID = 50893,
        },
        SHORT_FUSE_1 = {
            nodeID = 50892,
        },
        EZ_THRO_1 = {
            nodeID = 50891,
        },
        FUNCTION_OVER_FORM_1 = {
            nodeID = 50929,
            childNodeIDs = {"GEAR_1", "GEARS_FOR_GEAR_1", "UTILITY_1"},
        },
        GEAR_1 = {
            nodeID = 50928,
        },
        GEARS_FOR_GEAR_1 = {
            nodeID = 50927,
        },
        UTILITY_1 = {
            nodeID = 50926,
        },
        MECHANICAL_MIND_1 = {
            nodeID = 50956,
            childNodeIDs = {"INVENTIONS_1", "NOVELTIES_1"},
        },
        INVENTIONS_1 = {
            nodeID = 50955,
        },
        NOVELTIES_1 = {
            nodeID = 50954,
        },
    }
end