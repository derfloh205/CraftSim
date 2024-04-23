---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CUSTOMER_HISTORY
CraftSim.CUSTOMER_HISTORY = CraftSim.CUSTOMER_HISTORY

---@class CraftSim.CUSTOMER_HISTORY.DB
CraftSim.CUSTOMER_HISTORY.DB = {}

--- Legacy
---@class CraftSim.CustomerHistory.Legacy
---@field totalTip number
---@field history CraftSim.CustomerHistory.Craft.Legacy | CraftSim.CustomerHistory.ChatMessage.Legacy

---@class CraftSim.CustomerHistory.Craft.Legacy
---@field crafted string itemLink
---@field commission number tip
---@field reagents CraftingOrderReagentInfo[]
---@field timestamp number ms unix ts

---@class CraftSim.CustomerHistory.ChatMessage.Legacy
---@field from string? message if from player
---@field to string? message if from customer
---@field timestamp number ms unix ts

local DB_VERSION = 2
--- V2
---@class CraftSim.CustomerHistory
---@field v number -- data version
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
---@field timestamp number unix ts in seconds

---@class CraftSim.CustomerHistory.Craft
---@field itemLink string
---@field tip number
---@field reagents CraftingOrderReagentInfo[]
---@field reagentState Enum.CraftingOrderReagentsType
---@field timestamp number unix ts in seconds
---@field customerNotes string

---@type CraftSim.CustomerHistory[]
CraftSimCustomerHistoryV2 = CraftSimCustomerHistoryV2 or {}

---@param customer string
---@param realm string
---@return CraftSim.CustomerHistory
function CraftSim.CUSTOMER_HISTORY.DB:GetCustomerHistory(customer, realm)
    ---@type CraftSim.CustomerHistory
    local defaultCustomerHistory = {
        v = DB_VERSION,
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
    local maxEntriesPerClient = CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT")
    --- limit chat history to a certain amount of messages
    CraftSim.GUTIL:TrimTable(customerHistory.chatHistory, maxEntriesPerClient, true)

    CraftSimCustomerHistoryV2[customerHistory.customer .. "-" .. customerHistory.realm] = customerHistory
end

---@param customerHistory CraftSim.CustomerHistory
function CraftSim.CUSTOMER_HISTORY.DB:RemoveCustomerHistory(customerHistory)
    CraftSimCustomerHistoryV2[customerHistory.customer .. "-" .. customerHistory.realm] = nil
end

function CraftSim.CUSTOMER_HISTORY.DB:PurgeZeroTipCustomers()
    for key, customerHistory in pairs(CraftSimCustomerHistoryV2 or {}) do
        if not customerHistory.totalTip or customerHistory.totalTip <= 0 then
            CraftSimCustomerHistoryV2[key] = nil
        end
    end
end
