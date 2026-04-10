---@class CraftSim
local CraftSim = select(2, ...)

--- Midnight milling routes (see Midnight Milling / Shuffles sheet).
--- r2_r1: R2 herbs → rank-1 pigment (sheet: 15–20 pigments per 10 herbs).
--- r1_r1: R1 herbs → rank-1 pigment (10–15 per 10 herbs).
--- r2_r2: R2 herbs → rank-2 pigment (10–15 per 10 herbs).
--- Average yield in UI is (pigmentsMin + pigmentsMax) / 2 (e.g. 12.5, 17.5).
--- Azeroot is excluded (does not mill). Skill affects pigment quality, not quantity.
---@alias CraftSim.MillingShuffleCategory "r2_r1"|"r1_r1"|"r2_r2"

---@class CraftSim.MillingShuffleRow
---@field category CraftSim.MillingShuffleCategory
---@field herbItemID number
---@field pigmentItemID number
---@field herbsPerMill number        sheet uses 10 herbs per row (e.g. 10|0| or 0|10|)
---@field pigmentsMin number         minimum pigments for that batch (integer range low)
---@field pigmentsMax number         maximum pigments for that batch (integer range high)

--- Herb Q1/Q2 and pigment Q1/Q2 IDs match CraftSim ReagentWeightData / Midnight trade goods.
--- Pigments: Powder (Tranquility), Argentleaf, Sanguithorn, Mana Lily — two qualities each.

---@type CraftSim.MillingShuffleRow[]
CraftSim.MILLING_SHUFFLE_DATA = {
    -- R2 herb → R1 pigment (15–20 / 10 herbs)
    { category = "r2_r1", herbItemID = 236767, pigmentItemID = 245807, herbsPerMill = 10, pigmentsMin = 15, pigmentsMax = 20 },
    { category = "r2_r1", herbItemID = 236777, pigmentItemID = 245803, herbsPerMill = 10, pigmentsMin = 15, pigmentsMax = 20 },
    { category = "r2_r1", herbItemID = 236771, pigmentItemID = 245864, herbsPerMill = 10, pigmentsMin = 15, pigmentsMax = 20 },
    { category = "r2_r1", herbItemID = 236779, pigmentItemID = 245866, herbsPerMill = 10, pigmentsMin = 15, pigmentsMax = 20 },

    -- R1 herb → R1 pigment (10–15 / 10 herbs)
    { category = "r1_r1", herbItemID = 236761, pigmentItemID = 245807, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
    { category = "r1_r1", herbItemID = 236776, pigmentItemID = 245803, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
    { category = "r1_r1", herbItemID = 236770, pigmentItemID = 245864, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
    { category = "r1_r1", herbItemID = 236778, pigmentItemID = 245866, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },

    -- R2 herb → R2 pigment (10–15 / 10 herbs)
    { category = "r2_r2", herbItemID = 236767, pigmentItemID = 245808, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
    { category = "r2_r2", herbItemID = 236777, pigmentItemID = 245804, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
    { category = "r2_r2", herbItemID = 236771, pigmentItemID = 245865, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
    { category = "r2_r2", herbItemID = 236779, pigmentItemID = 245867, herbsPerMill = 10, pigmentsMin = 10, pigmentsMax = 15 },
}
