---@class CraftSim
local CraftSim = select(2, ...)

---@enum CraftSim.PRE_CRAFT_CONDITION_IDS
CraftSim.PRE_CRAFT_CONDITION_IDS = {
    LEARNED = "LEARNED",
    COOLDOWN = "COOLDOWN",
    IS_CRAFTER = "IS_CRAFTER",
    REAGENTS = "REAGENTS",
    RECIPE_REQUIREMENTS = "RECIPE_REQUIREMENTS",
    WORK_ORDER_MIN_QUALITY = "WORK_ORDER_MIN_QUALITY",
    PROFESSION_OPEN = "PROFESSION_OPEN",
    PROFESSION_TOOLS = "PROFESSION_TOOLS",
    PRE_CRAFT_ACTION = "PRE_CRAFT_ACTION",
}

---@class CraftSim.PreCraftConditions
---@field CONDITION_PRIORITY table<CraftSim.PRE_CRAFT_CONDITION_IDS, number>
CraftSim.PRE_CRAFT_CONDITIONS = CraftSim.PRE_CRAFT_CONDITIONS or {}

---@type CraftSim.PreCraftConditions
local PCC = CraftSim.PRE_CRAFT_CONDITIONS

---@type table<CraftSim.PRE_CRAFT_CONDITION_IDS, number>
PCC.CONDITION_PRIORITY = {
    IS_CRAFTER = 1000,
    LEARNED = 900,
    COOLDOWN = 800,
    RECIPE_REQUIREMENTS = 100,
    WORK_ORDER_MIN_QUALITY = 99,
    REAGENTS = 90,
    PROFESSION_OPEN = 50,
    PROFESSION_TOOLS = 40,
    PRE_CRAFT_ACTION = 30,
}

-- Per-item condition evaluation lives in CraftSim.PrecraftConditionSet (attached to CraftQueueItem).
-- This module keeps shared condition constants and small shared helper logic.
