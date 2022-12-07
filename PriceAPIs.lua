CraftSimPriceAPI = {}
CraftSimPriceAPIs = {}

CraftSimTSM = {name = "TradeSkillMaster"}
CraftSimAUCTIONATOR = {name = "Auctionator"}
CraftSimDEBUG_PRICE_API = {name = "Debug"}

CraftSimDebugData = CraftSimDebugData or {}

function CraftSimPriceAPI:InitPriceSource()
    local loadedSources = CraftSimPriceAPIs:GetAvailablePriceSourceAddons()

    if #loadedSources == 0 then
        print("CraftSim: No Supported Price Source Available!")
        -- TODO ?
        return
    end

    local savedSource = CraftSimOptions.priceSource

    if tContains(loadedSources, savedSource) then
        CraftSimPriceAPIs:SwitchAPIByAddonName(savedSource)
    else
        CraftSimPriceAPIs:SwitchAPIByAddonName(loadedSources[1])
        CraftSimOptions.priceSource = loadedSources[1]
    end
end

function CraftSimPriceAPIs:SwitchAPIByAddonName(addonName)
    if addonName == "TradeSkillMaster" then
        CraftSimPriceAPI = CraftSimTSM
    elseif addonName == "Auctionator" then
        CraftSimPriceAPI = CraftSimAUCTIONATOR
    end
end

function CraftSimPriceAPIs:GetAvailablePriceSourceAddons()
    local loadedAddons = {}
    for _, addonName in pairs(CraftSimCONST.SUPPORTED_PRICE_API_ADDONS) do
        if IsAddOnLoaded(addonName) then
            table.insert(loadedAddons, addonName)
        end
    end
    return loadedAddons
end

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
    
    return CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString)
end

function CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString)
    local minBuyoutPriceSourceKey = CraftSimOptions.tsmPriceKey
    local vendorBuy = "VendorBuy"
    local vendorBuyPrice, error = TSM_API.GetCustomPriceValue(vendorBuy, tsmItemString)

    if vendorBuyPrice == nil then
        --print("found no vendor buy price for: " .. itemLink)
        local minBuyout, error = TSM_API.GetCustomPriceValue(minBuyoutPriceSourceKey, tsmItemString)
        return minBuyout
    else
        --print("found vendor buy price for: " .. itemLink)
        return vendorBuyPrice
    end
end

function CraftSimTSM:GetMinBuyoutByItemLink(itemLink)
    if itemLink == nil then
        return
    end
    local tsmItemString = TSM_API.ToItemString(itemLink)
    -- NOTE: the bonusID 3524 which is often used for df crafted gear is not included in the tsm bonus id map yet
    return CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString)
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemID(itemID)
    local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(CraftSimCONST.AUCTIONATOR_CALLER_ID, itemID)
    if vendorPrice then
        return vendorPrice
    else
        return Auctionator.API.v1.GetAuctionPriceByItemID(CraftSimCONST.AUCTIONATOR_CALLER_ID , itemID)
    end
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemLink(itemLink)
    local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(CraftSimCONST.AUCTIONATOR_CALLER_ID, itemLink)
    if vendorPrice then
        return vendorPrice
    else
        return Auctionator.API.v1.GetAuctionPriceByItemLink(CraftSimCONST.AUCTIONATOR_CALLER_ID , itemLink)
    end
end

function CraftSimDEBUG_PRICE_API:GetMinBuyoutByItemID(itemID)
    local debugItem = CraftSimDebugData[itemID]
    if debugItem == nil then
        local itemName = GetItemInfo(itemID)
        if itemName == nil then
            print("itemData not loaded yet, add to debugData next time..")
            return 0
        end
        print("PriceData not in ItemID Debugdata for: " .. tostring(itemName) .. " .. creating")
        CraftSimDebugData[itemID] = {
            itemName = itemName,
            minBuyout = 0
        }
    end
    return CraftSimDebugData[itemID].minBuyout
end

function CraftSimDEBUG_PRICE_API:GetMinBuyoutByItemLink(itemLink)
    local itemString = select(3, strfind(itemLink, "|H(.+)%["))
    --print("itemString: " .. itemString)
    local debugItem = CraftSimDebugData[itemString]
    if debugItem == nil then
        local itemName = GetItemInfo(itemLink)
        if itemName == nil then
            print("itemData not loaded yet, add to debugData next time..")
            return 0
        end
        print("PriceData not in ItemString Debugdata for: " .. itemName .. " .. creating")
        CraftSimDebugData[itemString] = {
            itemName = itemName,
            minBuyout = 0
        }
    end
    return CraftSimDebugData[itemString].minBuyout
end