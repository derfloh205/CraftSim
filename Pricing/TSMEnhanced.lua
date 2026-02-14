-- =============================================================================
-- CraftSim - Pricing/TSMEnhanced.lua
-- Enhanced TSM integration: expected deposit costs & smart restock.
--
-- These features are only active when TSM (TradeSkillMaster) is loaded AND
-- the user has enabled them in CraftSim Options > TSM tab.
--
-- DEPOSIT COST:
--   CraftSim's profit formula does not account for AH listing deposits.
--   For items with low sale rates, repeated deposits can erode or exceed the
--   apparent profit. This module provides a deposit cost lookup via any TSM
--   custom price expression (e.g. "bilisexpecteddeposits" or a manual formula).
--   The cost is subtracted in ProfitCalculation.lua when enabled.
--
-- SMART RESTOCK:
--   CraftSim's "Send to Craft Queue" uses the TSM restock expression as a raw
--   target quantity but does NOT subtract what the player already owns across
--   bags, bank, AH, alts, and warbank.  This module exposes a helper that
--   returns the *net* quantity still needed.
-- =============================================================================
---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.TSM_ENHANCED
CraftSim.TSM_ENHANCED = {}

local print = CraftSim.DEBUG:RegisterDebugID("Pricing.TSMEnhanced")

-- ---------------------------------------------------------------------------
-- Availability guard
-- ---------------------------------------------------------------------------

--- Returns true when TSM is loaded and its public API is available.
---@return boolean
function CraftSim.TSM_ENHANCED:IsAvailable()
    return TSM_API ~= nil
end

-- ---------------------------------------------------------------------------
-- Deposit cost helpers
-- ---------------------------------------------------------------------------

--- Per-item deposit cache to avoid hammering TSM_API every frame.
---@type table<string, { value: number|nil, t: number }>
local depositCache = {}
local DEPOSIT_CACHE_TTL = 60 -- seconds

--- Retrieve the expected deposit cost for a recipe's result item.
--- Returns 0 when the feature is disabled, TSM is absent, or data is unavailable.
---@param recipeData CraftSim.RecipeData
---@return number depositCost  copper
function CraftSim.TSM_ENHANCED:GetExpectedDeposit(recipeData)
    if not self:IsAvailable() then return 0 end
    if not CraftSim.DB.OPTIONS:Get("TSM_DEPOSIT_ENABLED") then return 0 end

    -- No deposit cost for work orders
    if recipeData.orderData then return 0 end

    local resultData = recipeData.resultData
    if not resultData then return 0 end

    local item = resultData.expectedItem
    if not item then return 0 end

    -- Use GetItemID() instead of GetItemLink() — GetItemID() is always available
    -- synchronously, while GetItemLink() may return nil during RecipeScans when
    -- the ItemMixin has not finished loading yet.
    local itemID = item:GetItemID()
    if not itemID then return 0 end

    local tsmStr = "i:" .. itemID

    -- Check cache
    local entry = depositCache[tsmStr]
    local now = GetTime()
    if entry and (now - entry.t) < DEPOSIT_CACHE_TTL then
        return entry.value or 0
    end

    -- Query TSM
    local expression = CraftSim.DB.OPTIONS:Get("TSM_DEPOSIT_EXPRESSION")
    local deposit = TSM_API.GetCustomPriceValue(expression, tsmStr)

    depositCache[tsmStr] = { value = deposit, t = now }

    return deposit or 0
end

--- Invalidate the deposit cache (e.g. after changing the expression in settings).
function CraftSim.TSM_ENHANCED:ClearDepositCache()
    wipe(depositCache)
end

-- ---------------------------------------------------------------------------
-- Smart restock helpers
-- ---------------------------------------------------------------------------

--- Compute the net quantity still needed for a recipe's result item.
--- target = value of the TSM restock expression for this item
--- owned  = total inventory across player, AH, and optionally alts + warbank
--- needed = max(0, target - owned)
---@param recipeData CraftSim.RecipeData
---@return number needed  items still required (≥ 0)
---@return number target  TSM restock target
---@return number owned   total owned across tracked sources
function CraftSim.TSM_ENHANCED:GetSmartRestockAmount(recipeData)
    if not self:IsAvailable() then return 0, 0, 0 end
    if not CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_ENABLED") then return 0, 0, 0 end

    local resultData = recipeData.resultData
    if not resultData or not resultData.expectedItem then return 0, 0, 0 end

    -- For restock we need the full item link (quality-aware) — GetItemLink()
    -- is available here because restock runs after RecipeScan has finished and
    -- items are loaded.
    local itemLink = resultData.expectedItem:GetItemLink()
    if not itemLink then
        -- Fallback to itemID-based string
        local itemID = resultData.expectedItem:GetItemID()
        if not itemID then return 0, 0, 0 end
        itemLink = "i:" .. itemID
    end

    local tsmStr = TSM_API.ToItemString(itemLink)
    if not tsmStr then return 0, 0, 0 end

    -- Target from TSM expression
    local restockExpr = CraftSim.DB.OPTIONS:Get("TSM_RESTOCK_KEY_ITEMS")
    local target = TSM_API.GetCustomPriceValue(restockExpr, tsmStr) or 0

    -- Owned inventory via TSM_API
    local numPlayer, numAlts, numAuctions, numAltAuctions = TSM_API.GetPlayerTotals(tsmStr)
    local owned = numPlayer + numAuctions

    if CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_ALTS") then
        owned = owned + numAlts + numAltAuctions
    end

    if CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_WARBANK") then
        owned = owned + (TSM_API.GetWarbankQuantity and TSM_API.GetWarbankQuantity(tsmStr) or 0)
    end

    local needed = math.max(0, target - owned)
    return needed, target, owned
end
