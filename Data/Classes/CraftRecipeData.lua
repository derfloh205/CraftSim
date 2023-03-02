_, CraftSim = ...

---@class CraftSim.CraftRecipeData
CraftSim.CraftRecipeData = CraftSim.Object:extend()

---@param recipeID number
function CraftSim.CraftRecipeData:new(recipeID)
    self.recipeID = recipeID
    self.numCrafts = 0
    self.totalProfit = 0
    self.totalExpectedProfit = 0
    self.numInspiration = 0
    self.numMulticraft = 0
    self.numMulticraftExtraItems = 0
    self.numResourcefulness = 0
    self.totalSavedCosts = 0
    self.totalExpectedSavedCosts = 0
    ---@type CraftSim.CraftResult[]
    self.craftResults = {}
    ---@type CraftSim.CraftResultItem[]
    self.totalItems = {}
    ---@type CraftSim.CraftResultSavedReagent[]
    self.totalSavedReagents = {}
end

---@param craftResult CraftSim.CraftResult
function CraftSim.CraftRecipeData:AddCraftResult(craftResult)
    self.numCrafts = self.numCrafts + 1
    self.totalProfit = self.totalProfit + craftResult.profit
    self.totalExpectedProfit = self.totalExpectedProfit + craftResult.expectedAverageProfit
    self.numInspiration = self.numInspiration + ((craftResult.triggeredInspiration and 1) or 0)
    self.numMulticraft = self.numMulticraft + ((craftResult.triggeredMulticraft and 1) or 0)
    self.numResourcefulness = self.numResourcefulness + ((craftResult.triggeredResourcefulness and 1) or 0)
    self.totalSavedCosts = self.totalSavedCosts + craftResult.savedCosts
    self.totalExpectedSavedCosts = self.totalExpectedSavedCosts + craftResult.expectedAverageSavedCosts

    table.foreach(craftResult.craftResultItems, function (_, craftResultItemA)

        self.numMulticraftExtraItems = self.numMulticraftExtraItems + craftResultItemA.quantityMulticraft

        local found = CraftSim.GUTIL:Find(self.totalItems, function(craftResultItemB)
            local itemLinkA = craftResultItemA.item:GetItemLink() -- for gear its possible to match by itemlink
            local itemLinkB = craftResultItemB.item:GetItemLink()
            local itemIDA = craftResultItemA.item:GetItemID()
            local itemIDB = craftResultItemB.item:GetItemID()

            if itemLinkA and itemLinkB then -- if one or both are nil aka not loaded, we dont want to match..
                return itemLinkA == itemLinkB
            else
                return itemIDA == itemIDB
            end
        end)
        if not found then
            table.insert(self.totalItems, craftResultItemA)
        end
        -- we do not need to increase quantity as this would have been already done in the CraftSessionData Constructor
    end)

    table.foreach(craftResult.savedReagents, function (_, savedReagentA)
        local savedReagentB = CraftSim.GUTIL:Find(self.totalItems, function(savedReagentB) 
            return savedReagentA.item:GetItemID() == savedReagentB.item:GetItemID()
        end)

        if not savedReagentB then
            table.insert(self.totalSavedReagents, savedReagentA)
        end
        -- we do not need to increase quantity as this would have been already done in the CraftSessionData Constructor
    end) 

    table.insert(self.craftResults, craftResult)
end

function CraftSim.CraftRecipeData:Debug()
    local debugLines = {
        "recipeID: " .. self.recipeID,
        "numCrafts: " .. self.numCrafts,
        "totalProfit: " .. CraftSim.GUTIL:FormatMoney(self.totalProfit, true),
        "totalExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(self.totalExpectedProfit, true),
        "numInspiration: " .. self.numInspiration,
        "numMulticraft: " .. self.numMulticraft,
        "numMulticraftExtraItems: " .. self.numMulticraftExtraItems,
        "numResourcefulness: " .. self.numResourcefulness,
        "totalSavedCosts: " .. CraftSim.GUTIL:FormatMoney(self.totalSavedCosts),
        "totalExpectedSavedCosts: " .. CraftSim.GUTIL:FormatMoney(self.totalExpectedSavedCosts),
    }
    return debugLines
end

function CraftSim.CraftRecipeData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("numCrafts", self.numCrafts)
    jb:Add("totalProfit", self.totalProfit)
    jb:Add("totalExpectedProfit", self.totalExpectedProfit)
    jb:Add("numInspiration", self.numInspiration)
    jb:Add("numMulticraft", self.numMulticraft)
    jb:Add("numMulticraftExtraItems", self.numMulticraftExtraItems)
    jb:Add("numResourcefulness", self.numResourcefulness)
    jb:Add("totalSavedCosts", self.totalSavedCosts)
    jb:AddList("totalItems", self.totalItems)
    jb:AddList("totalSavedReagents", self.totalSavedReagents)
    jb:AddList("craftResults", self.craftResults, true)
    jb:End()
    return jb.json
end