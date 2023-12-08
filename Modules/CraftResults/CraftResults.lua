CraftSimAddonName, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)
---@class CraftSim.CRAFT_RESULTS : Frame
CraftSim.CRAFT_RESULTS = CraftSim.GUTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT"})

---@type CraftSim.RecipeData
CraftSim.CRAFT_RESULTS.currentRecipeData = nil

CraftSim.CRAFT_RESULTS.currentSessionData = nil


---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFT_RESULTS:OnCraftRecipe(recipeData)

    --- triggered by enchants and not salvage crafts

    if CraftSim.MAIN.currentRecipeData then
        local recipeData = CraftSim.MAIN.currentRecipeData
        -- if the open recipe is a recraft recipe than take this as current craft results recipe data instead 
        -- because this will not be able to be triggered by the craftqueue!
        if recipeData.isRecraft then
            CraftSim.CRAFT_RESULTS.currentRecipeData = recipeData
            return
        end
    end

    CraftSim.CRAFT_RESULTS.currentRecipeData = recipeData
end

function CraftSim.CRAFT_RESULTS:OnCraftSalvage()
    if CraftSim.MAIN.currentRecipeData then
        local recipeData = CraftSim.MAIN.currentRecipeData
        -- if the open recipe is a salvage or recraft recipe than take this as current craft results recipe data instead 
        -- because this will not be able to be triggered by the craftqueue!
        if recipeData.isSalvageRecipe then
            CraftSim.CRAFT_RESULTS.currentRecipeData = recipeData
            return
        end
    end
end

local currentCraftingResults = {}
local collectingResults = true
function CraftSim.CRAFT_RESULTS:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftResult)
    if CraftSimOptions.craftResultsDisable then
        return
    end

    -- buffer a small time frame, then use all result items at once
    table.insert(currentCraftingResults, craftResult)

    if collectingResults then
        collectingResults = false
        C_Timer.After(0.1, function() 
            CraftSim.CRAFT_RESULTS:processCraftResults()
        end)
    end
end

function CraftSim.CRAFT_RESULTS:ExportJSON() 
    local sessionData = CraftSim.CRAFT_RESULTS.currentSessionData

    return sessionData:GetJSON()
end

function CraftSim.CRAFT_RESULTS:ResetData()
    CraftSim.CRAFT_RESULTS.currentSessionData = CraftSim.CraftSessionData()
end

---Saves the currentCraftData
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_RESULTS:AddCraftData(craftResult)
    local craftResultFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    print("AddCraftData:", false, true)
    ---@type CraftSim.CraftSessionData
    CraftSim.CRAFT_RESULTS.currentSessionData = CraftSim.CRAFT_RESULTS.currentSessionData
    if not CraftSim.CRAFT_RESULTS.currentSessionData then
        print("AddCraftData: Create new SessionData")
        CraftSim.CRAFT_RESULTS.currentSessionData = CraftSim.CraftSessionData()
    else
        print("AddCraftData: Reuse session data")
    end

    CraftSim.CRAFT_RESULTS.currentSessionData:AddCraftResult(craftResult)

    -- update frames
    craftResultFrame.content.totalProfitAllValue:SetText(CraftSim.GUTIL:FormatMoney(CraftSim.CRAFT_RESULTS.currentSessionData.totalProfit, true))

    CraftSim.CRAFT_RESULTS.FRAMES:UpdateItemList()
end

---Adds Results to the UI
---@param recipeData CraftSim.RecipeData
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftResult)
    CraftSim.UTIL:StartProfiling("PROCESS_CRAFT_RESULTS_UI_UPDATE")
    local craftResultFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    local resourcesText = ""

    if craftResult.triggeredResourcefulness then
        for _, savedReagent in pairs(craftResult.savedReagents) do
            local qualityID = savedReagent.qualityID
            local iconAsText = CraftSim.GUTIL:IconToText(savedReagent.item:GetItemIcon(), 25)
            local qualityAsText = (qualityID > 0 and CraftSim.GUTIL:GetQualityIconString(qualityID, 20, 20)) or ""
            resourcesText = resourcesText .. "\n" .. iconAsText .. " " .. savedReagent.quantity .. " ".. qualityAsText
        end
    end

    local roundedProfit = CraftSim.GUTIL:Round(craftResult.profit*10000) / 10000
    local profitText = CraftSim.GUTIL:FormatMoney(roundedProfit, true)
    local chanceText = ""

    if not recipeData.isSalvageRecipe and recipeData.supportsCraftingStats then
       chanceText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_5) .. CraftSim.GUTIL:Round(craftResult.craftingChance*100, 1) .. "%\n" 
    end

    local resultsText = ""
    if #craftResult.craftResultItems > 0 then
        for _, craftResultItem in pairs(craftResult.craftResultItems) do
            resultsText = resultsText .. craftResultItem.quantity .. " x " .. (craftResultItem.item:GetItemLink() or recipeData.recipeName) .. "\n"
        end
    else
        resultsText = resultsText .. recipeData.recipeName .. "\n"
    end

    local multicraftExtraItemsText = ""
    for _, craftResultItem in pairs(craftResult.craftResultItems) do
        if craftResultItem.quantityMulticraft > 0 then
            multicraftExtraItemsText = multicraftExtraItemsText .. craftResultItem.quantityMulticraft .. " x " .. craftResultItem.item:GetItemLink() .. "\n"
        end
    end

    local newText =
    resultsText ..
    CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_1) .. profitText .. "\n" ..
    chanceText ..
    ((craftResult.triggeredInspiration and CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_2) .. "\n", CraftSim.GUTIL.COLORS.LEGENDARY)) or "") ..
    ((craftResult.triggeredMulticraft and (CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_3), CraftSim.GUTIL.COLORS.EPIC) .. multicraftExtraItemsText)) or "") ..
    ((craftResult.triggeredResourcefulness and (CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_4) .. "\n", CraftSim.GUTIL.COLORS.UNCOMMON) .. resourcesText .. "\n")) or "")

    craftResultFrame.content.scrollingMessageFrame:AddMessage("\n" .. newText)

    CraftSim.CRAFT_RESULTS:AddCraftData(craftResult)
    CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(craftResult.recipeID)
    CraftSim.UTIL:StopProfiling("PROCESS_CRAFT_RESULTS_UI_UPDATE")
end

---@param recipeData CraftSim.RecipeData
---@param craftResult CraftSim.CraftResult
---@return number
function CraftSim.CRAFT_RESULTS:GetProfitForCraft(recipeData, craftResult) 
    local craftingCosts = recipeData.priceData.craftingCosts

    local savedCosts = 0
    table.foreach(craftResult.savedReagents, function (_, craftResultSavedReagent)
        savedCosts = savedCosts + craftResultSavedReagent.savedCosts
    end)

    local resultValue = 0
    for _, craftResultItem in pairs(craftResult.craftResultItems) do
        local quantity = craftResultItem.quantity + craftResultItem.quantityMulticraft
        resultValue = resultValue + (CraftSim.PRICEDATA:GetMinBuyoutByItemLink(craftResultItem.item:GetItemLink()) or 0) * quantity
    end

    local craftProfit = (resultValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - (craftingCosts - savedCosts)

    return craftProfit
end

function CraftSim.CRAFT_RESULTS:processCraftResults()
    collectingResults = true
    print("Craft Detected", false, true)
    -- print(currentCraftingResults, true)
    -- print("Num Craft Results: " .. tostring(#currentCraftingResults))

    CraftSim.UTIL:StartProfiling("PROCESS_CRAFT_RESULTS")

    local CraftingItemResultData = CopyTable(currentCraftingResults)
    currentCraftingResults = {}

    if CraftSim.GUTIL:Find(CraftingItemResultData, function(result) return result.isEnchant end) then
        print("isEnchant -> ignore")
        return
    end

    local recipeData = CraftSim.CRAFT_RESULTS.currentRecipeData;

    if not recipeData then
        print("no recipeData")
        return
    end

    local craftResult = CraftSim.CraftResult(recipeData, CraftingItemResultData)

    print("Craft Result: ")
    print(craftResult)
    
    local itemsToLoad = CraftSim.GUTIL:Map(craftResult.savedReagents, function (savedReagent)
        return savedReagent.item
    end)
    CraftSim.UTIL:StopProfiling("PROCESS_CRAFT_RESULTS")
    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
        CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftResult)
    end) 
end