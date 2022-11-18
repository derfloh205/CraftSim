CraftSimPRICEDATA = {}

function CraftSimPRICEDATA:GetPriceData(recipeData)
    -- from selected price source e.g. TSM or Auctionator or UndermineJournal..
    local resultItemID1 = recipeData.resultItemID1
    local reagentList = {} -- TODO: get list of used reagentIDs by quality to retrieve

    return {
        minBuyoutPerItem = {40, 50, 60, 70, 80},
        craftingCostPerCraft = 200
    }
end