---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.PRICE_OVERRIDE : CraftSim.DB.Repository
CraftSim.DB.PRICE_OVERRIDE = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:RegisterDebugID("Database.priceOverrideDB")

---@class CraftSim.DB.PriceOverride.Data
---@field recipeID number
---@field itemID number
---@field price number
---@field qualityID? number

---@class CraftSim.DB.PriceOverride
---@field globalOverrides table<ItemID, CraftSim.DB.PriceOverride.Data>
---@field recipeResultOverrides table<RecipeID, table<QualityID, CraftSim.DB.PriceOverride.Data>>

function CraftSim.DB.PRICE_OVERRIDE:Init()
    if not CraftSimDB.priceOverrideDB then
        ---@type CraftSimDB.Database
        CraftSimDB.priceOverrideDB = {
            version = 0,
            ---@type CraftSim.DB.PriceOverride
            data = {
                globalOverrides = {},
                recipeResultOverrides = {},
            },
        }
    end

    CraftSimDB.priceOverrideDB.data = CraftSimDB.priceOverrideDB.data or {}
    CraftSimDB.priceOverrideDB.data.globalOverrides = CraftSimDB.priceOverrideDB.data.globalOverrides or {}
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides = CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {}
end

function CraftSim.DB.PRICE_OVERRIDE:Migrate()
    -- 0 -> 1
    if CraftSimDB.priceOverrideDB.version == 0 then
        local CraftSimPriceOverridesV2 = _G["CraftSimPriceOverridesV2"]
        if CraftSimPriceOverridesV2 then
            for itemID, priceOverrideData in pairs(CraftSimPriceOverridesV2.globalOverrides or {}) do
                CraftSimDB.priceOverrideDB.data.globalOverrides[itemID] = priceOverrideData
            end
            for recipeID, recipeResultOverride in pairs(CraftSimPriceOverridesV2.recipeResultOverrides or {}) do
                for qualityID, priceOverrideData in pairs(recipeResultOverride) do
                    CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID] = CraftSimDB.priceOverrideDB.data
                        .recipeResultOverrides[recipeID] or {}
                    CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID][qualityID] = priceOverrideData
                end
            end
        end
        CraftSimDB.priceOverrideDB.version = 1
    end
end

function CraftSim.DB.PRICE_OVERRIDE:ClearAll()
    wipe(CraftSimDB.priceOverrideDB.data.globalOverrides or {})
    wipe(CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {})
end

function CraftSim.DB.PRICE_OVERRIDE:CleanUp()
    if _G["CraftSimPriceOverridesV2"] then
        _G["CraftSimPriceOverridesV2"] = nil
    end
end

---@return table<ItemID, CraftSim.DB.PriceOverride.Data> globalOverrides
function CraftSim.DB.PRICE_OVERRIDE:GetGlobalOverrides()
    CraftSimDB.priceOverrideDB.data.globalOverrides = CraftSimDB.priceOverrideDB.data.globalOverrides or {}
    return CraftSimDB.priceOverrideDB.data.globalOverrides
end

---@return table<RecipeID, table<QualityID, CraftSim.DB.PriceOverride.Data>> resultOverrides
function CraftSim.DB.PRICE_OVERRIDE:GetResultOverrides()
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides = CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {}
    return CraftSimDB.priceOverrideDB.data.recipeResultOverrides
end

---@param itemID ItemID
---@return CraftSim.DB.PriceOverride.Data?
function CraftSim.DB.PRICE_OVERRIDE:GetGlobalOverride(itemID)
    CraftSimDB.priceOverrideDB.data.globalOverrides = CraftSimDB.priceOverrideDB.data.globalOverrides or {}
    return CraftSimDB.priceOverrideDB.data.globalOverrides[itemID]
end

---@param overrideData CraftSim.DB.PriceOverride.Data
function CraftSim.DB.PRICE_OVERRIDE:SaveGlobalOverride(overrideData)
    CraftSimDB.priceOverrideDB.data.globalOverrides = CraftSimDB.priceOverrideDB.data.globalOverrides or {}
    CraftSimDB.priceOverrideDB.data.globalOverrides[overrideData.itemID] = overrideData
end

---@param recipeID RecipeID
---@param qualityID QualityID
---@return CraftSim.DB.PriceOverride.Data?
function CraftSim.DB.PRICE_OVERRIDE:GetResultOverride(recipeID, qualityID)
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides = CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {}

    if CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID] then
        return CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID][qualityID]
    end
end

---@param recipeID number
---@param qualityID number
---@return number? price nil when no override exists
function CraftSim.DB.PRICE_OVERRIDE:GetResultOverridePrice(recipeID, qualityID)
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides = CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {}

    if CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID] then
        if CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID][qualityID] then
            return CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID][qualityID].price
        end
    end
end

---@param overrideData CraftSim.DB.PriceOverride.Data
function CraftSim.DB.PRICE_OVERRIDE:SaveResultOverride(overrideData)
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides = CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {}
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides[overrideData.recipeID] = CraftSimDB.priceOverrideDB.data
        .recipeResultOverrides[overrideData.recipeID] or {}
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides[overrideData.recipeID][overrideData.qualityID] = overrideData
end

---@param recipeID RecipeID
---@param qualityID QualityID
function CraftSim.DB.PRICE_OVERRIDE:DeleteResultOverride(recipeID, qualityID)
    CraftSimDB.priceOverrideDB.data.recipeResultOverrides = CraftSimDB.priceOverrideDB.data.recipeResultOverrides or {}
    if CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID] then
        CraftSimDB.priceOverrideDB.data.recipeResultOverrides[recipeID][qualityID] = nil
    end
end

---@param itemID ItemID
function CraftSim.DB.PRICE_OVERRIDE:DeleteGlobalOverride(itemID)
    CraftSimDB.priceOverrideDB.data.globalOverrides = CraftSimDB.priceOverrideDB.data.globalOverrides or {}
    CraftSimDB.priceOverrideDB.data.globalOverrides[itemID] = nil
end
