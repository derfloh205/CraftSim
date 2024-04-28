---@class CraftSim
local CraftSim = select(2, ...)

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@class CraftSim.ProfessionData : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, recipeID:number) : CraftSim.ProfessionData
CraftSim.ProfessionData = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param recipeID number
function CraftSim.ProfessionData:new(recipeData, recipeID)
	self.recipeData = recipeData
	local crafterUID = recipeData:GetCrafterUID()
	-- if not the crafter get from cache, if not cached take data-less info
	if not recipeData:IsCrafter() then
		self.professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeID)
		if not self.professionInfo then
			self.professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
			self.professionInfoCached = false
		else
			self.professionInfoCached = true
		end
	else
		self.professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)

		-- check if loaded
		if self.professionInfo.profession then
			-- save to db
			CraftSim.DB.CRAFTER:SaveProfessionInfoForRecipe(crafterUID, recipeID, self.professionInfo)
		else
			-- take from cache or take plain
			self.professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeID)

			if not self.professionInfo then
				error("No professionInfo cached for " .. crafterUID .. ": " .. tostring(recipeID))
			end
		end
	end
	self.skillLineID = self.professionInfo.professionID
end

function CraftSim.ProfessionData:UsesGear()
	return self.professionInfo.profession
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
