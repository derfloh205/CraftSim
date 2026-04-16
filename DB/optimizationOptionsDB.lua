---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterLogger("Database.optimizationOptionsDB")

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.OPTIMIZATION_OPTIONS : CraftSim.DB.Repository
CraftSim.DB.OPTIMIZATION_OPTIONS = CraftSim.DB:RegisterRepository("OptimizationOptionsDB")

function CraftSim.DB.OPTIMIZATION_OPTIONS:Init()
    if not CraftSimDB.optimizationOptionsDB then
        ---@type CraftSimDB.Database
        CraftSimDB.optimizationOptionsDB = {
            data = {},
            version = 0,
        }
    end

    self.db = CraftSimDB.optimizationOptionsDB

    CraftSimDB.optimizationOptionsDB.data = CraftSimDB.optimizationOptionsDB.data or {}
end

function CraftSim.DB.OPTIMIZATION_OPTIONS:ClearAll()
    wipe(CraftSimDB.optimizationOptionsDB.data)
end

---@param id string the OptimizationOptionsID
---@param key CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS the option key
---@param default? any default value if not set
---@return any
function CraftSim.DB.OPTIMIZATION_OPTIONS:Get(id, key, default)
    local idTable = CraftSimDB.optimizationOptionsDB.data[id]
    if idTable == nil then
        CraftSimDB.optimizationOptionsDB.data[id] = {}
        idTable = CraftSimDB.optimizationOptionsDB.data[id]
    end
    if idTable[key] == nil then
        idTable[key] = default
    end
    return idTable[key]
end

---@param id string the OptimizationOptionsID
---@param key CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS the option key
---@param value any
function CraftSim.DB.OPTIMIZATION_OPTIONS:Save(id, key, value)
    if CraftSimDB.optimizationOptionsDB.data[id] == nil then
        CraftSimDB.optimizationOptionsDB.data[id] = {}
    end
    CraftSimDB.optimizationOptionsDB.data[id][key] = value
end

---Get the full stored options table for an ID (for use in optimization code)
---@param id string the OptimizationOptionsID
---@return table
function CraftSim.DB.OPTIMIZATION_OPTIONS:GetTable(id)
    return CraftSimDB.optimizationOptionsDB.data[id] or {}
end

--- Migrations

function CraftSim.DB.OPTIMIZATION_OPTIONS.MIGRATION:M_0_1_Import_from_OptionsDB()
    local newData                       = CraftSimDB.optimizationOptionsDB.data
    local oldData                       = CraftSimDB.optionsDB and CraftSimDB.optionsDB.data or {}
    local KEYS                          = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
    local IDS                           = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS

    newData[IDS.CRAFTQUEUE_ADD_RECIPE]  = {
        [KEYS.AUTOSELECT_TOP_PROFIT_QUALITY] = oldData["CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY"],
        [KEYS.OPTIMIZE_PROFESSION_TOOLS]     = oldData["CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_PROFESSION_GEAR"],
        [KEYS.OPTIMIZE_CONCENTRATION]        = oldData["CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_CONCENTRATION"],
    }

    newData[IDS.CRAFTQUEUE_EDIT_RECIPE] = {
        [KEYS.AUTOSELECT_TOP_PROFIT_QUALITY]        = oldData["CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY"],
        [KEYS.OPTIMIZE_PROFESSION_TOOLS]            = oldData["CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_PROFESSION_GEAR"],
        [KEYS.OPTIMIZE_CONCENTRATION]               = oldData["CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_CONCENTRATION"],
        [KEYS.OPTIMIZE_FINISHING_REAGENTS]          = oldData["CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS"],
        [KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS] = oldData
            ["CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS_INCLUDE_SOULBOUND"],
    }

    newData[IDS.RECIPESCAN_SCAN]        = {
        [KEYS.ENABLE_CONCENTRATION]                 = oldData["RECIPESCAN_ENABLE_CONCENTRATION"],
        [KEYS.REAGENT_ALLOCATION]                   = oldData["RECIPESCAN_SCAN_MODE"],
        [KEYS.AUTOSELECT_TOP_PROFIT_QUALITY]        = oldData["RECIPESCAN_OPTIMIZE_REAGENTS_TOP_PROFIT"],
        [KEYS.OPTIMIZE_PROFESSION_TOOLS]            = oldData["RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS"],
        [KEYS.OPTIMIZE_CONCENTRATION]               = oldData["RECIPESCAN_OPTIMIZE_CONCENTRATION_VALUE"],
        [KEYS.OPTIMIZE_FINISHING_REAGENTS]          = oldData["RECIPESCAN_OPTIMIZE_FINISHING_REAGENTS"],
        [KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS] = oldData
            ["RECIPESCAN_OPTIMIZE_FINISHING_REAGENTS_INCLUDE_SOULBOUND"],
    }
end
