CraftSimAddonName, CraftSim = ...

CraftSim.TOOLTIP = {}

local hooked = false
function CraftSim.TOOLTIP:Init()
    if hooked then
        return
    end
    hooked = true

    -- local function OnTooltipSetItem(tooltip, data) 
    --     if not tooltip.GetItem then
    --         return
    --     end
    --     local name, itemLink = tooltip:GetItem()

    --     if not itemLink then
    --         return
    --     end

    --     local itemID = CraftSim.GUTIL:GetItemIDByLink(itemLink)

    --     if not itemID then
    --         return
    --     end

    --     local tooltipData = CraftSimTooltipData[itemID] or CraftSimTooltipData[itemLink]

    --     if not tooltipData then
    --         return
    --     end

    --     -- only reagent data is needed for this within the recipeData
    --     local craftingCostPerCraft = CraftSim.PRICEDATA:GetTotalCraftingCost(tooltipData)

    --     local resultValue = 0
    --     if tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR then
    --         resultValue = CraftSim.PRICEDATA:GetMinBuyoutByItemLink(tooltipData.result.hyperlink)
    --     elseif tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_MULTIPLE or tooltipData.recipeType == CraftSim.CONST.RECIPE_TYPES.NO_QUALITY_SINGLE then
    --         resultValue = CraftSim.PRICEDATA:GetMinBuyoutByItemID(tooltipData.result.itemID) * tooltipData.baseItemAmount
    --     elseif tooltipData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_ITEM and tooltipData.recipeType ~= CraftSim.CONST.RECIPE_TYPES.NO_CRAFT_OPERATION then
    --         resultValue = CraftSim.PRICEDATA:GetMinBuyoutByItemID(tooltipData.result.itemIDs[tooltipData.expectedQuality]) * tooltipData.baseItemAmount
    --     end
        
    --     local profitByCraft = resultValue * CraftSim.CONST.AUCTION_HOUSE_CUT - craftingCostPerCraft

    --     local titleLine = "CraftSim"
    --     tooltip:AddLine(titleLine)
    --     local relativeValue = CraftSimOptions.showProfitPercentage and craftingCostPerCraft or nil
    --     tooltip:AddDoubleLine(" Crafter:", tooltipData.crafter, 0.43, 0.57, 0.89, 1, 1, 1) -- TODO: class colors?
    --     tooltip:AddDoubleLine(" Profit / Craft (".. tooltipData.baseItemAmount .." Items):", CraftSim.GUTIL:FormatMoney(profitByCraft, true, relativeValue), 0.43, 0.57, 0.89)
    --     tooltip:AddDoubleLine(" Crafting costs with last used material combination:", CraftSim.GUTIL:FormatMoney(craftingCostPerCraft), 0.43, 0.57, 0.89, 1, 1, 1)

    --     if not CraftSimOptions.detailedCraftingInfoTooltip then
    --         return
    --     end

    --     -- TODO: show last sync?

    --     for _, reagent in pairs(tooltipData.reagents) do
    --         local combinationText = ""
    --         local priceText = ""

    --         if reagent.differentQualities then
    --             local allocations = {
    --                 reagent.itemsInfo[1].allocations,
    --                 reagent.itemsInfo[2].allocations,
    --                 reagent.itemsInfo[3].allocations,
    --             }
    --             local materialSum = allocations[1] + allocations[2] + allocations[3]
    --             if materialSum == 0 then
    --                 -- assume cheapest material
    --                 local qualityID = CraftSim.PRICEDATA:GetLowestCostQualityIDByItemsInfo(reagent.itemsInfo)
    --                 allocations[qualityID] = reagent.requiredQuantity
    --             end
    --             combinationText = allocations[1] .. " | " .. allocations[2] .. " | " .. allocations[3]
    --             local prices = {
    --                 CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[1].itemID, true) * allocations[1],
    --                 CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[2].itemID, true) * allocations[2],
    --                 CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[3].itemID, true) * allocations[3],
    --             }

    --             local sum = prices[1] + prices[2] + prices[3]
    --             -- TODO: tooltip option
    --             --priceText = CraftSim.GUTIL:FormatMoney(prices[1]) .. " | " .. CraftSim.GUTIL:FormatMoney(prices[2]) .. " | " .. CraftSim.GUTIL:FormatMoney(prices[3]) .. " (" .. CraftSim.GUTIL:FormatMoney(sum) .. ")"
    --             priceText = CraftSim.GUTIL:FormatMoney(sum)
    --         else
    --             local allocations = reagent.itemsInfo[1].allocations or reagent.quantityRequired
    --             combinationText = allocations
    --             local price = CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagent.itemsInfo[1].itemID, true) * allocations
    --             priceText = CraftSim.GUTIL:FormatMoney(price)
    --         end
    --         local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(reagent.itemsInfo[1].itemID)
    --         tooltip:AddDoubleLine(" " .. itemData.name .. ": " .. combinationText, priceText, 1, 1, 1, 1, 1, 1)
    --     end
    -- end

    --TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
end