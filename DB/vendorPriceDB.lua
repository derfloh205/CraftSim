---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.VENDOR_PRICE : CraftSim.DB.Repository
CraftSim.DB.VENDOR_PRICE = CraftSim.DB:RegisterRepository("VendorPriceDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.vendorPriceDB")

---@class CraftSim.DB.VendorPrice.Entry
---@field price number  copper
---@field vendorName string
---@field timestamp number  GetServerTime() when this was scanned

---@class CraftSim.DB.VendorPrice.Data
---@field discoveredPrices table<ItemID, CraftSim.DB.VendorPrice.Entry>

function CraftSim.DB.VENDOR_PRICE:Init()
    if not CraftSimDB.vendorPriceDB then
        ---@type CraftSimDB.Database
        CraftSimDB.vendorPriceDB = {
            version = 0,
            ---@type CraftSim.DB.VendorPrice.Data
            data = {
                discoveredPrices = {},
            },
        }
    end

    self.db = CraftSimDB.vendorPriceDB

    -- Defensive init for data table in case of partial saves
    CraftSimDB.vendorPriceDB.data = CraftSimDB.vendorPriceDB.data or {}
    CraftSimDB.vendorPriceDB.data.discoveredPrices = CraftSimDB.vendorPriceDB.data.discoveredPrices or {}
end

function CraftSim.DB.VENDOR_PRICE:ClearAll()
    wipe(CraftSimDB.vendorPriceDB.data.discoveredPrices or {})
end

function CraftSim.DB.VENDOR_PRICE:CleanUp()
    -- Nothing to migrate from legacy databases
end

---@return table<ItemID, CraftSim.DB.VendorPrice.Entry>
function CraftSim.DB.VENDOR_PRICE:GetAll()
    CraftSimDB.vendorPriceDB.data.discoveredPrices = CraftSimDB.vendorPriceDB.data.discoveredPrices or {}
    return CraftSimDB.vendorPriceDB.data.discoveredPrices
end

---@param itemID ItemID
---@return CraftSim.DB.VendorPrice.Entry?
function CraftSim.DB.VENDOR_PRICE:Get(itemID)
    CraftSimDB.vendorPriceDB.data.discoveredPrices = CraftSimDB.vendorPriceDB.data.discoveredPrices or {}
    return CraftSimDB.vendorPriceDB.data.discoveredPrices[itemID]
end

---@param itemID ItemID
---@param entry CraftSim.DB.VendorPrice.Entry
function CraftSim.DB.VENDOR_PRICE:Save(itemID, entry)
    CraftSimDB.vendorPriceDB.data.discoveredPrices = CraftSimDB.vendorPriceDB.data.discoveredPrices or {}
    CraftSimDB.vendorPriceDB.data.discoveredPrices[itemID] = entry
end

---@param itemID ItemID
function CraftSim.DB.VENDOR_PRICE:Delete(itemID)
    CraftSimDB.vendorPriceDB.data.discoveredPrices = CraftSimDB.vendorPriceDB.data.discoveredPrices or {}
    CraftSimDB.vendorPriceDB.data.discoveredPrices[itemID] = nil
end

---@return number count
function CraftSim.DB.VENDOR_PRICE:Count()
    local count = 0
    for _ in pairs(CraftSimDB.vendorPriceDB.data.discoveredPrices or {}) do
        count = count + 1
    end
    return count
end
