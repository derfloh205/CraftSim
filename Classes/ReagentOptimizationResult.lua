---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Classes.ReagentOptimizationResult")

---@class CraftSim.ReagentOptimizationResult : CraftSim.CraftSimObject
CraftSim.ReagentOptimizationResult = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param knapsackResult table
function CraftSim.ReagentOptimizationResult:new(recipeData, knapsackResult)
    self.recipeData = recipeData

    if knapsackResult then
        ---@type number
        self.qualityID = knapsackResult.qualityReached
        --self.craftingCosts = knapsackResult.minValue + recipeData.priceData.craftingCostsFixed

        local reagentItems = {}
        ---@type CraftSim.Reagent[]
        self.reagents = CraftSim.GUTIL:Map(recipeData.reagentData.requiredReagents, function(reagent)
            if reagent.hasQuality then
                local copy = reagent:Copy()
                copy:Clear()

                table.foreach(copy.items, function(_, reagentItem)
                    table.insert(reagentItems, reagentItem)
                end)

                return copy
            end
        end)

        -- map knapsackResult to reagents
        for _, matAllocation in pairs(knapsackResult.allocations) do
            for _, allocation in pairs(matAllocation.allocations) do
                local itemID = allocation.itemID
                local quantity = allocation.allocations

                local reagentItem = CraftSim.GUTIL:Find(reagentItems,
                    function(ri) return ri.item:GetItemID() == itemID end)
                reagentItem.quantity = quantity
            end
        end
    else
        self.qualityID = recipeData.maxQuality
        --self.craftingCosts = 0
        self.reagents = {}
    end
end

---@return boolean hasItems
function CraftSim.ReagentOptimizationResult:HasItems(crafterUID)
    for _, reagent in pairs(self.reagents) do
        local hasItems = reagent:HasItems(1, crafterUID)

        if not hasItems then
            return false
        end
    end

    return true
end

---@return CraftSim.ReagentListItem[]
function CraftSim.ReagentOptimizationResult:GetReagentItemList()
    local reagentItemList = {}
    for _, reagent in pairs(self.reagents) do
        if reagent.hasQuality then -- should here but why not check
            reagentItemList = CraftSim.GUTIL:Concat({ reagentItemList, reagent:GetReagentItemList() })
        end
    end

    return reagentItemList
end

function CraftSim.ReagentOptimizationResult:Debug()
    local debugLines = {
        "qualityID: " .. tostring(self.qualityID),
        "craftingCosts: " .. CraftSim.UTIL:FormatMoney(self.craftingCosts),
    }

    table.foreach(self.reagents, function(_, reagent)
        debugLines = CraftSim.GUTIL:Concat({ debugLines, reagent:Debug() })
    end)

    return debugLines
end

function CraftSim.ReagentOptimizationResult:IsAllocated(recipeData)
    return CraftSim.REAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, self)
end

function CraftSim.ReagentOptimizationResult:OptimizeQualityIDs(considerSubCrafts)
    --- if qualityIDs of a reagent share their price with a higher quality, use the higher one (relevant for selfcrafted items mostly)

    for _, reagent in ipairs(self.reagents) do
        local lastPrice = 0
        local lastQuality = 1
        local lastReagentItem = nil
        for q, reagentItem in ipairs(reagent.items) do
            local currentPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true, false,
                considerSubCrafts)

            if q > lastQuality then
                if currentPrice == lastPrice and lastReagentItem then
                    reagentItem.quantity = reagentItem.quantity + lastReagentItem.quantity
                    lastReagentItem.quantity = 0
                end
            end

            lastQuality = q
            lastPrice = currentPrice
            lastReagentItem = reagentItem
        end
    end
end

--- required costs only
---@return number totalCraftingCostsRequired
function CraftSim.ReagentOptimizationResult:GetTotalReagentCost()
    local reagentPriceInfos = self.recipeData.priceData.reagentPriceInfos
    local reagentItems = self:GetReagentItemList()

    return GUTIL:Fold(reagentItems, 0, function(totalCost, nextReagentItem)
        local itemPriceInfo = reagentPriceInfos[nextReagentItem.itemID]
        return totalCost + itemPriceInfo.itemPrice
    end)
end
