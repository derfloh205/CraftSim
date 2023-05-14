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
    self.db.realm[customer].history = self.db.realm[customer].history or {}
    if (event == "CHAT_MSG_WHISPER") then
        print("Received whisper from " .. customer .. " with message: " .. message)
        self.db.realm[customer].history[math.floor((time()+GetTime()%1)*1000)] = {from = message}
    elseif (event == "CHAT_MSG_WHISPER_INFORM") then
        print("Sent whisper to " .. customer .. " with message: " .. message)
        self.db.realm[customer].history[math.floor((time()+GetTime()%1)*1000)] = {to = message}
    end
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

    if (claimedOrder and event == "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" and result == 0) then
        if (not string.find(claimedOrder.customerName, "-")) then
            claimedOrder.customerName = claimedOrder.customerName .. "-" .. GetRealmName()
        end
        self.db.realm[claimedOrder.customerName] = self.db.realm[claimedOrder.customerName] or {}
        self.db.realm[claimedOrder.customerName].history = self.db.realm[claimedOrder.customerName].history or {}
        self.db.realm[claimedOrder.customerName].history[math.floor((time()+GetTime()%1)*1000)] = {crafted = claimedOrder.outputItemHyperlink, commission = claimedOrder.tipAmount, reagents = claimedOrder.reagents}
        self.db.realm[claimedOrder.customerName].totalTip = (self.db.realm[claimedOrder.customerName].totalTip or 0) + claimedOrder.tipAmount
        CraftSim.CUSTOMER_HISTORY.FRAMES:AddCustomer(claimedOrder.customerName)
        CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(claimedOrder.customerName)
    end
end

function CraftSim.CUSTOMER_HISTORY:Pairs(history)
    local a = {}
    for n in pairs(history) do table.insert(a, n) end
    table.sort(a)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], history[a[i]]
        end
    end
    return iter
end