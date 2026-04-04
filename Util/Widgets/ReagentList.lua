---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---@class CraftSim.WIDGETS.ReagentList.ConstructorOptions
---@field parent Frame
---@field anchorPoints GGUI.AnchorPoint[]?
---@field onHeaderClick fun(qualityID: integer)?
---@field onQuantityChanged fun(row: GGUI.FrameList.Row, columns: table, qualityIndex: integer)?

---@class CraftSim.WIDGETS.ReagentList : CraftSim.Object
---@overload fun(options: CraftSim.WIDGETS.ReagentList.ConstructorOptions): CraftSim.WIDGETS.ReagentList
---@field frame Frame usable as an anchor target (both lists share the same position)
---@field activeList GGUI.FrameList?
---@field private listQ3 GGUI.FrameList
---@field private listSimplified GGUI.FrameList
CraftSim.WIDGETS.ReagentList = CraftSim.Object:extend()

local QUALITY_ICON_SIZE = 15
local QUALITY_COLUMN_WIDTH = 50

---@param options CraftSim.WIDGETS.ReagentList.ConstructorOptions
function CraftSim.WIDGETS.ReagentList:new(options)
    options = options or {}

    local anchorPoints = options.anchorPoints or {
        {
            anchorParent = options.parent,
            offsetX = 10,
            offsetY = -20,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
        },
    }

    self.listQ3 = self:CreateQ3List(options.parent, anchorPoints)
    self.listSimplified = self:CreateSimplifiedList(options.parent, anchorPoints)
    self.frame = self.listQ3.frame
    self.onHeaderClick = options.onHeaderClick
    self.onQuantityChanged = options.onQuantityChanged

    self:CreateHeaderButtons(self.listQ3, false)
    self:CreateHeaderButtons(self.listSimplified, true)
end

---@private
function CraftSim.WIDGETS.ReagentList:CreateRowConstructor(qualityCount)
    local reagentList = self
    return function(columns, row)
        local iconColumn = columns[1]
        iconColumn.icon = GGUI.Icon {
            parent = iconColumn,
            anchorParent = iconColumn,
            anchorA = "LEFT",
            anchorB = "LEFT",
            sizeX = 30,
            sizeY = 30,
            hideQualityIcon = true,
        }

        for qualityIndex = 1, qualityCount do
            local qColumn = columns[qualityIndex + 1]
            qColumn.itemID = nil
            qColumn.input = GGUI.NumericInput {
                mouseWheelStep = 1,
                parent = qColumn,
                anchorParent = qColumn,
                sizeX = QUALITY_COLUMN_WIDTH * 0.8,
                anchorA = "CENTER",
                anchorB = "CENTER",
                minValue = 0,
                allowDecimals = false,
                onNumberValidCallback = function()
                    if reagentList.onQuantityChanged then
                        reagentList.onQuantityChanged(row, columns, qualityIndex)
                    end
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

        local requiredColumn = columns[qualityCount + 2]
        requiredColumn.text = GGUI.Text {
            parent = requiredColumn,
            anchorParent = requiredColumn,
            anchorA = "CENTER",
            anchorB = "CENTER",
            justifyOptions = { type = "H", align = "CENTER" },
        }
    end
end

---@private
function CraftSim.WIDGETS.ReagentList:BuildColumnOptions(qualityCount)
    local cols = {
        { width = 35 }, -- reagent icon
    }
    for _ = 1, qualityCount do
        table.insert(cols, {
            width = QUALITY_COLUMN_WIDTH,
            justifyOptions = { type = "H", align = "CENTER" },
        })
    end
    table.insert(cols, {
        width = 30,
        justifyOptions = { type = "H", align = "CENTER" },
    })
    return cols
end

---@private
---@return GGUI.FrameList
function CraftSim.WIDGETS.ReagentList:CreateQ3List(parent, anchorPoints)
    return GGUI.FrameList {
        parent = parent,
        anchorPoints = anchorPoints,
        sizeY = 120,
        hideScrollbar = true,
        rowHeight = 35,
        autoAdjustHeight = true,
        columnOptions = self:BuildColumnOptions(3),
        rowConstructor = self:CreateRowConstructor(3),
    }
end

---@private
---@return GGUI.FrameList
function CraftSim.WIDGETS.ReagentList:CreateSimplifiedList(parent, anchorPoints)
    return GGUI.FrameList {
        parent = parent,
        anchorPoints = anchorPoints,
        sizeY = 120,
        hideScrollbar = true,
        rowHeight = 35,
        autoAdjustHeight = true,
        columnOptions = self:BuildColumnOptions(2),
        rowConstructor = self:CreateRowConstructor(2),
    }
end

---@private
function CraftSim.WIDGETS.ReagentList:CreateHeaderButtons(frameList, simplified)
    if not frameList.headerColumns then
        return
    end

    local qualityCount = simplified and 2 or 3
    for qualityID = 1, qualityCount do
        local headerColumn = frameList.headerColumns[qualityID + 1]
        if headerColumn then
            self:CreateHeaderButton(headerColumn, qualityID, simplified)
        end
    end
end

---@private
function CraftSim.WIDGETS.ReagentList:CreateHeaderButton(headerColumn, qualityID, simplified)
    local reagentList = self
    local button = GGUI.Button {
        parent = headerColumn,
        anchorParent = headerColumn,
        anchorA = "CENTER",
        anchorB = "CENTER",
        sizeX = QUALITY_COLUMN_WIDTH,
        sizeY = 20,
        label = "",
        clickCallback = function()
            if reagentList.onHeaderClick then
                reagentList.onHeaderClick(qualityID)
            end
        end,
    }

    local atlasName = simplified
        and ("Professions-Icon-Quality-12-Tier" .. qualityID)
        or ("Professions-Icon-Quality-Tier" .. qualityID)
    local iconTexture = button.frame:CreateTexture(nil, "OVERLAY")
    iconTexture:SetSize(QUALITY_ICON_SIZE, QUALITY_ICON_SIZE)
    iconTexture:SetAtlas(atlasName)
    iconTexture:SetPoint("CENTER", button.frame, "CENTER", 0, 0)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.WIDGETS.ReagentList:Populate(recipeData)
    recipeData.reagentData:FillUnallocatedRequiredReagents()
    local simplified = recipeData:IsSimplifiedQualityRecipe()
    self.activeList = simplified and self.listSimplified or self.listQ3
    self.frame = self.activeList.frame
    local inactiveList = simplified and self.listQ3 or self.listSimplified

    inactiveList:Hide()
    inactiveList:Remove()
    self.activeList:Show()
    self.activeList:Remove()

    for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
        if reagent.hasQuality then
            self.activeList:Add(function(row, columns)
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

    self.activeList:UpdateDisplay()
end

function CraftSim.WIDGETS.ReagentList:Hide()
    self.listQ3:Hide()
    self.listSimplified:Hide()
end
