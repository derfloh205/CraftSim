---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.PRICEDATA = {}

CraftSim.PRICEDATA.noPriceDataLinks = {}

CraftSim.PRICEDATA.overrideResultProfits = {} -- mapped by qualityID
CraftSim.PRICEDATA.overrideCraftingCosts = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICEDATA)

---@class CraftSim.PriceData.PriceInfo
---@field ahPrice number
---@field priceOverride? number
---@field isAHPrice boolean
---@field noAHPriceFound boolean
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
        noAHPriceFound = ahPrice == nil,
        isOverride = false,
        noPriceSource = false,
        isAHPrice = false,
    }

    if forceAHPrice then
        priceInfo.isAHPrice = true
        return priceInfo.ahPrice, priceInfo
    end
    -- check for overrides
    if isReagent then
        local priceOverrideData = CraftSim.PRICE_OVERRIDE:GetGlobalOverride(itemID)


        if priceOverrideData then
            priceInfo.isOverride = true
            return priceOverrideData.price, priceInfo
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

--- returns the amount of the item the player has in the AH or nil if no price source addon is loaded that can fetch this for us
---@param idOrLink? number | string
---@return number? auctionAmount
function CraftSim.PRICEDATA:GetAuctionAmount(idOrLink)
    if C_AddOns.IsAddOnLoaded(CraftSimTSM.name) then
        return CraftSimTSM:GetAuctionAmount(idOrLink)
    else
        return
    end
end
