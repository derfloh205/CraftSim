---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@class CraftSim.ProfessionData
---@overload fun(recipeData: CraftSim.RecipeData, recipeID:number) : CraftSim.ProfessionData
CraftSim.ProfessionData = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param recipeID number
function CraftSim.ProfessionData:new(recipeData, recipeID)
	self.recipeData = recipeData
	self.professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
	self.skillLineID = self.professionInfo.professionID
end

function CraftSim.ProfessionData:GetJSON(indent)
	indent = indent or 0
	local jb = CraftSim.JSONBuilder(indent)
	jb:Begin()
	jb:Add("professionInfo", self.professionInfo)
	jb:Add("skillLineID", self.skillLineID, true)
	jb:End()
	return jb.json
end
