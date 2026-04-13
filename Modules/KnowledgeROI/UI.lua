---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.KNOWLEDGE_ROI.UI
CraftSim.KNOWLEDGE_ROI.UI = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.KnowledgeROI.UI")

function CraftSim.KNOWLEDGE_ROI.UI:Init()
    local sizeX = 350
    local sizeY = 400
    local offsetX = 260
    local offsetY = 200

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    ---@class CraftSim.KNOWLEDGE_ROI.FRAME : GGUI.Frame
    local frameNO_WO = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.KNOWLEDGE_ROI,
        title = "CraftSim Knowledge ROI",
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_KNOWLEDGE_ROI"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel,
    })

    ---@class CraftSim.KNOWLEDGE_ROI.FRAME : GGUI.Frame
    local frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.KNOWLEDGE_ROI_WO,
        title = "CraftSim Knowledge ROI",
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_KNOWLEDGE_ROI"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel,
    })

    ---@param frame CraftSim.KNOWLEDGE_ROI.FRAME
    local function createContent(frame)
        ---@class CraftSim.KNOWLEDGE_ROI.FRAME.CONTENT : Frame
        frame.content = frame.content

        frame:Hide()

        frame.content.modeText = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            text = f.l("Single Recipe Mode"),
            justifyOptions = { type = 'H', align = "LEFT" },
            offsetX = 15,
            offsetY = -30,
        })

        frame.content.fullScanButton = GGUI.Button({
            parent = frame.content,
            anchorPoints = { {
                anchorParent = frame.content,
                anchorA = "TOPRIGHT",
                anchorB = "TOPRIGHT",
                offsetX = -15,
                offsetY = -26,
            } },
            label = "Full Scan",
            sizeX = 85,
            sizeY = 22,
            clickCallback = function()
                CraftSim.KNOWLEDGE_ROI.UI:StartFullScan()
            end,
        })

        frame.content.optimizeButton = GGUI.Button({
            parent = frame.content,
            anchorPoints = { {
                anchorParent = frame.content,
                anchorA = "TOPRIGHT",
                anchorB = "TOPRIGHT",
                offsetX = -105,
                offsetY = -26,
            } },
            label = "Optimize",
            sizeX = 85,
            sizeY = 22,
            clickCallback = function()
                CraftSim.KNOWLEDGE_ROI.UI:StartOptimizePath()
            end,
        })

        frame.content.nodeList = GGUI.FrameList({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            hideScrollbar = false,
            sizeY = 295,
            selectionOptions = {
                noSelectionColor = true,
                hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            },
            rowHeight = 28,
            offsetX = 10,
            offsetY = -55,
            scale = 1,
            columnOptions = {
                {
                    label = "Node",
                    width = 150,
                },
                {
                    label = "Rank",
                    width = 60,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = "ROI / Pt",
                    width = 100,
                    justifyOptions = { type = "H", align = "RIGHT" },
                },
            },
            showHeaderLine = true,
            rowConstructor = function(columns)
                ---@class CraftSim.KNOWLEDGE_ROI.NODE_LIST.NAME_COL : Frame
                local nameCol = columns[1]

                ---@class CraftSim.KNOWLEDGE_ROI.NODE_LIST.RANK_COL : Frame
                local rankCol = columns[2]

                ---@class CraftSim.KNOWLEDGE_ROI.NODE_LIST.ROI_COL : Frame
                local roiCol = columns[3]

                local iconSize = 20
                nameCol.icon = GGUI.Texture({
                    parent = nameCol,
                    anchorParent = nameCol,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    sizeX = iconSize,
                    sizeY = iconSize,
                })

                nameCol.text = GGUI.Text({
                    parent = nameCol,
                    anchorParent = nameCol.icon.frame,
                    justifyOptions = { type = "H", align = "LEFT" },
                    anchorA = "LEFT",
                    anchorB = "RIGHT",
                    offsetX = 3,
                    fixedWidth = 120,
                })

                rankCol.text = GGUI.Text({
                    parent = rankCol,
                    anchorParent = rankCol,
                })

                roiCol.text = GGUI.Text({
                    parent = roiCol,
                    anchorParent = roiCol,
                    anchorA = "RIGHT",
                    anchorB = "RIGHT",
                    offsetX = -5,
                    justifyOptions = { type = "H", align = "RIGHT" },
                })

                -- ROI heatmap background bar
                local rowFrame = nameCol:GetParent()
                local bg = rowFrame:CreateTexture(nil, "BACKGROUND")
                bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
                bg:SetAllPoints(rowFrame)
                bg:SetAlpha(0)
                rowFrame.roiBg = bg
            end,
        })
    end

    createContent(frameNO_WO)
    createContent(frameWO)

    CraftSim.KNOWLEDGE_ROI.frame = frameNO_WO
    CraftSim.KNOWLEDGE_ROI.frameWO = frameWO
end

--- Update the knowledge ROI display for the given recipe.
---@param recipeData CraftSim.RecipeData
function CraftSim.KNOWLEDGE_ROI.UI:UpdateDisplay(recipeData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    ---@type CraftSim.KNOWLEDGE_ROI.FRAME
    local frame
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.KNOWLEDGE_ROI_WO) --[[@as CraftSim.KNOWLEDGE_ROI.FRAME]]
    else
        frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.KNOWLEDGE_ROI) --[[@as CraftSim.KNOWLEDGE_ROI.FRAME]]
    end

    ---@type CraftSim.KNOWLEDGE_ROI.FRAME.CONTENT
    local content = frame.content

    content.nodeList:Remove()

    if not recipeData.specializationData or not recipeData.supportsCraftingStats then
        content.modeText:SetText(f.l("No specialization data available"))
        content.nodeList:UpdateDisplay()
        return
    end

    local availPts = CraftSim.KNOWLEDGE_ROI:GetAvailableKnowledgePoints(recipeData)
    local ptsText = availPts > 0 and (" — " .. GUTIL:ColorizeText(tostring(availPts), GUTIL.COLORS.GREEN) .. " pts") or ""
    content.modeText:SetText(f.l("Single Recipe ROI") .. ptsText)

    CraftSim.DEBUG:StartProfiling("KnowledgeROI.SingleRecipe")
    local results = CraftSim.KNOWLEDGE_ROI:CalculateForRecipe(recipeData)
    CraftSim.DEBUG:StopProfiling("KnowledgeROI.SingleRecipe")

    self:PopulateNodeList(content, results)
end

--- Populate the frame list with node ROI results.
---@param content CraftSim.KNOWLEDGE_ROI.FRAME.CONTENT
---@param results CraftSim.KnowledgeROI.NodeResult[]|CraftSim.KnowledgeROI.FullScanResult[]
function CraftSim.KNOWLEDGE_ROI.UI:PopulateNodeList(content, results)
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
            ---@type CraftSim.KNOWLEDGE_ROI.NODE_LIST.NAME_COL
            local nameCol = columns[1]
            ---@type CraftSim.KNOWLEDGE_ROI.NODE_LIST.RANK_COL
            local rankCol = columns[2]
            ---@type CraftSim.KNOWLEDGE_ROI.NODE_LIST.ROI_COL
            local roiCol = columns[3]

            if result.nodeIcon then
                nameCol.icon:SetTexture(result.nodeIcon)
                nameCol.icon:Show()
            else
                nameCol.icon:Hide()
            end

            -- "Next Best" badge on first positive-ROI row
            local prefix = ""
            if i == 1 and result.roiPerPoint > 0 then
                prefix = GUTIL:ColorizeText("★ ", GUTIL.COLORS.LEGENDARY)
            end

            -- PathStep results (from Optimize) have a step field
            if result.step then
                nameCol.text:SetText(prefix .. GUTIL:ColorizeText("#" .. result.step, GUTIL.COLORS.WHITE) ..
                    " " .. (result.nodeName or ""))
                rankCol.text:SetText(math.max(0, result.rankBefore) .. "→" .. math.max(0, result.rankAfter) .. "/" .. result.maxRank)
            else
                nameCol.text:SetText(prefix .. (result.nodeName or ("Node " .. result.nodeID)))
                local rankText = tostring(math.max(0, result.currentRank)) .. "/" .. tostring(result.maxRank)
                rankCol.text:SetText(rankText)
            end

            -- Color-code ROI: green for positive, red for negative, white for zero
            local roiText
            if result.roiPerPoint > 0 then
                roiText = GUTIL:ColorizeText(
                    CraftSim.UTIL:FormatMoney(result.roiPerPoint, false),
                    GUTIL.COLORS.GREEN)
            elseif result.roiPerPoint < 0 then
                roiText = GUTIL:ColorizeText(
                    CraftSim.UTIL:FormatMoney(result.roiPerPoint, false),
                    GUTIL.COLORS.RED)
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
                    rowFrame.roiBg:SetAlpha(0.08 + t * 0.17) -- 0.08 to 0.25
                elseif roi < 0 then
                    local t = math.min(math.abs(roi) / roiRange, 1)
                    rowFrame.roiBg:SetVertexColor(0.8, 0, 0, 1)
                    rowFrame.roiBg:SetAlpha(0.08 + t * 0.17)
                else
                    rowFrame.roiBg:SetAlpha(0)
                end
            end

            -- Tooltip with details
            row.tooltipOptions = {
                text = self:BuildRowTooltip(result),
                anchor = "ANCHOR_CURSOR",
            }
        end)
    end

    content.nodeList:UpdateDisplay()
end

--- Build a tooltip string for a node ROI row.
---@param result CraftSim.KnowledgeROI.NodeResult|CraftSim.KnowledgeROI.FullScanResult
---@return string
function CraftSim.KNOWLEDGE_ROI.UI:BuildRowTooltip(result)
    local lines = {}

    if result.step then
        -- Optimal Path roadmap step
        tinsert(lines, f.bb("Step #" .. result.step .. ": " .. (result.nodeName or "")))
        tinsert(lines, "Rank: " .. math.max(0, result.rankBefore) .. " → " .. math.max(0, result.rankAfter) .. " / " .. result.maxRank)
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

        -- Full scan results include affected recipe details
        if result.topRecipes and #result.topRecipes > 0 then
            tinsert(lines, "")
            tinsert(lines, f.l("Top Affected Recipes:"))
            local count = math.min(5, #result.topRecipes)
            for i = 1, count do
                local impact = result.topRecipes[i]
                local deltaStr = CraftSim.UTIL:FormatMoney(impact.profitDelta, true)
                tinsert(lines, "  " .. (impact.recipeName or "") .. ": " .. deltaStr)
            end
            if result.affectedRecipeCount and result.affectedRecipeCount > count then
                tinsert(lines, "  ... and " .. (result.affectedRecipeCount - count) .. " more")
            end
        end
    end

    return table.concat(lines, "\n")
end

--- Start a full profession scan (triggered by button).
function CraftSim.KNOWLEDGE_ROI.UI:StartFullScan()
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for scan")
        return
    end

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    ---@type CraftSim.KNOWLEDGE_ROI.FRAME
    local frame
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.KNOWLEDGE_ROI_WO) --[[@as CraftSim.KNOWLEDGE_ROI.FRAME]]
    else
        frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.KNOWLEDGE_ROI) --[[@as CraftSim.KNOWLEDGE_ROI.FRAME]]
    end

    ---@type CraftSim.KNOWLEDGE_ROI.FRAME.CONTENT
    local content = frame.content
    content.modeText:SetText(f.l("Scanning..."))
    content.nodeList:Remove()
    content.nodeList:UpdateDisplay()

    -- Use C_Timer to avoid blocking the UI while computing
    C_Timer.After(0.01, function()
        local results = CraftSim.KNOWLEDGE_ROI:FullProfessionScan(recipeData, function(progress, total)
            content.modeText:SetText(f.l("Scanning... ") .. progress .. "/" .. total)
        end)

        local availPts = CraftSim.KNOWLEDGE_ROI:GetAvailableKnowledgePoints(recipeData)
        local ptsText = availPts > 0 and (", " .. availPts .. " pts") or ""
        content.modeText:SetText(f.l("Full Profession ROI") ..
            " (" .. #results .. " nodes" .. ptsText .. ")")
        self:PopulateNodeList(content, results)
    end)
end


--- Start the optimal path calculation (triggered by Optimize button).
function CraftSim.KNOWLEDGE_ROI.UI:StartOptimizePath()
    local recipeData = CraftSim.MODULES.recipeData
    if not recipeData then
        print("No recipe data available for optimization")
        return
    end

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    ---@type CraftSim.KNOWLEDGE_ROI.FRAME
    local frame
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.KNOWLEDGE_ROI_WO) --[[@as CraftSim.KNOWLEDGE_ROI.FRAME]]
    else
        frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.KNOWLEDGE_ROI) --[[@as CraftSim.KNOWLEDGE_ROI.FRAME]]
    end

    ---@type CraftSim.KNOWLEDGE_ROI.FRAME.CONTENT
    local content = frame.content
    content.modeText:SetText(f.l("Preparing scan..."))
    content.nodeList:Remove()
    content.nodeList:UpdateDisplay()

    local availablePoints = CraftSim.KNOWLEDGE_ROI:GetAvailableKnowledgePoints(recipeData)
    -- If no available points detected, plan ahead with a default of 5 points
    local pointsToPlan = availablePoints > 0 and availablePoints or 5

    C_Timer.After(0.01, function()
        local path = CraftSim.KNOWLEDGE_ROI:CalculateOptimalPath(recipeData, pointsToPlan,
            function(phase, progress, total)
                if phase == "scan" then
                    content.modeText:SetText(f.l("Scanning... ") .. progress .. "/" .. total)
                else
                    content.modeText:SetText(f.l("Optimizing... step ") .. progress .. "/" .. total)
                end
            end)

        local headerText = f.l("Optimal Path") .. " (" .. #path .. " steps"
        if availablePoints > 0 then
            headerText = headerText .. ", " .. availablePoints .. " pts available"
        else
            headerText = headerText .. ", planning " .. pointsToPlan .. " pts"
        end
        headerText = headerText .. ")"
        content.modeText:SetText(headerText)

        self:PopulateNodeList(content, path)
    end)
end
