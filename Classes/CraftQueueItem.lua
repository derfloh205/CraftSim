---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
---@type CraftSim.PreCraftConditions
local PRE_CRAFT_CONDITIONS = CraftSim.PRE_CRAFT_CONDITIONS

---@class CraftSim.CraftQueueItem : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.CraftQueueItem.Options): CraftSim.CraftQueueItem
CraftSim.CraftQueueItem = CraftSim.CraftSimObject:extend()

local Logger = CraftSim.DEBUG:RegisterLogger("CraftQueueItem")

CraftSim.CraftQueueItem.CONDITION_IDS = PRE_CRAFT_CONDITIONS.CONDITION_IDS
CraftSim.CraftQueueItem.CONDITION_PRIORITY = PRE_CRAFT_CONDITIONS.CONDITION_PRIORITY

---@class CraftSim.CraftQueueItem.Options
---@field recipeData CraftSim.RecipeData
---@field amount? number

---@param options CraftSim.CraftQueueItem.Options
function CraftSim.CraftQueueItem:new(options)
    options = options or {}
    ---@type CraftSim.RecipeData
    self.recipeData = options.recipeData
    ---@type number
    self.amount = options.amount or 1
    self.concentrating = self.recipeData.concentrating

    -- canCraft caches
    self.allowedToCraft = false
    self.canCraftOnce = false
    self.gearEquipped = false
    self.correctProfessionOpen = false
    --- Pre-craft buff gate (e.g. Midnight / TWW Shattering Essence): cast this before Craft.
    ---@class CraftSim.CraftQueueItem.PcbgData
    ---@field gateId CraftSim.PreCraftBuffGateId?
    ---@field needsStep boolean
    ---@field canCast boolean
    ---@field dueToLoginStale boolean
    ---@field dueToMissingBuff boolean
    ---@field recipeData CraftSim.RecipeData?
    ---@type CraftSim.CraftQueueItem.PcbgData
    self.pcbgData = {
        gateId = nil,
        needsStep = false,
        canCast = false,
        dueToLoginStale = false,
        dueToMissingBuff = false,
        recipeData = nil,
    }
    self.craftAbleAmount = 0
    self.notOnCooldown = true
    self.isCrafter = false
    self.learned = false
    self.recipeDisabled = false
    self.recipeDisabledReason = nil
    ---@type table[]
    self.conditions = {}
    ---@type table<string, table>
    self.conditionMap = {}
    ---@type table[]
    self.failedConditions = {}
    ---@type table?
    self.topFailedCondition = nil
    self.hasActiveSubRecipes = false

    --- important if the current character is not the crafter of the recipe
    self.allDataCached = false

    self.crafterData = options.recipeData:GetCrafterData()
end

---@param condition table
function CraftSim.CraftQueueItem:AddCondition(condition)
    tinsert(self.conditions, condition)
    self.conditionMap[condition.id] = condition
end

function CraftSim.CraftQueueItem:ResetConditions()
    wipe(self.conditions)
    wipe(self.conditionMap)
    wipe(self.failedConditions)
    self.topFailedCondition = nil
end

---@return table[]
function CraftSim.CraftQueueItem:GetFailedConditions()
    return self.failedConditions
end

---@return table?
function CraftSim.CraftQueueItem:GetTopFailedCondition()
    return self.topFailedCondition
end

---@param conditionID string
---@return table?
function CraftSim.CraftQueueItem:GetCondition(conditionID)
    return self.conditionMap[conditionID]
end

---@param conditionIDs string[]
---@return boolean
function CraftSim.CraftQueueItem:AreConditionsMet(conditionIDs)
    return PRE_CRAFT_CONDITIONS:AreConditionsMet(self, conditionIDs)
end

function CraftSim.CraftQueueItem:BuildFailedConditionCache()
    PRE_CRAFT_CONDITIONS:BuildFailedConditionCache(self)
end

---@return string
function CraftSim.CraftQueueItem:GetConditionDebugSignature()
    return PRE_CRAFT_CONDITIONS:GetConditionDebugSignature(self)
end

function CraftSim.CraftQueueItem:DebugLogConditionStateIfChanged()
    PRE_CRAFT_CONDITIONS:DebugLogConditionStateIfChanged(self)
end

---@return boolean
function CraftSim.CraftQueueItem:CanClaimWorkOrder()
    return PRE_CRAFT_CONDITIONS:CanClaimWorkOrder(self)
end

--- calculates allowedToCraft, canCraftOnce, gearEquipped, correctProfessionOpen, notOnCooldown and craftAbleAmount
function CraftSim.CraftQueueItem:CalculateCanCraft()
    CraftSim.DEBUG:StartProfiling('CraftQueue.CraftQueueItem.CalculateCanCraft')

    self.hasActiveSubRecipes, self.hasActiveSubRecipesFromAlts = CraftSim.CRAFTQ.craftQueue
        :RecipeHasActiveSubRecipesInQueue(self.recipeData)
    PRE_CRAFT_CONDITIONS:Evaluate(self)
    CraftSim.DEBUG:StopProfiling('CraftQueue.CraftQueueItem.CalculateCanCraft')
end

---@class CraftSim.CraftQueueItem.Serialized
---@field recipeID number
---@field amount? number
---@field craftListID? number
---@field concentrating? boolean
---@field crafterData CraftSim.CrafterData
---@field requiredReagents CraftSim.Reagent.Serialized[]
---@field requiredSelectableReagent CraftingReagentInfo?
---@field optionalReagents CraftingReagentInfo[]
---@field professionGearSet CraftSim.ProfessionGearSet.Serialized
---@field subRecipeDepth number
---@field subRecipeCostsEnabled boolean
---@field serializedSubRecipeData CraftSim.CraftQueueItem.Serialized[]
---@field parentRecipeInfo CraftSim.RecipeData.ParentRecipeInfo[]
---@field orderData CraftingOrderInfo?

function CraftSim.CraftQueueItem:Serialize()
    ---@param recipeData CraftSim.RecipeData
    local function serializeCraftQueueRecipeData(recipeData)
        ---@type CraftSim.CraftQueueItem.Serialized
        local serializedData = {
            recipeID = recipeData.recipeID,
            craftListID = recipeData.craftListID,
            crafterData = recipeData.crafterData,
            concentrating = recipeData.concentrating,
            requiredReagents = recipeData.reagentData:SerializeRequiredReagents(),
            requiredSelectableReagent = recipeData.reagentData:HasRequiredSelectableReagent() and
                recipeData.reagentData.requiredSelectableReagentSlot:GetCraftingReagentInfo(),
            optionalReagents = recipeData.reagentData:GetOptionalCraftingReagentInfoTbl(),
            professionGearSet = recipeData.professionGearSet:Serialize(),
            subRecipeDepth = recipeData.subRecipeDepth,
            subRecipeCostsEnabled = recipeData.subRecipeCostsEnabled,
            serializedSubRecipeData = {},
            parentRecipeInfo = recipeData.parentRecipeInfo,
            orderData = recipeData.orderData,
        }

        -- save correct mapping
        for itemID, optimizedSubRecipeData in pairs(recipeData.optimizedSubRecipes) do
            serializedData.serializedSubRecipeData[itemID] = serializeCraftQueueRecipeData(optimizedSubRecipeData)
        end

        return serializedData
    end

    local serializedCraftQueueItem = serializeCraftQueueRecipeData(self.recipeData)
    serializedCraftQueueItem.amount = self.amount
    serializedCraftQueueItem.concentrating = self.concentrating

    return serializedCraftQueueItem
end

---@param serializedData CraftSim.CraftQueueItem.Serialized
---@return CraftSim.CraftQueueItem?
function CraftSim.CraftQueueItem:Deserialize(serializedData)
    Logger:LogDebug("Deserialize CraftQueueItem")

    ---@param serializedCraftQueueItem CraftSim.CraftQueueItem.Serialized
    ---@return CraftSim.RecipeData?
    local function deserializeCraftQueueRecipeData(serializedCraftQueueItem)
        -- first create a recipeData
        local recipeData = CraftSim.RecipeData({
            recipeID = serializedCraftQueueItem.recipeID,
            crafterData = serializedCraftQueueItem.crafterData,
            forceCache = true, -- necessary here due to execution after login
        })
        recipeData.craftListID = serializedCraftQueueItem.craftListID or 0
        recipeData.subRecipeDepth = serializedCraftQueueItem.subRecipeDepth or 0
        recipeData.concentrating = serializedCraftQueueItem.concentrating
        recipeData.subRecipeCostsEnabled = serializedCraftQueueItem.subRecipeCostsEnabled
        recipeData.parentRecipeInfo = serializedCraftQueueItem.parentRecipeInfo or {}

        if serializedCraftQueueItem.orderData then
            recipeData:SetOrder(serializedCraftQueueItem.orderData)
        end


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

            if serializedCraftQueueItem.requiredSelectableReagent then
                if serializedCraftQueueItem.requiredSelectableReagent.reagent.currencyID then
                    recipeData.reagentData.requiredSelectableReagentSlot:SetCurrencyReagent(
                        serializedCraftQueueItem.requiredSelectableReagent.reagent.currencyID)
                elseif serializedCraftQueueItem.requiredSelectableReagent.reagent.itemID then
                    recipeData.reagentData:SetRequiredSelectableReagent(
                        serializedCraftQueueItem.requiredSelectableReagent.reagent.itemID)
                end
            end

            recipeData:SetNonQualityReagentsMax()

            recipeData.professionGearSet:LoadSerialized(serializedCraftQueueItem.professionGearSet)

            recipeData:Update() -- should also update pricedata which uses the optimizedsubrecipes


            return recipeData
        end
    end

    -- update price data to update self crafted reagents?
    local recipeData = deserializeCraftQueueRecipeData(serializedData)


    if recipeData then
        Logger:LogDebug("recipeInfo: " .. tostring(recipeData.recipeInfoCached))
        Logger:LogDebug("isCrafterInfoCached: " .. tostring(recipeData.isCrafterInfoCached))
        Logger:LogDebug("professionGearCached: " .. tostring(recipeData.professionGearCached))
        Logger:LogDebug("operationInfoCached: " .. tostring(recipeData.operationInfoCached))
        Logger:LogDebug("specializationDataCached: " .. tostring(recipeData.specializationDataCached))
        return CraftSim.CraftQueueItem({
            recipeData = recipeData,
            amount = serializedData.amount,
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

function CraftSim.CraftQueueItem:UpdateCountByParentRecipes()
    if self.recipeData.subRecipeDepth == 0 then return end

    local parentCraftQueueItems = GUTIL:Map(self.recipeData.parentRecipeInfo, function(prI)
        return CraftSim.CRAFTQ.craftQueue:FindRecipeByParentRecipeInfo(prI)
    end)

    local itemID = self.recipeData.resultData.expectedItem:GetItemID()
    local totalCount = GUTIL:Fold(parentCraftQueueItems, 0, function(foldValue, cqi)
        if not cqi then return foldValue end
        local itemCount = cqi.recipeData.reagentData:GetReagentQuantityByItemID(itemID) * cqi.amount

        return itemCount + foldValue
    end)

    -- if I am the crafter also use warbank count otherwise not
    local inventoryCount = CraftSim.DB.ITEM_COUNT:Get(self.recipeData:GetCrafterUID(), itemID, true, self.isCrafter)

    local restCount = math.max(0, totalCount - inventoryCount)

    local minimumCrafts = math.max(0, restCount / self.recipeData.baseItemAmount)

    self.amount = minimumCrafts

    Logger:LogDebug("Updated amount for " .. tostring(self.recipeData.resultData.expectedItem:GetItemLink()) .. ": " .. self
        .amount)
    Logger:LogDebug("parentCraftQueueItems: " .. #parentCraftQueueItems)
    Logger:LogDebug("totalCount: " .. totalCount)
    Logger:LogDebug("inventoryCount: " .. inventoryCount)
    Logger:LogDebug("restCount: " .. restCount)
    Logger:LogDebug("minimumCrafts: " .. minimumCrafts)
end

function CraftSim.CraftQueueItem:UpdateSubRecipesInQueue()
    if not self.recipeData:HasActiveSubRecipes() then return end

    Logger:LogDebug("UpdateSubRecipesInQueue for " .. self.recipeData.recipeName, false, true)

    -- fetch cqis or add them if not existing
    local subCraftQueueItems = GUTIL:Map(self.recipeData.priceData.selfCraftedReagents, function(itemID)
        local subRecipeData = self.recipeData.optimizedSubRecipes[itemID]
        -- only if parent recipe has quantity set for this itemID
        if subRecipeData then
            if self.recipeData:GetReagentQuantityByItemID(itemID) > 0 then
                local cqi = CraftSim.CRAFTQ.craftQueue:FindRecipe(subRecipeData)
                Logger:LogDebug(" - Searching in queue for " ..
                    subRecipeData.recipeName .. "\n" .. subRecipeData:GetRecipeCraftQueueUID())
                if not cqi then
                    Logger:LogDebug(" - Not Found, Adding to queue")
                    cqi = CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = subRecipeData, amount = 1, })
                else
                    Logger:LogDebug(" - Subrecipe already in queue")
                end

                return cqi
            end
        end

        return nil
    end)

    Logger:LogDebug("#subCraftQueueItems: " .. #subCraftQueueItems)
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
