CraftSimAddonName, CraftSim = ...

---@class CraftSim.CUSTOMER_HISTORY : Frame
CraftSim.CUSTOMER_HISTORY = CraftSim.GUTIL:CreateRegistreeForEvents(
    {"CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE"}
)

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_HISTORY)


function CraftSim.CUSTOMER_HISTORY:MigrateDataV2()
    print("Starting CustomerHistoryLegacy Migration")
    local playerRealm = GetRealmName()
    
    if CraftSimCustomerHistory and CraftSimCustomerHistory[playerRealm] then

        ---@type table<string, CraftSim.CustomerHistory.Legacy>
        local realmData = CraftSimCustomerHistory[playerRealm]
        for customerName, customerHistoryLegacy in pairs(realmData) do
            print("Migrating Customer: " .. tostring(customerName))
            local name, realm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(customerName)
            -- create customer history v2 in new db
            local customerHistory = CraftSim.CUSTOMER_HISTORY.DB:GetCustomerHistory(name, realm)

            customerHistory.totalTip = customerHistoryLegacy.totalTip
            customerHistory.chatHistory = CraftSim.GUTIL:Map(customerHistoryLegacy.history, 
            ---@param historyLegacy CraftSim.CustomerHistory.Craft.Legacy | CraftSim.CustomerHistory.ChatMessage.Legacy
            function (historyLegacy)
                if historyLegacy.crafted then
                    return nil
                end
                ---@type CraftSim.CustomerHistory.ChatMessage
                local chatMessage = {
                    content = historyLegacy.from or historyLegacy.to,
                    date = C_DateAndTime.GetCalendarTimeFromEpoch(historyLegacy.timestamp),
                    fromPlayer = historyLegacy.to ~= nil,
                }
                return chatMessage
            end)

            customerHistory.craftHistory = CraftSim.GUTIL:Map(customerHistoryLegacy.history, 
            ---@param historyLegacy CraftSim.CustomerHistory.Craft.Legacy | CraftSim.CustomerHistory.ChatMessage.Legacy
            function (historyLegacy)
                if historyLegacy.from or historyLegacy.to then
                    return nil
                end
                local reagentState = Enum.CraftingOrderReagentsType.All
                if not historyLegacy.reagents or #historyLegacy.reagents == 0 then
                    reagentState = Enum.CraftingOrderReagentsType.None
                end 
                if CraftSim.GUTIL:Some(historyLegacy.reagents, function(r) return r.source == Enum.CraftingOrderReagentSource.Customer end) then
                    reagentState = Enum.CraftingOrderReagentsType.Some
                end
                ---@type CraftSim.CustomerHistory.Craft
                local craft = {
                    customerNotes = "",
                    date = C_DateAndTime.GetCalendarTimeFromEpoch(historyLegacy.timestamp),
                    itemLink = historyLegacy.crafted,
                    reagentState = reagentState,
                    reagents = historyLegacy.reagents,
                    tip = historyLegacy.commission
                }
                return craft
            end)

            customerHistory.totalOrders = #customerHistory.craftHistory

            CraftSim.CUSTOMER_HISTORY.DB:SaveCustomerHistory(customerHistory)
        end
    end
end

function CraftSim.CUSTOMER_HISTORY:Init()
    -- local s, e = pcall(CraftSim.CUSTOMER_HISTORY.MigrateDataV2)
    -- if not s then
    --     print(CraftSim.UTIL:GetFormatter().r("CustomerHistoryLegacy Migration failed:\n" .. tostring(e)))
    -- else
    --     print(CraftSim.UTIL:GetFormatter().g("CustomerHistoryLegacy Migration succeded"))
    -- end
end

function CraftSim.CUSTOMER_HISTORY:CHAT_MSG_WHISPER(message, fullSenderName)
    local sender, realm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(fullSenderName)

    CraftSim.CUSTOMER_HISTORY:OnWhisper(sender, realm, message, false)
end
function CraftSim.CUSTOMER_HISTORY:CHAT_MSG_WHISPER_INFORM(message, _, _, _, fullTargetName)
    local target, targetRealm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(fullTargetName)

    CraftSim.CUSTOMER_HISTORY:OnWhisper(target, targetRealm, message, true)
end

---@param customer string
---@param customerRealm string
---@param message string
---@param fromPlayer boolean
function CraftSim.CUSTOMER_HISTORY:OnWhisper(customer, customerRealm, message, fromPlayer)
    print("OnWhisper")
    print("sender: " .. tostring(customer))
    print("realm: " .. tostring(customerRealm))
    print("message: " .. tostring(message))
    print("fromPlayer: " .. tostring(fromPlayer))

    local customerHistory = CraftSim.CUSTOMER_HISTORY.DB:GetCustomerHistory(customer, customerRealm)
    ---@type CraftSim.CustomerHistory.ChatMessage
    local chatMessage = {
        content=message,
        fromPlayer=fromPlayer,
        date=C_DateAndTime.GetCurrentCalendarTime()
    }
    table.insert(customerHistory.chatHistory, chatMessage)
    CraftSim.CUSTOMER_HISTORY.DB:SaveCustomerHistory(customerHistory)
end

---@param result Enum.CraftingOrderResult
---@param orderID number
function CraftSim.CUSTOMER_HISTORY:CRAFTINGORDERS_FULFILL_ORDER_RESPONSE(result, orderID)
    if result ~= Enum.CraftingOrderResult.Ok then
        return -- do not save any history
    end

    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    if claimedOrder then
        print("Claimed Order: ", false, true)
        print(claimedOrder, true)
        local customer, realm =  CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(claimedOrder.customerName)
        local customerHistory = CraftSim.CUSTOMER_HISTORY.DB:GetCustomerHistory(customer, realm)
        ---@type CraftSim.CustomerHistory.Craft
        local customerCraft = {
            date = C_DateAndTime.GetCurrentCalendarTime(),
            itemLink = claimedOrder.outputItemHyperlink,
            tip = claimedOrder.tipAmount,
            reagents = claimedOrder.reagents,
            customerNotes = claimedOrder.customerNotes or "",
            reagentState = claimedOrder.reagentState,
        }
        table.insert(customerHistory.craftHistory, customerCraft)
        customerHistory.totalOrders = customerHistory.totalOrders + 1
        customerHistory.totalTip = customerHistory.totalTip + customerCraft.tip
        if customerCraft.reagentState == Enum.CraftingOrderReagentsType.All then
            customerHistory.provisionAll = customerHistory.provisionAll + 1
        elseif customerCraft.reagentState == Enum.CraftingOrderReagentsType.Some then
            customerHistory.provisionSome = customerHistory.provisionSome + 1
        elseif customerCraft.reagentState == Enum.CraftingOrderReagentsType.None then
            customerHistory.provisionNone = customerHistory.provisionNone + 1
        end

        CraftSim.CUSTOMER_HISTORY.DB:SaveCustomerHistory(customerHistory)
    end
end

--- LEGACY

function CraftSim.CUSTOMER_HISTORY:OnOrderFinished(event, result, orderID)
    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    print("Order finished " .. event .. " : " .. tostring(result) .. " : " .. tostring(orderID))
    print(claimedOrder)

    if (claimedOrder and event == "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" and result == 0) then
        if (not string.find(claimedOrder.customerName, "-")) then
            claimedOrder.customerName = claimedOrder.customerName .. "-" .. GetRealmName()
        end
        self.db.realm[claimedOrder.customerName] = self.db.realm[claimedOrder.customerName] or {}
        self.db.realm[claimedOrder.customerName].history = self.db.realm[claimedOrder.customerName].history or {}
        table.insert(self.db.realm[claimedOrder.customerName].history, {crafted = claimedOrder.outputItemHyperlink, commission = claimedOrder.tipAmount, reagents = claimedOrder.reagents, timestamp = math.floor((time()+GetTime()%1)*1000)})
        self.db.realm[claimedOrder.customerName].totalTip = (self.db.realm[claimedOrder.customerName].totalTip or 0) + claimedOrder.tipAmount
        while (table.getn(self.db.realm[claimedOrder.customerName].history) > CraftSimOptions.maxHistoryEntriesPerClient) do
            table.remove(self.db.realm[claimedOrder.customerName].history, 1)
        end
        CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(claimedOrder.customerName)
    end
end

---@param fullName string
---@return string name, string realm
function CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(fullName)
    local name, realm = string.split("-", fullName, 2)
    realm = realm or GetRealmName()
    return name, realm
end
