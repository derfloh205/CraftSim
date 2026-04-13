# Feature: NPC Vendor Reagent Integration

## Summary

Automatically detect reagents purchasable from NPC vendors and use their fixed vendor price instead of the AH price when it's cheaper. Solves the widely reported problem ([Reddit thread](https://www.reddit.com/r/woweconomy/comments/1sdjgcs/craftsim_npc_vendor/)) where CraftSim lists basic reagents (thread, dye, flux, vials, etc.) as AH purchases when they're available at a fraction of the cost from NPCs.

## Problem Statement

Many crafting recipes require "commodity" reagents sold by NPC vendors at fixed prices:
- **Tailoring**: Thread (Runed Thread, Eternium Thread, Mosswool Thread, etc.)
- **Leatherworking**: Salt, Thread
- **Alchemy**: Vials (Crystal Vial, etc.)
- **Enchanting**: Rods, Dusts (some)
- **Blacksmithing**: Coal, Flux
- **Inscription**: Inks from vendors (limited)
- **All professions (Midnight)**: Housing Decor reagents from legacy expansions

CraftSim currently prices these from TSM/Auctionator AH data, often **overstating costs by 50-500%** because players list vendor items on the AH at markup. This cascades into inflated crafting costs, wrong profit calculations, and misleading recipe scan results.

## Proposed Features

### Phase 1 — Vendor Price Database
- Static lookup table: `itemID → vendorPrice` for all known vendor-sold reagents
- Covers all expansions (Classic through Midnight) since Housing Decor needs legacy reagents
- Data sourced from:
  - Wowhead vendor data (compiled once, stored in `Data/VendorReagentData.lua`)
  - `GetMerchantItemInfo()` live scanning when player opens a vendor
- Auto-update: when visiting a vendor, learn new vendor items dynamically and cache them

### Phase 2 — Price Source Priority
- New pricing logic in CraftSim's `PriceData` calculation:
  ```
  effective_price = min(AH_price, vendor_price) if vendor_price exists
                  = AH_price otherwise
  ```
- Visual indicator in recipe info: "📦 NPC" badge next to vendor-priced reagents
- Toggle in Options: "Prefer NPC vendor prices when cheaper" (default: ON)
- Override capability: player can force AH price for specific items if desired

### Phase 3 — Shopping List Enhancement
- In aggregated shopping lists, split into two sections:
  - 🏪 **Buy from NPC** — items with vendor sources (with vendor name + location)
  - 🏛️ **Buy from AH** — items only available on the auction house
- Vendor location tooltips: "Sold by <NPC Name> in <Zone>" with TomTom waypoint integration (optional)
- Cost summary: "NPC savings: X gold" showing how much cheaper vs all-AH

### Phase 4 — Dynamic Vendor Discovery
- Hook `MERCHANT_SHOW` event to scan vendor inventory when player opens any vendor
- For each item: if `GetMerchantItemInfo()` returns a price, cache `itemID → price`
- Store in `CraftSimDB.VENDOR_PRICES` keyed by itemID
- Freshness: vendor prices are fixed by Blizzard, so cache indefinitely (until expansion patch)
- Crowd-source within Warband: if Alt-A discovered a vendor price, all alts benefit

### Phase 5 — Housing Decor Reagent Coverage
- Specific focus on legacy expansion reagents needed for Housing Decor crafting:
  - Ironwood/Olemba/Ashwood/Bamboo/Dornic Fir Lumber
  - Legacy cloth bolts, leather, ores
  - Specialty reagents (Eternium Thread, Spirit of Harmony, etc.)
- Map which vendors sell each legacy material and in which zone
- "Housing Decor Shopping Route" — ordered list of vendors to visit for a decor recipe

## Technical Approach

### Data Sources
- **Static data**: `Data/VendorReagentData.lua` — comprehensive itemID→vendorPrice mapping
- **Live scanning**: `GetMerchantItemInfo(index)` — returns name, texture, price, stackCount, numAvailable
- **Events**: `MERCHANT_SHOW` — fires when vendor window opens; `MERCHANT_CLOSE` — cleanup
- **Existing CraftSim**: `PriceData` module, `PriceAPIs` system, `ITEM_COUNT` for ownership

### Static Data Structure
```lua
CraftSim.VENDOR_REAGENT_DATA = {
    -- itemID = { vendorPrice (copper), vendorName, zoneID }
    [38426] = { price = 1600, vendor = "Linna Bruder", zone = 85 },       -- Eternium Thread
    [3371]  = { price = 100,  vendor = "Any Trade Goods Vendor", zone = 0 }, -- Crystal Vial
    [2880]  = { price = 500,  vendor = "Mining Supplier", zone = 0 },       -- Weak Flux
    -- ... hundreds of entries covering Classic→Midnight
}
```

### Architecture
- New module: `Modules/VendorIntegration/`
  - `VendorReagentData.lua` — static vendor price database (generated, not hand-maintained)
  - `VendorIntegration.lua` — price priority logic and merchant scanning
  - `VendorIntegrationUI.lua` — badges, shopping list split, vendor location tooltips
- New DB repository: `CraftSimDB.VENDOR_PRICES` — dynamically discovered vendor prices
- Hook into existing `PriceAPIs` system:
  - New method `CraftSim.PRICE_APIS:GetVendorPrice(itemID)` → vendorPrice or nil
  - Modify `CraftSim.PriceData:Update()` to consider vendor price

### Integration Points
- **PriceData**: Inject vendor price as an alternative source in `GetMinBuyoutByItemID()` flow
- **RecipeInfo**: Add "NPC" badge indicator for vendor-sourced reagents
- **CraftQueue**: Shopping list split (NPC vs AH sections)
- **RecipeScan**: Correct profit calculations when vendor reagents are involved
- **SupplyChainTree** (if merged): Show vendor price at leaf nodes

### Generating the Static Database
1. Scrape Wowhead's "Sold By" data for all known crafting reagents
2. Cross-reference with in-game vendor scanning data
3. Output as `Data/VendorReagentData.lua` — static file committed to repo
4. Maintain a simple script (Python/Lua) to regenerate when new expansions add items
5. Dynamically learned prices from `MERCHANT_SHOW` supplement static data

### Performance Considerations
- Static data is O(1) lookup per itemID (hash table)
- Merchant scanning is event-gated (only when vendor is open)
- No additional API calls during normal profit calculations
- Vendor price cache is persistent across sessions (SavedVariables)

## Compliance Notes
- ✅ No automation: player opens vendors manually
- ✅ No protected actions: purely informational pricing
- ✅ `GetMerchantItemInfo()` is a standard unrestricted API
- ✅ Static data is publicly available (Wowhead, in-game client data)

## Dependencies
- CraftSim core (PriceData, PriceAPIs, RecipeInfo)
- GGUI framework for UI badges and shopping list
- Optional: TomTom for vendor waypoints
- No hard external addon dependencies

## API Verification (2026-04-13)
- ✅ `GetMerchantItemInfo(index)` — returns item price from open vendor window
- ✅ `GetMerchantNumItems()` — number of items current vendor sells
- ✅ `MERCHANT_SHOW` / `MERCHANT_CLOSE` events — vendor window lifecycle
- ✅ `CraftSim.PriceAPIs` — existing price source system, extensible
- ✅ `CraftSim.PriceData:Update()` — existing method to hook into

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Static data becomes outdated | Wrong vendor prices | Version-gate data per expansion; dynamic scanning supplements static |
| Some reagents sold by limited-supply vendors | Not actually available | Flag "limited supply" items; don't auto-prefer vendor price if supply=0 |
| Vendor prices vary by reputation | Incorrect savings estimate | Use base price (no rep discount) as default; note "may be cheaper with rep" |
| Housing Decor reagents from obscure vendors | Hard to find vendor location | Include zoneID + coordinates; TomTom integration |
| Large static data file | Addon size increase | Typically <50KB for complete vendor DB; negligible |

## Scope Estimation
- **Phase 1** (static DB): ~2-3 days (data generation + integration)
- **Phase 2** (price priority): ~1-2 days (hook into PriceData)
- **Phase 3** (shopping list): ~2 days (UI work)
- **Phase 4** (dynamic scanning): ~1 day (event handler + cache)
- **Phase 5** (Housing Decor): ~2 days (legacy vendor research)

## Integration Branch
Target: `feat/IncredibleFeature`

## Status
- [ ] Phase 1 — Vendor Price Database
- [ ] Phase 2 — Price Source Priority
- [ ] Phase 3 — Shopping List Enhancement
- [ ] Phase 4 — Dynamic Vendor Discovery
- [ ] Phase 5 — Housing Decor Reagent Coverage
