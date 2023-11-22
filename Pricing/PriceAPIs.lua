CraftSimAddonName, CraftSim = ...

CraftSim.PRICE_API = {}
CraftSim.PRICE_APIS = {}

CraftSimTSM = {name = "TradeSkillMaster"}
CraftSimAUCTIONATOR = {name = "Auctionator"}
CraftSimRECRYSTALLIZE = {name = "RECrystallize"}
CraftSimEXCHANGE = {name = "OribosExchange"}
CraftSimDEBUG_PRICE_API = {name = "Debug"}

CraftSimDebugData = CraftSimDebugData or {}
CraftSim.PRICE_APIS.available = true

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_APIS)

function CraftSim.PRICE_API:InitPriceSource()
    local loadedSources = CraftSim.PRICE_APIS:GetAvailablePriceSourceAddons()

    if #loadedSources == 0 then
        CraftSim.UTIL:SystemPrint(CraftSim.GUTIL:ColorizeText("CraftSim:",CraftSim.GUTIL.COLORS.BRIGHT_BLUE) .. " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM))
        CraftSim.PRICE_APIS.available = false
        if not CraftSimOptions.doNotRemindPriceSource then
             CraftSim.GGUI:ShowPopup({
                sizeX=400, sizeY=250, title=CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE), CraftSim.GUTIL.COLORS.RED),
                text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING) .. table.concat(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS, "\n"),
                acceptButtonLabel="OK", declineButtonLabel=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS),
                onDecline=function ()
                    StaticPopup_Show("CRAFT_SIM_ACCEPT_NO_PRICESOURCE_WARNING")
                end
             })
        end 
        CraftSim.PRICE_API = CraftSimDEBUG_PRICE_API
        return
    end

    local savedSource = CraftSimOptions.priceSource

    if tContains(loadedSources, savedSource) then
        CraftSim.PRICE_APIS:SwitchAPIByAddonName(savedSource)
    else
        CraftSim.PRICE_APIS:SwitchAPIByAddonName(loadedSources[1])
        CraftSimOptions.priceSource = loadedSources[1]
    end
end

function CraftSim.PRICE_APIS:SwitchAPIByAddonName(addonName)
    if addonName == "TradeSkillMaster" then
        CraftSim.PRICE_API = CraftSimTSM
    elseif addonName == "Auctionator" then
        CraftSim.PRICE_API = CraftSimAUCTIONATOR
    elseif addonName == "RECrystallize" then
        CraftSim.PRICE_API = CraftSimRECRYSTALLIZE
    elseif addonName == "OribosExchange" then
        CraftSim.PRICE_API = CraftSimEXCHANGE
    end
end

function CraftSim.PRICE_APIS:GetAvailablePriceSourceAddons()
    local loadedAddons = {}
    for _, addonName in pairs(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS) do
        if IsAddOnLoaded(addonName) then
            table.insert(loadedAddons, addonName)
        end
    end
    return loadedAddons
end

function CraftSim.PRICE_APIS:IsPriceApiAddonLoaded()
    local loaded = false
    for _, name in pairs(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS) do
        if IsAddOnLoaded(name) then
            return true
        end
    end
    return false
end

function CraftSim.PRICE_APIS:IsAddonPriceApiAddon(addon_name)
    local loading = false
    for _, name in pairs(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS) do
        if addon_name == name then
            return true
        end
    end
    return false
end

function CraftSim.PRICE_APIS:InitAvailablePriceAPI()
    local _, tsmLoaded = IsAddOnLoaded(CraftSimTSM.name)
    local _, auctionatorLoaded = IsAddOnLoaded(CraftSimAUCTIONATOR.name)
    local _, recrystallizeLoaded = IsAddOnLoaded(CraftSimRECRYSTALLIZE.name)
    local _, exchangeLoaded = IsAddOnLoaded(CraftSimEXCHANGE.name)
    if tsmLoaded then
        CraftSim.PRICE_API = CraftSimTSM
    elseif auctionatorLoaded then
        CraftSim.PRICE_API = CraftSimAUCTIONATOR
    elseif recrystallizeLoaded then
        CraftSimPriceAPI = CraftSimRECRYSTALLIZE
    elseif exchangeLoaded then
        CraftSimPriceAPI = CraftSimEXCHANGE
    else
        print("CraftSim: No supported price source found")
        print("Supported addons are: ")
        for _, name in pairs(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS) do
            print(name)
        end
    end
end

---@param idOrLink? number | string
---@return number? auctionAmount
function CraftSimTSM:GetAuctionAmount(idOrLink)
    if not idOrLink then
        return
    end
    if type(idOrLink) == 'number' then
        return CraftSimTSM:GetAuctionAmountByItemID(idOrLink)
    else
        return CraftSimTSM:GetAuctionAmountByItemLink(idOrLink)
    end
end

function CraftSimTSM:GetAuctionAmountByItemID(itemID)
	return TSM_API.GetAuctionQuantity("i:" .. itemID)
end

function CraftSimTSM:GetAuctionAmountByItemLink(itemLink)
	return TSM_API.GetAuctionQuantity(TSM_API.ToItemString(itemLink))
end

function CraftSimTSM:GetMinBuyoutByItemID(itemID, isReagent)
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
    
    return CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString, isReagent)
end

function CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString, isReagent)
    local minBuyoutPriceSourceKey = nil
    if isReagent then
        minBuyoutPriceSourceKey = CraftSimOptions.tsmPriceKeyMaterials
    else
        minBuyoutPriceSourceKey = CraftSimOptions.tsmPriceKeyItems

    end

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

function CraftSimTSM:GetMinBuyoutByItemLink(itemLink, isReagent)
    if itemLink == nil then
        return
    end
    local tsmItemString = TSM_API.ToItemString(itemLink)
    -- NOTE: the bonusID 3524 which is often used for df crafted gear is not included in the tsm bonus id map yet
    return CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString, isReagent)
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemID(itemID)
    local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(CraftSimAddonName, itemID)
    if vendorPrice then
        return vendorPrice
    else
        return Auctionator.API.v1.GetAuctionPriceByItemID(CraftSimAddonName , itemID)
    end
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemLink(itemLink)
    local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(CraftSimAddonName, itemLink)
    if vendorPrice then
        return vendorPrice
    else
        return Auctionator.API.v1.GetAuctionPriceByItemLink(CraftSimAddonName , itemLink)
    end
end

function CraftSimRECRYSTALLIZE:GetMinBuyoutByItemID(itemID)
    local output = RECrystallize_PriceCheckItemID(itemID)
    return output and output or 0
end

function CraftSimRECRYSTALLIZE:GetMinBuyoutByItemLink(itemLink)
    local output = RECrystallize_PriceCheck(itemLink)
    return output and output or 0
end

local OEresult = {}

function CraftSimEXCHANGE:GetMinBuyoutByItemID(itemID)
    local output = 0
    OEMarketInfo(itemID, OEresult)
    if OEresult["market"] and OEresult["market"] > 0 then
        output = OEresult["market"]
    elseif OEresult["region"] and OEresult["region"] > 0 then
        output = OEresult["region"]
    end
    return output
end

function CraftSimEXCHANGE:GetMinBuyoutByItemLink(itemLink)
    local output = 0
    OEMarketInfo(itemLink, OEresult)
    if OEresult["market"] and OEresult["market"] > 0 then
        output = OEresult["market"]
    elseif OEresult["region"] and OEresult["region"] > 0 then
        output = OEresult["region"]
    end
    return output
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
