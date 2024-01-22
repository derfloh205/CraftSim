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
    --- limit chat history to a certain amount of messages
    CraftSim.GUTIL:TrimTable(customerHistory.chatHistory, CraftSimOptions.maxHistoryEntriesPerClient, true)

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

-- MIGRATIONS

function CraftSim.CUSTOMER_HISTORY.DB:MigrateDataV2()
    print("Starting CustomerHistoryLegacy Migration")
    -- force a purge of zero tip customers for players who did not apply the workaround but still have problems with bloated history
    CraftSim.CUSTOMER_HISTORY:PurgeZeroTipCustomers()
    local playerRealm = GetRealmName()

    if CraftSimCustomerHistory and CraftSimCustomerHistory.realm and CraftSimCustomerHistory.realm[playerRealm] then
        ---@type table<string, CraftSim.CustomerHistory.Legacy>
        local realmData = CraftSimCustomerHistory.realm[playerRealm]
        for customerName, customerHistoryLegacy in pairs(realmData) do
            if type(customerHistoryLegacy) == "table" then
                -- only migrate customer
                print("Migrating Customer: " .. tostring(customerName))
                local name, realm = CraftSim.CUSTOMER_HISTORY:GetNameAndRealm(customerName)
                -- create customer history v2 in new db
                local customerHistory = CraftSim.CUSTOMER_HISTORY.DB:GetCustomerHistory(name, realm)

                customerHistory.totalTip = customerHistoryLegacy.totalTip
                customerHistory.chatHistory = CraftSim.GUTIL:Map(customerHistoryLegacy.history,
                    ---@param historyLegacy CraftSim.CustomerHistory.Craft.Legacy | CraftSim.CustomerHistory.ChatMessage.Legacy
                    function(historyLegacy)
                        if historyLegacy.crafted then
                            return nil
                        end
                        ---@type CraftSim.CustomerHistory.ChatMessage
                        local chatMessage = {
                            content = historyLegacy.from or historyLegacy.to,
                            timestamp = math.floor(historyLegacy.timestamp / 1000),
                            fromPlayer = historyLegacy.to ~= nil,
                        }
                        return chatMessage
                    end)

                local totalTip = 0
                customerHistory.craftHistory = CraftSim.GUTIL:Map(customerHistoryLegacy.history,
                    ---@param historyLegacy CraftSim.CustomerHistory.Craft.Legacy | CraftSim.CustomerHistory.ChatMessage.Legacy
                    function(historyLegacy)
                        if historyLegacy.from or historyLegacy.to then
                            return nil
                        end
                        local reagentState = Enum.CraftingOrderReagentsType.All
                        if not historyLegacy.reagents or #historyLegacy.reagents == 0 then
                            reagentState = Enum.CraftingOrderReagentsType.None
                        end
                        if CraftSim.GUTIL:Some(historyLegacy.reagents, function(r)
                                return r.source ==
                                    Enum.CraftingOrderReagentSource.Customer
                            end) then
                            reagentState = Enum.CraftingOrderReagentsType.Some
                        end
                        ---@type CraftSim.CustomerHistory.Craft
                        local craft = {
                            customerNotes = "",
                            timestamp = math.floor(historyLegacy.timestamp / 1000),
                            itemLink = historyLegacy.crafted,
                            reagentState = reagentState,
                            reagents = historyLegacy.reagents,
                            tip = historyLegacy.commission
                        }
                        totalTip = totalTip + craft.tip
                        return craft
                    end)

                customerHistory.totalOrders = #customerHistory.craftHistory
                customerHistory.totalTip = totalTip

                -- if the total tip is zero do not migrate

                if customerHistory.totalTip and customerHistory.totalTip > 0 then
                    CraftSim.CUSTOMER_HISTORY.DB:SaveCustomerHistory(customerHistory)
                end
            end
        end
    end
end
