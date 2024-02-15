---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueueItem : CraftSim.CraftSimObject
---@overload fun(recipeData:CraftSim.RecipeData, amount?:number, targetItemCountByQuality?: table<QualityID, number>)
CraftSim.CraftQueueItem = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:SetDebugPrint("CRAFTQ")

---@param recipeData CraftSim.RecipeData
---@param amount number?
---@param targetItemCountByQuality? table<QualityID, number>
function CraftSim.CraftQueueItem:new(recipeData, amount, targetItemCountByQuality)
    ---@type CraftSim.RecipeData
    self.recipeData = recipeData
    ---@type number
    self.amount = amount or 1
    ---@type boolean
    self.targetMode = false

    self.targetItemCountByQuality = targetItemCountByQuality

    if targetItemCountByQuality then
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

    self.crafterData = recipeData:GetCrafterData()
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
---@field requiredReagents CraftingReagentInfo[]
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
            requiredReagents = recipeData.reagentData:GetRequiredCraftingReagentInfoTbl(),
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

            recipeData:SetReagentsByCraftingReagentInfoTbl(GUTIL:Concat { serializedCraftQueueItem.requiredReagents, serializedCraftQueueItem.optionalReagents })

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
        return CraftSim.CraftQueueItem(recipeData, serializedData.amount, serializedData.targetItemCountByQuality)
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
        local itemCount = CraftSim.CACHE.ITEM_COUNT:Get(item:GetItemID(), true, false, true, crafterUID)

        if itemCount < count then
            return false
        end
    end

    return true
end

-- TODO: GIVE AN OPTION TO INCREASE THIS RELATIVELY
function CraftSim.CraftQueueItem:GetMinimumCraftsForTargetCount()
    if not self.targetMode or not self.targetItemCountByQuality then return 0 end

    -- get the expectedCrafts for each quality that is queued and then choose the highest and round up
    local highestExpectedCrafts = 0

    local minimumAmountForDifferentQualities = 0

    for qualityID, count in pairs(self.targetItemCountByQuality) do
        local item = self.recipeData.resultData.itemsByQuality[qualityID]
        local currentCount = CraftSim.CACHE.ITEM_COUNT:Get(item:GetItemID(), true, false, true,
            self.recipeData:GetCrafterUID())
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

    return ceiledExpectedCrafts
end

---@param targetItemCountByQuality table<QualityID, number>
function CraftSim.CraftQueueItem:AddTargetItemCount(targetItemCountByQuality)
    if not self.targetMode or self.targetItemCountByQuality then return end

    for qualityID, count in pairs(targetItemCountByQuality) do
        self:SetTargetCount(qualityID, count, true)
    end
end
