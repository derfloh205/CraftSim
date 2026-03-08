---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL


---@class CraftSim.OptionalReagentSlot : CraftSim.CraftSimObject
CraftSim.OptionalReagentSlot = CraftSim.CraftSimObject:extend()

---@param reagentSlotSchematic CraftingReagentSlotSchematic
---@param recipeData CraftSim.RecipeData
function CraftSim.OptionalReagentSlot:new(recipeData, reagentSlotSchematic)
    -- self.recipeData = recipeData
    if not recipeData or not reagentSlotSchematic then
        return
    end
    self.dataSlotIndex = reagentSlotSchematic.dataSlotIndex
    ---@type CraftSim.OptionalReagent[]
    self.possibleReagents = {}
    self.craftingReagentSlotSchematic = reagentSlotSchematic
    self.required = reagentSlotSchematic.required
    self.maxQuantity = reagentSlotSchematic.quantityRequired or 1

    if reagentSlotSchematic.slotInfo and reagentSlotSchematic.slotInfo.mcrSlotID then
        self.slotText = reagentSlotSchematic.slotInfo.slotText
        self.mcrSlotID = reagentSlotSchematic.slotInfo.mcrSlotID
        self.locked, self.lockedReason = C_TradeSkillUI.GetReagentSlotStatus(reagentSlotSchematic.slotInfo.mcrSlotID,
            recipeData.recipeID, recipeData.professionData.skillLineID)
    end

    for _, reagent in pairs(reagentSlotSchematic.reagents) do
        table.insert(self.possibleReagents, CraftSim.OptionalReagent(reagent))
    end
end

---@return boolean isAllocated
function CraftSim.OptionalReagentSlot:IsAllocated()
    return self.activeReagent ~= nil
end

---@return boolean isCurrency
function CraftSim.OptionalReagentSlot:IsCurrency()
    return self.possibleReagents and self.possibleReagents[1] and self.possibleReagents[1].currencyID ~= nil
end

---@param itemID ItemID
---@return boolean isPossibleReagent
function CraftSim.OptionalReagentSlot:IsPossibleReagent(itemID)
    if self:IsCurrency() then return false end
    return GUTIL:Some(self.possibleReagents, function(possibleReagent)
        return possibleReagent.item and possibleReagent.item:GetItemID() == itemID
    end)
end

---@param currencyID number
---@return boolean isPossibleReagent
function CraftSim.OptionalReagentSlot:IsPossibleCurrencyReagent(currencyID)
    if not self:IsCurrency() then return false end
    return GUTIL:Some(self.possibleReagents, function(possibleReagent)
        return possibleReagent.currencyID == currencyID
    end)
end

---@param recipeData CraftSim.RecipeData
---@return boolean isOrderReagent
function CraftSim.OptionalReagentSlot:IsOrderReagentIn(recipeData)
    if not self.activeReagent then return false end

    return self.activeReagent:IsOrderReagentIn(recipeData)
end

---@param itemID number?
function CraftSim.OptionalReagentSlot:SetReagent(itemID)
    if not itemID then
        self.activeReagent = nil
        return
    end

    ---@type CraftSim.OptionalReagent?
    self.activeReagent = CraftSim.GUTIL:Find(self.possibleReagents,
        function(possibleReagent) return possibleReagent.item and possibleReagent.item:GetItemID() == itemID end)
end

---@param currencyID number?
function CraftSim.OptionalReagentSlot:SetCurrencyReagent(currencyID)
    if not currencyID then
        self.activeReagent = nil
        return
    end

    ---@type CraftSim.OptionalReagent?
    self.activeReagent = CraftSim.GUTIL:Find(self.possibleReagents,
        function(possibleReagent) return possibleReagent.currencyID == currencyID end)
end

---@return CraftingReagentInfo?
function CraftSim.OptionalReagentSlot:GetCraftingReagentInfo()
    if self.activeReagent then
        if self.activeReagent:IsCurrency() then
            return {
                reagent = {
                    itemID = nil,
                    currencyID = self.activeReagent.currencyID,
                },
                dataSlotIndex = self.dataSlotIndex,
                quantity = self.maxQuantity,
            }
        else
            return {
                reagent = {
                    itemID = self.activeReagent.item:GetItemID(),
                    currencyID = nil,
                },
                dataSlotIndex = self.dataSlotIndex,
                quantity = self.maxQuantity,
            }
        end
    end
end

--- returns wether the player has enough the selected optional reagent
---@param multiplier number? default: 1
---@param crafterUID string
function CraftSim.OptionalReagentSlot:HasItem(multiplier, crafterUID)
    multiplier = multiplier or 1
    if not self.activeReagent then
        return true
    end

    if self.activeReagent:IsCurrency() then
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.activeReagent.currencyID)
        if not currencyInfo then return false end
        return currencyInfo.quantity >= (multiplier * self.maxQuantity)
    end

    local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, self.activeReagent.item:GetItemID())

    return itemCount >= (multiplier * self.maxQuantity)
end

--- check how many times the player can fulfill the allocated item quantity
---@param crafterUID string
function CraftSim.OptionalReagentSlot:HasQuantityXTimes(crafterUID)
    if not self.activeReagent then
        return math.huge -- yes I have infinite a number of times yes
    end

    if self.activeReagent:IsCurrency() then
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.activeReagent.currencyID)
        if not currencyInfo then return 0 end
        return currencyInfo.quantity * self.maxQuantity
    end

    local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, self.activeReagent.item:GetItemID())
    return itemCount * self.maxQuantity
end

function CraftSim.OptionalReagentSlot:Debug()
    local activeReagentText = "None"
    if self.activeReagent then
        if self.activeReagent:IsCurrency() then
            activeReagentText = "Currency:" .. tostring(self.activeReagent.currencyID) ..
                " (" .. tostring(self.activeReagent.name) .. ")"
        else
            activeReagentText = tostring(self.activeReagent.item:GetItemLink() or self.activeReagent.item:GetItemID())
        end
    end

    local debugLines = {
        "slotText: " .. tostring(self.slotText),
        "dataSlotIndex: " .. tostring(self.dataSlotIndex),
        "isCurrency: " .. tostring(self:IsCurrency()),
        "locked: " .. tostring(self.locked),
        "lockedReason: " .. tostring(self.lockedReason),
        "activeReagent: " .. activeReagentText,
        "possibleReagents: ",
    }

    for _, reagent in pairs(self.possibleReagents) do
        debugLines = CraftSim.GUTIL:Concat({ debugLines, reagent:Debug() })
    end

    return debugLines
end

function CraftSim.OptionalReagentSlot:Copy(recipeData)
    local copy = CraftSim.OptionalReagentSlot(recipeData)
    copy.possibleReagents = CraftSim.GUTIL:Map(self.possibleReagents, function(r) return r:Copy() end)
    if self.activeReagent then
        if self.activeReagent:IsCurrency() then
            copy.activeReagent = CraftSim.GUTIL:Find(copy.possibleReagents,
                function(r) return r.currencyID == self.activeReagent.currencyID end)
        else
            copy.activeReagent = CraftSim.GUTIL:Find(copy.possibleReagents,
                function(r) return r.item and r.item:GetItemID() == self.activeReagent.item:GetItemID() end)
        end
    end

    copy.slotText = self.slotText
    copy.dataSlotIndex = self.dataSlotIndex
    copy.locked = self.locked
    copy.lockedReason = self.lockedReason
    copy.maxQuantity = self.maxQuantity

    return copy
end

---@class CraftSim.OptionalReagentSlot.Serialized
---@field possibleReagents CraftSim.OptionalReagent.Serialized[]
---@field slotText string
---@field dataSlotIndex number
---@field locked boolean
---@field lockedReason? string
---@field maxQuantity number

---Serializes the optionalReagentSlot for sending via the addon channel
---@return CraftSim.OptionalReagentSlot.Serialized
function CraftSim.OptionalReagentSlot:Serialize()
    local serialized = {}
    serialized.slotText = self.slotText
    serialized.dataSlotIndex = self.dataSlotIndex
    serialized.locked = self.locked
    serialized.lockedReason = self.lockedReason
    serialized.possibleReagents = CraftSim.GUTIL:Map(self.possibleReagents, function(optionalReagent)
        return optionalReagent:Serialize()
    end)
    serialized.maxQuantity = self.maxQuantity or 1
    return serialized
end

---Deserializes the optionalReagentSlot
---@param serializedOptionalReagentSlot CraftSim.OptionalReagentSlot.Serialized
---@return CraftSim.OptionalReagentSlot
function CraftSim.OptionalReagentSlot:Deserialize(serializedOptionalReagentSlot)
    local deserialized = CraftSim.OptionalReagentSlot()
    deserialized.slotText = serializedOptionalReagentSlot.slotText
    deserialized.dataSlotIndex = tonumber(serializedOptionalReagentSlot.dataSlotIndex)
    deserialized.locked = not not serializedOptionalReagentSlot
        .locked -- is this enough to deserialize a boolean? or do I need to parse a string?
    deserialized.lockedReason = serializedOptionalReagentSlot.lockedReason
    deserialized.possibleReagents = CraftSim.GUTIL:Map(serializedOptionalReagentSlot.possibleReagents,
        function(serializedOptionalReagent)
            return CraftSim.OptionalReagent:Deserialize(serializedOptionalReagent)
        end)
    deserialized.maxQuantity = self.maxQuantity or 1
    return deserialized
end

function CraftSim.OptionalReagentSlot:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:AddList("possibleReagents", self.possibleReagents)
    jb:Add("activeReagent", self.activeReagent)
    jb:Add("slotText", self.slotText)
    jb:Add("dataSlotIndex", self.dataSlotIndex)
    jb:Add("locked", self.locked)
    jb:Add("maxQuantity", self.maxQuantity)
    jb:Add("lockedReason", self.lockedReason, true)
    jb:End()
    return jb.json
end
