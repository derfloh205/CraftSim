AddonName, CraftSim = ...

CraftSim.CUSTOMER_HISTORY = LibStub("AceAddon-3.0"):NewAddon("CraftSim.CUSTOMER_HISTORY", "AceComm-3.0", "AceEvent-3.0")

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_HISTORY)
local defaultDB = {
    realm = {
    }
}

function CraftSim.CUSTOMER_HISTORY:Init()
    self.db = LibStub("AceDB-3.0"):New("CraftSimCustomerHistory", defaultDB, true)
    -- self.db:ResetDB(false)
    self:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhisper")
    self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", "HandleWhisper")
    self:RegisterEvent("TRADE_SKILL_SHOW", "LoadMessages")
    self:RegisterEvent("CRAFTINGORDERS_FULFILL_ORDER_RESPONSE", "OnOrderFinished")
    self:RegisterEvent("CRAFTINGORDERS_RELEASE_ORDER_RESPONSE", "OnOrderFinished")
    self:RegisterEvent("CRAFTINGORDERS_REJECT_ORDER_RESPONSE", "OnOrderFinished")
end

function CraftSim.CUSTOMER_HISTORY:HandleWhisper(event, message, customer, ...)
    self.db.realm[customer] = self.db.realm[customer] or {}
    self.db.realm[customer] = self.db.realm[customer] or {}
    if (event == "CHAT_MSG_WHISPER") then
        print("Received whisper from " .. customer .. " with message: " .. message)
        self.db.realm[customer].history[math.floor((time()+GetTime())*1000)] = {from = message}
    elseif (event == "CHAT_MSG_WHISPER_INFORM") then
        print("Sent whisper to " .. customer .. " with message: " .. message)
        self.db.realm[customer].history[math.floor((time()+GetTime())*1000)] = {to = message}
    end
    table.sort(CraftSim.CUSTOMER_HISTORY.db.realm[customer])
    CraftSim.CUSTOMER_HISTORY.FRAMES:AddCustomer(customer)
    CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(customer)
end

function CraftSim.CUSTOMER_HISTORY:LoadMessages()
    CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer()
    self:UnregisterEvent("TRADE_SKILL_SHOW")
end

function CraftSim.CUSTOMER_HISTORY:OnOrderFinished(event, result, orderID)
    local claimedOrder = C_CraftingOrders.GetClaimedOrder()
    print("Order finished " .. event .. " : " .. tostring(result) .. " : " .. tostring(orderID))
    print(claimedOrder)

    if (claimedOrder and event == CRAFTINGORDERS_FULFILL_ORDER_RESPONSE and result == 0) then
        self.db.realm[self.currentOrder.customerName].history[math.floor((time()+GetTime())*1000)] = {crafted = claimedOrder.outputItemHyperlink, commission = claimedOrder.tipAmount, reagents = claimedOrder.reagents}
        self.db.realm[self.currentOrder.customerName].totalTip = (self.db.realm[self.currentOrder.customerName].totalTip or 0) + claimedOrder.tipAmount
        table.sort(CraftSim.CUSTOMER_HISTORY.db.realm[self.currentOrder.customerName].history)
        CraftSim.CUSTOMER_HISTORY.FRAMES:AddCustomer(self.currentOrder.customerName)
        CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(self.currentOrder.customerName)
    end
end