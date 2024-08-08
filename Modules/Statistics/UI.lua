---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI

local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.STATISTICS
CraftSim.STATISTICS = CraftSim.STATISTICS

---@class CraftSim.STATISTICS.UI
CraftSim.STATISTICS.UI = {}

local print = CraftSim.DEBUG:SetDebugPrint("STATISTICS")

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
            " " .. GUTIL:ColorizeText("WO", GUTIL.COLORS.GREY),
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
                label = "Probability Table",
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
                label = "Concentration",

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
        --self:InitConcentrationTab(frame.content.concentrationTab)

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
        offsetY = -180,
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
                text = GUTIL:FormatMoney(11312313, true),
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

---@param recipeData CraftSim.RecipeData
function CraftSim.STATISTICS.UI:UpdateDisplay(recipeData)
    local statisticsFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.STATISTICS)
    local meanProfit, probabilityTable = recipeData:GetAverageProfit()

    if not probabilityTable or not statisticsFrame then
        return
    end

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
            profitColumn.text:SetText(GUTIL:FormatMoney(probabilityInfo.profit, true))

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

    local probabilityPositive = CraftSim.STATISTICS:GetProbabilityOfPositiveProfitByCrafts(probabilityTable, numCrafts)

    content.expectedProfitValue:SetText(GUTIL:FormatMoney(meanProfit, true))
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

function CraftSim.STATISTICS.UI:SetVisible(showModule, exportMode)
    CraftSim.STATISTICS.frameWO:SetVisible(showModule and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
    CraftSim.STATISTICS.frameNO_WO:SetVisible(showModule and exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER)
end
