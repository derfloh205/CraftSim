---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL


---@class CraftSim.OptionalReagent : CraftSim.CraftSimObject
CraftSim.OptionalReagent = CraftSim.CraftSimObject:extend()

---@param craftingReagent CraftingReagent
function CraftSim.OptionalReagent:new(craftingReagent)
    local reagentData = craftingReagent.currencyID ~= nil
        and CraftSim.OPTIONAL_CURRENCY_REAGENT_DATA[craftingReagent.currencyID]
        or CraftSim.OPTIONAL_REAGENT_DATA[craftingReagent.itemID]

    if craftingReagent.currencyID ~= nil then
        self.currencyID = craftingReagent.currencyID
    else
        self.item = Item:CreateFromItemID(craftingReagent.itemID)
    end
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()

    if reagentData then
        self.qualityID = reagentData.qualityID
        self.expansionID = reagentData.expansionID
        self.name = reagentData.name

        ---@type table<string, number>
        local stats = reagentData.stats or {}

        self.professionStats.recipeDifficulty.value = stats.increasedifficulty or 0

        self.professionStats.skill.value = stats.skill or 0
        self.professionStats.multicraft.value = stats.multicraft or 0
        self.professionStats.resourcefulness.value = stats.resourcefulness or 0
        self.professionStats.ingenuity.value = stats.ingenuity or 0

        if stats.reagentssavedfromresourcefulness then
            self.professionStats.resourcefulness:SetExtraValue(stats.reagentssavedfromresourcefulness / 100)
        end

        if stats.ingenuityrefundincrease then
            self.professionStats.ingenuity:SetExtraValue(stats.ingenuityrefundincrease / 100)
        end

        if stats.reduceconcentrationcost then
            self.professionStats.ingenuity:SetExtraValue(stats.reduceconcentrationcost / 100, 2)
        end

        if stats.craftingspeed then
            self.professionStats.craftingspeed:SetExtraValue(stats.craftingspeed / 100)
        end

        if stats.additionalitemscraftedwithmulticraft then
            self.professionStats.multicraft:SetExtraValue(stats.additionalitemscraftedwithmulticraft / 100)
        end

        -- ignore: modifyskillgain
    end
end

function CraftSim.OptionalReagent:IsCurrency()
    return self.currencyID ~= nil
end

--- Crest currencies (Mistcrest etc.) and enchanted crest items.
---@return boolean
function CraftSim.OptionalReagent:IsCrest()
    local name = self.name
    if not name or name == "" then
        if self:IsCurrency() then
            local currencyData = CraftSim.OPTIONAL_CURRENCY_REAGENT_DATA[self.currencyID]
            name = currencyData and currencyData.name
        elseif self.item then
            local reagentData = CraftSim.OPTIONAL_REAGENT_DATA[self.item:GetItemID()]
            name = reagentData and reagentData.name
        end
    end
    if not name then
        return false
    end
    return string.find(string.lower(name), "crest", 1, true) ~= nil
end

--- Returns the sum of all profession stat values contributed by this reagent.
--- Used to compare soulbound reagents of the same slot to find the highest-value one,
--- which is more reliable than comparing qualityID (different reagent items can share
--- the same qualityID while providing different stat amounts).
---@return number
function CraftSim.OptionalReagent:GetTotalStatValue()
    if not self.professionStats then return 0 end
    local total = 0
    for _, stat in ipairs(self.professionStats:GetStatList()) do
        total = total + (stat.value or 0)
    end
    return total
end

function CraftSim.OptionalReagent:Debug()
    if self:IsCurrency() then
        return { "Currency:" .. tostring(self.currencyID) .. " (" .. tostring(self.name) .. ")" }
    end
    return {
        self.item:GetItemLink() or self.item:GetItemID()
    }
end

function CraftSim.OptionalReagent:Copy()
    return self:IsCurrency()
        and CraftSim.OptionalReagent({ currencyID = self.currencyID })
        or CraftSim.OptionalReagent({ itemID = self.item:GetItemID() })
end

---@class CraftSim.OptionalReagent.Serialized
---@field currencyID? number
---@field itemID? number
function CraftSim.OptionalReagent:Serialize()
    return {
        itemID = self.item and self.item:GetItemID() or nil,
        currencyID = self.currencyID
    }
end

---STATIC: Deserializes an optionalReagent
---@param serializedOptionalReagent CraftSim.OptionalReagent.Serialized
---@return CraftSim.OptionalReagent
function CraftSim.OptionalReagent:Deserialize(serializedOptionalReagent)
    return CraftSim.OptionalReagent(serializedOptionalReagent)
end

function CraftSim.OptionalReagent:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("professionStats", self.professionStats)
    jb:Add("qualityID", self.qualityID)
    if self.currencyID then
        jb:Add("currencyID", self.currencyID)
    end
    if self.item then
        jb:Add("itemID", self.item:GetItemID())
    end
    jb:End()
    return jb.json
end

---@param recipeData CraftSim.RecipeData
---@param dataSlotIndex number? when known (from the owning slot), also match customer-owned slots
function CraftSim.OptionalReagent:IsOrderReagentIn(recipeData, dataSlotIndex)
    if not recipeData or not recipeData.orderData then
        return false
    end

    local itemID = (not self:IsCurrency() and self.item) and self.item:GetItemID() or nil
    local currencyID = self:IsCurrency() and self.currencyID or nil

    return not CraftSim.WORK_ORDER_REAGENTS:ShouldCrafterProvideOptional(
        dataSlotIndex, itemID, currencyID, recipeData)
end
