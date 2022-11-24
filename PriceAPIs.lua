CraftSimPriceAPI = {}
CraftSimPriceAPIs = {}

CraftSimTSM = {}
CraftSimAUCTIONATOR = {}
CraftSimDEBUG_PRICE_API = {}

CraftSimPriceAPIs.DEBUG = true

function CraftSimPriceAPIs:IsPriceApiAddonLoaded()
    local loaded = false
    for _, name in pairs(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS) do
        if IsAddOnLoaded(name) then
            return true
        end
    end
    return false
end

function CraftSimPriceAPIs:IsAddonPriceApiAddon(addon_name)
    local loading = false
    for _, name in pairs(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS) do
        if addon_name == name then
            return true
        end
    end
    return false
end

function CraftSimPriceAPIs:InitAvailablePriceAPI()
    local _, tsmLoaded = IsAddOnLoaded("TradeSkillMaster")
    local _, auctionatorLoaded = IsAddOnLoaded("Auctionator")
    -- TODO: currently tsm will be prioritized as the price source api if multiple are loaded.. maybe create an optionspanel with dropdown to let the player choose?
    if tsmLoaded then
        --print("Load TSM API")
        CraftSimPriceAPI = CraftSimTSM
    elseif auctionatorLoaded then
        --print("Load Auctionator API")
        CraftSimPriceAPI = CraftSimAUCTIONATOR
    else
        print("CraftSim: No supported price source found")
        print("Supported addons are: ")
        for _, name in pairs(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS) do
            print(name)
        end
    end
end

function CraftSimTSM:GetMinBuyoutByItemID(itemID)
    if itemID == nil then
        return
    end
    local _, itemLink = GetItemInfo(itemID) 
    local tsmItemString = ""
    if itemLink == nil then
        tsmItemString = "i:" .. itemID -- manually, if the link was not generated
    else
        tsmItemString = TSM_API.ToItemString(itemLink)
    end
    
    local minBuyoutPriceSourceKey = "DBMinBuyout"
    local minBuyout, error = TSM_API.GetCustomPriceValue(minBuyoutPriceSourceKey, tsmItemString)
    return minBuyout
end

function CraftSimTSM:GetMinBuyoutByItemLink(itemLink)
    if itemLink == nil then
        return
    end
    local tsmItemString = TSM_API.ToItemString(itemLink)
    -- NOTE: the bonusID 3524 which is often used for df crafted gear is not included in the tsm bonus id map yet
    local minBuyoutPriceSourceKey = "DBMinBuyout"
    local minBuyout, error = TSM_API.GetCustomPriceValue(minBuyoutPriceSourceKey, tsmItemString)
    return minBuyout
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemID(itemID)
    return Auctionator.API.v1.GetAuctionPriceByItemID(CraftSimCONST.AUCTIONATOR_CALLER_ID , itemID)
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemLink(itemLink)
    return Auctionator.API.v1.GetAuctionPriceByItemLink(CraftSimCONST.AUCTIONATOR_CALLER_ID , itemLink)
end

function CraftSimDEBUG_PRICE_API:GetMinBuyoutByItemID(itemID)
    local minBuyout = CraftSimDEBUG_DATA.ITEMID_PRICE_DATA[itemID]
    if minBuyout == nil then
        local _, itemLink = GetItemInfo(itemID)
        print("PriceData not in ItemID Debugdata for: " .. itemLink)
        return 1
    end
    return CraftSimDEBUG_DATA.ITEMID_PRICE_DATA[itemID]
end

function CraftSimDEBUG_PRICE_API:GetMinBuyoutByItemLink(itemLink)
    local itemString = select(3, strfind(itemLink, "|H(.+)%["))
    print("itemString: " .. itemString)
    local minBuyout = CraftSimDEBUG_DATA.ITEMSTRING_PRICE_DATA[itemString]
    if minBuyout == nil then
        print("PriceData not in ItemString Debugdata for: " .. itemLink)
        return 1
    end
    return CraftSimDEBUG_DATA.ITEMSTRING_PRICE_DATA[itemString]
end