_, CraftSim = ...

CraftSim.CALC = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PROFIT_CALCULATION)

---@param recipeData CraftSim.RecipeData
function CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)
    local priceData = recipeData.priceData
    local extraSavedItemsFactor = recipeData.professionStats.resourcefulness:GetExtraFactor(true)

    local savedCosts = 0
    if recipeData.supportsResourcefulness then
        savedCosts = CraftSim.CALC:CalculateResourcefulnessSavedCosts(extraSavedItemsFactor, priceData.craftingCostsRequired)
    end

    return savedCosts
end

function CraftSim.CALC:CalculateResourcefulnessSavedCosts(resExtraFactor, craftingCostsRequired)
    return craftingCostsRequired * (CraftSimOptions.customResourcefulnessConstant * resExtraFactor)
end

---Returns the chance to receive an upgrade with hsv
---@param recipeData CraftSim.RecipeData
---@return number hsvChance -- not in decimal!
---@return boolean withInspirationOnly -- only if it procs together with inspiration, the inspiration chance has to be factored in afterwards
function CraftSim.CALC:getHSVChance(recipeData) 
    print("HSV Chance calc")
    if recipeData.maxQuality and recipeData.resultData.expectedQuality < recipeData.maxQuality then
        
        local baseRecipeDifficulty = recipeData.baseProfessionStats.recipeDifficulty.value
        local recipeDifficulty = recipeData.professionStats.recipeDifficulty.value
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeDifficulty, CraftSimOptions.breakPointOffset)
        local upperThreshold = thresholds[recipeData.resultData.expectedQuality]
        
        local playerSkill = recipeData.professionStats.skill.value
        
        local skillDiff = upperThreshold - playerSkill
        local relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

        print("skillDiff: " .. tostring(skillDiff))
        print("relativeToDifficulty: " .. tostring(relativeToDifficulty))
        if relativeToDifficulty >= 5 then
            -- check if we can reach together with inspiration (if inspiration is not reaching alone)
            local skillWithInspiration = playerSkill + recipeData.professionStats.inspiration:GetExtraValueByFactor()
            print("skillWithInsp: " .. skillWithInspiration)
            print("upperThreshold: " .. upperThreshold)
            if skillWithInspiration <= upperThreshold then
                -- check if within 5%
                skillDiff = upperThreshold - skillWithInspiration
                relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)
                print("relativeToDifficultyInsp: " .. tostring(relativeToDifficulty))
                if relativeToDifficulty < 5 then
                    -- together with hsv we can reach the threshold
                    -- calculate chance for this and mark as hsv with inspiration only
                    local hsvChance = (5-relativeToDifficulty) / 5
                    return hsvChance, true
                end
            end
            print("out of reach -> chance 0")
            return 0, false
        end

        local hsvChance = (5-relativeToDifficulty) / 5

        return hsvChance, false
    else
        print("max quality reached -> chance 0")
        return 0, false
    end
end


---Returns a table with information about the hsv interaction for the given recipe
---@param recipeData CraftSim.RecipeData
---@return CraftSim.HSVInfo hsvInfo
function CraftSim.CALC:GetHSVInfo(recipeData)
    print("GET HSV INFO", false, true)
    ---@class CraftSim.HSVInfo
    local hsvInfo = {
        chanceNextQuality = 0, -- hsv chance part to either skip to the next quality with hsv only or to skip to next quality together with inspiration
        nextQualityWithInspirationOnly = false,
        canSkipQualityWithInspiration = false,
        chanceSkipQuality = 0, -- chance to get enough skill from hsv to skip a quality tier together with inspiration
    }

    if recipeData.maxQuality and recipeData.resultData.expectedQuality < recipeData.maxQuality then
        
        local baseRecipeDifficulty = recipeData.baseProfessionStats.recipeDifficulty.value
        local recipeDifficulty = recipeData.professionStats.recipeDifficulty.value
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeDifficulty, CraftSimOptions.breakPointOffset)
        local upperThreshold = thresholds[recipeData.resultData.expectedQuality]
        
        local playerSkill = recipeData.professionStats.skill.value
        
        local skillDiff = upperThreshold - playerSkill
        local relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

        print("skillDiff: " .. tostring(skillDiff))
        print("relativeToDifficulty: " .. tostring(relativeToDifficulty))
        if relativeToDifficulty >= 5 then
            -- check if we can reach together with inspiration (if inspiration is not reaching alone)
            local skillWithInspiration = playerSkill + recipeData.professionStats.inspiration:GetExtraValueByFactor()
            print("skillWithInsp: " .. skillWithInspiration)
            print("upperThreshold: " .. upperThreshold)
            if skillWithInspiration <= upperThreshold then
                -- check if within 5%
                skillDiff = upperThreshold - skillWithInspiration
                relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)
                print("relativeToDifficultyInsp: " .. tostring(relativeToDifficulty))
                if relativeToDifficulty < 5 then
                    -- together with inspiration we can reach the threshold
                    hsvInfo.nextQualityWithInspirationOnly = true
                end
            end
        end

        hsvInfo.chanceNextQuality = math.max((5-relativeToDifficulty) / 5, 0)
    end

    if recipeData.maxQuality and recipeData.resultData.expectedQuality + 1 < recipeData.maxQuality then
        -- if it is possible to skip, check if we can skip a quality with inspiration + hsv
        local baseRecipeDifficulty = recipeData.baseProfessionStats.recipeDifficulty.value
        local recipeDifficulty = recipeData.professionStats.recipeDifficulty.value
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeDifficulty, CraftSimOptions.breakPointOffset)
        local skipThreshold = thresholds[recipeData.resultData.expectedQuality + 1]
        
        local playerSkill = recipeData.professionStats.skill.value
        local skillWithInspiration = playerSkill + recipeData.professionStats.inspiration:GetExtraValueByFactor()

        if skillWithInspiration <= skipThreshold then
            -- now check if within 5%
            local skillDiff = skipThreshold - skillWithInspiration
            local relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

            if relativeToDifficulty < 5 then
                -- hsv + inspiration can skip a quality
                hsvInfo.chanceSkipQuality = (5-relativeToDifficulty) / 5
                hsvInfo.canSkipQualityWithInspiration = true
            end
        end
    end


    print("hsvInfo:")
    print(hsvInfo, true)
    return hsvInfo
end

---Returns the total items received if multicraft procs
---@param recipeData CraftSim.RecipeData
---@return number expectedItems the total amount (base + extra)
---@return number expectedExtraItems the expected amount of extra items
function CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)
    if not recipeData.supportsMulticraft then
        return recipeData.baseItemAmount, 0
    end

    local maxExtraItems = (CraftSimOptions.customMulticraftConstant*recipeData.baseItemAmount) * recipeData.professionStats.multicraft:GetExtraFactor(true)
    local expectedExtraItems = (1 + maxExtraItems) / 2 
    local expectedItems = recipeData.baseItemAmount + expectedExtraItems

    return expectedItems, expectedExtraItems
end

function CraftSim.CALC:CalculateExpectedCosts(expectedCrafts, chance, resChance, resExtraFactor, avgItemAmount, craftingCosts, requiredCraftingCosts)
    local avgSavedCostsRes = CraftSim.CALC:CalculateResourcefulnessSavedCosts(resExtraFactor, requiredCraftingCosts) * resChance
    if chance == 1 then
        return (craftingCosts - avgSavedCostsRes) / avgItemAmount
    elseif chance > 0 then
        return ((craftingCosts- avgSavedCostsRes) * expectedCrafts) / avgItemAmount
    end
end

---@class CraftSim.ProbabilityInfo
---@field inspiration? boolean 
---@field multicraft? boolean 
---@field hsvNext? boolean 
---@field hsvSkip? boolean 
---@field resourcefulness? boolean 
---@field chance number 
---@field profit number 

--- Do not forget to update Price Data first
---@params recipeData CraftSim.RecipeData
---@return number meanProfit
---@return CraftSim.ProbabilityInfo[] probabilityTable
function CraftSim.CALC:GetAverageProfitOld(recipeData) -- Without HSVSkip Consideration
    print("Get Average Profit", false, true)
    print("Supports Crafting Stats: " .. tostring(recipeData.supportsCraftingStats))
    print("Inspiration: " .. tostring(recipeData.supportsInspiration))
    print("Multicraft: " .. tostring(recipeData.supportsMulticraft))
    print("Resourcefulness: " .. tostring(recipeData.supportsResourcefulness))
    local priceData = recipeData.priceData
    local professionStats = recipeData.professionStats
    if not recipeData.supportsCraftingStats then
        local resultValue = ((priceData.qualityPriceList[1] or 0) * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT
        local profit = resultValue - priceData.craftingCosts

        local probabilityTable = {{chance=1, profit=profit}}
        return profit, probabilityTable
    end

    local comissionProfit = 0
    if recipeData.orderData then
        comissionProfit = (tonumber(recipeData.orderData.tipAmount) or 0) - (tonumber(recipeData.orderData.consortiumCut) or 0)
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
    if recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChance(recipeData)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

        print("Chances:")
        print("inspChance: " .. inspChance)
        print("mcChance: " .. mcChance)
        print("resChance: " .. resChance)
        print("hsvChance: " .. hsvChance)

        print("SavedCostsRes: " .. CraftSim.GUTIL:FormatMoney(savedCostsByRes))

        local expectedItems = CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)

        print("Inspiration Extra Factor:" .. professionStats.inspiration.extraFactor)
        print("Inspiration Extra Value:" .. professionStats.inspiration.extraValue)
        print("Inspiration Extra Value By Factor:" .. professionStats.inspiration:GetExtraValueByFactor())

        local qualityWithInspiration = recipeData.resultData.expectedQualityInspiration
        local qualityWithInspirationHSV = recipeData.resultData.expectedQualityInspirationHSV
        local qualityWithHSV = recipeData.resultData.expectedQualityHSV

        print("expectedQuality: " .. recipeData.resultData.expectedQuality)
        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))
        print("qualityWithInspirationHSV: " .. tostring(qualityWithInspirationHSV))

        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, MC, HSV, RES)")

        local bitMax = "1111"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local procs = {
                false, -- insp
                false, -- mc
                false, -- hsv
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_MC = (procs[2] and mcChance) or (1-mcChance)
            local p_HSV = (procs[3] and hsvChance) or (1-hsvChance)
            local p_Res = (procs[4] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_MC * p_Res * p_HSV

            local craftingCosts = priceData.craftingCosts - ((procs[4] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- possible combos: (without res)
            --[[
                000,
                001,
                010,
                011,
                100,
                101,
                110,
                111
            --]]
            local subCombination = string.sub(table.concat(combination, ""), 1, 3)
            print("subCombination: " .. tostring(subCombination))
            -- nothing
            if subCombination == "000" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)

            -- no insp, no mc, hsv,  
            elseif subCombination == "001" then
                if not withInspirationOnly then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount)
                else
                    resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)
                end

            -- no insp, mc, no hsv, 
            elseif subCombination == "010" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems)

            -- no insp, mc, hsv, 
            elseif subCombination == "011" then
                if not withInspirationOnly then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems)
                else
                    resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems)
                end

            -- insp, no mc, no hsv, 
            elseif subCombination == "100" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount)

            -- insp, no mc, hsv
            elseif subCombination == "101" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSV] or 0) * recipeData.baseItemAmount)

            -- insp, mc, no hsv, 
            elseif subCombination == "110" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems)

            -- insp, mc, hsv
            elseif subCombination == "111" then
                if not withInspirationOnly then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems)
                else
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems)
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                multicraft = procs[2],
                hsvNext = procs[3],
                resourcefulness = procs[4],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no inspiration -> no hsv
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

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
            local procs = {
                false, -- mc
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_MC = (procs[1] and mcChance) or (1-mcChance)
            local p_Res = (procs[2] and resChance) or (1-resChance)

            local combinationChance = p_MC * p_Res

            local craftingCosts = priceData.craftingCosts - ((procs[2] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- if mc
            if procs[1] then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems)
            elseif not procs[1] then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)
            end
            
            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                multicraft = procs[1],
                resourcefulness = procs[2],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChance(recipeData)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

        print("Chances:")
        print("inspChance: " .. inspChance)
        print("resChance: " .. resChance)
        print("hsvChance: " .. hsvChance)

        local qualityWithInspiration = recipeData.resultData.expectedQualityInspiration
        local qualityWithInspirationHSV = recipeData.resultData.expectedQualityInspirationHSV
        local qualityWithHSV = recipeData.resultData.expectedQualityHSV
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        print("expectedQuality: " .. recipeData.resultData.expectedQuality)
        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))
        print("qualityWithInspirationHSV: " .. tostring(qualityWithInspirationHSV))

        local probabilityTable = {}

        print("Build Probability Table (INSP, RES)")

        local bitMax = "111"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local procs = {
                false, -- insp
                false, -- hsv
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Insp = (procs[1] and inspChance) or (1-inspChance)
            local p_HSV = (procs[2] and hsvChance) or (1-hsvChance)
            local p_Res = (procs[3] and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_Res * p_HSV

            local craftingCosts = priceData.craftingCosts- ((procs[3] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0


            -- if insp, no hsv
            if not procs[1] and not procs[2] then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)

            -- just insp
            elseif procs[1] and not procs[2] then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount)

            -- not insp, hsv
            elseif not procs[1] and procs[2] then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount)
            -- insp and hsv
            elseif procs[1] and procs[2] then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSV] or 0) * recipeData.baseItemAmount)
            end
            
            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                hsvNext = procs[2],
                resourcefulness = procs[3],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no insp no hsv
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)
        
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
            local procs = {
                false, -- res
            }

            for i, bit in pairs(combination) do
                if bit == 1 then
                    procs[i] = true
                end
            end

            local p_Res = (procs[1] and resChance) or (1-resChance)

            local combinationChance = p_Res

            local craftingCosts = priceData.craftingCosts- ((procs[1] and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)
            
            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                resourcefulness = procs[1],
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsResourcefulness then
        -- before having a salvage item allocated in prospecting e.g.
        return 0, {}
    end

    print(CraftSim.GUTIL:ColorizeText("Szenario not implemented yet", CraftSim.GUTIL.COLORS.RED), false, true)
    

    return 0, {}
end

--- Do not forget to update Price Data first
---@param recipeData CraftSim.RecipeData
---@return number meanProfit
---@return CraftSim.ProbabilityInfo[] probabilityTable
function CraftSim.CALC:GetAverageProfit(recipeData) -- With HSVSkip Consideration
    print("Get Average Profit", false, true)
    print("Supports Crafting Stats: " .. tostring(recipeData.supportsCraftingStats))
    print("Inspiration: " .. tostring(recipeData.supportsInspiration))
    print("Multicraft: " .. tostring(recipeData.supportsMulticraft))
    print("Resourcefulness: " .. tostring(recipeData.supportsResourcefulness))
    local priceData = recipeData.priceData
    local professionStats = recipeData.professionStats
    if not recipeData.supportsCraftingStats then
        local resultValue = ((priceData.qualityPriceList[1] or 0) * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT
        local profit = resultValue - priceData.craftingCosts

        local probabilityTable = {{chance=1, profit=profit}}
        return profit, probabilityTable
    end

    local comissionProfit = 0
    if recipeData.orderData then
        comissionProfit = (tonumber(recipeData.orderData.tipAmount) or 0) - (tonumber(recipeData.orderData.consortiumCut) or 0)

        -- we also need to consider any saved crafting costs from provided materials from the customer and the comission
        for _, reagentdata in ipairs(recipeData.orderData.reagents) do
            local price = CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentdata.reagent.itemID, true, false)
            comissionProfit = comissionProfit + (reagentdata.reagent.quantity * price)
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
    if recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local hsvInfo = recipeData.resultData.hsvInfo
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

        print("Chances:")
        print("inspChance: " .. inspChance)
        print("mcChance: " .. mcChance)
        print("resChance: " .. resChance)
        print("hsvNextChance: " .. hsvInfo.chanceNextQuality)
        print("hsvSkipChance: " .. hsvInfo.chanceSkipQuality)

        print("SavedCostsRes: " .. CraftSim.GUTIL:FormatMoney(savedCostsByRes))

        local expectedItems = CraftSim.CALC:GetExpectedItemAmountMulticraft(recipeData)

        local qualityWithInspiration = recipeData.resultData.expectedQualityInspiration
        local qualityWithInspirationHSVNext = recipeData.resultData.expectedQualityInspirationHSV
        local qualityWithInspirationHSVSkip = recipeData.resultData.expectedQualityInspirationHSVSkip
        local qualityWithHSV = recipeData.resultData.expectedQualityHSV

        print("expectedQuality: " .. recipeData.resultData.expectedQuality)
        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))
        print("qualityWithInspirationHSVNext: " .. tostring(qualityWithInspirationHSVNext))
        print("qualityWithInspirationHSVSkip: " .. tostring(qualityWithInspirationHSVSkip))

        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        local probabilityTable = {}

        print("Build Probability Table (INSP, MC, HSV Next, HSV Skip, RES)")

        local bitMax = "11111"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do

            local INSP = combination[1] == 1
            local MC = combination[2] == 1
            local HSV_NEXT = combination[3] == 1
            local HSV_SKIP = combination[4] == 1
            local RES = combination[5] == 1

            local p_Insp = (INSP and inspChance) or (1-inspChance)
            local p_MC = (MC and mcChance) or (1-mcChance)
            local p_HSV_Next = (HSV_NEXT and hsvInfo.chanceNextQuality) or (1-hsvInfo.chanceNextQuality)
            local p_HSV_Skip = (HSV_SKIP and hsvInfo.chanceSkipQuality) or (1-hsvInfo.chanceSkipQuality)
            local p_Res = (RES and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_MC * p_Res * p_HSV_Next * p_HSV_Skip

            local craftingCosts = priceData.craftingCosts - ((RES and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- possible combos: (without res)
            --[[
                0000
                0001
                0010
                0011
                0100
                0101
                0110
                0111
                1000
                1001
                1010
                1011
                1100
                1101
                1110
                1111
            --]]
            local subCombination = string.sub(table.concat(combination, ""), 1, 4)
            print("subCombination: " .. tostring(subCombination))
            -- - INSP, - MC, - HSV_NEXT, - HSV_SKIP
            if subCombination == "0000" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)

            -- - INSP, - MC, - HSV_NEXT, + HSV_SKIP
            elseif subCombination == "0001" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)
            
                
            -- - INSP, - MC, + HSV_NEXT, - HSV_SKIP
            elseif subCombination == "0010" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount)

            -- - INSP, - MC, + HSV_NEXT, + HSV_SKIP
            elseif subCombination == "0011" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount)

            -- - INSP, + MC, - HSV_NEXT, - HSV_SKIP 
            elseif subCombination == "0100" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems)

            -- - INSP, + MC, - HSV_NEXT, + HSV_SKIP 
            elseif subCombination == "0101" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems)

            -- - INSP, + MC, + HSV_NEXT, - HSV_SKIP 
            elseif subCombination == "0110" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems)

            -- - INSP, + MC, + HSV_NEXT, + HSV_SKIP 
            elseif subCombination == "0111" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems)

            -- + INSP, - MC, - HSV_NEXT, - HSV_SKIP 
            elseif subCombination == "1000" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount)

            -- + INSP, - MC, - HSV_NEXT, + HSV_SKIP 
            elseif subCombination == "1001" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVSkip] or 0) * recipeData.baseItemAmount)

            -- + INSP, - MC, + HSV_NEXT, - HSV_SKIP 
            elseif subCombination == "1010" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVNext] or 0) * recipeData.baseItemAmount)

            -- + INSP, - MC, + HSV_NEXT, + HSV_SKIP -> special case, depends on which of the two hsv values inspiration is affecting
            elseif subCombination == "1011" then
                if hsvInfo.nextQualityWithInspirationOnly then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVNext] or 0) * recipeData.baseItemAmount)
                elseif hsvInfo.canSkipQualityWithInspiration then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVSkip] or 0) * recipeData.baseItemAmount)
                else -- if inspiration is not affecting any of the hsv values then its just a normal inspiration proc
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount)
                end

            -- + INSP, + MC, - HSV_NEXT, - HSV_SKIP
            elseif subCombination == "1100" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems)

            -- + INSP, + MC, - HSV_NEXT, + HSV_SKIP
            elseif subCombination == "1101" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVSkip] or 0) * expectedItems)

            -- + INSP, + MC, + HSV_NEXT, - HSV_SKIP
            elseif subCombination == "1110" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVNext] or 0) * expectedItems)

            -- + INSP, + MC, + HSV_NEXT, + HSV_SKIP -> special case, depends on which of the two hsv values inspiration is affecting
            elseif subCombination == "1111" then
                if hsvInfo.nextQualityWithInspirationOnly then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVNext] or 0) * expectedItems)
                elseif hsvInfo.canSkipQualityWithInspiration then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVSkip] or 0) * expectedItems)
                else -- if inspiration is not affecting any of the hsv values then its just a normal inspiration proc
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems)
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = INSP,
                multicraft = MC,
                hsvNext = HSV_NEXT,
                hsvSkip = HSV_SKIP,
                resourcefulness = RES,
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        if tostring(probabilitySum) ~= "1" then
            print(CraftSim.GUTIL:ColorizeText("WARNING: ", CraftSim.GUTIL.COLORS.RED) .. "Probability Sum not 1 -> " .. probabilitySum )
        end
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no inspiration -> no hsv
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

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

            local p_MC = (MC and mcChance) or (1-mcChance)
            local p_Res = (RES and resChance) or (1-resChance)

            local combinationChance = p_MC * p_Res

            local craftingCosts = priceData.craftingCosts - ((RES and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- if mc
            if MC then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems)
            elseif not MC then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)
            end
            
            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
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
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local hsvInfo = CraftSim.CALC:GetHSVInfo(recipeData)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

        print("Chances:")
        print("inspChance: " .. inspChance)
        print("resChance: " .. resChance)
        print("hsvNextChance: " .. hsvInfo.chanceNextQuality)
        print("hsvSkipChance: " .. hsvInfo.chanceSkipQuality)

        local qualityWithInspiration = recipeData.resultData.expectedQualityInspiration
        local qualityWithInspirationHSVNext = recipeData.resultData.expectedQualityInspirationHSV
        local qualityWithInspirationHSVSkip = recipeData.resultData.expectedQualityInspirationHSVSkip
        local qualityWithHSV = recipeData.resultData.expectedQualityHSV
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

        print("expectedQuality: " .. recipeData.resultData.expectedQuality)
        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))
        print("qualityWithInspirationHSVNext: " .. tostring(qualityWithInspirationHSVNext))
        print("qualityWithInspirationHSVSkip: " .. tostring(qualityWithInspirationHSVSkip))

        local probabilityTable = {}

        print("Build Probability Table (INSP, RES)")



        local bitMax = "1111"
        local numBits = string.len(bitMax)
        local bitMaxNumber = tonumber(bitMax, 2)
        local totalCombinations = {}
        for currentCombination = 0, bitMaxNumber, 1 do
            local bits = CraftSim.UTIL:toBits(currentCombination, numBits)
            table.insert(totalCombinations, bits)
        end 

        for _, combination in pairs(totalCombinations) do
            local INSP = combination[1] == 1
            local HSV_NEXT = combination[2] == 1
            local HSV_SKIP = combination[3] == 1
            local RES = combination[4] == 1

            local p_Insp = (INSP and inspChance) or (1-inspChance)
            local p_HSV_Next = (HSV_NEXT and hsvInfo.chanceNextQuality) or (1-hsvInfo.chanceNextQuality)
            local p_HSV_Skip = (HSV_SKIP and hsvInfo.chanceSkipQuality) or (1-hsvInfo.chanceSkipQuality)
            local p_Res = (RES and resChance) or (1-resChance)

            local combinationChance = p_Insp * p_Res * p_HSV_Next * p_HSV_Skip

            local craftingCosts = priceData.craftingCosts- ((RES and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            -- possible combos: (without res)
            --[[
                000
                001
                010
                011
                100
                101
                110
                111
            --]]
            local subCombination = string.sub(table.concat(combination, ""), 1, 3)
            print("subCombination: " .. tostring(subCombination))
            -- - INSP - HSV_NEXT, - HSV_SKIP
            if subCombination == "000" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)

            -- - INSP - HSV_NEXT, + HSV_SKIP
            elseif subCombination == "001" then
                resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)

            -- - INSP + HSV_NEXT, - HSV_SKIP
            elseif subCombination == "010" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount)

            -- - INSP + HSV_NEXT, + HSV_SKIP
            elseif subCombination == "011" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount)

            -- + INSP - HSV_NEXT, - HSV_SKIP
            elseif subCombination == "100" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount)
            
            -- + INSP - HSV_NEXT, + HSV_SKIP
            elseif subCombination == "101" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVSkip] or 0) * recipeData.baseItemAmount)
            
            -- + INSP + HSV_NEXT, - HSV_SKIP
            elseif subCombination == "110" then
                resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVNext] or 0) * recipeData.baseItemAmount)
            
            -- + INSP + HSV_NEXT, + HSV_SKIP
            elseif subCombination == "111" then
                if hsvInfo.nextQualityWithInspirationOnly then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVNext] or 0) * recipeData.baseItemAmount)
                elseif hsvInfo.canSkipQualityWithInspiration then
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspirationHSVSkip] or 0) * recipeData.baseItemAmount)
                else -- if inspiration is not affecting any of the hsv values then its just a normal inspiration proc
                    resultValue = adaptResultValue((priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount)
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = INSP,
                hsvNext = HSV_NEXT,
                hsvSkip = HSV_SKIP,
                resourcefulness = RES,
                chance = combinationChance,
                profit = combinationProfit
            })
        end

        local probabilitySum = 0
        local expectedProfit = 0
        for _, entry in pairs(probabilityTable) do
            probabilitySum = probabilitySum + entry.chance
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no insp no hsv
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)
        
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

            local p_Res = (RES and resChance) or (1-resChance)

            local combinationChance = p_Res

            local craftingCosts = priceData.craftingCosts- ((RES and savedCostsByRes) or 0)

            local combinationProfit = 0
            local resultValue = 0

            resultValue = adaptResultValue((priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount)
            
            combinationProfit = resultValue - craftingCosts
            --print(table.concat(combination, "") .. ":" .. CraftSim.GUTIL:Round(combinationChance*100, 2) .. "% -> " .. CraftSim.GUTIL:FormatMoney(combinationProfit, true))
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
            expectedProfit = expectedProfit + (entry.profit*entry.chance)
        end

        print("Probability Sum: " .. tostring(probabilitySum))
        print("ExpectedProfit: " .. CraftSim.GUTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsResourcefulness then
        -- before having a salvage item allocated in prospecting e.g.
        return 0, {}
    end

    print(CraftSim.GUTIL:ColorizeText("Szenario not implemented yet", CraftSim.GUTIL.COLORS.RED), false, true)
    

    return 0, {}
end