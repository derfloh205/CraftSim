---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ProfessionData")

---@class CraftSim.ProfessionData.ConstructorOptions
---@field recipeData CraftSim.RecipeData
---@field forceCache? boolean

---@class CraftSim.ProfessionData : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.ProfessionData.ConstructorOptions) : CraftSim.ProfessionData
CraftSim.ProfessionData = CraftSim.CraftSimObject:extend()

---@param options CraftSim.ProfessionData.ConstructorOptions
function CraftSim.ProfessionData:new(options)
	options = options or {}
	self.recipeData = options.recipeData
	local recipeID = self.recipeData.recipeID
	local crafterUID = self.recipeData:GetCrafterUID()
	local forceCache = options.forceCache or false
	-- if not the crafter get from cache, if not cached take data-less info
	if not self.recipeData:IsCrafter() or forceCache then
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
	self.configID = C_ProfSpecs.GetConfigIDForSkillLine(self.skillLineID)
	-- handle Midnight's "Alchemy Research" mini-profession
	if not self.professionInfo.profession and self.professionInfo.professionID == 2950 then
		self.expansionID = CraftSim.CONST.EXPANSION_IDS.MIDNIGHT
	else
		for expansionID, skillLineID in pairs(CraftSim.CONST.TRADESKILLLINEIDS[self.professionInfo.profession]) do
			if skillLineID == self.skillLineID then
				self.expansionID = expansionID
				break
			end
		end
	end
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
