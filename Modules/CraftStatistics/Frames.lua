_, CraftSim = ...

CraftSim.STATISTICS.FRAMES = {}

function CraftSim.STATISTICS.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimStatisticsFrame", 
        "CraftSim Statistics", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        UIParent, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        350,
        350,
        CraftSim.CONST.FRAMES.STATISTICS, false, true, "DIALOG", "modulesStatistics")


    local function createContent(frame)

        frame.content.expectedProfitTitle = CraftSim.FRAME:CreateText("Expected Profit (μ)", frame.content, frame.title, "TOP", "TOP", 0, -30)
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

    local numCrafts = CraftSim.UTIL:ValidateNumberInput(statisticsFrame.content.numCraftsInput, false)

    local MAX_N = 1000

    if numCrafts > MAX_N then
        numCrafts = MAX_N
        statisticsFrame.content.numCraftsInput:SetText(MAX_N)
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