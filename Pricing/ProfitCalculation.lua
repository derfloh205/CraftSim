---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.CALC = {}

local print = CraftSim.DEBUG:RegisterDebugID("ProfitCalculation")

---@param recipeData CraftSim.RecipeData
function CraftSim.CALC:GetResourcefulnessSavedCosts(recipeData)
    local priceData = recipeData.priceData
    local extraSavedItemsFactor = 1 + recipeData.professionStats.resourcefulness:GetExtraValue()

    local savedCosts = 0
    if recipeData.supportsResourcefulness then
        savedCosts = CraftSim.CALC:CalculateResourcefulnessSavedCosts(extraSavedItemsFactor,
            priceData.craftingCostsRequired)
    end

    return savedCosts
end

function CraftSim.CALC:CalculateResourcefulnessSavedCosts(resExtraFactor, craftingCostsRequired)
    return craftingCostsRequired *
        (CraftSim.DB.OPTIONS:Get("PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT") * resExtraFactor)
end

---Returns the average items received considering a multicraft proc
---@param recipeData CraftSim.RecipeData
---@return number expectedItems the average total yield of a multicraft proc (base + extra)
---@return number expectedExtraItems the average amount of extra items of a multicraft proc
function CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)
    if not recipeData.supportsMulticraft then
        return recipeData.baseItemAmount, 0
    end

    local mcConstant = CraftSim.UTIL:GetMulticraftConstantByBaseYield(recipeData.baseItemAmount)
    local maxExtraItems = (mcConstant * recipeData.baseItemAmount) *
        (1 + recipeData.professionStats.multicraft:GetExtraValue())
    local expectedExtraItems = (1 + maxExtraItems) / 2
    local expectedItems = recipeData.baseItemAmount + expectedExtraItems

    return expectedItems, expectedExtraItems
end

---@class CraftSim.ProbabilityInfo
---@field multicraft? boolean
---@field resourcefulness? boolean
---@field chance number
---@field profit number

--- Do not forget to update Price Data first
---@param recipeData CraftSim.RecipeData
---@return number meanProfit
---@return CraftSim.ProbabilityInfo[] probabilityTable
function CraftSim.CALC:GetAverageProfit(recipeData)
    print("Get Average Profit", false, true)
    print("Supports Crafting Stats: " .. tostring(recipeData.supportsCraftingStats))
    print("Multicraft: " .. tostring(recipeData.supportsMulticraft))
    print("Resourcefulness: " .. tostring(recipeData.supportsResourcefulness))
    local priceData = recipeData.priceData
    local professionStats = recipeData.professionStats
    if not recipeData.supportsCraftingStats then
        local resultValue = ((priceData.qualityPriceList[1] or 0) * recipeData.baseItemAmount) *
            CraftSim.CONST.AUCTION_HOUSE_CUT
        local profit = resultValue - priceData.craftingCosts

        local probabilityTable = { { chance = 1, profit = profit } }
        return profit, probabilityTable
    end

    local comissionProfit = 0
    if recipeData.orderData then
        comissionProfit = (tonumber(recipeData.orderData.tipAmount) or 0) -
            (tonumber(recipeData.orderData.consortiumCut) or 0)

        -- we also need to consider any saved crafting costs from provided reagents from the customer and the comission
        for _, reagentdata in ipairs(recipeData.orderData.reagents) do
            local price = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(reagentdata.reagent.itemID, true, false)
            comissionProfit = comissionProfit + (reagentdata.reagent.quantity * price)
        end

        -- also if npc work order add item value of rewards to the comissionprofit
        for _, reward in ipairs(recipeData.orderData.npcOrderRewards or {}) do
            local price = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(Item:CreateFromItemLink(reward.itemLink):GetItemID())
            price = price * CraftSim.CONST.AUCTION_HOUSE_CUT
            comissionProfit = comissionProfit + price * reward.count
        end
    end

    -- for work orders we do not need to consider auction house cut but we can add the comissionProfit
    local function adaptResultValue(value)
        if recipeData.orderData and comissionProfit > 0 then
            return comissionProfit
        else
            return value * CraftSim.CONST.AUCTION_HOUSE_CUT
        end
    end


    -- case: every stats exists
    if recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:GetResourcefulnessSavedCosts(recipeData)

        local expectedItems = CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)

        local probabilityTable = {}

        print("Build Probability Table (MC, RES)")

        local bitMax = "11"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end

        for _, combination in pairs(totalCombinations) do
            local MC = combination[1] == 1
            local RES = combination[2] == 1

            local p_MC = (MC and mcChance) or (1 - mcChance)
            local p_Res = (RES and resChance) or (1 - resChance)

            local combinationChance = p_MC * p_Res

            local craftingCosts = priceData.craftingCosts - ((RES and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- if mc
            if MC then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) *
                    expectedItems)
            elseif not MC then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) *
                    recipeData.baseItemAmount)
            end

            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                multicraft = MC,
                resourcefulness = RES,
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit * entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no insp no hsv
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:GetResourcefulnessSavedCosts(recipeData)

        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (RES)")

        local bitMax = "1"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end

        for _, combination in pairs(totalCombinations) do
            local RES = combination[1] == 1

            local p_Res = (RES and resChance) or (1 - resChance)

            local combinationChance = p_Res

            local craftingCosts = priceData.craftingCosts - ((RES and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) *
                recipeData.baseItemAmount)

            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                resourcefulness = RES,
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit * entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsResourcefulness then
        -- before having a salvage item allocated in prospecting e.g.
        print("recipe does not support anything?")
        return 0, {}
    end

    print(CraftSim.GUTIL:ColorizeText("Szenario not implemented yet", CraftSim.GUTIL.COLORS.RED), false, true)


    return 0, {}
end
