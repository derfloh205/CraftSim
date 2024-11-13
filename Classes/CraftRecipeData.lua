---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CraftRecipeData.CraftingStats
---@field totalProfit number
---@field averageProfit number
---@field numMulticraft number
---@field totalMulticraftExtraItems number
---@field averageMulticraftExtraItems number
---@field numResourcefulness number
---@field totalResourcefulnessSavedCosts number
---@field averageResourcefulnessSavedCosts number
---@field numIngenuity number
---@field totalConcentrationCost number
---@field averageConcentrationCost number
---@field averageSavedConcentration number
---@field averageUsedConcentration number

---@type CraftSim.CraftRecipeData.CraftingStats
local initCraftingStatsTable = {
    totalProfit = 0,
    averageProfit = 0,
    numMulticraft = 0,
    totalMulticraftExtraItems = 0,
    averageMulticraftExtraItems = 0,
    numResourcefulness = 0,
    totalResourcefulnessSavedCosts = 0,
    averageResourcefulnessSavedCosts = 0,
    numIngenuity = 0,
    averageSavedConcentration = 0,
    averageUsedConcentration = 0,
    averageConcentrationCost = 0,
    totalConcentrationCost = 0,
}

---@class CraftSim.CraftRecipeData : CraftSim.CraftSimObject
CraftSim.CraftRecipeData = CraftSim.CraftSimObject:extend()

---@param recipeID number
function CraftSim.CraftRecipeData:new(recipeID)
    self.recipeID = recipeID
    self.numCrafts = 0
    ---@type CraftSim.CraftRecipeData.CraftingStats
    self.expectedStats = CopyTable(initCraftingStatsTable)
    ---@type CraftSim.CraftRecipeData.CraftingStats
    self.observedStats = CopyTable(initCraftingStatsTable)
    ---@type CraftSim.CraftResult[]
    self.craftResults = {}
    ---@type CraftSim.CraftResultItem[]
    self.totalItems = {}
    ---@type CraftSim.CraftResultSavedReagent[]
    self.totalSavedReagents = {}
end

---@param craftResult CraftSim.CraftResult
---@param recipeData CraftSim.RecipeData last crafted recipeData
function CraftSim.CraftRecipeData:AddCraftResult(craftResult, recipeData)
    self.numCrafts = self.numCrafts + 1
    -- observedStats
    do
        self.observedStats.totalProfit = self.observedStats.totalProfit + craftResult.profit
        self.observedStats.averageProfit = self.observedStats.totalProfit / self.numCrafts
        self.observedStats.numMulticraft = self.observedStats.numMulticraft +
            ((craftResult.triggeredMulticraft and 1) or 0)
        self.observedStats.numResourcefulness = self.observedStats.numResourcefulness +
            ((craftResult.triggeredResourcefulness and 1) or 0)
        self.observedStats.totalResourcefulnessSavedCosts = self.observedStats.totalResourcefulnessSavedCosts +
            craftResult.savedCosts
        self.observedStats.averageResourcefulnessSavedCosts = self.observedStats.totalResourcefulnessSavedCosts /
            self.numCrafts
        self.observedStats.numIngenuity = self.observedStats.numIngenuity + ((craftResult.triggeredIngenuity and 1) or 0)
        self.observedStats.totalConcentrationCost = self.observedStats.totalConcentrationCost + craftResult
            .usedConcentration
        self.observedStats.averageConcentrationCost = self.observedStats.totalConcentrationCost / self.numCrafts
    end
    -- expectedStats
    do
        self.expectedStats.totalProfit = self.expectedStats.totalProfit + craftResult.expectedAverageProfit
        self.expectedStats.averageProfit = self.expectedStats.totalProfit / self.numCrafts
        self.expectedStats.numMulticraft = self.expectedStats.numMulticraft +
            recipeData.professionStats.multicraft:GetPercent(true)
        self.expectedStats.numResourcefulness = self.expectedStats.numResourcefulness +
            recipeData.professionStats.resourcefulness:GetPercent(true)
        local resourcefulnessChance = recipeData.professionStats.resourcefulness:GetPercent(true)
        local resourcefulnessSavedCosts = CraftSim.CALC:GetResourcefulnessSavedCosts(recipeData)
        local averageResourcefulnessSavedCosts = resourcefulnessChance * resourcefulnessSavedCosts

        self.expectedStats.totalResourcefulnessSavedCosts = self.expectedStats.totalResourcefulnessSavedCosts +
            averageResourcefulnessSavedCosts

        self.expectedStats.averageResourcefulnessSavedCosts = self.expectedStats.totalResourcefulnessSavedCosts /
            self.numCrafts

        self.expectedStats.numIngenuity = self.expectedStats.numIngenuity +
            recipeData.professionStats.ingenuity:GetPercent(true)
        local ingenuityChance = recipeData.professionStats.ingenuity:GetPercent(true)
        local averageSavedConcentrationCost = (craftResult.ingenuityRefund * ingenuityChance)
        local averageConcentrationCost = recipeData.concentrationCost - averageSavedConcentrationCost
        self.expectedStats.totalConcentrationCost = self.expectedStats.totalConcentrationCost + averageConcentrationCost
        self.expectedStats.averageConcentrationCost = self.expectedStats.totalConcentrationCost / self.numCrafts
    end

    table.foreach(craftResult.craftResultItems, function(_, craftResultItemA)
        self.numMulticraftExtraItems = self.numMulticraftExtraItems + craftResultItemA.quantityMulticraft

        local craftResultItemB = CraftSim.GUTIL:Find(self.totalItems, function(craftResultItemB)
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
        if craftResultItemB then
            craftResultItemB.quantity = craftResultItemB.quantity +
                (craftResultItemA.quantity + craftResultItemA.quantityMulticraft)
            craftResultItemB.quantityMulticraft = craftResultItemB.quantityMulticraft +
                craftResultItemA.quantityMulticraft
        else
            table.insert(self.totalItems, craftResultItemA:Copy())
        end
        -- we do not need to increase quantity as this would have been already done in the CraftSessionData Constructor
    end)

    table.foreach(craftResult.savedReagents, function(_, savedReagentA)
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
        "totalProfit: " .. CraftSim.UTIL:FormatMoney(self.totalProfit, true),
        "totalExpectedProfit: " .. CraftSim.UTIL:FormatMoney(self.totalExpectedProfit, true),
        "numMulticraft: " .. self.numMulticraft,
        "numMulticraftExtraItems: " .. self.numMulticraftExtraItems,
        "numResourcefulness: " .. self.numResourcefulness,
        "totalSavedCosts: " .. CraftSim.UTIL:FormatMoney(self.totalSavedCosts),
        "totalExpectedSavedCosts: " .. CraftSim.UTIL:FormatMoney(self.totalExpectedSavedCosts),
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
