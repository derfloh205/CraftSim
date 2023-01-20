AddonName, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)
CraftSim.CRAFT_RESULTS = CraftSim.UTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT"})

function CraftSim.CRAFT_RESULTS:FitsRecipeData(recipeData, itemID)
    for _, resultItem in pairs(recipeData.result.resultItems) do
        if resultItem:GetItemID() == itemID then
            return true
        end
    end

    return false
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
    print(craftResult, true)

    local recipeData = CraftSim.MAIN.currentRecipeData;

    if not recipeData then
        print("no recipeData")
        return
    end

    -- check if crafted item does not fit result of recipeData.. (if crafted without viewing recipe e.g.)
    -- then dont log
    -- TODO: needs exceptions / id lists for salvaging recipes and experimenting
    -- if not CraftSim.CRAFT_RESULTS:FitsRecipeData(recipeData, craftResult.itemID) then
    --     print("Does not align with current recipeData, do not log")
    --     return
    -- end

    local craftData = {
        recipeID = recipeData.recipeID,
        profit = 0,
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

    craftResultFrame.content.resultFrame.resultFeed:SetText(currentText .. "\n\n" .. newText)

    craftResultFrame.content.AddProfit(craftData.profit, recipeData.recipeID)
    craftResultFrame.content.AddProfit(craftData.profit)
end