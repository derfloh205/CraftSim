---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueue
CraftSim.CraftQueue = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

function CraftSim.CraftQueue:new()
    ---@type CraftSim.CraftQueueItem[]
    self.craftQueueItems = {}

    self:RestoreFromCache()
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
        craftQueueItem.amount = craftQueueItem.amount + amount
    else
        -- create a new queue item
        table.insert(self.craftQueueItems, CraftSim.CraftQueueItem(recipeData, amount))
    end
end

--- set, increase or decrease amount of a queued recipeData in the queue, does nothing if recipe could not be found
---@param recipeData CraftSim.RecipeData
---@param amount number
---@param relative boolean? increment/decrement relative or set amount directly
---@return number? newAmount amount after adjustment, nil if recipe could not be adjusted
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

        return craftQueueItem.amount
    end
    return nil
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.CraftQueueItem | nil craftQueueItem, number? index
function CraftSim.CraftQueue:FindRecipe(recipeData)
    local craftQueueItem, index = GUTIL:Find(self.craftQueueItems,
        ---@param cqi CraftSim.CraftQueueItem
        function(cqi)
            local sameID = cqi.recipeData.recipeID == recipeData.recipeID
            local sameCrafter = cqi.recipeData:GetCrafterUID() == recipeData:GetCrafterUID()
            return sameID and sameCrafter
        end)
    return craftQueueItem, index
end

function CraftSim.CraftQueue:ClearAll()
    self.craftQueueItems = {}
    self:CacheQueueItems()
end

---@param crafterData CraftSim.CrafterData
function CraftSim.CraftQueue:ClearAllForCharacter(crafterData)
    self.craftQueueItems = GUTIL:Filter(self.craftQueueItems, function(craftQueueItem)
        return craftQueueItem.recipeData:CrafterDataEquals(crafterData)
    end)
    self:CacheQueueItems()
end

function CraftSim.CraftQueue:CacheQueueItems()
    CraftSim.UTIL:StartProfiling("CraftQueue Item Caching")
    CraftSimCraftQueueCache = GUTIL:Map(self.craftQueueItems, function(craftQueueItem)
        return craftQueueItem:Serialize()
    end)
    CraftSim.UTIL:StopProfiling("CraftQueue Item Caching")
end

function CraftSim.CraftQueue:RestoreFromCache()
    CraftSim.UTIL:StartProfiling("CraftQueue Item Restoration")
    print("Restore CraftQ From Cache Start...")
    local function load()
        print("Loading Cached CraftQueue...")
        self.craftQueueItems = GUTIL:Map(CraftSimCraftQueueCache, function(craftQueueItemSerialized)
            local craftQueueItem = CraftSim.CraftQueueItem:Deserialize(craftQueueItemSerialized)
            if craftQueueItem then
                craftQueueItem:CalculateCanCraft()
                return craftQueueItem
            end
            return nil
        end)

        print("CraftQueue Restore Finished")

        CraftSim.UTIL:StopProfiling("CraftQueue Item Restoration")
    end

    -- wait til necessary info is loaded, then put deserialized items into queue
    GUTIL:WaitFor(function()
            print("Wait for professionInfo loaded or cached")
            return GUTIL:Every(CraftSimCraftQueueCache,
                function(craftQueueItemSerialized)
                    -- from cache?
                    CraftSimRecipeDataCache.professionInfoCache[CraftSim.UTIL:GetCrafterUIDFromCrafterData(craftQueueItemSerialized.crafterData)] =
                        CraftSimRecipeDataCache.professionInfoCache
                        [CraftSim.UTIL:GetCrafterUIDFromCrafterData(craftQueueItemSerialized.crafterData)] or {}
                    local cachedProfessionInfos = CraftSimRecipeDataCache.professionInfoCache
                        [CraftSim.UTIL:GetCrafterUIDFromCrafterData(craftQueueItemSerialized.crafterData)]
                    local professionInfo = cachedProfessionInfos[craftQueueItemSerialized.recipeID]

                    if not professionInfo then
                        -- get from api
                        professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(craftQueueItemSerialized
                            .recipeID)
                    end

                    return professionInfo and professionInfo.profession --[[@as boolean]]
                end)
        end,
        load)
end
