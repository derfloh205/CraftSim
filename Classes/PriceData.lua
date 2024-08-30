---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL


---@class CraftSim.PriceData : CraftSim.CraftSimObject
CraftSim.PriceData = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)
local f = GUTIL:GetFormatter()

---@param recipeData CraftSim.RecipeData
function CraftSim.PriceData:new(recipeData)
    self.recipeData = recipeData
    ---@type number[]
    self.qualityPriceList = {}
    --- Per 1 Item
    self.craftingCosts = 0
    self.craftingCostsRequired = 0
    self.craftingCostsFixed = 0
    self.expectedCostsPerItem = 0
    self.resourcefulnessSavedCosts = 0
    self.resourcefulnessSavedCostsAverage = 0
    --- list of itemIDs of reagents where the selfcrafted price is used
    ---@type ItemID[]
    self.selfCraftedReagents = {}
end

---@param itemID ItemID
function CraftSim.PriceData:IsSelfCraftedReagent(itemID)
    return tContains(self.selfCraftedReagents, itemID)
end

--- Update Pricing Information based on reagentData and resultData and any price overrides
function CraftSim.PriceData:Update()
    local resultData = self.recipeData.resultData
    local reagentData = self.recipeData.reagentData

    self.craftingCosts = 0
    self.craftingCostsRequired = 0
    self.craftingCostsFixed = 0
    self.expectedCostsPerItem = 0
    self.resourcefulnessSavedCosts = 0
    self.resourcefulnessSavedCostsAverage = 0
    wipe(self.qualityPriceList)
    wipe(self.selfCraftedReagents)

    local useSubRecipes = self.recipeData.subRecipeCostsEnabled

    print("Update PriceData: " .. tostring(self.recipeData.recipeName), false, true)
    print("Using subrecipes: " .. tostring(useSubRecipes))

    print("Calculating Crafting Costs: ")

    if self.recipeData.isSalvageRecipe then
        if reagentData.salvageReagentSlot.activeItem then
            local itemID = reagentData.salvageReagentSlot.activeItem:GetItemID()
            -- only use subrecipe price if the item also has a optimizedSubRecipe in the recipeData
            local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
            self.craftingCosts = self.craftingCosts + itemPrice * reagentData.salvageReagentSlot.requiredQuantity
            self.craftingCostsRequired = self.craftingCosts
            if priceInfo.isExpectedCost then
                tinsert(self.selfCraftedReagents, itemID)
            end
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
                    local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                        useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
                    totalPrice = totalPrice + itemPrice * reagentItem.quantity
                    if priceInfo.isExpectedCost then
                        tinsert(self.selfCraftedReagents, itemID)
                    end
                end

                if totalQuantity < reagent.requiredQuantity then
                    -- assume cheapest
                    -- TODO: make a util function
                    local itemIDQ1 = reagent.items[1].item:GetItemID()
                    local itemIDQ2 = reagent.items[2].item:GetItemID()
                    local itemIDQ3 = reagent.items[3].item:GetItemID()
                    local itemPriceQ1 = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemIDQ1, true, false,
                        useSubRecipes and self.recipeData.optimizedSubRecipes[itemIDQ1])
                    local itemPriceQ2 = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemIDQ2, true, false,
                        useSubRecipes and self.recipeData.optimizedSubRecipes[itemIDQ2])
                    local itemPriceQ3 = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemIDQ3, true, false,
                        useSubRecipes and self.recipeData.optimizedSubRecipes[itemIDQ3])
                    local cheapestItemPrice = math.min(itemPriceQ1, itemPriceQ2, itemPriceQ3)

                    self.craftingCosts = self.craftingCosts + cheapestItemPrice * reagent.requiredQuantity
                else
                    self.craftingCosts = self.craftingCosts + totalPrice
                end
            else
                local itemID = reagent.items[1].item:GetItemID()
                local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                    useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
                self.craftingCosts = self.craftingCosts + itemPrice * reagent.requiredQuantity
                self.craftingCostsFixed = self.craftingCostsFixed + itemPrice * reagent.requiredQuantity -- always max

                if priceInfo.isExpectedCost then
                    tinsert(self.selfCraftedReagents, itemID)
                end
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
                local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                    useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
                self.craftingCosts = self.craftingCosts + itemPrice

                if priceInfo.isExpectedCost then
                    tinsert(self.selfCraftedReagents, itemID)
                end
            end
        end
    end

    for i, item in pairs(resultData.itemsByQuality) do
        -- if its gear, it should have a loaded link as we created the item with it
        -- if its not gear we get the price by id
        local itemPrice = 0
        if self.recipeData.isGear then
            itemPrice = CraftSim.DB.PRICE_OVERRIDE:GetResultOverridePrice(self.recipeData.recipeID, i) or
                CraftSim.PRICE_SOURCE:GetMinBuyoutByItemLink(item:GetItemLink())
        else
            itemPrice = CraftSim.DB.PRICE_OVERRIDE:GetResultOverridePrice(self.recipeData.recipeID, i) or
                CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(item:GetItemID())
        end
        table.insert(self.qualityPriceList, itemPrice)
    end


    if self.recipeData.supportsResourcefulness then
        self.resourcefulnessSavedCosts = CraftSim.CALC:GetResourcefulnessSavedCosts(self.recipeData)
        -- in this case we need the average saved costs per craft
        self.resourcefulnessSavedCostsAverage = self.resourcefulnessSavedCosts *
            self.recipeData.professionStats.resourcefulness:GetPercent(true)
    end

    local expectedYieldPerCraft = self.recipeData.resultData.expectedYieldPerCraft
    self.averageCraftingCosts = self.craftingCosts - self.resourcefulnessSavedCostsAverage
    self.expectedCostsPerItem = self.averageCraftingCosts / expectedYieldPerCraft

    print("calculated crafting costs: " .. tostring(self.craftingCosts))
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
    copy.qualityPriceList = CopyTable(self.qualityPriceList or {})
    copy.craftingCosts = self.craftingCosts
    copy.craftingCostsFixed = self.craftingCostsFixed
    copy.craftingCostsRequired = self.craftingCostsRequired
    copy.expectedCostsPerItem = self.expectedCostsPerItem
    copy.selfCraftedReagents = CopyTable(self.selfCraftedReagents or {})
    copy.averageCraftingCosts = self.averageCraftingCosts
    copy.resourcefulnessSavedCosts = self.resourcefulnessSavedCosts
    copy.resourcefulnessSavedCostsAverage = self.resourcefulnessSavedCostsAverage
    return copy
end

function CraftSim.PriceData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:AddList("qualityPriceList", self.qualityPriceList)
    jb:Add("craftingCosts", self.craftingCosts)
    jb:Add("craftingCostsRequired", self.craftingCostsRequired)
    jb:Add("craftingCostsFixed", self.craftingCostsFixed)
    jb:Add("expectedCostsPerItem", self.expectedCostsPerItem, true)
    jb:End()
    return jb.json
end
