---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL


---@class CraftSim.PriceData : CraftSim.CraftSimObject
CraftSim.PriceData = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.PriceData")
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
    self.craftingCostsNoOrderReagents = 0
    self.expectedCostsPerItem = 0
    self.resourcefulnessSavedCosts = 0
    self.resourcefulnessSavedCostsAverage = 0
    --- list of itemIDs of reagents where the selfcrafted price is used
    ---@type ItemID[]
    self.selfCraftedReagents = {}

    ---@class CraftSim.PriceData.ReagentPriceInfo
    ---@field itemPrice number
    ---@field priceInfo CraftSim.PriceData.PriceInfo


    ---@type table<ItemID, CraftSim.PriceData.ReagentPriceInfo>
    self.reagentPriceInfos = {}
end

---@param itemID ItemID
function CraftSim.PriceData:IsSelfCraftedReagent(itemID)
    return tContains(self.selfCraftedReagents, itemID)
end

---@return boolean active
function CraftSim.PriceData:PriceOverridesActive()
    local reagentOverride = GUTIL:Some(self.reagentPriceInfos, function(info)
        return info.priceInfo.isOverride
    end)

    if reagentOverride then return true end

    for qualityID, _ in ipairs(self.recipeData.resultData.itemsByQuality or {}) do
        local overrideInfo = CraftSim.DB.PRICE_OVERRIDE:GetResultOverride(self.recipeData.recipeID, qualityID)
        if overrideInfo then
            return true
        end
    end

    return false
end

--- Update Pricing Information based on reagentData and resultData and any price overrides
function CraftSim.PriceData:Update()
    local resultData = self.recipeData.resultData
    local reagentData = self.recipeData.reagentData

    self.craftingCosts = 0
    self.craftingCostsRequired = 0
    self.craftingCostsFixed = 0
    self.craftingCostsNoOrderReagents = 0
    self.expectedCostsPerItem = 0
    self.resourcefulnessSavedCosts = 0
    self.resourcefulnessSavedCostsAverage = 0
    wipe(self.qualityPriceList)
    wipe(self.selfCraftedReagents)

    self:UpdateReagentPriceInfos()

    local useSubRecipes = self.recipeData.subRecipeCostsEnabled

    print("Update PriceData: " .. tostring(self.recipeData.recipeName), false, true)
    print("Using subrecipes: " .. tostring(useSubRecipes))

    print("Calculating Crafting Costs: ")

    local isWorkOrder = self.recipeData.orderData ~= 0

    if self.recipeData.isSalvageRecipe and reagentData.salvageReagentSlot.activeItem then
        local itemID = reagentData.salvageReagentSlot.activeItem:GetItemID()
        -- only use subrecipe price if the item also has a optimizedSubRecipe in the recipeData
        local reagentPriceInfo = self.reagentPriceInfos[itemID]

        self.craftingCosts = self.craftingCosts +
            reagentPriceInfo.itemPrice * reagentData.salvageReagentSlot.requiredQuantity
        self.craftingCostsRequired = self.craftingCosts
        self.craftingCostsNoOrderReagents = self.craftingCosts

        if reagentPriceInfo.priceInfo.isExpectedCost then
            tinsert(self.selfCraftedReagents, itemID)
        end
    end

    print("Summing reagents:")
    for _, reagent in pairs(reagentData.requiredReagents) do
        local isOrderReagent = isWorkOrder and reagent:IsOrderReagentIn(self.recipeData)
        if reagent.hasQuality then
            local totalQuantity = 0
            local totalPrice = 0
            for _, reagentItem in pairs(reagent.items) do
                totalQuantity = totalQuantity + reagentItem.quantity
                local itemID = reagentItem.item:GetItemID()
                local reagentPriceInfo = self.reagentPriceInfos[itemID]
                totalPrice = totalPrice + reagentPriceInfo.itemPrice * reagentItem.quantity

                if not isOrderReagent and reagentPriceInfo.priceInfo.isExpectedCost then
                    tinsert(self.selfCraftedReagents, itemID)
                end
            end

            if totalQuantity < reagent.requiredQuantity then
                -- assume cheapest
                local itemIDQ1 = reagent.items[1].item:GetItemID()
                local itemIDQ2 = reagent.items[2].item:GetItemID()
                -- Midnight reagents only have 2-tier quality
                local itemIDQ3 = reagent.items[3] and reagent.items[3].item:GetItemID() or nil
                local reagentPriceInfoQ1 = self.reagentPriceInfos[itemIDQ1]
                local reagentPriceInfoQ2 = self.reagentPriceInfos[itemIDQ2]
                local reagentPriceInfoQ3 = itemIDQ3 and self.reagentPriceInfos[itemIDQ3] or nil
                local cheapestItemPrice = reagentPriceInfoQ3 and
                                            math.min(reagentPriceInfoQ1.itemPrice, reagentPriceInfoQ2.itemPrice, reagentPriceInfoQ3.itemPrice) or
                                            math.min(reagentPriceInfoQ1.itemPrice, reagentPriceInfoQ2.itemPrice)
                local reagentCosts = cheapestItemPrice * reagent.requiredQuantity
                self.craftingCosts = self.craftingCosts + reagentCosts
                if not isOrderReagent then
                    self.craftingCostsNoOrderReagents = self.craftingCostsNoOrderReagents + reagentCosts
                end
            else
                self.craftingCosts = self.craftingCosts + totalPrice
                if not isOrderReagent then
                    self.craftingCostsNoOrderReagents = self.craftingCostsNoOrderReagents + totalPrice
                end
            end
        else
            local itemID = reagent.items[1].item:GetItemID()
            local reagentPriceInfo = self.reagentPriceInfos[itemID]

            local reagentCosts = reagentPriceInfo.itemPrice * reagent.requiredQuantity

            self.craftingCosts = self.craftingCosts + reagentCosts
            self.craftingCostsFixed = self.craftingCostsFixed + reagentCosts -- always max

            if not isOrderReagent then
                self.craftingCostsNoOrderReagents = self.craftingCostsNoOrderReagents + reagentCosts
                if reagentPriceInfo.priceInfo.isExpectedCost then
                    tinsert(self.selfCraftedReagents, itemID)
                end
            end
        end
    end

    self.craftingCostsRequired = self.craftingCosts

    -- optionals and finishing
    local activeOptionalReagents = GUTIL:Concat({
        GUTIL:Map(reagentData.optionalReagentSlots, function(slot) return slot.activeReagent end),
        GUTIL:Map(reagentData.finishingReagentSlots, function(slot) return slot.activeReagent end),
    })
    local quantityMap = {} -- ugly hack
    if self.recipeData.reagentData:HasRequiredSelectableReagent() then
        if self.recipeData.reagentData.requiredSelectableReagentSlot.activeReagent then
            tinsert(activeOptionalReagents, self.recipeData.reagentData.requiredSelectableReagentSlot.activeReagent)
            quantityMap[self.recipeData.reagentData.requiredSelectableReagentSlot.activeReagent.item:GetItemID()] =
                self.recipeData.reagentData.requiredSelectableReagentSlot.maxQuantity
        end
    end
    print("num active optionals: " .. #activeOptionalReagents)
    for _, activeOptionalReagent in pairs(activeOptionalReagents) do
        if activeOptionalReagent then
            local isOrderReagent = isWorkOrder and activeOptionalReagent:IsOrderReagentIn(self.recipeData)
            print("added optional reagent to crafting cost: " .. tostring(activeOptionalReagent.item:GetItemLink()))
            local itemID = activeOptionalReagent.item:GetItemID()
            local reagentPriceInfo = self.reagentPriceInfos[itemID]

            local reagentCosts = (reagentPriceInfo.itemPrice * (quantityMap[itemID] or 1))
            self.craftingCosts = self.craftingCosts + reagentCosts

            if not isOrderReagent then
                self.craftingCostsNoOrderReagents = self.craftingCostsNoOrderReagents + reagentCosts
                if reagentPriceInfo.priceInfo.isExpectedCost then
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
    self.expectedCostsPerItem = self.averageCraftingCosts / (expectedYieldPerCraft > 0 and expectedYieldPerCraft or 1)

    print("calculated crafting costs: " .. tostring(self.craftingCosts))
end

--- updates self.reagentPriceInfos map
function CraftSim.PriceData:UpdateReagentPriceInfos()
    wipe(self.reagentPriceInfos)

    local useSubRecipes = self.recipeData.subRecipeCostsEnabled
    local reagentData = self.recipeData.reagentData

    if self.recipeData.isSalvageRecipe then
        -- map price infos of all possible salvage items
        for _, possibleSalveReagent in ipairs(self.recipeData.reagentData.salvageReagentSlot.possibleItems or {}) do
            local itemID = possibleSalveReagent:GetItemID()
            local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
            self.reagentPriceInfos[itemID] = {
                itemPrice = itemPrice,
                priceInfo = priceInfo,
            }
        end
    end

    for _, reagent in ipairs(reagentData.requiredReagents) do
        for _, reagentItem in ipairs(reagent.items) do
            local itemID = reagentItem.item:GetItemID()
            local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
            self.reagentPriceInfos[itemID] = {
                itemPrice = itemPrice,
                priceInfo = priceInfo,
            }
        end
    end

    ---@type CraftSim.OptionalReagent[]
    local possibleOptionals = (reagentData:HasRequiredSelectableReagent() and CopyTable(reagentData.requiredSelectableReagentSlot.possibleReagents, true)) or
        {}
    for _, optionalSlot in ipairs(GUTIL:Concat { reagentData.optionalReagentSlots or {}, reagentData.finishingReagentSlots or {} }) do
        tAppendAll(possibleOptionals, optionalSlot.possibleReagents)
    end

    for _, optionalReagent in ipairs(possibleOptionals) do
        if not optionalReagent:IsCurrency() then
            local itemID = optionalReagent.item:GetItemID()
            local itemPrice, priceInfo = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, false,
                useSubRecipes and self.recipeData.optimizedSubRecipes[itemID])
            self.reagentPriceInfos[itemID] = {
                itemPrice = itemPrice,
                priceInfo = priceInfo,
            }
        end
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
    copy.qualityPriceList = CopyTable(self.qualityPriceList or {})
    copy.craftingCosts = self.craftingCosts
    copy.craftingCostsFixed = self.craftingCostsFixed
    copy.craftingCostsRequired = self.craftingCostsRequired
    copy.expectedCostsPerItem = self.expectedCostsPerItem
    copy.selfCraftedReagents = CopyTable(self.selfCraftedReagents or {})
    copy.averageCraftingCosts = self.averageCraftingCosts
    copy.resourcefulnessSavedCosts = self.resourcefulnessSavedCosts
    copy.resourcefulnessSavedCostsAverage = self.resourcefulnessSavedCostsAverage
    copy.reagentPriceInfos = CopyTable(self.reagentPriceInfos)
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
