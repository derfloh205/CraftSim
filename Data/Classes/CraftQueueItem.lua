---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftQueueItem
---@overload fun(recipeData:CraftSim.RecipeData, amount:number)
CraftSim.CraftQueueItem = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint("CRAFTQ")

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
    CraftSim.UTIL:StartProfiling('CraftSim.CraftQueueItem:CalculateCanCraft')
    self.canCraftOnce, self.craftAbleAmount = self.recipeData:CanCraft(1)
    self.gearEquipped = self.recipeData.professionGearSet:IsEquipped() or false
    self.correctProfessionOpen = self.recipeData:IsProfessionOpen() or false
    self.notOnCooldown = not self.recipeData:OnCooldown()
    self.isCrafter = self:IsCrafter()
    self.learned = self.recipeData.learned

    self.allowedToCraft = self.canCraftOnce and self.gearEquipped and self.correctProfessionOpen and self.notOnCooldown and
        self.isCrafter and self.learned
    CraftSim.UTIL:StopProfiling('CraftSim.CraftQueueItem:CalculateCanCraft')
end

---@class CraftSim.CraftQueueItem.Serialized
---@field recipeID number
---@field amount number
---@field crafterData CraftSim.CrafterData
---@field requiredReagents CraftingReagentInfo[]
---@field optionalReagents CraftingReagentInfo[]
---@field professionGearSet CraftSim.ProfessionGearSet.Serialized

function CraftSim.CraftQueueItem:Serialize()
    ---@type CraftSim.CraftQueueItem.Serialized
    local serializedData = {
        recipeID = self.recipeData.recipeID,
        amount = self.amount,
        crafterData = self.crafterData,
        requiredReagents = self.recipeData.reagentData:GetRequiredCraftingReagentInfoTbl(),
        optionalReagents = self.recipeData.reagentData:GetOptionalCraftingReagentInfoTbl(),
        professionGearSet = self.recipeData.professionGearSet:Serialize()
    }
    return serializedData
end

---@param serializedData CraftSim.CraftQueueItem.Serialized
---@return CraftSim.CraftQueueItem?
function CraftSim.CraftQueueItem:Deserialize(serializedData)
    print("Deserialize CraftQueueItem")
    -- first create a recipeData
    local recipeData = CraftSim.RecipeData(serializedData.recipeID, nil, nil, serializedData.crafterData)

    if recipeData and recipeData.isCrafterInfoCached then
        recipeData:SetReagentsByCraftingReagentInfoTbl(GUTIL:Concat { serializedData.requiredReagents, serializedData.optionalReagents })

        recipeData:SetNonQualityReagentsMax()

        recipeData.professionGearSet:LoadSerialized(serializedData.professionGearSet)

        recipeData:Update()

        print("recipeInfo: " .. tostring(recipeData.recipeInfoCached))
        print("isCrafterInfoCached: " .. tostring(recipeData.isCrafterInfoCached))
        print("professionGearCached: " .. tostring(recipeData.professionGearCached))
        print("operationInfoCached: " .. tostring(recipeData.operationInfoCached))
        print("specializationDataCached: " .. tostring(recipeData.specializationDataCached))
        return CraftSim.CraftQueueItem(recipeData, serializedData.amount)
    end
    print("crafter info not cached...")
    -- if necessary recipeData could not be loaded from cache or is not fully cached return nil
    -- should only really happen if somehow it could not cache the recipe on crafter side due to a bug
    -- or if the player deleted the cache saved var during character switch
    return nil
end

function CraftSim.CraftQueueItem:IsCrafter()
    return self.recipeData:IsCrafter()
end
