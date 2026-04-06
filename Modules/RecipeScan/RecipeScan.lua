---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.RECIPE_SCAN
CraftSim.RECIPE_SCAN = {}

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

CraftSim.RECIPE_SCAN.frame = nil
CraftSim.RECIPE_SCAN.isScanning = false
CraftSim.RECIPE_SCAN.isScanningProfessions = false

---@type string? last profession UID that was open when UpdateProfessionListByCache ran
CraftSim.RECIPE_SCAN.lastOpenProfessionUID = nil

---@type GUTIL.FrameDistributor?
CraftSim.RECIPE_SCAN.rowScanFrameDistributor = nil

---@type GUTIL.FrameDistributor?
CraftSim.RECIPE_SCAN.professionScanFrameDistributor = nil

---@enum CraftSim.RecipeScanModes
CraftSim.RECIPE_SCAN.SCAN_MODES = {
    Q1 = "Q1",
    Q2 = "Q2",
    Q3 = "Q3",
    OPTIMIZE = "OPTIMIZE",
}

---@enum CraftSim.RecipeScanSortModes
CraftSim.RECIPE_SCAN.SORT_MODES = {
    PROFIT = "PROFIT",
    RELATIVE_PROFIT = "RELATIVE_PROFIT",
    CONCENTRATION_VALUE = "CONCENTRATION_VALUE",
    CONCENTRATION_COST = "CONCENTRATION_COST",
    CRAFTING_COST = "CRAFTING_COST",
}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.RecipeScan")
local printF = CraftSim.DEBUG:RegisterDebugID("Modules.RecipeScan.Filter")
local printS = CraftSim.DEBUG:RegisterDebugID("Modules.RecipeScan.Scanning")

--- Fonction pour vérifier si un item est craftable
---@param itemID number
---@return boolean, number? recipeID
local function IsItemCraftable(itemID)
    local recipes = C_TradeSkillUI.GetAllRecipeIDs()
    for _, recipeID in ipairs(recipes) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.itemIDCreated == itemID then
            return true, recipeID
        end
    end
    return false
end

--- Fonction récursive pour ajouter les précrafts à la file
---@param recipeData CraftSim.RecipeData
---@param amount number
---@param queue table
---@param shoppingList table
---@param processedRecipes table?
local function AddPrecraftsToQueue(recipeData, amount, queue, shoppingList, processedRecipes)
    processedRecipes = processedRecipes or {}
    for _, reagent in ipairs(recipeData.reagentData.requiredReagents) do
        if not reagent:IsOrderReagentIn(recipeData) then
            local itemID = reagent.items[1].item:GetItemID()
            local isCraftable, recipeID = IsItemCraftable(itemID)
            if isCraftable and not processedRecipes[recipeID] then
                processedRecipes[recipeID] = true
                local precraftRecipeData = CraftSim.RecipeData({ recipeID = recipeID })
                precraftRecipeData:SetCheapestQualityReagentsMax()
                precraftRecipeData:Update()
                table.insert(queue, {
                    recipeData = precraftRecipeData,
                    amount = reagent.quantity * amount,
                })
                AddPrecraftsToQueue(precraftRecipeData, reagent.quantity * amount, queue, shoppingList, processedRecipes)
            else
                local found = false
                for _, entry in ipairs(shoppingList) do
                    if entry.itemID == itemID then
                        entry.quantity = entry.quantity + (reagent.quantity * amount)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(shoppingList, {
                        itemID = itemID,
                        quantity = reagent.quantity * amount,
                    })
                end
            end
        end
    end
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:ToggleScanButton(row, value)
    local content = row.content
    content.scanButton:SetEnabled(value)
    content.cancelScanButton:SetVisible(not value)
    if not value then
        content.scanButton:SetText(CraftSim.LOCAL:GetText("RECIPE_SCAN_SCANNING") .. " 0%")
    else
        content.scanButton:SetText(CraftSim.LOCAL:GetText("RECIPE_SCAN_SCAN_RECIPIES"))
    end

    if CraftSim.RECIPE_SCAN.isScanningProfessions then
        content.cancelScanButton:Hide()
    end
end

---@return fun(a: any, b: any) : boolean
function CraftSim.RECIPE_SCAN:GetSortFunction()
    local ascending = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE_ASCENDING")
    local function compare(a, b)
        if ascending then
            return a < b
        else
            return a > b
        end
    end
    local sortFuncMap = {
        [CraftSim.RECIPE_SCAN.SORT_MODES.PROFIT] = function(a, b)
            return compare(a.averageProfit, b.averageProfit)
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.RELATIVE_PROFIT] = function(a, b)
            return compare(a.relativeProfit, b.relativeProfit)
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_COST] = function(a, b)
            return compare(a.concentrationCost, b.concentrationCost)
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_VALUE] = function(a, b)
            return compare(a.concentrationWeight, b.concentrationWeight)
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.CRAFTING_COST] = function(a, b)
            return compare(a.craftingCost, b.craftingCost)
        end,
    }
    return sortFuncMap[CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE")]
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:EndScan(row)
    local ms = CraftSim.DEBUG:StopProfiling("Total Recipe Scan")
    printS("Scan finished: " .. ms .. " ms")
    collectgarbage("collect")
    CraftSim.RECIPE_SCAN:ToggleScanButton(row, true)
    CraftSim.RECIPE_SCAN.isScanning = false

    local resultList = row.content.resultList
    resultList:UpdateDisplay(self:GetSortFunction())

    if CraftSim.RECIPE_SCAN.isScanningProfessions then
        CraftSim.RECIPE_SCAN:ScanNextProfessionRow()
    end
end

function CraftSim.RECIPE_SCAN:UpdateResultSort()
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList
    local activeRow = professionList.selectedRow

    if activeRow then
        local resultList = activeRow.content.resultList
        resultList:UpdateDisplay(self:GetSortFunction())
    end
end

function CraftSim.RECIPE_SCAN:CancelProfessionScan()
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList

    local scanRow = professionList.selectedRow
    if scanRow then
        CraftSim.RECIPE_SCAN:EndProfessionScan()
        CraftSim.RECIPE_SCAN:EndScan(scanRow)
    end
end

---@param crafterUID string
---@param recipeInfo TradeSkillRecipeInfo
function CraftSim.RECIPE_SCAN.FilterRecipeInfo(crafterUID, recipeInfo)
    printF("Filtering Recipe: " .. tostring(recipeInfo.name))
    if tContains(CraftSim.CONST.ALCHEMICAL_EXPERIMENTATION_RECIPE_IDS, recipeInfo.recipeID) then
        printF("Is Alchemical Experimentation: Exclude")
        return false
    end
    if recipeInfo.isDummyRecipe then
        printF("Is Dummy: Exclude")
        return false
    end
    if tContains(CraftSim.CONST.BLIZZARD_DUMMY_RECIPES, recipeInfo.recipeID) then
        printF("Is Dummy2: Exclude")
        return false
    end
    if not CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_NOT_LEARNED") and not recipeInfo.learned then
        printF("Is not learned: Exclude")
        return false
    end
    if tContains(CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS, recipeInfo.categoryID) then
        printF("Is Quest: Exclude")
        return false
    end

    local professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeInfo.recipeID)

    if not professionInfo then
        printF("professionInfo not Cached: Get from Api")
        professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)
    end

    if not professionInfo.profession then
        printF("ProfessionInfo - profession missing: Exclude")
        return false
    end

    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        CraftSim.DB.CRAFTER:UpdateFavoriteRecipe(crafterUID, professionInfo.profession, recipeInfo.recipeID,
            C_TradeSkillUI.IsRecipeFavorite(recipeInfo.recipeID) == true)
    end

    if CraftSim.DB.OPTIONS:Get("RECIPESCAN_ONLY_FAVORITES") and not CraftSim.DB.CRAFTER:IsFavorite(recipeInfo.recipeID, crafterUID, professionInfo.profession) then
        printF("Is not favorite: Exclude")
        return false
    end

    if not professionInfo or not professionInfo.profession or not professionInfo.professionID then
        printF("ProfessionInfo missing information: Exclude")
        return false
    end

    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(professionInfo.professionID)
    local includedExpansions = CraftSim.DB.OPTIONS:Get("RECIPESCAN_FILTERED_EXPANSIONS")
    local expansionEnabled = includedExpansions[expansionID] ~= false

    if not expansionEnabled then
        printF("Expansion filtered: Exclude (expansionID: " .. tostring(expansionID) .. ")")
        return false
    end

    local filteredCategories = CraftSim.DB.OPTIONS:Get("RECIPESCAN_FILTERED_CATEGORIES")
    local crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, professionInfo.profession)
    local expansionCategoryFilter = filteredCategories and filteredCategories[crafterProfessionUID]
        and filteredCategories[crafterProfessionUID][expansionID] or nil

    local categoryIncluded = true
    if expansionCategoryFilter and recipeInfo.categoryID then
        if expansionCategoryFilter[recipeInfo.categoryID] == false then
            printF("Category filtered: Exclude (categoryID: " .. tostring(recipeInfo.categoryID) .. ")")
            categoryIncluded = false
        end
    end

    if categoryIncluded and recipeInfo.isEnchantingRecipe then
        local baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeInfo.recipeID, {}, nil, false)
        if not baseOperationInfo then return false end
        local enchantData = CraftSim.ENCHANT_RECIPE_DATA[baseOperationInfo.craftingDataID]
        if enchantData then
            if enchantData.noOutputTinker then
                printF("Is noOutputTinker: Exclude")
                return false
            end
            printF(GUTIL:ColorizeText("Include", GUTIL.COLORS.GREEN))
            return true
        end

        printF("Missing Enchant Data: " .. tostring(recipeInfo.recipeID))
        pcall(function()
            error("CraftSim Recipe Scan Error: Missing Enchanting Data for " ..
                tostring(recipeInfo.name) .. " (" .. tostring(recipeInfo.recipeID) .. ")\nPlease report to author!")
        end)
        return false
    end
    if categoryIncluded then
        if recipeInfo and not recipeInfo.isGatheringRecipe and not recipeInfo.isSalvageRecipe and not recipeInfo.isRecraft then
            if recipeInfo.hyperlink then
                local isGear = recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil
                local isSoulbound = GUTIL:isItemSoulbound(GUTIL:GetItemIDByLink(recipeInfo.hyperlink))
                if not CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_SOULBOUND") then
                    if isGear and isSoulbound then
                        printF("Is Gear+Soulbound: Exclude")
                        return false
                    end
                    if not CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_GEAR") and isGear then
                        printF("Is Gear: Exclude")
                        return false
                    end

                    if isSoulbound then
                        printF("Is Soulbound: Exclude")
                        return false
                    end
                end

                if not CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_GEAR") and isGear then
                    printF("Is Gear: Exclude")
                    return false
                end
                printF(GUTIL:ColorizeText("Include", GUTIL.COLORS.GREEN))
                return true
            end
            printF("Is Gathering/Salvage/Recraft: Exclude")
            return false
        end
    end
    printF("Expansion/Category filtered or non-craftable: Exclude (expansionID: " .. tostring(expansionID) .. ", categoryID: " .. tostring(recipeInfo.categoryID) .. ")")
    return false
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@return TradeSkillRecipeInfo[]
function CraftSim.RECIPE_SCAN:GetScanRecipeInfo(row)
    local playerCrafterProfessionUID = CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID()
    if row.crafterProfessionUID == playerCrafterProfessionUID then
        local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
        printF("Total RecipeIDs: " .. #recipeIDs)
        return GUTIL:Map(recipeIDs, function(recipeID)
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            if CraftSim.RECIPE_SCAN.FilterRecipeInfo(row.crafterUID, recipeInfo) then
                return recipeInfo
            end
            return nil
        end)
    end
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(row.crafterUID, row.profession) or {}

    return GUTIL:Map(cachedRecipeIDs, function(recipeID)
        local recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(row.crafterUID, recipeID)
        if CraftSim.RECIPE_SCAN.FilterRecipeInfo(row.crafterUID, recipeInfo) then
            return recipeInfo
        end
        return nil
    end)
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:ScanRow(row)
    wipe(row.currentResults)
    CraftSim.RECIPE_SCAN.isScanning = true

    printS("Start Scan for: " .. tostring(row.crafterProfessionUID))

    local recipeInfos = CraftSim.RECIPE_SCAN:GetScanRecipeInfo(row)
    printS("Scanning " .. tostring(#recipeInfos) .. " Recipes")

    CraftSim.RECIPE_SCAN:ToggleScanButton(row, false)
    CraftSim.RECIPE_SCAN.UI:ResetResults(row)

    local OPT_ID = CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.RECIPESCAN_SCAN
    local KEYS   = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
    local FA     = CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM
    local optimizeGear = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_PROFESSION_TOOLS, false)
    local concentrationEnabled = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.ENABLE_CONCENTRATION, true)
    local optimizeSubRecipes = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_SUBRECIPES")
    local optimizeConcentration = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_CONCENTRATION, false)
    local optimizeTopProfit = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.AUTOSELECT_TOP_PROFIT_QUALITY, false)
    local optimizeFinishingReagents = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.OPTIMIZE_FINISHING_REAGENTS, false)
    local finishingAlgorithm = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.FINISHING_REAGENTS_ALGORITHM, FA.SIMPLE)
    local reagentAllocation = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.REAGENT_ALLOCATION, CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE)
    local optimizationScanMode = reagentAllocation == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE

    CraftSim.DEBUG:StartProfiling("Total Recipe Scan")

    CraftSim.RECIPE_SCAN.rowScanFrameDistributor = GUTIL.FrameDistributor {
        iterationTable = recipeInfos,
        iterationsPerFrame = 1,
        finally = function()
            CraftSim.RECIPE_SCAN:EndScan(row)
        end,
        continue = function(frameDistributor, recipeInfoIndex, recipeInfo, _, progress)
            local crafterData = row.crafterData
            local content = row.content

            CraftSim.DEBUG:StartProfiling("Single Recipe Scan")

            content.scanButton:SetText(CraftSim.LOCAL:GetText("RECIPE_SCAN_SCANNING") ..
                string.format(" %.0f%%", progress))
            content.resultAmount:SetText(recipeInfoIndex .. "/" .. #recipeInfos)

            ---@cast recipeInfo TradeSkillRecipeInfo
            printS("Scanning Recipe: " .. tostring(recipeInfo.name))

            local recipeData = CraftSim.RecipeData({ recipeID = recipeInfo.recipeID, crafterData = crafterData });

            if not recipeData then
                printS("No RecipeData created: End Scan")
                frameDistributor:Break()
                return
            end

            local function finalizeRecipeAndContinue()
                GUTIL:ContinueOnAllItemsLoaded(recipeData.resultData.itemsByQuality, function()
                    CraftSim.DEBUG:StopProfiling("Single Recipe Scan")

                    local profitMarginThreshold = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_PROFIT_MARGIN_THRESHOLD")
                    if profitMarginThreshold > 0 then
                        local relativeProfit = recipeData.relativeProfitCached or 0
                        if relativeProfit < profitMarginThreshold then
                            printS("Recipe filtered by profit margin: " .. tostring(recipeInfo.recipeID))
                            frameDistributor:Continue()
                            return
                        end
                    end

                    if TSM_API and recipeData.resultData and recipeData.resultData.expectedItem then
                        local tsmSaleRateThreshold = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_TSM_SALERATE_THRESHOLD")
                        if tsmSaleRateThreshold > 0 then
                            local resultSaleRate = CraftSimTSM:GetItemSaleRate(recipeData.resultData.expectedItem:GetItemLink())
                            if resultSaleRate < tsmSaleRateThreshold then
                                printS("Recipe filtered by TSM sale rate: " .. tostring(recipeInfo.recipeID))
                                frameDistributor:Continue()
                                return
                            end
                        end
                    end

                    CraftSim.RECIPE_SCAN.UI:AddRecipe(row, recipeData)

                    table.insert(row.currentResults, recipeData)

                    if CraftSim.DB.OPTIONS:Get("RECIPESCAN_UPDATE_LAST_CRAFTING_COST") then
                        CraftSim.DB.LAST_CRAFTING_COST:Save(recipeData)
                    end

                    printS("Continue Scan..")

                    frameDistributor:Continue()
                end)
            end

            recipeData.professionGearSet:LoadCurrentEquippedSet()

            if not optimizationScanMode then
                CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
            end

            recipeData:Update()

            if recipeData.supportsQualities and concentrationEnabled then
                recipeData.concentrating = true
                recipeData:Update()
            end

            local optimizeFinishingReagentOptions = nil

            if optimizeFinishingReagents then
                optimizeFinishingReagentOptions = {
                    includeLocked = false,
                    includeSoulbound = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.INCLUDE_SOULBOUND_FINISHING_REAGENTS, false),
                    onlyHighestQualitySoulbound = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(OPT_ID, KEYS.ONLY_HIGHEST_QUALITY_SOULBOUND_FINISHING_REAGENTS, false),
                    permutationBased = finishingAlgorithm == FA.PERMUTATION,
                    progressUpdateCallback = function(progress)
                    content.optimizationProgressStatusText:SetText(string.format("%.0f%%", progress) ..
                        " " ..
                        GUTIL:IconToText(recipeData.recipeIcon, 20, 20) ..
                        CreateAtlasMarkup("Banker", 20, 20))
                end
                }
            end

            recipeData:Optimize {
                finally = function()
                    finalizeRecipeAndContinue()
                    content.optimizationProgressStatusText:SetText("")
                end,
                optimizeConcentration = concentrationEnabled and optimizeConcentration,
                optimizeFinishingReagentsOptions = optimizeFinishingReagentOptions,
                optimizeGear = optimizeGear,
                optimizeReagentOptions = optimizationScanMode and {
                    highestProfit = optimizeTopProfit,
                },
                optimizeReagentProgressCallback = function(progress)
                end,
                optimizeConcentrationProgressCallback = function(progress)
                    content.optimizationProgressStatusText:SetText(string.format("%.0f%%", progress) ..
                        " " .. GUTIL:IconToText(recipeData.recipeIcon, 20, 20) ..
                        GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20))
                end,
                optimizeSubRecipesOptions = optimizeSubRecipes,
            }
        end,
        cancel = function()
            return not CraftSim.RECIPE_SCAN.isScanning
        end
    }:Continue()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
    local KEYS    = CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS
    local scanMode = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(
        CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.RECIPESCAN_SCAN,
        KEYS.REAGENT_ALLOCATION,
        CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE)
    if scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q1 then
        recipeData.reagentData:SetReagentsMaxByQuality(1)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q2 then
        recipeData.reagentData:SetReagentsMaxByQuality(2)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q3 then
        if recipeData:IsSimplifiedQualityRecipe() then
            recipeData.reagentData:SetReagentsMaxByQuality(2)
        else
            recipeData.reagentData:SetReagentsMaxByQuality(3)
        end
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE then
        recipeData:OptimizeReagents()
    end
end

---@param crafterUID string -  <name>-<NormalizedRealm>
---@param profession Enum.Profession
---@return string crafterProfessionUID <Name>-<NormalizedRealm>:<ProfessionID>
function CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)
    return tostring(crafterUID) .. ":" .. tostring(profession)
end

function CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID()
    local currentProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
    if currentProfessionInfo then
        return self:GetCrafterProfessionUID(CraftSim.UTIL:GetPlayerCrafterUID(), currentProfessionInfo.profession)
    end
    return ""
end

--- called everytime recipeScan is shown
function CraftSim.RECIPE_SCAN:UpdateProfessionListByCache()
    local professionInfoAtCall = C_TradeSkillUI.GetBaseProfessionInfo()
    local professionUIDAtCall = professionInfoAtCall and
        CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(CraftSim.UTIL:GetPlayerCrafterUID(), professionInfoAtCall.profession) or ""

    local function update()
        local professionChanged = CraftSim.RECIPE_SCAN.lastOpenProfessionUID ~= nil and
            CraftSim.RECIPE_SCAN.lastOpenProfessionUID ~= professionUIDAtCall
        CraftSim.RECIPE_SCAN.lastOpenProfessionUID = professionUIDAtCall
        CraftSim.RECIPE_SCAN.UI:UpdateProfessionList(professionChanged)
    end

    GUTIL:WaitFor(function()
        local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
        local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
        local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(playerCrafterUID, professionInfo.profession)
        return cachedRecipeIDs ~= nil
    end, update)
end

CraftSim.RECIPE_SCAN.currentScanProfessionRow = 0
function CraftSim.RECIPE_SCAN:ScanProfessions()
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList
    local activeRows = professionList.activeRows

    if #activeRows <= 0 then return end

    CraftSim.RECIPE_SCAN.currentScanProfessionRow = 0
    CraftSim.RECIPE_SCAN.isScanningProfessions = true
    professionList:SetSelectionEnabled(false)

    CraftSim.RECIPE_SCAN:ScanNextProfessionRow()
end

function CraftSim.RECIPE_SCAN:UpdateScanProfessionsButtons()
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
    local scanProfessionsButton = content.scanProfessionsButton
    local cancelButton = content.cancelScanProfessionsButton

    if CraftSim.RECIPE_SCAN.isScanningProfessions then
        scanProfessionsButton:SetStatus("Scanning")
        cancelButton:Show()
    else
        scanProfessionsButton:SetStatus("Ready")
        cancelButton:Hide()
    end
end

function CraftSim.RECIPE_SCAN:ScanNextProfessionRow()
    CraftSim.RECIPE_SCAN.currentScanProfessionRow = CraftSim.RECIPE_SCAN.currentScanProfessionRow + 1
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList
    local activeRows = professionList.activeRows

    local nextRow = activeRows[CraftSim.RECIPE_SCAN.currentScanProfessionRow]
    if not nextRow then
        CraftSim.RECIPE_SCAN:EndProfessionScan()
        return
    end

    local checkBoxColumn = nextRow.columns[1]

    if not checkBoxColumn.checkbox:GetChecked() then
        CraftSim.RECIPE_SCAN:ScanNextProfessionRow()
        return
    end

    CraftSim.RECIPE_SCAN:UpdateScanProfessionsButtons()

    nextRow:Select()
    CraftSim.RECIPE_SCAN:ScanRow(nextRow)
end

function CraftSim.RECIPE_SCAN:EndProfessionScan()
    CraftSim.RECIPE_SCAN.currentScanProfessionRow = 0
    CraftSim.RECIPE_SCAN.isScanningProfessions = false
    CraftSim.RECIPE_SCAN:UpdateScanProfessionsButtons()

    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList
    professionList:SetSelectionEnabled(true)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN:SendToCraftQueue()
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList
    local activeRows = professionList.activeRows

    if #activeRows <= 0 then return end

    local selectedRow = professionList.selectedRow

    if not selectedRow then
        return
    end

    local results = selectedRow.currentResults

    if #results == 0 then
        return
    end

    local filteredResults = GUTIL:Filter(results, function(recipeData)
        local marginThreshold = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_PROFIT_MARGIN_THRESHOLD")
        local relativeProfit = recipeData.relativeProfitCached
        return relativeProfit >= marginThreshold;
    end)

    if CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_CREATE_CRAFT_LIST") then
        CraftSim.CRAFTQ.UI:ShowCraftListNamePopup(
            L("CRAFT_LISTS_CREATE_POPUP_TITLE"),
            L("CRAFT_LISTS_NEW_LIST_DEFAULT_NAME"),
            false,
            function(name, isGlobal)
                if not name or name == "" then return end
                local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
                local newList = CraftSim.DB.CRAFT_LISTS:CreateList(name, isGlobal, crafterUID)
                for _, recipeData in ipairs(filteredResults) do
                    CraftSim.DB.CRAFT_LISTS:AddRecipe(newList.id, newList.isGlobal, crafterUID, recipeData.recipeID)
                end
                CraftSim.CRAFTQ.UI:UpdateCraftListsDisplay()
            end)
        return
    end

    local sendToCraftQueueButton = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .sendToCraftQueueButton

    sendToCraftQueueButton:SetEnabled(false)

    local concentrationEnabled = CraftSim.DB.OPTIMIZATION_OPTIONS:Get(
        CraftSim.CONST.OPTIMIZATION_OPTIONS_IDS.RECIPESCAN_SCAN,
        CraftSim.WIDGETS.OptimizationOptions.OPTION_KEYS.ENABLE_CONCENTRATION,
        true)

    GUTIL.FrameDistributor {
        iterationTable = filteredResults,
        iterationsPerFrame = 5,
        finally = function()
            sendToCraftQueueButton:SetStatus("Ready")
        end,
        continue = function(frameDistributor, _, recipeData, _, progress)
            recipeData = recipeData
            sendToCraftQueueButton:SetText(string.format("%.0f%%", progress))

            if concentrationEnabled and recipeData.supportsQualities then
                recipeData.concentrating = true
                recipeData:Update()
            end

            if TSM_API and recipeData.resultData.expectedItem then
                local saleRateThreshold = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_TSM_SALERATE_THRESHOLD")
                local resultSaleRate = CraftSimTSM:GetItemSaleRate(recipeData.resultData.expectedItem:GetItemLink())

                if resultSaleRate < saleRateThreshold then
                    frameDistributor:Continue()
                    return
                end
            end

            local restockAmount = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_DEFAULT_QUEUE_AMOUNT") or 0

            if TSM_API and recipeData.resultData.expectedItem and CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_USE_TSM_RESTOCK_EXPRESSION") then
                local tsmItemString = TSM_API.ToItemString(recipeData.resultData.expectedItem:GetItemLink())
                restockAmount = TSM_API.GetCustomPriceValue(CraftSim.DB.OPTIONS:Get("TSM_RESTOCK_KEY_ITEMS"),
                    tsmItemString) or 0
            end

            if CraftSimTSM:IsAvailable() and CraftSim.DB.OPTIONS:Get("TSM_SMART_RESTOCK_ENABLED") then
                local _, _, owned = CraftSimTSM:GetSmartRestockAmount(recipeData)
                restockAmount = math.max(0, restockAmount - owned)
            end

            if recipeData.cooldownData.isCooldownRecipe == true and recipeData.cooldownData.currentCharges < restockAmount then
                restockAmount = recipeData.cooldownData.currentCharges
            end

            if restockAmount >=1 then
                -- Ajouter les précrafts récursivement
                local queue = {}
                local shoppingList = {}
                AddPrecraftsToQueue(recipeData, restockAmount, queue, shoppingList, {})

                -- Ajouter la recette finale à la fin de la file
                table.insert(queue, {
                    recipeData = recipeData,
                    amount = restockAmount,
                })

                -- Ajouter les recettes à la file d'attente de CraftSim
                for _, entry in ipairs(queue) do
                    CraftSim.CRAFTQ:AddRecipe({ recipeData = entry.recipeData, amount = entry.amount })
                end
            end

            frameDistributor:Continue()
        end
    }:Continue()
end
