CraftSimDATAEXPORT = {}

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
		local _, link = GetItemInfo(newString)
		table.insert(linksByQuality, link)
	 end
	 return linksByQuality
end

function CraftSimDATAEXPORT:exportRecipeData()
	local recipeData = {}

	local professionInfo = ProfessionsFrame.professionInfo
	local professionFullName = professionInfo.professionName
	local craftingPage = ProfessionsFrame.CraftingPage
	local schematicForm = craftingPage.SchematicForm

	if not string.find(professionFullName, "Dragon Isles") then
		return nil
	end


	recipeData.profession = professionInfo.parentProfessionName
	local recipeInfo = schematicForm:GetRecipeInfo()

	if recipeInfo.isRecraft then
        --print("is recraft")
		CraftSimFRAME:ToggleFrames(false)
		return nil
	end

	if recipeInfo.isGatheringRecipe then
		--print("is gathering recipe")
		CraftSimFRAME:ToggleFrames(false)
		return nil
	end

	local details = schematicForm.Details
	local operationInfo = details.operationInfo

    if operationInfo == nil then
        return nil
    end

	local bonusStats = operationInfo.bonusStats

	local currentTransaction = schematicForm:GetTransaction()
	

	recipeData.reagents = {}
	for slotIndex, currentSlot in pairs(C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false).reagentSlotSchematics) do
		local reagents = currentSlot.reagents
		local reagentType = currentSlot.reagentType
		-- for now only consider the required reagents
		if reagentType ~= CraftSimCONST.REAGENT_TYPE.REQUIRED then
			break
		end
		local hasMoreThanOneQuality = currentSlot.reagents[2] ~= nil
		local reagentName = GetItemInfo(reagents[1].itemID)
		recipeData.reagents[slotIndex] = {
			name = reagentName,
			requiredQuantity = currentSlot.quantityRequired,
			differentQualities = reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED and hasMoreThanOneQuality,
			reagentType = currentSlot.reagentType
		}
		local slotAllocations = currentTransaction:GetAllocations(slotIndex)
		local currentSelected = slotAllocations:Accumulate()
		if reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED then --and currentSelected == currentSlot.quantityRequired then
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
		end
		
	end
	recipeData.stats = {}
	for _, statInfo in pairs(bonusStats) do
		local statName = string.lower(statInfo.bonusStatName)
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

	recipeData.expectedQuality = details.craftingQuality
	recipeData.maxQuality = recipeInfo.maxQuality
	recipeData.baseItemAmount = schematicForm.OutputIcon.Count:GetText()
	recipeData.recipeDifficulty = operationInfo.baseDifficulty + operationInfo.bonusDifficulty
	 -- baseSkill is like the base of the players skill and bonusSkill is what is added through reagents
	recipeData.stats.skill = operationInfo.baseSkill + operationInfo.bonusSkill
	recipeData.stats.baseSkill = operationInfo.baseSkill -- Needed for reagent optimization
	recipeData.result = {}

	if recipeInfo.qualityItemIDs then
		-- recipe is anything that results in 1-5 different itemids
		recipeData.result.itemIDs = {
			recipeInfo.qualityItemIDs[1],
			recipeInfo.qualityItemIDs[2],
			recipeInfo.qualityItemIDs[3],
			recipeInfo.qualityItemIDs[4],
			recipeInfo.qualityItemIDs[5]}

	elseif CraftSimUTIL:isRecipeProducingGear(recipeInfo) then
		recipeData.result.itemID = CraftSimUTIL:GetItemIDByLink(recipeInfo.hyperlink)
		recipeData.result.isGear = true
		local allocationItemGUID = currentTransaction:GetAllocationItemGUID()
		local craftingReagentInfoTbl = currentTransaction:CreateCraftingReagentInfoTbl()
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, craftingReagentInfoTbl, allocationItemGUID)
		recipeData.result.hyperlink = outputItemData.hyperlink
		local baseIlvl = recipeInfo.itemLevel
		recipeData.result.itemQualityLinks = CraftSimDATAEXPORT:GetDifferentQualityLinksByLink(outputItemData.hyperlink)
		recipeData.result.baseILvL = baseIlvl
	elseif not recipeInfo.supportsQualities then
		-- Probably something like transmuting air reagent that creates non equip stuff without qualities
		recipeData.result.itemID = CraftSimUTIL:GetItemIDByLink(recipeInfo.hyperlink)
		recipeData.result.isNoQuality = true
	end
	
	return recipeData
end

function CraftSimDATAEXPORT:GetProfessionGearStatsByLink(itemLink)
	-- TODO: how to get skill increase?
	local extractedStats = GetItemStats(itemLink)
	local stats = {}

	for statKey, value in pairs(extractedStats) do
		if CraftSimCONST.STAT_MAP[statKey] ~= nil then
			stats[CraftSimCONST.STAT_MAP[statKey]] = value
		end
	end

	stats.skill = 0 -- TODO

	return stats
end

function CraftSimDATAEXPORT:GetCurrentProfessionItemStats()
	local stats = {
		inspiration = 0,
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