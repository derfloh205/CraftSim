_, CraftSim = ...

---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = CraftSim.GUTIL:CreateRegistreeForEvents({"TRADE_SKILL_ITEM_CRAFTED_RESULT"})

---@type CraftSim.CraftQueue
CraftSim.CRAFTQ.craftQueue = nil

---@type CraftSim.RecipeData | nil
CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil

--- used to check if CraftSim was the one calling the C_TradeSkillUI.CraftRecipe api function
CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

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

function CraftSim.CRAFTQ:ImportRecipeScan()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})
    local profitableRecipes = CraftSim.GUTIL:Filter(CraftSim.RECIPE_SCAN.currentResults, 
    ---@param recipeData CraftSim.RecipeData
    function (recipeData)
        if recipeData.averageProfitCached then
            return recipeData.averageProfitCached > 0
        else
            return false
        end
    end)
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
    local reagentMap = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if reagent.hasQuality then
                for qualityID, reagentItem in pairs(reagent.items) do
                    reagentMap[reagentItem.item:GetItemName()] = reagentMap[reagentItem.item:GetItemName()] or {
                        itemID = reagentItem.item:GetItemID(),
                        qualityID = nil,
                        quantity = 0
                    }
                    reagentMap[reagentItem.item:GetItemName()].quantity = reagentMap[reagentItem.item:GetItemName()].quantity + (reagentItem.quantity * craftQueueItem.amount)
                    reagentMap[reagentItem.item:GetItemName()].qualityID = qualityID
                end
            else
                local reagentItem = reagent.items[1]
                reagentMap[reagentItem.item:GetItemName()] = reagentMap[reagentItem.item:GetItemName()] or {
                    itemID = reagentItem.item:GetItemID(),
                    qualityID = nil,
                    quantity = 0
                }
                reagentMap[reagentItem.item:GetItemName()].quantity = reagentMap[reagentItem.item:GetItemName()].quantity + (reagentItem.quantity * craftQueueItem.amount)
            end
        end
    end
    -- create shoppinglist import string?
     -- format: Test^"Frostfire Alloy";;0;0;0;0;0;0;0;0;;3;;#;;99
    local shoppingListImportString = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME

    for name, info in pairs(reagentMap) do
        local itemCount = GetItemCount(info.itemID, true, false, true)
        if itemCount < info.quantity then
            shoppingListImportString = shoppingListImportString .. '^"'..name..'"' .. ';;0;0;0;0;0;0;0;0;;'..(info.qualityID or '#')..';;' .. info.quantity - itemCount
        end
    end

    --CraftSim CraftQueue2^"Khaz'gorite Ore";;0;0;0;0;0;0;0;0;;1;;99^"Awakened Frost";;0;0;0;0;0;0;0;0;;0;;#;;1^"Awakened Fire";;0;0;0;0;0;0;0;0;;0;;#;;1^"Primal Flux";;0;0;0;0;0;0;0;0;;0;;#;;4^"Draconium Ore";;0;0;0;0;0;0;0;0;;1;;#;;5
    --CraftSim.UTIL:KethoEditBox_Show(shoppingListImportString)
    -- delete old list
    Auctionator.Shopping.ListManager:Delete(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME)
    Auctionator.Shopping.Lists.BatchImportFromString(shoppingListImportString)
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