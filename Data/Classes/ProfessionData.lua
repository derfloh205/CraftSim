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
	local crafterUID = recipeData:GetCrafterUID()
	CraftSimRecipeDataCache.professionInfoCache[crafterUID] = CraftSimRecipeDataCache.professionInfoCache[crafterUID] or
		{}
	-- if not the crafter get from cache, if not cached take data-less info
	if not recipeData:IsCrafter() then
		self.professionInfo = CraftSimRecipeDataCache.professionInfoCache[crafterUID][recipeID]
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
			-- cache it
			CraftSimRecipeDataCache.professionInfoCache[crafterUID][recipeID] = self.professionInfo
		else
			-- take from cache or take plain
			self.professionInfo = CraftSimRecipeDataCache.professionInfoCache[crafterUID][recipeID]

			if not self.professionInfo then
				error("No professionInfo cached for " .. crafterUID .. ": " .. tostring(recipeID))
			end
		end
	end
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
