addonName, CraftSim = ...

CraftSim.PRICE_OVERRIDE = {}

CraftSimPriceOverrides = CraftSimPriceOverrides or {
    globalOverrides = {},
    recipeOverrides = {},
}
function CraftSim.PRICE_OVERRIDE:AddOverrideForRecipe(recipeID, itemID, moneyValue)
    if not CraftSimPriceOverrides.recipeOverrides[recipeID] then
        CraftSimPriceOverrides.recipeOverrides[recipeID] = {}
    end
    CraftSimPriceOverrides.recipeOverrides[recipeID][itemID] = moneyValue
end

function CraftSim.PRICE_OVERRIDE:RemoveOverrideForRecipe(recipeID, itemID)
    if not CraftSimPriceOverrides.recipeOverrides[recipeID] then
        CraftSimPriceOverrides.recipeOverrides[recipeID] = {}
    end
    CraftSimPriceOverrides.recipeOverrides[recipeID][itemID] = null
end

function CraftSim.PRICE_OVERRIDE:AddOverrideGlobal(itemID, moneyValue)
        CraftSimPriceOverrides.globalOverrides[itemID] = moneyValue
end

function CraftSim.PRICE_OVERRIDE:RemoveOverrideGlobal(itemID)
    CraftSimPriceOverrides.globalOverrides[itemID] = null
end

function CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(recipeID, itemID)
    if CraftSimPriceOverrides.recipeOverrides[recipeID] then
        if CraftSimPriceOverrides.recipeOverrides[recipeID][itemID] then
            return CraftSimPriceOverrides.recipeOverrides[recipeID][itemID]
        end
    end 

    return CraftSimPriceOverrides.globalOverrides[itemID], true
end

function CraftSim.PRICE_OVERRIDE:RemoveAllOverridesForItem(recipeID, itemID)
    CraftSim.PRICE_OVERRIDE:RemoveOverrideGlobal(itemID)
    CraftSim.PRICE_OVERRIDE:RemoveOverrideForRecipe(recipeID, itemID)
end

function CraftSim.PRICE_OVERRIDE:ResetAll()
    CraftSimPriceOverrides = {
        globalOverrides = {},
        recipeOverrides = {},
    }
end

function CraftSim.PRICE_OVERRIDE:ResetRecipe(recipeID)
    CraftSimPriceOverrides.recipeOverrides[recipeID] = null
end