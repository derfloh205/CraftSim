_, CraftSim = ...

---@class CraftSim.CraftData
CraftSim.CraftData = CraftSim.Object:extend()

---@param expectedCrafts number
---@param requiredReagents CraftSim.Reagent[]
---@param optionalReagents CraftSim.OptionalReagent[]
---@param crafterName string
---@param crafterClass ClassFile
---@param chance number
---@param itemLink string -- the full item link of that item
---@param recipeID number
---@param professionID number
function CraftSim.CraftData:new(expectedCrafts, chance, requiredReagents, optionalReagents, crafterName, crafterClass, 
    resChance, resExtraFactor, avgItemAmount, itemLink, recipeID, professionID)
    self.expectedCrafts = expectedCrafts
    self.requiredReagents = requiredReagents
    self.optionalReagents = optionalReagents
    self.crafterName = crafterName
    self.crafterClass = crafterClass
    self.chance = chance
    self.resChance = resChance
    self.resExtraFactor = resExtraFactor
    self.avgItemAmount = avgItemAmount
    self.itemLink = itemLink
    self.recipeID = recipeID
    self.professionID = professionID
    --- use a unified itemString for key to enable saving data for gear
    -- get player level and specializationID and remove the bonusIDs from the link to make the string unique character wide
    self.unifiedItemString = CraftSim.CraftData:GetUnifiedItemStringFromLink(self.itemLink)
end

--- Set the CraftData as activeData for its item
function CraftSim.CraftData:SetActive()
    --print("Set CraftData as active")
    CraftSimCraftData[self.recipeID] = CraftSimCraftData[self.recipeID] or {}
    CraftSimCraftData[self.recipeID][self.unifiedItemString] = CraftSimCraftData[self.recipeID][self.unifiedItemString] or {
        activeData = nil,
        dataPerCrafter = {}
    }
    CraftSimCraftData[self.recipeID][self.unifiedItemString].activeData = self:Serialize()
end

---@return boolean isActive
function CraftSim.CraftData:IsActive()
    CraftSimCraftData[self.recipeID] = CraftSimCraftData[self.recipeID] or {}
    CraftSimCraftData[self.recipeID][self.unifiedItemString] = CraftSimCraftData[self.recipeID][self.unifiedItemString] or {
        activeData = nil,
        dataPerCrafter = {}
    }
    if CraftSimCraftData[self.recipeID][self.unifiedItemString].activeData then
        return CraftSimCraftData[self.recipeID][self.unifiedItemString].activeData.crafterName == self.crafterName
    end

    return false
end

function CraftSim.CraftData:Delete()
    CraftSimCraftData[self.recipeID] = CraftSimCraftData[self.recipeID] or {}
    CraftSimCraftData[self.recipeID][self.unifiedItemString] = CraftSimCraftData[self.recipeID][self.unifiedItemString] or {
        activeData = nil,
        dataPerCrafter = {}
    }
    CraftSimCraftData[self.recipeID][self.unifiedItemString].dataPerCrafter[self.crafterName] = nil
    if CraftSimCraftData[self.recipeID][self.unifiedItemString].activeData then
        if CraftSimCraftData[self.recipeID][self.unifiedItemString].activeData.crafterName == self.crafterName then
            CraftSimCraftData[self.recipeID][self.unifiedItemString].activeData = nil
        end
    end
end

--- STATIC careful: will not return the precise item if its not loaded and we cannot fetch the itemstring
function CraftSim.CraftData:GetActiveCraftDataByItem(item)

    local itemToRecipe = CraftSim.CACHE:GetCacheEntryByGameVersion(CraftSimRecipeMap, "itemToRecipe")
    local itemLink = item:GetItemLink()
    local itemID = item:GetItemID()
    --- if a cache entry for this recipe exists we can do it faster! otherwise search for it
    if itemToRecipe and itemToRecipe[itemID] then
        local recipeID = itemToRecipe[itemID]
        CraftSimCraftData[recipeID] = CraftSimCraftData[recipeID] or {}
        if itemLink then
            local unifiedItemString = CraftSim.CraftData:GetUnifiedItemStringFromLink(itemLink)
            CraftSimCraftData[recipeID][unifiedItemString] = CraftSimCraftData[recipeID][unifiedItemString] or {
                activeData = nil,
                dataPerCrafter = {}
            }

            return CraftSimCraftData[recipeID][unifiedItemString].activeData
        else
            -- if the itemlink is not loaded (could be for nongear reagents)
            for key, itemCraftData in pairs(CraftSimCraftData[recipeID]) do
                if string.match(tostring(key), tostring(itemID)) then
                    return itemCraftData.activeData
                end
            end
        end
        return nil     
    else
        for _, recipeItemList in pairs(CraftSimCraftData) do
            for _, itemCraftData in pairs(recipeItemList) do
                if itemCraftData.activeData then
                    local itemIDSaved = CraftSim.GUTIL:GetItemIDByLink(itemCraftData.activeData.itemLink)
    
                    if itemIDSaved == itemID then
                        return itemCraftData.activeData
                    end 
                end
            end
        end
    end
end

---STATIC
---@param itemLink string
function CraftSim.CraftData:GetUnifiedItemStringFromLink(itemLink)
    return CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(CraftSim.GUTIL:GetItemStringFromLink(itemLink))
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
---@field itemLink string
---@field recipeID number
---@field professionID number

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
    serialized.itemLink = self.itemLink
    serialized.recipeID = self.recipeID
    serialized.professionID = self.professionID
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
        serialized.avgItemAmount,
        serialized.itemLink,
        serialized.recipeID,
        serialized.professionID)
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
        "itemLink: " .. tostring(self.itemLink),
        "recipeID: " .. tostring(self.recipeID),
        "professionID: " .. tostring(self.professionID),
    }

    return debugLines
end