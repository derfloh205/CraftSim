_, CraftSim = ...

---@class CraftSim.RecipeData
---@field recipeID? number 
---@field recipeType? number,
---@field learned? boolean,
---@field numSkillUps? number,
---@field recipeIcon? string,
---@field recipeName? string,
---@field supportsCraftingStats? boolean,
---@field professionData? CraftSim.ProfessionData
---@field reagentData CraftSim.ReagentData

CraftSim.RecipeData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

---@return CraftSim.RecipeData?
function CraftSim.RecipeData:new(recipeID, isRecraft)
    self.professionData = CraftSim.ProfessionData(recipeID)

    if not self.professionData.isLoaded then
        print("Could not create recipeData: professionData not loaded")
        return nil
    end

    
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    
	if not recipeInfo then
		print("Could not create recipeData: recipeInfo nil")
		return nil
	end
    
    self.recipeID = recipeID
    self.isRecraft = isRecraft ~= nil
    self.recipeType = CraftSim.UTIL:GetRecipeType(recipeInfo)
    self.learned = recipeInfo.learned
	self.numSkillUps = recipeInfo.numSkillUps
	self.recipeIcon = recipeInfo.icon
	self.recipeName = recipeInfo.name
	self.supportsCraftingStats = recipeInfo.supportsCraftingStats
    self.isEnchantingRecipe = recipeInfo.isEnchantingRecipe
    self.isSalvageRecipe = recipeInfo.isSalvageRecipe

    -- fetch possible required/optional/finishing reagents, if possible categorize by quality?

    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(self.recipeID, self.isRecraft)

    self.reagentData = CraftSim.ReagentData(schematicInfo)
end