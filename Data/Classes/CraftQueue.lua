---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CraftQueue
CraftSim.CraftQueue = CraftSim.Object:extend()

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

function CraftSim.CraftQueue:new()
    ---@type CraftSim.CraftQueueItem[]
    self.craftQueueItems = {}
end

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CraftQueue:AddRecipe(recipeData, amount)
    amount = amount or 1

    print("Adding recipe to queue with reagents: ")
    print(recipeData.reagentData, true)

    -- make sure all required reagents are maxed out
    recipeData:SetNonQualityReagentsMax()
    for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
        if reagent.hasQuality then
            if reagent:GetTotalQuantity() < reagent.requiredQuantity then
                reagent:SetCheapestQualityMax()
            end

        end
    end
    
    local craftQueueItem = self:FindRecipe(recipeData)

    if craftQueueItem then
        -- only increase amount
        craftQueueItem.amount =  craftQueueItem.amount + amount
    else
        -- create a new queue item
        table.insert(self.craftQueueItems, CraftSim.CraftQueueItem(recipeData, amount))
    end
end

--- set, increase or decrease amount of a queued recipeData in the queue, does nothing if recipe could not be found
---@param recipeData CraftSim.RecipeData
---@param amount number
---@param relative boolean? increment/decrement relative or set amount directly
function CraftSim.CraftQueue:SetAmount(recipeData, amount, relative)
    relative = relative or false
    local craftQueueItem, index = self:FindRecipe(recipeData)
    if craftQueueItem and index then
        print("found craftQueueItem do decrement")
        if relative then
            craftQueueItem.amount = craftQueueItem.amount + amount
        else
            craftQueueItem.amount = amount
        end
        
        -- if amount is <= 0 then remove recipe from queue
        if craftQueueItem.amount <= 0 then
            self.craftQueueItems[index] = nil
        end
    end
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.CraftQueueItem | nil craftQueueItem, number? index
function CraftSim.CraftQueue:FindRecipe(recipeData)
    -- local craftQueueItem, index = CraftSim.GUTIL:Find(self.craftQueueItems, 
    -- ---@param cqi CraftSim.CraftQueueItem
    -- function (cqi)
    --     return cqi.recipeData:EqualCraftSetup(recipeData)
    -- end)
    -- return craftQueueItem, index
    
    local craftQueueItem, index = CraftSim.GUTIL:Find(self.craftQueueItems, 
    ---@param cqi CraftSim.CraftQueueItem
    function (cqi)
        return cqi.recipeData.recipeID == recipeData.recipeID
    end)
    return craftQueueItem, index
end