CraftSimTOOLTIP = {}

local hooked = false
function CraftSimTOOLTIP:Init()
    if hooked then
        return
    end
    hooked = true

    local function OnTooltipSetItem(tooltip, data) 
        local name, itemLink = GameTooltip:GetItem()

        if not itemLink then
            return
        end

        local itemID = CraftSimUTIL:GetItemIDByLink(itemLink)

        if not itemID then
            return
        end

        local tooltipData = CraftSimTooltipData[itemID] or CraftSimTooltipData[itemLink]

        if not tooltipData then
            return
        end

        -- only reagent data is needed for this within the recipeData
        local craftingCostPerCraft = CraftSimPRICEDATA:GetTotalCraftingCost(tooltipData)

        local resultValue = 0
        if tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR then
            resultValue = CraftSimPRICEDATA:GetMinBuyoutByItemLink(tooltipData.result.hyperlink)
        elseif tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
            resultValue = CraftSimPRICEDATA:GetMinBuyoutByItemID(tooltipData.result.itemID) * tooltipData.baseItemAmount
        elseif tooltipData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_ITEM and tooltipData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
            resultValue = CraftSimPRICEDATA:GetMinBuyoutByItemID(tooltipData.result.itemIDs[tooltipData.expectedQuality]) * tooltipData.baseItemAmount
        end
        
        local profitByCraft = resultValue * CraftSim.CONST.AUCTION_HOUSE_CUT - craftingCostPerCraft

        local titleLine = "CraftSim"
        GameTooltip:AddLine(titleLine)
        local relativeValue = CraftSimOptions.showProfitPercentage and craftingCostPerCraft or nil
        GameTooltip:AddDoubleLine(" Crafter:", tooltipData.crafter, 0.43, 0.57, 0.89, 1, 1, 1) -- TODO: class colors?
        GameTooltip:AddDoubleLine(" Profit / Craft (".. tooltipData.baseItemAmount .." Items):", CraftSimUTIL:FormatMoney(profitByCraft, true, relativeValue), 0.43, 0.57, 0.89)
        GameTooltip:AddDoubleLine(" Crafting costs with last used material combination:", CraftSimUTIL:FormatMoney(craftingCostPerCraft), 0.43, 0.57, 0.89, 1, 1, 1)

        if not CraftSimOptions.detailedCraftingInfoTooltip then
            return
        end

        -- TODO: show last sync?

        for _, reagent in pairs(tooltipData.reagents) do
            local combinationText = ""
            local priceText = ""

            if reagent.differentQualities then
                local allocations = {
                    reagent.itemsInfo[1].allocations,
                    reagent.itemsInfo[2].allocations,
                    reagent.itemsInfo[3].allocations,
                }
                local materialSum = allocations[1] + allocations[2] + allocations[3]
                if materialSum == 0 then
                    -- assume cheapest material
                    local qualityID = CraftSimPRICEDATA:GetLowestCostQualityIDByItemsInfo(reagent.itemsInfo)
                    allocations[qualityID] = reagent.requiredQuantity
                end
                combinationText = allocations[1] .. " | " .. allocations[2] .. " | " .. allocations[3]
                local prices = {
                    CraftSimPRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[1].itemID, true) * allocations[1],
                    CraftSimPRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[2].itemID, true) * allocations[2],
                    CraftSimPRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[3].itemID, true) * allocations[3],
                }

                local sum = prices[1] + prices[2] + prices[3]
                -- TODO: tooltip option
                --priceText = CraftSimUTIL:FormatMoney(prices[1]) .. " | " .. CraftSimUTIL:FormatMoney(prices[2]) .. " | " .. CraftSimUTIL:FormatMoney(prices[3]) .. " (" .. CraftSimUTIL:FormatMoney(sum) .. ")"
                priceText = CraftSimUTIL:FormatMoney(sum)
            else
                local allocations = reagent.itemsInfo[1].allocations or reagent.quantityRequired
                combinationText = allocations
                local price = CraftSimPRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[1].itemID, true) * allocations
                priceText = CraftSimUTIL:FormatMoney(price)
            end
            local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(reagent.itemsInfo[1].itemID)
            GameTooltip:AddDoubleLine(" " .. itemData.name .. ": " .. combinationText, priceText, 1, 1, 1, 1, 1, 1)
        end
    end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
end