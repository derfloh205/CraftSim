---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.ConcentrationData : CraftSim.CraftSimObject
---@overload fun(currencyID : number): CraftSim.ConcentrationData
CraftSim.ConcentrationData = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterDebugID("Classes.ConcentrationData")

---@param currencyID number
function CraftSim.ConcentrationData:new(currencyID)
    self.currencyID = currencyID
    self.lastUpdated = 0 -- seconds with ms precision, ( GetServerTime )
    self.amount = 0
    self.rechargingDurationMS = 0
    self.maxQuantity = 0
end

---@return CraftSim.ConcentrationData
function CraftSim.ConcentrationData:Copy()
    local copy = CraftSim.ConcentrationData(self.currencyID)
    copy.lastUpdated = self.lastUpdated
    copy.amount = self.amount
    copy.rechargingDurationMS = self.rechargingDurationMS
    copy.maxQuantity = self.maxQuantity
    return copy
end

function CraftSim.ConcentrationData:Update()
    print("Updating ConcentrationData")
    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currencyID)
    if not currencyInfo then return end
    self.lastUpdated = GetServerTime() -- is in seconds
    self.amount = currencyInfo.quantity
    self.maxQuantity = currencyInfo.maxQuantity
    self.rechargingDurationMS = currencyInfo.rechargingCycleDurationMS
end

function CraftSim.ConcentrationData:GetCurrentAmount()
    local timeDiff = GetServerTime() - self.lastUpdated
    local fullCyclesCompletedSinceUpdate = timeDiff / (self.rechargingDurationMS / 1000)
    return math.min(self.maxQuantity, self.amount + fullCyclesCompletedSinceUpdate)
end

---@param concentrationValue number
---@return number time in seconds with ms precision
function CraftSim.ConcentrationData:GetTimeUntil(concentrationValue)
    local concentrationleft = math.max(0, concentrationValue - self:GetCurrentAmount())

    return concentrationleft * (self.rechargingDurationMS / 1000)
end

---@return number time in seconds with ms precision
function CraftSim.ConcentrationData:GetTimeUntilMax()
    if self.maxQuantity == 0 then
        return 0
    end

    return self:GetTimeUntil(self.maxQuantity)
end

---@param concentrationValue number
---@return string formattedTimer
---@return boolean ready
function CraftSim.ConcentrationData:GetFormattedTimerUntil(concentrationValue)
    if self:GetCurrentAmount() >= concentrationValue then
        return "00:00:00:00", true
    end

    local restTime = self:GetTimeUntil(concentrationValue)
    local restTimeDate = date("!*t", restTime)

    return string.format("%02d:%02d:%02d:%02d", restTimeDate.day - 1, restTimeDate.hour, restTimeDate.min,
            restTimeDate.sec),
        false
end

---@return string formattedTimer
---@return boolean ready
function CraftSim.ConcentrationData:GetFormattedTimerUntilMax()
    return self:GetFormattedTimerUntil(self.maxQuantity)
end

function CraftSim.ConcentrationData:GetTimestampMax()
    return GetServerTime() + self:GetTimeUntilMax()
end

function CraftSim.ConcentrationData:GetFormattedDateMax()
    local maxDate = self:GetTimestampMax()

    local date = date("*t", maxDate) -- with local time support

    return string.format("%02d.%02d %02d:%02d", date.day, date.month, date.hour, date.min),
        not self:OnCooldown()
end

function CraftSim.ConcentrationData:OnCooldown()
    return self:GetCurrentAmount() < self.maxQuantity
end

---@class CraftSim.ConcentrationData.Serialized
---@field currencyID number
---@field lastUpdated number
---@field maxQuantity number
---@field amount number
---@field rechargeTimePerPoint number

function CraftSim.ConcentrationData:Serialize()
    ---@type CraftSim.ConcentrationData.Serialized
    local serialized = {
        currencyID = self.currencyID,
        lastUpdated = self.lastUpdated,
        amount = self.amount,
        maxQuantity = self.maxQuantity,
        rechargeTimePerPoint = self.rechargingDurationMS,
    }
    return serialized
end

---@param serialized CraftSim.ConcentrationData.Serialized
---@return CraftSim.ConcentrationData
function CraftSim.ConcentrationData:Deserialize(serialized)
    local concentrationData = CraftSim.ConcentrationData(serialized.currencyID)
    concentrationData.lastUpdated = serialized.lastUpdated
    concentrationData.maxQuantity = serialized.maxQuantity
    concentrationData.amount = serialized.amount
    concentrationData.rechargingDurationMS = serialized.rechargeTimePerPoint
    return concentrationData
end
