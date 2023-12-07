_, CraftSim = ...

---@class CraftSim.CraftQueueItem
CraftSim.CraftQueueItem = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CraftQueueItem:new(recipeData, amount)
    ---@type CraftSim.RecipeData
    self.recipeData = recipeData
    ---@type number
    self.amount = amount or 1
end

---@return boolean allowedToCraft, boolean canCraftOnce, boolean gearEquipped, boolean correctProfessionOpen
function CraftSim.CraftQueueItem:CanCraft()
    local canCraftOnce = self.recipeData:CanCraft(1) or false
    local gearEquipped = self.recipeData.professionGearSet:IsEquipped() or false
    local correctProfessionOpen = self.recipeData:IsProfessionOpen() or false

    local allowedToCraft = canCraftOnce and gearEquipped and correctProfessionOpen

    return allowedToCraft, canCraftOnce, gearEquipped, correctProfessionOpen
end