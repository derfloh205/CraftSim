---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_OPTIMIZED_COSTS : CraftSim.DB.Repository
CraftSim.DB.ITEM_OPTIMIZED_COSTS = CraftSim.DB:RegisterRepository("ItemOptimizedCostsDB")

---@class CraftSim.ExpectedCraftingCostsData
---@field qualityID QualityID
---@field crafter CrafterUID
---@field expectedCostsPerItem number
---@field expectedYieldPerCraft number
---@field profession Enum.Profession
---@field concentration boolean
---@field concentrationCost number

local print = CraftSim.DEBUG:RegisterDebugID("Database.itemOptimizedCostsDB")

function CraftSim.DB.ITEM_OPTIMIZED_COSTS:Init()
    if not CraftSimDB.itemOptimizedCostsDB then
        ---@type CraftSimDB.Database
        CraftSimDB.itemOptimizedCostsDB = {
            version = 0,
            ---@type table<ItemID, table<CrafterUID, CraftSim.ExpectedCraftingCostsData>>
            data = {},
        }
    end
    self.db = CraftSimDB.itemOptimizedCostsDB

    CraftSimDB.itemOptimizedCostsDB.data = CraftSimDB.itemOptimizedCostsDB.data or {}
end

function CraftSim.DB.ITEM_OPTIMIZED_COSTS:ClearAll()
    wipe(CraftSimDB.itemOptimizedCostsDB.data)
end

function CraftSim.DB.ITEM_OPTIMIZED_COSTS:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache and CraftSimRecipeDataCache["itemOptimizedCostsDataCache"] then
        CraftSimRecipeDataCache["itemOptimizedCostsDataCache"] = nil
    end
end

---@param itemID ItemID
---@param crafterUID CrafterUID
---@return CraftSim.ExpectedCraftingCostsData?
function CraftSim.DB.ITEM_OPTIMIZED_COSTS:Get(itemID, crafterUID)
    CraftSimDB.itemOptimizedCostsDB.data[itemID] = CraftSimDB.itemOptimizedCostsDB.data[itemID] or {}

    return CraftSimDB.itemOptimizedCostsDB.data[itemID][crafterUID]
end

---@param recipeData CraftSim.RecipeData
function CraftSim.DB.ITEM_OPTIMIZED_COSTS:Add(recipeData)
    -- cache the results if not gear and if its learned only
    if not recipeData.isGear and recipeData.learned then
        -- only if reachable
        for qualityID, item in ipairs(recipeData.resultData.itemsByQuality) do
            local reachable = qualityID <= recipeData.resultData.expectedQualityConcentration
            if reachable then
                print("Caching Optimized Costs Data for: " .. recipeData.recipeName .. " q" .. qualityID)
                local itemID = item:GetItemID()
                CraftSimDB.itemOptimizedCostsDB.data[itemID] = CraftSimDB.itemOptimizedCostsDB.data[itemID] or {}

                local concentrationAvailable = recipeData.concentrationCost > 0
                local concentration = qualityID == recipeData.resultData.expectedQualityConcentration and
                    concentrationAvailable

                -- Ensure expectedCostsPerItem is not nil to prevent GUTIL:Round errors
                local expectedCostsPerItem = recipeData.priceData.expectedCostsPerItem or 0

                ---@type CraftSim.ExpectedCraftingCostsData
                CraftSimDB.itemOptimizedCostsDB.data[itemID][recipeData:GetCrafterUID()] = {
                    crafter = recipeData:GetCrafterUID(),
                    qualityID = qualityID,
                    expectedCostsPerItem = expectedCostsPerItem,
                    expectedYieldPerCraft = recipeData.resultData.expectedYieldPerCraft,
                    concentration = concentration,
                    concentrationCost = recipeData.concentrationCost,
                    profession = recipeData.professionData.professionInfo.profession,
                }
            end
        end
    end
end

--- Migrations

function CraftSim.DB.ITEM_OPTIMIZED_COSTS.MIGRATION:M_0_1_Import_from_CraftSimRecipeDataCache()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.itemOptimizedCostsDB.data = CraftSimRecipeDataCache["itemOptimizedCostsDataCache"] or {}
        end
end

function CraftSim.DB.ITEM_OPTIMIZED_COSTS.MIGRATION:M_1_2_Remove_colored_crafter_names()
    -- remove any crafter entries with colored names...
        for _, data in pairs(CraftSimDB.itemOptimizedCostsDB.data or {}) do
            for crafterUID, _ in pairs(data) do
                if string.find(crafterUID, '\124c') then
                    data[crafterUID] = nil
                end
            end
        end
end

function CraftSim.DB.ITEM_OPTIMIZED_COSTS.MIGRATION:M_2_3_Remove_fishing_from_concentrationData()
    CraftSim.DB.ITEM_OPTIMIZED_COSTS:ClearAll()
end

function CraftSim.DB.ITEM_OPTIMIZED_COSTS.MIGRATION:M_3_4_ClearAll()
    CraftSim.DB.ITEM_OPTIMIZED_COSTS:ClearAll()
end