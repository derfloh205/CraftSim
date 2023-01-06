addonName, CraftSim = ...

CraftSim.STATS = {}

local statIncreaseFactor = 5

function CraftSim.STATS:GetQualityThresholds(maxQuality, recipeDifficulty, breakPointOffset)
    local offset = breakPointOffset and 1 or 0
    if maxQuality == 1 then
        return {}
    elseif maxQuality == 3 then
        return {recipeDifficulty*0.5 + offset, recipeDifficulty + offset}
    elseif maxQuality == 5 then
        return {recipeDifficulty*0.2 + offset, recipeDifficulty*0.5 + offset, recipeDifficulty*0.8 + offset, recipeDifficulty + offset}
    end
end

function CraftSim.STATS:getInspirationWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.inspiration == nil then
        --print("recipe cannot proc inspiration")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.inspiration.percent = modifiedData.stats.inspiration.percent + (CraftSim.UTIL:GetInspirationPercentByStat(statIncreaseFactor) * 100)
    return CraftSim.STATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSim.STATS:getMulticraftWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.multicraft == nil then
        --print("recipe cannot proc multicraft")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.multicraft.percent = modifiedData.stats.multicraft.percent + (CraftSim.UTIL:GetMulticraftPercentByStat(statIncreaseFactor) * 100)
    
    return CraftSim.STATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSim.STATS:getResourcefulnessWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.resourcefulness == nil then
        --print("recipe cannot proc resourcefulness")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.resourcefulness.percent = modifiedData.stats.resourcefulness.percent + (CraftSim.UTIL:GetResourcefulnessPercentByStat(statIncreaseFactor) * 100)
    return CraftSim.STATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSim.STATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
    local meanProfitModified = CraftSim.CALC:getMeanProfit(modifiedData, priceData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return {
        statWeight = statWeight,
        profitDiff = profitDiff,
        meanProfit = meanProfitModified
    }
end

function CraftSim.STATS:CalculateStatWeights(recipeData, priceData)

    local calculationResult = {} 
    local calculationData = {}
    --calculationResult.meanProfit, calculationData = CraftSim.CALC:getMeanProfit(recipeData, priceData)
    calculationResult.meanProfit, calculationData = CraftSim.CALC:getMeanProfit(recipeData, priceData)

    --CraftSim_DEBUG:print("MeanProfit V1: " .. CraftSim.UTIL:FormatMoney(calculationResult.meanProfit), CraftSim.CONST.DEBUG_IDS.PROFIT_CALCULATION)
    --CraftSim_DEBUG:print("MeanProfit V2: " .. CraftSim.UTIL:FormatMoney(meanProfitV2), CraftSim.CONST.DEBUG_IDS.PROFIT_CALCULATION)

    calculationData.meanProfit = calculationResult.meanProfit
    --CraftSim.FRAME:UpdateProfitDetails(recipeData, calculationData)

    local inspirationResults = CraftSim.STATS:getInspirationWeight(recipeData, priceData, calculationResult.meanProfit)
    local multicraftResults = CraftSim.STATS:getMulticraftWeight(recipeData, priceData, calculationResult.meanProfit)
    local resourcefulnessResults = CraftSim.STATS:getResourcefulnessWeight(recipeData, priceData, calculationResult.meanProfit)
    calculationResult.inspiration = inspirationResults and inspirationResults.statWeight or 0
    calculationResult.multicraft = multicraftResults and multicraftResults.statWeight or 0
    calculationResult.resourcefulness = resourcefulnessResults and resourcefulnessResults.statWeight or 0

    return calculationResult
end

function CraftSim.STATS:getProfessionStatWeightsForCurrentRecipe(recipeData, priceData)
	local statweights = CraftSim.STATS:CalculateStatWeights(recipeData, priceData)

    if statWeights == CraftSim.CONST.ERROR.NO_PRICE_DATA then
        return CraftSim.CONST.ERROR.NO_PRICE_DATA
    end

	return statweights
end

function CraftSim.STATS:GetExpectedQualityBySkill(recipeData, skill, breakPointOffset)
    local expectedQuality = 1
    local thresholds = CraftSim.STATS:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty, breakPointOffset)

    for _, threshold in pairs(thresholds) do
        if skill >= threshold then
            expectedQuality = expectedQuality + 1
        end
    end

    return expectedQuality
end