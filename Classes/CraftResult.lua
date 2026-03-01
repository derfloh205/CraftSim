---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

-- Collection of operationIds that have already been handled, to avoid double counting resourcefulness savings
local handledOperationIds = {};

-- Timestamp of the last construction of a CraftResult object, used to periodically clear handledOperationIds
local lastConstructTime = 0;

---@class CraftSim.CraftResult : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, craftingItemResultData: CraftingItemResultData, aNumCrafts: number): CraftSim.CraftResult
CraftSim.CraftResult = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param craftingItemResultData CraftingItemResultData[]
---@param aNumCrafts number
function CraftSim.CraftResult:new(recipeData, craftingItemResultData, aNumCrafts )
    self.recipeID = recipeData.recipeID
    ---@type CraftSim.CraftResultItem[]
    self.craftResultItems = {}
    ---@type CraftSim.CraftResultReagent[]
    self.savedReagents = {}
    ---@type CraftSim.CraftResultReagent[]
    self.reagents = {}
    self.expectedQuality = recipeData.resultData.expectedQuality
    self.triggeredMulticraft = false
    self.triggeredResourcefulness = false
    self.triggeredIngenuity = false
    self.savedConcentration = 0
    self.usedConcentration = 0
    self.ingenuityRefund = 0
    self.concentrating = recipeData.concentrating
    self.savedCosts = 0
    self.craftingCosts = 0
    self.reagentCombinationID = ""
    self.isWorkOrder = recipeData:IsWorkOrder()
    self.orderData = recipeData.orderData

    -- Periodically clear handledOperationIds so the table doesn't grow indefinitely
    -- Try to make it so a break in crafting triggers this - 5 seconds since the last craft
    if time() - lastConstructTime > 5 then
        handledOperationIds = {};
    end
    lastConstructTime = time();

    for _, craftingItemResult in pairs(craftingItemResultData) do
        if craftingItemResult.multicraft and craftingItemResult.multicraft > 0 then
            self.triggeredMulticraft = true
        end

        if craftingItemResult.hasIngenuityProc then
            self.triggeredIngenuity = true
            self.savedConcentration = craftingItemResult.ingenuityRefund or 0
        end

        self.ingenuityRefund = craftingItemResult.ingenuityRefund or 0
        self.usedConcentration = craftingItemResult.concentrationSpent or 0

        table.insert(self.craftResultItems,
            CraftSim.CraftResultItem(craftingItemResult.hyperlink, craftingItemResult.quantity,
                craftingItemResult.multicraft, craftingItemResult.craftingQuality))
    end

    -- Workaround for blizzard bug where saved salvage items aren't included in craftingItemResultData[].resourcesReturned for complex salvage recipes
    local nonSalvageQtySaved = 0;
    local salvageQuantitySaved = 0;
    local salvageItemSaved = false;
    local salvageItemId = nil;
    if recipeData.isSalvageRecipe then
        local slot = recipeData.reagentData.salvageReagentSlot
        salvageItemId = slot and slot.activeItem and slot.activeItem:GetItemID()
    end

    -- multiple sets of results in one frame - make sure to capture all resourcefulness savings
    for _, craftResult in ipairs( craftingItemResultData ) do
        if craftResult.resourcesReturned and handledOperationIds[craftResult.operationID] ~= true then
            self.triggeredResourcefulness = true
            for _, craftingResourceReturnInfo in pairs(craftResult.resourcesReturned) do
                local craftResultSavedReagent = CraftSim.CraftResultReagent(recipeData, craftingResourceReturnInfo.reagent.itemID, craftingResourceReturnInfo.quantity)
                self.savedCosts = self.savedCosts + craftResultSavedReagent.costs
                table.insert(self.savedReagents, craftResultSavedReagent)
                 -- Workaround for blizzard bug where saved salvage items aren't included in craftingItemResultData[].resourcesReturned for complex salvage recipes
                if salvageItemId == craftingResourceReturnInfo.reagent.itemID then
                    salvageItemSaved = true
                else
                    nonSalvageQtySaved = nonSalvageQtySaved + craftingResourceReturnInfo.quantity
                    local slot = recipeData.reagentData.salvageReagentSlot;
                    local quantity = math.min( slot.requiredQuantity, craftingResourceReturnInfo.quantity ); -- if we saved 5 bismuth, the max gems we can save is still 3
                    salvageQuantitySaved = salvageQuantitySaved + quantity;
                end
            end
            handledOperationIds[craftResult.operationID] = true;
        end
    end

    -- Workaround for blizzard bug where saved salvage items aren't included in craftingItemResultData[].resourcesReturned for complex salvage recipes
    -- Fixes the case described below:
    -- if the crafting result saves only bismuth, it saves the same # of gems, up to 3 (#gems required for recipe) 
	-- ex: if only bismuth saved, and 1 saved - also saved 1 gem
	-- ex: if only bismuth saved, and 2 saved - also saved 2 gem
	-- ex: if only bismuth saved, and 3 saved - also saved 3 gem
	-- ex: if only bismuth saved, and 4 saved - also saved 3 gem
    if salvageItemId ~= nil and nonSalvageQtySaved ~= 0 and salvageItemSaved == false then
        -- if the salvage item is not in the craftingItemResultData[1].resourcesReturned, add it manually
        local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID( salvageItemId, true, false, true ) * salvageQuantitySaved;
        self.savedCosts = self.savedCosts + reagentCosts;
        table.insert( self.savedReagents, CraftSim.CraftResultReagent( recipeData, salvageItemId, salvageQuantitySaved ) )

        -- Not sure this won't have side effects, log it for now
        -- print( "logged additional saved items for salvage recipe: " .. salvageItemId .. " quantity: " .. quantity );
    end

    -- Reagents
    do
        local reagentItemIDs = {}
        if recipeData.isSalvageRecipe then
            local slot = recipeData.reagentData.salvageReagentSlot
            if slot and slot.activeItem then
                local itemID = slot.activeItem:GetItemID()
                local quantity = slot.requiredQuantity * aNumCrafts
                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                self.craftingCosts = self.craftingCosts + reagentCosts
                tinsert(self.reagents, CraftSim.CraftResultReagent(recipeData, itemID, quantity)) -- how much we actually used
                tinsert(reagentItemIDs, itemID .. "." .. slot.requiredQuantity )                  -- how much the recipe called for, used for reagentCombinationID
            end
        end

        if recipeData:HasRequiredSelectableReagent() then
            local slot = recipeData.reagentData.requiredSelectableReagentSlot
            if slot and slot.activeReagent then
                local itemID = slot.activeReagent.item:GetItemID()
                local quantity = slot.maxQuantity * aNumCrafts
                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                local isOrderReagent = slot.activeReagent:IsOrderReagentIn(recipeData)
                if not isOrderReagent then
                    self.craftingCosts = self.craftingCosts + reagentCosts
                end
                tinsert(self.reagents,
                    CraftSim.CraftResultReagent(recipeData, itemID, quantity, isOrderReagent)) -- how much we actually used
                tinsert(reagentItemIDs, itemID .. "." .. slot.maxQuantity)                     -- how much the recipe called for, used for reagentCombinationID
            end
        end

        -- required
        for _, requiredReagent in ipairs(recipeData.reagentData.requiredReagents) do
            for _, reagentItem in ipairs(requiredReagent.items) do
                local quantity = reagentItem.quantity * aNumCrafts
                local itemID = reagentItem.item:GetItemID()
                local isOrderReagent = reagentItem:IsOrderReagentIn(recipeData)

                tinsert(self.reagents,
                    CraftSim.CraftResultReagent(recipeData, itemID, quantity, isOrderReagent)) -- how much we actually used

                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                if not isOrderReagent then
                    self.craftingCosts = self.craftingCosts + reagentCosts
                end
                if reagentItem.quantity > 0 then
                    tinsert(reagentItemIDs, itemID .. "." .. reagentItem.quantity)             -- how much the recipe called for, used for reagentCombinationID
                end
            end
        end

        for _, optionalReagentSlot in ipairs(GUTIL:Concat { recipeData.reagentData.optionalReagentSlots, recipeData.reagentData.finishingReagentSlots }) do
            if optionalReagentSlot:IsAllocated() then
                local itemID = optionalReagentSlot.activeReagent.item:GetItemID()
                local quantity = optionalReagentSlot.maxQuantity * aNumCrafts
                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                local isOrderReagent = optionalReagentSlot.activeReagent:IsOrderReagentIn(recipeData)
                if not isOrderReagent then
                    self.craftingCosts = self.craftingCosts + reagentCosts
                end
                tinsert(self.reagents,
                    CraftSim.CraftResultReagent(recipeData, itemID, quantity, isOrderReagent))  -- how much we actually used
                tinsert(reagentItemIDs, itemID .. "." .. optionalReagentSlot.maxQuantity)       -- how much the recipe called for, used for reagentCombinationID
            end
        end

        -- The reagentCombinationID should represent the reagents required for 1 craft, disregarding aNumCrafts
        for i, itemID in ipairs(reagentItemIDs) do
            local itemIDString
            if i > 1 then
                itemIDString = ":" .. itemID
            else
                itemIDString = itemID
            end
            self.reagentCombinationID = self.reagentCombinationID .. itemIDString
        end
    end

    --self.craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents - self.savedCosts -- commenting this out - it stops multiple crafts in one frame from counting everything correctly
    self.craftingCosts = self.craftingCosts - self.savedCosts;

    self.reagentCombinationID = self.reagentCombinationID ..
        ":" .. tostring(self.concentrating) .. ":" .. tostring(self.isWorkOrder)

    self.profit = self:CalculateCraftProfit()
end

function CraftSim.CraftResult:CalculateCraftProfit()
    local craftingCosts = self.craftingCosts -- considering saved costs by resourcefulness and orderReagents

    local orderCommission = 0
    if self.isWorkOrder then
        orderCommission = self.orderData.tipAmount - self.orderData.consortiumCut

        -- check for npcOrderRewards
        if self.orderData.npcOrderRewards then
            for _, orderRewardInfo in ipairs(self.orderData.npcOrderRewards) do
                local itemID = GUTIL:GetItemIDByLink(orderRewardInfo.itemLink)
                local sellPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID) * CraftSim.CONST.AUCTION_HOUSE_CUT
                orderCommission = orderCommission + sellPrice
            end
        end
    end

    local resultValue = 0
    if not self.isWorkOrder then
        for _, craftResultItem in pairs(self.craftResultItems) do
            local itemLink = craftResultItem.item:GetItemLink()
            local quantity = craftResultItem.quantity + craftResultItem.quantityMulticraft
            local resultItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemLink(itemLink) or 0
            resultValue = resultValue + resultItemPrice * quantity
        end
    end

    local craftProfit = 0
    if self.isWorkOrder then
        craftProfit = orderCommission - craftingCosts
    else
        craftProfit = (resultValue * CraftSim.CONST.AUCTION_HOUSE_CUT) - craftingCosts
    end

    return craftProfit
end

---@return number
function CraftSim.CraftResult:GetMulticraftExtraItems()
    return GUTIL:Fold(self.craftResultItems, 0, function(multicraftExtraItems, craftResultItem)
        return multicraftExtraItems + craftResultItem.quantityMulticraft
    end)
end

function CraftSim.CraftResult:Debug()
    local debugLines = {
        "recipeID: " .. tostring(self.recipeID),
        "profit: " .. CraftSim.UTIL:FormatMoney(self.profit, true),
        "expectedQuality: " .. tostring(self.expectedQuality),
        "triggeredMulticraft: " .. tostring(self.triggeredMulticraft),
        "triggeredResourcefulness: " .. tostring(self.triggeredResourcefulness),
    }
    if #self.craftResultItems > 0 then
        table.insert(debugLines, "Items:")
        for _, resultItem in pairs(self.craftResultItems) do
            local lines = resultItem:Debug()
            lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({ debugLines, lines })
        end
    end

    if #self.savedReagents > 0 then
        table.insert(debugLines, "SavedReagents:")
        for _, savedReagent in pairs(self.savedReagents) do
            local lines = savedReagent:Debug()
            lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({ debugLines, lines })
        end
    end


    return debugLines
end

function CraftSim.CraftResult:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("profit", self.profit)
    jb:Add("expectedQuality", self.expectedQuality)
    jb:Add("triggeredMulticraft", self.triggeredMulticraft)
    jb:Add("triggeredResourcefulness", self.triggeredResourcefulness)
    jb:AddList("craftResultItems", self.craftResultItems)
    jb:AddList("savedReagents", self.savedReagents, true)
    jb:End()
    return jb.json
end
