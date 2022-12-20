CraftSimCONST = {}

-- this average comes from 20-40% resources saved on proc with a minimum of 1
-- currently this is just an approximation
CraftSimCONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR = 0.30

CraftSimCONST.FRAMES = {
    MATERIALS = 0,
    STAT_WEIGHTS = 1,
    TOP_GEAR = 2,
    COST_OVERVIEW = 3,
    PROFIT_DETAILS = 4
}

CraftSimCONST.ERROR = {
    NO_PRICE_DATA = 0,
    NO_RECIPE_DATA = 1
}

-- if more needed, add https://wowpedia.fandom.com/wiki/LE_ITEM_BIND
CraftSimCONST.BINDTYPES = {
    SOULBOUND = 1
}

CraftSimCONST.PROFESSIONTOOL_INV_TYPES = {
    TOOL = "INVTYPE_PROFESSION_TOOL",
    GEAR = "INVTYPE_PROFESSION_GEAR"
}

CraftSimCONST.PROFESSION_INV_SLOTS = {{
    TOOL = "PROF0TOOLSLOT",
    GEAR0 = "PROF0GEAR0SLOT",
    GEAR1 = "PROF0GEAR1SLOT"
    }, 
    {
        TOOL = "PROF1TOOLSLOT",
        GEAR0 = "PROF1GEAR0SLOT",
        GEAR1 = "PROF1GEAR1SLOT"
    },
    {
        TOOL = "COOKINGTOOLSLOT",
        GEAR0 = "COOKINGGEAR0SLOT"
    }
}

CraftSimCONST.STAT_MAP = {
    ITEM_MOD_RESOURCEFULNESS_SHORT = "resourcefulness",
    ITEM_MOD_INSPIRATION_SHORT = "inspiration",
    ITEM_MOD_MULTICRAFT_SHORT = "multicraft",
    ITEM_MOD_CRAFTING_SPEED_SHORT = "craftingspeed"
}

CraftSimCONST.EMPTY_SLOT_LINK = "empty"
CraftSimCONST.EMPTY_SLOT_TEXTURE = "Interface\\containerframe\\bagsitemslot2x"

CraftSimCONST.SUPPORTED_PRICE_API_ADDONS = {"TradeSkillMaster", "Auctionator"}

CraftSimCONST.AUCTIONATOR_CALLER_ID = "CraftSim"

CraftSimCONST.REAGENT_TYPE = {
	OPTIONAL = 0,
	REQUIRED = 1,
	FINISHING_REAGENT = 2
}

CraftSimCONST.AUCTION_HOUSE_CUT = 0.95

CraftSimCONST.RECIPE_TYPES = {
    GEAR = 0, -- like blue gear
    SOULBOUND_GEAR = 1, -- like purple gear
    NO_QUALITY_MULTIPLE = 2, -- like transmuted air
    NO_QUALITY_SINGLE = 3, -- like repair hammer
    MULTIPLE = 4, -- like potions..
    SINGLE = 5, -- like omnium draconis
    NO_CRAFT_OPERATION = 6, -- like reclaim from alchemy
    RECRAFT = 7, -- like well.. recraft
    GATHERING = 8,
    NO_ITEM = 9, -- like phial experimentation
    ENCHANT = 10,
}

CraftSimCONST.GEAR_SIM_MODES = {
    PROFIT = "Top Profit",
    SKILL = "Top Skill",
    INSPIRATION = "Top Inspiration",
    MULTICRAFT = "Top Multicraft",
    RESOURCEFULNESS = "Top Resourcefulness",
    CRAFTING_SPEED = "Top Crafting Speed",
}

CraftSimCONST.DEFAULT_POSITIONS = {
    REAGENT_FRAME = {
        x = 0,
        y = 0,
    },
    COST_OVERVIEW_FRAME = {
        x = 0,
        y = 10,
    },
    TOP_GEAR_FRAME = {
        x = -5,
        y = 3,
    },
    STAT_WEIGHT_FRAME = {
        x = 0,
        y = -80,
    }
}

CraftSimCONST.COLORS = {
    GREEN = "cff00FF00",
    RED = "cffFF0000",
    DARK_BLUE = "cff2596be"
}

-- only need the ones that modify resourcefulness/multicraft
CraftSimCONST.RECIPE_CATEGORIES = {
    BLACKSMITHING = {
        STONEWORK = 1684,
        SMELTING = 1678
    },
    ALCHEMY = {
        ELEMENTAL_BOTH = 1646,
        PHIALS = {
            AIR = 1603,
            FROST = 1644,
        },
        POTIONS = {
            AIR = 1602,
            FROST = 1645
        },
        REAGENT = 1611,
        FINISHING_REAGENT = 1608,
        OPTIONAL_REAGENTS = 1609,
        INCENSE = 1610,
    },
    LEATHERWORKING = {
        DRUMS = 1655,
        ARMORKITS = 1651
    },
    INSCRIPTION = {
        INKS = 1754
    }
}

CraftSimCONST.LOCALES = {
    -- TODO
    EN = "enEN"
}

CraftSimCONST.TEXT = {
    RESOURCEFULNESS_EXPLANATION_TOOLTIP = 0,
    MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP = 1,
    MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP = 2,
    MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP = 3,
    INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP = 4,
    INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP = 5,
    MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP = 6,
    INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP = 7,
    INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP = 8
}
