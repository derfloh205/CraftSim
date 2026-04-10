---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.SALVAGING.UI
CraftSim.SALVAGING.UI = {}

---@type CraftSim.SALVAGING.FRAME?
CraftSim.SALVAGING.frame = nil

local L = CraftSim.UTIL:GetLocalizer()

---@param category CraftSim.MillingShuffleCategory
---@return CraftSim.MillingShuffleRow[]
local function GetRowsForCategory(category)
    return GUTIL:Filter(CraftSim.MILLING_SHUFFLE_DATA or {}, function(row)
        return row.category == category
    end)
end

---@return ItemMixin[]
local function CollectItemsForRows(rows)
    local items = {}
    local seen = {}
    for _, row in ipairs(rows) do
        if not seen[row.herbItemID] then
            seen[row.herbItemID] = true
            table.insert(items, Item:CreateFromItemID(row.herbItemID))
        end
        if not seen[row.pigmentItemID] then
            seen[row.pigmentItemID] = true
            table.insert(items, Item:CreateFromItemID(row.pigmentItemID))
        end
    end
    return items
end

---@return GGUI.FrameList.ColumnOption[]
local function GetMillingColumnOptions()
    local function resizeCol(col, newWidth)
        col.text:SetWidth(newWidth)
    end

    return {
        {
            label = L("SALVAGING_COLUMN_HERB"),
            width = 132,
            headerScale = 0.8,
            sortFunc = function(rowA, rowB)
                return (rowA.herbLink or "") < (rowB.herbLink or "")
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_PIGMENT"),
            width = 132,
            headerScale = 0.8,
            sortFunc = function(rowA, rowB)
                return (rowA.pigmentLink or "") < (rowB.pigmentLink or "")
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_COST"),
            width = 62,
            headerScale = 0.8,
            sortFunc = function(rowA, rowB)
                return rowA.costCopper < rowB.costCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_VALUE_MIN"),
            width = 68,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.valueMinCopper < rowB.valueMinCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_VALUE_AVG"),
            width = 68,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.valueAvgCopper < rowB.valueAvgCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_VALUE_MAX"),
            width = 68,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.valueMaxCopper < rowB.valueMaxCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_PROFIT_MIN"),
            width = 68,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.profitMinCopper < rowB.profitMinCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_PROFIT_AVG"),
            width = 68,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.profitAvgCopper < rowB.profitAvgCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_PROFIT_MAX"),
            width = 68,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.profitMaxCopper < rowB.profitMaxCopper
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
        {
            label = L("SALVAGING_COLUMN_PROFIT_PCT"),
            width = 40,
            headerScale = 0.75,
            sortFunc = function(rowA, rowB)
                return rowA.profitPctAvg < rowB.profitPctAvg
            end,
            resizable = true,
            resizeCallback = resizeCol,
            customSortArrowOffsetX = 0,
        },
    }
end

---@param list GGUI.FrameList
---@param rows CraftSim.MillingShuffleRow[]
local function PopulateMillingList(list, rows)
    list:Remove()
    if #rows == 0 then
        list:Add(function(row, columns)
            row.herbLink = ""
            row.pigmentLink = ""
            row.costCopper = 0
            row.valueMinCopper = 0
            row.valueAvgCopper = 0
            row.valueMaxCopper = 0
            row.profitMinCopper = 0
            row.profitAvgCopper = 0
            row.profitMaxCopper = 0
            row.profitPctAvg = 0
            columns[1].text:SetText(CraftSim.GUTIL:ColorizeText(L("SALVAGING_MILLING_EMPTY"), CraftSim.GUTIL.COLORS.GREY))
            for i = 2, 10 do
                columns[i].text:SetText("")
            end
        end)
        list:UpdateDisplay()
        return
    end

    local items = CollectItemsForRows(rows)
    GUTIL:ContinueOnAllItemsLoaded(items, function()
        for _, dataRow in ipairs(rows) do
            local herbPrice = select(1, CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(dataRow.herbItemID, true, false, true))
            local pigmentPrice = select(1,
                CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(dataRow.pigmentItemID, true, false, true))
            local costCopper = herbPrice * dataRow.herbsPerMill
            local pMin = dataRow.pigmentsMin
            local pMax = dataRow.pigmentsMax
            local pAvg = (pMin + pMax) / 2
            local valueMinCopper = pigmentPrice * pMin
            local valueAvgCopper = pigmentPrice * pAvg
            local valueMaxCopper = pigmentPrice * pMax
            local profitMinCopper = valueMinCopper - costCopper
            local profitAvgCopper = valueAvgCopper - costCopper
            local profitMaxCopper = valueMaxCopper - costCopper
            local profitPctAvg = 0
            if costCopper > 0 then
                profitPctAvg = (profitAvgCopper / costCopper) * 100
            end

            local herbItem = Item:CreateFromItemID(dataRow.herbItemID)
            local pigmentItem = Item:CreateFromItemID(dataRow.pigmentItemID)
            local herbLink = herbItem:GetItemLink() or ("item:" .. dataRow.herbItemID)
            local pigmentLink = pigmentItem:GetItemLink() or ("item:" .. dataRow.pigmentItemID)

            list:Add(function(row, columns)
                row.herbLink = herbLink
                row.pigmentLink = pigmentLink
                row.costCopper = costCopper
                row.valueMinCopper = valueMinCopper
                row.valueAvgCopper = valueAvgCopper
                row.valueMaxCopper = valueMaxCopper
                row.profitMinCopper = profitMinCopper
                row.profitAvgCopper = profitAvgCopper
                row.profitMaxCopper = profitMaxCopper
                row.profitPctAvg = profitPctAvg

                columns[1].text:SetText(herbLink)
                columns[2].text:SetText(pigmentLink)
                columns[3].text:SetText(CraftSim.UTIL:FormatMoney(costCopper, true))
                columns[4].text:SetText(CraftSim.UTIL:FormatMoney(valueMinCopper, true))
                columns[5].text:SetText(CraftSim.UTIL:FormatMoney(valueAvgCopper, true))
                columns[6].text:SetText(CraftSim.UTIL:FormatMoney(valueMaxCopper, true))
                columns[7].text:SetText(CraftSim.UTIL:FormatMoney(profitMinCopper, true, nil, false))
                columns[8].text:SetText(CraftSim.UTIL:FormatMoney(profitAvgCopper, true, nil, false))
                columns[9].text:SetText(CraftSim.UTIL:FormatMoney(profitMaxCopper, true, nil, false))
                columns[10].text:SetText(string.format("%.1f%%", profitPctAvg))
            end)
        end
        list:UpdateDisplay()
    end)
end

function CraftSim.SALVAGING.UI:UpdateMillingTab()
    local frame = CraftSim.SALVAGING.frame
    if not frame then
        return
    end
    ---@type CraftSim.SALVAGING.FRAME.CONTENT
    local content = frame.content
    if not content.millingTab then
        return
    end
    local millingContent = content.millingTab.content
    PopulateMillingList(millingContent.r2r1List, GetRowsForCategory("r2_r1"))
    PopulateMillingList(millingContent.r1r1List, GetRowsForCategory("r1_r1"))
    PopulateMillingList(millingContent.r2r2List, GetRowsForCategory("r2_r2"))
end

---@param parent Frame
---@param anchorParent Region
---@param offsetY number
---@param listKey string
---@return GGUI.FrameList
local function CreateMillingList(parent, anchorParent, offsetY, listKey)
    return GGUI.FrameList({
        sizeY = 86,
        rowHeight = 18,
        showBorder = true,
        parent = parent,
        anchorParent = anchorParent,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetX = 0,
        offsetY = offsetY,
        savedVariablesTableLayoutConfig = CraftSim.UTIL:GetFrameListLayoutConfig(listKey),
        columnOptions = GetMillingColumnOptions(),
        rowConstructor = function(columns, _row)
            for i = 1, 10 do
                local col = columns[i]
                col.text = GGUI.Text({
                    parent = col,
                    anchorParent = col,
                    anchorA = "LEFT",
                    anchorB = "LEFT",
                    justifyOptions = { align = "LEFT", type = "H" },
                    fixedWidth = col:GetWidth(),
                    scale = i <= 2 and 0.82 or 0.78,
                })
            end
        end,
    })
end

function CraftSim.SALVAGING.UI:Init()
    local sizeX = 784
    local sizeY = 468

    ---@class CraftSim.SALVAGING.FRAME : GGUI.Frame
    CraftSim.SALVAGING.frame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.SALVAGING,
        title = L("SALVAGING_TITLE"),
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
        hide = true,
    })

    ---@class CraftSim.SALVAGING.FRAME.CONTENT : Frame
    local content = CraftSim.SALVAGING.frame.content

    content.millingTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content,
            offsetY = -2,
            label = L("SALVAGING_TAB_MILLING"),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        initialTab = true,
        top = true,
    })

    content.prospectingTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content.millingTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = L("SALVAGING_TAB_PROSPECTING"),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        top = true,
    })

    GGUI.BlizzardTabSystem { content.millingTab, content.prospectingTab }

    local millingContent = content.millingTab.content

    millingContent.helpIcon = GGUI.HelpIcon({
        parent = millingContent,
        anchorParent = millingContent,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = 4,
        offsetY = -4,
        text = L("SALVAGING_MILLING_HELP"),
    })

    millingContent.refreshButton = GGUI.Button({
        parent = millingContent,
        anchorParent = millingContent,
        anchorA = "TOPRIGHT",
        anchorB = "TOPRIGHT",
        offsetX = -6,
        offsetY = -2,
        label = L("SALVAGING_REFRESH"),
        sizeY = 22,
        adjustWidth = true,
        width = 8,
        clickCallback = function()
            CraftSim.SALVAGING.UI:UpdateMillingTab()
        end,
    })

    millingContent.r2r1Title = GGUI.Text({
        parent = millingContent,
        anchorParent = millingContent.helpIcon.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetX = 0,
        offsetY = -8,
        text = L("SALVAGING_SECTION_R2_R1"),
        scale = 0.95,
    })

    millingContent.r2r1List = CreateMillingList(millingContent, millingContent.r2r1Title.frame, -3,
        "SALVAGING_MILLING_R2R1_LIST")

    millingContent.r1r1Title = GGUI.Text({
        parent = millingContent,
        anchorParent = millingContent.r2r1List.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetX = 0,
        offsetY = -8,
        text = L("SALVAGING_SECTION_R1_R1"),
        scale = 0.95,
    })

    millingContent.r1r1List = CreateMillingList(millingContent, millingContent.r1r1Title.frame, -3,
        "SALVAGING_MILLING_R1R1_LIST")

    millingContent.r2r2Title = GGUI.Text({
        parent = millingContent,
        anchorParent = millingContent.r1r1List.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetX = 0,
        offsetY = -8,
        text = L("SALVAGING_SECTION_R2_R2"),
        scale = 0.95,
    })

    millingContent.r2r2List = CreateMillingList(millingContent, millingContent.r2r2Title.frame, -3,
        "SALVAGING_MILLING_R2R2_LIST")

    local prospectingContent = content.prospectingTab.content
    prospectingContent.placeholder = GGUI.Text({
        parent = prospectingContent,
        anchorParent = prospectingContent,
        anchorA = "CENTER",
        anchorB = "CENTER",
        offsetY = -20,
        text = L("SALVAGING_PROSPECTING_SOON"),
        scale = 1,
    })
end

function CraftSim.SALVAGING.UI:ShowAndLoad()
    local frame = CraftSim.SALVAGING.frame
    if not frame then
        return
    end
    self:UpdateMillingTab()
    frame:Show()
end
