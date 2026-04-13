---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.INVENTORY_API
CraftSim.INVENTORY_API = {}
CraftSim.INVENTORY_APIS = {}

CraftSimSYNDICATOR = { name = "Syndicator" }
CraftSimINVENTORY_NONE = { name = "CraftSim" }

local print = CraftSim.DEBUG:RegisterDebugID("Data.InventoryAPI")

function CraftSim.INVENTORY_API:InitInventorySource()
    local loadedSources = CraftSim.INVENTORY_APIS:GetAvailableInventoryAddons()

    if #loadedSources == 0 then
        CraftSim.INVENTORY_API = CraftSimINVENTORY_NONE
        return
    end

    local savedSource = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.INVENTORY_SOURCE)

    if tContains(loadedSources, savedSource) then
        CraftSim.INVENTORY_APIS:SwitchAPIByAddonName(savedSource)
    else
        CraftSim.INVENTORY_APIS:SwitchAPIByAddonName(loadedSources[1])
        CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.INVENTORY_SOURCE, loadedSources[1])
    end
end

function CraftSim.INVENTORY_APIS:SwitchAPIByAddonName(addonName)
    if addonName == CraftSimSYNDICATOR.name then
        CraftSim.INVENTORY_API = CraftSimSYNDICATOR
    elseif addonName == CraftSimTSM.name then
        CraftSim.INVENTORY_API = CraftSimTSM
    else
        CraftSim.INVENTORY_API = CraftSimINVENTORY_NONE
    end
end

function CraftSim.INVENTORY_APIS:GetAvailableInventoryAddons()
    local loadedAddons = {}
    for _, addonName in pairs(CraftSim.CONST.SUPPORTED_INVENTORY_ADDONS) do
        if select(2, C_AddOns.IsAddOnLoaded(addonName)) then
            table.insert(loadedAddons, addonName)
        end
    end
    return loadedAddons
end

function CraftSim.INVENTORY_APIS:IsInventoryAddon(addonName)
    for _, name in pairs(CraftSim.CONST.SUPPORTED_INVENTORY_ADDONS) do
        if addonName == name then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------------------
-- CraftSimSYNDICATOR: Inventory
-- ---------------------------------------------------------------------------

--- Returns true when Syndicator is loaded and its API is available.
---@return boolean
function CraftSimSYNDICATOR:IsAvailable()
    return Syndicator ~= nil and Syndicator.API ~= nil
end

--- Returns the total inventory count (bags + bank) for an itemID.
--- Uses Syndicator's data to query current character inventory.
---@param itemID ItemID
---@return number count
function CraftSimSYNDICATOR:GetInventoryCount(itemID)
    if not self:IsAvailable() then return 0 end
    if not itemID then return 0 end

    local total = 0

    -- Syndicator API v1: query inventory count across tracked characters
    if Syndicator.API.v1 and Syndicator.API.v1.GetItemCount then
        total = Syndicator.API.v1.GetItemCount(CraftSimAddonName, itemID) or 0
    end

    return total
end

--- Returns the count of items posted on the AH by the player via Syndicator.
--- Returns nil if not supported.
---@param itemID ItemID
---@return number? auctionAmount
function CraftSimSYNDICATOR:GetAuctionAmount(itemID)
    return nil
end

-- ---------------------------------------------------------------------------
-- CraftSimTSM: Inventory (extends existing CraftSimTSM)
-- ---------------------------------------------------------------------------

--- Returns the total inventory count (bags + bank + optionally AH) for an itemID via TSM.
---@param itemID ItemID
---@return number count
function CraftSimTSM:GetInventoryCount(itemID)
    if not self:IsAvailable() then return 0 end
    if not itemID then return 0 end

    local tsmStr = "i:" .. itemID
    local numPlayer, numAlts, numAuctions, numAltAuctions = TSM_API.GetPlayerTotals(tsmStr)
    local total = (numPlayer or 0) + (numAuctions or 0)

    if CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_ALTS") then
        total = total + (numAlts or 0) + (numAltAuctions or 0)
    end

    if CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_WARBANK") then
        total = total + (TSM_API.GetWarbankQuantity and TSM_API.GetWarbankQuantity(tsmStr) or 0)
    end

    return total
end

-- ---------------------------------------------------------------------------
-- CraftSimINVENTORY_NONE: Fallback using CraftSim's built-in item count
-- ---------------------------------------------------------------------------

--- Returns true always (built-in, always available).
---@return boolean
function CraftSimINVENTORY_NONE:IsAvailable()
    return true
end

--- Returns the total inventory count using CraftSim's built-in tracking.
---@param itemID ItemID
---@return number count
function CraftSimINVENTORY_NONE:GetInventoryCount(itemID)
    if not itemID then return 0 end
    return C_Item.GetItemCount(itemID, true, false, true) or 0
end

--- Returns AH post amount if TSM is also loaded (for backwards compat).
---@param itemIDOrLink number | string
---@return number? auctionAmount
function CraftSimINVENTORY_NONE:GetAuctionAmount(itemIDOrLink)
    return nil
end

-- ---------------------------------------------------------------------------
-- CraftSim.INVENTORY_SOURCE: High-level API used by feature modules
-- ---------------------------------------------------------------------------

---@class CraftSim.INVENTORY_SOURCE
CraftSim.INVENTORY_SOURCE = {}

--- Returns the total inventory count for an item using the active inventory addon.
--- For use in restock count calculations (result items), NOT reagent tracking.
---@param itemID ItemID
---@return number count
function CraftSim.INVENTORY_SOURCE:GetInventoryCount(itemID)
    if not itemID then return 0 end
    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetInventoryCount then
        return CraftSim.INVENTORY_API:GetInventoryCount(itemID) or 0
    end
    return CraftSimINVENTORY_NONE:GetInventoryCount(itemID)
end

--- Returns the count of items currently posted on the AH using the active inventory addon.
--- Returns nil if the active addon does not support AH post counting.
---@param itemIDOrLink number | string
---@return number? auctionAmount
function CraftSim.INVENTORY_SOURCE:GetAuctionAmount(itemIDOrLink)
    local itemID = type(itemIDOrLink) == "number" and itemIDOrLink or
        (itemIDOrLink and C_Item.GetItemInfoInstant(itemIDOrLink))
    if not itemID then return nil end

    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetAuctionAmount then
        return CraftSim.INVENTORY_API:GetAuctionAmount(itemID)
    end
    return nil
end
