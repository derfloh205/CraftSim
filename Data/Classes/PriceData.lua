---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL


---@class CraftSim.PriceData
CraftSim.PriceData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)
local f = CraftSim.UTIL:GetFormatter()

---@param recipeData CraftSim.RecipeData
function CraftSim.PriceData:new(recipeData)
    self.recipeData = recipeData
    ---@type number[]
    self.qualityPriceList = {}
    self.expectedCostsByQuality = {}
    self.craftingCosts = 0
end

--- Update Pricing Information based on reagentData and resultData and any price overrides
function CraftSim.PriceData:Update()
    local resultData = self.recipeData.resultData
    local reagentData = self.recipeData.reagentData

    self.craftingCosts = 0
    self.craftingCostsRequired = 0
    self.craftingCostsFixed = 0
    wipe(self.qualityPriceList)
    wipe(self.expectedCostsByQuality)

    local useSubRecipes = self.recipeData.subRecipeCostsEnabled

    print("Update PriceData", false, true)
    print("using subrecipes: " .. tostring(useSubRecipes))

    print("Calculating Crafting Costs: ")

    if self.recipeData.isSalvageRecipe then
        if reagentData.salvageReagentSlot.activeItem then
            local itemID = reagentData.salvageReagentSlot.activeItem:GetItemID()
            local itemPrice = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true, false, useSubRecipes)
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
                    local itemPrice = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true, false, useSubRecipes)
                    totalPrice = totalPrice + itemPrice * reagentItem.quantity
                end

                if totalQuantity < reagent.requiredQuantity then
                    -- assume cheapest
                    -- TODO: make a util function
                    local itemIDQ1 = reagent.items[1].item:GetItemID()
                    local itemIDQ2 = reagent.items[2].item:GetItemID()
                    local itemIDQ3 = reagent.items[3].item:GetItemID()
                    local itemPriceQ1 = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemIDQ1, true, false, useSubRecipes)
                    local itemPriceQ2 = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemIDQ2, true, false, useSubRecipes)
                    local itemPriceQ3 = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemIDQ3, true, false, useSubRecipes)
                    local cheapestItemPrice = math.min(itemPriceQ1, itemPriceQ2, itemPriceQ3)

                    self.craftingCosts = self.craftingCosts + cheapestItemPrice * reagent.requiredQuantity
                else
                    self.craftingCosts = self.craftingCosts + totalPrice
                end
            else
                local itemID = reagent.items[1].item:GetItemID()
                local itemPrice = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true)
                self.craftingCosts = self.craftingCosts + itemPrice * reagent.requiredQuantity
                self.craftingCostsFixed = self.craftingCostsFixed + itemPrice * reagent.requiredQuantity -- always max
            end
        end

        self.craftingCostsRequired = self.craftingCosts

        -- optionals and finishing
        local activeOptionalReagents = GUTIL:Concat({
            GUTIL:Map(reagentData.optionalReagentSlots, function(slot) return slot.activeReagent end),
            GUTIL:Map(reagentData.finishingReagentSlots, function(slot) return slot.activeReagent end),
        })
        print("num active optionals: " .. #activeOptionalReagents)
        for _, activeOptionalReagent in pairs(activeOptionalReagents) do
            if activeOptionalReagent then
                print("added optional reagent to crafting cost: " .. tostring(activeOptionalReagent.item:GetItemLink()))
                local itemID = activeOptionalReagent.item:GetItemID()
                local itemPrice = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true, false, useSubRecipes)
                self.craftingCosts = self.craftingCosts + itemPrice
            end
        end
    end

    for i, item in pairs(resultData.itemsByQuality) do
        -- if its gear, it should have a loaded link as we created the item with it
        -- if its not gear we get the price by id
        local itemPrice = 0
        if self.recipeData.isGear then
            itemPrice = CraftSim.PRICE_OVERRIDE:GetResultOverridePrice(self.recipeData.recipeID, i) or
                CraftSim.PRICEDATA:GetMinBuyoutByItemLink(item:GetItemLink())
        else
            itemPrice = CraftSim.PRICE_OVERRIDE:GetResultOverridePrice(self.recipeData.recipeID, i) or
                CraftSim.PRICEDATA:GetMinBuyoutByItemID(item:GetItemID())
        end
        table.insert(self.qualityPriceList, itemPrice)
    end

    local avgSavedCostsRes = 0
    if self.recipeData.supportsResourcefulness then
        -- in this case we need the average saved costs per craft
        avgSavedCostsRes = CraftSim.CALC:getResourcefulnessSavedCosts(self.recipeData) *
            self.recipeData.professionStats.resourcefulness:GetPercent(true)
    end
    for qualityID, chance in pairs(self.recipeData.resultData.chanceByQuality) do
        local baseAmount = self.recipeData.baseItemAmount
        local averageItemAmountForUpgrade = baseAmount
        if self.recipeData.supportsMulticraft then
            local multicraftChance = self.recipeData.professionStats.multicraft:GetPercent(true)
            local multiCraftUpgradeChance = chance * multicraftChance
            local expectedExtraItems = select(2, CraftSim.CALC:GetExpectedItemAmountMulticraft(self.recipeData))
            local avgExpectedExtraItemsForUpgradeWithMC = multiCraftUpgradeChance * expectedExtraItems
            averageItemAmountForUpgrade = averageItemAmountForUpgrade + avgExpectedExtraItemsForUpgradeWithMC
        end

        if chance == 1 then
            self.expectedCostsByQuality[qualityID] = (self.craftingCosts - avgSavedCostsRes) /
                averageItemAmountForUpgrade
        elseif chance > 0 then
            local expectedCrafts = self.recipeData.resultData.expectedCraftsByQuality[qualityID]
            self.expectedCostsByQuality[qualityID] = CraftSim.CALC:CalculateExpectedCosts(
                expectedCrafts, chance, self.recipeData.professionStats.resourcefulness:GetPercent(true),
                self.recipeData.professionStats.resourcefulness:GetExtraFactor(true), averageItemAmountForUpgrade,
                self.craftingCosts, self.craftingCostsRequired)
        end
    end

    print("calculated crafting costs: " .. tostring(self.craftingCosts))
end

function CraftSim.PriceData:Debug()
    local debugLines = {
        "PriceData: ",
        "Crafting Costs: " .. GUTIL:FormatMoney(self.craftingCosts),
    }

    for q, qualityPrice in pairs(self.qualityPriceList) do
        table.insert(debugLines, "-Q" .. q .. ": " .. GUTIL:FormatMoney(qualityPrice))
    end

    return debugLines
end

function CraftSim.PriceData:Copy(recipeData)
    local copy = CraftSim.PriceData(recipeData)
    copy.qualityPriceList = CopyTable(self.qualityPriceList)
    copy.craftingCosts = self.craftingCosts
    copy.craftingCostsFixed = self.craftingCostsFixed
    copy.craftingCostsRequired = self.craftingCostsRequired
    copy.expectedCostsByQuality = CopyTable(self.expectedCostsByQuality)
    copy.optimizedReagentsExpectedCraftingCosts = CopyTable(self.optimizedReagentsExpectedCraftingCosts)
    copy.reagentPriceInfoByItemID = CopyTable(self.reagentPriceInfoByItemID)
    return copy
end

function CraftSim.PriceData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:AddList("qualityPriceList", self.qualityPriceList)
    jb:Add("craftingCosts", self.craftingCosts)
    jb:Add("craftingCostsRequired", self.craftingCostsRequired)
    jb:Add("craftingCostsFixed", self.craftingCostsFixed, true)
    jb:End()
    return jb.json
end
