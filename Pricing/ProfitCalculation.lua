addonName, CraftSim = ...

CraftSim.CALC = {}

local function print(text, recursive) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.PROFIT_CALCULATION, recursive)
end

function CraftSim.CALC:handleInspiration(recipeData, priceData, crafts, craftedItems, calculationData)
    local inspirationCanUpgrade = false
    calculationData.inspiration = {}

    if recipeData.expectedQuality ~= recipeData.maxQuality and recipeData.stats.inspiration ~= nil then
        local qualityThresholds = CraftSim.STATS:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty)
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
    calculationData.inspiration.inspirationItemsValueCurrent = craftedItems.baseQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0)
    calculationData.inspiration.inspirationItemsValueHigher = craftedItems.nextQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1] or 0)
end

function CraftSim.CALC:handleMulticraft(recipeData, priceData, crafts, craftedItems, calculationData)
    if recipeData.stats.multicraft then
        calculationData.multicraft = {}
        -- Recipe considers multicraft
        -- TODO implement multicraft additional item chance/amount based on multicraft tracker data
        -- For now just use a random value of 1-2.5y additional items at mean
        local expectedAdditionalItems = (1 + (2.5*recipeData.baseItemAmount)) / 2 
        -- Also add any additional items factor
        local specData = recipeData.specNodeData
        local multicraftExtraItemsFactor = 1

        if specData then
            multicraftExtraItemsFactor = recipeData.stats.multicraft.extraItemsFactor
        else
            multicraftExtraItemsFactor = recipeData.extraItemFactors.multicraftExtraItemsFactor
        end
        
        expectedAdditionalItems = expectedAdditionalItems * (multicraftExtraItemsFactor or 1)

        -- Since multicraft and inspiration can proc together add expected multicraft gain to both qualities
        local multicraftProcsBase = crafts.baseQuality*(recipeData.stats.multicraft.percent / 100)
        local multicraftProcsNext = crafts.nextQuality*(recipeData.stats.multicraft.percent / 100)
        local expectedExtraItemsBase = multicraftProcsBase * expectedAdditionalItems
        local expectedExtraItemsNext = multicraftProcsNext * expectedAdditionalItems
        craftedItems.baseQuality = craftedItems.baseQuality + expectedExtraItemsBase
        craftedItems.nextQuality = craftedItems.nextQuality + expectedExtraItemsNext

        calculationData.multicraft.averageMulticraftItemsCurrent = expectedExtraItemsBase
        calculationData.multicraft.averageMulticraftItemsHigher = expectedExtraItemsNext

        calculationData.multicraft.averageMulticraftCurrentValue = expectedExtraItemsBase * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0)

        if recipeData.expectedQuality < recipeData.maxQuality then
            calculationData.multicraft.averageMulticraftHigherValue = expectedExtraItemsNext * (priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1] or 0)
        end
    end
end

function CraftSim.CALC:getResourcefulnessSavedCostsV2(recipeData, priceData, calculationData)
    local specData = recipeData.specNodeData
    local resourcefulnessExtraItemsFactor = 1

    if specData then
        resourcefulnessExtraItemsFactor = recipeData.stats.resourcefulness.extraItemsFactor
    else
        resourcefulnessExtraItemsFactor = recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
    end

    if recipeData.salvageReagent then
        return (priceData.salvageReagentPrice * recipeData.salvageReagent.requiredQuantity) * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * (resourcefulnessExtraItemsFactor or 1)) 
    end

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
                        local lowestCostQualityID = CraftSim.PRICEDATA:GetLowestCostQualityIDByItemsInfo(reagentData.itemsInfo)
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
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
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
                local materialCost = CraftSim.PRICEDATA:GetMinBuyoutByItemID(totalReagents[materialIndex].itemID, true)
                local materialAllocations = totalReagents[materialIndex].allocations
                if bit == 1 then
                    -- TODO: factor in required quantity ? How to do this with different qualities?
                    -- use the lower quantity = min 1 saved "rule" for non quality materials for now
                    if totalReagents[materialIndex].differentQualities then
                        -- Save 30% of this material costs plus the specced addition if it was procced
                        materialCost = materialCost * materialAllocations
                        materialCost = materialCost * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * (resourcefulnessExtraItemsFactor or 1)) 
                    else
                        local savedMats = materialAllocations * CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR
                        if savedMats < 1 then
                            -- If 30% of a material would put us below 1, then assume that 1 is saved on average plus any bonus
                            materialCost = materialCost * (resourcefulnessExtraItemsFactor or 1)
                        else
                            -- if is >= 1 then just take the usual 0.3% of all allocatins and bonus
                            materialCost = materialCost * materialAllocations
                            materialCost = materialCost * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * (resourcefulnessExtraItemsFactor or 1))
                        end
                    end
                else
                    -- if the material was not procced then we save nothing
                    materialCost = 0
                end
                -- the value of this combination
                combinationCraftingCost = combinationCraftingCost + materialCost
            end
            -- we get the average contributing value of this combination by multiplying it with its chance to occur
            combinationCraftingCost = combinationCraftingCost * chance
            table.insert(averageSavedCostsByCombination, combinationCraftingCost)
            --print("chance/cost for " .. table.concat(combination, "") .. ": " .. CraftSim.UTIL:round(chance * 100, 5) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationCraftingCost))
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

function CraftSim.CALC:getResourcefulnessSavedCostsV1(recipeData, priceData)
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
                        local lowestCostQualityID = CraftSim.PRICEDATA:GetLowestCostQualityIDByItemsInfo(reagentData.itemsInfo)
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

--V2
function CraftSim.CALC:GetAverageItemsPerCraftByMulticraft(recipeData)
    -- mc only
    local expectedAdditionalItems = (1 + (2.5*recipeData.baseItemAmount)) / 2 
    -- Also add any additional items factor
    local specData = recipeData.specNodeData
    local multicraftExtraItemsFactor = 1

    if specData then
        multicraftExtraItemsFactor = recipeData.stats.multicraft and recipeData.stats.multicraft.extraItemsFactor or 1
    else
        multicraftExtraItemsFactor = recipeData.extraItemFactors and recipeData.extraItemFactors.multicraftExtraItemsFactor or 1
    end
    print("expectedAdditionalItems:" .. expectedAdditionalItems)
    print("Multicraft Extra Items Factor: " .. multicraftExtraItemsFactor)
    local averageAdditionalItemsPerCraft = (recipeData.stats.multicraft.percent / 100) * expectedAdditionalItems * (multicraftExtraItemsFactor or 1)

    return recipeData.baseItemAmount + averageAdditionalItemsPerCraft
end

-- V2
function CraftSim.CALC:GetAverageCraftValueMulticraft(recipeData, priceData)
    local averageItemsPerCraft = CraftSim.CALC:GetAverageItemsPerCraftByMulticraft(recipeData)
    local currentQualityPriceByItem = priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0
    local craftValue = averageItemsPerCraft * currentQualityPriceByItem

    return craftValue
end

--V2
function CraftSim.CALC:GetAverageCraftValueInspirationByItemsPerCraft(recipeData, priceData, itemsPerCraft, baseCraftValue)
    local skillWithInspirationBonus = recipeData.stats.inspiration.bonusskill + recipeData.stats.skill
    local qualityWithInspiration = CraftSim.STATS:GetExpectedQualityBySkill(recipeData, skillWithInspirationBonus)

    if recipeData.expectedQuality == qualityWithInspiration then
        -- Fall back to value with inspiration gain zero
        return baseCraftValue
    end

    local currentQualityPriceByItem = priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0
    local betterQualityPriceByItem = priceData.minBuyoutPerQuality[qualityWithInspiration] or 0

    local itemsCurrentQuality = itemsPerCraft * (1 - (recipeData.stats.inspiration.percent / 100))
    local itemsBetterQuality = itemsPerCraft * (recipeData.stats.inspiration.percent / 100)

    local craftValue = currentQualityPriceByItem * itemsCurrentQuality + betterQualityPriceByItem * itemsBetterQuality

    return craftValue
end

function CraftSim.CALC:GetAverageCraftValueMulticraftInspiration(recipeData, priceData, baseCraftValue)
    local averageItemsPerCraft = CraftSim.CALC:GetAverageItemsPerCraftByMulticraft(recipeData)
    print("averageItemsPerCraftMC: " .. tostring(averageItemsPerCraft))
    local craftValue = CraftSim.CALC:GetAverageCraftValueInspirationByItemsPerCraft(recipeData, priceData, averageItemsPerCraft, baseCraftValue)

    return craftValue
end

function CraftSim.CALC:getMeanProfitV2(recipeData, priceData)
    local calculationData = {
        chanceBase = nil,
        chanceDouble = nil,
        inspiration = recipeData.stats.inspiration and {} or nil,
        multicraft = recipeData.stats.multicraft and {} or nil,
        resourcefulness = nil,
        qualityWithInspiration = nil,
    }

    local averageProfit = 0

    -- this is independent to the other proccs
    local totalSavedCosts = CraftSim.CALC:getResourcefulnessSavedCostsV2(recipeData, priceData, calculationData)  
    local adaptedCraftingCosts = priceData.craftingCostPerCraft - totalSavedCosts
    local baseCraftValue = recipeData.baseItemAmount * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0)
    print("totalSavedCosts: " .. CraftSim.UTIL:FormatMoney(totalSavedCosts))

    if recipeData.stats.multicraft then
        calculationData.multicraft.averageMulticraftItems = CraftSim.CALC:GetAverageItemsPerCraftByMulticraft(recipeData)
    end

    
    -- case, recipe supports only multicraft not inspiration
    if recipeData.stats.multicraft and not recipeData.stats.inspiration then
        local chanceBase = 1 - (recipeData.stats.multicraft.percent / 100)
        local chanceMC = (recipeData.stats.multicraft.percent / 100)
        
        local weightedAverageCraftValueBase = chanceBase * baseCraftValue
        local weightedAverageCraftValueMC = chanceMC * CraftSim.CALC:GetAverageCraftValueMulticraft(recipeData, priceData)
        
        local averageCraftValue = weightedAverageCraftValueBase + weightedAverageCraftValueMC
        averageProfit = (averageCraftValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - adaptedCraftingCosts
        

        calculationData.chanceBase = chanceBase
        calculationData.multicraft.chance = chanceMC
    elseif recipeData.stats.inspiration and not recipeData.stats.multicraft then
        local chanceBase = 1 - (recipeData.stats.inspiration.percent / 100)
        local chanceINSP = (recipeData.stats.inspiration.percent / 100)
        
        local weightedAverageCraftValueBase = chanceBase * baseCraftValue
        -- fall back to base craft value if no insp break point
        local weightedAverageCraftValueINSP = chanceINSP * CraftSim.CALC:GetAverageCraftValueInspirationByItemsPerCraft(recipeData, priceData, recipeData.baseItemAmount, baseCraftValue)
        local averageCraftValue = weightedAverageCraftValueBase + weightedAverageCraftValueINSP

        averageProfit = (averageCraftValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - adaptedCraftingCosts

        calculationData.chanceBase = chanceBase
        calculationData.inspiration.chance = chanceINSP
    elseif recipeData.stats.inspiration and recipeData.stats.multicraft then
        -- consider cases:
        local chanceBase = (1 - (recipeData.stats.inspiration.percent / 100)) * (1 - (recipeData.stats.multicraft.percent / 100))
        local chanceMC = (recipeData.stats.multicraft.percent / 100) *  (1 - (recipeData.stats.inspiration.percent / 100))
        local chanceINSP = (recipeData.stats.inspiration.percent / 100) *  (1 - (recipeData.stats.multicraft.percent / 100))
        local chanceDOUBLE = (recipeData.stats.inspiration.percent / 100) *  (recipeData.stats.multicraft.percent / 100)
        
        local weightedAverageCraftValueBase = chanceBase * baseCraftValue

        local averageCraftValueMC = CraftSim.CALC:GetAverageCraftValueMulticraft(recipeData, priceData)
        local weightedAverageCraftValueMC = chanceMC * averageCraftValueMC

        local averageCraftValueINSP = CraftSim.CALC:GetAverageCraftValueInspirationByItemsPerCraft(recipeData, priceData, recipeData.baseItemAmount, baseCraftValue)
        local weightedAverageCraftValueINSP = chanceINSP * averageCraftValueINSP
        
        local averageCraftValueDOUBLE = CraftSim.CALC:GetAverageCraftValueMulticraftInspiration(recipeData, priceData, averageCraftValueMC)
        local weightedAverageCraftValueDOUBLE = chanceDOUBLE * averageCraftValueDOUBLE
        -- fall back to multicraft value if no insp break point

        print("chanceBase: " .. CraftSim.UTIL:round(chanceBase, 2))
        print("chanceMC: " .. CraftSim.UTIL:round(chanceMC, 2))
        print("chanceINSP: " .. CraftSim.UTIL:round(chanceINSP, 2))
        print("chanceDOUBLE: " .. CraftSim.UTIL:round(chanceDOUBLE, 2))
        print("baseCraftValue " .. CraftSim.UTIL:FormatMoney(baseCraftValue))
        print("weightedAverageCraftValueBase " .. CraftSim.UTIL:FormatMoney(weightedAverageCraftValueBase))
        print("averageCraftValueMC " .. CraftSim.UTIL:FormatMoney(averageCraftValueMC))
        print("weightedAverageCraftValueMC " .. CraftSim.UTIL:FormatMoney(weightedAverageCraftValueMC))
        print("averageCraftValueINSP " .. CraftSim.UTIL:FormatMoney(averageCraftValueINSP))
        print("weightedAverageCraftValueINSP " .. CraftSim.UTIL:FormatMoney(weightedAverageCraftValueINSP))
        print("averageCraftValueDOUBLE " .. CraftSim.UTIL:FormatMoney(averageCraftValueDOUBLE))
        print("weightedAverageCraftValueDOUBLE " .. CraftSim.UTIL:FormatMoney(weightedAverageCraftValueDOUBLE))
        
        
        local averageCraftValue = weightedAverageCraftValueBase + weightedAverageCraftValueMC + weightedAverageCraftValueINSP + weightedAverageCraftValueDOUBLE
        print("averageCraftValue " .. CraftSim.UTIL:FormatMoney(averageCraftValue))
        print("adaptedCraftingCosts " .. CraftSim.UTIL:FormatMoney(adaptedCraftingCosts))
        
        averageProfit = (averageCraftValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - adaptedCraftingCosts 

        calculationData.chanceBase = chanceBase
        calculationData.chanceDouble = chanceDOUBLE
        calculationData.inspiration.chance = chanceINSP
        calculationData.multicraft.chance = chanceMC
    else
        averageProfit = (baseCraftValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - adaptedCraftingCosts 
    end
    calculationData.meanProfit = averageProfit
    calculationData.craftingCostPerCraft = priceData.craftingCostPerCraft

    return averageProfit, calculationData
end

function CraftSim.CALC:getMeanProfit(recipeData, priceData)
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

    CraftSim.CALC:handleInspiration(recipeData, priceData, crafts, craftedItems, calculationData)
    CraftSim.CALC:handleMulticraft(recipeData, priceData, crafts, craftedItems, calculationData)

    local totalSavedCosts = CraftSim.CALC:getResourcefulnessSavedCostsV2(recipeData, priceData, calculationData)

    local totalCraftingCosts = priceData.craftingCostPerCraft - totalSavedCosts
    local totalWorth = 0
    if recipeData.expectedQuality == recipeData.maxQuality or recipeData.result.isNoQuality then
        totalWorth = craftedItems.baseQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0)
    else
        totalWorth = craftedItems.baseQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) + 
            craftedItems.nextQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1] or 0)
    end
    local meanProfit = ((totalWorth*CraftSim.CONST.AUCTION_HOUSE_CUT) - totalCraftingCosts)

    calculationData.craftingCostPerCraft = totalCraftingCosts

    return meanProfit, calculationData
end