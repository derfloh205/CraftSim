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

function CraftSim.OptionalReagent:Debug()
    -- TODO update assumption of item (vs currency)
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

-- TODO make this currency aware
---@param recipeData CraftSim.RecipeData
function CraftSim.OptionalReagent:IsOrderReagentIn(recipeData)
    if not recipeData.orderData then return false end

    local itemID = self.item:GetItemID()

    local orderItemIDs = GUTIL:Map(recipeData.orderData.reagents or {}, function(reagentInfo)
        return CraftSim.RecipeData.GetItemIDFromReagentInfo(reagentInfo, recipeData)
    end)

    return tContains(orderItemIDs, itemID)
end
