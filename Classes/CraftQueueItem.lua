---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueueItem : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.CraftQueueItem.Options): CraftSim.CraftQueueItem
CraftSim.CraftQueueItem = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.CraftQueue.CraftQueueItem")

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
    CraftSim.DEBUG:StartProfiling('CraftQueue.CraftQueueItem.CalculateCanCraft')
    local _, craftAbleAmount = self.recipeData:CanCraft(1)
    self.craftAbleAmount = craftAbleAmount
    self.canCraftOnce = craftAbleAmount > 0
    self.gearEquipped = self.recipeData.professionGearSet:IsEquipped() or false
    self.correctProfessionOpen = self.recipeData:IsProfessionOpen() or false
    self.notOnCooldown = not self.recipeData:OnCooldown()
    self.isCrafter = self:IsCrafter()
    self.learned = self.recipeData.learned

    self.hasActiveSubRecipes, self.hasActiveSubRecipesFromAlts = CraftSim.CRAFTQ.craftQueue
        :RecipeHasActiveSubRecipesInQueue(self.recipeData)

    self.allowedToCraft = self.canCraftOnce and self.gearEquipped and self.correctProfessionOpen and self.notOnCooldown and
        self.isCrafter and self.learned
    CraftSim.DEBUG:StopProfiling('CraftQueue.CraftQueueItem.CalculateCanCraft')
end

---@class CraftSim.CraftQueueItem.Serialized
---@field recipeID number
---@field amount? number
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
    print("Deserialize CraftQueueItem")

    ---@param serializedCraftQueueItem CraftSim.CraftQueueItem.Serialized
    ---@return CraftSim.RecipeData?
    local function deserializeCraftQueueRecipeData(serializedCraftQueueItem)
        -- first create a recipeData
        local recipeData = CraftSim.RecipeData({
            recipeID = serializedCraftQueueItem.recipeID,
            crafterData = serializedCraftQueueItem.crafterData,
            forceCache = true, -- necessary here due to execution after login
        })
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
                recipeData.reagentData:SetRequiredSelectableReagent(serializedCraftQueueItem.requiredSelectableReagent
                    .itemID)
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
        print("recipeInfo: " .. tostring(recipeData.recipeInfoCached))
        print("isCrafterInfoCached: " .. tostring(recipeData.isCrafterInfoCached))
        print("professionGearCached: " .. tostring(recipeData.professionGearCached))
        print("operationInfoCached: " .. tostring(recipeData.operationInfoCached))
        print("specializationDataCached: " .. tostring(recipeData.specializationDataCached))
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
        print("searching for ")
        print(prI, true, "PRI", 1)
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

    print("Updated amount for " .. tostring(self.recipeData.resultData.expectedItem:GetItemLink()) .. ": " .. self
        .amount)
    print("parentCraftQueueItems: " .. #parentCraftQueueItems)
    print("totalCount: " .. totalCount)
    print("inventoryCount: " .. inventoryCount)
    print("restCount: " .. restCount)
    print("minimumCrafts: " .. minimumCrafts)
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
                print(" - Searching in queue for " ..
                    subRecipeData.recipeName .. "\n" .. subRecipeData:GetRecipeCraftQueueUID())
                if not cqi then
                    print(" - Not Found, Adding to queue")
                    cqi = CraftSim.CRAFTQ.craftQueue:AddRecipe({ recipeData = subRecipeData, amount = 1, })
                else
                    print(" - Subrecipe already in queue")
                end

                return cqi
            end
        end

        return nil
    end)

    print("#subCraftQueueItems: " .. #subCraftQueueItems)
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
