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

	local recipeReagents = {}
	for k, currentSlot in pairs(C_TradeSkillUI.GetRecipeSchematic(recipeInfo.recipeID, false).reagentSlotSchematics) do
		local reagents = currentSlot.reagents
		local reagentType = currentSlot.reagentType
		-- for now only consider the required reagents
		if reagentType ~= REAGENT_TYPE.REQUIRED then
			break
		end
		recipeReagents[k] = {
			required = currentSlot.quantityRequired,
			differentQualities = reagentType == REAGENT_TYPE.REQUIRED and currentSlot.reagents[2] ~= nil,
			reagentType = currentSlot.reagentType
		}

		if reagentType == REAGENT_TYPE.REQUIRED and currentSlot.reagents[2] ~= nil then
			recipeReagents[k].itemsInfo = {}
			for i, reagent in pairs(reagents) do
				table.insert(recipeReagents[k].itemsInfo, {
					itemID = reagent.itemID
				})
			end
		else 
			recipeReagents[k].itemID = currentSlot.reagents[1].itemID
		end
		
	end
	for reagentIndex, reagentData in pairs(recipeReagents) do
		recipeData["reagent" .. reagentIndex .. "Name"] = name
		recipeData["reagent" .. reagentIndex .. "Required"] = reagentData.required
		if reagentData.differentQualities then
			recipeData["reagent" .. reagentIndex .. "q1ID"] = reagentData.itemsInfo[1].itemID
			recipeData["reagent" .. reagentIndex .. "q2ID"] = reagentData.itemsInfo[2].itemID
			recipeData["reagent" .. reagentIndex .. "q3ID"] = reagentData.itemsInfo[3].itemID
		else
			recipeData["reagent" .. reagentIndex .. "ID"] = itemID
		end
	end
	

	for k, statInfo in pairs(bonusStats) do
		local statName = statInfo.bonusStatName
		recipeData[statName .. "Value"] = statInfo.bonusStatValue
		recipeData[statName .. "Description"] = statInfo.ratingDescription
		recipeData[statName .. "Percent"] = statInfo.ratingPct
		if statName == 'Inspiration' then
			-- matches a row of numbers coming after the % character and any characters in between plus a space, should hopefully match in every localization...
			local _, _, bonusSkill = string.find(statInfo.ratingDescription, "%%.* (%d+)") 
			recipeData[statName .. "SkillBonus"] = bonusSkill
			--print("inspirationbonusskill: " .. tostring(bonusSkill))
		end
	end

	recipeData["expectedQuality"] = details.craftingQuality
	recipeData["maxQuality"] = recipeInfo.maxQuality
	recipeData["baseItemAmount"] = schematicForm.OutputIcon.Count:GetText()
	recipeData["recipeDifficulty"] = operationInfo.baseDifficulty -- TODO: is .bonusDifficulty needed here for anything? maybe this is for reagents?
	recipeData["playerSkill"] = operationInfo.baseSkill -- TODO: is .bonusSkill needed here for anything? maybe this is for reagents?
	if recipeInfo.qualityItemIDs then
		-- recipe is anything that results in 1-5 different itemids
		recipeData["resultItemID1"] = recipeInfo.qualityItemIDs[1]
		recipeData["resultItemID2"] = recipeInfo.qualityItemIDs[2]
		recipeData["resultItemID3"] = recipeInfo.qualityItemIDs[3]
		recipeData["resultItemID4"] = recipeInfo.qualityItemIDs[4]
		recipeData["resultItemID5"] = recipeInfo.qualityItemIDs[5]
	elseif recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil then
		-- recipe is gear
		recipeData["resultItemID1"] = CraftSimUTIL:GetItemIDByLink(recipeInfo.hyperlink)
		recipeData["isGear"] = true
		local baseIlvl = recipeInfo.itemLevel
		recipeData["resultItemLvL1"] = baseIlvl
		recipeData["resultItemLvl2"] = baseIlvl + recipeInfo.qualityIlvlBonuses[2]
		recipeData["resultItemLvl3"] = baseIlvl + recipeInfo.qualityIlvlBonuses[3]
		if recipeInfo.maxQuality >= 3 then
			-- dunno if this isnt always the case, but just to be sure
			recipeData["resultItemLvl4"] = baseIlvl + recipeInfo.qualityIlvlBonuses[4]
			recipeData["resultItemLvl5"] = baseIlvl + recipeInfo.qualityIlvlBonuses[5]
		end
	end
	
	return recipeData
end