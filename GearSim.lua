CraftSimGEARSIM = {}

CraftSimGEARSIM.IsEquipping = false

function CraftSimGEARSIM:GetUniqueCombosFromAllPermutations(totalCombos)
    local uniqueCombos = {}
    local combinationList = {}

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

    return uniqueCombos
end

function CraftSimGEARSIM:GetValidCombosFromUniqueCombos(uniqueCombos)
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

function CraftSimGEARSIM:GetProfessionGearCombinations()
    local equippedGear = CraftSimDATAEXPORT:GetEquippedProfessionGear()
    local inventoryGear =  CraftSimDATAEXPORT:GetProfessionGearFromInventory()

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
    local gearSlotItems = {{isEmptySlot = true, itemLink = CraftSimCONST.EMPTY_SLOT_LINK}}
    local toolSlotItems = {{isEmptySlot = true,  itemLink = CraftSimCONST.EMPTY_SLOT_LINK}}

    for _, gear in pairs(allGear) do
        --print("checking slot of gear: " .. gear.itemLink)
        --print("slot: " .. gear.equipSlot)
        if gear.equipSlot == CraftSimCONST.PROFESSIONTOOL_INV_TYPES.GEAR then
            table.insert(gearSlotItems, gear)
        elseif gear.equipSlot == CraftSimCONST.PROFESSIONTOOL_INV_TYPES.TOOL then
            table.insert(toolSlotItems, gear)
        end
    end

    -- permutate the gearslot items to get all combinations of two
    local gearSlotCombos = {}
    for key, gear in pairs(gearSlotItems) do
        for subkey, subgear in pairs(gearSlotItems) do
            if subkey ~= key then
                -- do not match item with itself..
                -- todo: somehow neglect order cause it is not important (maybe with temp list to remove items from..)
                table.insert(gearSlotCombos, {gear, subgear})
            end
        end
    end

    -- then permutate those combinations with the tool items to get all available gear combos
    local totalCombos = {}
    for _, gearcombo in pairs(gearSlotCombos) do
        for _, tool in pairs(toolSlotItems) do
            table.insert(totalCombos, {tool, gearcombo[1], gearcombo[2]})
        end
    end

    local uniqueCombos = CraftSimGEARSIM:GetUniqueCombosFromAllPermutations(totalCombos)
    

    -- TODO: remove invalid combos (with two gear items that share the same unique equipped restriction)

    local validCombos = CraftSimGEARSIM:GetValidCombosFromUniqueCombos(uniqueCombos)

    return validCombos
end

function CraftSimGEARSIM:GetStatChangesFromGearCombination(gearCombination)
    local stats = {
        inspiration = 0,
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

            -- below not yet meaningful implemented
            if gearItem.itemStats.craftingspeed ~= nil then
                stats.craftingspeed = stats.craftingspeed + gearItem.itemStats.craftingspeed
            end
            if gearItem.itemStats.skill ~= nil then
                stats.skill = stats.skill + gearItem.itemStats.skill
            end
        end
    end
    return stats
end

function CraftSimGEARSIM:GetModifiedRecipeDataByStatChanges(recipeData, statChanges)
    local modifedRecipeData = CopyTable(recipeData)
    if modifedRecipeData.stats.inspiration ~= nil then
        modifedRecipeData.stats.inspiration.value = modifedRecipeData.stats.inspiration.value + statChanges.inspiration
        modifedRecipeData.stats.inspiration.percent = modifedRecipeData.stats.inspiration.percent + CraftSimUTIL:GetInspirationPercentByStat(statChanges.inspiration)*100 
    end
    if modifedRecipeData.stats.multicraft ~= nil then
        modifedRecipeData.stats.multicraft.value = modifedRecipeData.stats.multicraft.value + statChanges.multicraft
        modifedRecipeData.stats.multicraft.percent = modifedRecipeData.stats.multicraft.percent + CraftSimUTIL:GetMulticraftPercentByStat(statChanges.multicraft)*100 
    end
    if modifedRecipeData.stats.resourcefulness ~= nil then
        modifedRecipeData.stats.resourcefulness.value = modifedRecipeData.stats.resourcefulness.value + statChanges.resourcefulness
        modifedRecipeData.stats.resourcefulness.percent = modifedRecipeData.stats.resourcefulness.percent + 
            CraftSimUTIL:GetResourcefulnessPercentByStat(statChanges.resourcefulness)*100 
    end
    -- TODO: to make changes of this have impact, need to evaluate the expectedQuality by player skill and quality thresholds..
    -- TODO: also, need to extract skill changes from profession gear anyway
    if modifedRecipeData.stats.skill ~= nil then
        modifedRecipeData.stats.skill = modifedRecipeData.stats.skill + statChanges.skill
        local expectedQualityWithItems = CraftSimSTATS:GetExpectedQualityBySkill(modifedRecipeData, modifedRecipeData.stats.skill)
        --print("expectedQ with Items: " .. tostring(expectedQualityWithItems))
        local oldexpected = modifedRecipeData.expectedQuality
        modifedRecipeData.expectedQuality = expectedQualityWithItems
        if oldexpected < expectedQualityWithItems then
            print("Combination with increased quality level found!")
        end
    end

    return modifedRecipeData
end

function CraftSimGEARSIM:SimulateProfessionGearCombinations(gearCombos, recipeData, priceData, baseProfit)
    local results = {}

    for _, gearCombination in pairs(gearCombos) do
        local statChanges = CraftSimGEARSIM:GetStatChangesFromGearCombination(gearCombination)
        local modifiedRecipeData = CraftSimGEARSIM:GetModifiedRecipeDataByStatChanges(recipeData, statChanges)

        local meanProfit = CraftSimSTATS:getMeanProfit(modifiedRecipeData, priceData)
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

function CraftSimGEARSIM:AddStatDiffByBaseRecipeData(bestSimulation, recipeData)
    bestSimulation.statDiff = {}
    if bestSimulation.modifiedRecipeData.stats.inspiration ~= nil then
        bestSimulation.statDiff.inspiration = bestSimulation.modifiedRecipeData.stats.inspiration.percent - recipeData.stats.inspiration.percent
    end
    if bestSimulation.modifiedRecipeData.stats.resourcefulness ~= nil then
        bestSimulation.statDiff.resourcefulness = bestSimulation.modifiedRecipeData.stats.resourcefulness.percent - recipeData.stats.resourcefulness.percent
    end
    if bestSimulation.modifiedRecipeData.stats.resourcefulness ~= nil then
        bestSimulation.statDiff.resourcefulness = bestSimulation.modifiedRecipeData.stats.resourcefulness.percent - recipeData.stats.resourcefulness.percent
    end
    if bestSimulation.modifiedRecipeData.stats.skill ~= nil then
        bestSimulation.statDiff.skill = bestSimulation.modifiedRecipeData.stats.skill - recipeData.stats.skill
    end
end

function CraftSimGEARSIM:DeductCurrentItemStats(recipeData)
    local itemStats = CraftSimDATAEXPORT:GetCurrentProfessionItemStats()
    local noItemRecipeData = CopyTable(recipeData)

    if noItemRecipeData.stats.inspiration ~= nil then
        noItemRecipeData.stats.inspiration.value = noItemRecipeData.stats.inspiration.value - itemStats.inspiration
        noItemRecipeData.stats.inspiration.percent = noItemRecipeData.stats.inspiration.percent - CraftSimUTIL:GetInspirationPercentByStat(itemStats.inspiration)*100
    end
    if noItemRecipeData.stats.multicraft ~= nil then
        noItemRecipeData.stats.multicraft.value = noItemRecipeData.stats.multicraft.value - itemStats.multicraft
        noItemRecipeData.stats.multicraft.percent = noItemRecipeData.stats.multicraft.percent - CraftSimUTIL:GetMulticraftPercentByStat(itemStats.multicraft)*100
    end
    if noItemRecipeData.stats.resourcefulness ~= nil then
        noItemRecipeData.stats.resourcefulness.value = noItemRecipeData.stats.resourcefulness.value - itemStats.resourcefulness
        noItemRecipeData.stats.resourcefulness.percent = noItemRecipeData.stats.resourcefulness.percent - CraftSimUTIL:GetResourcefulnessPercentByStat(itemStats.resourcefulness)*100
    end
    if noItemRecipeData.stats.craftingspeed ~= nil then
        -- TODO: get modifier!!!
        noItemRecipeData.stats.craftingspeed.value = noItemRecipeData.stats.craftingspeed.value --- CraftSimUTIL:GetInspirationPercentByStat(itemStats.craftingspeed)*100
    end
    if noItemRecipeData.stats.skill ~= nil then
        noItemRecipeData.stats.skill = noItemRecipeData.stats.skill - itemStats.skill
    end
    return noItemRecipeData
end

function CraftSimGEARSIM:SimulateBestProfessionGearCombination(recipeData, recipeType, priceData)
    local gearCombos = CraftSimGEARSIM:GetProfessionGearCombinations()

    if not gearCombos then
        CraftSimFRAME:ClearResultData()
        return
    end

    local noItemsRecipeData = CraftSimGEARSIM:DeductCurrentItemStats(recipeData)

    local currentComboMeanProfit = CraftSimSTATS:getMeanProfit(recipeData, priceData)
    local noItemMeanProfit = CraftSimSTATS:getMeanProfit(noItemsRecipeData, priceData)
    local simulationResults = CraftSimGEARSIM:SimulateProfessionGearCombinations(gearCombos, noItemsRecipeData, priceData, currentComboMeanProfit)

    local validSimulationResults = simulationResults

    local function countEmptySlots(combo)
        local numEmpty = 0
        for _, slot in pairs(combo) do
            if slot.isEmptySlot then
                numEmpty = numEmpty + 1
            end
        end
        return numEmpty
    end

    -- set the initial best combo as the current equipped combo!
    -- this leads to only better combos or combos with more items slotted being displayed
    local equippedSimResult = CraftSimGEARSIM:GetEquippedSimResult(validSimulationResults)
    local bestSimulation = equippedSimResult
    local foundBetter = false
    for index, simResult in pairs(validSimulationResults) do
        --print("Gearcombo " .. index .. " meanProfit: " .. simResult.meanProfit)
        if simResult.profitDiff > bestSimulation.profitDiff then
            bestSimulation = simResult
            foundBetter = true
        -- if the profit diff is the same, prefer the sim result with more items set
        elseif simResult.profitDiff == bestSimulation.profitDiff and countEmptySlots(bestSimulation.combo) > countEmptySlots(simResult.combo) then
            --print("sim result has less empty slots.. prefering..")
            foundBetter = true
            bestSimulation = simResult
        end
        -- else just keep the current set best set
    end

    if foundBetter then
        CraftSimGEARSIM:AddStatDiffByBaseRecipeData(bestSimulation, recipeData)
        CraftSimFRAME:FillSimResultData(bestSimulation)
        -- print("Best Profit Combination: " .. bestSimulation.meanProfit)
        -- print("Tool: " .. tostring(bestSimulation.combo[1].itemLink))
        -- print("Accessory 1: " .. tostring(bestSimulation.combo[2].itemLink))
        -- print("Accessory 1: " .. tostring(bestSimulation.combo[3].itemLink))
        -- CraftSimUTIL:PrintTable(bestSimulation.modifiedRecipeData.stats.resourcefulness)
        -- print("-- base:")
        -- CraftSimUTIL:PrintTable(recipeData.stats.resourcefulness)
    else
        --print("no best simulation found")
        CraftSimFRAME:ClearResultData()
    end

    -- TODO: equip the p gear combi of the best simulation ?
end

function CraftSimGEARSIM:GetEquippedSimResult(simulationResults)
    local equippedCombo = CraftSimGEARSIM:GetEquippedCombo()

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

    error("Could not find currently equipped simulation result.. should not happen please contact addon dev")
end

function CraftSimGEARSIM:GetEquippedCombo()
    -- set the initial best combo as the current equipped combo!
    local equippedGear = CraftSimDATAEXPORT:GetEquippedProfessionGear()
    local equippedCombo = {}
    local emptySlots = 3 - #equippedGear
    for i = 1, emptySlots, 1 do
        table.insert(equippedCombo, {isEmptySlot = true, itemLink = CraftSimCONST.EMPTY_SLOT_LINK})
    end

    for _, gear in pairs(equippedGear) do
        table.insert(equippedCombo, {itemLink = gear.itemLink})
    end

    return equippedCombo
end

function CraftSimGEARSIM:UnequipProfessionItems()
    local professionSlots = CraftSimFRAME:GetProfessionEquipSlots()
    -- TODO: factor in remaining inventory space?

    for _, currentSlot in pairs(professionSlots) do
        PickupInventoryItem(GetInventorySlotInfo(currentSlot))
        PutItemInBackpack();
    end
end

function CraftSimGEARSIM:EquipTopGear()
    CraftSimGEARSIM.IsEquipping = true
    local combo = CraftSimSimFrame.currentCombo
    if combo == nil then
        --print("no combo yet")
        return
    end
    -- first unequip everything
    CraftSimGEARSIM:UnequipProfessionItems()
    -- then wait a sec to let it unequip TODO: (maybe wait for specific event for each eqipped item to combat lag?)
    C_Timer.After(1, CraftSimGEARSIM.EquipBestCombo)
end

function CraftSimGEARSIM:EquipBestCombo()
    local combo = CraftSimSimFrame.currentCombo

    for _, item in pairs(combo) do
        if not item.isEmptySlot then
            --print("eqipping: " .. item.itemLink)
            CraftSimUTIL:EquipItemByLink(item.itemLink)
            EquipPendingItem(0)
        end
    end

    CraftSimGEARSIM.IsEquipping = false
end