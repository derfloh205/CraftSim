---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local Auctionator = Auctionator

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@enum CraftSim.CRAFTQ.QB_STATUS
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


---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT", "COMMODITY_PURCHASE_SUCCEEDED",
    "COMMODITY_PURCHASE_FAILED",
    "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
    "NEW_RECIPE_LEARNED", "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED", "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED",
    "BAG_UPDATE_DELAYED" })

---@type CraftSim.CraftQueue
CraftSim.CRAFTQ.craftQueue = nil

---@type CraftSim.RecipeData | nil
CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil

--- used to check if CraftSim was the one calling the C_TradeSkillUI.CraftRecipe api function
CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
-- if craftqueue craftlisted recipe was crafted via queue, need to remember for auto decrement and recognition
---@type number | nil
CraftSim.CRAFTQ.currentlyCraftedCraftListID = nil

--- used to cache player item counts during sorting and recalculation of craft queue
--- if canCraft and such functions are not called by craftqueue it should be nil
CraftSim.CRAFTQ.itemCountCache = nil

--- Saved in DB as CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID for "cheapest owned" mode
CraftSim.CRAFTQ.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED = "__CHEAPEST_OWNED__"

--- used to cache data for auctionator quick buy macro
CraftSim.CRAFTQ.quickBuyCache = {
    ---@type CraftSim.CRAFTQ.QB_STATUS
    status = QB_STATUS.INIT,
    ---@type table<string, table> Auctionator Search String -> TableBuilder Row
    resultRows = {},
    ---@type table<string, boolean>
    boughtSearchStrings = {},
    ---@type string Auctionator SearchString
    currentSearchString = nil,
    purchasePending = false, -- listen for commoditybought event / item bought event
    ---@type ItemID?
    pendingItemID = nil,
    ---@type number?
    pendingItemCount = nil,
}

---@param recipeData CraftSim.RecipeData
---@return ItemMixin?
function CraftSim.CRAFTQ:ApplyMidnightEnchantShatterSalvageSelection(recipeData)
    local slot = recipeData.reagentData.salvageReagentSlot
    local savedID = CraftSim.DB.OPTIONS:Get(CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID)
    if savedID == nil then
        return slot:SetCheapestItem()
    end
    if savedID == self.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED then
        return slot:SetCheapestOwnedItem()
    end
    local found = GUTIL:Find(slot.possibleItems, function(item)
        return item:GetItemID() == savedID
    end)
    if found then
        slot:SetItem(savedID)
        return slot.activeItem
    end
    CraftSim.DB.OPTIONS:Save(CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID, nil)
    return slot:SetCheapestItem()
end

---@param crafterData CraftSim.CrafterData
---@return CraftSim.RecipeData?
function CraftSim.CRAFTQ:PrepareMidnightEnchantShatterRecipeData(crafterData)
    local rd = CraftSim.RecipeData({
        recipeID = CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.MIDNIGHT_ENCHANTING_SHATTER,
        crafterData = crafterData,
    })
    if not rd or not rd.learned then
        return nil
    end
    self:ApplyMidnightEnchantShatterSalvageSelection(rd)
    rd:Update()
    return rd
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ:ShowMidnightEnchantShatterMoteMenu(recipeData)
    local optKey = CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_MIDNIGHT_SHATTER_MOTE_ITEMID
    MenuUtil.CreateContextMenu(UIParent, function(_, rootDescription)
        rootDescription:CreateRadio(L("CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC"), function()
            return CraftSim.DB.OPTIONS:Get(optKey) == nil
        end, function()
            CraftSim.DB.OPTIONS:Save(optKey, nil)
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end)
        rootDescription:CreateRadio(L("CRAFT_QUEUE_SHATTER_MOTE_AUTOMATIC_OWNED"), function()
            return CraftSim.DB.OPTIONS:Get(optKey) == CraftSim.CRAFTQ.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED
        end, function()
            CraftSim.DB.OPTIONS:Save(optKey, CraftSim.CRAFTQ.SHATTER_MOTE_SELECTION_CHEAPEST_OWNED)
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end)
        for _, item in ipairs(recipeData.reagentData.salvageReagentSlot.possibleItems) do
            local itemID = item:GetItemID()
            local itemName, itemLink = C_Item.GetItemInfo(itemID)
            local displayText = itemLink or itemName or ("#" .. tostring(itemID))
            local moteRadio = rootDescription:CreateRadio(displayText, function()
                return CraftSim.DB.OPTIONS:Get(optKey) == itemID
            end, function()
                CraftSim.DB.OPTIONS:Save(optKey, itemID)
                CraftSim.CRAFTQ.UI:UpdateDisplay()
            end)
            moteRadio:SetTooltip(function(tooltip, _)
                if tooltip.SetItemByID then
                    tooltip:SetItemByID(itemID)
                else
                    local _, il = C_Item.GetItemInfo(itemID)
                    if il and tooltip.SetHyperlink then
                        tooltip:SetHyperlink(il)
                    end
                end
            end)
        end
    end)
end

local printQB = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.AuctionatorQuickBuy")
local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue")
local printFC = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.FirstCrafts")


--- cache for OnConfirmCommoditiesPurchase -> COMMODITY_PURCHASE_SUCCEEDED flow
---@class CraftSim.CraftQueue.purchasedItem
---@field item ItemMixin?
---@field quantity number
CraftSim.CRAFTQ.purchasedItem = nil

---@param itemID number
---@param boughtQuantity number
function CraftSim.CRAFTQ:OnConfirmCommoditiesPurchase(itemID, boughtQuantity)
    if not select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
        return -- do not need if Auctionator not loaded
    end

    CraftSim.CRAFTQ.purchasedItem = {
        item = Item:CreateFromItemID(itemID),
        quantity = boughtQuantity
    }
end

function CraftSim.CRAFTQ:COMMODITY_PURCHASE_SUCCEEDED()
    -- reset purchase pending in qbCache
    printQB("- " .. f.l("COMMODITY_PURCHASE_SUCCEEDED"))
    if self.quickBuyCache.purchasePending then
        self.purchasedItem.item:ContinueOnItemLoad(function()
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") ..
                f.g("Quick Buy: ") ..
                "Purchased " .. self.quickBuyCache.pendingItemCount .. "x " .. self.purchasedItem.item:GetItemLink())
        end)
    end
    self.quickBuyCache.purchasePending = false
    self.quickBuyCache.pendingItemCount = nil
    self.quickBuyCache.pendingItemID = nil

    if not select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
        return -- do not need if Auctionator not loaded
    end

    if not Auctionator.API.v1.ConvertToSearchString then
        return -- if Auctionator is not up to date, do nothing
    end
    if CraftSim.CRAFTQ.purchasedItem then
        GUTIL:ContinueOnAllItemsLoaded({ CraftSim.CRAFTQ.purchasedItem.item }, function()
            local purchasedItem = CraftSim.CRAFTQ.purchasedItem
            print("commodity purchase successfull")
            print("item: " .. tostring(purchasedItem.item:GetItemLink()))
            print("quantity: " .. tostring(purchasedItem.quantity))
            local success
            local result
            local shoppingListName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME
            success, result = pcall(Auctionator.API.v1.GetShoppingListItems, addonName,
                shoppingListName)
            if not success then
                --print("Error calling GetShoppingListItems:\n" .. tostring(result))
                -- probably shopping list not existing
                -- try getting character specific shopping list
                shoppingListName = CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
                    " " .. CraftSim.UTIL:GetPlayerCrafterUID()
                success, result = pcall(Auctionator.API.v1.GetShoppingListItems, addonName,
                    shoppingListName)

                if not success then
                    -- no shopping list exists to deduct items from
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
                print("item could not be found in shopping list")
                return
            end

            local oldTerms = Auctionator.API.v1.ConvertFromSearchString(addonName, oldSearchString)

            -- modify original line by updated quantity
            local newQuantity = oldTerms.quantity - purchasedItem.quantity

            if newQuantity > 0 then
                searchTerms.quantity = newQuantity
                local newSearchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerms)
                -- adapt
                Auctionator.API.v1.AlterShoppingListItem(addonName, shoppingListName,
                    oldSearchString, newSearchString)
            else
                -- remove
                Auctionator.API.v1.DeleteShoppingListItem(addonName, shoppingListName,
                    oldSearchString)
            end

            CraftSim.CRAFTQ.purchasedItem = nil -- reset
        end)
    end
end

function CraftSim.CRAFTQ:CRAFTINGORDERS_CLAIMED_ORDER_UPDATED()
    self.UI:UpdateDisplay()
end

function CraftSim.CRAFTQ:CRAFTINGORDERS_CLAIMED_ORDER_REMOVED()
    self.UI:UpdateDisplay()
end

function CraftSim.CRAFTQ:QueueWorkOrders()
    local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.QueueWorkOrders")
    print("QueueWorkOrders", false, true)
    local profession = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not profession or not CraftSim.UTIL:ShouldEnableCraftQueueAddWorkOrdersButton() then
        return
    end
    local normalizedRealmName = GetNormalizedRealmName()
    local realmName = GetRealmName()
    local cleanedCrafterUIDs = GUTIL:Map(CraftSim.DB.CRAFTER:GetCrafterUIDs(), function(crafterUID)
        return select(1, gsub(crafterUID, "-" .. normalizedRealmName, ""))
    end)

    local maxPatronOrderCost = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST")
    local maxKPCost = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST")

    local workOrderTypes = {
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS") and Enum.CraftingOrderType.Npc,
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS") and Enum.CraftingOrderType.Guild,
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS") and Enum.CraftingOrderType.Personal,
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PUBLIC_ORDERS") and Enum.CraftingOrderType.Public,
    }
    local queueWorkOrdersButton = CraftSim.CRAFTQ.frame.content.queueTab.content
        .addWorkOrdersButton --[[@as GGUI.Button]]

    queueWorkOrdersButton:SetEnabled(false)

    GUTIL.FrameDistributor {
            iterationTable = workOrderTypes,
            iterationsPerFrame = 1,
            maxIterations = 10,
            finally = function()
                queueWorkOrdersButton:SetText(L("CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL"))
                queueWorkOrdersButton:SetEnabled(CraftSim.UTIL:ShouldEnableCraftQueueAddWorkOrdersButton())
            end,
            continue = function(frameDistributor, _, workOrderType, _, progress)
                local orderType = workOrderType --[[@as Enum.CraftingOrderType]]
                if not orderType then
                    frameDistributor:Continue()
                    return
                end
                local request = {
                    orderType = orderType,
                    searchFavorites = false,
                    initialNonPublicSearch = false,
                    primarySort = {
                        sortType = Enum.CraftingOrderSortType.ItemName,
                        reversed = false,
                    },
                    secondarySort = {
                        sortType = Enum.CraftingOrderSortType.MaxTip,
                        reversed = false,
                    },
                    forCrafter = true,
                    offset = 0,
                    profession = profession,
                    ---@diagnostic disable-next-line: redundant-parameter
                    callback = C_FunctionContainers.CreateCallback(function(result)
                        if result == Enum.CraftingOrderResult.Ok then
                            local orders = C_CraftingOrders.GetCrafterOrders()
                            local claimedOrder = C_CraftingOrders.GetClaimedOrder()
                            if claimedOrder then
                                tinsert(orders, claimedOrder)
                            end

                            local isPublicOrder = orderType == Enum.CraftingOrderType.Public
                            local publicOrderCandidates = {}

                            GUTIL.FrameDistributor {
                                iterationTable = orders,
                                iterationsPerFrame = 1,
                                maxIterations = 100,
                                finally = function()
                                    if isPublicOrder and #publicOrderCandidates > 0 then
                                        table.sort(publicOrderCandidates, function(a, b)
                                            return a.averageProfit > b.averageProfit
                                        end)
                                        local maxCount = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PUBLIC_ORDERS_MAX_COUNT")
                                        if maxCount == 0 then
                                            local claimInfo = C_CraftingOrders.GetOrderClaimInfo(profession)
                                            maxCount = (claimInfo and claimInfo.claimsRemaining) or 0
                                        end
                                        for i = 1, math.min(maxCount, #publicOrderCandidates) do
                                            CraftSim.CRAFTQ:AddRecipe { recipeData = publicOrderCandidates[i].recipeData }
                                        end
                                    end
                                    frameDistributor:Continue()
                                end,
                                continue = function(distributor, _, order, _, progress)
                                    order = order --[[@as CraftingOrderInfo]]
                                    local orderTypeText = CraftSim.UTIL:GetOrderTypeText(orderType)

                                    queueWorkOrdersButton:SetText(string.format("%s - %.0f%%", orderTypeText, progress))

                                    local isGuildOrder = order.orderType == Enum.CraftingOrderType.Guild
                                    local isPatronOrder = order.orderType == Enum.CraftingOrderType.Npc
                                    local knowledgePointsRewarded = 0

                                    if isGuildOrder then
                                        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY") then
                                            -- check for alts.. consider that alts on same realm do not have the realm name in customerName
                                            local cleanedCustomerName = gsub(order.customerName,
                                                "-" .. realmName, "")
                                            if not tContains(cleanedCrafterUIDs, cleanedCustomerName) then
                                                distributor:Continue()
                                                return
                                            end
                                        end
                                    end

                                    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(order.spellID)
                                    if recipeInfo and recipeInfo.learned then
                                        local recipeData = CraftSim.RecipeData({ recipeID = order.spellID })

                                        if not CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES") then
                                            if recipeData:HasRequiredSelectableReagent() then
                                                local slot = recipeData.reagentData.requiredSelectableReagentSlot
                                                if slot and slot:IsPossibleReagent(CraftSim.CONST.ITEM_IDS
                                                        .REQUIRED_SELECTABLE_ITEMS.SPARK_OF_OMENS) then
                                                    if slot:IsAllocated() and not slot:IsOrderReagentIn(recipeData) then
                                                        distributor:Continue()
                                                        return
                                                    end
                                                end
                                            end
                                        end

                                        recipeData:SetOrder(order)

                                        if recipeData.orderData and isPatronOrder then
                                            local rewardAllowed = GUTIL:Every(recipeData.orderData.npcOrderRewards,
                                                function(reward)
                                                    local acuityAllowed = CraftSim.DB.OPTIONS:Get(
                                                        "CRAFTQUEUE_PATRON_ORDERS_ACUITY")

                                                    if reward.currencyType then
                                                        local moxieContained = tContains(CraftSim.CONST.MOXIE_CURRENCY_IDS, reward.currencyType)
                                                        if not acuityAllowed and moxieContained then
                                                            return false
                                                        end

                                                        return true
                                                    end
                                                    local itemID = GUTIL:GetItemIDByLink(reward.itemLink)
                                                    local knowledgeAllowed = CraftSim.DB.OPTIONS:Get(
                                                        "CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS")
                                                    local runeAllowed = CraftSim.DB.OPTIONS:Get(
                                                        "CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE")

                                                    local knowledgeContained = false
                                                    if tContains(
                                                            CraftSim.CONST.PATRON_ORDERS_KNOWLEDGE_REWARD_ITEMS.WEEKLY,
                                                            itemID) then
                                                        knowledgePointsRewarded = 2
                                                        knowledgeContained = true
                                                    elseif tContains(
                                                            CraftSim.CONST.PATRON_ORDERS_KNOWLEDGE_REWARD_ITEMS.CATCHUP,
                                                            itemID) then
                                                        knowledgePointsRewarded = 1
                                                        knowledgeContained = true
                                                    end
                                                    local acuityContained = tContains(CraftSim.CONST.PATRON_ORDERS_ACUITY_REWARD_ITEMS, itemID)
                                                    local runeContained = tContains(CraftSim.CONST.PATRON_ORDERS_POWER_RUNE_REWARD_ITEMS, itemID)
                                                    if not acuityAllowed and acuityContained then
                                                        return false
                                                    end
                                                    if not runeAllowed and runeContained then
                                                        return false
                                                    end
                                                    if not knowledgeAllowed and knowledgeContained then
                                                        return false
                                                    end
                                                    return true
                                                end)
                                            if not rewardAllowed then
                                                distributor:Continue()
                                                return
                                            end
                                        end

                                        --- KP max cost is gold willing to pay per point (patron filter), not profit.
                                        --- Count recipe first-craft KP (1) with patron-listed KP rewards for that check.
                                        local totalKpForCostCheck = knowledgePointsRewarded
                                        if isPatronOrder and recipeInfo.firstCraft then
                                            totalKpForCostCheck = totalKpForCostCheck + 1
                                        end

                                        recipeData:SetCheapestQualityReagentsMax() -- considers patron reagents
                                        recipeData:Update()

                                        print("- Knowledge Points Rewarded: " .. tostring(knowledgePointsRewarded))


                                        local function withinKPCost(averageProfit)
                                            if isPatronOrder and totalKpForCostCheck > 0 and averageProfit < 0 then
                                                local kpCost = math.abs(averageProfit / totalKpForCostCheck)

                                                print("- kpCost: " .. GUTIL:FormatMoney(kpCost, true, nil, true))

                                                if kpCost >= maxKPCost then
                                                    return false
                                                end
                                                return true
                                            end
                                            return true
                                        end

                                        local function withinMaxPatronOrderCost(averageProfitCached)
                                            --- if max cost is 0 deactivate cost check
                                            if maxPatronOrderCost > 0 and isPatronOrder and averageProfitCached < 0 then
                                                print("- Crafting cost: "  .. GUTIL:FormatMoney(averageProfitCached, true, nil, true))
                                                if math.abs(averageProfitCached) >= maxPatronOrderCost then
                                                    return false
                                                end
                                                return true
                                            end
                                            return true
                                        end

                                        local function queueRecipe() 
                                            local isAlreadyQueued = CraftSim.CRAFTQ.craftQueue:FindRecipe(recipeData) ~= nil
                                            if isAlreadyQueued then
                                                print("Work order is already queued, skipping")
                                                distributor:Continue()
                                                return
                                            end

                                            local allowConcentration = CraftSim.DB.OPTIONS:Get(
                                                "CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION")
                                            local forceConcentration = CraftSim.DB.OPTIONS:Get(
                                                "CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION")
                                            local qualityWithoutConcentration = recipeData.resultData.expectedQuality
                                            local queueAble = false
                                            if recipeData.resultData.expectedQuality >= order.minQuality then
                                                queueAble = true
                                            end

                                            if (forceConcentration or allowConcentration) and order.minQuality and
                                                recipeData.resultData.expectedQualityConcentration == order.minQuality then
                                                recipeData.concentrating = true
                                                recipeData:Update()
                                                queueAble = true
                                                if qualityWithoutConcentration < order.minQuality then
                                                    local concentrationData = recipeData.concentrationData
                                                    local currentAmount = concentrationData and
                                                        concentrationData:GetCurrentAmount() or 0
                                                    if recipeData.concentrationCost <= 0 or
                                                        currentAmount < recipeData.concentrationCost then
                                                        queueAble = false
                                                        recipeData.concentrating = false
                                                        recipeData:Update()
                                                    end
                                                end
                                            end

                                            if queueAble then
                                                if isPublicOrder then
                                                    if order.isFulfillable == false then
                                                        distributor:Continue()
                                                        return
                                                    end
                                                    if not CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE") or recipeData.averageProfitCached > 0 then
                                                        tinsert(publicOrderCandidates, {
                                                            recipeData = recipeData,
                                                            averageProfit = recipeData.averageProfitCached,
                                                        })
                                                    end
                                                else
                                                    local isWithinKPCost = withinKPCost(recipeData.averageProfitCached)
                                                    local isWithinMaxCost = withinMaxPatronOrderCost(recipeData.averageProfitCached)
                                                    local isKPOrderWithinRange = totalKpForCostCheck > 0 and isWithinKPCost
                                                    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE") and
                                                    recipeData.averageProfitCached <= 0 and not isKPOrderWithinRange then
                                                        -- skip: not profitable and not a KP order within range
                                                    elseif isWithinKPCost and isWithinMaxCost then
                                                        CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData }
                                                    end
                                                end
                                            end

                                            distributor:Continue()
                                        end
                                        -- try to optimize for target quality
                                        if order.minQuality and order.minQuality > 0 then
                                            local maxQuality = (isPatronOrder and
                                                CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION"))
                                                and math.max(order.minQuality - 1, 1) or order.minQuality
                                            recipeData:Optimize {
                                                optimizeGear = true,
                                                optimizeReagentOptions = {
                                                    maxQuality = maxQuality,
                                                },
                                                finally = queueRecipe,
                                            }
                                        else
                                            queueRecipe()
                                        end
                                    else
                                        distributor:Continue()
                                    end
                                end
                            }:Continue()
                        end
                    end),
                }
                C_CraftingOrders.RequestCrafterOrders(request)
            end
        }:Continue()
end

function CraftSim.CRAFTQ:InitializeCraftQueue()
    -- load from Saved Variables
    CraftSim.CRAFTQ.craftQueue = CraftSim.CraftQueue()

    CraftSim.CRAFTQ.craftQueue:RestoreFromDB()

    -- hook onto auction buy confirm function
    hooksecurefunc(C_AuctionHouse, "ConfirmCommoditiesPurchase", function(itemID, quantity)
        CraftSim.CRAFTQ:OnConfirmCommoditiesPurchase(itemID, quantity)
    end)
end

---@class CraftSim.CRAFTQ.AddRecipe.Options : CraftSim.CraftQueueItem.Options
---@field splitSoulboundFinishingReagent? boolean when true, split the queue entry into a soulbound-finisher version and a non-soulbound version based on how many of the soulbound finishing reagent the crafter owns
---@field fromCraftListRestock? boolean
---@field craftListBracketCount? number

---@param options CraftSim.CRAFTQ.AddRecipe.Options
function CraftSim.CRAFTQ:AddRecipe(options)
    options = options or {}

    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    local recipeData = options.recipeData
    local amount = options.amount or 1

    local function finalizeAdd()
        CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_AUTO_SHOW") then
            CraftSim.DB.OPTIONS:Save("MODULE_CRAFT_QUEUE", true)
            CraftSim.CRAFTQ.frame:Show()
            CraftSim.CRAFTQ.frame:Raise()
        end
    end

    if options.splitSoulboundFinishingReagent and amount > 0 and recipeData:IsUsingSoulboundFinishingReagent() then
        local soulboundItemID, perCraft = recipeData:GetSoulboundFinishingReagentInfo()
        if soulboundItemID then
            local crafterUID = recipeData:GetCrafterUID()
            local owned = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, soulboundItemID, true) or 0
            local soulboundAmount = math.min(math.floor(owned / perCraft), amount)
            local nonSoulboundAmount = amount - soulboundAmount

            if soulboundAmount > 0 then
                CraftSim.CRAFTQ.craftQueue:AddRecipe({
                    recipeData = recipeData,
                    amount = soulboundAmount,
                    fromCraftListRestock = options.fromCraftListRestock == true,
                    craftListBracketCount = options.craftListBracketCount,
                })
            end

            if nonSoulboundAmount > 0 then
                local recipeDataCopy = recipeData:Copy()
                -- Clear soulbound finishing reagents from the copy so it gets a different UID
                for _, slot in ipairs(recipeDataCopy.reagentData.finishingReagentSlots) do
                    local active = slot.activeReagent
                    if active and not active:IsCurrency() and active.item then
                        local itemID = active.item:GetItemID()
                        if GUTIL:isItemSoulbound(itemID) then
                            slot:SetReagent(nil)
                        end
                    end
                end
                recipeDataCopy:Update()
                CraftSim.CRAFTQ.craftQueue:AddRecipe({
                    recipeData = recipeDataCopy,
                    amount = nonSoulboundAmount,
                    fromCraftListRestock = options.fromCraftListRestock == true,
                    craftListBracketCount = options.craftListBracketCount,
                })
            end

            finalizeAdd()
            return
        end
    end

    CraftSim.CRAFTQ.craftQueue:AddRecipe({
        recipeData = recipeData,
        amount = amount,
        fromCraftListRestock = options.fromCraftListRestock == true,
        craftListBracketCount = options.craftListBracketCount,
    })

    finalizeAdd()
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue:ClearAll()
    CraftSim.CRAFTQ.UI:UpdateDisplay()
end

function CraftSim.CRAFTQ:QueueFavorites()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    local profession = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not profession then
        return
    end
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    local favoriteRecipeIDs = CraftSim.DB.CRAFTER:GetFavoriteRecipes(crafterUID, profession)
    local bothMainProfessions = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_FAVORITES_QUEUE_MAIN_PROFESSIONS")

    -- always update favorite recipes
    CraftSim.DB.CRAFTER:UpdateProfessionFavorites()

    -- optimize and queue

    local queueFavoritesButton = CraftSim.CRAFTQ.frame.content.queueTab.content
        .queueFavoritesButton --[[@as GGUI.Button]]

    local optimizedRecipes = {}

    local concentrationData = CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    local currentConcentration = concentrationData and concentrationData:GetCurrentAmount() or 0

    local currentExpansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(C_TradeSkillUI.GetProfessionChildSkillLineID())

    local playerCrafterData = CraftSim.UTIL:GetPlayerCrafterData()

    local function finalizeProfessionProcess()
        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING") then
            ---@type CraftSim.RecipeData[]
            optimizedRecipes = GUTIL:Filter(optimizedRecipes,
                ---@param recipeData CraftSim.RecipeData
                function(recipeData)
                    return recipeData.concentrationCost <= currentConcentration
                end)

            -- sort by most profitable per concentration point
            table.sort(optimizedRecipes,
                ---@param recipeDataA CraftSim.RecipeData
                ---@param recipeDataB CraftSim.RecipeData
                function(recipeDataA, recipeDataB)
                    return recipeDataA:GetConcentrationValue() > recipeDataB:GetConcentrationValue()
                end)

            for _, recipeData in ipairs(optimizedRecipes) do
                if recipeData.concentrationCost > 0 then
                    local concentrationCosts = recipeData.concentrationCost
                    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT") then
                        local ingenuityChance = recipeData.professionStats.ingenuity:GetPercent(true)
                        local ingenuityRefund = 0.5 + recipeData.professionStats.ingenuity:GetExtraValue()
                        concentrationCosts = concentrationCosts -
                            (concentrationCosts * ingenuityChance * ingenuityRefund)
                    end
                    local queueableAmount = math.floor(currentConcentration / concentrationCosts)
                    -- Full cost required for at least one craft; adjusted cost is only for expected count.
                    if currentConcentration < recipeData.concentrationCost then
                        queueableAmount = 0
                    end
                    if queueableAmount > 0 then
                        local offsetAmount = tonumber(CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"))
                        local totalAmount = queueableAmount + offsetAmount

                        -- Ensure we only keep soulbound finishing reagents when we have enough
                        -- to cover all queued crafts for this recipe.
                        recipeData:AdjustSoulboundFinishingForAmount(totalAmount)

                        CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData, amount = totalAmount }
                        currentConcentration = currentConcentration -
                            (concentrationCosts * queueableAmount)
                        break -- only queue first recipe in this mode
                    end
                end
            end

            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end
    end

    ---@param frameDistributor GUTIL.FrameDistributor
    ---@param recipeID RecipeID
    ---@param profession Enum.Profession
    ---@param progress number
    local function processFavoriteRecipe(frameDistributor, recipeID, profession, progress)
        queueFavoritesButton:SetText(string.format("%.0f%%", progress))

        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

        if not recipeInfo or recipeInfo.isDummyRecipe or recipeInfo.isGatheringRecipe or recipeInfo.isRecraft or recipeInfo.isSalvageRecipe then
            frameDistributor:Continue()
            return
        end

        local recipeData = CraftSim.RecipeData { recipeID = recipeID, crafterData = playerCrafterData }

        if not recipeData then
            frameDistributor:Continue()
            return
        end

        recipeData:SetEquippedProfessionGearSet()
        recipeData:SetCheapestQualityReagentsMax()
        recipeData:Update()

        if recipeData.supportsQualities then
            recipeData.concentrating = true
            recipeData:Update()
        end

        local iconSize = 15

        recipeData:Optimize {
            optimizeReagentOptions = {
                highestProfit = true,
            },
            optimizeConcentration = true,
            optimizeGear = true,
            optimizeConcentrationProgressCallback = function(conProgress)
                queueFavoritesButton:SetText(string.format("%.0f%% - %s %s %s - %.0f%%",
                    progress,
                    GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[profession], iconSize, iconSize),
                    GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize),
                    GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, iconSize, iconSize),
                    conProgress))
            end,
            optimizeFinishingReagentsOptions = {
                includeLocked = false,
                includeSoulbound = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND"),
                progressUpdateCallback = function(frProgress)
                    queueFavoritesButton:SetText(string.format("%.0f%% - %s %s %s - %.0f%%",
                    progress,
                    GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[profession], iconSize, iconSize),
                    GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize),
                    CreateAtlasMarkup("Banker", iconSize, iconSize),
                    frProgress))
                end,
            },
            finally = function()
                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING") then
                    tinsert(optimizedRecipes, recipeData)
                else
                    local offsetAmount = tonumber(CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"))
                    local totalAmount = 1 + offsetAmount

                    -- Batch-aware adjustment: only keep soulbound finishers when we have enough
                    -- for all planned crafts of this favorite.
                    recipeData:AdjustSoulboundFinishingForAmount(totalAmount)

                    CraftSim.CRAFTQ.craftQueue:AddRecipe { recipeData = recipeData, amount = totalAmount }
                    CraftSim.CRAFTQ.UI:UpdateDisplay()
                end
                frameDistributor:Continue()
            end
        }
    end

    queueFavoritesButton:SetEnabled(false)

    local function createShoppingList()
        if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST") then
            CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
        end
    end

    -- keep table reference but change contents
    if bothMainProfessions then
        local professionFavorites = CraftSim.DB.CRAFTER:GetFavoriteRecipeProfessions(crafterUID)
        GUTIL.FrameDistributor {
            iterationTable = professionFavorites,
            iterationsPerFrame = 1,
            finally = function()
                queueFavoritesButton:SetStatus("Ready")
                createShoppingList()
            end,
            continue = function(frameDistributor, profession, recipeIDs, _, _)
                wipe(optimizedRecipes)
                concentrationData = CraftSim.DB.CRAFTER:GetCrafterConcentrationData(crafterUID, profession,
                    currentExpansionID)
                if not concentrationData then
                    frameDistributor:Break()
                    return
                end
                currentConcentration = concentrationData:GetCurrentAmount()

                GUTIL.FrameDistributor {
                    iterationTable = recipeIDs,
                    iterationsPerFrame = 1,
                    maxIterations = 1000,
                    finally = function()
                        finalizeProfessionProcess()
                        frameDistributor:Continue()
                    end,
                    continue = function(frameDistributor, _, recipeID, _, progress)
                        processFavoriteRecipe(frameDistributor, recipeID, profession, progress)
                    end
                }:Continue()
            end,
        }:Continue()
    else
        GUTIL.FrameDistributor {
            iterationTable = favoriteRecipeIDs,
            iterationsPerFrame = 1,
            maxIterations = 1000,
            finally = function()
                finalizeProfessionProcess()
                queueFavoritesButton:SetStatus("Ready")
                createShoppingList()
            end,
            continue = function(frameDistributor, _, recipeID, _, progress)
                processFavoriteRecipe(frameDistributor, recipeID, profession, progress)
            end
        }:Continue()
    end
end

---@param recipeData CraftSim.RecipeData
---@param amount number
---@param enchantItemTargetOrRecipeLevel ItemLocationMixin|number?
---@param isEnchantCraft boolean? true only for CraftEnchant; salvage uses a reagent item location, not vellum
function CraftSim.CRAFTQ:SetCraftedRecipeData(recipeData, amount, enchantItemTargetOrRecipeLevel, isEnchantCraft)
    -- find the current queue item and set it to currentlyCraftedQueueItem
    -- if an enchant was crafted that was not on a vellum, ignore (CraftSalvage passes the mote slot — never clear for that)
    if isEnchantCraft and enchantItemTargetOrRecipeLevel and type(enchantItemTargetOrRecipeLevel) ~= "number" and
        enchantItemTargetOrRecipeLevel:IsValid() then
        if C_Item.GetItemID(enchantItemTargetOrRecipeLevel) ~= CraftSim.CONST.ENCHANTING_VELLUM_ID then
            CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil
            return
        end
    end
    CraftSim.CRAFTQ.currentlyCraftedRecipeData = recipeData
end

function CraftSim.CRAFTQ:GetNonSoulboundAlternativeItemID(itemID)
    if GUTIL:isItemSoulbound(itemID) then
        -- if item is soulbound check if there is non soulbound alternative item
        local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID]
        if alternativeItemID and not GUTIL:isItemSoulbound(alternativeItemID) then
            print("Found non soulbound alt item: " .. tostring(alternativeItemID))
            return alternativeItemID
        else
            return nil
        end
    end
    return itemID
end

--- depricate as soon as there is an api for it
function CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(listName)
    local listExists = Auctionator.Shopping.ListManager:GetIndexForName(listName)
    if listExists then
        Auctionator.Shopping.ListManager:Delete(listName)
    end
end

function CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()
    -- delete the general shopping list if it exists
    CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME)
    -- delete , if existing, all shoppinglists for cached crafterUIDS
    local crafterUIDs = CraftSim.DB.CRAFTER:GetCrafterUIDs()
    for _, crafterUID in pairs(crafterUIDs) do
        CraftSim.CRAFTQ:DeleteAuctionatorShoppingList(CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME ..
            " " .. tostring(crafterUID))
    end
end

function CraftSim.CRAFTQ.CreateAuctionatorShoppingList()
    print("CraftSim.CRAFTQ:CreateAuctionatorShoppingList", false, true)

    CraftSim.CRAFTQ:DeleteAllCraftSimShoppingLists()

    -- reset quick buy
    CraftSim.CRAFTQ:ResetQuickBuyCache()

    CraftSim.DEBUG:StartProfiling("CreateAuctionatorShopping")
    local reagentMap = {}
    -- create a map of all used reagents in the queue and their quantity
    for _, craftQueueItem in pairs(CraftSim.CRAFTQ.craftQueue.craftQueueItems) do
        local requiredReagents = craftQueueItem.recipeData.reagentData.requiredReagents
        for _, reagent in pairs(requiredReagents) do
            if not reagent:IsOrderReagentIn(craftQueueItem.recipeData) then
                if reagent.hasQuality then
                    for qualityID, reagentItem in pairs(reagent.items) do
                        local itemID = reagentItem.item:GetItemID()
                        print("Shopping List Creation: Item: " .. (reagentItem.item:GetItemLink() or ""))
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
                        print("reagentMap Build: " .. tostring(reagentItem.item:GetItemLink()))
                        print("quantity: " .. tostring(reagentMap[itemID].quantity))
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

    local crafterUIDs = GUTIL:Map(CraftSim.CRAFTQ.craftQueue.craftQueueItems, function(cqi)
        return cqi.recipeData:GetCrafterUID()
    end)

    local crafterUIDs = GUTIL:ToSet(crafterUIDs)

    --- convert to Auctionator Search Strings and deduct item count (of all crafters total)
    local searchStrings = GUTIL:Map(reagentMap, function(info, itemID)
        itemID = CraftSim.CRAFTQ:GetNonSoulboundAlternativeItemID(itemID)
        if not itemID then
            return nil
        end
        -- subtract the total item count of all crafter's cached inventory
        local totalItemCount = GUTIL:Fold(crafterUIDs, 0, function(itemCount, crafterUID)
            local itemCountForCrafter = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
            return itemCount + itemCountForCrafter
        end)

        print("total item count " .. itemID .. "-> " .. totalItemCount)

        local searchTerm = {
            searchString = info.itemName,
            tier = info.qualityID,
            quantity = math.max(info.quantity - (tonumber(totalItemCount) or 0), 0),
            isExact = true,
            debug = tostring(info.quantity) .. " - " .. tostring((tonumber(totalItemCount) or 0)),
        }
        if searchTerm.quantity == 0 then
            return nil -- do not put into table
        end
        local searchString = Auctionator.API.v1.ConvertToSearchString(addonName, searchTerm)
        return searchString
    end)
    Auctionator.API.v1.CreateShoppingList(addonName, CraftSim.CONST.AUCTIONATOR_SHOPPING_LIST_QUEUE_NAME, searchStrings)

    CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. f.bb("Created Auctionator Shopping List"))

    CraftSim.DEBUG:StopProfiling("CreateAuctionatorShopping")
end

function CraftSim.CRAFTQ:BAG_UPDATE_DELAYED()
    local qFrame = CraftSim.CRAFTQ.frame
    if qFrame and qFrame:IsVisible() then
        CraftSim.CRAFTQ.UI:UpdateQuickAccessBarDisplay()
        -- Equip / unequip updates inventory after a delay; refresh queue gear state unless mid Equip() sequence.
        if not CraftSim.TOPGEAR.IsEquipping then
            CraftSim.CRAFTQ.UI:UpdateDisplay()
        end
    end
end

---@param craftingItemResultData CraftingItemResultData
function CraftSim.CRAFTQ:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftingItemResultData)
    if CraftSim.CRAFTQ.currentlyCraftedRecipeData then
        CraftSim.CRAFTQ.craftQueue:OnRecipeCrafted(CraftSim.CRAFTQ.currentlyCraftedRecipeData, craftingItemResultData)
    end
end

--- only for craft queue display update's flash cache
---@param crafterUID CrafterUID
---@param itemID number
---@param excludeWarbank? boolean
function CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID, excludeWarbank)
    local itemCount = (CraftSim.CRAFTQ.itemCountCache and CraftSim.CRAFTQ.itemCountCache[itemID]) or nil
    if not itemCount then
        itemCount = CraftSim.ITEM_COUNT:Get(crafterUID, itemID, excludeWarbank)
    end
    return itemCount
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ:IsRecipeQueueable(recipeData)
    return
        not recipeData.isRecraft and
        not recipeData.isSalvageRecipe and
        not recipeData.isBaseRecraftRecipe and
        recipeData.resultData.itemsByQuality[1] and -- needs at least one result?
        not recipeData.isAlchemicalExperimentation
end

---@class CraftSim.CraftQueue.RestockRecipeOption
---@field enabled boolean,
---@field profitMarginThreshold number,
---@field restockAmount number,
---@field restockPerQuality table<number, boolean>,
---@field saleRateThreshold number,
---@field saleRatePerQuality table<number, boolean>

---@param recipeID number
---@return CraftSim.CraftQueue.RestockRecipeOption
function CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeID)
    local restockPerRecipeOptions = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_PER_RECIPE_OPTIONS")
    restockPerRecipeOptions[recipeID] = restockPerRecipeOptions
        [recipeID] or {}

    restockPerRecipeOptions[recipeID].enabled = restockPerRecipeOptions[recipeID].enabled or false
    restockPerRecipeOptions[recipeID].profitMarginThreshold = restockPerRecipeOptions[recipeID].profitMarginThreshold or
        0
    restockPerRecipeOptions[recipeID].restockAmount = restockPerRecipeOptions[recipeID].restockAmount or 1
    restockPerRecipeOptions[recipeID].restockPerQuality = restockPerRecipeOptions[recipeID].restockPerQuality or {}
    restockPerRecipeOptions[recipeID].saleRateThreshold = restockPerRecipeOptions[recipeID].saleRateThreshold or 0
    restockPerRecipeOptions[recipeID].saleRatePerQuality = restockPerRecipeOptions[recipeID].saleRatePerQuality or {}

    return restockPerRecipeOptions[recipeID]
end

---@param recipeData CraftSim.RecipeData
---@param usedQualitiesTable table<number, boolean>?
---@param saleRateThreshold number
---@private
function CraftSim.CRAFTQ:CheckSaleRateThresholdForRecipe(recipeData, usedQualitiesTable, saleRateThreshold)
    usedQualitiesTable = usedQualitiesTable or { true, true, true, true, true }
    local allOff = not GUTIL:Some(usedQualitiesTable, function(v) return v end)
    if allOff then
        print("No quality checked -> sale rate true")
        return true -- if nothing is checked for an individual sale rate check then its just true
    end
    if not select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[1])) then
        print("tsm not loaded -> sale rate true")
        return true -- always true if TSM is not loaded
    end
    for qualityID, checkQuality in pairs(usedQualitiesTable or {}) do
        local item = recipeData.resultData.itemsByQuality[qualityID]
        if item and checkQuality then
            print("check sale rate for q" .. qualityID .. ": " .. tostring(checkQuality))
            -- return true if any item has a sale rate over the threshold
            local itemSaleRate = CraftSimTSM:GetItemSaleRate(item:GetItemLink())
            print("itemSaleRate: " .. tostring(itemSaleRate))
            print("saleRateThreshold: " .. tostring(saleRateThreshold))
            if itemSaleRate >= saleRateThreshold then
                print("sale reate reached for quality: " .. tostring(qualityID))
                return true
            end
        end
    end
    print("sale rate not reached")
    return false
end

function CraftSim.CRAFTQ:QueueOpenRecipe()
    ---@type CraftSim.RecipeData
    local recipeData
    if CraftSim.SIMULATION_MODE.isActive then
        if CraftSim.SIMULATION_MODE.recipeData then
            recipeData = CraftSim.SIMULATION_MODE.recipeData:Copy() -- need a copy or changes in simulation mode just overwrite it
        end
    else
        if CraftSim.MODULES.recipeData then
            recipeData = CraftSim.MODULES.recipeData:Copy()
        end
    end

    if not recipeData then
        return
    end

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local queueButton
    if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        queueButton = CraftSim.CRAFTQ.queueRecipeButton
    else
        queueButton = CraftSim.CRAFTQ.queueRecipeButtonWO
    end

    local KEYS = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
    local optimizeTopProfit = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(
        CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE, KEYS.AUTOSELECT_TOP_PROFIT_QUALITY, true)
    local optimizeGear = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(
        CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE, KEYS.OPTIMIZE_PROFESSION_TOOLS, true)
    local optimizeConcentration = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(
        CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE, KEYS.OPTIMIZE_CONCENTRATION, true)

    if not IsShiftKeyDown() then
        -- just queue without any optimizations
        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
        return
    end

    if optimizeConcentration and recipeData.supportsQualities then
        recipeData.concentrating = true
        recipeData:Update()
    end

    queueButton:SetEnabled(false)
    recipeData:Optimize {
        optimizeGear = optimizeGear,
        optimizeReagentOptions = optimizeTopProfit and { highestProfit = true } or nil,
        optimizeConcentration = optimizeConcentration,
        optimizeConcentrationProgressCallback = function(progress)
            queueButton:SetText(string.format("%.0f%%", progress))
        end,
        finally = function()
            queueButton:SetEnabled(true)
            queueButton:SetText("+ CraftQueue")
            CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
        end,
    }
end

---@deprecated Use CraftSim.WIDGETS.OptimizationOptions with optimizationOptionsID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE instead
function CraftSim.CRAFTQ:ShowQueueOpenRecipeOptions(rootDescription)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then return end
    local OPT_ID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.CRAFTQUEUE_ADD_RECIPE
    local KEYS   = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
    if recipeData.supportsQualities then
        rootDescription:CreateCheckbox(
            L("RECIPE_SCAN_AUTOSELECT_TOP_PROFIT"),
            function()
                return CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.AUTOSELECT_TOP_PROFIT_QUALITY, true)
            end, function()
                local value = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.AUTOSELECT_TOP_PROFIT_QUALITY, true)
                CraftSim.DB.OPTIMIZATION_OPTIONS:Save(OPT_ID, KEYS.AUTOSELECT_TOP_PROFIT_QUALITY, not value)
            end)
    end
    rootDescription:CreateCheckbox(
        L("OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS"),
        function()
            return CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_PROFESSION_TOOLS, true)
        end, function()
            local value = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_PROFESSION_TOOLS, true)
            CraftSim.DB.OPTIMIZATION_OPTIONS:Save(OPT_ID, KEYS.OPTIMIZE_PROFESSION_TOOLS, not value)
        end)
    if recipeData.supportsQualities then
        rootDescription:CreateCheckbox(
            L("RECIPE_SCAN_OPTIMIZE_CONCENTRATION"),
            function()
                return CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_CONCENTRATION, true)
            end, function()
                local value = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_CONCENTRATION, true)
                CraftSim.DB.OPTIMIZATION_OPTIONS:Save(OPT_ID, KEYS.OPTIMIZE_CONCENTRATION, not value)
            end)
    end
end

function CraftSim.CRAFTQ:QueueFirstCrafts()
    local openRecipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
    local currentSkillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()

    printFC("Queueing First Crafts: " .. tostring(#openRecipeIDs) .. " recipes to check")
    printFC("SkillLineID: " .. tostring(currentSkillLineID))

    local firstCraftRecipeIDs = GUTIL:Map(openRecipeIDs or {}, function(recipeID)
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.learned and recipeInfo.firstCraft then
            return recipeID
        end

        return nil
    end)

    printFC("First Craft Recipes: " .. tostring(#firstCraftRecipeIDs))

    GUTIL.FrameDistributor {
        iterationsPerFrame = 2,
        iterationTable = firstCraftRecipeIDs,
        continue = function(frameDistributor, _, recipeID, _, _)
            local recipeData = CraftSim.RecipeData({ recipeID = recipeID })
            local isSkillLine = recipeData.professionData.skillLineID == currentSkillLineID
            local ignoreAcuity = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
            local usesAcuity = recipeData.reagentData:HasOneOfReagents({
                CraftSim.CONST.ITEM_IDS.CURRENCY.ARTISANS_METTLE,
                CraftSim.CONST.ITEM_IDS.CURRENCY.ARTISANS_ACUITY,
                CraftSim.CONST.ITEM_IDS.CURRENCY.FUSED_VITALITY, -- TODO catches epic BoP equipment but not rare
            })
            local queueRecipe = isSkillLine and (not ignoreAcuity or not usesAcuity)

            printFC("Checking recipe: " .. tostring(recipeData.recipeName) .. " - " .. tostring(queueRecipe))
            if queueRecipe then
                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES") then
                    if recipeData:HasRequiredSelectableReagent() then
                        local ingenuityRecipe = recipeData.reagentData.requiredSelectableReagentSlot:IsPossibleReagent(CraftSim.CONST.ITEM_IDS.REQUIRED_SELECTABLE_ITEMS.SPARK_OF_INGENUITY)
                        local omenRecipe = recipeData.reagentData.requiredSelectableReagentSlot:IsPossibleReagent(CraftSim.CONST.ITEM_IDS.REQUIRED_SELECTABLE_ITEMS.SPARK_OF_OMENS)
                        local radianceRecipe = recipeData.reagentData.requiredSelectableReagentSlot:IsPossibleReagent(CraftSim.CONST.ITEM_IDS.REQUIRED_SELECTABLE_ITEMS.SPARK_OF_RADIANCE)
                        if ingenuityRecipe or omenRecipe or radianceRecipe then
                            frameDistributor:Continue()
                            return
                        end
                    end
                end

                local isAlreadyQueued = CraftSim.CRAFTQ.craftQueue:FindRecipe(recipeData) ~= nil
                if isAlreadyQueued then
                    printFC("First craft is already queued, skipping: " .. tostring(recipeData.recipeName))
                    frameDistributor:Continue()
                    return
                end

                recipeData:SetCheapestQualityReagentsMax()
                self:AddRecipe({ recipeData = recipeData })
                frameDistributor:Continue()
                return
            end
            frameDistributor:Continue()
        end
    }:Continue()
end

function CraftSim.CRAFTQ:OnRecipeEditSave()
    print("OnRecipeEditSave")
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)

    editRecipeFrame:Hide()
end

---@param recipeID RecipeID
function CraftSim.CRAFTQ:NEW_RECIPE_LEARNED(recipeID)
    -- if craftQueue has items from this crafter, update learned status and recipeInfo, and queue list
    for _, craftQueueItem in ipairs(self.craftQueue.craftQueueItems) do
        local recipeData = craftQueueItem.recipeData
        if recipeData:IsCrafter() and recipeData.recipeID == recipeID then
            -- recipe was learned, update
            recipeData.recipeInfo.learned = true
            recipeData.learned = true
            CraftSim.DB.CRAFTER:SaveRecipeInfo(recipeData:GetCrafterUID(), recipeData.recipeID, recipeData
                .recipeInfo)
        end
    end

    self.UI:UpdateDisplay()
end

--- Magic Command for one-button shopping list buying
--- Currently only works for craftsim shopping list due to relying on bought item removal
--- TODO: fix auto removal for reagents like darkmoon decks
function CraftSim.CRAFTQ:AuctionatorQuickBuy()
    local print = printQB

    print("AuctionatorQuickBuy", false, true)

    local qbCache = self.quickBuyCache

    if not AuctionatorShoppingFrame then
        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. f.r("Quick Buy only available for Auctionator Shopping Lists"))
        return
    end

    local listManager = Auctionator.Shopping.ListManager
    local listName = "CraftSim CraftQueue"

    local listsContainer = AuctionatorShoppingFrame.ListsContainer
    local resultsList = AuctionatorShoppingFrame.ResultsListing

    ---@param value CraftSim.CRAFTQ.QB_STATUS
    ---@return boolean
    local function status(value)
        return qbCache.status == value
    end


    ---@param value CraftSim.CRAFTQ.QB_STATUS
    local function set(value)
        print("- Setting Status: " .. tostring(value))
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
        -- map rows to shopping list items
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
        print("- No Items Left")
        return
    end

    -- get item that was not bought yet
    local buyShoppingListSearchString = GUTIL:Find(list.data.items, function(searchString)
        return not qbCache.boughtSearchStrings[searchString]
    end)

    print("- STATUS: " .. tostring(qbCache.status))

    if not buyShoppingListSearchString then
        print("- All bought")
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
        -- check if result row items match with shopping list if no do nothing, if yes continue
        mapSearchResultRows(allItemSearchStrings)

        if matchSearchResultRows(allItemSearchStrings) then
            set(QB_STATUS.RESULT_LIST_READY)
        end
    end

    if buyShoppingListSearchString and status(QB_STATUS.RESULT_LIST_READY) then
        local resultRow = qbCache.resultRows[buyShoppingListSearchString]

        if not resultRow then
            print("Result Row not found in result list: " .. tostring(buyShoppingListSearchString))
            return
        end

        local itemID = resultRow.itemKey.itemID
        local quantity = resultRow.purchaseQuantity

        -- check if player has enough gold to buy it
        local buyoutPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true, true)
        local totalPrice = buyoutPrice * quantity
        local playerMoney = GetMoney()

        if playerMoney < totalPrice then
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") .. f.bb("QuickBuy:") ..  " Not enough gold")
            CraftSim.DEBUG:SystemPrint(f.l("CraftSim ") .. f.bb("QuickBuy:") ..  " Missing: " .. CraftSim.GUTIL:FormatMoney(totalPrice - playerMoney))
            return
        end

        qbCache.pendingItemID = itemID
        qbCache.pendingItemCount = quantity

        qbCache.currentSearchString = buyShoppingListSearchString
        qbCache.purchasePending = true
        set(QB_STATUS.PURCHASE_AWAIT)

        -- Triggers AUCTION_HOUSE_THROTTLED_SYSTEM_READY and needs confirmation there
        C_AuctionHouse.StartCommoditiesPurchase(qbCache.pendingItemID, qbCache.pendingItemCount)
        return
    end

    if status(QB_STATUS.PURCHASE_AWAIT) and not qbCache.purchasePending then
        qbCache.boughtSearchStrings[qbCache.currentSearchString] = true
        set(QB_STATUS.RESULT_LIST_READY)
        self:AuctionatorQuickBuy()
    end
end

function CraftSim.CRAFTQ:AUCTION_HOUSE_THROTTLED_SYSTEM_READY()
    local qbCache = self.quickBuyCache
    if qbCache.pendingItemCount and qbCache.pendingItemID then
        C_AuctionHouse.ConfirmCommoditiesPurchase(qbCache.pendingItemID, qbCache.pendingItemCount)
        -- triggers COMMODITY_PURCHASE_SUCCEEDED
        -- TODO: Consider COMMODITY_PURCHASE_FAILED
    end
end

function CraftSim.CRAFTQ:COMMODITY_PURCHASE_FAILED()
    -- reset quick buy
    self:ResetQuickBuyCache()
end

function CraftSim.CRAFTQ:ResetQuickBuyCache()
    local qbCache = self.quickBuyCache
    qbCache.status = QB_STATUS.INIT
    qbCache.currentSearchString = nil
    qbCache.purchasePending = false
    wipe(qbCache.boughtSearchStrings)
    wipe(qbCache.resultRows)
end
