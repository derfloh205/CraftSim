_, CraftSim = ...

CraftSim.STATISTICS.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.STATISTICS)

function CraftSim.STATISTICS.FRAMES:Init()
    local sizeX = 700
    local sizeYExpanded = 630
    local sizeYRetracted = 350 

    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS).frame, 
        sizeX=sizeX,sizeY=sizeYRetracted,
        frameID=CraftSim.CONST.FRAMES.STATISTICS, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STATISTICS_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
        initialStatusID="RETRACTED",
    })

    local frameWO = CraftSim.GGUI.Frame({
        parent=CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER).frame, 
        sizeX=sizeX,sizeY=sizeYRetracted,
        frameID=CraftSim.CONST.FRAMES.STATISTICS_WORKORDER, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STATISTICS_TITLE) .. " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
        initialStatusID="RETRACTED",
    })


    local function createContent(frame)

        frame:SetStatusList({
            {
                statusID="RETRACTED",
                sizeY=sizeYRetracted,
            },
            {
                statusID="EXPANDED",
                sizeY=sizeYExpanded,
            },
        })

        frame:Hide()

        ---@type GGUI.Text | GGUI.Widget
        frame.content.expectedProfitTitle = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.title.frame,
            anchorA="TOP", anchorB="BOTTOM", offsetY=-30, text="Expected Profit (μ)"
        })
        ---@type GGUI.Text | GGUI.Widget
        frame.content.expectedProfitValue = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content.expectedProfitTitle.frame,
            anchorA="TOP", anchorB="BOTTOM", offsetY=-10,
        })
        ---@type GGUI.Text | GGUI.Widget
        frame.content.craftsTextTop = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content.expectedProfitValue.frame,
            anchorA="TOP", anchorB="BOTTOM", offsetY=-30, 
            text="Chance of " .. CraftSim.GUTIL:ColorizeText("Profit > 0", CraftSim.GUTIL.COLORS.GREEN) .. " after",
        })

        ---@type GGUI.NumericInput
        frame.content.numCraftsInput = CraftSim.GGUI.NumericInput({
            parent=frame.content, anchorParent=frame.content.craftsTextTop.frame,
            anchorA="TOP",anchorB="BOTTOM", offsetX=-40, offsetY=-10, sizeX=50, sizeY=25, initialValue=1,
            allowDecimals=false, minValue=1, incrementOneButtons=true,borderAdjustWidth=1.15, borderAdjustHeight=1.05,
            onNumberValidCallback = function ()
                local recipeData = CraftSim.MAIN.currentRecipeData
                if not recipeData then
                    return
                end
                CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
            end
        })

        frame.content.cdfExplanation = CraftSim.GGUI.HelpIcon({
            parent=frame.content,anchorParent=frame.content.numCraftsInput.textInput.frame,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION), anchorA="RIGHT", anchorB="LEFT", offsetX=-10, offsetY=1,
        })

        ---@type GGUI.Text | GGUI.Widget
        frame.content.craftsTextBottom = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.numCraftsInput.textInput.frame, offsetX=20,
            text="Crafts: ", anchorA="LEFT", anchorB="RIGHT",
        })

        ---@type GGUI.Text | GGUI.Widget
        frame.content.probabilityValue = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.content.craftsTextBottom.frame, offsetX=1,
            text="0%", justifyOptions= {type="H", align="LEFT"}, anchorA="LEFT", anchorB="RIGHT",
        })

        frame.content.chanceByQualityTable = CraftSim.GGUI.FrameList({
            parent=frame.content, anchorParent=frame.content.craftsTextTop.frame, anchorA="TOP", anchorB="BOTTOM", offsetY=-60,
            showHeaderLine=true, sizeY=130,
            columnOptions={
                {
                    label="Quality",
                    width=60,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="Chance",
                    width=60,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="Expected Crafts",
                    width=100,
                    justifyOptions={type="H", align="CENTER"},
                }
            },
            rowConstructor=function (columns)
                local qualityRow = columns[1]
                local chanceRow = columns[2]
                local craftsRow = columns[3]

                qualityRow.text = CraftSim.GGUI.Text({
                    parent=qualityRow,anchorParent=qualityRow,
                })
                function qualityRow:SetQuality(qualityID)
                    if qualityID then
                        qualityRow.text:SetText(CraftSim.GUTIL:GetQualityIconString(qualityID, 25, 25))
                    else
                        qualityRow.text:SetText("")
                    end
                end

                chanceRow.text = CraftSim.GGUI.Text({
                    parent=chanceRow, anchorParent=chanceRow,
                })

                craftsRow.text = CraftSim.GGUI.Text({
                    parent=craftsRow, anchorParent=craftsRow
                })
            end
        })

        frame.content.expandButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.frame, anchorA="BOTTOM", anchorB="BOTTOM",
            label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4), sizeX=15, sizeY=20, offsetY=10, adjustWidth = true,
            initialStatusID="DOWN",
            clickCallback=function ()
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
                statusID="UP",
                label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_UP, 0.4),
            },
            {
                statusID="DOWN",
                label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4),
            }
        })

        frame.content.expandFrame = CreateFrame("Frame", nil, frame.content)
        local expandFrame = frame.content.expandFrame
        expandFrame:SetSize(frame:GetWidth(), sizeYExpanded - sizeYRetracted)
        expandFrame:SetPoint("TOP", frame.content, "TOP", 0, - sizeYRetracted)
        expandFrame:Hide()

        expandFrame.probabilityTableTitle = CraftSim.GGUI.Text({
            parent=expandFrame, anchorParent=expandFrame, anchorA="TOP", anchorB="TOP",
            text="Recipe Probability Table"
        })

        CraftSim.GGUI.HelpIcon({
            parent=expandFrame, anchorParent=expandFrame.probabilityTableTitle.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=5,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.PROBABILITY_TABLE_EXPLANATION)
        })

        ---@type GGUI.FrameList | GGUI.Widget
        expandFrame.probabilityTable = CraftSim.GGUI.FrameList({
            parent=expandFrame, 
            sizeY=188, anchorA="TOP", anchorB="BOTTOM", anchorParent=expandFrame.probabilityTableTitle.frame,
            showHeaderLine = true, offsetY=-30,
            columnOptions={
                {
                    label="Chance",
                    width=60,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="Inspiration",
                    width=80,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="Multicraft",
                    width=80,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="Resourcefulness",
                    width=110,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="HSV Next",
                    width=70,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="HSV Skip",
                    width=70,
                    justifyOptions={type="H", align="CENTER"},
                },
                {
                    label="Expected Profit",
                    width=120,
                },
            },
            rowConstructor=function (columns)
                local chanceColumn = columns[1]
                local inspirationColumn = columns[2]
                local multicraftColumn = columns[3]
                local resourcefulnessColumn = columns[4]
                local hsvNextColumn = columns[5]
                local hsvSkipColumn = columns[6]
                local profitColumn = columns[7]
    
                ---@type GGUI.Text | GGUI.Widget
                chanceColumn.text = CraftSim.GGUI.Text({
                    parent=chanceColumn, anchorParent=chanceColumn,
                    text="100%", justifyOptions={type="H", align="CENTER"},
                })

                ---@type GGUI.Text | GGUI.Widget
                profitColumn.text = CraftSim.GGUI.Text({
                    parent=profitColumn, anchorParent=profitColumn,
                    text=CraftSim.GUTIL:FormatMoney(11312313, true), justifyOptions={type="H", align="LEFT"},
                })

                local booleanColumns = {inspirationColumn, multicraftColumn, resourcefulnessColumn, hsvNextColumn, hsvSkipColumn}

                local check = CraftSim.GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125), CraftSim.GUTIL.COLORS.GREEN)
                local cross = CraftSim.GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.125), CraftSim.GUTIL.COLORS.RED)
                local dash = CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY)

                for _, column in pairs(booleanColumns) do
                    ---@type GGUI.Text | GGUI.Widget
                    column.text = CraftSim.GGUI.Text({
                        parent=column, anchorParent=column,
                        text=cross, justifyOptions={type="H", align="CENTER"},
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

    createContent(frameNO_WO)
    createContent(frameWO)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
    local statisticsFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STATISTICS)
    local meanProfit, probabilityTable = CraftSim.CALC:GetAverageProfit(recipeData)

    if not probabilityTable then
        return
    end

    statisticsFrame.content.chanceByQualityTable:Remove()

    for qualityID, chance in pairs(recipeData.resultData.chanceByQuality) do
        local expectedCrafts = nil
        if chance == 0 then
            expectedCrafts = "-"
        else
            expectedCrafts = CraftSim.GUTIL:Round(recipeData.resultData.expectedCraftsByQuality[qualityID], 2)
        end

        statisticsFrame.content.chanceByQualityTable:Add(function (row) 
            local qualityRow = row.columns[1]
            local chanceRow = row.columns[2]
            local craftsRow = row.columns[3]

            qualityRow:SetQuality(qualityID)
            chanceRow.text:SetText(CraftSim.GUTIL:Round(chance*100, 2) .. "%")
            craftsRow.text:SetText(expectedCrafts)
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
            chanceColumn.text:SetText(CraftSim.GUTIL:Round(row.chance*100, 2) .. "%")
            profitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(probabilityInfo.profit, true))

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

    statisticsFrame.content.expandFrame.probabilityTable:UpdateDisplay(function (rowA, rowB)
        return rowA.chance > rowB.chance
    end)

    -- probabilityTable = CraftSim.GUTIL:Sort(probabilityTable, function(a, b) 
    --     return a.chance >= b.chance
    -- end)

    local numCrafts=statisticsFrame.content.numCraftsInput.currentValue

    -- local probabilityRows = statisticsFrame.content.probabilityTableFrame.tableRows
    -- for index, row in pairs(probabilityRows) do
    --     if not probabilityTable then
    --         row:Hide()
    --     else
    --         local probabilityEntry = probabilityTable[index]
    --         if not probabilityEntry then
    --             row:Hide()
    --         else
    --             row:Show()
    --             local check = CraftSim.GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125), CraftSim.GUTIL.COLORS.GREEN)
    --             local cross = CraftSim.GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.125), CraftSim.GUTIL.COLORS.RED)
    --             local isNot = CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY)
    --             if probabilityEntry.inspiration ~= nil then
    --                 row.inspiration:SetText(probabilityEntry.inspiration and check or cross)
    --             else
    --                 row.inspiration:SetText(isNot)
    --             end
    
    --             if probabilityEntry.multicraft ~= nil then
    --                 row.multicraft:SetText(probabilityEntry.multicraft and check or cross)
    --             else
    --                 row.multicraft:SetText(isNot)
    --             end
    
    --             if probabilityEntry.resourcefulness ~= nil then
    --                 row.resourcefulness:SetText(probabilityEntry.resourcefulness and check or cross)
    --             else
    --                 row.resourcefulness:SetText(isNot)
    --             end

    --             if probabilityEntry.hsv ~= nil then
    --                 row.hsv:SetText(probabilityEntry.hsv and check or cross)
    --             else
    --                 row.hsv:SetText(isNot)
    --             end
                
    --             row.chance:SetText(CraftSim.GUTIL:Round(probabilityEntry.chance*100, 2) .. "%")
    --             row.profit:SetText(CraftSim.GUTIL:FormatMoney(probabilityEntry.profit, true))
    --         end
    --     end
    -- end

    local probabilityPositive = CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable, numCrafts)

    statisticsFrame.content.expectedProfitValue:SetText(CraftSim.GUTIL:FormatMoney(meanProfit, true))
    local roundedProfit = CraftSim.GUTIL:Round(probabilityPositive * 100, 5)
    if probabilityPositive == 1 then
        -- if e.g. every craft has a positive outcome
        roundedProfit = "100.00000"
    elseif tonumber(roundedProfit) >= 100 then
        -- if the probability is not 1 but the rounded is 100 then show that there is a smaaaall chance of failure
        roundedProfit = ">99.99999"
    end
    statisticsFrame.content.probabilityValue:SetText(roundedProfit .. "%")
end