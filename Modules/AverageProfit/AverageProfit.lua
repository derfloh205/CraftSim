---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.AVERAGEPROFIT
CraftSim.AVERAGEPROFIT = {}

---@type GGUI.Frame
CraftSim.AVERAGEPROFIT.frame = nil
---@type GGUI.Frame
CraftSim.AVERAGEPROFIT.frameWO = nil

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT)

local statIncreaseFactor = 5

function CraftSim.AVERAGEPROFIT:GetQualityThresholds(maxQuality, recipeDifficulty, breakPointOffset)
    local offset = breakPointOffset and 1 or 0
    if maxQuality == 1 then
        return {}
    elseif maxQuality == 3 then
        return { recipeDifficulty * 0.5 + offset, recipeDifficulty + offset }
    elseif maxQuality == 5 then
        return { recipeDifficulty * 0.2 + offset, recipeDifficulty * 0.5 + offset, recipeDifficulty * 0.8 + offset,
            recipeDifficulty + offset }
    end
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
function CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseAverageProfit)
    recipeData:Update()
    local meanProfitModified = CraftSim.CALC:GetAverageProfit(recipeData)
    local profitDiff = meanProfitModified - baseAverageProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:GetMulticraftWeight(recipeData, baseAverageProfit)
    if not recipeData.supportsMulticraft then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.multicraft:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseAverageProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.multicraft:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
---@return number statWeight
function CraftSim.AVERAGEPROFIT:GetResourcefulnessWeight(recipeData, baseAverageProfit)
    if not recipeData.supportsResourcefulness then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.resourcefulness:addValue(statIncreaseFactor)
    local statWeight = CraftSim.AVERAGEPROFIT:CalculateStatWeightByModifiedData(recipeData, baseAverageProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.resourcefulness:subtractValue(statIncreaseFactor)
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
---@return number statWeight
---@return number averageProfitConcentration
function CraftSim.AVERAGEPROFIT:GetConcentrationWeight(recipeData, baseAverageProfit)
    if not recipeData.supportsQualities or recipeData.concentrating or recipeData.concentrationCost <= 0 then
        return 0
    end

    -- switch on concentration
    recipeData.concentrating = true
    recipeData.resultData:Update() -- to make concentration take effect
    local averageProfitConcentration = recipeData:GetAverageProfit()
    local profitDiff = averageProfitConcentration - baseAverageProfit
    local statWeight = profitDiff / recipeData.concentrationCost
    recipeData.concentrating = false
    return statWeight, averageProfitConcentration
end

---@param recipeData CraftSim.RecipeData
---@param skill number
function CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skill)
    local expectedQuality = 1
    local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality,
        recipeData.professionStats.recipeDifficulty.value, CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET"))

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

    print("calculate stat weights avg profit: " .. tostring(CraftSim.UTIL:FormatMoney(averageProfit, true)))

    local multicraftWeight = CraftSim.AVERAGEPROFIT:GetMulticraftWeight(recipeData, averageProfit)
    local resourcefulnessWeight = CraftSim.AVERAGEPROFIT:GetResourcefulnessWeight(recipeData, averageProfit)
    local concentrationWeight = CraftSim.AVERAGEPROFIT:GetConcentrationWeight(recipeData, averageProfit)

    recipeData:Update() -- revert

    return CraftSim.Statweights(averageProfit, multicraftWeight, resourcefulnessWeight, concentrationWeight)
end
