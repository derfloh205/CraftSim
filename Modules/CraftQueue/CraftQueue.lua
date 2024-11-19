---@class CraftSim
local CraftSim = select(2, ...)
local addonName = select(1, ...)

local Auctionator = Auctionator

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.CRAFTQ : Frame
CraftSim.CRAFTQ = GUTIL:CreateRegistreeForEvents({ "TRADE_SKILL_ITEM_CRAFTED_RESULT", "COMMODITY_PURCHASE_SUCCEEDED",
    "NEW_RECIPE_LEARNED", "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED", "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED" })

---@type CraftSim.CraftQueue
CraftSim.CRAFTQ.craftQueue = nil

---@type CraftSim.RecipeData | nil
CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil

--- used to check if CraftSim was the one calling the C_TradeSkillUI.CraftRecipe api function
CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false

--- used to cache player item counts during sorting and recalculation of craft queue
--- if canCraft and such functions are not called by craftqueue it should be nil
CraftSim.CRAFTQ.itemCountCache = nil

local systemPrint = print
local print = CraftSim.DEBUG:SetDebugPrint("CraftQueue")

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
    local profession = C_TradeSkillUI.GetChildProfessionInfo().profession
    local normalizedRealmName = GetNormalizedRealmName()
    local realmName = GetRealmName()
    local cleanedCrafterUIDs = GUTIL:Map(CraftSim.DB.CRAFTER:GetCrafterUIDs(), function(crafterUID)
        return select(1, gsub(crafterUID, "-" .. normalizedRealmName, ""))
    end)
    --TODO: Public Orders
    local workOrderTypes = {
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS") and Enum.CraftingOrderType.Npc,
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS") and Enum.CraftingOrderType.Guild,
        CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS") and Enum.CraftingOrderType.Personal,
    }
    if C_TradeSkillUI.IsNearProfessionSpellFocus(profession) then
        local queueWorkOrdersButton = CraftSim.CRAFTQ.frame.content.queueTab.content
            .addWorkOrdersButton --[[@as GGUI.Button]]

        queueWorkOrdersButton:SetEnabled(false)

        GUTIL.FrameDistributor {
            iterationTable = workOrderTypes,
            iterationsPerFrame = 1,
            maxIterations = 10,
            finally = function()
                queueWorkOrdersButton:SetText(L(CraftSim.CONST.TEXT
                    .CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL))
                queueWorkOrdersButton:SetEnabled(true)
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

                            GUTIL.FrameDistributor {
                                iterationTable = orders,
                                iterationsPerFrame = 1,
                                maxIterations = 100,
                                finally = function()
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
                                                    local itemID = GUTIL:GetItemIDByLink(reward.itemLink)
                                                    local knowledgeAllowed = CraftSim.DB.OPTIONS:Get(
                                                        "CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS")
                                                    local acuityAllowed = CraftSim.DB.OPTIONS:Get(
                                                        "CRAFTQUEUE_PATRON_ORDERS_ACUITY")
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
                                                    local acuityContained = itemID == 210814
                                                    local runeContained = itemID == 224572
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

                                        recipeData:SetCheapestQualityReagentsMax() -- considers patron reagents
                                        recipeData:Update()

                                        if isPatronOrder and knowledgePointsRewarded > 0 and recipeData.averageProfitCached < 0 then
                                            local maxKPCost = CraftSim.DB.OPTIONS:Get(
                                                "CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST")
                                            local kpCost = math.abs(recipeData.averageProfitCached /
                                                knowledgePointsRewarded)

                                            if kpCost >= maxKPCost then
                                                distributor:Continue()
                                                return
                                            end
                                        end

                                        local function queueRecipe()
                                            local allowConcentration = CraftSim.DB.OPTIONS:Get(
                                                "CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION")
                                            local forceConcentration = CraftSim.DB.OPTIONS:Get(
                                                "CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION")
                                            -- check if the min quality is reached, if not do not queue
                                            if recipeData.resultData.expectedQuality >= order.minQuality then
                                                CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData }
                                            end

                                            if (forceConcentration or allowConcentration) and
                                                recipeData.resultData.expectedQualityConcentration == order.minQuality then
                                                -- use concentration to reach and then queue
                                                recipeData.concentrating = true
                                                recipeData:Update()
                                                CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData }
                                            end

                                            distributor:Continue()
                                        end
                                        -- try to optimize for target quality
                                        if order.minQuality and order.minQuality > 0 then
                                            if isPatronOrder and CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION") then
                                                RunNextFrame(
                                                    function()
                                                        recipeData:OptimizeReagents({
                                                            maxQuality = math.max(order.minQuality - 1, 1)
                                                        })
                                                        queueRecipe()
                                                    end
                                                )
                                            else
                                                RunNextFrame(
                                                    function()
                                                        recipeData:OptimizeReagents({
                                                            maxQuality = order.minQuality
                                                        })
                                                        queueRecipe()
                                                    end
                                                )
                                            end
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

---@param options CraftSim.CraftQueueItem.Options
function CraftSim.CRAFTQ:AddRecipe(options)
    options = options or {}

    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()
    CraftSim.CRAFTQ.craftQueue:AddRecipe({
        recipeData = options.recipeData,
        amount = options.amount,
    })

    CraftSim.CRAFTQ.UI:UpdateQueueDisplay()

    if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_AUTO_SHOW") then
        CraftSim.DB.OPTIONS:Save("MODULE_CRAFT_QUEUE", true)
        CraftSim.CRAFTQ.frame:Show()
        CraftSim.CRAFTQ.frame:Raise()
    end
end

function CraftSim.CRAFTQ:ClearAll()
    CraftSim.CRAFTQ.craftQueue:ClearAll()
    CraftSim.CRAFTQ.UI:UpdateDisplay()
end

function CraftSim.CRAFTQ:QueueFavorites()
    CraftSim.CRAFTQ.craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    local profession = C_TradeSkillUI.GetChildProfessionInfo().profession
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
    local currentConcentration = concentrationData:GetCurrentAmount()

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
                        concentrationCosts = concentrationCosts -
                            (concentrationCosts * recipeData.professionStats.ingenuity:GetPercent(true) * recipeData.professionStats.ingenuity:GetExtraValue())
                    end
                    local queueableAmount = math.floor(currentConcentration / concentrationCosts)
                    if queueableAmount > 0 then
                        local offsetAmount = tonumber(CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"))
                        CraftSim.CRAFTQ:AddRecipe { recipeData = recipeData, amount = queueableAmount + offsetAmount }
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
            optimizeConcentrationProgressCallback = function(conProgress)
                queueFavoritesButton:SetText(string.format("%.0f%% - %s %s %s - %.0f%%",
                    progress,
                    GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[profession], iconSize, iconSize),
                    GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize),
                    GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, iconSize, iconSize),
                    conProgress))
            end,
            optimizeFinishingReagents = true,
            optimizeFinishingReagentsProgressCallback = function(frProgress)
                queueFavoritesButton:SetText(string.format("%.0f%% - %s %s %s - %.0f%%",
                    progress,
                    GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[profession], iconSize, iconSize),
                    GUTIL:IconToText(recipeData.recipeIcon, iconSize, iconSize),
                    CreateAtlasMarkup("Banker", iconSize, iconSize),
                    frProgress))
            end,
            finally = function()
                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING") then
                    tinsert(optimizedRecipes, recipeData)
                else
                    CraftSim.CRAFTQ.craftQueue:AddRecipe { recipeData = recipeData, amount = 1 + tonumber(CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT")) }
                    CraftSim.CRAFTQ.UI:UpdateDisplay()
                end
                frameDistributor:Continue()
            end
        }
    end

    queueFavoritesButton:SetEnabled(false)

    -- keep table reference but change contents
    if bothMainProfessions then
        local professionFavorites = CraftSim.DB.CRAFTER:GetFavoriteRecipeProfessions(crafterUID)
        GUTIL.FrameDistributor {
            iterationTable = professionFavorites,
            iterationsPerFrame = 1,
            finally = function()
                queueFavoritesButton:SetStatus("Ready")
            end,
            continue = function(frameDistributor, profession, recipeIDs, _, _)
                wipe(optimizedRecipes)
                concentrationData = CraftSim.DB.CRAFTER:GetCrafterConcentrationData(crafterUID, profession,
                    CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN)
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
function CraftSim.CRAFTQ:SetCraftedRecipeData(recipeData, amount, enchantItemTargetOrRecipeLevel)
    -- find the current queue item and set it to currentlyCraftedQueueItem
    -- if an enchant was crafted that was not on a vellum, ignore
    if enchantItemTargetOrRecipeLevel and type(enchantItemTargetOrRecipeLevel) ~= "number" and enchantItemTargetOrRecipeLevel:IsValid() then
        if C_Item.GetItemID(enchantItemTargetOrRecipeLevel) ~= CraftSim.CONST.ENCHANTING_VELLUM_ID then
            CraftSim.CRAFTQ.currentlyCraftedRecipeData = nil
            return
        end
    end
    print("OnCraftRecipe", false, true)
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
            if slot and slot:IsAllocated() and not slot:IsOrderReagentIn(craftQueueItem.recipeData) then
                tinsert(activeReagents, slot
                    .activeReagent)
                quantityMap[slot.activeReagent.item:GetItemID()] =
                    slot.maxQuantity or 1
            end
        end
        for _, optionalReagent in pairs(activeReagents) do
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

    CraftSim.DEBUG:StopProfiling("CreateAuctionatorShopping")
end

---@param craftingItemResultData CraftingItemResultData
function CraftSim.CRAFTQ:TRADE_SKILL_ITEM_CRAFTED_RESULT(craftingItemResultData)
    print("onCraftResult")
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
        if CraftSim.INIT.currentRecipeData then
            recipeData = CraftSim.INIT.currentRecipeData:Copy()
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

    local optimizeTopProfit = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY")
    local optimizeGear = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_PROFESSION_GEAR")
    local optimizeConcentration = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_CONCENTRATION")

    if IsShiftKeyDown() then
        -- just queue without any optimizations
        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
        return
    end

    if optimizeConcentration and recipeData.supportsQualities then
        recipeData.concentrating = true
        recipeData:Update()
    end

    if optimizeGear then
        recipeData:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
    end

    if optimizeTopProfit then
        recipeData:OptimizeReagents {
            highestProfit = true,
        }
    end

    if optimizeConcentration and recipeData.supportsQualities then
        queueButton:SetEnabled(false)
        recipeData:OptimizeConcentration {
            finally = function()
                queueButton:SetEnabled(true)
                queueButton:SetText("+ CraftQueue")
                CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
            end,
            progressUpdateCallback = function(progress)
                queueButton:SetText(string.format("%.0f%%", progress))
            end
        }
    else
        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
    end
end

function CraftSim.CRAFTQ:ShowQueueOpenRecipeOptions()
    MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
        local recipeData = CraftSim.INIT.currentRecipeData
        if not recipeData then return end
        if recipeData.supportsQualities then
            rootDescription:CreateCheckbox(
                "Optimize " .. f.g("Top Profit Quality"),
                function()
                    return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY")
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY", not value)
                end)
        end
        rootDescription:CreateCheckbox(
            "Optimize " .. f.bb("Profession Gear"),
            function()
                return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_PROFESSION_GEAR")
            end, function()
                local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_PROFESSION_GEAR")
                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_PROFESSION_GEAR", not value)
            end)
        if recipeData.supportsQualities then
            rootDescription:CreateCheckbox(
                "Optimize " .. f.gold("Concentration"),
                function()
                    return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_CONCENTRATION")
                end, function()
                    local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_CONCENTRATION")
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_OPEN_RECIPE_OPTIMIZE_CONCENTRATION", not value)
                end)
        end
    end)
end

function CraftSim.CRAFTQ:QueueFirstCrafts()
    local openRecipeIDs = C_TradeSkillUI.GetFilteredRecipeIDs()
    local currentSkillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()

    local firstCraftRecipeIDs = GUTIL:Map(openRecipeIDs or {}, function(recipeID)
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.learned and recipeInfo.firstCraft then
            return recipeID
        end

        return nil
    end)

    GUTIL.FrameDistributor {
        iterationsPerFrame = 2,
        iterationTable = firstCraftRecipeIDs,
        continue = function(frameDistributor, _, recipeID, _, _)
            local recipeData = CraftSim.RecipeData({ recipeID = recipeID })
            local isSkillLine = recipeData.professionData.skillLineID == currentSkillLineID
            local ignoreAcuity = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
            local usesAcuity = recipeData.reagentData:HasOneOfReagents({ CraftSim.CONST.ITEM_IDS.CURRENCY
                .ARTISANS_ACUITY })
            local queueRecipe = isSkillLine and (not ignoreAcuity or not usesAcuity)
            if queueRecipe then
                if CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES") then
                    if recipeData:HasRequiredSelectableReagent() then
                        if recipeData.reagentData.requiredSelectableReagentSlot:IsPossibleReagent(CraftSim.CONST.ITEM_IDS.REQUIRED_SELECTABLE_ITEMS.SPARK_OF_OMENS) then
                            frameDistributor:Continue()
                            return
                        end
                    end
                end

                recipeData:SetCheapestQualityReagentsMax()
                self:AddRecipe({ recipeData = recipeData })
                frameDistributor:Continue()
            end
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
