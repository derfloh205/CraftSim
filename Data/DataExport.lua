AddonName, CraftSim = ...

CraftSim.DATAEXPORT = {}

CraftSimTooltipData = CraftSimTooltipData or {}
CraftSimItemCache = CraftSimItemCache or {}

LibCompress = LibStub:GetLibrary("LibCompress")

local function print(text, recursive, l, debugID) -- override
	if not debugID then
		CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.DATAEXPORT, recursive, l)
	else
		CraftSim_DEBUG:print(text, debugID, recursive, l)
	end
end



function CraftSim.DATAEXPORT:GetDifferentQualitiesByCraftingReagentTbl(recipeID, craftingReagentInfoTbl, allocationItemGUID)
	local linksByQuality = {}
	for i = 4, 8, 1 do
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, craftingReagentInfoTbl, allocationItemGUID, i)
		table.insert(linksByQuality, outputItemData.hyperlink)
	end
	 return linksByQuality
end

function CraftSim.DATAEXPORT:GetDifferentQualityIDsByCraftingReagentTbl(recipeID, craftingReagentInfoTbl, allocationItemGUID)
	local qualityIDs = {}
	for i = 1, 3, 1 do
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, craftingReagentInfoTbl, allocationItemGUID, i)
		table.insert(qualityIDs, outputItemData.itemID)
	end
	 return qualityIDs
end

function CraftSim.DATAEXPORT:AddSupportedRecipeStats(recipeData, operationInfo)
	if not operationInfo then
		return
	end
	local bonusStats = operationInfo.bonusStats
	recipeData.stats = {}
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		-- check each stat individually to consider localization
		local inspiration = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION))
		local multicraft = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT))
		local resourcefulness = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS))
		local craftingspeed = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED))
		if statName == craftingspeed then
			recipeData.stats.craftingspeed = {}
		elseif statName == inspiration then
			--print("add inspiration")
			recipeData.stats.inspiration = {}
		elseif statName == multicraft then
			recipeData.stats.multicraft = {}
		elseif statName == resourcefulness then
			recipeData.stats.resourcefulness = {}
		end
	end
end

function CraftSim.DATAEXPORT:handlePlayerProfessionStatsV1(recipeData, operationInfo)
	local bonusStats = operationInfo.bonusStats
	local professionGearStats = CraftSim.DATAEXPORT:GetCurrentProfessionItemStats(recipeData.professionID)

	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
		-- check each stat individually to consider localization
		local inspiration = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_INSPIRATION))
		local multicraft = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT))
		local resourcefulness = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS))
		local craftingspeed = string.lower(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED))

		if statName == craftingspeed then
			recipeData.stats.craftingspeed.value = statInfo.bonusStatValue
			recipeData.stats.craftingspeed.description = statInfo.ratingDescription
			recipeData.stats.craftingspeed.percent = statInfo.ratingPct
		elseif statName == inspiration then
			local baseInspiration = 50
			recipeData.stats.inspiration.value = statInfo.bonusStatValue + baseInspiration
			recipeData.stats.inspiration.description = statInfo.ratingDescription
			recipeData.stats.inspiration.percent = CraftSim.UTIL:GetInspirationPercentByStat(recipeData.stats.inspiration.value) * 100

			-- matches a row of numbers coming after the % character and any characters in between plus a space, should hopefully match in every localization...
			local _, _, bonusSkillOld = string.find(statInfo.ratingDescription, "%%.* (%d+)") 
			-- new version that also factors in asian characters
			local bonusSkill = tonumber((statInfo.ratingDescription:gsub("[^0-9%%]", ""):gsub(".*%%", "")))
			print("inspiration bonus skill new version: " .. tostring(bonusSkill))
			print("inspiration bonus skill old version: " .. tostring(bonusSkillOld))
			recipeData.stats.inspiration.bonusskill = bonusSkill
			recipeData.stats.inspiration.baseBonusSkill = 0
			if recipeData.maxQuality == 3 then
				recipeData.stats.inspiration.baseBonusSkill = recipeData.baseDifficulty * (1/3)
			elseif recipeData.maxQuality == 5 then
				recipeData.stats.inspiration.baseBonusSkill = recipeData.baseDifficulty * (1/6)
			end

			-- in this case with specs
			recipeData.stats.inspiration.bonusSkillFactorNoSpecs = (recipeData.stats.inspiration.bonusskill / recipeData.stats.inspiration.baseBonusSkill)
			-- the shown ui bonusskill is probably rounded and the base bonus skill not..
			-- this is a problem.. cause when the base skill is a little bit higher than the ui one, we get a factor of like 0.99
			-- solution: if the factor is sub 0 without modulo, its 0%
			if recipeData.stats.inspiration.bonusSkillFactorNoSpecs < 1 then
				recipeData.stats.inspiration.bonusSkillFactorNoSpecs = 0
			else
				recipeData.stats.inspiration.bonusSkillFactorNoSpecs = recipeData.stats.inspiration.bonusSkillFactorNoSpecs % 1
			end
			
			print("exported bonusSkillfactorNoSpecs: " .. tostring(recipeData.stats.inspiration.bonusSkillFactorNoSpecs))
		elseif statName == multicraft then
			recipeData.stats.multicraft.value = statInfo.bonusStatValue
			recipeData.stats.multicraft.description = statInfo.ratingDescription
			recipeData.stats.multicraft.percent = statInfo.ratingPct
			-- will be set in extra item factors fetch
			recipeData.stats.multicraft.bonusItemsFactorNoSpecs = 0
		elseif statName == resourcefulness then
			recipeData.stats.resourcefulness.value = statInfo.bonusStatValue
			recipeData.stats.resourcefulness.description = statInfo.ratingDescription
			recipeData.stats.resourcefulness.percent = statInfo.ratingPct
			-- will be set in extra item factors fetch
			recipeData.stats.resourcefulness.bonusItemsFactorNoSpecs = 0
		end
	end

	-- baseSkill is like the base of the players skill and bonusSkill is what is added through reagents and items and specs and such
	local reagentSkillContribution = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData)
	recipeData.stats.skill = operationInfo.baseSkill + operationInfo.bonusSkill
	recipeData.stats.skillNoReagents = recipeData.stats.skill - reagentSkillContribution
	recipeData.stats.skillNoItems = recipeData.stats.skill - professionGearStats.skill

	-- crafting speed is always relevant but it is not shown in details when it is zero
	if not recipeData.stats.craftingspeed then
		recipeData.stats.craftingspeed = {
			value = 0,
			percent = 0,
			description = ""
		}
	end
end

function CraftSim.DATAEXPORT:GetStatsFromBuffs(buffData)
	local stats = {	
        inspiration = 0,
        inspirationBonusSkillPercent = 0,
        multicraft = 0,
        multicraftExtraItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessExtraItemsFactor = 1,
        craftingspeed = 0,
		craftingspeedBonusFactor = 1,
        skill = 0
    }

	stats.inspiration = buffData.inspirationIncense or 0
	stats.craftingspeedBonusFactor = 1 + ( (buffData.quickPhial or 0) / 100)
	
    return stats
end

function CraftSim.DATAEXPORT:exportBuffData()
	local buffData = {
		inspirationIncense = false,
		quickPhial = false
	}
	
	-- check for buffs
	local inspirationIncense = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.INSPIRATION_INCENSE)
	local quickPhial = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS)

	buffData.inspirationIncense = inspirationIncense and 20 -- gives 20 inspiration
	buffData.quickPhial = quickPhial and quickPhial.points[1] -- points gives us the % as integer

	return buffData
end

function CraftSim.DATAEXPORT:exportSpecNodeData(recipeData)
    local configID = C_ProfSpecs.GetConfigIDForSkillLine(recipeData.professionInfo.skillLineID)

	local nodes = CraftSim.SPEC_DATA:GetNodes(recipeData.professionID) or {}

	local specNodeData = {}
	for _, currentNode in pairs(nodes) do
		--print("checking node -> " .. currentNode.name)
		local nodeInfo = C_Traits.GetNodeInfo(configID, currentNode.nodeID)
		if nodeInfo then
			specNodeData[currentNode.nodeID] = {
				nodeID = currentNode.nodeID,
				name = currentNode.name,
				activeRank = nodeInfo.activeRank,
				maxRanks = nodeInfo.maxRanks,
				-- parent nodes? and other stuff..
			}
		end
	end
	return specNodeData
end

function CraftSim.DATAEXPORT:GetStatsFromOptionalReagents(recipeData)
	-- TODO: export optional and finishing reagents and get their modifiers to any stats
	-- also, recipeDifficulty is relevant here for simulation mode only as non sim mode reads from recipeInfo
	local stats = {	
		recipeDifficulty = 0,
        inspiration = 0,
        inspirationBonusSkillFactor = 1,
        multicraft = 0,
        multicraftExtraItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessExtraItemsFactor = 1,
        craftingspeed = 0,
		craftingspeedBonusFactor = 1,
        skill = 0
    } 

	local function handleStatsFromReagentList(reagentList, stats)
		for _, reagentData in pairs(reagentList) do
			local statData = CraftSim.OPTIONAL_REAGENT_DATA[reagentData.itemID]
	
			if statData then
				for statName, _ in pairs(stats) do
					if statData[statName] then
						stats[statName] = stats[statName] + statData[statName]
					end
				end
			else
				local itemData = reagentData.itemData
				local name = (itemData and itemData.name) or "Not cached"
				print("No stat data for item: " .. name .. " (" .. reagentData.itemID .. ")")
			end
		end
	end

	handleStatsFromReagentList(recipeData.optionalReagents, stats)
	handleStatsFromReagentList(recipeData.finishingReagents, stats)

	print("Stats from Reagents:", false, true)
	print(stats)

	return stats
end

function CraftSim.DATAEXPORT:handlePlayerProfessionStatsV2(recipeData, exportMode)
	--print("player stats v2")
	local professionInfo = recipeData.professionInfo
	local professionGearStats = CraftSim.DATAEXPORT:GetCurrentProfessionItemStats(recipeData.professionID)

	local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[recipeData.professionID]

	local specNodeStats = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes)
	local buffStats = CraftSim.DATAEXPORT:GetStatsFromBuffs(recipeData.buffData)
	local optionalReagentsStats = CraftSim.DATAEXPORT:GetStatsFromOptionalReagents(recipeData)

	print("Stats from Specialization: ")
	print(specNodeStats)

	-- skill
	local baseSkill = professionInfo.skillLevel
	--local racialSkill = CraftSim.DATAEXPORT:GetRacialProfessionSkillBonus(recipeData.professionID)
	--print("Player Racial Bonus: " .. tostring(racialSkill))
	local itemSkill = professionGearStats.skill
	local specNodeSkill = specNodeStats.skill
	local optionalReagentsSkill = optionalReagentsStats.skill
	local reagentSkillContribution = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData, exportMode)

	recipeData.stats.skill = baseSkill + itemSkill + specNodeSkill + optionalReagentsSkill + reagentSkillContribution
	recipeData.stats.skillNoReagents = baseSkill + itemSkill + specNodeSkill + optionalReagentsSkill
	recipeData.stats.skillNoItems = baseSkill + specNodeSkill + optionalReagentsSkill + reagentSkillContribution

	-- inspiration
	if recipeData.stats.inspiration then
		local baseInspiration = 50 -- everyone has this as base = 5%
		local baseBonusSkill = 0
		local specNodeBonus = specNodeStats.inspiration
		local itemBonus = professionGearStats.inspiration
		local buffBonus = buffStats.inspiration
		local itemBonusSkillFactor = professionGearStats.inspirationBonusSkillPercent
		local specNodeBonusSkillFactor = specNodeStats.inspirationBonusSkillFactor % 1 -- 1.15 -> 0.15

		local optionalReagentsBonusSkillFactor = optionalReagentsStats.inspirationBonusSkillFactor % 1  -- 1.15 -> 0.15

		-- stack additively
		local totalBonusSkillFactor = specNodeBonusSkillFactor + itemBonusSkillFactor + optionalReagentsBonusSkillFactor
		recipeData.stats.inspiration.bonusSkillFactorNoSpecs = itemBonusSkillFactor -- format 0.x

		if not recipeData.result.isNoQuality then
			if recipeData.maxQuality == 5 then
				baseBonusSkill = recipeData.baseDifficulty * (1/6)
			else -- its 3
				baseBonusSkill = recipeData.baseDifficulty * (1/3)
			end
		end

		recipeData.stats.inspiration.value = buffStats.inspiration + itemBonus + specNodeBonus + buffBonus + baseInspiration
		recipeData.stats.inspiration.percent = CraftSim.UTIL:GetInspirationPercentByStat(recipeData.stats.inspiration.value) * 100
		recipeData.stats.inspiration.bonusskill = baseBonusSkill * (1 + totalBonusSkillFactor)
		recipeData.stats.inspiration.baseBonusSkill = baseBonusSkill
	end

	-- multicraft
	if recipeData.stats.multicraft then
		-- TODO BUFFS?
		local specNodeBonus = specNodeStats.multicraft
		local itemBonus = professionGearStats.multicraft
		local specNodeBonusItemsFactor = specNodeStats.multicraftExtraItemsFactor % 1
		local finishingReagentsBonusItemsFactor = optionalReagentsStats.multicraftExtraItemsFactor %1

		recipeData.stats.multicraft.value = buffStats.multicraft + itemBonus + specNodeBonus
		recipeData.stats.multicraft.percent = CraftSim.UTIL:GetMulticraftPercentByStat(recipeData.stats.multicraft.value) * 100
		recipeData.stats.multicraft.bonusItemsFactor = specNodeBonusItemsFactor + finishingReagentsBonusItemsFactor
		recipeData.stats.multicraft.bonusItemsFactorNoSpecs = 0
	end

	-- resourcefulness
	if recipeData.stats.resourcefulness then
		-- TODO BUFFS?
		local specNodeBonus = specNodeStats.resourcefulness
		local itemBonus = professionGearStats.resourcefulness
		local specNodeBonusItemsFactor = specNodeStats.resourcefulnessExtraItemsFactor % 1
		-- TODO: consider ??? Dont know if that even exists
		local finishingReagentsBonusItemsFactor = optionalReagentsStats.resourcefulnessExtraItemsFactor % 1

		recipeData.stats.resourcefulness.value = buffStats.resourcefulness + itemBonus + specNodeBonus
		recipeData.stats.resourcefulness.percent = CraftSim.UTIL:GetResourcefulnessPercentByStat(recipeData.stats.resourcefulness.value) * 100
		recipeData.stats.resourcefulness.bonusItemsFactor = specNodeBonusItemsFactor + finishingReagentsBonusItemsFactor
		recipeData.stats.resourcefulness.bonusItemsFactorNoSpecs = 0
	end

	-- craftingspeed
	if recipeData.stats.craftingspeed then
		-- TODO BUFFS?
		local specNodeBonus = specNodeStats.craftingspeed
		local itemBonus = professionGearStats.craftingspeed
		local specNodeBonusPercent = (specNodeStats.craftingspeedBonusFactor - 1) * 100
		local buffBonusPercent = (buffStats.craftingspeedBonusFactor - 1) * 100
		-- TODO: consider ??? Dont know if that even exists
		local finishingReagentsBonusFactor = optionalReagentsStats.craftingspeedBonusFactor

		recipeData.stats.craftingspeed.value = buffStats.craftingspeed + itemBonus + specNodeBonus
		recipeData.stats.craftingspeed.percent = (CraftSim.UTIL:GetCraftingSpeedPercentByStat(recipeData.stats.craftingspeed.value) * 100) + buffBonusPercent + specNodeBonusPercent
	end

	-- debug
	print("Total Skill: " .. tostring(recipeData.stats.skill))
	print("Total Skill no Reagents: " .. tostring(recipeData.stats.skillNoReagents))
	print("Total Skill no Items: " .. tostring(recipeData.stats.skillNoItems))
	print("Total Inspiration: ")
	print(recipeData.stats.inspiration or {})
	print("Total Multicraft: ")
	print(recipeData.stats.multicraft or {})
	print("Total Resourcefulness: ")
	print(recipeData.stats.resourcefulness or {})
	print("Total Crafting speed: ")
	print(recipeData.stats.craftingspeed or {})
end

function CraftSim.DATAEXPORT:handlePlayerProfessionStats(recipeData, operationInfo, exportMode)
	if not CraftSim.UTIL:IsSpecImplemented(recipeData.professionID) then
		CraftSim.DATAEXPORT:handlePlayerProfessionStatsV1(recipeData, operationInfo)
	else
		print("Spec is implemented")
		CraftSim.DATAEXPORT:handlePlayerProfessionStatsV2(recipeData, exportMode)
	end
end

function CraftSim.DATAEXPORT:handleOutputIDs(recipeData, recipeInfo)
	-- I need both to identify the spec boni
	recipeData.categoryID = recipeInfo.categoryID
	local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(recipeData.result.itemID or recipeData.result.itemIDs[1]) or {}
	recipeData.subtypeID = itemData.subclassID or nil
end

function CraftSim.DATAEXPORT:GetQualityIDFromOptionalReagentItemID(itemID)
	local optionalReagentEntry = CraftSim.OPTIONAL_REAGENT_DATA[itemID]

	if optionalReagentEntry then
		return optionalReagentEntry.qualityID
	else
		print("Optional Reagent not found in Data: " .. tostring(itemID) .. "possibly old world recipe")
		return nil
	end

end

function CraftSim.DATAEXPORT:exportAvailableSlotReagentsFromReagentSlotsV2(schematicSlots, reagentType, recipeID, skillLineID)
	if not schematicSlots then
		return {}
	end
	-- could be more than 1 slot for optional and finishing, but is one slot strictly for salvaging
	local slotsToItemIDs = {}
	local currentRelevantSlot = 0
	local lastDataSlotIndex = -1
	for slotIndex, slotData in pairs(schematicSlots) do
		local button = slotData
		local reagents = slotData.reagents
		local dataSlotIndex = slotData.dataSlotIndex

		print(CraftSim.UTIL:ColorizeText("schematicSlot", CraftSim.CONST.COLORS.LEGENDARY), false, true)
		print(slotData, true)

		local locked = false
		local lockedReason = ""
		if slotData.slotInfo and slotData.slotInfo.mcrSlotID then
			locked, lockedReason = C_TradeSkillUI.GetReagentSlotStatus(slotData.slotInfo.mcrSlotID, recipeID, skillLineID)
	
			if locked then
				print(CraftSim.UTIL:ColorizeText("locked", CraftSim.CONST.COLORS.RED))
				print("reason: " .. tostring(lockedReason))
			else
				print(CraftSim.UTIL:ColorizeText("not locked", CraftSim.CONST.COLORS.GREEN))
			end
		end

		if reagentType == slotData.reagentType then
			-- count up for the different data slot indices
			if lastDataSlotIndex ~= dataSlotIndex then
				currentRelevantSlot = currentRelevantSlot + 1
				lastDataSlotIndex = dataSlotIndex
			end
			for _, slotReagentData in pairs(reagents) do
				if slotsToItemIDs[currentRelevantSlot] == nil then
					slotsToItemIDs[currentRelevantSlot] = {}
				end
				table.insert(slotsToItemIDs[currentRelevantSlot], {
					itemID = slotReagentData.itemID,
					qualityID = CraftSim.DATAEXPORT:GetQualityIDFromOptionalReagentItemID(slotReagentData.itemID),
					dataSlotIndex = dataSlotIndex,
					locked = locked,
					lockedReason = lockedReason,
				})
			end
		end
	end

	return slotsToItemIDs
end

function CraftSim.DATAEXPORT:GetCurrentRecipeOperationInfoByExportMode(exportMode, recipeID, overrideData)
	if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		return ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeOperationInfo()
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
		return ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:GetRecipeOperationInfo()
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
		if overrideData then
			local craftingReagentInfoTbl = CraftSim.DATAEXPORT:ConvertRecipeDataRequiredReagentsToCraftingReagentInfoTbl(overrideData.scanReagents or {})
			print("whatsmyoverridedata? ")
			print(overrideData, true)
			for _, reagent in pairs(overrideData.optionalReagents or {}) do
				print("inserting optional from override: " .. tostring(reagent))
				table.insert(craftingReagentInfoTbl, reagent)
			end
			for _, reagent in pairs(overrideData.finishingReagents or {}) do
				table.insert(craftingReagentInfoTbl, reagent)
			end
			print("craftingreagentinfotableByOverride: ")
			print(craftingReagentInfoTbl, true)
			return C_TradeSkillUI.GetCraftingOperationInfo(recipeID, craftingReagentInfoTbl) 
		else
			return C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {})
		end
	end
end

function CraftSim.DATAEXPORT:GetCurrentRecipeTransactionByExportMode(exportMode)
	if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		return ProfessionsFrame.CraftingPage.SchematicForm:GetTransaction()
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
		return ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:GetTransaction()
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
		return nil
	end
end

function CraftSim.DATAEXPORT:GetSchematicReagentSlotsByExportMode(exportMode)
	if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		return ProfessionsFrame.CraftingPage.SchematicForm.reagentSlots
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
		return ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.reagentSlots
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
		return nil
	end
end

function CraftSim.DATAEXPORT:GetRequiredReagentItemsInfoByExportMode(currentSlot, exportMode, currentTransaction, slotIndex)
	if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER or exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
		local slotAllocations = currentTransaction:GetAllocations(slotIndex)
		local itemsInfo = {}
		
		for i, reagent in pairs(currentSlot.reagents) do
			local reagentAllocation = (slotAllocations and slotAllocations:FindAllocationByReagent(reagent)) or nil
			local allocations = 0
			if reagentAllocation ~= nil then
				allocations = reagentAllocation:GetQuantity()
			end
			local itemInfo = {
				itemID = reagent.itemID,
				allocations = allocations
			}
			table.insert(itemsInfo, itemInfo)
		end
		return itemsInfo
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
		-- depends on the type of scan
		-- check scan module for that

		-- set all 0 , will be later set by scan mode
		local itemsInfo = {}
		for i, reagent in pairs(currentSlot.reagents) do
			local allocations = 0
			
			local itemInfo = {
				itemID = reagent.itemID,
				allocations = allocations
			}
			table.insert(itemsInfo, itemInfo)
			local reagentName = CraftSim.DATAEXPORT:GetReagentNameFromReagentData(reagent.itemID)
			--print("Allocations for Scan: " .. reagentName .. "Q" .. i .. " -> " .. tostring(allocations) .. "/" .. tostring(currentSlot.quantityRequired))
		end
		return itemsInfo		
	end
end

function CraftSim.DATAEXPORT:AddOptionalReagentByExportMode(currentSlot, exportMode, reagentList, reagentType, schematicReagentSlots, currentReagentNr)
	if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER or exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		local hasSlots = schematicReagentSlots[reagentType] ~= nil
		if hasSlots then
			local optionalSlots = schematicReagentSlots[reagentType][currentReagentNr]
			if not optionalSlots then
				return
			end
			local button = optionalSlots.Button
			local allocatedItemID = button:GetItemID()
			if allocatedItemID then
				local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(allocatedItemID)
				print("-> optional/finishing #" .. currentReagentNr .. ": " .. tostring(itemData.link) .. " Type: " .. tostring(reagentType))
				print("dataSlotIndex: " .. tostring(currentSlot.dataSlotIndex))
				table.insert(reagentList, {
					itemID = allocatedItemID,
					itemData = itemData,
					dataSlotIndex = currentSlot.dataSlotIndex
				})
			end
			
			return currentReagentNr + 1
		end
		return currentReagentNr
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
		-- do not add any optional reagent (yet)
		return currentReagentNr
	end
end

function CraftSim.DATAEXPORT:GetCraftingReagentInfoTblByExportMode(exportMode, currentTransaction, overrideData)
	if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER or exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		return currentTransaction:CreateCraftingReagentInfoTbl()
	elseif exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
		if overrideData then
			local craftingReagentInfoTbl = CraftSim.DATAEXPORT:ConvertRecipeDataRequiredReagentsToCraftingReagentInfoTbl(overrideData.scanReagents or {})
			for _, reagent in pairs(overrideData.optionalReagents or {}) do
				table.insert(craftingReagentInfoTbl, reagent)
			end
			for _, reagent in pairs(overrideData.finishingReagents or {}) do
				table.insert(craftingReagentInfoTbl, reagent)
			end
			return craftingReagentInfoTbl
		else
			return {}
		end
	end
end

function CraftSim.DATAEXPORT:ConvertRecipeDataRequiredReagentsToCraftingReagentInfoTbl(reagents)
	local craftingReagentInfoTbl = {}
    for _, reagent in pairs(reagents) do
        if reagent.differentQualities then
            for _, itemInfo in pairs(reagent.itemsInfo) do
                local infoEntry = {
                    itemID = itemInfo.itemID,
                    quantity = itemInfo.allocations,
                    dataSlotIndex = 2,
                }
                table.insert(craftingReagentInfoTbl, infoEntry)
            end
        end
    end

	return craftingReagentInfoTbl
end

function CraftSim.DATAEXPORT:exportRecipeData(recipeID, exportMode, overrideData)
	local recipeData = {}
	overrideData = overrideData or {}

	CraftSim.UTIL:StartProfiling("DATAEXPORT")

	--local professionInfo = ProfessionsFrame.professionInfo
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()

	if not professionInfo or not professionInfo.profession then
		-- try to get from cache
		recipeData.professionID = CraftSim.RECIPE_SCAN:GetProfessionIDByRecipeID(recipeID)

		if recipeData.professionID then
			professionInfo = CraftSim.CACHE:GetCacheEntryByVersion(CraftSimProfessionInfoCache, recipeData.professionID)

			if not professionInfo then
				return
			end
		end
	else
		-- recipeData.profession = professionInfo.parentProfessionName
		recipeData.professionID = professionInfo.profession
		if recipeData.professionID then
			professionInfo.skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
			CraftSim.CACHE:AddCacheEntryByVersion(CraftSimProfessionInfoCache, recipeData.professionID, professionInfo)
		end
	end

	print("RecipeData Export:", false, true)
	if recipeData.professionID == nil then
		-- not ready yet
		return
	end
	recipeData.professionInfo = professionInfo
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

	print("recipeInfo:")
	print(recipeInfo, true)

	-- Can happen when manually called without recipe open
	if not recipeInfo then
		print("RecipeInfo nil")
		return nil
	end

	local recipeType = CraftSim.UTIL:GetRecipeType(recipeInfo)

	recipeData.learned = recipeInfo.learned
	recipeData.numSkillUps = recipeInfo.numSkillUps -- for cheapest skill up scan
	recipeData.recipeIcon = recipeInfo.icon
	recipeData.recipeName = recipeInfo.name
	recipeData.recipeID = recipeInfo.recipeID
	print("recipeID: " .. tostring(recipeData.recipeID))
	recipeData.recipeType = recipeType
	recipeData.supportsCraftingStats = recipeInfo.supportsCraftingStats
	
	
	local operationInfo = CraftSim.DATAEXPORT:GetCurrentRecipeOperationInfoByExportMode(exportMode, recipeData.recipeID, overrideData)
	
    if recipeInfo.supportsCraftingStats and (operationInfo == nil or recipeType == CraftSim.CONST.RECIPE_TYPES.GATHERING) then
		print("OperationInfo nil")
        return nil
    end
	local currentTransaction = CraftSim.DATAEXPORT:GetCurrentRecipeTransactionByExportMode(exportMode)
	
	if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER or exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		recipeData.isRecraft = currentTransaction:GetRecraftAllocation() ~= nil -- I dont know why but isRecraft is false on recrafts ?
		recipeData.recraftAllocationGUID = currentTransaction:GetRecraftAllocation()
	else
		recipeData.isRecraft = false
	end
	print("isRecraft: " .. tostring(recipeData.isRecraft))

	print("recipeType: " .. tostring(recipeData.recipeType))

	recipeData.expectedQuality = operationInfo and operationInfo.craftingQuality
	recipeData.operationInfo = operationInfo
	print("expectedQuality: " .. tostring(recipeData.expectedQuality))
	print("expectedQuality: " .. tostring(recipeData.expectedQuality))

	recipeData.isEnchantingRecipe = recipeInfo.isEnchantingRecipe
	print("isEnchantingRecipe: " .. tostring(recipeData.isEnchantingRecipe))
	
	
	
	recipeData.currentTransaction = currentTransaction
	recipeData.reagents = {}

	if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		recipeData.isSalvageRecipe = recipeInfo.isSalvageRecipe
		print("isSalvageRecipe: " .. tostring(recipeData.isSalvageRecipe))
		local salvageAllocation = currentTransaction:GetSalvageAllocation()
		if salvageAllocation then
			recipeData.salvageReagent = {
				name = salvageAllocation:GetItemName(),
				itemLink = salvageAllocation:GetItemLink(),
				itemID = salvageAllocation:GetItemID(),
				requiredQuantity = ProfessionsFrame.CraftingPage.SchematicForm.salvageSlot.quantityRequired
			}
		end
	end

	local hasReagentsWithQuality = false
	
	local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(recipeData.recipeID, recipeData.isRecraft)
	-- this includes finishing AND optionalReagents too!!!

	recipeData.possibleOptionalReagents = {}
	recipeData.possibleFinishingReagents = {}
	recipeData.possibleSalvageReagents = {}

	local schematicReagentSlots = CraftSim.DATAEXPORT:GetSchematicReagentSlotsByExportMode(exportMode)

	if schematicReagentSlots and #schematicReagentSlots == 0 and not recipeData.isSalvageRecipe then
		return
	end

	-- extract possible optional and finishing and salvage reagents per slot
	recipeData.possibleOptionalReagents = CraftSim.DATAEXPORT:exportAvailableSlotReagentsFromReagentSlotsV2(schematicInfo.reagentSlotSchematics, CraftSim.CONST.REAGENT_TYPE.OPTIONAL, recipeData.recipeID, recipeData.professionInfo.skillLineID)
	recipeData.possibleFinishingReagents = CraftSim.DATAEXPORT:exportAvailableSlotReagentsFromReagentSlotsV2(schematicInfo.reagentSlotSchematics, CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT, recipeData.recipeID, recipeData.professionInfo.skillLineID)
	recipeData.possibleSalvageReagents = C_TradeSkillUI.GetSalvagableItemIDs(recipeData.recipeID) -- thx blizz tbh

	print("possible optional reagents:")
	print(recipeData.possibleOptionalReagents, true)
	print("possible finishing reagents:")
	print(recipeData.possibleFinishingReagents, true)
	print("possible salvage reagents:")
	print(recipeData.possibleSalvageReagents, true)



	recipeData.reagents = {}
	recipeData.optionalReagents = {}
	recipeData.finishingReagents = {}

	print("export: reagentSlotSchematics: " .. #schematicInfo.reagentSlotSchematics)
	
	recipeData.numReagentsWithQuality = 0
	local currentFinishingReagent = 1
	local currentOptionalReagent = 1
	local currentRequiredReagent = 1

	if not recipeData.isSalvageRecipe and not overrideData.scanReagents then
		for slotIndex, currentSlot in pairs(schematicInfo.reagentSlotSchematics) do
			local reagents = currentSlot.reagents
			local reagentType = currentSlot.reagentType
			local reagentName = CraftSim.DATAEXPORT:GetReagentNameFromReagentData(reagents[1].itemID)
			--print("SlotIndex: " .. tostring(slotIndex) .. " firstPossibleItem -> " .. tostring(reagentName))
			-- for now only consider the required reagents
			if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
				print(slotIndex .. " -> "..currentSlot.quantityRequired.." required #" .. currentRequiredReagent .. ": " .. tostring(reagentName) .. " Type: " .. tostring(reagentType))
				local hasMoreThanOneQuality = reagents[2] ~= nil
	
				if hasMoreThanOneQuality then
					hasReagentsWithQuality = true
					recipeData.numReagentsWithQuality = recipeData.numReagentsWithQuality + 1
				end
				local reagentEntry = {
					name = reagentName,
					requiredQuantity = currentSlot.quantityRequired,
					differentQualities = hasMoreThanOneQuality,
					reagentType = currentSlot.reagentType
				}
				
				reagentEntry.itemsInfo = CraftSim.DATAEXPORT:GetRequiredReagentItemsInfoByExportMode(currentSlot, exportMode, currentTransaction, slotIndex)
				
				table.insert(recipeData.reagents, reagentEntry)
	
				currentRequiredReagent = currentRequiredReagent + 1
			elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL then
				currentOptionalReagent = CraftSim.DATAEXPORT:AddOptionalReagentByExportMode(currentSlot, exportMode, recipeData.optionalReagents, reagentType, schematicReagentSlots, currentOptionalReagent)
			elseif reagentType == CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT then
				currentFinishingReagent = CraftSim.DATAEXPORT:AddOptionalReagentByExportMode(currentSlot, exportMode, recipeData.finishingReagents, reagentType, schematicReagentSlots, currentFinishingReagent)
			end
		end
	elseif not recipeData.isSalvageRecipe then
		recipeData.reagents = CopyTable(overrideData.scanReagents)
	end

	if overrideData.optionalReagents then
		recipeData.optionalReagents = CopyTable(overrideData.optionalReagents)
	end

	if overrideData.finishingReagents then
		recipeData.finishingReagents = CopyTable(overrideData.finishingReagents)
	end

	recipeData.hasReagentsWithQuality = hasReagentsWithQuality
	print("hasReagentsWithQuality: " .. tostring(recipeData.hasReagentsWithQuality))
	recipeData.maxQuality = recipeInfo.maxQuality
	print("maxQuality: " .. tostring(recipeData.maxQuality))
	
	recipeData.baseItemAmount = (schematicInfo.quantityMin + schematicInfo.quantityMax) / 2
	recipeData.hasSingleItemOutput = recipeInfo.hasSingleItemOutput
	print("baseItemAmount: " .. tostring(recipeData.baseItemAmount) .. "(" .. tostring(schematicInfo.quantityMin) .. "-" .. tostring(schematicInfo.quantityMax) .. ")")
	
	
	recipeData.recipeDifficulty = operationInfo and (operationInfo.baseDifficulty + operationInfo.bonusDifficulty)
	recipeData.baseDifficulty = operationInfo and operationInfo.baseDifficulty
	recipeData.bonusDifficulty = operationInfo and operationInfo.bonusDifficulty
	print("recipeDifficulty: " .. tostring(recipeData.recipeDifficulty))
	print("baseDifficulty: " .. tostring(recipeData.baseDifficulty))
	print("bonusDifficulty: " .. tostring(recipeData.bonusDifficulty))

	recipeData.result = {}

	local allocationItemGUID = nil 
	if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER or exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
		allocationItemGUID = currentTransaction:GetAllocationItemGUID()
	else
		allocationItemGUID = nil
	end

	print("allocationItemGUID: " .. tostring(allocationItemGUID))

	recipeData.result.resultItems = {} -- to utilize onitemload callbacks

	if recipeType == CraftSim.CONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.SINGLE then
		-- New Approach: Use the API with a quality override to fetch the result data, 
		-- to combat blizzards wierd order issues in the qualityItemIDs table
		local craftingReagentInfoTbl = CraftSim.DATAEXPORT:GetCraftingReagentInfoTblByExportMode(exportMode, currentTransaction, overrideData)
		recipeData.result.itemIDs = CraftSim.DATAEXPORT:GetDifferentQualityIDsByCraftingReagentTbl(recipeData.recipeID, craftingReagentInfoTbl, allocationItemGUID)

		for _, itemID in pairs(recipeData.result.itemIDs) do
			table.insert(recipeData.result.resultItems, Item:CreateFromItemID(itemID))
		end
		
	elseif recipeType == CraftSim.CONST.RECIPE_TYPES.ENCHANT then
		if not CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID] then
			error("CraftSim: Enchant Recipe Missing in Data: " .. recipeData.recipeID .. " Please contact the developer (discord: genju#4210)")
		end
		recipeData.result.itemIDs = {
			CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q1,
			CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q2,
			CraftSim.ENCHANT_RECIPE_DATA[recipeData.recipeID].q3}

		for _, itemID in pairs(recipeData.result.itemIDs) do
			table.insert(recipeData.result.resultItems, Item:CreateFromItemID(itemID))
		end
	elseif recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR then
		recipeData.result.itemID = schematicInfo.outputItemID
		
		local craftingReagentInfoTbl = CraftSim.DATAEXPORT:GetCraftingReagentInfoTblByExportMode(exportMode, currentTransaction, overrideData)
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, craftingReagentInfoTbl, allocationItemGUID)
		recipeData.result.hyperlink = outputItemData.hyperlink
		recipeData.result.itemQualityLinks = CraftSim.DATAEXPORT:GetDifferentQualitiesByCraftingReagentTbl(recipeData.recipeID, craftingReagentInfoTbl, allocationItemGUID)
	
		for _, itemLink in pairs(recipeData.result.itemQualityLinks) do
			table.insert(recipeData.result.resultItems, Item:CreateFromItemLink(itemLink))
		end
	elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
		-- Probably something like transmuting air reagent that creates non equip stuff without qualities
		recipeData.result.itemID = CraftSim.UTIL:GetItemIDByLink(recipeInfo.hyperlink)
		recipeData.result.isNoQuality = true	
		table.insert(recipeData.result.resultItems, Item:CreateFromItemID(recipeData.result.itemID))
	elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_ITEM then
		-- nothing cause there is no result
	else
		print("recipeType not covered in export: " .. tostring(recipeType))
	end

	print("isNoQuality: " .. tostring(recipeData.result.isNoQuality))	

	if recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_ITEM and recipeType ~= CraftSim.CONST.RECIPE_TYPES.GATHERING then
		CraftSim.DATAEXPORT:handleOutputIDs(recipeData, recipeInfo)
	end

	CraftSim.DATAEXPORT:AddSupportedRecipeStats(recipeData, operationInfo)

	if operationInfo then
		if not CraftSim.UTIL:IsSpecImplemented(recipeData.professionID) then
			recipeData.extraItemFactors = CraftSim.SPEC_DATA:GetSpecExtraItemFactorsByRecipeData(recipeData)
			print("NoSpec ExtraItemFactors:")
			print(recipeData.extraItemFactors, true)
		else
			print(CraftSim.UTIL:ColorizeText("Recipe is using SpecData", CraftSim.CONST.COLORS.GREEN))
			recipeData.buffData = CraftSim.DATAEXPORT:exportBuffData()
			print("BuffData:")
			print(recipeData.buffData, true)
			recipeData.specNodeData = CraftSim.DATAEXPORT:exportSpecNodeData(recipeData)
		end

		CraftSim.DATAEXPORT:handlePlayerProfessionStats(recipeData, operationInfo, exportMode)
		recipeData.maxReagentSkillIncreaseFactor = CraftSim.REAGENT_OPTIMIZATION:GetMaxReagentIncreaseFactor(recipeData, exportMode)
		print("maxReagentSkillIncreaseFactor: " .. tostring(recipeData.maxReagentSkillIncreaseFactor))
	end



	CraftSim.MAIN.currentRecipeData = recipeData


	recipeData.ContinueOnResultItemsLoaded = function (AllItemsLoadedCallback)
		recipeData.itemsToLoad = #recipeData.result.resultItems
		local itemLoaded = function ()
			recipeData.itemsToLoad = recipeData.itemsToLoad - 1
			CraftSim_DEBUG:print("loaded items left: " .. recipeData.itemsToLoad, CraftSim.CONST.DEBUG_IDS.MAIN)
	
			if recipeData.itemsToLoad <= 0 then
				CraftSim_DEBUG:print("all items loaded, call callback", CraftSim.CONST.DEBUG_IDS.MAIN)
				AllItemsLoadedCallback(recipeData)
			end
		end

		if recipeData.itemsToLoad >= 1 then
			for _, itemToLoad in pairs(recipeData.result.resultItems) do
				itemToLoad:ContinueOnItemLoad(itemLoaded)
			end
		end
	end

	CraftSim.UTIL:StopProfiling("DATAEXPORT")
	return recipeData
end

function CraftSim.DATAEXPORT:GetProfessionGearStatsByLink(itemLink)
	local extractedStats = GetItemStats(itemLink)
	local stats = {}

	local itemID = CraftSim.UTIL:GetItemIDByLink(itemLink)
	if CraftSim.CONST.SPECIAL_TOOL_STATS[itemID] then
		stats = CraftSim.CONST.SPECIAL_TOOL_STATS[itemID]
	end

	for statKey, value in pairs(extractedStats or {}) do
		if CraftSim.CONST.STAT_MAP[statKey] ~= nil then
			stats[CraftSim.CONST.STAT_MAP[statKey]] = value
		end
	end

	local parsedSkill = 0
	local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
	-- For now there is only inspiration and resourcefulness as enchant?
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
	for lineNum, line in pairs(tooltipData.lines) do
		for argNum, arg in pairs(line.args) do
			if arg.stringVal and string.find(arg.stringVal, equipMatchString) then
				-- here the stringVal looks like "Equip: +6 Blacksmithing Skill"
				parsedSkill = tonumber(string.match(arg.stringVal, "(%d+)"))
			end
			if arg.stringVal and string.find(arg.stringVal, enchantedMatchString) then
				if string.find(arg.stringVal, inspirationMatchString) then
					parsedEnchantingStats.inspiration = tonumber(string.match(arg.stringVal, "%+(%d+)"))
				elseif string.find(arg.stringVal, resourcefulnessMatchString) then
					parsedEnchantingStats.resourcefulness = tonumber(string.match(arg.stringVal, "%+(%d+)"))
				elseif string.find(arg.stringVal, multicraftMatchString) then
					parsedEnchantingStats.multicraft = tonumber(string.match(arg.stringVal, "%+(%d+)"))
				end
			end
		end
	end
	stats.inspiration = (stats.inspiration or 0) + parsedEnchantingStats.inspiration
	stats.resourcefulness = (stats.resourcefulness or 0) + parsedEnchantingStats.resourcefulness

	stats.skill = parsedSkill

	return stats
end

function CraftSim.DATAEXPORT:GetOutputInfoByRecipeData(recipeData)
	local outputLinkExpected = nil
	local outputLinkInspiration = nil
	local inspirationPercent = nil
	local inspirationCanUpgrade = false
	local expectedQuality = recipeData.expectedQuality
	local expectedQualityInspiration = recipeData.expectedQuality
	
	if recipeData.stats.inspiration then
		inspirationPercent = recipeData.stats.inspiration.percent

		local skillWithInspiration = recipeData.stats.skill + recipeData.stats.inspiration.bonusskill
        expectedQualityInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skillWithInspiration)
	end
	
	local expectedItem = recipeData.result.resultItems[recipeData.expectedQuality]
	CraftSim_DEBUG:print("Expected Item:", CraftSim.CONST.DEBUG_IDS.MAIN)
	CraftSim_DEBUG:print("- IsItemDataCached: " .. tostring(expectedItem:IsItemDataCached()), CraftSim.CONST.DEBUG_IDS.MAIN)
	CraftSim_DEBUG:print("- Link: " .. tostring(expectedItem:GetItemLink()), CraftSim.CONST.DEBUG_IDS.MAIN)
	outputLinkExpected = expectedItem:GetItemLink()
	if expectedQualityInspiration ~= recipeData.expectedQuality then
		inspirationCanUpgrade = true
		expectedQualityInspiration = expectedQualityInspiration
		local inspiredItem = recipeData.result.resultItems[expectedQualityInspiration]
		CraftSim_DEBUG:print("Inspired Item:", CraftSim.CONST.DEBUG_IDS.MAIN)
		CraftSim_DEBUG:print("- IsItemDataCached: " .. tostring(inspiredItem:IsItemDataCached()), CraftSim.CONST.DEBUG_IDS.MAIN)
		CraftSim_DEBUG:print("- Link: " .. tostring(inspiredItem:GetItemLink()), CraftSim.CONST.DEBUG_IDS.MAIN)
		outputLinkInspiration = inspiredItem:GetItemLink()
	end 

	return {
		isNoQuality = recipeData.result.isNoQuality,
		expected = outputLinkExpected,
		inspiration = outputLinkInspiration,
		inspirationPercent = inspirationPercent,
		inspirationCanUpgrade = inspirationCanUpgrade,
		expectedQuality = expectedQuality,
		expectedQualityInspiration = expectedQualityInspiration,
	}
end

function CraftSim.DATAEXPORT:GetCurrentProfessionItemStats(professionID)
	local stats = {
		inspiration = 0,
		inspirationBonusSkillPercent = 0,
		multicraft = 0,
		resourcefulness = 0,
		craftingspeed = 0,
		skill = 0
	}
	local currentProfessionSlots = C_TradeSkillUI.GetProfessionSlots(professionID)
	print("professionequipslots: ")
	print(currentProfessionSlots)

	for _, slotID in pairs(currentProfessionSlots) do
		--local slotID = GetInventorySlotInfo(slotName)
		local itemLink = GetInventoryItemLink("player", slotID)
		if itemLink ~= nil then
			local itemStats = CraftSim.DATAEXPORT:GetProfessionGearStatsByLink(itemLink)
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
				stats.inspirationBonusSkillPercent = stats.inspirationBonusSkillPercent + itemStats.inspirationBonusSkillPercent
			end
		end
	end

	print("stats from items:", false, true)
	print(stats, true)
	return stats
end

function CraftSim.DATAEXPORT:GetEquippedProfessionGear(professionID)
	local professionGear = {}
	local currentProfessionSlots = C_TradeSkillUI.GetProfessionSlots(professionID)
	
	for _, slotID in pairs(currentProfessionSlots) do
		--print("checking slot: " .. slotName)
		local itemLink = GetInventoryItemLink("player", slotID)
		if itemLink ~= nil then
			local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink) 
			local itemStats = CraftSim.DATAEXPORT:GetProfessionGearStatsByLink(itemLink)
			--print("e ->: " .. itemLink)
			table.insert(professionGear, {
				itemID = CraftSim.UTIL:GetItemIDByLink(itemLink),
				itemLink = itemLink,
				itemStats = itemStats,
				equipSlot = equipSlot,
				isEmptySlot = false
			})
		end
	end
	return professionGear
end

function CraftSim.DATAEXPORT:GetProfessionGearFromInventory()
	local currentProfession = ProfessionsFrame.professionInfo.parentProfessionName
	local professionGear = {}

	for bag=BANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		for slot=1,C_Container.GetContainerNumSlots(bag) do
			local itemLink = C_Container.GetContainerItemLink(bag, slot)
			if itemLink ~= nil then
				local _, _, _, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink) 
				if itemSubType == currentProfession then
					--print("i -> " .. tostring(itemLink))
					local itemStats = CraftSim.DATAEXPORT:GetProfessionGearStatsByLink(itemLink)
					table.insert(professionGear, {
						itemID = CraftSim.UTIL:GetItemIDByLink(itemLink),
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

function CraftSim.DATAEXPORT:GetReagentNameFromReagentData(itemID)
	local reagentData = CraftSim.REAGENT_DATA[itemID]

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

function CraftSim.DATAEXPORT:ExportTooltipData(recipeData)
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

function CraftSim.DATAEXPORT:UpdateTooltipData(recipeData)
	if recipeData.isRecraft then
		return
	end
	local data = CraftSim.DATAEXPORT:ExportTooltipData(recipeData)
    if recipeData.recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or recipeData.recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR then
        -- map itemlinks to data
		CraftSimTooltipData[recipeData.result.hyperlink] = data
	elseif recipeData.recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeData.recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
		CraftSimTooltipData[recipeData.result.itemID] = data
	elseif recipeData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.GATHERING and recipeData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION and
	    recipeData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_ITEM then
        -- map itemids to data
        -- the item id has a certain quality, so remember the itemid and the current crafting costs as "last crafting costs"
        CraftSimTooltipData[recipeData.result.itemIDs[recipeData.expectedQuality]] = data
    end
end

function CraftSim.DATAEXPORT:HandleItemIDMappings(itemID)
	local mappedID = CraftSim.CONST.ITEM_ID_EXCEPTION_MAPPING[itemID]

	return mappedID or itemID
end

function CraftSim.DATAEXPORT:GetItemFromCacheByItemID(itemID, ignoreOverrides)
	if not ignoreOverrides then
		itemID = CraftSim.DATAEXPORT:HandleItemIDMappings(itemID)
	end
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

-- function CraftSim.DATAEXPORT:GetRacialProfessionSkillBonus(professionID)
-- 	local _, playerRace = UnitRace("player")
-- 	print("Player Race: " .. tostring(playerRace))
-- 	local data = {
-- 		Gnome = {
-- 			professionIDs = {Enum.Profession.Engineering},
-- 			professionBonus = 5,
-- 		},
-- 		Draenei = {
-- 			professionIDs = {Enum.Profession.Jewelcrafting},
-- 			professionBonus = 5,
-- 		},
-- 		Worgen = {
-- 			professionIDs = {Enum.Profession.Skinning},
-- 			professionBonus = 5,
-- 		},
-- 		LightforgedDraenei = {
-- 			professionIDs = {Enum.Profession.Blacksmithing},
-- 			professionBonus = 5,
-- 		},
-- 		DarkIronDwarf = {
-- 			professionIDs = {Enum.Profession.Blacksmithing},
-- 			professionBonus = 5,
-- 		},
-- 		KulTiran = {
-- 			professionIDs = nil, -- everything
-- 			professionBonus = 2,
-- 		},
-- 		Pandaren = {
-- 			professionIDs = {Enum.Profession.Cooking},
-- 			professionBonus = 5,
-- 		},
-- 		Tauren = {
-- 			professionIDs = {Enum.Profession.Herbalism},
-- 			professionBonus = 5,
-- 		},
-- 		BloodElf = {
-- 			professionIDs = {Enum.Profession.Enchanting},
-- 			professionBonus = 5,
-- 		},
-- 		Goblin = {
-- 			professionIDs = {Enum.Profession.Alchemy},
-- 			professionBonus = 5,
-- 		},
-- 		Nightborne = {
-- 			professionIDs = {Enum.Profession.Inscription},
-- 			professionBonus = 5,
-- 		},
-- 		HighmountainTauren = {
-- 			professionIDs = {Enum.Profession.Mining},
-- 			professionBonus = 5,
-- 		}
-- 	}

-- 	local bonusData = data[playerRace]
-- 	if not bonusData then
-- 		return 0
-- 	end

-- 	if bonusData.professionIDs == nil or tContains(bonusData.professionIDs, professionID) then
-- 		return bonusData.professionBonus
-- 	else
-- 		return 0
-- 	end
		
-- end

function CraftSim.DATAEXPORT:GetExportString()
	local recipeData = CraftSim.MAIN.currentRecipeData

	if not recipeData then
		return "No Recipe Open"
	end
	-- convert to CSV
	local csvOutput = ""

	for key, value in pairs(recipeData) do
		if type(value) ~= "table" then
			csvOutput = csvOutput .. tostring(key) .. "," .. tostring(value) .. "\n"
		end
	end

	for statKey, statValue in pairs(recipeData.stats) do
		if type(statValue) == 'table' then
			csvOutput = csvOutput .. tostring(statKey) .. "," .. tostring(statValue.value) .. "\n"
		else
			csvOutput = csvOutput .. tostring(statKey) .. "," .. tostring(statValue) .. "\n"
		end
	end

	for _, reagentData in pairs(recipeData.reagents) do
		for qualityID, itemInfo in pairs(reagentData.itemsInfo) do
			csvOutput = csvOutput .. tostring(itemInfo.itemID) .. "," .. tostring(itemInfo.allocations) .. "\n"
		end
	end

	if CraftSim.SIMULATION_MODE.isActive then
		for index, dropdown in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames) do
			local itemID = dropdown.selectedItemID
			if itemID then
				csvOutput = csvOutput .. tostring(itemID) .. "," .. tostring(true) .. "\n"
			end
		end
	else
		for index, reagent in pairs(recipeData.optionalReagents) do
			csvOutput = csvOutput .. tostring(reagent.itemID) .. "," .. tostring(true) .. "\n"
		end
		for index, reagent in pairs(recipeData.finishingReagents) do
			csvOutput = csvOutput .. tostring(reagent.itemID) .. "," .. tostring(true) .. "\n"
		end
	end

	return csvOutput
end
