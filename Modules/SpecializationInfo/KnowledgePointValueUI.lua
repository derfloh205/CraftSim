---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.KNOWLEDGE_POINT_VALUE.UI
CraftSim.KNOWLEDGE_POINT_VALUE.UI = {}

local print = CraftSim.DEBUG:RegisterLogger("Modules.SpecializationInfo.KnowledgePointValue.UI")

--- Returns the optimizeContent sub-frame of the appropriate SpecInfo frame.
local function GetOptimizeContent()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local frameID = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER
        and CraftSim.CONST.FRAMES.SPEC_INFO_WO
        or  CraftSim.CONST.FRAMES.SPEC_INFO
    local specFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, frameID)
    return specFrame and specFrame.content and specFrame.content.optimizeContent or nil
end

---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
---@return boolean
local function IsRespecMode(content)
    return content.planMode == "respec"
end

---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
---@return CraftSim.KnowledgePointValue.ScanOptions?
local function GetScanOptions(content)
    if IsRespecMode(content) then
        return { startFromZero = true }
    end
    return nil
end

--- Switch Spend / Respec plan mode and refresh KP defaults + button labels.
---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
---@param mode "spend"|"respec"
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:SetPlanMode(content, mode)
    content.planMode = mode or "spend"

    if content.optimizeButton then
        content.optimizeButton:SetText(mode == "respec" and "Plan Respec" or "Optimize")
    end

    local recipeData = CraftSim.MODULES.recipeData
    if recipeData then
        self:PrefillPointsInput(content, recipeData)
        -- Refresh header text for the new mode without clearing a loaded plan list
        if mode == "respec" then
            local totalBudget, spent, unspent = CraftSim.KNOWLEDGE_POINT_VALUE:GetRespecBudget(recipeData)
            content.modeText:SetText(
                f.l("Respec Planner") .. " - " ..
                GUTIL:ColorizeText(tostring(totalBudget), GUTIL.COLORS.GREEN) .. " pts" ..
                GUTIL:ColorizeText(" (" .. spent .. " spent + " .. unspent .. " unspent)", GUTIL.COLORS.GREY))
        else
            local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
            local ptsText = availPts > 0 and (" - " .. GUTIL:ColorizeText(tostring(availPts), GUTIL.COLORS.GREEN) .. " pts") or ""
            content.modeText:SetText(f.l("Spend Mode") .. ptsText)
        end
    end
end

--- Prefill the KP input based on the active plan mode.
---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
---@param recipeData CraftSim.RecipeData
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:PrefillPointsInput(content, recipeData)
    if IsRespecMode(content) then
        local totalBudget, spent, unspent = CraftSim.KNOWLEDGE_POINT_VALUE:GetRespecBudget(recipeData)
        local value = totalBudget > 0 and totalBudget or 5
        content.pointsInput.textInput:SetText(tostring(value))
        if content.pointsLabel then
            content.pointsLabel:SetText(f.white("KP:"))
        end
        print("Respec budget: spent=" .. tostring(spent) .. " unspent=" .. tostring(unspent) .. " total=" .. tostring(totalBudget))
    else
        local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
        if availPts > 0 then
            content.pointsInput.textInput:SetText(tostring(availPts))
        end
    end
end

--- Format a short age string from a unix timestamp.
---@param savedAt number
---@return string
local function FormatPlanAge(savedAt)
    local age = time() - (savedAt or 0)
    if age < 3600 then
        return math.floor(age / 60) .. "m ago"
    elseif age < 86400 then
        return math.floor(age / 3600) .. "h ago"
    else
        return math.floor(age / 86400) .. "d ago"
    end
end

--- Build summary text for a respec comparison.
---@param comparison CraftSim.KnowledgePointValue.RespecComparison
---@param pointsUsed number
---@return string
local function FormatRespecSummary(comparison, pointsUsed)
    local lines = {
        CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
        "Respec gain: " .. CraftSim.UTIL:FormatMoney(comparison.plannedGain, true) ..
        " from " .. pointsUsed .. " pts",
    }
    if comparison.nodesChanged > 0 then
        tinsert(lines,
            GUTIL:ColorizeText(
                comparison.nodesChanged .. " nodes differ from current tree",
                GUTIL.COLORS.GREY))
        local preview = {}
        local count = math.min(3, #comparison.moves)
        for i = 1, count do
            local move = comparison.moves[i]
            local arrow = move.delta > 0 and "+" or ""
            tinsert(preview,
                (move.nodeName or "?") .. " " ..
                math.max(0, move.currentRank) .. "->" .. math.max(0, move.plannedRank) ..
                " (" .. arrow .. move.delta .. ")")
        end
        if #preview > 0 then
            tinsert(lines, table.concat(preview, "  |  "))
        end
        if #comparison.moves > count then
            tinsert(lines, "..." .. (#comparison.moves - count) .. " more")
        end
    else
        tinsert(lines, GUTIL:ColorizeText("Matches current tree", GUTIL.COLORS.GREEN))
    end
    return table.concat(lines, "\n")
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

    self:PrefillPointsInput(content, recipeData)

    if IsRespecMode(content) then
        local totalBudget, spent, unspent = CraftSim.KNOWLEDGE_POINT_VALUE:GetRespecBudget(recipeData)
        content.modeText:SetText(
            f.l("Respec Planner") .. " - " ..
            GUTIL:ColorizeText(tostring(totalBudget), GUTIL.COLORS.GREEN) .. " pts" ..
            GUTIL:ColorizeText(" (" .. spent .. " spent + " .. unspent .. " unspent)", GUTIL.COLORS.GREY))

        local plan = CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedRespecPlan(recipeData)
        if plan and plan.totalGain > 0 then
            content.summaryText:SetText(
                CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
                "Respec plan: " .. CraftSim.UTIL:FormatMoney(plan.totalGain, true) ..
                " from " .. plan.availablePoints .. " pts" ..
                "  " .. GUTIL:ColorizeText("(" .. FormatPlanAge(plan.savedAt) .. ")", GUTIL.COLORS.GREY))
        else
            content.summaryText:SetText("")
        end
    else
        local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
        local ptsText = availPts > 0 and (" - " .. GUTIL:ColorizeText(tostring(availPts), GUTIL.COLORS.GREEN) .. " pts") or ""
        content.modeText:SetText(f.l("Single Recipe Value") .. ptsText)

        local plan = CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedWeeklyPlan(recipeData)
        if plan and plan.totalGain > 0 and plan.topNodeName then
            content.summaryText:SetText(
                CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
                "Plan: " .. CraftSim.UTIL:FormatMoney(plan.totalGain, true) ..
                " from " .. plan.availablePoints .. " pts" ..
                "  " .. GUTIL:ColorizeText("(" .. FormatPlanAge(plan.savedAt) .. ")", GUTIL.COLORS.GREY))
        else
            content.summaryText:SetText("")
        end
    end

    CraftSim.DEBUG:StartProfiling("KnowledgePointValue.SingleRecipe")
    local results = CraftSim.KNOWLEDGE_POINT_VALUE:CalculateForRecipe(recipeData)
    CraftSim.DEBUG:StopProfiling("KnowledgePointValue.SingleRecipe")

    self:PopulateNodeList(content, results)
end

--- Populate the frame list with node ROI results.
---@param content Frame  the optimizeContent sub-frame
---@param results CraftSim.KnowledgePointValue.NodeResult[]|CraftSim.KnowledgePointValue.FullScanResult[]|CraftSim.KnowledgePointValue.PathStep[]|CraftSim.KnowledgePointValue.RespecNodeDelta[]
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:PopulateNodeList(content, results)
    content.nodeList:Remove()

    -- Determine ROI range for heatmap normalization
    local maxROI, minROI = 0, 0
    for _, result in ipairs(results) do
        local roi = result.roiPerPoint or result.delta or 0
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
            if i == 1 and (result.roiPerPoint or 0) > 0 then
                prefix = CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " "
            end

            -- PathStep results (from Optimize) have a step field
            if result.step then
                nameCol.text:SetText(prefix .. GUTIL:ColorizeText("#" .. result.step, GUTIL.COLORS.WHITE) ..
                    " " .. (result.nodeName or ""))
                rankCol.text:SetText(math.max(0, result.rankBefore) .. "->" .. math.max(0, result.rankAfter) .. "/" .. result.maxRank)
            elseif result.plannedRank ~= nil then
                -- Respec delta row
                local delta = result.delta or 0
                local deltaText = delta > 0 and ("+" .. delta) or tostring(delta)
                nameCol.text:SetText(prefix .. (result.nodeName or ("Node " .. result.nodeID)))
                rankCol.text:SetText(math.max(0, result.currentRank) .. "->" .. math.max(0, result.plannedRank))
                result.roiPerPoint = delta -- for heatmap below
                local colored = delta > 0
                    and GUTIL:ColorizeText(deltaText, GUTIL.COLORS.GREEN)
                    or GUTIL:ColorizeText(deltaText, GUTIL.COLORS.RED)
                roiCol.text:SetText(colored)
            else
                nameCol.text:SetText(prefix .. (result.nodeName or ("Node " .. result.nodeID)))
                rankCol.text:SetText(tostring(math.max(0, result.currentRank)) .. "/" .. tostring(result.maxRank))
            end

            if result.plannedRank == nil then
                -- Color-code ROI
                local roiText
                local roi = result.roiPerPoint or 0
                if roi > 0 then
                    roiText = GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(roi, false), GUTIL.COLORS.GREEN)
                elseif roi < 0 then
                    roiText = GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(roi, false), GUTIL.COLORS.RED)
                else
                    roiText = CraftSim.UTIL:FormatMoney(0, false)
                end
                roiCol.text:SetText(roiText)
            end

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
---@param result CraftSim.KnowledgePointValue.NodeResult|CraftSim.KnowledgePointValue.FullScanResult|CraftSim.KnowledgePointValue.PathStep|CraftSim.KnowledgePointValue.RespecNodeDelta
---@return string
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:BuildRowTooltip(result)
    local lines = {}

    if result.step then
        tinsert(lines, f.bb("Step #" .. result.step .. ": " .. (result.nodeName or "")))
        tinsert(lines, "Rank: " .. math.max(0, result.rankBefore) .. " -> " .. math.max(0, result.rankAfter) .. " / " .. result.maxRank)
        tinsert(lines, "")
        tinsert(lines, f.l("ROI this step: ") .. CraftSim.UTIL:FormatMoney(result.roiPerPoint, true))
        tinsert(lines, f.l("Cumulative ROI: ") .. CraftSim.UTIL:FormatMoney(result.cumulativeROI, true))
    elseif result.plannedRank ~= nil then
        tinsert(lines, f.bb(result.nodeName or ("Node " .. result.nodeID)))
        tinsert(lines, "Current: " .. math.max(0, result.currentRank) .. "  ->  Planned: " .. math.max(0, result.plannedRank))
        local delta = result.delta or 0
        if delta > 0 then
            tinsert(lines, f.g("Invest +" .. delta .. " after respec"))
        elseif delta < 0 then
            tinsert(lines, f.r("Leave empty / refund " .. math.abs(delta)))
        end
    else
        tinsert(lines, f.bb(result.nodeName or ("Node " .. result.nodeID)))
        tinsert(lines, "Rank: " .. math.max(0, result.currentRank) .. " / " .. result.maxRank)
        tinsert(lines, "Remaining Points: " .. (result.remainingRanks or 0))
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
---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartFullScan(content)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for scan")
        return
    end

    local options = GetScanOptions(content)
    local modeLabel = IsRespecMode(content) and "Respec Scan" or "Scanning"
    content.modeText:SetText(f.l(modeLabel .. "..."))
    content.nodeList:Remove()
    content.nodeList:UpdateDisplay()

    CraftSim.KNOWLEDGE_POINT_VALUE:FullProfessionScanAsync(recipeData,
        function(progress, total)
            content.modeText:SetText(f.l(modeLabel .. "... ") .. progress .. "/" .. total)
        end,
        function(results)
            if IsRespecMode(content) then
                local totalBudget = CraftSim.KNOWLEDGE_POINT_VALUE:GetRespecBudget(recipeData)
                content.modeText:SetText(f.l("Respec Tree Value") ..
                    " (" .. #results .. " nodes, " .. totalBudget .. " pts budget)")
            else
                local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
                local ptsText = availPts > 0 and (", " .. availPts .. " pts") or ""
                content.modeText:SetText(f.l("Full Profession Value") ..
                    " (" .. #results .. " nodes" .. ptsText .. ")")
            end
            self:PopulateNodeList(content, results)
        end,
        nil,
        options
    )
end

--- Start the optimal path calculation (Spend) or blank-slate respec plan.
---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartOptimizePath(content)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for optimization")
        return
    end

    local respec = IsRespecMode(content)
    local options = GetScanOptions(content)

    content.modeText:SetText(f.l(respec and "Preparing respec scan..." or "Preparing scan..."))
    content.summaryText:SetText("")
    content.nodeList:Remove()
    content.nodeList:UpdateDisplay()

    -- Read target point count from the input field (user can override)
    local pointsToPlan = tonumber(content.pointsInput.textInput:GetText()) or 0
    if pointsToPlan <= 0 then
        if respec then
            pointsToPlan = CraftSim.KNOWLEDGE_POINT_VALUE:GetRespecBudget(recipeData)
        else
            local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)
            pointsToPlan = availPts > 0 and availPts or 5
        end
        if pointsToPlan <= 0 then pointsToPlan = 5 end
        content.pointsInput.textInput:SetText(tostring(pointsToPlan))
    end

    CraftSim.KNOWLEDGE_POINT_VALUE:CalculateOptimalPathAsync(recipeData, pointsToPlan,
        function(phase, progress, total)
            if phase == "scan" then
                content.modeText:SetText(f.l((respec and "Respec scan" or "Scanning") .. "... ") .. progress .. "/" .. total)
            else
                content.modeText:SetText(f.l((respec and "Planning respec" or "Optimizing") .. "... step ") .. progress .. "/" .. total)
            end
        end,
        function(path)
            if respec then
                local comparison = CraftSim.KNOWLEDGE_POINT_VALUE:BuildRespecComparison(recipeData, path)
                CraftSim.KNOWLEDGE_POINT_VALUE:SaveRespecPlan(recipeData, path, pointsToPlan, comparison)

                content.modeText:SetText(
                    f.l("Respec Plan") .. " (" .. #path .. " steps, " .. pointsToPlan .. " pts)")
                content.summaryText:SetText(FormatRespecSummary(comparison, #path > 0 and #path or pointsToPlan))

                -- Show path by default; if there are tree deltas, append a note in summary
                self:PopulateNodeList(content, path)
            else
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
        end,
        options
    )
end

--- Load saved plan for the active mode, or run Optimize if missing.
---@param content CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT
function CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartWeeklyPlan(content)
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for weekly plan")
        return
    end

    if IsRespecMode(content) then
        local plan = CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedRespecPlan(recipeData)
        if plan and plan.path and #plan.path > 0 then
            content.modeText:SetText(
                f.l("Respec Plan") .. " (" .. #plan.path .. " steps, saved " .. FormatPlanAge(plan.savedAt) .. ")")

            if plan.comparison then
                content.summaryText:SetText(FormatRespecSummary(plan.comparison, plan.availablePoints))
            else
                content.summaryText:SetText(
                    CreateAtlasMarkup("PetJournal-FavoritesIcon", 14, 14) .. " " ..
                    "Respec: " .. CraftSim.UTIL:FormatMoney(plan.totalGain, true) ..
                    " from " .. plan.availablePoints .. " pts")
            end

            self:PopulateNodeList(content, plan.path)
        else
            self:StartOptimizePath(content)
        end
        return
    end

    local plan = CraftSim.KNOWLEDGE_POINT_VALUE:GetSavedWeeklyPlan(recipeData)
    if plan and plan.path and #plan.path > 0 then
        local availPts = CraftSim.KNOWLEDGE_POINT_VALUE:GetAvailableKnowledgePoints(recipeData)

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
            "  " .. GUTIL:ColorizeText("(saved " .. FormatPlanAge(plan.savedAt) .. ")", GUTIL.COLORS.GREY))

        self:PopulateNodeList(content, plan.path)
    else
        -- No saved plan – run Optimize
        self:StartOptimizePath(content)
    end
end
