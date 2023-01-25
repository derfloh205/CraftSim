_, CraftSim = ...

CraftSim.STATISTICS.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.STATISTICS)

function CraftSim.STATISTICS.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimStatisticsFrame", 
        "CraftSim Profit Statistics", 
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STAT_WEIGHTS),
        UIParent, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        600,
        400,
        CraftSim.CONST.FRAMES.STATISTICS, false, true, "DIALOG")


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

        frame.content.probabilityTableHeaderProfit = CraftSim.FRAME:CreateText(
        "Expected Profit", 
        frame.content, frame.content.probabilityTableHeaderResourcefulness, "LEFT", "RIGHT", 10, 0, nil, nil)

        frame.content.probabilityTableFrame.tableRows = {}
        local function createTableRow(offsetX, offsetY)
            local row = CreateFrame("Frame", nil, frame.content.probabilityTableFrame)
            row:SetSize(frame.content.probabilityTableFrame:GetWidth(), 25)
            row:SetPoint("TOPLEFT", frame.content.probabilityTableFrame, "TOPLEFT", offsetX, offsetY)

            row.chance = CraftSim.FRAME:CreateText(
            "70%", 
            row, row, "TOPLEFT", "TOPLEFT", 5, 0, nil, nil, {type="H", value="RIGHT"})
            row.chance:SetSize(50, 25)

            row.inspiration = CraftSim.FRAME:CreateText(
            "T", 
            row, row.chance, "LEFT", "RIGHT", 42, 0, nil, nil)

            row.multicraft = CraftSim.FRAME:CreateText(
            "T", 
            row, row.inspiration, "LEFT", "RIGHT", 70, 0, nil, nil)

            row.resourcefulness = CraftSim.FRAME:CreateText(
            "T", 
            row, row.multicraft, "LEFT", "RIGHT", 85, 0, nil, nil)

            row.profit = CraftSim.FRAME:CreateText(
            CraftSim.UTIL:FormatMoney(10000000, true), 
            row, row.resourcefulness, "LEFT", "RIGHT", 60, 0, nil, nil, {type="H", value="LEFT"})
            row.profit:SetSize(200, 25)

            return row
        end

        local numRows = 8
        local rowOffsetY = -20
        local rowOffsetX = 0

        for i = 1, numRows, 1 do
            table.insert(frame.content.probabilityTableFrame.tableRows, createTableRow(rowOffsetX, rowOffsetY*(i-1)))
        end

        frame.content.expectedProfitTitle = CraftSim.FRAME:CreateText("Expected Profit (μ)", frame.content, frame.content.scrollFrame, "TOP", "BOTTOM", 0, -30)
        frame.content.expectedProfitValue = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(0, true), frame.content, frame.content.expectedProfitTitle, "TOP", "BOTTOM", 0, -10)
        frame.content.craftsTextTop = CraftSim.FRAME:CreateText("Chance of " .. CraftSim.UTIL:ColorizeText("Profit > 0", CraftSim.CONST.COLORS.GREEN) .. " after", frame.content, frame.content.expectedProfitValue, "TOP", "BOTTOM", 0, -30)
        frame.content.numCraftsInput = CraftSim.FRAME:CreateNumericInput(nil, frame.content, frame.content.craftsTextTop, "TOP", "BOTTOM", -40, -10, 50, 25, 1, false, function() 
            local recipeData = CraftSim.MAIN.currentRecipeData
            if not recipeData then
                return
            end
            local priceData = CraftSim.PRICEDATA:GetPriceData(recipeData, recipeData.recipeType)
            if not priceData then
                return
            end
            CraftSim.STATISTICS.FRAMES:UpdateStatistics(recipeData, priceData)
        end)
        frame.content.craftsTextBottom = CraftSim.FRAME:CreateText("Crafts: ", frame.content, frame.content.numCraftsInput, "LEFT", "RIGHT", 20, 0)
        frame.content.probabilityValue = CraftSim.FRAME:CreateText("0%", frame.content, frame.content.craftsTextBottom, "LEFT", "RIGHT", 1, 0, nil, nil, {type="H", value="LEFT"})
    end

    createContent(frameNO_WO)
end

function CraftSim.STATISTICS.FRAMES:UpdateStatistics(recipeData, priceData)
    local statisticsFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.STATISTICS)
    local meanProfit, probabilityTable = CraftSim.CALC:getMeanProfitV2(recipeData, priceData)

    if not probabilityTable then
        return
    end

    probabilityTable = CraftSim.UTIL:Sort(probabilityTable, function(a, b) 
        return a.chance >= b.chance
    end)

    local numCrafts = CraftSim.UTIL:ValidateNumberInput(statisticsFrame.content.numCraftsInput, false)

    local MAX_N = 1000

    if numCrafts > MAX_N then
        numCrafts = MAX_N
        statisticsFrame.content.numCraftsInput:SetText(MAX_N)
    end

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
                local check = CraftSim.UTIL:ColorizeText("T", CraftSim.CONST.COLORS.GREEN)
                local cross = CraftSim.UTIL:ColorizeText("X", CraftSim.CONST.COLORS.RED)
                local isNot = CraftSim.UTIL:ColorizeText("-", CraftSim.CONST.COLORS.GREY)
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
                
                row.chance:SetText(CraftSim.UTIL:round(probabilityEntry.chance*100, 2) .. "%")
                row.profit:SetText(CraftSim.UTIL:FormatMoney(probabilityEntry.profit, true))
            end
        end
    end

    local probabilityPositive = CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable, numCrafts)

    statisticsFrame.content.expectedProfitValue:SetText(CraftSim.UTIL:FormatMoney(meanProfit, true))
    local roundedProfit = CraftSim.UTIL:round(probabilityPositive * 100, 5)
    if probabilityPositive == 1 then
        -- if e.g. every craft has a positive outcome
        roundedProfit = "100.00000"
    elseif tonumber(roundedProfit) >= 100 then
        -- if the probability is not 1 but the rounded is 100 then show that there is a smaaaall chance of failure
        roundedProfit = ">99.99999"
    end
    statisticsFrame.content.probabilityValue:SetText(roundedProfit .. "%")
end