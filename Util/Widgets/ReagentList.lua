---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---@class CraftSim.WIDGETS.ReagentListCallbacks
---@field onHeaderClick fun(qualityID: integer)?
---@field onQuantityChanged fun(row: GGUI.FrameList.Row, columns: table, qualityIndex: integer)?

---Create shared quality-reagent framelists (Q3 and simplified variants).
---@param parent Frame
---@param anchorPoints GGUI.AnchorPoint[]|nil
---@param callbacks CraftSim.WIDGETS.ReagentListCallbacks
---@return GGUI.FrameList reagentListQ3, GGUI.FrameList reagentListSimplified
function CraftSim.WIDGETS.CreateReagentLists(parent, anchorPoints, callbacks)
    callbacks = callbacks or {}

    -- match old CraftQueue quality buttons (small icon centered on red rectangle)
    local reagentListQualityIconOffsetY = 0
    local reagentListQualityIconOffsetX = -2
    local reagentListQualityIconHeaderSize = 15
    local reagentListQualityColumnWidth = 50

    anchorPoints = anchorPoints or {
        {
            anchorParent = parent,
            offsetX = 10,
            offsetY = -20,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
        },
    }

    local function handleHeaderClick(qualityID)
        if callbacks.onHeaderClick then
            callbacks.onHeaderClick(qualityID)
        end
    end

    local function handleQuantityChanged(row, columns, qualityIndex)
        if callbacks.onQuantityChanged then
            callbacks.onQuantityChanged(row, columns, qualityIndex)
        end
    end

    -- 3-quality layout
    local reagentListQ3 = GGUI.FrameList {
        parent = parent,
        anchorPoints = anchorPoints,
        sizeY = 120,
        hideScrollbar = true,
        rowHeight = 35,
        autoAdjustHeight = true,
        columnOptions = {
            {
                width = 35, -- reagentIcon
            },
            {
                width = reagentListQualityColumnWidth, -- q1
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                width = reagentListQualityColumnWidth, -- q2
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                width = reagentListQualityColumnWidth, -- q3
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                width = 20,
                justifyOptions = { type = "H", align = "CENTER" }, -- required quantity
            },
        },
        rowConstructor = function(columns, row)
            local iconColumn = columns[1]
            local q1Column = columns[2]
            local q2Column = columns[3]
            local q3Column = columns[4]
            local requiredColumn = columns[5]

            iconColumn.icon = GGUI.Icon {
                parent = iconColumn,
                anchorParent = iconColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                sizeX = 30,
                sizeY = 30,
                hideQualityIcon = true,
            }

            local function setupQualityColumn(qColumn, qualityIndex)
                qColumn.itemID = nil
                qColumn.input = GGUI.NumericInput {
                    mouseWheelStep = 1,
                    parent = qColumn,
                    anchorParent = qColumn,
                    sizeX = reagentListQualityColumnWidth * 0.8,
                    anchorA = "CENTER",
                    anchorB = "CENTER",
                    minValue = 0,
                    allowDecimals = false,
                    onNumberValidCallback = function()
                        handleQuantityChanged(row, columns, qualityIndex)
                    end,
                    borderAdjustWidth = 1.2,
                }

                qColumn:EnableMouse(true)
                ---@type ItemMixin?
                qColumn.item = nil
                GGUI:SetTooltipsByTooltipOptions(qColumn, qColumn)

                qColumn:SetScript("OnMouseDown", function()
                    if IsShiftKeyDown() and qColumn.item then
                        qColumn.item:ContinueOnItemLoad(function()
                            ChatEdit_InsertLink(qColumn.item:GetItemLink())
                        end)
                    end
                end)
            end

            setupQualityColumn(q1Column, 1)
            setupQualityColumn(q2Column, 2)
            setupQualityColumn(q3Column, 3)

            requiredColumn.text = GGUI.Text {
                parent = requiredColumn,
                anchorParent = requiredColumn,
                anchorA = "CENTER",
                anchorB = "CENTER",
                justifyOptions = { type = "H", align = "CENTER" },
            }
        end,
    }

    -- simplified 2-quality layout
    local reagentListSimplified = GGUI.FrameList {
        parent = parent,
        anchorPoints = anchorPoints,
        sizeY = 120,
        hideScrollbar = true,
        rowHeight = 35,
        autoAdjustHeight = true,
        columnOptions = {
            {
                width = 35, -- reagentIcon
            },
            {
                width = reagentListQualityColumnWidth, -- q1
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                width = reagentListQualityColumnWidth, -- q2
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                width = 20,
                justifyOptions = { type = "H", align = "CENTER" }, -- required quantity
            },
        },
        rowConstructor = function(columns, row)
            local iconColumn = columns[1]
            local q1Column = columns[2]
            local q2Column = columns[3]
            local requiredColumn = columns[4]

            iconColumn.icon = GGUI.Icon {
                parent = iconColumn,
                anchorParent = iconColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                sizeX = 30,
                sizeY = 30,
                hideQualityIcon = true,
            }

            local function setupQualityColumn(qColumn, qualityIndex)
                qColumn.itemID = nil
                qColumn.input = GGUI.NumericInput {
                    mouseWheelStep = 1,
                    parent = qColumn,
                    anchorParent = qColumn,
                    sizeX = reagentListQualityColumnWidth * 0.8,
                    anchorA = "CENTER",
                    anchorB = "CENTER",
                    minValue = 0,
                    allowDecimals = false,
                    onNumberValidCallback = function()
                        handleQuantityChanged(row, columns, qualityIndex)
                    end,
                    borderAdjustWidth = 1.2,
                }

                qColumn:EnableMouse(true)
                ---@type ItemMixin?
                qColumn.item = nil
                GGUI:SetTooltipsByTooltipOptions(qColumn, qColumn)

                qColumn:SetScript("OnMouseDown", function()
                    if IsShiftKeyDown() and qColumn.item then
                        qColumn.item:ContinueOnItemLoad(function()
                            ChatEdit_InsertLink(qColumn.item:GetItemLink())
                        end)
                    end
                end)
            end

            setupQualityColumn(q1Column, 1)
            setupQualityColumn(q2Column, 2)

            requiredColumn.text = GGUI.Text {
                parent = requiredColumn,
                anchorParent = requiredColumn,
                anchorA = "CENTER",
                anchorB = "CENTER",
                justifyOptions = { type = "H", align = "CENTER" },
            }
        end,
    }

    -- convert header quality columns into visible buttons
    local function createHeaderButton(frameList, headerIndex, label, qualityID)
        if not frameList.headerColumns then
            return
        end
        local headerColumn = frameList.headerColumns[headerIndex]
        if not headerColumn then
            return
        end

        local button = GGUI.Button {
            parent = headerColumn,
            anchorParent = headerColumn,
            anchorA = "CENTER",
            anchorB = "CENTER",
            -- let the button fill the full column width, centered vertically
            sizeX = reagentListQualityColumnWidth,
            sizeY = 20,
            -- use default UIPanelButtonTemplate to get the red rectangle look
            label = label,
            clickCallback = function()
                handleHeaderClick(qualityID)
            end,
        }

        -- ensure the icon string text is applied even if template/font changed
        button:SetText(label)
    end

    createHeaderButton(
        reagentListQ3,
        2,
        GUTIL:GetQualityIconString(
            1,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconOffsetX,
            reagentListQualityIconOffsetY
        ),
        1
    )
    createHeaderButton(
        reagentListQ3,
        3,
        GUTIL:GetQualityIconString(
            2,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconOffsetX,
            reagentListQualityIconOffsetY
        ),
        2
    )
    createHeaderButton(
        reagentListQ3,
        4,
        GUTIL:GetQualityIconString(
            3,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconOffsetX,
            reagentListQualityIconOffsetY
        ),
        3
    )

    createHeaderButton(
        reagentListSimplified,
        2,
        GUTIL:GetQualityIconStringSimplified(
            1,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconOffsetX,
            reagentListQualityIconOffsetY
        ),
        1
    )
    createHeaderButton(
        reagentListSimplified,
        3,
        GUTIL:GetQualityIconStringSimplified(
            2,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconHeaderSize,
            reagentListQualityIconOffsetX,
            reagentListQualityIconOffsetY
        ),
        2
    )

    return reagentListQ3, reagentListSimplified
end

---@param frameList GGUI.FrameList
---@param recipeData CraftSim.RecipeData
---@param simplified boolean
function CraftSim.WIDGETS.PopulateReagentListFromRecipe(frameList, recipeData, simplified)
    frameList:Remove()

    for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
        if reagent.hasQuality then
            frameList:Add(function(row, columns)
                ---@type GGUI.Icon
                local icon = columns[1].icon
                local q1Column = columns[2]
                local q2Column = columns[3]

                row.reagent = reagent

                if simplified then
                    local q1Input = q1Column.input --[[@as GGUI.NumericInput]]
                    local q2Input = q2Column.input --[[@as GGUI.NumericInput]]

                    q1Column.itemID = reagent.items[1].item:GetItemID()
                    q2Column.itemID = reagent.items[2].item:GetItemID()

                    icon:SetItem(q1Column.itemID)

                    q1Input:SetValue(reagent.items[1].quantity)
                    q1Input.maxValue = reagent.requiredQuantity
                    q2Input:SetValue(reagent.items[2].quantity)
                    q2Input.maxValue = reagent.requiredQuantity

                    local requiredText = columns[4].text --[[@as GGUI.Text]]
                    requiredText:SetText("/" .. reagent.requiredQuantity)
                else
                    local q3Column = columns[4]
                    local requiredColumn = columns[5]

                    local q1Input = q1Column.input --[[@as GGUI.NumericInput]]
                    local q2Input = q2Column.input --[[@as GGUI.NumericInput]]
                    local q3Input = q3Column.input --[[@as GGUI.NumericInput]]

                    q1Column.itemID = reagent.items[1].item:GetItemID()
                    q2Column.itemID = reagent.items[2].item:GetItemID()
                    q3Column.itemID = reagent.items[3].item:GetItemID()

                    icon:SetItem(q1Column.itemID)

                    q1Input:SetValue(reagent.items[1].quantity)
                    q1Input.maxValue = reagent.requiredQuantity
                    q2Input:SetValue(reagent.items[2].quantity)
                    q2Input.maxValue = reagent.requiredQuantity
                    q3Input:SetValue(reagent.items[3].quantity)
                    q3Input.maxValue = reagent.requiredQuantity

                    local requiredText = requiredColumn.text --[[@as GGUI.Text]]
                    requiredText:SetText("/" .. reagent.requiredQuantity)
                end
            end)
        end
    end

    frameList:UpdateDisplay()
end

