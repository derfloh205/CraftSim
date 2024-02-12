---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueueItem : CraftSim.CraftSimObject
---@overload fun(recipeData:CraftSim.RecipeData, amount:number)
CraftSim.CraftQueueItem = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:SetDebugPrint("CRAFTQ")

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CraftQueueItem:new(recipeData, amount)
    ---@type CraftSim.RecipeData
    self.recipeData = recipeData
    ---@type number
    self.amount = amount or 1

    -- canCraft caches
    self.allowedToCraft = false
    self.canCraftOnce = false
    self.gearEquipped = false
    self.correctProfessionOpen = false
    self.craftAbleAmount = 0
    self.notOnCooldown = true
    self.isCrafter = false
    self.learned = false

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
            parentRecipeInfo = recipeData.parentRecipeInfo
        }

        -- save correct mapping
        for itemID, optimizedSubRecipeData in pairs(recipeData.optimizedSubRecipes) do
            serializedData.serializedSubRecipeData[itemID] = serializeCraftQueueRecipeData(optimizedSubRecipeData)
        end

        return serializedData
    end

    local serializedCraftQueueItem = serializeCraftQueueRecipeData(self.recipeData)
    serializedCraftQueueItem.amount = self.amount

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
        return CraftSim.CraftQueueItem(recipeData, serializedData.amount)
    end
    -- if necessary recipeData could not be loaded from cache or is not fully cached return nil
    -- should only really happen if somehow it could not cache the recipe on crafter side due to a bug
    -- or if the player deleted the cache saved var during character switch
    return nil
end

function CraftSim.CraftQueueItem:IsCrafter()
    return self.recipeData:IsCrafter()
end
