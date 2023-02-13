AddonName, CraftSim = ...

CraftSim.AVERAGEPROFIT = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT)

local statIncreaseFactor = 5

function CraftSim.AVERAGEPROFIT:GetQualityThresholds(maxQuality, recipeDifficulty, breakPointOffset)
    local offset = breakPointOffset and 1 or 0
    if maxQuality == 1 then
        return {}
    elseif maxQuality == 3 then
        return {recipeDifficulty*0.5 + offset, recipeDifficulty + offset}
    elseif maxQuality == 5 then
        return {recipeDifficulty*0.2 + offset, recipeDifficulty*0.5 + offset, recipeDifficulty*0.8 + offset, recipeDifficulty + offset}
    end
end

function CraftSim.AVERAGEPROFIT:getInspirationWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.inspiration == nil then
        --print("recipe cannot proc inspiration")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.inspiration.percent = modifiedData.stats.inspiration.percent + (CraftSim.UTIL:GetInspirationPercentByStat(statIncreaseFactor) * 100)
    return CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSim.AVERAGEPROFIT:getMulticraftWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.multicraft == nil then
        --print("recipe cannot proc multicraft")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.multicraft.percent = modifiedData.stats.multicraft.percent + (CraftSim.UTIL:GetMulticraftPercentByStat(statIncreaseFactor) * 100)
    
    return CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSim.AVERAGEPROFIT:getResourcefulnessWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.stats.resourcefulness == nil then
        --print("recipe cannot proc resourcefulness")
        return nil
    end
    local modifiedData = CopyTable(recipeData)
    modifiedData.stats.resourcefulness.percent = modifiedData.stats.resourcefulness.percent + (CraftSim.UTIL:GetResourcefulnessPercentByStat(statIncreaseFactor) * 100)
    return CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
    local meanProfitModified = CraftSim.CALC:getMeanProfit(modifiedData, priceData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return {
        statWeight = statWeight,
        profitDiff = profitDiff,
        meanProfit = meanProfitModified
    }
end

function CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData, priceData, exportMode)

    local calculationResult = {} 
    calculationResult.meanProfit = CraftSim.CALC:getMeanProfitOLD(recipeData, priceData)
    local meanProfitV2 = CraftSim.CALC:getMeanProfit(CraftSim.MAIN.currentRecipeData, priceData)
   -- print("MeanProfitV1: " .. CraftSim.UTIL:FormatMoney(calculationResult.meanProfit, true))
    print("MeanProfitV2: " .. CraftSim.UTIL:FormatMoney(meanProfitV2, true))    

    calculationResult.meanProfit = meanProfitV2 or calculationResult.meanProfit



    local inspirationResults = CraftSim.AVERAGEPROFIT:getInspirationWeight(recipeData, priceData, calculationResult.meanProfit)
    local multicraftResults = CraftSim.AVERAGEPROFIT:getMulticraftWeight(recipeData, priceData, calculationResult.meanProfit)
    local resourcefulnessResults = CraftSim.AVERAGEPROFIT:getResourcefulnessWeight(recipeData, priceData, calculationResult.meanProfit)
    calculationResult.inspiration = inspirationResults and inspirationResults.statWeight or 0
    calculationResult.multicraft = multicraftResults and multicraftResults.statWeight or 0
    calculationResult.resourcefulness = resourcefulnessResults and resourcefulnessResults.statWeight or 0

    return calculationResult
end

function CraftSim.AVERAGEPROFIT:getProfessionStatWeightsForCurrentRecipe(recipeData, priceData, exportMode)
	local statweights = CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData, priceData, exportMode)

    if statWeights == CraftSim.CONST.ERROR.NO_PRICE_DATA then
        return CraftSim.CONST.ERROR.NO_PRICE_DATA
    end

	return statweights
end

function CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skill, breakPointOffset)
    local expectedQuality = 1
    local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty, breakPointOffset)

    for _, threshold in pairs(thresholds) do
        if skill >= threshold then
            expectedQuality = expectedQuality + 1
        end
    end

    return expectedQuality
end

-- OOP Refactor

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
function CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedDataOOP(recipeData, baseMeanProfit)
    recipeData:Update()
    local meanProfitModified = CraftSim.CALC:GetMeanProfitOOP(recipeData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:getInspirationWeightOOP(recipeData, baseMeanProfit)
    if not recipeData.supportsInspiration then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.inspiration:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedDataOOP(recipeData, baseMeanProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.inspiration:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:getMulticraftWeightOOP(recipeData, baseMeanProfit)
    if not recipeData.supportsMulticraft then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.multicraft:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedDataOOP(recipeData, baseMeanProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.multicraft:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:getResourcefulnessWeightOOP(recipeData, baseMeanProfit)
    if not recipeData.supportsResourcefulness then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.resourcefulness:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedDataOOP(recipeData, baseMeanProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.resourcefulness:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param skill number
function CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkillOOP(recipeData, skill)
    local expectedQuality = 1
    local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeData.professionStats.recipeDifficulty.value, CraftSimOptions.breakPointOffset)

    for _, threshold in pairs(thresholds) do
        if skill >= threshold then
            expectedQuality = expectedQuality + 1
        end
    end

    return expectedQuality
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Statweights statweightResult
function CraftSim.AVERAGEPROFIT:CalculateStatWeightsOOP(recipeData)
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT_OOP)

    local averageProfit = CraftSim.CALC:GetMeanProfitOOP(recipeData)

    local inspirationWeight = CraftSim.AVERAGEPROFIT:getInspirationWeightOOP(recipeData, averageProfit)
    local multicraftWeight = CraftSim.AVERAGEPROFIT:getMulticraftWeightOOP(recipeData, averageProfit)
    local resourcefulnessWeight = CraftSim.AVERAGEPROFIT:getResourcefulnessWeightOOP(recipeData, averageProfit)

    recipeData:Update() -- revert

    return CraftSim.Statweights(averageProfit, inspirationWeight, multicraftWeight, resourcefulnessWeight)
end