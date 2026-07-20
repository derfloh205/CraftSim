---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.INVENTORY_API
---@field name string
---@field GetInventoryCount fun(self: CraftSim.INVENTORY_API, itemIDOrLink: ItemID | string): number
---@field GetAuctionAmount fun(self: CraftSim.INVENTORY_API, itemIDOrLink: ItemID | string): number?
---@field GetInventoryBreakdownLines fun(self: CraftSim.INVENTORY_API, itemIDOrLink: ItemID | string, includeAlts: boolean?): {label: string, count: number}[]
CraftSim.INVENTORY_API = {}
CraftSim.INVENTORY_APIS = {}

CraftSimSYNDICATOR = { name = "Syndicator" }
CraftSimINVENTORY_NONE = { name = "CraftSim" }

local Logger = CraftSim.DEBUG:RegisterLogger("InventorySource")

--- Shared short-lived cache for all inventory sources (TSM, Syndicator, fallback).
---@type table<string, { value: any, t: number }>
local inventorySourceCache = {}
local INVENTORY_SOURCE_CACHE_TTL = {
    count = 1.0,
    breakdown = 1.0,
    auction = 2.0,
}

---@param value any
---@return boolean
local function IsSecretValue(value)
    return issecretvalue ~= nil and issecretvalue(value)
end

---@class CraftSim.InventoryQueryInput
---@field itemID number
---@field itemIDOrLink number | string
---@field qualityID number
---@field qualityItemLevels table<number, number>? recipe quality tier -> reference item level

---@param itemIDOrLink number | string
---@return CraftSim.InventoryQueryInput?
local function ResolveInventoryQueryInput(itemIDOrLink)
    if not itemIDOrLink then
        return nil
    end
    if type(itemIDOrLink) == "number" then
        return { itemID = itemIDOrLink, itemIDOrLink = itemIDOrLink, qualityID = 0 }
    end
    if type(itemIDOrLink) ~= "string" or IsSecretValue(itemIDOrLink) then
        return nil
    end

    local itemID = GUTIL:GetItemIDByLink(itemIDOrLink)
    if not itemID then
        return nil
    end

    -- Always prefer quality from the link when present (gear and crafted reagents).
    local qualityID = GUTIL:GetQualityIDFromLink(itemIDOrLink) or 0
    return { itemID = itemID, itemIDOrLink = itemIDOrLink, qualityID = qualityID }
end

---@param query CraftSim.InventoryQueryInput
---@return number | string
local function InventoryBackendArg(query)
    if query.qualityID > 0 then
        return query.itemIDOrLink
    end
    return query.itemID
end

---@param kind "count"|"breakdown"|"auction"|"tradable"
---@param apiName string
---@param query CraftSim.InventoryQueryInput
---@param includeAlts boolean?
---@return string
local function BuildInventorySourceCacheKey(kind, apiName, query, includeAlts)
    local refIlvl = 0
    if query.qualityItemLevels and query.qualityID > 0 then
        refIlvl = query.qualityItemLevels[query.qualityID] or 0
    end
    return string.format("%s|%s|%s|%d|%d|%d", kind, apiName, tostring(includeAlts), query.itemID, query.qualityID,
        refIlvl)
end

---@param itemLink string
---@param qualityItemLevels table<number, number>?
---@return number
local function ResolveCraftingQualityFromItemLink(itemLink, qualityItemLevels)
    if not itemLink or IsSecretValue(itemLink) then
        return 0
    end
    local linkQuality = GUTIL:GetQualityIDFromLink(itemLink)
    if linkQuality and linkQuality > 0 then
        return linkQuality
    end
    if not qualityItemLevels then
        return 0
    end
    local itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink)
    if not itemLevel or itemLevel <= 0 then
        return 0
    end
    for qualityID, refLevel in pairs(qualityItemLevels) do
        if refLevel == itemLevel then
            return qualityID
        end
    end
    return 0
end

---@param itemLink string
---@param targetQualityID number
---@param qualityItemLevels table<number, number>?
---@return boolean
local function InventoryItemMatchesQuality(itemLink, targetQualityID, qualityItemLevels)
    if targetQualityID <= 0 then
        return true
    end
    return ResolveCraftingQualityFromItemLink(itemLink, qualityItemLevels) == targetQualityID
end

--- Build reference item levels for each craft result quality (used when link quality tags are missing).
---@param recipeData CraftSim.RecipeData
---@return table<number, number>
function CraftSim.INVENTORY_SOURCE:BuildQualityItemLevels(recipeData)
    local levels = {}
    if not recipeData or not recipeData.resultData then
        return levels
    end
    for qualityID, item in pairs(recipeData.resultData.itemsByQuality) do
        local link = item and item:GetItemLink()
        if link and not IsSecretValue(link) then
            local itemLevel = C_Item.GetDetailedItemLevelInfo(link)
            if itemLevel and itemLevel > 0 then
                levels[qualityID] = itemLevel
            end
        end
    end
    return levels
end

---@param query CraftSim.InventoryQueryInput
---@param qualityIDOverride number?
---@param qualityItemLevels table<number, number>?
local function ApplyInventoryQualityContext(query, qualityIDOverride, qualityItemLevels)
    if qualityIDOverride and qualityIDOverride > 0 then
        query.qualityID = qualityIDOverride
    end
    if qualityItemLevels then
        query.qualityItemLevels = qualityItemLevels
    end
end

---@param key string
---@param ttl number
---@return any value
---@return boolean hit
local function GetInventorySourceCacheEntry(key, ttl)
    local entry = inventorySourceCache[key]
    if entry and (GetTime() - entry.t) < ttl then
        return entry.value, true
    end
    return nil, false
end

---@param key string
---@param value any
local function SetInventorySourceCacheEntry(key, value)
    inventorySourceCache[key] = { value = value, t = GetTime() }
end

---@param lines {label: string, count: number}[]
---@return {label: string, count: number}[]
local function CopyInventoryBreakdownLines(lines)
    local copy = {}
    for i, line in ipairs(lines) do
        copy[i] = { label = line.label, count = line.count }
    end
    return copy
end

---@param a number|string?
---@param b number|string?
---@return boolean
local function InventoryItemIDsMatch(a, b)
    if a == nil or b == nil then
        return false
    end
    return tonumber(a) == tonumber(b)
end

---@param itemLoc ItemLocationMixin
---@return string?
local function GetItemLinkFromLocation(itemLoc)
    if not itemLoc:IsValid() then
        return nil
    end
    local link = C_Item.GetItemLink(itemLoc)
    if link and not IsSecretValue(link) then
        return link
    end
    local bag, slot = itemLoc:GetBagAndSlot()
    if bag ~= nil and slot ~= nil then
        link = C_Container.GetContainerItemLink(bag, slot)
        if link and not IsSecretValue(link) then
            return link
        end
    end
    return nil
end

---@param itemLoc ItemLocationMixin
---@param query CraftSim.InventoryQueryInput
---@return boolean
local function ItemLocationMatchesInventoryQuery(itemLoc, query)
    if not itemLoc:IsValid() then
        return false
    end
    local locItemID = C_Item.GetItemID(itemLoc)
    if not locItemID or locItemID ~= query.itemID then
        return false
    end
    if query.qualityID > 0 then
        local locLink = GetItemLinkFromLocation(itemLoc)
        if not locLink then
            return false
        end
        return InventoryItemMatchesQuality(locLink, query.qualityID, query.qualityItemLevels)
    end
    return true
end

--- Count item stacks in the current character's bags, bank, and warband bank.
---@param query CraftSim.InventoryQueryInput
---@param includeBound boolean? when true, soulbound stacks are included (quality still matched)
---@return number
local function CountInPlayerInventory(query, includeBound)
    local count = 0
    local bagRanges = {
        { Enum.BagIndex.Backpack, Enum.BagIndex.Bag_4 },
        { Enum.BagIndex.CharacterBankTab_1, Enum.BagIndex.CharacterBankTab_6 },
        { Enum.BagIndex.AccountBankTab_1, Enum.BagIndex.AccountBankTab_5 },
    }

    for _, range in ipairs(bagRanges) do
        for bag = range[1], range[2] do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)
                if itemLoc:IsValid()
                    and (includeBound or not C_Item.IsBound(itemLoc))
                    and ItemLocationMatchesInventoryQuery(itemLoc, query) then
                    count = count + (C_Item.GetStackCount(itemLoc) or 1)
                end
            end
        end
    end

    return count
end

--- Count unbound item stacks in the current character's bags, bank, and warband bank.
---@param query CraftSim.InventoryQueryInput
---@return number
local function CountUnboundInPlayerInventory(query)
    return CountInPlayerInventory(query, false)
end

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

---@alias SyndicatorBasicCacheInfo {itemID: string, itemLink: string, itemCount: number}

---@alias SyndicatorCharacterInfo {auctions: SyndicatorBasicCacheInfo[], bags: SyndicatorBasicCacheInfo[][], bankTabs: {slots: SyndicatorBasicCacheInfo[]}[], equipped: number, mail: number, void: number, auctions: number}
---@alias SyndicatorWarbandInfo {bank: {slots: SyndicatorBasicCacheInfo[]}[]}[]

---@class SyndicatorData
---@field Characters table<CrafterUID, SyndicatorCharacterInfo>
---@field Guild table -- not relevant yet
---@field Warband SyndicatorWarbandInfo

---@param item ItemMixin
---@param includeAlts boolean? default: false
---@return number total, number warbank, table<CrafterUID, {bags: number, bank: number, auctions: number}> charMap
function CraftSimSYNDICATOR:GetGearInventoryCount(item, includeAlts)
    includeAlts = includeAlts or false
    local itemLink = item:GetItemLink()
    local quality = GUTIL:GetQualityIDFromLink(itemLink)
    local refItemLevel = itemLink and C_Item.GetDetailedItemLevelInfo(itemLink) or nil
    local itemID = item:GetItemID()
    local totalCount = 0
    local warbank = 0
    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local sourceMap = {}

    Logger:LogDebug("Syndicator GetGearInventoryCount: {itemLink}", item:GetItemLink())

    ---@type SyndicatorData
    local syndicatorData = SYNDICATOR_DATA

    if not syndicatorData then
        Logger:LogFatal("SYNDICATOR_DATA not available")
    end

    local function syndicatorItemMatchesQuality(invItemLink)
        if not invItemLink then
            return false
        end
        if quality and quality > 0 then
            return InventoryItemMatchesQuality(invItemLink, quality, refItemLevel and { [quality] = refItemLevel } or nil)
        end
        if refItemLevel then
            return C_Item.GetDetailedItemLevelInfo(invItemLink) == refItemLevel
        end
        return GUTIL:GetQualityIDFromLink(invItemLink) == quality
    end

    --- sum occurances in characters
    for crafterUID, data in pairs(syndicatorData.Characters) do
        sourceMap[crafterUID] = { bags = 0, bank = 0, auctions = 0 }
        if includeAlts or crafterUID == playerCrafterUID then
            for _, bags in ipairs(data.bags or {}) do
                for _, invItem in pairs(bags or {}) do
                    if invItem and InventoryItemIDsMatch(invItem.itemID, itemID)
                        and syndicatorItemMatchesQuality(invItem.itemLink) then
                        Logger:LogDebug("- Found in bags x{count}", invItem.itemCount)
                        totalCount = totalCount + invItem.itemCount
                        sourceMap[crafterUID].bags = sourceMap[crafterUID].bags + invItem.itemCount
                    end
                end
            end

            for _, invInfo in ipairs(data.bankTabs or {}) do
                for _, invItem in pairs(invInfo.slots or {}) do
                    if invItem and InventoryItemIDsMatch(invItem.itemID, itemID)
                        and syndicatorItemMatchesQuality(invItem.itemLink) then
                        Logger:LogDebug("- Found in bankTabs x{count}", invItem.itemCount)
                        totalCount = totalCount + invItem.itemCount
                        sourceMap[crafterUID].bank = sourceMap[crafterUID].bank + invItem.itemCount
                    end
                end
            end

            for _, invItem in ipairs(data.auctions or {}) do
                if invItem and InventoryItemIDsMatch(invItem.itemID, itemID)
                    and syndicatorItemMatchesQuality(invItem.itemLink) then
                    Logger:LogDebug("- Found in auctions x{count}", invItem.itemCount)

                    totalCount = totalCount + invItem.itemCount
                    sourceMap[crafterUID].auctions = sourceMap[crafterUID].auctions + invItem.itemCount
                end
            end
        end
    end

    for _, warbandInfo in ipairs(syndicatorData.Warband or {}) do
        for _, invInfo in ipairs(warbandInfo.bank) do
            for _, invItem in pairs(invInfo.slots) do
                if invItem and InventoryItemIDsMatch(invItem.itemID, itemID)
                    and syndicatorItemMatchesQuality(invItem.itemLink) then
                    Logger:LogDebug("- Found in warband bank x{count}", invItem.itemCount)
                    totalCount = totalCount + invItem.itemCount
                    warbank = warbank + invItem.itemCount
                end
            end
        end
    end

    Logger:LogDebug("Total count for itemID {itemLink}: {count}", item:GetItemLink(), totalCount)


    return totalCount, warbank, sourceMap
end

--- TODO: when fetch by itemlink is fixed, use it
--- Returns the total inventory count (bags + bank) for an itemID.
--- Uses Syndicator's data to query current character inventory.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include all characters; if false/nil, only current player
---@return number total
function CraftSimSYNDICATOR:GetInventoryCount(itemIDOrLink, includeAlts)
    if not self:IsAvailable() then return 0 end
    if not itemIDOrLink then return 0 end

    if type(itemIDOrLink) == "string" and not IsSecretValue(itemIDOrLink) then
        -- check if gear
        local item = Item:CreateFromItemLink(itemIDOrLink)
        if item then
            if item:GetInventoryType() ~= Enum.InventoryType.IndexNonEquipType then
                return select(1, CraftSimSYNDICATOR:GetGearInventoryCount(item, includeAlts))
            end
        end
    end

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
            -- Match by both name and realm to handle same-name characters on different realms
            if includeAlts or (characterInfo and characterInfo.character == playerName and characterInfo.realmNormalized == playerRealm) then
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

--- Returns a per-source inventory breakdown list for tooltip display.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include all characters; if false/nil, only current player
---@return {label: string, count: number}[] lines
function CraftSimSYNDICATOR:GetInventoryBreakdownLines(itemIDOrLink, includeAlts)
    if not self:IsAvailable() then return {} end
    if not itemIDOrLink then return {} end

    ---@type {characters: {character: string, realmNormalized: string, auctions: number, bags: number, bank: number, equipped: number, mail: number, void: number}[], guild: table, warband: table<number>}
    local inventoryInfo

    if type(itemIDOrLink) == "string" then
        -- check if gear
        local item = Item:CreateFromItemLink(itemIDOrLink)
        if item then
            if item:GetInventoryType() ~= Enum.InventoryType.IndexNonEquipType then
                Logger:LogDebug("Item is gear, using GetGearInventoryCount for breakdown lines")
                local total, warbank, sourceMap = CraftSimSYNDICATOR:GetGearInventoryCount(item, includeAlts)
                local lines = {}
                for crafterUID, sources in pairs(sourceMap) do
                    local charLabel = crafterUID
                    if sources.bags > 0 then
                        table.insert(lines, { label = charLabel .. " (bags)", count = sources.bags })
                    end
                    if sources.bank > 0 then
                        table.insert(lines, { label = charLabel .. " (bank)", count = sources.bank })
                    end
                    if sources.auctions > 0 then
                        table.insert(lines, { label = charLabel .. " (AH)", count = sources.auctions })
                    end
                end
                if warbank > 0 then
                    table.insert(lines, { label = "Warband", count = warbank })
                end
                return lines
            end
        end
    end

    if Syndicator.API and Syndicator.API.GetInventoryInfo then
        if type(itemIDOrLink) == "string" then
            local itemID = GUTIL:GetItemIDByLink(itemIDOrLink)
            ---@diagnostic disable-next-line: cast-local-type
            inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(itemID) or {}
        else
            ---@diagnostic disable-next-line: cast-local-type
            inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(itemIDOrLink) or {}
        end
    end

    if not inventoryInfo or not inventoryInfo.characters then return {} end

    local lines = {}
    local playerName, playerRealm
    if not includeAlts then
        playerName, playerRealm = UnitNameUnmodified("player")
        playerRealm = playerRealm or GetNormalizedRealmName()
    end

    for _, characterInfo in ipairs(inventoryInfo.characters) do
        if includeAlts or (characterInfo and characterInfo.character == playerName and characterInfo.realmNormalized == playerRealm) then
            local charLabel = (characterInfo and characterInfo.character and characterInfo.realmNormalized)
                and (characterInfo.character .. "-" .. characterInfo.realmNormalized) or "Unknown"
            local charInv = (characterInfo.bags or 0) + (characterInfo.bank or 0) +
                (characterInfo.equipped or 0) + (characterInfo.mail or 0) + (characterInfo.void or 0)
            table.insert(lines, { label = charLabel .. " (inv)", count = charInv })
            table.insert(lines, { label = charLabel .. " (AH)", count = characterInfo.auctions or 0 })
        end
    end

    -- Warband always included
    if inventoryInfo.warband and inventoryInfo.warband[1] and inventoryInfo.warband[1] > 0 then
        table.insert(lines, { label = "Warband", count = inventoryInfo.warband[1] or 0 })
    end

    return lines
end

--- Returns the count of items posted on the AH by the player via Syndicator.
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

--- Short-lived cache to collapse burst TSM_API calls during queue/UI refreshes.
---@type table<string, { value: any, t: number }>
local tsmInventoryCache = {}
local TSM_INVENTORY_CACHE_TTL = {
    inv = 1.0,
    breakdown = 1.0,
    ah = 2.0,
}
local tsmInventoryCacheStats = { hits = 0, misses = 0 }

---@param itemIDOrLink ItemID | string
---@return number? itemID
local function ResolveTSMItemID(itemIDOrLink)
    local query = ResolveInventoryQueryInput(itemIDOrLink)
    if query then
        return query.itemID
    end
    if type(itemIDOrLink) == "string" and not IsSecretValue(itemIDOrLink) and TSM_API and TSM_API.ToItemString then
        local tsmStr = TSM_API.ToItemString(itemIDOrLink)
        if tsmStr and not IsSecretValue(tsmStr) then
            return tonumber(tsmStr:match("^i:(%d+)"))
        end
    end
    return nil
end

---@param itemID number
---@return string
local function ToTSMItemString(itemID)
    return "i:" .. itemID
end

---@param tsmStr string
---@return number? numPlayer
---@return number? numAlts
---@return number? numAuctions
---@return number? numAltAuctions
local function SafeTSMGetPlayerTotals(tsmStr)
    local ok, numPlayer, numAlts, numAuctions, numAltAuctions = pcall(TSM_API.GetPlayerTotals, tsmStr)
    if not ok then
        Logger:LogWarning("TSM GetPlayerTotals failed for {tsmStr}: {err}", tsmStr, tostring(numPlayer))
        return 0, 0, 0, 0
    end
    return numPlayer, numAlts, numAuctions, numAltAuctions
end

---@param tsmStr string
---@return number
local function SafeTSMGetWarbankQuantity(tsmStr)
    if not TSM_API.GetWarbankQuantity then
        return 0
    end
    local ok, quantity = pcall(TSM_API.GetWarbankQuantity, tsmStr)
    if not ok then
        Logger:LogWarning("TSM GetWarbankQuantity failed for {tsmStr}: {err}", tsmStr, tostring(quantity))
        return 0
    end
    return quantity or 0
end

---@param tsmStr string
---@return number?
local function SafeTSMGetAuctionQuantity(tsmStr)
    local ok, quantity = pcall(TSM_API.GetAuctionQuantity, tsmStr)
    if not ok then
        Logger:LogWarning("TSM GetAuctionQuantity failed for {tsmStr}: {err}", tsmStr, tostring(quantity))
        return nil
    end
    return quantity
end

---@param includeAlts boolean?
---@return boolean shouldIncludeAlts
---@return boolean shouldIncludeWarbank
local function GetTSMInventoryIncludeModes(includeAlts)
    local shouldIncludeAlts = includeAlts ~= nil and includeAlts or
        CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_ALTS")
    local shouldIncludeWarbank = includeAlts ~= nil or
        CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_WARBANK")
    return shouldIncludeAlts, shouldIncludeWarbank
end

---@param kind "inv"|"breakdown"|"ah"
---@param itemID number
---@param includeAlts boolean?
---@return string
local function BuildTSMInventoryCacheKey(kind, itemID, includeAlts)
    if kind == "ah" then
        return kind .. "|" .. itemID
    end
    local shouldIncludeAlts, shouldIncludeWarbank = GetTSMInventoryIncludeModes(includeAlts)
    return string.format("%s|%d|alts:%s|warbank:%s", kind, itemID, tostring(shouldIncludeAlts),
        tostring(shouldIncludeWarbank))
end

---@param key string
---@param ttl number
---@return any value
---@return boolean hit
local function GetTSMInventoryCacheEntry(key, ttl)
    local entry = tsmInventoryCache[key]
    if entry and (GetTime() - entry.t) < ttl then
        tsmInventoryCacheStats.hits = tsmInventoryCacheStats.hits + 1
        return entry.value, true
    end
    tsmInventoryCacheStats.misses = tsmInventoryCacheStats.misses + 1
    return nil, false
end

---@param key string
---@param value any
local function SetTSMInventoryCacheEntry(key, value)
    tsmInventoryCache[key] = { value = value, t = GetTime() }
end

---@param lines {label: string, count: number}[]
---@return {label: string, count: number}[]
local function CopyTSMInventoryBreakdownLines(lines)
    return CopyInventoryBreakdownLines(lines)
end

--- Invalidate cached TSM inventory totals (bag/craft/purchase events).
function CraftSimTSM:ClearInventoryCache()
    wipe(tsmInventoryCache)
end

---@return { hits: number, misses: number }
function CraftSimTSM:GetInventoryCacheStats()
    return tsmInventoryCacheStats
end

--- Returns the total inventory count (bags + bank + optionally AH) for an itemID via TSM.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include alts; if false, exclude alts; if nil, use global setting
---@return number count
function CraftSimTSM:GetInventoryCount(itemIDOrLink, includeAlts)
    if not self:IsAvailable() then return 0 end
    if not itemIDOrLink then return 0 end

    local itemID = ResolveTSMItemID(itemIDOrLink)
    if not itemID then return 0 end

    local tsmStr = ToTSMItemString(itemID)
    local cacheKey = BuildTSMInventoryCacheKey("inv", itemID, includeAlts)
    local cached, hit = GetTSMInventoryCacheEntry(cacheKey, TSM_INVENTORY_CACHE_TTL.inv)
    if hit then
        return cached or 0
    end

    local numPlayer, numAlts, numAuctions, numAltAuctions = SafeTSMGetPlayerTotals(tsmStr)
    local total = (numPlayer or 0) + (numAuctions or 0)

    -- includeAlts=true/false overrides the global alts setting; nil falls back to it
    local shouldIncludeAlts, shouldIncludeWarbank = GetTSMInventoryIncludeModes(includeAlts)
    if shouldIncludeAlts then
        total = total + (numAlts or 0) + (numAltAuctions or 0)
    end

    -- Warband is always included when called from a craft-list context (includeAlts ~= nil).
    -- For other callers (includeAlts == nil) fall back to the global warbank setting.
    if shouldIncludeWarbank then
        total = total + SafeTSMGetWarbankQuantity(tsmStr)
    end

    SetTSMInventoryCacheEntry(cacheKey, total)
    return total
end

--- Returns a per-source inventory breakdown list for tooltip display.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include alts; if false, exclude alts; if nil, use global setting
---@return {label: string, count: number}[] lines
function CraftSimTSM:GetInventoryBreakdownLines(itemIDOrLink, includeAlts)
    if not self:IsAvailable() then return {} end
    if not itemIDOrLink then return {} end

    local itemID = ResolveTSMItemID(itemIDOrLink)
    if not itemID then return {} end

    local tsmStr = ToTSMItemString(itemID)
    local cacheKey = BuildTSMInventoryCacheKey("breakdown", itemID, includeAlts)
    local cached, hit = GetTSMInventoryCacheEntry(cacheKey, TSM_INVENTORY_CACHE_TTL.breakdown)
    if hit then
        return CopyTSMInventoryBreakdownLines(cached or {})
    end

    local numPlayer, numAlts, numAuctions, numAltAuctions = SafeTSMGetPlayerTotals(tsmStr)

    local shouldIncludeAlts, shouldIncludeWarbank = GetTSMInventoryIncludeModes(includeAlts)

    local lines = {}
    table.insert(lines, { label = "Player", count = numPlayer or 0 })
    table.insert(lines, { label = "AH", count = numAuctions or 0 })
    if shouldIncludeAlts then
        table.insert(lines, { label = "Alts", count = numAlts or 0 })
        table.insert(lines, { label = "Alt AH", count = numAltAuctions or 0 })
    end
    if shouldIncludeWarbank then
        table.insert(lines, { label = "Warband", count = SafeTSMGetWarbankQuantity(tsmStr) })
    end

    SetTSMInventoryCacheEntry(cacheKey, CopyTSMInventoryBreakdownLines(lines))
    return lines
end

---@param idOrLink? number | string
---@return number? auctionAmount
function CraftSimTSM:GetAuctionAmount(idOrLink)
    if not idOrLink then
        return
    end
    local itemID = ResolveTSMItemID(idOrLink)
    if not itemID then
        return nil
    end
    return CraftSimTSM:GetAuctionAmountByItemID(itemID)
end

---@param itemID number
---@return number? auctionAmount
function CraftSimTSM:GetAuctionAmountByItemID(itemID)
    if not self:IsAvailable() then return nil end
    local tsmStr = ToTSMItemString(itemID)
    local cacheKey = BuildTSMInventoryCacheKey("ah", itemID)
    local cached, hit = GetTSMInventoryCacheEntry(cacheKey, TSM_INVENTORY_CACHE_TTL.ah)
    if hit then
        return cached
    end
    local amount = SafeTSMGetAuctionQuantity(tsmStr)
    SetTSMInventoryCacheEntry(cacheKey, amount)
    return amount
end

---@param itemLink string
---@return number? auctionAmount
function CraftSimTSM:GetAuctionAmountByItemLink(itemLink)
    local itemID = ResolveTSMItemID(itemLink)
    if not itemID then
        return nil
    end
    return CraftSimTSM:GetAuctionAmountByItemID(itemID)
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

--- Returns a per-source inventory breakdown list for tooltip display.
---@param itemID ItemID | string
---@return {label: string, count: number}[] lines
function CraftSimINVENTORY_NONE:GetInventoryBreakdownLines(itemID)
    if not itemID then return {} end
    local count = C_Item.GetItemCount(itemID, true, false, true) or 0
    return { { label = "Current character", count = count } }
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

    local query = ResolveInventoryQueryInput(itemIDOrLink)
    if not query then return 0 end

    local apiName = (CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.name) or CraftSimINVENTORY_NONE.name
    local cacheKey = BuildInventorySourceCacheKey("count", apiName, query, includeAlts)
    local cached, hit = GetInventorySourceCacheEntry(cacheKey, INVENTORY_SOURCE_CACHE_TTL.count)
    if hit then
        return cached or 0
    end

    local backendArg = InventoryBackendArg(query)
    local count = 0
    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetInventoryCount then
        count = CraftSim.INVENTORY_API:GetInventoryCount(backendArg, includeAlts) or 0
    else
        count = CraftSimINVENTORY_NONE:GetInventoryCount(backendArg) or 0
    end

    SetInventorySourceCacheEntry(cacheKey, count)
    return count
end

--- Count AH posts from Syndicator character cache, optionally filtered by quality.
---@param query CraftSim.InventoryQueryInput
---@param includeAlts boolean?
---@return number? nil if Syndicator data is unavailable
local function CountSyndicatorAuctionsForQuery(query, includeAlts)
    ---@type SyndicatorData?
    local syndicatorData = SYNDICATOR_DATA
    if not syndicatorData or not syndicatorData.Characters then
        return nil
    end

    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local playerTotal = 0
    local accountTotal = 0
    local matchedPlayer = false

    for crafterUID, data in pairs(syndicatorData.Characters) do
        local matchesPlayer = crafterUID == playerCrafterUID
            or CraftSim.UTIL:NormalizeCrafterUIDKey(crafterUID) == playerCrafterUID
        local charTotal = 0
        for _, invItem in ipairs(data.auctions or {}) do
                if invItem and InventoryItemIDsMatch(invItem.itemID, query.itemID) then
                if query.qualityID <= 0
                    or InventoryItemMatchesQuality(invItem.itemLink, query.qualityID, query.qualityItemLevels) then
                    charTotal = charTotal + (invItem.itemCount or 0)
                end
            end
        end
        accountTotal = accountTotal + charTotal
        if matchesPlayer then
            matchedPlayer = true
            playerTotal = playerTotal + charTotal
        end
    end

    if includeAlts then
        return accountTotal
    end
    -- If crafter UID keys don't match Syndicator's format, fall back to account AH
    -- rather than under-counting (which over-queues restock).
    if matchedPlayer then
        return playerTotal
    end
    return accountTotal
end

--- Returns AH listings that should count toward restock for the given alt scope.
--- When the query includes a crafting quality, only auctions of that quality are counted.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean?
---@param qualityIDOverride number? force a crafting quality filter (1-5)
---@param qualityItemLevels table<number, number>? recipe reference ilvls per quality tier
---@return number
function CraftSim.INVENTORY_SOURCE:GetTradableAuctionCount(itemIDOrLink, includeAlts, qualityIDOverride, qualityItemLevels)
    if not itemIDOrLink then
        return 0
    end

    local query = ResolveInventoryQueryInput(itemIDOrLink)
    if not query then
        return 0
    end
    ApplyInventoryQualityContext(query, qualityIDOverride, qualityItemLevels)

    -- Prefer Syndicator for quality-aware AH counts. TSM item strings often collapse
    -- quality variants and under-count when a quality-specific string is used.
    if CraftSimSYNDICATOR and CraftSimSYNDICATOR.IsAvailable and CraftSimSYNDICATOR:IsAvailable() then
        local syndicatorCount = CountSyndicatorAuctionsForQuery(query, includeAlts)
        if syndicatorCount ~= nil then
            return syndicatorCount
        end

        if query.qualityID <= 0
            and Syndicator and Syndicator.API and Syndicator.API.GetInventoryInfoByItemID then
            local inventoryInfo = Syndicator.API.GetInventoryInfoByItemID(query.itemID)
            if inventoryInfo and inventoryInfo.characters then
                local total = 0
                local playerName, playerRealm
                if not includeAlts then
                    playerName, playerRealm = UnitNameUnmodified("player")
                    playerRealm = playerRealm or GetNormalizedRealmName()
                end
                for _, characterInfo in ipairs(inventoryInfo.characters) do
                    if includeAlts
                        or (characterInfo and characterInfo.character == playerName
                            and characterInfo.realmNormalized == playerRealm) then
                        total = total + (characterInfo.auctions or 0)
                    end
                end
                return total
            end
        end
    end

    if CraftSimTSM and CraftSimTSM.IsAvailable and CraftSimTSM:IsAvailable() then
        -- Quality-specific TSM strings are unreliable for AH; always use base item ID.
        local _, _, numAuctions, numAltAuctions = SafeTSMGetPlayerTotals(ToTSMItemString(query.itemID))
        local amount = numAuctions or 0
        if includeAlts then
            amount = amount + (numAltAuctions or 0)
        end
        -- Without Syndicator we cannot split by quality; avoid double-counting by only
        -- returning the full AH total when no quality filter is requested.
        if query.qualityID > 0 then
            return 0
        end
        return amount
    end

    return self:GetAuctionAmount(itemIDOrLink) or 0
end

--- Returns inventory that counts toward restock targets: unbound bags/bank on the current
--- character plus AH listings. Soulbound items in bags/bank are excluded.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include alt characters' tradable inventory and AH
---@param qualityIDOverride number? force a crafting quality filter (1-5)
---@param qualityItemLevels table<number, number>? recipe reference ilvls per quality tier
---@return number count
function CraftSim.INVENTORY_SOURCE:GetTradableInventoryCount(itemIDOrLink, includeAlts, qualityIDOverride,
    qualityItemLevels)
    if not itemIDOrLink then
        return 0
    end

    local query = ResolveInventoryQueryInput(itemIDOrLink)
    if not query then
        return 0
    end
    ApplyInventoryQualityContext(query, qualityIDOverride, qualityItemLevels)

    local cacheKey = BuildInventorySourceCacheKey("tradable", "CraftSim", query, includeAlts)
    local cached, hit = GetInventorySourceCacheEntry(cacheKey, INVENTORY_SOURCE_CACHE_TTL.count)
    if hit then
        return cached or 0
    end

    -- Bags/bank unbound only — does not include AH.
    local count = CountUnboundInPlayerInventory(query)
    count = count + self:GetTradableAuctionCount(itemIDOrLink, includeAlts, query.qualityID, query.qualityItemLevels)

    if includeAlts and not GUTIL:isItemSoulbound(query.itemID) then
        if CraftSimTSM and CraftSimTSM.IsAvailable and CraftSimTSM:IsAvailable()
            and not (CraftSimSYNDICATOR and CraftSimSYNDICATOR.IsAvailable and CraftSimSYNDICATOR:IsAvailable()) then
            -- Only add TSM alt bags when Syndicator is unavailable (AH already handled above).
            if query.qualityID <= 0 then
                local _, numAlts = SafeTSMGetPlayerTotals(ToTSMItemString(query.itemID))
                count = count + (numAlts or 0)
            end
        elseif not (CraftSimTSM and CraftSimTSM.IsAvailable and CraftSimTSM:IsAvailable()) then
            -- Alt bags/bank/mail/etc only. Strip alt AH so auctions aren't double-counted.
            local total = self:GetInventoryCount(itemIDOrLink, true)
            local playerTotal = self:GetInventoryCount(itemIDOrLink, false)
            local allAuctions = self:GetAuctionAmount(itemIDOrLink) or 0
            local playerAuctions = self:GetTradableAuctionCount(itemIDOrLink, false, query.qualityID, query.qualityItemLevels)
            local altAuctions = math.max(0, allAuctions - playerAuctions)
            local altNonAuction = math.max(0, (total - playerTotal) - altAuctions)
            count = count + altNonAuction
        end
    end

    SetInventorySourceCacheEntry(cacheKey, count)
    return count
end

--- Returns the count of items currently posted on the AH using the active inventory addon.
--- Returns nil if the active addon does not support AH post counting.
---@param itemIDOrLink number | string
---@return number? auctionAmount
function CraftSim.INVENTORY_SOURCE:GetAuctionAmount(itemIDOrLink)
    if not itemIDOrLink then return nil end

    local query = ResolveInventoryQueryInput(itemIDOrLink)
    if not query then return nil end

    local apiName = (CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.name) or CraftSimINVENTORY_NONE.name
    local cacheKey = BuildInventorySourceCacheKey("auction", apiName, query, nil)
    local cached, hit = GetInventorySourceCacheEntry(cacheKey, INVENTORY_SOURCE_CACHE_TTL.auction)
    if hit then
        return cached
    end

    local backendArg = InventoryBackendArg(query)
    local amount = nil
    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetAuctionAmount then
        amount = CraftSim.INVENTORY_API:GetAuctionAmount(backendArg)
    end

    SetInventorySourceCacheEntry(cacheKey, amount)
    return amount
end

--- Returns a per-source inventory breakdown list for tooltip display.
---@param itemIDOrLink ItemID | string
---@param includeAlts boolean? if true, include alt characters' inventory; if false/nil, only current player
---@return {label: string, count: number}[] lines
function CraftSim.INVENTORY_SOURCE:GetInventoryBreakdownLines(itemIDOrLink, includeAlts)
    if not itemIDOrLink then return {} end

    local query = ResolveInventoryQueryInput(itemIDOrLink)
    if not query then return {} end

    local apiName = (CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.name) or CraftSimINVENTORY_NONE.name
    local cacheKey = BuildInventorySourceCacheKey("breakdown", apiName, query, includeAlts)
    local cached, hit = GetInventorySourceCacheEntry(cacheKey, INVENTORY_SOURCE_CACHE_TTL.breakdown)
    if hit then
        return CopyInventoryBreakdownLines(cached or {})
    end

    local backendArg = InventoryBackendArg(query)
    local lines = {}
    if CraftSim.INVENTORY_API and CraftSim.INVENTORY_API.GetInventoryBreakdownLines then
        lines = CraftSim.INVENTORY_API:GetInventoryBreakdownLines(backendArg, includeAlts)
    else
        lines = CraftSimINVENTORY_NONE:GetInventoryBreakdownLines(backendArg)
    end

    lines = CopyInventoryBreakdownLines(lines)
    SetInventorySourceCacheEntry(cacheKey, lines)
    return lines
end

--- Clears short-lived inventory caches when bag/bank/craft state changes.
function CraftSim.INVENTORY_SOURCE:ClearInventoryCache()
    wipe(inventorySourceCache)
    if CraftSimTSM and CraftSimTSM.ClearInventoryCache then
        CraftSimTSM:ClearInventoryCache()
    end
end

---@deprecated Use ClearInventoryCache
function CraftSim.INVENTORY_SOURCE:ClearTSMInventoryCacheIfLoaded()
    self:ClearInventoryCache()
end
