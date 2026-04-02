---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.COOLDOWNS
CraftSim.COOLDOWNS = CraftSim.COOLDOWNS

---@class CraftSim.COOLDOWNS.UI
CraftSim.COOLDOWNS.UI = {}

---@class CraftSim.COOLDOWNS.FRAME : GGUI.Frame
CraftSim.COOLDOWNS.frame = nil

local GUTIL = CraftSim.GUTIL
local GGUI = CraftSim.GGUI
local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

local print = CraftSim.DEBUG:RegisterDebugID("Modules.Cooldowns.UI")

local DEFAULT_LIST_SCALE = 0.95
local DEFAULT_LIST_ROW_HEIGHT = 21

local COOLDOWN_LIST_LAYOUT_CONFIG_KEY = "COOLDOWNS_COOLDOWN_LIST"
local BLACKLIST_LIST_LAYOUT_CONFIG_KEY = "COOLDOWNS_BLACKLIST_LIST"

---@param key string
---@return table
local function EnsureFrameListLayoutConfig(key)
    local configs = CraftSim.DB.OPTIONS:Get("FRAME_LIST_LAYOUT_CONFIGS")
    if not configs[key] then
        configs[key] = {}
    end
    return configs[key]
end

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

---@param crafterUID CrafterUID
---@param serializationID string
---@return string
local function CreateBlacklistKey(crafterUID, serializationID)
    return tostring(crafterUID) .. "::" .. tostring(serializationID)
end

---@param row CraftSim.COOLDOWNS.CooldownList.Row
---@return number
local function GetTimeUntilNextCharge(row)
    local cooldownData = row.cooldownData
    if not cooldownData then
        return math.huge
    end
    local currentCharges = cooldownData:GetCurrentCharges() or 0
    local maxCharges = cooldownData.maxCharges or 0
    if maxCharges == 0 or currentCharges >= maxCharges then
        return 0
    end
    local startTimeCurrentCharge = cooldownData:GetStartTimeCurrentCharge() or 0
    return math.max((startTimeCurrentCharge + (cooldownData.cooldownPerCharge or 0)) - GetServerTime(), 0)
end

--- Ascending comparator for one cooldown list column (GGUI applies descending by swapping row arguments).
---@param sortMode "CRAFTER"|"RECIPE"|"CHARGES"|"NEXT"|"FULL"
---@param rowA CraftSim.COOLDOWNS.CooldownList.Row
---@param rowB CraftSim.COOLDOWNS.CooldownList.Row
---@return boolean?
local function CompareCooldownColumnAsc(sortMode, rowA, rowB)
    if sortMode == "CRAFTER" then
        if rowA.crafterUID ~= rowB.crafterUID then
            return rowA.crafterUID < rowB.crafterUID
        end
    elseif sortMode == "RECIPE" then
        local a = rowA.sortRecipeName or ""
        local b = rowB.sortRecipeName or ""
        if a ~= b then
            return a < b
        end
    elseif sortMode == "CHARGES" then
        if rowA.currentCharges ~= rowB.currentCharges then
            return rowA.currentCharges > rowB.currentCharges
        end
    elseif sortMode == "NEXT" then
        local a = rowA.nextChargeRemaining or math.huge
        local b = rowB.nextChargeRemaining or math.huge
        if a ~= b then
            return a < b
        end
    elseif sortMode == "FULL" then
        if rowA.allchargesFullTimestamp ~= rowB.allchargesFullTimestamp then
            return rowA.allchargesFullTimestamp < rowB.allchargesFullTimestamp
        end
    end
    return nil
end

--- When the matching profession is open, replace stale saved cooldown with live C_TradeSkillUI data.
---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@param cooldownData CraftSim.CooldownData
---@return CraftSim.CooldownData
local function TryRefreshCooldownDataFromTradeSkillUI(crafterUID, recipeID, cooldownData)
    if crafterUID ~= CraftSim.UTIL:GetPlayerCrafterUID() then
        return cooldownData
    end
    if not ProfessionsFrame or not ProfessionsFrame:IsVisible() then
        return cooldownData
    end
    local openProf = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not openProf then
        return cooldownData
    end
    local pinfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
    if not pinfo or pinfo.profession ~= openProf then
        return cooldownData
    end
    local live = CraftSim.CooldownData(recipeID)
    live:Update()
    if live.isCooldownRecipe then
        return live
    end
    return cooldownData
end

function CraftSim.COOLDOWNS.UI:OnTradeSkillItemCrafted()
    if not CraftSim.COOLDOWNS.frame or not CraftSim.COOLDOWNS.frame:IsVisible() then
        return
    end
    CraftSim.COOLDOWNS.UI:PersistPlayerCooldownsForOpenProfession()
    CraftSim.COOLDOWNS.UI:UpdateTimers()
end

--- Writes live cooldown state for the open profession so the list and saved data match after a craft.
function CraftSim.COOLDOWNS.UI:PersistPlayerCooldownsForOpenProfession()
    local playerUID = CraftSim.UTIL:GetPlayerCrafterUID()
    if not ProfessionsFrame or not ProfessionsFrame:IsVisible() then
        return
    end
    local openProf = CraftSim.UTIL:GetProfessionsFrameProfession()
    if not openProf then
        return
    end
    local allCooldowns = CraftSim.DB.CRAFTER:GetCrafterCooldownData()
    local recipeCooldowns = allCooldowns[playerUID]
    if not recipeCooldowns then
        return
    end
    for _, cooldownDataSerialized in pairs(recipeCooldowns) do
        local cd = CraftSim.CooldownData:Deserialize(cooldownDataSerialized)
        local recipeID = cd.recipeID
        local pinfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
        if pinfo and pinfo.profession == openProf then
            local live = CraftSim.CooldownData(recipeID)
            live:Update()
            local rInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            if live.isCooldownRecipe and rInfo and rInfo.learned then
                live:Save(playerUID)
            end
        end
    end
end

function CraftSim.COOLDOWNS.UI:Init()
    local sizeX = 680
    local sizeY = 265
    local offsetX = 0
    local offsetY = 0

    ---@class CraftSim.COOLDOWNS.FRAME : GGUI.Frame
    CraftSim.COOLDOWNS.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        anchorA = "TOPRIGHT",
        anchorB = "BOTTOMRIGHT",
        sizeX = sizeX,
        sizeY = sizeY,
        offsetY = offsetY,
        offsetX = offsetX,
        frameID = CraftSim.CONST.FRAMES.COOLDOWNS,
        title = L("COOLDOWNS_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_COOLDOWNS"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    ---@class CraftSim.COOLDOWNS.FRAME.CONTENT : Frame
    CraftSim.COOLDOWNS.frame.content = CraftSim.COOLDOWNS.frame.content

    ---@class CraftSim.COOLDOWNS.FRAME.CONTENT : Frame
    local content = CraftSim.COOLDOWNS.frame.content

    content.overviewTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content,
            offsetY = -2,
            label = L("COOLDOWNS_TAB_OVERVIEW"),
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
    content.cooldownOptionsTab = GGUI.BlizzardTab({
        buttonOptions = {
            parent = content,
            anchorParent = content.overviewTab.button,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            label = L("COOLDOWNS_TAB_OPTIONS"),
        },
        parent = content,
        anchorParent = content,
        sizeX = sizeX,
        sizeY = sizeY,
        canBeEnabled = true,
        offsetY = -30,
        top = true,
    })
    ---@class CraftSim.COOLDOWNS.UI.OVERVIEW_TAB : GGUI.BlizzardTab
    local overviewTab = content.overviewTab
    ---@class CraftSim.COOLDOWNS.UI.OVERVIEW_TAB.CONTENT : Frame
    overviewTab.content = overviewTab.content

    self:InitalizeOverviewTab(overviewTab)

    ---@class CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB : GGUI.BlizzardTab
    local cooldownOptionsTab = content.cooldownOptionsTab
    ---@class CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB.CONTENT : Frame
    cooldownOptionsTab.content = cooldownOptionsTab.content

    self:InitializeCooldownOptionsTab(cooldownOptionsTab)

    GGUI.BlizzardTabSystem { overviewTab, cooldownOptionsTab }
end

function CraftSim.COOLDOWNS.UI:CreateCooldownColumnOptions(includeActionColumn)
    ---@type GGUI.FrameList.ColumnOption[]
    local columnOptions = {
        {
            label = L("COOLDOWNS_CRAFTER_HEADER"),
            width = 140,
            sortFunc = function(rowA, rowB)
                local cmp = CompareCooldownColumnAsc("CRAFTER", rowA, rowB)
                if cmp ~= nil then
                    return cmp
                end
                return CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
            end,
        },
        {
            label = L("COOLDOWNS_RECIPE_HEADER"),
            width = 185,
            sortFunc = function(rowA, rowB)
                local cmp = CompareCooldownColumnAsc("RECIPE", rowA, rowB)
                if cmp ~= nil then
                    return cmp
                end
                return CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
            end,
        },
        {
            label = L("COOLDOWNS_CHARGES_HEADER"),
            width = 80,
            justifyOptions = { type = "H", align = "LEFT" },
            sortFunc = function(rowA, rowB)
                local cmp = CompareCooldownColumnAsc("CHARGES", rowA, rowB)
                if cmp ~= nil then
                    return cmp
                end
                return CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
            end,
        },
        {
            label = L("COOLDOWNS_NEXT_HEADER"),
            width = 100,
            justifyOptions = { type = "H", align = "LEFT" },
            sortFunc = function(rowA, rowB)
                local cmp = CompareCooldownColumnAsc("NEXT", rowA, rowB)
                if cmp ~= nil then
                    return cmp
                end
                return CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
            end,
        },
        {
            label = L("COOLDOWNS_ALL_HEADER"),
            width = 128,
            sortFunc = function(rowA, rowB)
                local cmp = CompareCooldownColumnAsc("FULL", rowA, rowB)
                if cmp ~= nil then
                    return cmp
                end
                return CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
            end,
        },
    }
    if includeActionColumn then
        tinsert(columnOptions, {
            label = "",
            width = 30,
            justifyOptions = { type = "H", align = "CENTER" },
        })
    end
    return columnOptions
end

---@param columns Frame[]
---@param row CraftSim.COOLDOWNS.CooldownList.Row
---@param isBlacklistRow boolean
function CraftSim.COOLDOWNS.UI:CooldownRowConstructor(columns, row, isBlacklistRow)
    row.cooldownData = nil
    row.allchargesFullTimestamp = 0
    row.currentCharges = 0
    row.nextChargeRemaining = math.huge
    row.sortRecipeName = ""

    local crafterColumn = columns[1]
    local recipeColumn = columns[2]
    local chargesColumn = columns[3]
    local nextColumn = columns[4]
    local allColumn = columns[5]
    local actionColumn = columns[6]

    crafterColumn.text = GGUI.Text {
        parent = crafterColumn,
        anchorParent = crafterColumn,
        justifyOptions = { type = "H", align = "LEFT" },
        anchorA = "LEFT",
        anchorB = "LEFT",
        scale = 0.95,
    }
    recipeColumn.text = GGUI.Text {
        parent = recipeColumn,
        anchorParent = recipeColumn,
        justifyOptions = { type = "H", align = "LEFT" },
        anchorA = "LEFT",
        anchorB = "LEFT",
        fixedWidth = 185,
        scale = 0.95,
    }
    chargesColumn.text = GGUI.Text {
        parent = chargesColumn,
        anchorParent = chargesColumn,
        justifyOptions = { type = "H", align = "LEFT" },
        anchorA = "LEFT",
        anchorB = "LEFT",
        fixedWidth = 80,
    }
    chargesColumn.SetCharges = function(_, current, max)
        current = math.min(current or 0, max or 0)
        if current == max and max > 0 then
            chargesColumn.text:SetText(string.format("%s/%s", f.g(current), f.g(max)))
        elseif max > 0 then
            chargesColumn.text:SetText(string.format("%s/%s", f.l(current), f.l(max)))
        else
            chargesColumn.text:SetText("-/-")
        end
    end
    nextColumn.text = GGUI.Text {
        parent = nextColumn,
        anchorParent = nextColumn,
        fixedWidth = 100,
        justifyOptions = { type = "H", align = "LEFT" },
        anchorA = "LEFT",
        anchorB = "LEFT",
    }
    allColumn.text = GGUI.Text {
        parent = allColumn,
        anchorParent = allColumn,
        justifyOptions = { type = "H", align = "LEFT" },
        anchorA = "LEFT",
        anchorB = "LEFT",
    }

    if isBlacklistRow and actionColumn then
        actionColumn.restoreButton = GGUI.Button {
            parent = actionColumn,
            anchorParent = actionColumn,
            sizeX = 18,
            sizeY = 18,
            label = "X",
            clickCallback = function()
                CraftSim.COOLDOWNS.UI:RemoveFromBlacklist(row.blacklistKey)
                CraftSim.COOLDOWNS.UI:UpdateDisplay()
            end,
            tooltipOptions = {
                text = L("COOLDOWNS_BLACKLIST_RESTORE"),
                owner = actionColumn,
                anchor = "ANCHOR_CURSOR",
            }
        }
    end
end

---@param row CraftSim.COOLDOWNS.CooldownList.Row
---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@param serializationID string
---@param cooldownData CraftSim.CooldownData
---@param professionInfo ProfessionInfo
---@param recipeInfo SkillLineAbilityInfo?
function CraftSim.COOLDOWNS.UI:PopulateCooldownRow(row, crafterUID, recipeID, serializationID, cooldownData, professionInfo, recipeInfo)
    row.crafterUID = crafterUID
    row.recipeID = recipeID
    row.serializationID = serializationID
    row.blacklistKey = CreateBlacklistKey(crafterUID, serializationID)
    row.cooldownData = cooldownData
    row.isCurrentCharacter = crafterUID == CraftSim.UTIL:GetPlayerCrafterUID()
    local columns = row.columns
    local crafterColumn = columns[1]
    local recipeColumn = columns[2]
    local chargesColumn = columns[3]
    local nextColumn = columns[4]
    local allColumn = columns[5]

    local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
    local crafterName = f.class(select(1, strsplit("-", crafterUID), crafterClass))
    local tooltipText = f.class(crafterUID, crafterClass)

    local professionIcon = ""
    if professionInfo and professionInfo.profession then
        professionIcon = CraftSim.CONST.PROFESSION_ICONS[professionInfo.profession]
        professionIcon = GUTIL:IconToText(professionIcon, 20, 20) .. " "
    end

    crafterColumn.text:SetText(professionIcon .. crafterName)

    if cooldownData.sharedCD then
        row.sortRecipeName = L(CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS[cooldownData.sharedCD]) or tostring(serializationID)
        recipeColumn.text:SetText(row.sortRecipeName)
        local recipeListText = ""
        for _, sharedRecipeID in pairs(CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPES[cooldownData.sharedCD]) do
            local sharedRecipeIDInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, sharedRecipeID) or
                C_TradeSkillUI.GetRecipeInfo(sharedRecipeID)
            if sharedRecipeIDInfo then
                recipeListText = recipeListText .. "\n" .. sharedRecipeIDInfo.name
            end
        end
        if #recipeListText > 0 then
            tooltipText = tooltipText .. L("COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP") .. f.white(recipeListText)
        end
    else
        row.sortRecipeName = (recipeInfo and recipeInfo.name) or tostring(serializationID)
        recipeColumn.text:SetText(row.sortRecipeName)
    end

    row.tooltipOptions = {
        text = tooltipText,
        owner = row.frame,
        anchor = "ANCHOR_CURSOR",
    }

    row.UpdateTimers = function(self)
        self.cooldownData = TryRefreshCooldownDataFromTradeSkillUI(self.crafterUID, self.recipeID, self.cooldownData)
        local rowCooldownData = self.cooldownData
        local currentCharges = rowCooldownData:GetCurrentCharges() or 0
        local maxCharges = rowCooldownData.maxCharges or 0
        chargesColumn:SetCharges(currentCharges, maxCharges)
        local allFullTS, ready = rowCooldownData:GetAllChargesFullTimestamp()
        local cdReady = ready or currentCharges >= maxCharges
        nextColumn.text:SetText(cdReady and f.grey("-") or f.bb(rowCooldownData:GetFormattedTimerNextCharge()))
        self.allchargesFullTimestamp = allFullTS or math.huge
        self.currentCharges = currentCharges
        self.nextChargeRemaining = GetTimeUntilNextCharge(self)
        if cdReady then
            allColumn.text:SetText(L("COOLDOWNS_RECIPE_READY"))
        else
            allColumn.text:SetText(f.g(rowCooldownData:GetAllChargesFullDateFormatted()))
        end
    end

    row:UpdateTimers()
end

---@param overviewTab CraftSim.COOLDOWNS.UI.OVERVIEW_TAB
function CraftSim.COOLDOWNS.UI:InitalizeOverviewTab(overviewTab)
    local content = overviewTab.content

    content.cooldownList = GGUI.FrameList {
        parent = content,
        anchorPoints = { { anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -34, offsetX = 17 } },
        scale = DEFAULT_LIST_SCALE,
        showBorder = true,
        rowHeight = DEFAULT_LIST_ROW_HEIGHT,
        sizeY = 198,
        savedVariablesTableLayoutConfig = EnsureFrameListLayoutConfig(COOLDOWN_LIST_LAYOUT_CONFIG_KEY),
        selectionOptions = {
            noSelectionColor = true,
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
            selectionCallback = function(row)
                if IsMouseButtonDown("RightButton") then
                    CraftSim.WIDGETS.ContextMenu.Open(UIParent, function(_, rootDescription)
                        rootDescription:CreateTitle(row.sortRecipeName)
                        rootDescription:CreateButton(L("COOLDOWNS_ADD_TO_BLACKLIST"), function()
                            CraftSim.COOLDOWNS.UI:AddToBlacklist(row.blacklistKey)
                            CraftSim.COOLDOWNS.UI:UpdateDisplay()
                        end)
                    end)
                end
            end,
        },
        columnOptions = self:CreateCooldownColumnOptions(false),
        rowConstructor = function(columns, row)
            CraftSim.COOLDOWNS.UI:CooldownRowConstructor(columns, row, false)
        end,
    }

    WrapFrameListUpdateDisplayWithDefaultSort(content.cooldownList, function(rowA, rowB)
        return CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
    end)

    content:HookScript("OnShow", function()
        CraftSim.COOLDOWNS:StartTimerUpdate()
    end)
    content:HookScript("OnHide", function()
        CraftSim.COOLDOWNS:StopTimerUpdate()
    end)
end

---@param content CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB.CONTENT
function CraftSim.COOLDOWNS.UI:InitializeBlacklistListInOptions(content)
    content.blacklistList = GGUI.FrameList {
        parent = content,
        anchorPoints = {
            { anchorParent = content.expansionSelector.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -30, offsetX = 0 }
        },
        scale = 0.9,
        showBorder = true,
        rowHeight = DEFAULT_LIST_ROW_HEIGHT,
        sizeY = 120,
        savedVariablesTableLayoutConfig = EnsureFrameListLayoutConfig(BLACKLIST_LIST_LAYOUT_CONFIG_KEY),
        selectionOptions = {
            noSelectionColor = true,
            hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE,
        },
        columnOptions = {
            {
                label = L("COOLDOWNS_CRAFTER_HEADER"),
                width = 180,
                sortFunc = function(rowA, rowB)
                    if rowA.crafterUID ~= rowB.crafterUID then
                        return rowA.crafterUID < rowB.crafterUID
                    end
                    return CraftSim.COOLDOWNS.UI:SortBlacklistRowsDefault(rowA, rowB)
                end,
            },
            {
                label = L("COOLDOWNS_RECIPE_HEADER"),
                width = 210,
                sortFunc = function(rowA, rowB)
                    local a = rowA.sortRecipeName or rowA.columns[2].text:GetText() or ""
                    local b = rowB.sortRecipeName or rowB.columns[2].text:GetText() or ""
                    if a ~= b then
                        return a < b
                    end
                    if rowA.crafterUID ~= rowB.crafterUID then
                        return rowA.crafterUID < rowB.crafterUID
                    end
                    return false
                end,
            },
            {
                label = L("COOLDOWNS_CHARGES_HEADER"),
                width = 90,
                justifyOptions = { type = "H", align = "LEFT" },
            },
            {
                label = "",
                width = 30,
                justifyOptions = { type = "H", align = "CENTER" },
            },
        },
        rowConstructor = function(columns, row)
            row.cooldownData = nil
            local crafterColumn = columns[1]
            local recipeColumn = columns[2]
            local chargesColumn = columns[3]
            local actionColumn = columns[4]

            crafterColumn.text = GGUI.Text {
                parent = crafterColumn, anchorParent = crafterColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT", scale = 0.9
            }
            recipeColumn.text = GGUI.Text {
                parent = recipeColumn, anchorParent = recipeColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT", fixedWidth = 210, scale = 0.9
            }
            chargesColumn.text = GGUI.Text {
                parent = chargesColumn, anchorParent = chargesColumn, justifyOptions = { type = "H", align = "LEFT" },
                anchorA = "LEFT", anchorB = "LEFT",
                fixedWidth = 90,
            }

            actionColumn.restoreButton = GGUI.Button {
                parent = actionColumn,
                anchorParent = actionColumn,
                sizeX = 18,
                sizeY = 18,
                label = "X",
                clickCallback = function()
                    CraftSim.COOLDOWNS.UI:RemoveFromBlacklist(row.blacklistKey)
                    CraftSim.COOLDOWNS.UI:UpdateDisplay()
                end,
                tooltipOptions = {
                    text = L("COOLDOWNS_BLACKLIST_RESTORE"),
                    owner = actionColumn,
                    anchor = "ANCHOR_CURSOR",
                }
            }

            row.UpdateTimers = function(self)
                self.cooldownData = TryRefreshCooldownDataFromTradeSkillUI(self.crafterUID, self.recipeID, self.cooldownData)
                local cooldownData = self.cooldownData
                local currentCharges = cooldownData:GetCurrentCharges() or 0
                local maxCharges = cooldownData.maxCharges or 0
                chargesColumn.text:SetText(string.format("%s/%s", currentCharges, maxCharges))
            end
        end,
    }

    WrapFrameListUpdateDisplayWithDefaultSort(content.blacklistList, function(rowA, rowB)
        return CraftSim.COOLDOWNS.UI:SortBlacklistRowsDefault(rowA, rowB)
    end)
end

---@return table<string, boolean>
function CraftSim.COOLDOWNS.UI:GetBlacklist()
    return CraftSim.DB.OPTIONS:Get("COOLDOWNS_BLACKLIST")
end

---@param blacklistKey string
function CraftSim.COOLDOWNS.UI:AddToBlacklist(blacklistKey)
    local blacklist = self:GetBlacklist()
    blacklist[blacklistKey] = true
end

---@param blacklistKey string
function CraftSim.COOLDOWNS.UI:RemoveFromBlacklist(blacklistKey)
    local blacklist = self:GetBlacklist()
    blacklist[blacklistKey] = nil
end

---@param cooldownOptionsTab CraftSim.COOLDOWNS.UI.COOLDOWN_OPTIONS_TAB
function CraftSim.COOLDOWNS.UI:InitializeCooldownOptionsTab(cooldownOptionsTab)
    local content = cooldownOptionsTab.content

    content.expansionSelector = GGUI.CheckboxSelector {
        savedVariablesTable = CraftSim.DB.OPTIONS:Get("COOLDOWNS_FILTERED_EXPANSIONS"),
        initialItems = GUTIL:Sort(GUTIL:Map(CraftSim.CONST.EXPANSION_IDS,
            function(expansionID)
                ---@type GGUI.CheckboxSelector.CheckboxItem
                local item = {
                    name = L(CraftSim.CONST.EXPANSION_LOCALIZATION_IDS[expansionID]),
                    savedVariableProperty = expansionID,
                    selectionID = expansionID,
                }
                return item
            end), function(a, b)
            return a.selectionID > b.selectionID
        end),
        parent = content,
        anchorPoints = { { anchorParent = content, anchorA = "TOP", anchorB = "TOP", offsetY = -10 } },
        label = L("COOLDOWNS_EXPANSION_FILTER_BUTTON"),
        sizeX = 30, sizeY = 25,
        buttonOptions = {
            parent = content, anchorParent = content,
            anchorA = "TOP", anchorB = "TOP", offsetY = -10,
            label = L("COOLDOWNS_EXPANSION_FILTER_BUTTON"),
            adjustWidth = true, sizeX = 20,
        },
        onSelectCallback = function(_, _, _)
            CraftSim.COOLDOWNS.UI:UpdateDisplay()
        end
    }

    self:InitializeBlacklistListInOptions(content)
end

function CraftSim.COOLDOWNS.UI:UpdateDisplay()
    CraftSim.COOLDOWNS.UI:UpdateList()
    CraftSim.COOLDOWNS.UI:UpdateTimers()
end

---@param rowA CraftSim.COOLDOWNS.CooldownList.Row
---@param rowB CraftSim.COOLDOWNS.CooldownList.Row
---@return boolean
function CraftSim.COOLDOWNS.UI:SortCooldownRowsDefault(rowA, rowB)
    if rowA.isCurrentCharacter ~= rowB.isCurrentCharacter then
        return rowA.isCurrentCharacter
    end
    if rowA.currentCharges ~= rowB.currentCharges then
        return rowA.currentCharges > rowB.currentCharges
    end
    if rowA.nextChargeRemaining ~= rowB.nextChargeRemaining then
        return rowA.nextChargeRemaining < rowB.nextChargeRemaining
    end
    if rowA.allchargesFullTimestamp ~= rowB.allchargesFullTimestamp then
        return rowA.allchargesFullTimestamp < rowB.allchargesFullTimestamp
    end
    if rowA.sortRecipeName ~= rowB.sortRecipeName then
        return rowA.sortRecipeName < rowB.sortRecipeName
    end
    return rowA.crafterUID < rowB.crafterUID
end

---@param rowA GGUI.FrameList.Row
---@param rowB GGUI.FrameList.Row
---@return boolean
function CraftSim.COOLDOWNS.UI:SortBlacklistRowsDefault(rowA, rowB)
    if rowA.crafterUID ~= rowB.crafterUID then
        return rowA.crafterUID < rowB.crafterUID
    end
    local a = rowA.sortRecipeName or rowA.columns[2].text:GetText() or ""
    local b = rowB.sortRecipeName or rowB.columns[2].text:GetText() or ""
    return a < b
end

function CraftSim.COOLDOWNS.UI:UpdateList()
    local cooldownList = CraftSim.COOLDOWNS.frame.content.overviewTab.content.cooldownList
    local blacklistList = CraftSim.COOLDOWNS.frame.content.cooldownOptionsTab.content.blacklistList

    cooldownList:Remove()
    blacklistList:Remove()

    local crafterCooldownData = CraftSim.DB.CRAFTER:GetCrafterCooldownData()
    local includedExpansionIDs = CraftSim.COOLDOWNS:GetIncludedExpansions()
    local blacklist = self:GetBlacklist()

    for crafterUID, recipeCooldowns in pairs(crafterCooldownData) do
        for serializationID, cooldownDataSerialized in pairs(recipeCooldowns) do
            local cooldownData = CraftSim.CooldownData:Deserialize(cooldownDataSerialized)
            local recipeID = cooldownData.recipeID
            cooldownData = TryRefreshCooldownDataFromTradeSkillUI(crafterUID, recipeID, cooldownData)
            local professionInfo = CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeID) or
                C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)

            local skillLineID = professionInfo and professionInfo.professionID
            local expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(skillLineID)

            local expansionIncluded = tContains(includedExpansionIDs, expansionID)

            if expansionIncluded then
                local recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, recipeID) or C_TradeSkillUI.GetRecipeInfo(recipeID)
                local blacklistKey = CreateBlacklistKey(crafterUID, serializationID)
                local targetList = blacklist[blacklistKey] and blacklistList or cooldownList
                targetList:Add(function(row)
                    if targetList == blacklistList then
                        row.crafterUID = crafterUID
                        row.recipeID = recipeID
                        row.serializationID = serializationID
                        row.blacklistKey = blacklistKey
                        row.cooldownData = cooldownData
                        local rowClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
                        local professionIcon = ""
                        if professionInfo and professionInfo.profession then
                            professionIcon = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[professionInfo.profession], 16, 16) .. " "
                        end
                        row.columns[1].text:SetText(professionIcon .. f.class(select(1, strsplit("-", crafterUID), rowClass)))
                        if cooldownData.sharedCD then
                            row.sortRecipeName = L(CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS[cooldownData.sharedCD])
                            row.columns[2].text:SetText(row.sortRecipeName)
                        else
                            row.sortRecipeName = (recipeInfo and recipeInfo.name) or serializationID
                            row.columns[2].text:SetText(row.sortRecipeName)
                        end
                        row:UpdateTimers()
                    else
                        CraftSim.COOLDOWNS.UI:PopulateCooldownRow(row, crafterUID, recipeID, serializationID, cooldownData,
                            professionInfo, recipeInfo)
                    end
                end)
            end
        end
    end

    cooldownList:UpdateDisplay()
    blacklistList:UpdateDisplay()
end

function CraftSim.COOLDOWNS.UI:UpdateTimers()
    local cooldownList = CraftSim.COOLDOWNS.frame.content.overviewTab.content.cooldownList
    local blacklistList = CraftSim.COOLDOWNS.frame.content.cooldownOptionsTab.content.blacklistList

    for _, activeRow in pairs(cooldownList.activeRows) do
        activeRow:UpdateTimers()
    end
    for _, activeRow in pairs(blacklistList.activeRows) do
        activeRow:UpdateTimers()
    end
end
