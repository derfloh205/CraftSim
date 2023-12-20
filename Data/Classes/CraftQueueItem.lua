---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CraftQueueItem
CraftSim.CraftQueueItem = CraftSim.Object:extend()

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
end

--- calculates allowedToCraft, canCraftOnce, gearEquipped, correctProfessionOpen and craftAbleAmount
function CraftSim.CraftQueueItem:CalculateCanCraft()
    CraftSim.UTIL:StartProfiling('CraftSim.CraftQueueItem:CalculateCanCraft')
    self.canCraftOnce, self.craftAbleAmount = self.recipeData:CanCraft(1)
    self.gearEquipped = self.recipeData.professionGearSet:IsEquipped() or false
    self.correctProfessionOpen = self.recipeData:IsProfessionOpen() or false
    self.notOnCooldown = not self.recipeData:GetCooldownInformation().onCooldown
    
    self.allowedToCraft = self.canCraftOnce and self.gearEquipped and self.correctProfessionOpen and self.notOnCooldown
    CraftSim.UTIL:StopProfiling('CraftSim.CraftQueueItem:CalculateCanCraft')
end