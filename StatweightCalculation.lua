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
    if recipeData.expectedQuality ~= recipeData.maxQuality and recipeData.stats.inspiration ~= nil then
        local qualityThresholds = CraftSimSTATS:GetQualityThresholds(recipeData.maxQuality, recipeData.recipeDifficulty)
        local qualityUpgradeThreshold = qualityThresholds[recipeData.expectedQuality]
        --print("upgrade threshold: " .. qualityUpgradeThreshold)
        --print("thresholds: " .. unpack(qualityThresholds))
        inspirationCanUpgrade = (recipeData.stats.skill + recipeData.stats.inspiration.bonusskill) >= qualityUpgradeThreshold
    end
    --print("inspiration can upgrade recipe: " .. tostring(inspirationCanUpgrade))
    if inspirationCanUpgrade then
        -- Recipe considers inspiration and inspiration upgrades are possible
        local inspirationProcs = numCrafts*(recipeData.stats.inspiration.percent / 100)

        crafts.baseQuality = numCrafts - inspirationProcs
        crafts.nextQuality = inspirationProcs

        craftedItems.baseQuality = totalItemsCrafted - (inspirationProcs * recipeData.baseItemAmount)
        craftedItems.nextQuality = inspirationProcs * recipeData.baseItemAmount
    else
        craftedItems.baseQuality = totalItemsCrafted * recipeData.baseItemAmount
        crafts.baseQuality = numCrafts
    end

    if recipeData.stats.multicraft ~= nil then
        -- Recipe considers multicraft
        -- TODO implement multicraft additional item chance/amount based on multicraft tracker data
        -- For now just use a random value of 1-2.5y additional items at mean
        local expectedAdditionalItems = (1 + (2.5*recipeData.baseItemAmount)) / 2 

        -- Since multicraft and inspiration can proc together add expected multicraft gain to both qualities
        local craftNumBase = craftedItems.baseQuality / recipeData.baseItemAmount
        local craftNumNext = craftedItems.nextQuality / recipeData.baseItemAmount
        local multicraftProcsBase = crafts.baseQuality*(recipeData.stats.multicraft.percent / 100)
        local multicraftProcsNext = crafts.nextQuality*(recipeData.stats.multicraft.percent / 100)
        local expectedExtraItemsBase = multicraftProcsBase * expectedAdditionalItems
        local expectedExtraItemsNext = multicraftProcsNext * expectedAdditionalItems
        craftedItems.baseQuality = craftedItems.baseQuality + expectedExtraItemsBase
        craftedItems.nextQuality = craftedItems.nextQuality + expectedExtraItemsNext
    end

    local totalSavedCosts = 0
    if recipeData.stats.resourcefulness ~= nil then
        -- Recipe considers resourcefulness
        -- For each craft save a resource by X% Chance
        -- -> This means I need to calculate the total amount of allocated reagents (per quality..?) used for all crafts then take X% of it to be saved
        -- -> Then for all saved resources, sum up the minbuyouts and remove that from the totalCraftingCosts for it to be considered in the meanProfit
        -- TODO: research how resourcefulness behaves with different allocated qualities

        local totalReagentAllocationsByQuality = {}
        for reagentIndex, reagentData in pairs(recipeData.reagents) do
            if reagentData.reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED then
                    totalReagentAllocationsByQuality[reagentIndex] = CopyTable(reagentData.itemsInfo)
                    for _, itemInfo in pairs(totalReagentAllocationsByQuality[reagentIndex]) do
                        itemInfo.allocations = itemInfo.allocations * numCrafts
                    end
            end
        end

        for reagentIndex, itemsInfo in pairs(totalReagentAllocationsByQuality) do
            for qualityIndex, itemInfo in pairs(itemsInfo) do
                local savedItems = itemInfo.allocations * (recipeData.stats.resourcefulness.percent / 100)
                totalSavedCosts = totalSavedCosts + priceData.reagentsPriceByQuality[reagentIndex][qualityIndex].minBuyout * savedItems
            end
        end
        --print("total saved costs: " .. totalSavedCosts)
    end

    local totalCraftingCosts = (priceData.craftingCostPerCraft * numCrafts) - totalSavedCosts
    local totalWorth = 0
    if recipeData.expectedQuality == recipeData.maxQuality or recipeData.result.isNoQuality then
        totalWorth = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality]
    else
        totalWorth = craftedItems.baseQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality] + 
            craftedItems.nextQuality * priceData.minBuyoutPerQuality[recipeData.expectedQuality + 1]
    end
    local meanProfit = ((totalWorth*CraftSimCONST.AUCTION_HOUSE_CUT) - totalCraftingCosts) / numCrafts
    return meanProfit
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
    local meanProfitModified = CraftSimSTATS:getMeanProfit(modifiedData, priceData)
    local profitDiff = meanProfitModified - baseMeanProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

function CraftSimSTATS:CalculateStatWeights(recipeData)
    if CraftSimUTIL:isRecipeNotProducingItem(recipeData) then
        --print("Recipe does not produce item")
        CraftSimFRAME:ToggleFrames(false)
        return
    end

    if CraftSimUTIL:isRecipeProducingSoulbound(recipeData) then
        --print("Recipe produces soulbound")
        CraftSimFRAME:ToggleFrames(false)
        return
    end

    if recipeData.baseItemAmount == nil then
        -- when only one item is produced the baseItemAmount will be nil as this comes form the number of items produced shown in the ui
        recipeData.baseItemAmount = 1
    end

    --print("Calculate Profession Statweights.. ")
    local priceData = CraftSimPRICEDATA:GetPriceData(recipeData)

    if priceData == nil then
        return CraftSimCONST.ERROR.NO_PRICE_DATA
    end
    local calculationResult = {}
    calculationResult.meanProfit = CraftSimSTATS:getMeanProfit(recipeData, priceData)

    calculationResult.inspiration = CraftSimSTATS:getInspirationWeight(recipeData, priceData, calculationResult.meanProfit)
    calculationResult.multicraft = CraftSimSTATS:getMulticraftWeight(recipeData, priceData, calculationResult.meanProfit)
    calculationResult.resourcefulness = CraftSimSTATS:getResourcefulnessWeight(recipeData, priceData, calculationResult.meanProfit)

    --print("BaseMeanProfit: " .. CraftSimUTIL:round(calculationResult.meanProfit, 2))
    return calculationResult
end

function CraftSimSTATS:getProfessionStatWeightsForCurrentRecipe()
	local recipeData = CraftSimDATAEXPORT:exportRecipeData()

	if recipeData == nil then
        print("recipe data nil")
		return CraftSimCONST.ERROR.NO_RECIPE_DATA
	end

	local statweights = CraftSimSTATS:CalculateStatWeights(recipeData)

    if statWeights == CraftSimCONST.ERROR.NO_PRICE_DATA then
        return CraftSimCONST.ERROR.NO_PRICE_DATA
    end

	return statweights
end