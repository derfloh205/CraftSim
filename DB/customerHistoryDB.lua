---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.CUSTOMER_HISTORY : CraftSim.DB.Repository
CraftSim.DB.CUSTOMER_HISTORY = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:RegisterDebugID("Database.customerHistoryDB")

---@alias CustomerID string

---@class CraftSim.DB.CustomerHistory
---@field customer string
---@field realm string
---@field chatHistory CraftSim.DB.CustomerHistory.ChatMessage[]
---@field craftHistory CraftSim.DB.CustomerHistory.Craft[]
---@field totalTip number
---@field totalOrders number
---@field provisionAll number
---@field provisionSome number
---@field provisionNone number
---@field npc boolean

---@class CraftSim.DB.CustomerHistory.ChatMessage
---@field fromPlayer boolean
---@field content string
---@field timestamp number unix ts in seconds

---@class CraftSim.DB.CustomerHistory.Craft
---@field itemLink string
---@field tip number
---@field reagents CraftingOrderReagentInfo[]
---@field reagentState Enum.CraftingOrderReagentsType
---@field timestamp number unix ts in seconds
---@field customerNotes string

function CraftSim.DB.CUSTOMER_HISTORY:Init()
    if not CraftSimDB.customerHistoryDB then
        ---@type CraftSimDB.Database
        CraftSimDB.customerHistoryDB = {
            version = 0,
            ---@type table<CustomerID, CraftSim.DB.CustomerHistory>
            data = {},
        }
    end

    CraftSimDB.customerHistoryDB.data = CraftSimDB.customerHistoryDB.data or {}
end

function CraftSim.DB.CUSTOMER_HISTORY:Migrate()
    -- 0 -> 1
    if CraftSimDB.customerHistoryDB.version == 0 then
        local CraftSimCustomerHistoryV2 = _G["CraftSimCustomerHistoryV2"]
        if CraftSimCustomerHistoryV2 then
            for _, data in pairs(CraftSimCustomerHistoryV2) do
                data["v"] = nil
            end
            CraftSimDB.customerHistoryDB.data = CraftSimCustomerHistoryV2
        end
        CraftSimDB.customerHistoryDB.version = 1
    end
end

function CraftSim.DB.CUSTOMER_HISTORY:ClearAll()
    wipe(CraftSimDB.customerHistoryDB.data)
end

function CraftSim.DB.CUSTOMER_HISTORY:CleanUp()
    if _G["CraftSimCustomerHistoryV2"] then
        _G["CraftSimCustomerHistoryV2"] = nil
    end
end

---@return table<CustomerID, CraftSim.DB.CustomerHistory>
function CraftSim.DB.CUSTOMER_HISTORY:GetAll()
    return CraftSimDB.customerHistoryDB.data
end

function CraftSim.DB.CUSTOMER_HISTORY:Count()
    return GUTIL:Count(CraftSimDB.customerHistoryDB.data)
end

---@param customer string
---@param realm string
---@return CraftSim.DB.CustomerHistory
function CraftSim.DB.CUSTOMER_HISTORY:Get(customer, realm)
    CraftSimDB.customerHistoryDB.data[customer .. "-" .. realm] = CraftSimDB.customerHistoryDB.data
        [customer .. "-" .. realm] or {
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
    return CraftSimDB.customerHistoryDB.data[customer .. "-" .. realm]
end

---@param customerHistory CraftSim.DB.CustomerHistory
function CraftSim.DB.CUSTOMER_HISTORY:Save(customerHistory)
    local maxEntriesPerClient = CraftSim.DB.OPTIONS:Get("CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT")
    --- limit chat history to a certain amount of messages
    CraftSim.GUTIL:TrimTable(customerHistory.chatHistory, maxEntriesPerClient, true)

    CraftSimDB.customerHistoryDB.data[customerHistory.customer .. "-" .. customerHistory.realm] = customerHistory
end

---@param customerHistory CraftSim.DB.CustomerHistory
function CraftSim.DB.CUSTOMER_HISTORY:Delete(customerHistory)
    CraftSimDB.customerHistoryDB.data[customerHistory.customer .. "-" .. customerHistory.realm] = nil
end

---@param minimumTip number
function CraftSim.DB.CUSTOMER_HISTORY:PurgeCustomers(minimumTip)
    for customerID, customerHistory in pairs(CraftSimDB.customerHistoryDB.data) do
        if not customerHistory.totalTip or customerHistory.totalTip <= minimumTip then
            CraftSimDB.customerHistoryDB.data[customerID] = nil
        end
    end
end
