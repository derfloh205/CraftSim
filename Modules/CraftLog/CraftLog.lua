AddonName, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTLOG)
CraftSim.CRAFTLOG = CraftSim.UTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT"})

function CraftSim.CRAFTLOG:FitsRecipeData(recipeData, itemID)
    for _, resultItem in pairs(recipeData.result.resultItems) do
        if resultItem:GetItemID() == itemID then
            return true
        end
    end

    return false
end

function CraftSim.CRAFTLOG:GetProfitForCraft(recipeData, craftData) 
    local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
    if not priceData then
        return
    end
    local craftingCosts = priceData.craftingCostPerCraft
end

function CraftSim.CRAFTLOG:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftResult)
    print("Craft Detected", false, true)

    local recipeData = CraftSim.MAIN.currentRecipeData;

    if not recipeData then
        return
    end

    -- check if crafted item does not fit result of recipeData.. (if crafted without viewing recipe e.g.)
    -- then dont log
    if not CraftSim.CRAFTLOG:FitsRecipeData(recipeData, craftResult.itemID) then
        print("Does not align with current recipeData, do not log")
        return
    end

    local craftLogEntry = {
        recipeID = recipeData.recipeID,
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

    if craftResult.isCrit then
        craftLogEntry.proccs.inspiration.triggered = true
        craftLogEntry.proccs.inspiration.craftingQuality = craftResult.craftingQuality
    end

    if craftResult.multicraft > 0 then
        craftLogEntry.proccs.multicraft.triggered = true
        craftLogEntry.proccs.multicraft.extraItems = craftResult.multicraft
        craftLogEntry.proccs.multicraft.baseItems = craftResult.quantity - craftResult.multicraft
    end
    
    if craftResult.resourcesReturned then
        craftLogEntry.proccs.resourcefulness.triggered = true
        craftLogEntry.proccs.resourcefulness.savedReagents = craftResult.resourcesReturned
    end

    -- calculate craftingChance, TODO: make more dynamic

    local inspChance = (recipeData.stats.inspiration and recipeData.stats.inspiration.percent / 100) or 1
    local mcChance = (recipeData.stats.multicraft and recipeData.stats.multicraft.percent / 100) or 1
    local resChance = (recipeData.stats.resourcefulness and recipeData.stats.resourcefulness.percent / 100) or 1

    if inspChance < 1 then
        inspChance = (craftLogEntry.proccs.inspiration.triggered and inspChance) or (1-inspChance)
    end

    if mcChance < 1 then
        mcChance = (craftLogEntry.proccs.multicraft.triggered and mcChance) or (1-mcChance)
    end

    local totalResChance = 1
    if resChance < 1 then
        if not craftLogEntry.proccs.resourcefulness.triggered then
            totalResChance = (1-resChance) ^ #recipeData.reagents
        else
            for _, reagentData in pairs(recipeData.reagents) do
                for _, itemInfo in pairs(reagentData.itemsInfo) do
                    local isSaved = CraftSim.UTIL:Find(craftLogEntry.proccs.resourcefulness.savedReagents, function(r) return r.itemID == itemInfo.itemID end)

                    if isSaved then
                        totalResChance = totalResChance * resChance
                    else
                        totalResChance = totalResChance * (1-resChance)
                    end
                end
            end
        end
    end

    craftLogEntry.craftingChance = inspChance*mcChance*totalResChance
    
    print("Chance for Craft: " .. tostring(CraftSim.UTIL:round(craftLogEntry.craftingChance * 100, 1)) .. "%")
end