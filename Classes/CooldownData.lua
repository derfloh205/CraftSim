---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CooldownData : CraftSim.CraftSimObject
---@overload fun(recipeID: RecipeID): CraftSim.CooldownData
CraftSim.CooldownData = CraftSim.CraftSimObject:extend()

local print = CraftSim.DEBUG:RegisterLogger("Classes.CooldownData")

---@param recipeID RecipeID
function CraftSim.CooldownData:new(recipeID)
    self.recipeID = recipeID
    self.isCooldownRecipe = false
    self.currentCharges = 0
    self.maxCharges = 0
    self.startTime = 0              -- seconds with ms precision, starttime for charge 1
    self.startTimeCurrentCharge = 0 -- seconds with ms precision, starttime for charge 1
    self.cooldownPerCharge = 0      -- with cd reductions included
    ---@type CraftSim.SHARED_PROFESSION_COOLDOWNS
    self.sharedCD = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID]
end

---@return CraftSim.CooldownData
function CraftSim.CooldownData:Copy()
    local copy = CraftSim.CooldownData(self.recipeID)
    copy.isCooldownRecipe = self.isCooldownRecipe
    copy.currentCharges = self.currentCharges
    copy.maxCharges = self.maxCharges
    copy.startTime = self.startTime
    copy.startTimeCurrentCharge = self.startTimeCurrentCharge
    copy.cooldownPerCharge = self.cooldownPerCharge
    return copy
end

function CraftSim.CooldownData:Update()
    local currentCooldown, isDayCooldown, currentCharges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(self.recipeID)
    currentCooldown = currentCooldown or 0
    -- some new recipes in TWW are not marked as day cds even if they are... like inventing
    -- they only have a cd shown when on cd otherwise same info as regular recipes.. great
    self.isCooldownRecipe = isDayCooldown or (maxCharges and maxCharges > 0) or currentCooldown > 0
    if not self.isCooldownRecipe then
        return
    end

    print("Update Recipe Cooldown: " .. tostring(self.recipeID))
    self.currentCharges = tonumber(currentCharges) or 0
    self.maxCharges = maxCharges or 0

    -- daily cooldowns will be treated as cooldown recipes with 1 charge and a cooldown of 24h per charge
    if isDayCooldown or (self.maxCharges == 0 and currentCooldown > 0) then
        print("Is Day Cooldown or other cooldown")
        local spellCooldownInfo = C_Spell.GetSpellCooldown(self.recipeID)
        self.cooldownPerCharge = spellCooldownInfo.duration
        self.maxCharges = 1
        self.currentCharges = 1
        if spellCooldownInfo.startTime > 0 then
            self.currentCharges = 0
            local elapsedTimeSinceCooldownStart = (self.cooldownPerCharge - currentCooldown)
            self.startTimeCurrentCharge = GetServerTime() - elapsedTimeSinceCooldownStart
            self.startTime = self.startTimeCurrentCharge
        end
    else
        print("not IsDayCooldown")
        local spellCharges = C_Spell.GetSpellCharges(self.recipeID)
        self.cooldownPerCharge = (spellCharges and spellCharges.cooldownDuration) or 0
        local apiCharges = tonumber(currentCharges) or 0
        if apiCharges < self.maxCharges and self.cooldownPerCharge > 0 then
            local elapsedTimeSinceCooldownStart = (self.cooldownPerCharge - currentCooldown)
            self.startTimeCurrentCharge = GetServerTime() - elapsedTimeSinceCooldownStart
            self.startTime = math.max(self.startTimeCurrentCharge - apiCharges * self.cooldownPerCharge, 0)
        elseif self.maxCharges > 0 and self.cooldownPerCharge > 0 then
            -- At max charges: anchor startTime so charge/timer math does not use a stale partial-charge baseline.
            self.startTime = GetServerTime() - self.cooldownPerCharge * self.maxCharges
            self.startTimeCurrentCharge = self.startTime
        end
    end
end

---@return boolean onCooldown
function CraftSim.CooldownData:OnCooldown()
    if not self.isCooldownRecipe then return false end

    return self:GetCurrentCharges() == 0 and self.maxCharges > 0
end

function CraftSim.CooldownData:GetStartTimeCurrentCharge()
    if self.maxCharges > 0 then
        local charges = self:GetCurrentCharges()
        return self.startTime + (charges * self.cooldownPerCharge)
    end
end

--- crafting character independent
---@return string formattedTimerString
---@return boolean ready
function CraftSim.CooldownData:GetFormattedTimerNextCharge()
    local currentTime = GetServerTime()
    if self.maxCharges > 0 then
        local charges = self:GetCurrentCharges()

        print("GetFormattedTimerNextCharge", false, true)

        if charges == self.maxCharges then
            return "00:00:00", true
        end

        local startTimeCurrentCharge = self:GetStartTimeCurrentCharge()
        local restTime = math.max((startTimeCurrentCharge + self.cooldownPerCharge) - currentTime, 0)
        local restTimeDate = date("!*t", restTime)

        return string.format("%02d:%02d:%02d", restTimeDate.hour, restTimeDate.min, restTimeDate.sec), false
    end

    return "", false
end

function CraftSim.CooldownData:GetAllChargesFullTimestamp()
    if self.maxCharges > 0 then
        return self.startTime + self.cooldownPerCharge * self.maxCharges
    end
end

function CraftSim.CooldownData:GetCurrentCharges()
    if self.maxCharges > 0 then
        -- Prefer live API (avoids stale startTime when at full charges or after Deserialize).
        local _, _, apiCharges, apiMax = C_TradeSkillUI.GetRecipeCooldown(self.recipeID)
        if apiCharges ~= nil and apiMax ~= nil and apiMax > 0 then
            return math.min(math.max(apiCharges, 0), apiMax)
        end
        if self.cooldownPerCharge and self.cooldownPerCharge > 0 then
            local currentTime = GetServerTime()
            local diffTotal = currentTime - (self.startTime or 0)
            local interpolated = math.floor(diffTotal / self.cooldownPerCharge)
            return math.min(math.max(interpolated, 0), self.maxCharges)
        end
        local snap = tonumber(self.currentCharges)
        if snap ~= nil then
            return math.min(math.max(snap, 0), self.maxCharges)
        end
        return 0
    end
end

---@return string formattedString
---@return boolean ready
function CraftSim.CooldownData:GetAllChargesFullDateFormatted()
    local allChargesFullTime = self:GetAllChargesFullTimestamp()

    local date = date("*t", allChargesFullTime) -- with local time support

    return string.format("%02d.%02d.%d %02d:%02d", date.day, date.month, date.year, date.hour, date.min),
        GetServerTime() <= allChargesFullTime
end

---@param crafterUID CrafterUID
function CraftSim.CooldownData:Save(crafterUID)
    CraftSim.DB.CRAFTER:SaveRecipeCooldownData(crafterUID, self.recipeID, self)
end

---@class CraftSim.CooldownData.Serialized
---@field recipeID RecipeID
---@field currentCharges number
---@field maxCharges number
---@field startTime number
---@field cooldownPerCharge number?
---@field sharedCD CraftSim.SHARED_PROFESSION_COOLDOWNS?

function CraftSim.CooldownData:Serialize()
    -- calculate startTime by using cooldown
    ---@type CraftSim.CooldownData.Serialized
    local serialized = {
        recipeID = self.recipeID,
        currentCharges = self.currentCharges,
        maxCharges = self.maxCharges,
        startTime = self.startTime,
        cooldownPerCharge = self.cooldownPerCharge,
        sharedCD = self.sharedCD,
    }
    return serialized
end

---@param serialized CraftSim.CooldownData.Serialized
---@return CraftSim.CooldownData
function CraftSim.CooldownData:Deserialize(serialized)
    local cooldownData = CraftSim.CooldownData(serialized.recipeID)
    cooldownData.currentCharges = serialized.currentCharges
    cooldownData.maxCharges = serialized.maxCharges
    cooldownData.startTime = serialized.startTime
    cooldownData.cooldownPerCharge = serialized.cooldownPerCharge
    cooldownData.sharedCD = serialized.sharedCD
    return cooldownData
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return CraftSim.CooldownData
function CraftSim.CooldownData:DeserializeForCrafter(crafterUID, recipeID)
    local serializedCooldownData = CraftSim.DB.CRAFTER:GetRecipeCooldownData(crafterUID, recipeID)

    if serializedCooldownData then
        local data = CraftSim.CooldownData:Deserialize(serializedCooldownData)
        data.isCooldownRecipe = true
        return data
    else
        return CraftSim.CooldownData(recipeID)
    end
end
