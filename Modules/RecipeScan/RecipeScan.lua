---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.RECIPE_SCAN
CraftSim.RECIPE_SCAN = {}

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

CraftSim.RECIPE_SCAN.frame = nil
CraftSim.RECIPE_SCAN.isScanning = false
CraftSim.RECIPE_SCAN.isScanningProfessions = false

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
---@type table<CraftSim.RecipeScanModes, CraftSim.LOCALIZATION_IDS>
CraftSim.RECIPE_SCAN.SCAN_MODES_TRANSLATION_MAP = {
    Q1 = CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q1,
    Q2 = CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q2,
    Q3 = CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q3,
    OPTIMIZE = CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE,
}

---@enum CraftSim.RecipeScanSortModes
CraftSim.RECIPE_SCAN.SORT_MODES = {
    PROFIT = "PROFIT",
    RELATIVE_PROFIT = "RELATIVE_PROFIT",
    CONCENTRATION_VALUE = "CONCENTRATION_VALUE",
    CONCENTRATION_COST = "CONCENTRATION_COST",
}

CraftSim.RECIPE_SCAN.SORT_MODES_TRANSLATION_MAP = {
    PROFIT = CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT,
    RELATIVE_PROFIT = CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT,
    CONCENTRATION_VALUE = CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE,
    CONCENTRATION_COST = CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST,
}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)
local printF = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN_FILTER)
local printS = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN_SCAN)

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:ToggleScanButton(row, value)
    local content = row.content
    content.scanButton:SetEnabled(value)
    content.cancelScanButton:SetVisible(not value)
    if not value then
        content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING) .. " 0%")
    else
        content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES))
    end

    -- if within professionscan always hide the cancel button in the scanning row
    if CraftSim.RECIPE_SCAN.isScanningProfessions then
        content.cancelScanButton:Hide()
    end
end

---@return fun(a: any, b: any) : boolean
function CraftSim.RECIPE_SCAN:GetSortFunction()
    local sortFuncMap = {
        [CraftSim.RECIPE_SCAN.SORT_MODES.PROFIT] = function(a, b)
            return a.averageProfit > b.averageProfit
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.RELATIVE_PROFIT] = function(a, b)
            return a.relativeProfit > b.relativeProfit
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_COST] = function(a, b)
            return a.concentrationCost < b.concentrationCost
        end,
        [CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_VALUE] = function(a, b)
            return a.concentrationWeight > b.concentrationWeight
        end,
    }
    return sortFuncMap[CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE")]
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:EndScan(row)
    printS("scan finished")
    collectgarbage("collect") -- By Option?
    CraftSim.RECIPE_SCAN:ToggleScanButton(row, true)
    CraftSim.RECIPE_SCAN.isScanning = false

    CraftSim.CRAFTQ.UI:UpdateRecipeScanRestockButton(row.currentResults)

    local resultList = row.content.resultList
    resultList:UpdateDisplay(self:GetSortFunction())

    if CraftSim.RECIPE_SCAN.isScanningProfessions then
        CraftSim.RECIPE_SCAN:ScanNextProfessionRow()
    end
end

function CraftSim.RECIPE_SCAN:CancelProfessionScan()
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList --[[@as GGUI.FrameList]]

    local scanRow = professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
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
    if CraftSim.DB.OPTIONS:Get("RECIPESCAN_ONLY_FAVORITES") and not recipeInfo.favorite then
        printF("Is not favorite: Exclude")
        return false
    end

    -- use cache if available for performance
    local professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeInfo.recipeID)

    if not professionInfo then
        printF("professionInfo not Cached: Get from Api")
        professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeInfo.recipeID)
    end

    -- if recipe does not have any profession info, exclude recipe
    -- it seems some pandaren recipes may not have this info such as C_TradeSkillUI.GetProfessionInfoByRecipeID(381364)
    if not professionInfo or not professionInfo.profession or not professionInfo.professionID then
        printF("ProfessionInfo missing information: Exclude")
        return false
    end

    local includedExpansions = {}
    for expansionID, included in pairs(CraftSim.DB.OPTIONS:Get("RECIPESCAN_FILTERED_EXPANSIONS")) do
        if included then
            table.insert(includedExpansions, expansionID)
        end
    end

    local recipeExpansionIncluded = GUTIL:Some(includedExpansions, function(expansionID)
        local skillLineID = CraftSim.CONST.TRADESKILLLINEIDS[professionInfo.profession][expansionID]
        return professionInfo.professionID == skillLineID
    end)

    if recipeExpansionIncluded and recipeInfo.isEnchantingRecipe then
        local baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeInfo.recipeID, {}, nil, false)
        if not baseOperationInfo then return false end
        -- except if its a tinker with no output
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
        -- filter out but throw error async to not stop
        pcall(function()
            error("CraftSim Recipe Scan Error: Missing Enchanting Data for " ..
                tostring(recipeInfo.name) .. " (" .. tostring(recipeInfo.recipeID) .. ")\nPlease report to author!")
        end)
        return false
    end
    if recipeExpansionIncluded then
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
    printF("Is not expansion: Exclude (ExpacID: " .. tostring(expansionID) .. ")")
    return false
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@return TradeSkillRecipeInfo[]
function CraftSim.RECIPE_SCAN:GetScanRecipeInfo(row)
    local playerCrafterProfessionUID = CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID()
    -- if its the currently open profession we can just take it directly
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
    -- else take the infos from db
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(row.crafterUID, row.profession)

    return GUTIL:Map(cachedRecipeIDs, function(recipeID)
        -- also take from db
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

    local optimizeGear = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS")
    local concentrationEnabled = CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION")
    local optimizeSubRecipes = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_SUBRECIPES")
    local optimizeConcentration = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_CONCENTRATION_VALUE")
    local optimizeTopProfit = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_REAGENTS_TOP_PROFIT")
    local optimizeFinishingReagents = CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_FINISHING_REAGENTS")
    local optimizationScanMode = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE") ==
        CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE

    local optimizationTaskList = {
        optimizeGear and "GEAR",
        "REAGENTS",
        concentrationEnabled and optimizeConcentration and "CONCENTRATION",
        optimizeFinishingReagents and "FINISHING_REAGENTS",
        optimizeSubRecipes and "SUB_RECIPES",
    }

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

            -- update button
            content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING) ..
                string.format(" %.0f%%", progress))
            content.resultAmount:SetText(recipeInfoIndex .. "/" .. #recipeInfos)

            local recipeData = CraftSim.RecipeData({ recipeID = recipeInfo.recipeID, crafterData = crafterData });

            if not recipeData then
                printS("No RecipeData created: End Scan")
                frameDistributor:Break()
                return
            end

            local function finalizeRecipeAndContinue()
                -- since the result links are needed for calculations and probably not loaded within a scan
                GUTIL:ContinueOnAllItemsLoaded(recipeData.resultData.itemsByQuality, function()
                    CraftSim.DEBUG:StopProfiling("Single Recipe Scan")
                    CraftSim.RECIPE_SCAN.UI:AddRecipe(row, recipeData)

                    table.insert(row.currentResults, recipeData)

                    printS("Continue Scan..")

                    frameDistributor:Continue()
                end)
            end

            recipeData.professionGearSet:LoadCurrentEquippedSet()
            recipeData:Update()

            if recipeData.supportsQualities and concentrationEnabled then
                recipeData.concentrating = true
                recipeData:Update()
            end

            GUTIL.FrameDistributor {
                iterationTable = optimizationTaskList,
                finally = function()
                    finalizeRecipeAndContinue()
                end,
                continue = function(frameDistributorTasks, _, optimizationTask, _, _)
                    if optimizationTask == "GEAR" then
                        recipeData:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
                        frameDistributorTasks:Continue()
                    elseif optimizationTask == "REAGENTS" then
                        if optimizationScanMode then
                            recipeData:OptimizeReagents {
                                highestProfit = optimizeTopProfit,
                                maxQuality = math.max(recipeData.maxQuality or 1, 1)
                            }
                        else
                            CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
                        end
                        frameDistributorTasks:Continue()
                    elseif optimizationTask == "CONCENTRATION" then
                        if recipeData.supportsQualities then
                            printS("Optimize Concentration Value")
                            recipeData:OptimizeConcentration {
                                finally = function()
                                    frameDistributorTasks:Continue()
                                    content.optimizationProgressStatusText:SetText("")
                                end,
                                progressUpdateCallback = function(progress)
                                    content.optimizationProgressStatusText:SetText(string.format("%.0f%%", progress) ..
                                        " " .. GUTIL:IconToText(recipeData.recipeIcon, 20, 20) ..
                                        GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20))
                                end
                            }
                        else
                            frameDistributorTasks:Continue()
                        end
                    elseif optimizationTask == "FINISHING_REAGENTS" then
                        recipeData:OptimizeFinishingReagents {
                            finally = function()
                                frameDistributorTasks:Continue()
                                content.optimizationProgressStatusText:SetText("")
                            end,
                            progressUpdateCallback = function(progress)
                                content.optimizationProgressStatusText:SetText(string.format("%.0f%%", progress) ..
                                    " " ..
                                    GUTIL:IconToText(recipeData.recipeIcon, 20, 20) ..
                                    CreateAtlasMarkup("Banker", 20, 20))
                            end
                        }
                    elseif optimizationTask == "SUB_RECIPES" then
                        recipeData:SetSubRecipeCostsUsage(true)
                        recipeData:OptimizeSubRecipes({
                            optimizeGear = optimizeGear,
                            optimizeReagentOptions = {
                                highestProfit = false,
                                maxQuality = recipeData.maxQuality,
                            },
                        })
                        frameDistributorTasks:Continue()
                    else
                        frameDistributorTasks:Continue()
                    end
                end
            }:Continue()
        end,
        cancel = function()
            return not CraftSim.RECIPE_SCAN.isScanning
        end
    }:Continue()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
    local scanMode = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE")
    if scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q1 then
        recipeData.reagentData:SetReagentsMaxByQuality(1)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q2 then
        recipeData.reagentData:SetReagentsMaxByQuality(2)
    elseif scanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q3 then
        recipeData.reagentData:SetReagentsMaxByQuality(3)
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
    local currentProfessionInfo = C_TradeSkillUI
        .GetBaseProfessionInfo()
    if currentProfessionInfo then
        return self:GetCrafterProfessionUID(CraftSim.UTIL:GetPlayerCrafterUID(),
            currentProfessionInfo.profession)
    end
    return ""
end

--- called everytime recipeScan is shown
function CraftSim.RECIPE_SCAN:UpdateProfessionListByCache()
    -- wait til the currently open profession is cached then update list

    local function update()
        CraftSim.RECIPE_SCAN.UI:UpdateProfessionList()
    end

    GUTIL:WaitFor(function()
        local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
        local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
        local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(playerCrafterUID, professionInfo.profession)
        return cachedRecipeIDs ~= nil
    end, update)
end

-- ALL OF THE PROFESSIONS #meme

CraftSim.RECIPE_SCAN.currentScanProfessionRow = 0
function CraftSim.RECIPE_SCAN:ScanProfessions()
    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList --[[@as GGUI.FrameList]]
    local activeRows = professionList.activeRows --[[@as table<number, CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW>]]

    if #activeRows <= 0 then return end

    -- for each row, select it,  scan, then go to next -> async!
    CraftSim.RECIPE_SCAN.currentScanProfessionRow = 0
    CraftSim.RECIPE_SCAN.isScanningProfessions = true
    professionList:SetSelectionEnabled(false)

    CraftSim.RECIPE_SCAN:ScanNextProfessionRow()
end

function CraftSim.RECIPE_SCAN:UpdateScanProfessionsButtons()
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
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
        .professionList --[[@as GGUI.FrameList]]
    local activeRows = professionList.activeRows --[[@as table<number, CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW>]]

    local nextRow = activeRows[CraftSim.RECIPE_SCAN.currentScanProfessionRow]
    if not nextRow then
        CraftSim.RECIPE_SCAN:EndProfessionScan()
        return
    end

    local checkBoxColumn = nextRow.columns[1] --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.CHECKBOX_COLUMN]]

    if not checkBoxColumn.checkbox:GetChecked() then
        CraftSim.RECIPE_SCAN:ScanNextProfessionRow() -- skip to next
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
        .professionList --[[@as GGUI.FrameList]]
    professionList:SetSelectionEnabled(true)
end
