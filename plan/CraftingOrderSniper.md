# Feature: Crafting Order Sniper & Commission Optimizer

## Summary

Monitor available public and patron Work Orders in real-time to surface the most profitable commissions. Alert the player when a high-value order appears, calculate net profit after reagent costs, and provide historical commission data to help set competitive prices.

## Problem Statement

The Crafting Orders system in Midnight is a significant gold source, but the in-game UI for browsing orders is primitive:
- No profitability calculation (commission minus reagent costs)
- No filtering by profit threshold
- No alerts when valuable orders appear
- No historical data on typical commission rates per recipe
- Must be physically at a crafting station to browse orders

Players waste time manually scanning orders, doing mental math, and missing profitable opportunities.

## Proposed Features

### Phase 1 — Order Profitability Scanner
- Hook into `C_CraftingOrders.GetCrafterOrders()` when at a crafting station
- For each available order, compute:
  - **Commission** (gold offered by customer)
  - **Reagent cost** (materials not provided by customer, priced from TSM/Auctionator)
  - **Concentration cost** (if needed to hit the required quality, valued at gold/concentration-point)
  - **Net profit** = commission - reagent cost - concentration opportunity cost
  - **Moxie earned** (if patron order)
- Display sorted by net profit with color coding (green = profitable, red = loss)

### Phase 2 — Smart Alert System
- Configurable profit threshold: "Alert me for orders with net profit > X gold"
- Sound + visual notification when a qualifying order appears
- Support for both:
  - **Active scanning**: periodic refresh while at crafting station (throttled, configurable interval)
  - **Passive detection**: hook into `CRAFTINGORDERS_UPDATE_ORDER_COUNT` event
- Alert cooldown to prevent spam (min 30s between alerts for same recipe)
- Filter by: profession, recipe category, minimum profit, patron-only, public-only

### Phase 3 — Commission History & Analytics
- Track all orders seen (accepted or not) in `CraftSimDB.ORDER_HISTORY`
- Per-recipe analytics:
  - Average commission offered
  - Median commission
  - Frequency (orders/day)
  - Your acceptance rate
  - Profit trend over time
- "Fair Price" recommendation when posting your own commissions
- "Competition" indicator: how many orders are available vs crafters (indirect via frequency)

### Phase 4 — Patron Order Optimization
- Focus on patron (NPC) orders specifically:
  - Track Moxie rewards per order
  - Calculate Moxie-per-gold-spent ROI
  - Recommend which patron orders to prioritize for Moxie farming
  - Weekly patron order tracker: completed / available / missed
- Integration with Moxie Budget Optimizer (if feat/MoxieBudget exists)

### Phase 5 — Quick-Accept UI Enhancement
- Floating panel near the crafting orders UI showing top 5 most profitable orders
- One-click to navigate to the order in the Blizzard UI (cannot auto-accept — player action required)
- "Quick Reject" list for recipes you never want to craft (configurable blacklist)
- Reagent availability check: "You have all materials for this order" badge

## Technical Approach

### Data Sources
- `C_CraftingOrders.GetCrafterOrders()` — returns available orders (must be at crafting station)
- `C_CraftingOrders.GetOrderClaimInfo()` — claim status
- `CRAFTINGORDERS_UPDATE_ORDER_COUNT` / `CRAFTINGORDERS_DISPLAY_CRAFTER_FULFILLED_MSG` events
- `CraftSim.RecipeData` — recipe data for reagent cost calculation
- `CraftSim.PriceData` — reagent pricing
- `CraftSim.ConcentrationData` — concentration cost estimation

### Architecture
- New module: `Modules/OrderSniper/`
  - `OrderSniper.lua` — core scanning and profitability engine
  - `OrderSniperUI.lua` — alert system and quick-accept panel
  - `OrderHistory.lua` — historical tracking and analytics
  - `PatronOptimizer.lua` — patron order Moxie ROI calculations
- New DB repositories:
  - `CraftSimDB.ORDER_HISTORY` — historical orders seen and accepted
  - `CraftSimDB.ORDER_SNIPER_CONFIG` — alert thresholds, blacklists, preferences

### Key Algorithms
1. **Net Profit Calculation**:
   ```
   net_profit = commission
              - Σ(reagent_cost × qty for non-provided reagents)
              - concentration_cost_in_gold (if quality upgrade needed)
              + moxie_value (if patron order, valued at gold-per-moxie rate)
   ```
2. **Concentration Gold Value**: Derived from the most profitable concentration-spending recipe available. "1 concentration point = X gold opportunity cost"
3. **Alert Scoring**: `score = net_profit × urgency_factor` where urgency increases as order approaches expiration
4. **Fair Commission**: Percentile-based from history — "90th percentile commission for this recipe = X gold"

### Event Flow
```
Player arrives at crafting station
  → TRADE_SKILL_SHOW event
  → OrderSniper registers CRAFTINGORDERS_UPDATE_ORDER_COUNT
  → Periodic scan via C_Timer (configurable: 30s / 60s / 120s)
  → For each order: compute net profit
  → If profit > threshold → play sound + show alert frame
  → Log all orders to ORDER_HISTORY

Player leaves crafting station
  → TRADE_SKILL_CLOSE event
  → OrderSniper unregisters events, stops timer
```

### Performance Considerations
- Only scan when at crafting station (event-gated)
- Throttle scans to minimum 30s interval
- Cache reagent prices for the scan session (invalidate on new Auctionator scan)
- ORDER_HISTORY pruning: keep last 30 days, compress older data to daily summaries

## Compliance Notes
- ✅ No automation: player must manually accept orders
- ✅ No protected actions: alerts are purely informational
- ✅ Scanning is throttled and event-gated
- ✅ No advantage over manual browsing — just calculated information faster

## Dependencies
- CraftSim core (RecipeData, PriceData, ConcentrationData)
- GGUI framework for alert and panel UI
- No external addon dependencies

## API Verification (2026-04-13)
- ✅ `C_CraftingOrders.GetCrafterOrders()` — returns available orders table
- ✅ `C_CraftingOrders` namespace — extensive API for order management (72KB of API docs)
- ✅ `CRAFTINGORDERS_UPDATE_ORDER_COUNT` event — fires on order list changes
- ✅ `C_CurrencyInfo.GetCurrencyInfo()` — Moxie tracking for patron orders
- ⚠️ Orders only accessible at crafting station — cannot scan remotely

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Orders only visible at crafting station | Limited scanning window | Clear UX: "Go to crafting station to scan"; show last scan results when away |
| Rapid order turnover (sniped before accepting) | Frustrating alerts for gone orders | Show order age/expiry; re-check before alert |
| Commission manipulation (fake high orders) | Bad history data | Outlier detection; median more robust than mean |
| Blizzard throttles order queries | Rate-limited scanning | Respect server throttles; adaptive scan interval |
| Moxie valuation subjective | Misleading patron order ROI | Configurable gold-per-moxie rate with sensible default |

## Integration Branch
Target: `feat/IncredibleFeature`

## Status
- [ ] Phase 1 — Order Profitability Scanner
- [ ] Phase 2 — Smart Alert System
- [ ] Phase 3 — Commission History & Analytics
- [ ] Phase 4 — Patron Order Optimization
- [ ] Phase 5 — Quick-Accept UI Enhancement
