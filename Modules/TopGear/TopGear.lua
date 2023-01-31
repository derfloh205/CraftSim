AddonName, CraftSim = ...

CraftSim.TOPGEAR = {}

CraftSim.TOPGEAR.IsEquipping = false

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
    local topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    CraftSim.TOPGEAR.IsEquipping = true
    local combo = topGearFrame.currentCombo
    if combo == nil then
        --print("no combo yet")
        return
    end
    -- first unequip everything
    CraftSim.TOPGEAR:UnequipProfessionItems(CraftSim.MAIN.currentRecipeData.professionID)
    -- then wait a sec to let it unequip TODO: (maybe wait for specific event for each eqipped item to combat lag?)
    C_Timer.After(1, CraftSim.TOPGEAR.EquipBestCombo)
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