---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

--- NPC Vendor Reagent Integration
--- Detects reagents purchasable from NPC vendors and substitutes
--- their fixed vendor price when it is cheaper than the AH price.
---
--- Price lookup order (when option enabled, for isReagent calls):
---   1. Statically known vendor price  (Data/VendorReagentData.lua)
---   2. Dynamically scanned price      (DB/vendorPriceDB.lua via MERCHANT_SHOW)
--- If a vendor price is found and is cheaper than the AH price,
--- it is returned instead.
---
--- Inline icon used throughout: Interface\Minimap\Tracking\Vendor

---@class CraftSim.VENDOR_INTEGRATION : Frame
CraftSim.VENDOR_INTEGRATION = GUTIL:CreateRegistreeForEvents {
    "MERCHANT_SHOW",
    "MERCHANT_CLOSED",
}

--- WoW game texture for the vendor tracking minimap icon (fits 16-px inline text).
CraftSim.VENDOR_INTEGRATION.ICON_NPC = "|TInterface\\Minimap\\Tracking\\Vendor:16:16|t"
--- Icon representing the Auction House coin stack (inline text usage).
CraftSim.VENDOR_INTEGRATION.ICON_AH  = "|TInterface\\Icons\\inv_misc_coin_01:16:16|t"

local print = CraftSim.DEBUG:RegisterDebugID("Modules.VendorIntegration")

-- ──────────────────────────────────────────────────────────────
-- Option helper
-- ──────────────────────────────────────────────────────────────

---@return boolean
function CraftSim.VENDOR_INTEGRATION:IsEnabled()
    return CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.VENDOR_PRICE_PREFER_NPC)
end

--- Returns true when the vendor price should be used instead of ahPrice.
--- Vendor wins when cheaper OR equal (no AH fees, guaranteed stock).
---@param vendorPrice number  vendor price in copper
---@param ahPrice number|nil  AH buy price in copper (nil = no AH data)
---@return boolean
function CraftSim.VENDOR_INTEGRATION:IsVendorPreferred(vendorPrice, ahPrice)
    if not ahPrice then return true end
    return vendorPrice <= ahPrice
end

-- ──────────────────────────────────────────────────────────────
-- Price lookup
-- ──────────────────────────────────────────────────────────────

---Return the lowest known vendor buy price for *itemID*, or nil when
---this item is not known to be sold by any NPC vendor.
---
---Lookup priority:
---  1. Dynamically discovered price  (from the most recent merchant scan)
---  2. Static data                   (Data/VendorReagentData.lua)
---
---This function does NOT check whether the option is enabled; the
---caller (PriceSource) is responsible for that gate.
---
---@param itemID ItemID
---@return number? vendorPrice  copper, or nil if unknown
---@return string  vendorName
function CraftSim.VENDOR_INTEGRATION:GetVendorPrice(itemID)
    -- 1. Dynamic (most up-to-date, scanned from open merchants)
    local dynEntry = CraftSim.DB.VENDOR_PRICE:Get(itemID)
    if dynEntry and dynEntry.price and dynEntry.price > 0 then
        return dynEntry.price, dynEntry.vendorName
    end

    -- 2. Static database
    local staticEntry = CraftSim.VENDOR_REAGENT_DATA and CraftSim.VENDOR_REAGENT_DATA[itemID]
    if staticEntry and staticEntry.price and staticEntry.price > 0 then
        return staticEntry.price, staticEntry.vendorName
    end

    return nil, ""
end

-- ──────────────────────────────────────────────────────────────
-- Merchant scanning (Phase 4 – Dynamic Vendor Discovery)
-- ──────────────────────────────────────────────────────────────

local SCAN_DELAY = 0.1 -- seconds to wait after MERCHANT_SHOW before scanning

local function ScanMerchant()
    local numItems = GetMerchantNumItems()
    if not numItems or numItems == 0 then return end

    local scanned, updated = 0, 0
    local vendorName = UnitName("target") or ""

    for i = 1, numItems do
        -- C_MerchantFrame.GetItemInfo replaces the old GetMerchantItemInfo global (removed in Midnight)
        local info = C_MerchantFrame.GetItemInfo(i)

        if info and info.name and info.price and info.price > 0 then
            -- GetMerchantItemID is cheaper than going through the item link
            local itemID = GetMerchantItemID(i)
            if itemID then
                local existing = CraftSim.DB.VENDOR_PRICE:Get(itemID)
                -- Only update if price changed or we have no entry yet
                if not existing or existing.price ~= info.price then
                    CraftSim.DB.VENDOR_PRICE:Save(itemID, {
                        price      = info.price,
                        vendorName = vendorName,
                        timestamp  = GetServerTime(),
                    })
                    updated = updated + 1
                end
                scanned = scanned + 1
            end
        end
    end

    CraftSim.DEBUG:SystemPrint(string.format(
        "|cff33ff99CraftSim VendorIntegration:|r Scanné %d articles chez %s (%d mis à jour)",
        scanned, vendorName ~= "" and vendorName or "?", updated))
end

function CraftSim.VENDOR_INTEGRATION:MERCHANT_SHOW()
    -- Delay slightly to ensure item links are loaded
    C_Timer.After(SCAN_DELAY, ScanMerchant)
end

function CraftSim.VENDOR_INTEGRATION:MERCHANT_CLOSED()
    -- Nothing to do; data is committed per-item during the scan
end

-- ──────────────────────────────────────────────────────────────
-- Debug / slash helpers (exposed via /craftsim vendorprice)
-- ──────────────────────────────────────────────────────────────

---Print the vendor price info for an itemID to the chat frame.
---Useful for verification during development.
---@param itemID ItemID
function CraftSim.VENDOR_INTEGRATION:DebugPrintPrice(itemID)
    local vendorPrice, vendorName = CraftSim.VENDOR_INTEGRATION:GetVendorPrice(itemID)
    local ahPrice = CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, true)
    local enabled = CraftSim.VENDOR_INTEGRATION:IsEnabled()
    CraftSim.DEBUG:SystemPrint(string.format(
        "|cff33ff99CraftSim VendorIntegration|r ItemID %d  enabled=%s",
        itemID, tostring(enabled)))
    if vendorPrice then
        CraftSim.DEBUG:SystemPrint(string.format(
            "  Vendeur: %s%s (%s)",
            CraftSim.VENDOR_INTEGRATION.ICON_NPC,
            GUTIL:FormatMoney(vendorPrice),
            vendorName ~= "" and vendorName or "?"
        ))
    else
        CraftSim.DEBUG:SystemPrint("  Vendeur: inconnu")
    end
    if ahPrice then
        local cheaper = vendorPrice and vendorPrice < ahPrice and "|cff00ff00 ← moins cher|r" or ""
        CraftSim.DEBUG:SystemPrint(string.format(
            "  HV:      %s%s%s",
            CraftSim.VENDOR_INTEGRATION.ICON_AH,
            GUTIL:FormatMoney(ahPrice),
            cheaper
        ))
    else
        CraftSim.DEBUG:SystemPrint("  HV:      pas de prix")
        if vendorPrice then
            CraftSim.DEBUG:SystemPrint("  → Prix vendeur sera utilisé (pas de prix HV)")
        end
    end
    if vendorPrice and ahPrice and vendorPrice >= ahPrice then
        CraftSim.DEBUG:SystemPrint("|cffffff00  → HV moins cher, prix vendeur ignoré|r")
    end
end

---Print a summary of all dynamically-discovered vendor prices.
function CraftSim.VENDOR_INTEGRATION:DebugPrintAll()
    local all = CraftSim.DB.VENDOR_PRICE:GetAll()
    local count = CraftSim.DB.VENDOR_PRICE:Count()
    CraftSim.DEBUG:SystemPrint(string.format(
        "|cff33ff99CraftSim VendorIntegration|r %d dynamically discovered prices:", count))
    for itemID, entry in pairs(all) do
        CraftSim.DEBUG:SystemPrint(string.format(
            "  ItemID=%-8d  %s  (vendor: %s)",
            itemID,
            GUTIL:FormatMoney(entry.price),
            entry.vendorName
        ))
    end
end

-- ──────────────────────────────────────────────────────────────
-- Item tooltip hook – show NPC vendor price badge (Phase 2)
-- ──────────────────────────────────────────────────────────────

local tooltipHooked = false

function CraftSim.VENDOR_INTEGRATION:HookItemTooltip()
    if tooltipHooked then return end
    tooltipHooked = true

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipInfo)
        if not tooltipInfo or not tooltipInfo.id then return end
        if not CraftSim.VENDOR_INTEGRATION:IsEnabled() then return end

        local itemID = tooltipInfo.id
        local vendorPrice, vendorName = CraftSim.VENDOR_INTEGRATION:GetVendorPrice(itemID)
        if not vendorPrice or vendorPrice <= 0 then return end

        local ahPrice = CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, true)
        local priceText = GUTIL:FormatMoney(vendorPrice)

        if ahPrice and ahPrice > 0 and vendorPrice < ahPrice then
            -- Cheaper than AH – highlight the savings
            local saved = ahPrice - vendorPrice
            tooltip:AddDoubleLine(
                CraftSim.VENDOR_INTEGRATION.ICON_NPC .. " " .. (vendorName ~= "" and vendorName or "NPC Vendor"),
                f.g(priceText) .. "  " .. f.grey("(-" .. GUTIL:FormatMoney(saved) .. " vs AH)")
            )
        else
            -- Just inform that a vendor source exists
            tooltip:AddDoubleLine(
                CraftSim.VENDOR_INTEGRATION.ICON_NPC .. " " .. (vendorName ~= "" and vendorName or "NPC Vendor"),
                priceText
            )
        end
    end)
end
