# Feature: Knowledge Path ROI Optimizer

## Summary

Recommend the optimal path through the profession specialization tree based on expected profit per knowledge point invested. Each node unlocks or improves recipes — this module quantifies the gold value of every branch so the player always knows where to invest next.

## Problem Statement

CraftSim already shows which specialization nodes affect a given recipe (SpecializationInfo module), but there is **no guidance on which knowledge point to spend next** from a profit perspective. Players must manually cross-reference dozens of nodes against recipe profitability — a tedious and error-prone process.

## Proposed Features

### Phase 1 — Node ROI Calculation Engine
- For each unspent node in the active specialization tree, compute:
  - Which recipes are unlocked or improved (skill bonus, stat bonus, perk)
  - The delta in expected profit for each affected recipe
  - Aggregated ROI = Σ(profit_delta × estimated_weekly_crafts)
- Store results per `crafterUID` in a new DB repository `KNOWLEDGE_ROI`

### Phase 2 — Heatmap Visualization
- Overlay the existing specialization tree UI with a color gradient (red→yellow→green) based on ROI
- Tooltip per node: "This point improves recipes X, Y, Z → +1,250g/week estimated"
- "Next Best Point" prominent recommendation badge

### Phase 3 — Path Simulation ("What-If")
- Allow the player to simulate spending N points along a path
- Show cumulative profit delta, breakeven time, and opportunity cost vs alternative paths
- Compare up to 3 paths side-by-side

### Phase 4 — Weekly Planner Integration
- "This week, spend your knowledge points here" summary
- Factor in knowledge point sources (treasures, patron orders, treatises) and remaining budget
- Alert when new knowledge points are available and unspent

## Technical Approach

### Data Sources
- `CraftSim.SpecializationData` — node tree, perk definitions, stat contributions
- `CraftSim.RecipeData` + `CraftSim.PriceData` — profit per recipe
- `C_Traits.GetNodeInfo()` / `C_ProfSpecs` — live node state from WoW API
- `C_CurrencyInfo.GetCurrencyInfo()` — Artisan Moxie tracking (knowledge purchases)

### Architecture
- New module: `Modules/KnowledgeROI/`
  - `KnowledgeROI.lua` — core calculation engine
  - `KnowledgeROIUI.lua` — heatmap overlay and recommendations
  - `KnowledgeROISimulation.lua` — what-if path simulator
- New DB repository: `CraftSimDB.KNOWLEDGE_ROI`
- Hooks into existing `SpecializationInfo` module for tree rendering

### Key Algorithms
1. **Node Impact Mapping**: For each node, enumerate affected recipes via perk/stat contribution data
2. **Profit Delta**: For each affected recipe, compute `profit(with_node) - profit(without_node)` using CraftSim's existing profit engine
3. **Weekly Weighting**: Multiply delta by estimated weekly craft count (from CraftLog history or configurable default)
4. **Path Optimization**: Greedy algorithm (next best point) + optional exhaustive search for short paths (≤10 points)

### Performance Considerations
- Cache ROI calculations per session (invalidate on price change or spec change)
- Lazy compute: only calculate for visible nodes + next N recommendations
- Use `CraftSim.UTIL.FrameDistributor` for async computation spread across frames

## Dependencies
- CraftSim core (RecipeData, PriceData, SpecializationData, CraftLog)
- GGUI framework for heatmap overlay
- No external addon dependencies

## API Verification (2026-04-13)
- ✅ `C_TradeSkillUI.GetRecipeInfo(recipeSpellID)` — returns recipe info, `secretArguments: AllowedWhenUntainted`
- ✅ `C_CurrencyInfo.GetCurrencyInfo(type)` — returns currency quantity/max, `secretArguments: AllowedWhenUntainted`
- ✅ `CraftSim.SpecializationData` — existing tree data model with node stats
- ✅ `CraftSim.PriceData` — existing profit calculation engine

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Specialization tree changes mid-season | Data model breaks | Version-gated spec data (already done per expansion in CraftSim) |
| Profit estimates stale after market shift | Bad recommendations | Recalculate on RecipeScan or manual refresh; show "last updated" timestamp |
| Performance on large trees (50+ nodes) | UI lag | Async frame distribution + caching |
| Accuracy of "weekly craft estimate" | Misleading ROI | Default to CraftLog actuals; fallback to configurable manual estimate |

## Integration Branch
Target: `feat/KnowledgePathROI`

## Status
- [x] Phase 1 — Node ROI Calculation Engine (bc8bee07)
- [x] Phase 2 — Optimal Path Calculator (cfa5a846) + Bugfixes (af01afe1)
- [x] Phase 3 — ROI Heatmap Visualization & Tooltip Integration (d71b8edf)
- [x] Phase 4 — Weekly Planner Integration (9e2471a4)
