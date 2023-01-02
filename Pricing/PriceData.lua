addonName, CraftSim = ...

CraftSim.PRICEDATA = {}

-- TODO: how to get possible different itemLinks / strings of different ItemUpgrade with different ilvl?
CraftSim.PRICEDATA.noPriceDataLinks = {}

function CraftSim.PRICEDATA:GetReagentCosts(recipeData, getMinimum) 
    local reagentCosts = {}
    for reagentIndex, reagentInfo in pairs(recipeData.reagents) do
        -- check if soulbound reagent
        if CraftSim.UTIL:isItemSoulbound(reagentInfo.itemsInfo[1].itemID) then
            -- well then the price is technically zero
            table.insert(reagentCosts, 0)
        else
            local totalBuyout = 0
            for _qualityIndex, itemInfo in pairs(reagentInfo.itemsInfo) do
                local minbuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemInfo.itemID, true)
                    totalBuyout = totalBuyout +  (minbuyout * itemInfo.allocations)
                    itemInfo.minBuyout = minbuyout -- used by lowestcostbyqualityID
            end
            if totalBuyout == 0 or getMinimum then
                -- Assuming that the player has 0 of an required item, set the buyout to lowest qID of that item * required
                -- Or if getMinimum is set override
                local qualityID = CraftSim.PRICEDATA:GetLowestCostQualityIDByItemsInfo(reagentInfo.itemsInfo)
                local minbuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentInfo.itemsInfo[qualityID].itemID, true)
                totalBuyout = minbuyout * reagentInfo.requiredQuantity
            end
            table.insert(reagentCosts, totalBuyout)
        end
    end

    return reagentCosts
end

function CraftSim.PRICEDATA:GetTotalCraftingCost(recipeData, getMinimum)
    if not recipeData.salvageReagent then
        local reagentCosts = CraftSim.PRICEDATA:GetReagentCosts(recipeData, getMinimum)  
        local totalCraftingCost = 0

        for _, cost in pairs(reagentCosts) do
            totalCraftingCost = totalCraftingCost + cost
        end

        return totalCraftingCost
    else
        return CraftSim.PRICEDATA:GetMinBuyoutByItemLink(recipeData.salvageReagent.itemLink, true) * recipeData.salvageReagent.requiredQuantity
    end 
end

function CraftSim.PRICEDATA:GetReagentsPriceByQuality(recipeData)
    local reagentQualityPrices = {}

    for reagentIndex, reagent in pairs(recipeData.reagents) do
        if reagent.reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
            local reagentPriceData = CopyTable(reagent.itemsInfo)
            for q, itemInfo in pairs(reagentPriceData) do
                itemInfo.minBuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemInfo.itemID, true)
            end
            reagentQualityPrices[reagentIndex] = reagentPriceData
        end
    end

    return reagentQualityPrices
end

function CraftSim.PRICEDATA:GetPriceData(recipeData, recipeType)

    if not recipeData then
        return nil
    end

    local craftingCostPerCraft = CraftSim.PRICEDATA:GetTotalCraftingCost(recipeData) 
    local minimumCostPerCraft = CraftSim.PRICEDATA:GetTotalCraftingCost(recipeData, true) 
    local reagentsPriceByQuality = CraftSim.PRICEDATA:GetReagentsPriceByQuality(recipeData)
    local minBuyoutPerQuality = {}

    if recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR then
        for _, itemLink in pairs(recipeData.result.itemQualityLinks) do
            local currentMinbuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemLink(itemLink)
            table.insert(minBuyoutPerQuality, currentMinbuyout)
        end
    elseif recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_ITEM then
        -- nothing.. we only want the reagentspriceby quality and the crafting costs
    elseif recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE or recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE then
        local currentMinbuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemID(recipeData.result.itemID)
        table.insert(minBuyoutPerQuality, currentMinbuyout)
    elseif recipeType == CraftSim.CONST.RECIPE_TYPES.SINGLE or recipeType == CraftSim.CONST.RECIPE_TYPES.MULTIPLE or recipeType == CraftSim.CONST.RECIPE_TYPES.ENCHANT then
        for _, itemID in pairs(recipeData.result.itemIDs) do
            local currentMinbuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID)
            table.insert(minBuyoutPerQuality, currentMinbuyout)
        end
    else
        print("CraftSimError: Unhandled recipeType in priceData: " .. tostring(recipeType))
    end

    return {
        minBuyoutPerQuality = minBuyoutPerQuality,
        craftingCostPerCraft = craftingCostPerCraft,
        minimumCostPerCraft = minimumCostPerCraft,
        reagentsPriceByQuality = reagentsPriceByQuality
    }
end

-- Wrappers 
function CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, isReagent)
    local minbuyout = CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, isReagent)
    if minbuyout == nil then
        local _, link = GetItemInfo(itemID)
        if link == nil then
            link = itemID
        end
        if CraftSim.PRICEDATA.noPriceDataLinks[link] == nil then
            -- not beautiful but hey, easy map
            CraftSim.PRICEDATA.noPriceDataLinks[link] = link
        end
        minbuyout = 0
    end
    return minbuyout
end

function CraftSim.PRICEDATA:GetMinBuyoutByItemLink(itemLink, isReagent)
    local minbuyout = CraftSim.PRICE_API:GetMinBuyoutByItemLink(itemLink, isReagent)
    if minbuyout == nil then
        if CraftSim.PRICEDATA.noPriceDataLinks[itemLink] == nil then
            -- not beautiful but hey, easy map
            CraftSim.PRICEDATA.noPriceDataLinks[itemLink] = itemLink
        end
        minbuyout = 0
    end
    return minbuyout
end

function CraftSim.PRICEDATA:GetLowestCostQualityIDByItemsInfo(itemsInfo)
    -- TODO: refactor spaghetti
    if not itemsInfo[1].minBuyout then
        --populate with minbuyout info
        for _, itemInfo in pairs(itemsInfo) do
            itemInfo.minBuyout = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemInfo.itemID, true)
        end
    end

    local lowestQualityID = 1
    local lowestMinBuyout = itemsInfo[1].minBuyout
    for qualityID, itemInfo in pairs(itemsInfo) do
        if itemInfo.minBuyout < lowestMinBuyout then
            lowestQualityID = qualityID
            lowestMinBuyout = itemInfo.minBuyout
        end
    end

    return lowestQualityID
end