---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

CraftSimAPI = {}

---Fetch a CraftSim.RecipeData instance for a recipe
---@param options CraftSim.RecipeData.ConstructorOptions
---@return CraftSim.RecipeData recipeData
function CraftSimAPI:GetRecipeData(options)
    return CraftSim.RecipeData(options)
end

---Fetch the currently open CraftSim.RecipeData instance (or the last one opened if profession window was closed)
---@return CraftSim.RecipeData | nil
function CraftSimAPI:GetOpenRecipeData()
    return CraftSim.MODULES.recipeData
end

---Get the whole CraftSim addon table for whatever reason. Have Fun!
function CraftSimAPI:GetCraftSim()
    return CraftSim
end

---Get the expected AH deposit cost for a recipe (requires TSM + option enabled).
---@param recipeData CraftSim.RecipeData
---@return number depositCost copper (0 if unavailable)
function CraftSimAPI:GetExpectedDeposit(recipeData)
    return CraftSimTSM:GetExpectedDeposit(recipeData)
end

---Get the smart restock amount for a recipe, subtracting existing inventory.
---@param recipeData CraftSim.RecipeData
---@return number needed items still required
---@return number target TSM restock target
---@return number owned total owned across tracked sources
function CraftSimAPI:GetSmartRestockAmount(recipeData)
    return CraftSimTSM:GetSmartRestockAmount(recipeData)
end

---Get the last recorded average crafting cost for an item.
---For non-gear items, each quality has its own itemID, so pass the itemID directly.
---For gear items, the same itemID is shared across qualities - pass either:
---  - An itemLink (from which the qualityID is extracted), or
---  - A numeric itemID to look up any stored quality.
---Returns the cheapest cost across all known crafters, the timestamp of that entry, and the crafter UID.
---@param itemIDOrLink number|string itemID (number) or itemLink (string)
---@return number|nil cost cheapest average crafting cost per item in copper, or nil if not available
---@return number|nil timestamp unix timestamp of the last update for the cheapest entry, or nil if not available
---@return CrafterUID|nil crafterUID crafter with the cheapest cost, or nil if not available
function CraftSimAPI:GetLastCraftingCost(itemIDOrLink)
    if not CraftSim.DB.LAST_CRAFTING_COST then return nil, nil, nil end

    local crafterUID, cost, timestamp
    if type(itemIDOrLink) == "number" then
        crafterUID, cost, timestamp = CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemID(itemIDOrLink)
    elseif type(itemIDOrLink) == "string" then
        crafterUID, cost, timestamp = CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemLink(itemIDOrLink)
    end

    if cost then
        return cost, timestamp, crafterUID
    end
    return nil, nil, nil
end

--- CraftSim triggers and listens to custom [events](Events.lua) for internal communication between modules.
--- You can also register your own listeners to these events.
--- If a table is registered any function that has the exact same name as an event will be called
--- when that event is fired, with the event arguments passed as function arguments.
--- E.g function RegisteredTable:CRAFTSIM_PROFESSION_OPENED(professionInfo, selectedTab, isLogin, isReload)
--- When registered, craftsim logging will also log your events to LogSink:Table / DevTool addon
---@param table table the table to register the callback on (e.g. a module or UI frame)
---@param events CraftSim.Event[]
function CraftSimAPI:RegisterEvents(table, events)
    GUTIL:RegisterCustomEvents(table, events)
end

--- Add a custom module to craftsim
--- A module should follow the CraftSim.Module type found in [Modules.lua](../Modules/Modules.lua), and can optionally be registered for the control panel to get a button in the craftsim settings to open it.
---@param moduleID string
---@param module CraftSim.Module
---@param controlPanelOptions table
function CraftSimAPI:RegisterCustomModule(moduleID, module, controlPanelOptions)
    CraftSim.MODULES:RegisterModule(moduleID, module, controlPanelOptions)
end
