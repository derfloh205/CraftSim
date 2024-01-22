---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.RECIPE_SCAN
CraftSim.RECIPE_SCAN = {}

local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()

CraftSim.RECIPE_SCAN.frame = nil
CraftSim.RECIPE_SCAN.isScanning = false
CraftSim.RECIPE_SCAN.isScanningProfessions = false

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

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)
local printF = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN_FILTER)
local printS = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN_SCAN)

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

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:UpdateScanPercent(row, currentProgress, maxProgress)
    local currentPercentage = GUTIL:Round(currentProgress / (maxProgress / 100))
    local content = row.content

    if currentPercentage % 1 == 0 then
        content.scanButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING) ..
            " " .. currentPercentage .. "%")
    end
    content.resultAmount:SetText(currentProgress .. "/" .. maxProgress)
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:EndScan(row)
    printS("scan finished")
    collectgarbage("collect") -- By Option?
    CraftSim.RECIPE_SCAN:ToggleScanButton(row, true)
    CraftSim.RECIPE_SCAN.isScanning = false

    CraftSim.CRAFTQ.FRAMES:UpdateRecipeScanRestockButton(row.currentResults)

    --sort scan results?
    local resultList = row.content.resultList
    if CraftSimOptions.recipeScanSortByProfitMargin then
        resultList:UpdateDisplay(function(rowA, rowB)
            return rowA.relativeProfit > rowB.relativeProfit
        end)
    else
        resultList:UpdateDisplay(function(rowA, rowB)
            return rowA.averageProfit > rowB.averageProfit
        end)
    end

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
    if not CraftSimOptions.recipeScanIncludeNotLearned and not recipeInfo.learned then
        printF("Is not learned: Exclude")
        return false
    end
    if tContains(CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS, recipeInfo.categoryID) then
        printF("Is Quest: Exclude")
        return false
    end
    if CraftSimOptions.recipeScanOnlyFavorites and not recipeInfo.favorite then
        printF("Is not favorite: Exclude")
        return false
    end

    -- use cache if available for performance
    local professionInfoCache = CraftSimRecipeDataCache.professionInfoCache[crafterUID] or {}
    local professionInfo = professionInfoCache[recipeInfo.recipeID]

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
    for expansionID, included in pairs(CraftSimOptions.recipeScanFilteredExpansions) do
        if included then
            table.insert(includedExpansions, expansionID)
        end
    end

    local recipeExpansionIncluded = GUTIL:Some(includedExpansions, function(expansionID)
        local skillLineID = CraftSim.CONST.TRADESKILLLINEIDS[professionInfo.profession][expansionID]
        return professionInfo.professionID == skillLineID
    end)

    if recipeExpansionIncluded and recipeInfo.isEnchantingRecipe then
        -- except if its a tinker with no output
        local enchantData = CraftSim.ENCHANT_RECIPE_DATA[recipeInfo.recipeID]
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
                if not CraftSimOptions.recipeScanIncludeSoulbound then
                    if isGear and isSoulbound then
                        printF("Is Gear+Soulbound: Exclude")
                        return false
                    end
                    if not CraftSimOptions.recipeScanIncludeGear and isGear then
                        printF("Is Gear: Exclude")
                        return false
                    end

                    if isSoulbound then
                        printF("Is Soulbound: Exclude")
                        return false
                    end
                end

                if not CraftSimOptions.recipeScanIncludeGear and isGear then
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
    printF("Is not expansion: Exclude")
    return false
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@return TradeSkillRecipeInfo[]
function CraftSim.RECIPE_SCAN:GetScanRecipeInfo(row)
    local playerCrafterProfessionUID = CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID()
    -- if its the currently open profession we can just take it directly
    if row.crafterProfessionUID == playerCrafterProfessionUID then
        return GUTIL:Map(C_TradeSkillUI.GetAllRecipeIDs(), function(recipeID)
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            if CraftSim.RECIPE_SCAN.FilterRecipeInfo(row.crafterUID, recipeInfo) then
                return recipeInfo
            end
            return nil
        end)
    end
    -- else take the infos from cache
    local cachedProfessions = CraftSimRecipeDataCache.cachedRecipeIDs[row.crafterUID] or {}
    local cachedRecipeIDs = cachedProfessions[row.profession] or {}

    return GUTIL:Map(cachedRecipeIDs, function(recipeID)
        -- also take from cache
        local recipeInfoCache = CraftSimRecipeDataCache.recipeInfoCache[row.crafterUID] or {}
        local recipeInfo = recipeInfoCache[recipeID]
        if CraftSim.RECIPE_SCAN.FilterRecipeInfo(row.crafterUID, recipeInfo) then
            return recipeInfo
        end
        return nil
    end)
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN:StartScan(row)
    wipe(row.currentResults)
    CraftSim.RECIPE_SCAN.isScanning = true

    printS("Start Scan for: " .. tostring(row.crafterProfessionUID))

    local recipeInfos = CraftSim.RECIPE_SCAN:GetScanRecipeInfo(row)
    printS("Scanning " .. tostring(#recipeInfos) .. " Recipes")
    local currentIndex = 1

    local function scanRecipesByInterval()
        -- check if scan was ended
        if not CraftSim.RECIPE_SCAN.isScanning then
            return
        end

        CraftSim.UTIL:StartProfiling("Single Recipe Scan")
        local recipeInfo = recipeInfos[currentIndex]
        local crafterData = row.crafterData
        if not recipeInfo then
            CraftSim.RECIPE_SCAN:EndScan(row)
            return
        end

        CraftSim.RECIPE_SCAN:UpdateScanPercent(row, currentIndex, #recipeInfos)

        printS("recipeID: " .. tostring(recipeInfo.recipeID), false, true)
        printS("recipeName: " .. tostring(recipeInfo.name))
        printS("isEnchant: " .. tostring(recipeInfo.isEnchantingRecipe))

        --- @type CraftSim.RecipeData
        local recipeData = CraftSim.RecipeData(recipeInfo.recipeID, nil, nil, crafterData);

        if recipeData.reagentData:HasOptionalReagents() and CraftSimOptions.recipeScanUseInsight then
            recipeData:SetOptionalReagent(CraftSim.CONST.ITEM_IDS.OPTIONAL_REAGENTS.ILLUSTRIOUS_INSIGHT)
            recipeData:SetOptionalReagent(CraftSim.CONST.ITEM_IDS.OPTIONAL_REAGENTS.LESSER_ILLUSTRIOUS_INSIGHT)
        end

        recipeData.professionGearSet:LoadCurrentEquippedSet()
        recipeData:Update()
        if not recipeData then
            printS("No RecipeData created: End Scan")
            CraftSim.RECIPE_SCAN:EndScan(row)
            return
        end

        --optimize top gear first cause optimized reagents might change depending on the gear
        if CraftSimOptions.recipeScanOptimizeProfessionTools then
            printS("Optimizing Gear...")
            CraftSim.UTIL:StartProfiling("Optimize ALL: SCAN")
            if CraftSimOptions.recipeScanScanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE then
                recipeData:OptimizeProfit()
            else
                CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
                recipeData:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
            end
            CraftSim.UTIL:StopProfiling("Optimize ALL: SCAN")
        else
            CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
        end

        local function continueScan()
            CraftSim.UTIL:StopProfiling("Single Recipe Scan")
            CraftSim.RECIPE_SCAN.FRAMES:AddRecipe(row, recipeData)

            table.insert(row.currentResults, recipeData)

            currentIndex = currentIndex + 1
            RunNextFrame(scanRecipesByInterval)
        end
        -- since the result links are needed for calculations and probably not loaded within a scan
        GUTIL:ContinueOnAllItemsLoaded(recipeData.resultData.itemsByQuality, continueScan)
    end

    printS("End Scan")
    CraftSim.RECIPE_SCAN:ToggleScanButton(row, false)
    CraftSim.RECIPE_SCAN.FRAMES:ResetResults(row)
    scanRecipesByInterval()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN:SetReagentsByScanMode(recipeData)
    if CraftSimOptions.recipeScanScanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q1 then
        recipeData.reagentData:SetReagentsMaxByQuality(1)
    elseif CraftSimOptions.recipeScanScanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q2 then
        recipeData.reagentData:SetReagentsMaxByQuality(2)
    elseif CraftSimOptions.recipeScanScanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.Q3 then
        recipeData.reagentData:SetReagentsMaxByQuality(3)
    elseif CraftSimOptions.recipeScanScanMode == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE then
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
        CraftSim.RECIPE_SCAN.FRAMES:UpdateProfessionList()
    end

    GUTIL:WaitFor(function()
        local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
        local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
        CraftSimRecipeDataCache.cachedRecipeIDs[playerCrafterUID] = CraftSimRecipeDataCache.cachedRecipeIDs
            [playerCrafterUID] or {}
        return CraftSimRecipeDataCache.cachedRecipeIDs[playerCrafterUID][professionInfo.profession] ~= nil
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
    CraftSim.RECIPE_SCAN:StartScan(nextRow)
end

function CraftSim.RECIPE_SCAN:EndProfessionScan()
    CraftSim.RECIPE_SCAN.currentScanProfessionRow = 0
    CraftSim.RECIPE_SCAN.isScanningProfessions = false
    CraftSim.RECIPE_SCAN:UpdateScanProfessionsButtons()

    local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
        .professionList --[[@as GGUI.FrameList]]
    professionList:SetSelectionEnabled(true)
end
