AddonName, CraftSim = ...

CraftSim.COSTOVERVIEW = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.COST_OVERVIEW)

function CraftSim.COSTOVERVIEW:CalculateCostOverview(recipeData, recipeType, priceData, exportMode)
    -- calculate profit for qualities from current until max
    local profitByNextQualities = {}
    if recipeData.supportsCraftingStats then
            --for i = recipeData.expectedQuality, recipeData.maxQuality, 1 do
            local numQualityItems = math.max(recipeData.maxQuality, 1)
            for i = 1, numQualityItems, 1 do
                local priceForQuality = priceData.minBuyoutPerQuality[i] or 0
                local meanProfitCurrentQuality = (priceForQuality * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT - priceData.craftingCostPerCraft
                table.insert(profitByNextQualities, meanProfitCurrentQuality)
            end
    else
        local priceForItem = priceData.minBuyoutPerQuality[1] or 0
        local meanProfitCurrentQuality = (priceForItem * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT - priceData.craftingCostPerCraft
        table.insert(profitByNextQualities, meanProfitCurrentQuality)
    end

    CraftSim.COSTOVERVIEW.FRAMES:Fill(priceData.craftingCostPerCraft, priceData.minimumCostPerCraft, profitByNextQualities, 1, exportMode) --recipeData.expectedQuality)
end