---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFT_RESULTS
CraftSim.CRAFT_RESULTS = CraftSim.CRAFT_RESULTS

---@class CraftSim.CRAFT_RESULTS.UI
CraftSim.CRAFT_RESULTS.UI = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)

function CraftSim.CRAFT_RESULTS.UI:Init()
    ---@class CraftSim.CRAFT_RESULTS.FRAME : GGUI.Frame
    local frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage,
        anchorParent = ProfessionsFrame.CraftingPage.CraftingOutputLog,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetY = 10,
        sizeX = 700,
        sizeY = 450,
        frameID = CraftSim.CONST.FRAMES.CRAFT_RESULTS,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_CRAFT_RESULTS"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    CraftSim.CRAFT_RESULTS.frame = frame

    local function createContent(frame)
        local tabSizeX = 700
        local tabSizeY = 450

        ---@class CraftSim.CRAFT_RESULTS.CRAFT_PROFITS_TAB : GGUI.BlizzardTab
        frame.content.craftProfitsTab = GGUI.BlizzardTab {
            buttonOptions = {
                label = "Craft Profits",
                offsetY = -3,
            },
            parent = frame.content, anchorParent = frame.content, initialTab = true,
            sizeX = tabSizeX, sizeY = tabSizeY,
            top = true,
        }

        self:InitCraftProfitsTab(frame.content.craftProfitsTab)

        ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB : GGUI.BlizzardTab
        frame.content.statisticsTrackerTab = GGUI.BlizzardTab {
            buttonOptions = {
                label = "Statistics Tracker",
                anchorParent = frame.content.craftProfitsTab.button,
                anchorA = "LEFT",
                anchorB = "RIGHT",
            },
            parent = frame.content, anchorParent = frame.content,
            sizeX = tabSizeX, sizeY = tabSizeY,
            top = true,
        }

        self:InitStatisticsTrackerTab(frame.content.statisticsTrackerTab)

        GGUI.BlizzardTabSystem { frame.content.craftProfitsTab, frame.content.statisticsTrackerTab }
    end

    createContent(frame)
    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
end

---@param craftProfitsTab CraftSim.CRAFT_RESULTS.CRAFT_PROFITS_TAB
function CraftSim.CRAFT_RESULTS.UI:InitCraftProfitsTab(craftProfitsTab)
    ---@class CraftSim.CRAFT_RESULTS.CRAFT_PROFITS_TAB
    craftProfitsTab = craftProfitsTab
    ---@class CraftSim.CRAFT_RESULTS.CRAFT_PROFITS_TAB.CONTENT : Frame
    local content = craftProfitsTab.content

    content.totalProfitAllTitle = CraftSim.FRAME:CreateText(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_SESSION_PROFIT), content, content,
        "TOP", "TOP", 140, -60, nil, nil, { type = "H", value = "LEFT" })
    content.totalProfitAllValue = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(0, true), content,
        content.totalProfitAllTitle,
        "TOPLEFT", "BOTTOMLEFT", 0, -5, nil, nil, { type = "H", value = "LEFT" })


    content.clearButton = GGUI.Button({
        parent = content,
        anchorParent = content.totalProfitAllTitle,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        offsetY = -40,
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_RESET_DATA),
        clickCallback = function()
            content.scrollingMessageFrame:Clear()
            content.craftedItemsFrame.resultFeed:SetText("")
            content.totalProfitAllValue:SetText(CraftSim.UTIL:FormatMoney(0, true))
            CraftSim.CRAFT_RESULTS:ResetData()
            CraftSim.CRAFT_RESULTS.UI:UpdateRecipeData(CraftSim.INIT.currentRecipeData.recipeID)
        end
    })

    content.exportButton = GGUI.Button({
        parent = content,
        anchorParent = content.clearButton.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = 25,
        sizeY = 25,
        offsetY = -10,
        adjustWidth = true,
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_EXPORT_JSON),
        clickCallback = function()
            local json = CraftSim.CRAFT_RESULTS:ExportJSON()
            CraftSim.UTIL:ShowTextCopyBox(json)
        end
    })


    -- craft results
    content.craftsTitle = CraftSim.FRAME:CreateText(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG), content, content, "TOPLEFT",
        "TOPLEFT",
        155, -40)

    content.scrollingMessageFrame = CraftSim.FRAME:CreateScrollingMessageFrame(content,
        content.craftsTitle,
        "TOPLEFT", "BOTTOMLEFT", -125, -15, 30, 200, 140)
    --

    content.scrollFrame2, content.craftedItemsFrame = CraftSim.FRAME:CreateScrollFrame(content,
        -230, 20, -350, 20)

    content.craftedItemsTitle = CraftSim.FRAME:CreateText(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_CRAFTED_ITEMS), content,
        content.scrollFrame2, "BOTTOM", "TOP", 0, 0)

    content.craftedItemsFrame.resultFeed = CraftSim.FRAME:CreateText("", content.craftedItemsFrame,
        content.craftedItemsFrame,
        "TOPLEFT", "TOPLEFT", 10, -10, nil, nil, { type = "H", value = "LEFT" })

    content.statisticsTitle = CraftSim.FRAME:CreateText(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_RECIPE_STATISTICS), content,
        content.craftedItemsTitle, "LEFT", "RIGHT", 270, 0)
    content.statisticsText = CraftSim.FRAME:CreateText(
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_NOTHING), content,
        content.statisticsTitle,
        "TOPLEFT", "BOTTOMLEFT", -70, -10, nil, nil, { type = "H", value = "LEFT" })
    content.statisticsText:SetWidth(300)

    content.disableCraftResultsCB = GGUI.Checkbox {
        parent = content, anchorParent = content.exportButton.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -10,
        label = " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX),
        tooltip = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP),
        initialValue = CraftSim.DB.OPTIONS:Get("CRAFT_RESULTS_DISABLE"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("CRAFT_RESULTS_DISABLE", checked)
        end
    }
end

---@param statisticsTrackerTab CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB
function CraftSim.CRAFT_RESULTS.UI:InitStatisticsTrackerTab(statisticsTrackerTab)
    ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.CONTENT : Frame
    local content = statisticsTrackerTab.content

    content.recipeHeader = GGUI.Text {
        parent = content, anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -20 } },
        scale = 2
    }

    content.resultDistributionList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 10, offsetY = -100 } },
        parent = content,
        sizeY = 150,
        showBorder = true,
        columnOptions = {
            {
                width = 170,
            },
            {
                width = 50,
            }
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.RESULT_COLUMN : Frame
            local resultColumn = columns[1]
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.DIST_COLUMN : Frame
            local distColumn = columns[2]

            resultColumn.text = GGUI.Text {
                parent = resultColumn,
                anchorPoints = { { anchorParent = resultColumn, anchorA = "LEFT", anchorB = "LEFT" } },
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = 150,
            }

            distColumn.text = GGUI.Text {
                parent = distColumn,
                anchorPoints = { { anchorParent = distColumn } },
            }
        end,
        selectionOptions = { noSelectionColor = true },
    }

    GGUI.Text {
        parent = content,
        anchorPoints = { { anchorParent = content.resultDistributionList.frame, anchorA = "BOTTOM", anchorB = "TOP", offsetY = 2 } },
        text = "Result Distribution"
    }

    GGUI.HelpIcon {
        parent = content, anchorParent = content.resultDistributionList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPRIGHT", offsetX = -5, offsetY = -4,
        text = "Relative distribution of crafted item results.\n(Ignoring Multicraft Quantities)"
    }

    content.multicraftStatisticsList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.resultDistributionList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 30, } },
        parent = content,
        sizeY = 150,
        showBorder = true,
        columnOptions = {
            {
                width = 130,
            },
            {
                width = 40,
            }
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.STATISTICS_COLUMN : Frame
            local statisticsColumn = columns[1]
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.VALUE_COLUMN : Frame
            local valueColumn = columns[2]

            statisticsColumn.text = GGUI.Text {
                parent = statisticsColumn,
                anchorPoints = { { anchorParent = statisticsColumn, anchorA = "RIGHT", anchorB = "RIGHT", offsetX = -5 } },
                justifyOptions = { type = "H", align = "RIGHT" }
            }

            valueColumn.text = GGUI.Text {
                parent = valueColumn,
                anchorPoints = { { anchorParent = valueColumn } },
            }
        end,
    }

    GGUI.Text {
        parent = content,
        anchorPoints = { { anchorParent = content.multicraftStatisticsList.frame, anchorA = "BOTTOM", anchorB = "TOP", offsetY = 2 } },
        text = "Multicraft"
    }

    content.resourcefulnessStatisticsList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.multicraftStatisticsList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = 30, } },
        parent = content,
        sizeY = 150,
        showBorder = true,
        columnOptions = {
            {
                width = 130,
            },
            {
                width = 40,
            }
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.STATISTICS_COLUMN : Frame
            local statisticsColumn = columns[1]
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.VALUE_COLUMN : Frame
            local valueColumn = columns[2]

            statisticsColumn.text = GGUI.Text {
                parent = statisticsColumn,
                anchorPoints = { { anchorParent = statisticsColumn, anchorA = "RIGHT", anchorB = "RIGHT", offsetX = -5 } },
                justifyOptions = { type = "H", align = "RIGHT" }
            }

            valueColumn.text = GGUI.Text {
                parent = valueColumn,
                anchorPoints = { { anchorParent = valueColumn } },
            }
        end,
    }

    GGUI.Text {
        parent = content,
        anchorPoints = { { anchorParent = content.resourcefulnessStatisticsList.frame, anchorA = "BOTTOM", anchorB = "TOP", offsetY = 2 } },
        text = "Resourcefulness"
    }

    content.yieldStatisticsList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.multicraftStatisticsList.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -20, offsetX = -5 } },
        parent = content,
        sizeY = 160,
        showBorder = true,
        columnOptions = {
            {
                width = 170,
            },
            {
                width = 40,
            },
            {
                width = 40,
            }
        },
        selectionOptions = { noSelectionColor = true },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.STATISTICS_COLUMN : Frame
            local itemColumn = columns[1]
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.YIELD_COLUMN : Frame
            local yieldColumn = columns[2]
            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.DIST_COLUMN : Frame
            local distColumn = columns[3]

            itemColumn.text = GGUI.Text {
                parent = itemColumn,
                anchorPoints = { { anchorParent = itemColumn, anchorA = "LEFT", anchorB = "LEFT", } },
                justifyOptions = { type = "H", align = "LEFT" }
            }

            yieldColumn.text = GGUI.Text {
                parent = yieldColumn,
                anchorPoints = { { anchorParent = yieldColumn } },
            }

            distColumn.text = GGUI.Text {
                parent = distColumn,
                anchorPoints = { { anchorParent = distColumn } },
            }
        end,
    }

    GGUI.Text {
        parent = content,
        anchorPoints = { { anchorParent = content.yieldStatisticsList.frame, anchorA = "BOTTOM", anchorB = "TOP", offsetY = 2 } },
        text = "Yield Distribution"
    }
end

function CraftSim.CRAFT_RESULTS.UI:UpdateItemList()
    local craftResultFrame = CraftSim.CRAFT_RESULTS.frame

    -- total items
    local craftResultItems = CraftSim.CRAFT_RESULTS.currentSessionData.totalItems

    -- CraftProfits
    do
        local craftProfitsTabContent = craftResultFrame.content.craftProfitsTab.content
        local craftedItemsFrame = craftProfitsTabContent.craftedItemsFrame

        -- sort craftedItems by rareness
        local sortedCraftResultItems = CraftSim.GUTIL:Sort(craftResultItems, function(a, b)
            local rarityA = a.item:GetItemQuality()
            local rarityB = b.item:GetItemQuality()
            if rarityA and rarityB then
                return a.item:GetItemQuality() > b.item:GetItemQuality()
            end
        end)

        local craftedItemsText = ""
        for _, craftResultItem in pairs(sortedCraftResultItems) do
            craftedItemsText = craftedItemsText ..
                craftResultItem.quantity .. " x " .. craftResultItem.item:GetItemLink() .. "\n"
        end

        -- add saved reagents
        local savedReagentsText = ""
        if #CraftSim.CRAFT_RESULTS.currentSessionData.totalSavedReagents > 0 then
            savedReagentsText = "\n" .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_SAVED_REAGENTS) .. "\n"
            for _, savedReagent in pairs(CraftSim.CRAFT_RESULTS.currentSessionData.totalSavedReagents) do
                savedReagentsText = savedReagentsText ..
                    (savedReagent.quantity or 1) .. " x " .. (savedReagent.item:GetItemLink() or "") .. "\n"
            end
        end

        craftedItemsFrame.resultFeed:SetText(craftedItemsText .. savedReagentsText)
    end
end

function CraftSim.CRAFT_RESULTS.UI:UpdateRecipeData(recipeID)
    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_RESULTS)
    print("Update RecipeData: " .. tostring(recipeID))

    -- only update frontend if its the shown recipeID
    if not CraftSim.INIT.currentRecipeData or CraftSim.INIT.currentRecipeData.recipeID ~= recipeID then
        print("no frontend update: is not shown recipe")
        return
    end
    print("Do update cause its the shown recipe")

    local craftResultFrame = CraftSim.CRAFT_RESULTS.frame

    local craftSessionData = CraftSim.CRAFT_RESULTS.currentSessionData
    if not craftSessionData then
        print("create new craft session data")
        craftSessionData                          = CraftSim.CraftSessionData()
        CraftSim.CRAFT_RESULTS.currentSessionData = craftSessionData
    else
        print("Reuse sessionData")
    end

    local craftRecipeData = craftSessionData:GetCraftRecipeData(recipeID)
    if not craftRecipeData then
        print("create new recipedata")
        craftRecipeData = CraftSim.CraftRecipeData(recipeID)
        table.insert(craftSessionData.craftRecipeData, craftRecipeData)
    else
        print("Reuse recipedata")
    end

    -- Craft Profits
    do
        local craftProfitsContent = craftResultFrame.content.craftProfitsTab
            .content --[[@as CraftSim.CRAFT_RESULTS.CRAFT_PROFITS_TAB.CONTENT]]
        local statisticsText = ""
        local expectedAverageProfit = CraftSim.UTIL:FormatMoney(0, true)
        local actualAverageProfit = CraftSim.UTIL:FormatMoney(0, true)
        if craftRecipeData.numCrafts > 0 then
            expectedAverageProfit = CraftSim.UTIL:FormatMoney(
                (craftRecipeData.totalExpectedProfit / craftRecipeData.numCrafts) or 0, true)
            actualAverageProfit = CraftSim.UTIL:FormatMoney(
                (craftRecipeData.totalProfit / craftRecipeData.numCrafts) or 0,
                true)
        end
        local actualProfit = CraftSim.UTIL:FormatMoney(craftRecipeData.totalProfit, true)
        statisticsText = statisticsText ..
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_1) .. craftRecipeData.numCrafts .. "\n\n"

        if CraftSim.INIT.currentRecipeData.supportsCraftingStats then
            statisticsText = statisticsText ..
                CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_2) .. expectedAverageProfit .. "\n"
            statisticsText = statisticsText ..
                CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_3) .. actualAverageProfit .. "\n"
            statisticsText = statisticsText ..
                CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_4) .. actualProfit .. "\n\n"
            statisticsText = statisticsText ..
                CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_5) .. "\n\n"

            if CraftSim.INIT.currentRecipeData.supportsMulticraft then
                local expectedProcs = tonumber(CraftSim.GUTIL:Round(
                        CraftSim.INIT.currentRecipeData.professionStats.multicraft:GetPercent(true) *
                        craftRecipeData.numCrafts, 1)) or
                    0
                if craftRecipeData.numMulticraft >= expectedProcs then
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_7) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numMulticraft, CraftSim.GUTIL.COLORS.GREEN) ..
                        " / " .. expectedProcs .. "\n"
                else
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_7) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numMulticraft, CraftSim.GUTIL.COLORS.RED) ..
                        " / " .. expectedProcs .. "\n"
                end
                local averageExtraItems = 0
                local expectedAdditionalItems = 0
                local multicraftExtraItemsFactor = 1 + CraftSim.INIT.currentRecipeData.professionStats.multicraft
                    :GetExtraValue()

                local maxExtraItems = (CraftSim.DB.OPTIONS:Get("PROFIT_CALCULATION_MULTICRAFT_CONSTANT") * CraftSim.INIT.currentRecipeData.baseItemAmount) *
                    multicraftExtraItemsFactor
                expectedAdditionalItems = tonumber(CraftSim.GUTIL:Round((1 + maxExtraItems) / 2, 2)) or 0

                averageExtraItems = tonumber(CraftSim.GUTIL:Round(
                    (craftRecipeData.numMulticraft > 0 and (craftRecipeData.numMulticraftExtraItems / craftRecipeData.numMulticraft)) or
                    0, 2)) or 0
                if averageExtraItems == 0 then
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8) ..
                        averageExtraItems .. " / " .. expectedAdditionalItems .. "\n"
                elseif averageExtraItems >= expectedAdditionalItems then
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8) ..
                        CraftSim.GUTIL:ColorizeText(averageExtraItems, CraftSim.GUTIL.COLORS.GREEN) ..
                        " / " .. expectedAdditionalItems .. "\n"
                else
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8) ..
                        CraftSim.GUTIL:ColorizeText(averageExtraItems, CraftSim.GUTIL.COLORS.RED) ..
                        " / " .. expectedAdditionalItems .. "\n"
                end
            end
            if CraftSim.INIT.currentRecipeData.supportsResourcefulness then
                local averageSavedCosts = 0
                local expectedAverageSavedCosts = 0
                if craftRecipeData.numCrafts > 0 then
                    averageSavedCosts = CraftSim.GUTIL:Round((craftRecipeData.totalSavedCosts / craftRecipeData.numCrafts) /
                            10000) *
                        10000 --roundToGold
                    expectedAverageSavedCosts = CraftSim.GUTIL:Round((craftRecipeData.totalExpectedSavedCosts / craftRecipeData.numCrafts) /
                        10000) * 10000
                end

                if averageSavedCosts == 0 then
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN)
                elseif averageSavedCosts >= expectedAverageSavedCosts then
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN) ..
                        "\n" ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_10) ..
                        CraftSim.GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(averageSavedCosts),
                            CraftSim.GUTIL.COLORS.GREEN) ..
                        " / " .. CraftSim.UTIL:FormatMoney(expectedAverageSavedCosts)
                else
                    statisticsText = statisticsText ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN) ..
                        "\n" ..
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_10) ..
                        CraftSim.GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(averageSavedCosts),
                            CraftSim.GUTIL.COLORS.RED) ..
                        " / " .. CraftSim.UTIL:FormatMoney(expectedAverageSavedCosts)
                end
            end
        else
            statisticsText = statisticsText ..
                CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_11) .. actualProfit .. "\n\n"
        end


        craftProfitsContent.statisticsText:SetText(statisticsText)
    end

    -- Statistics Tracker
    do
        local statisticsTrackerTabContent = craftResultFrame.content.statisticsTrackerTab
            .content --[[@as CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.CONTENT]]

        statisticsTrackerTabContent.recipeHeader:SetText(CraftSim.INIT.currentRecipeData.recipeName .. " " ..
            GUTIL:IconToText(CraftSim.INIT.currentRecipeData.recipeIcon, 15, 15))

        -- Result Distribution
        do
            local resultDistributionList = statisticsTrackerTabContent.resultDistributionList

            resultDistributionList:Remove()

            -- Ignore multicraft quantity on purpose

            local totalItemCount = GUTIL:Fold(craftRecipeData.totalItems, 0, function(foldValue, nextElement)
                return foldValue + nextElement.quantity
            end)
            local oncePercent = totalItemCount / 100

            for _, craftResultItem in pairs(craftRecipeData.totalItems) do
                resultDistributionList:Add(function(row, columns)
                    local resultColumn = columns
                        [1] --[[@as CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.RESULT_COLUMN]]
                    local distColumn = columns
                        [2] --[[@as CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.DIST_COLUMN]]

                    resultColumn.text:SetText(craftResultItem.item:GetItemLink())
                    local itemDist = GUTIL:Round((craftResultItem.quantity / oncePercent) / 100, 2)
                    distColumn.text:SetText(itemDist)
                    row.tooltipOptions = {
                        itemID = craftResultItem.item:GetItemID(),
                        anchor = "ANCHOR_RIGHT",
                        owner = row.frameList.frame
                    }
                end)
            end

            resultDistributionList:UpdateDisplay()
        end

        -- Multicraft Statistics
        do
            local multicraftStatisticsList = statisticsTrackerTabContent.multicraftStatisticsList

            multicraftStatisticsList:Remove()

            if craftRecipeData.numCrafts > 0 then
                local function addStatistic(label, value)
                    multicraftStatisticsList:Add(function(row, columns)
                        ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.STATISTICS_COLUMN : Frame
                        local statisticsColumn = columns[1]
                        ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.VALUE_COLUMN : Frame
                        local valueColumn = columns[2]

                        statisticsColumn.text:SetText(label)
                        valueColumn.text:SetText(value)
                    end)
                end

                local distribution = GUTIL:Round(
                    (craftRecipeData.numMulticraft / (craftRecipeData.numCrafts / 100)) / 100, 2)
                addStatistic("Distribution:", distribution)
                local additionalYield = 0
                if craftRecipeData.numMulticraft > 0 then
                    additionalYield = GUTIL:Round(craftRecipeData.numMulticraftExtraItems / craftRecipeData
                        .numMulticraft, 2)
                end
                addStatistic("Ø Additional Yield:", additionalYield)
            end
            multicraftStatisticsList:UpdateDisplay()
        end

        -- Resourcefulness Statistics
        do
            local resourcefulnessStatisticsList = statisticsTrackerTabContent.resourcefulnessStatisticsList

            resourcefulnessStatisticsList:Remove()

            if craftRecipeData.numCrafts > 0 then
                local function addStatistic(label, value)
                    resourcefulnessStatisticsList:Add(function(row, columns)
                        ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.STATISTICS_COLUMN : Frame
                        local statisticsColumn = columns[1]
                        ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.VALUE_COLUMN : Frame
                        local valueColumn = columns[2]

                        statisticsColumn.text:SetText(label)
                        valueColumn.text:SetText(value)
                    end)
                end

                local distribution = GUTIL:Round(
                    (craftRecipeData.numResourcefulness / (craftRecipeData.numCrafts / 100)) / 100, 2)
                addStatistic("Distribution:", distribution)
            end
            resourcefulnessStatisticsList:UpdateDisplay()
        end

        -- Yield Statistics
        do
            local yieldStatisticsList = statisticsTrackerTabContent.yieldStatisticsList
            yieldStatisticsList:Remove()

            if craftRecipeData.numCrafts > 0 then
                local yieldDistributionMap = {}
                for _, craftResult in pairs(craftRecipeData.craftResults) do
                    local itemResultCountMap = {}
                    for _, craftResultItem in pairs(craftResult.craftResultItems) do
                        local itemLink = craftResultItem.item:GetItemLink()
                        itemResultCountMap[itemLink] = itemResultCountMap[itemLink] or 0
                        itemResultCountMap[itemLink] = itemResultCountMap[itemLink] + craftResultItem.quantity +
                            craftResultItem.quantityMulticraft
                    end

                    for itemLink, count in pairs(itemResultCountMap) do
                        yieldDistributionMap[itemLink] = yieldDistributionMap[itemLink] or {}
                        yieldDistributionMap[itemLink].distributions = yieldDistributionMap[itemLink].distributions or {}
                        yieldDistributionMap[itemLink].totalDistributionCount = yieldDistributionMap[itemLink]
                            .totalDistributionCount or 0

                        if not yieldDistributionMap[itemLink].distributions[count] then
                            yieldDistributionMap[itemLink].distributions[count] = 0
                        end

                        yieldDistributionMap[itemLink].distributions[count] = yieldDistributionMap[itemLink]
                            .distributions[count] + 1
                        yieldDistributionMap[itemLink].totalDistributionCount = yieldDistributionMap[itemLink]
                            .totalDistributionCount + 1
                    end
                end

                for itemLink, distributionData in pairs(yieldDistributionMap) do
                    for yield, count in pairs(distributionData.distributions) do
                        yieldStatisticsList:Add(function(row, columns)
                            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.STATISTICS_COLUMN : Frame
                            local itemColumn = columns[1]
                            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.YIELD_COLUMN : Frame
                            local yieldColumn = columns[2]
                            ---@class CraftSim.CRAFT_RESULTS.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.DIST_COLUMN : Frame
                            local distColumn = columns[3]

                            itemColumn.text:SetText(itemLink)
                            local dist = GUTIL:Round(
                                (count / (distributionData.totalDistributionCount / 100)) / 100, 2)
                            distColumn.text:SetText(dist)
                            yieldColumn.text:SetText("x " .. yield)
                            row.yield = yield
                            row.itemLink = itemLink
                            row.tooltipOptions = {
                                itemID = GUTIL:GetItemIDByLink(itemLink),
                                anchor = "ANCHOR_RIGHT",
                                owner = row.frameList.frame
                            }
                        end)
                    end
                end
            end

            yieldStatisticsList:UpdateDisplay(function(rowA, rowB)
                if rowA.itemLink > rowB.itemLink then
                    return true
                elseif rowA.itemLink < rowB.itemLink then
                    return false
                end

                return rowA.yield > rowB.yield
            end)
        end
    end
end
