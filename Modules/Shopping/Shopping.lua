---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local Auctionator = Auctionator

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local f = GUTIL:GetFormatter()

local Logger = CraftSim.DEBUG:RegisterLogger("Shopping")

---@class CraftSim.SHOPPING : CraftSim.Module
CraftSim.SHOPPING = CraftSim.SHOPPING or GUTIL:CreateRegistreeForEvents({
    "COMMODITY_PURCHASE_SUCCEEDED",
    "COMMODITY_PURCHASE_FAILED",
    "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
})

GUTIL:RegisterCustomEvents(CraftSim.SHOPPING, {
    "CRAFTSIM_CRAFTQUEUE_QUEUE_PROCESS_FINISHED",
    "CRAFTSIM_MODULE_OPENED",
})

local L = CraftSim.LOCAL:GetLocalizer()

CraftSim.MODULES:RegisterModule("MODULE_SHOPPING", CraftSim.SHOPPING, {
    label = L("CONTROL_PANEL_MODULES_SHOPPING_LIST_LABEL"),
    tooltip = L("CONTROL_PANEL_MODULES_SHOPPING_LIST_TOOLTIP"),
})

---@class CraftSim.SHOPPING.UI : CraftSim.Module.UI
CraftSim.SHOPPING.UI = {}

function CraftSim.SHOPPING.UI:Init()
    -- frame is created lazily on first open; nothing to do here
end

function CraftSim.SHOPPING.UI:Update()
    if CraftSim.SHOPPING.shoppingListViewFrame and CraftSim.SHOPPING.shoppingListViewFrame:IsVisible() then
        CraftSim.SHOPPING:UpdateShoppingListViewDisplay()
    end
end

function CraftSim.SHOPPING.UI:VisibleByContext()
    return CraftSim.DB.OPTIONS:IsModuleEnabled("MODULE_SHOPPING")
end

---@param moduleID CraftSim.ModuleID
function CraftSim.SHOPPING:CRAFTSIM_MODULE_OPENED(moduleID)
    if moduleID ~= "MODULE_SHOPPING" then
        return
    end
    self:ShowShoppingListView()
end

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
            and (terms.categoryKey or "") == (searchTerm.categoryKey or "")
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
    if shoppingSearch.categoryKey then
        searchTerm.categoryKey = shoppingSearch.categoryKey
    end

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

---@class CraftSim.Shopping.ShoppingListEntry
---@field itemID number
---@field itemName string
---@field qualityID number
---@field quantity number

---@param includeSoulboundWithoutAlternative boolean? when true, keep soulbound items that have no auctionable mapping
---@return CraftSim.Shopping.ShoppingListEntry[]
function CraftSim.SHOPPING:GetMissingReagentsFromCraftQueue(includeSoulboundWithoutAlternative)
    local craftQueue = CraftSim.CRAFTQ and CraftSim.CRAFTQ.craftQueue
    if not craftQueue then
        return {}
    end

    ---@type table<number, { itemName: string, qualityID: number?, quantity: number }>
    local reagentMap = {}

    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        local recipeData = craftQueueItem.recipeData
        local reagentData = recipeData and recipeData.reagentData
        if reagentData then
            local requiredReagents = reagentData.requiredReagents
            for _, reagent in pairs(requiredReagents) do
                if not reagent:IsOrderReagentIn(recipeData) then
                    if reagent.hasQuality then
                        for qualityID, reagentItem in pairs(reagent.items) do
                            local itemID = reagentItem.item:GetItemID()
                            local isSelfCrafted = recipeData:IsSelfCraftedReagent(itemID)
                            if not isSelfCrafted then
                                reagentMap[itemID] = reagentMap[itemID] or {
                                    itemName = reagentItem.item:GetItemName(),
                                    qualityID = nil,
                                    quantity = 0,
                                }
                                reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                                    (reagentItem.quantity * craftQueueItem.amount)
                                reagentMap[itemID].qualityID = qualityID
                            end
                        end
                    else
                        local reagentItem = reagent.items[1]
                        local itemID = reagentItem.item:GetItemID()
                        local isSelfCrafted = recipeData:IsSelfCraftedReagent(itemID)
                        if not isSelfCrafted then
                            reagentMap[itemID] = reagentMap[itemID] or {
                                itemName = reagentItem.item:GetItemName(),
                                qualityID = nil,
                                quantity = 0,
                            }
                            reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                                (reagentItem.quantity * craftQueueItem.amount)
                        end
                    end
                end
            end

            local activeReagents = reagentData:GetActiveOptionalReagents()
            local quantityMap = {}

            if recipeData:HasRequiredSelectableReagent() then
                local slot = reagentData.requiredSelectableReagentSlot
                if slot and slot:IsAllocated() and not slot:IsCurrency() and not slot:IsOrderReagentIn(recipeData) then
                    tinsert(activeReagents, slot.activeReagent)
                    quantityMap[slot.activeReagent.item:GetItemID()] = slot.maxQuantity or 1
                end
            end

            for _, optionalReagent in pairs(activeReagents) do
                if not optionalReagent:IsCurrency() then
                    local itemID = optionalReagent.item:GetItemID()
                    local isSelfCrafted = recipeData:IsSelfCraftedReagent(itemID)
                    local isOrderReagent = optionalReagent:IsOrderReagentIn(recipeData)
                    local qualityID = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID)

                    if not isOrderReagent and not isSelfCrafted and not GUTIL:isItemSoulbound(itemID) then
                        local allocatedQuantity = quantityMap[itemID] or 1
                        reagentMap[itemID] = reagentMap[itemID] or {
                            itemName = optionalReagent.item:GetItemName(),
                            qualityID = qualityID,
                            quantity = 0,
                        }
                        reagentMap[itemID].quantity = reagentMap[itemID].quantity +
                            allocatedQuantity * craftQueueItem.amount
                    end
                end
            end
        end
    end

    local crafterUIDs = GUTIL:Map(craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)
    crafterUIDs = GUTIL:ToSet(crafterUIDs)

    ---@type CraftSim.Shopping.ShoppingListEntry[]
    local entries = {}
    for itemID, info in pairs(reagentMap) do
        local purchaseItemID = getNonSoulboundAlternativeItemID(itemID)
        if not purchaseItemID and includeSoulboundWithoutAlternative then
            purchaseItemID = itemID
        end
        if purchaseItemID then
            local totalItemCount = GUTIL:Fold(crafterUIDs, 0, function(itemCount, crafterUID)
                local itemCountForCrafter =
                    CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, purchaseItemID)
                return itemCount + (itemCountForCrafter or 0)
            end)

            local missingQuantity = math.max(info.quantity - (tonumber(totalItemCount) or 0), 0)
            if missingQuantity > 0 then
                local itemName = info.itemName
                if purchaseItemID ~= itemID then
                    local altItem = Item:CreateFromItemID(purchaseItemID)
                    if altItem then
                        local name = altItem:GetItemName()
                        if name then
                            itemName = name
                        end
                    end
                end

                tinsert(entries, {
                    itemID = purchaseItemID,
                    itemName = itemName,
                    qualityID = info.qualityID,
                    quantity = missingQuantity,
                })
            end
        end
    end

    table.sort(entries, function(a, b)
        local nameA = a.itemName or ""
        local nameB = b.itemName or ""
        if nameA == nameB then
            return (a.qualityID or 0) > (b.qualityID or 0)
        end
        return nameA < nameB
    end)

    return entries
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
    -- Keep Auctionator behavior unchanged: do not include soulbound-only reagents.
    local entries = self:GetMissingReagentsFromCraftQueue(false)
    local searchStrings = GUTIL:Map(entries, function(e)
        if e.quantity <= 0 then
            return nil
        end
        local searchTerm = {
            searchString = e.itemName,
            tier = e.qualityID,
            quantity = e.quantity,
            isExact = true,
        }
        return Auctionator.API.v1.ConvertToSearchString(addonName, searchTerm)
    end)

    Auctionator.API.v1.CreateShoppingList(addonName, CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME, searchStrings)

    local listCreatedMessage = f.l("CraftSim: ") .. f.bb("Created Auctionator Shopping List")
    if #searchStrings > 0 then
        listCreatedMessage = listCreatedMessage .. " " .. f.g("(new items added)")
    else
        listCreatedMessage = listCreatedMessage .. " " .. f.r("(no items added)")
    end
    CraftSim.DEBUG:SystemPrint(listCreatedMessage)
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
    CraftSim.INVENTORY_SOURCE:ClearInventoryCache()
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
    if CraftSim.SHOPPING.shoppingListViewFrame and CraftSim.SHOPPING.shoppingListViewFrame:IsVisible() then
        CraftSim.SHOPPING:UpdateShoppingListViewDisplay()
    end
end

function CraftSim.SHOPPING:CreateShoppingListViewFrameIfNeeded()
    if self.shoppingListViewFrame then
        return
    end

    local onClose = CraftSim.MODULES:GetModuleFrameStateCallbacks(CraftSim.SHOPPING)

    local frame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = 520,
        sizeY = 280,
        title = "Shopping List",
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        raiseOnInteraction = true,
        closeOnEscape = true,
        onCloseCallback = onClose,
    })

    self.shoppingListViewFrame = frame
    -- wire into module system so VisibleByContext and frame toggling works
    CraftSim.SHOPPING.frame = frame

    local content = frame.content
    local listPad = 12
    local scrollbarWidth = 30
    local listSizeX = 520 - (listPad * 2) - scrollbarWidth
    local listSizeY = 280 - 72

    content.reagentList = GGUI.FrameList({
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = listPad,
        offsetY = -28,
        sizeX = listSizeX,
        sizeY = listSizeY,
        rowHeight = 18,
        showBorder = true,
        hideScrollbar = false,
        columnOptions = {
            {
                label = "Item",
                width = 360,
            },
            {
                label = "Qty",
                width = 70,
                justifyOptions = { type = "H", align = "RIGHT" },
            },
        },
        rowConstructor = function(columns)
            local itemCol = columns[1]
            local qtyCol = columns[2]

            itemCol.icon = GGUI.Icon({
                parent = itemCol,
                anchorParent = itemCol,
                anchorA = "LEFT",
                anchorB = "LEFT",
                offsetX = 2,
                sizeX = 16,
                sizeY = 16,
                qualityIconScale = 1,
            })
            itemCol.name = GGUI.Text({
                parent = itemCol,
                anchorParent = itemCol,
                anchorA = "LEFT",
                anchorB = "LEFT",
                offsetX = 40,
                scale = 0.85,
                wrap = true,
                fixedWidth = 315,
                justifyOptions = { type = "H", align = "LEFT" },
            })

            itemCol.quality = GGUI.Text({
                parent = itemCol,
                anchorParent = itemCol,
                anchorA = "LEFT",
                anchorB = "LEFT",
                offsetX = 20,
                scale = 0.9,
                justifyOptions = { type = "H", align = "LEFT" },
            })

            qtyCol.text = GGUI.Text({
                parent = qtyCol,
                anchorParent = qtyCol,
                anchorA = "RIGHT",
                anchorB = "RIGHT",
                scale = 0.9,
                justifyOptions = { type = "H", align = "RIGHT" },
            })

        end,
    })

    frame:Hide()
end

function CraftSim.SHOPPING:UpdateShoppingListViewDisplay()
    self:CreateShoppingListViewFrameIfNeeded()

    local frame = self.shoppingListViewFrame
    if not frame or not frame.content or not frame.content.reagentList then
        return
    end

    -- In the internal view, still show soulbound reagents even when no auctionable alternative exists.
    local entries = self:GetMissingReagentsFromCraftQueue(true)
    local list = frame.content.reagentList --[[@as GGUI.FrameList]]
    list:Remove()

    for _, entry in ipairs(entries) do
        list:Add(function(row, columns)
            local itemCol = columns[1]
            local qtyCol = columns[2]

            local itemMixin = Item:CreateFromItemID(entry.itemID)
            if itemMixin then
                itemCol.icon:SetItem(itemMixin)
            else
                itemCol.icon:SetItem(nil)
            end

            itemCol.name:SetText(entry.itemName)
            qtyCol.text:SetText(tostring(entry.quantity))

            if entry.qualityID and entry.qualityID > 0 then
                itemCol.quality:SetText(GUTIL:GetQualityIconStringSimplified(entry.qualityID, 14, 14) or "")
            else
                itemCol.quality:SetText("")
            end

            row.entry = entry
            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner = row.frame,
                text = f.white(itemMixin and itemMixin:GetItemLink() or entry.itemName),
            }
        end)
    end

    list:UpdateDisplay()
end

function CraftSim.SHOPPING:ShowShoppingListView()
    CraftSim.DB.OPTIONS:SetModuleEnabled("MODULE_SHOPPING", true)
    self:CreateShoppingListViewFrameIfNeeded()
    self:UpdateShoppingListViewDisplay()
    local frame = self.shoppingListViewFrame
    if frame then
        frame:Show()
        frame:Raise()
    end
end

function CraftSim.SHOPPING:HideShoppingListView()
    GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_CLOSED", "MODULE_SHOPPING")
end

function CraftSim.SHOPPING:ToggleShoppingListView()
    self:CreateShoppingListViewFrameIfNeeded()
    local frame = self.shoppingListViewFrame
    if frame and frame:IsVisible() then
        self:HideShoppingListView()
        return
    end
    self:ShowShoppingListView()
end
