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

<<<<<<< HEAD
    local minBuyOut = CraftSimPriceAPI:GetMinBuyOutByItemID(resultItemID1)
    print("minbuyout for item id: " .. tostring(minBuyOut))
=======
    local minBuyout = CraftSimPriceAPI:GetMinBuyoutByItemID(resultItemID1)
    print("minbuyout for item id: " .. tostring(minBuyout))

    local minBuyoutPerQuality = {}
    for i = 1, recipeData.maxQuality, 1 do
        local currentMinbuyout, error = CraftSimPriceAPI:GetMinBuyoutByItemID(recipeData["resultItemID" .. i])
        table.insert(minBuyoutPerQuality, currentMinbuyout)
    end
>>>>>>> b795e62 (adapted for tsm price source)

    return {
        minBuyoutPerQuality = minBuyoutPerQuality, -- {40, 50, 60, 70, 80}
        craftingCostPerCraft = 200
    }
end

<<<<<<< HEAD
function CraftSimTSM:GetMinBuyOutByItemID(itemID)
    local tsmItemString = TSM_API.Item:ToItemString(itemID)
    print("tsm itemstring")
=======
function CraftSimTSM:GetMinBuyoutByItemID(itemID)
    local _, itemLink = GetItemInfo(itemID) 
    local tsmItemString = TSM_API.ToItemString(itemLink)
    local minBuyoutPriceSourceKey = "DBMinBuyout"
    print("tsm itemstring: " .. tsmItemString)
    local minBuyout, error = TSM_API.GetCustomPriceValue(minBuyoutPriceSourceKey, tsmItemString)

    print("minbuyout: " .. minBuyout)
    print("error: " .. tostring(error))

    return minBuyout
>>>>>>> b795e62 (adapted for tsm price source)
end