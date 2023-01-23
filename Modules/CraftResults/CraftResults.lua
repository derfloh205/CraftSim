AddonName, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)
CraftSim.CRAFT_RESULTS = CraftSim.UTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT", "TRADE_SKILL_CRAFT_BEGIN"})

CraftSim.CRAFT_RESULTS.currentRecipeData = nil
CraftSim.CRAFT_RESULTS.currentCrafts = 0

CraftSim.CRAFT_RESULTS.sessionData = {
    total = {
        profit = 0,
        craftedItems = {},
    },
    byRecipe = {},
}

CraftSim.CRAFT_RESULTS.baseRecipeEntry = {
    profit = 0, 
    craftedItems = {}, 
    statistics = {
        totalExpectedAverageProfit = 0,
        crafts = 0,
        baseItemCount = 0,
        inspiration = 0,
        multicraft = 0,
        multicraftExtraItems = 0,
        resourcefulness = 0,
        savedReagents = {},
        -- and many more?
    }
}

local resetData = CopyTable(CraftSim.CRAFT_RESULTS.sessionData)

function CraftSim.CRAFT_RESULTS:ResetData()
    CraftSim.CRAFT_RESULTS.sessionData = CopyTable(resetData)
end

function CraftSim.CRAFT_RESULTS:AddCraftData(craftData, recipeID)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)
    CraftSim.CRAFT_RESULTS.sessionData.total.profit = CraftSim.CRAFT_RESULTS.sessionData.total.profit + craftData.profit
    CraftSim.CRAFT_RESULTS.sessionData.total.craftedItems[craftData.resultLink] = (CraftSim.CRAFT_RESULTS.sessionData.total.craftedItems[craftData.resultLink] or 0) + 1

    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID] = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID] or CopyTable(CraftSim.CRAFT_RESULTS.baseRecipeEntry)

    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.crafts = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.crafts + 1
    
    if not craftData.proccs.multicraft.triggered then
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount = 
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount + craftData.craftedItems
    end

    if craftData.proccs.inspiration.triggered then
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.inspiration = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.inspiration or 0) + 1
    end

    if not craftData.proccs.multicraft.triggered then
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount = 
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount + craftData.craftedItems
    else
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraft = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraft or 0) + 1
        
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraftExtraItems = 
        (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraftExtraItems or 0) + craftData.proccs.multicraft.extraItems

        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount = 
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount + craftData.proccs.multicraft.baseItems
    end

    if craftData.proccs.resourcefulness.triggered then
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.resourcefulness = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.resourcefulness or 0) + 1
        
        for _, savedReagent in pairs(craftData.proccs.resourcefulness.savedReagents) do
            local itemID = savedReagent:GetItemID()
            if not CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.savedReagents[savedReagent:GetItemID()] then
                CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.savedReagents[savedReagent:GetItemID()] = {
                    itemID = itemID,
                    quantity = savedReagent.quantity, 
                }
            else
                CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.savedReagents[savedReagent:GetItemID()].quantity = 
                CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.savedReagents[savedReagent:GetItemID()].quantity + savedReagent.quantity
            end
        end
    end

    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].profit = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].profit + craftData.profit
    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.totalExpectedAverageProfit = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.totalExpectedAverageProfit + craftData.expectedAverageProfit
    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].craftedItems[craftData.resultLink] = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].craftedItems[craftData.resultLink] or 0) + 1


    -- update frames
    craftResultFrame.content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(CraftSim.CRAFT_RESULTS.sessionData.total.profit, true))

    CraftSim.CRAFT_RESULTS.FRAMES:UpdateItemList()
end

-- save current craft data
function CraftSim.CRAFT_RESULTS:TRADE_SKILL_CRAFT_BEGIN(spellID)
    -- new craft begins if we do not have saved any recipe data yet
    -- or if the current cached data does not match the recipeid
    if CraftSim.CRAFT_RESULTS.currentRecipeData == nil or (CraftSim.CRAFT_RESULTS.currentRecipeData and CraftSim.CRAFT_RESULTS.currentRecipeData.recipeID ~= spellID) then
        local craftingQueue = ProfessionsFrame.CraftingPage.craftingQueue
        -- get recipe data from crafting queue, spellid, and export recipe data with reagent overwrite?
        -- this might make it possible to track crafts that are initiated from anywhere
        local totalCrafts = 0
        CraftSim.CRAFT_RESULTS.currentCrafts = 1
        if craftingQueue then
            print("crafting queue: ")
            print(craftingQueue, true)
            totalCrafts = (craftingQueue and craftingQueue:GetTotal()) or 1

            -- TODO: get reagent info from crafting queue and create recipe data with it
            -- TODO: where to get reagent info if no crafting queue? (e.g. when only 1 item is crafted)
            -- for now just assume we start at the correct recipe
            if CraftSim.MAIN.currentRecipeData and CraftSim.MAIN.currentRecipeData.recipeID == spellID then
                CraftSim.CRAFT_RESULTS.currentRecipeData = CraftSim.MAIN.currentRecipeData
            else
                -- TODO: consider this case but for now its so edge case that we skip it
            end

        else -- no crafting queue = only 1 item is crafted
            -- assume we are on the same recipe as the currentRecipeData in CraftSim.MAIN points to
            print("no crafting queue, check current main recipe data")
            if CraftSim.MAIN.currentRecipeData and CraftSim.MAIN.currentRecipeData.recipeID == spellID then
                print("matches")
                CraftSim.CRAFT_RESULTS.currentRecipeData = CraftSim.MAIN.currentRecipeData
                totalCrafts = C_TradeSkillUI.GetRecipeRepeatCount(); -- mostly 1 ?
            else
                print("does not match, ignore craft")
                -- TODO: consider this case but for now its so edge case that we skip it
            end
        end

        print("craft " .. CraftSim.CRAFT_RESULTS.currentCrafts .. "/" .. totalCrafts .. " -> " .. tostring(spellID))
    end

end

function CraftSim.CRAFT_RESULTS:GetProfitForCraft(recipeData, craftData) 
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    if not priceData then
        return
    end
    local craftingCosts = priceData.craftingCostPerCraft

    local saved = 0
    for _, savedItem in pairs(craftData.proccs.resourcefulness.savedReagents) do
        local itemID = savedItem:GetItemID()
        local value = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
        local total = value*savedItem.quantity
        saved = saved + total
    end

    local endItemValue = (craftData.resultLink and CraftSim.PRICEDATA:GetMinBuyoutByItemLink(craftData.resultLink)) or 0
    endItemValue = endItemValue * craftData.craftedItems

    local craftProfit = (endItemValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - (craftingCosts - saved)

    return craftProfit
end

function CraftSim.CRAFT_RESULTS:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftResult)
    print("Craft Detected", false, true)
    --print(craftResult, true)

    local recipeData = CraftSim.CRAFT_RESULTS.currentRecipeData;

    if not recipeData then
        print("no recipeData")
        return
    end

    local craftData = {
        recipeID = recipeData.recipeID,
        profit = 0,
        expectedAverageProfit = 0,
        quantityImportant = false,
        recipeName = recipeData.recipeName,
        resultLink = craftResult.hyperlink,
        craftedItems = craftResult.quantity,
        expectedQuality = recipeData.expectedQuality,
        craftingChance = nil,
        proccs = {
            inspiration = {
                triggered = false,
                craftedQuality = nil,
            },
            multicraft = {
                triggered = false,
                extraItems = 0,
                baseItems = 0,
            },
            resourcefulness = {
                triggered = false,
                savedReagents = {}
            },
        },
    }

    if recipeData.stats.multicraft or recipeData.baseItemAmount > 1 then
        craftData.quantityImportant = true
    end

    if craftResult.isCrit then
        craftData.proccs.inspiration.triggered = true
        craftData.proccs.inspiration.craftingQuality = craftResult.craftingQuality
    end

    if craftResult.multicraft > 0 then
        craftData.proccs.multicraft.triggered = true
        craftData.proccs.multicraft.extraItems = craftResult.multicraft
        craftData.proccs.multicraft.baseItems = craftResult.quantity - craftResult.multicraft
    end
    
    if craftResult.resourcesReturned then
        craftData.proccs.resourcefulness.triggered = true
        for _, savedReagent in pairs(craftResult.resourcesReturned) do
            local item = Item:CreateFromItemID(savedReagent.itemID)
            item.quantity = savedReagent.quantity
            table.insert(craftData.proccs.resourcefulness.savedReagents, item)
        end
    end

    -- calculate craftingChance, TODO: make more dynamic

    local inspChance = (recipeData.stats.inspiration and recipeData.stats.inspiration.percent / 100) or 1
    local mcChance = (recipeData.stats.multicraft and recipeData.stats.multicraft.percent / 100) or 1
    local resChance = (recipeData.stats.resourcefulness and recipeData.stats.resourcefulness.percent / 100) or 1

    if inspChance < 1 then
        inspChance = (craftData.proccs.inspiration.triggered and inspChance) or (1-inspChance)
    end

    if mcChance < 1 then
        mcChance = (craftData.proccs.multicraft.triggered and mcChance) or (1-mcChance)
    end

    local totalResChance = 1
    if resChance < 1 then
        if not craftData.proccs.resourcefulness.triggered then
            totalResChance = (1-resChance) ^ #recipeData.reagents
        else
            local numProcced = #craftData.proccs.resourcefulness.savedReagents
            local numNotProcced = #recipeData.reagents - numProcced
            totalResChance = (resChance ^ numProcced) * ( (1-resChance) ^ numNotProcced )
        end
    end

    craftData.craftingChance = inspChance*mcChance*totalResChance

    local craftProfit = CraftSim.CRAFT_RESULTS:GetProfitForCraft(recipeData, craftData) 

    craftData.profit = craftProfit
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    craftData.expectedAverageProfit = CraftSim.CALC:getMeanProfit(recipeData, priceData)
    
    print("Chance for Craft: " .. tostring(CraftSim.UTIL:round(craftData.craftingChance * 100, 1)) .. "%")

    CraftSim.UTIL:ContinueOnAllItemsLoaded(craftData.proccs.resourcefulness.savedReagents, function ()
        CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftData)
    end) 

end

function CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftData)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    local currentText = craftResultFrame.content.resultFrame.resultFeed:GetText() or ""

    local resourcesText = ""

    if craftData.proccs.resourcefulness.triggered then
        for _, reagentItem in pairs(craftData.proccs.resourcefulness.savedReagents) do
            local qualityID = 0
            for _, reagentData in pairs(recipeData.reagents) do
                for q, itemInfo in pairs(reagentData.itemsInfo) do
                    if reagentItem:GetItemID() == itemInfo.itemID then
                        if reagentData.differentQualities then
                            qualityID = q
                        end
                        break;
                    end
                end
            end
            local iconAsText = CraftSim.UTIL:IconToText(reagentItem:GetItemIcon(), 25)
            local qualityAsText = (qualityID > 0 and CraftSim.UTIL:GetQualityIconAsText(qualityID, 20, 20)) or ""
            resourcesText = resourcesText .. "\n" .. iconAsText .. " " .. reagentItem.quantity .. " ".. qualityAsText
        end
    end

    local roundedProfit = CraftSim.UTIL:round(craftData.profit*10000) / 10000
    local profitText = CraftSim.UTIL:FormatMoney(roundedProfit, true)
    local chanceText = ""

    if not recipeData.isSalvageRecipe then
       chanceText = "Chance: " .. CraftSim.UTIL:round(craftData.craftingChance*100, 1) .. "%\n" 
    end

    local newText =
    (craftData.resultLink or craftData.resultName) .. "\n" ..
    "Profit: " .. profitText .. "\n" ..
    chanceText ..
    ((craftData.quantityImportant and ("Quantity: " .. craftData.craftedItems .. "\n")) or "") ..
    ((craftData.proccs.inspiration.triggered and CraftSim.UTIL:ColorizeText("Inspired!\n", CraftSim.CONST.COLORS.LEGENDARY)) or "") ..
    ((craftData.proccs.multicraft.triggered and (CraftSim.UTIL:ColorizeText("Multicraft: ", CraftSim.CONST.COLORS.EPIC) .. craftData.proccs.multicraft.extraItems .. "\n")) or "") ..
    ((craftData.proccs.resourcefulness.triggered and (CraftSim.UTIL:ColorizeText("Resources Saved!: \n", CraftSim.CONST.COLORS.UNCOMMON) .. resourcesText .. "\n")) or "")

    if currentText ~= "" then
        currentText = currentText .. "\n\n"
    end
    -- cut start of currentText if over x lines
    if craftResultFrame.content.resultFrame.resultFeed:GetNumLines() > 500 then
        currentText = string.gsub(currentText, ".*\n", 10)
    end
    craftResultFrame.content.resultFrame.resultFeed:SetText(currentText .. newText)

    CraftSim.CRAFT_RESULTS:AddCraftData(craftData, recipeData.recipeID)
    CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeData.recipeID)
end