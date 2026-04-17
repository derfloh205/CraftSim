---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

--- Craft Queue patron Moxie copper-per-unit overrides (CraftSimDB.patronMoxieValuesDB).
---@class CraftSim.DB.PATRON_MOXIE_VALUES : CraftSim.DB.Repository
CraftSim.DB.PATRON_MOXIE_VALUES = CraftSim.DB:RegisterRepository("PatronMoxieValuesDB")

local LEGACY_OPTION_KEY = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_QUEUE_PATRON_ORDERS_MOXIE_VALUES

---@param currencyID number
---@return number
local function storageCurrencyID(currencyID)
    return CraftSim.PATRON_MOXIE_SURPLUS:GetStorageCurrencyID(currencyID)
end

function CraftSim.DB.PATRON_MOXIE_VALUES:Init()
    if not CraftSimDB.patronMoxieValuesDB then
        ---@class CraftSimDB.PatronMoxieValuesDB : CraftSimDB.Database
        CraftSimDB.patronMoxieValuesDB = {
            version = 0,
            ---@type table<number|string, number> storage currency id -> copper; string keys mirror numerics for SavedVariables
            data = {},
        }
    end
    self.db = CraftSimDB.patronMoxieValuesDB
    CraftSimDB.patronMoxieValuesDB.data = CraftSimDB.patronMoxieValuesDB.data or {}
end

function CraftSim.DB.PATRON_MOXIE_VALUES:ClearAll()
    wipe(CraftSimDB.patronMoxieValuesDB.data)
end

function CraftSim.DB.PATRON_MOXIE_VALUES:CleanUp()
end

---@return table
function CraftSim.DB.PATRON_MOXIE_VALUES:GetStoredTable()
    local data = CraftSimDB.patronMoxieValuesDB.data
    if type(data) ~= "table" then
        return {}
    end
    return data
end

---@return table
function CraftSim.DB.PATRON_MOXIE_VALUES:GetOrCreateStoredTable()
    CraftSimDB.patronMoxieValuesDB.data = CraftSimDB.patronMoxieValuesDB.data or {}
    return CraftSimDB.patronMoxieValuesDB.data
end

---@param stored table?
---@param currencyID number
---@return number
function CraftSim.DB.PATRON_MOXIE_VALUES:GetCopperPerMoxieFromStored(stored, currencyID)
    if type(stored) ~= "table" then
        return 0
    end
    local sid = storageCurrencyID(currencyID)
    return tonumber(stored[sid] or stored[tostring(sid)]) or 0
end

---@param currencyID number
---@return number
function CraftSim.DB.PATRON_MOXIE_VALUES:GetCopperPerMoxie(currencyID)
    return self:GetCopperPerMoxieFromStored(self:GetStoredTable(), currencyID)
end

---@param currencyID number
---@param copperTotal number
function CraftSim.DB.PATRON_MOXIE_VALUES:SetCopperPerMoxie(currencyID, copperTotal)
    local data = self:GetOrCreateStoredTable()
    local value = tonumber(copperTotal) or 0
    local sid = storageCurrencyID(currencyID)
    data[sid] = value
    data[tostring(sid)] = value
end

--- Migrations

function CraftSim.DB.PATRON_MOXIE_VALUES.MIGRATION:M_0_1_Craft_queue_moxie_values_from_optionsDB()
    local data = CraftSimDB.patronMoxieValuesDB.data
    if next(data) ~= nil then
        return
    end
    local opts = CraftSimDB.optionsDB and CraftSimDB.optionsDB.data
    if not opts then
        return
    end
    local legacy = opts[LEGACY_OPTION_KEY]
    if type(legacy) ~= "table" or next(legacy) == nil then
        return
    end
    for k, v in pairs(legacy) do
        data[k] = v
    end
    opts[LEGACY_OPTION_KEY] = nil
end

--- Backwards-compatible alias (same table as CraftSim.DB.PATRON_MOXIE_VALUES).
CraftSim.PATRON_MOXIE_VALUE_DB = CraftSim.DB.PATRON_MOXIE_VALUES
