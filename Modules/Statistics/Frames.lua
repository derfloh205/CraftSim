---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.STATISTICS
CraftSim.STATISTICS = CraftSim.STATISTICS

---@class CraftSim.STATISTICS.FRAMES
CraftSim.STATISTICS.FRAMES = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.STATISTICS)

function CraftSim.STATISTICS.FRAMES:Init()
    local sizeX = 900
    local sizeYExpanded = 630
    local sizeYRetracted = 350

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    CraftSim.STATISTICS.frameNO_WO = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = sizeX,
        sizeY = sizeYRetracted,
        frameID = CraftSim.CONST.FRAMES.STATISTICS,
        title = L(CraftSim.CONST.TEXT.STATISTICS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        initialStatusID = "RETRACTED",
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
        sizeY = sizeYRetracted,
        frameID = CraftSim.CONST.FRAMES.STATISTICS_WORKORDER,
        title = L(CraftSim.CONST.TEXT.STATISTICS_TITLE) ..
            " " .. GUTIL:ColorizeText("WO", GUTIL.COLORS.GREY),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        initialStatusID = "RETRACTED",
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_STATISTICS"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })


    local function createContent(frame)
        frame:SetStatusList({
            {
                statusID = "RETRACTED",
                sizeY = sizeYRetracted,
            },
            {
                statusID = "EXPANDED",
                sizeY = sizeYExpanded,
            },
        })

        frame:Hide()

        ---@type GGUI.Text | GGUI.Widget
        frame.content.expectedProfitTitle = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetY = -30,
            text = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT)
        })
        ---@type GGUI.Text | GGUI.Widget
        frame.content.expectedProfitValue = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.expectedProfitTitle.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetY = -10,
        })
        ---@type GGUI.Text | GGUI.Widget
        frame.content.craftsTextTop = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.expectedProfitValue.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetY = -30,
            text = L(CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF) ..
                GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.STATISTICS_PROFIT) .. " > 0",
                    GUTIL.COLORS.GREEN) .. L(CraftSim.CONST.TEXT.STATISTICS_AFTER),
        })

        ---@type GGUI.NumericInput
        frame.content.numCraftsInput = GGUI.NumericInput({
            parent = frame.content,
            anchorParent = frame.content.craftsTextTop.frame,
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
                CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
            end
        })

        frame.content.cdfExplanation = GGUI.HelpIcon({
            parent = frame.content,
            anchorParent = frame.content.numCraftsInput.textInput.frame,
            text = L(CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION),
            anchorA = "RIGHT",
            anchorB = "LEFT",
            offsetX = -10,
            offsetY = 1,
        })

        ---@type GGUI.Text | GGUI.Widget
        frame.content.craftsTextBottom = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.numCraftsInput.textInput.frame,
            offsetX = 20,
            text = L(CraftSim.CONST.TEXT.STATISTICS_CRAFTS),
            anchorA = "LEFT",
            anchorB = "RIGHT",
        })

        ---@type GGUI.Text | GGUI.Widget
        frame.content.probabilityValue = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.craftsTextBottom.frame,
            offsetX = 1,
            text = "0%",
            justifyOptions = { type = "H", align = "LEFT" },
            anchorA = "LEFT",
            anchorB = "RIGHT",
        })

        frame.content.chanceByQualityTable = GGUI.FrameList({
            parent = frame.content,
            anchorParent = frame.content.craftsTextTop.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetY = -60,
            showBorder = true,
            sizeY = 130,
            columnOptions = {
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER),
                    width = 60,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER),
                    width = 70,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_CRAFTS_HEADER),
                    width = 130,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_HEADER),
                    width = 170,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_CHANCE_MIN_HEADER),
                    width = 70,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_CRAFTS_MIN_HEADER),
                    width = 130,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_MIN_HEADER),
                    width = 170,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
            },
            rowConstructor = function(columns)
                local qualityRow = columns[1]
                local chanceRow = columns[2]
                local craftsRow = columns[3]
                local expectedCostsRow = columns[4]
                local chanceMinRow = columns[5]
                local craftsMinRow = columns[6]
                local expectedCostsMinRow = columns[7]

                qualityRow.text = GGUI.Text({
                    parent = qualityRow, anchorParent = qualityRow,
                })
                function qualityRow:SetQuality(qualityID)
                    if qualityID then
                        qualityRow.text:SetText(GUTIL:GetQualityIconString(qualityID, 25, 25))
                    else
                        qualityRow.text:SetText("")
                    end
                end

                chanceRow.text = GGUI.Text({
                    parent = chanceRow, anchorParent = chanceRow,
                })

                craftsRow.text = GGUI.Text({
                    parent = craftsRow, anchorParent = craftsRow
                })

                expectedCostsRow.text = GGUI.Text({
                    parent = expectedCostsRow, anchorParent = expectedCostsRow,
                })

                chanceMinRow.text = GGUI.Text({
                    parent = chanceMinRow, anchorParent = chanceMinRow,
                })

                craftsMinRow.text = GGUI.Text({
                    parent = craftsMinRow, anchorParent = craftsMinRow
                })

                expectedCostsMinRow.text = GGUI.Text({
                    parent = expectedCostsMinRow, anchorParent = expectedCostsMinRow,
                })
            end
        })

        frame.content.statisticsExplanationIcon = GGUI.HelpIcon(
            {
                parent = frame.content,
                anchorParent = frame.content.chanceByQualityTable.frame,
                anchorA = "BOTTOMLEFT",
                anchorB = "TOPRIGHT",
                text = L(CraftSim.CONST.TEXT.STATISTICS_EXPLANATION_ICON),
                offsetY = 5,
                offsetX = -3
            })

        frame.content.expandButton = GGUI.Button({
            parent = frame.content,
            anchorParent = frame.frame,
            anchorA = "BOTTOM",
            anchorB = "BOTTOM",
            label = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4),
            sizeX = 15,
            sizeY = 20,
            offsetY = 10,
            adjustWidth = true,
            initialStatusID = "DOWN",
            clickCallback = function()
                if frame:GetStatus() == "RETRACTED" then
                    frame:SetStatus("EXPANDED")
                    frame.content.expandButton:SetStatus("UP")
                    frame.content.expandFrame:Show()
                elseif frame:GetStatus() == "EXPANDED" then
                    frame:SetStatus("RETRACTED")
                    frame.content.expandButton:SetStatus("DOWN")
                    frame.content.expandFrame:Hide()
                end
            end
        })



        frame.content.expandButton:SetStatusList({
            {
                statusID = "UP",
                label = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_UP, 0.4),
            },
            {
                statusID = "DOWN",
                label = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4),
            }
        })

        frame.content.expandFrame = CreateFrame("Frame", nil, frame.content)
        local expandFrame = frame.content.expandFrame
        expandFrame:SetSize(frame:GetWidth(), sizeYExpanded - sizeYRetracted)
        expandFrame:SetPoint("TOP", frame.content, "TOP", 0, -sizeYRetracted)
        expandFrame:Hide()

        expandFrame.probabilityTableTitle = GGUI.Text({
            parent = expandFrame,
            anchorParent = expandFrame,
            anchorA = "TOP",
            anchorB = "TOP",
            text = L(CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE)
        })

        GGUI.HelpIcon({
            parent = expandFrame,
            anchorParent = expandFrame.probabilityTableTitle.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = L(CraftSim.CONST.TEXT.PROBABILITY_TABLE_EXPLANATION)
        })

        ---@type GGUI.FrameList | GGUI.Widget
        expandFrame.probabilityTable = GGUI.FrameList({
            parent = expandFrame,
            sizeY = 188,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            anchorParent = expandFrame.probabilityTableTitle.frame,
            showBorder = true,
            offsetY = -30,
            columnOptions = {
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER),
                    width = 70,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_INSPIRATION_HEADER),
                    width = 80,
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
                    label = L(CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT),
                    width = 70,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP),
                    width = 70,
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = L(CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER),
                    width = 120,
                },
            },
            rowConstructor = function(columns)
                local chanceColumn = columns[1]
                local inspirationColumn = columns[2]
                local multicraftColumn = columns[3]
                local resourcefulnessColumn = columns[4]
                local hsvNextColumn = columns[5]
                local hsvSkipColumn = columns[6]
                local profitColumn = columns[7]

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
                    text = GUTIL:FormatMoney(11312313, true),
                    justifyOptions = { type = "H", align = "LEFT" },
                })

                local booleanColumns = { inspirationColumn, multicraftColumn, resourcefulnessColumn, hsvNextColumn,
                    hsvSkipColumn }

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

    createContent(CraftSim.STATISTICS.frameNO_WO)
    createContent(CraftSim.STATISTICS.frameWO)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
    local statisticsFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.STATISTICS)
    local meanProfit, probabilityTable = recipeData:GetAverageProfit()

    if not probabilityTable then
        return
    end

    statisticsFrame.content.chanceByQualityTable:Remove()

    for qualityID, chance in pairs(recipeData.resultData.chanceByQuality) do
        local expectedCrafts = nil
        local expectedCraftsMin = nil
        local chanceMin = recipeData.resultData.chancebyMinimumQuality[qualityID]
        if chanceMin == 0 or recipeData.resultData.expectedCraftsByMinimumQuality[qualityID] == nil then
            expectedCraftsMin = "-"
        else
            expectedCraftsMin = GUTIL:Round(recipeData.resultData.expectedCraftsByMinimumQuality[qualityID], 2)
        end
        if chance == 0 or recipeData.resultData.expectedCraftsByQuality[qualityID] == nil then
            expectedCrafts = "-"
        else
            expectedCrafts = GUTIL:Round(recipeData.resultData.expectedCraftsByQuality[qualityID], 2)
        end

        statisticsFrame.content.chanceByQualityTable:Add(function(row, columns)
            local qualityRow = columns[1]
            local chanceRow = columns[2]
            local craftsRow = columns[3]
            local expectedCostsRow = columns[4]
            local chanceMinRow = columns[5]
            local craftsMinRow = columns[6]
            local expectedCostsMinRow = columns[7]

            qualityRow:SetQuality(qualityID)
            chanceRow.text:SetText(GUTIL:Round(chance * 100, 2) .. "%")
            chanceMinRow.text:SetText(GUTIL:Round(chanceMin * 100, 2) .. "%")
            craftsRow.text:SetText(expectedCrafts)
            craftsMinRow.text:SetText(expectedCraftsMin)

            local expectedCostsForQuality = recipeData.priceData.expectedCostsByQuality[qualityID]
            local expectedCostsForQualityMin = recipeData.priceData.expectedCostsByMinimumQuality[qualityID]

            if expectedCostsForQuality then
                expectedCostsRow.text:SetText(GUTIL:ColorizeText(GUTIL:FormatMoney(expectedCostsForQuality),
                    GUTIL.COLORS.RED))
            else
                expectedCostsRow.text:SetText("-")
            end

            if expectedCostsForQualityMin then
                expectedCostsMinRow.text:SetText(GUTIL:ColorizeText(GUTIL:FormatMoney(expectedCostsForQualityMin),
                    GUTIL.COLORS.RED))
            else
                expectedCostsMinRow.text:SetText("-")
            end
        end)
    end

    statisticsFrame.content.chanceByQualityTable:UpdateDisplay()


    statisticsFrame.content.expandFrame.probabilityTable:Remove()

    for _, probabilityInfo in pairs(probabilityTable) do
        statisticsFrame.content.expandFrame.probabilityTable:Add(function(row)
            local chanceColumn = row.columns[1]
            local inspirationColumn = row.columns[2]
            local multicraftColumn = row.columns[3]
            local resourcefulnessColumn = row.columns[4]
            local hsvNextColumn = row.columns[5]
            local hsvSkipColumn = row.columns[6]
            local profitColumn = row.columns[7]

            row.chance = probabilityInfo.chance
            chanceColumn.text:SetText(GUTIL:Round(row.chance * 100, 2) .. "%")
            profitColumn.text:SetText(GUTIL:FormatMoney(probabilityInfo.profit, true))

            if recipeData.supportsInspiration then
                inspirationColumn:SetChecked(probabilityInfo.inspiration)

                if recipeData.resultData.hsvInfo.chanceNextQuality > 0 then
                    hsvNextColumn:SetChecked(probabilityInfo.hsvNext)
                else
                    hsvNextColumn:SetIrrelevant()
                end

                if recipeData.resultData.hsvInfo.chanceSkipQuality > 0 then
                    hsvSkipColumn:SetChecked(probabilityInfo.hsvSkip)
                else
                    hsvSkipColumn:SetIrrelevant()
                end
            else
                inspirationColumn:SetIrrelevant()
                hsvNextColumn:SetIrrelevant()
                hsvSkipColumn:SetIrrelevant()
            end
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

    statisticsFrame.content.expandFrame.probabilityTable:UpdateDisplay(function(rowA, rowB)
        return rowA.chance > rowB.chance
    end)

    local numCrafts = statisticsFrame.content.numCraftsInput.currentValue

    local probabilityPositive = CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable, numCrafts)

    statisticsFrame.content.expectedProfitValue:SetText(GUTIL:FormatMoney(meanProfit, true))
    local roundedProfit = GUTIL:Round(probabilityPositive * 100, 5)
    if probabilityPositive == 1 then
        -- if e.g. every craft has a positive outcome
        roundedProfit = "100.00000"
    elseif tonumber(roundedProfit) >= 100 then
        -- if the probability is not 1 but the rounded is 100 then show that there is a smaaaall chance of failure
        roundedProfit = ">99.99999"
    end
    statisticsFrame.content.probabilityValue:SetText(roundedProfit .. "%")
end

function CraftSim.STATISTICS.FRAMES:SetVisible(showModule, exportMode)
    CraftSim.STATISTICS.frameWO:SetVisible(showModule and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
    CraftSim.STATISTICS.frameNO_WO:SetVisible(showModule and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
end
