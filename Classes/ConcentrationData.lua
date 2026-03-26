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

---@return number totalHoursUntilMax
function CraftSim.ConcentrationData:GetHoursUntilMax()
    local restTime = self:GetTimeUntilMax()
    local restTimeDate = date("!*t", restTime)
    return ((restTimeDate.day - 1) * 24) + restTimeDate.hour
end

---@param concentrationValue number
---@return number Unix timestamp when that amount will be reached
function CraftSim.ConcentrationData:GetTimestampUntil(concentrationValue)
    return GetServerTime() + self:GetTimeUntil(concentrationValue)
end

---@param concentrationValue number
---@param useUSFormat? boolean when true, format as MM/DD HH:MM instead of DD.MM HH:MM
---@return string dateTime
function CraftSim.ConcentrationData:GetFormattedDateUntil(concentrationValue, useUSFormat)
    local timestamp = self:GetTimestampUntil(concentrationValue)
    local t = date("*t", timestamp)
    if useUSFormat then
        return string.format("%02d/%02d %02d:%02d", t.month, t.day, t.hour, t.min)
    else
        return string.format("%02d.%02d %02d:%02d", t.day, t.month, t.hour, t.min)
    end
end

function CraftSim.ConcentrationData:GetTimestampMax()
    return self:GetTimestampUntil(self.maxQuantity)
end

---@return string formattedMax
function CraftSim.ConcentrationData:GetFormattedDateMax()
    local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
    if formatMode == "HOURS_LEFT" then
        local restHours = self:GetHoursUntilMax()
        return string.format("%dh", restHours)
    else
        return self:GetFormattedDateUntil(self.maxQuantity, formatMode == "AMERICA_MAX_DATE")
    end
end

---@param requiredAmount number
---@param requiredAmount number
---@param useUSFormat? boolean passed through to GetFormattedDateUntil
---@return string? localized text with estimated time (date in blue), or nil if already have enough
function CraftSim.ConcentrationData:GetEstimatedTimeUntilEnoughText(requiredAmount, useUSFormat)
    if self:GetCurrentAmount() >= requiredAmount then
        return nil
    end
    local formattedDate = self:GetFormattedDateUntil(requiredAmount, useUSFormat)
    local f = CraftSim.GUTIL:GetFormatter()
    return string.format(CraftSim.LOCAL:GetText("CONCENTRATION_ESTIMATED_TIME_UNTIL"), f.bb(formattedDate))
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
