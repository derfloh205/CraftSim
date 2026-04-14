# Feature: Crafting Order Sniper — Smart Alert System

## Summary

Enhance the existing CraftQueue Work Orders system with smart alerts: notify the player (sound + chat message) when profitable orders are detected during auto-queue, with configurable profit thresholds and alert settings integrated directly into the existing Work Orders options dropdown.

## Problem Statement

CraftSim already computes profitability and auto-queues work orders when opening a profession table. However, the player has no notification when high-value orders are found — they must manually check the queue to see what was added.

## What Already Exists (as of 2026-04-14)

The following features are **already implemented** in CraftQueue:

- ✅ **Order Profitability Calculation**: `averageProfitCached` (commission - reagent cost - concentration)
- ✅ **Moxie Valuation**: configurable gold-per-moxie, included in profit calculations
- ✅ **Auto-Queue on Detection** (commit `2faea16`): `CRAFTQUEUE_WORK_ORDERS_AUTO_QUEUE` triggers `QueueWorkOrders()` when profession frame opens
- ✅ **Per-Profession Preload**: orders preloaded once per profession per session
- ✅ **Order Type Filtering**: Patron, Guild, Personal, Public checkboxes
- ✅ **Profit Filtering**: "Only Profitable" option
- ✅ **Patron Order Filters**: Spark recipes, KP, Acuity, Power Rune, force/allow concentration
- ✅ **Patron Cost Limits**: Max cost per order, max cost per KP
- ✅ **Public Order Sorting**: Top N by profit, limited by available claims
- ✅ **Navigate to Order**: Click queue row to open order in Blizzard UI
- ✅ **Patron Reward Values UI**: Configurable moxie values per currency

## Proposed Feature — Smart Alert System

Integrated into the existing CraftQueue Work Orders options, directly below the "Auto Queue" checkbox.

### Alert Settings (in Work Orders options dropdown)
- **Enable Alerts** checkbox (master toggle, default: off)
- **Minimum Profit Threshold**: CurrencyInput — only alert for orders with net profit ≥ this value (default: 0 = alert on any profitable order)
- **Sound Alert** checkbox (default: on) — play a sound when profitable orders are found
- **Chat Alert** checkbox (default: on) — print a summary in chat when profitable orders are found

### Alert Behavior
- Fires **after** auto-queue completes (in the `finally` callback of `QueueWorkOrders`)
- Counts how many orders were queued and the total/best profit
- If any queued order meets the profit threshold:
  - Play `SOUNDKIT.AUCTION_WINDOW_OPEN` (or similar recognizable sound)
  - Print to chat: `"|cff00ccffCraftSim:|r Queued X work orders — best profit: Y gold"`
- Alert only fires during auto-queue (not manual "Queue Work Orders" button clicks)
- No cooldown needed since auto-queue fires once per profession per session

### Blacklist (Recipe Ignore List)
- Stored in SavedVariables: `CraftSimDB.WORK_ORDER_BLACKLIST` — table of `recipeID = true`
- During `QueueWorkOrders`, skip any recipe in the blacklist
- Right-click context menu on CraftQueue work order rows: "Blacklist this recipe"
- Option in Work Orders dropdown: "Clear Blacklist" button

## Technical Approach

### Data Flow
```
ProfessionsFrame opens
  → Preload orders per profession (existing)
  → CRAFTSIM_CRAFTING_ORDERS_PRELOADED fires
  → Auto-queue enabled? → QueueWorkOrders()
  → Track queued orders during scan (count, profits)
  → QueueWorkOrders finally: → fire alerts if threshold met
```

### Changes Required

#### `Util/Const.lua` — New option keys
- `CRAFTQUEUE_WORK_ORDERS_ALERTS_ENABLED`
- `CRAFTQUEUE_WORK_ORDERS_ALERTS_MIN_PROFIT`
- `CRAFTQUEUE_WORK_ORDERS_ALERTS_SOUND`
- `CRAFTQUEUE_WORK_ORDERS_ALERTS_CHAT`
- `CRAFTQUEUE_WORK_ORDERS_BLACKLIST`

#### `Locals/enUS.lua` + `Locals/LocalizationIDs.lua` — New strings
- Alert checkbox labels and tooltips
- Blacklist context menu text

#### `Modules/CraftQueue/CraftQueue.lua` — Alert logic
- Track queued orders during scan (accumulator in `QueueWorkOrders`)
- Fire alert in `finally` callback
- Blacklist check in `queueRecipe()` inner function

#### `Modules/CraftQueue/UI.lua` — Settings UI
- Add alert options in the Work Orders options dropdown, grouped under "Auto Queue" section
- Right-click context menu on queue rows for blacklist

### Performance Considerations
- Zero overhead when alerts disabled
- Alert fires once per auto-queue (not per order)
- Blacklist is a simple table lookup (O(1))

## Compliance Notes
- ✅ No automation: player must manually accept orders from the queue
- ✅ No protected actions: alerts are purely informational (sound + chat)
- ✅ No new frames or windows: integrated into existing dropdown

## Dependencies
- CraftSim core (existing CraftQueue, RecipeData, PriceData)
- GGUI framework (existing)
- No external addon dependencies

## API Verification (2026-04-13)
- ✅ `PlaySound(SOUNDKIT.*)` — standard WoW sound API
- ✅ `C_CraftingOrders.GetCrafterOrders()` — already used in QueueWorkOrders
- ✅ `CRAFTSIM_CRAFTING_ORDERS_PRELOADED` — custom event, already wired

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Sound spam if many professions visited | Annoying alerts | Once per profession per session (existing preload guard) |
| Blacklist grows unbounded | SavedVariables bloat | Blacklist is recipe IDs only (small); add "Clear All" button |
| Profit threshold misleading | User confusion | Tooltip explains: "Minimum net profit after reagent costs" |

## Integration Branch
Target: `feat/IncredibleFeature`

## Status
- [x] Phase 1 — Order Profitability Scanner (already done in CraftQueue)
- [ ] Phase 2 — Smart Alert System (this feature)
- [x] ~~Phase 3 — Commission History & Analytics~~ (removed — too heavy, no clear value)
- [x] Phase 4 — Patron Order Optimization (already done: moxie valuation, KP cost limits)
- [x] ~~Phase 5 — Quick-Accept UI Enhancement~~ (removed — no screen space for floating panel)
