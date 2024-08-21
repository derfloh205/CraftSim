---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.CUSTOMER_HISTORY : Frame
CraftSim.CUSTOMER_HISTORY = GUTIL:CreateRegistreeForEvents(
    { "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" }
)

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_HISTORY)

function CraftSim.CUSTOMER_HISTORY:Init()
    CraftSim.CUSTOMER_HISTORY:AutoPurge()
end

function CraftSim.CUSTOMER_HISTORY:CHAT_MSG_WHISPER(message, fullSenderName)
    local sender, realm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(fullSenderName)

    -- DEBUG
    -- sender = "Smitey"
    -- realm = "Thrall"
    -- message = "Hello again! I thought maybe I should write a really long message to test the capacity for the the customer history and to see if the message will clip out or not. So anyway this is a really long message. Hi."
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

    local customerHistory = CraftSim.DB.CUSTOMER_HISTORY:Get(customer, customerRealm)
    ---@type CraftSim.DB.CustomerHistory.ChatMessage
    local chatMessage = {
        content = message,
        fromPlayer = fromPlayer,
        timestamp = C_DateAndTime.GetServerTimeLocal()
    }
    table.insert(customerHistory.chatHistory, chatMessage)
    CraftSim.DB.CUSTOMER_HISTORY:Save(customerHistory)
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
        local customer, realm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(claimedOrder.customerName)
        local customerHistory = CraftSim.DB.CUSTOMER_HISTORY:Get(customer, realm)
        ---@type CraftSim.DB.CustomerHistory.Craft
        local customerCraft = {
            timestamp = C_DateAndTime.GetServerTimeLocal(),
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

        CraftSim.DB.CUSTOMER_HISTORY:Save(customerHistory)
    end
end

---@param fullName string
---@return string name, string realm
function CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(fullName)
    local name, realm = string.split("-", fullName, 2)
    realm = realm or GetRealmName()
    return name, realm
end

function CraftSim.CUSTOMER_HISTORY:StartWhisper(name)
    ChatFrame_SendTell(name)
end

function CraftSim.CUSTOMER_HISTORY:PurgeZeroTipCustomers()
    CraftSim.DB.CUSTOMER_HISTORY:DeleteZeroTipCustomers()
    CraftSim.CUSTOMER_HISTORY.UI:UpdateCustomerHistoryList()
end

---@param customerHistory CraftSim.DB.CustomerHistory
function CraftSim.CUSTOMER_HISTORY:RemoveCustomer(row, customerHistory)
    CraftSim.DB.CUSTOMER_HISTORY:Delete(customerHistory)
    CraftSim.CUSTOMER_HISTORY.UI:UpdateDisplay()
    if row == CraftSim.CUSTOMER_HISTORY.frame.content.customerList.selectedRow then
        CraftSim.CUSTOMER_HISTORY.frame.content.customerList:SelectRow(1)
    end
end

function CraftSim.CUSTOMER_HISTORY:AutoPurge()
    if CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL") == 0 then
        return
    end
    if not CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE") then
        CraftSim.DB.CUSTOMER_HISTORY:DeleteZeroTipCustomers()
        CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE", C_DateAndTime.GetServerTimeLocal())
    else
        local currentTime = C_DateAndTime.GetServerTimeLocal()
        -- debug
        local dayDiff = GUTIL:GetDaysBetweenTimestamps(currentTime,
            CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE"))
        print("Day Difference:" .. dayDiff)

        if dayDiff >= CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL") then
            print("auto purge 0 tip customers.." .. tostring(dayDiff))
            CraftSim.DB.CUSTOMER_HISTORY:DeleteZeroTipCustomers()
            CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE", C_DateAndTime.GetServerTimeLocal())
        else
            print("do not purge, daydiff too low: " .. tostring(dayDiff))
        end
    end
end
