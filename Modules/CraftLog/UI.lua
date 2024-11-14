---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.CRAFT_LOG
CraftSim.CRAFT_LOG = CraftSim.CRAFT_LOG

---@class CraftSim.CRAFT_LOG.UI
CraftSim.CRAFT_LOG.UI = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_LOG)

function CraftSim.CRAFT_LOG.UI:Init()
    ---@class CraftSim.CRAFT_LOG.LOG_FRAME : GGUI.Frame
    local logFrame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPLEFT",
        anchorB = "TOPRIGHT",
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
        anchorParent = logFrame.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = -20,
        sizeX = 700,
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
                            if ProfessionsFrame.CraftingPage.CraftingOutputLog:IsVisible() then
                                ProfessionsFrame.CraftingPage.CraftingOutputLog:Hide()
                            end
                        else
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_ITEM_CRAFTED_RESULT")
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_CURRENCY_REWARD_RESULT")
                        end
                    end)

                hideBlizzardCraftingLog:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        "Hides the default UI " .. f.bb("Crafting Output Log") .. " when crafting");
                end)

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

                local autoShowCB = rootDescription:CreateCheckbox(
                    f.g("Auto Show ") .. "on Craft",
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFT_LOG_AUTO_SHOW")
                    end, function()
                        local newValue = not CraftSim.DB.OPTIONS:Get(
                            "CRAFT_LOG_AUTO_SHOW")
                        CraftSim.DB.OPTIONS:Save("CRAFT_LOG_AUTO_SHOW",
                            newValue)

                        if newValue then
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:UnregisterAllEvents()
                            if ProfessionsFrame.CraftingPage.CraftingOutputLog:IsVisible() then
                                ProfessionsFrame.CraftingPage.CraftingOutputLog:Hide()
                            end
                        else
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_ITEM_CRAFTED_RESULT")
                            ProfessionsFrame.CraftingPage.CraftingOutputLog:RegisterEvent(
                                "TRADE_SKILL_CURRENCY_REWARD_RESULT")
                        end
                    end)

                hideBlizzardCraftingLog:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        "Hides the default UI " .. f.bb("Crafting Output Log") .. " when crafting");
                end)

                local exportOptions = rootDescription:CreateButton("Export Data")

                exportOptions:CreateButton("as " .. f.bb("JSON"), function()
                    local json = CraftSim.CRAFT_LOG:ExportJSON()
                    CraftSim.UTIL:ShowTextCopyBox(json)
                end)

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
    local tabSizeX = 700
    local tabSizeY = 340

    ---@class CraftSim.CRAFT_LOG.DETAILS_FRAME : GGUI.Frame
    frame = frame

    frame.content.recipeHeader = GGUI.Text {
        parent = frame.content, anchorPoints = {
        { anchorParent = frame.content,     anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -11, offsetX = 10 },
        { anchorParent = frame.title.frame, anchorA = "RIGHT",   anchorB = "LEFT" },
    },
    }

    frame.content.crafts = GGUI.Text {
        parent = frame.content, anchorPoints = {
        { anchorParent = frame.content,     anchorA = "TOPRIGHT", anchorB = "TOPRIGHT", offsetY = -16, offsetX = -10 },
        { anchorParent = frame.title.frame, anchorA = "LEFT",     anchorB = "RIGHT" }, },
        prefix = L(CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX),
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
        anchorPoints = { { anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -80 } },
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

    local itemColumnWidth = 170
    local distributionColumnWidth = 40

    content.resultDistributionList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 20, offsetY = -80 } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
        showBorder = true,
        columnOptions = {
            {
                label = "Item",
                width = itemColumnWidth,
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
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG.RESULT_DISTRIBUTION_LIST.ROW : GGUI.FrameList.Row
            row = row
            row.resultColumn = columns[1]
            row.distColumn = columns[2]

            row.resultColumn.text = GGUI.Text {
                parent = row.resultColumn,
                anchorPoints = { { anchorParent = row.resultColumn, anchorA = "LEFT", anchorB = "LEFT" } },
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = itemColumnWidth,
            }

            row.distColumn.text = GGUI.Text {
                parent = row.distColumn,
                anchorPoints = { { anchorParent = row.distColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = distributionColumnWidth,
            }
        end,
        selectionOptions = { noSelectionColor = true },
    }

    local yieldColumnWidth = 40
    content.yieldDistributionList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.resultDistributionList.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetY = 0, offsetX = 40 } },
        parent = content,
        sizeY = 220,
        scale = 0.9,
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

            row.itemColumn.text = GGUI.Text {
                parent = row.itemColumn,
                anchorPoints = { { anchorParent = row.itemColumn, anchorA = "LEFT", anchorB = "LEFT", } },
                justifyOptions = { type = "H", align = "LEFT" },
                fixedWidth = itemColumnWidth
            }

            row.yieldColumn.text = GGUI.Text {
                parent = row.yieldColumn,
                anchorPoints = { { anchorParent = row.yieldColumn } },
                justifyOptions = { type = "H", align = "RIGHT" },
                fixedWidth = yieldColumnWidth
            }

            row.distColumn.text = GGUI.Text {
                parent = row.distColumn,
                anchorPoints = { { anchorParent = row.distColumn } },
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

    local statNameColumnWidth = 135
    local expectedValueColumnWidth = 125
    local observedValueColumnWidth = 125

    content.comparisonList = GGUI.FrameList {
        parent = content,
        scale = 0.9,
        anchorPoints = { {
            anchorParent = content,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -80, offsetX = 20,
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

    GGUI.HelpIcon {
        parent = content,
        anchorParent = content.comparisonList.frame,
        offsetY = 10,
        anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT",
        text = f.bb("Ø") .. " .. Average\n" .. f.bb("#") .. " .. Count",
    }

    -- TODO: LibGraph Magic
    -- for profit..
    -- for procs over time.. and so on
    -- based on selected stat
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

        -- -- add saved reagents
        -- local savedReagentsText = ""
        -- if #CraftSim.CRAFT_LOG.currentSessionData.totalSavedReagents > 0 then
        --     savedReagentsText = "\n" .. L(CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS) .. "\n"
        --     for _, savedReagent in pairs(CraftSim.CRAFT_LOG.currentSessionData.totalSavedReagents) do
        --         savedReagentsText = savedReagentsText ..
        --             (savedReagent.quantity or 1) .. " x " .. (savedReagent.item:GetItemLink() or "") .. "\n"
        --     end
        -- end
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

        if craftResult.triggeredResourcefulness then
            for _, savedReagent in pairs(craftResult.savedReagents) do
                local qualityID = savedReagent.qualityID
                local iconAsText = GUTIL:IconToText(savedReagent.item:GetItemIcon(), 25)
                local qualityAsText = (qualityID > 0 and GUTIL:GetQualityIconString(qualityID, 20, 20)) or ""
                resourcesText = resourcesText ..
                    "\n" .. iconAsText .. " " .. savedReagent.quantity .. " " .. qualityAsText
            end
        end

        local roundedProfit = GUTIL:Round(craftResult.profit * 10000) / 10000
        local profitText = CraftSim.UTIL:FormatMoney(roundedProfit, true)
        local chanceText = ""

        if not recipeData.isSalvageRecipe and recipeData.supportsCraftingStats then
            chanceText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5) ..
                GUTIL:Round(craftResult.craftingChance * 100, 1) .. "%\n"
        end

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

        local newText =
            resultsText ..
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1) .. profitText .. "\n" ..
            chanceText ..
            ((craftResult.triggeredMulticraft and (GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3), GUTIL.COLORS.EPIC) .. multicraftExtraItemsText)) or "") ..
            ((craftResult.triggeredResourcefulness and (GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4) .. "\n", GUTIL.COLORS.UNCOMMON) .. resourcesText .. "\n")) or "")

        craftLog:AddMessage("\n" .. newText)
    end
    -- FrameList
    self:UpdateResultItemLog()
end

---@param craftRecipeData CraftSim.CraftRecipeData
---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFT_LOG.UI:UpdateCalculationComparison(craftRecipeData, recipeData)
    local adv = CraftSim.CRAFT_LOG.advFrame
    local comparisonTabContent = adv.content.calculationComparisonTab
        .content --[[@as CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB.CONTENT]]
    local comparisonList = comparisonTabContent.comparisonList

    comparisonList:Remove()

    local function addComparison(statName, expectedValue, observedValue)
        comparisonList:Add(
        ---@param row CraftSim.CRAFT_LOG_ADV.COMPARISON_LIST.ROW
            function(row)
                row.statNameColumn.text:SetText(statName)
                row.expectedValueColumn.text:SetText(expectedValue)
                row.observedValueColumn.text:SetText(observedValue)
            end)
    end

    -- TODO: Add colorization if expected values are met

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
        CraftSim.UTIL:FormatMoney(craftRecipeData.expectedStats.totalProfit, true),
        CraftSim.UTIL:FormatMoney(craftRecipeData.observedStats.totalProfit, true)
    )

    addComparison(
        "Ø Profit: ",
        CraftSim.UTIL:FormatMoney(craftRecipeData.expectedStats.averageProfit, true),
        CraftSim.UTIL:FormatMoney(craftRecipeData.observedStats.averageProfit, true)
    )

    addComparison(
        "Sum Crafting Costs: ",
        CraftSim.UTIL:FormatMoney(-craftRecipeData.expectedStats.totalCraftingCosts, true),
        CraftSim.UTIL:FormatMoney(-craftRecipeData.observedStats.totalCraftingCosts, true)
    )

    addComparison(
        "Ø Crafting Costs: ",
        CraftSim.UTIL:FormatMoney(-craftRecipeData.expectedStats.averageCraftingCosts, true),
        CraftSim.UTIL:FormatMoney(-craftRecipeData.observedStats.averageCraftingCosts, true)
    )

    if recipeData.supportsMulticraft then
        addComparison(
            "# Multicraft: ",
            GUTIL:Round(craftRecipeData.expectedStats.numMulticraft, 2),
            colorizeObservedValue(craftRecipeData.observedStats.numMulticraft,
                craftRecipeData.expectedStats.numMulticraft)
        )

        addComparison(
            "Sum Extra Items: ",
            GUTIL:Round(craftRecipeData.expectedStats.totalMulticraftExtraItems, 2),
            colorizeObservedValue(GUTIL:Round(craftRecipeData.observedStats.totalMulticraftExtraItems, 2),
                GUTIL:Round(craftRecipeData.expectedStats.totalMulticraftExtraItems, 2))
        )

        addComparison(
            "Ø Extra Items: ",
            GUTIL:Round(craftRecipeData.expectedStats.averageMulticraftExtraItems, 2),
            colorizeObservedValue(GUTIL:Round(craftRecipeData.observedStats.averageMulticraftExtraItems, 2),
                GUTIL:Round(craftRecipeData.expectedStats.averageMulticraftExtraItems, 2))
        )
    end

    if recipeData.supportsResourcefulness then
        addComparison(
            "# Resourcefulness: ",
            GUTIL:Round(craftRecipeData.expectedStats.numResourcefulness, 2),
            colorizeObservedValue(craftRecipeData.observedStats.numResourcefulness,
                GUTIL:Round(craftRecipeData.expectedStats.numResourcefulness, 2))
        )

        addComparison(
            "Sum Saved Costs: ",
            CraftSim.UTIL:FormatMoney(craftRecipeData.expectedStats.totalResourcefulnessSavedCosts, true),
            CraftSim.UTIL:FormatMoney(craftRecipeData.observedStats.totalResourcefulnessSavedCosts, true)
        )

        addComparison(
            "Ø Saved Costs: ",
            CraftSim.UTIL:FormatMoney(craftRecipeData.expectedStats.averageResourcefulnessSavedCosts, true),
            CraftSim.UTIL:FormatMoney(craftRecipeData.observedStats.averageResourcefulnessSavedCosts, true)
        )
    end

    if recipeData.supportsIngenuity then
        addComparison(
            "# Ingenuity: ",
            GUTIL:Round(craftRecipeData.expectedStats.numIngenuity, 2),
            colorizeObservedValue(craftRecipeData.observedStats.numIngenuity,
                GUTIL:Round(craftRecipeData.expectedStats.numIngenuity, 2))
        )

        addComparison(
            "Sum Concentration: ",
            GUTIL:Round(craftRecipeData.expectedStats.totalConcentrationCost, 0),
            colorizeObservedValue(GUTIL:Round(craftRecipeData.observedStats.totalConcentrationCost, 0),
                GUTIL:Round(craftRecipeData.expectedStats.totalConcentrationCost, 0))
        )

        addComparison(
            "Ø Concentration: ",
            GUTIL:Round(craftRecipeData.expectedStats.averageConcentrationCost, 0),
            colorizeObservedValue(GUTIL:Round(craftRecipeData.observedStats.averageConcentrationCost, 0),
                GUTIL:Round(craftRecipeData.expectedStats.averageConcentrationCost, 0))
        )
    end

    comparisonList:UpdateDisplay()
end

---@param craftRecipeData CraftSim.CraftRecipeData
function CraftSim.CRAFT_LOG.UI:UpdateReagentDetails(craftRecipeData)
    local reagentDetailsContent = CraftSim.CRAFT_LOG.advFrame.content.reagentDetailsTab
        .content --[[@as CraftSim.CRAFT_LOG.REAGENT_DETAILS_TAB.CONTENT]]
    local reagentsList = reagentDetailsContent.reagentList
    local savedReagentsList = reagentDetailsContent.savedReagentsList

    local craftResultItems = craftRecipeData.totalItems -- TODO: make switchable by reagentCombinationID

    -- Crafting Reagents
    do
        reagentsList:Remove()
        for _, craftResultSavedReagent in ipairs(craftResultItems.reagents) do
            reagentsList:Add(
            ---@param row CraftSim.CRAFT_LOG_ADV.SAVED_REAGENTS_LIST.ROW
                function(row)
                    row.craftResultSavedReagent = craftResultSavedReagent
                    row.itemColumn.text:SetText(craftResultSavedReagent.item:GetItemLink())
                    row.countColumn.text:SetText(craftResultSavedReagent.quantity or 0)
                    row.costColumn.text:SetText(CraftSim.UTIL:FormatMoney(-craftResultSavedReagent.costs, true))
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
                    row.itemColumn.text:SetText(craftResultSavedReagent.item:GetItemLink())
                    row.countColumn.text:SetText(craftResultSavedReagent.quantity or 0)
                    row.costColumn.text:SetText(CraftSim.UTIL:FormatMoney(craftResultSavedReagent.costs, true))
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

    local craftResultItems = craftRecipeData.totalItems -- TODO: make switchable by reagentCombinationID

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
                    row.resultColumn.text:SetText(craftResultItem.item:GetItemLink())
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
        local yieldDistributionList = resultAnalysisContent.yieldDistributionList
        yieldDistributionList:Remove()

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
                    yieldDistributionList:Add(
                    ---@param row CraftSim.CRAFT_LOG.YIELD_DISTRIBUTION_LIST.ROW
                        function(row)
                            row.itemColumn.text:SetText(itemLink)
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
end

---@param recipeID RecipeID last crafted recipeID
function CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(recipeID)
    local advFrame = CraftSim.CRAFT_LOG.advFrame
    local recipeData = CraftSim.INIT.currentRecipeData

    -- only update if its the shown recipeID otherwise no need
    if not recipeData or recipeData.recipeID ~= recipeID then return end

    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CRAFT_LOG.currentSessionData or CraftSim.CraftSessionData()
    local sessionData = CraftSim.CRAFT_LOG.currentSessionData
    local craftRecipeData = sessionData:GetCraftRecipeData(recipeID)

    advFrame.content.crafts:SetText(craftRecipeData.numCrafts)

    advFrame.content.recipeHeader:SetText(recipeData:GetFormattedRecipeName(true, true))

    self:UpdateCalculationComparison(craftRecipeData, recipeData)
    self:UpdateReagentDetails(craftRecipeData)
    self:UpdateResultAnalysis(craftRecipeData)
end
