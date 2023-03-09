AddonName, CraftSim = ...

CraftSim.PRICEDATA = {}

CraftSim.PRICEDATA.noPriceDataLinks = {}

CraftSim.PRICEDATA.overrideResultProfits = {} -- mapped by qualityID
CraftSim.PRICEDATA.overrideCraftingCosts = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)

---@class CraftSim.PriceData.PriceInfo
---@field ahPrice number
---@field craftDataExpectedCosts? number
---@field priceOverride? number
---@field isAHPrice boolean
---@field noAHPriceFound boolean
---@field isCraftData boolean
---@field isOverride boolean
---@field noPriceSource boolean

---Wrapper for Price Source addons price fetch by itemID
---@param itemID number
---@param isReagent? boolean Use TSM Expression for materials
---@return number usedPrice
---@return CraftSim.PriceData.PriceInfo priceInfo
function CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, isReagent, forceAHPrice)
    local ahPrice = CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, isReagent)
    ---@type CraftSim.PriceData.PriceInfo
    local priceInfo = {
        ahPrice = ahPrice or 0,
        noAHPriceFound = ahPrice == nil
    }

    if forceAHPrice then
        priceInfo.isAHPrice = true
        return priceInfo.ahPrice, priceInfo
    end
    -- check for overrides
    if isReagent then
        local priceOverrideData = CraftSim.PRICE_OVERRIDE:GetGlobalOverride(itemID)

        if priceOverrideData then
            if priceOverrideData.useCraftData then
                --- get craft data and return expected costs
                --- based on cached map
                local craftDataSerialized = CraftSim.CraftData:GetActiveCraftDataByItem(Item:CreateFromItemID(itemID))

                --- this no craft data is found it will continue and just fetch the buyout
                if craftDataSerialized then
                    local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
                    local expectedCosts = craftData:GetExpectedCosts()
                    priceInfo.craftDataExpectedCosts = expectedCosts

                    if priceInfo.noAHPriceFound then
                        -- if no ahPrice could be found but we have craftData, use craftData
                        priceInfo.isCraftData = true
                        priceInfo.noAHPriceFound = true
                        return expectedCosts, priceInfo
                    end

                    if priceInfo.ahPrice <= expectedCosts then
                        -- if we have ah price and expected costs but ah price is lower, use ah price
                        priceInfo.isAHPrice = true
                        return priceInfo.ahPrice, priceInfo
                    end

                    priceInfo.isCraftData = true
                    return expectedCosts, priceInfo
                end
            else
                -- we have an override, but no craft data, so use override
                priceInfo.isOverride = true
                return priceOverrideData.price, priceInfo
            end
        end
    end

    if not CraftSim.PRICE_APIS.available then
        priceInfo.noPriceSource = true
        return 0, priceInfo
    end

    priceInfo.isAHPrice = true
    return priceInfo.ahPrice, priceInfo
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