---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.WORK_ORDER_TRACKER
CraftSim.WORK_ORDER_TRACKER = CraftSim.WORK_ORDER_TRACKER

---@class CraftSim.WORK_ORDER_TRACKER.UI : CraftSim.Module.UI
CraftSim.WORK_ORDER_TRACKER.UI = {}

---@type CraftSim.WORK_ORDER_TRACKER.FRAME
CraftSim.WORK_ORDER_TRACKER.frame = nil

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local L = CraftSim.LOCAL:GetLocalizer()
local f = GUTIL:GetFormatter()

CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE = {
    TIME = "TIME",
    CHARACTER = "CHARACTER",
}

CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE_LOCALIZATION_IDS = {
    TIME = "WORK_ORDER_TRACKER_SORT_MODE_TIME",
    CHARACTER = "WORK_ORDER_TRACKER_SORT_MODE_CHARACTER",
}

CraftSim.WORK_ORDER_TRACKER.UI.STATUS_FILTER_ORDER = {
    CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.READY,
    CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.IN_PROGRESS,
    CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.NEEDS_REAGENTS,
    CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.NEEDS_QUALITY,
    CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.NEEDS_RECIPE,
    CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.BLOCKED,
}

--- GGUI calls UpdateDisplay() with no args on header clicks; merge default ordering when no column sort is active.
---@param frameList GGUI.FrameList
---@param defaultSortFunc fun(rowA: GGUI.FrameList.Row, rowB: GGUI.FrameList.Row): boolean
local function WrapFrameListUpdateDisplayWithDefaultSort(frameList, defaultSortFunc)
    local baseUpdateDisplay = GGUI.FrameList.UpdateDisplay
    function frameList:UpdateDisplay(sortFunc)
        if sortFunc ~= nil then
            return baseUpdateDisplay(self, sortFunc)
        end
        return baseUpdateDisplay(self, function(rowA, rowB)
            if self.activeSortFunc then
                return self.activeSortFunc(rowA, rowB)
            end
            return defaultSortFunc(rowA, rowB)
        end)
    end
end

---@param rowA GGUI.FrameList.Row
---@param rowB GGUI.FrameList.Row
---@return boolean
function CraftSim.WORK_ORDER_TRACKER.UI:SortWorkOrderRowsDefault(rowA, rowB)
    local sortMode = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_SORT_MODE")
    -- legacy saved value from removed recipe sort option
    if sortMode == "RECIPE" then
        sortMode = CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE.CHARACTER
    end

    if sortMode == CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE.CHARACTER then
        local a = rowA.sortCrafterName or ""
        local b = rowB.sortCrafterName or ""
        if a ~= b then
            return a < b
        end
        if rowA.profession ~= rowB.profession then
            return rowA.profession < rowB.profession
        end
        if rowA.timeBucketRank ~= rowB.timeBucketRank then
            return rowA.timeBucketRank < rowB.timeBucketRank
        end
        return (rowA.timeRemainingSeconds or 0) < (rowB.timeRemainingSeconds or 0)
    end

    if rowA.timeBucketRank ~= rowB.timeBucketRank then
        return rowA.timeBucketRank < rowB.timeBucketRank
    end
    if (rowA.timeRemainingSeconds or 0) ~= (rowB.timeRemainingSeconds or 0) then
        return (rowA.timeRemainingSeconds or 0) < (rowB.timeRemainingSeconds or 0)
    end
    local a = rowA.sortCrafterName or ""
    local b = rowB.sortCrafterName or ""
    if a ~= b then
        return a < b
    end
    return (rowA.orderID or 0) < (rowB.orderID or 0)
end

---@param craftability string?
---@return boolean
function CraftSim.WORK_ORDER_TRACKER.UI:IsStatusFilterEnabled(craftability)
    if not craftability then
        return true
    end
    local filtered = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_FILTERED_STATUS") or {}
    if filtered[craftability] == nil then
        return true
    end
    return filtered[craftability]
end

---@param craftability string
function CraftSim.WORK_ORDER_TRACKER.UI:SetStatusFilterEnabled(craftability, enabled)
    local filtered = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_FILTERED_STATUS") or {}
    filtered[craftability] = enabled
    CraftSim.DB.OPTIONS:Save("WORK_ORDER_TRACKER_FILTERED_STATUS", filtered)
    self:UpdateDisplay()
end

---@param craftability string
function CraftSim.WORK_ORDER_TRACKER.UI:ToggleStatusFilter(craftability)
    self:SetStatusFilterEnabled(craftability, not self:IsStatusFilterEnabled(craftability))
end

--- Ascending comparator for one list column (GGUI applies descending by swapping row arguments).
---@param sortMode "CHARACTER"|"TIME"
---@param rowA GGUI.FrameList.Row
---@param rowB GGUI.FrameList.Row
---@return boolean
local function CompareWorkOrderColumnAsc(sortMode, rowA, rowB)
    if sortMode == "CHARACTER" then
        local a = rowA.sortCrafterName or ""
        local b = rowB.sortCrafterName or ""
        if a ~= b then
            return a < b
        end
        if rowA.profession ~= rowB.profession then
            return rowA.profession < rowB.profession
        end
        if rowA.timeBucketRank ~= rowB.timeBucketRank then
            return rowA.timeBucketRank < rowB.timeBucketRank
        end
        return (rowA.timeRemainingSeconds or 0) < (rowB.timeRemainingSeconds or 0)
    end

    if rowA.timeBucketRank ~= rowB.timeBucketRank then
        return rowA.timeBucketRank < rowB.timeBucketRank
    end
    local a = rowA.timeRemainingSeconds or 0
    local b = rowB.timeRemainingSeconds or 0
    if a ~= b then
        return a < b
    end
    local crafterA = rowA.sortCrafterName or ""
    local crafterB = rowB.sortCrafterName or ""
    if crafterA ~= crafterB then
        return crafterA < crafterB
    end
    return (rowA.orderID or 0) < (rowB.orderID or 0)
end

---@param crafterUID CrafterUID
---@param orderID number
---@return string
local function RowKey(crafterUID, orderID)
    return tostring(crafterUID) .. ":" .. tostring(orderID)
end

---@param craftability string
---@return string
local function FormatCraftabilityText(craftability)
    return CraftSim.WORK_ORDER_TRACKER:GetCraftabilityLabel(craftability)
end

---@param craftability string
---@return string colorPrefix
local function CraftabilityColorPrefix(craftability)
    local CRAFT = CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY
    if craftability == CRAFT.READY or craftability == CRAFT.IN_PROGRESS then
        return f.g
    end
    if craftability == CRAFT.NEEDS_RECIPE or craftability == CRAFT.NEEDS_QUALITY then
        return f.r
    end
    return f.l
end

---@param bucket string
---@return string colorPrefix
local function TimeBucketColorPrefix(bucket)
    local BUCKET = CraftSim.WORK_ORDER_TRACKER.TIME_BUCKET
    if bucket == BUCKET.EXPIRED then
        return f.grey
    end
    if bucket == BUCKET.LT_6H then
        return f.r
    end
    if bucket == BUCKET.H_6_12 then
        return f.l
    end
    return f.bb
end

---@param craftability string
---@param detail string?
---@return boolean
local function ShouldShowCraftabilityDetail(craftability, detail)
    if not detail or detail == "" then
        return false
    end
    local CRAFT = CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY
    if craftability == CRAFT.NEEDS_REAGENTS and detail == "Missing Reagents" then
        return false
    end
    if craftability == CRAFT.NEEDS_RECIPE and detail == "Not Learned" then
        return false
    end
    if craftability == CRAFT.NEEDS_QUALITY and detail == "Below minimum quality" then
        return false
    end
    if craftability == CRAFT.ON_COOLDOWN and detail == "On Cooldown" then
        return false
    end
    return true
end

---@param quality number?
---@return string
local function FormatQualityTooltipLine(label, quality)
    if not quality then
        return ""
    end
    return "\n" .. label .. ": " .. GUTIL:GetQualityIconString(quality, 15, 15)
end

---@param lastSnapshotAt number?
---@return string
local function FormatLastSnapshotAge(lastSnapshotAt)
    if not lastSnapshotAt or lastSnapshotAt <= 0 then
        return ""
    end
    local secondsAgo = math.max(GetTime() - lastSnapshotAt, 0)
    local timeText = SecondsToTime(secondsAgo, false, false, 1)
    if secondsAgo < 1 or timeText == nil or timeText == "" then
        timeText = "0 Sec"
    end
    return string.format(L("WORK_ORDER_TRACKER_LAST_SNAPSHOT_FMT"), timeText)
end

---@param orderSnapshot CraftSim.PatronWorkOrderSnapshot
---@return string
local function FormatExpirationTooltipLine(orderSnapshot)
    local endTime = orderSnapshot.isClaimed and orderSnapshot.claimEndTime or orderSnapshot.expirationTime
    if not endTime or endTime <= 0 then
        return ""
    end
    local formatted = CraftSim.CooldownData.FormatLocalDateTime(endTime)
    local labelKey = orderSnapshot.isClaimed and "WORK_ORDER_TRACKER_TOOLTIP_CLAIM_ENDS"
        or "WORK_ORDER_TRACKER_TOOLTIP_EXPIRES"
    return "\n" .. string.format(L(labelKey), formatted)
end

---@param orderSnapshot CraftSim.PatronWorkOrderSnapshot
---@return string
local function FormatAcquisitionTooltipLine(orderSnapshot)
    if not orderSnapshot.acquisitionHint or orderSnapshot.acquisitionHint == "" then
        return ""
    end

    local CRAFT = CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY
    local label
    if orderSnapshot.craftability == CRAFT.NEEDS_QUALITY then
        label = L("WORK_ORDER_TRACKER_TOOLTIP_SUGGESTED_SPEC")
    else
        label = L("WORK_ORDER_TRACKER_TOOLTIP_RECIPE_SOURCE")
    end

    return "\n" .. label .. ": " .. orderSnapshot.acquisitionHint
end

---@param orderSnapshot CraftSim.PatronWorkOrderSnapshot
---@return string
local function GetAcquisitionButtonTooltip(orderSnapshot)
    if not orderSnapshot.acquisitionHint or orderSnapshot.acquisitionHint == "" then
        return L("WORK_ORDER_TRACKER_HINT_UNAVAILABLE")
    end

    if orderSnapshot.acquisitionKind == CraftSim.RECIPE_ACQUISITION.KIND.SPEC then
        return L("WORK_ORDER_TRACKER_HINT_OPEN_SPEC") .. "\n" .. orderSnapshot.acquisitionHint
    end

    if orderSnapshot.acquisitionKind == CraftSim.RECIPE_ACQUISITION.KIND.DROP then
        return L("WORK_ORDER_TRACKER_HINT_ADD_TO_SHOPPING_LIST") .. "\n" .. orderSnapshot.acquisitionHint
    end

    return L("WORK_ORDER_TRACKER_HINT_VIEW_RECIPE_SOURCE") .. "\n" .. orderSnapshot.acquisitionHint
end

---@param row GGUI.FrameList.Row
---@param rowData { crafterUID: CrafterUID, profession: Enum.Profession, orderSnapshot: CraftSim.PatronWorkOrderSnapshot, lastSnapshotAt: number }
local function PopulateWorkOrderTrackerRow(row, rowData)
    local crafterUID = rowData.crafterUID
    local profession = rowData.profession
    local orderSnapshot = rowData.orderSnapshot
    local lastSnapshotAt = rowData.lastSnapshotAt

    local crafterColumn = row.columns[1]
    local recipeColumn = row.columns[2]
    local timeColumn = row.columns[3]
    local statusColumn = row.columns[4]

    local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
    local professionIcon = CraftSim.CONST.PROFESSION_ICONS[profession]
    local crafterName = select(1, CraftSim.UTIL:SplitCrafterUID(crafterUID)) or crafterUID
    local crafterProfessionText = GUTIL:IconToText(professionIcon, 15, 15) ..
        " " .. f.class(crafterName, crafterClass)

    row.rowKey = RowKey(crafterUID, orderSnapshot.orderID)
    row.crafterUID = crafterUID
    row.profession = profession
    row.orderID = orderSnapshot.orderID
    row.orderSnapshot = orderSnapshot
    row.lastSnapshotAt = lastSnapshotAt
    row.sortCrafterName = crafterName

    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        row.characterHighlight:Show()
    else
        row.characterHighlight:Hide()
    end

    crafterColumn.text:SetText(crafterProfessionText)

    local recipeText = orderSnapshot.recipeName
    if orderSnapshot.minQuality then
        recipeText = recipeText .. " " .. GUTIL:GetQualityIconString(orderSnapshot.minQuality, 15, 15)
    end
    if orderSnapshot.isClaimed then
        recipeText = recipeText .. f.bb(" [" .. L("WORK_ORDER_TRACKER_CLAIMED") .. "]")
    end
    recipeColumn.text:SetText(recipeText)

    local bucket, remaining = CraftSim.WORK_ORDER_TRACKER:GetTimeBucketForSnapshot(orderSnapshot)
    row.timeBucket = bucket
    row.timeBucketRank = CraftSim.WORK_ORDER_TRACKER:GetTimeBucketSortRank(bucket)
    row.timeRemainingSeconds = remaining
    timeColumn.text:SetText(TimeBucketColorPrefix(bucket)(CraftSim.WORK_ORDER_TRACKER:GetTimeBucketLabel(bucket)))

    row.craftability = orderSnapshot.craftability
    local statusText = FormatCraftabilityText(orderSnapshot.craftability)
    statusColumn.text:SetText(CraftabilityColorPrefix(orderSnapshot.craftability)(statusText))

    local isCurrentPlayer = crafterUID == CraftSim.UTIL:GetPlayerCrafterUID()
    local showHintButton = isCurrentPlayer
        and orderSnapshot.acquisitionHint
        and orderSnapshot.acquisitionHint ~= ""
        and (orderSnapshot.craftability == CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.NEEDS_RECIPE
            or orderSnapshot.craftability == CraftSim.WORK_ORDER_TRACKER.CRAFTABILITY.NEEDS_QUALITY)

    if showHintButton then
        CraftSim.RECIPE_ACQUISITION:UpdateAcquisitionButton(
            statusColumn.hintButton,
            { sourceKind = orderSnapshot.acquisitionKind },
            function()
                CraftSim.WORK_ORDER_TRACKER:NavigateToAcquisitionHint(orderSnapshot, profession, orderSnapshot.expansionID)
            end,
            function(btn)
                GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(GetAcquisitionButtonTooltip(orderSnapshot), 1, 1, 1, true)
                GameTooltip:Show()
            end)
    else
        CraftSim.RECIPE_ACQUISITION:UpdateAcquisitionButton(statusColumn.hintButton, nil, nil)
    end

    local snapshotAge = FormatLastSnapshotAge(lastSnapshotAt)

    local detailLine = ""
    if ShouldShowCraftabilityDetail(orderSnapshot.craftability, orderSnapshot.craftabilityDetail) then
        detailLine = "\n" .. orderSnapshot.craftabilityDetail
    end

    row.tooltipOptions = {
        anchor = "ANCHOR_CURSOR",
        owner = row.frame,
        text = crafterProfessionText ..
            "\n" .. orderSnapshot.recipeName ..
            "\n" .. L("WORK_ORDER_TRACKER_TOOLTIP_STATUS") .. ": " .. FormatCraftabilityText(orderSnapshot.craftability) ..
            detailLine ..
            FormatAcquisitionTooltipLine(orderSnapshot) ..
            FormatQualityTooltipLine(L("WORK_ORDER_TRACKER_TOOLTIP_REQUIRED_QUALITY"), orderSnapshot.minQuality) ..
            FormatQualityTooltipLine(L("WORK_ORDER_TRACKER_TOOLTIP_QUALITY"), orderSnapshot.expectedQuality) ..
            FormatExpirationTooltipLine(orderSnapshot) ..
            "\n" .. snapshotAge,
    }
end

function CraftSim.WORK_ORDER_TRACKER.UI:Init()
    local sizeX = 620
    local sizeY = 320
    local onClose, onMinimize, onMaximize = CraftSim.MODULES:GetModuleFrameStateCallbacks(self.module)

    ---@class CraftSim.WORK_ORDER_TRACKER.FRAME : GGUI.Frame
    CraftSim.WORK_ORDER_TRACKER.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        title = L("WORK_ORDER_TRACKER_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = onClose,
        onCollapseCallback = onMinimize,
        onCollapseOpenCallback = onMaximize,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })

    self.module.frame = CraftSim.WORK_ORDER_TRACKER.frame

    ---@class CraftSim.WORK_ORDER_TRACKER.FRAME.CONTENT : Frame
    local content = CraftSim.WORK_ORDER_TRACKER.frame.content

    content.listTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content,
            offsetY = -2,
            label = L("WORK_ORDER_TRACKER_LIST_TAB_LABEL"),
        },
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        initialTab = true,
        top = true,
    })

    content.optionsTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content.listTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = L("WORK_ORDER_TRACKER_OPTIONS_TAB_LABEL"),
        },
        parent = content,
        anchorParent = content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        top = true,
    })

    ---@class CraftSim.WORK_ORDER_TRACKER.UI.LIST_TAB : GGUI.BlizzardTab
    local listTab = content.listTab
    ---@class CraftSim.WORK_ORDER_TRACKER.UI.OPTIONS_TAB : GGUI.BlizzardTab
    local optionsTab = content.optionsTab

    local listPad = 12
    local listSizeX = sizeX - (listPad * 2) - 30
    local listSizeY = sizeY - 67

    listTab.content.refreshButton = GGUI.Button {
        parent = listTab.content,
        anchorPoints = { { anchorParent = listTab.content, anchorA = "TOPRIGHT", anchorB = "TOPRIGHT", offsetX = -listPad, offsetY = -6 } },
        label = L("WORK_ORDER_TRACKER_REFRESH_BUTTON"),
        adjustWidth = true,
        sizeX = 30,
        clickCallback = function()
            CraftSim.WORK_ORDER_TRACKER:SnapshotCurrentProfession(function()
                CraftSim.WORK_ORDER_TRACKER.UI:UpdateDisplay()
            end)
        end,
    }

    listTab.content.statusFilterButton = CraftSim.WIDGETS.OptionsButton {
        parent = listTab.content,
        isFilter = true,
        anchorPoints = { { anchorParent = listTab.content.refreshButton.frame, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -6 } },
        tooltipOptions = {
            anchor = "ANCHOR_RIGHT",
            text = L("WORK_ORDER_TRACKER_STATUS_FILTER_TOOLTIP"),
        },
        menuUtilCallback = function(_, rootDescription)
            rootDescription:CreateTitle(L("WORK_ORDER_TRACKER_STATUS_FILTER_TITLE"))
            for _, craftability in ipairs(CraftSim.WORK_ORDER_TRACKER.UI.STATUS_FILTER_ORDER) do
                rootDescription:CreateCheckbox(
                    CraftSim.WORK_ORDER_TRACKER:GetCraftabilityLabel(craftability),
                    function()
                        return CraftSim.WORK_ORDER_TRACKER.UI:IsStatusFilterEnabled(craftability)
                    end,
                    function()
                        CraftSim.WORK_ORDER_TRACKER.UI:ToggleStatusFilter(craftability)
                    end)
            end
        end,
    }

    listTab.content.orderList = GGUI.FrameList {
        columnOptions = {
            {
                label = L("WORK_ORDER_TRACKER_COLUMN_CRAFTER"),
                width = 150,
                sortFunc = function(rowA, rowB)
                    return CompareWorkOrderColumnAsc("CHARACTER", rowA, rowB)
                end,
            },
            {
                label = L("WORK_ORDER_TRACKER_COLUMN_RECIPE"),
                width = 210,
            },
            {
                label = L("WORK_ORDER_TRACKER_COLUMN_TIME"),
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" },
                sortFunc = function(rowA, rowB)
                    return CompareWorkOrderColumnAsc("TIME", rowA, rowB)
                end,
            },
            {
                label = L("WORK_ORDER_TRACKER_COLUMN_STATUS"),
                width = 130,
                justifyOptions = { type = "H", align = "LEFT" },
            },
        },
        rowHeight = 22,
        sizeX = listSizeX,
        sizeY = listSizeY,
        headerOffsetX = 0,
        parent = listTab.content,
        anchorPoints = { { anchorParent = listTab.content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -26, offsetX = listPad } },
        rowConstructor = function(columns, row)
            local crafterColumn = columns[1]
            local recipeColumn = columns[2]
            local timeColumn = columns[3]
            local statusColumn = columns[4]

            local hlColor = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.CURRENT_PLAYER_LIGHT_YELLOW
            row.characterHighlight = row.frame:CreateTexture(nil, "BACKGROUND", nil, -8)
            row.characterHighlight:SetDrawLayer("BACKGROUND", -8)
            row.characterHighlight:SetAllPoints(row.frame)
            row.characterHighlight:SetColorTexture(hlColor[1], hlColor[2], hlColor[3], hlColor[4])
            row.characterHighlight:Hide()

            crafterColumn.text = GGUI.Text {
                parent = crafterColumn,
                anchorPoints = { { anchorParent = crafterColumn, anchorA = "LEFT", anchorB = "LEFT" } },
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 1,
            }
            recipeColumn.text = GGUI.Text {
                parent = recipeColumn,
                anchorPoints = { { anchorParent = recipeColumn, anchorA = "LEFT", anchorB = "LEFT" } },
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 1,
            }
            timeColumn.text = GGUI.Text {
                parent = timeColumn,
                anchorPoints = { { anchorParent = timeColumn, anchorA = "CENTER", anchorB = "CENTER" } },
                justifyOptions = { type = "H", align = "CENTER" },
                scale = 1,
                fixedWidth = 70,
            }
            statusColumn.text = GGUI.Text {
                parent = statusColumn,
                anchorPoints = { { anchorParent = statusColumn, anchorA = "LEFT", anchorB = "LEFT", offsetX = 0 } },
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 1,
                fixedWidth = 100,
            }
            statusColumn.hintButton = CraftSim.RECIPE_ACQUISITION:CreateIconButton(
                statusColumn, statusColumn, "RIGHT", "RIGHT", 0, 0, 20)
        end,
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true,
            selectionCallback = function(row)
                if not IsMouseButtonDown("LeftButton") then
                    return
                end
                if row.crafterUID ~= CraftSim.UTIL:GetPlayerCrafterUID() then
                    return
                end
                if row.orderID and row.profession then
                    CraftSim.WORK_ORDER_TRACKER:TryOpenPatronOrder(row.orderID, row.profession)
                end
            end,
        },
    }

    WrapFrameListUpdateDisplayWithDefaultSort(listTab.content.orderList, function(rowA, rowB)
        return CraftSim.WORK_ORDER_TRACKER.UI:SortWorkOrderRowsDefault(rowA, rowB)
    end)

    optionsTab.content.autoSnapshotCheckbox = GGUI.Checkbox {
        parent = optionsTab.content,
        anchorParent = optionsTab.content,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = 15,
        offsetY = -25,
        label = L("WORK_ORDER_TRACKER_OPTION_AUTO_SNAPSHOT"),
        initialValue = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_AUTO_SNAPSHOT"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("WORK_ORDER_TRACKER_AUTO_SNAPSHOT", checked)
        end,
    }

    optionsTab.content.useConcentrationCheckbox = GGUI.Checkbox {
        parent = optionsTab.content,
        anchorParent = optionsTab.content.autoSnapshotCheckbox.frame,
        anchorA = "TOPLEFT",
        anchorB = "BOTTOMLEFT",
        offsetY = -8,
        label = L("WORK_ORDER_TRACKER_OPTION_USE_CONCENTRATION"),
        initialValue = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_USE_CONCENTRATION"),
        clickCallback = function(_, checked)
            CraftSim.DB.OPTIONS:Save("WORK_ORDER_TRACKER_USE_CONCENTRATION", checked)
        end,
    }

    local initialSortMode = CraftSim.DB.OPTIONS:Get("WORK_ORDER_TRACKER_SORT_MODE")
    if initialSortMode == "RECIPE" then
        initialSortMode = CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE.CHARACTER
    end
    local initialSortLabel = L(CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE_LOCALIZATION_IDS[initialSortMode])

    optionsTab.content.sortModeDropdown = CreateFrame("DropdownButton", nil, optionsTab.content, "WowStyle1DropdownTemplate")
    optionsTab.content.sortModeDropdown:SetDefaultText(initialSortLabel)
    optionsTab.content.sortModeDropdown:SetPoint("TOPLEFT", optionsTab.content.useConcentrationCheckbox.frame, "BOTTOMLEFT", 0, -12)
    optionsTab.content.sortModeDropdown:SetSize(150, 25)
    optionsTab.content.sortModeDropdown:SetupMenu(function(dropdown, rootDescription)
        for sortModeOption in pairs(CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE) do
            local sortModeLabel = L(CraftSim.WORK_ORDER_TRACKER.UI.SORT_MODE_LOCALIZATION_IDS[sortModeOption])
            rootDescription:CreateButton(sortModeLabel, function()
                CraftSim.DB.OPTIONS:Save("WORK_ORDER_TRACKER_SORT_MODE", sortModeOption)
                dropdown:SetDefaultText(sortModeLabel)
                CraftSim.WORK_ORDER_TRACKER.UI:UpdateDisplay()
            end)
        end
    end)

    optionsTab.content.sortModeLabel = GGUI.Text {
        parent = optionsTab.content,
        anchorPoints = { { anchorParent = optionsTab.content.sortModeDropdown, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -10 } },
        text = L("WORK_ORDER_TRACKER_OPTION_SORT_MODE"),
    }

    GGUI.BlizzardTabSystem { listTab, optionsTab }

    CraftSim.WORK_ORDER_TRACKER.frame:HookScript("OnShow", function()
        CraftSim.WORK_ORDER_TRACKER.UI:UpdateDisplay()
    end)
end

function CraftSim.WORK_ORDER_TRACKER.UI:UpdateDisplay()
    local frame = CraftSim.WORK_ORDER_TRACKER.frame
    if not frame or not frame.content or not frame.content.listTab then
        return
    end

    CraftSim.WORK_ORDER_TRACKER:PruneExpiredPatronWorkOrders()

    local orderList = frame.content.listTab.content.orderList
    if not orderList then
        return
    end

    ---@type { crafterUID: CrafterUID, profession: Enum.Profession, orderSnapshot: CraftSim.PatronWorkOrderSnapshot, lastSnapshotAt: number }[]
    local trackerRows = {}
    ---@type table<string, boolean>
    local validRowKeys = {}

    for _, entry in ipairs(CraftSim.DB.CRAFTER:GetAllPatronWorkOrderSnapshots()) do
        local crafterUID = entry.crafterUID
        local profession = entry.profession
        local snapshot = entry.snapshot
        if snapshot and snapshot.orders then
            for _, orderSnapshot in pairs(snapshot.orders) do
                if CraftSim.WORK_ORDER_TRACKER.UI:IsStatusFilterEnabled(orderSnapshot.craftability) then
                    local rowData = {
                        crafterUID = crafterUID,
                        profession = profession,
                        orderSnapshot = orderSnapshot,
                        lastSnapshotAt = snapshot.lastSnapshotAt,
                    }
                    validRowKeys[RowKey(crafterUID, orderSnapshot.orderID)] = true
                    tinsert(trackerRows, rowData)
                end
            end
        end
    end

    orderList:Remove(function(row)
        if not row.rowKey then
            return true
        end
        return not validRowKeys[row.rowKey]
    end)

    for _, rowData in ipairs(trackerRows) do
        local key = RowKey(rowData.crafterUID, rowData.orderSnapshot.orderID)
        local existingRow = orderList:GetRow(function(row)
            return row.rowKey == key
        end)
        if existingRow then
            PopulateWorkOrderTrackerRow(existingRow, rowData)
        else
            orderList:Add(function(row)
                PopulateWorkOrderTrackerRow(row, rowData)
            end)
        end
    end

    orderList:UpdateDisplay()
end

function CraftSim.WORK_ORDER_TRACKER.UI:Update()
    self:UpdateDisplay()
end

function CraftSim.WORK_ORDER_TRACKER.UI:VisibleByContext()
    return CraftSim.DB.OPTIONS:IsModuleEnabled(self.module.moduleID)
end

function CraftSim.WORK_ORDER_TRACKER.UI:RestoreFrameConfig()
    CraftSim.WORK_ORDER_TRACKER.frame:RestoreSavedConfig(ProfessionsFrame)
end
