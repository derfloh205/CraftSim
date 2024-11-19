---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL
local L = CraftSim.UTIL:GetLocalizer()
local f = CraftSim.GUTIL:GetFormatter()

---@class CraftSim.RECIPE_SCAN
CraftSim.RECIPE_SCAN = CraftSim.RECIPE_SCAN

---@class CraftSim.RECIPE_SCAN.UI
CraftSim.RECIPE_SCAN.UI = {}

local print = CraftSim.DEBUG:RegisterDebugID("Modules.RecipeScan.UI")

function CraftSim.RECIPE_SCAN.UI:Init()
    local frameLevel = CraftSim.UTIL:NextFrameLevel()
    ---@class CraftSim.RECIPE_SCAN.FRAME : GGUI.Frame
    CraftSim.RECIPE_SCAN.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = 1050,
        sizeY = 400,
        frameID = CraftSim.CONST.FRAMES.RECIPE_SCAN,
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_RECIPE_SCAN"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    -- manually create title for offset
    CraftSim.RECIPE_SCAN.frame.title = GGUI.Text {
        parent = CraftSim.RECIPE_SCAN.frame.frame, anchorParent = CraftSim.RECIPE_SCAN.frame.frame,
        offsetX = 100, offsetY = -10, anchorA = "TOP", anchorB = "TOP",
        text = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE),
    }

    ---@class CraftSim.RECIPE_SCAN.FRAME.CONTENT
    CraftSim.RECIPE_SCAN.frame.content = CraftSim.RECIPE_SCAN.frame.content

    local function createContent(frame)
        frame:Hide()

        ---@class CraftSim.RECIPE_SCAN.FRAME.CONTENT : Frame
        frame.content = frame.content

        local tabSizeX, tabSizeY = frame.content:GetSize()

        ---@class CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB : GGUI.BlizzardTab
        frame.content.recipeScanTab = GGUI.BlizzardTab {
            buttonOptions = {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN),
                offsetY = -3,
            },
            parent = frame.content, anchorParent = frame.content, initialTab = true,
            sizeX = tabSizeX, sizeY = tabSizeY,
            top = true,
        }

        CraftSim.RECIPE_SCAN.UI:InitRecipeScanTab(frame.content.recipeScanTab)

        GGUI.BlizzardTabSystem { frame.content.recipeScanTab }
    end

    createContent(CraftSim.RECIPE_SCAN.frame)
    GGUI:EnableHyperLinksForFrameAndChilds(CraftSim.RECIPE_SCAN.frame.content)
end

---@param selectedRow CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.UI:OnProfessionRowSelected(selectedRow, userInput)
    print("select row: " .. tostring(selectedRow.crafterData.name) .. ": " .. tostring(selectedRow.profession))
    print("userInput: " .. tostring(userInput))
    -- hide all others except me
    for _, row in pairs(selectedRow.activeRows) do
        row.contentFrame:Hide()
    end

    selectedRow.contentFrame:Show()

    CraftSim.RECIPE_SCAN.UI:UpdateProfessionListRowCachedRecipesInfo(selectedRow)
end

---@param selectedRow CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.UI:UpdateProfessionListRowCachedRecipesInfo(selectedRow)
    -- update cached recipes value
    local content = selectedRow.content --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT]]
    local cachedRecipeIDs = CraftSim.DB.CRAFTER:GetCachedRecipeIDs(selectedRow.crafterUID, selectedRow.profession) or {}
    if C_TradeSkillUI.IsTradeSkillReady() then
        if selectedRow.crafterProfessionUID ~= CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID() then
            content.cachedRecipesInfoHelpIcon:Show()
            content.cachedRecipesInfo:SetText("(" ..
                L(CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES) .. tostring(#cachedRecipeIDs) .. ") ")
        else
            content.cachedRecipesInfo:SetText("")
            content.cachedRecipesInfoHelpIcon:Hide()
        end
    else
        print("trade skill not ready")
        content.cachedRecipesInfo:SetText("")
        content.cachedRecipesInfoHelpIcon:Hide()
    end
end

---@param recipeScanTab CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB
function CraftSim.RECIPE_SCAN.UI:InitRecipeScanTab(recipeScanTab)
    ---@class CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB
    recipeScanTab = recipeScanTab
    ---@class CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT : Frame
    local content = recipeScanTab.content

    content.professionList = GGUI.FrameList {
        parent = content, anchorParent = content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -40, offsetX = 5,
        sizeY = 350,
        showBorder = true, selectionOptions = {
        selectionCallback =
        ---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
            function(row, userInput)
                if not userInput or IsMouseButtonDown("LeftButton") then
                    CraftSim.RECIPE_SCAN.UI:OnProfessionRowSelected(row, userInput)
                elseif IsMouseButtonDown("RightButton") then
                    MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                        local removeButton = rootDescription:CreateButton(f.r("Remove"), function()
                            local professionList = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab.content
                                .professionList --[[@as GGUI.FrameList]]
                            CraftSim.DB.CRAFTER:RemoveCrafterProfessionData(row.crafterUID, row.profession)
                            professionList:Remove(function(_row)
                                local removing = _row.crafterUID == row.crafterUID and _row.profession == row.profession
                                return removing
                            end)

                            CraftSim.RECIPE_SCAN.UI:UpdateProfessionListDisplay()
                        end)
                        removeButton:SetTooltip(function(tooltip, elementDescription)
                            GameTooltip_AddInstructionLine(tooltip,
                                f.r("Remove ") .. "all cached data about this character - profession combination");
                        end);
                    end)
                end
            end
    },
        columnOptions = {
            {
                label = "", -- checkbox
                width = 40,
            },
            {
                label = "", -- crafter name + prof icon
                width = 150,
            },
        },
        rowConstructor = function(columns)
            ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.CHECKBOX_COLUMN : Frame
            local checkboxColumn = columns[1]
            ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.CRAFTER_COLUMN : Frame
            local crafterColumn = columns[2]

            checkboxColumn.checkbox = GGUI.Checkbox {
                parent = checkboxColumn, anchorParent = checkboxColumn,
            }

            crafterColumn.text = GGUI.Text {
                parent = crafterColumn, anchorParent = crafterColumn, anchorA = "LEFT", anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" }
            }
        end
    }

    content.scanProfessionsButton = GGUI.Button {
        parent = content, anchorParent = content.professionList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT",
        adjustWidth = true, sizeX = 15, offsetY = 5, initialStatusID = "Ready",
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY), clickCallback = function()
        CraftSim.RECIPE_SCAN:ScanProfessions()
    end,
    }

    content.sendToCraftQueueButton = GGUI.Button {
        parent = content,
        sizeX = 170,
        anchorPoints = { { anchorParent = content.professionList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPRIGHT", offsetX = 32, offsetY = -45, } },
        label = "Send to Craft Queue",
        initialStatusID = "Ready",
        clickCallback = function()
            CraftSim.RECIPE_SCAN:SendToCraftQueue()
        end
    }

    content.sendToCraftQueueButton:SetStatusList {
        {
            statusID = "Ready",
            label = "Send to Craft Queue",
            enabled = true,
        }
    }

    GGUI.Button {
        parent = content, anchorPoints = { { anchorParent = content.sendToCraftQueueButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS, sizeX = 20, sizeY = 20,
        cleanTemplate = true,
        clickCallback = function(_, _)
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                    frame.label = GGUI.Text {
                        parent = frame,
                        anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = "Profit Margin Threshold (%): ",
                        justifyOptions = { type = "H", align = "LEFT" },
                    }
                    frame.input = GGUI.NumericInput {
                        parent = frame, anchorParent = frame,
                        sizeX = 30, sizeY = 25, offsetX = 5,
                        anchorA = "RIGHT", anchorB = "RIGHT",
                        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_PROFIT_MARGIN_THRESHOLD"),
                        borderAdjustWidth = 1.32,
                        allowDecimals = true,
                        onNumberValidCallback = function(input)
                            CraftSim.DB.OPTIONS:Save("RECIPESCAN_SEND_TO_CRAFTQUEUE_PROFIT_MARGIN_THRESHOLD",
                                tonumber(input.currentValue))
                        end,
                    }
                end, 200, 25, "RECIPE_SCAN_SEND_TO_CRAFT_QUEUE_PROFIT_MARGIN_INPUT")

                GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                    frame.label = GGUI.Text {
                        parent = frame,
                        anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                        text = "Default Queue Amount: ",
                        justifyOptions = { type = "H", align = "LEFT" },
                    }
                    frame.input = GGUI.NumericInput {
                        parent = frame, anchorParent = frame,
                        sizeX = 30, sizeY = 25, offsetX = 5,
                        anchorA = "RIGHT", anchorB = "RIGHT",
                        initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_DEFAULT_QUEUE_AMOUNT"),
                        borderAdjustWidth = 1.32,
                        minValue = 1,
                        onNumberValidCallback = function(input)
                            CraftSim.DB.OPTIONS:Save("RECIPESCAN_SEND_TO_CRAFTQUEUE_DEFAULT_QUEUE_AMOUNT",
                                tonumber(input.currentValue))
                        end,
                    }
                end, 200, 25, "RECIPE_SCAN_SEND_TO_CRAFT_QUEUE_DEFAULT_QUEUE_AMOUNT_INPUT")

                if TSM_API then
                    local tsmOptions = rootDescription:CreateButton(f.bb("TSM"))

                    local tsmExpressionCB = tsmOptions:CreateCheckbox(
                        "Use " .. f.bb("TSM") .. " Restock Amount Expression",
                        function()
                            return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_USE_TSM_RESTOCK_EXPRESSION")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "RECIPESCAN_SEND_TO_CRAFTQUEUE_USE_TSM_RESTOCK_EXPRESSION")
                            CraftSim.DB.OPTIONS:Save("RECIPESCAN_SEND_TO_CRAFTQUEUE_USE_TSM_RESTOCK_EXPRESSION",
                                not value)
                        end)
                    tsmExpressionCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "If enabled, restock amount will be determined by configured " ..
                            f.bb("TSM Expression") .. " (Options)");
                    end);

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(tsmOptions, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = f.bb("TSM") .. " Sale Rate Threshold: ",
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.NumericInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 30, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SEND_TO_CRAFTQUEUE_TSM_SALERATE_THRESHOLD"),
                            borderAdjustWidth = 1.32,
                            allowDecimals = true,
                            maxValue = 1,
                            minValue = 0,
                            onNumberValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("RECIPESCAN_SEND_TO_CRAFTQUEUE_TSM_SALERATE_THRESHOLD",
                                    tonumber(input.currentValue))
                            end,
                        }
                    end, 150, 25, "RECIPE_SCAN_SEND_TO_CRAFT_QUEUE_TSM_SALERATE_INPUT")
                end
            end)
        end
    }

    content.cancelScanProfessionsButton = GGUI.Button {
        parent = content, anchorParent = content.scanProfessionsButton.frame, anchorA = "LEFT", anchorB = "RIGHT",
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL), offsetX = 5, adjustWidth = true, sizeX = 15,
        clickCallback = function()
            CraftSim.RECIPE_SCAN:CancelProfessionScan()
        end
    }
    content.cancelScanProfessionsButton:Hide()

    content.scanProfessionsButton:SetStatusList {
        {
            statusID = "Ready",
            adjustWidth = true,
            sizeX = 15,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY),
            enabled = true,
        },
        {
            statusID = "Scanning",
            adjustWidth = true,
            sizeX = 15,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING),
            enabled = false,
        },
    }
end

function CraftSim.RECIPE_SCAN.UI:UpdateProfessionList()
    -- for each profession that is cached, create a tabFrame and connect it to the row of the profession
    -- do this only if the profession is not yet added to the list
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    local activeRows = content.professionList.activeRows
    local crafterDBDataMap = CraftSim.DB.CRAFTER:GetAll()

    for crafterUID, crafterDBData in pairs(crafterDBDataMap) do
        local cachedProfessionRecipeIDs = crafterDBData.cachedRecipeIDs or {}
        for profession, _ in pairs(cachedProfessionRecipeIDs) do
            local crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)
            local alreadyListed = GUTIL:Some(activeRows, function(activeRow)
                return activeRow.crafterProfessionUID == crafterProfessionUID
            end)
            local isGatheringProfession = CraftSim.CONST.GATHERING_PROFESSIONS[profession]
            if not alreadyListed and not isGatheringProfession then
                CraftSim.RECIPE_SCAN.UI:AddProfessionTabRow(crafterUID, profession)
            end
        end
    end

    CraftSim.RECIPE_SCAN.UI:UpdateProfessionListDisplay()
end

function CraftSim.RECIPE_SCAN.UI:UpdateProfessionListDisplay()
    print("update prof list display")
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    content.professionList:UpdateDisplay(
    ---@param rowA CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
    ---@param rowB CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
        function(rowA, rowB)
            local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
            local playerCrafterProfessionUID = CraftSim.RECIPE_SCAN:GetPlayerCrafterProfessionUID()
            local crafterUIDA = CraftSim.UTIL:GetCrafterUIDFromCrafterData(rowA.crafterData)
            local crafterUIDB = CraftSim.UTIL:GetCrafterUIDFromCrafterData(rowB.crafterData)
            local playerCrafterProfessionUIDA = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUIDA, rowA
                .profession)
            local playerCrafterProfessionUIDB = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUIDB, rowB
                .profession)

            -- current character and current profession always on top
            if playerCrafterProfessionUIDA == playerCrafterProfessionUID and playerCrafterProfessionUIDB ~= playerCrafterProfessionUID then
                return true
            elseif playerCrafterProfessionUIDA ~= playerCrafterProfessionUID and playerCrafterProfessionUIDB == playerCrafterProfessionUID then
                return false
            end

            -- next prefer current character
            if crafterUIDA == playerCrafterUID and crafterUIDB ~= playerCrafterUID then
                return true
            elseif crafterUIDA ~= playerCrafterUID and crafterUIDB == playerCrafterUID then
                return false
            end

            -- next sort by alphabet
            if crafterUIDA > crafterUIDB then
                return true
            elseif crafterUIDA < crafterUIDB then
                return false
            end

            return false
        end)

    --- since this is only called when first opening or in general opening a profession just select the current profession always
    -- only select if there is nothing selected yet
    local selectedRow = content.professionList.selectedRow --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    if not selectedRow then
        content.professionList:SelectRow(1)
    else
        CraftSim.RECIPE_SCAN.UI:UpdateProfessionListRowCachedRecipesInfo(selectedRow) --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW]]
    end
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@param content Frame
---@return CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT
function CraftSim.RECIPE_SCAN.UI:CreateProfessionTabContent(row, content)
    ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.TAB_CONTENT : Frame
    content = content

    content.recipeTitle = GGUI.Text {
        parent = content, anchorParent = content,
        anchorA = "TOP",
        anchorB = "TOP",
        offsetY = 8,
        sizeX = 15,
        sizeY = 25,
        scale = 1.2,
    }

    content.cachedRecipesInfo = GGUI.Text {
        parent = content, anchorParent = content.recipeTitle.frame, anchorA = "LEFT",
        anchorB = "RIGHT", justifyOptions = { type = "H", align = "LEFT" }, offsetX = 10, scale = 1,
    }

    content.cachedRecipesInfoHelpIcon = GGUI.HelpIcon {
        parent = content, anchorParent = content.cachedRecipesInfo.frame, anchorA = "LEFT", anchorB = "RIGHT",
        scale = 1, offsetX = 2, text = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP), offsetY = -1.5,
    }

    content.cachedRecipesInfoHelpIcon:Hide()

    content.scanButton = GGUI.Button({
        parent = content,
        anchorParent = content.recipeTitle.frame,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES),
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetY = -5,
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.RECIPE_SCAN:ScanRow(row)
        end
    })

    local expansionItems = GUTIL:Sort(GUTIL:Map(CraftSim.CONST.EXPANSION_IDS,
        function(expansionID)
            ---@type GGUI.CheckboxSelector.CheckboxItem
            local item = {
                name = L(CraftSim.CONST.EXPANSION_LOCALIZATION_IDS[expansionID]),
                savedVariableProperty = expansionID,
            }
            return item
        end), function(a, b)
        return a.savedVariableProperty > b.savedVariableProperty
    end)

    content.scanOptionsButton = GGUI.Button {
        parent = content,
        anchorPoints = { { anchorParent = content.scanButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
        cleanTemplate = true,
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        sizeX = 20, sizeY = 20,
        clickCallback = function(_, _)
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                local concentrationCB = rootDescription:CreateCheckbox(
                    f.bb("Enable ") .. f.gold("Concentration"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_ENABLE_CONCENTRATION")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_ENABLE_CONCENTRATION",
                            not value)
                    end)

                local favoritesCB = rootDescription:CreateCheckbox(
                    f.r("Only ") .. f.bb("Favorites"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_ONLY_FAVORITES")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_ONLY_FAVORITES")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_ONLY_FAVORITES",
                            not value)
                    end)

                rootDescription:CreateDivider()

                local soulboundCB = rootDescription:CreateCheckbox(
                    "Include " .. f.e("Soulbound") .. " Items",
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_SOULBOUND")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_INCLUDE_SOULBOUND")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_INCLUDE_SOULBOUND",
                            not value)
                    end)

                local unlearnedCB = rootDescription:CreateCheckbox(
                    "Include " .. f.r("Unlearned") .. " recipes",
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_NOT_LEARNED")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_INCLUDE_NOT_LEARNED")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_INCLUDE_NOT_LEARNED",
                            not value)
                    end)

                local gearCB = rootDescription:CreateCheckbox(
                    "Include " .. "Gear",
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDE_GEAR")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_INCLUDE_GEAR")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_INCLUDE_GEAR",
                            not value)
                    end)

                rootDescription:CreateDivider()

                local reagentAllocation = rootDescription:CreateButton("Reagent Allocation")

                reagentAllocation:CreateRadio("All " .. GUTIL:GetQualityIconString(1, 20, 20),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE") ==
                            CraftSim.RECIPE_SCAN.SCAN_MODES.Q1
                    end, function()
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_SCAN_MODE", CraftSim.RECIPE_SCAN.SCAN_MODES.Q1)
                    end)

                reagentAllocation:CreateRadio("All " .. GUTIL:GetQualityIconString(2, 20, 20), function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE") == CraftSim.RECIPE_SCAN.SCAN_MODES.Q2
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SCAN_MODE", CraftSim.RECIPE_SCAN.SCAN_MODES.Q2)
                end)

                reagentAllocation:CreateRadio("All " .. GUTIL:GetQualityIconString(3, 20, 20), function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE") == CraftSim.RECIPE_SCAN.SCAN_MODES.Q3
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SCAN_MODE", CraftSim.RECIPE_SCAN.SCAN_MODES.Q3)
                end)

                reagentAllocation:CreateRadio(L("RECIPE_SCAN_MODE_OPTIMIZE"), function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SCAN_MODE") == CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SCAN_MODE", CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE)
                end)

                local optimizeTopProfit = rootDescription:CreateCheckbox(
                    "Autoselect " .. f.g("Top Profit Quality"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_REAGENTS_TOP_PROFIT")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_OPTIMIZE_REAGENTS_TOP_PROFIT")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_REAGENTS_TOP_PROFIT",
                            not value)
                    end)

                local optimizeGear = rootDescription:CreateCheckbox(
                    "Optimize " .. f.bb("Profession Gear"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS",
                            not value)
                    end)

                local optimizeConcentration = rootDescription:CreateCheckbox(
                    "Optimize " .. f.gold("Concentration"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_CONCENTRATION_VALUE")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_OPTIMIZE_CONCENTRATION_VALUE")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_CONCENTRATION_VALUE",
                            not value)
                    end)

                local optimizeFinishingReagents = rootDescription:CreateCheckbox(
                    "Optimize " .. f.bb("Finishing Reagents"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_FINISHING_REAGENTS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_OPTIMIZE_FINISHING_REAGENTS")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_FINISHING_REAGENTS",
                            not value)
                    end)

                local optimizeSubRecipes = rootDescription:CreateCheckbox(
                    "Optimize " .. f.bb("Sub Recipes ") .. f.r("(Experimental - WIP)"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_SUBRECIPES")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "RECIPESCAN_OPTIMIZE_SUBRECIPES")
                        CraftSim.DB.OPTIONS:Save("RECIPESCAN_OPTIMIZE_SUBRECIPES",
                            not value)
                    end)

                rootDescription:CreateDivider()

                local includeExpansions = rootDescription:CreateButton("Include Expansion")
                local includedExpansions = CraftSim.DB.OPTIONS:Get("RECIPESCAN_FILTERED_EXPANSIONS")

                for _, expansionItem in ipairs(expansionItems) do
                    includeExpansions:CreateCheckbox(
                        expansionItem.name,
                        function()
                            return includedExpansions[expansionItem.savedVariableProperty]
                        end,
                        function()
                            includedExpansions[expansionItem.savedVariableProperty] = not includedExpansions
                                [expansionItem.savedVariableProperty]
                        end
                    )
                end
            end)
        end
    }

    content.cancelScanButton = GGUI.Button({
        parent = content,
        anchorParent = content.scanButton.frame,
        label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL),
        anchorA = "LEFT",
        anchorB = "RIGHT",
        offsetX = 30,
        sizeX = 15,
        sizeY = 25,
        adjustWidth = true,
        clickCallback = function()
            CraftSim.RECIPE_SCAN.isScanning = false
        end
    })

    content.resultAmount = GGUI.Text {
        parent = content, anchorParent = content.scanButton.frame, anchorA = "RIGHT", anchorB = "LEFT",
        offsetX = -10, justifyOptions = { type = "H", align = "RIGHT" }, text = "",
        fixedWidth = 50,
    }

    content.optimizationProgressStatusText = GGUI.Text {
        parent = content,
        anchorPoints = { { anchorParent = content.resultAmount.frame, anchorA = "RIGHT", anchorB = "LEFT", offsetX = 5, offsetY = -1 } },
        justifyOptions = { type = "H", align = "RIGHT" },
        text = "",
    }

    content.cancelScanButton:Hide()

    local columnOptions = {
        {
            --label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER),
            width = 15,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
            width = 160,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER),
            width = 90,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER),
            width = 100,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER),
            width = 60,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
            width = 140,
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER),
            width = 120,
            justifyOptions = { type = "H", align = "CENTER" }
        },
        {
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER),
            width = 80,
            justifyOptions = { type = "H", align = "CENTER" }
        }
    }

    ---@type GGUI.FrameList
    content.resultList = GGUI.FrameList({
        parent = content,
        anchorParent = content.scanButton.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        showBorder = true,
        sizeY = 280,
        offsetX = 15,
        offsetY = -25,
        columnOptions = columnOptions,
        selectionOptions = {
            hoverRGBA = { 1, 1, 1, 0.1 },
            noSelectionColor = true,
            selectionCallback = function(row)
                local recipeData = row.recipeData --[[@as CraftSim.RecipeData]]

                if recipeData then
                    if IsShiftKeyDown() and IsMouseButtonDown("LeftButton") then
                        -- queue into CraftQueue
                        if CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION") then
                            recipeData.concentrating = true
                        end
                        CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                    elseif IsMouseButtonDown("LeftButton") then
                        C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                    elseif IsMouseButtonDown("RightButton") then
                        MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                            rootDescription:CreateButton("Add to Craft Queue", function()
                                -- queue into CraftQueue
                                if CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION") then
                                    recipeData.concentrating = true
                                end
                                CraftSim.CRAFTQ:AddRecipe({ recipeData = recipeData })
                            end)
                            if recipeData:IsCrafter() then
                                local isFavorite = C_TradeSkillUI.IsRecipeFavorite(recipeData.recipeID)
                                if isFavorite then
                                    rootDescription:CreateButton(f.r("Remove") .. " Favorite", function()
                                        C_TradeSkillUI.SetRecipeFavorite(recipeData.recipeID, false)
                                        row.learnedColumn:SetLearned(true, false)
                                    end)
                                else
                                    rootDescription:CreateButton(f.g("Add") .. " Favorite", function()
                                        C_TradeSkillUI.SetRecipeFavorite(recipeData.recipeID, true)
                                        row.learnedColumn:SetLearned(true, true)
                                    end)
                                end
                            else
                                rootDescription:CreateButton(f.r("Favorites can only be changed on the crafter"))
                            end
                        end)
                    end
                end
            end
        },
        rowConstructor = function(columns, row)
            local learnedColumn = columns[1]
            row.learnedColumn = learnedColumn
            local recipeColumn = columns[2]
            local expectedResultColumn = columns[3]
            local concentrationValueColumn = columns[4]
            local concentrationCostColumn = columns[5]
            local averageProfitColumn = columns[6]
            local topGearColumn = columns[7]
            local countColumn = columns[8]

            recipeColumn.text = GGUI.Text({
                parent = recipeColumn,
                anchorParent = recipeColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
                scale = 0.9,
                fixedWidth = recipeColumn:GetWidth(),
                wrap = true,
            })

            local learnedIconSize = 0.08
            local learnedIcon = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, learnedIconSize)
            local notLearnedIcon = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, learnedIconSize)
            local favoriteIcon = CreateAtlasMarkup("PetJournal-FavoritesIcon", 15, 15)

            learnedColumn.text = GGUI.Text({
                parent = learnedColumn,
                anchorParent = learnedColumn,
                justifyOptions = { type = "H", align = "CENTER" },
                offsetY = -1,
                tooltipOptions = {
                    owner = learnedColumn,
                    anchor = "ANCHOR_CURSOR_RIGHT",
                    text = notLearnedIcon .. " .. not learned\n" .. learnedIcon .. " .. learned"
                },
            })

            function learnedColumn:SetLearned(learned, isFavorite)
                -- if its favorite it has to be learned
                if isFavorite then
                    learnedColumn.text:SetText(favoriteIcon)
                    return
                end
                if learned then
                    learnedColumn.text:SetText(learnedIcon)
                else
                    learnedColumn.text:SetText(notLearnedIcon)
                end
            end

            local iconSize = 23

            ---@type GGUI.Icon
            expectedResultColumn.itemIcon = GGUI.Icon({
                parent = expectedResultColumn,
                anchorParent = expectedResultColumn,
                sizeX = iconSize,
                sizeY =
                    iconSize,
                qualityIconScale = 1.4,
            })

            ---@type GGUI.Text
            concentrationValueColumn.text = GGUI.Text({
                parent = concentrationValueColumn,
                anchorParent = concentrationValueColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                justifyOptions = { type = "H", align = "LEFT" },
            })

            ---@type GGUI.Text
            concentrationCostColumn.text = GGUI.Text({
                parent = concentrationCostColumn,
                anchorParent = concentrationCostColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                scale = 0.95,
            })

            averageProfitColumn.text = GGUI.Text({
                parent = averageProfitColumn,
                anchorParent = averageProfitColumn,
                anchorA = "LEFT",
                anchorB = "LEFT",
                scale = 0.95,
            })

            topGearColumn.gear2Icon = GGUI.Icon({
                parent = topGearColumn, anchorParent = topGearColumn, sizeX = iconSize, sizeY = iconSize, qualityIconScale = 1.4,
            })

            topGearColumn.gear1Icon = GGUI.Icon({
                parent = topGearColumn,
                anchorParent = topGearColumn.gear2Icon.frame,
                anchorA = "RIGHT",
                anchorB = "LEFT",
                sizeX =
                    iconSize,
                sizeY = iconSize,
                qualityIconScale = 1.4,
                offsetX = -10,
            })
            topGearColumn.toolIcon = GGUI.Icon({
                parent = topGearColumn,
                anchorParent = topGearColumn.gear2Icon.frame,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                sizeX =
                    iconSize,
                sizeY = iconSize,
                qualityIconScale = 1.4,
                offsetX = 10
            })
            topGearColumn.equippedText = GGUI.Text({
                parent = topGearColumn, anchorParent = topGearColumn
            })

            function topGearColumn.equippedText:SetEquipped()
                topGearColumn.equippedText:SetText(GUTIL:ColorizeText(L(CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED),
                    GUTIL.COLORS.GREEN))
            end

            function topGearColumn.equippedText:SetIrrelevant()
                topGearColumn.equippedText:SetText(GUTIL:ColorizeText("-", GUTIL.COLORS.GREY))
            end

            countColumn.text = GGUI.Text({
                parent = countColumn, anchorParent = countColumn
            })
        end
    })

    GGUI.HelpIcon {
        parent = content, anchorParent = content.resultList.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT", offsetY = -4, offsetX = 65,
        text = "Press " ..
            CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + shift to queue selected recipe into the " .. f.bb("Craft Queue"),
        scale = 1.1,
    }

    content.sortButton = CreateFrame("DropdownButton", nil, content, "WowStyle1FilterDropdownTemplate")
    content.sortButton:SetText("Sort By")

    content.sortButton:SetSize(80, 23)
    content.sortButton:SetPoint("BOTTOMRIGHT", content.resultList.frame, "TOPRIGHT", 15, 25)

    content.sortButton:HookScript("OnClick", function()
        MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
            rootDescription:CreateCheckbox("Ascending", function()
                return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE_ASCENDING")
            end, function()
                local value = CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE_ASCENDING")
                CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE_ASCENDING", not value)
                CraftSim.RECIPE_SCAN:UpdateResultSort()
            end)

            rootDescription:CreateRadio(
                L("RECIPE_SCAN_SORT_MODE_PROFIT"),
                function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE") == CraftSim.RECIPE_SCAN.SORT_MODES.PROFIT
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE", CraftSim.RECIPE_SCAN.SORT_MODES.PROFIT)
                    CraftSim.RECIPE_SCAN:UpdateResultSort()
                end)
            rootDescription:CreateRadio(
                L("RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT"),
                function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE") ==
                        CraftSim.RECIPE_SCAN.SORT_MODES.RELATIVE_PROFIT
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE",
                        CraftSim.RECIPE_SCAN.SORT_MODES.RELATIVE_PROFIT)
                    CraftSim.RECIPE_SCAN:UpdateResultSort()
                end)
            rootDescription:CreateRadio(
                L("RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE"),
                function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE") ==
                        CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_VALUE
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE", CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_VALUE)
                    CraftSim.RECIPE_SCAN:UpdateResultSort()
                end)
            rootDescription:CreateRadio(
                L("RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST"),
                function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE") ==
                        CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_COST
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE", CraftSim.RECIPE_SCAN.SORT_MODES.CONCENTRATION_COST)
                    CraftSim.RECIPE_SCAN:UpdateResultSort()
                end)
            rootDescription:CreateRadio(
                L("RECIPE_SCAN_SORT_MODE_CRAFTING_COST"),
                function()
                    return CraftSim.DB.OPTIONS:Get("RECIPESCAN_SORT_MODE") ==
                        CraftSim.RECIPE_SCAN.SORT_MODES.CRAFTING_COST
                end, function()
                    CraftSim.DB.OPTIONS:Save("RECIPESCAN_SORT_MODE", CraftSim.RECIPE_SCAN.SORT_MODES.CRAFTING_COST)
                    CraftSim.RECIPE_SCAN:UpdateResultSort()
                end)
        end)
    end)

    return content
end

---@param crafterUID string
---@param profession Enum.Profession
function CraftSim.RECIPE_SCAN.UI:AddProfessionTabRow(crafterUID, profession)
    local content = CraftSim.RECIPE_SCAN.frame.content.recipeScanTab
        .content --[[@as CraftSim.RECIPE_SCAN.RECIPE_SCAN_TAB.CONTENT]]
    content.professionList:Add(function(row)
        ---@class CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW : GGUI.FrameList.Row
        row = row

        ---@type Enum.Profession
        row.profession = profession
        ---@type string
        row.crafterUID = crafterUID
        ---@type string
        row.crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)

        ---@type CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW[]
        row.activeRows = content.professionList.activeRows
        local columns = row.columns
        local checkboxColumn = columns[1] --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.CHECKBOX_COLUMN]]
        ---@type CraftSim.RECIPE_SCAN.PROFESSION_LIST.CRAFTER_COLUMN : Frame
        local crafterColumn = columns[2] --[[@as CraftSim.RECIPE_SCAN.PROFESSION_LIST.CRAFTER_COLUMN]]

        local crafterClass = CraftSim.DB.CRAFTER:GetClass(crafterUID)
        local crafterName, crafterRealm = strsplit("-", crafterUID)
        local coloredCrafterName = f.class(crafterName, crafterClass)
        local professionIconSize = 20
        local professionIcon = GUTIL:IconToText(CraftSim.CONST.PROFESSION_ICONS[row.profession], professionIconSize,
            professionIconSize)
        ---@type GGUI.TooltipOptions
        row.tooltipOptions = {
            text = crafterUID .. ": " .. L(CraftSim.CONST.PROFESSION_LOCALIZATION_IDS[profession]),
            anchor = "ANCHOR_TOP",
            owner = row.frame
        }

        crafterColumn.text:SetText(professionIcon .. " " .. coloredCrafterName)
        ---@type Enum.Profession
        ---@type CraftSim.CrafterData
        row.crafterData = {
            name = crafterName,
            realm = crafterRealm,
            class = crafterClass,
        }

        ---@type CraftSim.RecipeData[]
        row.currentResults = {}

        local crafterProfessionUID = CraftSim.RECIPE_SCAN:GetCrafterProfessionUID(crafterUID, profession)

        local isChecked = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDED_PROFESSIONS")[crafterProfessionUID]

        checkboxColumn.checkbox:SetChecked(isChecked)

        checkboxColumn.checkbox.clickCallback = function(_, checked)
            local includedProfessions = CraftSim.DB.OPTIONS:Get("RECIPESCAN_INCLUDED_PROFESSIONS")
            includedProfessions[crafterProfessionUID] = checked
        end

        row.contentFrame = GGUI.Frame {
            parent = content, anchorParent = content.professionList.frame, sizeX = 850, sizeY = content.professionList:GetHeight(),
            anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetX = -20,
        }
        row.contentFrame.frame:SetFrameStrata(content:GetFrameStrata())
        row.contentFrame.frame:SetFrameLevel(content:GetFrameLevel() + 10)
        row.contentFrame:Hide()

        row.content = CraftSim.RECIPE_SCAN.UI:CreateProfessionTabContent(row, row.contentFrame.content)

        row.content.recipeTitle:SetText(professionIcon .. " " .. coloredCrafterName)
    end)
end

---@param scanOptionsTab CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB
function CraftSim.RECIPE_SCAN.UI:InitScanOptionsTab(scanOptionsTab)
    ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB
    scanOptionsTab = scanOptionsTab
    ---@class CraftSim.RECIPE_SCAN.SCAN_OPTIONS_TAB.CONTENT : Frame
    local content = scanOptionsTab.content
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
function CraftSim.RECIPE_SCAN.UI:ResetResults(row)
    local resultList = row.content.resultList
    resultList:Remove()
    row.content.resultAmount:SetText("")
end

---@param row CraftSim.RECIPE_SCAN.PROFESSION_LIST.ROW
---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN.UI:AddRecipe(row, recipeData)
    local resultList = row.content.resultList
    local showProfit = CraftSim.DB.OPTIONS:Get("SHOW_PROFIT_PERCENTAGE")

    resultList:Add(
        function(row)
            local columns = row.columns

            local learnedColumn = columns[1]
            local recipeColumn = columns[2]
            local expectedResultColumn = columns[3]
            local concentrationValueColumn = columns[4]
            local concentrationCostColumn = columns[5]
            local averageProfitColumn = columns[6]
            local topGearColumn = columns[7]
            local countColumn = columns[8]

            row.recipeData = recipeData

            local enableConcentration = CraftSim.DB.OPTIONS:Get("RECIPESCAN_ENABLE_CONCENTRATION") and
                recipeData.supportsQualities

            local recipeRarity = recipeData.resultData.expectedItem:GetItemQualityColor()

            local cooldownInfoText = ""
            local cooldownData = recipeData:GetCooldownDataForRecipeCrafter()
            if cooldownData and cooldownData.isCooldownRecipe then
                local timeIcon = CreateAtlasMarkup(CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.COOLDOWN.texture, 13, 13)
                local currentCharges = cooldownData:GetCurrentCharges()
                cooldownInfoText = " " .. timeIcon ..
                    "(" .. currentCharges .. "/" .. cooldownData.maxCharges .. ")"
            end

            local isFavorite = CraftSim.DB.CRAFTER:IsFavorite(recipeData.recipeID, recipeData:GetCrafterUID(),
                recipeData.professionData.professionInfo.profession)

            recipeColumn.text:SetText(recipeRarity.hex ..
                recipeData.recipeName .. "|r" .. cooldownInfoText)

            learnedColumn:SetLearned(recipeData.learned, isFavorite)

            if enableConcentration then
                expectedResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItemConcentration)
            else
                expectedResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItem)
            end


            local relativeTo = nil
            if showProfit then
                relativeTo = recipeData.priceData.craftingCosts
            end

            local averageProfit = recipeData:GetAverageProfit()
            row.concentrationWeight = 0
            row.concentrationProfit = 0
            if enableConcentration then
                row.concentrationWeight, row.concentrationProfit = recipeData:GetConcentrationValue()
            end

            if enableConcentration and (row.concentrationProfit > 0) then
                averageProfit = row.concentrationProfit
            end

            row.averageProfit = averageProfit
            row.relativeProfit = GUTIL:GetPercentRelativeTo(averageProfit, recipeData.priceData.craftingCosts)
            row.craftingCost = recipeData.priceData.craftingCosts
            recipeData.resultData:Update() -- switch back
            row.concentrationCost = recipeData.concentrationCost
            concentrationCostColumn.text:SetText((enableConcentration and row.concentrationCost) or f.grey("-"))
            concentrationValueColumn.text:SetText((enableConcentration and CraftSim.UTIL:FormatMoney(row.concentrationWeight, true)) or
                f.grey("-"))

            averageProfitColumn.text:SetText(CraftSim.UTIL:FormatMoney(averageProfit, true, relativeTo, true))

            if CraftSim.DB.OPTIONS:Get("RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS") then
                if recipeData.professionGearSet:IsEquipped() then
                    topGearColumn.equippedText:Show()
                    topGearColumn.equippedText:SetEquipped()

                    topGearColumn.gear1Icon:Hide()
                    topGearColumn.gear2Icon:Hide()
                    topGearColumn.toolIcon:Hide()
                else
                    topGearColumn.equippedText:Hide()
                    if recipeData.isCooking then
                        topGearColumn.gear1Icon:Hide()
                    else
                        topGearColumn.gear1Icon:SetItem(recipeData.professionGearSet.gear1.item)
                        topGearColumn.gear1Icon:Show()
                    end

                    topGearColumn.gear2Icon:SetItem(recipeData.professionGearSet.gear2.item)
                    topGearColumn.toolIcon:SetItem(recipeData.professionGearSet.tool.item)

                    topGearColumn.gear2Icon:Show()
                    topGearColumn.toolIcon:Show()
                end
            else
                topGearColumn.gear1Icon:Hide()
                topGearColumn.gear2Icon:Hide()
                topGearColumn.toolIcon:Hide()
                topGearColumn.equippedText:Show()
                topGearColumn.equippedText:SetIrrelevant()
            end

            -- for inventory count, count all result items together? For now.. Maybe a user will have a better idea!

            local totalCountInv = 0
            local totalCountAH = nil
            for _, resultItem in pairs(recipeData.resultData.itemsByQuality) do
                -- links are already loaded here
                totalCountInv = totalCountInv + C_Item.GetItemCount(resultItem:GetItemLink(), true, false, true)
                local countAH = CraftSim.PRICE_SOURCE:GetAuctionAmount(resultItem:GetItemLink())

                if countAH then
                    totalCountAH = (totalCountAH or 0) + countAH
                end
            end

            local countText = tostring(totalCountInv)

            if totalCountAH then
                countText = countText .. " / " .. totalCountAH
            end

            countColumn.text:SetText(countText)

            -- show reagents in tooltip when recipe is hovered

            row.tooltipOptions = {
                text = recipeData.reagentData:GetTooltipText(1, recipeData:GetCrafterUID()),
                owner = row.frame,
                anchor = "ANCHOR_CURSOR",
            }
        end)
    resultList:UpdateDisplay()
end
