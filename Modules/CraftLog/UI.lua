---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local LibGraph = CraftSim.LibGraph

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.CRAFT_LOG
CraftSim.CRAFT_LOG = CraftSim.CRAFT_LOG

---@class CraftSim.CRAFT_LOG.UI
CraftSim.CRAFT_LOG.UI = {}

CraftSim.CRAFT_LOG.UI.STAT_COMPARISON_GRAPH_OBSERVED_LINE_COLOR = { 0.93, 0.79, 0.0, 0.8 }
CraftSim.CRAFT_LOG.UI.STAT_COMPARISON_GRAPH_EXPECTED_LINE_COLOR = { 0.0, 1.0, 0.0, 0.8 }

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftLog.UI")

function CraftSim.CRAFT_LOG.UI:Init()
    ---@class CraftSim.CRAFT_LOG.LOG_FRAME : GGUI.Frame
    local logFrame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = UIParent,
        anchorA = "RIGHT",
        anchorB = "RIGHT",
        sizeX = 260,
        sizeY = 340,
        frameID = CraftSim.CONST.FRAMES.CRAFT_LOG_LOG_FRAME,
        title = L("CRAFT_LOG_TITLE"),
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_CRAFT_LOG"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = "DIALOG",
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    ---@class CraftSim.CRAFT_LOG.DETAILS_FRAME : GGUI.Frame
    local advFrame = GGUI.Frame({
        parent = logFrame.frame,
        anchorParent = UIParent,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = 720,
        sizeY = 340,
        frameID = CraftSim.CONST.FRAMES.CRAFT_LOG,
        title = L("CRAFT_LOG_ADV_TITLE"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = "DIALOG",
        moveable = true,
        closeable = true,
        onCloseCallback = function()
            CraftSim.DB.OPTIONS:Save("CRAFT_LOG_SHOW_ADV_LOG", false)
        end,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        hide = not CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SHOW_ADV_LOG"),
    })

    CraftSim.CRAFT_LOG.logFrame = logFrame
    CraftSim.CRAFT_LOG.advFrame = advFrame

    local hideBlizzardCraftingLog = CraftSim.DB.OPTIONS:Get("CRAFT_LOG_HIDE_BLIZZARD_CRAFTING_LOG")

    if hideBlizzardCraftingLog and ProfessionsFrame.CraftingPage.CraftingOutputLog then
        ProfessionsFrame.CraftingPage.CraftingOutputLog:UnregisterAllEvents()
        ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:UnregisterAllEvents()
    end

    self:InitLogFrame(logFrame)
    self:InitAdvancedLogFrame(advFrame)
end

function CraftSim.CRAFT_LOG.UI:InitLogFrame(frame)
    ---@class CraftSim.CRAFT_LOG.LOG_FRAME : GGUI.Frame
    frame = frame

    local craftLogX = 250
    local craftLogY = 150

    frame.content.craftResultsOptionsButton = GGUI.Button {
        parent = frame.content,
        anchorPoints = { { anchorParent = frame.title.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
        cleanTemplate = true,
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        sizeX = 20, sizeY = 20,
        clickCallback = function(_, _)
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                local disableCB = rootDescription:CreateCheckbox(
                    L("CRAFT_LOG_DISABLE_CHECKBOX"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_DISABLE")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_DISABLE")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_DISABLE",
                            newValue)
                    end)

                disableCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L("CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP"))
                end);

                local disableADVData = rootDescription:CreateCheckbox(
                    f.r("Disable ") .. " Advanced Data Processing",
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_DISABLE_ADV_DATA")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_DISABLE_ADV_DATA")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_DISABLE_ADV_DATA",
                            newValue)
                    end)

                disableADVData:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        "Disables the recording of advanced log data to save RAM and CPU during crafting")
                end);

                local ignoreWorkOrdersCB = rootDescription:CreateCheckbox(
                    f.r("Ignore ") .. "Work Orders",
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_IGNORE_WORK_ORDERS")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_IGNORE_WORK_ORDERS")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_IGNORE_WORK_ORDERS",
                            newValue)
                    end)

                local showAdvancedLogCB = rootDescription:CreateCheckbox(
                    "Show " .. f.l("Advanced Craft Log"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_SHOW_ADV_LOG")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_SHOW_ADV_LOG")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_SHOW_ADV_LOG",
                            newValue)

                        if newValue then
                            CraftSim.CRAFT_LOG.advFrame:Show()
                            -- also update
                            local recipeData = CraftSim.INIT.currentRecipeData
                            if recipeData then
                                self:UpdateAdvancedCraftLogDisplay(recipeData.recipeID)
                            end
                        else
                            CraftSim.CRAFT_LOG.advFrame:Hide()
                        end
                    end)

                local hideBlizzardCraftingLog = rootDescription:CreateCheckbox(
                    "Hide " .. f.bb("Blizzard Default Crafting Log"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_HIDE_BLIZZARD_CRAFTING_LOG")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_HIDE_BLIZZARD_CRAFTING_LOG")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_HIDE_BLIZZARD_CRAFTING_LOG",
                            newValue)

                        if newValue then
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:UnregisterAllEvents()
                            ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:UnregisterAllEvents()
                            if ProfessionsFrame.CraftingPage.CraftingOutputLog:IsVisible() then
                                ProfessionsFrame.CraftingPage.CraftingOutputLog:Hide()
                            elseif ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:IsVisible() then
                                ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:Hide()
                            end
                        else
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_ITEM_CRAFTED_RESULT")
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_CURRENCY_REWARD_RESULT")
                            ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_ITEM_CRAFTED_RESULT")
                            ProfessionsFrame.OrdersPage.OrderView.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_CURRENCY_REWARD_RESULT")
                        end
                    end)

                hideBlizzardCraftingLog:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        "Hides the default UI " .. f.bb("Crafting Output Log") .. " when crafting");
                end)

                local autoShowCB = rootDescription:CreateCheckbox(
                    f.g("Auto Show ") .. "on Craft",
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_AUTO_SHOW")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_AUTO_SHOW")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_AUTO_SHOW",
                            newValue)
                    end)

                hideBlizzardCraftingLog:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        "Hides the default UI " .. f.bb("Crafting Output Log") .. " when crafting");
                end)


                -- TODO: Fix/Refactor and Reimplement
                local exportOptions = rootDescription:CreateButton(f.l("Export Data Feature - WIP"))
                exportOptions:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        f.l("Feature will be reworked and reimplemented in a future update"));
                end)
                -- local exportOptions = rootDescription:CreateButton("Export Data")

                -- exportOptions:CreateButton("as " .. f.bb("JSON"), function()
                --     local json = CraftSim.CRAFT_LOG:ExportJSON()
                --     CraftSim.UTIL:ShowTextCopyBox(json)
                -- end)

                local clearDataButton = rootDescription:CreateButton(f.r("Clear Data"), function()
                    CraftSim.CRAFT_LOG:ClearData()
                end)
            end)
        end
    }

    frame.content.backgroundFrame = GGUI.Frame {
        parent = frame.content,
        sizeX = craftLogX, sizeY = craftLogY,
        anchorParent = frame.content,
        anchorA = "TOP", anchorB = "TOP", offsetY = -37,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS
    }

    frame.content.craftLogScrollingMessageFrame = GGUI.ScrollingMessageFrame {
        parent = frame.content.backgroundFrame.content,
        anchorParent = frame.content.backgroundFrame.content,
        enableScrolling = true,
        fading = false,
        maxLines = 3000,
        sizeX = craftLogX - 20,
        sizeY = craftLogY - 20,
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
        showScrollBar = true,
    }

    frame.content.craftLogScrollingMessageFrame:EnableHyperLinksForFrameAndChilds()

    frame.content.craftedItemsTitle = GGUI.Text {
        parent = frame.content,
        anchorPoints = { { anchorParent = frame.content.craftLogScrollingMessageFrame.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -20 } },
        text = L("CRAFT_LOG_CRAFTED_ITEMS")
    }

    frame.content.craftedItemsList = GGUI.FrameList {
        parent = frame.content,
        anchorPoints = {
            { anchorParent = frame.content.craftLogScrollingMessageFrame.frame,
                anchorA = "TOPLEFT",
                anchorB = "BOTTOMLEFT",
                offsetX = -20,
                offsetY = -38
            } },
        columnOptions = {
            {
                width = 25,
            },
            {
                width = 192
            }
        },
        rowHeight = 15,
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true,
        },
        rowConstructor = function(columns, row)
            row.itemCountColumn = columns[1]
            row.itemLinkColumn = columns[2]
            ---@class CraftSim.CRAFT_RESULTS.CraftItemResultList.Row : GGUI.FrameList.Row
            row = row

            ---@type ItemMixin
            row.item = nil

            row.itemCountColumn.text = GGUI.Text {
                parent = row.itemCountColumn, anchorPoints = { { anchorParent = row.itemCountColumn } },
                scale = 0.9,
                fixedWidth = 25
            }

            row.itemLinkColumn.text = GGUI.Text {
                parent = row.itemLinkColumn, anchorPoints = { { anchorParent = row.itemLinkColumn } },
                justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9,
                fixedWidth = 192
            }
        end,
        showBorder = true,
    }

    frame.content.sessionProfitTitle = GGUI.Text {
        parent = frame.content,
        anchorPoints = { { anchorParent = frame.content.craftedItemsList.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -8, offsetX = 2 } },
        text = L("CRAFT_LOG_SESSION_PROFIT")
    }

    frame.content.sessionProfitValue = GGUI.Text {
        parent = frame.content,
        anchorPoints = { { anchorParent = frame.content.sessionProfitTitle.frame, anchorA = "LEFT", anchorB = "RIGHT" } },
        justifyOptions = { type = "H", align = "LEFT" },
        text = CraftSim.UTIL:FormatMoney(0, true)
    }
end

function CraftSim.CRAFT_LOG.UI:InitAdvancedLogFrame(frame)
    local tabSizeX = 720
    local tabSizeY = 340

    ---@class CraftSim.CRAFT_LOG.DETAILS_FRAME : GGUI.Frame
    frame = frame

    frame.content.recipeHeader = GGUI.Text {
        parent = frame.content, anchorPoints = {
        { anchorParent = frame.content,     anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -13, offsetX = 10 },
        { anchorParent = frame.title.frame, anchorA = "RIGHT",   anchorB = "LEFT" },
    },
    }

    frame.content.crafts = GGUI.Text {
        parent = frame.content, anchorPoints = {
        { anchorParent = frame.content,     anchorA = "TOPRIGHT", anchorB = "TOPRIGHT", offsetY = -16, offsetX = -10 },
        { anchorParent = frame.title.frame, anchorA = "LEFT",     anchorB = "RIGHT" }, },
        prefix = L(CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX),
    }

    local reagentCombinationIDsSaveTable = CraftSim.DB.OPTIONS:Get(
        "CRAFT_LOG_SELECTED_RECIPE_REAGENT_COMBINATION_ID")

    frame.content.reagentCombinationButton = GGUI.FilterButton {
        parent = frame.content,
        anchorPoints = { { anchorParent = frame.title.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -10 } },
        sizeX = 200, sizeY = 25,
        label = "Crafting Reagents Filter",
        menuUtilCallback = function(ownerRegion, rootDescription)
            -- get currently viewed recipe craft data
            local recipeData = CraftSim.INIT.currentRecipeData
            if not recipeData then return end

            local sessionData = CraftSim.CRAFT_LOG.currentSessionData
            local craftRecipeData = sessionData:GetCraftRecipeData(recipeData.recipeID)

            local reagentCombinationIDs = craftRecipeData:GetReagentCombinationIDs()

            for _, reagentCombinationID in ipairs(reagentCombinationIDs) do
                local reagentCombinationIDDisplayString = craftRecipeData:GetReagentCombinationDisplayString(
                    reagentCombinationID)
                rootDescription:CreateRadio(reagentCombinationIDDisplayString, function()
                    return reagentCombinationIDsSaveTable[recipeData.recipeID] == reagentCombinationID
                end, function()
                    reagentCombinationIDsSaveTable[recipeData.recipeID] = reagentCombinationID
                    CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(recipeData.recipeID)
                end)
            end
        end
    }

    ---@class CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB : GGUI.BlizzardTab
    frame.content.calculationComparisonTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = "Calculation Comparison",
            offsetY = -3,
        },
        parent = frame.content, anchorParent = frame.content,
        sizeX = tabSizeX, sizeY = tabSizeY, initialTab = true,
        top = true,
    }

    self:InitCalculationComparisonTab(frame.content.calculationComparisonTab)

    ---@class CraftSim.CRAFT_LOG.REAGENT_DETAILS_TAB : GGUI.BlizzardTab
    frame.content.reagentDetailsTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = L("CRAFT_LOG_REAGENT_DETAILS_TAB"),
            anchorParent = frame.content.calculationComparisonTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
        },
        parent = frame.content, anchorParent = frame.content,
        sizeX = tabSizeX, sizeY = tabSizeY,
        top = true,
    }

    self:InitReagentDetailsTab(frame.content.reagentDetailsTab)

    ---@class CraftSim.CRAFT_LOG.RESULT_ANALYSIS_TAB : GGUI.BlizzardTab
    frame.content.resultAnalysisTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = L("CRAFT_LOG_RESULT_ANALYSIS_TAB"),
            anchorParent = frame.content.reagentDetailsTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
        },
        parent = frame.content, anchorParent = frame.content,
        sizeX = tabSizeX, sizeY = tabSizeY,
        top = true,
    }

    self:InitResultAnalysisTab(frame.content.resultAnalysisTab)

    GGUI.BlizzardTabSystem { frame.content.calculationComparisonTab, frame.content.reagentDetailsTab, frame.content.resultAnalysisTab }

    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
end

---@param reagentDetailsTab CraftSim.CRAFT_LOG.REAGENT_DETAILS_TAB
function CraftSim.CRAFT_LOG.UI:InitReagentDetailsTab(reagentDetailsTab)
    ---@class CraftSim.CRAFT_LOG.REAGENT_DETAILS_TAB
    reagentDetailsTab = reagentDetailsTab
    ---@class CraftSim.CRAFT_LOG.REAGENT_DETAILS_TAB.CONTENT : Frame
    local content = reagentDetailsTab.content

    local reagentColumnWidth = 170
    local countColumnWidth = 40
    local costColumnWidth = 100

    content.reagentList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 50, offsetY = -100 } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
        showBorder = true,
        columnOptions = {
            {
                label = "Used Reagent",
                width = reagentColumnWidth,
            },
            {
                label = "Count",
                width = countColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" },
            },
            {
                label = "Costs",
                width = costColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" },
            }
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG.REAGENT_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.itemColumn = columns[1]
            row.countColumn = columns[2]
            row.costColumn = columns[3]
            ---@type CraftSim.CraftResultReagent
            row.craftResultSavedReagent = nil

            row.itemColumn.text = GGUI.Text {
                parent = row.itemColumn,
                anchorPoints = { { anchorParent = row.itemColumn, anchorA = "LEFT", anchorB = "LEFT", } },
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = reagentColumnWidth,
            }

            row.countColumn.text = GGUI.Text {
                parent = row.countColumn,
                anchorPoints = { { anchorParent = row.countColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = countColumnWidth,
            }

            row.costColumn.text = GGUI.Text {
                parent = row.costColumn,
                anchorPoints = { { anchorParent = row.costColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = costColumnWidth,
            }
        end,
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true },
    }

    content.savedReagentsList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.reagentList.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetY = 0, offsetX = 40 } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
        showBorder = true,
        columnOptions = {
            {
                label = "Saved Reagent",
                width = reagentColumnWidth,
            },
            {
                label = "Count",
                width = countColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" },
            },
            {
                label = "Saved Costs",
                width = costColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" },
            }
        },
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.itemColumn = columns[1]
            row.countColumn = columns[2]
            row.costColumn = columns[3]
            ---@type CraftSim.CraftResultReagent
            row.craftResultSavedReagent = nil

            row.itemColumn.text = GGUI.Text {
                parent = row.itemColumn,
                anchorPoints = { { anchorParent = row.itemColumn, anchorA = "LEFT", anchorB = "LEFT", } },
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = reagentColumnWidth,
            }

            row.countColumn.text = GGUI.Text {
                parent = row.countColumn,
                anchorPoints = { { anchorParent = row.countColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = countColumnWidth,
            }

            row.costColumn.text = GGUI.Text {
                parent = row.costColumn,
                anchorPoints = { { anchorParent = row.costColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = costColumnWidth,
            }
        end,
    }
end

---@param resultAnalysisTab CraftSim.CRAFT_LOG.RESULT_ANALYSIS_TAB
function CraftSim.CRAFT_LOG.UI:InitResultAnalysisTab(resultAnalysisTab)
    ---@class CraftSim.CRAFT_LOG.RESULT_ANALYSIS_TAB.CONTENT : Frame
    local content = resultAnalysisTab.content

    local iconSize = 28
    local itemColumnWidth = 35
    local distributionColumnWidth = 100
    local valueColumnWidth = 120
    local countColumnWidth = 60
    local yieldColumnWidth = 40
    local listSpacingX = 60

    content.totalResultsList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -100 } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
        rowHeight = 30,
        showBorder = true,
        columnOptions = {
            {
                label = "Item",
                width = itemColumnWidth,
            },
            {
                label = "Count",
                width = countColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = "AH Sell Value",
                width = valueColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" }
            }
        },
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG.TOTAL_RESULTS_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.itemColumn = columns[1]
            row.countColumn = columns[2]
            row.valueColumn = columns[3]

            row.count = 0
            ---@type string
            row.itemLink = nil
            row.value = 0

            row.itemColumn.icon = GGUI.Icon {
                parent = row.itemColumn,
                anchorParent = row.itemColumn,
                qualityIconScale = 1.5,
                sizeX = iconSize,
                sizeY = iconSize,
            }

            row.countColumn.text = GGUI.Text {
                parent = row.countColumn,
                anchorPoints = { { anchorParent = row.countColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = countColumnWidth
            }

            row.valueColumn.text = GGUI.Text {
                parent = row.valueColumn,
                anchorPoints = { { anchorParent = row.valueColumn, offsetX = -5 } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = valueColumnWidth
            }
        end,
    }

    content.resultDistributionList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.totalResultsList.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetY = 0, offsetX = listSpacingX } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
        rowHeight = 30,
        showBorder = true,
        columnOptions = {
            {
                label = "Item",
                width = itemColumnWidth,
            },
            {
                label = "Dist",
                width = (distributionColumnWidth * 2) - yieldColumnWidth,
                tooltipOptions = {
                    anchor = "ANCHOR_TOP",
                    text = "Item Distribution",
                },
                justifyOptions = { type = "H", align = "RIGHT" }
            }
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG.RESULT_DISTRIBUTION_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.resultColumn = columns[1]
            row.distColumn = columns[2]


            row.resultColumn.icon = GGUI.Icon {
                parent = row.resultColumn,
                anchorParent = row.resultColumn,
                qualityIconScale = 1.5,
                sizeX = iconSize,
                sizeY = iconSize,
            }

            row.distColumn.text = GGUI.Text {
                parent = row.distColumn,
                anchorPoints = { { anchorParent = row.distColumn, offsetX = -5 } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = (distributionColumnWidth * 2) - yieldColumnWidth,
            }
        end,
        selectionOptions = { noSelectionColor = true },
    }

    content.yieldDistributionList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.resultDistributionList.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetY = 0, offsetX = listSpacingX } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
        rowHeight = 30,
        showBorder = true,
        columnOptions = {
            {
                label = "Item",
                width = itemColumnWidth,
            },
            {
                label = "Yield",
                width = yieldColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = "Dist",
                width = distributionColumnWidth,
                tooltipOptions = {
                    anchor = "ANCHOR_TOP",
                    text = "Item Distribution",
                },
                justifyOptions = { type = "H", align = "RIGHT" }
            }
        },
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG.YIELD_DISTRIBUTION_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.itemColumn = columns[1]
            row.yieldColumn = columns[2]
            row.distColumn = columns[3]

            row.itemColumn.icon = GGUI.Icon {
                parent = row.itemColumn,
                anchorParent = row.itemColumn,
                qualityIconScale = 1.5,
                sizeX = iconSize,
                sizeY = iconSize,
            }

            row.yieldColumn.text = GGUI.Text {
                parent = row.yieldColumn,
                anchorPoints = { { anchorParent = row.yieldColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = yieldColumnWidth
            }

            row.distColumn.text = GGUI.Text {
                parent = row.distColumn,
                anchorPoints = { { anchorParent = row.distColumn, offsetX = -5 } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = distributionColumnWidth
            }
        end,
    }
end

---@param calculationComparisonTab CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB
function CraftSim.CRAFT_LOG.UI:InitCalculationComparisonTab(calculationComparisonTab)
    ---@class CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB
    calculationComparisonTab = calculationComparisonTab
    ---@class CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB.CONTENT : Frame
    local content = calculationComparisonTab.content

    local statNameColumnWidth = 120
    local expectedValueColumnWidth = 125
    local observedValueColumnWidth = 125

    content.comparisonList = GGUI.FrameList {
        parent = content,
        scale = 0.9,
        anchorPoints = { {
            anchorParent = content,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -100, offsetX = 20,
        } },
        showBorder = true,
        sizeY = 220,
        columnOptions = {
            {
                label = "Value",
                width = statNameColumnWidth,
            },
            {
                label = "Expected",
                width = expectedValueColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = "Observed",
                width = observedValueColumnWidth,
                justifyOptions = { type = "H", align = "RIGHT" }
            }
        },
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            selectedRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.SELECTED_LIGHT_WHITE,
            selectionCallback = function(row, userInput)
                if CraftSim.INIT.currentRecipeData and userInput then
                    CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(CraftSim.INIT.currentRecipeData.recipeID)
                end
            end
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG_ADV.COMPARISON_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.statNameColumn = columns[1]
            row.expectedValueColumn = columns[2]
            row.observedValueColumn = columns[3]

            row.statNameColumn.text = GGUI.Text {
                parent = row.statNameColumn,
                anchorPoints = { { anchorParent = row.statNameColumn } },
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = statNameColumnWidth - 5,
                offsetX = 5,
            }

            row.expectedValueColumn.text = GGUI.Text {
                parent = row.expectedValueColumn,
                anchorPoints = { { anchorParent = row.expectedValueColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = expectedValueColumnWidth,
            }

            row.observedValueColumn.text = GGUI.Text {
                parent = row.observedValueColumn,
                anchorPoints = { { anchorParent = row.observedValueColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                offsetX = -5,
                fixedWidth = observedValueColumnWidth - 5,
            }
        end
    }

    content.statComparisonGraph = LibGraph:CreateGraphLine("StatComparisonGraph", content.comparisonList.frame,
        "LEFT", "RIGHT", 30,
        0, 350, 220)
    content.statComparisonGraph:SetXAxis(0, 1)
    content.statComparisonGraph:SetYAxis(0, 1)
    -- content.concentrationCurveGraph:LockYMin(true)
    content.statComparisonGraph:SetGridSpacing(1, 1)
    content.statComparisonGraph:SetGridColor({ 0.5, 0.5, 0.5, 0.5 })
    content.statComparisonGraph:SetAxisDrawing(false, true)
    content.statComparisonGraph:SetAxisColor({ 1.0, 1.0, 1.0, 1.0 })
    content.statComparisonGraph:SetAutoScale(true)
    if content.statComparisonGraph.SetYLabels then
        content.statComparisonGraph:SetYLabels(true)
    end

    function content.statComparisonGraph:SetDefault()
        local defaultData = { { 0, 0 } }
        local defaultData2 = { { 5, 5 } }
        content.statComparisonGraph:SetGridSpacing(1, 1)
        content.statComparisonGraph:AddDataSeries(defaultData,
            CraftSim.CRAFT_LOG.UI.STAT_COMPARISON_GRAPH_OBSERVED_LINE_COLOR)
        content.statComparisonGraph:AddDataSeries(defaultData2,
            CraftSim.CRAFT_LOG.UI.STAT_COMPARISON_GRAPH_OBSERVED_LINE_COLOR)
    end

    content.statComparisonGraphTitle = GGUI.Text {
        parent = content,
        scale = 0.9,
        anchorPoints = { {
            anchorParent = content.statComparisonGraph,
            anchorA = "BOTTOM",
            anchorB = "TOP", offsetY = 5,
        } },
        text = "<StatTitle>"
    }

    content.numCraftsInfo = GGUI.Text {
        parent = content,
        wrap = true,
        scale = 0.9,
        anchorPoints = { {
            anchorParent = content.statComparisonGraph,
            anchorA = "TOP",
            anchorB = "BOTTOM", offsetY = -15,
        } },
        text = "# Crafts"
    }

    content.valueLegend = GGUI.Text {
        parent = content, scale = 0.9,
        anchorPoints = { { anchorParent = content.numCraftsInfo.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -5, } },
        text = f.gold("Observed Value") .. " - " .. f.g("Expected Value"),
    }

    content.statComparisonGraph:SetDefault()
end

function CraftSim.CRAFT_LOG.UI:UpdateResultItemLog()
    local logFrame = CraftSim.CRAFT_LOG.logFrame
    local craftedItemsList = logFrame.content.craftedItemsList --[[@as GGUI.FrameList]]

    -- total items
    local craftResultItems = CraftSim.CRAFT_LOG.currentSessionData.totalItems

    do
        craftedItemsList:Remove()

        for _, craftResultItem in ipairs(craftResultItems) do
            craftedItemsList:Add(
            ---@param row CraftSim.CRAFT_RESULTS.CraftItemResultList.Row
                function(row)
                    local itemLink = craftResultItem.item:GetItemLink()
                    row.itemCountColumn.text:SetText(craftResultItem.quantity)
                    row.itemLinkColumn.text:SetText(itemLink)
                    row.tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        owner = row.frame,
                        itemLink = itemLink,
                    }
                    row.item = craftResultItem.item
                end)
        end

        craftedItemsList:UpdateDisplay(
        ---@param rowA CraftSim.CRAFT_RESULTS.CraftItemResultList.Row
        ---@param rowB CraftSim.CRAFT_RESULTS.CraftItemResultList.Row
            function(rowA, rowB)
                local rarityA = rowA.item:GetItemQuality()
                local rarityB = rowB.item:GetItemQuality()
                if rarityA and rarityB then
                    return rarityA > rarityB
                end

                return false
            end)
    end
end

---@param craftResult CraftSim.CraftResult
---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFT_LOG.UI:UpdateCraftLogDisplay(craftResult, recipeData)
    local logFrame = CraftSim.CRAFT_LOG.logFrame
    -- Session Profit Display
    do
        logFrame.content.sessionProfitValue:SetText(CraftSim.UTIL:FormatMoney(
            CraftSim.CRAFT_LOG.currentSessionData.totalProfit, true))
    end
    -- ScrollingMessageFrame
    do
        local craftLog = logFrame.content.craftLogScrollingMessageFrame

        local resourcesText = ""
        local savedCostsText = ""

        if craftResult.triggeredResourcefulness then
            for _, savedReagent in pairs(craftResult.savedReagents) do
                local itemLink = savedReagent.item:GetItemLink()
                resourcesText = string.format("%s\n %dx %s", resourcesText, savedReagent.quantity, itemLink)
            end

            savedCostsText = CraftSim.UTIL:FormatMoney(craftResult.savedCosts, true)
        end

        local roundedProfit = GUTIL:Round(craftResult.profit * 10000) / 10000
        local profitText = CraftSim.UTIL:FormatMoney(roundedProfit, true)

        local resultsText = ""
        if #craftResult.craftResultItems > 0 then
            for _, craftResultItem in pairs(craftResult.craftResultItems) do
                resultsText = resultsText ..
                    craftResultItem.quantity ..
                    " x " .. (craftResultItem.item:GetItemLink() or recipeData.recipeName) .. "\n"
            end
        else
            resultsText = resultsText .. recipeData.recipeName .. "\n"
        end

        local multicraftExtraItemsText = ""
        for _, craftResultItem in pairs(craftResult.craftResultItems) do
            if craftResultItem.quantityMulticraft > 0 then
                multicraftExtraItemsText = multicraftExtraItemsText ..
                    craftResultItem.quantityMulticraft .. " x " .. craftResultItem.item:GetItemLink() .. "\n"
            end
        end

        local savedConcentrationText = ""
        if craftResult.triggeredIngenuity then
            savedConcentrationText = f.gold(" + " .. tostring(craftResult.savedConcentration))
        end

        local commissionText = ""
        if craftResult.isWorkOrder then
            local commission = craftResult.orderData.tipAmount - craftResult.orderData.consortiumCut
            commissionText = CraftSim.UTIL:FormatMoney(commission, true)
        end

        local messageText =
            resultsText ..
            L(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1) .. profitText .. "\n" ..
            ((craftResult.triggeredIngenuity and (f.gold(L(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2)) .. savedConcentrationText .. "\n")) or "") ..
            ((craftResult.isWorkOrder and (f.gold("Commission: ") .. commissionText .. "\n")) or "") ..
            ((craftResult.triggeredMulticraft and (f.e(L(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3)) .. "\n" .. multicraftExtraItemsText)) or "") ..
            ((craftResult.triggeredResourcefulness and (f.g(L(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4) .. savedCostsText) .. resourcesText)) or "")
        craftLog:AddMessage("\n" .. messageText)
    end
    -- FrameList
    self:UpdateResultItemLog()
end

---@param craftRecipeData CraftSim.CraftRecipeData
---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFT_LOG.UI:UpdateCalculationComparison(craftRecipeData, recipeData)
    local advFrame = CraftSim.CRAFT_LOG.advFrame
    local comparisonTabContent = advFrame.content.calculationComparisonTab
        .content --[[@as CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB.CONTENT]]
    local comparisonList = comparisonTabContent.comparisonList

    local previouslySelectedStatID = (comparisonList.selectedRow and comparisonList.selectedRow.statID)
    comparisonList:Remove()

    local craftingStatData = craftRecipeData:GetCraftingStatDataBySelectedReagentCombinationID()

    local expectedStats = craftingStatData.expectedStats
    local observedStats = craftingStatData.observedStats

    -- Comparison Table
    do
        local function addComparison(statName, expectedValue, observedValue, statID, statTitle, isGoldValue)
            comparisonList:Add(
            ---@param row CraftSim.CRAFT_LOG_ADV.COMPARISON_LIST.ROW
                function(row)
                    row.statID = statID
                    row.statTitle = statTitle
                    row.isGoldValue = isGoldValue
                    row.statNameColumn.text:SetText(statName)
                    row.expectedValueColumn.text:SetText(expectedValue)
                    row.observedValueColumn.text:SetText(observedValue)
                end)
        end

        local function colorizeObservedValue(observedValue, expectedValue, smallerThan)
            if smallerThan then
                if observedValue <= expectedValue then
                    return f.g(observedValue)
                else
                    return f.r(observedValue)
                end
            else
                if observedValue >= expectedValue then
                    return f.g(observedValue)
                else
                    return f.r(observedValue)
                end
            end
        end

        addComparison(
            "Sum Profit: ",
            CraftSim.UTIL:FormatMoney(expectedStats.totalProfit, true),
            CraftSim.UTIL:FormatMoney(observedStats.totalProfit, true),
            "totalProfit", "Total Profit", true
        )

        addComparison(
            "Ø Profit: ",
            CraftSim.UTIL:FormatMoney(expectedStats.averageProfit, true),
            CraftSim.UTIL:FormatMoney(observedStats.averageProfit, true),
            "averageProfit", "Average Profit", true
        )

        addComparison(
            "Sum Crafting Costs: ",
            CraftSim.UTIL:FormatMoney(-expectedStats.totalCraftingCosts, true),
            CraftSim.UTIL:FormatMoney(-observedStats.totalCraftingCosts, true),
            "totalCraftingCosts", "Total Crafting Costs", true
        )

        addComparison(
            "Ø Crafting Costs: ",
            CraftSim.UTIL:FormatMoney(-expectedStats.averageCraftingCosts, true),
            CraftSim.UTIL:FormatMoney(-observedStats.averageCraftingCosts, true),
            "averageCraftingCosts", "Average Crafting Costs", true
        )

        if recipeData.supportsMulticraft then
            addComparison(
                "# Multicraft: ",
                GUTIL:Round(expectedStats.numMulticraft, 2),
                colorizeObservedValue(observedStats.numMulticraft,
                    expectedStats.numMulticraft),
                "numMulticraft", "Multicraft Procs"
            )

            addComparison(
                "Sum Extra Items: ",
                GUTIL:Round(expectedStats.totalMulticraftExtraItems, 2),
                colorizeObservedValue(GUTIL:Round(observedStats.totalMulticraftExtraItems, 2),
                    GUTIL:Round(expectedStats.totalMulticraftExtraItems, 2)),
                "totalMulticraftExtraItems", "Total Multicraft Extra Items"
            )

            addComparison(
                "Ø Extra Items: ",
                GUTIL:Round(expectedStats.averageMulticraftExtraItems, 2),
                colorizeObservedValue(GUTIL:Round(observedStats.averageMulticraftExtraItems, 2),
                    GUTIL:Round(expectedStats.averageMulticraftExtraItems, 2)),
                "averageMulticraftExtraItems", "Average Multicraft Extra Items"
            )
        end

        if recipeData.supportsResourcefulness then
            addComparison(
                "# Resourcefulness: ",
                GUTIL:Round(expectedStats.numResourcefulness, 2),
                colorizeObservedValue(observedStats.numResourcefulness,
                    GUTIL:Round(expectedStats.numResourcefulness, 2)),
                "numResourcefulness", "Resourcefulness Procs"
            )

            addComparison(
                "Sum Saved Costs: ",
                CraftSim.UTIL:FormatMoney(expectedStats.totalResourcefulnessSavedCosts, true),
                CraftSim.UTIL:FormatMoney(observedStats.totalResourcefulnessSavedCosts, true),
                "totalResourcefulnessSavedCosts", "Total Resourcefulness Saved Costs", true
            )

            addComparison(
                "Ø Saved Costs: ",
                CraftSim.UTIL:FormatMoney(expectedStats.averageResourcefulnessSavedCosts, true),
                CraftSim.UTIL:FormatMoney(observedStats.averageResourcefulnessSavedCosts, true),
                "averageResourcefulnessSavedCosts", "Average Resourcefulness Saved Costs", true
            )
        end

        if recipeData.supportsIngenuity then
            addComparison(
                "# Ingenuity: ",
                GUTIL:Round(expectedStats.numIngenuity, 2),
                colorizeObservedValue(observedStats.numIngenuity,
                    GUTIL:Round(expectedStats.numIngenuity, 2)),
                "numIngenuity", "Ingenuity Procs"
            )

            addComparison(
                "Sum Concentration: ",
                GUTIL:Round(expectedStats.totalConcentrationCost, 0),
                colorizeObservedValue(GUTIL:Round(observedStats.totalConcentrationCost, 0),
                    GUTIL:Round(expectedStats.totalConcentrationCost, 0)),
                "totalConcentrationCost", "Total Concentration Cost"
            )

            addComparison(
                "Ø Concentration: ",
                GUTIL:Round(expectedStats.averageConcentrationCost, 0),
                colorizeObservedValue(GUTIL:Round(observedStats.averageConcentrationCost, 0),
                    GUTIL:Round(expectedStats.averageConcentrationCost, 0)),
                "averageConcentrationCost", "Average Concentration Cost"
            )
        end

        comparisonList:UpdateDisplay()
        -- reselect the row with the selected statID
        comparisonList:SelectRowWhere(function(row)
            return row.statID == previouslySelectedStatID
        end, 2)
    end

    CraftSim.DEBUG:StartProfiling("CRAFT_LOG_COMPARISON_GRAPH_UPDATE")

    -- Comparison Graph
    do
        --CraftSim.DEBUG:SystemPrint("Updating Graph")
        local craftingStatDataSnapshots = craftRecipeData:GetCraftingStatDataSnapshotsBySelectedReagentCombinationID()
        local comparisonGraph = comparisonTabContent.statComparisonGraph
        local graphTitle = comparisonTabContent.statComparisonGraphTitle
        local selectedStatID = "averageProfit"
        local selectedStatTitle = "Average Profit"
        local isGoldValue = true
        if comparisonList.selectedRow then
            selectedStatID = comparisonList.selectedRow.statID
            selectedStatTitle = comparisonList.selectedRow.statTitle
            isGoldValue = comparisonList.selectedRow.isGoldValue
        end
        graphTitle:SetText(selectedStatTitle)
        if comparisonGraph.SetYLabels then
            comparisonGraph:SetYLabels(true, false, function(labelValue)
                -- custom so silver and copper not included and its already gold only
                if labelValue > 5 then
                    labelValue = GUTIL:Round(labelValue)
                elseif labelValue > 1 then
                    labelValue = GUTIL:Round(labelValue, 1)
                else
                    labelValue = GUTIL:Round(labelValue, 2)
                end
                if isGoldValue then
                    if labelValue > 0 then
                        return f.g(labelValue) .. f.gold("g")
                    else
                        return f.r(labelValue) .. f.gold("g")
                    end
                else
                    return labelValue
                end
            end)
        end

        if craftingStatData.numCrafts == 0 then
            comparisonGraph:ResetData()
            comparisonGraph:SetDefault()
            --CraftSim.DEBUG:SystemPrint("- Setting Default Data, numCrafts: 0")
        else
            comparisonGraph:ResetData()
            local expectedPoints = { { 0, 0 } }
            local observedPoints = { { 0, 0 } }

            for craftNr, craftingStatData in ipairs(craftingStatDataSnapshots) do
                local expectedValue = craftingStatData.expectedStats[selectedStatID]
                local observedValue = craftingStatData.observedStats[selectedStatID]

                if isGoldValue then
                    -- Convert from copper to gold
                    expectedValue = expectedValue / 10000
                    observedValue = observedValue / 10000
                end

                tinsert(expectedPoints, { craftNr, expectedValue })
                tinsert(observedPoints, { craftNr, observedValue })
            end

            -- set grid spacing based on maxValue
            local maxValue = GUTIL:Fold(expectedPoints, 0, function(maxValue, expectedPoint, craftNr)
                local observedPoint = observedPoints[craftNr]
                return math.max(math.abs(observedPoint[2]), math.abs(expectedPoint[2]), math.abs(maxValue))
            end)

            local gridSpacingX = math.ceil(craftingStatData.numCrafts / 10)
            local gridSpacingY = maxValue / 5

            -- should in best case not happen.. but prevent game freeze if it does
            if maxValue > 0 and gridSpacingY > 0 then
                comparisonGraph:SetGridSpacing(gridSpacingX, gridSpacingY)
                comparisonGraph:AddDataSeries(expectedPoints, CraftSim.CRAFT_LOG.UI
                    .STAT_COMPARISON_GRAPH_EXPECTED_LINE_COLOR)
                comparisonGraph:AddDataSeries(observedPoints, CraftSim.CRAFT_LOG.UI
                    .STAT_COMPARISON_GRAPH_OBSERVED_LINE_COLOR)
            else
                comparisonGraph:SetDefault()
                --CraftSim.DEBUG:SystemPrint(f.l("CraftSim: ") .. f.r("Did no refresh graph cause gridSpacingY is 0"))
            end
        end
    end

    CraftSim.DEBUG:StopProfiling("CRAFT_LOG_COMPARISON_GRAPH_UPDATE")
end

---@param craftRecipeData CraftSim.CraftRecipeData
function CraftSim.CRAFT_LOG.UI:UpdateReagentDetails(craftRecipeData)
    local reagentDetailsContent = CraftSim.CRAFT_LOG.advFrame.content.reagentDetailsTab
        .content --[[@as CraftSim.CRAFT_LOG.REAGENT_DETAILS_TAB.CONTENT]]
    local reagentsList = reagentDetailsContent.reagentList
    local savedReagentsList = reagentDetailsContent.savedReagentsList

    local craftResultItems = craftRecipeData:GetCraftResultItemsBySelectedReagentCombinationID()

    -- Crafting Reagents
    do
        reagentsList:Remove()
        for _, craftResultReagent in ipairs(craftResultItems.reagents) do
            reagentsList:Add(
            ---@param row CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
                function(row)
                    row.craftResultSavedReagent = craftResultReagent
                    craftResultReagent.item:ContinueOnItemLoad(function ()
                        row.itemColumn.text:SetText(craftResultReagent.item:GetItemLink())
                        row.countColumn.text:SetText(craftResultReagent.quantity or 0)
                        row.costColumn.text:SetText(CraftSim.UTIL:FormatMoney(-craftResultReagent.costs, true))
                        row.tooltipOptions = {
                            anchor = "ANCHOR_CURSOR_RIGHT",
                            itemID = craftResultReagent.item:GetItemID(),
                        }
                    end)
                end)
        end

        reagentsList:UpdateDisplay(
        ---@param rowA CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
        ---@param rowB CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
            function(rowA, rowB)
                return rowA.craftResultSavedReagent.costs > rowB.craftResultSavedReagent.costs
            end)
    end

    -- Saved Reagents
    do
        savedReagentsList:Remove()
        for _, craftResultSavedReagent in ipairs(craftResultItems.savedReagents) do
            savedReagentsList:Add(
            ---@param row CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
                function(row)
                    row.craftResultSavedReagent = craftResultSavedReagent
                    craftResultSavedReagent.item:ContinueOnItemLoad(
                        function ()
                            row.itemColumn.text:SetText(craftResultSavedReagent.item:GetItemLink())
                            row.countColumn.text:SetText(craftResultSavedReagent.quantity or 0)
                            row.costColumn.text:SetText(CraftSim.UTIL:FormatMoney(craftResultSavedReagent.costs, true))
                            row.tooltipOptions = {
                                anchor = "ANCHOR_CURSOR_RIGHT",
                                itemID = craftResultSavedReagent.item:GetItemID(),
                            }
                        end
                    )
                end)
        end

        savedReagentsList:UpdateDisplay(
        ---@param rowA CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
        ---@param rowB CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
            function(rowA, rowB)
                return rowA.craftResultSavedReagent.costs > rowB.craftResultSavedReagent.costs
            end)
    end
end

---@param craftRecipeData CraftSim.CraftRecipeData
function CraftSim.CRAFT_LOG.UI:UpdateResultAnalysis(craftRecipeData)
    -- Result Analysis
    local resultAnalysisContent = CraftSim.CRAFT_LOG.advFrame.content.resultAnalysisTab
        .content --[[@as CraftSim.CRAFT_LOG.RESULT_ANALYSIS_TAB.CONTENT]]

    local craftResultItems = craftRecipeData:GetCraftResultItemsBySelectedReagentCombinationID()
    local craftResults = craftRecipeData:GetCraftResultsBySelectedReagentCombinationID()
    local craftingStatData = craftRecipeData:GetCraftingStatDataBySelectedReagentCombinationID()

    local isWorkOrder = craftResults[1] and craftResults[1].isWorkOrder

    -- Result Distribution
    do
        local resultDistributionList = resultAnalysisContent.resultDistributionList

        resultDistributionList:Remove()

        -- Ignore multicraft quantity on purpose

        local totalItemCount = GUTIL:Fold(craftResultItems.resultItems, 0, function(foldValue, nextElement)
            return foldValue + nextElement.quantity
        end)
        local oncePercent = totalItemCount / 100

        for _, craftResultItem in pairs(craftResultItems.resultItems) do
            resultDistributionList:Add(
            ---@param row CraftSim.CRAFT_LOG.RESULT_DISTRIBUTION_LIST.ROW
                function(row)
                    row.resultColumn.icon:SetItem(craftResultItem.item:GetItemLink())
                    local itemDist = GUTIL:Round((craftResultItem.quantity / oncePercent) / 100, 2)
                    row.distColumn.text:SetText(itemDist)
                    row.tooltipOptions = {
                        itemID = craftResultItem.item:GetItemID(),
                        anchor = "ANCHOR_RIGHT",
                        owner = row.frameList.frame
                    }
                end)
        end

        resultDistributionList:UpdateDisplay()
    end

    -- Yield Distribution
    do
        local craftResults = craftRecipeData:GetCraftResultsBySelectedReagentCombinationID()
        local yieldDistributionList = resultAnalysisContent.yieldDistributionList
        yieldDistributionList:Remove()

        if craftingStatData.numCrafts > 0 then
            local yieldDistributionMap = {}
            for _, craftResult in pairs(craftResults) do
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
                    yieldDistributionList:Add(
                    ---@param row CraftSim.CRAFT_LOG.YIELD_DISTRIBUTION_LIST.ROW
                        function(row)
                            row.itemColumn.icon:SetItem(itemLink)
                            local dist = GUTIL:Round(
                                (count / (distributionData.totalDistributionCount / 100)) / 100, 2)
                            row.distColumn.text:SetText(dist)
                            row.yieldColumn.text:SetText("x " .. yield)
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

        yieldDistributionList:UpdateDisplay(function(rowA, rowB)
            if rowA.itemLink > rowB.itemLink then
                return true
            elseif rowA.itemLink < rowB.itemLink then
                return false
            end

            return rowA.yield > rowB.yield
        end)
    end

    -- Total Result List
    do
        local craftResultItems = craftRecipeData:GetCraftResultItemsBySelectedReagentCombinationID()
        local totalResultsList = resultAnalysisContent.totalResultsList
        totalResultsList:Remove()

        for _, craftResultItem in ipairs(craftResultItems.resultItems) do
            local itemLink = craftResultItem.item:GetItemLink()
            local count = craftResultItem.quantity
            local value = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemLink(itemLink) * CraftSim.CONST.AUCTION_HOUSE_CUT
            if isWorkOrder then
                value = 0
            end
            -- TODO: maybe quantityMulticraft?
            totalResultsList:Add(
            ---@param row CraftSim.CRAFT_LOG.TOTAL_RESULTS_LIST.ROW
                function(row)
                    row.itemColumn.icon:SetItem(itemLink)
                    row.countColumn.text:SetText("x " .. count)
                    row.valueColumn.text:SetText(CraftSim.UTIL:FormatMoney(value, true))
                    row.count = count
                    row.itemLink = itemLink
                    row.value = value
                    row.tooltipOptions = {
                        itemLink = itemLink,
                        anchor = "ANCHOR_RIGHT",
                        owner = row.frameList.frame
                    }
                end)
        end


        totalResultsList:UpdateDisplay(
        ---@param rowA CraftSim.CRAFT_LOG.TOTAL_RESULTS_LIST.ROW
        ---@param rowB CraftSim.CRAFT_LOG.TOTAL_RESULTS_LIST.ROW
            function(rowA, rowB)
                return rowA.value > rowB.value
            end)
    end
end

---@param recipeID RecipeID last crafted recipeID
function CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(recipeID)
    local advFrame = CraftSim.CRAFT_LOG.advFrame
    local recipeData = CraftSim.INIT.currentRecipeData

    -- only update if its the shown recipeID otherwise no need
    if not recipeData or recipeData.recipeID ~= recipeID then return end

    -- also only update if the log is shown to save cpu time when its hidden
    if not advFrame:IsVisible() then return end

    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CRAFT_LOG.currentSessionData or CraftSim.CraftSessionData()
    local sessionData = CraftSim.CRAFT_LOG.currentSessionData
    local craftRecipeData = sessionData:GetCraftRecipeData(recipeID)

    local craftingStatData = craftRecipeData.craftingStatData

    advFrame.content.crafts:SetText(craftingStatData.numCrafts)
    -- need to wait for expectedItem to load..
    if recipeData.resultData.expectedItem then
        recipeData.resultData.expectedItem:ContinueOnItemLoad(function()
            advFrame.content.recipeHeader:SetText(recipeData:GetFormattedRecipeName(true, true))
        end)
    else
        advFrame.content.recipeHeader:SetText(recipeData:GetFormattedRecipeName(true, true))
    end

    self:UpdateCalculationComparison(craftRecipeData, recipeData)
    self:UpdateReagentDetails(craftRecipeData)
    self:UpdateResultAnalysis(craftRecipeData)
end
