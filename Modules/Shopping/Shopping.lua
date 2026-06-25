---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local Auctionator = Auctionator

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.LOCAL:GetLocalizer()

local Logger = CraftSim.DEBUG:RegisterLogger("Shopping")

---@class CraftSim.SHOPPING : CraftSim.Module
CraftSim.SHOPPING = CraftSim.SHOPPING or GUTIL:CreateRegistreeForEvents({
    "COMMODITY_PURCHASE_SUCCEEDED",
    "COMMODITY_PURCHASE_FAILED",
    "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
})

GUTIL:RegisterCustomEvents(CraftSim.SHOPPING, {
    "CRAFTSIM_CRAFTQUEUE_QUEUE_PROCESS_FINISHED",
})

CraftSim.MODULES:RegisterModule("MODULE_SHOPPING", CraftSim.SHOPPING)

---@enum CraftSim.SHOPPING.QB_STATUS
local QB_STATUS = {
    INIT = "INIT",
    SEARCH_READY = "SEARCH_READY",
    RESULT_LIST_READY = "RESULT_LIST_READY",
    BUY_READY = "BUY_READY",
    SEARCH_STARTED = "SEARCH_STARTED",
    CONFIRM_START = "CONFIRM_START",
    CONFIRM_AWAIT = "CONFIRM_AWAIT",
    CONFIRM_READY = "CONFIRM_READY",
    PURCHASE_AWAIT = "PURCHASE_AWAIT",
}

--- used to cache data for auctionator quick buy macro
CraftSim.SHOPPING.quickBuyCache = CraftSim.SHOPPING.quickBuyCache or {
    ---@type CraftSim.SHOPPING.QB_STATUS
    status = QB_STATUS.INIT,
    ---@type table<string, table> Auctionator Search String -> TableBuilder Row
    resultRows = {},
    ---@type table<string, boolean>
    boughtSearchStrings = {},
    ---@type string Auctionator SearchString
    currentSearchString = nil,
    purchasePending = false,
    ---@type ItemID?
    pendingItemID = nil,
    ---@type number?
    pendingItemCount = nil,
}

--- cache for OnConfirmCommoditiesPurchase -> COMMODITY_PURCHASE_SUCCEEDED flow
---@class CraftSim.Shopping.PurchasedItem
---@field item ItemMixin?
---@field quantity number
CraftSim.SHOPPING.purchasedItem = CraftSim.SHOPPING.purchasedItem or nil

local function getNonSoulboundAlternativeItemID(itemID)
    if GUTIL:isItemSoulbound(itemID) then
        local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID]
        if alternativeItemID and not GUTIL:isItemSoulbound(alternativeItemID) then
            Logger:LogVerbose("Found non soulbound alt item: {item}", alternativeItemID)
            return alternativeItemID
        else
            return nil
        end
    end
    return itemID
end

---@param listName string
function CraftSim.SHOPPING:DeleteAuctionatorShoppingList(listName)
    local listExists = Auctionator.Shopping.ListManager:GetIndexForName(listName)
    if listExists then
        Auctionator.Shopping.ListManager:Delete(listName)
    end
end

function CraftSim.SHOPPING:DeleteAllCraftSimShoppingLists()
    self:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME)
    local crafterUIDs = CraftSim.DB.CRAFTER:GetCrafterUIDs()
    for _, crafterUID in pairs(crafterUIDs) do
        self:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
            " " .. tostring(crafterUID))
    end
end

---@return boolean
function CraftSim.SHOPPING:IsAuctionatorAvailable()
    return C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])
        and Auctionator ~= nil
        and Auctionator.API ~= nil
        and Auctionator.API.v1 ~= nil
        and Auctionator.API.v1.ConvertToSearchString ~= nil
end

---@param searchTerm table
---@param listName string?
---@return boolean
function CraftSim.SHOPPING:AddSearchTermToShoppingList(searchTerm, listName)
    if not self:IsAuctionatorAvailable() then
        return false
    end

    listName = listName or CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME
    local api = Auctionator.API.v1
    local searchString = api.ConvertToSearchString(addonName, searchTerm)

    if api.AddToShoppingList then
        local ok = pcall(api.AddToShoppingList, addonName, listName, { searchTerm })
        if ok then
            return true
        end
        ok = pcall(api.AddToShoppingList, listName, { searchTerm })
        if ok then
            return true
        end
    end

    local listManager = Auctionator.Shopping and Auctionator.Shopping.ListManager
    local listExists = listManager and listManager:GetIndexForName(listName)
    if not listExists then
        local ok = pcall(api.CreateShoppingList, addonName, listName, { searchString })
        return ok == true
    end

    local success, items = pcall(api.GetShoppingListItems, addonName, listName)
    if not success or not items then
        return false
    end

    local oldSearchString = GUTIL:Find(items, function(existingSearchString)
        local terms = api.ConvertFromSearchString(addonName, existingSearchString)
        return terms
            and terms.searchString == searchTerm.searchString
            and (terms.tier or 0) == (searchTerm.tier or 0)
    end)

    if oldSearchString then
        local oldTerms = api.ConvertFromSearchString(addonName, oldSearchString)
        searchTerm.quantity = (oldTerms.quantity or 1) + (searchTerm.quantity or 1)
        local newSearchString = api.ConvertToSearchString(addonName, searchTerm)
        local ok = pcall(api.AlterShoppingListItem, addonName, listName, oldSearchString, newSearchString)
        return ok == true
    end

    local mergedSearchStrings = GUTIL:Map(items, function(existingSearchString)
        return existingSearchString
    end)
    tinsert(mergedSearchStrings, searchString)
    local ok = pcall(api.CreateShoppingList, addonName, listName, mergedSearchStrings)
    return ok == true
end

---@param recipeID number
---@param recipeName string?
---@param sourceText string?
---@return boolean
function CraftSim.SHOPPING:AddRecipeToShoppingList(recipeID, recipeName, sourceText)
    if not CraftSim.RECIPE_ACQUISITION then
        return false
    end

    local shoppingSearch = CraftSim.RECIPE_ACQUISITION:GetRecipeShoppingSearch(recipeID, recipeName, sourceText)
    if not shoppingSearch then
        return false
    end

    ---@type table
    local searchTerm = {
        searchString = shoppingSearch.itemName,
        isExact = false,
        quantity = 1,
    }

    if not self:AddSearchTermToShoppingList(searchTerm) then
        return false
    end

    CraftSim.DEBUG:SystemPrint(
        f.l("CraftSim: ")
            .. string.format(L("RECIPE_ACQUISITION_ADDED_TO_SHOPPING_LIST"), f.bb(shoppingSearch.itemName)))

    if self.shoppingListViewFrame and self.shoppingListViewFrame:IsVisible() then
        self:UpdateShoppingListViewDisplay()
    end

    return true
end

function CraftSim.SHOPPING:CreateShoppingListFromCraftQueue()
    local craftQueue = CraftSim.CRAFTQ and CraftSim.CRAFTQ.craftQueue
    if not craftQueue then
        return
    end

    Logger:LogDebug("CraftSim.SHOPPING:CreateShoppingListFromCraftQueue")

    self:DeleteAllCraftSimShoppingLists()
    self:ResetQuickBuyCache()

    CraftSim.DEBUG:StartProfiling("CreateAuctionatorShopping")
    local reagentMap = {}
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if not reagent:IsOrderReagentIn(craftQueueItem.recipeData) then
                if reagent.hasQuality then
                    for qualityID, reagentItem in pairs(reagent.items) do
                        local itemID = reagentItem.item:GetItemID()
                        Logger:LogVerbose("Shopping List Creation: Item: {item}", reagentItem.item:GetItemLink())
                        local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                        if not isSelfCrafted then
                            reagentMap[itemID] = reagentMap[itemID] or {
                                itemName = reagentItem.item:GetItemName(),
                                qualityID = nil,
                                quantity = 0
                            }
                            reagentMap[itemID].quantity = reagentMap[itemID]
                                .quantity + (reagentItem.quantity * craftQueueItem.amount)
                            reagentMap[itemID].qualityID = qualityID
                        end
                    end
                else
                    local reagentItem = reagent.items[1]
                    local itemID = reagentItem.item:GetItemID()
                    local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                    if not isSelfCrafted then
                        reagentMap[itemID] = reagentMap[itemID] or {
                            itemName = reagentItem.item:GetItemName(),
                            qualityID = nil,
                            quantity = 0
                        }
                        reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                            (reagentItem.quantity * craftQueueItem.amount)
                        Logger:LogVerbose("reagentMap Build: Item: {item}", reagentItem.item:GetItemLink() or "")
                        Logger:LogVerbose("quantity: {quantity}", reagentMap[itemID].quantity)
                    end
                end
            end
        end
        local activeReagents = craftQueueItem.recipeData.reagentData:GetActiveOptionalReagents()
        local quantityMap = {}
        if craftQueueItem.recipeData:HasRequiredSelectableReagent() then
            local slot = craftQueueItem.recipeData.reagentData.requiredSelectableReagentSlot
            if slot and slot:IsAllocated() and not slot:IsCurrency() and not slot:IsOrderReagentIn(craftQueueItem.recipeData) then
                tinsert(activeReagents, slot.activeReagent)
                quantityMap[slot.activeReagent.item:GetItemID()] = slot.maxQuantity or 1
            end
        end
        for _, optionalReagent in pairs(activeReagents) do
            if not optionalReagent:IsCurrency() then
                local itemID = optionalReagent.item:GetItemID()
                local isSelfCrafted = craftQueueItem.recipeData:IsSelfCraftedReagent(itemID)
                local isOrderReagent = optionalReagent:IsOrderReagentIn(craftQueueItem.recipeData)
                local qualityID = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID)
                if not isOrderReagent and not isSelfCrafted and not GUTIL:isItemSoulbound(itemID) then
                    local allocatedQuantity = quantityMap[itemID] or 1
                    reagentMap[itemID] = reagentMap[itemID] or {
                        itemName = optionalReagent.item:GetItemName(),
                        qualityID = qualityID,
                        quantity = 0
                    }
                    reagentMap[itemID].quantity = reagentMap[itemID]
                        .quantity + allocatedQuantity * craftQueueItem.amount
                end
            end
        end
    end

    local crafterUIDs = GUTIL:Map(craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)

    crafterUIDs = GUTIL:ToSet(crafterUIDs)

    local searchStrings = GUTIL:Map(reagentMap, function(info, itemID)
        itemID = getNonSoulboundAlternativeItemID(itemID)
        if not itemID then
            return nil
        end
        local totalItemCount = GUTIL:Fold(crafterUIDs, 0, function(itemCount, crafterUID)
            local itemCountForCrafter = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
            return itemCount + itemCountForCrafter
        end)

        local searchTerm = {
            searchString = info.itemName,
            tier = info.qualityID,
            quantity = math.max(info.quantity - (tonumber(totalItemCount) or 0), 0),
            isExact = true,
            debug = tostring(info.quantity) .. " - " .. tostring((tonumber(totalItemCount) or 0)),
        }
        if searchTerm.quantity == 0 then
            return nil
        end
        local searchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerm)
        return searchString
    end)

    Auctionator.API.v1.CreateShoppingList(addonName, CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME, searchStrings)

    CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. f.bb("Created Auctionator Shopping List"))

    CraftSim.DEBUG:StopProfiling("CreateAuctionatorShopping")
end

---@param itemID number
---@param boughtQuantity number
function CraftSim.SHOPPING:OnConfirmCommoditiesPurchase(itemID, boughtQuantity)
    if not C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2]) then
        return
    end

    self.purchasedItem = {
        item = Item:CreateFromItemID(itemID),
        quantity = boughtQuantity
    }
end

function CraftSim.SHOPPING:COMMODITY_PURCHASE_SUCCEEDED()
    if self.quickBuyCache.purchasePending and self.purchasedItem and self.purchasedItem.item then
        self.purchasedItem.item:ContinueOnItemLoad(function()
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") ..
                f.g("Quick Buy: ") ..
                "Purchased " .. self.quickBuyCache.pendingItemCount .. "x " .. self.purchasedItem.item:GetItemLink())
        end)
    end
    self.quickBuyCache.purchasePending = false
    self.quickBuyCache.pendingItemCount = nil
    self.quickBuyCache.pendingItemID = nil

    if not C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2]) then
        return
    end

    if not Auctionator.API.v1.ConvertToSearchString then
        return
    end
    if self.purchasedItem then
        GUTIL:ContinueOnAllItemsLoaded({ self.purchasedItem.item }, function()
            local purchasedItem = self.purchasedItem
            Logger:LogDebug("commodity purchase successfull")
            Logger:LogDebug("item: {item}", purchasedItem.item:GetItemLink())
            Logger:LogDebug("quantity: {quantity}", purchasedItem.quantity)
            local success
            local result
            local shoppingListName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME
            success, result = pcall(Auctionator.API.v1.GetShoppingListItems, addonName,
                shoppingListName)
            if not success then
                shoppingListName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
                    " " .. CraftSim.UTIL:GetPlayerCrafterUID()
                success, result = pcall(Auctionator.API.v1.GetShoppingListItems, addonName,
                    shoppingListName)

                if not success then
                    return
                end
            end

            local itemQualityID = GUTIL:GetQualityIDFromLink(purchasedItem.item:GetItemLink())
            local searchTerms = {
                searchString = purchasedItem.item:GetItemName(),
                isExact = true,
                tier = itemQualityID,
            }
            local searchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerms)
            local oldSearchString = GUTIL:Find(result, function(r)
                return GUTIL:StringStartsWith(r, searchString)
            end)
            if not oldSearchString then
                Logger:LogWarning("item could not be found in shopping list")
                return
            end

            local oldTerms = Auctionator.API.v1.ConvertFromSearchString(addonName, oldSearchString)

            local newQuantity = oldTerms.quantity - purchasedItem.quantity

            if newQuantity > 0 then
                searchTerms.quantity = newQuantity
                local newSearchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerms)
                Auctionator.API.v1.AlterShoppingListItem(addonName, shoppingListName,
                    oldSearchString, newSearchString)
            else
                Auctionator.API.v1.DeleteShoppingListItem(addonName, shoppingListName,
                    oldSearchString)
            end

            self.purchasedItem = nil
        end)
    end
end

local LibAHTab

function CraftSim.SHOPPING:AuctionatorQuickBuy()
    Logger:LogDebug("AuctionatorQuickBuy")

    local qbCache = self.quickBuyCache

    if not AuctionHouseFrame:IsVisible() then
        return
    end

    if not AuctionatorShoppingFrame then
        return
    end

    if not AuctionatorShoppingFrame:IsVisible() then
        LibAHTab = LibAHTab or LibStub("LibAHTab-1-0")
        if LibAHTab:DoesIDExist("AuctionatorTabs_Shopping") then
            LibAHTab:SetSelected("AuctionatorTabs_Shopping")
        end
        return
    end

    if not AuctionatorShoppingFrame then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. f.r("Quick Buy only available for Auctionator Shopping Lists"))
        return
    end

    local listManager = Auctionator.Shopping.ListManager
    local listName = "CraftSim CraftQueue"

    local listsContainer = AuctionatorShoppingFrame.ListsContainer
    local resultsList = AuctionatorShoppingFrame.ResultsListing

    local function status(value)
        return qbCache.status == value
    end

    local function set(value)
        Logger:LogDebug("- Setting Status: {status}", value)
        qbCache.status = value
    end

    local function getResultSearchString(itemID)
        local item = Item:CreateFromItemID(itemID)
        local itemLink = item:GetItemLink()
        local qualityID = GUTIL:GetQualityIDFromLink(itemLink)
        local searchTerm = {
            searchString = item:GetItemName(),
            isExact = true,
            tier = qualityID
        }
        return Auctionator.API.v1.ConvertToSearchString("CraftSim", searchTerm)
    end

    local function mapSearchResultRows(itemSearchStrings)
        wipe(qbCache.resultRows)
        local rows = {}
        for i = 1, resultsList.dataProvider:GetCount() do
            table.insert(rows, resultsList.dataProvider:GetEntryAt(i))
        end
        for _, searchString in ipairs(itemSearchStrings) do
            local row = GUTIL:Find(rows, function(row)
                local itemID = row.itemKey.itemID
                return GUTIL:StringStartsWith(searchString, getResultSearchString(itemID))
            end)

            if row then
                qbCache.resultRows[searchString] = row
            end
        end
    end

    local function matchSearchResultRows(itemSearchStrings)
        return GUTIL:Every(itemSearchStrings, function(searchString)
            return qbCache.resultRows[searchString] ~= nil
        end)
    end

    local listIndex = listManager:GetIndexForName(listName)

    if not listIndex then
        set(QB_STATUS.INIT)
        return
    end

    local list = listManager:GetByIndex(listIndex)
    local allItemSearchStrings = list:GetAllItems()
    local numItems = allItemSearchStrings

    if numItems == 0 then
        set(QB_STATUS.INIT)
        Logger:LogDebug("- No Items Left")
        return
    end

    local buyShoppingListSearchString = GUTIL:Find(list.data.items, function(searchString)
        return not qbCache.boughtSearchStrings[searchString]
    end)

    Logger:LogDebug("- STATUS: " .. tostring(qbCache.status))

    if not buyShoppingListSearchString then
        Logger:LogDebug("- All bought")
        self:ResetQuickBuyCache()
        return
    end

    if status(QB_STATUS.INIT) then
        set(QB_STATUS.SEARCH_READY)
        if not listsContainer:IsListExpanded(list) then
            listsContainer:ExpandList(list)
        end
    end

    if status(QB_STATUS.SEARCH_READY) then
        wipe(qbCache.resultRows)
        AuctionatorShoppingFrame:DoSearch(allItemSearchStrings)
        set(QB_STATUS.SEARCH_STARTED)
        return
    end

    if status(QB_STATUS.SEARCH_STARTED) then
        mapSearchResultRows(allItemSearchStrings)

        if matchSearchResultRows(allItemSearchStrings) then
            set(QB_STATUS.RESULT_LIST_READY)
        end
    end

    if buyShoppingListSearchString and status(QB_STATUS.RESULT_LIST_READY) then
        local resultRow = qbCache.resultRows[buyShoppingListSearchString]

        if not resultRow then
            Logger:LogError("Result Row not found in result list: {searchString}", buyShoppingListSearchString)
            return
        end

        local itemID = resultRow.itemKey.itemID
        local quantity = resultRow.purchaseQuantity

        local buyoutPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, true)
        local totalPrice = buyoutPrice * quantity
        local playerMoney = GetMoney()

        if playerMoney < totalPrice then
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") .. f.bb("QuickBuy:") .. " Not enough gold")
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") ..
                f.bb("QuickBuy:") .. " Missing: " .. CraftSim.GUTIL:FormatMoney(totalPrice - playerMoney))
            return
        end

        qbCache.pendingItemID = itemID
        qbCache.pendingItemCount = quantity

        qbCache.currentSearchString = buyShoppingListSearchString
        qbCache.purchasePending = true
        set(QB_STATUS.PURCHASE_AWAIT)

        C_AuctionHouse.StartCommoditiesPurchase(qbCache.pendingItemID, qbCache.pendingItemCount)
        return
    end

    if status(QB_STATUS.PURCHASE_AWAIT) and not qbCache.purchasePending then
        qbCache.boughtSearchStrings[qbCache.currentSearchString] = true
        set(QB_STATUS.RESULT_LIST_READY)
        self:AuctionatorQuickBuy()
    end
end

function CraftSim.SHOPPING:AUCTION_HOUSE_THROTTLED_SYSTEM_READY()
    local qbCache = self.quickBuyCache
    if qbCache.pendingItemCount and qbCache.pendingItemID then
        C_AuctionHouse.ConfirmCommoditiesPurchase(qbCache.pendingItemID, qbCache.pendingItemCount)
    end
end

function CraftSim.SHOPPING:COMMODITY_PURCHASE_FAILED()
    self:ResetQuickBuyCache()
end

function CraftSim.SHOPPING:ResetQuickBuyCache()
    local qbCache = self.quickBuyCache
    qbCache.status = QB_STATUS.INIT
    qbCache.currentSearchString = nil
    qbCache.purchasePending = false
    qbCache.pendingItemCount = nil
    qbCache.pendingItemID = nil
    wipe(qbCache.boughtSearchStrings)
    wipe(qbCache.resultRows)
end

local hooksInitialized = false

function CraftSim.SHOPPING:Init()
    if hooksInitialized then
        return
    end
    hooksInitialized = true

    hooksecurefunc(C_AuctionHouse, "ConfirmCommoditiesPurchase", function(itemID, quantity)
        CraftSim.SHOPPING:OnConfirmCommoditiesPurchase(itemID, quantity)
    end)
end

function CraftSim.SHOPPING:CRAFTSIM_CRAFTQUEUE_QUEUE_PROCESS_FINISHED()
    -- create shopping list
    CraftSim.SHOPPING:CreateShoppingListFromCraftQueue()
end
