---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.ProfessionStats : CraftSim.CraftSimObject
---@overload fun(serialized: boolean?):CraftSim.ProfessionStats
CraftSim.ProfessionStats = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.ProfessionStats")

---@param serialized boolean?
function CraftSim.ProfessionStats:new(serialized)
	if serialized then
		return
	end
	-- TODO: Make configurable to distinquish between expansion's scaling
	local statPercentModTable = CraftSim.CONST.PERCENT_MODS[CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN]
	---@type CraftSim.ProfessionStat
	self.recipeDifficulty = CraftSim.ProfessionStat("recipedifficulty")
	---@type CraftSim.ProfessionStat
	self.skill = CraftSim.ProfessionStat("skill")
	---@type CraftSim.ProfessionStat
	self.multicraft = CraftSim.ProfessionStat("multicraft", 0, statPercentModTable.MULTICRAFT)
	---@type CraftSim.ProfessionStat
	self.resourcefulness = CraftSim.ProfessionStat("resourcefulness", 0, statPercentModTable.RESOURCEFULNESS)
	---@type CraftSim.ProfessionStat
	self.ingenuity = CraftSim.ProfessionStat("ingenuity", 0, statPercentModTable.INGENUITY)
	---@type CraftSim.ProfessionStat
	self.craftingspeed = CraftSim.ProfessionStat("craftingspeed", 0, statPercentModTable.CRAFTINGSPEED)
end

---@param recipeData CraftSim.RecipeData
---@param operationInfo CraftingOperationInfo
function CraftSim.ProfessionStats:SetStatsByOperationInfo(recipeData, operationInfo)
	if not operationInfo then
		print("No Operation Info -> No Stats")
		return
	end
	print("Parse Stats By OperationInfo", false, true)
	self.skill.value = (operationInfo.baseSkill or 0) + (operationInfo.bonusSkill or 0)
	self.recipeDifficulty.value = operationInfo.baseDifficulty or 0
	local bonusStats = operationInfo.bonusStats or {}
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		-- check each stat individually to consider localization
		local multicraft = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT))
		local resourcefulness = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS))
		local ingenuity = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY))
		local craftingspeed = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED))
		print(CraftSim.LOCAL)
		if statName == craftingspeed then
			self.craftingspeed:SetValueByPercent(statInfo.ratingPct / 100)
		elseif statName == multicraft then
			self.multicraft.value = statInfo.bonusStatValue
			recipeData.supportsMulticraft = true
		elseif statName == resourcefulness then
			self.resourcefulness.value = statInfo.bonusStatValue
			recipeData.supportsResourcefulness = true
		elseif statName == ingenuity then
			self.ingenuity.value = statInfo.bonusStatValue
			recipeData.supportsIngenuity = true
		end
	end
end

function CraftSim.ProfessionStats:GetStatList()
	return { self.recipeDifficulty, self.skill, self.multicraft, self.resourcefulness, self.ingenuity, self
		.craftingspeed }
end

---@params professionStatsB CraftSim.ProfessionStats
function CraftSim.ProfessionStats:subtract(professionStatsB)
	local statsA = self:GetStatList()
	local statsB = professionStatsB:GetStatList()

	for index, professionStatA in pairs(statsA) do
		local professionStatB = statsB[index]
		professionStatA:subtractValue(professionStatB.value)
		professionStatA:subtractExtraValues(professionStatB)
	end
end

---@param professionStatsB CraftSim.ProfessionStats
function CraftSim.ProfessionStats:add(professionStatsB)
	local statsA = self:GetStatList()
	local statsB = professionStatsB:GetStatList()

	for index, professionStatA in pairs(statsA) do
		local professionStatB = statsB[index]
		professionStatA:addValue(professionStatB.value)
		professionStatA:addExtraValues(professionStatB)
	end
end

function CraftSim.ProfessionStats:Clear()
	local statList = self:GetStatList()

	for _, stat in pairs(statList) do
		stat:Clear()
	end
end

function CraftSim.ProfessionStats:ClearExtraValues()
	local statList = self:GetStatList()

	for _, stat in pairs(statList) do
		wipe(stat.extraValues)
	end
end

function CraftSim.ProfessionStats:Debug()
	local debugLines = {
		"RecipeDifficulty: " .. self.recipeDifficulty.value,
		"Skill: " .. self.skill.value,
		"Multicraft: " .. self.multicraft.value .. " (" .. self.multicraft:GetPercent() .. "%)",
		"Multicraft Factor: " .. (self.multicraft:GetExtraValue()),
		"Resourcefulness: " .. self.resourcefulness.value .. " (" .. self.resourcefulness:GetPercent() .. "%)",
		"Resourcefulness Factor: " .. (self.resourcefulness:GetExtraValue()),
		"Ingenuity: " .. self.ingenuity.value .. " (" .. self.ingenuity:GetPercent() .. "%)",
		"CraftingSpeed: " .. self.craftingspeed.value .. " (" .. self.craftingspeed:GetPercent() .. "%)",
	}

	return debugLines
end

---@param maxProfessionStats CraftSim.ProfessionStats
function CraftSim.ProfessionStats:GetTooltipText(maxProfessionStats)
	local r = math.floor
	if not maxProfessionStats then
		local text =
			((self.skill.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL) .. ": " .. r(self.skill.value) .. "\n")) or "") ..
			((self.multicraft.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT) .. ": " .. r(self.multicraft.value) .. "\n")) or "") ..
			((self.multicraft:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS) .. ": " .. r(self.multicraft:GetExtraValue() * 100) .. "%" .. "\n")) or "") ..
			((self.resourcefulness.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS) .. ": " .. r(self.resourcefulness.value) .. "\n")) or "") ..
			((self.resourcefulness:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS) .. ": " .. r(self.resourcefulness:GetExtraValue() * 100) .. "%" .. "\n")) or "") ..
			((self.ingenuity.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY) .. ": " .. r(self.ingenuity.value) .. "\n")) or "") ..
			((self.ingenuity:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS) .. ": " .. self.ingenuity:GetExtraValue() * 100 .. "%" .. "\n")) or "") ..
			((self.ingenuity:GetExtraValue(2) > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION) .. ": " .. self.ingenuity:GetExtraValue(2) * 100 .. "%" .. "\n")) or "") ..
			((self.craftingspeed.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED) .. ": " .. r(self.craftingspeed.value) .. "\n")) or "") ..
			((self.craftingspeed:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS) .. ": " .. r(self.craftingspeed:GetExtraValue() * 100) .. "%" .. "\n")) or "")
		return text
	end

	-- for specializationData help tooltip
	local f = CraftSim.GUTIL:GetFormatter()
	-- use the maxProfessionStats as reference to show the line at all
	local text =
		((maxProfessionStats.skill.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL) .. ": " .. r(self.skill.value) .. " / " .. f.grey(r(maxProfessionStats.skill.value)) .. "\n")) or "") ..
		((maxProfessionStats.multicraft.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT) .. ": " .. r(self.multicraft.value) .. " / " .. f.grey(r(maxProfessionStats.multicraft.value)) .. "\n")) or "") ..
		((maxProfessionStats.multicraft:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS) .. ": " .. r(self.multicraft:GetExtraValue() * 100) .. "%" .. " / " .. f.grey(r(maxProfessionStats.multicraft:GetExtraValue() * 100) .. "%") .. "\n")) or "") ..
		((maxProfessionStats.resourcefulness.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS) .. ": " .. r(self.resourcefulness.value) .. " / " .. f.grey(r(maxProfessionStats.resourcefulness.value)) .. "\n")) or "") ..
		((maxProfessionStats.resourcefulness:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS) .. ": " .. r(self.resourcefulness:GetExtraValue() * 100) .. "%" .. " / " .. f.grey(r(maxProfessionStats.resourcefulness:GetExtraValue() * 100) .. "%") .. "\n")) or "") ..
		((maxProfessionStats.ingenuity.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY) .. ": " .. r(self.ingenuity.value) .. " / " .. f.grey(r(maxProfessionStats.ingenuity.value)) .. "\n")) or "") ..
		((maxProfessionStats.ingenuity:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS) .. ": " .. self.ingenuity:GetExtraValue() * 100 .. "%" .. " / " .. f.grey(maxProfessionStats.ingenuity:GetExtraValue() * 100 .. "%") .. "\n")) or "") ..
		((maxProfessionStats.ingenuity:GetExtraValue(2) > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION) .. ": " .. self.ingenuity:GetExtraValue(2) * 100 .. "%" .. " / " .. f.grey(maxProfessionStats.ingenuity:GetExtraValue(2) * 100 .. "%") .. "\n")) or "") ..
		((maxProfessionStats.craftingspeed.value > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED) .. ": " .. r(self.craftingspeed.value) .. " / " .. f.grey(r(maxProfessionStats.craftingspeed.value)) .. "\n")) or "") ..
		((maxProfessionStats.craftingspeed:GetExtraValue() > 0 and (CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS) .. ": " .. r(self.craftingspeed:GetExtraValue() * 100) .. "%" .. " / " .. f.grey(r(maxProfessionStats.craftingspeed:GetExtraValue() * 100) .. "%") .. "\n")) or "")

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
	jb:Add("multicraft", self.multicraft)
	jb:Add("resourcefulness", self.resourcefulness)
	jb:Add("ingenuity", self.ingenuity)
	jb:Add("craftingspeed", self.craftingspeed)
	jb:End()
	return jb.json
end

---@class CraftSim.ProfessionStats.Serialized
---@field recipeDifficulty CraftSim.ProfessionStat.Serialized
---@field skill CraftSim.ProfessionStat.Serialized
---@field multicraft CraftSim.ProfessionStat.Serialized
---@field resourcefulness CraftSim.ProfessionStat.Serialized
---@field ingenuity CraftSim.ProfessionStat.Serialized
---@field craftingspeed CraftSim.ProfessionStat.Serialized

---@return CraftSim.ProfessionStats.Serialized
function CraftSim.ProfessionStats:Serialize()
	---@type CraftSim.ProfessionStats.Serialized
	local serializedData = {
		recipeDifficulty = self.recipeDifficulty:Serialize(),
		skill = self.skill:Serialize(),
		multicraft = self.multicraft:Serialize(),
		resourcefulness = self.resourcefulness:Serialize(),
		ingenuity = self.ingenuity:Serialize(),
		craftingspeed = self.craftingspeed:Serialize(),
	}
	return serializedData
end

---@param serializedData CraftSim.ProfessionStats.Serialized
---@return CraftSim.ProfessionStats
function CraftSim.ProfessionStats:Deserialize(serializedData)
	local professionStats = CraftSim.ProfessionStats(true)
	professionStats.recipeDifficulty = CraftSim.ProfessionStat:Deserialize(serializedData.recipeDifficulty)
	professionStats.skill = CraftSim.ProfessionStat:Deserialize(serializedData.skill)
	professionStats.multicraft = CraftSim.ProfessionStat:Deserialize(serializedData.multicraft)
	professionStats.resourcefulness = CraftSim.ProfessionStat:Deserialize(serializedData.resourcefulness)
	professionStats.ingenuity = CraftSim.ProfessionStat:Deserialize(serializedData.ingenuity)
	professionStats.craftingspeed = CraftSim.ProfessionStat:Deserialize(serializedData.craftingspeed)
	return professionStats
end
