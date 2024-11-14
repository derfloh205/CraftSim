---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CraftRecipeData.CraftingStats
---@field totalProfit number
---@field averageProfit number
---@field totalCraftingCosts number
---@field averageCraftingCosts number
---@field numMulticraft number
---@field totalMulticraftExtraItems number
---@field averageMulticraftExtraItems number
---@field numResourcefulness number
---@field totalResourcefulnessSavedCosts number
---@field averageResourcefulnessSavedCosts number
---@field numIngenuity number
---@field totalConcentrationCost number
---@field averageConcentrationCost number

---@type CraftSim.CraftRecipeData.CraftingStats
local initCraftingStatsTable = {
    totalProfit = 0,
    averageProfit = 0,
    totalCraftingCosts = 0,
    averageCraftingCosts = 0,
    numMulticraft = 0,
    totalMulticraftExtraItems = 0,
    averageMulticraftExtraItems = 0,
    numResourcefulness = 0,
    totalResourcefulnessSavedCosts = 0,
    averageResourcefulnessSavedCosts = 0,
    numIngenuity = 0,
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
    ---@type CraftSim.CraftResultReagent[]
    self.totalReagents = {}
    ---@type CraftSim.CraftResultReagent[]
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

        self.observedStats.totalCraftingCosts = self.observedStats.totalCraftingCosts + craftResult.craftingCosts
        self.observedStats.averageCraftingCosts = self.observedStats.totalCraftingCosts / self.numCrafts

        self.observedStats.numMulticraft = self.observedStats.numMulticraft +
            ((craftResult.triggeredMulticraft and 1) or 0)
        self.observedStats.totalMulticraftExtraItems = self.observedStats.totalMulticraftExtraItems +
            craftResult:GetMulticraftExtraItems()
        self.observedStats.averageMulticraftExtraItems = self.observedStats.totalMulticraftExtraItems / self.numCrafts

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

        self.expectedStats.totalCraftingCosts = self.expectedStats.totalCraftingCosts +
            recipeData.priceData.averageCraftingCosts
        self.expectedStats.averageCraftingCosts = self.expectedStats.totalCraftingCosts / self.numCrafts

        self.expectedStats.numMulticraft = self.expectedStats.numMulticraft +
            recipeData.professionStats.multicraft:GetPercent(true)
        local multicraftChance = recipeData.professionStats.multicraft:GetPercent(true)
        local multicraftExtraItems = select(2, CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData))
        local averageMulticraftExtraItems = multicraftExtraItems * multicraftChance
        self.expectedStats.totalMulticraftExtraItems = self.expectedStats.totalMulticraftExtraItems +
            averageMulticraftExtraItems
        self.expectedStats.averageMulticraftExtraItems = self.expectedStats.totalMulticraftExtraItems / self.numCrafts

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

    CraftSim.CRAFT_LOG:MergeCraftResultItemData(self.totalItems, craftResult.craftResultItems)
    CraftSim.CRAFT_LOG:MergeReagentsItemData(self.totalReagents, craftResult.reagents)
    CraftSim.CRAFT_LOG:MergeReagentsItemData(self.totalSavedReagents, craftResult.savedReagents)

    table.insert(self.craftResults, craftResult)
end

function CraftSim.CraftRecipeData:Debug()
    local debugLines = {
        "recipeID: " .. self.recipeID,
        "numCrafts: " .. self.numCrafts,
    }
    return debugLines
end

function CraftSim.CraftRecipeData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("numCrafts", self.numCrafts)
    jb:AddList("expectedStats", self.expectedStats)
    jb:AddList("observedStats", self.observedStats)
    jb:AddList("totalItems", self.totalItems)
    jb:AddList("totalSavedReagents", self.totalSavedReagents)
    jb:AddList("craftResults", self.craftResults, true)
    jb:End()
    return jb.json
end
