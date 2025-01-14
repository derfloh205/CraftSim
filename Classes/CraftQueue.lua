---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueue : CraftSim.CraftSimObject
CraftSim.CraftQueue = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.CraftQueue")

function CraftSim.CraftQueue:new()
    ---@type CraftSim.CraftQueueItem[]
    self.craftQueueItems = {}

    --- quick key value map to O(1) find craft queue items based on RecipeCrafterUIDs
    ---@type table<RecipeCraftQueueUID, CraftSim.CraftQueueItem>
    self.recipeCrafterMap = {}
end

---@param options CraftSim.CraftQueueItem.Options
---@return CraftSim.CraftQueueItem
function CraftSim.CraftQueue:AddRecipe(options)
    options = options or {}
    local recipeData = options.recipeData
    local amount = options.amount or 1

    print("Adding Recipe to Queue: " .. recipeData.recipeName .. " x" .. amount, true)
    print("concentrating: " .. tostring(recipeData.concentrating))

    local recipeCrafterUID = recipeData:GetRecipeCraftQueueUID()

    -- make sure all required reagents are maxed out
    recipeData:SetNonQualityReagentsMax()
    recipeData:SetCheapestQualityReagentsMax()

    local craftQueueItem = self:FindRecipe(recipeData)

    if craftQueueItem then
        craftQueueItem.amount = craftQueueItem.amount + amount

        -- Check if I have parent recipes that the already queued recipe does not have and merge if yes
        craftQueueItem.recipeData:AddParentRecipeInfosFrom(recipeData)
    else
        craftQueueItem = CraftSim.CraftQueueItem({
            recipeData = recipeData:Copy(),
            amount = amount,
        })
        -- create a new queue item
        table.insert(self.craftQueueItems, craftQueueItem)
        self.recipeCrafterMap[recipeCrafterUID] = craftQueueItem
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
                        print("Found self crafted reagent: queue into cq: " .. subRecipe.recipeName .. " q" .. qualityID)
                        subRecipe:SetNonQualityReagentsMax()

                        -- its allocated but is it also necessary to craft? Or do I own enough?
                        -- include warbank only when crafter is player
                        local inventoryCount = CraftSim.DB.ITEM_COUNT:Get(subRecipe:GetCrafterUID(), itemID, true,
                            subRecipe:IsCrafter())
                        local restCount = math.max(0, (reagentItem.quantity * craftQueueItem.amount) - inventoryCount)
                        if restCount > 0 then
                            local minimumCrafts = math.max(0, restCount / subRecipe.baseItemAmount)
                            if minimumCrafts > 0 then
                                self:AddRecipe({ recipeData = subRecipe, amount = minimumCrafts })
                            end
                        end
                    end
                end
            end
        end

        -- TODO: optional reagents
    end

    return craftQueueItem
end

--- set, increase or decrease amount of a queued recipeData in the queue, does nothing if recipe could not be found
---@param recipeData CraftSim.RecipeData
---@param amount number
---@param relative boolean? increment/decrement relative or set amount directly
---@return number? newAmount amount after adjustment, nil if recipe could not be adjusted
function CraftSim.CraftQueue:SetAmount(recipeData, amount, relative)
    relative = relative or false
    local craftQueueItem = self:FindRecipe(recipeData)
    if craftQueueItem then
        print("found craftQueueItem do decrement")
        if relative then
            craftQueueItem.amount = craftQueueItem.amount + amount
        else
            craftQueueItem.amount = amount
        end

        -- if amount is <= 0 then remove recipe from queue
        if craftQueueItem.amount <= 0 then
            self:Remove(craftQueueItem)
        end

        return craftQueueItem.amount
    end
    return nil
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.CraftQueueItem | nil craftQueueItem
function CraftSim.CraftQueue:FindRecipe(recipeData)
    local craftQueueItem = self.recipeCrafterMap[recipeData:GetRecipeCraftQueueUID()]

    return craftQueueItem
end

---@param craftQueueItem CraftSim.CraftQueueItem
---@param removeParentSubcraftInformation boolean?
function CraftSim.CraftQueue:Remove(craftQueueItem, removeParentSubcraftInformation)
    local _, index = GUTIL:Find(self.craftQueueItems, function(cqI)
        return craftQueueItem == cqI
    end)

    -- Fix deleting multiple row
    if index == nil then
        return
    end

    self.recipeCrafterMap[craftQueueItem.recipeData:GetRecipeCraftQueueUID()] = nil
    tremove(self.craftQueueItems, index)

    -- after removal check if cqi had any subrecipes that are now without parents, if yes remove them too (recursively)
    -- ? Return a table with 3times the same subrecipe => try to deleting 3 times the same subrecipe
    -- But the index is nil in the second iteration because :Find return nil (already deleted)
    local subCraftQueueItems = GUTIL:Map(craftQueueItem.recipeData.priceData.selfCraftedReagents, function(itemID)
        local subRecipeData = craftQueueItem.recipeData.optimizedSubRecipes[itemID]
        if subRecipeData then
            local subCQI = CraftSim.CRAFTQ.craftQueue:FindRecipe(subRecipeData)
            -- only queue for removal if I am the only parent recipe in queue
            if subCQI and subCQI:GetNumParentRecipesInQueue() == 0 then
                return subCQI
            end
        end

        return nil
    end)

    for _, subCqi in ipairs(subCraftQueueItems) do
        self:Remove(subCqi)
    end

    -- if i was a subrecipe, check my parent recipes, and set the item I crafted there to not be crafted anymore by me (reoptimize needed?)
    -- by removing the optimizedSubRecipe and selfCraftedReagents entry

    if removeParentSubcraftInformation then
        for _, prI in ipairs(craftQueueItem.recipeData.parentRecipeInfo) do
            local parentCQI = self:FindRecipeByParentRecipeInfo(prI)

            if parentCQI then
                -- remove all references to this subrecipe and update priceData and profit
                for itemID, optimizedSubRecipe in pairs(parentCQI.recipeData.optimizedSubRecipes) do
                    if optimizedSubRecipe then
                        if optimizedSubRecipe:GetRecipeCraftQueueUID() == craftQueueItem.recipeData:GetRecipeCraftQueueUID() then
                            parentCQI.recipeData.optimizedSubRecipes[itemID] = nil
                        end
                    end
                end

                parentCQI.recipeData.priceData:Update()
                parentCQI.recipeData:GetAverageProfit()
            end
        end
    end

    if craftQueueItem.recipeData:IsWorkOrder() then
        -- check if claimed if yes release
        local claimedOrder = C_CraftingOrders.GetClaimedOrder()
        if claimedOrder and claimedOrder.orderID == craftQueueItem.recipeData.orderData.orderID then
            C_CraftingOrders.ReleaseOrder(claimedOrder.orderID,
                craftQueueItem.recipeData.professionData.professionInfo.profession)
        end
    end
end

---@param prI CraftSim.RecipeData.ParentRecipeInfo
---@return CraftSim.CraftQueueItem | nil
function CraftSim.CraftQueue:FindRecipeByParentRecipeInfo(prI)
    return self.recipeCrafterMap
        [prI.crafterUID .. ":" .. prI.recipeID .. ":" .. prI.subRecipeDepth .. ":" .. tostring(prI.concentrating)]
end

function CraftSim.CraftQueue:ClearAll()
    wipe(self.craftQueueItems)
    wipe(self.recipeCrafterMap)
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
    CraftSim.DEBUG:StartProfiling("CraftQueue Item DB Save")
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
    for _, craftQueueItem in ipairs(self.craftQueueItems) do
        CraftSim.DB.CRAFT_QUEUE:Add(craftQueueItem:Serialize())
    end
    CraftSim.DEBUG:StopProfiling("CraftQueue Item DB Save")
end

function CraftSim.CraftQueue:RestoreFromDB()
    CraftSim.DEBUG:StartProfiling("CraftQueue Item Restoration")
    print("Restore CraftQ From DB Start...")
    local dbCraftQueueItems = CraftSim.DB.CRAFT_QUEUE:GetAll()
    local function load()
        print("Loading CraftQueue from DB...")
        self.craftQueueItems = GUTIL:Map(dbCraftQueueItems, function(craftQueueItemSerialized)
            local craftQueueItem = CraftSim.CraftQueueItem:Deserialize(craftQueueItemSerialized)
            if craftQueueItem then
                craftQueueItem:CalculateCanCraft()
                self.recipeCrafterMap[craftQueueItem.recipeData:GetRecipeCraftQueueUID()] = craftQueueItem
                return craftQueueItem
            end
            return nil
        end)

        -- at last restore subrecipes
        self:UpdateSubRecipes()

        print("CraftQueue Restore Finished")

        CraftSim.DEBUG:StopProfiling("CraftQueue Item Restoration")
    end

    -- wait til necessary info is loaded, then put deserialized items into queue
    GUTIL:WaitFor(function()
            print("Wait for professionInfo loaded or cached")
            return GUTIL:Every(dbCraftQueueItems,
                function(craftQueueItemSerialized)
                    local crafterUID = CraftSim.UTIL:GetCrafterUIDFromCrafterData(craftQueueItemSerialized.crafterData)
                    -- from db
                    local professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID,
                        craftQueueItemSerialized.recipeID)

                    if not professionInfo then
                        -- get from api if not in db
                        professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(craftQueueItemSerialized
                            .recipeID)
                    end

                    return professionInfo and professionInfo.profession --[[@as boolean]]
                end)
        end,
        load)
end

function CraftSim.CraftQueue:FilterSortByPriority()
    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    -- first append all recipes of the current crafter character that do not have any subrecipes
    local characterRecipesNoAltDependency, restRecipes = GUTIL:Split(self.craftQueueItems, function(cqi)
        local noActiveSubRecipes = not cqi.hasActiveSubRecipes
        local noSubRecipeFromAlts = not cqi.hasActiveSubRecipesFromAlts
        local validSubRecipeStatus = noActiveSubRecipes or noSubRecipeFromAlts
        return validSubRecipeStatus and cqi.isCrafter
    end)
    local sortedCharacterRecipes = GUTIL:Sort(characterRecipesNoAltDependency,
        function(a, b)
            -- sort work orders on top of non subrecipe recipes
            local aWorkOrder = a.recipeData:IsWorkOrder()
            local bWorkOrder = b.recipeData:IsWorkOrder()

            local aSubRecipe = a.recipeData:IsSubRecipe()
            local bSubRecipe = b.recipeData:IsSubRecipe()

            -- subrecipes always on top
            if aSubRecipe and not bSubRecipe then
                return true
            elseif not aSubRecipe and bSubRecipe then
                return false
            end

            if a.correctProfessionOpen and not b.correctProfessionOpen then
                return true
            elseif not a.correctProfessionOpen and b.correctProfessionOpen then
                return false
            end

            -- work order recipes always above non work orders
            if aWorkOrder and not bWorkOrder then
                return true
            elseif bWorkOrder and not aWorkOrder then
                return false
            end

            -- now recipes are either both work orders or both not work orders

            -- if both work orders
            if aWorkOrder and bWorkOrder then
                -- submittable order always above non submittable (if there is a fulfillable order)
                if claimedOrder and claimedOrder.isFulfillable then
                    local aSubmittable = a.recipeData.orderData.orderID == claimedOrder.orderID
                    local bSubmittable = b.recipeData.orderData.orderID == claimedOrder.orderID
                    if aSubmittable and not bSubmittable then
                        return true
                    elseif not aSubmittable and bSubmittable then
                        return false
                    end
                end
            end

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
    local print = CraftSim.DEBUG:RegisterDebugID("SUB_RECIPE_DATA")
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
        local debugItem = tostring(select(1, C_Item.GetItemInfo(itemID)) or itemID) ..
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

---@param recipeData CraftSim.RecipeData
---@param craftingItemResultData CraftingItemResultData
function CraftSim.CraftQueue:OnRecipeCrafted(recipeData, craftingItemResultData)
    local craftQueueItem = self:FindRecipe(recipeData)

    if not craftQueueItem then return end

    -- if found only recognize as same crafted if concentration status and more is the same

    if craftQueueItem.recipeData.concentrating ~= recipeData.concentrating then return end

    if craftQueueItem.recipeData:GetReagentUID() ~= recipeData:GetReagentUID() then return end

    local ignoreIngenuityProc = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_IGNORE_INGENUITY_PROCS") and
        craftingItemResultData.hasIngenuityProc

    if recipeData.concentrating and recipeData.concentrationData then
        recipeData.concentrationData:Update()
    end

    -- decrement by one and refresh list (only when not work order recipe and when not ignoring ingenuity)
    if not craftQueueItem.recipeData.orderData then
        local ignoreIngenuityProc = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_IGNORE_INGENUITY_PROCS") and
            craftingItemResultData.hasIngenuityProc
        local autoRemoveConcentrationUsedUp = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED")
        local concentrationUsedUp = false



        if recipeData.concentrating and recipeData.concentrationData and autoRemoveConcentrationUsedUp then
            local remainingConcentration = recipeData.concentrationData:GetCurrentAmount()
            concentrationUsedUp = remainingConcentration < recipeData.concentrationCost
        end

        if concentrationUsedUp then
            local cqI = CraftSim.CRAFTQ.craftQueue:FindRecipe(recipeData)
            if cqI then
                CraftSim.CRAFTQ.craftQueue:Remove(cqI)
                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FLASH_TASKBAR_ON_CRAFT_FINISHED") then
                    FlashClientIcon()
                end
            end
        elseif not ignoreIngenuityProc then
            local newAmount = CraftSim.CRAFTQ.craftQueue:SetAmount(recipeData, -1, true)
            if newAmount and newAmount <= 0 and CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FLASH_TASKBAR_ON_CRAFT_FINISHED") then
                FlashClientIcon()
            end
        end
    end
    CraftSim.CRAFTQ.UI:UpdateDisplay()
end

---@return number maxDepth
function CraftSim.CraftQueue:GetMaxRecipeDepth()
    return GUTIL:Fold(self.craftQueueItems, 0, function(maxDepth, nextElement)
        if nextElement.recipeData.subRecipeDepth > maxDepth then
            return nextElement.recipeData.subRecipeDepth
        else
            return maxDepth
        end
    end)
end

-- add subrecipes not yet existing
function CraftSim.CraftQueue:UpdateSubRecipes()
    print("Update Subrecipes")
    local maxDepth = self:GetMaxRecipeDepth()
    for depth = 0, maxDepth do
        for _, cqi in ipairs(self.craftQueueItems) do
            if cqi.recipeData.subRecipeDepth == depth then
                cqi:UpdateSubRecipesInQueue()
            end
        end
    end

    self:UpdateSubRecipesItemCount()
    self:RemoveZeroCountSubRecipes()
end

function CraftSim.CraftQueue:UpdateSubRecipesItemCount()
    local maxDepth = self:GetMaxRecipeDepth()
    print("Update Sub Recipe Item Counts")
    for depth = 0, maxDepth do
        for _, cqi in ipairs(self.craftQueueItems) do
            if cqi.recipeData.subRecipeDepth == depth then
                cqi:UpdateCountByParentRecipes()
            end
        end
    end
end

function CraftSim.CraftQueue:RemoveZeroCountSubRecipes()
    print("Remove Zero Count")
    for _, cqi in ipairs(CopyTable(self.craftQueueItems, true)) do
        if cqi and cqi.recipeData.subRecipeDepth > 0 and cqi.amount <= 0 then
            print("- Removing: " .. cqi.recipeData.recipeName)
            self:Remove(cqi)
        end
    end
end
