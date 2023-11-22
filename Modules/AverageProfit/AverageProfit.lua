CraftSimAddonName, CraftSim = ...

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

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
function CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseMeanProfit)
    recipeData:Update()
    local meanProfitModified = CraftSim.CALC:GetAverageProfit(recipeData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:getInspirationWeight(recipeData, baseMeanProfit)
    if not recipeData.supportsInspiration then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.inspiration:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseMeanProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.inspiration:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:getMulticraftWeight(recipeData, baseMeanProfit)
    if not recipeData.supportsMulticraft then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.multicraft:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseMeanProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.multicraft:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseMeanProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:getResourcefulnessWeight(recipeData, baseMeanProfit)
    if not recipeData.supportsResourcefulness then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.resourcefulness:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseMeanProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.resourcefulness:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param skill number
function CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skill)
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
function CraftSim.AVERAGEPROFIT:CalculateStatWeights(recipeData)
    print("Get Average Profit", false, true)
    local averageProfit = CraftSim.CALC:GetAverageProfit(recipeData)

    print("calculate stat weights avg profit: " .. tostring(CraftSim.GUTIL:FormatMoney(averageProfit, true)))

    local inspirationWeight = CraftSim.AVERAGEPROFIT:getInspirationWeight(recipeData, averageProfit)
    local multicraftWeight = CraftSim.AVERAGEPROFIT:getMulticraftWeight(recipeData, averageProfit)
    local resourcefulnessWeight = CraftSim.AVERAGEPROFIT:getResourcefulnessWeight(recipeData, averageProfit)

    recipeData:Update() -- revert

    return CraftSim.Statweights(averageProfit, inspirationWeight, multicraftWeight, resourcefulnessWeight)
end