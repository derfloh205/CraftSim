---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CooldownData
---@overload fun(recipeID: RecipeID): CraftSim.CooldownData
CraftSim.CooldownData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint("COOLDOWNS")

---@param recipeID RecipeID
function CraftSim.CooldownData:new(recipeID)
    self.recipeID = recipeID
    self.isCooldownRecipe = false
    self.isDayCooldown = false
    self.currentCharges = 0
    self.maxCharges = 0
    self.startTime = 0              -- seconds with ms precision, starttime for charge 1
    self.startTimeCurrentCharge = 0 -- seconds with ms precision, starttime for charge 1
    self.cooldownPerCharge = 0      -- with cd reductions included
    ---@type CraftSim.SHARED_PROFESSION_COOLDOWNS
    self.sharedCD = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID]
end

function CraftSim.CooldownData:Update()
    local currentCooldown, isDayCooldown, currentCharges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(self.recipeID)
    currentCooldown = currentCooldown or 0
    self.isCooldownRecipe = isDayCooldown or (maxCharges and maxCharges > 0)
    if not self.isCooldownRecipe then
        return
    end

    print("Update Recipe Cooldown: " .. tostring(self.recipeID))
    self.isDayCooldown = isDayCooldown or false
    self.currentCharges = currentCharges
    self.maxCharges = maxCharges or 0

    if self.isDayCooldown then
        local _, maxCooldown = select(2, GetSpellCooldown(self.recipeID))
        self.maxCooldown = maxCooldown -- for day cooldowns only (cd reductions inclusive)
        local elapsedTimeSinceCooldownStart = (self.maxCooldown - currentCooldown)
        self.startTime = math.max(GetServerTime() - elapsedTimeSinceCooldownStart, 0)
    else
        self.cooldownPerCharge = select(4, GetSpellCharges(self.recipeID))
        if self.currentCharges < self.maxCharges then
            local elapsedTimeSinceCooldownStart = (self.cooldownPerCharge - currentCooldown)
            self.startTimeCurrentCharge = GetServerTime() - elapsedTimeSinceCooldownStart
            self.startTime = math.max(self.startTimeCurrentCharge - (currentCharges) * self.cooldownPerCharge, 0)
        end
    end
end

---@return boolean onCooldown
function CraftSim.CooldownData:OnCooldown()
    if not self.isCooldownRecipe then return false end

    if self.isDayCooldown or self.maxCharges == 0 then
        return GetServerTime() - (self.startTime + self.maxCooldown) <= 0
    else
        return self:GetCurrentCharges() == 0 and self.maxCharges > 0
    end
end

function CraftSim.CooldownData:GetStartTimeCurrentCharge()
    if self.maxCharges > 0 then
        local charges = self:GetCurrentCharges()
        return self.startTime + (charges * self.cooldownPerCharge)
    end

    if self.isDayCooldown or self.maxCharges == 0 then
        return self.startTime
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

    if self.isDayCooldown or self.maxCharges == 0 then
        local restTime = math.max((self.startTime + self.maxCooldown) - currentTime, 0)
        local restTimeDate = date("!*t", restTime)

        if restTime == 0 then
            return "00:00:00", true
        end

        return string.format("%02d:%02d:%02d", restTimeDate.hour, restTimeDate.min, restTimeDate.sec), false
    end
end

function CraftSim.CooldownData:GetAllChargesFullTimestamp()
    if self.maxCharges > 0 then
        return self.startTime + self.cooldownPerCharge * self.maxCharges
    end

    if self.isDayCooldown or self.maxCharges == 0 then
        return self.startTime + self.maxCooldown
    end
end

function CraftSim.CooldownData:GetCurrentCharges()
    if self.maxCharges > 0 then
        local currentTime = GetServerTime()
        local diffTotal = currentTime - self.startTime
        return math.floor(diffTotal / self.cooldownPerCharge)
    end

    if self.isDayCooldown or self.maxCharges == 0 then
        return 0
    end
end

function CraftSim.CooldownData:GetAllChargesFullDateFormatted()
    local allchargesFullTime = self:GetAllChargesFullTimestamp()

    local date = date("!*t", allchargesFullTime)

    return string.format("%02d.%02d.%d %02d:%02d", date.day, date.month, date.year, date.hour, date.min),
        GetServerTime() <= allchargesFullTime
end

---@param crafterUID CrafterUID
function CraftSim.CooldownData:Save(crafterUID)
    CraftSimRecipeDataCache.cooldownCache[crafterUID] = CraftSimRecipeDataCache.cooldownCache[crafterUID] or {}

    local serialized = self:Serialize()
    local serializationID = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[self.recipeID] or
        self.recipeID

    CraftSimRecipeDataCache.cooldownCache[crafterUID][serializationID] = serialized
end

---@class CraftSim.CooldownData.Serialized
---@field recipeID RecipeID
---@field isDayCooldown boolean
---@field currentCharges number
---@field maxCharges number
---@field startTime number
---@field cooldownPerCharge number?
---@field maxCooldown number?
---@field sharedCD CraftSim.SHARED_PROFESSION_COOLDOWNS?

function CraftSim.CooldownData:Serialize()
    -- calculate startTime by using cooldown
    ---@type CraftSim.CooldownData.Serialized
    local serialized = {
        recipeID = self.recipeID,
        isDayCooldown = self.isDayCooldown,
        currentCharges = self.currentCharges,
        maxCharges = self.maxCharges,
        startTime = self.startTime,
        cooldownPerCharge = self.cooldownPerCharge,
        maxCooldown = self.maxCooldown,
        sharedCD = self.sharedCD,
    }
    return serialized
end

---@param serialized CraftSim.CooldownData.Serialized
---@return CraftSim.CooldownData
function CraftSim.CooldownData:Deserialize(serialized)
    local cooldownData = CraftSim.CooldownData(serialized.recipeID)
    cooldownData.isDayCooldown = serialized.isDayCooldown
    cooldownData.currentCharges = serialized.currentCharges
    cooldownData.maxCharges = serialized.maxCharges
    cooldownData.startTime = serialized.startTime
    cooldownData.cooldownPerCharge = serialized.cooldownPerCharge
    cooldownData.maxCooldown = serialized.maxCooldown
    cooldownData.sharedCD = serialized.sharedCD
    return cooldownData
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return CraftSim.CooldownData
function CraftSim.CooldownData:DeserializeForCrafter(crafterUID, recipeID)
    CraftSimRecipeDataCache.cooldownCache[crafterUID] = CraftSimRecipeDataCache.cooldownCache[crafterUID] or {}

    local serializationID = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID] or
        recipeID

    local serializedCooldownData = CraftSimRecipeDataCache.cooldownCache[crafterUID][serializationID]

    if serializedCooldownData then
        return CraftSim.CooldownData:Deserialize(serializedCooldownData)
    else
        return CraftSim.CooldownData(recipeID)
    end
end
