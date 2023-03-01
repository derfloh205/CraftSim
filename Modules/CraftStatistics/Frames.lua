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

        frame.content.scrollFrame, frame.content.probabilityTableFrame = CraftSim.FRAME:CreateScrollFrame(frame.content, -200, 50, -50, 300)
        frame.content.probabilityTableHeaderChance = CraftSim.FRAME:CreateText(
            "Chance", 
        frame.content, frame.content.scrollFrame, "BOTTOMLEFT", "TOPLEFT", 10, 10, nil, nil)

        frame.content.probabilityTableHeaderInspiration = CraftSim.FRAME:CreateText(
            "Inspiration", 
        frame.content, frame.content.probabilityTableHeaderChance, "LEFT", "RIGHT", 10, 0, nil, nil)

        frame.content.probabilityTableHeaderMulticraft = CraftSim.FRAME:CreateText(
        "Multicraft", 
        frame.content, frame.content.probabilityTableHeaderInspiration, "LEFT", "RIGHT", 10, 0, nil, nil)

        frame.content.probabilityTableHeaderResourcefulness = CraftSim.FRAME:CreateText(
        "Resourcefulness", 
        frame.content, frame.content.probabilityTableHeaderMulticraft, "LEFT", "RIGHT", 10, 0, nil, nil)

        frame.content.probabilityTableHeaderHSV = CraftSim.FRAME:CreateText(
        "HSV", 
        frame.content, frame.content.probabilityTableHeaderResourcefulness, "LEFT", "RIGHT", 10, 0, nil, nil)

        frame.content.probabilityTableHeaderHSV.helperIcon = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.HSV_EXPLANATION), 
            frame.content, frame.content.probabilityTableHeaderHSV, "BOTTOM", "TOP", 0, 10)

        frame.content.probabilityTableHeaderProfit = CraftSim.FRAME:CreateText(
        "Expected Profit", 
        frame.content, frame.content.probabilityTableHeaderHSV, "LEFT", "RIGHT", 10, 0, nil, nil)

        frame.content.probabilityTableFrame.tableRows = {}
        local function createTableRow(offsetX, offsetY)
            local row = CreateFrame("Frame", nil, frame.content.probabilityTableFrame)
            row:SetSize(frame.content.probabilityTableFrame:GetWidth(), 25)
            row:SetPoint("TOPLEFT", frame.content.probabilityTableFrame, "TOPLEFT", offsetX, offsetY)

            row.chance = CraftSim.FRAME:CreateText(
            "70%", 
            row, row, "TOPLEFT", "TOPLEFT", 5, 0, nil, nil, {type="H", value="RIGHT"})
            row.chance:SetSize(50, 25)

            local boolRowWidth = 20

            row.inspiration = CraftSim.FRAME:CreateText(
            CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125), 
            row, row.chance, "LEFT", "RIGHT", 42, 0, nil, nil)
            row.inspiration:SetSize(boolRowWidth, 25)

            row.multicraft = CraftSim.FRAME:CreateText(
            CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125),  
            row, row.inspiration, "LEFT", "RIGHT", 55, 0, nil, nil)
            row.multicraft:SetSize(boolRowWidth, 25)

            row.resourcefulness = CraftSim.FRAME:CreateText(
            CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125),  
            row, row.multicraft, "LEFT", "RIGHT", 75, 0, nil, nil)
            row.resourcefulness:SetSize(boolRowWidth, 25)

            row.hsv = CraftSim.FRAME:CreateText(
            CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125),  
            row, row.resourcefulness, "LEFT", "RIGHT", 55, 0, nil, nil)
            row.hsv:SetSize(boolRowWidth, 25)

            row.profit = CraftSim.FRAME:CreateText(
            CraftSim.GUTIL:FormatMoney(10000000, true), 
            row, row.hsv, "LEFT", "RIGHT", 15, 0, nil, nil, {type="H", value="LEFT"})
            row.profit:SetSize(200, 25)

            return row
        end

        local numRows = 16
        local rowOffsetY = -20
        local rowOffsetX = 0

        for i = 1, numRows, 1 do
            table.insert(frame.content.probabilityTableFrame.tableRows, createTableRow(rowOffsetX, rowOffsetY*(i-1)))
        end

        frame.content.expectedProfitTitle = CraftSim.FRAME:CreateText("Expected Profit (μ)", frame.content, frame.content.scrollFrame, "TOP", "BOTTOM", 0, -30)
        frame.content.expectedProfitValue = CraftSim.FRAME:CreateText(CraftSim.GUTIL:FormatMoney(0, true), frame.content, frame.content.expectedProfitTitle, "TOP", "BOTTOM", 0, -10)
        frame.content.craftsTextTop = CraftSim.FRAME:CreateText("Chance of " .. CraftSim.GUTIL:ColorizeText("Profit > 0", CraftSim.GUTIL.COLORS.GREEN) .. " after", frame.content, frame.content.expectedProfitValue, "TOP", "BOTTOM", 0, -30)
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

function CraftSim.STATISTICS.FRAMES:UpdateDisplay(recipeData)
    local statisticsFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.STATISTICS)
    local meanProfit, probabilityTable = CraftSim.CALC:GetAverageProfit(recipeData)

    if not probabilityTable then
        return
    end

    probabilityTable = CraftSim.GUTIL:Sort(probabilityTable, function(a, b) 
        return a.chance >= b.chance
    end)

    local numCrafts = CraftSim.UTIL:ValidateNumberInput(statisticsFrame.content.numCraftsInput, false)

    local probabilityRows = statisticsFrame.content.probabilityTableFrame.tableRows
    for index, row in pairs(probabilityRows) do
        if not probabilityTable then
            row:Hide()
        else
            local probabilityEntry = probabilityTable[index]
            if not probabilityEntry then
                row:Hide()
            else
                row:Show()
                local check = CraftSim.GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125), CraftSim.GUTIL.COLORS.GREEN)
                local cross = CraftSim.GUTIL:ColorizeText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.125), CraftSim.GUTIL.COLORS.RED)
                local isNot = CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY)
                if probabilityEntry.inspiration ~= nil then
                    row.inspiration:SetText(probabilityEntry.inspiration and check or cross)
                else
                    row.inspiration:SetText(isNot)
                end
    
                if probabilityEntry.multicraft ~= nil then
                    row.multicraft:SetText(probabilityEntry.multicraft and check or cross)
                else
                    row.multicraft:SetText(isNot)
                end
    
                if probabilityEntry.resourcefulness ~= nil then
                    row.resourcefulness:SetText(probabilityEntry.resourcefulness and check or cross)
                else
                    row.resourcefulness:SetText(isNot)
                end

                if probabilityEntry.hsv ~= nil then
                    row.hsv:SetText(probabilityEntry.hsv and check or cross)
                else
                    row.hsv:SetText(isNot)
                end
                
                row.chance:SetText(CraftSim.GUTIL:Round(probabilityEntry.chance*100, 2) .. "%")
                row.profit:SetText(CraftSim.GUTIL:FormatMoney(probabilityEntry.profit, true))
            end
        end
    end

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