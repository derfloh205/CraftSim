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

---Returns the recipe weight for the reagent
---@param itemID integer
---@return integer weight the weight, if found, or 0
function CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID)
    local weightEntry = CraftSim.REAGENT_DATA[itemID]
    if weightEntry == nil then
        return 0
    end
    return weightEntry.weight
end

---@return integer
function CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    --print("get gcd between " .. a .. " and " .. b)
    if b ~= 0 then
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(b, a % b)
    else
        return abs(a)
    end
end

--- By Liqorice's knapsack solution
---@param ks CraftSim.REAGENT_OPTIMIZATION.REAGENT[]
---@param BPs table
---@param recipeData CraftSim.RecipeData
---@return CraftSim.ReagentOptimizationResult[] results
function CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ks, BPs, recipeData)
    print("optimizeKnapsack...")
    local numReagents, j, k, maxWeight

    numReagents = #ks or 1 -- should be ks -1 or 1 and behave like UBound(ks, 1)

    maxWeight = 0
    for i = 0, numReagents, 1 do
        maxWeight = maxWeight + 2 * ks[i].numReq * ks[i].recipeFactoredWeight
    end

    local inf = math.huge

    local b = {}

    -- initialize the b array
    for i = 0, numReagents, 1 do
        for j = 0, maxWeight, 1 do
            if b[i] == nil then
                b[i] = {}
            end
            b[i][j] = inf
        end
    end

    local c = {}

    -- initialize the c array
    for i = 0, numReagents, 1 do
        for j = 0, maxWeight, 1 do
            if c[i] == nil then
                c[i] = {}
            end
            c[i][j] = 0
        end
    end

    -- do initial weight first
    local i = 0
    for k = 0, 2 * ks[i].numReq, 1 do -- for each weight and value in reagent(0)
        --print("current composition: " .. k)
        if ks[i].compositions[k] then
            b[i][ks[i].compositions[k].weight] = ks[i].compositions[k].value
            c[i][ks[i].compositions[k].weight] = k
        end
    end

    -- do next weights
    for i = 1, numReagents, 1 do
        for k = 0, 2 * ks[i].numReq, 1 do   -- for each weight and value in reagent(i)
            for j = 0, maxWeight, 1 do -- for each possible weight value
                -- look at the previous row for this weight j, if it has a value then...
                if b[i - 1][j] < inf then
                    -- we know it is reachable
                    -- so look at the spot where adding the new weight would put us
                    -- if its current value is > than what we get by adding the new weight...

                    -- only if composition exists (consider composition removal due to order)
                    if ks[i].compositions[k] then
                        if b[i][j + ks[i].compositions[k].weight] > b[i - 1][j] + ks[i].compositions[k].value then
                            -- our new weight is better so use its value instead
                            b[i][j + ks[i].compositions[k].weight] = b[i - 1][j] + ks[i].compositions[k].value
                            -- and record the weight that got us here
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
    local lowestj = 0 -- target start BP value, end search element for that BP, lowest index for the min value

    -- Breakpoints are sorted highest to lowest
    -- Array value = -1 means this breakpoint is unreachable
    --               0 means no skill bonus required to reach this BP
    --               0 means the indicated skill bonus is required to reach this BP
    -- At least one entry will be >= 0

    -- we will search for lowest cost between tStart and tEnd (we will move both for each breakpoint)

    tEnd = maxWeight

    for h = 0, #BPs, 1 do -- #BPs gives 1 less than how many are in there so here it fits!
        local outAllocation = {
            qualityReached = nil,
            minValue = nil,
            allocations = {}
        }
        if BPs[h] >= 0 then --can reach this BP
            tStart = math.ceil(BPs[h] * maxWeight)
            i = numReagents -- i was initialized above
            -- walk the last row of the matrix backwards to find the best value (gold cost) for minimum target weight (j = skill bonus)
            i = numReagents
            minValue = inf

            -- search the space from target to the end weight (for this breakpoint) to get the lowest cost
            for j = tStart, tEnd, 1 do
                if b[i][j] < minValue then -- found a new low cost
                    minValue = b[i][j]
                    lowestj = j
                end
            end
            -- now minValue is set and lowestj points to the correct column
            j = lowestj

            -- create the list of reagents that represent optimization for target BP
            for i = numReagents, 0, -1 do
                k = c[i][j]                  -- the index into V and W for minValue > target
                local composition = ks[i].compositions[k] -- to work around the single composition of patron order reagents
                if composition then
                    --print("current matstring: " .. tostring(matString))
                    --print("name: " .. ks[i].name)
                    local matAllocations = {}
                    for qualityIndex, qualityAllocations in pairs(composition.mix) do
                        --print("qualityIndex: " .. qualityIndex)
                        --print("allocations: " .. qualityAllocations)
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

            -- now set our new target endpoint to the column before the current target start so that
            -- next time through this loop we don't search past this breakpoint
            tEnd = tStart - 1
        end
    end

    local results = GUTIL:Map(outResult,
        function(result) return CraftSim.ReagentOptimizationResult(recipeData, result) end)

    return results
end

---@param optimizationResult CraftSim.ReagentOptimizationResult
function CraftSim.REAGENT_OPTIMIZATION:AssignBestAllocation(optimizationResult)
    local simulationModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local reagentOverwriteFrame = simulationModeFrames.reagentOverwriteFrame
    if CraftSim.SIMULATION_MODE.isActive then
        for reagentIndex, currentInput in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do
            local reagent = optimizationResult.reagents[reagentIndex]

            if reagent then
                if currentInput.isActive and reagent.hasQuality then
                    for i, reagentItem in pairs(reagent.items) do
                        currentInput["inputq" .. i]:SetText(reagentItem.quantity)
                    end
                end
            end
        end

        CraftSim.INIT:TriggerModuleUpdate()
    end
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

    if ksItem.isOrderReagent then
        local q2Count = ksItem.reagent.items[2].quantity
        local q1Count = ksItem.reagent.items[1].quantity
        local allocatedQuantity = q2Count
        local goldCost = q2Count * q2ItemPrice + q1Count * q1ItemPrice
        ---@class CraftSim.REAGENT_OPTIMIZATION.REAGENT_COMPOSITION
        ---@field weight integer percentage of weighted contribution
        ---@field mix table<integer, integer> dictionary of item counts by quality
        ---@field value integer total cost of reagent items in composition
        local orderReagentComposition = {
            weight = allocatedQuantity * ksItem.recipeFactoredWeight,
            mix = { q1Count, q2Count },
            value = goldCost,
        }
        ksItem.compositions = { [0] = orderReagentComposition }
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

-- By Liqorice's knapsack solution
---@param recipeData CraftSim.RecipeData
---@param maxQuality number?
---@return CraftSim.ReagentOptimizationResult?
function CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, maxQuality)
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

    -- Create Knapsacks for required reagents with different Qualities
    local requiredReagents = GUTIL:Filter(recipeData.reagentData.requiredReagents, function(reagent)
        return reagent.hasQuality
    end)

    ---@type table<integer, integer>
    local reagentWeightsBySlot = {}
    -- init
    for i = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(i)]
        local itemID = reagent.items[1].item:GetItemID()
        --print("reagentWeightsBySlot array init: " .. i .. " to " .. CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) )
        reagentWeightsBySlot[i] = CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) --  * reagent.requiredQuantity fixed double counting of quantity
    end

    -- The greatest common divisor of the weights is derived here to simplify the factors used in later calculation and thereby reduce overall permutation count (i.e. compositions)
    --print(" calculating gcd of " .. unpack(reagentWeightsBySlot))
    local gcdOfReagentWeights = GUTIL:Fold(reagentWeightsBySlot, 0, function(a, b)
        --print("fold " .. a .. " and " .. b)
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    end)
    -- prevent division-by-zero when no reagents are weighted
    if gcdOfReagentWeights == 0 then
        gcdOfReagentWeights = 1
    end

    --print("gcd: " .. tostring(gcdOfReagentWeights))
    -- create the ks items

    ---@type CraftSim.REAGENT_OPTIMIZATION.REAGENT[]
    local ksItems = {}
    -- init all arrays to force 0 -> n-1 indexing
    for i = 0, #requiredReagents - 1, 1 do
        ksItems[i] = {}
    end
    CraftSim.DEBUG:StartProfiling("KnapsackKsItemCreation")
    -- !!!!! lua tables init with a 0 index, show one less entry with #table then there really is
    for index = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(index)]
        -- get costs for reagent quality
        -- print("creating ks item for " .. tostring(reagent.name) .. "(" .. tostring(reagent.itemsInfo[1]) .. ")")

        ---@class CraftSim.REAGENT_OPTIMIZATION.REAGENT
        ---@field compositions table<integer, CraftSim.REAGENT_OPTIMIZATION.REAGENT_COMPOSITION>
        local ksItem = {
            name = reagent.items[1].item:GetItemName(),
            reagent = reagent:Copy(),
            isOrderReagent = reagent:IsOrderReagentIn(recipeData),
            numReq = reagent.requiredQuantity,
            recipeFactoredWeight = reagentWeightsBySlot[index] / gcdOfReagentWeights,
            compositions = {}
        }

        --print("recipeFactoredWeight of " .. reagent.name .. " is " .. ksItem.recipeFactoredWeight)
        --print("recipeFactoredWeight[index] / weightGCD -> " .. recipeFactoredWeight[index] .. " / " .. weightGCD .. " = " .. recipeFactoredWeight[index] / weightGCD)

        -- fill compositions
        if recipeData:IsSimplifiedQualityRecipe() then
            CraftSim.REAGENT_OPTIMIZATION:CreateSimplifiedCompositions(ksItem, recipeData.subRecipeCostsEnabled)
        else
            CraftSim.REAGENT_OPTIMIZATION:CreateCompositions(ksItem, recipeData.subRecipeCostsEnabled)
        end
        ksItems[index] = ksItem
    end
    CraftSim.DEBUG:StopProfiling("KnapsackKsItemCreation")

    --CraftSim.DEBUG:InspectTable(ksItems, "ksItems")

    -- Calculate ArrayBP (The skill breakpoints)
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

    -- consider maxOptimizationQuality by removing the top breakpoints
    -- e.g. optimizing a maxQ3 recipe for q2 would remove 3-2=1 top breakpoints
    local bpRemovalCount = recipeData.maxQuality - maxOptimizationQuality

    if bpRemovalCount > 0 then
        -- manually remove and reorder first entries due to tremove not considering the 0 index
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

    numBP = #craftingDifficultyBP + 1 -- the 0 index will not be counted..
    --print("numBP: " .. numBP)

    local reagentMaxSkillFactor = recipeData.reagentData:GetMaxSkillFactor()
    local recipeMaxSkillBonus = reagentMaxSkillFactor * recipeData.baseProfessionStats.recipeDifficulty.value

    -- Calculate the reagent bonus needed to meet each breakpoint based on the player's
    --   existing skill and the recipe difficulty (as a fraction of the recipeMaxSkillBonus
    -- Breakpoints are sorted highest to lowest
    -- Array value = -1 means this breakpoint is unreachable
    --               0 means no skill bonus required to reach this BP
    --               > 0 means the indicated skill bonus is required to reach this BP
    -- At least one entry will be >= 0

    -- should be 0 for scan
    local reagentSkillContribution = recipeData.reagentData:GetSkillFromRequiredReagents()
    --local skillsFromOptionalReagents = recipeData.reagentData:GetProfessionStatsByOptionals().skill.value
    --local totalBaseSkill = skillsFromOptionalReagents + recipeData.professionStats.skill.value
    local skillWithoutReagentIncrease = recipeData.professionStats.skill.value - reagentSkillContribution
    print("in Simulation Mode: " .. tostring(recipeData.isSimulationModeData ~= nil))
    print("skill total: " .. tostring(recipeData.professionStats.skill.value))
    print("skill without reagents: " .. tostring(skillWithoutReagentIncrease))

    print("skillWithoutReagentIncrease" .. tostring(skillWithoutReagentIncrease))


    local expectedQualityWithoutReagents = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData,
        skillWithoutReagentIncrease)

    print("expectedQualityWithoutReagents: " .. tostring(expectedQualityWithoutReagents))

    local function calculateArrayBP(playerSkill)
        local arrayBP = {}
        for i = 0, numBP - 1, 1 do
            local extraSkillPoint = (CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET") and 1) or 0
            local skillBreakpoint = craftingDifficultyBP[i] * recipeData.professionStats.recipeDifficulty.value +
                extraSkillPoint

            print("skill BP: " .. skillBreakpoint)
            arrayBP[i] = skillBreakpoint - playerSkill
            -- If skill already meets or exceeds this BP...
            if arrayBP[i] <= 0 then -- ...then no skill bonus is needed to reach this breakpoint
                arrayBP[i] = 0
                -- ...and all breakpoints lower than this one are unreachable
                -- CraftSim specific: no need to translate index cause it is based on i
                for j = (i + 1), (numBP - 1), 1 do
                    arrayBP[j] = -1 -- cannot reach this quality
                end
                break               -- exit for I guess means break.. and not continue
            end

            -- not 100% clear where blizzard has landed on rounding errors, need to check this at some point
            -- we want our array of BP's to be expressed not as skill numbers but as a fraction of
            -- the recipeMaxSkillBonus. This way when later looking at optimizing for reagent weights we
            -- can use the BP% x maxWeight as our markers
            arrayBP[i] = arrayBP[i] / recipeMaxSkillBonus

            if arrayBP[i] > 1 then -- Can't reach this high even with all Q3 reagents
                arrayBP[i] = -1
            end
        end

        return arrayBP
    end

    local arrayBP = calculateArrayBP(skillWithoutReagentIncrease)


    CraftSim.DEBUG:StartProfiling("optimizeKnapsack")
    -- Optimize Knapsack
    local resultsUnfiltered = CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ksItems, arrayBP, recipeData)

    -- remove any result that maps to the expected quality without reagent increase
    -- -- NEW: any that is below! Same is fine
    -- local results = GUTIL:Filter(resultsUnfiltered, function(result)
    --     return result.qualityID >= expectedQualityWithoutReagents
    -- end)

    local bestResult = resultsUnfiltered[1]

    if bestResult then
        -- if certain qualityIDs have the same price, use the higher qualityID
        bestResult:OptimizeQualityIDs(recipeData.subRecipeCostsEnabled)
    end

    CraftSim.DEBUG:StopProfiling("optimizeKnapsack")

    return bestResult
end
