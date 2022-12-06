CraftSimPRICEDATA = {}

-- TODO: how to get possible different itemLinks / strings of different ItemUpgrade with different ilvl?
CraftSimPRICEDATA.noPriceDataLinks = {}

function CraftSimPRICEDATA:GetReagentCosts(recipeData) 
    local reagentCosts = {}
    for reagentIndex, reagentInfo in pairs(recipeData.reagents) do
        -- check if soulbound reagent
        if CraftSimUTIL:isItemSoulbound(reagentInfo.itemsInfo[1].itemID) then
            -- well then the price is technically zero
            table.insert(reagentCosts, 0)
        else
            local totalBuyout = 0
            for _qualityIndex, itemInfo in pairs(reagentInfo.itemsInfo) do
                local minbuyout = CraftSimPRICEDATA:GetMinBuyoutByItemID(itemInfo.itemID)
                    totalBuyout = totalBuyout +  (minbuyout * itemInfo.allocations)
            end
            if totalBuyout == 0 then
                -- Assuming that the player has 0 of an required item, set the buyout to q1 of that item * required
                local minbuyout = CraftSimPRICEDATA:GetMinBuyoutByItemID(reagentInfo.itemsInfo[1].itemID)
                totalBuyout = minbuyout * reagentInfo.requiredQuantity
            end
            table.insert(reagentCosts, totalBuyout)
        end
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

function CraftSimPRICEDATA:GetReagentsPriceByQuality(recipeData)
    local reagentQualityPrices = {}

    for reagentIndex, reagent in pairs(recipeData.reagents) do
        if reagent.reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED then
            local reagentPriceData = CopyTable(reagent.itemsInfo)
            for _, itemInfo in pairs(reagentPriceData) do
                itemInfo.minBuyout = CraftSimPRICEDATA:GetMinBuyoutByItemID(itemInfo.itemID)
            end
            reagentQualityPrices[reagentIndex] = reagentPriceData
        end
    end

    return reagentQualityPrices
end

function CraftSimPRICEDATA:GetPriceData(recipeData, recipeType)

    if not recipeData then
        return nil
    end

    local craftingCostPerCraft = CraftSimPRICEDATA:GetTotalCraftingCost(recipeData) 
    local reagentsPriceByQuality = CraftSimPRICEDATA:GetReagentsPriceByQuality(recipeData)
    local minBuyoutPerQuality = {}

    if recipeType == CraftSimCONST.RECIPE_TYPES.GEAR then
        for _, itemLink in pairs(recipeData.result.itemQualityLinks) do
            local currentMinbuyout = CraftSimPRICEDATA:GetMinBuyoutByItemLink(itemLink)
            table.insert(minBuyoutPerQuality, currentMinbuyout)
        end
    elseif recipeType == CraftSimCONST.RECIPE_TYPES.SOULBOUND_GEAR then
        -- nothing.. we only want the reagentspriceby quality and the crafting costs
    elseif recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_SINGLE or recipeType == CraftSimCONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE then
        local currentMinbuyout = CraftSimPRICEDATA:GetMinBuyoutByItemID(recipeData.result.itemID)
        table.insert(minBuyoutPerQuality, currentMinbuyout)
    elseif recipeType == CraftSimCONST.RECIPE_TYPES.SINGLE or recipeType == CraftSimCONST.RECIPE_TYPES.MULTIPLE then
        for _, itemID in pairs(recipeData.result.itemIDs) do
            local currentMinbuyout = CraftSimPRICEDATA:GetMinBuyoutByItemID(itemID)
            table.insert(minBuyoutPerQuality, currentMinbuyout)
        end
    else
        print("CraftSimError: Unhandled recipeType in priceData: " .. tostring(recipeType))
    end

    return {
        minBuyoutPerQuality = minBuyoutPerQuality,
        craftingCostPerCraft = craftingCostPerCraft,
        reagentsPriceByQuality = reagentsPriceByQuality
    }
end

-- Wrappers 
function CraftSimPRICEDATA:GetMinBuyoutByItemID(itemID)
    local minbuyout = CraftSimPriceAPI:GetMinBuyoutByItemID(itemID)
    if minbuyout == nil then
        local _, link = GetItemInfo(itemID)
        if link == nil then
            link = itemID
        end
        if CraftSimPRICEDATA.noPriceDataLinks[link] == nil then
            -- not beautiful but hey, easy map
            CraftSimPRICEDATA.noPriceDataLinks[link] = link
        end
        minbuyout = 0
    end
    return minbuyout
end

function CraftSimPRICEDATA:GetMinBuyoutByItemLink(itemLink)
    local minbuyout = CraftSimPriceAPI:GetMinBuyoutByItemLink(itemLink)
    if minbuyout == nil then
        if CraftSimPRICEDATA.noPriceDataLinks[itemLink] == nil then
            -- not beautiful but hey, easy map
            CraftSimPRICEDATA.noPriceDataLinks[itemLink] = itemLink
        end
        minbuyout = 0
    end
    return minbuyout
end