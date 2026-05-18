---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CONCENTRATION_TRACKER
CraftSim.CONCENTRATION_TRACKER = CraftSim.CONCENTRATION_TRACKER

---@type CraftSim.CONCENTRATION_TRACKER.FRAME
CraftSim.CONCENTRATION_TRACKER.frame = nil

---@type CraftSim.CONCENTRATION_TRACKER.TRACKER_FRAME
CraftSim.CONCENTRATION_TRACKER.trackerFrame = nil

---@class CraftSim.CONCENTRATION_TRACKER.UI : CraftSim.Module.UI
CraftSim.CONCENTRATION_TRACKER.UI = {}

CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE = {
    CHARACTER = "CHARACTER",
    CONCENTRATION = "CONCENTRATION",
    PROFESSION = "PROFESSION",
}

CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE = {
    EUROPE_MAX_DATE = "EUROPE_MAX_DATE",
    AMERICA_MAX_DATE = "AMERICA_MAX_DATE",
    HOURS_LEFT = "HOURS_LEFT",
}

CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE_LOCALIZATION_IDS = {
    CHARACTER = "CONCENTRATION_TRACKER_SORT_MODE_CHARACTER",
    CONCENTRATION = "CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION",
    PROFESSION = "CONCENTRATION_TRACKER_SORT_MODE_PROFESSION",
}

CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE_LOCALIZATION_IDS = {
    EUROPE_MAX_DATE = "CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE",
    AMERICA_MAX_DATE = "CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE",
    HOURS_LEFT = "CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT",
}

local f = GUTIL:GetFormatter()
local L = CraftSim.LOCAL:GetLocalizer()

local Logger = CraftSim.DEBUG:RegisterLogger("ConcentrationTracker.UI")

local MOXIE_ICON_THRESHOLD = 600
local MOXIE_ICON_ALPHA_ACTIVE = 1
local MOXIE_ICON_ALPHA_FADED = 0.2

--- Midnight gathering professions with moxie but no concentration on the tracker list.
local MOXIE_GATHERING_PROFESSIONS = {
    [Enum.Profession.Herbalism] = true,
    [Enum.Profession.Mining] = true,
    [Enum.Profession.Skinning] = true,
}

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return boolean
local function CrafterHasGatheringProfession(crafterUID, profession)
    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        return CraftSim.UTIL:IsProfessionLearned(profession)
    end
    local cachedRecipes = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(crafterUID, profession)
    return cachedRecipes ~= nil and #cachedRecipes > 0
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return string
local function GetTrackerRowKey(crafterUID, profession)
    return crafterUID .. ":" .. profession
end

---@param row GGUI.FrameList.Row
---@param trackerRowData { crafterUID: CrafterUID, profession: Enum.Profession, expansionID: CraftSim.EXPANSION_IDS, serializedData: string? }
---@param showMoxieColumn boolean
---@param noConcentrationText string
local function PopulateConcentrationTrackerRow(row, trackerRowData, showMoxieColumn, noConcentrationText)
    local crafterUID = trackerRowData.crafterUID
    local profession = trackerRowData.profession
    local expansionID = trackerRowData.expansionID
    local serializedData = trackerRowData.serializedData

    local crafterProfessionColumn = row.columns[1]
    local concentrationColumn = row.columns[2]
    local maxedColumn = row.columns[3]
    local moxieColumn = row.columns[4]

    local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
    local professionIcon = CraftSim.CONST.PROFESSION_ICONS[profession]
    local crafterProfessionText = GUTIL:IconToText(professionIcon, 15, 15) ..
        " " .. f.class(crafterUID, crafterClass)

    local moxieQty, hasMoxieCurrency = CraftSim.CONCENTRATION_TRACKER:GetListRowMoxieQuantity(crafterUID, profession,
        expansionID)

    row.crafterProfessionText = crafterProfessionText
    row.crafterUID = crafterUID
    row.profession = profession
    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        row.characterHighlight:Show()
    else
        row.characterHighlight:Hide()
    end
    crafterProfessionColumn.text:SetText(crafterProfessionText)

    if serializedData then
        local concentrationData = CraftSim.ConcentrationData:Deserialize(serializedData)
        local currentConcentration = concentrationData:GetSpendableAmount()
        row.concentration = currentConcentration
        concentrationColumn.text:SetText(currentConcentration)

        local maxedColumnText = ""
        local concentrationFull = currentConcentration >= concentrationData.maxQuantity
        if concentrationFull then
            maxedColumnText = CraftSim.LOCAL:GetText("CONCENTRATION_TRACKER_MAX")
        else
            maxedColumnText = f.bb(CraftSim.CONCENTRATION_TRACKER:GetMaxFormatByFormatMode(concentrationData))
        end
        maxedColumn.text:SetText(maxedColumnText)
    else
        row.concentration = -1
        concentrationColumn.text:SetText(noConcentrationText)
        maxedColumn.text:SetText(noConcentrationText)
    end

    moxieColumn:SetShown(showMoxieColumn)
    if showMoxieColumn then
        if hasMoxieCurrency then
            ApplyConcentrationTrackerMoxieIcon(moxieColumn.icon, profession, moxieQty)
        else
            ApplyConcentrationTrackerMoxieIcon(moxieColumn.icon, profession, nil)
        end

        if hasMoxieCurrency then
            local moxieDisplay = moxieQty ~= nil and BreakUpLargeNumbers(moxieQty)
                or L("CONCENTRATION_TRACKER_LIST_ROW_MOXIE_UNKNOWN")
            row.tooltipOptions = {
                anchor = "ANCHOR_CURSOR",
                owner = row.frame,
                text = string.format(L("CONCENTRATION_TRACKER_LIST_ROW_MOXIE"), moxieDisplay),
            }
        else
            row.tooltipOptions = nil
        end
    else
        row.tooltipOptions = nil
    end
end

---@param moxieIcon GGUI.Icon
---@param profession Enum.Profession
---@param moxieQty number?
local function ApplyConcentrationTrackerMoxieIcon(moxieIcon, profession, moxieQty)
    local moxieCurrencyID = CraftSim.CONST.MOXIE_CURRENCY_ID_BY_PROFESSION[profession]
    if not moxieCurrencyID then
        moxieIcon:SetCurrency(nil)
        moxieIcon:SetItem(nil)
        moxieIcon.frame:Hide()
        return
    end
    moxieIcon:SetCurrency(moxieCurrencyID)
    moxieIcon.frame:Show()
    local meetsThreshold = moxieQty and moxieQty > MOXIE_ICON_THRESHOLD
    moxieIcon.frame:SetAlpha(meetsThreshold and MOXIE_ICON_ALPHA_ACTIVE or MOXIE_ICON_ALPHA_FADED)
end

function CraftSim.CONCENTRATION_TRACKER.UI:Init()
    local sizeX = 220
    local sizeY = 40
    local offsetX = 0
    local offsetY = 0
    ---@class CraftSim.CONCENTRATION_TRACKER.FRAME : GGUI.Frame
    CraftSim.CONCENTRATION_TRACKER.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.ConcentrationDisplay,
        anchorParent = ProfessionsFrame.CraftingPage.ConcentrationDisplay,
        anchorA = "CENTER",
        anchorB = "CENTER",
        sizeX = sizeX,
        sizeY = sizeY,
        scale = 1,
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        hide = true,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel(),
    })

    local function createContent(frame)
        ---@class CraftSim.CONCENTRATION_TRACKER.FRAME : GGUI.Frame
        frame = frame

        ---@class CraftSim.CONCENTRATION_TRACKER.FRAME.CONTENT : Frame
        local content = frame.content

        local textScale = 0.9

        content.slash = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -5 } },
            text = "/", scale = 1.2,
        }

        content.value = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content.slash.frame, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -1 } },
            justifyOptions = { type = "H", align = "LEFT" },
            text = "0", scale = 1.2,
        }

        content.maxValue = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content.slash.frame, anchorA = "LEFT", anchorB = "RIGHT" } },
            justifyOptions = { type = "H", align = "RIGHT" },
            text = "0", scale = 1.2,
        }

        content.maxTimer = GGUI.Text {
            parent = content, anchorPoints = { { anchorParent = content, anchorA = "BOTTOM", anchorB = "BOTTOM", offsetY = 6 } },
            justifyOptions = { type = "H", align = "LEFT" }, scale = textScale,
        }

        content.concentrationIcon = GGUI.Icon {
            parent = content, anchorParent = content,
            anchorA = "LEFT", anchorB = "LEFT", sizeX = 30, sizeY = 30, offsetX = 5,
            texturePath = CraftSim.CONST.CONCENTRATION_ICON }

        local pinButtonLabel = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIN, 0.45)

        content.pinButton = GGUI.ToggleButton {
            parent = content, anchorPoints = { { anchorParent = content, anchorA = "RIGHT", anchorB = "RIGHT", offsetX = -12, offsetY = 1 } },
            sizeX = 26, sizeY = 26,
            labelOff = pinButtonLabel,
            labelOn = pinButtonLabel,
            isOn = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_PINNED"),
            tooltipOptions = {
                anchor = "ANCHOR_CURSOR_RIGHT",
                owner = content,
                text = L("CONCENTRATION_TRACKER_PIN_TOOLTIP"),
            },
            clickCallback = function()
                local nowPinned = not CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_PINNED")
                CraftSim.DB.OPTIONS:Save("CONCENTRATION_TRACKER_PINNED", nowPinned)
                CraftSim.CONCENTRATION_TRACKER.trackerFrame:SetVisible(nowPinned)
                if nowPinned then
                    self:UpdateTrackerDisplay()
                end
            end
        }

        CraftSim.CONCENTRATION_TRACKER.frame:HookScript("OnEnter", function()
            local isPinned = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_PINNED")
            if not isPinned then
                CraftSim.CONCENTRATION_TRACKER.trackerFrame:SetVisible(true)
                self:UpdateTrackerDisplay()
            end
        end)
        CraftSim.CONCENTRATION_TRACKER.frame:HookScript("OnLeave", function()
            local isPinned = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_PINNED")
            if not isPinned then
                CraftSim.CONCENTRATION_TRACKER.trackerFrame:SetVisible(false)
            end
        end)
    end

    createContent(CraftSim.CONCENTRATION_TRACKER.frame)
    self:InitTrackerFrame()
end

function CraftSim.CONCENTRATION_TRACKER.UI.InitTrackerFrame()
    local sizeX = 410
    local sizeY = 400
    local offsetX = 0
    local offsetY = -15

    ---@class CraftSim.CONCENTRATION_TRACKER.TRACKER_FRAME : GGUI.Frame
    CraftSim.CONCENTRATION_TRACKER.trackerFrame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = CraftSim.CONCENTRATION_TRACKER.frame.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        sizeX = sizeX,
        sizeY = sizeY,
        scale = 0.9,
        offsetX = offsetX,
        offsetY = offsetY,
        title = L("CONCENTRATION_TRACKER_TITLE"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata = "TOOLTIP",
        frameLevel = 99,
        moveable = true,
        hide = true,
    })

    ---@class CraftSim.CONCENTRATION_TRACKER.TRACKER_FRAME.CONTENT : Frame
    local content = CraftSim.CONCENTRATION_TRACKER.trackerFrame.content

    content.listTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content,
            offsetY = -2,
            label = L("CONCENTRATION_TRACKER_LIST_TAB_LABEL"),
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

    content.optionsTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content.listTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = L("CONCENTRATION_TRACKER_OPTIONS_TAB_LABEL"),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        top = true,
    })

    GGUI.BlizzardTabSystem { content.listTab, content.optionsTab }

    -- LIST TAB (padding: 12 sides, 26 top, 16 bottom, 25 header, 30 scrollbar)
    local listPad = 12
    local listSizeX = sizeX - (listPad * 2) - 30
    local listSizeY = sizeY - 67

    content.listTab.content.concentrationList = GGUI.FrameList {
        columnOptions = {
            {
                label = CraftSim.LOCAL:GetText("CONCENTRATION_TRACKER_LABEL_CRAFTER"),
                width = 160,
            },
            {
                label = CraftSim.LOCAL:GetText("CONCENTRATION_TRACKER_LABEL_CURRENT"),
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = CraftSim.LOCAL:GetText("CONCENTRATION_TRACKER_LABEL_MAX"),
                width = 90,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                width = 22,
                justifyOptions = { type = "H", align = "CENTER" },
            },
        },
        rowHeight = 20,
        sizeX = listSizeX,
        sizeY = listSizeY,
        headerOffsetX = 0,
        parent = content.listTab.content, anchorPoints = { { anchorParent = content.listTab.content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -26, offsetX = listPad } },
        rowConstructor = function(columns, row)
            local crafterProfessionColumn = columns[1]
            local concentrationColumn = columns[2]
            local maxedColumn = columns[3]
            local moxieColumn = columns[4]

            local hlColor = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.CURRENT_PLAYER_LIGHT_YELLOW
            row.characterHighlight = row.frame:CreateTexture(nil, "BACKGROUND", nil, -8)
            row.characterHighlight:SetDrawLayer("BACKGROUND", -8)
            row.characterHighlight:SetAllPoints(row.frame)
            row.characterHighlight:SetColorTexture(hlColor[1], hlColor[2], hlColor[3], hlColor[4])
            row.characterHighlight:Hide()

            crafterProfessionColumn.text = GGUI.Text {
                parent = crafterProfessionColumn, anchorPoints = { { anchorParent = crafterProfessionColumn, anchorA = "LEFT", anchorB = "LEFT" } },
                justifyOptions = { type = "H", align = "LEFT" }, scale = 1,
            }
            concentrationColumn.text = GGUI.Text {
                parent = concentrationColumn, anchorPoints = { { anchorParent = concentrationColumn, anchorA = "CENTER", anchorB = "CENTER" } },
                justifyOptions = { type = "H", align = "CENTER" }, scale = 1, fixedWidth = 70,
                fontOptions = {
                    fontFile = CraftSim.CONST.FONT_FILES.MONOSPACE,
                    height = 12,
                },
            }
            maxedColumn.text = GGUI.Text {
                parent = maxedColumn, anchorPoints = { { anchorParent = maxedColumn, anchorA = "CENTER", anchorB = "CENTER" } },
                justifyOptions = { type = "H", align = "CENTER" }, scale = 1, fixedWidth = 90,
                fontOptions = {
                    fontFile = CraftSim.CONST.FONT_FILES.MONOSPACE,
                    height = 12,
                },
            }
            moxieColumn.icon = GGUI.Icon {
                parent = moxieColumn,
                anchorParent = moxieColumn,
                anchorA = "CENTER",
                anchorB = "CENTER",
                sizeX = 18,
                sizeY = 18,
            }
        end,
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true,
            selectionCallback = function(row, userInput)
                if IsMouseButtonDown("RightButton") then
                    CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(ownerRegion, rootDescription)
                        rootDescription:CreateTitle(row.crafterProfessionText)
                        rootDescription:CreateButton(L("CONCENTRATION_TRACKER_LIST_TAB_REMOVE_AND_BLACKLIST"), function()
                            CraftSim.CONCENTRATION_TRACKER:BlacklistData(row.crafterUID, row.profession)
                            CraftSim.CONCENTRATION_TRACKER.UI:UpdateTrackerDisplay()
                        end)
                    end)
                end
            end
        },
    }

    -- OPTIONS TAB
    content.optionsTab.content.clearBlacklistButton = GGUI.Button {
        parent = content.optionsTab.content,
        anchorPoints = { { anchorParent = content.optionsTab.content, anchorA = "TOP", anchorB = "TOP", offsetY = -25 } },
        label = L("CONCENTRATION_TRACKER_OPTIONS_TAB_CLEAR_BLACKLIST"),
        adjustWidth = true,
        sizeX = 30,
        clickCallback = function()
            CraftSim.CONCENTRATION_TRACKER:ClearBlacklist()
            CraftSim.CONCENTRATION_TRACKER.UI:UpdateTrackerDisplay()
        end
    }

    local intialSortModeValue = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_SORT_MODE")
    local intialSortModeLabel = L(CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE_LOCALIZATION_IDS[intialSortModeValue])

    content.optionsTab.content.sortModeDropdown = CreateFrame("DropdownButton", nil, content.optionsTab.content,
        "WowStyle1DropdownTemplate")
    content.optionsTab.content.sortModeDropdown:SetDefaultText(intialSortModeLabel)
    content.optionsTab.content.sortModeDropdown:SetPoint("TOPLEFT", content.optionsTab.content.clearBlacklistButton
        .frame, "BOTTOMLEFT",
        0, -5)
    content.optionsTab.content.sortModeDropdown:SetSize(130, 25)
    content.optionsTab.content.sortModeDropdown:SetupMenu(function(dropdown, rootDescription)
        for sortModeOption in pairs(CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE) do
            local sortModeLabel = L(CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE_LOCALIZATION_IDS
                [sortModeOption])
            rootDescription:CreateButton(sortModeLabel, function()
                CraftSim.DB.OPTIONS:Save("CONCENTRATION_TRACKER_SORT_MODE", sortModeOption)
                dropdown:SetDefaultText(sortModeLabel)
                CraftSim.CONCENTRATION_TRACKER.UI:UpdateTrackerDisplay()
            end)
        end
    end)

    content.optionsTab.content.sortModeLabel = GGUI.Text {
        parent = content.optionsTab.content,
        anchorPoints = { { anchorParent = content.optionsTab.content.sortModeDropdown, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -10 } },
        text = L("CONCENTRATION_TRACKER_OPTIONS_TAB_SORT_MODE")
    }

    local intialFormatModeValue = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
    local intialFormatModeLabel = L(CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE_LOCALIZATION_IDS
        [intialFormatModeValue])

    content.optionsTab.content.formatModeDropdown = CreateFrame("DropdownButton", nil, content.optionsTab.content,
        "WowStyle1DropdownTemplate")
    content.optionsTab.content.formatModeDropdown:SetDefaultText(intialFormatModeLabel)
    content.optionsTab.content.formatModeDropdown:SetPoint("TOPLEFT", content.optionsTab.content.sortModeDropdown,
        "BOTTOMLEFT",
        0, -5)
    content.optionsTab.content.formatModeDropdown:SetSize(130, 25)
    content.optionsTab.content.formatModeDropdown:SetupMenu(function(dropdown, rootDescription)
        for formatModeOption in pairs(CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE) do
            local formatModeLabel = L(CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE_LOCALIZATION_IDS
                [formatModeOption])
            rootDescription:CreateButton(formatModeLabel, function()
                CraftSim.DB.OPTIONS:Save("CONCENTRATION_TRACKER_FORMAT_MODE", formatModeOption)
                dropdown:SetDefaultText(formatModeLabel)
                CraftSim.CONCENTRATION_TRACKER.UI:Update()
                CraftSim.CRAFTQ.UI:Update()
                if CraftSim.SIMULATION_MODE and CraftSim.SIMULATION_MODE.recipeData then
                    CraftSim.SIMULATION_MODE.UI:UpdateCraftingDetailsPanel()
                end
            end)
        end
    end)

    content.optionsTab.content.formatModeLabel = GGUI.Text {
        parent = content.optionsTab.content,
        anchorPoints = { { anchorParent = content.optionsTab.content.formatModeDropdown, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -10 } },
        text = L("CONCENTRATION_TRACKER_OPTIONS_TAB_TIME_FORMAT")
    }
end

function CraftSim.CONCENTRATION_TRACKER.UI:VisibleByContext()
    -- only show for expansions DF and higher
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    return expansionID and expansionID >= CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT
end

function CraftSim.CONCENTRATION_TRACKER.UI:UpdateTrackerDisplay()
    local trackerFrame = CraftSim.CONCENTRATION_TRACKER.trackerFrame

    local content = trackerFrame.content.listTab.content
    local concentrationList = content.concentrationList

    local crafterUIDs = CraftSim.DB.CRAFTER:GetCrafterUIDs()
    ---@type { crafterUID: CrafterUID, profession: Enum.Profession, expansionID: CraftSim.EXPANSION_IDS, serializedData: string? }[]
    local trackerRows = {}
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local openExpansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    local showMoxieColumn = openExpansionID == CraftSim.CONST.EXPANSION_IDS.MIDNIGHT
    local blacklist = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_BLACKLIST")
    local noConcentrationText = L("CONCENTRATION_TRACKER_LIST_ROW_MOXIE_UNKNOWN")

    local moxieHeaderColumn = concentrationList.headerColumns and concentrationList.headerColumns[4]
    if moxieHeaderColumn then
        moxieHeaderColumn:SetShown(showMoxieColumn)
    end

    ---@type table<string, boolean>
    local desiredRowKeys = {}

    for _, crafterUID in ipairs(crafterUIDs) do
        local crafterBlacklist = blacklist[crafterUID] or {}

        for profession, serializedData in pairs(CraftSim.DB.CRAFTER:GetConcentrationDataListForExpansion(crafterUID,
            openExpansionID)) do
            if not tContains(crafterBlacklist, profession) and serializedData then
                local rowData = {
                    crafterUID = crafterUID,
                    profession = profession,
                    expansionID = openExpansionID,
                    serializedData = serializedData,
                }
                desiredRowKeys[GetTrackerRowKey(crafterUID, profession)] = true
                tinsert(trackerRows, rowData)
            end
        end

        if showMoxieColumn then
            for profession in pairs(MOXIE_GATHERING_PROFESSIONS) do
                if not tContains(crafterBlacklist, profession) and CrafterHasGatheringProfession(crafterUID, profession) then
                    local rowData = {
                        crafterUID = crafterUID,
                        profession = profession,
                        expansionID = openExpansionID,
                        serializedData = nil,
                    }
                    desiredRowKeys[GetTrackerRowKey(crafterUID, profession)] = true
                    tinsert(trackerRows, rowData)
                end
            end
        end
    end

    concentrationList:Remove(function(row)
        if not row.crafterUID or not row.profession then
            return true
        end
        return not desiredRowKeys[GetTrackerRowKey(row.crafterUID, row.profession)]
    end)

    for _, trackerRowData in ipairs(trackerRows) do
        local existingRow = concentrationList:GetRow(function(row)
            return row.crafterUID == trackerRowData.crafterUID and row.profession == trackerRowData.profession
        end)
        if existingRow then
            PopulateConcentrationTrackerRow(existingRow, trackerRowData, showMoxieColumn, noConcentrationText)
        else
            concentrationList:Add(function(row)
                PopulateConcentrationTrackerRow(row, trackerRowData, showMoxieColumn, noConcentrationText)
            end)
        end
    end

    local sortMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_SORT_MODE")

    concentrationList:UpdateDisplay(function(rowA, rowB)
        if sortMode == CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE.CHARACTER then
            if rowA.crafterUID > rowB.crafterUID then
                return true
            end

            return false
        elseif sortMode == CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE.PROFESSION then
            if rowA.profession > rowB.profession then
                return true
            end

            return false
        elseif sortMode == CraftSim.CONCENTRATION_TRACKER.UI.SORT_MODE.CONCENTRATION then
            if rowA.concentration > rowB.concentration then
                return true
            end

            return false
        end
    end)
end

function CraftSim.CONCENTRATION_TRACKER.UI:Update()
    local concentrationData = CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    if not concentrationData or not concentrationData.currencyID then return end

    local content = CraftSim.CONCENTRATION_TRACKER.frame.content --[[@as CraftSim.CONCENTRATION_TRACKER.FRAME.CONTENT]]

    local currentConcentration = concentrationData:GetSpendableAmount()
    content.value:SetText(currentConcentration)
    content.maxValue:SetText(concentrationData.maxQuantity)

    if currentConcentration >= concentrationData.maxQuantity then
        content.maxTimer:SetText(CraftSim.LOCAL:GetText("CONCENTRATION_TRACKER_FULL"))
    else
        content.maxTimer:SetText(f.bb(CraftSim.CONCENTRATION_TRACKER:GetMaxFormatByFormatMode(concentrationData)))
    end

    local isPinned = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_PINNED")

    content.pinButton:SetToggle(not isPinned)
    if isPinned then
        CraftSim.CONCENTRATION_TRACKER.trackerFrame:SetVisible(true)
        CraftSim.CONCENTRATION_TRACKER.UI:UpdateTrackerDisplay()
    end
end
