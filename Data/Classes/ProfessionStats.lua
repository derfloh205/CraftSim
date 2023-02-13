_, CraftSim = ...

---@class CraftSim.ProfessionStats
---@field recipeDifficulty CraftSim.ProfessionStat
---@field skill CraftSim.ProfessionStat
---@field inspiration CraftSim.ProfessionStat
---@field multicraft CraftSim.ProfessionStat
---@field resourcefulness CraftSim.ProfessionStat
---@field craftingspeed CraftSim.ProfessionStat
---@field phialExperimentationFactor CraftSim.ProfessionStat
---@field potionExperimentationFactor CraftSim.ProfessionStat

CraftSim.ProfessionStats = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

function CraftSim.ProfessionStats:new()
    self.recipeDifficulty = CraftSim.ProfessionStat("recipedifficulty")
    self.skill = CraftSim.ProfessionStat("skill")
    self.inspiration = CraftSim.ProfessionStat("inspiration", 0, CraftSim.CONST.PERCENT_MODS.INSPIRATION)
    self.multicraft = CraftSim.ProfessionStat("multicraft", 0, CraftSim.CONST.PERCENT_MODS.MULTICRAFT)
    self.resourcefulness = CraftSim.ProfessionStat("resourcefulness", 0, CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS)
    self.craftingspeed = CraftSim.ProfessionStat("craftingspeed", 0, CraftSim.CONST.PERCENT_MODS.CRAFTINGSPEED)

	-- alchemy specific
    self.phialExperimentationFactor = CraftSim.ProfessionStat("phialExperimentationFactor")
    self.potionExperimentationFactor = CraftSim.ProfessionStat("potionExperimentationFactor")
end

---@param recipeData CraftSim.RecipeData
---@param operationInfo CraftingOperationInfo
function CraftSim.ProfessionStats:SetStatsByOperationInfo(recipeData, operationInfo)
	if not operationInfo then
		print("No Operation Info -> No Stats")
		return
	end
    self.skill.value = operationInfo.baseSkill + operationInfo.bonusSkill
    self.recipeDifficulty.value = operationInfo.baseDifficulty
	local bonusStats = operationInfo.bonusStats
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		-- check each stat individually to consider localization
		local inspiration = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION))
		local multicraft = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT))
		local resourcefulness = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS))
		local craftingspeed = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED))
		if statName == craftingspeed then
			self.craftingspeed:SetValueByPercent(statInfo.ratingPct / 100)
		elseif statName == inspiration then
			self.inspiration.value = statInfo.bonusStatValue + 50 -- 50 = 5% Base Inspiration
            local bonusSkill = tonumber((statInfo.ratingDescription:gsub("[^0-9%%]", ""):gsub(".*%%", "")))
            self.inspiration.extraValue = bonusSkill
            recipeData.supportsInspiration = true
		elseif statName == multicraft then
			self.multicraft.value = statInfo.bonusStatValue
			recipeData.supportsMulticraft = true
		elseif statName == resourcefulness then
			self.resourcefulness.value = statInfo.bonusStatValue
			recipeData.supportsResourcefulness = true
		end
	end
end

function CraftSim.ProfessionStats:GetStatList()
	return {self.recipeDifficulty, self.skill, self.inspiration, self.multicraft, self.resourcefulness, self.craftingspeed, self.phialExperimentationFactor, self.potionExperimentationFactor}
end

---@params professionStatsA CraftSim.ProfessionStats
---@params professionStatsB CraftSim.ProfessionStats
function CraftSim.ProfessionStats:subtract(professionStatsB)

	local statsA = self:GetStatList()
	local statsB = professionStatsB:GetStatList()

	for index, professionStatA in pairs(statsA) do
		local professionStatB = statsB[index]
		professionStatA:subtractValue(professionStatB.value)
		professionStatA:subtractFactor(professionStatB.extraFactor)
	end
end

---@params professionStatsA CraftSim.ProfessionStats
---@params professionStatsB CraftSim.ProfessionStats
function CraftSim.ProfessionStats:add(professionStatsB)

	local statsA = self:GetStatList()
	local statsB = professionStatsB:GetStatList()

	for index, professionStatA in pairs(statsA) do
		local professionStatB = statsB[index]
		professionStatA:addValue(professionStatB.value)
		professionStatA:addFactor(professionStatB.extraFactor)
	end
end

function CraftSim.ProfessionStats:Clear()
	local statList = self:GetStatList()

	for _, stat in pairs(statList) do
		stat:Clear()
	end
end

function CraftSim.ProfessionStats:Debug()
	local debugLines = {
		"RecipeDifficulty: " .. self.recipeDifficulty.value,
		"Skill: " .. self.skill.value,
		"Inspiration: " .. self.inspiration.value .. " (".. self.inspiration:GetPercent()*100 .."%) " .. self.inspiration.percentMod,
		"Inspiration Bonus Skill: " .. self.inspiration:GetExtraValueByFactor() .. " (".. self.inspiration.extraValue .." * ".. self.inspiration:GetExtraFactor(true) ..")",
		"Multicraft: " .. self.multicraft.value .. " (".. self.multicraft:GetPercent()*100 .."%)",
		"Multicraft Factor: " .. self.multicraft.extraFactor,
		"Resourcefulness: " .. self.resourcefulness.value .. " (".. self.resourcefulness:GetPercent()*100 .."%)",
		"Resourcefulness Factor: " .. self.resourcefulness.extraFactor,
		"CraftingSpeed: " .. self.craftingspeed.value .. " (".. self.craftingspeed:GetPercent()*100 .."%)",
	}

	if self.phialExperimentationFactor.extraFactor > 0 then
		table.insert(debugLines, "Phial Experimentation: " .. tostring(self.phialExperimentationFactor.extraFactor))
	end
	if self.potionExperimentationFactor.extraFactor > 0 then
		table.insert(debugLines, "Potion Experimentation: " .. tostring(self.potionExperimentationFactor.extraFactor))
	end

	return debugLines
end

function CraftSim.ProfessionStats:Copy()
	local copy = CraftSim.ProfessionStats()
	copy:add(self)

	return copy
end