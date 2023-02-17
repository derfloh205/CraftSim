_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@class CraftSim.ProfessionData
---@field professionInfo ProfessionInfo
---@field skillLineID number
---@field isLoaded boolean

CraftSim.ProfessionData = CraftSim.Object:extend()

function CraftSim.ProfessionData:new(recipeID)
    self.professionInfo = C_TradeSkillUI.GetChildProfessionInfo()

	if not self.professionInfo or not self.professionInfo.profession then
		-- try to get from cache
		local professionID = CraftSim.RECIPE_SCAN:GetProfessionIDByRecipeID(recipeID)

		if professionID then
			self.professionInfo = CraftSim.CACHE:GetCacheEntryByVersion(CraftSimProfessionInfoCache, professionID)
			self.skillLineID = CraftSim.CACHE:GetCacheEntryByVersion(CraftSimProfessionSkillLineIDCache, professionID)
		end
	else
		if self.professionInfo.profession then
			self.skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
			CraftSim.CACHE:AddCacheEntryByVersion(CraftSimProfessionInfoCache, self.professionInfo.profession, self.professionInfo)
			CraftSim.CACHE:AddCacheEntryByVersion(CraftSimProfessionSkillLineIDCache, self.professionInfo.profession, self.skillLineID)
		end
	end

    if self.professionInfo and self.professionInfo.profession then
        self.isLoaded = true
    end
end