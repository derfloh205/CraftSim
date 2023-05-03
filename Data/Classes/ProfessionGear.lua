_, CraftSim = ...

---@class CraftSim.ProfessionGear
CraftSim.ProfessionGear = CraftSim.Object:extend()
local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

function CraftSim.ProfessionGear:new()
	---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
end

function CraftSim.ProfessionGear:Equals(professionGear)
	if not self.item and not professionGear.item then
		return true
	elseif not self.item or not professionGear.item then
		return false
	end
	return self.item:GetItemLink() == professionGear.item:GetItemLink()
end

function CraftSim.ProfessionGear:SetItem(itemLink)

	if not itemLink then
		return
	end

    self.item = Item:CreateFromItemLink(itemLink)

    -- parse stats
    local extractedStats = GetItemStats(itemLink)

    if not extractedStats then
        print("Could not extract item stats: " .. tostring(itemLink))
        return
    end

    self.professionStats.inspiration.value = extractedStats.ITEM_MOD_INSPIRATION_SHORT or 0
    self.professionStats.multicraft.value = extractedStats.ITEM_MOD_MULTICRAFT_SHORT or 0
    self.professionStats.resourcefulness.value = extractedStats.ITEM_MOD_RESOURCEFULNESS_SHORT or 0
    self.professionStats.craftingspeed.value = extractedStats.ITEM_MOD_CRAFTING_SPEED_SHORT or 0

	local itemID = self.item:GetItemID()
	if CraftSim.CONST.SPECIAL_TOOL_STATS[itemID] then
		local stats = CraftSim.CONST.SPECIAL_TOOL_STATS[itemID]

        if stats.inspirationBonusSkillPercent then
            self.professionStats.inspiration.extraFactor = stats.inspirationBonusSkillPercent
        end
        -- TODO: check if there any other relevant special stats
	end

	local parsedSkill = 0
	local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)

	local parsedEnchantingStats = {
		inspiration = 0,
		resourcefulness = 0,
		multicraft = 0,
	}
	local equipMatchString = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.EQUIP_MATCH_STRING)
	local enchantedMatchString = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING)
	local inspirationMatchString = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION)
	local resourcefulnessMatchString = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS)
	local multicraftMatchString = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT)
	--print("TooltipData lines:")
	--print(tooltipData.lines, true)
	for _, line in pairs(tooltipData.lines) do
		local lineText = line.leftText -- 10.1 Change
		--for _, arg in pairs(line.args) do
			if lineText and string.find(lineText, equipMatchString) then
				-- here the stringVal looks like "Equip: +6 Blacksmithing Skill"
				parsedSkill = tonumber(string.match(lineText, "(%d+)")) or 0
			end
			if lineText and string.find(lineText, enchantedMatchString) then
				if string.find(lineText, inspirationMatchString) then
					parsedEnchantingStats.inspiration = tonumber(string.match(lineText, "%+(%d+)")) or 0
				elseif string.find(lineText, resourcefulnessMatchString) then
					parsedEnchantingStats.resourcefulness = tonumber(string.match(lineText, "%+(%d+)")) or 0
				elseif string.find(lineText, multicraftMatchString) then
					parsedEnchantingStats.multicraft = tonumber(string.match(lineText, "%+(%d+)")) or 0
				end
			end
		--end
	end

    if parsedSkill > 0 then
        self.professionStats.skill.value = parsedSkill
    end

    if parsedEnchantingStats.inspiration then
        self.professionStats.inspiration.value = self.professionStats.inspiration.value + parsedEnchantingStats.inspiration
    end

    if parsedEnchantingStats.resourcefulness then
        self.professionStats.resourcefulness.value = self.professionStats.resourcefulness.value + parsedEnchantingStats.resourcefulness
    end

    if parsedEnchantingStats.multicraft then
        self.professionStats.multicraft.value = self.professionStats.multicraft.value + parsedEnchantingStats.multicraft
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
		return {"None"}
	else
		return {self.item:GetItemLink() or self.item:GetItemID()}
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