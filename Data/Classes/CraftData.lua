_, CraftSim = ...

---@class CraftSim.CraftData
CraftSim.CraftData = CraftSim.Object:extend()

---@param expectedCrafts number
---@param requiredReagents CraftSim.Reagent[]
---@param optionalReagents CraftSim.OptionalReagent[]
---@param crafterName string
---@param crafterClass ClassFile
---@param chance number
function CraftSim.CraftData:new(expectedCrafts, chance, requiredReagents, optionalReagents, crafterName, crafterClass, resChance, resExtraFactor, avgItemAmount)
    self.expectedCrafts = expectedCrafts
    self.requiredReagents = requiredReagents
    self.optionalReagents = optionalReagents
    self.crafterName = crafterName
    self.crafterClass = crafterClass
    self.chance = chance
    self.resChance = resChance
    self.resExtraFactor = resExtraFactor
    self.avgItemAmount = avgItemAmount
end

---@class CraftSim.CraftData.Serialized
---@field expectedCrafts number
---@field requiredReagents CraftSim.Reagent.Serialized[]
---@field optionalReagents CraftSim.OptionalReagent.Serialized[]
---@field crafterName string
---@field crafterClass ClassFile
---@field chance number
---@field resChance number
---@field resExtraFactor number
---@field avgItemAmount number

---@return CraftSim.CraftData.Serialized
function CraftSim.CraftData:Serialize()
    local serialized = {}
    serialized.expectedCrafts = self.expectedCrafts
    serialized.crafterName = self.crafterName
    serialized.crafterClass = self.crafterClass
    serialized.chance = self.chance
    serialized.resChance = self.resChance
    serialized.resExtraFactor = self.resExtraFactor
    serialized.avgItemAmount = self.avgItemAmount
    serialized.requiredReagents = CraftSim.GUTIL:Map(self.requiredReagents, function (reagent)
        return reagent:Serialize()
    end)
    serialized.optionalReagents = CraftSim.GUTIL:Map(self.optionalReagents, function (reagent)
        return reagent:Serialize()
    end)

    return serialized
end

---@return number totalCosts
---@return number requiredCosts
function CraftSim.CraftData:GetCraftingCosts()
    local totalCosts = 0
    local requiredCosts = 0

    table.foreach(self.requiredReagents, function (_, reagent)
        table.foreach(reagent.items, function (_, reagentItem)
            local itemCosts = CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true) * reagentItem.quantity
            totalCosts = totalCosts + itemCosts
            requiredCosts = requiredCosts + itemCosts
        end)
    end)

    table.foreach(self.optionalReagents, function (_, optionalReagent)
        totalCosts = totalCosts + CraftSim.PRICEDATA:GetMinBuyoutByItemID(optionalReagent.item:GetItemID(), true)
    end)

    return totalCosts, requiredCosts
end

function CraftSim.CraftData:GetExpectedCosts()
    local craftingCosts, craftingCostsRequired = self:GetCraftingCosts()
    return CraftSim.CALC:CalculateExpectedCosts(
                self.expectedCrafts, self.chance, self.resChance, 
                self.resExtraFactor, self.avgItemAmount, craftingCosts, craftingCostsRequired)
end

---@param serialized CraftSim.CraftData.Serialized
---@return CraftSim.CraftData
function CraftSim.CraftData:Deserialize(serialized)
    local requiredReagents = CraftSim.GUTIL:Map(serialized.requiredReagents, function (serializedReagent)
        return CraftSim.Reagent:Deserialize(serializedReagent)
    end)
    local optionalReagents = CraftSim.GUTIL:Map(serialized.optionalReagents, function (serializedReagent)
        return CraftSim.OptionalReagent:Deserialize(serializedReagent)
    end)

    return CraftSim.CraftData(
        serialized.expectedCrafts, 
        serialized.chance, 
        requiredReagents, 
        optionalReagents, 
        serialized.crafterName, 
        serialized.crafterClass, 
        serialized.resChance, 
        serialized.resExtraFactor, 
        serialized.avgItemAmount)
end

function CraftSim.CraftData:Debug()
    local debugLines = {
        "Expected Crafts: " .. tostring(self.expectedCrafts),
        "Chance: " .. tostring(self.chance),
        "Crafter: " .. tostring(self.crafterName),
        "Crafter Class: " .. tostring(self.crafterClass),
        "Res Chance: " .. tostring(self.resChance),
        "Res Factor: " .. tostring(self.resExtraFactor),
        "AvgItems: " .. tostring(self.avgItemAmount),
        "requiredReagents: " .. tostring(self.requiredReagents),
        "optionalReagents: " .. tostring(self.optionalReagents),
    }

    return debugLines
end