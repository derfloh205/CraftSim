---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local systemPrint = print
local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_LOG)
---@class CraftSim.CRAFT_LOG : Frame
CraftSim.CRAFT_LOG = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT" })

---@type CraftSim.RecipeData
CraftSim.CRAFT_LOG.currentRecipeData = nil

CraftSim.CRAFT_LOG.currentSessionData = nil

---@type CraftSim.CRAFT_LOG.LOG_FRAME
CraftSim.CRAFT_LOG.logFrame = nil
---@type CraftSim.CRAFT_LOG.DETAILS_FRAME
CraftSim.CRAFT_LOG.detailsFrame = nil

local dataCollect = true

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFT_LOG:SetCraftedRecipeData(recipeData)
    print("OnCraftRecipe: " .. tostring(recipeData))
    CraftSim.CRAFT_LOG.currentRecipeData = recipeData
end

local currentCraftingResults = {}
local collectingResults = true
---@param craftResult CraftingItemResultData
function CraftSim.CRAFT_LOG:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftResult)
    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_DISABLE") then
        return
    end

    --CraftSim.DEBUG:InspectTable(craftResult, "Craft Result")

    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_AUTO_SHOW") and not CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG") then
        CraftSim.DB.OPTIONS:Save("MODULE_CRAFT_LOG", true)
        CraftSim.CRAFT_LOG.logFrame:Show()
        CraftSim.CRAFT_LOG.detailsFrame:SetVisible(CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SHOW_ADV_LOG"))
    end

    -- buffer a small time frame, then use all result items at once
    table.insert(currentCraftingResults, craftResult)

    if collectingResults then
        collectingResults = false
        C_Timer.After(0.1, function()
            CraftSim.CRAFT_LOG:processCraftResults()
        end)
    end

    -- always update reagents of that craft
    GUTIL:WaitForEvent("PLAYERREAGENTBANKSLOTS_CHANGED", function()
        local print = CraftSim.DEBUG:SetDebugPrint("CACHE_ITEM_COUNT")
        print("PLAYERREAGENTBANKSLOTS_CHANGED After Craft")
        -- update item count for each of the used reagents in this craft! (in next frame to batch results)
        RunNextFrame(function()
            local recipeData = CraftSim.CRAFT_LOG.currentRecipeData
            print("Updating Reagents Count for: " .. tostring(recipeData.recipeName))
            recipeData.reagentData:UpdateItemCountCacheForAllocatedReagents()
        end)
    end, 0.1)
end

function CraftSim.CRAFT_LOG:ExportJSON()
    local sessionData = CraftSim.CRAFT_LOG.currentSessionData

    return sessionData:GetJSON()
end

function CraftSim.CRAFT_LOG:ClearData()
    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CraftSessionData()
    CraftSim.CRAFT_LOG.logFrame.content.craftLogScrollingMessageFrame:Clear()
    CraftSim.CRAFT_LOG.logFrame.content.craftedItemsList:Remove()
    CraftSim.CRAFT_LOG.logFrame.content.craftedItemsList:UpdateDisplay()
    CraftSim.CRAFT_LOG.logFrame.content.sessionProfitValue:SetText(CraftSim.UTIL:FormatMoney(0, true))
    CraftSim.CRAFT_LOG.UI:UpdateRecipeData(CraftSim.INIT.currentRecipeData.recipeID)
end

---Saves the currentCraftResult
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_LOG:AddCraftResult(craftResult)
    local detailsFrame = CraftSim.CRAFT_LOG.detailsFrame
    local logFrame = CraftSim.CRAFT_LOG.logFrame

    print("AddCraftResult:", false, true)
    ---@type CraftSim.CraftSessionData
    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CRAFT_LOG.currentSessionData or CraftSim.CraftSessionData()

    CraftSim.CRAFT_LOG.currentSessionData:AddCraftResult(craftResult)

    logFrame.content.sessionProfitValue:SetText(CraftSim.UTIL:FormatMoney(
        CraftSim.CRAFT_LOG.currentSessionData.totalProfit, true))

    CraftSim.CRAFT_LOG.UI:UpdateItemList()
end

---Adds Results to the UI
---@param recipeData CraftSim.RecipeData
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_LOG:AddResult(recipeData, craftResult)
    CraftSim.DEBUG:StartProfiling("PROCESS_CRAFT_LOG_UI_UPDATE")
    local craftLogFrame = CraftSim.CRAFT_LOG.logFrame
    local craftLog = craftLogFrame.content.craftLogScrollingMessageFrame

    local resourcesText = ""

    if craftResult.triggeredResourcefulness then
        for _, savedReagent in pairs(craftResult.savedReagents) do
            local qualityID = savedReagent.qualityID
            local iconAsText = GUTIL:IconToText(savedReagent.item:GetItemIcon(), 25)
            local qualityAsText = (qualityID > 0 and GUTIL:GetQualityIconString(qualityID, 20, 20)) or ""
            resourcesText = resourcesText .. "\n" .. iconAsText .. " " .. savedReagent.quantity .. " " .. qualityAsText
        end
    end

    local roundedProfit = GUTIL:Round(craftResult.profit * 10000) / 10000
    local profitText = CraftSim.UTIL:FormatMoney(roundedProfit, true)
    local chanceText = ""

    if not recipeData.isSalvageRecipe and recipeData.supportsCraftingStats then
        chanceText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5) ..
            GUTIL:Round(craftResult.craftingChance * 100, 1) .. "%\n"
    end

    local resultsText = ""
    if #craftResult.craftResultItems > 0 then
        for _, craftResultItem in pairs(craftResult.craftResultItems) do
            resultsText = resultsText ..
                craftResultItem.quantity ..
                " x " .. (craftResultItem.item:GetItemLink() or recipeData.recipeName) .. "\n"
        end
    else
        resultsText = resultsText .. recipeData.recipeName .. "\n"
    end

    local multicraftExtraItemsText = ""
    for _, craftResultItem in pairs(craftResult.craftResultItems) do
        if craftResultItem.quantityMulticraft > 0 then
            multicraftExtraItemsText = multicraftExtraItemsText ..
                craftResultItem.quantityMulticraft .. " x " .. craftResultItem.item:GetItemLink() .. "\n"
        end
    end

    local newText =
        resultsText ..
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1) .. profitText .. "\n" ..
        chanceText ..
        ((craftResult.triggeredMulticraft and (GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3), GUTIL.COLORS.EPIC) .. multicraftExtraItemsText)) or "") ..
        ((craftResult.triggeredResourcefulness and (GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4) .. "\n", GUTIL.COLORS.UNCOMMON) .. resourcesText .. "\n")) or "")

    craftLog:AddMessage("\n" .. newText)

    CraftSim.CRAFT_LOG:AddCraftResult(craftResult)
    CraftSim.CRAFT_LOG.UI:UpdateRecipeData(craftResult.recipeID)
    CraftSim.DEBUG:StopProfiling("PROCESS_CRAFT_LOG_UI_UPDATE")
end

---@param recipeData CraftSim.RecipeData
---@param craftResult CraftSim.CraftResult
---@return number
function CraftSim.CRAFT_LOG:GetProfitForCraft(recipeData, craftResult)
    local craftingCosts = recipeData.priceData.craftingCosts

    local savedCosts = 0
    table.foreach(craftResult.savedReagents, function(_, craftResultSavedReagent)
        savedCosts = savedCosts + craftResultSavedReagent.savedCosts
    end)

    local resultValue = 0
    for _, craftResultItem in pairs(craftResult.craftResultItems) do
        local itemLink = craftResultItem.item:GetItemLink()
        local qualityID = GUTIL:GetQualityIDFromLink(itemLink)
        local quantity = craftResultItem.quantity + craftResultItem.quantityMulticraft
        local priceOverrideData = CraftSim.DB.PRICE_OVERRIDE:GetResultOverride(recipeData.recipeID, qualityID)
        local resultItemPrice = (priceOverrideData and priceOverrideData.price) or
            CraftSim.PRICE_SOURCE:GetMinBuyoutByItemLink(itemLink) or 0
        resultValue = resultValue + resultItemPrice * quantity
        print("resultitem: " .. (itemLink or 0))
        print("result value: " .. CraftSim.UTIL:FormatMoney(resultValue, true))
        if priceOverrideData then
            print("(result price overridden)")
        end
    end


    local craftProfit = (resultValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - (craftingCosts - savedCosts)

    return craftProfit
end

function CraftSim.CRAFT_LOG:processCraftResults()
    collectingResults = true
    print("Craft Detected", false, true)
    -- print(currentCraftingResults, true)
    -- print("Num Craft Results: " .. tostring(#currentCraftingResults))

    CraftSim.DEBUG:StartProfiling("PROCESS_CRAFT_LOG")

    local CraftingItemResultData = CopyTable(currentCraftingResults)
    currentCraftingResults = {}

    if GUTIL:Find(CraftingItemResultData, function(result) return result.isEnchant end) then
        print("isEnchant -> ignore")
        return
    end

    local recipeData = CraftSim.CRAFT_LOG.currentRecipeData;

    if not recipeData then
        print("no recipeData")
        return
    end

    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_IGNORE_WORK_ORDERS") and recipeData:IsWorkOrder() then
        return
    end

    print("process craft results for: " .. tostring(recipeData.recipeName))
    local craftResult = CraftSim.CraftResult(recipeData, CraftingItemResultData)

    -- Debug for data collection
    CraftSim.CRAFT_LOG:CollectData(recipeData, craftResult)

    -- print("Craft Result: ")
    -- print(craftResult)

    local itemsToLoad = GUTIL:Map(craftResult.savedReagents, function(savedReagent)
        return savedReagent.item
    end)
    CraftSim.DEBUG:StopProfiling("PROCESS_CRAFT_LOG")
    GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function()
        CraftSim.CRAFT_LOG:AddResult(recipeData, craftResult)
    end)
end

local collectData = {}
--- used to gather craft data for craftsim tuning, adjust as needed
---@param recipeData CraftSim.RecipeData
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_LOG:CollectData(recipeData, craftResult)
    if not dataCollect then return end

    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_DATA_COLLECT)

    collectData.craftsTotal = collectData.craftsTotal or 0
    collectData.yieldDistribution = collectData.yieldDistribution or {}
    collectData.yieldFactors = collectData.yieldFactors or {}

    local tastyHatchlingsTreat = 381380 -- yields 2
    local blubberyMuffin = 381377       -- yields 3
    local pepples = 381363              -- yields 2-3
    local twiceBakedPotato = 381365     -- yields 4
    local charitableCheddar = 407100    -- yields 5

    -- yield data collection for item amount
    if recipeData.isCooking and recipeData.recipeID == pepples then
        collectData.craftsTotal = collectData.craftsTotal + 1
        local quantity = craftResult.craftResultItems[1].quantity
        collectData.yieldDistribution[quantity] = collectData.yieldDistribution[quantity] or 0
        collectData.yieldDistribution[quantity] = collectData.yieldDistribution[quantity] + 1


        -- update all cause craftsTotal changed
        for quantity, _ in pairs(collectData.yieldDistribution) do
            collectData.yieldFactors[quantity] = GUTIL:Round(
                collectData.yieldDistribution[quantity] / collectData.craftsTotal, 3)
        end

        print("-- #" .. collectData.craftsTotal, false, true)
        print(collectData.yieldFactors, true)
    end
end
