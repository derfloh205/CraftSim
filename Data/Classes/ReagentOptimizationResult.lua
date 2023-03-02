_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.REAGENT_OPTIMIZATION)

---@class CraftSim.ReagentOptimizationResult
CraftSim.ReagentOptimizationResult = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param knapsackResult table
function CraftSim.ReagentOptimizationResult:new(recipeData, knapsackResult)
    if knapsackResult then
        ---@type number
        self.qualityID = knapsackResult.qualityReached
        self.craftingCosts = knapsackResult.minValue + recipeData.priceData.craftingCostsFixed
    
        local reagentItems = {}
        ---@type CraftSim.Reagent[]
        self.reagents = CraftSim.GUTIL:Map(recipeData.reagentData.requiredReagents, function(reagent) 
            if reagent.hasQuality then
                local copy = reagent:Copy()
                copy:Clear()
        
                table.foreach(copy.items, function (_, reagentItem)
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
                
                local reagentItem = CraftSim.GUTIL:Find(reagentItems, function(ri) return ri.item:GetItemID() == itemID end)
                reagentItem.quantity = quantity
            end
        end
    else
        self.qualityID = recipeData.maxQuality
        self.craftingCosts = 0
        self.reagents = {}
    end
end

---@return boolean hasItems
function CraftSim.ReagentOptimizationResult:HasItems()
    for _, reagent in pairs(self.reagents) do
        local hasItems = reagent:HasItems()

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
            reagentItemList = CraftSim.GUTIL:Concat({reagentItemList, reagent:GetReagentItemList()})
        end
    end

    return reagentItemList
end

function CraftSim.ReagentOptimizationResult:Debug()
    local debugLines = {
        "qualityID: " .. tostring(self.qualityID),
        "craftingCosts: " .. CraftSim.GUTIL:FormatMoney(self.craftingCosts),
    }

    table.foreach(self.reagents, function (_, reagent)
        debugLines = CraftSim.GUTIL:Concat({debugLines, reagent:Debug()})
    end)

    return debugLines
end

function CraftSim.ReagentOptimizationResult:IsAllocated(recipeData)
    return CraftSim.REAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, self)
end