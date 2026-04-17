---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.CUSTOMER_HISTORY : Frame
---@field UI CraftSim.CUSTOMER_HISTORY.UI
---@field frame CraftSim.CUSTOMER_HISTORY.FRAME
CraftSim.CUSTOMER_HISTORY = GUTIL:CreateRegistreeForEvents(
    { "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" }
)

local Logger = CraftSim.DEBUG:RegisterLogger("CustomerHistory")

function CraftSim.CUSTOMER_HISTORY:Init()
    CraftSim.CUSTOMER_HISTORY:AutoPurge()
end

---@param result Enum.CraftingOrderResult
---@param orderID number
function CraftSim.CUSTOMER_HISTORY:CRAFTINGORDERS_FULFILL_ORDER_RESPONSE(result, orderID)
    if not CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_ENABLED") then return end

    if result ~= Enum.CraftingOrderResult.Ok then
        return -- do not save any history
    end

    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    if claimedOrder then
        if not CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_RECORD_PATRON_ORDERS") then
            if claimedOrder.orderType == Enum.CraftingOrderType.Npc then
                return
            end
        end

        Logger:LogDebug("Claimed Order: ", false, true)
        local customer, realm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(claimedOrder.customerName)
        local customerHistory = CraftSim.DB.CUSTOMER_HISTORY:Get(customer, realm)
        ---@type CraftSim.DB.CustomerHistory.Craft
        local customerCraft = {
            timestamp = C_DateAndTime.GetServerTimeLocal(),
            itemLink = claimedOrder.outputItemHyperlink,
            tip = tonumber(claimedOrder.tipAmount) or 0,
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

        customerHistory.npc = claimedOrder.orderType == Enum.CraftingOrderType.Npc

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

---@param minimumTip number
function CraftSim.CUSTOMER_HISTORY:PurgeCustomers(minimumTip)
    CraftSim.DB.CUSTOMER_HISTORY:PurgeCustomers(minimumTip)
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
    local tipThreshold = CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_REMOVAL_TIP_THRESHOLD")
    if CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL") == 0 then
        return
    end
    if not CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE") then
        CraftSim.DB.CUSTOMER_HISTORY:PurgeCustomers(tipThreshold)
        CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE", C_DateAndTime.GetServerTimeLocal())
    else
        local currentTime = C_DateAndTime.GetServerTimeLocal()
        -- debug
        local dayDiff = GUTIL:GetDaysBetweenTimestamps(currentTime,
            CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE"))
        Logger:LogDebug("Day Difference:" .. dayDiff)

        if dayDiff >= CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL") then
            Logger:LogDebug("auto purge 0 tip customers.." .. tostring(dayDiff))
            CraftSim.DB.CUSTOMER_HISTORY:PurgeCustomers(tipThreshold)
            CraftSim.DB.OPTIONS:Save("CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE", C_DateAndTime.GetServerTimeLocal())
        else
            Logger:LogDebug("do not purge, daydiff too low: " .. tostring(dayDiff))
        end
    end
end
