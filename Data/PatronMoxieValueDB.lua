---@class CraftSim
local CraftSim = select(2, ...)

--- Persisted Craft Queue "copper per Moxie" overrides (shared storage key per surplus group).
CraftSim.PATRON_MOXIE_VALUE_DB = {}

local OPTION_KEY = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_QUEUE_PATRON_ORDERS_MOXIE_VALUES

---@param currencyID number
---@return number
local function StorageCurrencyID(currencyID)
    return CraftSim.PATRON_MOXIE_SURPLUS:GetStorageCurrencyID(currencyID)
end

---@return table
function CraftSim.PATRON_MOXIE_VALUE_DB:GetStoredTable()
    local stored = CraftSim.DB.OPTIONS:Get(OPTION_KEY)
    if type(stored) ~= "table" then
        return {}
    end
    return stored
end

---@return table
function CraftSim.PATRON_MOXIE_VALUE_DB:GetOrCreateStoredTable()
    local stored = CraftSim.DB.OPTIONS:Get(OPTION_KEY)
    if type(stored) ~= "table" then
        stored = {}
        CraftSim.DB.OPTIONS:Save(OPTION_KEY, stored)
    end
    return stored
end

---@param stored table?
---@param currencyID number
---@return number
function CraftSim.PATRON_MOXIE_VALUE_DB:GetCopperPerMoxieFromStored(stored, currencyID)
    if type(stored) ~= "table" then
        return 0
    end
    local storageCurrencyID = StorageCurrencyID(currencyID)
    return tonumber(stored[storageCurrencyID] or stored[tostring(storageCurrencyID)]) or 0
end

---@param currencyID number
---@return number
function CraftSim.PATRON_MOXIE_VALUE_DB:GetCopperPerMoxie(currencyID)
    return self:GetCopperPerMoxieFromStored(CraftSim.DB.OPTIONS:Get(OPTION_KEY), currencyID)
end

---@param currencyID number
---@param copperTotal number
function CraftSim.PATRON_MOXIE_VALUE_DB:SetCopperPerMoxie(currencyID, copperTotal)
    local stored = CraftSim.DB.OPTIONS:Get(OPTION_KEY)
    if type(stored) ~= "table" then
        stored = {}
    end
    local value = tonumber(copperTotal) or 0
    local storageCurrencyID = StorageCurrencyID(currencyID)
    stored[storageCurrencyID] = value
    stored[tostring(storageCurrencyID)] = value
    CraftSim.DB.OPTIONS:Save(OPTION_KEY, stored)
end
