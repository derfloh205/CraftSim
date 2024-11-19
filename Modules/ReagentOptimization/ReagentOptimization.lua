---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.REAGENT_OPTIMIZATION
CraftSim.REAGENT_OPTIMIZATION = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.ReagentOptimization")

local function translateLuaIndex(index)
    return index + 1
end

function CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID)
    local weightEntry = CraftSim.REAGENT_DATA[itemID]
    if weightEntry == nil then
        return 0
    end
    return weightEntry.weight
end

function CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    --print("get gcd between " .. a .. " and " .. b)
    if b ~= 0 then
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(b, a % b)
    else
        return abs(a)
    end
end

--- By Liqorice's knapsack solution
---@param ks table
---@param BPs table
---@param recipeData CraftSim.RecipeData
---@return CraftSim.ReagentOptimizationResult[] results
function CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ks, BPs, recipeData)
    print("optimizeKnapsack...")
    local numReagents, i, j, k, maxWeight

    numReagents = #ks or 1 -- should be ks -1 or 1 and behave like UBound(ks, 1)

    maxWeight = 0
    for i = 0, numReagents, 1 do
        maxWeight = maxWeight + 2 * ks[i].n * ks[i].mWeight
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
    for k = 0, 2 * ks[i].n, 1 do -- for each weight and value in reagent(0)
        --print("current crumb: " .. k)
        if ks[i].crumb[k] then
            b[i][ks[i].crumb[k].weight] = ks[i].crumb[k].value
            c[i][ks[i].crumb[k].weight] = k
        end
    end

    -- do next weights
    for i = 1, numReagents, 1 do
        for k = 0, 2 * ks[i].n, 1 do   -- for each weight and value in reagent(i)
            for j = 0, maxWeight, 1 do -- for each possible weight value
                -- look at the previous row for this weight j, if it has a value then...
                if b[i - 1][j] < inf then
                    -- we know it is reachable
                    -- so look at the spot where adding the new weight would put us
                    -- if its current value is > than what we get by adding the new weight...

                    -- only if crumb exists (consider crumb removal due to order)
                    if ks[i].crumb[k] then
                        if b[i][j + ks[i].crumb[k].weight] > b[i - 1][j] + ks[i].crumb[k].value then
                            -- our new weight is better so use its value instead
                            b[i][j + ks[i].crumb[k].weight] = b[i - 1][j] + ks[i].crumb[k].value
                            -- and record the weight that got us here
                            c[i][j + ks[i].crumb[k].weight] = k
                        end
                    end
                end
            end
        end
    end

    local minValue = 0
    local outArr = {}
    local outResult = {}
    local target = 0
    local h = 0
    local tStart = 0
    local tEnd = 0
    local lowestj = 0 -- target start BP value, end search element for that BP, lowest index for the min value
    local matString = ""

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
                local crumb = ks[i].crumb[k] -- to work around the single crumb of patron order reagents
                if crumb then
                    --print("current matstring: " .. tostring(matString))
                    --print("name: " .. ks[i].name)
                    local matAllocations = {}
                    for qualityIndex, qualityAllocations in pairs(crumb.mix) do
                        --print("qualityIndex: " .. qualityIndex)
                        --print("allocations: " .. qualityAllocations)
                        table.insert(matAllocations, {
                            quality = qualityIndex,
                            itemID = ks[i].reagent.items[qualityIndex].item:GetItemID(),
                            allocations = qualityAllocations
                        })
                    end
                    j = j - crumb.weight

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

---@param ksItem CraftSim.REAGENT_OPTIMIZATION.KS_ITEM
---@param useSubRecipeCosts boolean
function CraftSim.REAGENT_OPTIMIZATION:CreateCrumbs(ksItem, useSubRecipeCosts)
    local inf = math.huge

    local j, k, q3Count, q2Count, q1Count, requiredQuantity, allocatedQuantity
    local goldCost

    requiredQuantity = ksItem.n

    -- APPROACH: do not translate indices here to lua indices cause they are not used for accessing later.. w is used for that
    --print("crumbs init to " .. (2*n))
    for j = 0, 2 * requiredQuantity, 1 do
        ksItem.crumb[j] = {}
        ksItem.crumb[j].value = inf
    end

    local q3ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[3].item:GetItemID(), true, false,
        useSubRecipeCosts)
    local q2ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[2].item:GetItemID(), true, false,
        useSubRecipeCosts)
    local q1ItemPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(ksItem.reagent.items[1].item:GetItemID(), true, false,
        useSubRecipeCosts)

    if ksItem.isOrderReagent then
        -- only one available crumb - current allocation
        q3Count = ksItem.reagent.items[3].quantity
        q2Count = ksItem.reagent.items[2].quantity
        q1Count = ksItem.reagent.items[1].quantity
        allocatedQuantity = 2 * q3Count + q2Count
        goldCost = q3Count * q3ItemPrice + q2Count * q2ItemPrice + q1Count * q1ItemPrice
        ksItem.crumb = {
            [0] = {
                weight = allocatedQuantity * ksItem.mWeight,
                mix = { q1Count, q2Count, q3Count },
                value = goldCost,
            }
        }
    else
        for k = 0, requiredQuantity, 1 do
            --print("creating crumb #" .. k)
            for j = k, requiredQuantity, 1 do
                q3Count = k
                q2Count = j - k
                q1Count = requiredQuantity - j
                allocatedQuantity = 2 * q3Count + q2Count

                goldCost = q3Count * q3ItemPrice + q2Count * q2ItemPrice + q1Count * q1ItemPrice
                if goldCost < ksItem.crumb[allocatedQuantity].value then
                    -- q3, q2, q1

                    ksItem.crumb[allocatedQuantity].weight = allocatedQuantity * ksItem.mWeight
                    ksItem.crumb[allocatedQuantity].mix = { q1Count, q2Count, q3Count } -- q3, q2, q1
                    ksItem.crumb[allocatedQuantity].value = goldCost
                end
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
        table.foreach(recipeData.reagentData.requiredReagents, function(_, reagent)
            if reagent.hasQuality then
                local resultReagent = reagent:Copy()
                resultReagent:SetCheapestQualityMax(recipeData.subRecipeCostsEnabled)
                table.insert(result.reagents, resultReagent)
            end
        end)
        return result
    end

    local maxOptimizationQuality = math.min(maxQuality or recipeData.maxQuality, recipeData.maxQuality)

    -- Create Knapsacks for required reagents with different Qualities
    local requiredReagents = GUTIL:Filter(recipeData.reagentData.requiredReagents, function(reagent)
        return reagent.hasQuality
    end)


    local mWeight = {}
    -- init
    for i = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(i)]
        local itemID = reagent.items[1].item:GetItemID()
        --print("mWeight array init: " .. i .. " to " .. CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) )
        mWeight[i] = CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) --  * reagent.requiredQuantity fixed double counting of quantity
    end

    --print(" calculating gcd of " .. unpack(mWeight))
    local weightGCD = GUTIL:Fold(mWeight, 0, function(a, b)
        --print("fold " .. a .. " and " .. b)
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    end)
    -- prevent division-by-zero when no reagents are weighted
    if weightGCD == 0 then
        weightGCD = 1
    end

    --print("gcd: " .. tostring(weightGCD))
    -- create the ks items
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
        --print("creating ks item for " .. tostring(reagent.name) .. "(" .. tostring(reagent.itemsInfo[1]) .. ")")
        ---@class CraftSim.REAGENT_OPTIMIZATION.KS_ITEM
        local ksItem = {
            name = reagent.items[1].item:GetItemName(),
            reagent = reagent:Copy(),
            isOrderReagent = reagent:IsOrderReagentIn(recipeData),
            n = reagent.requiredQuantity,
            mWeight = mWeight[index] / weightGCD,
            crumb = {}
        }

        --print("mWeight of " .. reagent.name .. " is " .. ksItem.mWeight)
        --print("mWeight[index] / weightGCD -> " .. mWeight[index] .. " / " .. weightGCD .. " = " .. mWeight[index] / weightGCD)

        -- fill crumbs
        CraftSim.REAGENT_OPTIMIZATION:CreateCrumbs(ksItem, recipeData.subRecipeCostsEnabled)
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
