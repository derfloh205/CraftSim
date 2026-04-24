---@class CraftSim
local CraftSim = select(2, ...)
local GUTIL = CraftSim.GUTIL

---@class CraftSim.RECIPE_INFO : CraftSim.Module
CraftSim.RECIPE_INFO = {}

CraftSim.MODULES:RegisterModule("MODULE_RECIPE_INFO", CraftSim.RECIPE_INFO, {
    label = "CONTROL_PANEL_MODULES_RECIPE_INFO_LABEL",
    tooltip = "CONTROL_PANEL_MODULES_RECIPE_INFO_TOOLTIP",
})

GUTIL:RegisterCustomEvents(CraftSim.RECIPE_INFO, {
    "CRAFTSIM_RECIPE_DATA_UPDATED",
})

---@type GGUI.Frame
CraftSim.RECIPE_INFO.frame = nil
---@type CraftSim.RecipeData?
CraftSim.RECIPE_INFO.currentRecipeData = nil

local Logger = CraftSim.DEBUG:RegisterLogger("RecipeInfo")

local statIncreaseFactor = 5

--- Default values for each display option key.
--- Keys that are true are shown by default; false keys must be toggled on by the user.
CraftSim.RECIPE_INFO.DISPLAY_OPTIONS_DEFAULTS = {
    -- Stat-weight rows: on by default
    AVG_PROFIT                = true,
    MULTICRAFT_WEIGHT         = true,
    RESOURCEFULNESS_WEIGHT    = true,
    CONCENTRATION_WEIGHT      = true,
    -- Extra rows: off by default
    CRAFTING_COST             = false,
    AVG_CRAFTING_COST         = false,
    RESULT_ICONS              = false,
    KNOWLEDGE_POINTS          = false,
    AVG_YIELD                 = false,
    AVG_MULTICRAFT_ITEMS      = false,
    AVG_RESOURCEFULNESS_SAVED = false,
    CONCENTRATION_PROFIT      = false,
    CONCENTRATION_COST        = false,
    PROFIT_PER_QUALITY        = true,
}

--- Returns the display-options table, filling in any missing keys from defaults.
---@return table<string, boolean> opts
function CraftSim.RECIPE_INFO:GetDisplayOptions()
    local opts = CraftSim.DB.OPTIONS:Get("RECIPE_INFO_DISPLAY_OPTIONS")
    for k, v in pairs(CraftSim.RECIPE_INFO.DISPLAY_OPTIONS_DEFAULTS) do
        if opts[k] == nil then opts[k] = v end
    end
    return opts
end

function CraftSim.RECIPE_INFO:GetQualityThresholds(maxQuality, recipeDifficulty, breakPointOffset)
    local offset = breakPointOffset and 1 or 0
    if maxQuality == 1 then
        return {}
    elseif maxQuality == 2 then
        return { recipeDifficulty + offset }
    elseif maxQuality == 3 then
        return { recipeDifficulty * 0.5 + offset, recipeDifficulty + offset }
    elseif maxQuality == 5 then
        return { recipeDifficulty * 0.2 + offset, recipeDifficulty * 0.5 + offset, recipeDifficulty * 0.8 + offset,
            recipeDifficulty + offset }
    end
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
function CraftSim.RECIPE_INFO:CalculateStatWeightByModifiedData(recipeData, baseAverageProfit)
    recipeData:Update()
    local meanProfitModified = CraftSim.CALC:GetAverageProfit(recipeData)
    local profitDiff = meanProfitModified - baseAverageProfit
    local statWeight = profitDiff / statIncreaseFactor

    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
---@return number statWeight
function CraftSim.RECIPE_INFO:GetMulticraftWeight(recipeData, baseAverageProfit)
    if not recipeData.supportsMulticraft then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.multicraft:addValue(statIncreaseFactor)
    local statWeight = CraftSim.RECIPE_INFO:CalculateStatWeightByModifiedData(recipeData, baseAverageProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.multicraft:subtractValue(statIncreaseFactor)
    recipeData:Update() -- needed to refresh profession stats after reverting modifier changes
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param baseAverageProfit number
---@return number statWeight
function CraftSim.RECIPE_INFO:GetResourcefulnessWeight(recipeData, baseAverageProfit)
    if not recipeData.supportsResourcefulness then
        return 0
    end
    -- increase modifier
    recipeData.professionStatModifiers.resourcefulness:addValue(statIncreaseFactor)
    local statWeight = CraftSim.RECIPE_INFO:CalculateStatWeightByModifiedData(recipeData, baseAverageProfit)
    -- revert change (probably more performant than just to copy the whole thing)
    recipeData.professionStatModifiers.resourcefulness:subtractValue(statIncreaseFactor)
    recipeData:Update() -- needed to refresh profession stats after reverting modifier changes
    return statWeight
end

---@param recipeData CraftSim.RecipeData
---@param skill number
function CraftSim.RECIPE_INFO:GetExpectedQualityBySkill(recipeData, skill)
    local expectedQuality = 1
    local thresholds = CraftSim.RECIPE_INFO:GetQualityThresholds(recipeData.maxQuality,
        recipeData.professionStats.recipeDifficulty.value, CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET"))

    for _, threshold in pairs(thresholds) do
        if skill >= threshold then
            expectedQuality = expectedQuality + 1
        end
    end

    return expectedQuality
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.Statweights statweightResult
function CraftSim.RECIPE_INFO:CalculateStatWeights(recipeData)
    Logger:LogDebug("Get Average Profit", false, true)
    local averageProfit = CraftSim.CALC:GetAverageProfit(recipeData)

    Logger:LogDebug("calculate stat weights avg profit: " .. tostring(CraftSim.UTIL:FormatMoney(averageProfit, true)))

    local multicraftWeight = CraftSim.RECIPE_INFO:GetMulticraftWeight(recipeData, averageProfit)
    local resourcefulnessWeight = CraftSim.RECIPE_INFO:GetResourcefulnessWeight(recipeData, averageProfit)
    local concentrationValue = recipeData:GetConcentrationValue()

    return CraftSim.Statweights(averageProfit, multicraftWeight, resourcefulnessWeight, concentrationValue)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_INFO:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    if not recipeData then
        return
    end

    self.currentRecipeData = recipeData

    local statWeights = self:CalculateStatWeights(recipeData)
    self.UI:UpdateDisplay(recipeData, statWeights)
end

--- Returns allocated and maximum knowledge points for this recipe from spec data
---@param recipeData CraftSim.RecipeData
---@return number allocatedKP
---@return number maxKP
function CraftSim.RECIPE_INFO:GetKnowledgePoints(recipeData)
    if not recipeData.specializationData then
        return 0, 0
    end

    local allocatedKP = 0
    local maxKP = 0

    for _, nodeData in pairs(recipeData.specializationData.nodeData) do
        if nodeData:HasRelevantStats(recipeData) then
            local rank = math.max(0, nodeData.rank)
            allocatedKP = allocatedKP + rank
            maxKP = maxKP + nodeData.maxRank
        end
    end

    return allocatedKP, maxKP
end
