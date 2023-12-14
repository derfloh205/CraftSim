_, CraftSim = ...

---@class CraftSim.CUSTOMER_HISTORY.DB
CraftSim.CUSTOMER_HISTORY.DB = {}

--- V2
---@class CraftSim.CustomerHistory
---@field customer string
---@field realm string
---@field chatHistory CraftSim.CustomerHistory.ChatMessage[]
---@field craftHistory CraftSim.CustomerHistory.Craft[]
---@field totalTip number
---@field totalOrders number
---@field provisionAll number
---@field provisionSome number
---@field provisionNone number

---@class CraftSim.CustomerHistory.ChatMessage
---@field fromPlayer boolean
---@field content string
---@field date CalendarTime

---@class CraftSim.CustomerHistory.Craft
---@field itemLink string
---@field tip number
---@field reagents CraftingOrderReagentInfo[]
---@field reagentState Enum.CraftingOrderReagentsType
---@field date CalendarTime
---@field customerNotes string

---@type CraftSim.CustomerHistory[]
CraftSimCustomerHistoryV2 = CraftSimCustomerHistoryV2 or {}

---@param customer string
---@param realm string
---@return CraftSim.CustomerHistory
function CraftSim.CUSTOMER_HISTORY.DB:GetCustomerHistory(customer, realm)
    ---@type CraftSim.CustomerHistory
    local defaultCustomerHistory = {
        chatHistory = {},
        craftHistory = {},
        customer = customer,
        realm = realm,
        totalTip = 0,
        totalOrders = 0,
        provisionAll = 0,
        provisionSome = 0,
        provisionNone = 0,
    }
    return CraftSimCustomerHistoryV2[customer .. "-" .. realm] or defaultCustomerHistory
end
---@param customerHistory CraftSim.CustomerHistory
function CraftSim.CUSTOMER_HISTORY.DB:SaveCustomerHistory(customerHistory)

    --- limit chat history to a certain amount of messages
    while (table.getn(customerHistory.chatHistory) > CraftSimOptions.maxHistoryEntriesPerClient) do
        table.remove(customerHistory.chatHistory, 1)
    end

    CraftSimCustomerHistoryV2[customerHistory.customer .. "-" .. customerHistory.realm] = customerHistory
end