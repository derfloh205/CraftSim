---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.LastCraftingCostData
---@field cost number average crafting cost per item in copper
---@field timestamp number unix timestamp of last update

---@class CraftSim.DB.LAST_CRAFTING_COST : CraftSim.DB.Repository
CraftSim.DB.LAST_CRAFTING_COST = CraftSim.DB:RegisterRepository("LastCraftingCostDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.lastCraftingCostDB")

function CraftSim.DB.LAST_CRAFTING_COST:Init()
    if not CraftSimDB.lastCraftingCostDB then
        ---@class CraftSimDB.Database
        CraftSimDB.lastCraftingCostDB = {
            version = 0,
            ---@type table<string, table<CrafterUID, CraftSim.LastCraftingCostData>>
            data = {},
        }
    end
    self.db = CraftSimDB.lastCraftingCostDB
    CraftSimDB.lastCraftingCostDB.data = CraftSimDB.lastCraftingCostDB.data or {}
end

function CraftSim.DB.LAST_CRAFTING_COST:ClearAll()
    wipe(CraftSimDB.lastCraftingCostDB.data)
end

--- Get the DB key for a non-gear item (by itemID)
---@param itemID ItemID
---@return string
function CraftSim.DB.LAST_CRAFTING_COST:GetKeyByItemID(itemID)
    return tostring(itemID)
end

--- Get the DB key for a gear item (by itemID and qualityID)
---@param itemID ItemID
---@param qualityID QualityID
---@return string
function CraftSim.DB.LAST_CRAFTING_COST:GetKeyByItemIDAndQuality(itemID, qualityID)
    return tostring(itemID) .. ":" .. tostring(qualityID)
end

--- Save the expected crafting cost for a recipe's expected quality, keyed per crafter.
--- Only the expectedQuality is stored (concentration-adjusted when recipeData.concentrating is true).
---@param recipeData CraftSim.RecipeData
function CraftSim.DB.LAST_CRAFTING_COST:Save(recipeData)
    if not recipeData.learned then return end
    if not recipeData.resultData then return end

    local expectedQuality = recipeData.resultData.expectedQuality
    local item = recipeData.resultData.itemsByQuality[expectedQuality]
    if not item then return end

    local itemID = item:GetItemID()
    if not itemID then return end

    local key
    if recipeData.isGear then
        -- For gear all qualities share the same itemID; differentiate by qualityID
        key = self:GetKeyByItemIDAndQuality(itemID, expectedQuality)
    else
        -- For non-gear each quality has a unique itemID
        key = self:GetKeyByItemID(itemID)
    end

    local crafterUID = recipeData:GetCrafterUID()
    local expectedCostsPerItem = recipeData.priceData and recipeData.priceData.expectedCostsPerItem or 0
    local timestamp = time()

    print("Saving LastCraftingCost: " .. tostring(recipeData.recipeName) .. " q" .. tostring(expectedQuality) .. " crafter=" .. crafterUID)

    CraftSimDB.lastCraftingCostDB.data[key] = CraftSimDB.lastCraftingCostDB.data[key] or {}
    CraftSimDB.lastCraftingCostDB.data[key][crafterUID] = {
        cost = expectedCostsPerItem,
        timestamp = timestamp,
    }
end

--- Get all crafter entries for a non-gear item.
---@param itemID ItemID
---@return table<CrafterUID, CraftSim.LastCraftingCostData>?
function CraftSim.DB.LAST_CRAFTING_COST:GetByItemID(itemID)
    local key = self:GetKeyByItemID(itemID)
    return CraftSimDB.lastCraftingCostDB.data[key]
end

--- Get all crafter entries for a gear item by itemID and qualityID.
---@param itemID ItemID
---@param qualityID QualityID
---@return table<CrafterUID, CraftSim.LastCraftingCostData>?
function CraftSim.DB.LAST_CRAFTING_COST:GetByItemIDAndQuality(itemID, qualityID)
    local key = self:GetKeyByItemIDAndQuality(itemID, qualityID)
    return CraftSimDB.lastCraftingCostDB.data[key]
end

--- Get all crafter entries from an itemLink.
--- For gear items, the qualityID is extracted from the itemLink.
---@param itemLink string
---@return table<CrafterUID, CraftSim.LastCraftingCostData>?
function CraftSim.DB.LAST_CRAFTING_COST:GetByItemLink(itemLink)
    if not itemLink then return nil end
    local itemID = select(1, C_Item.GetItemInfoInstant(itemLink))
    if not itemID then return nil end

    local qualityID = GUTIL:GetQualityIDFromLink(itemLink)
    if qualityID and qualityID > 0 then
        local gearData = self:GetByItemIDAndQuality(itemID, qualityID)
        if gearData then return gearData end
    end

    return self:GetByItemID(itemID)
end

--- Find the cheapest crafter entry from a crafter map.
---@param entries table<CrafterUID, CraftSim.LastCraftingCostData>?
---@return CrafterUID? cheapestCrafterUID
---@return number? cheapestCost
---@return number? cheapestTimestamp
function CraftSim.DB.LAST_CRAFTING_COST:GetCheapestEntry(entries)
    if not entries then return nil, nil, nil end
    local cheapestCrafterUID, cheapestCost, cheapestTimestamp
    for crafterUID, data in pairs(entries) do
        if not cheapestCost or data.cost < cheapestCost then
            cheapestCrafterUID = crafterUID
            cheapestCost = data.cost
            cheapestTimestamp = data.timestamp
        end
    end
    return cheapestCrafterUID, cheapestCost, cheapestTimestamp
end

--- Get the cheapest crafter entry for a non-gear item by itemID.
---@param itemID ItemID
---@return CrafterUID? cheapestCrafterUID
---@return number? cheapestCost
---@return number? cheapestTimestamp
function CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemID(itemID)
    return self:GetCheapestEntry(self:GetByItemID(itemID))
end

--- Get the cheapest crafter entry for a gear item by itemID and qualityID.
---@param itemID ItemID
---@param qualityID QualityID
---@return CrafterUID? cheapestCrafterUID
---@return number? cheapestCost
---@return number? cheapestTimestamp
function CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemIDAndQuality(itemID, qualityID)
    return self:GetCheapestEntry(self:GetByItemIDAndQuality(itemID, qualityID))
end

--- Get the cheapest crafter entry from an itemLink.
---@param itemLink string
---@return CrafterUID? cheapestCrafterUID
---@return number? cheapestCost
---@return number? cheapestTimestamp
function CraftSim.DB.LAST_CRAFTING_COST:GetCheapestByItemLink(itemLink)
    return self:GetCheapestEntry(self:GetByItemLink(itemLink))
end

--- Migrations

function CraftSim.DB.LAST_CRAFTING_COST.MIGRATION:M_0_1_Clear_Non_Per_Crafter_Data()
    -- Old structure: data[key] = {cost, timestamp}
    -- New structure: data[key][crafterUID] = {cost, timestamp}
    -- Cannot migrate since old entries have no crafter info - clear all
    wipe(CraftSimDB.lastCraftingCostDB.data)
end
