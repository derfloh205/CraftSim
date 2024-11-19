---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

---@class CraftSim.STATISTICS
CraftSim.STATISTICS = CraftSim.STATISTICS

---@class CraftSim.STATISTICS.UI
CraftSim.STATISTICS.UI = {}

CraftSim.STATISTICS.UI.CONCENTRATION_GRAPH_LINE_COLOR = { 0.93, 0.79, 0.0, 0.8 }

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Statistics.UI")

function CraftSim.STATISTICS.UI:Init()
    local sizeX = 500
    local sizeY = 400

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    CraftSim.STATISTICS.frameNO_WO = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.STATISTICS,
        title = L(CraftSim.CONST.TEXT.STATISTICS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_STATISTICS"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    CraftSim.STATISTICS.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.STATISTICS_WORKORDER,
        title = L(CraftSim.CONST.TEXT.STATISTICS_TITLE) ..
            " " .. GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SOURCE_COLUMN_WO), GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_STATISTICS"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })


    local function createContent(frame)
        frame:Hide()
        local tabContentSizeX = sizeX
        local tabContentSizeY = sizeY


        ---@class CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB : GGUI.BlizzardTab
        frame.content.probabilityTableTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                offsetY = -2,
                label = L(CraftSim.CONST.TEXT.STATISTICS_PROBABILITY_TABLE_TAB),
            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = tabContentSizeX,
            sizeY = tabContentSizeY,
            canBeEnabled = true,
            offsetY = -30,
            initialTab = true,
            top = true,
        })

        ---@class CraftSim.STATISTICS.UI.CONCENTRATION_TAB : GGUI.BlizzardTab
        frame.content.concentrationTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content.probabilityTableTab.button,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                label = L(CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_TAB),

            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = tabContentSizeX,
            sizeY = tabContentSizeY,
            canBeEnabled = true,
            offsetY = -30,
            top = true,
        })

        self:InitProbabilityTableTab(frame.content.probabilityTableTab)
        self:InitConcentrationTab(frame.content.concentrationTab)

        GGUI.BlizzardTabSystem { frame.content.probabilityTableTab, frame.content.concentrationTab }
    end

    createContent(CraftSim.STATISTICS.frameNO_WO)
    createContent(CraftSim.STATISTICS.frameWO)
end

---@param tab CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB
function CraftSim.STATISTICS.UI:InitProbabilityTableTab(tab)
    ---@class CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB
    tab = tab

    ---@class CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB.CONTENT : Frame
    local content = tab.content

    ---@type GGUI.Text | GGUI.Widget
    content.expectedProfitTitle = GGUI.Text({
        parent = content,
        anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = -20,
        text = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT)
    })
    ---@type GGUI.Text | GGUI.Widget
    content.expectedProfitValue = GGUI.Text({
        parent = content,
        anchorParent = content.expectedProfitTitle.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetY = -10,
    })
    ---@type GGUI.Text | GGUI.Widget
    content.craftsTextTop = GGUI.Text({
        parent = content,
        anchorParent = content.expectedProfitValue.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetY = -30,
        text = L(CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF) ..
            GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.STATISTICS_PROFIT) .. " > 0",
                GUTIL.COLORS.GREEN) .. L(CraftSim.CONST.TEXT.STATISTICS_AFTER),
    })

    ---@type GGUI.NumericInput
    content.numCraftsInput = GGUI.NumericInput({
        parent = content,
        anchorParent = content.craftsTextTop.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetX = -40,
        offsetY = -10,
        sizeX = 50,
        sizeY = 25,
        initialValue = 1,
        allowDecimals = false,
        minValue = 1,
        incrementOneButtons = true,
        borderAdjustWidth = 1.15,
        borderAdjustHeight = 1.05,
        onNumberValidCallback = function()
            local recipeData = CraftSim.INIT.currentRecipeData
            if not recipeData then
                return
            end
            CraftSim.STATISTICS.UI:UpdateDisplay(recipeData)
        end
    })

    content.cdfExplanation = GGUI.HelpIcon({
        parent = content,
        anchorParent = content.numCraftsInput.textInput.frame,
        text = L(CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION),
        anchorA = "RIGHT",
        anchorB = "LEFT",
        offsetX = -10,
        offsetY = 1,
    })

    ---@type GGUI.Text | GGUI.Widget
    content.craftsTextBottom = GGUI.Text({
        parent = content,
        anchorParent = content.numCraftsInput.textInput.frame,
        offsetX = 20,
        text = L(CraftSim.CONST.TEXT.STATISTICS_CRAFTS),
        anchorA = "LEFT",
        anchorB = "RIGHT",
    })

    ---@type GGUI.Text | GGUI.Widget
    content.probabilityValue = GGUI.Text({
        parent = content,
        anchorParent = content.craftsTextBottom.frame,
        offsetX = 1,
        text = "0%",
        justifyOptions = { type = "H", align = "LEFT" },
        anchorA = "LEFT",
        anchorB = "RIGHT",
    })

    content.probabilityTableTitle = GGUI.Text({
        parent = content,
        anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        text = L(CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE),
        offsetY = -150,
    })

    ---@type GGUI.FrameList | GGUI.Widget
    content.probabilityTable = GGUI.FrameList({
        parent = content,
        sizeY = 150,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        anchorParent = content.probabilityTableTitle.frame,
        showBorder = true,
        offsetX = -10,
        offsetY = -30,
        columnOptions = {
            {
                label = L(CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER),
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER),
                width = 110,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER),
                width = 110,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER),
                width = 120,
            },
        },
        rowConstructor = function(columns)
            local chanceColumn = columns[1]
            local multicraftColumn = columns[2]
            local resourcefulnessColumn = columns[3]
            local profitColumn = columns[4]

            ---@type GGUI.Text | GGUI.Widget
            chanceColumn.text = GGUI.Text({
                parent = chanceColumn,
                anchorParent = chanceColumn,
                text = "100%",
                justifyOptions = { type = "H", align = "CENTER" },
            })

            ---@type GGUI.Text | GGUI.Widget
            profitColumn.text = GGUI.Text({
                parent = profitColumn,
                anchorParent = profitColumn,
                text = CraftSim.UTIL:FormatMoney(11312313, true),
                justifyOptions = { type = "H", align = "LEFT" },
            })

            local booleanColumns = { multicraftColumn, resourcefulnessColumn }

            local check = GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125),
                GUTIL.COLORS.GREEN)
            local cross = GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.125),
                GUTIL.COLORS.RED)
            local dash = GUTIL:ColorizeText("-", GUTIL.COLORS.GREY)

            for _, column in pairs(booleanColumns) do
                ---@type GGUI.Text | GGUI.Widget
                column.text = GGUI.Text({
                    parent = column,
                    anchorParent = column,
                    text = cross,
                    justifyOptions = { type = "H", align = "CENTER" },
                })

                function column:SetChecked(value)
                    if value then
                        column.text:SetText(check)
                    else
                        column.text:SetText(cross)
                    end
                end

                function column:SetIrrelevant()
                    column.text:SetText(dash)
                end
            end
        end,
    })
end

function CraftSim.STATISTICS.UI:InitConcentrationTab(tab)
    ---@class CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB
    tab = tab

    ---@class CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB.CONTENT : Frame
    local content = tab.content

    content.concentrationCurveGraph = CraftSim.LibGraph:CreateGraphLine("ConcentrationCurveGraph", content, "TOP", "TOP",
        0,
        -20, 450, 320)
    content.concentrationCurveGraph:SetXAxis(0, 1)
    content.concentrationCurveGraph:SetYAxis(0, 1)
    -- content.concentrationCurveGraph:LockYMin(true)
    content.concentrationCurveGraph:SetGridSpacing(0.1, 0.3)
    content.concentrationCurveGraph:SetGridColor({ 0.5, 0.5, 0.5, 0.5 })
    content.concentrationCurveGraph:SetAxisDrawing(true, true)
    content.concentrationCurveGraph:SetAxisColor({ 1.0, 1.0, 1.0, 1.0 })
    content.concentrationCurveGraph:SetAutoScale(true)
    content.concentrationCurveGraph:SetYLabels(true)

    function content.concentrationCurveGraph:SetDefault()
        local Data1 = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }

        content.concentrationCurveGraph:AddDataSeries(Data1, CraftSim.STATISTICS.UI.CONCENTRATION_GRAPH_LINE_COLOR)
    end

    content.graphTitle = GGUI.Text {
        parent = content,
        anchorPoints = { {
            anchorParent = content.concentrationCurveGraph,
            anchorA = "BOTTOM",
            anchorB = "TOP", offsetY = 5,
        } },
        text = L(CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH)
    }

    GGUI.HelpIcon {
        parent = content,
        anchorParent = content.graphTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        text = L(CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP),
    }
end

---@param recipeData CraftSim.RecipeData
function CraftSim.STATISTICS.UI:UpdateDisplay(recipeData)
    local statisticsFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.STATISTICS)
    local meanProfit, probabilityTable = recipeData:GetAverageProfit()

    if not statisticsFrame then return end

    if not probabilityTable then
        statisticsFrame.content.concentrationTab.content.concentrationCurveGraph:ResetData()
        statisticsFrame.content.concentrationTab.content.concentrationCurveGraph:AddDefault()
        return
    end

    --- ProbabilityTableTab
    do
        local content = statisticsFrame.content.probabilityTableTab
            .content --[[@as CraftSim.STATISTICS.UI.PROBABILITY_TABLE_TAB.CONTENT]]

        content.probabilityTable:Remove()

        for _, probabilityInfo in pairs(probabilityTable) do
            content.probabilityTable:Add(function(row)
                local chanceColumn = row.columns[1]
                local multicraftColumn = row.columns[2]
                local resourcefulnessColumn = row.columns[3]
                local profitColumn = row.columns[4]

                row.chance = probabilityInfo.chance
                chanceColumn.text:SetText(GUTIL:Round(row.chance * 100, 2) .. "%")
                profitColumn.text:SetText(CraftSim.UTIL:FormatMoney(probabilityInfo.profit, true))

                if recipeData.supportsMulticraft then
                    multicraftColumn:SetChecked(probabilityInfo.multicraft)
                else
                    multicraftColumn:SetIrrelevant()
                end
                if recipeData.supportsResourcefulness then
                    resourcefulnessColumn:SetChecked(probabilityInfo.resourcefulness)
                else
                    resourcefulnessColumn:SetIrrelevant()
                end
            end)
        end

        content.probabilityTable:UpdateDisplay(function(rowA, rowB)
            return rowA.chance > rowB.chance
        end)

        local numCrafts = content.numCraftsInput.currentValue

        local probabilityPositive = CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable,
            numCrafts)

        content.expectedProfitValue:SetText(CraftSim.UTIL:FormatMoney(meanProfit, true))
        local roundedProfit = GUTIL:Round(probabilityPositive * 100, 5)
        if probabilityPositive == 1 then
            -- if e.g. every craft has a positive outcome
            roundedProfit = "100.00000"
        elseif tonumber(roundedProfit) >= 100 then
            -- if the probability is not 1 but the rounded is 100 then show that there is a smaaaall chance of failure
            roundedProfit = ">99.99999"
        end
        content.probabilityValue:SetText(roundedProfit .. "%")
    end

    --- ConcentrationTab
    do
        local content = statisticsFrame.content.concentrationTab
            .content --[[@as CraftSim.STATISTICS.UI.CONCENTRATION_TAB.CONTENT]]

        local graph = content.concentrationCurveGraph

        local concentrationCurveData = recipeData.concentrationCurveData

        graph:ResetData()

        if not concentrationCurveData then
            graph:SetDefault()
        else
            -- draw points and modify them based on stats they represent
            local recipeDifficulty = recipeData.professionStats.recipeDifficulty.value

            local curveData = concentrationCurveData.curveData
            local costConstantData = concentrationCurveData.costConstantData

            local specExtraValues = recipeData.specializationData:GetExtraValues()
            local lessConcentrationUsageFactor = specExtraValues.ingenuity:GetExtraValue(2)
            local optionalReagentStats = recipeData.reagentData:GetProfessionStatsByOptionals()
            local lessConcentrationUsageFactor2 = optionalReagentStats.ingenuity:GetExtraValue(2)

            local points = {}
            for x, y in pairs(curveData) do
                local pointDifficulty = x * recipeDifficulty
                local curveConstantData, nextCurveConstantData = CraftSim.UTIL:FindBracketData(pointDifficulty,
                    costConstantData)
                local curveData, nextCurveData = CraftSim.UTIL:FindBracketData(x,
                    curveData)
                local pointConstant = CraftSim.UTIL:CalculateCurveConstant(pointDifficulty, curveConstantData,
                    nextCurveConstantData)
                local recipeDifficultyFactor = (curveData and curveData.index) or 0
                local nextRecipeDifficultyFactor = (nextCurveData and nextCurveData.index) or 1
                local skillCurveValueStart = (curveData and curveData.data) or 0
                local skillCurveValueEnd = (nextCurveData and nextCurveData.data) or 1
                local skillStart = recipeDifficulty * recipeDifficultyFactor
                local skillEnd = recipeDifficulty * nextRecipeDifficultyFactor

                local pointCost = CraftSim.UTIL:CalculateConcentrationCost(pointConstant, pointDifficulty, skillStart,
                    skillEnd, skillCurveValueStart, skillCurveValueEnd,
                    { lessConcentrationUsageFactor, lessConcentrationUsageFactor2 })
                tinsert(points, { pointDifficulty, pointCost })
            end
            table.sort(points, function(a, b)
                return a[1] < b[1]
            end)

            -- set grid spacing anew based on recipeDifficulty and maxCost
            local maxCost = GUTIL:Fold(points, 0, function(foldValue, nextElement)
                if nextElement[2] > foldValue then
                    return nextElement[2]
                end
                return foldValue
            end)
            graph:SetGridSpacing(recipeDifficulty / 10, maxCost / 10)

            graph:AddDataSeries(points, CraftSim.STATISTICS.UI.CONCENTRATION_GRAPH_LINE_COLOR)

            -- draw current skill, but set maximum x to recipedifficulty
            local currentSkill = math.min(recipeData.professionStats.skill.value, recipeDifficulty)
            local currentCost = recipeData.concentrationCost
            local yOffset = (maxCost / 100) * 1.5        -- % of yMax
            local xOffset = (recipeDifficulty / 100) * 1 -- % of xMax

            -- draw it in X shape
            graph:AddDataSeries(
                { { currentSkill - xOffset, currentCost - yOffset }, { currentSkill + xOffset, currentCost + yOffset } },
                { 0, 1, 0, 1 })
            -- draw it in X shape
            graph:AddDataSeries(
                { { currentSkill - xOffset, currentCost + yOffset }, { currentSkill + xOffset, currentCost - yOffset } },
                { 0, 1, 0, 1 })
        end
    end
end

function CraftSim.STATISTICS.UI:SetVisible(showModule, exportMode)
    CraftSim.STATISTICS.frameWO:SetVisible(showModule and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
    CraftSim.STATISTICS.frameNO_WO:SetVisible(showModule and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
end
