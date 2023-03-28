_, CraftSim = ...

---@class CraftSim.ProfessionStats
CraftSim.ProfessionStats = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

function CraftSim.ProfessionStats:new()
	---@type CraftSim.ProfessionStat
    self.recipeDifficulty = CraftSim.ProfessionStat("recipedifficulty")
	---@type CraftSim.ProfessionStat
    self.skill = CraftSim.ProfessionStat("skill")
	---@type CraftSim.ProfessionStat
    self.inspiration = CraftSim.ProfessionStat("inspiration", 0, CraftSim.CONST.PERCENT_MODS.INSPIRATION)
	---@type CraftSim.ProfessionStat
    self.multicraft = CraftSim.ProfessionStat("multicraft", 0, CraftSim.CONST.PERCENT_MODS.MULTICRAFT)
	---@type CraftSim.ProfessionStat
    self.resourcefulness = CraftSim.ProfessionStat("resourcefulness", 0, CraftSim.CONST.PERCENT_MODS.RESOURCEFULNESS)
	---@type CraftSim.ProfessionStat
    self.craftingspeed = CraftSim.ProfessionStat("craftingspeed", 0, CraftSim.CONST.PERCENT_MODS.CRAFTINGSPEED)
	
	-- alchemy specific
	---@type CraftSim.ProfessionStat
    self.phialExperimentationFactor = CraftSim.ProfessionStat("phialExperimentationFactor")
	---@type CraftSim.ProfessionStat
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

---@param baseRecipeDifficulty number
---@param maxQuality number
function CraftSim.ProfessionStats:SetInspirationBaseBonusSkill(baseRecipeDifficulty, maxQuality)
	if maxQuality == 3 then
		self.inspiration.extraValue = baseRecipeDifficulty * (1/3)
	elseif maxQuality == 5 then
		self.inspiration.extraValue = baseRecipeDifficulty * (1/6)
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
		professionStatA:subtractExtraValueAfterFactor(professionStatB.extraValueAfterFactor)
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
		professionStatA:addExtraValueAfterFactor(professionStatB.extraValueAfterFactor)
	end
end

function CraftSim.ProfessionStats:Clear()
	local statList = self:GetStatList()

	for _, stat in pairs(statList) do
		stat:Clear()
	end
end

function CraftSim.ProfessionStats:ClearFactors()
	local statList = self:GetStatList()

	for _, stat in pairs(statList) do
		stat.extraFactor = 0
	end
end

function CraftSim.ProfessionStats:Debug()
	local debugLines = {
		"RecipeDifficulty: " .. self.recipeDifficulty.value,
		"Skill: " .. self.skill.value,
		"Inspiration: " .. self.inspiration.value .. " (".. self.inspiration:GetPercent() .."%) " .. self.inspiration.percentMod,
		"Inspiration Bonus Skill: " .. self.inspiration:GetExtraValueByFactor() .. " (".. self.inspiration.extraValue .." * ".. self.inspiration:GetExtraFactor(true) .. "+" .. self.inspiration.extraValueAfterFactor ..")",
		"Multicraft: " .. self.multicraft.value .. " (".. self.multicraft:GetPercent() .."%)",
		"Multicraft Factor: " .. self.multicraft.extraFactor,
		"Resourcefulness: " .. self.resourcefulness.value .. " (".. self.resourcefulness:GetPercent() .."%)",
		"Resourcefulness Factor: " .. self.resourcefulness.extraFactor,
		"CraftingSpeed: " .. self.craftingspeed.value .. " (".. self.craftingspeed:GetPercent() .."%)",
	}

	if self.phialExperimentationFactor.extraFactor > 0 then
		table.insert(debugLines, "Phial Experimentation: " .. tostring(self.phialExperimentationFactor.extraFactor))
	end
	if self.potionExperimentationFactor.extraFactor > 0 then
		table.insert(debugLines, "Potion Experimentation: " .. tostring(self.potionExperimentationFactor.extraFactor))
	end

	return debugLines
end

function CraftSim.ProfessionStats:GetTooltipText()
	local text = 
		((self.skill.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL) .. ": " .. self.skill.value .. "\n")) or "") ..
		((self.inspiration.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION) .. ": " .. self.inspiration.value .. "\n")) or "") ..
		((self.inspiration.extraFactor > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS) .. ": " .. self.inspiration.extraFactor*100 .. "%" .. "\n")) or "") ..
		((self.multicraft.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT) .. ": " .. self.multicraft.value .. "\n")) or "") ..
		((self.multicraft.extraFactor > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS) .. ": " .. self.multicraft.extraFactor*100 .. "%" .. "\n")) or "") ..
		((self.resourcefulness.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS) .. ": " .. self.resourcefulness.value .. "\n")) or "") ..
		((self.resourcefulness.extraFactor > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS) .. ": " .. self.resourcefulness.extraFactor*100 .. "%" .. "\n")) or "") ..
		((self.craftingspeed.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED) .. ": " .. self.craftingspeed.value .. "\n")) or "") ..
		((self.craftingspeed.extraFactor > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS) .. ": " .. self.craftingspeed.extraFactor*100 .. "%" .. "\n")) or "")
	return text
end

function CraftSim.ProfessionStats:Copy()
	local copy = CraftSim.ProfessionStats()
	copy:add(self)

	return copy
end

function CraftSim.ProfessionStats:GetJSON(indent)
	indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("recipeDifficulty", self.recipeDifficulty)
    jb:Add("skill", self.skill)
    jb:Add("inspiration", self.inspiration)
    jb:Add("multicraft", self.multicraft)
    jb:Add("resourcefulness", self.resourcefulness)
    jb:Add("craftingspeed", self.craftingspeed)
    jb:Add("phialExperimentationFactor", self.phialExperimentationFactor)
    jb:Add("potionExperimentationFactor", self.potionExperimentationFactor, true)
    jb:End()
    return jb.json
end