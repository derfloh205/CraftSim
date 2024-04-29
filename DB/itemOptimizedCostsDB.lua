---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_OPTIMIZED_COSTS : CraftSim.DB.Repository
CraftSim.DB.ITEM_OPTIMIZED_COSTS = CraftSim.DB:RegisterRepository()

---@class CraftSim.ExpectedCraftingCostsData
---@field qualityID QualityID
---@field crafter CrafterUID
---@field expectedCosts number
---@field expectedCostsMin number
---@field craftingChance number
---@field craftingChanceMin number
---@field expectedCrafts number
---@field expectedCraftsMin number
---@field profession Enum.Profession

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

function CraftSim.DB.ITEM_OPTIMIZED_COSTS:Init()
    if not CraftSimDB.itemOptimizedCostsDB then
        ---@type CraftSimDB.Database
        CraftSimDB.itemOptimizedCostsDB = {
            version = 0,
            ---@type table<ItemID, table<CrafterUID, CraftSim.ExpectedCraftingCostsData>>
            data = {},
        }
    end

    CraftSimDB.itemOptimizedCostsDB.data = CraftSimDB.itemOptimizedCostsDB.data or {}
end

function CraftSim.DB.ITEM_OPTIMIZED_COSTS:Migrate()
    -- 0 -> 1
    if CraftSimDB.itemOptimizedCostsDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.itemOptimizedCostsDB.data = CraftSimRecipeDataCache["itemOptimizedCostsDataCache"] or {}
        end
        CraftSimDB.itemOptimizedCostsDB.version = 1
    end

    -- 1 -> 2 (16.1.2 -> 16.1.3)
    if CraftSimDB.itemOptimizedCostsDB.version == 1 then
        -- remove any crafter entries with colored names...
        for _, data in pairs(CraftSimDB.itemOptimizedCostsDB.data or {}) do
            for crafterUID, _ in pairs(data) do
                if string.find(crafterUID, '\124c') then
                    data[crafterUID] = nil
                end
            end
        end

        CraftSimDB.itemOptimizedCostsDB.version = 2
    end
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
        --print("Caching Optimized Costs Data for: " .. self.recipeName)

        -- only if reachable
        for qualityID, item in ipairs(recipeData.resultData.itemsByQuality) do
            local chance = recipeData.resultData.chanceByQuality[qualityID] or 0
            local minChance = recipeData.resultData.chancebyMinimumQuality[qualityID] or 0
            if minChance > 0 then
                print("Caching Optimized Costs Data for: " .. recipeData.recipeName)
                local itemID = item:GetItemID()
                CraftSimDB.itemOptimizedCostsDB.data[itemID] = CraftSimDB.itemOptimizedCostsDB.data[itemID] or {}

                CraftSimDB.itemOptimizedCostsDB.data[itemID][recipeData:GetCrafterUID()] = {
                    crafter = recipeData:GetCrafterUID(),
                    qualityID = qualityID,
                    craftingChance = chance,
                    craftingChanceMin = minChance,
                    expectedCosts = recipeData.priceData.expectedCostsByQuality[qualityID],
                    expectedCostsMin = recipeData.priceData.expectedCostsByMinimumQuality[qualityID],
                    expectedCrafts = recipeData.resultData.expectedCraftsByQuality[qualityID],
                    expectedCraftsMin = recipeData.resultData.expectedCraftsByMinimumQuality[qualityID],
                    profession = recipeData.professionData.professionInfo.profession,
                }
            end
        end
    end
end
