---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.INVENTORY_API
---@field name string
---@field GetInventoryCount fun(self: CraftSim.INVENTORY_API, itemIDOrLink: ItemID | string): number
---@field GetAuctionAmount fun(self: CraftSim.INVENTORY_API, itemIDOrLink: ItemID | string): number?
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
    -- Note: CraftSimSYNDICATOR is defined in this file; CraftSimTSM is a global defined in PriceAPIs.lua (loaded first)
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
        if C_AddOns.IsAddOnLoaded(addonName) then
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

--- TODO: when fetch by itemlink is fixed, use it
--- Returns the total inventory count (bags + bank) for an itemID.
--- Uses Syndicator's data to query current character inventory.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include all characters; if false/nil, only current player
---@return number count
function CraftSimSYNDICATOR:GetInventoryCount(itemIDOrLink, includeAlts)
    if not self:IsAvailable() then return 0 end
    if not itemIDOrLink then return 0 end

    ---@type {characters: {auctions: number, bags: number, bank: number, equipped: number, mail: number, void: number}[], guild: table, warband: table<number>}
    local inventoryInfo

    if Syndicator.API and Syndicator.API.GetInventoryInfo then
        if type(itemIDOrLink) == "string" then
            local itemID = GUTIL:GetItemIDByLink(itemIDOrLink)
            ---@diagnostic disable-next-line: cast-local-type
            inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(itemID) or 0
        else
            ---@diagnostic disable-next-line: cast-local-type
            inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(itemIDOrLink) or 0
        end
    end

    local total = 0
    if inventoryInfo and inventoryInfo.characters then
        local playerName = nil
        local playerRealm = nil
        if not includeAlts then
            -- Use UnitNameUnmodified to get the bare character name, and
            -- GetNormalizedRealmName for the realm, to match Syndicator's format
            playerName, playerRealm = UnitNameUnmodified("player")
            playerRealm = playerRealm or GetNormalizedRealmName()
        end
        for _, characterInfo in ipairs(inventoryInfo.characters) do
            local charInfo = characterInfo.character
            -- Match by both name and realm to handle same-name characters on different realms
            if includeAlts or (charInfo and charInfo.name == playerName and charInfo.realm == playerRealm) then
                total = total + (characterInfo.bags or 0) + (characterInfo.bank or 0) +
                    (characterInfo.equipped or 0) + (characterInfo.mail or 0) +
                    (characterInfo.void or 0) + (characterInfo.auctions or 0)
            end
        end

        -- Warband is always included regardless of includeAlts setting
        if inventoryInfo.warband and inventoryInfo.warband[1] then
            total = total + (inventoryInfo.warband[1] or 0)
        end
    end

    return total
end

--- Returns the count of items posted on the AH by the player via Syndicator.
--- Returns nil if not supported.
---@param itemIDOrLink ItemID | string
---@return number? auctionAmount
function CraftSimSYNDICATOR:GetAuctionAmount(itemIDOrLink)
    if not self:IsAvailable() then return 0 end
    if not itemIDOrLink then return 0 end

    ---@type {characters: {auctions: number, bags: number, bank: number, equipped: number, mail: number, void: number}[], guild: table, warband: table<number>}
    local inventoryInfo

    if Syndicator.API and Syndicator.API.GetInventoryInfo then
        if type(itemIDOrLink) == "string" then
            local itemID = GUTIL:GetItemIDByLink(itemIDOrLink)
            ---@diagnostic disable-next-line: cast-local-type
            inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(itemID) or 0
        else
            ---@diagnostic disable-next-line: cast-local-type
            inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(itemIDOrLink) or 0
        end
    end

    local total = 0
    if inventoryInfo and inventoryInfo.characters then
        for _, characterInfo in ipairs(inventoryInfo.characters) do
            total = total + (characterInfo.auctions or 0)
        end
    end

    return total
end

-- ---------------------------------------------------------------------------
-- CraftSimTSM: Inventory (extends existing CraftSimTSM)
-- ---------------------------------------------------------------------------

--- Returns the total inventory count (bags + bank + optionally AH) for an itemID via TSM.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include alts; if false, exclude alts; if nil, use global setting
---@return number count
function CraftSimTSM:GetInventoryCount(itemIDOrLink, includeAlts)
    if not self:IsAvailable() then return 0 end
    if not itemIDOrLink then return 0 end

    local tsmStr = ""
    if type(itemIDOrLink) == "string" then
        tsmStr = TSM_API.ToItemString(itemIDOrLink)
    else
        tsmStr = "i:" .. itemIDOrLink
    end

    local numPlayer, numAlts, numAuctions, numAltAuctions = TSM_API.GetPlayerTotals(tsmStr)
    local total = (numPlayer or 0) + (numAuctions or 0)

    -- includeAlts=true/false overrides the global alts setting; nil falls back to it
    local shouldIncludeAlts = includeAlts ~= nil and includeAlts or
        CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_ALTS")
    if shouldIncludeAlts then
        total = total + (numAlts or 0) + (numAltAuctions or 0)
    end

    -- Warband is always included when called from a craft-list context (includeAlts ~= nil).
    -- For other callers (includeAlts == nil) fall back to the global warbank setting.
    local shouldIncludeWarbank = includeAlts ~= nil or
        CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_WARBANK")
    if shouldIncludeWarbank then
        total = total + (TSM_API.GetWarbankQuantity and TSM_API.GetWarbankQuantity(tsmStr) or 0)
    end

    return total
end

---@param idOrLink? number | string
---@return number? auctionAmount
function CraftSimTSM:GetAuctionAmount(idOrLink)
    if not idOrLink then
        return
    end
    if type(idOrLink) == 'number' then
        return CraftSimTSM:GetAuctionAmountByItemID(idOrLink)
    else
        return CraftSimTSM:GetAuctionAmountByItemLink(idOrLink)
    end
end

function CraftSimTSM:GetAuctionAmountByItemID(itemID)
    return TSM_API.GetAuctionQuantity("i:" .. itemID)
end

function CraftSimTSM:GetAuctionAmountByItemLink(itemLink)
    return TSM_API.GetAuctionQuantity(TSM_API.ToItemString(itemLink))
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
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include alt characters' inventory; if false/nil, only current player
---@return number count
function CraftSim.INVENTORY_SOURCE:GetInventoryCount(itemIDOrLink, includeAlts)
    if not itemIDOrLink then return 0 end
    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetInventoryCount then
        return CraftSim.INVENTORY_API:GetInventoryCount(itemIDOrLink, includeAlts) or 0
    end
    return CraftSimINVENTORY_NONE:GetInventoryCount(itemIDOrLink)
end

--- Returns the count of items currently posted on the AH using the active inventory addon.
--- Returns nil if the active addon does not support AH post counting.
---@param itemIDOrLink number | string
---@return number? auctionAmount
function CraftSim.INVENTORY_SOURCE:GetAuctionAmount(itemIDOrLink)
    if not itemIDOrLink then return nil end

    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetAuctionAmount then
        return CraftSim.INVENTORY_API:GetAuctionAmount(itemIDOrLink)
    end
    return nil
end
