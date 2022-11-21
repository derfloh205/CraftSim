CraftSimSTATS = {}

local numCrafts = 1000000
local statIncreaseFactor = 5

function CraftSimSTATS:GetQualityThresholds(maxQuality, recipeDifficulty)
    if maxQuality == 1 then
        return {}
    elseif maxQuality == 3 then
        return {recipeDifficulty*0.5, recipeDifficulty}
    elseif maxQuality == 5 then
        return {recipeDifficulty*0.2, recipeDifficulty*0.5, recipeDifficulty*0.8, recipeDifficulty}
    end
end

function CraftSimSTATS:getMeanProfit(recipeData, priceData)
    local inspirationStatByPercent = CraftSimUTIL:GetInspirationStatByPercent(recipeData.InspirationPercent)

    local totalItemsCrafted = numCrafts * recipeData.baseItemAmount
    local craftedItems = {
        baseQuality = 0,
        nextQuality = 0
    }
    local crafts = {
        baseQuality = 0,
        nextQuality = 0
    }
    local inspirationCanUpgrade = false
    if recipeData.expectedQuality ~= recipeData.maxQuality and recipeData.InspirationPercent ~= nil then
        local qualityThresholds = CraftSimSTATS:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty)
        local qualityUpgradeThreshold = qualityThresholds[recipeData.expectedQuality]
        --print("upgrade threshold: " .. qualityUpgradeThreshold)
        --print("thresholds: " .. unpack(qualityThresholds))
        inspirationCanUpgrade = (recipeData.playerSkill + recipeData.InspirationSkillBonus) >= qualityUpgradeThreshold
    end
    --print("inspiration can upgrade recipe: " .. tostring(inspirationCanUpgrade))
    if inspirationCanUpgrade then
        -- Recipe considers inspiration and inspiration upgrades are possible
        local inspirationProcs = numCrafts*(recipeData.InspirationPercent / 100)

        crafts.baseQuality = numCrafts - inspirationProcs
        crafts.nextQuality = inspirationProcs

        craftedItems.baseQuality = totalItemsCrafted - (inspirationProcs * recipeData.baseItemAmount)
        craftedItems.nextQuality = inspirationProcs * recipeData.baseItemAmount
    else
        craftedItems.baseQuality = totalItemsCrafted * recipeData.baseItemAmount
        crafts.baseQuality = numCrafts
    end

    if recipeData.MulticraftPercent ~= nil then
        -- Recipe considers multicraft
        -- TODO implement multicraft additional item chance/amount based on multicraft tracker data
        -- For now just use a random value of 1-2.5y additional items
        local expectedAdditionalItems = (1 + (2.5*recipeData.baseItemAmount)) / 2 

        -- Since multicraft and inspiration can proc together add expected multicraft gain to both qualities
        local craftNumBase = craftedItems.baseQuality / recipeData.baseItemAmount
        local craftNumNext = craftedItems.nextQuality / recipeData.baseItemAmount
        local multicraftProcsBase = crafts.baseQuality*(recipeData.MulticraftPercent / 100)
        local multicraftProcsNext = crafts.nextQuality*(recipeData.MulticraftPercent / 100)
        local expectedExtraItemsBase = multicraftProcsBase * expectedAdditionalItems
        local expectedExtraItemsNext = multicraftProcsNext * expectedAdditionalItems
        craftedItems.baseQuality = craftedItems.baseQuality + expectedExtraItemsBase
        craftedItems.nextQuality = craftedItems.nextQuality + expectedExtraItemsNext
    end

    local totalCraftingCosts = priceData.craftingCostPerCraft * numCrafts
    local totalWorth = 0
    if recipeData.expectedQuality == recipeData.maxQuality then
        totalWorth = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality]
    else
        totalWorth = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality] + 
            craftedItems.nextQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1]
    end
    local meanProfit = (totalWorth - totalCraftingCosts) / numCrafts
    return meanProfit
end

function CraftSimSTATS:getInspirationWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.InspirationValue == nil then
        --print("recipe cannot proc inspiration")
        return 0
    end
    local modifiedData = CraftSimUTIL:CloneTable(recipeData)
    modifiedData.InspirationPercent = modifiedData.InspirationPercent + CraftSimUTIL:GetInspirationPercentByStat(statIncreaseFactor)
    
    return CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSimSTATS:getMulticraftWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.MulticraftValue == nil then
        --print("recipe cannot proc multicraft")
        return 0
    end
    local modifiedData = CraftSimUTIL:CloneTable(recipeData)
    modifiedData.MulticraftPercent = modifiedData.MulticraftPercent + CraftSimUTIL:GetMulticraftPercentByStat(statIncreaseFactor)
    
    return CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSimSTATS:getResourcefulnessWeight(recipeData, priceData, baseMeanProfit)
    if recipeData.ResourcefulnessValue == nil then
        --print("recipe cannot proc resourcefulness")
        return 0
    end
    local modifiedData = CraftSimUTIL:CloneTable(recipeData)
    modifiedData.ResourcefulnessPercent = modifiedData.ResourcefulnessPercent + CraftSimUTIL:GetResourcefulnessPercentByStat(statIncreaseFactor)
    
    return CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
end

function CraftSimSTATS:CalculateStatWeightByModifiedData(modifiedData, priceData, baseMeanProfit)
    local meanProfitModified = CraftSimSTATS:getMeanProfit(modifiedData, priceData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

function CraftSimSTATS:CalculateStatWeights(recipeData)
    if CraftSimUTIL:isRecipeNotProducingItem(recipeData) then
        --print("Recipe does not produce item")
        CraftSimDetailsFrame:Hide()
        return
    end
    if recipeData.baseItemAmount == nil then
        -- when only one item is produced the baseItemAmount will be nil as this comes form the number of items produced shown in the ui
        recipeData.baseItemAmount = 1
    end

    --print("Calculate Profession Statweights.. " .. tostring(recipeData))
    local priceData = CraftSimPRICEDATA:GetPriceData(recipeData)

    if priceData == nil then
        return CraftSimCONST.ERROR.NO_PRICE_DATA
    end

    local baseMeanProfit = CraftSimSTATS:getMeanProfit(recipeData, priceData)

    local inspirationWeight = CraftSimSTATS:getInspirationWeight(recipeData, priceData, baseMeanProfit)
    local multicraftWeight = CraftSimSTATS:getMulticraftWeight(recipeData, priceData, baseMeanProfit)
    local resourcefulnessWeight = CraftSimSTATS:getResourcefulnessWeight(recipeData, priceData, baseMeanProfit)

    --print("BaseMeanProfit: " .. CraftSimUTIL:round(baseMeanProfit, 2))
    return {
        meanProfit = baseMeanProfit,
        inspiration = inspirationWeight,
        multicraft = multicraftWeight,
        resourcefulness = resourcefulnessWeight
    }
end

function CraftSimSTATS:getProfessionStatWeightsForCurrentRecipe()
	local recipeData = CraftSimDATAEXPORT:exportRecipeData()

	if recipeData == nil then
        --print("recipe data nil")
		return CraftSimCONST.ERROR.NO_RECIPE_DATA
	end

	local statweights = CraftSimSTATS:CalculateStatWeights(recipeData)

    if statWeights == CraftSimCONST.ERROR.NO_PRICE_DATA then
        return CraftSimCONST.ERROR.NO_PRICE_DATA
    end

	return statweights
end