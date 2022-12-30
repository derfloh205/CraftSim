CraftSimCALC = {}

function CraftSimCALC:handleInspiration(recipeData, priceData, crafts, craftedItems, calculationData)
    local inspirationCanUpgrade = false
    calculationData.inspiration = {}

    if recipeData.expectedQuality ~= recipeData.maxQuality and recipeData.stats.inspiration ~= nil then
        local qualityThresholds = CraftSimSTATS:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty)
        local qualityUpgradeThreshold = qualityThresholds[recipeData.expectedQuality]

        inspirationCanUpgrade = (recipeData.stats.skill + recipeData.stats.inspiration.bonusskill) >= qualityUpgradeThreshold
    end
    if inspirationCanUpgrade then
        -- Recipe considers inspiration and inspiration upgrades are possible
        local inspirationProcs = (recipeData.stats.inspiration.percent / 100)

        crafts.baseQuality = 1 - inspirationProcs -- 1 was numCrafts earlier..
        crafts.nextQuality = inspirationProcs

        craftedItems.baseQuality = recipeData.baseItemAmount - (inspirationProcs * recipeData.baseItemAmount)
        craftedItems.nextQuality = inspirationProcs * recipeData.baseItemAmount
    else
        craftedItems.baseQuality = recipeData.baseItemAmount
        crafts.baseQuality = 1
    end
    calculationData.inspiration.averageInspirationItemsCurrent = craftedItems.baseQuality
    calculationData.inspiration.averageInspirationItemsHigher = craftedItems.nextQuality or 0
    calculationData.inspiration.inspirationItemsValueCurrent = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality]
    calculationData.inspiration.inspirationItemsValueHigher = craftedItems.nextQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1] or 0)
end

function CraftSimCALC:handleMulticraft(recipeData, priceData, crafts, craftedItems, calculationData)
    if recipeData.stats.multicraft ~= nil then
        calculationData.multicraft = {}
        -- Recipe considers multicraft
        -- TODO implement multicraft additional item chance/amount based on multicraft tracker data
        -- For now just use a random value of 1-2.5y additional items at mean
        local expectedAdditionalItems = (1 + (2.5*recipeData.baseItemAmount)) / 2 
        -- Also add any additional items factor
        expectedAdditionalItems = expectedAdditionalItems * (recipeData.extraItemFactors.multicraftBonusItemsFactor or 1)

        -- Since multicraft and inspiration can proc together add expected multicraft gain to both qualities
        local multicraftProcsBase = crafts.baseQuality*(recipeData.stats.multicraft.percent / 100)
        local multicraftProcsNext = crafts.nextQuality*(recipeData.stats.multicraft.percent / 100)
        local expectedExtraItemsBase = multicraftProcsBase * expectedAdditionalItems
        local expectedExtraItemsNext = multicraftProcsNext * expectedAdditionalItems
        craftedItems.baseQuality = craftedItems.baseQuality + expectedExtraItemsBase
        craftedItems.nextQuality = craftedItems.nextQuality + expectedExtraItemsNext

        calculationData.multicraft.averageMulticraftItemsCurrent = expectedExtraItemsBase
        calculationData.multicraft.averageMulticraftItemsHigher = expectedExtraItemsNext

        calculationData.multicraft.averageMulticraftCurrentValue = expectedExtraItemsBase * priceData.minBuyoutPerQuality[recipeData.expectedQuality]

        if recipeData.expectedQuality < recipeData.maxQuality then
            calculationData.multicraft.averageMulticraftHigherValue = expectedExtraItemsNext * priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1]
        end
    end
end

-- TODO: get all possible procs of saved reagents and calculate the mean profit between them
function CraftSimCALC:getResourcefulnessSavedCostsV2(recipeData, priceData, calculationData)
    local savedCosts = 0
    if recipeData.stats.resourcefulness ~= nil then
        calculationData.resourcefulness = {}
        local totalReagents = {}
        for reagentIndex, reagentData in pairs(recipeData.reagents) do
            if reagentData.reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
                    local itemsInfo = CopyTable(reagentData.itemsInfo)
                    local totalAllocations = 0
                    for _, itemInfo in pairs(itemsInfo) do
                        totalAllocations = totalAllocations + itemInfo.allocations
                        itemInfo.differentQualities = reagentData.differentQualities
                        itemInfo.requiredQuantity = reagentData.requiredQuantity
                    end

                    if totalAllocations == 0 then
                        -- not enough items, assume maxquantity with lowest price quality
                        local lowestCostQualityID = CraftSimPRICEDATA:GetLowestCostQualityIDByItemsInfo(reagentData.itemsInfo)
                        itemsInfo[lowestCostQualityID].allocations = reagentData.requiredQuantity
                    end

                    for _, itemInfo in pairs(itemsInfo) do
                        if itemInfo.allocations > 0 then
                            table.insert(totalReagents, itemInfo)
                        end
                    end
            end
        end

        local numReagents =  #totalReagents

        local bitMax = ""
        for i = 1, numReagents, 1 do
            bitMax = bitMax .. "1"
        end
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSimUTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        -- for each possible combination get the chance of it occuring and the material costs of it
        local procChancePerMaterial = recipeData.stats.resourcefulness.percent / 100
        local negativeChancePerMaterial = 1 - procChancePerMaterial
        local averageSavedCostsByCombination = {}
        for _, combination in pairs(totalCombinations) do
            local chance = 1
            local combinationCraftingCost = 0
            for materialIndex, bit in pairs(combination) do
                local bitChance = bit == 1 and procChancePerMaterial or bit == 0 and negativeChancePerMaterial
                chance = chance * bitChance
                local materialCost = CraftSimPRICEDATA:GetMinBuyoutByItemID(totalReagents[materialIndex].itemID, true)
                local materialAllocations = totalReagents[materialIndex].allocations
                if bit == 1 then
                    -- TODO: factor in required quantity ? How to do this with different qualities?
                    -- use the lower quantity = min 1 saved "rule" for non quality materials for now
                    if totalReagents[materialIndex].differentQualities then
                        -- Save 30% of this material costs plus the specced addition if it was procced
                        materialCost = materialCost * materialAllocations
                        materialCost = materialCost * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * (recipeData.extraItemFactors.resourcefulnessBonusItemsFactor or 1)) 
                    else
                        local savedMats = materialAllocations * CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR
                        if savedMats < 1 then
                            -- If 30% of a material would put us below 1, then assume that 1 is saved on average plus any bonus
                            materialCost = materialCost * (recipeData.extraItemFactors.resourcefulnessBonusItemsFactor or 1)
                        else
                            -- if is >= 1 then just take the usual 0.3% of all allocatins and bonus
                            materialCost = materialCost * materialAllocations
                            materialCost = materialCost * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * (recipeData.extraItemFactors.resourcefulnessBonusItemsFactor or 1))
                        end
                    end
                else
                    -- if the material was not procced then we save nothing
                    materialCost = 0
                end
                -- the value of this combination
                combinationCraftingCost = combinationCraftingCost + materialCost
                -- we get the average contributing value of this combination by multiplying it with its chance to occur
                combinationCraftingCost = combinationCraftingCost * chance
            end
            table.insert(averageSavedCostsByCombination, combinationCraftingCost)
            --print("chance/cost for " .. table.concat(combination, "") .. ": " .. CraftSimUTIL:round(chance * 100, 5) .. "% -> " .. CraftSimUTIL:FormatMoney(combinationCraftingCost))
        end

        -- now we sum up all the little contributions to the total average
        for _, avgSavedCost in pairs(averageSavedCostsByCombination) do
            savedCosts = savedCosts + avgSavedCost
        end
        -- this is actually too much, cause the average is already based and weighted by the different chances of occurance
        -- THX to Kroge for pointing that out!
        --savedCosts = savedCosts / #averageSavedCostsByCombination
    end

    if calculationData.resourcefulness then
        calculationData.resourcefulness.averageSavedCosts = savedCosts
    end

    return savedCosts
end

function CraftSimCALC:getResourcefulnessSavedCostsV1(recipeData, priceData)
    local totalSavedCosts = 0
    if recipeData.stats.resourcefulness ~= nil then
        -- Recipe considers resourcefulness
        -- For each craft save a resource by X% Chance
        -- -> This means I need to calculate the total amount of allocated reagents (per quality..?) used for all crafts then take X% of it to be saved
        -- -> Then for all saved resources, sum up the minbuyouts and remove that from the totalCraftingCosts for it to be considered in the meanProfit
        -- TODO: research how resourcefulness behaves with different allocated qualities

        local totalReagentAllocationsByQuality = {}
        for reagentIndex, reagentData in pairs(recipeData.reagents) do
            if reagentData.reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
                totalReagentAllocationsByQuality[reagentIndex] = CopyTable(reagentData.itemsInfo)
                    local totalAllocations = 0
                    for _, itemInfo in pairs(totalReagentAllocationsByQuality[reagentIndex]) do
                        totalAllocations = totalAllocations + itemInfo.allocations
                        itemInfo.allocations = itemInfo.allocations
                    end

                    if totalAllocations == 0 then
                        -- not enough items, assume maxquantity with lowest price quality
                        -- TODO: maybe show a warning or smth?
                        local lowestCostQualityID = CraftSimPRICEDATA:GetLowestCostQualityIDByItemsInfo(reagentData.itemsInfo)
                        totalReagentAllocationsByQuality[reagentIndex][lowestCostQualityID].allocations = reagentData.requiredQuantity
                    end
            end
        end

        for reagentIndex, itemsInfo in pairs(totalReagentAllocationsByQuality) do
            for qualityIndex, itemInfo in pairs(itemsInfo) do
                local savedItems = itemInfo.allocations * (recipeData.stats.resourcefulness.percent / 100)
                -- test
                savedItems = savedItems * CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR
                savedItems = savedItems * recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
                --
                totalSavedCosts = totalSavedCosts + priceData.reagentsPriceByQuality[reagentIndex][qualityIndex].minBuyout * savedItems
            end
        end
    end

    return totalSavedCosts
end

function CraftSimCALC:getMeanProfit(recipeData, priceData)
    local craftedItems = {
        baseQuality = 0,
        nextQuality = 0
    }
    local crafts = {
        baseQuality = 0,
        nextQuality = 0
    }

    local calculationData = {
        inspiration = nil,
        multicraft = nil,
        resourcefulness = nil
    }

    CraftSimCALC:handleInspiration(recipeData, priceData, crafts, craftedItems, calculationData)
    CraftSimCALC:handleMulticraft(recipeData, priceData, crafts, craftedItems, calculationData)

    local totalSavedCosts = CraftSimCALC:getResourcefulnessSavedCostsV2(recipeData, priceData, calculationData)

    local totalCraftingCosts = priceData.craftingCostPerCraft - totalSavedCosts
    local totalWorth = 0
    if recipeData.expectedQuality == recipeData.maxQuality or recipeData.result.isNoQuality then
        totalWorth = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality]
    else
        totalWorth = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality] + 
            craftedItems.nextQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1]
    end
    local meanProfit = ((totalWorth*CraftSim.CONST.AUCTION_HOUSE_CUT) - totalCraftingCosts)

    calculationData.craftingCostPerCraft = totalCraftingCosts

    return meanProfit, calculationData
end