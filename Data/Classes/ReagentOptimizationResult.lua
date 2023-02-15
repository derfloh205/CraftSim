_, CraftSim = ...

---@class CraftSim.ReagentOptimizationResult
---@field reagents CraftSim.Reagent[]
---@field qualityID number
---@field craftingCosts number -- required + fixed costs

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.REAGENT_OPTIMIZATION_OOP)

CraftSim.ReagentOptimizationResult = CraftSim.Object:extend()

function CraftSim.ReagentOptimizationResult:new(recipeData, knapsackResult)
    if knapsackResult then
        self.qualityID = knapsackResult.qualityReached
        self.craftingCosts = knapsackResult.minValue + recipeData.priceData.craftingCostsFixed
    
        local reagentItems = {}
        self.reagents = CraftSim.UTIL:Map(recipeData.reagentData.requiredReagents, function(reagent) 
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
                
                local reagentItem = CraftSim.UTIL:Find(reagentItems, function(ri) return ri.item:GetItemID() == itemID end)
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
            reagentItemList = CraftSim.UTIL:Concat({reagentItemList, reagent:GetReagentItemList()})
        end
    end

    return reagentItemList
end

function CraftSim.ReagentOptimizationResult:Debug()
    local debugLines = {
        "qualityID: " .. tostring(self.qualityID),
        "craftingCosts: " .. CraftSim.UTIL:FormatMoney(self.craftingCosts),
    }

    table.foreach(self.reagents, function (_, reagent)
        debugLines = CraftSim.UTIL:Concat({debugLines, reagent:Debug()})
    end)

    return debugLines
end

function CraftSim.ReagentOptimizationResult:IsAllocated(recipeData)
    CraftSim.REAGENT_OPTIMIZATION:IsCurrentAllocationOOP(recipeData, self)
end