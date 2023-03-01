_, CraftSim = ...

CraftSim.CONST = {}

-- One Time Info ------------
CraftSim.CONST.currentInfoVersionID = 61 -- last patch increase: 7.8.1
CraftSim.CONST.debugInfoText = false
CraftSim.CONST.infoBoxSizeX = 500
CraftSim.CONST.infoBoxSizeY = 400
----------------

CraftSim.CONST.FEATURE_TOGGLES = {
}

CraftSim.CONST.PERCENT_MODS = {
    INSPIRATION = 0.001,
    MULTICRAFT = 0.0009,
    RESOURCEFULNESS = 0.00111,
    CRAFTINGSPEED = 0.002,
}

-- this average comes from 20-40% resources saved on proc with a minimum of 1
-- currently this is just an approximation
CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR = 0.30
CraftSim.CONST.MULTICRAFT_CONSTANT = 2.5

CraftSim.CONST.DISCORD_INVITE_URL = "https://discord.gg/7vqKMgezXR"

CraftSim.CONST.EXPORT_MODE = {
    NON_WORK_ORDER = 0,
    WORK_ORDER = 1,
    SCAN = 2,
}

CraftSim.CONST.FRAMES = {
    MATERIALS = "MATERIALS",
    STAT_WEIGHTS = "STAT_WEIGHTS",
    TOP_GEAR = "TOP_GEAR",
    COST_OVERVIEW = "COST_OVERVIEW",
    PROFIT_DETAILS = "PROFIT_DETAILS",
    CRAFTING_DETAILS = "CRAFTING_DETAILS",
    SPEC_INFO = "SPEC_INFO",
    WARNING = "WARNING",
    INFO = "INFO",
    DEBUG = "DEBUG",
    DEBUG_CONTROL = "DEBUG_CONTROL",
    SPEC_SIM = "SPEC_SIM",
    CONTROL_PANEL = "CONTROL_PANEL",
    STAT_WEIGHTS_WORK_ORDER = "STAT_WEIGHTS_WORK_ORDER",
    PROFIT_DETAILS_WORK_ORDER = "PROFIT_DETAILS_WORK_ORDER",
    MATERIALS_WORK_ORDER = "MATERIALS_WORK_ORDER",
    COST_OVERVIEW_WORK_ORDER = "COST_OVERVIEW_WORK_ORDER",
    TOP_GEAR_WORK_ORDER = "TOP_GEAR_WORK_ORDER",
    PRICE_OVERRIDE_WORK_ORDER = "PRICE_OVERRIDE_WORK_ORDER",
    PRICE_OVERRIDE = "PRICE_OVERRIDE",
    RECIPE_SCAN = "RECIPE_SCAN",
    CRAFT_RESULTS = "CRAFT_RESULTS",
    STATISTICS = "STATISTICS",
    CUSTOMER_SERVICE = "CUSTOMER_SERVICE",
    LIVE_PREVIEW = "LIVE_PREVIEW",
    CRAFTING_DETAILS_WO = "CRAFTING_DETAILS_WO",
    SPEC_SIM_WO = "SPEC_SIM_WO",
    SPEC_INFO_WO = "SPEC_INFO_WO",
}

CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS = {
    1566, -- Blacksmithing,
    1582, -- Alchemy
    1587, -- Leatherworking
    1593, -- Jewelcrafting
    1588, -- Enchanting
    1592, -- Inscription
    1591, -- Tailoring
    1595, -- Engineering
    1585, -- Cooking
}

CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS = {
    1688, 1522, -- Blacksmithing
    1687, 1525, -- Alchemy
    1693, -- Leatherworking
    1686, -- Jewelcrafting
    1690, 1527, -- Enchanting
    1692, -- Inscription
    1696, 1532, -- Tailoring
    1691, 1528, -- Engineering
    1526, -- Cooking
}

CraftSim.CONST.DEBUG_IDS = {
    MAIN = "MAIN",
    SPECDATA = "SPECDATA",
    ERROR = "ERROR",
    DATAEXPORT = "DATAEXPORT",
    SIMULATION_MODE = "SIMULATION_MODE",
    REAGENT_OPTIMIZATION = "REAGENT_OPTIMIZATION",
    PRICEDATA = "PRICEDATA",
    PROFIT_CALCULATION = "PROFIT_CALCULATION",
    FRAMES = "FRAMES",
    CACHE = "CACHE",
    PROFILING = "PROFILING",
    RECIPE_SCAN = "RECIPE_SCAN",
    CRAFT_RESULTS = "CRAFT_RESULTS",
    PRICE_OVERRIDE = "PRICE_OVERRIDE",
    AVERAGE_PROFIT = "AVERAGE_PROFIT",
    STATISTICS = "STATISTICS",
    CUSTOMER_SERVICE = "CUSTOMER_SERVICE",
    COMM = "COMM",
    UTIL = "UTIL",
    COST_OVERVIEW = "COST_OVERVIEW",
    MEDIA = "MEDIA",
    TOP_GEAR = "TOP_GEAR",
}

CraftSim.CONST.ERROR = {
    NO_PRICE_DATA = 0,
    NO_RECIPE_DATA = 1
}

--> used in GUTIL now
-- if more needed, add https://wowpedia.fandom.com/wiki/LE_ITEM_BIND
CraftSim.CONST.BINDTYPES = {
    SOULBOUND = 1
}

CraftSim.CONST.PROFESSIONTOOL_INV_TYPES = {
    TOOL = "INVTYPE_PROFESSION_TOOL",
    GEAR = "INVTYPE_PROFESSION_GEAR"
}

-- CraftSim.CONST.PROFESSION_INV_SLOTS = {{
--     TOOL = "PROF0TOOLSLOT",
--     GEAR0 = "PROF0GEAR0SLOT",
--     GEAR1 = "PROF0GEAR1SLOT"
--     }, 
--     {
--         TOOL = "PROF1TOOLSLOT",
--         GEAR0 = "PROF1GEAR0SLOT",
--         GEAR1 = "PROF1GEAR1SLOT"
--     },
--     {
--         TOOL = "COOKINGTOOLSLOT",
--         GEAR0 = "COOKINGGEAR0SLOT"
--     }
-- }

CraftSim.CONST.STAT_MAP = {
    ITEM_MOD_RESOURCEFULNESS_SHORT = "resourcefulness",
    ITEM_MOD_INSPIRATION_SHORT = "inspiration",
    ITEM_MOD_MULTICRAFT_SHORT = "multicraft",
    ITEM_MOD_CRAFTING_SPEED_SHORT = "craftingspeed",
    CRAFTING_DETAILS_RECIPE_DIFFICULTY = "recipedifficulty",
    CRAFTING_DETAILS_SKILL = "skill",
    CRAFTING_DETAILS_INSPIRATION = "inspiration",
    CRAFTING_DETAILS_INSPIRATION_SKILL = "inspirationBonusSkill",
    CRAFTING_DETAILS_MULTICRAFT = "multicraft",
    CRAFTING_DETAILS_RESOURCEFULNESS = "resourcefulness",
}

CraftSim.CONST.EMPTY_SLOT_LINK = "empty"
CraftSim.CONST.EMPTY_SLOT_TEXTURE = "Interface\\containerframe\\bagsitemslot2x"

CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS = {"TradeSkillMaster", "Auctionator", "RECrystallize"}

CraftSim.CONST.REAGENT_TYPE = {
	OPTIONAL = 0,
	REQUIRED = 1,
	FINISHING_REAGENT = 2
}

CraftSim.CONST.AUCTION_HOUSE_CUT = 0.95

CraftSim.CONST.vellumItemID = 38682

CraftSim.CONST.TSM_DEFAULT_PRICE_EXPRESSION = "first(DBRecent, DBMinbuyout)"

CraftSim.CONST.RECIPE_TYPES = {
    GEAR = 0, -- like blue gear
    SOULBOUND_GEAR = 1, -- like purple gear
    NO_QUALITY_MULTIPLE = 2, -- like transmuted air
    NO_QUALITY_SINGLE = 3, -- like repair hammer
    MULTIPLE = 4, -- like potions..
    SINGLE = 5, -- like omnium draconis
    NO_CRAFT_OPERATION = 6, -- like reclaim from alchemy or old world stuff
    GATHERING = 7,
    NO_ITEM = 8, -- like phial experimentation
    ENCHANT = 9,
}

CraftSim.CONST.GEAR_SIM_MODES = {
    PROFIT = "Top Profit",
    SKILL = "Top Skill",
    INSPIRATION = "Top Inspiration",
    MULTICRAFT = "Top Multicraft",
    RESOURCEFULNESS = "Top Resourcefulness",
    CRAFTING_SPEED = "Top Crafting Speed",
}

CraftSim.CONST.DEFAULT_POSITIONS = {
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

CraftSim.CONST.RECIPE_CATEGORIES = {
    ALL = 999999,
    BLACKSMITHING = {
        STONEWORK = 1684,
        SMELTING = 1678,
        TOOLS = 1677,
        WEAPONS = 1675,
        ARMOR = 1567,
        SHIELDS = 1786,
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
        TRANSMUTATIONS = 1604,
        ESSENTIALS = 1681,
        ALCHEMIST_STONES = 1605,
        CAULDRONS = 1612,
    },
    LEATHERWORKING = {
        DRUMS = 1655,
        ARMOR_KITS = 1651,
        LEATHER_ARMOR = 1657,
        MAIL_ARMOR = 1658,
        PROFESSION_EQUIPMENT = 1656,
        WEAPONS = 1648,
        ELEMENTAL_PATTERNS = 1811,
        BESTIAL_PATTERNS = 1812,
        DECAYED_PATTERNS = 1810,
        REAGENTS = 1654,
        OPTIONAL_REAGENTS = 1649,
        TOYS = 1652,
    },
    INSCRIPTION = {
        INKS = 1754
    },
    JEWELCRAFTING = {
        REAGENTS = 1630,
        TRINKETS = 1631,
        JEWELRY = 1632,
        STATUES_AND_CARVING = 1633,
        PROFESSION_EQUIP = 1642,
        EXTRA_GLASSWARES = 1635,
        RUDI_GEMS = 1636,
        AIR_GEMS = 1637,
        EARTH_GEMS = 1638,
        FIRE_GEMS = 1639,
        FROST_GEMS = 1640,
        PRIMALIST_GEMS = 1641,
        MISC = 1629,

    }
}

CraftSim.CONST.RECIPE_ITEM_SUBTYPES = {
    ALL = 999999,
    BLACKSMITHING = {
        STONEWORK = 8, -- "Other"
        METAL_AND_STONE = 7,
        BLACKSMITHING = 0,
        LEATHERWORKING = 1,
        SKINNING = 10,
        TAILORING = 6,
        HERBALISM = 3,
        MINING = 5,

        -- WEAPONS
        MACE_2H = 5,
        FIST = 13,
        POLEARM = 6,
        SWORDS_1H = 7,
        AXE_1H = 0,
        DAGGERS = 15,
        AXE_2H = 1,
        SWORDS_2H = 8,
        MACE_1H = 4,
        WARGLAIVES = 9,

        -- ARMOR
        PLATE = 4,
        SHIELDS = 6,
    },
    ALCHEMY = {
        PHIALS = 3, -- "Flask"
        POTIONS = 1,
        REAGENT = 11, -- "Other"
        FINISHING_REAGENT = 19,
        OPTIONAL_REAGENTS = 18,
        INCENSE = 8, -- "other"
        ELEMENTAL = 10, -- transmutations
        EXPLOSIVES_AND_DEVICES = 0, -- transmutations
        MISC = 0, -- trinket
    },
    LEATHERWORKING = {
        DRUMS = 8, -- Drums
        MISC = 14, -- Armor Kits
        MISCELLANEOUS = 0, -- Witherrot Tome
        OTHER = 4, -- Toys

        -- Armor
        LEATHER = 2,
        MAIL = 3,

        -- Tools
        ALCHEMY = 2,
        SKINNING = 10,
        BLACKSMITHING = 0,
        HERBALISM = 3,
        LEATHERWORKING = 1,
        JEWELCRAFTING = 11,
        ENGINEERING = 7,

        -- Weapons
        CROSSBOWS = 18,
        BOWS = 2,

        -- Reagents
        OPTIONAL_REAGENTS = 18, -- Fang Adornments, Toxified Armor Patch (Optional Reagents)
        LEATHER_REAGENTS = 6, -- Hides, Scales (Reagents)
    },
    INSCRIPTION = {
        INKS = 16, -- "Inscription"
    },
    JEWELCRAFTING = {
        GEMS = 9, -- Other
    },
}

CraftSim.CONST.BUFF_IDS = {
    INSPIRATION_INCENSE = 371234,
    PHIAL_OF_QUICK_HANDS = 393665,
    ALCHEMICALLY_INSPIRED = 382093,
}

CraftSim.CONST.LOCALES = {
    EN = "enUS",
    DE = "deDE",
    IT = "itIT",
    RU = "ruRU",
    PT = "ptBR",
    ES = "esES",
    FR = "frFR",
    MX = "esMX",
    KO = "koKR",
    TW = "zhTW",
}

CraftSim.CONST.TEXT = {
    RESOURCEFULNESS_EXPLANATION_TOOLTIP = 0,
    MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP = 1,
    MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP = 2,
    MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP = 3,
    INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP = 4,
    INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP = 5,
    MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP = 6,
    INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP = 7,
    INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP = 8,
    RECIPE_DIFFICULTY_LABEL = 9,
    INSPIRATION_LABEL = 10,
    MULTICRAFT_LABEL = 11,
    RESOURCEFULNESS_LABEL = 12,
    RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP = 13,
    INSPIRATION_EXPLANATION_TOOLTIP = 14,
    MULTICRAFT_EXPLANATION_TOOLTIP = 15,
    REAGENTSKILL_EXPLANATION_TOOLTIP = 17,
    
    -- required stuff
    STAT_INSPIRATION = 18,
    STAT_MULTICRAFT = 19,
    STAT_RESOURCEFULNESS = 20,
    STAT_CRAFTINGSPEED = 21,
    EQUIP_MATCH_STRING = 22,
    ENCHANTED_MATCH_STRING = 24,
    --

    -- optional: 
    STAT_SKILL = 25,
    STAT_MULTICRAFT_BONUS = 26,
    STAT_RESOURCEFULNESS_BONUS = 27,
    STAT_PHIAL_EXPERIMENTATION = 28,
    STAT_POTION_EXPERIMENTATION = 29,
    STAT_CRAFTINGSPEED_BONUS = 30,
    STAT_INSPIRATION_BONUS = 31,

    INSPIRATION_SKILL_LABEL = 32,
    INSPIRATION_SKILL_EXPLANATION_TOOLTIP = 33,
    REAGENTFACTOR_EXPLANATION_TOOLTIP = 34,

    RESOURCEFULNESS_BONUS_LABEL = 35,
    MATERIAL_QUALITY_BONUS_LABEL = 36,
    MATERIAL_QUALITY_MAXIMUM_LABEL = 37,
    EXPECTED_QUALITY_LABEL = 38,
    NEXT_QUALITY_LABEL = 39,
    MISSING_SKILL_LABEL = 40,
    MISSING_SKILL_INSPIRATION_LABEL = 41,
    SKILL_LABEL = 42,
    MULTICRAFT_BONUS_LABEL = 43,
    CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION = 44,
    CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION = 45,
    CUSTOMER_SERVICE_AUTO_REPLY_EXPLANATION = 46,
    HSV_EXPLANATION = 47,
    CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX_EXPLANATION = 48,
    STATISTICS_CDF_EXPLANATION = 49,
    PROFIT_EXPLANATION = 50,
    PROFIT_EXPLANATION_HSV = 51,
    MULTICRAFT_CONSTANT_EXPLANATION = 52,
    RESOURCEFULNESS_CONSTANT_EXPLANATION = 53,
}

CraftSim.CONST.IMPLEMENTED_SKILL_BUILD_UP = function() 
    return {
        Enum.Profession.Blacksmithing, 
        Enum.Profession.Alchemy, 
        Enum.Profession.Jewelcrafting, 
        Enum.Profession.Leatherworking,
    }
end

CraftSim.CONST.ITEM_ID_EXCEPTION_MAPPING = {
    [199345] = 200074 -- frosted rimefin tuna to rimefin tuna, due to frosted generating it, and rimefin tuna being soulbound
}

CraftSim.CONST.EXCEPTION_ORDER_ITEM_IDS = {
    [382363] = {198236, 198237, 198238}
}

CraftSim.CONST.SPECIAL_TOOL_STATS = {
    [191228] = { -- Epic BS Hammer
        inspirationBonusSkillPercent = 0.15,
    }
}
