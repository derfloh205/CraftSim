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
    local detailsFrame = GGUI.Frame({
        parent = logFrame.frame,
        anchorParent = logFrame.frame,
        anchorA = "TOPLEFT",
        anchorB = "TOPRIGHT",
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
    CraftSim.CRAFT_LOG.detailsFrame = detailsFrame

    local hideBlizzardCraftingLog = CraftSim.DB.OPTIONS:Get("CRAFT_LOG_HIDE_BLIZZARD_CRAFTING_LOG")

    if hideBlizzardCraftingLog and ProfessionsFrame.CraftingPage.CraftingOutputLog then
        ProfessionsFrame.CraftingPage.CraftingOutputLog:UnregisterAllEvents()
    end

    self:InitLogFrame(logFrame)
    self:InitAdvancedLogFrame(detailsFrame)
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
                            CraftSim.CRAFT_LOG.detailsFrame:Show()
                        else
                            CraftSim.CRAFT_LOG.detailsFrame:Hide()
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

    ---@class CraftSim.CRAFT_LOG.STAT_DETAILS_TAB : GGUI.BlizzardTab
    frame.content.statDetailsTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = L("CRAFT_LOG_STAT_DETAILS_TAB"),
            anchorParent = frame.content.calculationComparisonTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
        },
        parent = frame.content, anchorParent = frame.content,
        sizeX = tabSizeX, sizeY = tabSizeY,
        top = true,
    }

    self:InitStatDetailsTab(frame.content.statDetailsTab)

    ---@class CraftSim.CRAFT_LOG.RESULT_DETAILS_TAB : GGUI.BlizzardTab
    frame.content.resultDetailsTab = GGUI.BlizzardTab {
        buttonOptions = {
            label = L("CRAFT_LOG_RESULT_DETAILS_TAB"),
            anchorParent = frame.content.statDetailsTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
        },
        parent = frame.content, anchorParent = frame.content,
        sizeX = tabSizeX, sizeY = tabSizeY,
        top = true,
    }

    self:InitResultDetailsTab(frame.content.resultDetailsTab)

    GGUI.BlizzardTabSystem { frame.content.calculationComparisonTab, frame.content.statDetailsTab, frame.content.resultDetailsTab }

    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
end

---@param statDetailsTab CraftSim.CRAFT_LOG.STAT_DETAILS_TAB
function CraftSim.CRAFT_LOG.UI:InitStatDetailsTab(statDetailsTab)
    ---@class CraftSim.CRAFT_LOG.STAT_DETAILS_TAB
    statDetailsTab = statDetailsTab
    ---@class CraftSim.CRAFT_LOG.STAT_DETAILS_TAB.CONTENT : Frame
    local content = statDetailsTab.content

    content.statisticsTitle = CraftSim.FRAME:CreateText(
        L(CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS), content,
        content, "TOP", "TOP", 270, 0)
    content.statisticsText = CraftSim.FRAME:CreateText(
        L(CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING), content,
        content.statisticsTitle,
        "TOPLEFT", "BOTTOMLEFT", -70, -10, nil, nil, { type = "H", value = "LEFT" })
    content.statisticsText:SetWidth(300)
end

---@param statisticsTrackerTab CraftSim.CRAFT_LOG.RESULT_DETAILS_TAB
function CraftSim.CRAFT_LOG.UI:InitResultDetailsTab(statisticsTrackerTab)
    ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.CONTENT : Frame
    local content = statisticsTrackerTab.content

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
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.RESULT_COLUMN : Frame
            local resultColumn = columns[1]
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.DIST_COLUMN : Frame
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
        text = L(CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_DETAILS_TAB_DISTRIBUTION_LABEL)
    }

    GGUI.HelpIcon {
        parent = content, anchorParent = content.resultDistributionList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPRIGHT", offsetX = -5, offsetY = -4,
        text = L(CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_DETAILS_TAB_DISTRIBUTION_HELP)
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
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.STATISTICS_COLUMN : Frame
            local statisticsColumn = columns[1]
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.VALUE_COLUMN : Frame
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
        text = L(CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_DETAILS_TAB_MULTICRAFT)
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
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.STATISTICS_COLUMN : Frame
            local statisticsColumn = columns[1]
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.VALUE_COLUMN : Frame
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
        text = L(CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_DETAILS_TAB_RESOURCEFULNESS)
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
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.STATISTICS_COLUMN : Frame
            local itemColumn = columns[1]
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.YIELD_COLUMN : Frame
            local yieldColumn = columns[2]
            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.DIST_COLUMN : Frame
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
        text = L(CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_DETAILS_TAB_YIELD_DDISTRIBUTION)
    }
end

---@param calculationComparisonTab CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB
function CraftSim.CRAFT_LOG.UI:InitCalculationComparisonTab(calculationComparisonTab)
    ---@class CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB
    calculationComparisonTab = calculationComparisonTab
    ---@class CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB.CONTENT : Frame
    local content = calculationComparisonTab.content

    content.comparisonList = GGUI.FrameList {
        parent = content,
        scale = 0.9,
        anchorPoints = { {
            anchorParent = content,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -70, offsetX = 20,
        } },
        showBorder = true,
        sizeY = 200,
        columnOptions = {
            {
                label = "Value",
                width = 80, -- stat name
            },
            {
                label = "Expected",
                width = 150 -- expected
            },
            {
                label = "Observed",
                width = 150, -- observed
            }
        },
        rowConstructor = function(columns, row)
            ---@class CraftSim.CRAFT_LOG_ADV.COMPARISON_LIST.ROW
            row = row
            row.statNameColumn = columns[1]
            row.expectedValueColumn = columns[2]
            row.realValueColumn = columns[3]

            row.statNameColumn.text = GGUI.Text {
                parent = row.statNameColumn,
                anchorPoints = { { anchorParent = row.statNameColumn } },
                justifyOptions = { type = "H", align = "LEFT" }
            }

            row.expectedValueColumn.text = GGUI.Text {
                parent = row.expectedValueColumn,
                anchorPoints = { { anchorParent = row.expectedValueColumn } },
            }

            row.realValueColumn.text = GGUI.Text {
                parent = row.realValueColumn,
                anchorPoints = { { anchorParent = row.realValueColumn } },
            }
        end
    }

    -- TODO: LibGraph Magic
    -- for profit..
    -- for procs over time.. and so on
    -- based on selected stat
end

function CraftSim.CRAFT_LOG.UI:UpdateItemList()
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

function CraftSim.CRAFT_LOG.UI:UpdateCalculationComparison(craftRecipeData)
    local detailsFrame = CraftSim.CRAFT_LOG.detailsFrame
    local comparisonTabContent = detailsFrame.content.calculationComparisonTab
        .content --[[@as CraftSim.CRAFT_LOG.CALCULATION_COMPARISON_TAB.CONTENT]]

    detailsFrame.content.crafts:SetText(craftRecipeData.numCrafts)
end

function CraftSim.CRAFT_LOG.UI:UpdateRecipeData(recipeID)
    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_LOG)
    print("Update RecipeData: " .. tostring(recipeID))

    -- only update frontend if its the shown recipeID
    if not CraftSim.INIT.currentRecipeData or CraftSim.INIT.currentRecipeData.recipeID ~= recipeID then
        print("no frontend update: is not shown recipe")
        return
    end
    print("Do update cause its the shown recipe")

    local craftResultFrame = CraftSim.CRAFT_LOG.detailsFrame

    local craftSessionData = CraftSim.CRAFT_LOG.currentSessionData
    if not craftSessionData then
        print("create new craft session data")
        craftSessionData                      = CraftSim.CraftSessionData()
        CraftSim.CRAFT_LOG.currentSessionData = craftSessionData
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

    -- UI Updates
    -- new

    do
        self:UpdateCalculationComparison(craftRecipeData)
    end

    -- legacy
    do
        local craftProfitsContent = craftResultFrame.content.statDetailsTab
            .content --[[@as CraftSim.CRAFT_LOG.STAT_DETAILS_TAB.CONTENT]]
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
            L(CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX) ..
            craftRecipeData.numCrafts .. "\n\n"

        if CraftSim.INIT.currentRecipeData.supportsCraftingStats then
            statisticsText = statisticsText ..
                L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2) .. expectedAverageProfit .. "\n"
            statisticsText = statisticsText ..
                L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3) .. actualAverageProfit .. "\n"
            statisticsText = statisticsText ..
                L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4) .. actualProfit .. "\n\n"
            statisticsText = statisticsText ..
                L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5) .. "\n\n"

            if CraftSim.INIT.currentRecipeData.supportsMulticraft then
                local expectedProcs = tonumber(CraftSim.GUTIL:Round(
                        CraftSim.INIT.currentRecipeData.professionStats.multicraft:GetPercent(true) *
                        craftRecipeData.numCrafts, 1)) or
                    0
                if craftRecipeData.numMulticraft >= expectedProcs then
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numMulticraft, CraftSim.GUTIL.COLORS.GREEN) ..
                        " / " .. expectedProcs .. "\n"
                else
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numMulticraft, CraftSim.GUTIL.COLORS.RED) ..
                        " / " .. expectedProcs .. "\n"
                end
                local averageExtraItems = 0
                local expectedAdditionalItems = 0
                local multicraftExtraItemsFactor = 1 + CraftSim.INIT.currentRecipeData.professionStats.multicraft
                    :GetExtraValue()
                local mcConstant = CraftSim.UTIL:GetMulticraftConstantByBaseYield(CraftSim.INIT.currentRecipeData
                    .baseItemAmount)
                local maxExtraItems = (mcConstant * CraftSim.INIT.currentRecipeData.baseItemAmount) *
                    multicraftExtraItemsFactor
                expectedAdditionalItems = tonumber(CraftSim.GUTIL:Round((1 + maxExtraItems) / 2, 2)) or 0

                averageExtraItems = tonumber(CraftSim.GUTIL:Round(
                    (craftRecipeData.numMulticraft > 0 and (craftRecipeData.numMulticraftExtraItems / craftRecipeData.numMulticraft)) or
                    0, 2)) or 0
                if averageExtraItems == 0 then
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8) ..
                        averageExtraItems .. " / " .. expectedAdditionalItems .. "\n"
                elseif averageExtraItems >= expectedAdditionalItems then
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8) ..
                        CraftSim.GUTIL:ColorizeText(averageExtraItems, CraftSim.GUTIL.COLORS.GREEN) ..
                        " / " .. expectedAdditionalItems .. "\n"
                else
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8) ..
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
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN)
                elseif averageSavedCosts >= expectedAverageSavedCosts then
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN) ..
                        "\n" ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0) ..
                        CraftSim.GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(averageSavedCosts),
                            CraftSim.GUTIL.COLORS.GREEN) ..
                        " / " .. CraftSim.UTIL:FormatMoney(expectedAverageSavedCosts)
                else
                    statisticsText = statisticsText ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9) ..
                        CraftSim.GUTIL:ColorizeText(craftRecipeData.numResourcefulness, CraftSim.GUTIL.COLORS.GREEN) ..
                        "\n" ..
                        L(CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0) ..
                        CraftSim.GUTIL:ColorizeText(CraftSim.UTIL:FormatMoney(averageSavedCosts),
                            CraftSim.GUTIL.COLORS.RED) ..
                        " / " .. CraftSim.UTIL:FormatMoney(expectedAverageSavedCosts)
                end
            end
        else
            statisticsText = statisticsText ..
                L(CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1) .. actualProfit .. "\n\n"
        end


        craftProfitsContent.statisticsText:SetText(statisticsText)
    end

    -- Statistics Tracker
    do
        local statisticsTrackerTabContent = craftResultFrame.content.resultDetailsTab
            .content --[[@as CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.CONTENT]]

        CraftSim.CRAFT_LOG.detailsFrame.content.recipeHeader:SetText(
            GUTIL:IconToText(CraftSim.INIT.currentRecipeData.recipeIcon, 20, 20) ..
            " [" .. CraftSim.INIT.currentRecipeData.recipeName .. "]")

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
                        [1] --[[@as CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.RESULT_COLUMN]]
                    local distColumn = columns
                        [2] --[[@as CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESULT_DISTRIBUTION_LIST.DIST_COLUMN]]

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
                        ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.STATISTICS_COLUMN : Frame
                        local statisticsColumn = columns[1]
                        ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.MULTICRAFT_STATISTICS_LIST.VALUE_COLUMN : Frame
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
                        ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.STATISTICS_COLUMN : Frame
                        local statisticsColumn = columns[1]
                        ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.RESOURCEFULNESS_STATISTICS_LIST.VALUE_COLUMN : Frame
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
                            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.STATISTICS_COLUMN : Frame
                            local itemColumn = columns[1]
                            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.YIELD_COLUMN : Frame
                            local yieldColumn = columns[2]
                            ---@class CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.YIELD_STATISTICS_LIST.DIST_COLUMN : Frame
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
