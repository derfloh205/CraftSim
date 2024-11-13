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

local accumulatingCraftingItemResultData = {}
local isAccumulatingCraftingItemResultData = true
--- Collects CraftingItemResultData tables after a recipe was crafted
--- Due to lag or other reasons one craft could fire multiple events and thus create multiple result tables
---@param craftingItemResultData CraftingItemResultData
function CraftSim.CRAFT_LOG:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftingItemResultData)
    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_DISABLE") then
        return
    end

    --CraftSim.DEBUG:InspectTable(craftingItemResultData, "craftingItemResultData")

    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_AUTO_SHOW") and not CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG") then
        CraftSim.DB.OPTIONS:Save("MODULE_CRAFT_LOG", true)
        CraftSim.CRAFT_LOG.logFrame:Show()
        CraftSim.CRAFT_LOG.detailsFrame:SetVisible(CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SHOW_ADV_LOG"))
    end

    -- buffer a small time frame, then forward all result tables at once
    table.insert(accumulatingCraftingItemResultData, craftingItemResultData)

    if isAccumulatingCraftingItemResultData then
        isAccumulatingCraftingItemResultData = false
        --TODO: check if NextFrame would make more sense or if there is an event to listen to
        -- Maybe even react on **either** a timer **or** the start of the next craft
        -- Maybe WaitForEvent could be used with a max timer?
        C_Timer.After(0.1, function()
            CraftSim.CRAFT_LOG:AccumulateCraftResults()
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
    CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(CraftSim.INIT.currentRecipeData.recipeID)
end

---Adds Results to the UI
---@param recipeData CraftSim.RecipeData last crafted
---@param craftResult CraftSim.CraftResult
function CraftSim.CRAFT_LOG:ProcessCraftResult(recipeData, craftResult)
    CraftSim.DEBUG:StartProfiling("PROCESS_CRAFT_RESULT")

    self:UpdateCraftData(craftResult, recipeData)
    self.UI:UpdateCraftLogDisplay(craftResult, recipeData)
    self.UI:UpdateAdvancedCraftLogDisplay(recipeData.recipeID)

    CraftSim.DEBUG:StopProfiling("PROCESS_CRAFT_RESULT")
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

---@param craftResult CraftSim.CraftResult
---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFT_LOG:UpdateCraftData(craftResult, recipeData)
    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_LOG)
    local recipeID = recipeData.recipeID

    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CRAFT_LOG.currentSessionData or CraftSim.CraftSessionData()
    local craftSessionData = CraftSim.CRAFT_LOG.currentSessionData

    local craftRecipeData = craftSessionData:GetCraftRecipeData(recipeID)
    if not craftRecipeData then
        craftRecipeData = CraftSim.CraftRecipeData(recipeID)
        table.insert(craftSessionData.craftRecipeData, craftRecipeData)
    end

    print("AddCraftResult:", false, true)

    craftSessionData:AddCraftResult(craftResult)
    craftRecipeData:AddCraftResult(craftResult)
end

--- Collects craft results from last craft and puts them into one CraftResult object for further processing
--- Also pairs the CraftResult with the relevant RecipeData object for further analysis
function CraftSim.CRAFT_LOG:AccumulateCraftResults()
    isAccumulatingCraftingItemResultData = true
    print("AccumulateCraftResults", false, true)

    CraftSim.DEBUG:StartProfiling("PROCESS_CRAFT_LOG")

    local collectedCraftingItemResultData = accumulatingCraftingItemResultData
    accumulatingCraftingItemResultData = {}

    if GUTIL:Find(collectedCraftingItemResultData, function(result) return result.isEnchant end) then return end

    local recipeData = CraftSim.CRAFT_LOG.currentRecipeData;

    if not recipeData then return end

    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_IGNORE_WORK_ORDERS") and recipeData:IsWorkOrder() then return end

    local craftResult = CraftSim.CraftResult(recipeData, collectedCraftingItemResultData)

    local itemsToLoad = GUTIL:Map(craftResult.savedReagents, function(savedReagent)
        return savedReagent.item
    end)
    CraftSim.DEBUG:StopProfiling("PROCESS_CRAFT_LOG")
    GUTIL:ContinueOnAllItemsLoaded(itemsToLoad, function()
        CraftSim.CRAFT_LOG:ProcessCraftResult(recipeData, craftResult)
    end)
end
