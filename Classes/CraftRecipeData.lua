---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

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

---@class CraftSim.CraftRecipeData.CraftingStatData
---@field numCrafts number
---@field expectedStats CraftSim.CraftRecipeData.CraftingStats
---@field observedStats CraftSim.CraftRecipeData.CraftingStats



---@type CraftSim.CraftRecipeData.CraftingStats
local initCraftingStats = {
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

---@type CraftSim.CraftRecipeData.CraftingStatData
local initCraftingStatComparison = {
    numCrafts = 0,
    expectedStats = initCraftingStats, -- will be deep copied later
    observedStats = initCraftingStats,
}

---@class CraftSim.CraftRecipeData.CraftResultItems
---@field resultItems CraftSim.CraftResultItem[]
---@field reagents CraftSim.CraftResultReagent[]
---@field savedReagents CraftSim.CraftResultReagent[]

local initCraftResultItemsTable = {
    resultItems = {},
    reagents = {},
    savedReagents = {},
}

---@class CraftSim.CraftRecipeData : CraftSim.CraftSimObject
---@overload fun(recipeID: RecipeID):CraftSim.CraftRecipeData
CraftSim.CraftRecipeData = CraftSim.CraftSimObject:extend()

---@param recipeID number
function CraftSim.CraftRecipeData:new(recipeID)
    self.recipeID = recipeID
    ---@type CraftSim.CraftRecipeData.CraftingStatData
    self.craftingStatData = CopyTable(initCraftingStatComparison)
    ---@type CraftSim.CraftRecipeData.CraftingStatData[]
    self.craftStatDataSnapshots = {}
    ---@type table<string, CraftSim.CraftRecipeData.CraftingStatData>
    self.craftingStatDataByReagentCombination = {}
    ---@type table<string, CraftSim.CraftRecipeData.CraftingStatData[]>
    self.craftingStatDataByReagentCombinationSnapshots = {}
    ---@type CraftSim.CraftResult[]
    self.craftResults = {}
    ---@type CraftSim.CraftRecipeData.CraftResultItems
    self.totalItems = CopyTable(initCraftResultItemsTable)
    ---@type table<string, CraftSim.CraftRecipeData.CraftResultItems>
    self.totalItemsByReagentCombination = {}

    -- TODO: remove if data is at some point persisted over sessions
    local savedReagentCombinationID = CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SELECTED_RECIPE_REAGENT_COMBINATION_ID")
    savedReagentCombinationID[recipeID] = "Total"
end

---@return string[] reagentCombinationIDs
function CraftSim.CraftRecipeData:GetReagentCombinationIDs()
    local reagentCombinationIDs = { "Total" }

    for reagentCombinationID, _ in pairs(self.craftingStatDataByReagentCombination) do
        tinsert(reagentCombinationIDs, reagentCombinationID)
    end
    return reagentCombinationIDs
end

---@return CraftSim.CraftRecipeData.CraftingStatData
function CraftSim.CraftRecipeData:GetCraftingStatDataBySelectedReagentCombinationID()
    local selectedReagentCombinationID = CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SELECTED_RECIPE_REAGENT_COMBINATION_ID")
        [self.recipeID]

    if selectedReagentCombinationID ~= "Total" then
        return self.craftingStatDataByReagentCombination[selectedReagentCombinationID]
    end

    return self.craftingStatData
end

---@return CraftSim.CraftRecipeData.CraftingStatData[]
function CraftSim.CraftRecipeData:GetCraftingStatDataSnapshotsBySelectedReagentCombinationID()
    local selectedReagentCombinationID = CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SELECTED_RECIPE_REAGENT_COMBINATION_ID")
        [self.recipeID]

    if selectedReagentCombinationID ~= "Total" then
        return self.craftingStatDataByReagentCombinationSnapshots[selectedReagentCombinationID]
    end

    return self.craftStatDataSnapshots
end

---@return CraftSim.CraftRecipeData.CraftResultItems
function CraftSim.CraftRecipeData:GetCraftResultItemsBySelectedReagentCombinationID()
    local selectedReagentCombinationID = CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SELECTED_RECIPE_REAGENT_COMBINATION_ID")
        [self.recipeID]

    if selectedReagentCombinationID ~= "Total" then
        return self.totalItemsByReagentCombination[selectedReagentCombinationID]
    end

    return self.totalItems
end

---@param reagentCombinationID "Total" | string format itemID:itemID
---@return string displayString
function CraftSim.CraftRecipeData:GetReagentCombinationDisplayString(reagentCombinationID)
    ---@type CraftSim.CraftResultReagent[]
    local reagents
    if reagentCombinationID == "Total" then
        return reagentCombinationID
    else
        reagents = self.totalItemsByReagentCombination[reagentCombinationID].reagents
    end

    if not reagents then return "<?>" end

    local displayString = ""
    for index, craftResultReagent in ipairs(reagents) do
        local itemIcon = GUTIL:IconToText(craftResultReagent.item:GetItemIcon(), 17, 17)
        local qualityIcon = ""
        local quantityText = "x " .. craftResultReagent.quantity
        if craftResultReagent.qualityID and craftResultReagent.qualityID > 0 then
            qualityIcon = GUTIL:GetQualityIconString(craftResultReagent.qualityID, 20, 20, 0, -1)
        end
        if index > 1 then
            displayString = displayString .. "  " .. itemIcon .. qualityIcon .. quantityText
        else
            displayString = displayString .. itemIcon .. qualityIcon .. quantityText
        end
    end

    return displayString
end

---@param craftResult CraftSim.CraftResult
---@param recipeData CraftSim.RecipeData last crafted recipeData
function CraftSim.CraftRecipeData:AddCraftResult(craftResult, recipeData)
    ---@param craftingStatData CraftSim.CraftRecipeData.CraftingStatData
    local function addStats(craftingStatData)
        craftingStatData.numCrafts = craftingStatData.numCrafts + 1

        local observedStats = craftingStatData.observedStats
        local expectedStats = craftingStatData.expectedStats
        local numCrafts = craftingStatData.numCrafts
        do
            -- observedStats
            observedStats.totalProfit = observedStats.totalProfit + craftResult.profit
            observedStats.averageProfit = observedStats.totalProfit / numCrafts

            observedStats.totalCraftingCosts = observedStats.totalCraftingCosts + craftResult.craftingCosts
            observedStats.averageCraftingCosts = observedStats.totalCraftingCosts / numCrafts

            observedStats.numMulticraft = observedStats.numMulticraft +
                ((craftResult.triggeredMulticraft and 1) or 0)
            observedStats.totalMulticraftExtraItems = observedStats.totalMulticraftExtraItems +
                craftResult:GetMulticraftExtraItems()
            observedStats.averageMulticraftExtraItems = observedStats.totalMulticraftExtraItems / numCrafts

            observedStats.numResourcefulness = observedStats.numResourcefulness +
                ((craftResult.triggeredResourcefulness and 1) or 0)
            observedStats.totalResourcefulnessSavedCosts = observedStats.totalResourcefulnessSavedCosts +
                craftResult.savedCosts
            observedStats.averageResourcefulnessSavedCosts = observedStats.totalResourcefulnessSavedCosts /
                numCrafts

            observedStats.numIngenuity = observedStats.numIngenuity + ((craftResult.triggeredIngenuity and 1) or 0)
            observedStats.totalConcentrationCost = observedStats.totalConcentrationCost + craftResult
                .usedConcentration
            observedStats.averageConcentrationCost = observedStats.totalConcentrationCost / numCrafts
        end

        -- expectedStats
        do
            expectedStats.totalProfit = expectedStats.totalProfit + craftResult.expectedAverageProfit
            expectedStats.averageProfit = expectedStats.totalProfit / numCrafts

            expectedStats.totalCraftingCosts = expectedStats.totalCraftingCosts +
                recipeData.priceData.averageCraftingCosts
            expectedStats.averageCraftingCosts = expectedStats.totalCraftingCosts / numCrafts

            expectedStats.numMulticraft = expectedStats.numMulticraft +
                recipeData.professionStats.multicraft:GetPercent(true)
            local multicraftChance = recipeData.professionStats.multicraft:GetPercent(true)
            local multicraftExtraItems = select(2, CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData))
            local averageMulticraftExtraItems = multicraftExtraItems * multicraftChance
            expectedStats.totalMulticraftExtraItems = expectedStats.totalMulticraftExtraItems +
                averageMulticraftExtraItems
            expectedStats.averageMulticraftExtraItems = expectedStats.totalMulticraftExtraItems / numCrafts

            expectedStats.numResourcefulness = expectedStats.numResourcefulness +
                recipeData.professionStats.resourcefulness:GetPercent(true)
            local resourcefulnessChance = recipeData.professionStats.resourcefulness:GetPercent(true)
            local resourcefulnessSavedCosts = CraftSim.CALC:GetResourcefulnessSavedCosts(recipeData)
            local averageResourcefulnessSavedCosts = resourcefulnessChance * resourcefulnessSavedCosts
            expectedStats.totalResourcefulnessSavedCosts = expectedStats.totalResourcefulnessSavedCosts +
                averageResourcefulnessSavedCosts
            expectedStats.averageResourcefulnessSavedCosts = expectedStats.totalResourcefulnessSavedCosts /
                numCrafts

            expectedStats.numIngenuity = expectedStats.numIngenuity +
                recipeData.professionStats.ingenuity:GetPercent(true)
            local ingenuityChance = recipeData.professionStats.ingenuity:GetPercent(true)
            local averageSavedConcentrationCost = (craftResult.ingenuityRefund * ingenuityChance)
            local averageConcentrationCost = recipeData.concentrationCost - averageSavedConcentrationCost
            expectedStats.totalConcentrationCost = expectedStats.totalConcentrationCost + averageConcentrationCost
            expectedStats.averageConcentrationCost = expectedStats.totalConcentrationCost / numCrafts
        end
    end

    addStats(self.craftingStatData)

    self.craftingStatDataByReagentCombination[craftResult.reagentCombinationID] = self
        .craftingStatDataByReagentCombination[craftResult.reagentCombinationID] or
        CopyTable(initCraftingStatComparison)

    addStats(self.craftingStatDataByReagentCombination[craftResult.reagentCombinationID])

    CraftSim.CRAFT_LOG:MergeCraftResultItemData(self.totalItems.resultItems, craftResult.craftResultItems)
    CraftSim.CRAFT_LOG:MergeReagentsItemData(self.totalItems.reagents, craftResult.reagents)
    CraftSim.CRAFT_LOG:MergeReagentsItemData(self.totalItems.savedReagents, craftResult.savedReagents)

    self.totalItemsByReagentCombination[craftResult.reagentCombinationID] = self.totalItemsByReagentCombination
        [craftResult.reagentCombinationID] or CopyTable(initCraftResultItemsTable)
    local reagentCombinationItems = self.totalItemsByReagentCombination[craftResult.reagentCombinationID]

    CraftSim.CRAFT_LOG:MergeCraftResultItemData(reagentCombinationItems.resultItems, craftResult.craftResultItems)
    CraftSim.CRAFT_LOG:MergeReagentsItemData(reagentCombinationItems.reagents, craftResult.reagents)
    CraftSim.CRAFT_LOG:MergeReagentsItemData(reagentCombinationItems.savedReagents, craftResult.savedReagents)

    table.insert(self.craftResults, craftResult)

    -- insert craftData snapshots
    table.insert(self.craftStatDataSnapshots, CopyTable(self.craftingStatData))

    self.craftingStatDataByReagentCombinationSnapshots[craftResult.reagentCombinationID] = self
        .craftingStatDataByReagentCombinationSnapshots[craftResult.reagentCombinationID] or {}

    table.insert(self.craftingStatDataByReagentCombinationSnapshots[craftResult.reagentCombinationID],
        CopyTable(self.craftingStatDataByReagentCombination[craftResult.reagentCombinationID]))
end

function CraftSim.CraftRecipeData:Debug()
    local debugLines = {
        "recipeID: " .. self.recipeID,
        "numCrafts: " .. self.craftingStatData.numCrafts,
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
    jb:AddList("totalItemsByReagentCombination", self.totalItemsByReagentCombination, true)
    jb:End()
    return jb.json
end
