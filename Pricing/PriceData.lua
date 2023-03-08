AddonName, CraftSim = ...

CraftSim.PRICEDATA = {}

CraftSim.PRICEDATA.noPriceDataLinks = {}

CraftSim.PRICEDATA.overrideResultProfits = {} -- mapped by qualityID
CraftSim.PRICEDATA.overrideCraftingCosts = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)

---Wrapper for Price Source addons price fetch by itemID
---@param itemID number
---@param isReagent? boolean Use TSM Expression for materials
---@return number
---@return boolean? isPriceOverride
---@return boolean? isCraftData
function CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, isReagent, forceAHPrice)
    if forceAHPrice then
        return CraftSim.PRICE_API:GetMinBuyoutByItemID(itemID, isReagent) or 0
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
                    return craftData:GetExpectedCosts(), true, true
                end
            else
                --print("does not use craft data")
                return priceOverrideData.price, true
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