CraftSimAddonName, CraftSim = ...

CraftSim.TOPGEAR = {}
CraftSim.TOPGEAR.IsEquipping = false
CraftSim.TOPGEAR.EMPTY_SLOT = "EMPTY_SLOT"

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOP_GEAR)

CraftSim.TOPGEAR.SIM_MODES = {
    PROFIT = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT,
    SKILL = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL,
    INSPIRATION = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_INSPIRATION,
    MULTICRAFT = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT,
    RESOURCEFULNESS = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS,
    CRAFTING_SPEED = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED
}

function CraftSim.TOPGEAR:GetSimMode(simMode) 
    return CraftSim.LOCAL:GetText(simMode)
end

function CraftSim.TOPGEAR:UnequipProfessionItems(professionID)
    local professionSlots = C_TradeSkillUI.GetProfessionSlots(professionID)
    -- TODO: factor in remaining inventory space?

    for _, currentSlot in pairs(professionSlots) do
        PickupInventoryItem(currentSlot)
        PutItemInBackpack();
    end
end

function CraftSim.TOPGEAR:EquipTopGear()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local topGearFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    else
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    end
    if topGearFrame.currentTopResult then
        topGearFrame.currentTopResult.professionGearSet:Equip()
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndType(recipeData)
    local availableModes = {}

    table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT)) -- profit should now also always be available since overwriting prices is always possible

    if recipeData.supportsQualities then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL))
    end

    if recipeData.supportsInspiration then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.INSPIRATION))
    end

    if recipeData.supportsMulticraft then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.MULTICRAFT))
    end

    if recipeData.supportsResourcefulness then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.RESOURCEFULNESS))
    end

    -- crafting speed should always be able to sim cause it is always available even if not shown in details
    table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.CRAFTING_SPEED))
    
    return availableModes
end

function CraftSim.TOPGEAR:GetValidCombosFromUniqueCombos(uniqueCombos)
    local validCombos = {}
    for _, combo in pairs(uniqueCombos) do
        -- combo[1] is the tool always, we have only one slot anyway
        if combo[2] == CraftSim.TOPGEAR.EMPTY_SLOT or combo[3] == CraftSim.TOPGEAR.EMPTY_SLOT then
            table.insert(validCombos, {combo[1], combo[2], combo[3]})
        else
            local id2 = combo[2].item:GetItemID()
            local id3 = combo[3].item:GetItemID()

            local _, limitName2, limitCount2 = C_Item.GetItemUniquenessByID(id2)
            local _, limitName3, limitCount3 = C_Item.GetItemUniquenessByID(id3)
            
            if limitName2 ~= nil and limitCount2 >= 1 and limitName3 ~= nil and limitCount3 >= 1 then
                --print("comparing limits: " .. limitName2 .. " == " .. limitName3)
                if limitName2 ~= limitName3 then
                    table.insert(validCombos, {combo[1], combo[2], combo[3]})
                end
            end
        end
    end
    return validCombos
end

function CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutations(totalCombos, isCooking)
    local uniqueCombos = {}
    local EMPTY = CraftSim.TOPGEAR.EMPTY_SLOT

    for _, comboA in pairs(totalCombos) do
        -- combination can have 3 entry where each is either empty or a professionGear
        local toolA = comboA[1]
        local gear1A = comboA[2]
        local gear2A = comboA[3]

        local inserted = CraftSim.GUTIL:Find(uniqueCombos, function(comboB)
        
            if not isCooking then
                local toolB = comboB[1]
                local gear1B = comboB[2]
                local gear2B = comboB[3]
        
                local existsGear1 = gear1A == EMPTY and (gear1B == EMPTY or gear2B == EMPTY)
                if not existsGear1 then
                    existsGear1 = (gear1B ~= EMPTY and gear1B:Equals(gear1A)) or (gear2B ~= EMPTY and gear2B:Equals(gear1A))
                end
    
                local existsGear2 = gear2A == EMPTY and (gear1B == EMPTY or gear2B == EMPTY)
                if not existsGear2 then
                    existsGear2 = (gear1B ~= EMPTY and gear1B:Equals(gear2A)) or (gear2B ~= EMPTY and gear2B:Equals(gear2A))
                end
    
                local existsTool = toolA == EMPTY and toolB == EMPTY
                if not existsTool then
                    existsTool = toolB ~= EMPTY and toolB:Equals(toolA)
                end
    
                if existsGear1 and existsGear2 and existsTool then
                    -- print("found matching combo..")
                    return true
                end
    
                return false
            else
                local toolB = comboB[1]
                local gear1B = comboB[2]
        
                local existsGear = gear1A == EMPTY and gear1B == EMPTY
                if not existsGear then
                    existsGear = gear1B ~= EMPTY and gear1B:Equals(gear1A)
                end
    
                local existsTool = toolA == EMPTY and toolB == EMPTY
                if not existsTool then
                    existsTool = toolB ~= EMPTY and toolB:Equals(toolA)
                end
    
                if existsGear and existsTool then
                    return true
                end
    
                return false
            end
        end)

        if not inserted then
            table.insert(uniqueCombos, comboA)
        end
    end

    return uniqueCombos
end

---@return CraftSim.ProfessionGearSet[] inventoryGear
function CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
	local currentProfession = recipeData.professionData.professionInfo.parentProfessionName
	local inventoryGear = {}

	for bag=BANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		for slot=1,C_Container.GetContainerNumSlots(bag) do
			local itemLink = C_Container.GetContainerItemLink(bag, slot)
			if itemLink ~= nil then
				local itemSubType = select(3, GetItemInfoInstant(itemLink))
				if itemSubType == currentProfession then
                    local professionGear = CraftSim.ProfessionGear()
                    professionGear:SetItem(itemLink)
					table.insert(inventoryGear, professionGear)
				end
			end
		end
	end
	return inventoryGear
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.ProfessionGearSet[] topGearSets
function CraftSim.TOPGEAR:GetProfessionGearCombinations(recipeData)
    local equippedGear = CraftSim.ProfessionGearSet(recipeData.professionData.professionInfo.profession)
    equippedGear:LoadCurrentEquippedSet()
    local inventoryGear =  CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)

    local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(), function(gear) return gear and gear.item ~= nil end)

    if #equippedGearList == 0 and #inventoryGear == 0 then
        return {}
    end

    local allGear = CraftSim.GUTIL:Concat({inventoryGear, equippedGearList})

    -- remove duplicated items (with same stats, this means the link should be the same..)
    local uniqueGear = {}
    for _, professionGear in pairs(allGear) do
        if not CraftSim.GUTIL:Find(uniqueGear, function(gear) return gear.item:GetItemLink() == professionGear.item:GetItemLink() end) then
            table.insert(uniqueGear, professionGear)
        end
    end

    allGear = uniqueGear
    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local gearSlotItems = CraftSim.GUTIL:Filter(allGear, function (gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType end)
    local toolSlotItems = CraftSim.GUTIL:Filter(allGear, function (gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType end)
    table.insert(gearSlotItems, CraftSim.TOPGEAR.EMPTY_SLOT)
    table.insert(toolSlotItems, CraftSim.TOPGEAR.EMPTY_SLOT)

    -- permutate the gearslot items to get all combinations of two

    -- if cooking we do not need to make any combinations cause we only have one gear slot
    local gearSlotCombos = {}

    if not recipeData.isCooking then
        for _, professionGearA in pairs(gearSlotItems) do
            for _, professionGearB in pairs(gearSlotItems) do
                local emptyA = professionGearA == CraftSim.TOPGEAR.EMPTY_SLOT
                local emptyB = professionGearB == CraftSim.TOPGEAR.EMPTY_SLOT
                local bothEmpty = emptyA and emptyB
                local partlyEmpty = emptyA or emptyB
                if bothEmpty or (partlyEmpty or not professionGearA:Equals(professionGearB)) then
                    -- do not match item with itself..
                    -- todo: somehow neglect order cause it is not important (maybe with temp list to remove items from..)
                    table.insert(gearSlotCombos, {professionGearA, professionGearB})
                end
            end
        end
    else
        gearSlotCombos = gearSlotItems
    end
    

    -- then permutate those combinations with the tool items to get all available gear combos
    -- if cooking just combine 1 gear with tool
    local totalCombos = {}

    if not recipeData.isCooking then
        for _, combo in pairs(gearSlotCombos) do
            for _, tool in pairs(toolSlotItems) do
                table.insert(totalCombos, {tool, combo[1], combo[2]})
            end
        end
    else
        for _, combo in pairs(gearSlotCombos) do
            for _, tool in pairs(toolSlotItems) do
                table.insert(totalCombos, {tool, combo})
            end
        end
    end
    

    local uniqueCombos = CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutations(totalCombos, recipeData.isCooking)

    local function convertToProfessionGearSet(combos)
        return CraftSim.GUTIL:Map(combos, function (combo)
            local professionGearSet = CraftSim.ProfessionGearSet(recipeData.professionData.professionInfo.profession)
            local tool = combo[1]
            local gear1 = combo[2]
            local gear2 = combo[3]
            if recipeData.isCooking then
                if tool ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.tool = tool
                end
                if gear1 ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.gear2 = gear1
                end
            else
                if tool ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.tool = tool
                end
                if gear1 ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.gear1 = gear1
                end
                if gear2 ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.gear2 = gear2
                end
            end

            professionGearSet:UpdateProfessionStats()
            return professionGearSet
        end)
    end
    

    -- Remove invalid combos (with two gear items that share the same unique equipped restriction)
    -- only needed if not cooking
    if not recipeData.isCooking then
        local validCombos = CraftSim.TOPGEAR:GetValidCombosFromUniqueCombos(uniqueCombos)
        return convertToProfessionGearSet(validCombos)
    else
        return convertToProfessionGearSet(uniqueCombos)
    end
end

---@return CraftSim.TopGearResult[] topGearResults
function CraftSim.TOPGEAR:OptimizeTopGear(recipeData, topGearMode)
    topGearMode = topGearMode or CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT)
    local combinations = CraftSim.TOPGEAR:GetProfessionGearCombinations(recipeData)

    local previousGear = recipeData.professionGearSet
    local averageProfitPreviousGear = CraftSim.CALC:GetAverageProfit(recipeData)

    -- convert to top gear results
    local results = CraftSim.GUTIL:Map(combinations, function(professionGearSet)
        recipeData.professionGearSet = professionGearSet
        recipeData:Update()
        local averageProfit = CraftSim.CALC:GetAverageProfit(recipeData)
        local relativeProfit = averageProfit - averageProfitPreviousGear
        local relativeStats = professionGearSet.professionStats:Copy()
        local expectedQuality = recipeData.resultData.expectedQuality
        local expectedQualityUpgrade = recipeData.resultData.expectedQualityUpgrade
        relativeStats:subtract(previousGear.professionStats)
        local result = CraftSim.TopGearResult(professionGearSet, averageProfit, relativeProfit, relativeStats, expectedQuality, expectedQualityUpgrade)
        return result
    end)

    -- revert recipe data
    recipeData.professionGearSet = previousGear
    recipeData:Update()

    -- sort results by selected mode
    if topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT) then
        print("Top Gear Mode: Profit")
        results = CraftSim.GUTIL:Sort(results, function (resultA, resultB)
            return resultA.averageProfit > resultB.averageProfit
        end)
        results = CraftSim.GUTIL:Filter(results, function (result)
            -- should have at least 1 copper profit (and not some small decimal)
            local gold, silver, copper = CraftSim.GUTIL:GetMoneyValuesFromCopper(result.relativeProfit)
            return (gold + silver + copper) > 0
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.INSPIRATION) then
        print("Top Gear Mode: Inspiration")
        results = CraftSim.GUTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.inspiration.value > resultB.professionGearSet.professionStats.inspiration.value
        end)
        results = CraftSim.GUTIL:Filter(results, function (result)
            return result.relativeStats.inspiration.value > 0
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.MULTICRAFT) then
        print("Top Gear Mode: Multicraft")
        results = CraftSim.GUTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.multicraft.value > resultB.professionGearSet.professionStats.multicraft.value
        end)
        results = CraftSim.GUTIL:Filter(results, function (result)
            return result.relativeStats.multicraft.value > 0
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.RESOURCEFULNESS) then
        print("Top Gear Mode: Resourcefulness")
        results = CraftSim.GUTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.resourcefulness.value > resultB.professionGearSet.professionStats.resourcefulness.value
        end)
        results = CraftSim.GUTIL:Filter(results, function (result)
            return result.relativeStats.resourcefulness.value > 0
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.CRAFTING_SPEED) then
        print("Top Gear Mode: Craftingspeed")
        results = CraftSim.GUTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.craftingspeed.value > resultB.professionGearSet.professionStats.craftingspeed.value
        end)
        results = CraftSim.GUTIL:Filter(results, function (result)
            return result.relativeStats.craftingspeed.value > 0
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL) then
        print("Top Gear Mode: Skill")
        results = CraftSim.GUTIL:Sort(results, function (resultA, resultB)
            local maxSkillA = resultA.professionGearSet.professionStats.skill.value + resultA.professionGearSet.professionStats.inspiration:GetExtraValueByFactor()
            local maxSkillB = resultB.professionGearSet.professionStats.skill.value + resultB.professionGearSet.professionStats.inspiration:GetExtraValueByFactor()
            return maxSkillA > maxSkillB
        end)
    end

    return results
end

function CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
    local results = self:OptimizeTopGear(recipeData, CraftSimOptions.topGearMode)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local hasResults = #results > 0
    
    if hasResults and not recipeData.professionGearSet:Equals(results[1].professionGearSet) then
        print("best result")
        print(results[1])
        CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplay(results, CraftSimOptions.topGearMode, exportMode)
    else
        CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(recipeData, false, exportMode)
    end
end