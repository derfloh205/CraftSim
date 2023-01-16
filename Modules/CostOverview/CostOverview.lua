addonName, CraftSim = ...

CraftSim.COSTOVERVIEW = {}

function CraftSim.COSTOVERVIEW:CalculateCostOverview(recipeData, recipeType, priceData, craftingCostsOnly, exportMode)
    -- calculate profit for qualities from current until max
    local profitByNextQualities = {}
    if not craftingCostsOnly then
        --for i = recipeData.expectedQuality, recipeData.maxQuality, 1 do
        for i = 1, recipeData.maxQuality, 1 do
            local currRecipeData = CopyTable(recipeData)
            currRecipeData.expectedQuality = i
            local priceForQuality = priceData.minBuyoutPerQuality[i] or 0
            local meanProfitCurrentQuality = (priceForQuality * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT - priceData.craftingCostPerCraft
            table.insert(profitByNextQualities, meanProfitCurrentQuality)
        end
    end

    CraftSim.COSTOVERVIEW.FRAMES:Fill(priceData.craftingCostPerCraft, priceData.minimumCostPerCraft, profitByNextQualities, 1, exportMode) --recipeData.expectedQuality)
end