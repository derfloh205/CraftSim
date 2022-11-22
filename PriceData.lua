CraftSimPRICEDATA = {}
CraftSimTSM = {}
CraftSimPriceAPI = {}

local DEBUG = true

local reagentMinBuyoutPerQualityDebugData = {5, 6, 7, 8, 9}

function CraftSimPRICEDATA:InitAvailablePriceAPI()
    local loaded, finished = IsAddOnLoaded("TradeSkillMaster")
    if finished then
        --print("Load TSM API")
        CraftSimPriceAPI = CraftSimTSM
    end
end

function CraftSimPRICEDATA:GetReagentCosts(recipeData) 
    local reagentCosts = {}
    local priceError = nil
    for reagentIndex, reagentInfo in pairs(recipeData.reagents) do
        -- check if soulbound reagent
        if CraftSimUTIL:isItemSoulbound(reagentInfo.itemsInfo[1].itemID) then
            -- well then the price is technically zero
            table.insert(reagentCosts, 0)
        else
            local totalBuyout = 0
            for _qualityIndex, itemInfo in pairs(reagentInfo.itemsInfo) do
                if not DEBUG then
                    local minbuyout, _priceError = CraftSimPriceAPI:GetMinBuyoutByItemID(itemInfo.itemID)
                    priceError = _priceError
                    totalBuyout = totalBuyout +  (minbuyout * itemInfo.allocations)
                else
                    local minbuyout = reagentMinBuyoutPerQualityDebugData[_qualityIndex]
                    totalBuyout = totalBuyout +  (minbuyout * itemInfo.allocations)
                end
            end
            if totalBuyout == 0 then
                -- Assuming that the player has 0 of an required item, set the buyout to q1 of that item * required
                if not DEBUG then
                    local minbuyout, _priceError = CraftSimPriceAPI:GetMinBuyoutByItemID(reagentInfo.itemsInfo[1].itemID)
                    priceError = _priceError
                    totalBuyout = minbuyout * reagentInfo.requiredQuantity
                else
                    local minbuyout = reagentMinBuyoutPerQualityDebugData[1]
                    totalBuyout = minbuyout * reagentInfo.requiredQuantity
                end
            end
            table.insert(reagentCosts, totalBuyout)
        end
    end
    if priceError and not DEBUG then
        print("Error: not all reagent possibilities have price data")
        return nil
    end
    return reagentCosts
end

function CraftSimPRICEDATA:GetTotalCraftingCost(recipeData)
    local reagentCosts = CraftSimPRICEDATA:GetReagentCosts(recipeData)  
    local totalCraftingCost = 0

    for _, cost in pairs(reagentCosts) do
        totalCraftingCost = totalCraftingCost + cost
    end

    return totalCraftingCost
end

function CraftSimPRICEDATA:GetPriceData(recipeData)
    local craftingCostPerCraft = CraftSimPRICEDATA:GetTotalCraftingCost(recipeData) 
    local priceError = nil
    local minBuyoutPerQuality = {}
    if recipeData.result.isGear then
        for _, itemLvL in pairs(recipeData.result.itemLvLs) do
            -- TODO get minbuyout by itemid and ilvl ?
            local currentMinbuyout, _priceError = CraftSimTSM:GetMinBuyoutByItemLink(recipeData.result.hyperlink)
            priceError = _priceError
            table.insert(minBuyoutPerQuality, currentMinbuyout)
        end
    elseif recipeData.result.isNoQuality then
        local currentMinbuyout, _priceError = CraftSimPriceAPI:GetMinBuyoutByItemID(recipeData.result.itemID)
        priceError = _priceError
        table.insert(minBuyoutPerQuality, currentMinbuyout)
    else
        for _, itemID in pairs(recipeData.result.itemIDs) do
            local currentMinbuyout, _priceError = CraftSimPriceAPI:GetMinBuyoutByItemID(itemID)
            priceError = _priceError
            table.insert(minBuyoutPerQuality, currentMinbuyout)
        end
    end

    if priceError and not DEBUG then
        -- TODO: gather all items with price errors and display some kind of error msg?
        return nil
    end
    if DEBUG then
        minBuyoutPerQuality = {40, 50, 60, 70, 80} -- some debug data
    end

    return {
        minBuyoutPerQuality = minBuyoutPerQuality,
        craftingCostPerCraft = craftingCostPerCraft,
    }
end

function CraftSimTSM:GetMinBuyoutByItemID(itemID)
    if itemID == nil then
        --print("itemID nil")
        return
    end
    local _, itemLink = GetItemInfo(itemID) 
    print("itemLink: " .. tostring(itemLink))
    local tsmItemString = ""
    if itemLink == nil then
        print("item link was nil..")
        tsmItemString = "i:" .. itemID -- manually, if the link was not generated
    else
        tsmItemString = TSM_API.ToItemString(itemLink)
    end
    
    local minBuyoutPriceSourceKey = "DBMinBuyout"
    --print("tsm itemstring: " .. tsmItemString)
    local minBuyout, error = TSM_API.GetCustomPriceValue(minBuyoutPriceSourceKey, tsmItemString)

    --print("minbuyout: " .. tostring(minBuyout))
    --print("error: " .. tostring(error))

    return minBuyout
end

function CraftSimTSM:GetMinBuyoutByItemLink(itemLink)
    if itemLink == nil then
        --print("itemID nil")
        return
    end
    print("by itemLink" .. itemLink)
    local tsmItemString = TSM_API.ToItemString(itemLink)
    local minBuyoutPriceSourceKey = "DBMinBuyout"
    print("tsm itemstring: " .. tsmItemString)
    local minBuyout, error = TSM_API.GetCustomPriceValue(minBuyoutPriceSourceKey, tsmItemString)

    --print("minbuyout: " .. tostring(minBuyout))
    --print("error: " .. tostring(error))

    return minBuyout
end