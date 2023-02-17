AddonName, CraftSim = ...

CraftSim.PRICEDATA = {}

CraftSim.PRICEDATA.noPriceDataLinks = {}

CraftSim.PRICEDATA.overrideResultProfits = {} -- mapped by qualityID
CraftSim.PRICEDATA.overrideCraftingCosts = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)

-- Wrappers 
function CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, isReagent)
    -- check for overrides
    if isReagent then
        -- only applies to reagents here
        local recipeData = CraftSim.MAIN.currentRecipeData

        if recipeData then
            local priceOverride = CraftSim.PRICE_OVERRIDE:GetPriceOverrideForItem(recipeData.recipeID, itemID)

            if priceOverride then
                return priceOverride
            end
        end
    end

    if not CraftSim.PRICE_APIS.available then
        return 0
    end

    local minbuyout = CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, isReagent)
    if minbuyout == nil then
        local _, link = GetItemInfo(itemID)
        if link == nil then
            link = itemID
        end
        if CraftSim.PRICEDATA.noPriceDataLinks[link] == nil then
            -- not beautiful but hey, easy map
            CraftSim.PRICEDATA.noPriceDataLinks[link] = link
        end
        minbuyout = 0
    end
    return minbuyout
end

function CraftSim.PRICEDATA:GetMinBuyoutByItemLink(itemLink, isReagent)
    if not CraftSim.PRICE_APIS.available then
        return 0
    end
    
    local minbuyout = CraftSim.PRICE_API:GetMinBuyoutByItemLink(itemLink, isReagent)
    if minbuyout == nil then
        if CraftSim.PRICEDATA.noPriceDataLinks[itemLink] == nil then
            -- not beautiful but hey, easy map
            CraftSim.PRICEDATA.noPriceDataLinks[itemLink] = itemLink
        end
        minbuyout = 0
    end
    return minbuyout
end