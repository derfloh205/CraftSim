--[[

    This following logic executes a combinatorial optimization for a modified version of the knapsack
    problem for recipes with quality-rated, required reagents, referred to now simply as reagents.
    
    These crafting equations are used to prepare the data for the optimization.

    -----------------------------------------------------------------------------------------------

    Maximum skill bonus for a recipe from reagent quality

    maxSkillBonus = maxDifficultyOfBaseRecipe × 0.4

    As an example, a recipe with a base difficulty of 700 requires a total skill of 700 to reach the
    highest quality result.  Thus, reagents can provide 280 bonus skill since 280 is 40% of 700.
    Note that optional reagents can increase the recipe difficulty beyond the base but this is not
    a factor when determining the possible skill bonus from reagents.

    This value is added to the crafter's skill when all required reagents are provided at maximum
    quality (i.e. quality 3 for Dragonflight & The War Within; quality 2 (i.e. high quality) for Midnight)

    -----------------------------------------------------------------------------------------------

    Percentage of a recipe's maximum skill bonus for a reagent i out of n reagents

    skillBonusPercentageForReagent = (wᵢ × rᵢ) ÷ ( (w₁ × r₁) + (w₂ × r₂) + ... + (wₙ × rₙ) )
    where:
    wᵢ = weight of reagent i (looked up by item ID from Data/ReagentWeightData.lua)
    rᵢ = required quantity of reagent i

    This value is the percentage of the maximum skill bonus a single reagent can grant when provided
    in the required quantity at maximum quality.

    Continuing the previous example, if the recipe had 2 required, quality-tiered reagents, A and B,
    and requires 10 of reagent A, which has a weight of 48, and 5 of reagent B, which has a weight
    of 32, then reagent A's percentage would be expressed as:
        (48 × 10) ÷ (48 × 10 + 32 × 5) = 480 ÷ 640 = 75%
    and reagent B's percentage would be expressed as:
        (32 × 5) ÷ 640 = 160 ÷ 640 = 25%

    Note: the logic derives the greatest common divisor (GCD) for the set of reagents weights and
    factors it out during data preparation before executing the combinatorial optimization.

    Factoring out a GCD of 16 would make the above equations:
        (3 × 10) ÷ (3 × 10 + 2 × 5) = 30 ÷ 40 = 75%
        (2 × 5) ÷ 40 = 10 ÷ 40 = 25%

    -----------------------------------------------------------------------------------------------

    Actual skill bonus for a reagent for the combination of item qualities used

    actualSkillBonusForReagent = ( ( q₁ + q₂ + ... + qₙ ) ÷ n ) × skillBonusPercentageForReagent × maxSkillBonus
    where:
    n = the recipe's required quantity for the reagent
    q = quality factor for the item provided

    The quality factors are as follows:
    quality 1 = 0.0 (i.e. no bonus)
    quality 2 = 0.5 (Dragonflight & The War Within)
              = 1.0 (Midnight)
    quality 3 = 1.0

    Using the previous examples of a max difficulty of 700 and 10 items with a 75% share of bonus skill,
    we get the following examples:
        All max quality: ( (1.0 × 10) ÷ 10 ) × 0.75 × 280 = 210 skill
        Half max, half mid: ( (1.0 × 5 + 0.5 × 5) ÷ 10 ) × 210 = 157.5 skill
        Half mid, half min: ( (0.5 × 5 + 0.0 × 5) ÷ 10 ) × 210 = 52.5 skill

    Note: When preparing data for 3-tier reagents (Dragonflight & The War Within), the logic sums the
    quality factors for each permutation of qualities and filters out duplicates with higher gold costs.
    This reduces the size of the permutation set from ⁿ⁺²C₂ to 2n+1. Additionally, the quality factor
    is multiplied by 2 so that max quality becomes 2 and mid quality becomes 1.  This reduces the
    use of floating point variables and therefore reduces potential rounding errors.

]]

---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.REAGENT_OPTIMIZATION
CraftSim.REAGENT_OPTIMIZATION = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.ReagentOptimization")

local function translateLuaIndex(index)
    return index + 1
end

--- Fonction pour vérifier si un item est craftable
---@param itemID number
---@return boolean, number? recipeID
local function IsItemCraftable(itemID)
    local recipes = C_TradeSkillUI.GetAllRecipeIDs()
    for _, recipeID in ipairs(recipes) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.itemIDCreated == itemID then
            return true, recipeID
        end
    end
    return false
end

---@return integer
function CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    if b ~= 0 then
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(b, a % b)
    else
        return abs(a)
    end
end

---@param ks CraftSim.REAGENT_OPTIMIZATION.REAGENT[]
---@param BPs table
---@param recipeData CraftSim.RecipeData
---@return CraftSim.ReagentOptimizationResult[] results
function CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ks, BPs, recipeData)
    print("optimizeKnapsack...")
    local numReagents, j, k, maxWeight

    numReagents = #ks or 1

    local maxQualityFactor = recipeData:IsSimplifiedQualityRecipe() and 1 or 2

    maxWeight = 0
    for i = 0, numReagents, 1 do
        local maxCompWeight = 0
        for _, comp in pairs(ks[i].compositions) do
            if comp.weight and comp.weight > maxCompWeight then
                maxCompWeight = comp.weight
            end
        end
        maxWeight = maxWeight + maxCompWeight
    end

    local inf = math.huge

    local b = {}

    for i = 0, numReagents, 1 do
        for j = 0, maxWeight, 1 do
            if b[i] == nil then
                b[i] = {}
            end
            b[i][j] = inf
        end
    end

    local c = {}

    for i = 0, numReagents, 1 do
        for j = 0, maxWeight, 1 do
            if c[i] == nil then
                c[i] = {}
            end
            c[i][j] = 0
        end
    end

    local i = 0
    for k = 0, maxQualityFactor * ks[i].numReq, 1 do
        if ks[i].compositions[k] then
            b[i][ks[i].compositions[k].weight] = ks[i].compositions[k].value
            c[i][ks[i].compositions[k].weight] = k
        end
    end

    for i = 1, numReagents, 1 do
        for k = 0, maxQualityFactor * ks[i].numReq, 1 do
            for j = 0, maxWeight, 1 do
                if b[i - 1][j] < inf then
                    if ks[i].compositions[k] then
                        if b[i][j + ks[i].compositions[k].weight] > b[i - 1][j] + ks[i].compositions[k].value then
                            b[i][j + ks[i].compositions[k].weight] = b[i - 1][j] + ks[i].compositions[k].value
                            c[i][j + ks[i].compositions[k].weight] = k
                        end
                    end
                end
            end
        end
    end

    local minValue = 0
    local outResult = {}
    local tStart = 0
    local tEnd = 0
    local lowestj = 0

    tEnd = maxWeight

    for h = 0, #BPs, 1 do
        local outAllocation = {
            qualityReached = nil,
            minValue = nil,
            allocations = {}
        }
        if BPs[h] >= 0 then
            tStart = math.ceil(BPs[h] * maxWeight)
            i = numReagents
            minValue = inf
            lowestj = 0

            for j = tStart, tEnd, 1 do
                if b[i][j] < minValue then
                    minValue = b[i][j]
                    lowestj = j
                end
            end
            j = lowestj

            for i = numReagents, 0, -1 do
                k = c[i][j]
                local composition = ks[i].compositions[k]
                if composition then
                    local matAllocations = {}
                    for qualityIndex, qualityAllocations in pairs(composition.mix) do
                        table.insert(matAllocations, {
                            quality = qualityIndex,
                            itemID = ks[i].reagent.items[qualityIndex].item:GetItemID(),
                            allocations = qualityAllocations
                        })
                    end
                    j = j - composition.weight

                    table.insert(outAllocation.allocations, {
                        itemName = ks[i].name,
                        allocations = matAllocations
                    })
                end
            end

            outAllocation.qualityReached = abs(h - (#BPs + 1))
            outAllocation.minValue = minValue
            table.insert(outResult, outAllocation)

            tEnd = tStart - 1
        end
    end

    local results = GUTIL:Map(outResult,
        function(result) return CraftSim.ReagentOptimizationResult(recipeData, result) end)

    return results
end

---@param recipeData CraftSim.RecipeData
---@param bestResult CraftSim.ReagentOptimizationResult
function CraftSim.REAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, bestResult)
    if not bestResult then
        return false
    end
    print("Is current allocation", false, true)
    return recipeData.reagentData:EqualsQualityReagents(bestResult.reagents)
end

---@param ksItem CraftSim.REAGENT_OPTIMIZATION.REAGENT
---@param useSubRecipeCosts boolean
function CraftSim.REAGENT_OPTIMIZATION:CreateCompositions(ksItem, useSubRecipeCosts)
    local inf = math.huge
    local requiredQuantity = ksItem.numReq

    for j = 0, 2 * requiredQuantity do
        ksItem.compositions[j] = { value = inf }
    end

    local q3ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[3].item:GetItemID(), true, false,
        useSubRecipeCosts)
    local q2ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[2].item:GetItemID(), true, false,
        useSubRecipeCosts)
    local q1ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[1].item:GetItemID(), true, false,
        useSubRecipeCosts)

    -- Si le réactif est craftable, utilisez le coût de ses réactifs
    local isCraftable, recipeID = IsItemCraftable(ksItem.reagent.items[1].item:GetItemID())
    if isCraftable and useSubRecipeCosts then
        local precraftRecipeData = CraftSim.RecipeData({ recipeID = recipeID })
        precraftRecipeData:SetCheapestQualityReagentsMax()
        precraftRecipeData:Update()
        -- Remplacez le coût du réactif par le coût total de ses précrafts
        local precraftCost = precraftRecipeData.craftingCost
        q3ItemPrice = precraftCost
        q2ItemPrice = precraftCost
        q1ItemPrice = precraftCost
    end

    if ksItem.isOrderReagent then
        local q3Count = ksItem.reagent.items[3].quantity
        local q2Count = ksItem.reagent.items[2].quantity
        local q1Count = ksItem.reagent.items[1].quantity
        local sumOfQualityFactors = 2 * q3Count + q2Count
        local goldCost = q3Count * q3ItemPrice + q2Count * q2ItemPrice + q1Count * q1ItemPrice
        ksItem.compositions = {
            [0] = {
                weight = sumOfQualityFactors * ksItem.recipeFactoredWeight,
                mix = { q1Count, q2Count, q3Count },
                value = goldCost,
            }
        }
    else
        local deltaMid = (q3ItemPrice - 2 * q2ItemPrice + q1ItemPrice)
        for sumOfQualityFactors = 0, 2 * requiredQuantity do
            local q3Low = math.max(0, sumOfQualityFactors - requiredQuantity)
            local q3High = math.floor(sumOfQualityFactors / 2)
            if q3Low <= q3High then
                local q3Count
                if deltaMid > 0 then
                    q3Count = q3Low
                elseif deltaMid < 0 then
                    q3Count = q3High
                else
                    q3Count = q3Low
                end
                local q2Count = sumOfQualityFactors - 2 * q3Count
                local q1Count = requiredQuantity - q2Count - q3Count
                local goldCost = q1Count * q1ItemPrice + q2Count * q2ItemPrice + q3Count * q3ItemPrice

                ksItem.compositions[sumOfQualityFactors].weight = sumOfQualityFactors * ksItem.recipeFactoredWeight
                ksItem.compositions[sumOfQualityFactors].mix = { q1Count, q2Count, q3Count }
                ksItem.compositions[sumOfQualityFactors].value = goldCost
            end
        end
    end
end

---@param ksItem CraftSim.REAGENT_OPTIMIZATION.REAGENT
---@param useSubRecipeCosts boolean
function CraftSim.REAGENT_OPTIMIZATION:CreateSimplifiedCompositions(ksItem, useSubRecipeCosts)
    local requiredQuantity = ksItem.numReq

    for j = 0, requiredQuantity do
        ksItem.compositions[j] = { value = math.huge }
    end

    local q2ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[2].item:GetItemID(), true, false,
        useSubRecipeCosts)
    local q1ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[1].item:GetItemID(), true, false,
        useSubRecipeCosts)

    -- Si le réactif est craftable, utilisez le coût de ses réactifs
    local isCraftable, recipeID = IsItemCraftable(ksItem.reagent.items[1].item:GetItemID())
    if isCraftable and useSubRecipeCosts then
        local precraftRecipeData = CraftSim.RecipeData({ recipeID = recipeID })
        precraftRecipeData:SetCheapestQualityReagentsMax()
        precraftRecipeData:Update()
        -- Remplacez le coût du réactif par le coût total de ses précrafts
        local precraftCost = precraftRecipeData.craftingCost
        q2ItemPrice = precraftCost
        q1ItemPrice = precraftCost
    end

    if ksItem.isOrderReagent then
        local q2Count = ksItem.reagent.items[2].quantity
        local q1Count = ksItem.reagent.items[1].quantity
        local allocatedQuantity = q2Count
        local goldCost = q2Count * q2ItemPrice + q1Count * q1ItemPrice
        ksItem.compositions = { [0] = {
            weight = allocatedQuantity * ksItem.recipeFactoredWeight,
            mix = { q1Count, q2Count },
            value = goldCost,
        } }
    else
        for sumOfQualityFactors = 0, requiredQuantity do
            local q2Count = sumOfQualityFactors
            local q1Count = requiredQuantity - q2Count
            local goldCost = q1Count * q1ItemPrice + q2Count * q2ItemPrice

            if ksItem.compositions == nil or
                (ksItem.compositions[sumOfQualityFactors] and ksItem.compositions[sumOfQualityFactors].value > goldCost)
            then
                ksItem.compositions[sumOfQualityFactors].weight = sumOfQualityFactors * ksItem.recipeFactoredWeight
                ksItem.compositions[sumOfQualityFactors].mix = { q1Count, q2Count }
                ksItem.compositions[sumOfQualityFactors].value = goldCost
            end
        end
    end
end

---@param recipeData CraftSim.RecipeData
---@param maxQuality number?
---@param useSubRecipeCosts boolean?
---@return CraftSim.ReagentOptimizationResult?
function CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, maxQuality, useSubRecipeCosts)
    useSubRecipeCosts = useSubRecipeCosts or false
    if not recipeData.hasQualityReagents then
        return nil
    end

    if not recipeData.supportsQualities then
        local result = CraftSim.ReagentOptimizationResult(recipeData)
        for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
            if reagent.hasQuality then
                local resultReagent = reagent:Copy()
                resultReagent:SetCheapestQualityMax(recipeData.subRecipeCostsEnabled)
                table.insert(result.reagents, resultReagent)
            end
        end
        return result
    end

    local maxOptimizationQuality = math.min(maxQuality or recipeData.maxQuality, recipeData.maxQuality)

    local requiredReagents = GUTIL:Filter(recipeData.reagentData.requiredReagents, function(reagent)
        return reagent.hasQuality
    end)

    ---@type table<integer, integer>
    local reagentWeightsBySlot = {}
    for i = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(i)]
        local itemID = reagent.items[1].item:GetItemID()
        reagentWeightsBySlot[i] = CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID)
    end

    local gcdOfReagentWeights = GUTIL:Fold(reagentWeightsBySlot, 0, function(a, b)
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    end)
    if gcdOfReagentWeights == 0 then
        gcdOfReagentWeights = 1
    end

    ---@type CraftSim.REAGENT_OPTIMIZATION.REAGENT[]
    local ksItems = {}
    for i = 0, #requiredReagents - 1, 1 do
        ksItems[i] = {}
    end

    CraftSim.DEBUG:StartProfiling("KnapsackKsItemCreation")
    for index = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(index)]
        ---@class CraftSim.REAGENT_OPTIMIZATION.REAGENT
        local ksItem = {
            name = reagent.items[1].item:GetItemName(),
            reagent = reagent:Copy(),
            isOrderReagent = reagent:IsOrderReagentIn(recipeData),
            numReq = reagent.requiredQuantity,
            recipeFactoredWeight = reagentWeightsBySlot[index] / gcdOfReagentWeights,
            compositions = {}
        }

        if recipeData:IsSimplifiedQualityRecipe() then
            CraftSim.REAGENT_OPTIMIZATION:CreateSimplifiedCompositions(ksItem, useSubRecipeCosts)
        else
            CraftSim.REAGENT_OPTIMIZATION:CreateCompositions(ksItem, useSubRecipeCosts)
        end
        ksItems[index] = ksItem
    end
    CraftSim.DEBUG:StopProfiling("KnapsackKsItemCreation")

    local numBP = 0
    local craftingDifficultyBP = {}
    if recipeData.maxQuality == 3 then
        craftingDifficultyBP = {
            [0] = 1,
            [1] = 0.5,
            [2] = 0
        }
    elseif recipeData.maxQuality == 2 then
        craftingDifficultyBP = {
            [0] = 1,
            [1] = 0
        }
    elseif recipeData.maxQuality == 5 then
        craftingDifficultyBP = {
            [0] = 1,
            [1] = 0.8,
            [2] = 0.5,
            [3] = 0.2,
            [4] = 0,
        }
    end

    local bpRemovalCount = recipeData.maxQuality - maxOptimizationQuality
    if bpRemovalCount > 0 then
        local craftingDifficultyBPTrimmed = {}
        local newIndex = 0
        for i = bpRemovalCount, #craftingDifficultyBP + 1, 1 do
            if craftingDifficultyBP[i] then
                craftingDifficultyBPTrimmed[newIndex] = craftingDifficultyBP[i]
                newIndex = newIndex + 1
            end
        end
        craftingDifficultyBP = craftingDifficultyBPTrimmed
    end

    numBP = #craftingDifficultyBP + 1
    if numBP <= 0 or craftingDifficultyBP[0] == nil then
        local result = CraftSim.ReagentOptimizationResult(recipeData)
        for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
            if reagent.hasQuality then
                local resultReagent = reagent:Copy()
                resultReagent:SetCheapestQualityMax(recipeData.subRecipeCostsEnabled)
                table.insert(result.reagents, resultReagent)
            end
        end
        return result
    end

    local reagentMaxSkillFactor = recipeData.reagentData:GetMaxSkillFactor()
    local recipeMaxSkillBonus = reagentMaxSkillFactor * recipeData.baseProfessionStats.recipeDifficulty.value
    local reagentSkillContribution = recipeData.reagentData:GetSkillFromRequiredReagents()
    local skillWithoutReagentIncrease = recipeData.professionStats.skill.value - reagentSkillContribution

    local function calculateArrayBP(playerSkill)
        local arrayBP = {}
        for i = 0, numBP - 1, 1 do
            local extraSkillPoint = (CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET") and 1) or 0
            local skillBreakpoint = craftingDifficultyBP[i] * recipeData.professionStats.recipeDifficulty.value + extraSkillPoint

            arrayBP[i] = skillBreakpoint - playerSkill
            if arrayBP[i] <= 0 then
                arrayBP[i] = 0
                for j = (i + 1), (numBP - 1), 1 do
                    arrayBP[j] = -1
                end
                break
            end

            arrayBP[i] = arrayBP[i] / recipeMaxSkillBonus
            if arrayBP[i] > 1 then
                arrayBP[i] = -1
            end
        end
        return arrayBP
    end

    local arrayBP = calculateArrayBP(skillWithoutReagentIncrease)

    CraftSim.DEBUG:StartProfiling("optimizeKnapsack")
    local resultsUnfiltered = CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ksItems, arrayBP, recipeData)
    local bestResult = resultsUnfiltered[1]

    if bestResult then
        bestResult:OptimizeQualityIDs(recipeData.subRecipeCostsEnabled)
    end
    CraftSim.DEBUG:StopProfiling("optimizeKnapsack")

    return bestResult
end

---@param reagentData CraftSim.ReagentData
---@return integer
function CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID)
    local weightEntry = CraftSim.REAGENT_DATA[itemID]
    if weightEntry == nil then
        return 0
    end
    return weightEntry.weight
end
