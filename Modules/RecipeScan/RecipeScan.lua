_, CraftSim = ...

CraftSim.RECIPE_SCAN = {}

CraftSim.RECIPE_SCAN.scanInterval = 0.01
CraftSim.RECIPE_SCAN.frame = nil
CraftSim.RECIPE_SCAN.isScanning = false

CraftSim.RECIPE_SCAN.SCAN_MODES = {
    Q1 = "Materials Quality 1", 
    Q2 = "Materials Quality 2", 
    Q3 = "Materials Quality 3", 
    OPTIMIZE_G = "Optimize for Guaranteed", 
    OPTIMIZE_I = "Optimize for Inspiration"
}

    ---@type CraftSim.RecipeData[]
CraftSim.RECIPE_SCAN.currentResults = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)

function CraftSim.RECIPE_SCAN:GetScanMode()
    local RecipeScanFrame = CraftSim.RECIPE_SCAN.frame
    return RecipeScanFrame.content.scanMode.selectedValue
end

function CraftSim.RECIPE_SCAN:ToggleScanButton(value)
    local frame = CraftSim.RECIPE_SCAN.frame
    frame.content.scanButton:SetEnabled(value)
    frame.content.cancelScanButton:SetVisible(not value)
    if not value then
        frame.content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING) .. " 0%")
    else
        frame.content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES))
    end
end

function CraftSim.RECIPE_SCAN:UpdateScanPercent(currentProgress, maxProgress)
    local currentPercentage = CraftSim.GUTIL:Round(currentProgress / (maxProgress / 100))

    if currentPercentage % 1 == 0 then
        local frame = CraftSim.RECIPE_SCAN.frame
        frame.content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING) .. " " .. currentPercentage .. "%")
    end
end

function CraftSim.RECIPE_SCAN:EndScan()
    print("scan finished")
    collectgarbage("collect") -- By Option?
    CraftSim.RECIPE_SCAN:ToggleScanButton(true)
    CraftSim.RECIPE_SCAN.isScanning = false
end

function CraftSim.RECIPE_SCAN:GetProfessionIDByRecipeID(recipeID)
    for professionID, recipeIDs in pairs(CraftSimRecipeIDs.data) do
        if tContains(recipeIDs, recipeID) then
            return professionID
        end
    end

    return nil
end

function CraftSim.RECIPE_SCAN:GetAllRecipeIDsFromCacheByProfessionID(professionID)
    return CraftSimRecipeIDs.data[professionID]
end

function CraftSim.RECIPE_SCAN:GetAllRecipeIDsFromCache()
    local recipeIDs = {}

    for professionID, professionRecipeIDs in pairs(CraftSimRecipeIDs.data) do
        for _, recipeID in pairs(professionRecipeIDs) do
            table.insert(recipeIDs, recipeID)
        end
    end

    return recipeIDs
end

function CraftSim.RECIPE_SCAN:GetRecipeInfoByResult(resultItem)

    local itemID = resultItem:GetItemID()

    print("Searching for Recipe with result: " .. tostring(itemID))

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

    if not recipeIDs or #recipeIDs == 0 then
        recipeIDs = CraftSim.RECIPE_SCAN:GetAllRecipeIDsFromCache()

        -- if still not, return nil
        if not recipeIDs or #recipeIDs == 0 then
            print("CraftSim: ProfessionRecipes not cached yet")
            return nil
        end
    end

    local recipeInfos = CraftSim.GUTIL:Map(recipeIDs, function(recipeID) 
        return C_TradeSkillUI.GetRecipeInfo(recipeID)
    end)

    -- check learned recipes for recipe with this item as result
    local foundRecipeInfo = CraftSim.GUTIL:Find(recipeInfos, function(recipeInfo) 
        if not recipeInfo.learned then
            return false
        end
        ---@diagnostic disable-next-line: missing-parameter
        local recipeCategoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
        local isDragonIsleRecipe = tContains(CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS, recipeCategoryInfo.parentCategoryID)
        if isDragonIsleRecipe and recipeInfo.isEnchantingRecipe then
            local foundEnchant, recipeID = CraftSim.GUTIL:Find(CraftSim.ENCHANT_RECIPE_DATA, function (enchantData) 
                return enchantData.q1 == itemID or enchantData.q2 == itemID or enchantData.q3 == itemID
            end)
            if foundEnchant then
                print("found as enchant")
                return true
            end
        end
        if isDragonIsleRecipe then
            if recipeInfo.hyperlink then
                local outputQ1 = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, {}, nil, 1)

                if outputQ1.itemID == itemID then
                    return true
                end

                local outputQ2 = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, {}, nil, 2)

                if outputQ2.itemID == itemID then
                    return true
                end

                local outputQ3 = C_TradeSkillUI.GetRecipeOutputItemData(recipeInfo.recipeID, {}, nil, 3)

                if outputQ3.itemID == itemID then
                    return true
                end

            end
        end
        return false
    end)

    if foundRecipeInfo then
        print("Found Recipe: " .. foundRecipeInfo.name)
        return foundRecipeInfo
    end

    return nil
end

---@param recipeInfo TradeSkillRecipeInfo
function CraftSim.RECIPE_SCAN.FilterRecipes(recipeInfo)
    if recipeInfo.isDummyRecipe then
        return false
    end
    if tContains(CraftSim.CONST.BLIZZARD_DUMMY_RECIPES, recipeInfo.recipeID) then
        return false
    end
    if not CraftSimOptions.recipeScanIncludeNotLearned and not recipeInfo.learned then
        return false
    end
    if tContains(CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS, recipeInfo.categoryID) then
        return false
    end
    ---@diagnostic disable-next-line: missing-parameter
    local recipeCategoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
    local isDragonIsleRecipe = tContains(CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS, recipeCategoryInfo.parentCategoryID)
    if isDragonIsleRecipe and recipeInfo.isEnchantingRecipe then
        return true
    end
    if isDragonIsleRecipe then
        if recipeInfo and recipeInfo.supportsCraftingStats and not recipeInfo.isGatheringRecipe and not recipeInfo.isSalvageRecipe and not recipeInfo.isRecraft then
            if recipeInfo.hyperlink then
                local isGear = recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil
                local isSoulbound = CraftSim.GUTIL:isItemSoulbound(CraftSim.GUTIL:GetItemIDByLink(recipeInfo.hyperlink))
                if not CraftSimOptions.recipeScanIncludeSoulbound then
                    if isGear and isSoulbound then
                        return false
                    end
                    if not CraftSimOptions.recipeScanIncludeGear and isGear then
                        return false
                    end

                    if isSoulbound then
                        return false
                    end
                end

                if not CraftSimOptions.recipeScanIncludeGear and isGear then
                    return false
                end
                
                return true
            end
            return false
        end
    end
    return false
end

function CraftSim.RECIPE_SCAN:StartScan()

    CraftSim.RECIPE_SCAN.currentResults = {}
    CraftSim.RECIPE_SCAN.isScanning = true
    
    local scanMode = CraftSim.RECIPE_SCAN:GetScanMode()
    print("Scan Mode: " .. tostring(scanMode))
    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    local recipeInfos = CraftSim.GUTIL:Map(recipeIDs, function(recipeID) 
        return C_TradeSkillUI.GetRecipeInfo(recipeID)
    end)
    recipeInfos = CraftSim.GUTIL:Filter(recipeInfos, CraftSim.RECIPE_SCAN.FilterRecipes)
    local currentIndex = 1

    local function scanRecipesByInterval()

        -- check if scan was ended
        if not CraftSim.RECIPE_SCAN.isScanning then
            return
        end

        CraftSim.UTIL:StartProfiling("Single Recipe Scan")
        local recipeInfo = recipeInfos[currentIndex]
        if not recipeInfo then
            CraftSim.RECIPE_SCAN:EndScan()
            return
        end

        CraftSim.RECIPE_SCAN:UpdateScanPercent(currentIndex, #recipeInfos)

        print("recipeID: " .. tostring(recipeInfo.recipeID), false, true)
        print("recipeName: " .. tostring(recipeInfo.name))
        print("isEnchant: " .. tostring(recipeInfo.isEnchantingRecipe))
        
        --- @type CraftSim.RecipeData
        local recipeData = CraftSim.RecipeData(recipeInfo.recipeID);

        if recipeData.reagentData:HasOptionalReagents() and CraftSimOptions.recipeScanUseInsight then
            recipeData:SetOptionalReagent(CraftSim.CONST.ITEM_IDS.OPTIONAL_REAGENTS.ILLUSTRIOUS_INSIGHT)
            recipeData:SetOptionalReagent(CraftSim.CONST.ITEM_IDS.OPTIONAL_REAGENTS.LESSER_ILLUSTRIOUS_INSIGHT)
        end

        recipeData.professionGearSet:LoadCurrentEquippedSet()
        recipeData:Update()
        if not recipeData then
            CraftSim.RECIPE_SCAN:EndScan()
            return
        end

        --optimize top gear first cause optimized reagents might change depending on the gear
        if CraftSimOptions.recipeScanOptimizeProfessionTools then
            CraftSim.UTIL:StartProfiling("Optimize ALL: SCAN")
            local optimizeG = scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_G
            local optimizeI = scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I
            if optimizeG or optimizeI then
                recipeData:OptimizeProfit(optimizeI)
            else
                CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
                recipeData:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
            end
            CraftSim.UTIL:StopProfiling("Optimize ALL: SCAN")
        else
            CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
        end

        local function continueScan()
            CraftSim.UTIL:StopProfiling("Single Recipe Scan")
            CraftSim.RECIPE_SCAN.FRAMES:AddRecipe(recipeData) 

            table.insert(CraftSim.RECIPE_SCAN.currentResults, recipeData)

            currentIndex = currentIndex + 1
            C_Timer.After(CraftSim.RECIPE_SCAN.scanInterval, scanRecipesByInterval)
        end
        -- so we can display them smoothly
        -- TODO: should we also wait for the reagents to load?
        CraftSim.GUTIL:ContinueOnAllItemsLoaded(recipeData.resultData.itemsByQuality, continueScan)
    end

    print("End Scan")
    CraftSim.RECIPE_SCAN:ToggleScanButton(false)
    CraftSim.RECIPE_SCAN:ResetResults()
    scanRecipesByInterval()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
    local scanMode = CraftSim.RECIPE_SCAN:GetScanMode()

    if scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q1 then
        recipeData.reagentData:SetReagentsMaxByQuality(1)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q2 then
        recipeData.reagentData:SetReagentsMaxByQuality(2)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q3 then
        recipeData.reagentData:SetReagentsMaxByQuality(3)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_G or scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I then
        local optimizeInspiration = scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I
        recipeData:OptimizeReagents(optimizeInspiration)
    end
end