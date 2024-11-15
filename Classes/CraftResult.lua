---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CraftResult : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, craftingItemResultData: CraftingItemResultData): CraftSim.CraftResult
CraftSim.CraftResult = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param craftingItemResultData CraftingItemResultData[]
function CraftSim.CraftResult:new(recipeData, craftingItemResultData)
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

    -- just take resourcefulness from the first craftResult
    -- this is because of a blizzard bug where the same proc is listed in every craft result

    if craftingItemResultData[1].resourcesReturned then
        self.triggeredResourcefulness = true
        for _, craftingResourceReturnInfo in pairs(craftingItemResultData[1].resourcesReturned) do
            local craftResultSavedReagent = CraftSim.CraftResultReagent(recipeData,
                craftingResourceReturnInfo.itemID, craftingResourceReturnInfo.quantity)
            self.savedCosts = self.savedCosts + craftResultSavedReagent.costs
            table.insert(self.savedReagents, craftResultSavedReagent)
        end
    end

    -- Reagents
    do
        local reagentItemIDs = {}
        if recipeData.isSalvageRecipe then
            local slot = recipeData.reagentData.salvageReagentSlot
            local itemID = slot.activeItem:GetItemID()
            local quantity = slot.requiredQuantity
            local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
            self.craftingCosts = self.craftingCosts + reagentCosts
            tinsert(self.reagents, CraftSim.CraftResultReagent(recipeData, itemID, quantity))
            tinsert(reagentItemIDs, itemID .. "." .. quantity)
        end

        if recipeData:HasRequiredSelectableReagent() then
            local slot = recipeData.reagentData.requiredSelectableReagentSlot
            if slot then
                local itemID = slot.activeReagent.item:GetItemID()
                local quantity = slot.maxQuantity
                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                local isOrderReagent = slot.activeReagent:IsOrderReagentIn(recipeData)
                if not isOrderReagent then
                    self.craftingCosts = self.craftingCosts + reagentCosts
                end
                tinsert(self.reagents,
                    CraftSim.CraftResultReagent(recipeData, itemID, quantity, isOrderReagent))
                tinsert(reagentItemIDs, itemID .. "." .. quantity)
            end
        end

        -- required
        for _, requiredReagent in ipairs(recipeData.reagentData.requiredReagents) do
            for _, reagentItem in ipairs(requiredReagent.items) do
                local quantity = reagentItem.quantity
                local itemID = reagentItem.item:GetItemID()
                local isOrderReagent = reagentItem:IsOrderReagentIn(recipeData)

                tinsert(self.reagents,
                    CraftSim.CraftResultReagent(recipeData, itemID, quantity, isOrderReagent))

                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                if not isOrderReagent then
                    self.craftingCosts = self.craftingCosts + reagentCosts
                end
                if quantity > 0 then
                    tinsert(reagentItemIDs, itemID .. "." .. quantity)
                end
            end
        end

        for _, optionalReagentSlot in ipairs(GUTIL:Concat { recipeData.reagentData.optionalReagentSlots, recipeData.reagentData.finishingReagentSlots }) do
            if optionalReagentSlot:IsAllocated() then
                local itemID = optionalReagentSlot.activeReagent.item:GetItemID()
                local quantity = optionalReagentSlot.maxQuantity
                local reagentCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false, true) * quantity
                local isOrderReagent = optionalReagentSlot.activeReagent:IsOrderReagentIn(recipeData)
                if not isOrderReagent then
                    self.craftingCosts = self.craftingCosts + reagentCosts
                end
                tinsert(self.reagents,
                    CraftSim.CraftResultReagent(recipeData, itemID, quantity, isOrderReagent))
                tinsert(reagentItemIDs, itemID .. "." .. quantity)
            end
        end

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

    self.craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents - self.savedCosts

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
        "expectedAverageProfit: " .. CraftSim.UTIL:FormatMoney(self.expectedAverageProfit, true),
        "expectedAverageSavedCosts: " .. CraftSim.UTIL:FormatMoney(self.expectedAverageSavedCosts, true),
        "expectedQuality: " .. tostring(self.expectedQuality),
        "craftingChance: " .. tostring((self.craftingChance or 0) * 100) .. "%",
        "triggeredMulticraft: " .. tostring(self.triggeredMulticraft),
        "triggeredResourcefulness: " .. tostring(self.triggeredResourcefulness),
    }
    if #self.craftResultItems > 0 then
        table.insert(debugLines, "Items:")
        table.foreach(self.craftResultItems, function(_, resultItem)
            local lines = resultItem:Debug()
            lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({ debugLines, lines })
        end)
    end

    if #self.savedReagents > 0 then
        table.insert(debugLines, "SavedReagents:")
        table.foreach(self.savedReagents, function(_, savedReagent)
            local lines = savedReagent:Debug()
            lines = CraftSim.GUTIL:Map(lines, function(line) return "-" .. line end)
            debugLines = CraftSim.GUTIL:Concat({ debugLines, lines })
        end)
    end


    return debugLines
end

function CraftSim.CraftResult:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("profit", self.profit)
    jb:Add("expectedAverageProfit", self.expectedAverageProfit)
    jb:Add("expectedAverageSavedCosts", self.expectedAverageSavedCosts)
    jb:Add("expectedQuality", self.expectedQuality)
    jb:Add("craftingChance", self.craftingChance)
    jb:Add("triggeredMulticraft", self.triggeredMulticraft)
    jb:Add("triggeredResourcefulness", self.triggeredResourcefulness)
    jb:AddList("craftResultItems", self.craftResultItems)
    jb:AddList("savedReagents", self.savedReagents, true)
    jb:End()
    return jb.json
end
