_, CraftSim = ...

CraftSim.STATISTICS.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.STATISTICS)

function CraftSim.STATISTICS.FRAMES:Init()
    local sizeX = 700
    local sizeY = 400

    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS).frame, 
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.STATISTICS, 
        title="CraftSim Statistics",
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
    })

    local frameWO = CraftSim.GGUI.Frame({
        parent=CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER).frame, 
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.STATISTICS_WORKORDER, 
        title="CraftSim Statistics " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
    })


    local function createContent(frame)

        frame:Hide()

        ---@type GGUI.FrameList | GGUI.Widget
        frame.content.probabilityTable = CraftSim.GGUI.FrameList({
            parent=frame.content, 
            sizeY=170, anchorA="TOP", anchorB="BOTTOM", anchorParent=frame.title.frame,
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

        ---@type GGUI.Text | GGUI.Widget
        frame.content.expectedProfitTitle = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content.probabilityTable.frame,
            anchorA="TOP", anchorB="BOTTOM", offsetY=-30, text="Expected Profit (μ)"
        })
        ---@type GGUI.Text | GGUI.Widget
        frame.content.expectedProfitValue = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content.expectedProfitTitle.frame,
            anchorA="TOP", anchorB="BOTTOM", offsetY=-10,
        })

        frame.content.craftsTextTop = CraftSim.FRAME:CreateText("Chance of " .. CraftSim.GUTIL:ColorizeText("Profit > 0", CraftSim.GUTIL.COLORS.GREEN) .. " after", frame.content, frame.content.expectedProfitValue.frame, "TOP", "BOTTOM", 0, -30)
        frame.content.numCraftsInput = CraftSim.FRAME:CreateNumericInput(nil, frame.content, frame.content.craftsTextTop, "TOP", "BOTTOM", -40, -10, 50, 25, 1, false, function() 
            local recipeData = CraftSim.MAIN.currentRecipeData
            if not recipeData then
                return
            end
            CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
        end)
        frame.content.cdfExplanation = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION), frame.content, frame.content.numCraftsInput, "RIGHT", "LEFT", -10, 1)
        frame.content.craftsTextBottom = CraftSim.FRAME:CreateText("Crafts: ", frame.content, frame.content.numCraftsInput, "LEFT", "RIGHT", 20, 0)
        frame.content.probabilityValue = CraftSim.FRAME:CreateText("0%", frame.content, frame.content.craftsTextBottom, "LEFT", "RIGHT", 1, 0, nil, nil, {type="H", value="LEFT"})
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


    statisticsFrame.content.probabilityTable:Remove()

    for _, probabilityInfo in pairs(probabilityTable) do
        statisticsFrame.content.probabilityTable:Add(function(row) 
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

    statisticsFrame.content.probabilityTable:UpdateDisplay(function (rowA, rowB)
        return rowA.chance > rowB.chance
    end)

    -- probabilityTable = CraftSim.GUTIL:Sort(probabilityTable, function(a, b) 
    --     return a.chance >= b.chance
    -- end)

    local numCrafts = CraftSim.UTIL:ValidateNumberInput(statisticsFrame.content.numCraftsInput, false)

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