CraftSimCONST = {}

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