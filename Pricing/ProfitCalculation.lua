_, CraftSim = ...

CraftSim.CALC = {}

local function print(text, recursive, l) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.PROFIT_CALCULATION, recursive, l)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)
    local priceData = recipeData.priceData
    local extraSavedItemsFactor = recipeData.professionStats.resourcefulness:GetExtraFactor(true)

    local savedCosts = 0
    if recipeData.supportsResourcefulness then
        savedCosts = priceData.craftingCostsRequired * (CraftSim.CONST.BASE_RESOURCEFULNESS_AVERAGE_SAVE_FACTOR * extraSavedItemsFactor)
    end

    return savedCosts
end

---Returns the chance to receive an upgrade with hsv
---@param recipeData CraftSim.RecipeData
---@return number hsvChance -- not in decimal!
---@return boolean withInspirationOnly -- only if it procs together with inspiration, the inspiration chance has to be factored in afterwards
function CraftSim.CALC:getHSVChance(recipeData) 
    if CraftSimOptions.enableHSV and recipeData.maxQuality and recipeData.resultData.expectedQuality < recipeData.maxQuality then
        
        local baseRecipeDifficulty = recipeData.baseProfessionStats.recipeDifficulty.value
        local recipeDifficulty = recipeData.professionStats.recipeDifficulty.value
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, recipeDifficulty)
        local upperThreshold = thresholds[recipeData.resultData.expectedQuality]

        local playerSkill = recipeData.professionStats.skill.value

        local skillDiff = upperThreshold - playerSkill
        local relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

        if relativeToDifficulty >= 5 then
            -- check if we can reach together with inspiration (if inspiration is not reaching alone)
            local skillWithInspiration = playerSkill + recipeData.professionStats.inspiration.extraValue
            if skillWithInspiration < upperThreshold then
                -- check if within 5%
                skillDiff = upperThreshold - skillWithInspiration
                relativeToDifficulty = skillDiff / (baseRecipeDifficulty / 100)

                if relativeToDifficulty < 5 then
                    -- together with hsv we can reach the threshold
                    -- calculate chance for this and mark as hsv with inspiration only
                    local hsvChance = (5-relativeToDifficulty) / 5
                    return hsvChance, true
                end
            end
            return 0
        end

        local hsvChance = (5-relativeToDifficulty) / 5

        return hsvChance
    else
        return 0
    end
end

--- Do not forget to update Price Data first
---@params recipeData CraftSim.RecipeData
---@return number meanProfit
---@return table probabilityTable
function CraftSim.CALC:GetMeanProfitOOP(recipeData)
    local priceData = recipeData.priceData
    local professionStats = recipeData.professionStats
    if not recipeData.supportsCraftingStats then
        local resultValue = ((priceData.qualityPriceList[1] or 0) * recipeData.baseItemAmount) * CraftSim.CONST.AUCTION_HOUSE_CUT
        local profit = resultValue - priceData.craftingCosts

        local probabilityTable = {{chance=1, profit=profit}}
        return profit, probabilityTable
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

        print("SavedCostsRes: " .. CraftSim.UTIL:FormatMoney(savedCostsByRes))

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * professionStats.multicraft:GetExtraFactor(true)
        local expectedAdditionalItems = (1 + maxExtraItems) / 2 
        local expectedItems = recipeData.baseItemAmount + expectedAdditionalItems

        print("Inspiration Extra Factor:" .. professionStats.inspiration.extraFactor)
        print("Inspiration Extra Value:" .. professionStats.inspiration.extraValue)
        print("Inspiration Extra Value By Factor:" .. professionStats.inspiration:GetExtraValueByFactor())

        local skillWithInspiration = professionStats.skill.value + professionStats.inspiration:GetExtraValueByFactor()
        print("skill: " .. professionStats.skill.value)
        print("skillWithInspiration: " .. skillWithInspiration)
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkillOOP(recipeData, skillWithInspiration)
        local qualityWithHSV = math.min(recipeData.resultData.expectedQuality + 1, recipeData.maxQuality)

        print("expectedQuality: " .. recipeData.resultData.expectedQuality)
        print("qualityWithHSV: " .. tostring(qualityWithHSV))
        print("qualityWithInspiration: " .. tostring(qualityWithInspiration))

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
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- no insp, no mc, hsv,  
            elseif subCombination == "001" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- no insp, mc, no hsv, 
            elseif subCombination == "010" then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- no insp, mc, hsv, 
            elseif subCombination == "011" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- insp, no mc, no hsv, 
            elseif subCombination == "100" then
                resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- insp, no mc, hsv
            elseif subCombination == "101" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end

            -- insp, mc, no hsv, 
            elseif subCombination == "110" then
                resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- insp, mc, hsv
            elseif subCombination == "111" then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                multicraft = procs[2],
                hsv = procs[3],
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
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsInspiration and recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        -- no inspiration -> no hsv
        local mcChance = professionStats.multicraft:GetPercent(true)
        local resChance = professionStats.resourcefulness:GetPercent(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

        local maxExtraItems = (2.5*recipeData.baseItemAmount) * professionStats.multicraft:GetExtraFactor(true)
        local expectedAdditionalItems = (1 + maxExtraItems) / 2 
        local expectedItems = recipeData.baseItemAmount + expectedAdditionalItems

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
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * expectedItems * CraftSim.CONST.AUCTION_HOUSE_CUT
            elseif not procs[1] then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
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
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif recipeData.supportsInspiration and not recipeData.supportsMulticraft and recipeData.supportsResourcefulness then
        local inspChance = professionStats.inspiration:GetPercent(true)
        local hsvChance, withInspirationOnly = CraftSim.CALC:getHSVChance(recipeData)
        local resChance = professionStats.resourcefulness:GetExtraFactor(true)
        local savedCostsByRes = CraftSim.CALC:getResourcefulnessSavedCosts(recipeData)

        local skillWithInspiration = professionStats.skill.value + professionStats.inspiration.extraValue
        local qualityWithInspiration = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkillOOP(recipeData, skillWithInspiration)
        local qualityWithHSV = math.min(recipeData.resultData.expectedQuality + 1, recipeData.maxQuality)
        
        -- get all possible craft results (for resourcefulness take avg) and their profits
        -- to build the probability distribution with p(x) = x where x is the profit

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

            print("recipeData.baseItemAmount: " .. tostring(recipeData.baseItemAmount))
            print("buyout for expected: " .. tostring(priceData.qualityPriceList[recipeData.resultData.expectedQuality]))

            -- if insp, no hsv
            if not procs[1] and not procs[2] then
                resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- just insp
            elseif procs[1] and not procs[2] then
                resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT

            -- not insp, hsv
            elseif not procs[1] and procs[2] then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            elseif procs[1] and procs[2] then
                if not withInspirationOnly then
                    resultValue = (priceData.qualityPriceList[qualityWithInspiration] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                else
                    resultValue = (priceData.qualityPriceList[qualityWithHSV] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
                end
            end
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
            table.insert(probabilityTable, {
                inspiration = procs[1],
                hsv = procs[2],
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
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

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

            resultValue = (priceData.qualityPriceList[recipeData.resultData.expectedQuality] or 0) * recipeData.baseItemAmount * CraftSim.CONST.AUCTION_HOUSE_CUT
            
            combinationProfit = resultValue - craftingCosts
            print(table.concat(combination, "") .. ":" .. CraftSim.UTIL:round(combinationChance*100, 2) .. "% -> " .. CraftSim.UTIL:FormatMoney(combinationProfit, true))
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
        print("ExpectedProfit: " .. CraftSim.UTIL:FormatMoney(expectedProfit, true))

        return expectedProfit, probabilityTable
    elseif not recipeData.supportsResourcefulness then
        -- before having a salvage item allocated in prospecting e.g.
        return 0, {}
    end

    print(CraftSim.UTIL:ColorizeText("Szenario not implemented yet", CraftSim.CONST.COLORS.RED), false, true)
    print("Supports Crafting Stats: " .. recipeData.supportsCraftingStats)
    print("Inspiration: " .. recipeData.supportsInspiration)
    print("Multicraft: " .. recipeData.supportsMulticraft)
    print("Resourcefulness: " .. recipeData.supportsResourcefulness)

    return 0, {}
end