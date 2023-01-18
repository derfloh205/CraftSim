local addonName, CraftSim = ...

CraftSim.PROFIT_SCAN = {}

CraftSim.PROFIT_SCAN.scanInterval = 0.01

CraftSim.PROFIT_SCAN.SCAN_MODES = {
    Q1 = "Materials Quality 1", 
    Q2 = "Materials Quality 2", 
    Q3 = "Materials Quality 3", 
    OPTIMIZE_G = "Optimize for Guaranteed", 
    OPTIMIZE_I = "Optimize for Inspiration"}

local function print(text, recursive, l) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.MAIN, recursive, l)
end

function CraftSim.PROFIT_SCAN:GetScanMode()
    local profitScanFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.PROFIT_SCAN)
    return profitScanFrame.content.scanMode.currentMode
end

function CraftSim.PROFIT_SCAN:SetReagentAllocationByScanMode(recipeData, priceData)
    local scanMode = CraftSim.PROFIT_SCAN:GetScanMode()

    if scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.Q1 then
        for _, reagent in pairs(recipeData.reagents) do
            reagent.itemsInfo[1].allocations = reagent.requiredQuantity
        end
    elseif scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.Q2 then
        for _, reagent in pairs(recipeData.reagents) do
            if reagent.differentQualities then
                reagent.itemsInfo[2].allocations = reagent.requiredQuantity
            else
                reagent.itemsInfo[1].allocations = reagent.requiredQuantity
            end 
        end
    elseif scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.Q3 then
        for _, reagent in pairs(recipeData.reagents) do
            if reagent.differentQualities then
                reagent.itemsInfo[3].allocations = reagent.requiredQuantity
            else
                reagent.itemsInfo[1].allocations = reagent.requiredQuantity
            end 
        end
    elseif scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.OPTIMIZE_G or scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.OPTIMIZE_I then
        local bestAllocation = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeData.recipeType, priceData, CraftSim.CONST.EXPORT_MODE.SCAN)
        if bestAllocation then
            -- set reagents by best allocation
            -- print("Optimized Allocation: ")
            -- print(bestAllocation, true)
            for _, reagent in pairs(recipeData.reagents) do
                if reagent.differentQualities then
                    for _, itemInfo in pairs(reagent.itemsInfo) do
                        for _, allocation in pairs(bestAllocation.allocations) do
                            for _, subAllocation in pairs(allocation) do
                                if itemInfo.itemID == allocation.itemID then
                                    itemInfo.allocations = subAllocation.allocations
                                end
                            end
                        end
                    end
                    reagent.itemsInfo[3].allocations = reagent.requiredQuantity
                else
                    reagent.itemsInfo[1].allocations = reagent.requiredQuantity
                end 
            end
        else
            print("No best allocation found (should not be possible)")
        end
    end

    return CopyTable(recipeData.reagents)
end

function CraftSim.PROFIT_SCAN:StartScan()
    
    local scanMode = CraftSim.PROFIT_SCAN:GetScanMode()
    print("Scan Mode: " .. tostring(scanMode))
    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    local currentIndex = 1
    local function scanRecipesByInterval()
        local recipeID = recipeIDs[currentIndex]
        if not recipeID then
            return
        end
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and not recipeInfo.isRecraft and not recipeInfo.isSalvageRecipe and not recipeInfo.isGatheringRecipe then
            ---@diagnostic disable-next-line: missing-parameter
            local recipeCategoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
            if tContains(CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS, recipeCategoryInfo.parentCategoryID) and recipeInfo.itemLevel > 1 then -- nonquest dragon isles recipes
                local isQualityScan = scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.OPTIMIZE_G or scanMode == CraftSim.PROFIT_SCAN.SCAN_MODES.OPTIMIZE_I
                if recipeInfo.supportsCraftingStats and ((isQualityScan and recipeInfo.supportsQualities) or not isQualityScan) then
                    print("Scanning RecipeID: " .. tostring(recipeID))
                    -- print("- Learned: " .. tostring(recipeInfo.learned))
                    -- print("- itemLevel: " .. tostring(recipeInfo.itemLevel))
                    -- print("- Name: " .. recipeInfo.name)
                    local recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeID, CraftSim.CONST.EXPORT_MODE.SCAN);
                    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
                    local scanReagents = CraftSim.PROFIT_SCAN:SetReagentAllocationByScanMode(recipeData, priceData)

                    -- reexport the recipeData, now with the new reagents
                    recipeData = CraftSim.DATAEXPORT:exportRecipeData(recipeID, CraftSim.CONST.EXPORT_MODE.SCAN, scanReagents)
                    -- refetch price data
                    priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
                    local meanProfit = CraftSim.CALC:getMeanProfit(recipeData, priceData)

                    print("- Mean Profit: " .. CraftSim.UTIL:FormatMoney(meanProfit))
                    local outputLink = nil
                    if recipeData.result.itemQualityLinks then
                        outputLink = recipeData.result.itemQualityLinks[recipeData.expectedQuality]
                    elseif recipeData.result.itemIDs then
                        local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(recipeData.result.itemIDs[recipeData.expectedQuality])
                        outputLink = itemData.link
                    end
                    print("- Expected Item: " .. tostring(outputLink))
                    
                end
                
            end
        end

        currentIndex = currentIndex + 1

        C_Timer.After(CraftSim.PROFIT_SCAN.scanInterval, scanRecipesByInterval)
    end

    scanRecipesByInterval()
end