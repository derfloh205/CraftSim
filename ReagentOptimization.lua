CraftSimREAGENT_OPTIMIZATION = {}

local function translateLuaIndex(index)
    return index + 1
end

-- wow.tools -> ModifiedCraftingCategory -- TODO: export?
DEBUG_REAGENT_WEIGHTS = {
    --Draconium Ore
    [189143] = 10,
    [188658] = 10,
    [190311] = 10,

    -- Severite Ore
    [190395] = 3,
    [190396] = 3,
    [190394] = 3,

    -- Primal Flux
    [190452] = 0 -- no entry.. maybe cause no quality?
}

-- By Liqorice's knapsack solution
function CraftSimREAGENT_OPTIMIZATION:OptimizeReagentAllocation()
    local recipeData = CraftSimDATAEXPORT:exportRecipeData()
    local priceData = CraftSimPRICEDATA:GetPriceData(recipeData)

    if recipeData == nil then
        print("recipe data nil")
        return nil
    end

    -- insert costs
    local reagentCostsByQuality = CraftSimPRICEDATA:GetReagentsPriceByQuality(recipeData)

    -- insert
    local requiredReagents = {}
    for index, reagent in pairs(recipeData.reagents) do
        reagent.itemsInfo = reagentCostsByQuality[index]
    end

    local recipeFixedCost = 0
    for index, reagent in pairs(recipeData.reagents) do
        if not reagent.differentQualities then
            recipeFixedCost = recipeFixedCost + reagent.itemsInfo[1].minBuyout * reagent.requiredQuantity
        end
    end

    -- Create Knapsacks for required reagents with different Qualities
    local requiredReagents = CraftSimUTIL:FilterTable(recipeData.reagents, function(reagent) 
        return reagent.reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED and reagent.differentQualities
    end)

    local mWeight = {}
    -- init
    for i = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(i)]
        local itemID = reagent.itemsInfo[1].itemID -- all qualities have the same weight
        mWeight[i] = CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) * reagent.requiredQuantity
    end

    local weightGCD = CraftSimUTIL:FoldTable(mWeight, function(a, b) 
        return CraftSimREAGENT_OPTIMIZATION:GetGCD(a, b)
    end, true)

    -- create the ks items
    local ksItems = {}
    -- init all arrays to force 0 -> n-1 indexing
    for i = 0, #requiredReagents - 1, 1 do
        ksItems[i] = {}
    end
    -- !!!!! lua tables init with a 0 index, show one less entry with #table then there really is
    for index = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(index)]
        local costs ={}
        -- get costs for reagent quality
        local ksItem = {
            name = reagent.name,
            itemsInfo = reagent.itemsInfo, -- this contains the ids of all qualities and costs
            n = reagent.requiredQuantity,
            mWeight = mWeight[index] / weightGCD,
            crumb = {}
        }        

        -- fill crumbs
        CraftSimREAGENT_OPTIMIZATION:CreateCrumbs(ksItem)
        ksItems[index] = ksItem
    end

    -- Calculate ArrayBP (The skill breakpoints)
    local numBP = 0
    local arrayBP = {}
    
    local craftingDifficultyBP = nil
    if recipeData.maxQuality == 3 then
        craftingDifficultyBP = {
            [0] = 1, 
            [1] = 0.5,
            [2] = 0}
    elseif recipeData.maxQuality == 5 then
        craftingDifficultyBP = {
            [0] = 1,
            [1] = 0.8,
            [2] = 0.5,
            [3] = 0.2,
            [4] = 0,
        }
    end
    numBP = #craftingDifficultyBP + 1 -- the 0 index will not be counted..
    --print("numBP: " .. numBP)

    local recipeMaxSkillBonus = 0.25 * recipeData.recipeDifficulty
    print("max skill bonus: " .. recipeMaxSkillBonus)
    
    -- Calculate the material bonus needed to meet each breakpoint based on the player's
    --   existing skill and the recipe difficulty (as a fraction of the recipeMaxSkillBonus
    -- Breakpoints are sorted highest to lowest
    -- Array value = -1 means this breakpoint is unreachable
    --               0 means no skill bonus required to reach this BP
    --               > 0 means the indicated skill bonus is required to reach this BP
    -- At least one entry will be >= 0
    print("working with skill: " ..  recipeData.stats.skill)
    local totalSkill = recipeData.stats.skill

    local skillWithoutReagentIncrease = totalSkill - CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData)

    for i = 0, numBP - 1, 1 do
        print("checking BP: " .. tostring(craftingDifficultyBP[i]))
        local skillBreakpoint = craftingDifficultyBP[i] * recipeData.recipeDifficulty
        print("skill BP: " .. skillBreakpoint)
        -- EXPERIMENT: try to adjust skillbp by 1 to workaround blizz rounding errors
        skillBreakpoint = skillBreakpoint + 1
        arrayBP[i] = skillBreakpoint - skillWithoutReagentIncrease
        print("skill needed for this breakpoint:" .. arrayBP[i])
        -- If skill already meets or exceeds this BP...
        if arrayBP[i] <= 0 then  -- ...then no skill bonus is needed to reach this breakpoint
            arrayBP[i] = 0
            -- ...and all breakpoints lower than this one are unreachable
            -- CraftSim specific: no need to translate index cause it is based on i
            for j = (i + 1), (numBP - 1), 1 do
                arrayBP[j] = -1 -- cannot reach this quality
            end
            break -- exit for I guess means break.. and not continue
        end
        
        -- not 100% clear where blizzard has landed on rounding errors, need to check this at some point
        -- we want our array of BP's to be expressed not as skill numbers but as a fraction of
        -- the recipeMaxSkillBonus. This way when later looking at optimizing for material weights we
        -- can use the BP% x maxWeight as our markers
        arrayBP[i] = arrayBP[i] / recipeMaxSkillBonus
        
        if arrayBP[i] > 1 then -- Can't reach this high even with all Q3 materials
            arrayBP[i] = -1
        end
    end

    print("arrayBP: ")
    CraftSimUTIL:PrintTable(arrayBP)


    -- Optimize Knapsack
    local results = CraftSimREAGENT_OPTIMIZATION:optimizeKnapsack(ksItems, arrayBP)

    -- lets assume first, the highest quality reached is also the most profitable?
    -- TODO: consider minvalue, the crafting costs and the profit..

    CraftSimFRAME:ShowBestReagentAllocation(results[#results])
end

function CraftSimREAGENT_OPTIMIZATION:GetSkillThresholdPercentagesByMaxQuality(maxQuality)
    if maxQuality == 3 then
        return {0, 5, 10}
    elseif maxQuality == 5 then
        return {0, 2, 5, 8, 10}
    end
end

function CraftSimREAGENT_OPTIMIZATION:CreateCrumbs(ksItem)
    local inf = math.huge

    local j, k, a, b, c, n, w
    local goldCost

    n = ksItem.n

    -- APPROACH: do not translate indices here to lua indices cause they are not used for accessing later.. w is used for that
    --print("crumbs init to " .. (2*n))
    for j = 0, 2 * n, 1 do
        ksItem.crumb[j] = {}
        ksItem.crumb[j].value = inf
    end

    --print("start crumb creation: " .. ksItem.name)
    for k = 0, n, 1 do
        --print("creating crumb #" .. k)
        for j = k, n, 1 do
            a = k
            b = j - k
            c = n - j
            w = 2 * a + b -- plus one to make up for lua indexing?
            goldCost = a * ksItem.itemsInfo[3].minBuyout + b * ksItem.itemsInfo[2].minBuyout + c * ksItem.itemsInfo[1].minBuyout
            --print("current iteration ".. j .." goldCost: " .. tostring(goldCost))
            --print("w: " .. tostring(w))
            if goldCost < ksItem.crumb[w].value then
                --print("gold Cost smaller than value: " .. ksItem.crumb[w].value)
                --print("saving weight " .. ksItem.mWeight * w .. " into index " .. w)
                ksItem.crumb[w].weight = w * ksItem.mWeight
                ksItem.crumb[w].mix = {a, b, c}
                ksItem.crumb[w].mixDebug = tostring(a) .. "," .. tostring(b) .. "," .. tostring(c)
                ksItem.crumb[w].value = goldCost
            end
        end
    end

    --print("crumbs created for " .. ksItem.name)
    --CraftSimUTIL:PrintTable(ksItem.crumb)
end

function CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) 
    local weight = DEBUG_REAGENT_WEIGHTS[itemID]
    if weight == nil then
        print("no weight in debug data for: " .. itemID)
        return 0
    end
    return DEBUG_REAGENT_WEIGHTS[itemID]
end


function CraftSimREAGENT_OPTIMIZATION:GetGCD(a, b)
        return b==0 and a or CraftSimREAGENT_OPTIMIZATION:GetGCD(b,a%b)
end

function CraftSimREAGENT_OPTIMIZATION:optimizeKnapsack(ks, BPs)
    print("Starting optimization...")
    local numMaterials, i, j, k, maxWeight

    numMaterials = #ks or 1 -- should be ks -1 or 1 and behave like UBound(ks, 1)

    maxWeight = 0
    for i = 0, numMaterials, 1 do
        maxWeight = maxWeight + 2 * ks[i].n * ks[i].mWeight
    end

    local inf = math.huge

    local b = {}

    -- initialize the b array
    for i = 0, numMaterials, 1 do
        for j = 0, maxWeight, 1 do
            if b[i] == nil then
                b[i] = {}
            end
            b[i][j] = inf
        end
    end

    local c = {}

    -- initialize the c array
    for i = 0, numMaterials, 1 do
        for j = 0, maxWeight, 1 do
            if c[i] == nil then
                c[i] = {}
            end
            c[i][j] = 0
        end
    end

    -- do initial weight first
    local i = 0
    for k = 0, 2 * ks[i].n, 1 do -- for each weight and value in material(0)
        --print("current crumb: " .. k)
        --CraftSimUTIL:PrintTable(ks[i].crumb[k])
        b[i][ks[i].crumb[k].weight] = ks[i].crumb[k].value
        c[i][ks[i].crumb[k].weight] = k
    end

    -- do next weights
    for i = 1, numMaterials, 1 do
        for k = 0, 2 * ks[i].n, 1 do -- for each weight and value in material(i)
            for j = 0, maxWeight, 1 do -- for each possible weight value
                -- look at the previous row for this weight j, if it has a value then...
                if b[i - 1][j] < inf then
                    -- we know it is reachable
                    -- so look at the spot where adding the new weight would put us
                    -- if its current value is > than what we get by adding the new weight...
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

    local outArr = {}
    local outResult = {}
    local target = 0
    local h = 0

    for h = 0, #BPs, 1 do -- #BPs gives 1 less than how many are in there so here it fits!
        local outAllocation = {
            qualityReached = nil,
            minValue = nil,
            allocations = {}
        }
        if BPs[h] < 0 then --cannot reach this BP
            outArr[2 * h] = "None"
            outArr[2 * h + 1] = ""
        else
            target = CraftSimUTIL:round(BPs[h] * maxWeight, 0)  -- breakpoints are a % of maxSkillBonus
            -- walk the last row of the matrix backwards to find the best value (gold cost) for minimum target weight (j = skill bonus)
            i = numMaterials
            j = target - 1 -- start one short of the target because we increment j in the first step
            --j = translateLuaIndex(j) -- I guess this is necessary?
            matString = ""
            minValue = inf
        
            -- its ok to throw an error if we don't find minValue before j > maxWeight because it should never happen
            --    otherwise to capture the error we would Do Until (minValue < inf) Or (j > maxWeight)
            -- CraftSim: maybe in basic this is true 1 time?
            repeat
                j = j + 1
                minValue = b[i][j]
            until minValue < inf
            -- now minValue is set and j points to the correct column
            
            -- create the list of materials that represent optimization for target BP
            for i = 0, numMaterials, 1 do
                k = c[i][j] -- the index into V and W for minValue > target
                local ifstring = ""
                if i < numMaterials then -- TODO + 1 ?
                    ifstring = ", "
                end
                matString = matString .. ks[i].crumb[k].mixDebug .. " " .. ks[i].name .. ifstring
        
                --print("current matstring: " .. tostring(matString))
                --print("name: " .. ks[i].name)
                local matAllocations = {}
                for qualityIndex, qualityAllocations in pairs(ks[i].crumb[k].mix) do
                    --print("qualityIndex: " .. qualityIndex)
                    --print("allocations: " .. qualityAllocations)
                    table.insert(matAllocations, {
                        quality = qualityIndex,
                        itemID = ks[i].itemsInfo[qualityIndex].itemID,
                        allocations = qualityAllocations
                    })
                end
                j = j - ks[i].crumb[k].weight

                table.insert(outAllocation.allocations, {
                    itemName = ks[i].name,
                    allocations = matAllocations
                })
            end
        
            outArr[2 * h] = minValue
            outArr[2 * h + 1] = matString
            outAllocation.qualityReached = h
            outAllocation.minValue = minValue
            table.insert(outResult, outAllocation)
        end
    end

    print("results: ")
    for _, itemAllocation in pairs(outResult) do
        print("Reachable quality: " .. itemAllocation.qualityReached)

        for _, matAllocation in pairs(itemAllocation.allocations) do
            print("- name: " .. matAllocation.itemName)

            for qualityIndex, allocation in pairs(matAllocation.allocations) do
                print("- - q" .. qualityIndex .. ": " .. allocation.allocations)
                --print("- - itemID" .. allocation.itemID)
            end
        end
    end

    return outResult
end

function CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData)

    -- TODO: iterate current reagent allocation and calculate the total skill increase by their weights?
    local skillIncrease = 0
    
    return skillIncrease
end