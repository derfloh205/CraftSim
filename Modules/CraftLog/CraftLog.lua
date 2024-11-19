---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local systemPrint = print
local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftLog")
---@class CraftSim.CRAFT_LOG : Frame
CraftSim.CRAFT_LOG = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT" })

---@type CraftSim.RecipeData
CraftSim.CRAFT_LOG.currentRecipeData = nil

CraftSim.CRAFT_LOG.currentSessionData = nil

---@type CraftSim.CRAFT_LOG.LOG_FRAME
CraftSim.CRAFT_LOG.logFrame = nil
---@type CraftSim.CRAFT_LOG.DETAILS_FRAME
CraftSim.CRAFT_LOG.advFrame = nil

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

    if CraftSim.DB.OPTIONS:Get("CRAFT_LOG_AUTO_SHOW") and not CraftSim.DB.OPTIONS:Get("MODULE_CRAFT_LOG") then
        CraftSim.DB.OPTIONS:Save("MODULE_CRAFT_LOG", true)
        CraftSim.CRAFT_LOG.logFrame:Show()
        CraftSim.CRAFT_LOG.advFrame:SetVisible(CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SHOW_ADV_LOG"))
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
        local print = CraftSim.DEBUG:RegisterDebugID("CACHE_ITEM_COUNT")
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

    local enableAdvData = not CraftSim.DB.OPTIONS:Get("CRAFT_LOG_DISABLE_ADV_DATA")
    self:UpdateCraftData(craftResult, recipeData, enableAdvData)
    self.UI:UpdateCraftLogDisplay(craftResult, recipeData)
    self.UI:UpdateAdvancedCraftLogDisplay(recipeData.recipeID)

    CraftSim.DEBUG:StopProfiling("PROCESS_CRAFT_RESULT")
end

---@param craftResult CraftSim.CraftResult
---@param recipeData CraftSim.RecipeData
---@param enableAdvData boolean
function CraftSim.CRAFT_LOG:UpdateCraftData(craftResult, recipeData, enableAdvData)
    local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftLog.UpdateCraftData")
    local recipeID = recipeData.recipeID

    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CRAFT_LOG.currentSessionData or CraftSim.CraftSessionData()
    local craftSessionData = CraftSim.CRAFT_LOG.currentSessionData

    local craftRecipeData = craftSessionData:GetCraftRecipeData(recipeID)

    craftSessionData:AddCraftResult(craftResult, enableAdvData)
    if enableAdvData then
        craftRecipeData:AddCraftResult(craftResult, recipeData)
    end
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

---@param totalCraftResultItems CraftSim.CraftResultItem[]
---@param craftResultItems CraftSim.CraftResultItem[]
function CraftSim.CRAFT_LOG:MergeCraftResultItemData(totalCraftResultItems, craftResultItems)
    for _, craftResultItemNew in ipairs(craftResultItems) do
        -- for every item in the list of craftResultItems check if it was already added
        local craftResultItemOld = CraftSim.GUTIL:Find(totalCraftResultItems, function(craftResultItemOld)
            local itemLinkNew = craftResultItemNew.item:GetItemLink() -- for gear its possible to match by itemlink
            local itemLinkOld = craftResultItemOld.item:GetItemLink()
            local itemIDNew = craftResultItemNew.item:GetItemID()
            local itemIDOld = craftResultItemOld.item:GetItemID()

            if itemLinkNew and itemLinkOld then -- if one or both are nil aka not loaded, we dont want to match..
                return itemLinkNew == itemLinkOld
            else
                return itemIDNew == itemIDOld
            end
        end)

        -- if yes we need to add the quantities
        -- need to sum quantity and quantityMulticraft into quantity together
        if craftResultItemOld then
            craftResultItemOld.quantity = craftResultItemOld.quantity +
                (craftResultItemNew.quantity + craftResultItemNew.quantityMulticraft)
            craftResultItemOld.quantityMulticraft = craftResultItemOld.quantityMulticraft +
                craftResultItemNew.quantityMulticraft
        else
            -- if its the first time the item is inserted, change quantity to total quantity
            local craftResultItem = craftResultItemNew:Copy()
            craftResultItem.quantity = craftResultItem.quantity + craftResultItem.quantityMulticraft
            table.insert(totalCraftResultItems, craftResultItem)
        end
    end
end

---@param totalReagents CraftSim.CraftResultReagent[]
---@param newReagents CraftSim.CraftResultReagent[]
function CraftSim.CRAFT_LOG:MergeReagentsItemData(totalReagents, newReagents)
    for _, savedReagentNew in ipairs(newReagents) do
        local savedReagentOld = CraftSim.GUTIL:Find(totalReagents, function(savedReagentOld)
            return savedReagentNew.item:GetItemID() == savedReagentOld.item:GetItemID()
        end)

        if savedReagentOld then
            savedReagentOld.quantity = savedReagentOld.quantity + savedReagentNew.quantity
            savedReagentOld.costs = savedReagentOld.costs + savedReagentNew.costs
        else
            table.insert(totalReagents, savedReagentNew:Copy())
        end
    end
end
