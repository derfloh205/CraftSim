CraftSimCOSTS = {}

function CraftSimCOSTS:CalculateCostsAndProfits()
    local recipeData = CraftSimDATAEXPORT:exportRecipeData()
    local priceData = CraftSimPRICEDATA:GetPriceData(recipeData)

    -- calculate profit for qualities from current until max
    local profitByNextQualities = {}
    for i = recipeData.expectedQuality, recipeData.maxQuality, 1 do
        local currRecipeData = CopyTable(recipeData)
        currRecipeData.expectedQuality = i
        local meanProfitCurrentQuality = CraftSimSTATS:getMeanProfit(currRecipeData, priceData)
        table.insert(profitByNextQualities, meanProfitCurrentQuality)
    end

    CraftSimFRAME:FillCostOverview(priceData.craftingCostPerCraft, profitByNextQualities, recipeData.expectedQuality)
end