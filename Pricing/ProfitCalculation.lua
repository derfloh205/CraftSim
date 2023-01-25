_, CraftSim = ...

CraftSim.CALC = {}

local function print(text, recursive, l) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.PROFIT_CALCULATION, recursive, l)
end

function CraftSim.CALC:handleInspiration(recipeData, priceData, crafts, craftedItems, calculationData)
    local inspirationCanUpgrade = false
    calculationData.inspiration = {}

    local inspirationQuality = recipeData.expectedQuality

    if recipeData.expectedQuality ~= recipeData.maxQuality and recipeData.stats.inspiration ~= nil then
        local qualityThresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty)
        local skillWithInspiration = recipeData.stats.skill + recipeData.stats.inspiration.bonusskill
        inspirationQuality = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skillWithInspiration)
        inspirationCanUpgrade = recipeData.expectedQuality < inspirationQuality
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
    calculationData.inspiration.inspirationItemsValueHigher = craftedItems.nextQuality * (priceData.minBuyoutPerQuality[inspirationQuality] or 0)

    return inspirationQuality
end

function CraftSim.CALC:handleMulticraft(recipeData, priceData, crafts, craftedItems, calculationData, inspirationQuality)
    if recipeData.stats.multicraft then
        calculationData.multicraft = {}
        local multicraftExtraItemsFactor = 1

        if recipeData.specNodeData then
            multicraftExtraItemsFactor = 1 + recipeData.stats.multicraft.bonusItemsFactor
        else
            multicraftExtraItemsFactor = recipeData.extraItemFactors.multicraftExtraItemsFactor
        end

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * multicraftExtraItemsFactor

        local expectedAdditionalItems = (1 + maxExtraItems) / 2 
        
        -- print("ProfitCalc MC expectedAdditionalItems Old: " .. tostring( ((1+(2.5*recipeData.baseItemAmount)) / 2)*multicraftExtraItemsFactor))
        -- print("ProfitCalc MC expectedAdditionalItems New: " .. tostring(expectedAdditionalItems))

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
            calculationData.multicraft.averageMulticraftHigherValue = expectedExtraItemsNext * (priceData.minBuyoutPerQuality[inspirationQuality] or 0)
        end
    end
end

function CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData, calculationData)
    local specData = recipeData.specNodeData
    local resourcefulnessExtraItemsFactor = 1

    if specData and recipeData.stats.resourcefulness then
        resourcefulnessExtraItemsFactor = 1 + recipeData.stats.resourcefulness.bonusItemsFactor
    elseif recipeData.stats.resourcefulness then
        resourcefulnessExtraItemsFactor = recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
    end

    if recipeData.salvageReagent then
        return (priceData.salvageReagentPrice * recipeData.salvageReagent.requiredQuantity) * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * resourcefulnessExtraItemsFactor) 
    end

    local savedCosts = 0
    if recipeData.stats.resourcefulness then
        savedCosts = CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR * priceData.craftingCostPerCraft * resourcefulnessExtraItemsFactor
        -- print("Saved Costs V3: " .. CraftSim.UTIL:FormatMoney(savedCosts))
    end

    if calculationData and calculationData.resourcefulness then
        calculationData.resourcefulness.averageSavedCosts = savedCosts
    end

    return savedCosts
end

function CraftSim.CALC:getResourcefulnessSavedCostsV2(recipeData, priceData, calculationData)
    local specData = recipeData.specNodeData
    local resourcefulnessExtraItemsFactor = 1

    if specData and recipeData.stats.resourcefulness then
        resourcefulnessExtraItemsFactor = 1 + recipeData.stats.resourcefulness.bonusItemsFactor
    elseif recipeData.stats.resourcefulness then
        resourcefulnessExtraItemsFactor = recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
    end

    if recipeData.salvageReagent then
        return (priceData.salvageReagentPrice * recipeData.salvageReagent.requiredQuantity) * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * resourcefulnessExtraItemsFactor) 
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
                    if totalReagents[materialIndex].differentQualities or not CraftSimOptions.profitCalcConsiderSub1MaterialsInRes then
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
    end

    print("Saved Costs By combinations: " .. CraftSim.UTIL:FormatMoney(savedCosts), false, true)
    print("Saved Costs by CraftingCosts*0.3*resChance: " .. CraftSim.UTIL:FormatMoney(priceData.craftingCostPerCraft*0.3*(recipeData.stats.resourcefulness.percent / 100)))

    if calculationData.resourcefulness then
        calculationData.resourcefulness.averageSavedCosts = savedCosts
    end

    return savedCosts
end

function CraftSim.CALC:getMeanProfitOLD(recipeData, priceData)
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
        resourcefulness = nil,
        inspirationQuality = nil,
    }

    local inspirationQuality = CraftSim.CALC:handleInspiration(recipeData, priceData, crafts, craftedItems, calculationData)
    calculationData.inspirationQuality = inspirationQuality
    CraftSim.CALC:handleMulticraft(recipeData, priceData, crafts, craftedItems, calculationData, inspirationQuality)

    local totalSavedCosts = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData, calculationData)

    local totalCraftingCosts = priceData.craftingCostPerCraft - totalSavedCosts
    local totalWorth = 0
    if recipeData.expectedQuality == recipeData.maxQuality or recipeData.result.isNoQuality then
        totalWorth = craftedItems.baseQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0)
    else
        totalWorth = craftedItems.baseQuality * (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) + 
            craftedItems.nextQuality * (priceData.minBuyoutPerQuality[inspirationQuality] or 0)
    end
    local meanProfit = ((totalWorth*CraftSim.CONST.AUCTION_HOUSE_CUT) - totalCraftingCosts)

    calculationData.craftingCostPerCraft = totalCraftingCosts

    return meanProfit, calculationData
end

function CraftSim.CALC:getMeanProfit(recipeData, priceData)

    -- TODO: other cases
    -- case: every stats exists
    if recipeData.stats.inspiration and recipeData.stats.multicraft and recipeData.stats.resourcefulness then
        local inspChance = recipeData.stats.inspiration.percent / 100
        local mcChance = recipeData.stats.multicraft.percent / 100
        local resChance = recipeData.stats.resourcefulness.percent / 100
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)

        local multicraftExtraItemsFactor = 1

        if recipeData.specNodeData then
            multicraftExtraItemsFactor = 1 + recipeData.stats.multicraft.bonusItemsFactor
        else
            multicraftExtraItemsFactor = recipeData.extraItemFactors.multicraftExtraItemsFactor
        end

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * multicraftExtraItemsFactor
        local expectedAdditionalItems = (1 + maxExtraItems) / 2 
        local expectedItems = recipeData.baseItemAmount + expectedAdditionalItems

        local skillWithInspiration = recipeData.stats.skill + recipeData.stats.inspiration.bonusskill
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skillWithInspiration)
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, MC, RES)")

        local bitMax = "111"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local procs = {
                false, -- insp
                false, -- mc
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_MC = (procs[2] and mcChance) or (1-mcChance)
            local p_Res = (procs[3] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_MC * p_Res

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[3] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- if insp but not mc
            if procs[1] and not procs[2] then
                resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            -- if mc but not insp
            elseif not procs[1] and procs[2] then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
            -- both procs
            elseif procs[1] and procs[2] then
                resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
            -- no mc and no insp
            elseif not procs[1] and not procs[2] then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                multicraft = procs[2],
                resourcefulness = procs[3],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.stats.inspiration and recipeData.stats.multicraft and recipeData.stats.resourcefulness then
        local mcChance = recipeData.stats.multicraft.percent / 100
        local resChance = recipeData.stats.resourcefulness.percent / 100
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)

        local multicraftExtraItemsFactor = 1

        if recipeData.specNodeData then
            multicraftExtraItemsFactor = 1 + recipeData.stats.multicraft.bonusItemsFactor
        else
            multicraftExtraItemsFactor = recipeData.extraItemFactors.multicraftExtraItemsFactor
        end

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * multicraftExtraItemsFactor
        local expectedAdditionalItems = (1 + maxExtraItems) / 2 
        local expectedItems = recipeData.baseItemAmount + expectedAdditionalItems

        local probabilityTable = {}

        print("Build Probability Table (MC, RES)")

        local bitMax = "11"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local procs = {
                false, -- mc
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_MC = (procs[1] and mcChance) or (1-mcChance)
            local p_Res = (procs[2] and resChance) or (1-resChance)

            local combinationChance = p_MC * p_Res

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[2] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- if mc
            if procs[1] then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
            elseif not procs[1] then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                multicraft = procs[1],
                resourcefulness = procs[2],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif recipeData.stats.inspiration and not recipeData.stats.multicraft and recipeData.stats.resourcefulness then
        local inspChance = recipeData.stats.inspiration.percent / 100
        local resChance = recipeData.stats.resourcefulness.percent / 100
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)

        local skillWithInspiration = recipeData.stats.skill + recipeData.stats.inspiration.bonusskill
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skillWithInspiration)
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, RES)")

        local bitMax = "11"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local procs = {
                false, -- insp
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_Res = (procs[2] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_Res

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[2] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            print("recipeData.baseItemAmount: " .. tostring(recipeData.baseItemAmount))
            print("buyout for expected: " .. tostring(priceData.minBuyoutPerQuality[recipeData.expectedQuality]))

            -- if insp
            if procs[1]  then
                resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            elseif not procs[1] then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                resourcefulness = procs[2],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.stats.inspiration and not recipeData.stats.multicraft and recipeData.stats.resourcefulness then
        local resChance = recipeData.stats.resourcefulness.percent / 100
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (RES)")

        local bitMax = "1"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local procs = {
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Res = (procs[1] and resChance) or (1-resChance)

            local combinationChance = p_Res

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[2] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0


            resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                resourcefulness = procs[1],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.stats.resourcefulness then
        -- before having a salvage item allocated in prospecting e.g.
        return 0, {}
    end

    print(CraftSim.UTIL:ColorizeText("Szenario not implemented yet", CraftSim.CONST.COLORS.RED), false, true)
    print("Inspiration: " .. tostring(recipeData.stats.inspiration ~= nil))
    print("Multicraft: " .. tostring(recipeData.stats.multicraft ~= nil))
    print("Resourcefulness: " .. tostring(recipeData.stats.resourcefulness ~= nil))

    return 0
end