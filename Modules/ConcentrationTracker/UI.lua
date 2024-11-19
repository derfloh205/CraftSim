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

---@class CraftSim.CONCENTRATION_TRACKER.UI
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
    CHARACTER = CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CHARACTER,
    CONCENTRATION = CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION,
    PROFESSION = CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_PROFESSION,
}

CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE_LOCALIZATION_IDS = {
    EUROPE_MAX_DATE = CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE,
    AMERICA_MAX_DATE = CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE,
    HOURS_LEFT = CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT,
}

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

local print = CraftSim.DEBUG:RegisterDebugID("Modules.ConcentrationTracker.UI")

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
        frameID = CraftSim.CONST.FRAMES.CONCENTRATION_TRACKER,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
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
                text = "Pin Overview",
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
    local sizeX = 390
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
        frameID = CraftSim.CONST.FRAMES.CONCENTRATION_TRACKER_TRACKER_FRAME,
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
            label = "List",
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
            label = "Options",
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

    -- LIST TAB

    content.listTab.content.concentrationList = GGUI.FrameList {
        columnOptions = {
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CRAFTER),
                width = 160,
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CURRENT),
                width = 70,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_MAX),
                width = 90,
                justifyOptions = { type = "H", align = "CENTER" },
            }
        },
        rowHeight = 20, sizeY = 300,
        parent = content.listTab.content, anchorPoints = { { anchorParent = content.listTab.content, anchorA = "TOP", anchorB = "TOP", offsetY = -30, offsetX = -10 } },
        rowConstructor = function(columns, row)
            local crafterProfessionColumn = columns[1]
            local concentrationColumn = columns[2]
            local maxedColumn = columns[3]

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
        end,
        selectionOptions = {
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            noSelectionColor = true,
            selectionCallback = function(row, userInput)
                if IsMouseButtonDown("RightButton") then
                    MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                        rootDescription:CreateTitle(row.crafterProfessionText)
                        rootDescription:CreateButton("Remove and Blacklist", function()
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
        label = "Clear Blacklist",
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
        text = "Sort Mode: "
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
                CraftSim.CONCENTRATION_TRACKER.UI:UpdateDisplay()
            end)
        end
    end)

    content.optionsTab.content.formatModeLabel = GGUI.Text {
        parent = content.optionsTab.content,
        anchorPoints = { { anchorParent = content.optionsTab.content.formatModeDropdown, anchorA = "RIGHT", anchorB = "LEFT", offsetX = -10 } },
        text = "Time Format: "
    }
end

function CraftSim.CONCENTRATION_TRACKER.UI:UpdateTrackerDisplay()
    local trackerFrame = CraftSim.CONCENTRATION_TRACKER.trackerFrame

    local content = trackerFrame.content.listTab.content
    content.concentrationList:Remove()

    local crafterUIDs = CraftSim.DB.CRAFTER:GetCrafterUIDs()
    local crafterConcentrationTable = {}
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local openExpansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)
    local blacklist = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_BLACKLIST")

    for _, crafterUID in ipairs(crafterUIDs) do
        local crafterBlacklist = blacklist[crafterUID] or {}
        local professionDataList = CraftSim.DB.CRAFTER:GetConcentrationDataListForExpansion(crafterUID,
            openExpansionID)
        for profession, serializedData in pairs(professionDataList) do
            if not tContains(crafterBlacklist, profession) then
                crafterConcentrationTable[crafterUID] = crafterConcentrationTable[crafterUID] or {}

                if serializedData then
                    tinsert(crafterConcentrationTable[crafterUID], {
                        profession = profession,
                        expansionID = openExpansionID,
                        serializedData = serializedData
                    })
                end
            end
        end
    end

    for crafterUID, professionConcentrationDataList in pairs(crafterConcentrationTable) do
        for _, professionConcentrationData in ipairs(professionConcentrationDataList) do
            content.concentrationList:Add(function(row, columns)
                local crafterProfessionColumn = columns[1]
                local concentrationColumn = columns[2]
                local maxedColumn = columns[3]

                local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
                local professionIcon = CraftSim.CONST.PROFESSION_ICONS[professionConcentrationData.profession]
                local crafterProfessionText = GUTIL:IconToText(professionIcon, 15, 15) ..
                    " " .. f.class(crafterUID, crafterClass)
                row.crafterProfessionText = crafterProfessionText
                row.crafterUID = crafterUID
                row.profession = professionConcentrationData.profession
                crafterProfessionColumn.text:SetText(crafterProfessionText)

                local concentrationData = CraftSim.ConcentrationData:Deserialize(professionConcentrationData
                    .serializedData)

                local currentConcentration = concentrationData:GetCurrentAmount()
                row.concentration = currentConcentration

                concentrationColumn.text:SetText(math.floor(currentConcentration))

                local maxedColumnText = ""
                local concentrationFull = currentConcentration >= concentrationData.maxQuantity

                if concentrationFull then
                    maxedColumnText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX)
                else
                    maxedColumnText = f.bb(CraftSim.CONCENTRATION_TRACKER:GetMaxFormatByFormatMode(concentrationData))
                end

                maxedColumn.text:SetText(maxedColumnText)
            end)
        end
    end

    local sortMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_SORT_MODE")

    content.concentrationList:UpdateDisplay(function(rowA, rowB)
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

function CraftSim.CONCENTRATION_TRACKER.UI:UpdateDisplay()
    local concentrationData = CraftSim.CONCENTRATION_TRACKER:GetCurrentConcentrationData()
    if not concentrationData or not concentrationData.currencyID then return end

    local content = CraftSim.CONCENTRATION_TRACKER.frame.content --[[@as CraftSim.CONCENTRATION_TRACKER.FRAME.CONTENT]]

    local currentConcentration = concentrationData:GetCurrentAmount()
    content.value:SetText(math.floor(currentConcentration))
    content.maxValue:SetText(concentrationData.maxQuantity)

    if currentConcentration >= concentrationData.maxQuantity then
        content.maxTimer:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FULL))
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
