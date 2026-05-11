---@class CraftSim
local CraftSim = select(2, ...)

---@enum CraftSim.PRE_CRAFT_CONDITION_IDS
CraftSim.PRE_CRAFT_CONDITION_IDS = {
    LEARNED = "LEARNED",
    COOLDOWN = "COOLDOWN",
    IS_CRAFTER = "IS_CRAFTER",
    REAGENTS = "REAGENTS",
    RECIPE_REQUIREMENTS = "RECIPE_REQUIREMENTS",
    --- Druid (and similar): must be in caster/humanoid form to craft; other classes always pass.
    SHAPESHIFT = "SHAPESHIFT",
    WORK_ORDER_MIN_QUALITY = "WORK_ORDER_MIN_QUALITY",
    PROFESSION_OPEN = "PROFESSION_OPEN",
    PROFESSION_TOOLS = "PROFESSION_TOOLS",
    PRE_CRAFT_GATE = "PRE_CRAFT_GATE",
}

---@class CraftSim.PreCraftConditions
---@field CONDITION_PRIORITY table<CraftSim.PRE_CRAFT_CONDITION_IDS, number>
---@field GetShapeshiftCraftingStatus fun(self: CraftSim.PreCraftConditions): boolean, string?
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
    SHAPESHIFT = 95,
    REAGENTS = 90,
    PROFESSION_OPEN = 50,
    PROFESSION_TOOLS = 40,
    PRE_CRAFT_GATE = 30,
}

--- Evaluates `PRE_CRAFT_CONDITION_IDS.SHAPESHIFT` from live API state (druid shapeshift).
---@return boolean isMet
---@return string? reason
function PCC:GetShapeshiftCraftingStatus()
    local classFile = select(2, UnitClass("player"))
    if classFile ~= "DRUID" then
        return true, nil
    end
    local formID = GetShapeshiftForm()
    local isMet = formID == 0
    local reason = isMet and nil or (rawget(_G, "ERR_CANT_DO_THAT_WHILE_SHAPESHIFTED") or "Must be in normal form")
    return isMet, reason
end

-- Per-item condition evaluation lives in CraftSim.PrecraftConditionSet (attached to CraftQueueItem).
-- This module keeps shared condition constants and small shared helper logic.
