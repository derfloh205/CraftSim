_, CraftSim = ...

---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = CraftSim.GUTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT"})

---@type CraftSim.CraftQueue
CraftSim.CRAFTQ.craftQueue = nil

---@type CraftSim.RecipeData | nil
CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil

--- used to check if CraftSim was the one calling the C_TradeSkillUI.CraftRecipe api function
CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false

--- used to cache player item counts during sorting and recalculation of craft queue
--- if canCraft and such functions are not called by craftqueue it should be nil
CraftSim.CRAFTQ.itemCountCache = nil

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

function CraftSim.CRAFTQ:InitializeCraftQueue()
    -- TODO: load from Saved Variables?
    CraftSim.CRAFTQ.craftQueue = CraftSim.CraftQueue({})
end

---@param recipeData CraftSim.RecipeData
---@param amount number?
function CraftSim.CRAFTQ:AddRecipe(recipeData, amount)
    amount = amount or 1

    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})
    CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, amount)

    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CraftQueue({})
    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ.ImportRecipeScanFilter(recipeData) -- . accessor instead of : is on purpose here
    if not recipeData.learned then
        return false
    end
    if recipeData.averageProfitCached then
        return recipeData.averageProfitCached > 0
    else
        return false
    end
end

function CraftSim.CRAFTQ:ImportRecipeScan()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})
    local profitableRecipes = CraftSim.GUTIL:Filter(CraftSim.RECIPE_SCAN.currentResults, CraftSim.CRAFTQ.ImportRecipeScanFilter)
    for _, recipeData in pairs(profitableRecipes) do
        CraftSim.CRAFTQ.craftQueue:AddRecipe(recipeData, 1) -- TODO: make configureable per recipe, maybe via tsm string? as option or some fixed stuff
    end

    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()    
end

---@param recipeData CraftSim.RecipeData
---@param amount number
---@param enchantItemTarget ItemLocationMixin?
function CraftSim.CRAFTQ:OnCraftRecipe(recipeData, amount, enchantItemTarget)
    -- find the current queue item and set it to currentlyCraftedQueueItem
    -- if an enchant was crafted that was not on a vellum, ignore
    if enchantItemTarget and enchantItemTarget:IsValid() then
        if C_Item.GetItemID(enchantItemTarget) ~= CraftSim.CONST.ENCHANTING_VELLUM_ID then
            CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil
            return
        end
    end
    print("OnCraftRecipe", false, true)
    CraftSim.CRAFTQ.currentlyCraftedRecipeData = recipeData
end

function CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
    CraftSim.UTIL:StartProfiling("CreateAuctionatorShopping")
    local reagentMap = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if reagent.hasQuality then
                for qualityID, reagentItem in pairs(reagent.items) do
                    reagentMap[reagentItem.item:GetItemID()] = reagentMap[reagentItem.item:GetItemID()] or {
                        itemName = reagentItem.item:GetItemName(),
                        qualityID = nil,
                        quantity = 0
                    }
                    reagentMap[reagentItem.item:GetItemID()].quantity = reagentMap[reagentItem.item:GetItemID()].quantity + (reagentItem.quantity * craftQueueItem.amount)
                    reagentMap[reagentItem.item:GetItemID()].qualityID = qualityID
                end
            else
                local reagentItem = reagent.items[1]
                reagentMap[reagentItem.item:GetItemID()] = reagentMap[reagentItem.item:GetItemID()] or {
                    itemName = reagentItem.item:GetItemName(),
                    qualityID = nil,
                    quantity = 0
                }
                reagentMap[reagentItem.item:GetItemID()].quantity = reagentMap[reagentItem.item:GetItemID()].quantity + (reagentItem.quantity * craftQueueItem.amount)
            end
        end
    end
    -- create shoppinglist import string?
     -- format: Test^"Frostfire Alloy";;0;0;0;0;0;0;0;0;;3;;#;;99
    local shoppingListImportString = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME

    for itemID, info in pairs(reagentMap) do
        local isSoulbound = CraftSim.GUTIL:isItemSoulbound(itemID)
        if not isSoulbound then
            local itemCount = GetItemCount(itemID, true, false, true)
            if itemCount < info.quantity then
                shoppingListImportString = shoppingListImportString .. '^"'..info.itemName..'"' .. ';;0;0;0;0;0;0;0;0;;'..(info.qualityID or '#')..';;' .. info.quantity - itemCount
            end
        end
    end

    --CraftSim CraftQueue2^"Khaz'gorite Ore";;0;0;0;0;0;0;0;0;;1;;99^"Awakened Frost";;0;0;0;0;0;0;0;0;;0;;#;;1^"Awakened Fire";;0;0;0;0;0;0;0;0;;0;;#;;1^"Primal Flux";;0;0;0;0;0;0;0;0;;0;;#;;4^"Draconium Ore";;0;0;0;0;0;0;0;0;;1;;#;;5
    
    -- delete old list only if it exists to refresh contents instead of adding them
    local listExists = Auctionator.Shopping.ListManager:GetIndexForName(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME)
    if listExists then
        Auctionator.Shopping.ListManager:Delete(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME)
    end
    Auctionator.Shopping.Lists.BatchImportFromString(shoppingListImportString)
    ---CraftSim.UTIL:KethoEditBox_Show(shoppingListImportString)
    CraftSim.UTIL:StopProfiling("CreateAuctionatorShopping")
end

function CraftSim.CRAFTQ:TRADE_SKILL_ITEM_CRAFTED_RESULT()
    print("onCraftResult")
    if CraftSim.CRAFTQ.currentlyCraftedRecipeData then
        print("have recipeData, now decrement")
        -- decrement by one and refresh list
        CraftSim.CRAFTQ.craftQueue:SetAmount(CraftSim.CRAFTQ.currentlyCraftedRecipeData, -1, true)
        CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
    end
end

--- only working for craft queue display update
function CraftSim.CRAFTQ:GetItemCountFromCache(itemID, bank, uses, reagentbank)
    local itemCount = (CraftSim.CRAFTQ.itemCountCache and CraftSim.CRAFTQ.itemCountCache[itemID]) or nil
    if not itemCount then
        itemCount = GetItemCount(itemID, bank, uses, reagentbank)
    end
    return itemCount
end