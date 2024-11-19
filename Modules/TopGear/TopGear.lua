---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.TOPGEAR
CraftSim.TOPGEAR = {}
CraftSim.TOPGEAR.IsEquipping = false
CraftSim.TOPGEAR.EMPTY_SLOT = "EMPTY_SLOT"

local print = CraftSim.DEBUG:RegisterDebugID("Modules.TopGear")

CraftSim.TOPGEAR.SIM_MODES = {
    PROFIT = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT,
    SKILL = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL,
    MULTICRAFT = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT,
    RESOURCEFULNESS = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS,
    CRAFTING_SPEED = CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED
}

function CraftSim.TOPGEAR:GetSimMode(simMode)
    return CraftSim.LOCAL:GetText(simMode)
end

function CraftSim.TOPGEAR:UnequipProfessionItems(professionID)
    local professionSlots = C_TradeSkillUI.GetProfessionSlots(professionID)

    for _, currentSlot in pairs(professionSlots) do
        PickupInventoryItem(currentSlot)
        PutItemInBackpack();
    end
end

function CraftSim.TOPGEAR:EquipTopGear()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local topGearFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    else
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    end
    if topGearFrame.currentTopResult then
        topGearFrame.currentTopResult.professionGearSet:Equip()
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndType(recipeData)
    local availableModes = {}

    table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT)) -- profit should now also always be available since overwriting prices is always possible

    if recipeData.supportsQualities then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL))
    end

    if recipeData.supportsMulticraft then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.MULTICRAFT))
    end

    if recipeData.supportsResourcefulness then
        table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.RESOURCEFULNESS))
    end

    -- crafting speed should always be able to sim cause it is always available even if not shown in details
    table.insert(availableModes, CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.CRAFTING_SPEED))

    return availableModes
end

function CraftSim.TOPGEAR:GetValidCombosFromUniqueCombos(uniqueCombos)
    local validCombos = {}
    for _, combo in pairs(uniqueCombos) do
        -- combo[1] is the tool always, we have only one slot anyway
        if combo[2] == CraftSim.TOPGEAR.EMPTY_SLOT or combo[3] == CraftSim.TOPGEAR.EMPTY_SLOT then
            table.insert(validCombos, { combo[1], combo[2], combo[3] })
        else
            local id2 = combo[2].item:GetItemID()
            local id3 = combo[3].item:GetItemID()

            local _, limitName2, limitCount2 = C_Item.GetItemUniquenessByID(id2)
            local _, limitName3, limitCount3 = C_Item.GetItemUniquenessByID(id3)

            if limitName2 ~= nil and limitCount2 >= 1 and limitName3 ~= nil and limitCount3 >= 1 then
                --print("comparing limits: " .. limitName2 .. " == " .. limitName3)
                if limitName2 ~= limitName3 then
                    table.insert(validCombos, { combo[1], combo[2], combo[3] })
                end
            end
        end
    end
    return validCombos
end

function CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutations(totalCombos, isCooking)
    local uniqueCombos = {}
    local EMPTY = CraftSim.TOPGEAR.EMPTY_SLOT

    for _, comboA in pairs(totalCombos) do
        -- combination can have 3 entry where each is either empty or a professionGear
        local toolA = comboA[1]
        local gear1A = comboA[2]
        local gear2A = comboA[3]

        local inserted = GUTIL:Find(uniqueCombos, function(comboB)
            if not isCooking then
                local toolB = comboB[1]
                local gear1B = comboB[2]
                local gear2B = comboB[3]

                local existsGear1 = gear1A == EMPTY and (gear1B == EMPTY or gear2B == EMPTY)
                if not existsGear1 then
                    existsGear1 = (gear1B ~= EMPTY and gear1B:Equals(gear1A)) or
                        (gear2B ~= EMPTY and gear2B:Equals(gear1A))
                end

                local existsGear2 = gear2A == EMPTY and (gear1B == EMPTY or gear2B == EMPTY)
                if not existsGear2 then
                    existsGear2 = (gear1B ~= EMPTY and gear1B:Equals(gear2A)) or
                        (gear2B ~= EMPTY and gear2B:Equals(gear2A))
                end

                local existsTool = toolA == EMPTY and toolB == EMPTY
                if not existsTool then
                    existsTool = toolB ~= EMPTY and toolB:Equals(toolA)
                end

                if existsGear1 and existsGear2 and existsTool then
                    -- print("found matching combo..")
                    return true
                end

                return false
            else
                local toolB = comboB[1]
                local gear1B = comboB[2]

                local existsGear = gear1A == EMPTY and gear1B == EMPTY
                if not existsGear then
                    existsGear = gear1B ~= EMPTY and gear1B:Equals(gear1A)
                end

                local existsTool = toolA == EMPTY and toolB == EMPTY
                if not existsTool then
                    existsTool = toolB ~= EMPTY and toolB:Equals(toolA)
                end

                if existsGear and existsTool then
                    return true
                end

                return false
            end
        end)

        if not inserted then
            table.insert(uniqueCombos, comboA)
        end
    end

    return uniqueCombos
end

---@param recipeData CraftSim.RecipeData
---@param forceCache? boolean
---@return CraftSim.ProfessionGear[] inventoryGear
function CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData, forceCache)
    local crafterUID = recipeData:GetCrafterUID()
    if recipeData:IsCrafter() and not forceCache then
        local currentProfession = recipeData.professionData.professionInfo.parentProfessionName
        print("GetProfessionGearFromInventory: currentProfession: " .. tostring(currentProfession))
        local inventoryGear = {}

        for bag = BANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)
                if itemLoc:IsValid() then
                    local isCached = C_Item.IsItemDataCached(itemLoc)
                    if not isCached then
                        C_Item.RequestLoadItemData(itemLoc)
                    end

                    local itemLink = C_Item.GetItemLink(ItemLocation:CreateFromBagAndSlot(bag, slot))
                    if itemLink ~= nil then
                        local itemSubType = select(3, C_Item.GetItemInfoInstant(itemLink))
                        local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemLink))
                        if itemSubType == currentProfession and (itemEquipLoc == "INVTYPE_PROFESSION_TOOL" or itemEquipLoc == "INVTYPE_PROFESSION_GEAR") then
                            local professionGear = CraftSim.ProfessionGear()
                            professionGear:SetItem(itemLink)
                            table.insert(inventoryGear, professionGear)

                            CraftSim.DB.CRAFTER:SaveProfessionGearAvailable(crafterUID,
                                recipeData.professionData.professionInfo.profession, professionGear)
                        end
                    end
                end
            end
        end
        CraftSim.DB.CRAFTER:FlagProfessionGearCached(crafterUID, recipeData.professionData.professionInfo.profession)
        return inventoryGear
    else
        recipeData.professionGearCached = CraftSim.DB.CRAFTER:GetProfessionGearCached(crafterUID,
            recipeData.professionData.professionInfo.profession)

        return CraftSim.DB.CRAFTER:GetProfessionGearAvailable(crafterUID,
            recipeData.professionData.professionInfo.profession)
    end
end

---@param recipeData CraftSim.RecipeData
---@return CraftSim.ProfessionGearSet[] topGearSets
function CraftSim.TOPGEAR:GetProfessionGearCombinations(recipeData)
    local equippedGear = CraftSim.ProfessionGearSet(recipeData)

    equippedGear:LoadCurrentEquippedSet()

    local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)

    local equippedGearList = GUTIL:Filter(equippedGear:GetProfessionGearList(),
        function(gear) return gear and gear.item ~= nil end)

    if #equippedGearList == 0 and #inventoryGear == 0 then
        return {}
    end

    local allGear = GUTIL:Concat({ inventoryGear, equippedGearList })

    -- remove duplicated items (with same stats, this means the link should be the same..)
    local uniqueGear = {}
    for _, professionGear in pairs(allGear) do
        if not GUTIL:Find(uniqueGear, function(gear)
                return gear.item:GetItemLink() ==
                    professionGear.item:GetItemLink()
            end) then
            table.insert(uniqueGear, professionGear)
        end
    end

    allGear = uniqueGear
    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local gearSlotItems = GUTIL:Filter(allGear,
        function(gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType end)
    local toolSlotItems = GUTIL:Filter(allGear,
        function(gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType end)
    table.insert(gearSlotItems, CraftSim.TOPGEAR.EMPTY_SLOT)
    table.insert(toolSlotItems, CraftSim.TOPGEAR.EMPTY_SLOT)

    -- permutate the gearslot items to get all combinations of two

    -- if cooking we do not need to make any combinations cause we only have one gear slot
    local gearSlotCombos = {}

    if not recipeData.isCooking then
        for _, professionGearA in pairs(gearSlotItems) do
            for _, professionGearB in pairs(gearSlotItems) do
                local emptyA = professionGearA == CraftSim.TOPGEAR.EMPTY_SLOT
                local emptyB = professionGearB == CraftSim.TOPGEAR.EMPTY_SLOT
                local bothEmpty = emptyA and emptyB
                local partlyEmpty = emptyA or emptyB
                if bothEmpty or (partlyEmpty or not professionGearA:Equals(professionGearB)) then
                    -- do not match item with itself..
                    table.insert(gearSlotCombos, { professionGearA, professionGearB })
                end
            end
        end
    else
        gearSlotCombos = gearSlotItems
    end


    -- then permutate those combinations with the tool items to get all available gear combos
    -- if cooking just combine 1 gear with tool
    local totalCombos = {}

    if not recipeData.isCooking then
        for _, combo in pairs(gearSlotCombos) do
            for _, tool in pairs(toolSlotItems) do
                table.insert(totalCombos, { tool, combo[1], combo[2] })
            end
        end
    else
        for _, combo in pairs(gearSlotCombos) do
            for _, tool in pairs(toolSlotItems) do
                table.insert(totalCombos, { tool, combo })
            end
        end
    end


    local uniqueCombos = CraftSim.TOPGEAR:GetUniqueCombosFromAllPermutations(totalCombos, recipeData.isCooking)

    local function convertToProfessionGearSet(combos)
        return GUTIL:Map(combos, function(combo)
            local professionGearSet = CraftSim.ProfessionGearSet(recipeData)
            local tool = combo[1]
            local gear1 = combo[2]
            local gear2 = combo[3]
            if recipeData.isCooking then
                if tool ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.tool = tool
                end
                if gear1 ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.gear2 = gear1
                end
            else
                if tool ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.tool = tool
                end
                if gear1 ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.gear1 = gear1
                end
                if gear2 ~= CraftSim.TOPGEAR.EMPTY_SLOT then
                    professionGearSet.gear2 = gear2
                end
            end

            professionGearSet:UpdateProfessionStats()
            return professionGearSet
        end)
    end


    -- Remove invalid combos (with two gear items that share the same unique equipped restriction)
    -- only needed if not cooking
    if not recipeData.isCooking then
        local validCombos = CraftSim.TOPGEAR:GetValidCombosFromUniqueCombos(uniqueCombos)
        return convertToProfessionGearSet(validCombos)
    else
        return convertToProfessionGearSet(uniqueCombos)
    end
end

---@param recipeData CraftSim.RecipeData
---@param topGearMode string
---@return CraftSim.TopGearResult[] topGearResults
function CraftSim.TOPGEAR:OptimizeTopGear(recipeData, topGearMode)
    topGearMode = topGearMode or CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT)
    local combinations = CraftSim.TOPGEAR:GetProfessionGearCombinations(recipeData)

    local previousGear = recipeData.professionGearSet
    local averageProfitPreviousGear = CraftSim.CALC:GetAverageProfit(recipeData)
    local concentrationValuePreviousGear = recipeData:GetConcentrationValue()

    -- convert to top gear results
    ---@type CraftSim.TopGearResult[]
    local results = GUTIL:Map(combinations, function(professionGearSet)
        recipeData.professionGearSet = professionGearSet
        recipeData:Update()
        local averageProfit = CraftSim.CALC:GetAverageProfit(recipeData)
        local concentrationValue = recipeData:GetConcentrationValue()
        local relativeProfit = averageProfit - averageProfitPreviousGear
        local relativeConcentrationValue = concentrationValue - concentrationValuePreviousGear
        local relativeStats = professionGearSet.professionStats:Copy()
        local expectedQuality = recipeData.resultData.expectedQuality
        local expectedQualityUpgrade = recipeData.resultData.expectedQualityUpgrade -- TODO: Remove or change
        relativeStats:subtract(previousGear.professionStats)
        local result = CraftSim.TopGearResult(professionGearSet, averageProfit, relativeProfit, concentrationValue,
            relativeConcentrationValue, relativeStats,
            expectedQuality, expectedQualityUpgrade)
        return result
    end)

    -- revert recipe data
    recipeData.professionGearSet = previousGear
    recipeData:Update()

    -- sort results by selected mode
    if topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT) then
        print("Top Gear Mode: Profit")
        results = GUTIL:Filter(results,
            ---@param result CraftSim.TopGearResult
            function(result)
                -- should have at least 1 copper profit (and not some small decimal)
                print("Relative Profit in Filter: " .. tostring(result.relativeProfit))
                return result.relativeProfit >= 1
            end)
        results = GUTIL:Sort(results, function(resultA, resultB)
            if recipeData.concentrating and recipeData.supportsQualities then
                return resultA.concentrationValue > resultB.concentrationValue
            else
                return resultA.averageProfit > resultB.averageProfit
            end
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.MULTICRAFT) then
        print("Top Gear Mode: Multicraft")
        results = GUTIL:Filter(results, function(result)
            return result.relativeStats.multicraft.value > 0
        end)
        results = GUTIL:Sort(results, function(resultA, resultB)
            return resultA.professionGearSet.professionStats.multicraft.value >
                resultB.professionGearSet.professionStats.multicraft.value
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.RESOURCEFULNESS) then
        print("Top Gear Mode: Resourcefulness")
        results = GUTIL:Filter(results, function(result)
            return result.relativeStats.resourcefulness.value > 0
        end)
        results = GUTIL:Sort(results, function(resultA, resultB)
            return resultA.professionGearSet.professionStats.resourcefulness.value >
                resultB.professionGearSet.professionStats.resourcefulness.value
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.CRAFTING_SPEED) then
        print("Top Gear Mode: Craftingspeed")
        results = GUTIL:Filter(results, function(result)
            return result.relativeStats.craftingspeed.value > 0
        end)
        results = GUTIL:Sort(results, function(resultA, resultB)
            return resultA.professionGearSet.professionStats.craftingspeed.value >
                resultB.professionGearSet.professionStats.craftingspeed.value
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL) then
        print("Top Gear Mode: Skill")
        results = GUTIL:Sort(results, function(resultA, resultB)
            local maxSkillA = resultA.professionGearSet.professionStats.skill.value
            local maxSkillB = resultB.professionGearSet.professionStats.skill.value
            return maxSkillA > maxSkillB
        end)
    end

    return results
end

function CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
    local topGearMode = CraftSim.DB.OPTIONS:Get("TOP_GEAR_MODE")
    local results = self:OptimizeTopGear(recipeData, topGearMode)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local hasResults = #results > 0

    if hasResults and not recipeData.professionGearSet:Equals(results[1].professionGearSet) then
        print("best result")
        print(results[1])
        CraftSim.TOPGEAR.UI:UpdateTopGearDisplay(results, topGearMode, exportMode)
    else
        CraftSim.TOPGEAR.UI:ClearTopGearDisplay(recipeData, false, exportMode)
    end
end
