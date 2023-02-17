AddonName, CraftSim = ...

CraftSim.COSTOVERVIEW = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.COST_OVERVIEW)

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.COSTOVERVIEW:UpdateDisplay(recipeData, exportMode)
    -- calculate profit for qualities from current until max
    local profitByNextQualities = {}
    if recipeData.supportsCraftingStats then
            --for i = recipeData.expectedQuality, recipeData.maxQuality, 1 do
            local numQualityItems = math.max(recipeData.maxQuality, 1)
            for i = 1, numQualityItems, 1 do
                local priceForQuality = recipeData.priceData.qualityPriceList[i] or 0
                local meanProfitCurrentQuality = (priceForQuality * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT - recipeData.priceData.craftingCosts
                table.insert(profitByNextQualities, meanProfitCurrentQuality)
            end
    else
        local priceForItem = recipeData.priceData.qualityPriceList[1] or 0
        local meanProfitCurrentQuality = (priceForItem * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT - recipeData.priceData.craftingCosts
        table.insert(profitByNextQualities, meanProfitCurrentQuality)
    end

    -- TODO: refactor the mincraftingcosts thingy, currently just set it always to same
    CraftSim.COSTOVERVIEW.FRAMES:UpdateDisplay(recipeData, profitByNextQualities, 1, exportMode)
end