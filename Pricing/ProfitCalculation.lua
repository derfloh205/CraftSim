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

function CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)
    local specData = recipeData.specNodeData
    local resourcefulnessExtraItemsFactor = 1

    if specData and recipeData.stats.resourcefulness then
        resourcefulnessExtraItemsFactor = 1 + recipeData.stats.resourcefulness.bonusItemsFactor
    elseif recipeData.stats.resourcefulness then
        resourcefulnessExtraItemsFactor = recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
    end

    print("resourcefulnessExtraItemsFactor: " .. tostring(resourcefulnessExtraItemsFactor), false, true)
    if recipeData.salvageReagent then
        return (priceData.salvageReagentPrice * recipeData.salvageReagent.requiredQuantity) * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR  * resourcefulnessExtraItemsFactor) 
    end

    local savedCosts = 0
    if recipeData.stats.resourcefulness then
        savedCosts = priceData.craftingCostPerCraft * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR * resourcefulnessExtraItemsFactor)
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

function CraftSim.CALC:getHSVChance(recipeData) 
    if CraftSimOptions.enableHSV and recipeData.maxQuality and recipeData.expectedQuality < recipeData.maxQuality then
        local currentQualityProgress = recipeData.operationInfo.quality % 1
        
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeData.baseDifficulty)
        local lowerThreshold = thresholds[recipeData.expectedQuality-1] or 0
        local upperThreshold = thresholds[recipeData.expectedQuality]
        local diff = upperThreshold - lowerThreshold
        local playerSkill = lowerThreshold + (diff*currentQualityProgress)

        if recipeData.isSimModeData then
            print("sim mode skill: " .. recipeData.stats.skill)
            playerSkill = recipeData.stats.skill
        end

        local skillDiff = upperThreshold - playerSkill
        print("skillDiff: " .. skillDiff)
        local relativeToDifficulty = skillDiff / (recipeData.baseDifficulty / 100)
        print("relativeToDifficulty: " .. relativeToDifficulty)

        if relativeToDifficulty >= 5 then
            -- check if we can reach together with inspiration (if inspiration is not reaching alone)
            local skillWithInspiration = playerSkill + recipeData.stats.inspiration.bonusskill
            if skillWithInspiration < upperThreshold then
                -- check if within 5%
                skillDiff = upperThreshold - skillWithInspiration
                relativeToDifficulty = skillDiff / (recipeData.baseDifficulty / 100)

                if relativeToDifficulty < 5 then
                    -- together with hsv we can reach the threshold
                    -- calculate chance for this and mark as hsv with inspiration only
                    local hsvChance = (5-relativeToDifficulty) / 5
                    return hsvChance, true
                end
            end
            return 0
        end

        local hsvChance = (5-relativeToDifficulty) / 5

        return hsvChance
    else
        return 0
    end
end

function CraftSim.CALC:getMeanProfit(recipeData, priceData)

    if not recipeData.stats then
        local resultValue = ((priceData.minBuyoutPerQuality[1] or 0) * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT
        local profit = resultValue - priceData.craftingCostPerCraft

        local probabilityTable = {{chance=1, profit=profit}}
        return profit, probabilityTable
    end
    -- case: every stats exists
    if recipeData.stats.inspiration and recipeData.stats.multicraft and recipeData.stats.resourcefulness then
        local inspChance = recipeData.stats.inspiration.percent / 100
        local mcChance = recipeData.stats.multicraft.percent / 100
        local resChance = recipeData.stats.resourcefulness.percent / 100
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChance(recipeData)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)

        print("HSV Upgrade Chance: " .. CraftSim.UTIL:round(hsvChance*100, 2) .. "%")

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
        local qualityWithHSV = math.min(recipeData.expectedQuality + 1, recipeData.maxQuality)

        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))

        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, MC, RES, HSV)")

        local bitMax = "1111"
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
                false, -- hsv
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_MC = (procs[2] and mcChance) or (1-mcChance)
            local p_HSV = (procs[3] and hsvChance) or (1-hsvChance)
            local p_Res = (procs[4] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_MC * p_Res * p_HSV

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[4] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- possible combos: (without res)
            --[[
                000,
                001,
                010,
                011,
                100,
                101,
                110,
                111
            --]]
            local subCombination = string.sub(table.concat(combination, ""), 1, 3)
            print("subCombination: " .. tostring(subCombination))
            -- nothing
            if subCombination == "000" then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- no insp, no mc, hsv,  
            elseif subCombination == "001" then
                if not withInspirationOnly then
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- no insp, mc, no hsv, 
            elseif subCombination == "010" then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- no insp, mc, hsv, 
            elseif subCombination == "011" then
                if not withInspirationOnly then
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithHSV] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- insp, no mc, no hsv, 
            elseif subCombination == "100" then
                resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- insp, no mc, hsv
            elseif subCombination == "101" then
                if not withInspirationOnly then
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- insp, mc, no hsv, 
            elseif subCombination == "110" then
                resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- insp, mc, hsv
            elseif subCombination == "111" then
                if not withInspirationOnly then
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithHSV] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                multicraft = procs[2],
                hsv = procs[3],
                resourcefulness = procs[4],
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
        -- no inspiration -> no hsv
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
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChance(recipeData)
        local resChance = recipeData.stats.resourcefulness.percent / 100
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsV3(recipeData, priceData)

        local skillWithInspiration = recipeData.stats.skill + recipeData.stats.inspiration.bonusskill
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skillWithInspiration)
        local qualityWithHSV = math.min(recipeData.expectedQuality + 1, recipeData.maxQuality)
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, RES)")

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
                false, -- hsv
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_HSV = (procs[2] and hsvChance) or (1-hsvChance)
            local p_Res = (procs[3] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_Res * p_HSV

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[3] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            print("recipeData.baseItemAmount: " .. tostring(recipeData.baseItemAmount))
            print("buyout for expected: " .. tostring(priceData.minBuyoutPerQuality[recipeData.expectedQuality]))

            -- if insp, no hsv
            if not procs[1] and not procs[2] then
                resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- just insp
            elseif procs[1] and not procs[2] then
                resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- not insp, hsv
            elseif not procs[1] and procs[2] then
                if not withInspirationOnly then
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.minBuyoutPerQuality[recipeData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            elseif procs[1] and procs[2] then
                if not withInspirationOnly then
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.minBuyoutPerQuality[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                hsv = procs[2],
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
    elseif not recipeData.stats.inspiration and not recipeData.stats.multicraft and recipeData.stats.resourcefulness then
        -- no insp no hsv
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

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[1] and savedCostsByRes) or 0)

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

function CraftSim.CALC:getMeanProfitNoHSV(recipeData, priceData)

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

            local craftingCosts = priceData.craftingCostPerCraft - ((procs[1] and savedCostsByRes) or 0)

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


-- OOP Refactor

---@param recipeData CraftSim.RecipeData
function CraftSim.CALC:getResourcefulnessSavedCostsOOP(recipeData)
    local priceData = recipeData.priceData
    local extraSavedItemsFactor = recipeData.professionStats.resourcefulness:GetExtraFactor(true)

    local savedCosts = 0
    if recipeData.supportsResourcefulness then
        savedCosts = priceData.craftingCosts * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR * extraSavedItemsFactor)
    end

    return savedCosts
end

function CraftSim.CALC:getHSVChanceOOP(recipeData) 
    if CraftSimOptions.enableHSV and recipeData.maxQuality and recipeData.resultData.expectedQuality < recipeData.maxQuality then
        
        local baseRecipeDifficulty = recipeData.baseProfessionStats.recipeDifficulty.value
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, baseRecipeDifficulty)
        local upperThreshold = thresholds[recipeData.resultData.expectedQuality]

        local playerSkill = recipeData.professionStats.skill.value

        local skillDiff = upperThreshold - playerSkill
        local relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

        if relativeToDifficulty >= 5 then
            -- check if we can reach together with inspiration (if inspiration is not reaching alone)
            local skillWithInspiration = playerSkill + recipeData.professionStats.inspiration.extraValue
            if skillWithInspiration < upperThreshold then
                -- check if within 5%
                skillDiff = upperThreshold - skillWithInspiration
                relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

                if relativeToDifficulty < 5 then
                    -- together with hsv we can reach the threshold
                    -- calculate chance for this and mark as hsv with inspiration only
                    local hsvChance = (5-relativeToDifficulty) / 5
                    return hsvChance, true
                end
            end
            return 0
        end

        local hsvChance = (5-relativeToDifficulty) / 5

        return hsvChance
    else
        return 0
    end
end

--- Do not forget to update Price Data first
---@params recipeData CraftSim.RecipeData
---@return number meanProfit
---@return table probabilityTable
function CraftSim.CALC:GetMeanProfitOOP(recipeData)
    local priceData = recipeData.priceData
    local professionStats = recipeData.professionStats
    if not recipeData.supportsCraftingStats then
        local resultValue = ((priceData.qualityPriceList[1] or 0) * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT
        local profit = resultValue - priceData.craftingCosts

        local probabilityTable = {{chance=1, profit=profit}}
        return profit, probabilityTable
    end
    -- case: every stats exists
    if recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChanceOOP(recipeData)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsOOP(recipeData)

        print("HSV Upgrade Chance: " .. CraftSim.UTIL:round(hsvChance*100, 2) .. "%")

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * professionStats.multicraft:GetExtraFactor(true)
        local expectedAdditionalItems = (1 + maxExtraItems) / 2 
        local expectedItems = recipeData.baseItemAmount + expectedAdditionalItems

        local skillWithInspiration = professionStats.skill.value + professionStats.inspiration.extraValue
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkillOOP(recipeData, skillWithInspiration)
        local qualityWithHSV = math.min(recipeData.resultData.expectedQuality + 1, recipeData.maxQuality)

        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))

        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, MC, RES, HSV)")

        local bitMax = "1111"
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
                false, -- hsv
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_MC = (procs[2] and mcChance) or (1-mcChance)
            local p_HSV = (procs[3] and hsvChance) or (1-hsvChance)
            local p_Res = (procs[4] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_MC * p_Res * p_HSV

            local craftingCosts = priceData.craftingCosts - ((procs[4] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- possible combos: (without res)
            --[[
                000,
                001,
                010,
                011,
                100,
                101,
                110,
                111
            --]]
            local subCombination = string.sub(table.concat(combination, ""), 1, 3)
            print("subCombination: " .. tostring(subCombination))
            -- nothing
            if subCombination == "000" then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- no insp, no mc, hsv,  
            elseif subCombination == "001" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- no insp, mc, no hsv, 
            elseif subCombination == "010" then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- no insp, mc, hsv, 
            elseif subCombination == "011" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- insp, no mc, no hsv, 
            elseif subCombination == "100" then
                resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- insp, no mc, hsv
            elseif subCombination == "101" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- insp, mc, no hsv, 
            elseif subCombination == "110" then
                resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- insp, mc, hsv
            elseif subCombination == "111" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                multicraft = procs[2],
                hsv = procs[3],
                resourcefulness = procs[4],
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
    elseif not recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no inspiration -> no hsv
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsOOP(recipeData)

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * professionStats.multicraft:GetExtraFactor(true)
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

            local craftingCosts = priceData.craftingCosts - ((procs[2] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- if mc
            if procs[1] then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
            elseif not procs[1] then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
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
    elseif recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChanceOOP(recipeData)
        local resChance = professionStats.resourcefulness:GetExtraFactor(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsOOP(recipeData)

        local skillWithInspiration = professionStats.skill.value + professionStats.inspiration.extraValue
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkillOOP(recipeData, skillWithInspiration)
        local qualityWithHSV = math.min(recipeData.resultData.expectedQuality + 1, recipeData.maxQuality)
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, RES)")

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
                false, -- hsv
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_HSV = (procs[2] and hsvChance) or (1-hsvChance)
            local p_Res = (procs[3] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_Res * p_HSV

            local craftingCosts = priceData.craftingCosts- ((procs[3] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            print("recipeData.baseItemAmount: " .. tostring(recipeData.baseItemAmount))
            print("buyout for expected: " .. tostring(priceData.qualityPriceList[recipeData.resultData.expectedQuality]))

            -- if insp, no hsv
            if not procs[1] and not procs[2] then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- just insp
            elseif procs[1] and not procs[2] then
                resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- not insp, hsv
            elseif not procs[1] and procs[2] then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            elseif procs[1] and procs[2] then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                hsv = procs[2],
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
    elseif not recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no insp no hsv
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCostsOOP(recipeData)
        
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

            local craftingCosts = priceData.craftingCosts- ((procs[1] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            
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
    elseif not recipeData.supportsResourcefulness then
        -- before having a salvage item allocated in prospecting e.g.
        return 0, {}
    end

    print(CraftSim.UTIL:ColorizeText("Szenario not implemented yet", CraftSim.CONST.COLORS.RED), false, true)
    print("Supports Crafting Stats: " .. recipeData.supportsCraftingStats)
    print("Inspiration: " .. recipeData.supportsInspiration)
    print("Multicraft: " .. recipeData.supportsMulticraft)
    print("Resourcefulness: " .. recipeData.supportsResourcefulness)

    return 0, {}
end