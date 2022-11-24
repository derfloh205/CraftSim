CraftSimGEARSIM = {}

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
    -- local equippedGear = CraftSimDATAEXPORT:GetEquippedProfessionGear()
    -- APPROACH: consider inventory only for now
    local inventoryGear =  CraftSimDATAEXPORT:GetProfessionGearFromInventory()

    -- remove duplicated items (with same stats, this means the link should be the same..)
    local setInventoryGear = {}
    for _, gear in pairs(inventoryGear) do
        if setInventoryGear[gear.itemLink] == nil then
            setInventoryGear[gear.itemLink] = gear
        end
    end
    inventoryGear = setInventoryGear

    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local gearSlotItems = {{isEmptySlot = true, itemLink = CraftSimCONST.EMPTY_SLOT_LINK}}
    local toolSlotItems = {{isEmptySlot = true,  itemLink = CraftSimCONST.EMPTY_SLOT_LINK}}

    for _, gear in pairs(inventoryGear) do
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
        modifedRecipeData.stats.inspiration.percent = modifedRecipeData.stats.inspiration.percent + CraftSimUTIL:GetInspirationPercentByStat(statChanges.inspiration) 
    end
    if modifedRecipeData.stats.multicraft ~= nil then
        modifedRecipeData.stats.multicraft.value = modifedRecipeData.stats.multicraft.value + statChanges.multicraft
        modifedRecipeData.stats.multicraft.percent = modifedRecipeData.stats.multicraft.percent + CraftSimUTIL:GetMulticraftPercentByStat(statChanges.multicraft) 
    end
    if modifedRecipeData.stats.resourcefulness ~= nil then
        modifedRecipeData.stats.resourcefulness.value = modifedRecipeData.stats.resourcefulness.value + statChanges.resourcefulness
        modifedRecipeData.stats.resourcefulness.percent = modifedRecipeData.stats.resourcefulness.percent + 
            CraftSimUTIL:GetResourcefulnessPercentByStat(statChanges.resourcefulness) 
    end
    -- TODO: check if this is already included in stat table ?
    -- TODO: to make changes of this have impact, need to evaluate the expectedQuality by player skill and quality thresholds..
    -- TODO: also, need to extract skill changes from profession gear anyway
    if modifedRecipeData.stats.skill ~= nil then
        modifedRecipeData.stats.skill = modifedRecipeData.stats.skill + statChanges.skill
    end

    return modifedRecipeData
end

function CraftSimGEARSIM:SimulateProfessionGearCombinations(gearCombos, recipeData, priceData, baseProfit)
    local results = {}

    for _, gearCombination in pairs(gearCombos) do
        local statChanges = CraftSimGEARSIM:GetStatChangesFromGearCombination(gearCombination)
        local modifedRecipeData = CraftSimGEARSIM:GetModifiedRecipeDataByStatChanges(recipeData, statChanges)

        local meanProfit = CraftSimSTATS:getMeanProfit(modifedRecipeData, priceData)
        local profitDiff = meanProfit - baseProfit
        table.insert(results, {
            meanProfit = meanProfit,
            profitDiff = profitDiff,
            combo = gearCombination
        })
    end

    return results
end

function CraftSimGEARSIM:SimulateBestProfessionGearCombination()
    -- unequip all professiontools and just get from inventory for easier equipping/listing?
    local recipeData = CraftSimDATAEXPORT:exportRecipeData()

    if recipeData == nil then
        return
    end

    if CraftSimUTIL:isRecipeNotProducingItem(recipeData) then
        return
    end

    if CraftSimUTIL:isRecipeProducingSoulbound(recipeData) then
        return
    end

    if recipeData.baseItemAmount == nil then
        -- when only one item is produced the baseItemAmount will be nil as this comes form the number of items produced shown in the ui
        recipeData.baseItemAmount = 1
    end


    local priceData = CraftSimPRICEDATA:GetPriceData(recipeData)
    local gearCombos = CraftSimGEARSIM:GetProfessionGearCombinations()

    local baseProfit = CraftSimSTATS:getMeanProfit(recipeData, priceData)
    local simulationResults = CraftSimGEARSIM:SimulateProfessionGearCombinations(gearCombos, recipeData, priceData, baseProfit)

    -- TODO: filter out everything with a profitDiff of zero or less (does not make sense to display as top gear)
    local validSimulationResults = {}
    for _, simResult in pairs(simulationResults) do
        if simResult.profitDiff > 0 then
            table.insert(validSimulationResults, simResult)
        end
    end

    local bestSimulation = nil
    for index, simResult in pairs(validSimulationResults) do
        --print("Gearcombo " .. index .. " meanProfit: " .. simResult.meanProfit)
        if bestSimulation == nil or simResult.profitDiff > bestSimulation.profitDiff then
            bestSimulation = simResult
        end
    end

    if bestSimulation ~= nil then
        CraftSimFRAME:FillSimResultData(bestSimulation)
        --print("Best Profit Combination: " .. bestSimulation.meanProfit)
        --print("Tool: " .. tostring(bestSimulation.combo[1].itemLink))
        --print("Accessory 1: " .. tostring(bestSimulation.combo[2].itemLink))
        --print("Accessory 1: " .. tostring(bestSimulation.combo[3].itemLink))
    else
        --print("no best simulation found")
        CraftSimFRAME:ClearResultData()
    end

    -- TODO: equip the p gear combi of the best simulation ?
end

function CraftSimGEARSIM:EquipBestCombo()
    local combo = CraftSimSimFrame.currentCombo
    if combo == nil then
        --print("no combo yet")
        return
    end

    for _, item in pairs(combo) do
        if not item.isEmptySlot then
            --print("eqipping: " .. item.itemLink)
            CraftSimUTIL:EquipItemByLink(item.itemLink)
            EquipPendingItem(0)
        end
    end
end
