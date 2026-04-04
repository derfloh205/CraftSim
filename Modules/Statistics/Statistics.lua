---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.STATISTICS
CraftSim.STATISTICS = {}

---@type GGUI.Frame
CraftSim.STATISTICS.frameNO_WO = nil
---@type GGUI.Frame
CraftSim.STATISTICS.frameWO = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Statistics")

-- https://math.stackexchange.com/questions/888165/abramowitz-and-stegun-approximation-for-cumulative-normal-distribution
function CraftSim.STATISTICS:CDF(q, mu, sd)
    local function Phi(z)
        local pdfx = 1 / (math.sqrt(2 * math.pi)) * math.exp(-z * z / 2)
        local t = 1 / (1 + 0.2316419 * z)
        return (1 - pdfx * (0.319381530 * t - 0.356563782 * t ^ 2
            + 1.781477937 * t ^ 3 - 1.821255978 * t ^ 4 + 1.330274429 * t ^ 5))
    end

    local zValue = (q - mu) / sd

    local phi_Z = Phi(zValue)
    if phi_Z <= 0.0001 then -- catch the case of it returning wierd stuff
        return 1
    elseif phi_Z >= 1 then
        return 0
    end
    return phi_Z
end

function CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable, numCrafts)
    local meanOneCraft = 0

    probabilityTable = CraftSim.GUTIL:Filter(probabilityTable, function(entry)
        return entry.chance > 0
    end)

    local allNegative = true
    local allPositive = true
    for _, probability in pairs(probabilityTable) do
        meanOneCraft = meanOneCraft + (probability.profit * probability.chance)
        if probability.profit > 0 then
            allNegative = false
        end
        if probability.profit <= 0 then
            allPositive = false
        end
    end

    if allPositive then
        return 1
    end

    if allNegative then
        return 0
    end



    local standardDeviation = 0

    for _, probability in pairs(probabilityTable) do
        standardDeviation = standardDeviation + (probability.profit - meanOneCraft) ^ 2
    end

    standardDeviation = standardDeviation / #probabilityTable

    standardDeviation = math.sqrt(standardDeviation)
    local standardDeviationNumCrafts = math.sqrt(numCrafts) * standardDeviation
    local meanNumCrafts = meanOneCraft * numCrafts

    print("mean (profit) of 1 craft: " .. CraftSim.UTIL:FormatMoney(meanOneCraft, true))
    print("mean (profit) of " .. numCrafts .. " crafts: " .. CraftSim.UTIL:FormatMoney(meanNumCrafts, true))
    print("standardDeviation 1 craft: " .. CraftSim.UTIL:FormatMoney(standardDeviation, true))
    print("standardDeviation " .. numCrafts ..
        " crafts: " .. CraftSim.UTIL:FormatMoney(standardDeviationNumCrafts, true))


    -- CDF:
    -- test override:
    --meanNumCrafts = 5
    --standardDeviationNumCrafts = 1

    print("CDF of: " .. tostring(meanNumCrafts) .. ", " .. tostring(standardDeviationNumCrafts))
    local cdfResult = CraftSim.STATISTICS:CDF(0, meanNumCrafts, standardDeviationNumCrafts)
    print("result: " .. tostring(cdfResult))

    -- get probability of x or higher:
    local chanceOfHavingHigher = 1 - cdfResult

    print("chance for profit > 0 after crafts: " .. tostring(chanceOfHavingHigher))

    return chanceOfHavingHigher
end
