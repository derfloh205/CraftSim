---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.TOPGEAR : CraftSim.Module
CraftSim.TOPGEAR = {}
CraftSim.TOPGEAR.IsEquipping = false
CraftSim.TOPGEAR.EMPTY_SLOT = "EMPTY_SLOT"

local Logger = CraftSim.DEBUG:RegisterLogger("TopGear")

CraftSim.MODULES:RegisterModule("MODULE_TOP_GEAR", CraftSim.TOPGEAR, {
    label = L("CONTROL_PANEL_MODULES_TOP_GEAR_LABEL"),
    tooltip = L("CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP"),
})

GUTIL:RegisterCustomEvents(CraftSim.TOPGEAR, {
    "CRAFTSIM_RECIPE_DATA_UPDATED",
    "BAG_UPDATE_DELAYED",
    "PLAYER_ENTERING_WORLD",
})

CraftSim.TOPGEAR.SIM_MODES = {
    PROFIT = "TOP_GEAR_SIM_MODES_PROFIT",
    SKILL = "TOP_GEAR_SIM_MODES_SKILL",
    MULTICRAFT = "TOP_GEAR_SIM_MODES_MULTICRAFT",
    RESOURCEFULNESS = "TOP_GEAR_SIM_MODES_RESOURCEFULNESS",
    CRAFTING_SPEED = "TOP_GEAR_SIM_MODES_CRAFTING_SPEED"
}

---@param recipeData CraftSim.RecipeData
function CraftSim.TOPGEAR:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    self.UI:Update(recipeData)
end

function CraftSim.TOPGEAR:BAG_UPDATE_DELAYED()
    CraftSim.DB.CRAFTER:InvalidateProfessionGearCache(CraftSim.UTIL:GetPlayerCrafterUID())
end

function CraftSim.TOPGEAR:PLAYER_ENTERING_WORLD()
    CraftSim.DB.CRAFTER:InvalidateProfessionGearCache(CraftSim.UTIL:GetPlayerCrafterUID())
end

---@param professionGears CraftSim.ProfessionGear[]
---@param includeUncategorized boolean? when true, keeps the highest-ilvl item without a unique category
---@return CraftSim.ProfessionGear[]
local function getHighestItemLevelPerUniqueCategory(professionGears, includeUncategorized)
    ---@type table<number, CraftSim.ProfessionGear>
    local highestItemLevels = {}
    ---@type CraftSim.ProfessionGear?
    local highestUncategorized = nil

    for _, professionGear in pairs(professionGears) do
        local uniqueCategoryID = select(4, C_Item.GetItemUniquenessByID(professionGear.item:GetItemID()))
        local itemLevel = professionGear:GetItemLevel() or 0

        if uniqueCategoryID then
            local current = highestItemLevels[uniqueCategoryID]
            local currentItemLevel = current and current:GetItemLevel() or 0
            if not current or currentItemLevel < itemLevel then
                highestItemLevels[uniqueCategoryID] = professionGear
            end
        elseif includeUncategorized then
            local currentItemLevel = highestUncategorized and highestUncategorized:GetItemLevel() or 0
            if not highestUncategorized or currentItemLevel < itemLevel then
                highestUncategorized = professionGear
            end
        end
    end

    ---@type CraftSim.ProfessionGear[]
    local result = {}
    for _, professionGear in pairs(highestItemLevels) do
        table.insert(result, professionGear)
    end
    if includeUncategorized and highestUncategorized then
        table.insert(result, highestUncategorized)
    end
    return result
end

---@param combo (CraftSim.ProfessionGear|string)[]
---@param isCooking boolean
---@return string comboKey
local function getComboKey(combo, isCooking)
    local EMPTY = CraftSim.TOPGEAR.EMPTY_SLOT

    local function gearKey(gear)
        if gear == EMPTY or not gear or not gear.item then
            return ""
        end
        return gear.item:GetItemLink():gsub("Player.-:", "")
    end

    local toolKey = gearKey(combo[1])
    if isCooking then
        return toolKey .. "|" .. gearKey(combo[2])
    end

    local gearKeyA = gearKey(combo[2])
    local gearKeyB = gearKey(combo[3])
    if gearKeyA > gearKeyB then
        gearKeyA, gearKeyB = gearKeyB, gearKeyA
    end
    return toolKey .. "|" .. gearKeyA .. "|" .. gearKeyB
end

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
    local topGearFrame = CraftSim.TOPGEAR.frame
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
                --Logger:LogDebug("comparing limits: " .. limitName2 .. " == " .. limitName3)
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
    local seenKeys = {}

    for _, comboA in pairs(totalCombos) do
        local comboKey = getComboKey(comboA, isCooking)
        if not seenKeys[comboKey] then
            seenKeys[comboKey] = true
            table.insert(uniqueCombos, comboA)
        end
    end

    return uniqueCombos
end

---@param recipeData CraftSim.RecipeData
---@param forceCache? boolean when true, return DB snapshot only (alt crafter / deserialized queue items)
---@return CraftSim.ProfessionGear[] inventoryGear
function CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData, forceCache)
    local crafterUID = recipeData:GetCrafterUID()
    local profession = recipeData.professionData.professionInfo.profession

    if not recipeData:IsCrafter() or forceCache then
        recipeData.professionGearCached = CraftSim.DB.CRAFTER:GetProfessionGearCached(crafterUID, profession)
        return CraftSim.DB.CRAFTER:GetProfessionGearAvailable(crafterUID, profession)
    end

    -- Player crafter: always rescan bags so selectors / TopGear see current inventory.
    CraftSim.DB.CRAFTER:ClearProfessionGearAvailable(crafterUID, profession)
    local currentProfession = recipeData.professionData.professionInfo.parentProfessionName
    Logger:LogDebug("GetProfessionGearFromInventory: currentProfession: " .. tostring(currentProfession))
    local inventoryGear = {}
    local recipeExpansionID = recipeData.professionData and recipeData.professionData.expansionID
    local pendingItemLoads = false

    for bag = Enum.BagIndex.Backpack, Enum.BagIndex.CharacterBankTab_6 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)
            if itemLoc:IsValid() then
                local isCached = C_Item.IsItemDataCached(itemLoc)
                if not isCached then
                    C_Item.RequestLoadItemData(itemLoc)
                    pendingItemLoads = true
                end

                local itemLink = C_Item.GetItemLink(ItemLocation:CreateFromBagAndSlot(bag, slot))
                if itemLink ~= nil then
                    local itemID, _, itemSubType, itemEquipLoc = C_Item.GetItemInfoInstant(itemLink)
                    if itemSubType == currentProfession and
                        (itemEquipLoc == "INVTYPE_PROFESSION_TOOL" or itemEquipLoc == "INVTYPE_PROFESSION_GEAR") then
                        -- Only exclude items that are definitively from an older expansion.
                        if CraftSim.UTIL:IsItemExpansionCompatible(recipeExpansionID, itemID, "TopGearInventory") then
                            -- Ignore tradeable bag/bank pieces (e.g. fresh crafts); equipped set is added elsewhere.
                            if not isCached or C_Item.IsBound(itemLoc) then
                                local professionGear = CraftSim.ProfessionGear()
                                professionGear:SetItem(itemLink)
                                table.insert(inventoryGear, professionGear)

                                CraftSim.DB.CRAFTER:SaveProfessionGearAvailable(
                                    crafterUID,
                                    profession,
                                    professionGear
                                )
                            end
                        end
                    end
                elseif not isCached then
                    pendingItemLoads = true
                end
            end
        end
    end

    if pendingItemLoads then
        recipeData.professionGearCached = false
    else
        CraftSim.DB.CRAFTER:FlagProfessionGearCached(crafterUID, profession)
        recipeData.professionGearCached = true
    end

    return inventoryGear
end

--- Multicraft does not apply to work orders or non-multicraft recipes; keep resourcefulness tools and drop multicraft-only tools.
---@param uniqueGear CraftSim.ProfessionGear[]
---@param defaultToolSlotItems (CraftSim.ProfessionGear|string)[]
---@return CraftSim.ProfessionGear[]
function CraftSim.TOPGEAR:GetWorkOrderToolSlotItems(uniqueGear, defaultToolSlotItems)
    local tools = GUTIL:Filter(uniqueGear, function(gear)
        return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
    end)

    local bestResTool ---@type CraftSim.ProfessionGear?
    for _, tool in ipairs(tools) do
        local res = tool:GetResourcefulnessValue()
        if res > 0 and (not bestResTool or res > bestResTool:GetResourcefulnessValue()) then
            bestResTool = tool
        end
    end

    local result = GUTIL:Filter(defaultToolSlotItems, function(gear)
        if gear == CraftSim.TOPGEAR.EMPTY_SLOT then
            return true
        end
        return not gear:IsMulticraftOnlyTool()
    end)

    if bestResTool and not GUTIL:Find(result, function(gear)
            return gear ~= CraftSim.TOPGEAR.EMPTY_SLOT and gear:Equals(bestResTool)
        end) then
        tinsert(result, bestResTool)
    end

    if #result == 0 then
        tinsert(result, CraftSim.TOPGEAR.EMPTY_SLOT)
    end

    return result
end

---@param recipeData CraftSim.RecipeData
---@param results CraftSim.TopGearResult[]
---@return CraftSim.TopGearResult[]
function CraftSim.TOPGEAR:FilterResultsByWorkOrderMinQuality(recipeData, results)
    if not recipeData.orderData then
        return results
    end
    local minQuality = recipeData.orderData.minQuality
    if not minQuality or minQuality <= 0 or not recipeData.supportsQualities then
        return results
    end

    local filtered = GUTIL:Filter(results, function(result)
        return result.expectedQuality >= minQuality
    end)

    if #filtered > 0 then
        return filtered
    end

    -- No set meets min quality: prefer highest achievable quality (skill over useless mc tools).
    return GUTIL:Sort(results, function(resultA, resultB)
        if resultA.expectedQuality ~= resultB.expectedQuality then
            return resultA.expectedQuality > resultB.expectedQuality
        end
        local resA = resultA.professionGearSet.professionStats.resourcefulness.value
        local resB = resultB.professionGearSet.professionStats.resourcefulness.value
        return resA > resB
    end)
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
    ---@type CraftSim.ProfessionGear[]
    local uniqueGear = {}
    for _, professionGear in pairs(allGear) do
        if not GUTIL:Find(uniqueGear, function(gear)
                return gear.item:GetItemLink() ==
                    professionGear.item:GetItemLink()
            end) then
            table.insert(uniqueGear, professionGear)
        end
    end

    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local accessoryItems = GUTIL:Filter(uniqueGear,
        function(gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType end)

    local gearSlotItems = getHighestItemLevelPerUniqueCategory(accessoryItems, false)

    local toolSlotItems = getHighestItemLevelPerUniqueCategory(GUTIL:Filter(uniqueGear,
        function(gear) return gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType end), true)

    if recipeData:ShouldAvoidMulticraftOnlyTools() then
        toolSlotItems = CraftSim.TOPGEAR:GetWorkOrderToolSlotItems(uniqueGear, toolSlotItems)
    end

    -- if it is not possible to fill all slots, add an empty slot for permutation calculation
    if #gearSlotItems < 2 then
        table.insert(gearSlotItems, CraftSim.TOPGEAR.EMPTY_SLOT)
    end

    -- if no tool is available, add an empty slot for permutation calculation
    if #toolSlotItems < 1 then
        table.insert(toolSlotItems, CraftSim.TOPGEAR.EMPTY_SLOT)
    end

    -- permutate the gearslot items to get all combinations of two
    -- since there is either the accessory with the highest ilvl or an empty slot it will be at max 2^2 combinations

    -- if cooking we do not need to make any combinations cause we only have one gear slot
    local gearSlotCombos = {}

    if not recipeData.isCooking then
        for _, professionGearA in pairs(gearSlotItems) do
            for _, professionGearB in pairs(gearSlotItems) do
                local emptyA = professionGearA == CraftSim.TOPGEAR.EMPTY_SLOT
                local emptyB = professionGearB == CraftSim.TOPGEAR.EMPTY_SLOT
                local bothEmpty = emptyA and emptyB
                local partlyEmpty = emptyA or emptyB
                if bothEmpty or partlyEmpty or not professionGearA:Equals(professionGearB) then
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
    local averageProfitPreviousGear = recipeData.averageProfitCached or CraftSim.CALC:GetAverageProfit(recipeData)
    local needsConcentrationValue = topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT)
        and recipeData.concentrating
        and recipeData.supportsQualities
    local concentrationValuePreviousGear = needsConcentrationValue and recipeData:GetConcentrationValue() or 0

    -- convert to top gear results
    ---@type CraftSim.TopGearResult[]
    local results = GUTIL:Map(combinations, function(professionGearSet)
        recipeData.professionGearSet = professionGearSet
        recipeData:Update()
        local averageProfit = recipeData.averageProfitCached or CraftSim.CALC:GetAverageProfit(recipeData)
        local concentrationValue = needsConcentrationValue and recipeData:GetConcentrationValue() or 0
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
        Logger:LogDebug("Top Gear Mode: Profit")
        results = GUTIL:Filter(results,
            ---@param result CraftSim.TopGearResult
            function(result)
                -- should have at least 1 copper profit (and not some small decimal)
                Logger:LogDebug("Relative Profit in Filter: " .. tostring(result.relativeProfit))
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
        Logger:LogDebug("Top Gear Mode: Multicraft")
        results = GUTIL:Filter(results, function(result)
            return result.relativeStats.multicraft.value > 0
        end)
        results = GUTIL:Sort(results, function(resultA, resultB)
            return resultA.professionGearSet.professionStats.multicraft.value >
                resultB.professionGearSet.professionStats.multicraft.value
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.RESOURCEFULNESS) then
        Logger:LogDebug("Top Gear Mode: Resourcefulness")
        if recipeData:ShouldAvoidMulticraftOnlyTools() then
            local unfiltered = results
            results = GUTIL:Filter(results, function(result)
                local tool = result.professionGearSet.tool
                if tool and tool:IsMulticraftOnlyTool() then
                    return false
                end
                local res = result.professionGearSet.professionStats.resourcefulness.value
                return res > 0 or result.relativeStats.resourcefulness.value > 0
            end)
            if #results == 0 then
                results = GUTIL:Filter(unfiltered, function(result)
                    local tool = result.professionGearSet.tool
                    return not tool or not tool:IsMulticraftOnlyTool()
                end)
            end
        else
            results = GUTIL:Filter(results, function(result)
                return result.relativeStats.resourcefulness.value > 0
            end)
        end
        results = GUTIL:Sort(results, function(resultA, resultB)
            local resA = resultA.professionGearSet.professionStats.resourcefulness.value
            local resB = resultB.professionGearSet.professionStats.resourcefulness.value
            if resA ~= resB then
                return resA > resB
            end
            if recipeData.orderData and recipeData.orderData.minQuality and recipeData.supportsQualities then
                local skillA = resultA.professionGearSet.professionStats.skill.value
                local skillB = resultB.professionGearSet.professionStats.skill.value
                if skillA ~= skillB then
                    return skillA > skillB
                end
            end
            return resultA.averageProfit > resultB.averageProfit
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.CRAFTING_SPEED) then
        Logger:LogDebug("Top Gear Mode: Craftingspeed")
        results = GUTIL:Filter(results, function(result)
            return result.relativeStats.craftingspeed.value > 0
        end)
        results = GUTIL:Sort(results, function(resultA, resultB)
            return resultA.professionGearSet.professionStats.craftingspeed.value >
                resultB.professionGearSet.professionStats.craftingspeed.value
        end)
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL) then
        Logger:LogDebug("Top Gear Mode: Skill")
        results = GUTIL:Sort(results, function(resultA, resultB)
            local maxSkillA = resultA.professionGearSet.professionStats.skill.value
            local maxSkillB = resultB.professionGearSet.professionStats.skill.value
            return maxSkillA > maxSkillB
        end)
    end

    return self:FilterResultsByWorkOrderMinQuality(recipeData, results)
end

function CraftSim.TOPGEAR:OptimizeAndDisplay(recipeData)
    local topGearMode = CraftSim.DB.OPTIONS:Get("TOP_GEAR_MODE")
    local results = self:OptimizeTopGear(recipeData, topGearMode)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local hasResults = #results > 0

    if hasResults and not recipeData.professionGearSet:Equals(results[1].professionGearSet) then
        Logger:LogDebug("best result")
        CraftSim.TOPGEAR.UI:UpdateTopGearDisplay(results, topGearMode, exportMode)
    else
        CraftSim.TOPGEAR.UI:ClearTopGearDisplay(recipeData, false, exportMode)
    end
end
