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
            ---@type table<string, CraftSim.LastCraftingCostData>
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

---@param recipeData CraftSim.RecipeData
function CraftSim.DB.LAST_CRAFTING_COST:Save(recipeData)
    if not recipeData.learned then return end
    if not recipeData.resultData then return end

    local expectedCostsPerItem = recipeData.priceData and recipeData.priceData.expectedCostsPerItem or 0
    local timestamp = time()

    if recipeData.isGear then
        -- For gear, each quality has the same itemID but different qualityID in the itemLink
        -- Store by itemID:qualityID
        for qualityID, item in ipairs(recipeData.resultData.itemsByQuality) do
            local itemID = item:GetItemID()
            if itemID then
                local key = self:GetKeyByItemIDAndQuality(itemID, qualityID)
                print("Saving LastCraftingCost for gear: " .. tostring(recipeData.recipeName) .. " q" .. qualityID .. " key=" .. key)
                CraftSimDB.lastCraftingCostDB.data[key] = {
                    cost = expectedCostsPerItem,
                    timestamp = timestamp,
                }
            end
        end
    else
        -- For non-gear, each quality has a different itemID
        for _, item in ipairs(recipeData.resultData.itemsByQuality) do
            local itemID = item:GetItemID()
            if itemID then
                local key = self:GetKeyByItemID(itemID)
                print("Saving LastCraftingCost for item: " .. tostring(recipeData.recipeName) .. " itemID=" .. tostring(itemID))
                CraftSimDB.lastCraftingCostDB.data[key] = {
                    cost = expectedCostsPerItem,
                    timestamp = timestamp,
                }
            end
        end
    end
end

--- Get the last crafting cost for an item by itemID (for non-gear items)
---@param itemID ItemID
---@return CraftSim.LastCraftingCostData?
function CraftSim.DB.LAST_CRAFTING_COST:GetByItemID(itemID)
    local key = self:GetKeyByItemID(itemID)
    return CraftSimDB.lastCraftingCostDB.data[key]
end

--- Get the last crafting cost for a gear item by itemID and qualityID
---@param itemID ItemID
---@param qualityID QualityID
---@return CraftSim.LastCraftingCostData?
function CraftSim.DB.LAST_CRAFTING_COST:GetByItemIDAndQuality(itemID, qualityID)
    local key = self:GetKeyByItemIDAndQuality(itemID, qualityID)
    return CraftSimDB.lastCraftingCostDB.data[key]
end

--- Get the last crafting cost from an itemLink.
--- For gear items, the quality is extracted from the itemLink.
--- For non-gear items, the itemID is used as the key.
---@param itemLink string
---@return CraftSim.LastCraftingCostData?
function CraftSim.DB.LAST_CRAFTING_COST:GetByItemLink(itemLink)
    if not itemLink then return nil end
    local itemID = select(1, C_Item.GetItemInfoInstant(itemLink))
    if not itemID then return nil end

    local qualityID = GUTIL:GetQualityIDFromLink(itemLink)
    if qualityID and qualityID > 0 then
        -- Likely a gear item with quality in the link
        local gearData = self:GetByItemIDAndQuality(itemID, qualityID)
        if gearData then return gearData end
    end

    -- Fall back to non-gear lookup by itemID
    return self:GetByItemID(itemID)
end
