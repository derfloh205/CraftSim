CraftSimAddonName, CraftSim = ...

CraftSim.CUSTOMER_HISTORY = LibStub("AceAddon-3.0"):NewAddon("CraftSim.CUSTOMER_HISTORY", "AceComm-3.0", "AceEvent-3.0")

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_HISTORY)
local defaultDB = {
    realm = {
        version = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")
    }
}

function CraftSim.CUSTOMER_HISTORY:Init()
    self.db = LibStub("AceDB-3.0"):New("CraftSimCustomerHistory", defaultDB, true)
    -- self.db:ResetDB(false)
    CraftSim.CUSTOMER_HISTORY.MIGRATIONS:Migrate(self.db)
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhisper")
    self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", "HandleWhisper")
    self:RegisterEvent("TRADE_SKILL_SHOW", "LoadHistory")
    self:RegisterEvent("CRAFTINGORDERS_FULFILL_ORDER_RESPONSE", "OnOrderFinished")
    self:RegisterEvent("CRAFTINGORDERS_RELEASE_ORDER_RESPONSE", "OnOrderFinished")
    self:RegisterEvent("CRAFTINGORDERS_REJECT_ORDER_RESPONSE", "OnOrderFinished")
end

function CraftSim.CUSTOMER_HISTORY:HandleWhisper(event, message, customer, ...)
    self.db.realm[customer] = self.db.realm[customer] or {}
    self.db.realm[customer].history = self.db.realm[customer].history or {}
    if (event == "CHAT_MSG_WHISPER") then
        print("Received whisper from " .. customer .. " with message: " .. message)
        table.insert(self.db.realm[customer].history, {from = message, timestamp = math.floor((time()+GetTime()%1)*1000)})
    elseif (event == "CHAT_MSG_WHISPER_INFORM") then
        print("Sent whisper to " .. customer .. " with message: " .. message)
        table.insert(self.db.realm[customer].history, {to = message, timestamp = math.floor((time()+GetTime()%1)*1000)})
    end
    while (table.getn(self.db.realm[customer].history) > CraftSimOptions.maxHistoryEntriesPerClient) do
        table.remove(self.db.realm[customer].history, 1)
    end
    CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(customer)
end

function CraftSim.CUSTOMER_HISTORY:LoadHistory()
    CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(self.db.realm.lastCustomer)
end

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
