_, CraftSim = ...

CraftSim.STATISTICS = {}


function CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable, numCrafts)

    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.AVERAGE_PROFIT)

    print("Probability of positive profit: ", false, true)

    local chancePositive = 0
    local averagePositiveProfit = 0

    local chanceNegative = 0
    local averageNegativeProfit = 0

    local numPositives = 0
    local numNegatives = 0
    for _, entry in pairs(probabilityTable) do
        if entry.profit > 0 then
            chancePositive = chancePositive + entry.chance
            averagePositiveProfit = averagePositiveProfit + entry.profit
            numPositives = numPositives + 1
        else
            chanceNegative = chanceNegative + entry.chance
            averageNegativeProfit = averageNegativeProfit + entry.profit
            numNegatives = numNegatives + 1
        end
    end
    if numPositives == 0 then
        -- no chance of having any positive profit
        print("No chance of having any positive profit")
        return 0
    elseif numNegatives == 0 then
        -- no chance of having any negative profit
        print("No chance of having any negative profit")
        return 1
    end
    averagePositiveProfit = averagePositiveProfit / numPositives
    averageNegativeProfit = averageNegativeProfit / numNegatives

    print("Chance for positive Profit: " .. CraftSim.UTIL:round(chancePositive*100) .. "% -> " .. CraftSim.UTIL:FormatMoney(averagePositiveProfit, true))
    print("Chance for negative Profit: " .. CraftSim.UTIL:round(chanceNegative*100) .. "% -> " .. CraftSim.UTIL:FormatMoney(averageNegativeProfit, true))

    -- after numCrafts, how many positive crafts do I need to have a profit > 0 ?

    -- 0 < x*averageNegativeProfit + y*averagePositiveProfit

    -- solve iteratively?
    local numSuccesses = 0
    local endProfit = -1
    while endProfit < 0 do
        numSuccesses = numSuccesses + 1
        endProfit = averageNegativeProfit*(numCrafts - numSuccesses) + averagePositiveProfit*numSuccesses


        -- if numSuccesses > numCrafts then
        --     print("should not happen.. cannot get positive event after numCrafts * positive profit??")
        --     break
        -- end
    end

    -- if numSuccess == numCrafts, we need full successes to have a positive end profit

    print("At least " .. numSuccesses .. " / " .. numCrafts .. " need to be a success to have a profit > 0")

    -- now solve the chance of this occuring with binomial probability
    -- https://statisticsbyjim.com/probability/binomial-distribution/

    local function factorial(n)
        if (n == 0) then
            return 1
        else
            return n * factorial(n - 1)
        end
    end

    -- to get the cumulative binomial, sum up the chances of all possible successes from numSuccess to numCrafts

    local cumulativeBinomialChance = 0
    for i = numSuccesses, numCrafts, 1 do
        local numCombinations = factorial(numCrafts) / (factorial(i) * factorial(numCrafts - i))
        local binomialChance = numCombinations * (chancePositive ^ i) * ((1 - chancePositive) ^ (numCrafts - i))
        cumulativeBinomialChance = cumulativeBinomialChance + binomialChance
    end

    print("Chance of having a positive Profit after " .. numCrafts .. " Crafts: " .. CraftSim.UTIL:round(cumulativeBinomialChance*100, 2) .. "%")
    print("not rounded: " .. cumulativeBinomialChance)

    return cumulativeBinomialChance
end