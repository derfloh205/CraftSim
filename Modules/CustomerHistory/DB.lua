_, CraftSim = ...

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

--[[
    function CraftSim.CUSTOMER_HISTORY:HandleWhisper(event, message, customer, ...)
    self.db.realm[customer] = self.db.realm[customer] or {}
    self.db.realm[customer].history = self.db.realm[customer].history or {}
    if (event == "CHAT_MSG_WHISPER") then
        print("Received whisper from " .. customer .. " with message: " .. message)
        table.insert(self.db.realm[customer].history, {from = message, timestamp = math.floor((time()+GetTime()%1)*1000)})
    elseif (event == "CHAT_MSG_WHISPER_INFORM") then
        print("Sent whisper to " .. customer .. " with message: " .. message)
        table.insert(self.db.realm[customer].history, {to = message, timestamp = math.floor((time()+GetTime()%1)*1000)})
]]


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
        v = 2,
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
    CraftSim.GUTIL:TrimTable(customerHistory.chatHistory, CraftSimOptions.maxHistoryEntriesPerClient, true)

    CraftSimCustomerHistoryV2[customerHistory.customer .. "-" .. customerHistory.realm] = customerHistory
end