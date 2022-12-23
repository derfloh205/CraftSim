CraftSimREAGENT_OPTIMIZATION = {}

-- TODO: check why the calculation is off

local function translateLuaIndex(index)
    return index + 1
end

-- By Liqorice's knapsack solution
function CraftSimREAGENT_OPTIMIZATION:OptimizeReagentAllocation(recipeData, recipeType, priceData)
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
        local itemID = reagent.itemsInfo[1].itemID
        --print("mWeight array init: " .. i .. " to " .. CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) )
        mWeight[i] = CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) --  * reagent.requiredQuantity fixed double counting of quantity
    end

    --print(" calculating gcd of " .. unpack(mWeight))
    local weightGCD = CraftSimUTIL:FoldTable(mWeight, function(a, b) 
        --print("fold " .. a .. " and " .. b)
        return CraftSimREAGENT_OPTIMIZATION:GetGCD(a, b)
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

    local recipeMaxSkillBonus = 0.25 * recipeData.baseDifficulty
    
    -- Calculate the material bonus needed to meet each breakpoint based on the player's
    --   existing skill and the recipe difficulty (as a fraction of the recipeMaxSkillBonus
    -- Breakpoints are sorted highest to lowest
    -- Array value = -1 means this breakpoint is unreachable
    --               0 means no skill bonus required to reach this BP
    --               > 0 means the indicated skill bonus is required to reach this BP
    -- At least one entry will be >= 0
    local totalSkill = recipeData.stats.skill
    local reagentSkillContribution = CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData) or 0
    local skillWithoutReagentIncrease = totalSkill - reagentSkillContribution
    --print("skill without reagents: " .. tostring(skillWithoutReagentIncrease))
    --print("reagentSkillContribution: " .. tostring(reagentSkillContribution))

    local expectedQualityWithoutReagents = CraftSimSTATS:GetExpectedQualityBySkill(recipeData, skillWithoutReagentIncrease)

    for i = 0, numBP - 1, 1 do
        --print("checking BP: " .. tostring(craftingDifficultyBP[i]))
        local extraSkillPoint = 0
        if CraftSimOptions.breakPointOffset then
            extraSkillPoint = 1
        end
        local skillBreakpoint = craftingDifficultyBP[i] * recipeData.recipeDifficulty + extraSkillPoint
        --print("skill BP: " .. skillBreakpoint)
        -- EXPERIMENT: try to adjust skillbp by 1 to workaround blizz rounding errors
        --skillBreakpoint = skillBreakpoint + 1
        local inspirationBonusSkill = CraftSimOptions.materialSuggestionInspirationThreshold and recipeData.stats.inspiration.bonusskill or 0
        arrayBP[i] = skillBreakpoint - (skillWithoutReagentIncrease + inspirationBonusSkill)
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

    --print("arrayBP: ")
    --CraftSimUTIL:PrintTable(arrayBP)

    -- print("ksItems: ")
    -- for k, v in pairs(ksItems) do
    --     print(v.name .. ": ")
    --     print("weight: " .. tostring(v.mWeight))
    -- end


    -- Optimize Knapsack
    local results = CraftSimREAGENT_OPTIMIZATION:optimizeKnapsack(ksItems, arrayBP)  

    -- remove any result that maps to the expected quality without reagent increase
    -- NEW: any that is below! Same is fine
    local results = CraftSimUTIL:FilterTable(results, function(result) 
        return result.qualityReached >= expectedQualityWithoutReagents
    end)

    -- TODO: remove results that are the same allocation as the current one? and disable button?

    
    local hasItems = true
    local bestAllocation = results[1]--results[#results]
    local isSameAllocation = CraftSimREAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, bestAllocation)

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
    
    CraftSimFRAME:ShowBestReagentAllocation(recipeData, recipeType, priceData, bestAllocation, hasItems, isSameAllocation)
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

function CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(itemID) 
    local weightEntry = CraftSimREAGENTWEIGHTS[itemID]
    if weightEntry == nil then
        return 0
    end
    return weightEntry.weight
end


function CraftSimREAGENT_OPTIMIZATION:GetGCD(a, b)
        --print("get gcd between " .. a .. " and " .. b)
        if b ~= 0 then
            return CraftSimREAGENT_OPTIMIZATION:GetGCD(b, a % b)
        else
            return abs(a)
        end
end

function CraftSimREAGENT_OPTIMIZATION:optimizeKnapsack(ks, BPs)
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
                    -- if b[i][j + ks[i].crumb[k].weight] == nil then
                    --     -- NOTE: this is to fix calculated floats as weights (like potion of frozen focus which results in weight 10.5)
                    --     -- Cause the init of it just inits integer j indices
                    --     b[i][j + ks[i].crumb[k].weight] = inf 
                    -- end
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
            tStart = math.floor(BPs[h] * maxWeight)
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

    --print("outArr:")
    --CraftSimUTIL:PrintTable(outArr)

    --print("results: ")
    for _, itemAllocation in pairs(outResult) do
        --print("Reachable quality: " .. itemAllocation.qualityReached)

        for _, matAllocation in pairs(itemAllocation.allocations) do
            --print("- name: " .. matAllocation.itemName)

            local qText = "--"
            for qualityIndex, allocation in pairs(matAllocation.allocations) do
                qText = qText .. "q" .. qualityIndex .. ": " .. allocation.allocations .. " | "
            end
            --print(qText)
        end
    end

    return outResult
end

function CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(recipeData)

    local matBonus = {}
    local totalWeight = 0

    local hasAtLeastOneFullSlot = false
    for index, reagent in pairs(recipeData.reagents) do
        if reagent.differentQualities then
            local n3 = reagent.itemsInfo[3].allocations
            local n2 = reagent.itemsInfo[2].allocations
            local n1 = reagent.itemsInfo[1].allocations
            local matQuantity = n1 + n2 + n3
            local matWeight = CraftSimREAGENT_OPTIMIZATION:GetReagentWeightByID(reagent.itemsInfo[1].itemID)
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
    local recipeMaxSkillBonus = 0.25 * recipeData.baseDifficulty
    for _, bonus in pairs(matBonus) do
        matSkillBonus = matSkillBonus + bonus / totalWeight * recipeMaxSkillBonus
    end

    --print("reagent skill contribution: " .. matSkillBonus)
    -- Try rounding it..
    return CraftSimUTIL:round(matSkillBonus)
end

function CraftSimREAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(recipeData.recipeID, false)
	--print("export: reagentSlotSchematics: " .. #schematicInfo.reagentSlotSchematics)
    if not CraftSimSIMULATION_MODE.isActive then
        -- -- TODO: possibly protected.. 
        -- return
        -- local reagentSlots = ProfessionsFrame.CraftingPage.SchematicForm.reagentSlots[1]
        -- for slotIndex, currentSlot in pairs(schematicInfo.reagentSlotSchematics) do
        --     local reagents = currentSlot.reagents
        --     local reagentType = currentSlot.reagentType
        --     local reagentName = CraftSimDATAEXPORT:GetReagentNameFromReagentData(reagents[1].itemID)
        --     local allocations = recipeData.currentTransaction:GetAllocations(slotIndex)
        --     --allocations:Clear(); -- set all to zero
        --     if reagentType == CraftSimCONST.REAGENT_TYPE.REQUIRED then
        --         local hasMoreThanOneQuality = reagents[2] ~= nil
    
        --         if hasMoreThanOneQuality then
        --             for reagentIndex, reagent in pairs(reagents) do
        --                 local allocationForQuality = nil
        --                 -- check if bestAllocations has a allocation set for this reagent
        --                 for _, allocation in pairs(bestAllocation.allocations) do
        --                     for _, qAllocation in pairs(allocation.allocations) do
        --                         if qAllocation.itemID == reagent.itemID then
        --                             --print("found qAllocation..")
        --                             allocationForQuality = qAllocation.allocations
        --                         end
        --                     end
        --                 end
        --                 if allocationForQuality then
        --                     --print("Allocate: " .. reagent.itemID .. ": " .. allocationForQuality)
        --                     allocations:Allocate(reagent, allocationForQuality);
        --                 end
        --             end
        --         else
        --             local itemCount = GetItemCount(reagents[1].itemID, true, true, true)
        --             allocations:Allocate(reagents[1], math.min(itemCount, recipeData.reagents[slotIndex].requiredQuantity))
        --         end
        --         recipeData.currentTransaction:OverwriteAllocations(slotIndex, allocations);
        --         recipeData.currentTransaction:SetManuallyAllocated(true);
        --         reagentSlots[slotIndex]:Update();
        --     end
        -- end
        -- -- this should trigger our modules AND everything blizzard needs to know
        -- ProfessionsFrame.CraftingPage.SchematicForm:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified)
        -- update frontend with fresh data
        -- local freshRecipeData = CraftSimDATAEXPORT:exportRecipeData()
        -- local freshPriceData = CraftSimPRICEDATA:GetPriceData(freshRecipeData, freshRecipeData.recipeType)
        -- CraftSimREAGENT_OPTIMIZATION:OptimizeReagentAllocation(freshRecipeData, freshRecipeData.recipeType, freshPriceData)
    else
        --print("sim mode allocate..")
        for _, currentInput in pairs(CraftSimSIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
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
    
        CraftSimMAIN:TriggerModulesByRecipeType()
    end
	
end

function CraftSimREAGENT_OPTIMIZATION:IsCurrentAllocation(recipeData, bestAllocation)
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

-- TODO: does not work cause allocations are protected..
function CraftSimREAGENT_OPTIMIZATION:AutoAssignVellum(recipeData)
    -- print("vellum auto assign")
    -- local vellumItemID = 38682
    -- -- local enchantAllocation = recipeData.currentTransaction:GetEnchantAllocation()
    -- -- -- if something is already allocated, ignore
    -- -- if enchantAllocation then
    -- --     print("ignore cause enchant is allocated")
    -- --     return
    -- -- end
    -- ItemUtil.IteratePlayerInventoryAndEquipment(function(itemLocation)
    --     if C_Item.GetItemID(itemLocation) == vellumItemID then

    --         local allocations = recipeData.currentTransaction:GetAllocations(slotIndex)
    --         print("try to set enchant")
    --         local vellumItem = Item:CreateFromItemGUID(C_Item.GetItemGUID(itemLocation))
    --         recipeData.currentTransaction:SetEnchantAllocation(vellumItem) -- seems to be protected???
    --         ProfessionsFrame.CraftingPage.SchematicForm.enchantSlot:SetItem(vellumItem)
    --         recipeData.currentTransaction:SanitizeTargetAllocations();
    --         ProfessionsFrame.CraftingPage.SchematicForm:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
    --     end
    -- end);
end