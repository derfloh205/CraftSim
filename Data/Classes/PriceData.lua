_, CraftSim = ...

---@class CraftSim.PriceData
---@field recipeData CraftSim.RecipeData
---@field qualityPriceList number[]
---@field craftingCosts number
---@field craftingCostsRequired number
---@field craftingCostsFixed number -- the crafting costs without any reagents of quality

CraftSim.PriceData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT)

---@param recipeData CraftSim.RecipeData
function CraftSim.PriceData:new(recipeData)
    self.recipeData = recipeData
    self.qualityPriceList = {}
    self.craftingCosts = 0
end

--- Update Pricing Information based on reagentData and resultData and any price overrides
function CraftSim.PriceData:Update()
    local resultData = self.recipeData.resultData
    local reagentData = self.recipeData.reagentData

    self.craftingCosts = 0
    self.craftingCostsRequired = 0
    self.craftingCostsFixed = 0
    self.qualityPriceList = {}

    print("Calculating Crafting Costs: ", false, true)

    if self.recipeData.isSalvageRecipe then
        if reagentData.salvageReagentSlot.activeItem then
            local itemID = reagentData.salvageReagentSlot.activeItem:GetItemID()
            local itemPrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemID) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
            self.craftingCosts = self.craftingCosts + itemPrice * reagentData.salvageReagentSlot.requiredQuantity
            self.craftingCostsRequired = self.craftingCosts
        end
    else
        print("Summing reagents:")
        for _, reagent in pairs(reagentData.requiredReagents) do
            if reagent.hasQuality then
                local totalQuantity = 0
                local totalPrice = 0
                for _, reagentItem in pairs(reagent.items) do
                    totalQuantity = totalQuantity + reagentItem.quantity
                    local itemID = reagentItem.item:GetItemID()
                    local itemPrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemID) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
                    totalPrice = totalPrice + itemPrice * reagentItem.quantity
                end

                if totalQuantity < reagent.requiredQuantity then
                    -- assume cheapest
                    -- TODO: make a util function
                    local itemIDQ1 = reagent.items[1].item:GetItemID()
                    local itemIDQ2 = reagent.items[2].item:GetItemID()
                    local itemIDQ3 = reagent.items[3].item:GetItemID()
                    local itemPriceQ1 = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemIDQ1) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemIDQ1, true)
                    local itemPriceQ2 = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemIDQ2) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemIDQ2, true)
                    local itemPriceQ3 = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemIDQ3) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemIDQ3, true)
                    local cheapestItemPrice = math.min(itemPriceQ1, itemPriceQ2, itemPriceQ3)

                    self.craftingCosts = self.craftingCosts + cheapestItemPrice * reagent.requiredQuantity
                else
                    self.craftingCosts = self.craftingCosts + totalPrice
                end
            else
                local itemID = reagent.items[1].item:GetItemID()
                local itemPrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemID) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
                self.craftingCosts = self.craftingCosts + itemPrice * reagent.requiredQuantity
                self.craftingCostsFixed = self.craftingCostsFixed + itemPrice * reagent.requiredQuantity -- always max
            end
        end

        self.craftingCostsRequired = self.craftingCosts

        -- optionals and finishing
        local activeOptionalReagents = CraftSim.UTIL:Concat({
                CraftSim.UTIL:Map(reagentData.optionalReagentSlots, function(slot) return slot.activeItem end),
                CraftSim.UTIL:Map(reagentData.finishingReagentSlots, function(slot) return slot.activeItem end),
            })
        for _, activeOptionalReagent in pairs(activeOptionalReagents) do
            if activeOptionalReagent then
                local itemID = activeOptionalReagent.item:GetItemID()
                local itemPrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemID) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
                self.craftingCosts = self.craftingCosts + itemPrice
            end
        end
    end

    for i, item in pairs(resultData.itemsByQuality) do
        -- if its gear, it should have a loaded link as we created the item with it
        -- if its not gear we get the price by id
        local itemPrice = 0
        if self.recipeData.isGear then
            itemPrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, i) or CraftSim.PRICEDATA:GetMinBuyoutByItemLink(item:GetItemLink())
        else
            itemPrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, i) or CraftSim.PRICEDATA:GetMinBuyoutByItemID(item:GetItemID())
        end
        table.insert(self.qualityPriceList, itemPrice)
    end
end

function CraftSim.PriceData:Debug() 
    local debugLines = {
        "PriceData: ",
        "Crafting Costs: " .. CraftSim.UTIL:FormatMoney(self.craftingCosts),
    }

    for q, qualityPrice in pairs(self.qualityPriceList) do
        table.insert(debugLines, "-Q" .. q .. ": " .. CraftSim.UTIL:FormatMoney(qualityPrice))
    end

    return debugLines
end

function CraftSim.PriceData:Copy(recipeData)
    local copy = CraftSim.PriceData(recipeData)
    copy.qualityPriceList = CraftSim.UTIL:Map(self.qualityPriceList, function(n) return n end)
    copy.craftingCosts = self.craftingCosts
    copy.craftingCostsFixed = self.craftingCostsFixed
    copy.craftingCostsRequired = self.craftingCostsRequired
    return copy
end