_, CraftSim = ...

CraftSim.REAGENT_OPTIMIZATION = {}

local function print(text, recursive) -- override
	CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.REAGENT_OPTIMIZATION, recursive)
end

local function translateLuaIndex(index)
    return index + 1
end

-- By Liqorice's knapsack solution
function CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeType, priceData, exportMode, UseInspirationOverride)
    -- insert costs
    local reagentCostsByQuality = CraftSim.PRICEDATA:GetReagentsPriceByQuality(recipeData)

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
    local requiredReagents = CraftSim.UTIL:FilterTable(recipeData.reagents, function(reagent) 
        return reagent.reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED and reagent.differentQualities
    end)

    local mWeight = {}
    -- init
    for i = 0, #requiredReagents - 1, 1 do
        local reagent = requiredReagents[translateLuaIndex(i)]
        local itemID = reagent.itemsInfo[1].itemID
        --print("mWeight array init: " .. i .. " to " .. CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) )
        mWeight[i] = CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) --  * reagent.requiredQuantity fixed double counting of quantity
    end

    --print(" calculating gcd of " .. unpack(mWeight))
    local weightGCD = CraftSim.UTIL:FoldTable(mWeight, function(a, b) 
        --print("fold " .. a .. " and " .. b)
        return CraftSim.REAGENT_OPTIMIZATION:GetGCD(a, b)
    end, true)

    --print("gcd: " .. tostring(weightGCD))
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
        --print("creating ks item for " .. tostring(reagent.name) .. "(" .. tostring(reagent.itemsInfo[1]) .. ")")
        local ksItem = {
            name = reagent.name,
            itemsInfo = reagent.itemsInfo, -- this contains the ids of all qualities and costs
            n = reagent.requiredQuantity,
            mWeight = mWeight[index] / weightGCD,
            crumb = {}
        }        

        --print("mWeight of " .. reagent.name .. " is " .. ksItem.mWeight)
        --print("mWeight[index] / weightGCD -> " .. mWeight[index] .. " / " .. weightGCD .. " = " .. mWeight[index] / weightGCD)

        -- fill crumbs
        CraftSim.REAGENT_OPTIMIZATION:CreateCrumbs(ksItem)
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

    local recipeMaxSkillBonus = recipeData.maxReagentSkillIncreaseFactor * recipeData.baseDifficulty
    
    -- Calculate the material bonus needed to meet each breakpoint based on the player's
    --   existing skill and the recipe difficulty (as a fraction of the recipeMaxSkillBonus
    -- Breakpoints are sorted highest to lowest
    -- Array value = -1 means this breakpoint is unreachable
    --               0 means no skill bonus required to reach this BP
    --               > 0 means the indicated skill bonus is required to reach this BP
    -- At least one entry will be >= 0

    -- should be 0 for scan
    local reagentSkillContribution = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData, exportMode) or 0
    local skillWithoutReagentIncrease = recipeData.stats.skillNoReagents
    print("in Simulation Mode: " .. tostring(recipeData.isSimModeData ~= nil))
    print("skill total: " .. tostring(recipeData.stats.skill))
    print("skill without reagents: " .. tostring(skillWithoutReagentIncrease))
    print("reagentSkillContribution: " .. tostring(reagentSkillContribution))

    local expectedQualityWithoutReagents = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(recipeData, skillWithoutReagentIncrease)

    for i = 0, numBP - 1, 1 do
        --print("checking BP: " .. tostring(craftingDifficultyBP[i]))
        local extraSkillPoint = 0
        if CraftSimOptions.breakPointOffset then
            extraSkillPoint = 1
        end
        local skillBreakpoint = craftingDifficultyBP[i] * recipeData.recipeDifficulty + extraSkillPoint
        
        local inspirationBonusSkill = 0
        if recipeData.stats.inspiration then
            if exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
                local scanMode = CraftSim.RECIPE_SCAN:GetScanMode()
                if scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_G and not UseInspirationOverride then
                    inspirationBonusSkill = 0
                elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I or UseInspirationOverride then
                    inspirationBonusSkill = recipeData.stats.inspiration.bonusskill
                end
            else
                inspirationBonusSkill = (CraftSimOptions.materialSuggestionInspirationThreshold and recipeData.stats.inspiration.bonusskill) or 0
            end

            skillBreakpoint = skillBreakpoint - inspirationBonusSkill -- make it easier to reach 
        end
        print("skill BP: " .. skillBreakpoint)
        arrayBP[i] = skillBreakpoint - skillWithoutReagentIncrease
        --print("skill needed for this breakpoint:" .. arrayBP[i])
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

    -- print("ksItems: ")
    -- for k, v in pairs(ksItems) do
    --     print(v.name .. ": ")
    --     print("weight: " .. tostring(v.mWeight))
    -- end


    -- Optimize Knapsack
    local results = CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ksItems, arrayBP)  

    -- remove any result that maps to the expected quality without reagent increase
    -- NEW: any that is below! Same is fine
    local results = CraftSim.UTIL:FilterTable(results, function(result) 
        return result.qualityReached >= expectedQualityWithoutReagents
    end)

    -- TODO: remove results that are the same allocation as the current one? and disable button?
    
    local hasItems = true
    local bestAllocation = results[1]--results[#results]
    local isSameAllocation = false
    if exportMode ~= CraftSim.CONST.EXPORT_MODE.SCAN then
        isSameAllocation = CraftSim.REAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, bestAllocation)
        if bestAllocation and not isSameAllocation then
            for _, matAllocation in pairs(bestAllocation.allocations) do
                for qualityIndex, allocation in pairs(matAllocation.allocations) do
                    local hasItemCount = GetItemCount(allocation.itemID, true, true, true)
                    if hasItemCount < allocation.allocations then
                        hasItems = false
                    end
                end
            end
        end
        
        CraftSim.REAGENT_OPTIMIZATION.FRAMES:UpdateReagentDisplay(recipeData, recipeType, priceData, bestAllocation, hasItems, isSameAllocation, exportMode)
    end

    return bestAllocation
end

function CraftSim.REAGENT_OPTIMIZATION:CreateCrumbs(ksItem)
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
            w = 2 * a + b

            goldCost = a * ksItem.itemsInfo[3].minBuyout + b * ksItem.itemsInfo[2].minBuyout + c * ksItem.itemsInfo[1].minBuyout
            --print("current iteration ".. j .." goldCost: " .. tostring(goldCost))
            --print("w: " .. tostring(w))
            if goldCost < ksItem.crumb[w].value then
                --print("gold Cost smaller than value: " .. ksItem.crumb[w].value)
                --print("saving weight " .. ksItem.mWeight * w .. " into index " .. w)
                ksItem.crumb[w].weight = w * ksItem.mWeight
                ksItem.crumb[w].mix = {c, b, a}
                ksItem.crumb[w].mixDebug = tostring(c) .. "," .. tostring(b) .. "," .. tostring(a)
                ksItem.crumb[w].goldCostDebug = c * ksItem.itemsInfo[1].minBuyout .. "," .. b * ksItem.itemsInfo[2].minBuyout .. "," .. a * ksItem.itemsInfo[3].minBuyout
                ksItem.crumb[w].value = goldCost
            end
        end
    end
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

function CraftSim.REAGENT_OPTIMIZATION:optimizeKnapsack(ks, BPs)
    --print("Starting optimization...")
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
        --CraftSim.UTIL:PrintTable(ks[i].crumb[k])
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
        if BPs[h] < 0 then --cannot reach this BP
            outArr[2 * h] = "None"
            outArr[2 * h + 1] = ""
        else
            tStart = math.ceil(BPs[h] * maxWeight)
            i = numMaterials -- i was initialized above
            -- walk the last row of the matrix backwards to find the best value (gold cost) for minimum target weight (j = skill bonus)
            i = numMaterials
            matString = ""
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
            
            -- create the list of materials that represent optimization for target BP
            for i = numMaterials, 0, -1 do
                k = c[i][j] -- the index into V and W for minValue > target
                local ifstring = ""
                if i > 0 then -- TODO + 1 ?
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
            outAllocation.qualityReached = abs(h - (#BPs + 1))
            outAllocation.minValue = minValue
            table.insert(outResult, outAllocation)

            -- now set our new target endpoint to the column before the current target start so that
            -- next time through this loop we don't search past this breakpoint
            tEnd = tStart - 1
        end
    end

    -- print("outArr:")
    -- print(outArr)

    print("results: ")
    for _, itemAllocation in pairs(outResult) do
        print("Reachable quality: " .. itemAllocation.qualityReached)

        for _, matAllocation in pairs(itemAllocation.allocations) do
            print("- name: " .. matAllocation.itemName)

            local qText = "--"
            for qualityIndex, allocation in pairs(matAllocation.allocations) do
                qText = qText .. "q" .. qualityIndex .. ": " .. allocation.allocations .. " | "
            end
            print(qText)
        end
    end

    return outResult
end

function CraftSim.REAGENT_OPTIMIZATION:GetMaxReagentIncreaseFactor(recipeData, exportMode)

    


    -- For recrafts we need to calculate it

    local recipeDataNoReagents = CopyTable(recipeData)

    -- get operationinfo of recipe with no reagents
    local orderID = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        orderID = ProfessionsFrame.OrdersPage.OrderView.order.orderID
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeData.recipeID, {}, orderID)
    else
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeData.recipeID, {}, recipeData.recraftAllocationGUID)
    end

    -- create CraftingReagentInfoTbl with max q3 reagents
    -- https://wowpedia.fandom.com/wiki/API_C_TradeSkillUI.GetCraftingOperationInfo
    local craftingReagentInfoTbl = {}
    for index, reagent in pairs(recipeData.reagents) do
        if reagent.differentQualities then
            for qualityID, itemInfo in pairs(reagent.itemsInfo) do
                local allocations = 0
                if qualityID == 3 then
                    allocations = reagent.requiredQuantity
                end
                local infoEntry = {
                    itemID = itemInfo.itemID,
                    quantity = allocations,
                    dataSlotIndex = 2,
                }
                table.insert(craftingReagentInfoTbl, infoEntry)
            end
        end
    end
    local Q3ReagentsOperationInfo = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        Q3ReagentsOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeData.recipeID, craftingReagentInfoTbl, orderID)
    else
        Q3ReagentsOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeData.recipeID, craftingReagentInfoTbl, recipeData.recraftAllocationGUID)
    end
    
    local baseSkill = baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill
    local skillQ3Reagents = Q3ReagentsOperationInfo.baseSkill + Q3ReagentsOperationInfo.bonusSkill

    local reagentQualityIncrease = skillQ3Reagents - baseSkill

    print("Reagent Quality Increase: " .. tostring(reagentQualityIncrease))

    local maxReagentIncreaseFactor = recipeData.baseDifficulty / reagentQualityIncrease

    print("maxReagentIncreaseFactor: " .. tostring(maxReagentIncreaseFactor))

    local percentFactor = (100 / maxReagentIncreaseFactor) / 100

    print("maxReagentIncreaseFactor % of difficulty: " .. tostring(percentFactor) .. " %")

    return percentFactor
end

function CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData, exportMode)
    -- get operationinfo of recipe with no reagents
    local baseOperationInfo = nil
    local orderID = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        orderID = ProfessionsFrame.OrdersPage.OrderView.order.orderID
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeData.recipeID, {}, orderID)
    else
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeData.recipeID, {}, recipeData.recraftAllocationGUID)
    end

    -- create CraftingReagentInfoTbl from current reagents
    -- https://wowpedia.fandom.com/wiki/API_C_TradeSkillUI.GetCraftingOperationInfo
    local craftingReagentInfoTbl = CraftSim.DATAEXPORT:ConvertRecipeDataRequiredReagentsToCraftingReagentInfoTbl(recipeData.reagents)
    local currentOperationInfo = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        currentOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeData.recipeID, craftingReagentInfoTbl, orderID)
    else
        --print("get crafting operation info:")
        --print(tostring(recipeData.recipeID) .. ", " .. tostring(craftingReagentInfoTbl) .. ", " .. tostring(recipeData.recraftAllocationGUID))
        --print(craftingReagentInfoTbl, true)
        currentOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeData.recipeID, craftingReagentInfoTbl, recipeData.recraftAllocationGUID)
    end
    print("Base Operation Info")
    print(baseOperationInfo)
    print("Current Operation Info")
    print(currentOperationInfo)

    local baseSkill = baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill
    local skillCurrent = currentOperationInfo.baseSkill + currentOperationInfo.bonusSkill

    print("baseSkill: " .. tostring(baseSkill))
    print("skillCurrent: " .. tostring(skillCurrent))

    local reagentQualityIncrease = skillCurrent - baseSkill

    print("reagentQualityIncrease: " .. tostring(reagentQualityIncrease))

    return reagentQualityIncrease
end

function CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncreaseOLD(recipeData)

    local matBonus = {}
    local totalWeight = 0

    local hasAtLeastOneFullSlot = false
    for index, reagent in pairs(recipeData.reagents) do
        if reagent.differentQualities then
            local n3 = reagent.itemsInfo[3].allocations
            local n2 = reagent.itemsInfo[2].allocations
            local n1 = reagent.itemsInfo[1].allocations
            local matQuantity = n1 + n2 + n3
            local matWeight = CraftSim.REAGENT_OPTIMIZATION:GetReagentWeightByID(reagent.itemsInfo[1].itemID)
            local relativeBonus = (n2 + 2 * n3) / 2 * matWeight
            
            if matQuantity < reagent.requiredQuantity then
                -- If you do not have enough of a material in total for a reagent slot, blizz assumes that you have max quantity of q2
                matQuantity = reagent.requiredQuantity
                relativeBonus = matQuantity / 2 * matWeight
            else
                if n2 + n3 > 0 then
                    -- the other slots are only treated as max q2 IF you have at least one slot that is satisfied AND gives you quality..
                    -- so full q1 does not count
                    hasAtLeastOneFullSlot = true
                end
            end
            --print("matQuantity: " .. matQuantity)
            table.insert(matBonus, relativeBonus)
            totalWeight = totalWeight + matQuantity * matWeight
        end
    end

    -- if nothing is allocated to satisfy a required quantity than the reagent skill contribution is 0
    if not hasAtLeastOneFullSlot then 
        return 0 
    end

    local matSkillBonus = 0
    local recipeMaxSkillBonus = recipeData.maxReagentSkillIncreaseFactor * recipeData.baseDifficulty
    for _, bonus in pairs(matBonus) do
        matSkillBonus = matSkillBonus + bonus / totalWeight * recipeMaxSkillBonus
    end

    print("reagent skill contribution old: " .. matSkillBonus)
    print("reagent skill contribution old (rounded): " .. CraftSim.UTIL:round(matSkillBonus))
    -- Try rounding it..
    return CraftSim.UTIL:round(matSkillBonus)
end

function CraftSim.REAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(recipeData.recipeID, false)
	--print("export: reagentSlotSchematics: " .. #schematicInfo.reagentSlotSchematics)
    if not CraftSim.SIMULATION_MODE.isActive then

    else
        --print("sim mode allocate..")
        for _, currentInput in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
            local reagentIndex = currentInput.inputq1.reagentIndex
            local reagentData = recipeData.reagents[reagentIndex]

            if currentInput.isActive and reagentData.differentQualities then
                for i = 1, 3, 1 do
                    local allocationForQuality = nil
                    -- check if bestAllocations has a allocation set for this reagent
                    for _, allocation in pairs(bestAllocation.allocations) do
                        for _, qAllocation in pairs(allocation.allocations) do
                            if qAllocation.itemID == reagentData.itemsInfo[i].itemID then
                                --print("found qAllocation..")
                                allocationForQuality = qAllocation.allocations
                            end
                        end
                    end
                    if allocationForQuality then
                        reagentData.itemsInfo[i].allocations = allocationForQuality
                        currentInput["inputq" .. i]:SetText(allocationForQuality)
                    end
                end
            end
        end
    
        CraftSim.MAIN:TriggerModulesErrorSafe()
    end
	
end

function CraftSim.REAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, bestAllocation)
    if not bestAllocation then
        return false
    end
    for _, reagent in pairs(recipeData.reagents) do
        for _, itemInfo in pairs(reagent.itemsInfo) do
            --print("check same alloc: " .. reagent.name)
            for _, allocation in pairs(bestAllocation.allocations) do
                for _, qAllocation in pairs(allocation.allocations) do
                    if qAllocation.itemID == itemInfo.itemID then
                        if qAllocation.allocations ~= itemInfo.allocations then
                            -- if we find any allocation that does not match for the same itemID ..
                            return false
                        end
                    end
                end
            end
        end
    end

    return true
end

function CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentsForScannedRecipeData(recipeData, priceData, UseInspiration, overrideData) 
    if not recipeData.hasReagentsWithQuality then
        return recipeData.reagents -- e.g: Primal Convergence
    end

    if recipeData.result.isNoQuality then
        for i, reagent in pairs(recipeData.reagents) do
            local cheapestQualityID = CraftSim.PRICEDATA:GetLowestCostQualityIDByItemsInfo(reagent.itemsInfo)
            reagent.itemsInfo[cheapestQualityID].allocations = reagent.requiredQuantity
            print("NonQualityRecipe: Return cheapest reagent quality for reagent #" .. tostring(i) .. ": " .. tostring(cheapestQualityID))
        end
        return recipeData.reagents
    end
    
    local bestAllocation = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeData.recipeType, priceData, CraftSim.CONST.EXPORT_MODE.SCAN, UseInspiration)
    print("Found Best Allocation For WhisperScan: ")
    print(bestAllocation, true)
    if bestAllocation then
        for _, reagent in pairs(recipeData.reagents) do
            if reagent.differentQualities then
                for _, itemInfo in pairs(reagent.itemsInfo) do
                    for _, allocation in pairs(bestAllocation.allocations) do
                        for _, subAllocation in pairs(allocation.allocations) do
                            if itemInfo.itemID == subAllocation.itemID then
                                itemInfo.allocations = subAllocation.allocations
                            end
                        end
                    end
                end
                -- reagent.itemsInfo[3].allocations = reagent.requiredQuantity
            else
                reagent.itemsInfo[1].allocations = reagent.requiredQuantity
            end 
        end

        return CopyTable(recipeData.reagents)
    else
        print("No best allocation found (should not be possible)")
    end
end