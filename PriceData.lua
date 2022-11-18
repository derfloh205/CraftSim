CraftSimPRICEDATA = {}
CraftSimTSM = {}
CraftSimPriceAPI = {}

function CraftSimPRICEDATA:InitAvailablePriceAPI()
    local loaded, finished = IsAddOnLoaded("TradeSkillMaster")
    if finished then
        print("Load TSM API")
        CraftSimPriceAPI = CraftSimTSM
    end
end

function CraftSimPRICEDATA:GetPriceData(recipeData)
    local resultItemID1 = recipeData.resultItemID1
    local reagentList = {} -- TODO: get list of used reagentIDs by quality to retrieve

    local minBuyOut = CraftSimPriceAPI:GetMinBuyOutByItemID(resultItemID1)
    print("minbuyout for item id: " .. tostring(minBuyOut))

    return {
        minBuyoutPerItem = {40, 50, 60, 70, 80},
        craftingCostPerCraft = 200
    }
end

function CraftSimTSM:GetMinBuyOutByItemID(itemID)
    local tsmItemString = TSM_API.Item:ToItemString(itemID)
    print("tsm itemstring")
end