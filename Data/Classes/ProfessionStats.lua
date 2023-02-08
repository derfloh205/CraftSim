_, CraftSim = ...

---@class CraftSim.ProfessionStats
---@field recipeDifficulty CraftSim.ProfessionStat
---@field skill CraftSim.ProfessionStat
---@field inspiration? CraftSim.ProfessionStat
---@field multicraft? CraftSim.ProfessionStat
---@field resourcefulness? CraftSim.ProfessionStat
---@field craftingspeed? CraftSim.ProfessionStat

CraftSim.ProfessionStats = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

---@param recipeID number
function CraftSim.ProfessionStats:new(recipeID)
    -- fetch current stats from operationInfo (with Items, with SpecData)
    local baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}) -- TODO: consider allocationItemGUID

    
    if not baseOperationInfo then
        print("Could not create PlayerStats: No Operation Info found")
		return nil
	end
    
    self.skill = CraftSim.ProfessionStat("skill", baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill)
    self.recipeDifficulty = baseOperationInfo.baseDifficulty
	local bonusStats = baseOperationInfo.bonusStats
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		-- check each stat individually to consider localization
		local inspiration = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION))
		local multicraft = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT))
		local resourcefulness = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS))
		local craftingspeed = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED))
		if statName == craftingspeed then
			self.craftingspeed = CraftSim.ProfessionStat("craftingspeed", statInfo.bonusStatValue, CraftSim.CONST.PERCENT_MODS.CRAFTINGSPEED)
		elseif statName == inspiration then
			self.inspiration = CraftSim.ProfessionStat("inspiration", statInfo.bonusStatValue, CraftSim.CONST.PERCENT_MODS.INSPIRATION)
            local bonusSkill = tonumber((statInfo.ratingDescription:gsub("[^0-9%%]", ""):gsub(".*%%", "")))
            self.inspiration.extraValue = bonusSkill
		elseif statName == multicraft then
			self.multicraft = CraftSim.ProfessionStat("multicraft", statInfo.bonusStatValue, CraftSim.CONST.PERCENT_MODS.MULTICRAFT)
		elseif statName == resourcefulness then
			self.resourcefulness = CraftSim.ProfessionStat("resourcefulness", statInfo.bonusStatValue, CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS)
		end
	end
end