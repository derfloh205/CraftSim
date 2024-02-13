---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueue : CraftSim.CraftSimObject
CraftSim.CraftQueue = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

function CraftSim.CraftQueue:new()
    ---@type CraftSim.CraftQueueItem[]
    self.craftQueueItems = {}
end

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CraftQueue:AddRecipe(recipeData, amount)
    amount = amount or 1

    print("Adding Recipe to Queue: " .. recipeData.recipeName, true)

    -- make sure all required reagents are maxed out
    recipeData:SetNonQualityReagentsMax()
    for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
        if reagent.hasQuality then
            if reagent:GetTotalQuantity() < reagent.requiredQuantity then
                reagent:SetCheapestQualityMax()
            end
        end
    end

    local craftQueueItem = self:FindRecipe(recipeData)

    if craftQueueItem then
        -- only increase amount, but if recipeData has deeper (higher) subrecipedepth than take lower one
        craftQueueItem.amount = craftQueueItem.amount + amount
        craftQueueItem.recipeData.subRecipeDepth = math.max(craftQueueItem.recipeData.subRecipeDepth,
            recipeData.subRecipeDepth)

        -- also check if I have parent recipes that the already queued recipe does not have
        for _, parentRecipesInfo in ipairs(recipeData.parentRecipeInfo) do
            local hasPri = GUTIL:Some(craftQueueItem.recipeData.parentRecipeInfo, function(pri)
                return pri.crafterUID == parentRecipesInfo.crafterUID and pri.recipeID == parentRecipesInfo.recipeID
            end)
            if not hasPri then
                tinsert(craftQueueItem.recipeData.parentRecipeInfo, parentRecipesInfo)
            end
        end
    else
        craftQueueItem = CraftSim.CraftQueueItem(recipeData, amount)
        -- create a new queue item
        table.insert(self.craftQueueItems, craftQueueItem)
    end

    if #recipeData.priceData.selfCraftedReagents > 0 then
        -- for each reagent check if its self crafted
        for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
            for qualityID, reagentItem in ipairs(reagent.items) do
                local itemID = reagentItem.item:GetItemID()
                if recipeData:IsSelfCraftedReagent(itemID) and reagentItem.quantity > 0 then
                    -- queue recipeData
                    local subRecipe = recipeData.optimizedSubRecipes[itemID]
                    if subRecipe then
                        subRecipe:SetNonQualityReagentsMax()
                        -- TODO: as option or always use minimum quality instead of exact?
                        local queuedCrafts = math.ceil(subRecipe.resultData:GetExpectedCraftsForYieldByQuality(
                            reagentItem.quantity, qualityID) * craftQueueItem.amount)
                        self:AddRecipe(subRecipe, queuedCrafts)
                    end
                end
            end
        end

        -- TODO: optional reagents
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
    CraftSim.DEBUG:StartProfiling("CraftQueue Item Caching")
    CraftSimCraftQueueCache = GUTIL:Map(self.craftQueueItems, function(craftQueueItem)
        return craftQueueItem:Serialize()
    end)
    CraftSim.DEBUG:StopProfiling("CraftQueue Item Caching")
end

function CraftSim.CraftQueue:RestoreFromCache()
    CraftSim.DEBUG:StartProfiling("CraftQueue Item Restoration")
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

        CraftSim.DEBUG:StopProfiling("CraftQueue Item Restoration")
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

function CraftSim.CraftQueue:FilterSortByPriority()
    -- first append all recipes of the current crafter character that do not have any subrecipes
    local characterRecipesNoAltDependency, restRecipes = GUTIL:Split(self.craftQueueItems, function(cqi)
        local noActiveSubRecipes = not cqi.hasActiveSubRecipes
        local noSubRecipeFromAlts = not cqi.hasActiveSubRecipesFromAlts
        local validSubRecipeStatus = noActiveSubRecipes or noSubRecipeFromAlts
        return validSubRecipeStatus and cqi.isCrafter
    end)
    local sortedCharacterRecipes = GUTIL:Sort(characterRecipesNoAltDependency,
        function(a, b)
            if a.allowedToCraft and not b.allowedToCraft then
                return true
            elseif not a.allowedToCraft and b.allowedToCraft then
                return false
            end

            if a.recipeData.subRecipeDepth > b.recipeData.subRecipeDepth then
                return true
            elseif a.recipeData.subRecipeDepth < b.recipeData.subRecipeDepth then
                return false
            end

            if a.recipeData.averageProfitCached > b.recipeData.averageProfitCached then
                return true
            elseif a.recipeData.averageProfitCached < b.recipeData.averageProfitCached then
                return false
            end

            return false
        end)

    -- then sort the rest items by subrecipedepth and character names / profit
    local sortedRestRecipes = GUTIL:Sort(restRecipes, function(a, b)
        if a.recipeData.subRecipeDepth > b.recipeData.subRecipeDepth then
            return true
        elseif a.recipeData.subRecipeDepth < b.recipeData.subRecipeDepth then
            return false
        end

        local crafterA = a.recipeData:GetCrafterUID()
        local crafterB = b.recipeData:GetCrafterUID()

        if crafterA > crafterB then
            return true
        elseif crafterA < crafterB then
            return false
        end

        if a.recipeData.averageProfitCached > b.recipeData.averageProfitCached then
            return true
        elseif a.recipeData.averageProfitCached < b.recipeData.averageProfitCached then
            return false
        end

        return false
    end)

    wipe(self.craftQueueItems)
    tAppendAll(self.craftQueueItems, sortedCharacterRecipes)
    tAppendAll(self.craftQueueItems, sortedRestRecipes)
end

---Returns wether the recipe has any active subrecipes and if they are from alts (sub recipe is active if the item quantity > 0 and is crafted by another character)
---@param recipeData CraftSim.RecipeData
---@return boolean HasActiveSubRecipes
---@return boolean HasActiveSubRecipesFromAlts
function CraftSim.CraftQueue:RecipeHasActiveSubRecipesInQueue(recipeData)
    local print = CraftSim.DEBUG:SetDebugPrint("SUB_RECIPE_DATA")
    local activeSubRecipes = false
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()

    print("HasActiveSubRecipes? " .. recipeData:GetCrafterUID() .. "-" .. recipeData.recipeName)

    local activeSubRecipesFromAlts = GUTIL:Some(recipeData.priceData.selfCraftedReagents, function(itemID)
        -- need to find the corresponding recipeData in the craftQueue since the optimized one referenced in the recipeData itself is not necessarily the same (due to serialization and AddRecipe adding amount)
        local optimizedSubRecipeData = recipeData.optimizedSubRecipes[itemID]
        if not optimizedSubRecipeData then return false end
        local craftQueueItem = self:FindRecipe(optimizedSubRecipeData)
        if not craftQueueItem then return false end
        local subRecipeData = craftQueueItem.recipeData
        local debugItem = tostring(select(1, GetItemInfo(itemID)) or itemID) ..
            " q: " .. recipeData.reagentData:GetReagentQualityIDByItemID(itemID)
        print("checking item: " .. debugItem)
        local quantity = recipeData:GetReagentQuantityByItemID(itemID)
        local hasQuantity = quantity > 0
        if hasQuantity then
            print("item quantity: " .. quantity)
            activeSubRecipes = true -- if we find at least one active then we have subrecipes

            local isAlt = subRecipeData:GetCrafterUID() ~= crafterUID
            if isAlt then
                print("- has alt dep sub recipes")
                return true
            end

            -- else check if subRecipeData has ActiveSubRecipes not from the player
            local _, subRecipeAltDependend = self:RecipeHasActiveSubRecipesInQueue(subRecipeData)

            if subRecipeAltDependend then
                print("- has sub rep with alt dep")
                return true
            end
        end

        print("- no quantity for item")

        return false
    end)

    print("return " .. tostring(activeSubRecipes) .. ", " .. tostring(activeSubRecipesFromAlts))

    return activeSubRecipes, activeSubRecipesFromAlts
end
