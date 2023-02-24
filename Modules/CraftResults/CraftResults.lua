AddonName, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)
CraftSim.CRAFT_RESULTS = CraftSim.UTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT", "TRADE_SKILL_CRAFT_BEGIN"})

CraftSim.CRAFT_RESULTS.currentRecipeData = nil

CraftSim.CRAFT_RESULTS.currentSessionData = nil

-- save current craft data
function CraftSim.CRAFT_RESULTS:TRADE_SKILL_CRAFT_BEGIN(spellID)
    -- new craft begins if we do not have saved any recipe data yet
    -- or if the current cached data does not match the recipeid

    if CraftSim.MAIN.currentRecipeData and CraftSim.MAIN.currentRecipeData.recipeID == spellID then
        -- if prospecting or other salvage item, only use the current recipedata if we have a salvage reagent, otherwise use saved one
        if CraftSim.MAIN.currentRecipeData.isSalvageRecipe and CraftSim.MAIN.currentRecipeData.reagentData.salvageReagentSlot.activeItem then
            print("Use RecipeData of Salvage")
            CraftSim.CRAFT_RESULTS.currentRecipeData = CraftSim.MAIN.currentRecipeData
        elseif not CraftSim.MAIN.currentRecipeData.isSalvageRecipe then
            print("Use RecipeData")
            CraftSim.CRAFT_RESULTS.currentRecipeData = CraftSim.MAIN.currentRecipeData
        else
            print("Use RecipeData of last Salvage, cause not reagent found")
        end
    elseif CraftSim.MAIN.currentRecipeData then
        print("RecipeID does not match, take saved one")
    else
        print("No RecipeData to match current craft")
    end
end

local currentCraftingResults = {}
local collectingResults = true
function CraftSim.CRAFT_RESULTS:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftResult)
    -- buffer a small time frame, then use all result items at once
    table.insert(currentCraftingResults, craftResult)

    if collectingResults then
        collectingResults = false
        C_Timer.After(0.1, function() 
            CraftSim.CRAFT_RESULTS:processCraftResults()
        end)
    end
end

local function showhsvInfo(recipeData, craftResult)
    
    if recipeData.maxQuality and recipeData.expectedQuality < recipeData.maxQuality then
        local currentQualityProgress = recipeData.operationInfo.quality % 1
        local craftQualityProgress = craftResult.qualityProgress
        
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeData.baseDifficulty)
        local lowerThreshold = thresholds[recipeData.expectedQuality-1] or 0
        local upperThreshold = thresholds[recipeData.expectedQuality]
        local diff = upperThreshold - lowerThreshold
        local playerSkill = lowerThreshold + (diff*currentQualityProgress)
        local hsvSkill = lowerThreshold + (diff*craftQualityProgress)
        local skillDiff = hsvSkill - playerSkill
        local relativeToDifficulty = skillDiff / (recipeData.baseDifficulty / 100)

        if craftResult.isCrit then
            print("HSV (INSP):")
        else
            print("HSV:")
        end
        print("- currentQualityProgress: " .. tostring(currentQualityProgress))
        print("- craftQualityProgress: " .. tostring(craftQualityProgress))
        print("- playerSkill: " .. tostring(playerSkill))
        print("- craftSkill: " .. tostring(hsvSkill))
        print("- hsvSkill: " .. tostring(skillDiff))
        print("- % of difficulty: " .. tostring(relativeToDifficulty) .. "%")

    end
end

function CraftSim.CRAFT_RESULTS:ExportJSON() 
    local sessionData = CraftSim.CRAFT_RESULTS.currentSessionData

    if not CraftSim.MAIN.currentRecipeData then
        return
    end

    return sessionData:GetJSON()
end

function CraftSim.CRAFT_RESULTS:ResetData()
    CraftSim.CRAFT_RESULTS.currentSessionData = CraftSim.CraftSessionData()
end

---Saves the currentCraftData
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_RESULTS:AddCraftData(craftResult)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    print("AddCraftData:", false, true)
    CraftSim.CRAFT_RESULTS.currentSessionData = CraftSim.CRAFT_RESULTS.currentSessionData
    if not CraftSim.CRAFT_RESULTS.currentSessionData then
        print("AddCraftData: Create new SessionData")
        CraftSim.CRAFT_RESULTS.currentSessionData = CraftSim.CraftSessionData()
    else
        print("AddCraftData: Reuse session data")
    end

    CraftSim.CRAFT_RESULTS.currentSessionData:AddCraftResult(craftResult)

    -- update frames
    craftResultFrame.content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(CraftSim.CRAFT_RESULTS.currentSessionData.totalProfit, true))

    CraftSim.CRAFT_RESULTS.FRAMES:UpdateItemList()
end

---Adds Results to the UI
---@param recipeData CraftSim.RecipeData
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftResult)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    local resourcesText = ""

    if craftResult.triggeredResourcefulness then
        for _, savedReagent in pairs(craftResult.savedReagents) do
            local qualityID = savedReagent.qualityID
            local iconAsText = CraftSim.UTIL:IconToText(savedReagent.item:GetItemIcon(), 25)
            local qualityAsText = (qualityID > 0 and CraftSim.GUTIL:GetQualityIconString(qualityID, 20, 20)) or ""
            resourcesText = resourcesText .. "\n" .. iconAsText .. " " .. savedReagent.quantity .. " ".. qualityAsText
        end
    end

    local roundedProfit = CraftSim.GUTIL:Round(craftResult.profit*10000) / 10000
    local profitText = CraftSim.UTIL:FormatMoney(roundedProfit, true)
    local chanceText = ""

    if not recipeData.isSalvageRecipe and recipeData.supportsCraftingStats then
       chanceText = "Chance: " .. CraftSim.GUTIL:Round(craftResult.craftingChance*100, 1) .. "%\n" 
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
    "Profit: " .. profitText .. "\n" ..
    chanceText ..
    ((craftResult.triggeredInspiration and CraftSim.UTIL:ColorizeText("Inspired!\n", CraftSim.CONST.COLORS.LEGENDARY)) or "") ..
    ((craftResult.triggeredMulticraft and (CraftSim.UTIL:ColorizeText("Multicraft: ", CraftSim.CONST.COLORS.EPIC) .. multicraftExtraItemsText)) or "") ..
    ((craftResult.triggeredResourcefulness and (CraftSim.UTIL:ColorizeText("Resources Saved!: \n", CraftSim.CONST.COLORS.UNCOMMON) .. resourcesText .. "\n")) or "")

    craftResultFrame.content.scrollingMessageFrame:AddMessage("\n" .. newText)

    CraftSim.CRAFT_RESULTS:AddCraftData(craftResult)
    CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(craftResult.recipeID)
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

    local CraftingItemResultData = CopyTable(currentCraftingResults)
    currentCraftingResults = {}

    if CraftSim.UTIL:Find(CraftingItemResultData, function(result) return result.isEnchant end) then
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
    
    local itemsToLoad = CraftSim.UTIL:Map(craftResult.savedReagents, function (savedReagent)
        return savedReagent.item
    end)
    CraftSim.GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
        CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftResult)
    end) 
end