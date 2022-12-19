CraftSimSTATS = {}

local statIncreaseFactor = 5

function CraftSimSTATS:GetQualityThresholds(maxQuality, recipeDifficulty, breakPointOffset)
    local offset = breakPointOffset and 1 or 0
    if maxQuality == 1 then
        return {}
    elseif maxQuality == 3 then
        return {recipeDifficulty*0.5 + offset, recipeDifficulty + offset}
    elseif maxQuality == 5 then
        return {recipeDifficulty*0.2 + offset, recipeDifficulty*0.5 + offset, recipeDifficulty*0.8 + offset, recipeDifficulty + offset}
    end
end

function CraftSimSTATS:getInspirationWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.inspiration == nil then
        --print("recipe cannot proc inspiration")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.inspiration.percent = modifiedData.stats.inspiration.percent + (CraftSimUTIL:GetInspirationPercentByStat(statIncreaseFactor) * 100)
    
    return CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSimSTATS:getMulticraftWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.multicraft == nil then
        --print("recipe cannot proc multicraft")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.multicraft.percent = modifiedData.stats.multicraft.percent + (CraftSimUTIL:GetMulticraftPercentByStat(statIncreaseFactor) * 100)
    
    return CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSimSTATS:getResourcefulnessWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.resourcefulness == nil then
        --print("recipe cannot proc resourcefulness")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.resourcefulness.percent = modifiedData.stats.resourcefulness.percent + (CraftSimUTIL:GetResourcefulnessPercentByStat(statIncreaseFactor) * 100)
    
    return CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
    local meanProfitModified = CraftSimCALC:getMeanProfit(modifiedData, priceData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

function CraftSimSTATS:CalculateStatWeights(recipeData, priceData)

    local calculationResult = {}
    calculationResult.meanProfit = CraftSimCALC:getMeanProfit(recipeData, priceData)

    calculationResult.inspiration = CraftSimSTATS:getInspirationWeight(recipeData, priceData, calculationResult.meanProfit)
    calculationResult.multicraft = CraftSimSTATS:getMulticraftWeight(recipeData, priceData, calculationResult.meanProfit)
    calculationResult.resourcefulness = CraftSimSTATS:getResourcefulnessWeight(recipeData, priceData, calculationResult.meanProfit)

    --print("BaseMeanProfit: " .. CraftSimUTIL:round(calculationResult.meanProfit, 2))
    return calculationResult
end

function CraftSimSTATS:getProfessionStatWeightsForCurrentRecipe(recipeData, priceData)
	local statweights = CraftSimSTATS:CalculateStatWeights(recipeData, priceData)

    if statWeights == CraftSimCONST.ERROR.NO_PRICE_DATA then
        return CraftSimCONST.ERROR.NO_PRICE_DATA
    end

	return statweights
end

function CraftSimSTATS:GetExpectedQualityBySkill(recipeData, skill, breakPointOffset)
    local expectedQuality = 1
    local thresholds = CraftSimSTATS:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty, breakPointOffset)

    for _, threshold in pairs(thresholds) do
        if skill > threshold then
            expectedQuality = expectedQuality + 1
        end
    end

    return expectedQuality
end