---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.KNOWLEDGE_POINT_VALUE.UI
CraftSim.KNOWLEDGE_POINT_VALUE.UI = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.SpecializationInfo.KnowledgePointValue.UI")

--- Returns the optimizeContent sub-frame of the appropriate SpecInfo frame.
local function GetOptimizeContent()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local frameID = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER
        and CraftSim.CONST.FRAMES.SPEC_INFO_WO
        or  CraftSim.CONST.FRAMES.SPEC_INFO
    local specFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, frameID)
    return specFrame and specFrame.content and specFrame.content.optimizeContent or nil
end

--- Update the knowledge point value display for the given recipe (single-recipe mode).
---@param recipeData CraftSim.RecipeData
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:UpdateDisplay(recipeData)
    local content = GetOptimizeContent()
    if not content then return end

    content.nodeList:Remove()

    if not recipeData.specializationData or not recipeData.supportsCraftingStats then
        content.modeText:SetText(f.l("No specialization data available"))
        content.summaryText:SetText("")
        content.nodeList:UpdateDisplay()
        return
    end

    local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
    local ptsText = availPts > 0 and (" - " .. GUTIL:ColorizeText(tostring(availPts), GUTIL.COLORS.GREEN) .. " pts") or ""
    content.modeText:SetText(f.l("Single Recipe Value") .. ptsText)

    -- Pre-fill the KP input with detected available points
    if availPts > 0 then
        content.pointsInput.textInput:SetText(tostring(availPts))
    end

    -- Show saved weekly plan summary if available
    local plan = CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedWeeklyPlan(recipeData)
    if plan and plan.totalGain > 0 and plan.topNodeName then
        local age = time() - (plan.savedAt or 0)
        local ageText = ""
        if age < 3600 then
            ageText = math.floor(age / 60) .. "m ago"
        elseif age < 86400 then
            ageText = math.floor(age / 3600) .. "h ago"
        else
            ageText = math.floor(age / 86400) .. "d ago"
        end
        content.summaryText:SetText(
            CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
            "Plan: " .. CraftSim.UTIL:FormatMoney(plan.totalGain, true) ..
            " from " .. plan.availablePoints .. " pts" ..
            "  " .. GUTIL:ColorizeText("(" .. ageText .. ")", GUTIL.COLORS.GREY))
    else
        content.summaryText:SetText("")
    end

    CraftSim.DEBUG:StartProfiling("KnowledgePointValue.SingleRecipe")
    local results = CraftSim.KNOWLEDGE_POINT_VALUE:CalculateForRecipe(recipeData)
    CraftSim.DEBUG:StopProfiling("KnowledgePointValue.SingleRecipe")

    self:PopulateNodeList(content, results)
end

--- Populate the frame list with node ROI results.
---@param content Frame  the optimizeContent sub-frame
---@param results CraftSim.KnowledgePointValue.NodeResult[]|CraftSim.KnowledgePointValue.FullScanResult[]
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:PopulateNodeList(content, results)
    content.nodeList:Remove()

    -- Determine ROI range for heatmap normalization
    local maxROI, minROI = 0, 0
    for _, result in ipairs(results) do
        local roi = result.roiPerPoint or 0
        if roi > maxROI then maxROI = roi end
        if roi < minROI then minROI = roi end
    end
    local roiRange = math.max(maxROI, math.abs(minROI), 1) -- avoid division by zero

    for i, result in ipairs(results) do
        content.nodeList:Add(function(row)
            local columns = row.columns
            local nameCol = columns[1]
            local rankCol = columns[2]
            local roiCol  = columns[3]

            if result.nodeIcon then
                nameCol.icon:SetTexture(result.nodeIcon)
                nameCol.icon:Show()
            else
                nameCol.icon:Hide()
            end

            -- "Next Best" badge on first positive-ROI row
            local prefix = ""
            if i == 1 and result.roiPerPoint > 0 then
                prefix = CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " "
            end

            -- PathStep results (from Optimize) have a step field
            if result.step then
                nameCol.text:SetText(prefix .. GUTIL:ColorizeText("#" .. result.step, GUTIL.COLORS.WHITE) ..
                    " " .. (result.nodeName or ""))
                rankCol.text:SetText(math.max(0, result.rankBefore) .. "->" .. math.max(0, result.rankAfter) .. "/" .. result.maxRank)
            else
                nameCol.text:SetText(prefix .. (result.nodeName or ("Node " .. result.nodeID)))
                rankCol.text:SetText(tostring(math.max(0, result.currentRank)) .. "/" .. tostring(result.maxRank))
            end

            -- Color-code ROI
            local roiText
            if result.roiPerPoint > 0 then
                roiText = GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(result.roiPerPoint, false), GUTIL.COLORS.GREEN)
            elseif result.roiPerPoint < 0 then
                roiText = GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(result.roiPerPoint, false), GUTIL.COLORS.RED)
            else
                roiText = CraftSim.UTIL:FormatMoney(0, false)
            end
            roiCol.text:SetText(roiText)

            -- ROI heatmap background color
            local rowFrame = nameCol:GetParent()
            if rowFrame.roiBg then
                local roi = result.roiPerPoint or 0
                if roi > 0 then
                    local t = math.min(roi / roiRange, 1)
                    rowFrame.roiBg:SetVertexColor(0, 0.8, 0, 1)
                    rowFrame.roiBg:SetAlpha(0.08 + t * 0.17)
                elseif roi < 0 then
                    local t = math.min(math.abs(roi) / roiRange, 1)
                    rowFrame.roiBg:SetVertexColor(0.8, 0, 0, 1)
                    rowFrame.roiBg:SetAlpha(0.08 + t * 0.17)
                else
                    rowFrame.roiBg:SetAlpha(0)
                end
            end

            row.tooltipOptions = {
                text = self:BuildRowTooltip(result),
                anchor = "ANCHOR_CURSOR",
            }
        end)
    end

    content.nodeList:UpdateDisplay()
end

--- Build a tooltip string for a node ROI row.
---@param result CraftSim.KnowledgePointValue.NodeResult|CraftSim.KnowledgePointValue.FullScanResult
---@return string
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:BuildRowTooltip(result)
    local lines = {}

    if result.step then
        tinsert(lines, f.bb("Step #" .. result.step .. ": " .. (result.nodeName or "")))
        tinsert(lines, "Rank: " .. math.max(0, result.rankBefore) .. " -> " .. math.max(0, result.rankAfter) .. " / " .. result.maxRank)
        tinsert(lines, "")
        tinsert(lines, f.l("ROI this step: ") .. CraftSim.UTIL:FormatMoney(result.roiPerPoint, true))
        tinsert(lines, f.l("Cumulative ROI: ") .. CraftSim.UTIL:FormatMoney(result.cumulativeROI, true))
    else
        tinsert(lines, f.bb(result.nodeName or ("Node " .. result.nodeID)))
        tinsert(lines, "Rank: " .. math.max(0, result.currentRank) .. " / " .. result.maxRank)
        tinsert(lines, "Remaining Points: " .. result.remainingRanks)
        tinsert(lines, "")
        tinsert(lines, f.l("ROI per Point: ") .. CraftSim.UTIL:FormatMoney(result.roiPerPoint, true))
        tinsert(lines, f.l("Total Estimated ROI: ") .. CraftSim.UTIL:FormatMoney(result.totalEstimatedROI, true))

        if result.topRecipes and #result.topRecipes > 0 then
            tinsert(lines, "")
            tinsert(lines, f.l("Top Affected Recipes:"))
            local count = math.min(5, #result.topRecipes)
            for i = 1, count do
                local impact = result.topRecipes[i]
                tinsert(lines, "  " .. (impact.recipeName or "") .. ": " .. CraftSim.UTIL:FormatMoney(impact.profitDelta, true))
            end
            if result.affectedRecipeCount and result.affectedRecipeCount > count then
                tinsert(lines, "  ... and " .. (result.affectedRecipeCount - count) .. " more")
            end
        end
    end

    return table.concat(lines, "\n")
end

--- Start a full profession scan.
---@param content Frame  the optimizeContent sub-frame (passed from button callback)
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartFullScan(content)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for scan")
        return
    end

    content.modeText:SetText(f.l("Scanning..."))
    content.nodeList:Remove()
    content.nodeList:UpdateDisplay()

    CraftSim.KNOWLEDGE_POINT_VALUE:FullProfessionScanAsync(recipeData,
        function(progress, total)
            content.modeText:SetText(f.l("Scanning... ") .. progress .. "/" .. total)
        end,
        function(results)
            local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
            local ptsText = availPts > 0 and (", " .. availPts .. " pts") or ""
            content.modeText:SetText(f.l("Full Profession Value") ..
                " (" .. #results .. " nodes" .. ptsText .. ")")
            self:PopulateNodeList(content, results)
        end
    )
end

--- Start the optimal path calculation.
--- Uses the KP count from `content.pointsInput` (auto-detected available pts or user-set value).
---@param content Frame  the optimizeContent sub-frame (passed from button callback)
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartOptimizePath(content)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for optimization")
        return
    end

    content.modeText:SetText(f.l("Preparing scan..."))
    content.summaryText:SetText("")
    content.nodeList:Remove()
    content.nodeList:UpdateDisplay()

    -- Read target point count from the input field (user can override)
    local pointsToPlan = tonumber(content.pointsInput.textInput:GetText()) or 0
    if pointsToPlan <= 0 then
        local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
        pointsToPlan = availPts > 0 and availPts or 5
        content.pointsInput.textInput:SetText(tostring(pointsToPlan))
    end

    CraftSim.KNOWLEDGE_POINT_VALUE:CalculateOptimalPathAsync(recipeData, pointsToPlan,
        function(phase, progress, total)
            if phase == "scan" then
                content.modeText:SetText(f.l("Scanning... ") .. progress .. "/" .. total)
            else
                content.modeText:SetText(f.l("Optimizing... step ") .. progress .. "/" .. total)
            end
        end,
        function(path)
            local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
            local headerText = f.l("Optimal Path") .. " (" .. #path .. " steps"
            if availPts > 0 then
                headerText = headerText .. ", " .. availPts .. " pts"
            else
                headerText = headerText .. ", " .. pointsToPlan .. " pts planned"
            end
            headerText = headerText .. ")"
            content.modeText:SetText(headerText)

            CraftSim.KNOWLEDGE_POINT_VALUE:SaveWeeklyPlan(recipeData, path, pointsToPlan)

            if #path > 0 then
                local totalGain = path[#path].cumulativeROI or 0
                content.summaryText:SetText(
                    CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
                    "Total gain: " .. CraftSim.UTIL:FormatMoney(totalGain, true) ..
                    " from " .. #path .. " pts")
            end

            self:PopulateNodeList(content, path)
        end
    )
end

--- Start the Weekly Plan: load saved plan instantly, or run Optimize if missing.
---@param content Frame  the optimizeContent sub-frame (passed from button callback)
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartWeeklyPlan(content)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for weekly plan")
        return
    end

    local plan = CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedWeeklyPlan(recipeData)
    if plan and plan.path and #plan.path > 0 then
        local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)

        local age = time() - (plan.savedAt or 0)
        local ageText
        if age < 3600 then
            ageText = math.floor(age / 60) .. "m ago"
        elseif age < 86400 then
            ageText = math.floor(age / 3600) .. "h ago"
        else
            ageText = math.floor(age / 86400) .. "d ago"
        end

        local headerText = f.l("Weekly Plan") .. " (" .. #plan.path .. " steps"
        if availPts > 0 then
            headerText = headerText .. ", " .. GUTIL:ColorizeText(tostring(availPts), GUTIL.COLORS.GREEN) .. " pts now"
        end
        headerText = headerText .. ")"
        content.modeText:SetText(headerText)

        content.summaryText:SetText(
            CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
            "Plan: " .. CraftSim.UTIL:FormatMoney(plan.totalGain, true) ..
            " from " .. plan.availablePoints .. " pts" ..
            "  " .. GUTIL:ColorizeText("(saved " .. ageText .. ")", GUTIL.COLORS.GREY))

        self:PopulateNodeList(content, plan.path)
    else
        -- No saved plan – run Optimize
        self:StartOptimizePath(content)
    end
end
