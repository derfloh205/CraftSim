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

function CraftSim.CRAFT_RESULTS:ExportCSV() 
    local sessionData = CraftSim.CRAFT_RESULTS.sessionData

    if not CraftSim.MAIN.currentRecipeData then
        return
    end
    local recipeID = CraftSim.MAIN.currentRecipeData.recipeID

    local recipeCraftData = sessionData.byRecipe[recipeID]

    if not recipeCraftData then
        return "No Crafting Data for this Recipe yet"
    end

    local inspiration = (CraftSim.MAIN.currentRecipeData.stats.inspiration and CraftSim.MAIN.currentRecipeData.stats.inspiration.value) or nil
    local multicraft = (CraftSim.MAIN.currentRecipeData.stats.multicraft and CraftSim.MAIN.currentRecipeData.stats.multicraft.value) or nil
    local resourcefulness = (CraftSim.MAIN.currentRecipeData.stats.resourcefulness and CraftSim.MAIN.currentRecipeData.stats.resourcefulness.value) or nil

    local resultText = ""
    local index = 1
    for link, count in pairs(recipeCraftData.craftedItems) do
        print("craftedItems, link: " .. tostring(link))
        resultText = resultText .. "result" .. index .. "," .. CraftSim.UTIL:GetItemIDByLink(link) .. "\n"
        resultText = resultText .. "result" .. index .. "Count," .. count .. "\n"
        index = index + 1
    end

    local savedReagentText = ""
    index = 1
    for itemID, savedReagent in pairs(recipeCraftData.statistics.savedReagents) do
        savedReagentText = savedReagentText .. "savedReagent" .. index .. "," .. itemID .. "\n"
        savedReagentText = savedReagentText .. "savedReagent" .. index .. "Count," .. savedReagent.quantity .. "\n"
    end

    local csv =
    "recipeID," .. recipeID .. "\n" ..
    "recipeName," .. CraftSim.MAIN.currentRecipeData.recipeName .. "\n" ..
    "skill," .. CraftSim.MAIN.currentRecipeData.stats.skill .. "\n" ..
    ((inspiration and "inspirationStat," .. inspiration .. "\n") or "") ..
    ((inspiration and "inspirationChance," .. CraftSim.MAIN.currentRecipeData.stats.inspiration.percent .. "\n") or "") ..
    ((inspiration and "inspirationSkillBonus," .. CraftSim.MAIN.currentRecipeData.stats.inspiration.bonusskill .. "\n") or "") ..
    ((multicraft and "multicraftStat," .. multicraft .. "\n") or "") ..
    ((multicraft and "multicraftChance," .. CraftSim.MAIN.currentRecipeData.stats.multicraft.percent .. "\n") or "") ..
    ((resourcefulness and "resourcefulnessStat," .. resourcefulness .. "\n") or "") ..
    ((resourcefulness and "resourcefulnessChance," .. CraftSim.MAIN.currentRecipeData.stats.resourcefulness.percent .. "\n") or "") ..
    "profit," ..  recipeCraftData.profit .. "\n" ..
    "crafts," ..  recipeCraftData.statistics.crafts .. "\n" ..
    "baseItems," ..  recipeCraftData.statistics.baseItemCount .. "\n" ..
    "multicraftExtraItems," ..  recipeCraftData.statistics.multicraftExtraItems .. "\n" ..
    "inspirationProcs," ..  recipeCraftData.statistics.inspiration .. "\n" ..
    "multicraftProcs," ..  recipeCraftData.statistics.multicraft .. "\n" ..
    "resourcefulnessProcs," ..  recipeCraftData.statistics.resourcefulness .. "\n" ..
    resultText ..
    savedReagentText

    return csv
end

function CraftSim.CRAFT_RESULTS:AddCraftData(craftData, recipeID)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)
    CraftSim.CRAFT_RESULTS.sessionData.total.profit = CraftSim.CRAFT_RESULTS.sessionData.total.profit + craftData.profit
    for _, craftResult in pairs(craftData.results) do
        CraftSim.CRAFT_RESULTS.sessionData.total.craftedItems[craftResult.item] = (CraftSim.CRAFT_RESULTS.sessionData.total.craftedItems[craftResult.item] or 0) + craftResult.quantity
    end

    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID] = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID] or CopyTable(CraftSim.CRAFT_RESULTS.baseRecipeEntry)

    CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.crafts = CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.crafts + 1


    if craftData.procs.inspiration.triggered then
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.inspiration = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.inspiration or 0) + 1
    end

    if not craftData.procs.multicraft.triggered then
        -- TODO: are there crafts that can multicraft that also result in different items?
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount = 
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount + craftData.results[1].quantity
    else
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraft = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraft or 0) + 1
        
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraftExtraItems = 
        (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.multicraftExtraItems or 0) + craftData.procs.multicraft.procItems[1].extraItems

        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount = 
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.baseItemCount + craftData.procs.multicraft.procItems[1].baseItemAmount
    end

    if craftData.procs.resourcefulness.triggered then
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.resourcefulness = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.resourcefulness or 0) + 1
        
        for _, savedReagent in pairs(craftData.procs.resourcefulness.savedReagents) do
            local itemID = savedReagent:GetItemID()
            if not CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.savedReagents[savedReagent:GetItemID()] then
                CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].statistics.savedReagents[savedReagent:GetItemID()] = {
                    item = savedReagent,
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
    
    for _, craftResult in pairs(craftData.results) do
        CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].craftedItems[craftResult.item] = (CraftSim.CRAFT_RESULTS.sessionData.byRecipe[recipeID].craftedItems[craftResult.item] or 0) + craftResult.quantity
    end


    -- update frames
    craftResultFrame.content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(CraftSim.CRAFT_RESULTS.sessionData.total.profit, true))

    CraftSim.CRAFT_RESULTS.FRAMES:UpdateItemList()
end

-- save current craft data
function CraftSim.CRAFT_RESULTS:TRADE_SKILL_CRAFT_BEGIN(spellID)
    -- new craft begins if we do not have saved any recipe data yet
    -- or if the current cached data does not match the recipeid

    if CraftSim.MAIN.currentRecipeData and CraftSim.MAIN.currentRecipeData.recipeID == spellID then
        -- if prospecting or other salvage item, only use the current recipedata if we have a salvage reagent, otherwise use saved one
        if CraftSim.MAIN.currentRecipeData.isSalvageRecipe and CraftSim.MAIN.currentRecipeData.salvageReagent then
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

function CraftSim.CRAFT_RESULTS:GetProfitForCraft(recipeData, craftData) 
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    if not priceData then
        return
    end
    local craftingCosts = priceData.craftingCostPerCraft

    local saved = 0
    for _, savedItem in pairs(craftData.procs.resourcefulness.savedReagents) do
        local itemID = savedItem:GetItemID()
        local value = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
        local total = value*savedItem.quantity
        saved = saved + total
    end

    local endItemsValue = 0
    for _, craftResult in pairs(craftData.results) do
        endItemsValue = endItemsValue + ((craftResult.item and CraftSim.PRICEDATA:GetMinBuyoutByItemLink(craftResult.item)) or 0) * craftResult.quantity
    end

    local craftProfit = (endItemsValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - (craftingCosts - saved)

    return craftProfit
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

function CraftSim.CRAFT_RESULTS:processCraftResults()
    collectingResults = true
    print("Craft Detected", false, true)
    print(currentCraftingResults, true)
    print("Num Craft Results: " .. tostring(#currentCraftingResults))

    local craftingResults = CopyTable(currentCraftingResults)
    currentCraftingResults = {}

    if CraftSim.UTIL:Find(craftingResults, function(result) return result.isEnchant end) then
        print("isEnchant -> ignore")
        return
    end

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
        results = {},
        expectedQuality = recipeData.expectedQuality,
        craftingChance = nil,
        procs = {
            inspiration = {
                triggered = false,
            },
            multicraft = {
                triggered = false,
                procItems = {},
            },
            resourcefulness = {
                triggered = false,
                savedReagents = {}
            },
        },
    }

    craftData.quantityImportant = recipeData.stats.multicraft or recipeData.baseItemAmount > 1

    for _, craftResult in pairs(craftingResults) do

        if craftResult.isCrit then
            craftData.procs.inspiration.triggered = true
        end

        if craftResult.multicraft > 0 then
            craftData.procs.multicraft.triggered = true
            table.insert(craftData.procs.multicraft.procItems, {
                item = craftResult.hyperlink,
                baseItemAmount = craftResult.quantity - craftResult.multicraft,
                extraItems = craftResult.multicraft,
            })
        end

        

        table.insert(craftData.results, {
            item = craftResult.hyperlink,
            quantity = craftResult.quantity
        })
    end

    -- just take resourcefulness from the first craftResult
    -- this is because of a blizzard bug where the same proc is listed in every craft result
    if craftingResults[1].resourcesReturned then
        craftData.procs.resourcefulness.triggered = true
        for _, savedReagent in pairs(craftingResults[1].resourcesReturned) do
            local item = Item:CreateFromItemID(savedReagent.itemID)
            item.quantity = savedReagent.quantity
            table.insert(craftData.procs.resourcefulness.savedReagents, item)
        end
    end

    local inspChance = (recipeData.stats.inspiration and recipeData.stats.inspiration.percent / 100) or 1
    local mcChance = (recipeData.stats.multicraft and recipeData.stats.multicraft.percent / 100) or 1
    local resChance = (recipeData.stats.resourcefulness and recipeData.stats.resourcefulness.percent / 100) or 1

    if inspChance < 1 then
        inspChance = (craftData.procs.inspiration.triggered and inspChance) or (1-inspChance)
    end

    if mcChance < 1 then
        mcChance = (craftData.procs.multicraft.triggered and mcChance) or (1-mcChance)
    end

    local totalResChance = 1
    if resChance < 1 and craftData.procs.resourcefulness.triggered then
        local numProcced = #craftData.procs.resourcefulness.savedReagents
        totalResChance = resChance ^ numProcced
    end

    craftData.craftingChance = inspChance*mcChance*totalResChance

    local craftProfit = CraftSim.CRAFT_RESULTS:GetProfitForCraft(recipeData, craftData) 

    craftData.profit = craftProfit
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    craftData.expectedAverageProfit = CraftSim.CALC:getMeanProfit(recipeData, priceData)
    
    print("Chance for Craft: " .. tostring(CraftSim.UTIL:round(craftData.craftingChance * 100, 1)) .. "%")

    CraftSim.UTIL:ContinueOnAllItemsLoaded(craftData.procs.resourcefulness.savedReagents, function ()
        CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftData)
    end) 

end

function CraftSim.CRAFT_RESULTS:AddResult(recipeData, craftData)
    local craftResultFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CRAFT_RESULTS)

    --local currentText = craftResultFrame.content.resultFrame.resultFeed:GetText() or ""

    local resourcesText = ""

    if craftData.procs.resourcefulness.triggered then
        for _, reagentItem in pairs(craftData.procs.resourcefulness.savedReagents) do
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

    local resultsText = ""
    for _, craftResult in pairs(craftData.results) do
        local itemBaseQuantity = craftResult.quantity
        if craftData.procs.multicraft.triggered then
            -- check if item was multicrafted
            local item = CraftSim.UTIL:Find(craftData.procs.multicraft.procItems, function(procItem) return procItem.item == craftResult.item end)

            if item then
                itemBaseQuantity = item.baseItemAmount
            end

        end

        resultsText = resultsText .. itemBaseQuantity .. " x " .. (craftResult.item or recipeData.recipeName) .. "\n"
    end

    local multicraftExtraItemsText = ""
    for _, procItem in pairs(craftData.procs.multicraft.procItems) do
        multicraftExtraItemsText = multicraftExtraItemsText .. procItem.extraItems .. " x " .. procItem.item .. "\n"
    end

    local newText =
    resultsText ..
    "Profit: " .. profitText .. "\n" ..
    chanceText ..
    ((craftData.procs.inspiration.triggered and CraftSim.UTIL:ColorizeText("Inspired!\n", CraftSim.CONST.COLORS.LEGENDARY)) or "") ..
    ((craftData.procs.multicraft.triggered and (CraftSim.UTIL:ColorizeText("Multicraft: ", CraftSim.CONST.COLORS.EPIC) .. multicraftExtraItemsText)) or "") ..
    ((craftData.procs.resourcefulness.triggered and (CraftSim.UTIL:ColorizeText("Resources Saved!: \n", CraftSim.CONST.COLORS.UNCOMMON) .. resourcesText .. "\n")) or "")

    craftResultFrame.content.scrollingMessageFrame:AddMessage("\n" .. newText)

    CraftSim.CRAFT_RESULTS:AddCraftData(craftData, recipeData.recipeID)
    CraftSim.CRAFT_RESULTS.FRAMES:UpdateRecipeData(recipeData.recipeID)
end