CraftSimDATAEXPORT = {}

CraftSimTooltipData = CraftSimTooltipData or {}
CraftSimItemCache = CraftSimItemCache or {}

LibCompress = LibStub:GetLibrary("LibCompress")

-- DEPRICATED
function CraftSimDATAEXPORT:getExportString()
	local exportData = CraftSimDATAEXPORT:exportRecipeData()
	-- now digest into an export string
	if exportData == nil then
		return "Current Recipe Type not supported"
	end
	local exportString = ""
	for property, value in pairs(exportData) do
		exportString = exportString .. tostring(property) .. "," .. tostring(value) .. "\n"
	end
	return exportString
end

function CraftSimDATAEXPORT:GetDifferentQualityLinksByLink(itemLink)
	-- TODO: is this consistent enough?
	local linksByQuality = {}
	local itemString = select(3, strfind(itemLink, "|H(.+)|h%["))
	--print("itemstring: " .. itemString)
	for qualityID = 4, 8, 1 do
		local parts = { string.split(":", itemString) }
		
		parts[#parts-5] = qualityID
		local newString = table.concat(parts, ":")
		--print("item string q" .. qualityID .. " " .. tostring(newString))
		local _, link = GetItemInfo(newString)
		--print("link: " .. link)
		table.insert(linksByQuality, link)
	 end
	 return linksByQuality
end

function CraftSimDATAEXPORT:AddSupportedRecipeStats(recipeData, operationInfo)
	-- if stat not available -> not supported
	local bonusStats = operationInfo.bonusStats
	-- crafting speed is always supported!
	recipeData.stats = {craftingspeed = {}}
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		if statName == "crafting speed" then
			statName = "craftingspeed"
		end
		if recipeData.stats[statName] == nil then
			recipeData.stats[statName] = {}
		end
	end
end

function CraftSimDATAEXPORT:handlePlayerProfessionStatsV1(recipeData, operationInfo)
	local bonusStats = operationInfo.bonusStats
	recipeData.stats = {}
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		if statName == "crafting speed" then
			statName = "craftingspeed"
		end
		if recipeData.stats[statName] == nil then
			recipeData.stats[statName] = {}
		end
		recipeData.stats[statName].value = statInfo.bonusStatValue
		recipeData.stats[statName].description = statInfo.ratingDescription
		recipeData.stats[statName].percent = statInfo.ratingPct
		if statName == 'inspiration' then
			-- matches a row of numbers coming after the % character and any characters in between plus a space, should hopefully match in every localization...
			local _, _, bonusSkill = string.find(statInfo.ratingDescription, "%%.* (%d+)") 
			recipeData.stats[statName].bonusskill = bonusSkill
			--print("inspirationbonusskill: " .. tostring(bonusSkill))
		end
	end

	-- baseSkill is like the base of the players skill and bonusSkill is what is added through reagents
	recipeData.stats.skill = operationInfo.baseSkill + operationInfo.bonusSkill
	recipeData.stats.baseSkill = operationInfo.baseSkill -- Needed for reagent optimization

	-- crafting speed is always relevant but it is not shown in details when it is zero
	if not recipeData.stats.craftingspeed then
		recipeData.stats.craftingspeed = {
			value = 0,
			percent = 0,
			description = ""
		}
	end
end

function CraftSimDATAEXPORT:GetStatsFromBuffs(buffData)
	-- TODO: Implement
    return {	
        inspiration = 0,
        inspirationBonusSkillPercent = 0,
        multicraft = 0,
        multicraftBonusItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessBonusItemsFactor = 1,
        craftingspeed = 0,
		craftingspeedBonusFactor = 1,
        skill = 0
    }
end

function CraftSimDATAEXPORT:exportBuffData(recipeData)
	return { -- TODO: information about relevant stats like crafting speed / inspiration incense / inspiration portrait (?)

	}
end

function CraftSimDATAEXPORT:exportSpecNodeData(recipeData)
	local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(skillLineID)

	local nodes = CraftSimCONST.NODES()[recipeData.professionID] or {}

	local specNodeData = {}
	for _, currentNode in pairs(nodes) do
		--print("checking node -> " .. currentNode.name)
		local nodeInfo = C_Traits.GetNodeInfo(configID, currentNode.nodeID)
		if nodeInfo then
			specNodeData[currentNode.nodeID] = {
				nodeID = currentNode.nodeID,
				name = currentNode.name,
				activeRank = nodeInfo.activeRank
				-- parent nodes? and other stuff..
			}
		end
	end
	return specNodeData
end

function CraftSimDATAEXPORT:GetStatsFromReagents(recipeData)
	-- TODO: export optional and finishing reagents and get their modifiers
	return {	
        inspiration = 0,
        inspirationBonusSkillFactor = 1,
        multicraft = 0,
        multicraftBonusItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessBonusItemsFactor = 1,
        craftingspeed = 0,
		craftingspeedBonusFactor = 1,
        skill = 0
    }
end

function CraftSimDATAEXPORT:handlePlayerProfessionStatsV2(recipeData)
	print("player stats v2")
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
	local professionGearStats = CraftSimDATAEXPORT:GetCurrentProfessionItemStats()

	local relevantNodes = CraftSimSPECDATA.RELEVANT_NODES()[recipeData.professionID]

	local specNodeStats = CraftSimSPECDATA:GetStatsFromSpecNodeData(recipeData, relevantNodes)
	local buffStats = CraftSimDATAEXPORT:GetStatsFromBuffs(recipeData.buffData)
	local reagentStats = CraftSimDATAEXPORT:GetStatsFromReagents(recipeData)

	print("specnodestats: ")
	CraftSimUTIL:PrintTable(specNodeStats)

	-- skill
	local baseSkill = professionInfo.skillLevel
	local racialSkill = CraftSimDATAEXPORT:GetRacialProfessionSkillBonus(recipeData.professionID)
	local itemSkill = professionGearStats.skill
	local specNodeSkill = specNodeStats.skill
	local reagentSkill = reagentStats.skill

	recipeData.stats.skill = baseSkill + racialSkill + itemSkill + specNodeSkill + reagentSkill

	-- inspiration
	if recipeData.stats.inspiration then
		local basePercent = 5 -- everyone has this as base 
		local baseInspirationBonusSkill = 0
		local specNodeBonus = specNodeStats.inspiration
		local itemBonus = professionGearStats.inspiration
		local itemBonusSkillFactor = 1 + (professionGearStats.inspirationBonusSkillPercent / 100) -- 15% -> 1.15
		local specNodeBonusSkillFactor = specNodeStats.inspirationBonusSkillFactor
		-- TODO: consider stable fluidic draconium 
		local finishingReagentsBonusSkillFactor = reagentStats.inspirationBonusSkillFactor

		if not recipeData.result.isNoQuality then
			if recipeData.maxQuality == 5 then
				baseInspirationBonusSkill = recipeData.baseDifficulty * (1/6)
			else -- its 3
				baseInspirationBonusSkill = recipeData.baseDifficulty * (1/3)
			end
		end

		recipeData.stats.inspiration.value = buffStats.inspiration + itemBonus + specNodeBonus
		recipeData.stats.inspiration.percent = basePercent + CraftSimUTIL:GetInspirationPercentByStat(recipeData.stats.inspiration.value) * 100
		recipeData.stats.inspiration.bonusskill = baseInspirationBonusSkill * specNodeBonusSkillFactor * itemBonusSkillFactor * finishingReagentsBonusSkillFactor
	end

	-- multicraft
	if recipeData.stats.multicraft then
		-- TODO BUFFS?
		local specNodeBonus = specNodeStats.multicraft
		local itemBonus = professionGearStats.multicraft
		local specNodeBonusItemsFactor = specNodeStats.multicraftBonusItemsFactor
		-- TODO: consider ??? I think in cooking maybe
		local finishingReagentsBonusItemsFactor = reagentStats.multicraftBonusItemsFactor
		recipeData.stats.multicraft.value = buffStats.multicraft + itemBonus + specNodeBonus
		recipeData.stats.multicraft.percent = CraftSimUTIL:GetMulticraftPercentByStat(recipeData.stats.multicraft.value) * 100
		recipeData.stats.multicraft.bonusItemsFactor = specNodeBonusItemsFactor * finishingReagentsBonusItemsFactor
	end

	-- resourcefulness
	if recipeData.stats.resourcefulness then
		-- TODO BUFFS?
		local specNodeBonus = specNodeStats.resourcefulness
		local itemBonus = professionGearStats.resourcefulness
		local specNodeBonusItemsFactor = specNodeStats.resourcefulnessBonusItemsFactor
		-- TODO: consider ??? Dont know if that even exists
		local finishingReagentsBonusItemsFactor = reagentStats.resourcefulnessBonusItemsFactor

		recipeData.stats.resourcefulness.value = buffStats.resourcefulness + itemBonus + specNodeBonus
		recipeData.stats.resourcefulness.percent = CraftSimUTIL:GetResourcefulnessPercentByStat(recipeData.stats.resourcefulness.value) * 100
		recipeData.stats.resourcefulness.bonusItemsFactor = specNodeBonusItemsFactor * finishingReagentsBonusItemsFactor
	end

	-- craftingspeed
	if recipeData.stats.craftingspeed then
		-- TODO BUFFS?
		local specNodeBonus = specNodeStats.craftingspeed
		local itemBonus = professionGearStats.craftingspeed
		local specNodeBonusItemsFactor = specNodeStats.craftingspeedBonusFactor
		-- TODO: consider ??? Dont know if that even exists
		local finishingReagentsBonusFactor = reagentStats.craftingspeedBonusFactor

		recipeData.stats.craftingspeed.value = buffStats.craftingspeed + itemBonus + specNodeBonus
		recipeData.stats.craftingspeed.percent = CraftSimUTIL:GetCraftingSpeedPercentByStat(recipeData.stats.craftingspeed.value) * 100
	end

	-- debug
	-- print("total skill: " .. tostring(recipeData.stats.skill))
	-- print("total inspiration: ")
	-- CraftSimUTIL:PrintTable(recipeData.stats.inspiration or {})
	-- print("total multicraft: ")
	-- CraftSimUTIL:PrintTable(recipeData.stats.multicraft or {})
	-- print("total resourcefulness: ")
	-- CraftSimUTIL:PrintTable(recipeData.stats.resourcefulness or {})
end

function CraftSimDATAEXPORT:handlePlayerProfessionStats(recipeData, operationInfo)
	local implemented = tContains(CraftSimCONST.IMPLEMENTED_SKILL_BUILD_UP(), recipeData.professionID)

	if not implemented then
		CraftSimDATAEXPORT:handlePlayerProfessionStatsV1(recipeData, operationInfo)
	else
		CraftSimDATAEXPORT:handlePlayerProfessionStatsV2(recipeData)
	end
end

function CraftSimDATAEXPORT:exportRecipeData()
	local recipeData = {}

	--local professionInfo = ProfessionsFrame.professionInfo
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()
	local expansionName = professionInfo.expansionName
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm

	recipeData.profession = professionInfo.parentProfessionName
	recipeData.professionID = professionInfo.profession
	local recipeInfo = CraftSimMAIN.currentRecipeInfo --or schematicForm:GetRecipeInfo() -- should always be the first

	local recipeType = CraftSimUTIL:GetRecipeType(recipeInfo)

	recipeData.recipeID = recipeInfo.recipeID
	recipeData.recipeType = recipeType
	
	local operationInfo = schematicForm:GetRecipeOperationInfo()
	
    if operationInfo == nil or recipeType == CraftSimCONST.RECIPE_TYPES.GATHERING then
        return nil
    end
	recipeData.expectedQuality = operationInfo.craftingQuality


	local currentTransaction = schematicForm.transaction or schematicForm:GetTransaction()
	
	recipeData.currentTransaction = currentTransaction
	recipeData.reagents = {}

	local salvageAllocation = currentTransaction:GetSalvageAllocation()

	if salvageAllocation then
		recipeData.salvageReagent = {
			name = salvageAllocation:GetItemName(),
			itemLink = salvageAllocation:GetItemLink(),
			itemID = salvageAllocation:GetItemID(),
			requiredQuantity = schematicForm.salvageSlot.quantityRequired
		}
	end

	local hasReagentsWithQuality = false
	local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false)
	--print("export: reagentSlotSchematics: " .. #schematicInfo.reagentSlotSchematics)
	for slotIndex, currentSlot in pairs(schematicInfo.reagentSlotSchematics) do
		local reagents = currentSlot.reagents
		local reagentType = currentSlot.reagentType
		local reagentName = CraftSimDATAEXPORT:GetReagentNameFromReagentData(reagents[1].itemID)
		-- for now only consider the required reagents
		if reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED then --and currentSelected == currentSlot.quantityRequired then
			local hasMoreThanOneQuality = reagents[2] ~= nil

			if hasMoreThanOneQuality then
				hasReagentsWithQuality = true
			end

			recipeData.reagents[slotIndex] = {
				name = reagentName,
				requiredQuantity = currentSlot.quantityRequired,
				differentQualities = hasMoreThanOneQuality,
				reagentType = currentSlot.reagentType
			}
			
			local slotAllocations = currentTransaction:GetAllocations(slotIndex)
			local currentSelected = slotAllocations:Accumulate()
			recipeData.reagents[slotIndex].itemsInfo = {}

			for i, reagent in pairs(reagents) do
				local reagentAllocation = slotAllocations:FindAllocationByReagent(reagent)
				local allocations = 0
				if reagentAllocation ~= nil then
					allocations = reagentAllocation:GetQuantity()
				end
				local itemInfo = {
					itemID = reagent.itemID,
					allocations = allocations
				}
				table.insert(recipeData.reagents[slotIndex].itemsInfo, itemInfo)
			end
		else
			--print("reagent not required: " .. tostring(reagentName))
			-- TODO: export optional reagents
		end
	end
	recipeData.hasReagentsWithQuality = hasReagentsWithQuality

	recipeData.maxQuality = recipeInfo.maxQuality

	recipeData.baseItemAmount = (schematicInfo.quantityMin + schematicInfo.quantityMax) / 2
	recipeData.hasSingleItemOutput = recipeInfo.hasSingleItemOutput


	recipeData.recipeDifficulty = operationInfo.baseDifficulty + operationInfo.bonusDifficulty
	recipeData.baseDifficulty = operationInfo.baseDifficulty

	recipeData.result = {}

	local allocationItemGUID = currentTransaction:GetAllocationItemGUID()
	local craftingReagentInfoTbl = currentTransaction:CreateCraftingReagentInfoTbl()
	local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, craftingReagentInfoTbl, allocationItemGUID)

	if recipeType == CraftSimCONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSimCONST.RECIPE_TYPES.SINGLE then
		-- recipe is anything that results in 1-5 different itemids with quality
		local qualityItemIDs = CopyTable(recipeInfo.qualityItemIDs)
		if qualityItemIDs[1] > qualityItemIDs[3] then
			--print("itemIDs for qualities not in expected order, reordering..: " .. outputItemData.hyperlink)
			table.sort(qualityItemIDs)
			--print(unpack(qualityItemIDs))
		end
		recipeData.result.itemIDs = {
			qualityItemIDs[1],
			qualityItemIDs[2],
			qualityItemIDs[3],
			qualityItemIDs[4],
			qualityItemIDs[5]}
	elseif recipeType == CraftSimCONST.RECIPE_TYPES.ENCHANT then
		if not CraftSimENCHANT_DATA[recipeData.recipeID] then
			error("CraftSim: Enchant Recipe Missing in Data: " .. recipeData.recipeID .. " Please contact the developer (discord: genju#4210)")
		end
		recipeData.result.itemIDs = {
			CraftSimENCHANT_DATA[recipeData.recipeID].q1,
			CraftSimENCHANT_DATA[recipeData.recipeID].q2,
			CraftSimENCHANT_DATA[recipeData.recipeID].q3}
	elseif recipeType == CraftSimCONST.RECIPE_TYPES.GEAR or recipeType == CraftSimCONST.RECIPE_TYPES.SOULBOUND_GEAR then
		recipeData.result.itemID = schematicInfo.outputItemID
		
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, craftingReagentInfoTbl, allocationItemGUID)
		recipeData.result.hyperlink = outputItemData.hyperlink
		local baseIlvl = recipeInfo.itemLevel
		recipeData.result.itemQualityLinks = CraftSimDATAEXPORT:GetDifferentQualityLinksByLink(outputItemData.hyperlink)
		recipeData.result.baseILvL = baseIlvl
	elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE then
		-- Probably something like transmuting air reagent that creates non equip stuff without qualities
		recipeData.result.itemID = CraftSimUTIL:GetItemIDByLink(recipeInfo.hyperlink)
		recipeData.result.isNoQuality = true		
	elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
		recipeData.result.itemID = CraftSimUTIL:GetItemIDByLink(recipeInfo.hyperlink)
		recipeData.result.isNoQuality = true	
	elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_ITEM then
		-- nothing cause there is no result
	else
		print("recipeType not covered in export: " .. tostring(recipeType))
	end

	-- I need both to identify the spec boni
	recipeData.categoryID = recipeInfo.categoryID
	local itemData = CraftSimDATAEXPORT:GetItemFromCacheByItemID(recipeData.result.itemID or recipeData.result.itemIDs[1]) or {}
	recipeData.subtypeID = itemData.subclassID or nil

	CraftSimDATAEXPORT:AddSupportedRecipeStats(recipeData, operationInfo)

	--recipeData.extraItemFactors = CraftSimSPECDATA:GetSpecExtraItemFactorsByRecipeData(recipeData)

	recipeData.buffData = CraftSimDATAEXPORT:exportBuffData()
	recipeData.specNodeData = CraftSimDATAEXPORT:exportSpecNodeData(recipeData)

	CraftSimDATAEXPORT:handlePlayerProfessionStats(recipeData, operationInfo)

	
	CraftSimMAIN.currentRecipeData = recipeData
	return recipeData
end

function CraftSimDATAEXPORT:GetProfessionGearStatsByLink(itemLink)
	local extractedStats = GetItemStats(itemLink)
	local stats = {}

	for statKey, value in pairs(extractedStats) do
		if CraftSimCONST.STAT_MAP[statKey] ~= nil then
			stats[CraftSimCONST.STAT_MAP[statKey]] = value
		end
	end

	local parsedSkill = 0
	local parsedInspirationSkillBonusPercent = 0
	local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
	-- For now there is only inspiration and resourcefulness as enchant?
	local parsedEnchantingStats = {
		inspiration = 0,
		resourcefulness = 0
	}
	for lineNum, line in pairs(tooltipData.lines) do
		for argNum, arg in pairs(line.args) do
			if arg.stringVal and string.find(arg.stringVal, "Equip:") then -- TODO: Localization differences? 
				-- here the stringVal looks like "Equip: +6 Blacksmithing Skill"
				parsedSkill = tonumber(string.match(arg.stringVal, "%+(%d+)"))
			end
			if arg.stringVal and string.find(arg.stringVal, "increases the Skill provided when inspired by") then -- TODO: Localization?
				--
				parsedInspirationSkillBonusPercent = tonumber(string.match(arg.stringVal, "by (%d+)%%"))
			end
			if arg.stringVal and string.find(arg.stringVal, "Enchanted:") then
				if string.find(arg.stringVal, "Inspiration") then
					parsedEnchantingStats.inspiration = tonumber(string.match(arg.stringVal, "%+(%d+)"))
				elseif string.find(arg.stringVal, "Resourcefulness") then
					parsedEnchantingStats.resourcefulness = tonumber(string.match(arg.stringVal, "%+(%d+)"))
				end
			end
		end
	end
	stats.inspiration = (stats.inspiration or 0) + parsedEnchantingStats.inspiration
	stats.resourcefulness = (stats.resourcefulness or 0) + parsedEnchantingStats.resourcefulness

	stats.skill = parsedSkill
	stats.inspirationBonusSkillPercent = parsedInspirationSkillBonusPercent

	return stats
end

function CraftSimDATAEXPORT:GetCurrentProfessionItemStats()
	local stats = {
		inspiration = 0,
		inspirationBonusSkillPercent = 0,
		multicraft = 0,
		resourcefulness = 0,
		craftingspeed = 0,
		skill = 0
	}
	local currentProfessionSlots = CraftSimFRAME:GetProfessionEquipSlots()

	for _, slotName in pairs(currentProfessionSlots) do
		local slotID = GetInventorySlotInfo(slotName)
		local itemLink = GetInventoryItemLink("player", slotID)
		if itemLink ~= nil then
			local itemStats = CraftSimDATAEXPORT:GetProfessionGearStatsByLink(itemLink)
			if itemStats.inspiration then
				stats.inspiration = stats.inspiration + itemStats.inspiration
			end
			if itemStats.multicraft then
				stats.multicraft = stats.multicraft + itemStats.multicraft
			end
			if itemStats.resourcefulness then
				stats.resourcefulness = stats.resourcefulness + itemStats.resourcefulness
			end
			if itemStats.craftingspeed then
				stats.craftingspeed = stats.craftingspeed + itemStats.craftingspeed
			end
			if itemStats.skill then
				stats.skill = stats.skill + itemStats.skill
			end

			if itemStats.inspirationBonusSkillPercent then
				-- "additive or multiplicative? or dont care cause multiple items cannot have this bonus?"
				stats.inspirationBonusSkillPercent = stats.inspirationBonusSkillPercent + itemStats.inspirationBonusSkillPercent 
			end
		end
	end

	return stats
end

function CraftSimDATAEXPORT:GetEquippedProfessionGear()
	local professionGear = {}
	local currentProfessionSlots = CraftSimFRAME:GetProfessionEquipSlots()
	
	for _, slotName in pairs(currentProfessionSlots) do
		--print("checking slot: " .. slotName)
		local slotID = GetInventorySlotInfo(slotName)
		local itemLink = GetInventoryItemLink("player", slotID)
		if itemLink ~= nil then
			local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink) 
			local itemStats = CraftSimDATAEXPORT:GetProfessionGearStatsByLink(itemLink)
			--print("e ->: " .. itemLink)
			table.insert(professionGear, {
				itemID = CraftSimUTIL:GetItemIDByLink(itemLink),
				itemLink = itemLink,
				itemStats = itemStats,
				equipSlot = equipSlot,
				isEmptySlot = false
			})
		end
	end
	return professionGear
end

function CraftSimDATAEXPORT:GetProfessionGearFromInventory()
	local currentProfession = ProfessionsFrame.professionInfo.parentProfessionName
	local professionGear = {}

	for bag=BANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		for slot=1,C_Container.GetContainerNumSlots(bag) do
			local itemLink = C_Container.GetContainerItemLink(bag, slot)
			if itemLink ~= nil then
				local _, _, _, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink) 
				if itemSubType == currentProfession then
					--print("i -> " .. tostring(itemLink))
					local itemStats = CraftSimDATAEXPORT:GetProfessionGearStatsByLink(itemLink)
					table.insert(professionGear, {
						itemID = CraftSimUTIL:GetItemIDByLink(itemLink),
						itemLink = itemLink,
						itemStats = itemStats,
						equipSlot = equipSlot,
						isEmptySlot = false
					})
				end
			end
		end
	end
	return professionGear
end

function CraftSimDATAEXPORT:GetReagentNameFromReagentData(itemID)
	local reagentData = CraftSimREAGENTWEIGHTS[itemID]

	if reagentData then
		return reagentData.name
	else
		local name = GetItemInfo(itemID)

		if name then
			return name
		else
			return "Unknown"
		end
	end
end

function CraftSimDATAEXPORT:ExportTooltipData(recipeData)
	local crafter = GetUnitName("player", showServerName)

	local tooltipData = {
		expectedQuality = recipeData.expectedQuality,
		recipeType = recipeData.recipeType,
		baseItemAmount = recipeData.baseItemAmount,
		reagents = recipeData.reagents,
		result = recipeData.result,
		crafter = crafter
	}

	-- needed data: recipetype, reagents, and results, and the source character
	return tooltipData
end

function CraftSimDATAEXPORT:UpdateTooltipData(recipeData)
	local data = CraftSimDATAEXPORT:ExportTooltipData(recipeData)
    if recipeData.recipeType == CraftSimCONST.RECIPE_TYPES.GEAR or recipeData.recipeType == CraftSimCONST.RECIPE_TYPES.SOULBOUND_GEAR then
        -- map itemlinks to data
		CraftSimTooltipData[recipeData.result.hyperlink] = data
	elseif recipeData.recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeData.recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
		CraftSimTooltipData[recipeData.result.itemID] = data
	elseif recipeData.recipeType ~= CraftSimCONST.RECIPE_TYPES.GATHERING and recipeData.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_CRAFT_OPERATION and
	 recipeData.recipeType ~= CraftSimCONST.RECIPE_TYPES.RECRAFT and recipeData.recipeType ~= CraftSimCONST.RECIPE_TYPES.NO_ITEM then
        -- map itemids to data
        -- the item id has a certain quality, so remember the itemid and the current crafting costs as "last crafting costs"
        CraftSimTooltipData[recipeData.result.itemIDs[recipeData.expectedQuality]] = data
    end
end

function CraftSimDATAEXPORT:GetItemFromCacheByItemID(itemID)
	if CraftSimItemCache[itemID] then
		return CraftSimItemCache[itemID]
	else
		local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
		itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
		expacID, setID, isCraftingReagent = GetItemInfo(itemID) 

		local itemData = {
			name = itemName,
			link = itemLink,
			quality = itemQuality,
			itemLevel = itemLevel,
			itemMinLevel = itemMinLevel,
			itemType = itemType,
			itemSubType = itemSubType,
			itemStackCount = itemStackCount,
			itemEquipLoc = itemEquipLoc,
			itemTexture = itemTexture,
			sellPrice = sellPrice,
			classID = classID,
			subclassID = subclassID,
			bindType = bindType,
			expacID = expacID,
			setID = setID,
			isCraftingReagent = isCraftingReagent
		}

		if not itemName then
			itemData.name = "Fetching Item.."
			local item = Item:CreateFromItemID(itemID)

			item:ContinueOnItemLoad(function()
				local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
				itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
				expacID, setID, isCraftingReagent = GetItemInfo(itemID) 

				local itemData = {
					name = itemName,
					link = itemLink,
					quality = itemQuality,
					itemLevel = itemLevel,
					itemMinLevel = itemMinLevel,
					itemType = itemType,
					itemSubType = itemSubType,
					itemStackCount = itemStackCount,
					itemEquipLoc = itemEquipLoc,
					itemTexture = itemTexture,
					sellPrice = sellPrice,
					classID = classID,
					subclassID = subclassID,
					bindType = bindType,
					expacID = expacID,
					setID = setID,
					isCraftingReagent = isCraftingReagent
				}

				CraftSimItemCache[itemID] = itemData
			end)
		end

		return itemData
	end
end

function CraftSimDATAEXPORT:GetRacialProfessionSkillBonus(professionID)
	local _, playerRace = UnitRace("player")
	local data = {
		Gnome = {
			professionIDs = {Enum.Profession.Engineering},
			professionBonus = 5,
		},
		Draenei = {
			professionIDs = {Enum.Profession.Jewelcrafting},
			professionBonus = 5,
		},
		Worgen = {
			professionIDs = {Enum.Profession.Skinning},
			professionBonus = 5,
		},
		LightforgedDraenei = {
			professionIDs = {Enum.Profession.Blacksmithing},
			professionBonus = 5,
		},
		DarkIronDwarf = {
			professionIDs = {Enum.Profession.Blacksmithing},
			professionBonus = 5,
		},
		KulTiran = {
			professionIDs = nil, -- everything
			professionBonus = 2,
		},
		Pandaren = {
			professionIDs = {Enum.Profession.Cooking},
			professionBonus = 5,
		},
		Tauren = {
			professionIDs = {Enum.Profession.Herbalism},
			professionBonus = 5,
		},
		BloodElf = {
			professionIDs = {Enum.Profession.Enchanting},
			professionBonus = 5,
		},
		Goblin = {
			professionIDs = {Enum.Profession.Alchemy},
			professionBonus = 5,
		},
		Nightborne = {
			professionIDs = {Enum.Profession.Inscription},
			professionBonus = 5,
		},
		HighmountainTauren = {
			professionIDs = {Enum.Profession.Mining},
			professionBonus = 5,
		}
	}

	local bonusData = data[playerRace]
	if not bonusData then
		return 0
	end

	if bonusData.professionIDs == nil or tContains(bonusData.professionIDs, professionID) then
		return bonusData.professionBonus
	else
		return 0
	end
		
end