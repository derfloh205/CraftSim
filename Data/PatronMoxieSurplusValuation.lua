---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local function RoundCopper(value)
    local raw = value or 0
    -- Round down to whole silver to omit copper.
    return math.floor(raw / 100) * 100
end

--- Expected contents of Midnight "Master … Surplus Reagent(s)" turn-ins and consortium Moxie yield,
--- using tier-2 (quality 2) trade-good item IDs where the game splits tiers by item ID.
--- Item IDs follow community references (Wowhead / TSM); adjust if Blizzard changes IDs.
---@class CraftSim.PatronMoxieSurplusEntry
---@field itemID number
---@field qty number

CraftSim.PATRON_MOXIE_SURPLUS = {}
local SURPLUS_BAG_COST_MOXIE = 600

local SURPLUS_BAG_ALCHEMY_HERBALISM = {
    { itemID = 236767, qty = 35.0 }, -- Tranquility Bloom Q2
    { itemID = 236777, qty = 17.5 }, -- Argentleaf Q2
    { itemID = 236779, qty = 17.5 }, -- Mana Lily Q2
    { itemID = 236771, qty = 17.5 }, -- Sanguithorn Q2
    { itemID = 236775, qty = 17.5 }, -- Azeroot Q2
    { itemID = 236780, qty = 4.0 },  -- Nocturnal Lotus
    { itemID = 251285, qty = 1 },    -- Petrified Root
}

local SURPLUS_BAG_BS_ENG_JC_MINING = {
    { itemID = 237361, qty = 45.0 }, -- Refulgent Copper Ore Q2
    { itemID = 237363, qty = 25.0 }, -- Umbral Tin Ore Q2
    { itemID = 237365, qty = 25.0 }, -- Brilliant Silver Ore Q2
    { itemID = 237366, qty = 7.5 },  -- Dazzling Thorium
    { itemID = 251285, qty = 1 },    -- Petrified Root
}

local SURPLUS_BAG_ENCHANTING = {
    { itemID = 243600, qty = 60.0 }, -- Eversinging Dust Q2
    { itemID = 243603, qty = 25.0 }, -- Radiant Shard Q2
    { itemID = 243606, qty = 7.5 },  -- Dawn Crystal Q2
    { itemID = 251285, qty = 1 },    -- Petrified Root
}

local SURPLUS_BAG_LW_SKINNING = {
    { itemID = 238512, qty = 35.2 }, -- Void-Tempered Leather Q2
    { itemID = 238514, qty = 35.2 }, -- Void-Tempered Scales Q2
    { itemID = 238519, qty = 4.5 },  -- Void-Tempered Hide Q2
    { itemID = 238521, qty = 4.5 },  -- Void-Tempered Plating Q2
    -- One-of-three outcome groups: distribute expected quantity across options.
    { itemID = 238528, qty = 0.4 },              -- Majestic Claw (1.2 / 3)
    { itemID = 238530, qty = 0.4 },              -- Majestic Fin (1.2 / 3)
    { itemID = 238529, qty = 0.4 },              -- Majestic Hide (1.2 / 3)
    { itemID = 238522, qty = 1.9333333333333 },  -- Peerless Plumage (5.8 / 3)
    { itemID = 238525, qty = 1.9333333333333 },  -- Fantastic Fur (5.8 / 3)
    { itemID = 238523, qty = 1.9333333333333 },  -- Carving Canine (5.8 / 3)
    { itemID = 251285, qty = 1 },                -- Petrified Root
}

local SURPLUS_BAG_TAILORING = {
    { itemID = 237018, qty = 5.0 },  -- Arcanoweave Q2
    { itemID = 237016, qty = 5.0 },  -- Sunfire Silk Q2
    { itemID = 236965, qty = 12.5 }, -- Bright Linen Q2
    { itemID = 251285, qty = 1.0 },  -- Petrified Root
}

---@type table<number, CraftSim.PatronMoxieSurplusEntry[]>
local specsByCurrencyID = {
    -- Alchemy — Master Alchemist's Surplus Reagent
    [3256] = SURPLUS_BAG_ALCHEMY_HERBALISM,
    -- Herbalism — Master Herbalist's Surplus Reagent
    [3260] = SURPLUS_BAG_ALCHEMY_HERBALISM,
    -- Inscription — Master Scribe's Surplus Reagent
    [3261] = SURPLUS_BAG_ALCHEMY_HERBALISM,
    -- Blacksmithing — Master Smith's Surplus Reagents
    [3257] = SURPLUS_BAG_BS_ENG_JC_MINING,
    -- Engineering — Master Engineer's Surplus Reagents
    [3259] = SURPLUS_BAG_BS_ENG_JC_MINING,
    -- Jewelcrafting — Master Jeweler's Surplus Reagents
    [3262] = SURPLUS_BAG_BS_ENG_JC_MINING,
    -- Mining — Master Miner's Surplus Reagents
    [3264] = SURPLUS_BAG_BS_ENG_JC_MINING,
    -- Enchanting — Master Enchanter's Surplus Reagent
    [3258] = SURPLUS_BAG_ENCHANTING,
    -- Leatherworking — Master Leatherworker's Surplus Reagents
    [3263] = SURPLUS_BAG_LW_SKINNING,
    -- Skinning — Master Skinner's Surplus Reagents
    [3265] = SURPLUS_BAG_LW_SKINNING,
    -- Tailoring — Master Tailor's Surplus Reagents
    [3266] = SURPLUS_BAG_TAILORING,
}

---@param currencyID number
---@return CraftSim.PatronMoxieSurplusEntry[]|nil
function CraftSim.PATRON_MOXIE_SURPLUS:GetSpec(currencyID)
    return specsByCurrencyID[currencyID]
end

---@param currencyID number
---@return number|nil
function CraftSim.PATRON_MOXIE_SURPLUS:GetExpectedMoxie(currencyID)
    local entries = specsByCurrencyID[currencyID]
    if not entries then
        return nil
    end
    return SURPLUS_BAG_COST_MOXIE
end

--- Expected copper value for one unit of Moxie from surplus turn-in valuation (AH / overrides), or nil if unknown.
---@param currencyID number
---@return number|nil
function CraftSim.PATRON_MOXIE_SURPLUS:ComputeCopperPerMoxie(currencyID)
    local entries = specsByCurrencyID[currencyID]
    local expectedMoxie = CraftSim.PATRON_MOXIE_SURPLUS:GetExpectedMoxie(currencyID)
    if not entries or not expectedMoxie or expectedMoxie <= 0 then
        return nil
    end
    if not CraftSim.PRICE_APIS.available then
        return nil
    end
    local total = 0
    for _, entry in ipairs(entries) do
        local unit = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(entry.itemID, true)
        total = total + unit * entry.qty
    end
    if total <= 0 then
        return nil
    end
    return RoundCopper(total / expectedMoxie)
end
