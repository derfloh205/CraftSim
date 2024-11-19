---@class CraftSim
local CraftSim = select(2, ...)

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.ProfessionGear : CraftSim.CraftSimObject
---@overload fun():CraftSim.ProfessionGear
CraftSim.ProfessionGear = CraftSim.CraftSimObject:extend()
local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ProfessionGear")

function CraftSim.ProfessionGear:new()
	---@type CraftSim.ProfessionStats
	self.professionStats = CraftSim.ProfessionStats()
	---@type ItemMixin?
	self.item = nil
end

function CraftSim.ProfessionGear:Equals(professionGear)
	if not self.item and not professionGear.item then
		return true
	elseif not self.item or not professionGear.item then
		return false
	end
	-- remove player guid references before comparing
	local itemLinkA = string.gsub(self.item:GetItemLink(), "Player.-:", "")
	local itemLinkB = string.gsub(professionGear.item:GetItemLink(), "Player.-:", "")
	return itemLinkA == itemLinkB
end

---@param itemLink string?
function CraftSim.ProfessionGear:SetItem(itemLink)
	self.professionStats:Clear()
	if not itemLink then
		self.item = nil
		return
	end

	self.item = Item:CreateFromItemLink(itemLink)

	-- parse stats
	local extractedStats = C_Item.GetItemStats(itemLink)

	if not extractedStats then
		print("Could not extract item stats: " .. tostring(itemLink))
		return
	end

	self.professionStats.multicraft.value = extractedStats.ITEM_MOD_MULTICRAFT_SHORT or 0
	self.professionStats.resourcefulness.value = extractedStats.ITEM_MOD_RESOURCEFULNESS_SHORT or 0
	self.professionStats.craftingspeed.value = extractedStats.ITEM_MOD_CRAFTING_SPEED_SHORT or 0
	self.professionStats.ingenuity.value = extractedStats.ITEM_MOD_INGENUITY_SHORT or 0

	local itemID = self.item:GetItemID()
	if CraftSim.CONST.SPECIAL_TOOL_STATS[itemID] then
		local stats = CraftSim.CONST.SPECIAL_TOOL_STATS[itemID]

		self.professionStats.ingenuity:addExtraValue((stats.ingenuityrefundincrease or 0) / 100)
		self.professionStats.ingenuity:addExtraValue((stats.reduceconcentrationcost or 0) / 100, 2)
	end

	local parsedSkill = 0
	local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)

	local parsedEnchantingStats = {
		resourcefulness = 0,
		multicraft = 0,
	}
	local equipMatchString = L(CraftSim.CONST.TEXT.EQUIP_MATCH_STRING)
	local enchantedMatchString = L(CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING)
	local resourcefulnessMatchString = L(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS)
	local multicraftMatchString = L(CraftSim.CONST.TEXT.STAT_MULTICRAFT)
	local ingenuityMatchString = L(CraftSim.CONST.TEXT.STAT_INGENUITY)
	--print("TooltipData lines:")
	--print(tooltipData.lines, true)
	for _, line in pairs(tooltipData.lines) do
		local lineText = line.leftText -- 10.1 Change
		if lineText and string.find(lineText, equipMatchString) then
			-- here the stringVal looks like "Equip: +6 Blacksmithing Skill"
			-- make sure it tries to only match the parsed equip line once to prevent special effect confusion (runed epic rod tww)
			if parsedSkill == 0 then
				parsedSkill = tonumber(string.match(lineText, "(%d+)")) or 0
			end
		end
		if lineText and string.find(lineText, enchantedMatchString) then
			if string.find(lineText, resourcefulnessMatchString) then
				parsedEnchantingStats.resourcefulness = tonumber(string.match(lineText, "%+(%d+)")) or 0
			elseif string.find(lineText, multicraftMatchString) then
				parsedEnchantingStats.multicraft = tonumber(string.match(lineText, "%+(%d+)")) or 0
			elseif string.find(lineText, ingenuityMatchString) then
				parsedEnchantingStats.ingenuity = tonumber(string.match(lineText, "%+(%d+)")) or 0
			end
		end
	end

	if parsedSkill > 0 then
		self.professionStats.skill.value = parsedSkill
	end

	if parsedEnchantingStats.resourcefulness then
		self.professionStats.resourcefulness.value = self.professionStats.resourcefulness.value +
			parsedEnchantingStats.resourcefulness
	end

	if parsedEnchantingStats.multicraft then
		self.professionStats.multicraft.value = self.professionStats.multicraft.value + parsedEnchantingStats.multicraft
	end

	if parsedEnchantingStats.ingenuity then
		self.professionStats.ingenuity.value = self.professionStats.ingenuity.value + parsedEnchantingStats.ingenuity
	end
end

function CraftSim.ProfessionGear:Copy()
	local copy = CraftSim.ProfessionGear()
	if self.item then
		copy:SetItem(self.item:GetItemLink())
	end

	return copy
end

function CraftSim.ProfessionGear:Debug()
	if not self.item then
		return { "None" }
	else
		return { self.item:GetItemLink() or self.item:GetItemID() }
	end
end

function CraftSim.ProfessionGear:GetJSON(indent)
	indent = indent or 0
	local jb = CraftSim.JSONBuilder(indent)
	jb:Begin()
	jb:Add("itemID", self.item:GetItemID())
	jb:Add("itemString", CraftSim.GUTIL:GetItemStringFromLink(self.item:GetItemLink()))
	jb:Add("professionStats", self.professionStats, true)
	jb:End()
	return jb.json
end

---@class CraftSim.ProfessionGear.Serialized
---@field itemLink string
---@field professionStats CraftSim.ProfessionStats.Serialized

---@return CraftSim.ProfessionGear.Serialized
function CraftSim.ProfessionGear:Serialize()
	---@type CraftSim.ProfessionGear.Serialized
	local serializedData = {
		itemLink = self.item and self.item:GetItemLink(),
		professionStats = self.professionStats and self.professionStats:Serialize(),
	}
	return serializedData
end

---@param serializedData CraftSim.ProfessionGear.Serialized
---@return CraftSim.ProfessionGear
function CraftSim.ProfessionGear:Deserialize(serializedData)
	local professionGear = CraftSim.ProfessionGear()
	professionGear.item = serializedData.itemLink and Item:CreateFromItemLink(serializedData.itemLink)
	professionGear.professionStats = CraftSim.ProfessionStats:Deserialize(serializedData.professionStats)

	return professionGear
end
