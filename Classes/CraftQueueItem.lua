---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueueItem : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.CraftQueueItem.Options): CraftSim.CraftQueueItem
CraftSim.CraftQueueItem = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:SetDebugPrint("CRAFTQ")

---@class CraftSim.CraftQueueItem.Options
---@field recipeData CraftSim.RecipeData
---@field amount? number
---@field targetItemCountByQuality? table<QualityID, number>

---@param options CraftSim.CraftQueueItem.Options
function CraftSim.CraftQueueItem:new(options)
    options = options or {}
    ---@type CraftSim.RecipeData
    self.recipeData = options.recipeData
    ---@type number
    self.amount = options.amount or 1
    ---@type boolean
    self.targetMode = false

    self.targetItemCountByQuality = options.targetItemCountByQuality

    if options.targetItemCountByQuality then
        self.targetMode = true
    end

    -- canCraft caches
    self.allowedToCraft = false
    self.canCraftOnce = false
    self.gearEquipped = false
    self.correctProfessionOpen = false
    self.craftAbleAmount = 0
    self.notOnCooldown = true
    self.isCrafter = false
    self.learned = false
    self.hasActiveSubRecipes = false

    --- important if the current character is not the crafter of the recipe
    self.allDataCached = false

    self.crafterData = options.recipeData:GetCrafterData()
end

--- calculates allowedToCraft, canCraftOnce, gearEquipped, correctProfessionOpen, notOnCooldown and craftAbleAmount
function CraftSim.CraftQueueItem:CalculateCanCraft()
    CraftSim.DEBUG:StartProfiling('CraftSim.CraftQueueItem:CalculateCanCraft')
    self.canCraftOnce, self.craftAbleAmount = self.recipeData:CanCraft(1)
    self.gearEquipped = self.recipeData.professionGearSet:IsEquipped() or false
    self.correctProfessionOpen = self.recipeData:IsProfessionOpen() or false
    self.notOnCooldown = not self.recipeData:OnCooldown()
    self.isCrafter = self:IsCrafter()
    self.learned = self.recipeData.learned

    self.hasActiveSubRecipes, self.hasActiveSubRecipesFromAlts = CraftSim.CRAFTQ.craftQueue
        :RecipeHasActiveSubRecipesInQueue(self.recipeData)

    self.allowedToCraft = self.canCraftOnce and self.gearEquipped and self.correctProfessionOpen and self.notOnCooldown and
        self.isCrafter and self.learned
    CraftSim.DEBUG:StopProfiling('CraftSim.CraftQueueItem:CalculateCanCraft')
end

---@class CraftSim.CraftQueueItem.Serialized
---@field recipeID number
---@field amount? number
---@field crafterData CraftSim.CrafterData
---@field requiredReagents CraftSim.Reagent.Serialized[]
---@field optionalReagents CraftingReagentInfo[]
---@field professionGearSet CraftSim.ProfessionGearSet.Serialized
---@field subRecipeDepth number
---@field subRecipeCostsEnabled boolean
---@field serializedSubRecipeData CraftSim.CraftQueueItem.Serialized[]
---@field parentRecipeInfo CraftSim.RecipeData.ParentRecipeInfo[]
---@field targetMode? boolean
---@field targetItemCountByQuality? table<QualityID, number>

function CraftSim.CraftQueueItem:Serialize()
    ---@param recipeData CraftSim.RecipeData
    local function serializeCraftQueueRecipeData(recipeData)
        ---@type CraftSim.CraftQueueItem.Serialized
        local serializedData = {
            recipeID = recipeData.recipeID,
            crafterData = recipeData.crafterData,
            requiredReagents = recipeData.reagentData:SerializeRequiredReagents(),
            optionalReagents = recipeData.reagentData:GetOptionalCraftingReagentInfoTbl(),
            professionGearSet = recipeData.professionGearSet:Serialize(),
            subRecipeDepth = recipeData.subRecipeDepth,
            subRecipeCostsEnabled = recipeData.subRecipeCostsEnabled,
            serializedSubRecipeData = {},
            parentRecipeInfo = recipeData.parentRecipeInfo,
        }

        -- save correct mapping
        for itemID, optimizedSubRecipeData in pairs(recipeData.optimizedSubRecipes) do
            serializedData.serializedSubRecipeData[itemID] = serializeCraftQueueRecipeData(optimizedSubRecipeData)
        end

        return serializedData
    end

    local serializedCraftQueueItem = serializeCraftQueueRecipeData(self.recipeData)
    serializedCraftQueueItem.amount = self.amount
    serializedCraftQueueItem.targetMode = self.targetMode
    serializedCraftQueueItem.targetItemCountByQuality = self.targetItemCountByQuality

    return serializedCraftQueueItem
end

---@param serializedData CraftSim.CraftQueueItem.Serialized
---@return CraftSim.CraftQueueItem?
function CraftSim.CraftQueueItem:Deserialize(serializedData)
    print("Deserialize CraftQueueItem")

    ---@param serializedCraftQueueItem CraftSim.CraftQueueItem.Serialized
    ---@return CraftSim.RecipeData?
    local function deserializeCraftQueueRecipeData(serializedCraftQueueItem)
        -- first create a recipeData
        local recipeData = CraftSim.RecipeData(serializedCraftQueueItem.recipeID, nil, nil,
            serializedCraftQueueItem.crafterData)
        recipeData.subRecipeDepth = serializedCraftQueueItem.subRecipeDepth or 0
        recipeData.subRecipeCostsEnabled = serializedCraftQueueItem.subRecipeCostsEnabled
        recipeData.parentRecipeInfo = serializedCraftQueueItem.parentRecipeInfo or {}

        if recipeData and recipeData.isCrafterInfoCached then
            -- deserialize potential subrecipes and restore correct mapping
            for itemID, serializedSubRecipeData in pairs(serializedCraftQueueItem.serializedSubRecipeData or {}) do
                recipeData.optimizedSubRecipes[itemID] = deserializeCraftQueueRecipeData(serializedSubRecipeData)
            end

            local requiredReagentsCraftingReagentInfos = {}
            for _, serializedReagent in ipairs(serializedData.requiredReagents) do
                local reagent = CraftSim.Reagent:Deserialize(serializedReagent)
                tAppendAll(requiredReagentsCraftingReagentInfos, reagent:GetCraftingReagentInfos())
            end

            recipeData:SetReagentsByCraftingReagentInfoTbl(GUTIL:Concat { requiredReagentsCraftingReagentInfos, serializedCraftQueueItem.optionalReagents })

            recipeData:SetNonQualityReagentsMax()

            recipeData.professionGearSet:LoadSerialized(serializedCraftQueueItem.professionGearSet)

            recipeData:Update() -- should also update pricedata which uses the optimizedsubrecipes


            return recipeData
        end
    end

    -- update price data to update self crafted reagents?
    local recipeData = deserializeCraftQueueRecipeData(serializedData)


    if recipeData then
        print("recipeInfo: " .. tostring(recipeData.recipeInfoCached))
        print("isCrafterInfoCached: " .. tostring(recipeData.isCrafterInfoCached))
        print("professionGearCached: " .. tostring(recipeData.professionGearCached))
        print("operationInfoCached: " .. tostring(recipeData.operationInfoCached))
        print("specializationDataCached: " .. tostring(recipeData.specializationDataCached))
        return CraftSim.CraftQueueItem({
            recipeData = recipeData,
            amount = serializedData.amount,
            targetItemCountByQuality = serializedData.targetItemCountByQuality
        })
    end
    -- if necessary recipeData could not be loaded from cache or is not fully cached return nil
    -- should only really happen if somehow it could not cache the recipe on crafter side due to a bug
    -- or if the player deleted the cache saved var during character switch
    return nil
end

function CraftSim.CraftQueueItem:IsCrafter()
    return self.recipeData:IsCrafter()
end

---@param amount number
---@param relative boolean?
function CraftSim.CraftQueueItem:SetTargetCount(qualityID, amount, relative)
    if not self.targetMode then return end

    self.targetItemCountByQuality = self.targetItemCountByQuality or {}

    if relative then
        self.targetItemCountByQuality[qualityID] = self.targetItemCountByQuality[qualityID] or 0
        self.targetItemCountByQuality[qualityID] = math.max(0, self.targetItemCountByQuality[qualityID] + amount)
    else
        self.targetItemCountByQuality[qualityID] = amount
    end
end

---@return number
function CraftSim.CraftQueueItem:GetTargetCount(qualityID)
    if not self.targetMode then return 0 end
    self.targetItemCountByQuality = self.targetItemCountByQuality or {}

    return self.targetItemCountByQuality[qualityID] or 0
end

---@return boolean satisfied
function CraftSim.CraftQueueItem:IsTargetCountSatisfied()
    if not self.targetMode or not self.targetItemCountByQuality then return false end

    local crafterUID = self.recipeData:GetCrafterUID()
    for qualityID, count in pairs(self.targetItemCountByQuality) do
        local item = self.recipeData.resultData.itemsByQuality[qualityID]
        local itemCount = CraftSim.ITEM_COUNT:Get(crafterUID, item:GetItemID())

        if itemCount < count then
            return false
        end
    end

    return true
end

function CraftSim.CraftQueueItem:GetMinimumCraftsForTargetCount()
    if not self.targetMode or not self.targetItemCountByQuality then return 0 end

    -- get the expectedCrafts for each quality that is queued and then choose the highest and round up
    local highestExpectedCrafts = 0

    local minimumAmountForDifferentQualities = 0

    for qualityID, count in pairs(self.targetItemCountByQuality) do
        local item = self.recipeData.resultData.itemsByQuality[qualityID]
        local currentCount = CraftSim.ITEM_COUNT:Get(self.recipeData:GetCrafterUID(), item:GetItemID())
        local restCount = math.max(0, count - currentCount)
        if restCount > 0 then
            minimumAmountForDifferentQualities = minimumAmountForDifferentQualities + 1
        end
        local expectedCrafts = self.recipeData.resultData:GetExpectedCraftsForYieldByQuality(restCount, qualityID) or 0
        print("Minimum Crafts for " .. restCount .. " x q" .. qualityID .. ": " .. expectedCrafts)

        if expectedCrafts > highestExpectedCrafts then
            highestExpectedCrafts = expectedCrafts
        end
    end

    local ceiledExpectedCrafts = math.max(minimumAmountForDifferentQualities, math.ceil(highestExpectedCrafts))

    print("Minimum Crafts for Target Count: " .. ceiledExpectedCrafts)

    return ceiledExpectedCrafts + CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_TARGET_MODE_CRAFTOFFSET")
end

---@param targetItemCountByQuality table<QualityID, number>
function CraftSim.CraftQueueItem:AddTargetItemCount(targetItemCountByQuality)
    if not self.targetMode or self.targetItemCountByQuality then return end

    for qualityID, count in pairs(targetItemCountByQuality) do
        self:SetTargetCount(qualityID, count, true)
    end
end

function CraftSim.CraftQueueItem:UpdateSubRecipesInQueue()
    if not self.recipeData:HasActiveSubRecipes() then return end

    print("UpdateSubRecipesInQueue for " .. self.recipeData.recipeName, false, true)

    -- fetch cqis or add them if not existing
    local subCraftQueueItems = GUTIL:Map(self.recipeData.priceData.selfCraftedReagents, function(itemID)
        local subRecipeData = self.recipeData.optimizedSubRecipes[itemID]
        -- only if parent recipe has quantity set for this itemID
        if subRecipeData then
            if self.recipeData:GetReagentQuantityByItemID(itemID) > 0 then
                local cqi = CraftSim.CRAFTQ.craftQueue:FindRecipe(subRecipeData)
                if not cqi then
                    print("- Adding Subrecipe to queue: " ..
                        subRecipeData.recipeName .. " - " .. subRecipeData:GetCrafterUID())
                    cqi = CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = subRecipeData, amount = 1, targetItemCountByQuality = {} })
                end

                return cqi
            end
        end

        return nil
    end)

    print("#subCraftQueueItems: " .. #subCraftQueueItems)

    -- update their target count by all of their parent recipes
    for _, cqi in ipairs(subCraftQueueItems) do
        cqi:UpdateTargetModeSubRecipeByParentRecipes()
    end
end

function CraftSim.CraftQueueItem:UpdateTargetModeSubRecipeByParentRecipes()
    if not self.targetMode or self.recipeData.subRecipeDepth == 0 then return nil end

    print("UpdateTargetModeSubRecipeByParentRecipes", false, true)

    wipe(self.targetItemCountByQuality)

    for _, pri in ipairs(self.recipeData.parentRecipeInfo) do
        local parentCQI = CraftSim.CRAFTQ.craftQueue:FindRecipeByParentRecipeInfo(pri)

        if parentCQI then
            print("Found Parent Recipe in Queue: " .. parentCQI.recipeData:GetRecipeCraftQueueUID())
            for qualityID, item in ipairs(self.recipeData.resultData.itemsByQuality) do
                -- only if this item is a activesubreagent and I am the crafter!
                local itemID = item:GetItemID()
                local isSubReagent = parentCQI.recipeData:IsSelfCraftedReagent(itemID)
                if isSubReagent then
                    local subReagentCrafter = parentCQI.recipeData.optimizedSubRecipes[itemID]:GetCrafterUID()
                    local isCrafter = self.recipeData:GetCrafterUID() == subReagentCrafter

                    if isCrafter then
                        local totalQuantity = parentCQI.recipeData.reagentData:GetReagentQuantityByItemID(item:GetItemID()) *
                            parentCQI.amount
                        self.targetItemCountByQuality[qualityID] = self.targetItemCountByQuality[qualityID] or 0
                        self.targetItemCountByQuality[qualityID] = self.targetItemCountByQuality[qualityID] +
                            totalQuantity
                    end
                end
            end
        end
    end

    -- update expectedCrafts
    self.amount = self:GetMinimumCraftsForTargetCount()
end

function CraftSim.CraftQueueItem:GetNumParentRecipesInQueue()
    local count = 0
    for _, prI in ipairs(self.recipeData.parentRecipeInfo) do
        if CraftSim.CRAFTQ.craftQueue:FindRecipeByParentRecipeInfo(prI) then
            count = count + 1
        end
    end
    return count
end
