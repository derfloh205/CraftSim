_, CraftSim = ...

---@class CraftSim.PriceData
---@field recipeData CraftSim.RecipeData
---@field qualityPriceList number[]
---@field craftingCosts number

CraftSim.PriceData = CraftSim.Object:extend()

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

    if self.recipeData.isSalvageRecipe then
        if reagentData.salvageReagentSlot.activeItem then
            local itemID = reagentData.salvageReagentSlot.activeItem:GetItemID()
            local overridePrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, itemID) 
            if overridePrice then
                self.craftingCosts = overridePrice * reagentData.salvageReagentSlot.requiredQuantity
            else
                self.craftingCosts = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true) * reagentData.salvageReagentSlot.requiredQuantity
            end
        end
    else
        for _, craftingReagentInfo in pairs(reagentData:GetCraftingReagentInfoTbl()) do
            local overridePrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, craftingReagentInfo.itemID) 
            if overridePrice then
                self.craftingCosts = overridePrice * craftingReagentInfo.quantity
            else
                self.craftingCosts = CraftSim.PRICEDATA:GetMinBuyoutByItemID(craftingReagentInfo.itemID, true) * craftingReagentInfo.quantity
            end
        end
    end

    for i, item in pairs(resultData.itemsByQuality) do
        local overridePrice = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(self.recipeData.recipeID, i) 
        if overridePrice then
            table.insert(self.qualityPriceList, overridePrice)
        else
            table.insert(self.qualityPriceList, CraftSim.PRICEDATA:GetMinBuyoutByItemID(item:GetItemID()))
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