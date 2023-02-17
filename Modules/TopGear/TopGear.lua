AddonName, CraftSim = ...

CraftSim.TOPGEAR = {}
CraftSim.TOPGEAR.IsEquipping = false
CraftSim.TOPGEAR.EMPTY_SLOT = "EMPTY_SLOT"

function CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutations(totalCombos, isCooking)
    local uniqueCombos = {}
    local combinationList = {}

    if not isCooking then
        local function checkIfCombinationExists(combinationToTest)
            for _, combination in pairs(combinationList) do
                local exists1 = false
                local exists2 = false   
                local exists3 = false
                for _, itemLink in pairs(combination) do 
                    if combinationToTest[1] == itemLink then
                        exists1 = true
                    elseif combinationToTest[2] == itemLink then
                        exists2 = true
                    elseif combinationToTest[3] == itemLink then
                        exists3 = true
                    end
                end
                if exists1 and exists2 and exists3 then
                    --print("found existing combo..")
                    return true
                end
            end
            --print("combo not existing..")
            return false
        end
    
        for _, combo in pairs(totalCombos) do
            -- check if combinationList of itemLinks already exists in combinationList
            -- write the itemLink of an empty slot as "empty"
            local link1 = combo[1].itemLink
            local link2 = combo[2].itemLink
            local link3 = combo[3].itemLink
            local comboTuple = {link1, link2, link3}
            if not checkIfCombinationExists(comboTuple) then
                table.insert(combinationList, comboTuple)
                table.insert(uniqueCombos, combo)
            end
        end
    else
        local function checkIfCombinationExists(combinationToTest)
            for _, combination in pairs(combinationList) do
                local exists1 = false
                local exists2 = false   
                for _, itemLink in pairs(combination) do 
                    if combinationToTest[1] == itemLink then
                        exists1 = true
                    elseif combinationToTest[2] == itemLink then
                        exists2 = true
                    end
                end
                if exists1 and exists2 then
                    --print("found existing combo..")
                    return true
                end
            end
            --print("combo not existing..")
            return false
        end
    
        for _, combo in pairs(totalCombos) do
            -- check if combinationList of itemLinks already exists in combinationList
            -- write the itemLink of an empty slot as "empty"
            local link1 = combo[1].itemLink
            local link2 = combo[2].itemLink
            local comboTuple = {link1, link2}
            if not checkIfCombinationExists(comboTuple) then
                table.insert(combinationList, comboTuple)
                table.insert(uniqueCombos, combo)
            end
        end
    end

    return uniqueCombos
end

function CraftSim.TOPGEAR:GetValidCombosFromUniqueCombos(uniqueCombos)
    local validCombos = {}
    for _, combo in pairs(uniqueCombos) do
        -- combo[1] is the tool always, we have only one slot anyway
        if combo[2].isEmptySlot or combo[3].isEmptySlot then
            table.insert(validCombos, {combo[1], combo[2], combo[3]})
        else
            local id2 = combo[2].itemID
            local id3 = combo[3].itemID

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

function CraftSim.TOPGEAR:GetProfessionGearCombinations(isCooking)
    local equippedGear = CraftSim.DATAEXPORT:GetEquippedProfessionGear(CraftSim.MAIN.currentRecipeData.professionID)
    local inventoryGear =  CraftSim.DATAEXPORT:GetProfessionGearFromInventory()

    if #equippedGear == 0 and #inventoryGear == 0 then
        return nil
    end

    local allGear = inventoryGear
    for _, gear in pairs(equippedGear) do
        table.insert(allGear, gear)
    end
    -- remove duplicated items (with same stats, this means the link should be the same..)
    local uniqueGear = {}
    for _, gear in pairs(allGear) do
        if uniqueGear[gear.itemLink] == nil then
            uniqueGear[gear.itemLink] = gear
        end
    end
    allGear = uniqueGear

    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local gearSlotItems = {{isEmptySlot = true, itemLink = CraftSim.CONST.EMPTY_SLOT_LINK}}
    local toolSlotItems = {{isEmptySlot = true,  itemLink = CraftSim.CONST.EMPTY_SLOT_LINK}}

    for _, gear in pairs(allGear) do
        --print("checking slot of gear: " .. gear.itemLink)
        --print("slot: " .. gear.equipSlot)
        if gear.equipSlot == CraftSim.CONST.PROFESSIONTOOL_INV_TYPES.GEAR then
            table.insert(gearSlotItems, gear)
        elseif gear.equipSlot == CraftSim.CONST.PROFESSIONTOOL_INV_TYPES.TOOL then
            table.insert(toolSlotItems, gear)
        end
    end

    -- permutate the gearslot items to get all combinations of two

    -- if cooking we do not need to make any combinations cause we only have one gear slot
    local gearSlotCombos = {}

    if not isCooking then
        for key, gear in pairs(gearSlotItems) do
            for subkey, subgear in pairs(gearSlotItems) do
                if subkey ~= key then
                    -- do not match item with itself..
                    -- todo: somehow neglect order cause it is not important (maybe with temp list to remove items from..)
                    table.insert(gearSlotCombos, {gear, subgear})
                end
            end
        end
    else
        gearSlotCombos = gearSlotItems
    end
    

    -- then permutate those combinations with the tool items to get all available gear combos
    -- if cooking just combine 1 gear with tool
    local totalCombos = {}

    if not isCooking then
        for _, gearcombo in pairs(gearSlotCombos) do
            for _, tool in pairs(toolSlotItems) do
                table.insert(totalCombos, {tool, gearcombo[1], gearcombo[2]})
            end
        end
    else
        for _, gearcombo in pairs(gearSlotCombos) do
            for _, tool in pairs(toolSlotItems) do
                table.insert(totalCombos, {tool, gearcombo})
            end
        end
    end
    

    local uniqueCombos = CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutations(totalCombos, isCooking)
    

    -- Remove invalid combos (with two gear items that share the same unique equipped restriction)
    -- only needed if not cooking
    if not isCooking then
        return CraftSim.TOPGEAR:GetValidCombosFromUniqueCombos(uniqueCombos)
    else
        return uniqueCombos
    end
end

function CraftSim.TOPGEAR:GetStatChangesFromGearCombination(gearCombination)
    local stats = {
        inspiration = 0,
        inspirationBonusSkillPercent = 0,
        multicraft = 0,
        resourcefulness = 0,
        craftingspeed = 0,
        skill = 0
    }

    for _, gearItem in pairs(gearCombination) do
        if not gearItem.isEmptySlot then
            if gearItem.itemStats.inspiration ~= nil then
                stats.inspiration = stats.inspiration + gearItem.itemStats.inspiration
            end
            if gearItem.itemStats.multicraft ~= nil then
                stats.multicraft = stats.multicraft + gearItem.itemStats.multicraft
            end
            if gearItem.itemStats.resourcefulness ~= nil then
                stats.resourcefulness = stats.resourcefulness + gearItem.itemStats.resourcefulness
            end

            if gearItem.itemStats.craftingspeed ~= nil then
                stats.craftingspeed = stats.craftingspeed + gearItem.itemStats.craftingspeed
            end
            if gearItem.itemStats.skill ~= nil then
                stats.skill = stats.skill + gearItem.itemStats.skill
            end
            if gearItem.itemStats.inspirationBonusSkillPercent then
				-- additive or multiplicative? or dont care cause multiple items cannot have this bonus?
				stats.inspirationBonusSkillPercent = stats.inspirationBonusSkillPercent + gearItem.itemStats.inspirationBonusSkillPercent 
			end
        end
    end
    return stats
end

function CraftSim.TOPGEAR:GetModifiedRecipeDataByStatChanges(recipeData, recipeType, statChanges)
    local modifiedRecipeData = CopyTable(recipeData)
    if modifiedRecipeData.stats.inspiration ~= nil then
        modifiedRecipeData.stats.inspiration.value = modifiedRecipeData.stats.inspiration.value + statChanges.inspiration
        modifiedRecipeData.stats.inspiration.percent = modifiedRecipeData.stats.inspiration.percent + CraftSim.UTIL:GetInspirationPercentByStat(statChanges.inspiration)*100
        modifiedRecipeData.stats.inspiration.bonusskill = modifiedRecipeData.stats.inspiration.bonusskill * (1 + statChanges.inspirationBonusSkillPercent / 100)
    end
    if modifiedRecipeData.stats.multicraft ~= nil then
        modifiedRecipeData.stats.multicraft.value = modifiedRecipeData.stats.multicraft.value + statChanges.multicraft
        modifiedRecipeData.stats.multicraft.percent = modifiedRecipeData.stats.multicraft.percent + CraftSim.UTIL:GetMulticraftPercentByStat(statChanges.multicraft)*100 
    end
    if modifiedRecipeData.stats.resourcefulness ~= nil then
        modifiedRecipeData.stats.resourcefulness.value = modifiedRecipeData.stats.resourcefulness.value + statChanges.resourcefulness
        modifiedRecipeData.stats.resourcefulness.percent = modifiedRecipeData.stats.resourcefulness.percent + 
            CraftSim.UTIL:GetResourcefulnessPercentByStat(statChanges.resourcefulness)*100 
    end
    if modifiedRecipeData.stats.craftingspeed ~= nil then
        modifiedRecipeData.stats.craftingspeed.value = modifiedRecipeData.stats.craftingspeed.value + statChanges.craftingspeed
        modifiedRecipeData.stats.craftingspeed.percent = modifiedRecipeData.stats.craftingspeed.percent + 
            CraftSim.UTIL:GetCraftingSpeedPercentByStat(statChanges.craftingspeed)*100 
    end

    if modifiedRecipeData.stats.skill ~= nil and 
        recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE and 
        recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
        modifiedRecipeData.stats.skill = modifiedRecipeData.stats.skill + statChanges.skill
        local expectedQualityWithItems = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(modifiedRecipeData, modifiedRecipeData.stats.skill, true)
        --print("expectedQ with Items: " .. tostring(expectedQualityWithItems))
        local oldexpected = modifiedRecipeData.expectedQuality
        modifiedRecipeData.expectedQuality = expectedQualityWithItems
        if oldexpected < expectedQualityWithItems then
            --print("Combination with increased quality level found!")
        end
    end

    return modifiedRecipeData
end

function CraftSim.TOPGEAR:SimulateProfessionGearCombinations(gearCombos, recipeData, recipeType, priceData, baseProfit)
    local results = {}

    for _, gearCombination in pairs(gearCombos) do
        local statChanges = CraftSim.TOPGEAR:GetStatChangesFromGearCombination(gearCombination)
        local modifiedRecipeData = CraftSim.TOPGEAR:GetModifiedRecipeDataByStatChanges(recipeData, recipeType, statChanges)
        local meanProfit = CraftSim.CALC:getMeanProfit(modifiedRecipeData, priceData)
        local profitDiff = meanProfit - baseProfit
        table.insert(results, {
            meanProfit = meanProfit,
            profitDiff = profitDiff,
            combo = gearCombination,
            modifiedRecipeData = modifiedRecipeData
        })
    end

    return results
end

function CraftSim.TOPGEAR:AddStatDiffByBaseRecipeData(bestSimulation, recipeData)
    bestSimulation.statDiff = {}
    if bestSimulation.modifiedRecipeData.stats.inspiration ~= nil then
        bestSimulation.statDiff.inspiration = bestSimulation.modifiedRecipeData.stats.inspiration.percent - recipeData.stats.inspiration.percent

        if recipeData.stats.inspiration.bonusskill then
            bestSimulation.statDiff.inspirationBonusskill = bestSimulation.modifiedRecipeData.stats.inspiration.bonusskill - recipeData.stats.inspiration.bonusskill
        end
    end
    if bestSimulation.modifiedRecipeData.stats.multicraft ~= nil then
        bestSimulation.statDiff.multicraft = bestSimulation.modifiedRecipeData.stats.multicraft.percent - recipeData.stats.multicraft.percent
    end
    if bestSimulation.modifiedRecipeData.stats.resourcefulness ~= nil then
        bestSimulation.statDiff.resourcefulness = bestSimulation.modifiedRecipeData.stats.resourcefulness.percent - recipeData.stats.resourcefulness.percent
    end
    if bestSimulation.modifiedRecipeData.stats.skill ~= nil then
        bestSimulation.statDiff.skill = bestSimulation.modifiedRecipeData.stats.skill - recipeData.stats.skill
    end
    if bestSimulation.modifiedRecipeData.stats.craftingspeed ~= nil then
        bestSimulation.statDiff.craftingspeed = bestSimulation.modifiedRecipeData.stats.craftingspeed.percent - recipeData.stats.craftingspeed.percent
    end
end

function CraftSim.TOPGEAR:DeductCurrentItemStats(recipeData, recipeType)
    local itemStats = CraftSim.DATAEXPORT:GetCurrentProfessionItemStats(recipeData.professionID)
    local noItemRecipeData = CopyTable(recipeData)

    if noItemRecipeData.stats.inspiration ~= nil then
        noItemRecipeData.stats.inspiration.value = noItemRecipeData.stats.inspiration.value - itemStats.inspiration
        noItemRecipeData.stats.inspiration.percent = noItemRecipeData.stats.inspiration.percent - CraftSim.UTIL:GetInspirationPercentByStat(itemStats.inspiration)*100
        noItemRecipeData.stats.inspiration.bonusskill = noItemRecipeData.stats.inspiration.bonusskill / (1 + itemStats.inspirationBonusSkillPercent / 100)
    end
    if noItemRecipeData.stats.multicraft ~= nil then
        noItemRecipeData.stats.multicraft.value = noItemRecipeData.stats.multicraft.value - itemStats.multicraft
        noItemRecipeData.stats.multicraft.percent = noItemRecipeData.stats.multicraft.percent - CraftSim.UTIL:GetMulticraftPercentByStat(itemStats.multicraft)*100
    end
    if noItemRecipeData.stats.resourcefulness ~= nil then
        noItemRecipeData.stats.resourcefulness.value = noItemRecipeData.stats.resourcefulness.value - itemStats.resourcefulness
        noItemRecipeData.stats.resourcefulness.percent = noItemRecipeData.stats.resourcefulness.percent - CraftSim.UTIL:GetResourcefulnessPercentByStat(itemStats.resourcefulness)*100
    end
    if noItemRecipeData.stats.craftingspeed ~= nil then
        noItemRecipeData.stats.craftingspeed.value = noItemRecipeData.stats.craftingspeed.value - itemStats.craftingspeed
        noItemRecipeData.stats.craftingspeed.percent = noItemRecipeData.stats.craftingspeed.percent - CraftSim.UTIL:GetCraftingSpeedPercentByStat(itemStats.craftingspeed)*100
    end
    if noItemRecipeData.stats.skill ~= nil and 
        recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE and 
        recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE then
        noItemRecipeData.stats.skill = noItemRecipeData.stats.skill - itemStats.skill

        -- recalculate expected quality in case it decreases..
        local expectedQualityWithoutItems = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(noItemRecipeData, noItemRecipeData.stats.skill)
        --print("expectedQ with Items: " .. tostring(expectedQualityWithItems))
        local oldexpected = noItemRecipeData.expectedQuality
        noItemRecipeData.expectedQuality = expectedQualityWithoutItems
        if oldexpected > expectedQualityWithoutItems then
            --print("no items would decrease quality level!")
        end

    end

    return noItemRecipeData
end

function CraftSim.TOPGEAR:SimulateBestProfessionGearCombination(recipeData, recipeType, priceData, exportMode, topGearModeOverride)
    local isCooking = recipeData.professionID == Enum.Profession.Cooking

    local gearCombos = CraftSim.TOPGEAR:GetProfessionGearCombinations(isCooking)

    if not gearCombos then
        CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(isCooking, false, exportMode)
        return
    end

    local noItemsRecipeData = CraftSim.TOPGEAR:DeductCurrentItemStats(recipeData, recipeType)

    local topGearMode = topGearModeOverride or CraftSimOptions.topGearMode
    
    if exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
        topGearMode = CraftSim.CONST.GEAR_SIM_MODES.PROFIT
    end

    if topGearMode == CraftSim.CONST.GEAR_SIM_MODES.PROFIT then
        local currentComboMeanProfit = CraftSim.CALC:getMeanProfit(recipeData, priceData)
        CraftSim.UTIL:StartProfiling("Top Gear_CombinationSim")
        local simulationResults = CraftSim.TOPGEAR:SimulateProfessionGearCombinations(gearCombos, noItemsRecipeData, recipeType, priceData, currentComboMeanProfit)
        CraftSim.UTIL:StopProfiling("Top Gear_CombinationSim")

        local validSimulationResults = simulationResults

        -- set the initial best combo as the current equipped combo!
        -- this leads to only better combos or combos with more items slotted being displayed
        local equippedSimResult = CraftSim.TOPGEAR:GetEquippedSimResult(validSimulationResults, isCooking)
        local bestSimulation = equippedSimResult
        local foundBetter = false
        for index, simResult in pairs(validSimulationResults) do
            --print("Gearcombo " .. index .. " meanProfit: " .. simResult.meanProfit)
            if simResult.profitDiff > bestSimulation.profitDiff or
                simResult.profitDiff == bestSimulation.profitDiff and CraftSim.TOPGEAR:hasMoreSlotsThan(simResult.combo, bestSimulation.combo) then
                bestSimulation = simResult
                foundBetter = true
            end
            -- else just keep the current set best set
        end

        if foundBetter then
            CraftSim.TOPGEAR:AddStatDiffByBaseRecipeData(bestSimulation, recipeData)
            CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplay(bestSimulation, topGearMode, isCooking, exportMode)
            return bestSimulation
        else
            CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(isCooking, false, exportMode)
            return nil
        end
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.SKILL then
        local equippedCombo = CraftSim.TOPGEAR:GetEquippedCombo(isCooking)
        local bestSimulation =  {
            combo = equippedCombo,
            modifiedRecipeData = recipeData
        }
        local foundBetter = false
        for _, combo in pairs(gearCombos) do
            local statChanges = CraftSim.TOPGEAR:GetStatChangesFromGearCombination(combo)
            local modifiedRecipeData = CraftSim.TOPGEAR:GetModifiedRecipeDataByStatChanges(noItemsRecipeData, recipeType, statChanges)

            if modifiedRecipeData.stats.skill > bestSimulation.modifiedRecipeData.stats.skill
                or modifiedRecipeData.stats.skill == bestSimulation.modifiedRecipeData.stats.skill 
                and CraftSim.TOPGEAR:hasMoreSlotsThan(combo, bestSimulation.combo) then
                bestSimulation = {
                    combo = combo,
                    modifiedRecipeData = modifiedRecipeData,
                    skill = modifiedRecipeData.stats.skill
                }
                foundBetter = true
            end
        end

        if foundBetter then
            CraftSim.TOPGEAR:AddStatDiffByBaseRecipeData(bestSimulation, recipeData)
            CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplay(bestSimulation, topGearMode, isCooking, exportMode)
            return bestSimulation
        else
            CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(isCooking, false, exportMode)
            return nil
        end
    elseif 
        topGearMode == CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION or 
        topGearMode == CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT or 
        topGearMode == CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED or 
        topGearMode == CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS or 
        topGearMode == CraftSim.CONST.GEAR_SIM_MODES.SKILL
     then
        local statName = CraftSim.TOPGEAR:GetRelevantStatNameByTopGearMode(topGearMode)
        local equippedCombo = CraftSim.TOPGEAR:GetEquippedCombo(isCooking)
        local bestSimulation =  {
            combo = equippedCombo,
            modifiedRecipeData = recipeData
        }
        local foundBetter = false
        for _, combo in pairs(gearCombos) do
            local statChanges = CraftSim.TOPGEAR:GetStatChangesFromGearCombination(combo)
            local modifiedRecipeData = CraftSim.TOPGEAR:GetModifiedRecipeDataByStatChanges(noItemsRecipeData, recipeType, statChanges)

            if modifiedRecipeData.stats[statName] and (modifiedRecipeData.stats[statName].value > bestSimulation.modifiedRecipeData.stats[statName].value
                or modifiedRecipeData.stats[statName].value == bestSimulation.modifiedRecipeData.stats[statName].value
                and CraftSim.TOPGEAR:hasMoreSlotsThan(combo, bestSimulation.combo)) then
                bestSimulation = {
                    combo = combo,
                    modifiedRecipeData = modifiedRecipeData,
                }
                bestSimulation[statName] = modifiedRecipeData.stats[statName].value
                if statName ~= "skill" then
                    bestSimulation[statName .. "Percent"] = modifiedRecipeData.stats[statName].percent
                end
                foundBetter = true
            end
        end

        if foundBetter then
            CraftSim.TOPGEAR:AddStatDiffByBaseRecipeData(bestSimulation, recipeData)
            CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplay(bestSimulation, topGearMode, isCooking, exportMode)
            return bestSimulation
        else
            CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(isCooking, false, exportMode)
            return nil
        end
    end

end

function CraftSim.TOPGEAR:hasMoreSlotsThan(comboOne, comboTwo)
    return CraftSim.TOPGEAR:countEmptySlots(comboOne) < CraftSim.TOPGEAR:countEmptySlots(comboTwo)
end

function CraftSim.TOPGEAR:countEmptySlots(combo)
    local numEmpty = 0
    for _, slot in pairs(combo) do
        if slot.isEmptySlot then
            numEmpty = numEmpty + 1
        end
    end
    return numEmpty
end

function CraftSim.TOPGEAR:GetEquippedSimResult(simulationResults, isCooking)
    local equippedCombo = CraftSim.TOPGEAR:GetEquippedCombo(isCooking)

    if not isCooking then
        for _, result in pairs(simulationResults) do
            local foundSlot1 = false
            local foundSlot2 = false
            local foundSlot3 = false
    
            for _, slot in pairs(result.combo) do
                if slot.itemLink == equippedCombo[1].itemLink then
                    foundSlot1 = true
                end
                if slot.itemLink == equippedCombo[2].itemLink then
                    foundSlot2 = true
                end
                if slot.itemLink == equippedCombo[3].itemLink then
                    foundSlot3 = true
                end
            end
    
            if foundSlot1 and foundSlot2 and foundSlot3 then
                --print("found currently equipped simulation result!")
                return result
            end
        end
    else
        for _, result in pairs(simulationResults) do
            local foundSlot1 = false
            local foundSlot2 = false
    
            for _, slot in pairs(result.combo) do
                if slot.itemLink == equippedCombo[1].itemLink then
                    foundSlot1 = true
                end
                if slot.itemLink == equippedCombo[2].itemLink then
                    foundSlot2 = true
                end
            end
    
            if foundSlot1 and foundSlot2 then
                --print("found currently equipped simulation result!")
                return result
            end
        end
    end
    -- can happen when window closes..
end

function CraftSim.TOPGEAR:GetEquippedCombo(isCooking)
    -- set the initial best combo as the current equipped combo!
    local equippedGear = CraftSim.DATAEXPORT:GetEquippedProfessionGear(CraftSim.MAIN.currentRecipeData.professionID)
    local equippedCombo = {}
    local emptySlots = 3 - #equippedGear
    if isCooking then
        emptySlots = 2 - #equippedGear
    end
    for i = 1, emptySlots, 1 do
        table.insert(equippedCombo, {isEmptySlot = true, itemLink = CraftSim.CONST.EMPTY_SLOT_LINK})
    end

    for _, gear in pairs(equippedGear) do
        table.insert(equippedCombo, {itemLink = gear.itemLink})
    end

    return equippedCombo
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
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    else
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    end
    if topGearFrame.currentTopResult then
        topGearFrame.currentTopResult.professionGearSet:Equip()
    end
end

function CraftSim.TOPGEAR:EquipBestCombo()
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    local combo = topGearFrame.currentCombo
    for _, item in pairs(combo) do
        if not item.isEmptySlot then
            --print("eqipping: " .. item.itemLink)
            CraftSim.UTIL:EquipItemByLink(item.itemLink)
            EquipPendingItem(0)
        end
    end

    CraftSim.TOPGEAR.IsEquipping = false
end

function CraftSim.TOPGEAR:GetRelevantStatNameByTopGearMode(mode)
    if mode == CraftSim.CONST.GEAR_SIM_MODES.SKILL then
        return "skill"
    elseif mode == CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION then
        return "inspiration"
    elseif mode == CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT then
        return "multicraft"
    elseif mode == CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        return "craftingspeed"
    elseif mode == CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        return "resourcefulness"
    end
end

function CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndType(recipeData, recipeType)
    local availableModes = {}

    table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.PROFIT) -- profit should now also always be available since overwriting prices is always possible

    if recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.MULTIPLE or 
    recipeType == CraftSim.CONST.RECIPE_TYPES.SINGLE or recipeType == CraftSim.CONST.RECIPE_TYPES.ENCHANT then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.SKILL)
    elseif recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.SKILL)
    elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then

    elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_ITEM then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.SKILL)
    end

    if recipeData.stats.inspiration then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION)
    end

    if recipeData.stats.multicraft then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT)
    end

    if recipeData.stats.resourcefulness then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS)
    end

    -- crafting speed should always be able to sim cause it is always available even if not shown in details
    table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED)
    
    return availableModes
end

-- OOP Refactor

---@param recipeData CraftSim.RecipeData
function CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndTypeOOP(recipeData)
    local availableModes = {}

    table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.PROFIT) -- profit should now also always be available since overwriting prices is always possible

    if recipeData.supportsQualities then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.SKILL)
    end

    if recipeData.supportsInspiration then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION)
    end

    if recipeData.supportsMulticraft then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT)
    end

    if recipeData.supportsResourcefulness then
        table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS)
    end

    -- crafting speed should always be able to sim cause it is always available even if not shown in details
    table.insert(availableModes, CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED)
    
    return availableModes
end

function CraftSim.TOPGEAR:GetValidCombosFromUniqueCombosOOP(uniqueCombos)
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

function CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutationsOOP(totalCombos, isCooking)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOPGEAR_OOP)
    local uniqueCombos = {}
    local EMPTY = CraftSim.TOPGEAR.EMPTY_SLOT

    for _, comboA in pairs(totalCombos) do
        -- combination can have 3 entry where each is either empty or a professionGear
        local toolA = comboA[1]
        local gear1A = comboA[2]
        local gear2A = comboA[3]

        local inserted = CraftSim.UTIL:Find(uniqueCombos, function(comboB)
        
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
        
                local existsGear = gear2A == EMPTY and gear1B == EMPTY
                if not existsGear then
                    existsGear = gear1B ~= EMPTY and gear1B:Equals(gear2A)
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
function CraftSim.TOPGEAR:GetProfessionGearFromInventoryOOP(recipeData)
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
function CraftSim.TOPGEAR:GetProfessionGearCombinationsOOP(recipeData)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOPGEAR_OOP)
    local equippedGear = CraftSim.ProfessionGearSet(recipeData.professionData.professionInfo.profession)
    equippedGear:LoadCurrentEquippedSet()
    local inventoryGear =  CraftSim.TOPGEAR:GetProfessionGearFromInventoryOOP(recipeData)

    local equippedGearList = CraftSim.UTIL:FilterTable(equippedGear:GetProfessionGearList(), function(gear) return gear and gear.item ~= nil end)

    if #equippedGearList == 0 and #inventoryGear == 0 then
        return {}
    end

    local allGear = CraftSim.UTIL:Concat({inventoryGear, equippedGearList})

    -- remove duplicated items (with same stats, this means the link should be the same..)
    local uniqueGear = {}
    for _, professionGear in pairs(allGear) do
        if not CraftSim.UTIL:Find(uniqueGear, function(gear) return gear.item:GetItemLink() == professionGear.item:GetItemLink() end) then
            table.insert(uniqueGear, professionGear)
        end
    end

    allGear = uniqueGear
    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local gearSlotItems = CraftSim.UTIL:FilterTable(allGear, function (gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType end)
    local toolSlotItems = CraftSim.UTIL:FilterTable(allGear, function (gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType end)
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
    

    local uniqueCombos = CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutationsOOP(totalCombos, recipeData.isCooking)

    local function convertToProfessionGearSet(combos)
        return CraftSim.UTIL:Map(combos, function (combo)
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
        local validCombos = CraftSim.TOPGEAR:GetValidCombosFromUniqueCombosOOP(uniqueCombos)
        return convertToProfessionGearSet(validCombos)
    else
        return convertToProfessionGearSet(uniqueCombos)
    end
end

---@return CraftSim.TopGearResult[] topGearResults
function CraftSim.TOPGEAR:OptimizeTopGear(recipeData, topGearMode)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOPGEAR_OOP)
    topGearMode = topGearMode or CraftSim.CONST.GEAR_SIM_MODES.PROFIT
    local combinations = CraftSim.TOPGEAR:GetProfessionGearCombinationsOOP(recipeData)

    local previousGear = recipeData.professionGearSet
    local averageProfitPreviousGear = CraftSim.CALC:GetMeanProfitOOP(recipeData)

    -- convert to top gear results
    local results = CraftSim.UTIL:Map(combinations, function(professionGearSet)
        recipeData.professionGearSet = professionGearSet
        recipeData:Update()
        local averageProfit = CraftSim.CALC:GetMeanProfitOOP(recipeData)
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
    if topGearMode == CraftSim.CONST.GEAR_SIM_MODES.PROFIT then
        print("Top Gear Mode: Profit")
        results = CraftSim.UTIL:Sort(results, function (resultA, resultB)
            return resultA.averageProfit > resultB.averageProfit
        end)
        results = CraftSim.UTIL:FilterTable(results, function (result)
            -- should have at least 1 copper profit (and not some small decimal)
            local gold, silver, copper = CraftSim.UTIL:GetMoneyValuesFromCopper(result.relativeProfit)
            return (gold + silver + copper) > 0
        end)
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION then
        print("Top Gear Mode: Inspiration")
        results = CraftSim.UTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.inspiration.value > resultB.professionGearSet.professionStats.inspiration.value
        end)
        results = CraftSim.UTIL:FilterTable(results, function (result)
            return result.relativeStats.inspiration.value > 0
        end)
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT then
        print("Top Gear Mode: Multicraft")
        results = CraftSim.UTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.multicraft.value > resultB.professionGearSet.professionStats.multicraft.value
        end)
        results = CraftSim.UTIL:FilterTable(results, function (result)
            return result.relativeStats.multicraft.value > 0
        end)
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        print("Top Gear Mode: Resourcefulness")
        results = CraftSim.UTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.resourcefulness.value > resultB.professionGearSet.professionStats.resourcefulness.value
        end)
        results = CraftSim.UTIL:FilterTable(results, function (result)
            return result.relativeStats.resourcefulness.value > 0
        end)
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        print("Top Gear Mode: Craftingspeed")
        results = CraftSim.UTIL:Sort(results, function (resultA, resultB)
            return resultA.professionGearSet.professionStats.craftingspeed.value > resultB.professionGearSet.professionStats.craftingspeed.value
        end)
        results = CraftSim.UTIL:FilterTable(results, function (result)
            return result.relativeStats.craftingspeed.value > 0
        end)
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.SKILL then
        print("Top Gear Mode: Skill")
        results = CraftSim.UTIL:Sort(results, function (resultA, resultB)
            local maxSkillA = resultA.professionGearSet.professionStats.skill.value + resultA.professionGearSet.professionStats.inspiration:GetExtraValueByFactor()
            local maxSkillB = resultB.professionGearSet.professionStats.skill.value + resultB.professionGearSet.professionStats.inspiration:GetExtraValueByFactor()
            return maxSkillA > maxSkillB
        end)
    end

    return results
end

function CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOPGEAR_OOP)
    local results = self:OptimizeTopGear(recipeData, CraftSimOptions.topGearMode)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local hasResults = #results > 0
    
    if hasResults and not recipeData.professionGearSet:Equals(results[1].professionGearSet) then
        print("best result")
        print(results[1])
        CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplayOOP(results, CraftSimOptions.topGearMode, exportMode)
    else
        CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(recipeData.isCooking, false, exportMode)
    end
end