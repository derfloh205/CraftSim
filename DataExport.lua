CraftSimDATAEXPORT = {}

local REAGENT_TYPE = {
	OPTIONAL = 0,
	REQUIRED = 1,
	FINISHING_REAGENT = 2
}

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
        print("is recraft")
		return nil
	end

	local details = schematicForm.Details
	local operationInfo = details.operationInfo

    if operationInfo == nil then
        print("no operation info")
        return nil
    end

	local bonusStats = operationInfo.bonusStats

	recipeData.reagents = {}
	for reagentIndex, currentSlot in pairs(C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false).reagentSlotSchematics) do
		local reagents = currentSlot.reagents
		local reagentType = currentSlot.reagentType
		-- for now only consider the required reagents
		if reagentType ~= REAGENT_TYPE.REQUIRED then
			break
		end
		local hasMoreThanOneQuality = currentSlot.reagents[2] ~= nil
		recipeData.reagents[reagentIndex] = {
			requiredQuantity = currentSlot.quantityRequired,
			differentQualities = reagentType == REAGENT_TYPE.REQUIRED and hasMoreThanOneQuality,
			reagentType = currentSlot.reagentType
		}

		if reagentType == REAGENT_TYPE.REQUIRED then
			recipeData.reagents[reagentIndex].itemsInfo = {}
			for i, reagent in pairs(reagents) do
				table.insert(recipeData.reagents[reagentIndex].itemsInfo, {
					itemID = reagent.itemID
					-- TODO: add current assigned quantity by player here
				})
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
	recipeData.recipeDifficulty = operationInfo.baseDifficulty -- TODO: is .bonusDifficulty needed here for anything? maybe this is for reagents?
	recipeData.stats.skill = operationInfo.baseSkill -- TODO: is .bonusSkill needed here for anything? maybe this is for reagents?
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
		local baseIlvl = recipeInfo.itemLevel
		recipeData.result.itemLvLs = {
			baseIlvl,
			baseIlvl + recipeInfo.qualityIlvlBonuses[2],
			baseIlvl + recipeInfo.qualityIlvlBonuses[3],
			baseIlvl + recipeInfo.qualityIlvlBonuses[4],
			baseIlvl + recipeInfo.qualityIlvlBonuses[5]
		}
	end
	
	return recipeData
end