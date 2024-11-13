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

    content.yieldStatisticsList = GGUI.FrameList {
        anchorPoints = { { anchorParent = content.resultDistributionList.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -20, offsetX = -5 } },
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

    local statNameColumnWidth = 135
    local expectedValueColumnWidth = 125
    local observedValueColumnWidth = 125

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
---@param recipeData CraftSim.RecipeData Open Recipe Data
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

---@param recipeID RecipeID last crafted recipeID
function CraftSim.CRAFT_LOG.UI:UpdateAdvancedCraftLogDisplay(recipeID)
    local advFrame = CraftSim.CRAFT_LOG.advFrame

    -- only update if its the shown recipeID otherwise no need
    if not CraftSim.INIT.currentRecipeData or CraftSim.INIT.currentRecipeData.recipeID ~= recipeID then
        return
    end

    CraftSim.CRAFT_LOG.currentSessionData = CraftSim.CRAFT_LOG.currentSessionData or CraftSim.CraftSessionData()
    local sessionData = CraftSim.CRAFT_LOG.currentSessionData
    local craftRecipeData = sessionData:GetCraftRecipeData(recipeID)

    -- update numCrafts
    advFrame.content.crafts:SetText(craftRecipeData.numCrafts)

    do
        self:UpdateCalculationComparison(craftRecipeData, CraftSim.INIT.currentRecipeData)
    end

    -- Statistics Tracker
    do
        local statisticsTrackerTabContent = advFrame.content.resultDetailsTab
            .content --[[@as CraftSim.CRAFT_LOG.STATISTICS_TRACKER_TAB.CONTENT]]

        CraftSim.CRAFT_LOG.advFrame.content.recipeHeader:SetText(
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
