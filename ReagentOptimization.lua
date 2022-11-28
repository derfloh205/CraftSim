CraftSimREAGENT_OPTIMIZATION = {}


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

    -- Create Knapsacks for required reagents with different Qualities
    local requiredReagents = CraftSimUTIL:FilterTable(recipeData.reagents, function(reagent) 
        return reagent.reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED and reagent.differentQualities
    end)

    local mWeight = {}

    for _, reagent in pairs(requiredReagents) do
        local itemID = reagent.itemsInfo[1].itemID -- all qualities have the same weight
        table.insert(mWeight, CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) * reagent.requiredQuantity)
    end

    local weightGCD = CraftSimUTIL:FoldTable(mWeight, function(a, b) 
        return CraftSimREAGENT_OPTIMIZATION:GetGCD(a, b)
    end)

    print("mWeight: ")
    CraftSimUTIL:PrintTable(mWeight)
    print("weightGCD: " .. tostring(weightGCD))

    -- create the ks items
    local ksItems = {}
    for index, reagent in pairs(requiredReagents) do
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

        -- DEBUG
        print("ksItem for " .. reagent.name)
        CraftSimUTIL:PrintTable(ksItem)

        for k, v in pairs(ksItem.crumb) do
            print("crumb #" .. k)
            print("value: " .. v.value .. " weight: " .. v.weight)
            print("mix: " .. v.mixDebug)
        end
        -- /DEBUG

        -- Optimize Knapsack

        

        table.insert(ksItems, ksItem)
    end
end

function CraftSimREAGENT_OPTIMIZATION:CreateCrumbs(ksItem)
    local inf = tonumber('inf')

    local j, k, a, b, c, n, w
    local goldCost

    n = ksItem.n

    for j = 0, 2 * n, 1 do -- inclusive 2*n or exclusive?
        ksItem.crumb[j] = {}
        ksItem.crumb[j].value = inf
    end

    for k = 0, n, 1 do -- again.. inclusive or exclusive?
        for j = k, n, 1 do
            a = k
            b = j - k
            c = n - j
            w = 2 * a + b
            goldCost = a * ksItem.itemsInfo[3].minBuyout + b * ksItem.itemsInfo[2].minBuyout + c * ksItem.itemsInfo[1].minBuyout
            if goldCost < ksItem.crumb[w].value then
                ksItem.crumb[w].weight = w * ksItem.mWeight
                ksItem.crumb[w].mix = {a, b, c}
                ksItem.crumb[w].mixDebug = tostring(a) .. "," .. tostring(b) .. "," .. tostring(c)
                ksItem.crumb[w].value = goldCost
            end
        end
    end
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