CraftSimCOSTS = {}

function CraftSimCOSTS:CalculateCostOverview(recipeData, recipeType, priceData, craftingCostsOnly)
    -- calculate profit for qualities from current until max
    local profitByNextQualities = {}
    if not craftingCostsOnly then
        for i = recipeData.expectedQuality, recipeData.maxQuality, 1 do
            local currRecipeData = CopyTable(recipeData)
            currRecipeData.expectedQuality = i
            local meanProfitCurrentQuality = CraftSimSTATS:getMeanProfit(currRecipeData, priceData)
            table.insert(profitByNextQualities, meanProfitCurrentQuality)
        end
    end

    CraftSimFRAME:FillCostOverview(priceData.craftingCostPerCraft, priceData.minimumCostPerCraft, profitByNextQualities, recipeData.expectedQuality)
end