---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.PRICE_API
CraftSim.PRICE_API = {}
CraftSim.PRICE_APIS = {}

CraftSimTSM = { name = "TradeSkillMaster" }
CraftSimAUCTIONATOR = { name = "Auctionator" }
CraftSimRECRYSTALLIZE = { name = "RECrystallize" }
CraftSimEXCHANGE = { name = "OribosExchange" }
CraftSimNO_PRICE_API = { name = "None" }

CraftSim.PRICE_APIS.available = true

local systemPrint = print
local print = CraftSim.DEBUG:RegisterDebugID("Data.PriceAPI")

function CraftSim.PRICE_API:InitPriceSource()
    local loadedSources = CraftSim.PRICE_APIS:GetAvailablePriceSourceAddons()

    if #loadedSources == 0 then
        systemPrint(CraftSim.GUTIL:ColorizeText("CraftSim:", CraftSim.GUTIL.COLORS.BRIGHT_BLUE) ..
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM))
        CraftSim.PRICE_APIS.available = false
        if not CraftSim.DB.OPTIONS:Get("PRICE_SOURCE_REMINDER_DISABLED") then
            CraftSim.GGUI:ShowPopup({
                sizeX = 400,
                sizeY = 250,
                title = CraftSim.GUTIL:ColorizeText(
                    CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE), CraftSim.GUTIL.COLORS.RED),
                text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING) ..
                    table.concat(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS, "\n"),
                acceptButtonLabel = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT),
                declineButtonLabel = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS),
                onDecline = function()
                    StaticPopup_Show("CRAFT_SIM_ACCEPT_NO_PRICESOURCE_WARNING")
                end
            })
        end
        CraftSim.PRICE_API = CraftSimNO_PRICE_API
        return
    end

    local savedSource = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.PRICE_SOURCE)

    if tContains(loadedSources, savedSource) then
        CraftSim.PRICE_APIS:SwitchAPIByAddonName(savedSource)
    else
        CraftSim.PRICE_APIS:SwitchAPIByAddonName(loadedSources[1])
        CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.PRICE_SOURCE, loadedSources[1])
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
        if select(2, C_AddOns.IsAddOnLoaded(addonName)) then
            table.insert(loadedAddons, addonName)
        end
    end
    return loadedAddons
end

function CraftSim.PRICE_APIS:IsPriceApiAddonLoaded()
    for _, name in pairs(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS) do
        if select(2, C_AddOns.IsAddOnLoaded(name)) then
            return true
        end
    end
    return false
end

function CraftSim.PRICE_APIS:IsAddonPriceApiAddon(addon_name)
    for _, name in pairs(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS) do
        if addon_name == name then
            return true
        end
    end
    return false
end

function CraftSim.PRICE_APIS:InitAvailablePriceAPI()
    local _, tsmLoaded = C_AddOns.IsAddOnLoaded(CraftSimTSM.name)
    local _, auctionatorLoaded = C_AddOns.IsAddOnLoaded(CraftSimAUCTIONATOR.name)
    local _, recrystallizeLoaded = C_AddOns.IsAddOnLoaded(CraftSimRECRYSTALLIZE.name)
    local _, exchangeLoaded = C_AddOns.IsAddOnLoaded(CraftSimEXCHANGE.name)
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

---@param itemID string
---@param isReagent boolean?
function CraftSimTSM:GetMinBuyoutByItemID(itemID, isReagent)
    if itemID == nil then
        return
    end
    local _, itemLink = C_Item.GetItemInfo(itemID)
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
        minBuyoutPriceSourceKey = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_REAGENTS)
    else
        minBuyoutPriceSourceKey = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_ITEMS)
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

---@param itemLink string
---@param isReagent boolean?
function CraftSimTSM:GetMinBuyoutByItemLink(itemLink, isReagent)
    if itemLink == nil then
        return
    end
    local tsmItemString = TSM_API.ToItemString(itemLink)
    -- NOTE: the bonusID 3524 which is often used for df crafted gear is not included in the tsm bonus id map yet
    return CraftSimTSM:GetMinBuyoutByTSMItemString(tsmItemString, isReagent)
end

function CraftSimTSM:GetItemSaleRate(itemLink)
    local key = "dbregionsalerate*1000" -- because 0.x will be rounded down to 0 and resolves to nil
    local tsmItemString = TSM_API.ToItemString(itemLink)
    local salerate, error = TSM_API.GetCustomPriceValue(key, tsmItemString)
    if error then
        print(f.r("CraftSimTSM:GetItemSaleRate Error: " .. tostring(error)), false, true)
        print("itemLink: " .. tostring(itemLink))
    end
    salerate = salerate or 0 -- nil safe
    return salerate / 1000
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemID(itemID)
    if not itemID then return 0 end
    local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemID(CraftSimAddonName, itemID)
    if vendorPrice then
        return vendorPrice
    else
        return Auctionator.API.v1.GetAuctionPriceByItemID(CraftSimAddonName, itemID)
    end
end

function CraftSimAUCTIONATOR:GetMinBuyoutByItemLink(itemLink)
    if not itemLink then return 0 end
    local vendorPrice = Auctionator.API.v1.GetVendorPriceByItemLink(CraftSimAddonName, itemLink)
    if vendorPrice then
        return vendorPrice
    else
        return Auctionator.API.v1.GetAuctionPriceByItemLink(CraftSimAddonName, itemLink)
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

---@param itemID ItemID
---@param isReagent boolean?
---@return number 0
function CraftSimNO_PRICE_API:GetMinBuyoutByItemID(itemID, isReagent)
    return 0
end

---@param itemLink string
---@param isReagent boolean?
---@return number 0
function CraftSimNO_PRICE_API:GetMinBuyoutByItemLink(itemLink, isReagent)
    return 0
end

-- ---------------------------------------------------------------------------
-- CraftSimTSM: Expected Deposit Cost
-- ---------------------------------------------------------------------------

--- Per-item deposit cache to avoid hammering TSM_API every frame.
---@type table<string, { value: number|nil, t: number }>
local depositCache = {}
local DEPOSIT_CACHE_TTL = 60 -- seconds

--- Returns true when TSM is loaded and its public API is available.
---@return boolean
function CraftSimTSM:IsAvailable()
    return TSM_API ~= nil
end

--- Retrieve the expected deposit cost for a recipe's result item.
--- Returns 0 when the feature is disabled, TSM is absent, or data is unavailable.
---@param recipeData CraftSim.RecipeData
---@return number depositCost  copper
function CraftSimTSM:GetExpectedDeposit(recipeData)
    if not self:IsAvailable() then return 0 end
    if not CraftSim.DB.OPTIONS:Get("TSM_DEPOSIT_ENABLED") then return 0 end

    -- No deposit cost for work orders
    if recipeData.orderData then return 0 end

    local resultData = recipeData.resultData
    if not resultData then return 0 end

    local item = resultData.expectedItem
    if not item then return 0 end

    -- Use GetItemID() instead of GetItemLink() — GetItemID() is always available
    -- synchronously, while GetItemLink() may return nil during RecipeScans when
    -- the ItemMixin has not finished loading yet.
    local itemID = item:GetItemID()
    if not itemID then return 0 end

    local tsmStr = "i:" .. itemID

    -- Check cache
    local entry = depositCache[tsmStr]
    local now = GetTime()
    if entry and (now - entry.t) < DEPOSIT_CACHE_TTL then
        return entry.value or 0
    end

    -- Query TSM
    local expression = CraftSim.DB.OPTIONS:Get("TSM_DEPOSIT_EXPRESSION")

    local deposit
    if expression and expression ~= "" then
        local ok, result = pcall(TSM_API.GetCustomPriceValue, expression, tsmStr)
        if not ok then
            print("GetExpectedDeposit: TSM_API.GetCustomPriceValue error for expression '",
                tostring(expression), "' and item '", tostring(tsmStr), "': ", tostring(result))
            deposit = nil
        else
            deposit = result
            if deposit == nil then
                print("GetExpectedDeposit: TSM expression returned nil for '",
                    tostring(expression), "' and item '", tostring(tsmStr), "'")
            end
        end
    else
        print("GetExpectedDeposit: No TSM deposit expression configured; using 0 for item '", tostring(tsmStr), "'")
        deposit = nil
    end
    depositCache[tsmStr] = { value = deposit, t = now }

    return deposit or 0
end

--- Invalidate the deposit cache (e.g. after changing the expression in settings).
function CraftSimTSM:ClearDepositCache()
    wipe(depositCache)
end

-- ---------------------------------------------------------------------------
-- CraftSimTSM: Smart Restock
-- ---------------------------------------------------------------------------

--- Compute the net quantity still needed for a recipe's result item.
--- target = value of the TSM restock expression for this item
--- owned  = total inventory across player, AH, and optionally alts + warbank
--- needed = max(0, target - owned)
---@param recipeData CraftSim.RecipeData
---@return number needed  items still required (≥ 0)
---@return number target  TSM restock target
---@return number owned   total owned across tracked sources
function CraftSimTSM:GetSmartRestockAmount(recipeData)
    if not self:IsAvailable() then return 0, 0, 0 end
    if not CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_ENABLED") then return 0, 0, 0 end

    local resultData = recipeData.resultData
    if not resultData or not resultData.expectedItem then return 0, 0, 0 end

    local itemLink = resultData.expectedItem:GetItemLink()
    if not itemLink then
        local itemID = resultData.expectedItem:GetItemID()
        if not itemID then return 0, 0, 0 end
        itemLink = "i:" .. itemID
    end

    local tsmStr = TSM_API.ToItemString(itemLink)
    if not tsmStr then return 0, 0, 0 end

    -- Target from TSM expression
    local restockExpr = CraftSim.DB.OPTIONS:Get("TSM_RESTOCK_KEY_ITEMS")
    local target = TSM_API.GetCustomPriceValue(restockExpr, tsmStr) or 0

    -- Owned inventory via TSM_API
    local numPlayer, numAlts, numAuctions, numAltAuctions = TSM_API.GetPlayerTotals(tsmStr)
    local owned = numPlayer + numAuctions

    if CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_ALTS") then
        owned = owned + numAlts + numAltAuctions
    end

    if CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_INCLUDE_WARBANK") then
        owned = owned + (TSM_API.GetWarbankQuantity and TSM_API.GetWarbankQuantity(tsmStr) or 0)
    end

    local needed = math.max(0, target - owned)
    return needed, target, owned
end
