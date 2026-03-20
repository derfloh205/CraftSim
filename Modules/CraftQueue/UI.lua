---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ
CraftSim.CRAFTQ = CraftSim.CRAFTQ

---@class CraftSim.CRAFTQ.UI
CraftSim.CRAFTQ.UI = {}

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

local print = CraftSim.DEBUG:RegisterDebugID("Modules.CraftQueue.UI")

function CraftSim.CRAFTQ.UI:Init()
    local sizeX = 880
    local sizeY = 420

    ---@class CraftSim.CraftQueue.Frame : GGUI.Frame
    CraftSim.CRAFTQ.frame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE,
        title = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_CRAFT_QUEUE"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = CraftSim.UTIL:NextFrameLevel()
    })

    ---@param frame CraftSim.CraftQueue.Frame
    local function createContent(frame)
        local tabContentSizeX = 1010
        local tabContentSizeY = 330

        ---@class CraftSim.CraftQueue.Frame.Content : Frame
        frame.content = frame.content


        self:InitializeQuickAccessBar(frame)


        frame.content.craftQueueOptionsButton = CraftSim.WIDGETS.OptionsButton {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.title.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            menuUtilCallback = function(ownerRegion, rootDescription)
                local autoShow = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.CRAFT_QUEUE_MENU_AUTO_SHOW),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_AUTO_SHOW")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_AUTO_SHOW")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_AUTO_SHOW",
                            not value)
                    end)

                local ingenuityIgnoreCB = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.CRAFT_QUEUE_MENU_INGENUITY_IGNORE),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_IGNORE_INGENUITY_PROCS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_IGNORE_INGENUITY_PROCS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_IGNORE_INGENUITY_PROCS",
                            not value)
                    end)

                local dequeueConcentrationCB = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get(
                            "CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_REMOVE_ON_ALL_CONCENTRATION_USED",
                            not value)
                    end)

                dequeueConcentrationCB:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_AddInstructionLine(tooltip,
                        L(CraftSim.CONST.TEXT.CRAFT_QUEUE_MENU_DEQUEUE_CONCENTRATION_TOOLTIP));
                end);
            end
        }

        GGUI.HelpIcon {
            parent = frame.content,
            anchorParent = frame.content.craftQueueOptionsButton.frame,
            anchorA = "LEFT", anchorB = "RIGHT",
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_HELP),
        }

        ---@type GGUI.BlizzardTab
        frame.content.queueTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                offsetY = -2,
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL),
            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = tabContentSizeX,
            sizeY = tabContentSizeY,
            canBeEnabled = true,
            offsetY = -30,
            initialTab = true,
            top = true,
        })
        ---@class CraftSim.CraftQueue.QueueTab : GGUI.BlizzardTab
        local queueTab = frame.content.queueTab
        ---@class CraftSim.CraftQueue.QueueTab.Content
        queueTab.content = queueTab.content

        GGUI.BlizzardTabSystem({ queueTab })

        ---@type GGUI.FrameList.ColumnOption[]
        local columnOptions = {
            {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER),
                width = 100,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
                width = 150,
            },
            {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER),
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
                width = 120,
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER),
                width = 130,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20, 1),
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" },
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER),
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT),
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER),
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER), -- Status
                width = 50,
                justifyOptions = { type = "H", align = "CENTER" },
                tooltipOptions = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    anchor = nil,
                    owner = nil,
                    text = f.white(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP)),
                    textWrap = true,
                },
            },
            {
                label = "", -- craftButtonColumn
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" }
            },
        }

        ---@class CraftSim.CraftQueue.CraftList : GGUI.FrameList
        queueTab.content.craftList = GGUI.FrameList({
            parent = queueTab.content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "TOP",
            scale = 0.95,
            showBorder = true,
            selectionOptions = {
                hoverRGBA = { 1, 1, 1, 0.1 },
                noSelectionColor = true,
                selectionCallback = function(row)
                    ---@type CraftSim.CraftQueueItem
                    local craftQueueItem = row.craftQueueItem
                    if craftQueueItem then
                        local recipeData = craftQueueItem.recipeData
                        if recipeData then
                            if IsMouseButtonDown("LeftButton") then
                                if recipeData:IsWorkOrder() and C_CraftingOrders.ShouldShowCraftingOrderTab() and ProfessionsFrame.isCraftingOrdersTabEnabled then
                                    if not ProfessionsFrame.OrdersPage:IsVisible() then
                                        ProfessionsFrame:GetTabButton(3):Click() -- 3 is Crafting Orders Tab
                                    end
                                    ProfessionsFrame.OrdersPage:ViewOrder(recipeData.orderData)
                                    CraftSim.MODULES:UpdateUI()
                                else
                                    if not ProfessionsFrame.CraftingPage:IsVisible() then
                                        ProfessionsFrame:GetTabButton(1):Click()
                                        C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                                    else
                                        RunNextFrame(function()
                                            C_TradeSkillUI.OpenRecipe(recipeData.recipeID)
                                        end)
                                    end
                                end
                            elseif IsMouseButtonDown("RightButton") then
                                MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                                    rootDescription:CreateTitle(recipeData.recipeName)
                                    rootDescription:CreateDivider()

                                    if recipeData:IsCrafter() then
                                        if not recipeData.professionGearSet:IsEquipped() then
                                            rootDescription:CreateButton(f.g("Equip Tools"), function()
                                                recipeData.professionGearSet:Equip()
                                            end)
                                            rootDescription:CreateButton(f.l("Force Equipped Tools"), function()
                                                recipeData:SetEquippedProfessionGearSet()
                                                CraftSim.CRAFTQ.UI:UpdateDisplay()
                                            end)
                                        end
                                    end

                                    rootDescription:CreateButton(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_EDIT),
                                        function()
                                            CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(craftQueueItem)
                                            if not CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:IsVisible() then
                                                CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:Show()
                                            end
                                        end)
                                    rootDescription:CreateButton(f.r("Remove"), function()
                                        CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem, true)
                                        CraftSim.CRAFTQ.UI:UpdateDisplay()
                                    end)
                                end)
                            elseif IsMouseButtonDown("MiddleButton") then
                                CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem, true)
                                CraftSim.CRAFTQ.UI:UpdateDisplay()
                            end
                        end
                    end
                end
            },
            sizeY = 232,
            offsetY = -70,
            offsetX = -10,
            columnOptions = columnOptions,
            rowConstructor = function(columns, row)
                ---@class CraftSim.CraftQueue.CraftList.CrafterColumn : Frame
                local crafterColumn = columns[1]
                ---@class CraftSim.CraftQueue.CraftList.RecipeColumn : Frame
                local recipeColumn = columns[2]
                ---@class CraftSim.CraftQueue.CraftList.ResultColumn : Frame
                local resultColumn = columns[3]
                ---@class CraftSim.CraftQueue.CraftList.AverageProfitColumn : Frame
                local averageProfitColumn = columns[4]
                ---@class CraftSim.CraftQueue.CraftList.CraftingCostColumn : Frame
                local craftingCostsColumn = columns[5]
                ---@class CraftSim.CraftQueue.CraftList.ConcentrationColumn : Frame
                local concentrationColumn = columns[6]
                ---@class CraftSim.CraftQueue.CraftList.TopGearColumn : Frame
                local topGearColumn = columns[7]
                ---@class CraftSim.CraftQueue.CraftList.CraftAbleColumn : Frame
                local craftAbleColumn = columns[8]
                ---@class CraftSim.CraftQueue.CraftList.CraftAmountColumn : Frame
                local craftAmountColumn = columns[9]
                ---@class CraftSim.CraftQueue.CraftList.StatusColumn : Frame
                local statusColumn = columns[10]
                ---@class CraftSim.CraftQueue.CraftList.CraftButtonColumn : Frame
                local craftButtonColumn = columns[11]

                crafterColumn.text = GGUI.Text {
                    parent = crafterColumn, anchorParent = crafterColumn,
                    scale = 0.9
                }

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

                local iconSize = 23

                resultColumn.icon = GGUI.Icon {
                    parent = resultColumn,
                    anchorParent = resultColumn,
                    qualityIconScale = 1.2,
                    sizeX = iconSize,
                    sizeY = iconSize,
                }

                ---@type GGUI.Text | GGUI.Widget
                averageProfitColumn.text = GGUI.Text(
                    {
                        parent = averageProfitColumn,
                        anchorParent = averageProfitColumn,
                        anchorA = "LEFT",
                        anchorB =
                        "LEFT",
                        scale = 0.9,

                    })

                craftingCostsColumn.text = GGUI.Text {
                    parent = craftingCostsColumn,
                    anchorParent = craftingCostsColumn,
                    anchorA = "RIGHT",
                    anchorB =
                    "RIGHT",
                    scale = 0.9,
                    justifyOptions = { type = "H", align = "RIGHT" }
                }

                concentrationColumn.text = GGUI.Text {
                    parent = concentrationColumn,
                    anchorParent = concentrationColumn,
                    scale = 0.9,
                }

                local statusIconSize = 17

                topGearColumn.statusIcon = GGUI.Texture {
                    parent = topGearColumn, anchorParent = topGearColumn,
                    sizeX = statusIconSize, sizeY = statusIconSize,
                    atlas = CraftSim.CONST.ATLAS_TEXTURES.CHECKMARK,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = "",
                    },
                }

                ---@param professionGearSet CraftSim.ProfessionGearSet
                ---@param isEquipped boolean
                function topGearColumn.statusIcon:SetTools(professionGearSet, isEquipped)
                    if isEquipped then
                        self:SetAtlas(CraftSim.CONST.ATLAS_TEXTURES.CHECKMARK)
                    else
                        self:SetAtlas(CraftSim.CONST.ATLAS_TEXTURES.CROSS)
                    end

                    local tooltipText = ""
                    local toolIconSize = 25
                    local emptySlotIcon = GUTIL:IconToText(CraftSim.CONST.EMPTY_SLOT_TEXTURE, toolIconSize, toolIconSize)

                    if professionGearSet.gear1 then
                        local item = professionGearSet.gear1.item
                        if item then
                            local icon = item:GetItemIcon()
                            tooltipText = tooltipText ..
                                GUTIL:IconToText(icon, toolIconSize, toolIconSize) .. " " .. item:GetItemLink() .. "\n"
                        else
                            tooltipText = tooltipText .. emptySlotIcon .. f.grey(" [Empty Slot]\n")
                        end
                    end

                    if professionGearSet.gear2 then
                        local item = professionGearSet.gear2.item
                        if item then
                            local icon = item:GetItemIcon()
                            tooltipText = tooltipText ..
                                GUTIL:IconToText(icon, toolIconSize, toolIconSize) .. " " .. item:GetItemLink() .. "\n"
                        else
                            tooltipText = tooltipText .. emptySlotIcon .. f.grey(" [Empty Slot]\n")
                        end
                    end

                    if professionGearSet.tool then
                        local item = professionGearSet.tool.item
                        if item then
                            local icon = item:GetItemIcon()
                            local statText = ""
                            if professionGearSet.tool.professionStats.craftingspeed.value > 0 then
                                statText = string.format(" (%s)", L("STAT_CRAFTINGSPEED"))
                            elseif professionGearSet.tool.professionStats.multicraft.value > 0 then
                                statText = string.format(" (%s)", L("STAT_MULTICRAFT"))
                            elseif professionGearSet.tool.professionStats.resourcefulness.value > 0 then
                                statText = string.format(" (%s)", L("STAT_RESOURCEFULNESS"))
                            elseif professionGearSet.tool.professionStats.ingenuity.value > 0 then
                                statText = string.format(" (%s)", L("STAT_INGENUITY"))
                            end
                            tooltipText = tooltipText ..
                                GUTIL:IconToText(icon, toolIconSize, toolIconSize) ..
                                " " .. item:GetItemLink() .. f.bb(statText) .. "\n"
                        else
                            tooltipText = tooltipText .. emptySlotIcon .. f.grey(" [Empty Slot]")
                        end
                    end

                    self.tooltipOptions.text = tooltipText
                end

                craftAbleColumn.text = GGUI.Text({
                    parent = craftAbleColumn, anchorParent = craftAbleColumn
                })

                craftAmountColumn.inputText = GGUI.Text {
                    parent = craftAmountColumn, anchorPoints = { { anchorParent = craftAmountColumn, anchorA = "LEFT", anchorB = "LEFT", offsetX = -1 } },
                    hide = true, scale = 0.95,
                }

                craftAmountColumn.input = GGUI.NumericInput({
                    parent = craftAmountColumn,
                    anchorParent = craftAmountColumn,
                    sizeX = 35,
                    borderAdjustWidth = 1.3,
                    minValue = 1,
                    initialValue = 1,
                    onEnterPressedCallback = nil, -- set dynamically on Add
                    onTabPressedCallback = function(input)
                        -- focus next editbox in the row below
                        local activeRowIndex = row:GetActiveRowIndex()
                        if activeRowIndex then
                            local nextRow = row.frameList.activeRows[activeRowIndex + 1]
                            if nextRow then
                                input.textInput.frame:ClearFocus()
                                local craftAmountColumn = nextRow.columns
                                    [9] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
                                craftAmountColumn.input.textInput.frame:SetFocus()
                            end
                        end
                    end,
                    onNumberValidCallback = function()
                        craftAmountColumn.unsavedMarker:Show()
                    end
                })

                craftAmountColumn.unsavedMarker = GGUI.Text {
                    parent = craftAmountColumn, anchorPoints =
                { { anchorParent = craftAmountColumn.input.textInput.frame, anchorA = "TOPRIGHT", anchorB = "TOPLEFT", offsetX = -5, offsetY = -3 } },
                    text = "*", scale = 1.2,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR",
                        text = L("CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP")
                    },
                    hide = true,
                }

                statusColumn.statusIcon = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn,
                    sizeX = statusIconSize, sizeY = statusIconSize,
                    atlas = CraftSim.CONST.ATLAS_TEXTURES.CHECKMARK,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = f.g("Ready to Craft"),
                    },
                }

                function statusColumn.statusIcon:SetStatus(enabled, tooltipText)
                    if enabled then
                        self:SetAtlas(CraftSim.CONST.ATLAS_TEXTURES.CHECKMARK)
                        self.tooltipOptions.text = f.g("Ready to Craft")
                    else
                        self:SetAtlas(CraftSim.CONST.ATLAS_TEXTURES.CROSS)
                        self.tooltipOptions.text = tooltipText
                    end
                end

                craftButtonColumn.craftButton = GGUI.Button({
                    parent = craftButtonColumn,
                    anchorParent = craftButtonColumn,
                    label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL),
                    adjustWidth = true,
                    secure = true,
                })
            end
        })

        local craftQueueButtonsOffsetY = -5
        local fixedButtonWidth = 180
        ---@type GGUI.Button
        queueTab.content.queueFavoritesButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = craftQueueButtonsOffsetY,
            offsetX = 0,
            sizeX = fixedButtonWidth,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL),
            initialStatusID = "Ready",
            clickCallback = function()
                CraftSim.CRAFTQ:QueueFavorites()
            end
        })

        queueTab.content.queueFavoritesButton:SetStatusList {
            {
                statusID = "Ready",
                enabled = true,
                sizeX = fixedButtonWidth,
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL),
            },
        }

        queueTab.content.queueFavoritesButtonOptions = GGUI.Button {
            parent = queueTab.content,
            anchorPoints = { { anchorParent = queueTab.content.queueFavoritesButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            cleanTemplate = true,
            buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
            sizeX = 20, sizeY = 20,
            clickCallback = function(_, _)
                MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                    local smartQueueCB = rootDescription:CreateCheckbox(
                        L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING",
                                not value)
                        end)
                    smartQueueCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING_TOOLTIP));
                    end);

                    local concentrationCraftsCB = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT),
                        function()
                            return CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT",
                                not value)
                        end)
                    concentrationCraftsCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT_TOOLTIP));
                    end);

                    local mainProfessionsCB = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS),
                        function()
                            return CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_QUEUE_FAVORITES_QUEUE_MAIN_PROFESSIONS")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_QUEUE_FAVORITES_QUEUE_MAIN_PROFESSIONS")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_FAVORITES_QUEUE_MAIN_PROFESSIONS",
                                not value)
                        end)
                    mainProfessionsCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_QUEUE_MAIN_PROFESSIONS_TOOLTIP));
                    end);

                    local includeSoulboundFRDB = rootDescription:CreateCheckbox(
                        "Include " .. f.e("Soulbound") .. f.bb(" Finishing Reagents"),
                        function()
                            return CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND",
                                not value)
                        end)

                    includeSoulboundFRDB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "If enabled, CraftSim will suggest soulbound finishing reagents during optimization");
                    end);

                    local includeSoulboundFRDB = rootDescription:CreateCheckbox(
                        "Include " .. f.e("Soulbound") .. f.bb(" Finishing Reagents"),
                        function()
                            return CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND",
                                not value)
                        end)

                    includeSoulboundFRDB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "If enabled, CraftSim will suggest soulbound finishing reagents during optimization");
                    end);

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(rootDescription, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_LABEL),
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.NumericInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 30, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"),
                            borderAdjustWidth = 1.32,
                            minValue = 0,
                            tooltipOptions = {
                                anchor = "ANCHOR_TOP",
                                owner = frame,
                                text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_OFFSET_QUEUE_AMOUNT_TOOLTIP),
                            },
                            onNumberValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT",
                                    tonumber(input.currentValue))
                            end,
                        }
                    end, 200, 25, "RECIPE_SCAN_SEND_TO_CRAFT_QUEUE_OFFSET_QUEUE_AMOUNT_INPUT")

                    local autoShoppingListCB = rootDescription:CreateCheckbox(
                    L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_RESTOCK_FAVORITES_AUTO_SHOPPING_LIST",
                                not value)
                        end)
                    autoShoppingListCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_RESTOCK_FAVORITES_OPTIONS_AUTO_SHOPPING_LIST"));
                    end)
                end)
            end
        }

        queueTab.content.addAllFirstCraftsButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.queueFavoritesButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            sizeX = fixedButtonWidth,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL),
            clickCallback = function()
                CraftSim.CRAFTQ:QueueFirstCrafts()
            end
        })

        queueTab.content.addAllFirstCraftsOptions = GGUI.Button {
            parent = queueTab.content,
            anchorPoints = { { anchorParent = queueTab.content.addAllFirstCraftsButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            cleanTemplate = true,
            buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
            sizeX = 20, sizeY = 20,
            clickCallback = function(_, _)
                MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                    local acuityCB = rootDescription:CreateCheckbox(
                        L(CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES", not value)
                        end)

                    acuityCB:SetTooltip(function(tooltip, elementDescription)
                        --GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP"));
                        --GameTooltip_AddNormalLine(tooltip, "Test Tooltip Normal Line");
                        --GameTooltip_AddErrorLine(tooltip, "Test Tooltip Colored Line");
                    end);

                    local sparksCB = rootDescription:CreateCheckbox(
                        L(CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_LABEL),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_SPARK_RECIPES", not value)
                        end)

                    sparksCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L(CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_SPARK_RECIPES_CHECKBOX_TOOLTIP));
                    end);
                end)
            end
        }

        queueTab.content.addWorkOrdersButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addAllFirstCraftsButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            sizeX = fixedButtonWidth,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL),
            clickCallback = function()
                CraftSim.CRAFTQ:QueueWorkOrders()
            end
        })

        queueTab.content.addWorkOrdersOptions = GGUI.Button {
            parent = queueTab.content,
            anchorPoints = { { anchorParent = queueTab.content.addWorkOrdersButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
            cleanTemplate = true,
            buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
            sizeX = 20, sizeY = 20,
            clickCallback = function(_, _)
                MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                    local concentrationCB = rootDescription:CreateCheckbox(L("CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION", not value)
                        end)

                    concentrationCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP"));
                    end);
                        
                    local onlyProfitableCB = rootDescription:CreateCheckbox(L("CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_ONLY_PROFITABLE", not value)
                        end)

                    onlyProfitableCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_ADD_WORK_ORDERS_ONLY_PROFITABLE_TOOLTIP"))
                    end);
 
                    local orderTypeSubMenu = rootDescription:CreateButton(L("CRAFT_QUEUE_WORK_ORDER_TYPE_BUTTON"))

                    orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_PATRON_ORDERS_BUTTON"), function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PATRON_ORDERS", not value)
                    end)

                    orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_GUILD_ORDERS_BUTTON"), function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_GUILD_ORDERS", not value)
                    end)

                    orderTypeSubMenu:CreateCheckbox(L("CRAFT_QUEUE_PERSONAL_ORDERS_BUTTON"), function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_INCLUDE_PERSONAL_ORDERS", not value)
                    end)

                    local guildOrderOptions = rootDescription:CreateButton(L("CRAFT_QUEUE_GUILD_ORDERS_BUTTON"))
                    local altCharsOnlyGuild = guildOrderOptions:CreateCheckbox(L("CRAFT_QUEUE_GUILD_ORDERS_ALTS_ONLY_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_GUILD_ALTS_ONLY", not value)
                        end)

                    local patronOrderOptions = rootDescription:CreateButton(L("CRAFT_QUEUE_PATRON_ORDERS_BUTTON"))

                    local forceConcentrationCB = patronOrderOptions:CreateCheckbox(
                        L("CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION", not value)
                        end)

                    forceConcentrationCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_PATRON_ORDERS_FORCE_CONCENTRATION_TOOLTIP"));
                    end);

                    local sparkCB = patronOrderOptions:CreateCheckbox(L("CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_SPARK_RECIPES", not value)
                        end)

                    sparkCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_PATRON_ORDERS_SPARK_RECIPES_TOOLTIP"));
                    end);

                    local acuityCB = patronOrderOptions:CreateCheckbox(
                        L("CRAFT_QUEUE_PATRON_ORDERS_ACUITY_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_ACUITY")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_ACUITY")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_ACUITY", not value)
                        end)

                    acuityCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_PATRON_ORDERS_ACUITY_TOOLTIP"));
                    end);

                    local powerRuneCB = patronOrderOptions:CreateCheckbox(
                        L("CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_POWER_RUNE", not value)
                        end)

                    powerRuneCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_PATRON_ORDERS_POWER_RUNE_TOOLTIP"));
                    end);

                    local knowledgeCB = patronOrderOptions:CreateCheckbox(
                        L("CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_CHECKBOX"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS", not value)
                        end)

                    knowledgeCB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            L("CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_TOOLTIP"));
                    end);

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST),
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.CurrencyInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 60, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST"),
                            borderAdjustWidth = 1,
                            minValue = 0.94,
                            tooltipOptions = {
                                anchor = "ANCHOR_TOP",
                                owner = frame,
                                text = f.white(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_PATRON_ORDERS_KNOWLEDGE_POINTS_MAX_COST_TOOLTIP) .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                            },
                            onValueValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST",
                                    tonumber(input.total))
                            end,
                        }
                    end, 210, 25, "CRAFTQUEUE_QUEUE_PATRON_ORDERS_KP_MAX_COST_INPUT")

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_PATRON_ORDERS_MAX_COST),
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.CurrencyInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 60, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST"),
                            borderAdjustWidth = 1,
                            minValue = 0.94,
                            tooltipOptions = {
                                anchor = "ANCHOR_TOP",
                                owner = frame,
                                text = f.white(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_PATRON_ORDERS_MAX_COST_TOOLTIP) .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                            },
                            onValueValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST",
                                    tonumber(input.total))
                            end,
                        }
                    end, 210, 25, "CRAFTQUEUE_QUEUE_PATRON_ORDERS_MAX_COST_INPUT")

                    GUTIL:CreateReuseableMenuUtilContextMenuFrame(patronOrderOptions, function(frame)
                        frame.label = GGUI.Text {
                            parent = frame,
                            anchorPoints = { { anchorParent = frame, anchorA = "LEFT", anchorB = "LEFT" } },
                            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE),
                            justifyOptions = { type = "H", align = "LEFT" },
                        }
                        frame.input = GGUI.CurrencyInput {
                            parent = frame, anchorParent = frame,
                            sizeX = 60, sizeY = 25, offsetX = 5,
                            anchorA = "RIGHT", anchorB = "RIGHT",
                            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE"),
                            borderAdjustWidth = 1,
                            minValue = 0.94,
                            tooltipOptions = {
                                anchor = "ANCHOR_TOP",
                                owner = frame,
                                text = f.white(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_TOOLTIP) .. GUTIL:FormatMoney(1000000, false, nil, false, false)),
                            },
                            onValueValidCallback = function(input)
                                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE",
                                    tonumber(input.total))
                            end,
                        }
                    end, 210, 25, "CRAFTQUEUE_QUEUE_PATRON_ORDERS_REAGENT_BAG_VALUE_INPUT")
                end)
            end
        }

        ---@type GGUI.Button
        queueTab.content.clearAllButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addWorkOrdersButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            sizeX = fixedButtonWidth,
            label = f.l(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL)),
            clickCallback = function()
                CraftSim.CRAFTQ:ClearAll()
            end
        })

        ---@type GGUI.Button
        queueTab.content.craftNextButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            offsetY = craftQueueButtonsOffsetY,
            offsetX = 0,
            adjustWidth = true,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL),
            clickCallback = nil
        })


        if select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
            ---@type GGUI.Button
            queueTab.content.createAuctionatorShoppingList = GGUI.Button({
                parent = queueTab.content,
                anchorParent = queueTab.content,
                anchorA = "BOTTOM",
                anchorB = "BOTTOM",
                adjustWidth = true,
                sizeX = 15,
                offsetY = -2,
                offsetX = 5,
                clickCallback = function()
                    CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
                end,
                label = L(CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL)
            })
        end

        -- summaries

        queueTab.content.totalAverageProfitLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            scale = 0.95,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            offsetX = 0,
            offsetY = -15,
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL),
            justifyOptions = { type = "H", align = "RIGHT" }
        })
        queueTab.content.totalAverageProfit = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalAverageProfitLabel.frame,
            scale = 1,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = CraftSim.UTIL:FormatMoney(0, true),
            justifyOptions = { type = "H", align = "LEFT" }
        })
        queueTab.content.totalCraftingCostsLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalAverageProfitLabel.frame,
            scale = 0.95,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            offsetY = -19,
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL),
            justifyOptions = { type = "H", align = "RIGHT" }
        })
        queueTab.content.totalCraftingCosts = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalCraftingCostsLabel.frame,
            scale = 1,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = CraftSim.UTIL:FormatMoney(0, true),
            justifyOptions = { type = "H", align = "RIGHT" }
        })

        queueTab.content.editRecipeFrame = CraftSim.CRAFTQ.UI:InitEditRecipeFrame(queueTab.content, frame.content)
    end

    createContent(CraftSim.CRAFTQ.frame)

    -- add to queue button in crafting ui
    CraftSim.CRAFTQ.queueRecipeButton = GGUI.Button {
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorPoints = { {
            anchorParent = ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckbox,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -18, offsetY = -19,
        } },
        adjustWidth = true,
        sizeX = 15,
        label = "+ CraftQueue",
        tooltipOptions = {
            anchor = "ANCHOR_CURSOR_RIGHT",
            text = CreateAtlasMarkup("NPE_LeftClick", 20, 20, 2) .. " + Shift to " .. f.g("optimize") .. " recipe before adding it to the queue",
        },
        clickCallback = function(_, _)
            CraftSim.CRAFTQ:QueueOpenRecipe()
        end,
    }

    CraftSim.CRAFTQ.queueRecipeButtonOptions = GGUI.Button {
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorPoints = { {
            anchorParent = CraftSim.CRAFTQ.queueRecipeButton.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        sizeX = 20, sizeY = 20,
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        cleanTemplate = true,
        clickCallback = function(_, _)
            CraftSim.CRAFTQ:ShowQueueOpenRecipeOptions()
        end
    }

    -- add to queue button in crafting ui for work orders
    CraftSim.CRAFTQ.queueRecipeButtonWO = GGUI.Button {
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorPoints = { {
            anchorParent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.TrackRecipeCheckbox,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -15,
        } },
        adjustWidth = true,
        sizeX = 15,
        label = "+ CraftQueue",
        clickCallback = function(_, _)
            CraftSim.CRAFTQ:QueueOpenRecipe()
        end,
    }

    CraftSim.CRAFTQ.queueRecipeButtonOptionsWO = GGUI.Button {
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorPoints = { {
            anchorParent = CraftSim.CRAFTQ.queueRecipeButtonWO.frame,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        } },
        sizeX = 20, sizeY = 20,
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS,
        cleanTemplate = true,
        clickCallback = function(_, _)
            CraftSim.CRAFTQ:ShowQueueOpenRecipeOptions()
        end
    }

    CraftSim.CRAFTQ.frame:HookScript("OnShow", function()
        RunNextFrame(function()
            if CraftSim.CRAFTQ.frame:IsVisible() then
                CraftSim.CRAFTQ.UI:UpdateDisplay()
            end
        end)
    end)
end

---@param frame GGUI.Frame
function CraftSim.CRAFTQ.UI:InitializeQuickAccessBar(frame)
    local content = frame.content

    content.quickBarFrame = GGUI.Frame {
        parent = content, anchorParent = content,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = -1, offsetX = 10,
        sizeX = 200, sizeY = 70,
    }

    local quickBarFrameButtonSize = 30
    content.quickBarFrame.buttonList = GGUI.FrameList {
        parent = content.quickBarFrame.frame, anchorParent = content.quickBarFrame.frame,
        horizontal = true, offsetY = 0,
        rowHeight = 35,
        hideScrollbar = true,
        sizeY = 50,
        autoAdjustHeight = true,
        columnOptions = {
            {
                width = 30, -- icon
            },
        },
        anchorA = "LEFT", anchorB = "LEFT",
        rowConstructor = function (columns, row)
            local buttonColumn = columns[1]
            buttonColumn.macroButton = GGUI.Button {
                    parent = buttonColumn, anchorParent = buttonColumn, sizeX = quickBarFrameButtonSize, sizeY = quickBarFrameButtonSize, anchorA = "CENTER",
                    anchorB = "CENTER",
                    macro = true,
                    macroText = "",
                    tooltipOptions = {
                        anchor = "ANCHOR_TOP",
                        text = "",
                    },
                    fontOptions = {
                        fontFile = CraftSim.CONST.FONT_FILES.ROBOTO,
                        scale = 3,
                        flags = "THICKOUTLINE",
                    },
                    borderOptions = {
                        colorRGBA = {1, 1, 1, 1},
                        borderSize = 10,
                        showBorder = false,
                    },
                }
            buttonColumn.recipeCraftButton = GGUI.Button {
                    parent = buttonColumn, anchorParent = buttonColumn, sizeX = quickBarFrameButtonSize, sizeY = quickBarFrameButtonSize, anchorA = "CENTER",
                    anchorB = "CENTER",
                    tooltipOptions = {
                        anchor = "ANCHOR_TOP",
                        text = "",
                    },
                    fontOptions = {
                        fontFile = CraftSim.CONST.FONT_FILES.ROBOTO,
                        scale = 3,
                        flags = "THICKOUTLINE",
                    },
                    borderOptions = {
                        colorRGBA = {1, 1, 1, 1},
                        borderSize = 10,
                        showBorder = false,
                    },
                }
        end,
    }
end

---@param parent frame
---@param anchorParent Region
---@return CraftSim.CRAFTQ.EditRecipeFrame editRecipeFrame
function CraftSim.CRAFTQ.UI:InitEditRecipeFrame(parent, anchorParent)
    local editFrameX = 600
    local editFrameY = 350
    ---@class CraftSim.CRAFTQ.EditRecipeFrame : GGUI.Frame
    local editRecipeFrame = GGUI.Frame {
        parent = parent, anchorParent = anchorParent,
        sizeX = editFrameX, sizeY = editFrameY, backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE, frameTable = CraftSim.INIT.FRAMES,
        title = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE),
        frameStrata = "DIALOG", closeable = true, closeOnClickOutside = true, moveable = true, frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
    }

    ---@type CraftSim.CraftQueueItem?
    editRecipeFrame.craftQueueItem = nil

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.title.frame, anchorA = "TOP", anchorB = "BOTTOM",
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL), scale = 1.5, offsetY = -10,
    }

    -- required reagent frames (only for quality reagents as the non quality ones are fixed anyway)
    local qIconSize = 15
    local qButtonSize = 20 -- kept for layout reference
    local qButtonSpacingX = 25
    local qButtonBaseOffsetX = 50
    local qButtonBaseOffsetY = -70

    -- required quality reagents list (FrameList-based, shared with SimulationMode)
    local reagentAnchorPoints = {
        {
            anchorParent = editRecipeFrame.content,
            offsetX = qButtonBaseOffsetX,
            offsetY = qButtonBaseOffsetY - 30,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
        },
    }

    local function setAllReagentsByQuality(qualityID)
        if not editRecipeFrame.craftQueueItem or not editRecipeFrame.craftQueueItem.recipeData then
            return
        end

        local recipeData = editRecipeFrame.craftQueueItem.recipeData
        if recipeData:IsSimplifiedQualityRecipe() and qualityID == 3 then
            return
        end

        recipeData.reagentData:SetReagentsMaxByQuality(qualityID)
        recipeData:Update()
        CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
        CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
    end

    local function onReagentQuantityChanged(row, columns, qualityIndex)
        if not editRecipeFrame.craftQueueItem or not editRecipeFrame.craftQueueItem.recipeData then
            return
        end

        local recipeData = editRecipeFrame.craftQueueItem.recipeData
        local reagent = row.reagent --[[@as CraftSim.Reagent?]]
        if not reagent then
            return
        end

        local simplified = recipeData:IsSimplifiedQualityRecipe()
        local requiredQuantity = reagent.requiredQuantity

        local qInputs = {}
        qInputs[1] = columns[2].input --[[@as GGUI.NumericInput]]
        qInputs[2] = columns[3].input --[[@as GGUI.NumericInput]]
        local maxIndex = 2
        if not simplified then
            qInputs[3] = columns[4].input --[[@as GGUI.NumericInput]]
            maxIndex = 3
        end

        local function getTotal()
            local total = 0
            for i = 1, maxIndex do
                local input = qInputs[i]
                total = total + (tonumber(input.currentValue) or 0)
            end
            return total
        end

        local total = getTotal()
        if total > requiredQuantity then
            local diff = total - requiredQuantity
            local changedInput = qInputs[qualityIndex]
            local newQuantity = math.max((tonumber(changedInput.currentValue) or 0) - diff, 0)
            changedInput.textInput:SetText(newQuantity)
            changedInput.currentValue = newQuantity
        end

        total = getTotal()

        local requiredText = (simplified and columns[4].text) or columns[5].text --[[@as GGUI.Text]]

        if total == requiredQuantity then
            requiredText:SetColor(GUTIL.COLORS.WHITE)

            -- propagate into reagent items
            reagent.items[1].quantity = qInputs[1].currentValue
            reagent.items[2].quantity = qInputs[2].currentValue
            if not simplified and qInputs[3] then
                reagent.items[3].quantity = qInputs[3].currentValue
            elseif reagent.items[3] then
                reagent.items[3].quantity = 0
            end

            recipeData:Update()
            CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
        else
            requiredText:SetColor(GUTIL.COLORS.RED)
        end
    end

    editRecipeFrame.content.reagentList = CraftSim.WIDGETS.ReagentList {
        parent = editRecipeFrame.content,
        anchorPoints = reagentAnchorPoints,
        onHeaderClick = setAllReagentsByQuality,
        onQuantityChanged = onReagentQuantityChanged,
    }

    local oRFrameX = 100
    local oRFrameY = 65
    local optionalReagentsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    optionalReagentsFrame:SetPoint("TOPLEFT", editRecipeFrame.content.reagentList.frame, "TOPRIGHT", 0, 20)

    optionalReagentsFrame.collapse = function()
        optionalReagentsFrame:SetSize(oRFrameX, 0.1)
    end
    optionalReagentsFrame.decollapse = function()
        optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    end
    optionalReagentsFrame.SetCollapsed = function(self, collapse)
        if collapse then
            optionalReagentsFrame.collapse()
        else
            optionalReagentsFrame.decollapse()
        end
    end

    editRecipeFrame.content.optionalReagentsFrame = optionalReagentsFrame

    -- optional reagent slots
    editRecipeFrame.content.optionalReagentsTitle = GGUI.Text {
        parent = optionalReagentsFrame, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL), justifyOptions = { type = "H", align = "LEFT" }
    }
    ---@class CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector : GGUI.ItemSelector
    ---@field slot CraftSim.OptionalReagentSlot?

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.optionalReagentSelectors = {}
    local itemSelectorSizeX = 25
    local itemSelectorSizeY = 25
    local itemSelectorBaseOffsetX = 0
    local itemSelectorBaseOffsetY = -10
    local itemSelectorSpacingX = itemSelectorSizeX + 5
    local function CreateItemSelector(parent, anchorParent, saveTable, onSelectCallback, anchorA, anchorB, offsetX,
                                      offsetY)
        local numSelectors = #saveTable
        table.insert(saveTable, GGUI.ItemSelector {
            parent = parent, anchorParent = anchorParent, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
            offsetX = itemSelectorBaseOffsetX + itemSelectorSpacingX * numSelectors,
            offsetY = itemSelectorBaseOffsetY,
            sizeX = itemSelectorSizeX, sizeY = itemSelectorSizeY, selectionFrameOptions = {
            backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            title = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL), anchorA = anchorA, anchorB = anchorB, offsetX = offsetX, offsetY = offsetY
        },
            emptyIcon = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD, isAtlas = true, onSelectCallback = onSelectCallback
        })
    end

    ---@param itemSelector CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector
    ---@param selectedItem ItemMixin?
    ---@param selectedCurrencyID number?
    local function OnSelectOptionalReagent(itemSelector, selectedItem, selectedCurrencyID)
        if itemSelector and itemSelector.slot then
            if selectedCurrencyID then
                itemSelector.slot:SetCurrencyReagent(selectedCurrencyID)
            elseif not selectedItem and itemSelector.slot:IsCurrency() then
                itemSelector.slot:SetCurrencyReagent(nil)
            else
                print("setting reagent: " .. tostring(selectedItem and selectedItem:GetItemLink()))
                itemSelector.slot:SetReagent((selectedItem and selectedItem:GetItemID()) or nil)
            end
            editRecipeFrame.craftQueueItem.recipeData:Update()
            CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
        end
    end

    local numOptionalReagentSelectors = 3
    for _ = 1, numOptionalReagentSelectors do
        CreateItemSelector(optionalReagentsFrame, editRecipeFrame.content.optionalReagentsTitle.frame,
            editRecipeFrame.content.optionalReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.finishingReagentsTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL), justifyOptions = { type = "H", align = "LEFT" }
    }

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.finishingReagentSelectors = {}
    local numFinishingReagentSelectors = 3
    for _ = 1, numFinishingReagentSelectors do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.finishingReagentsTitle.frame,
            editRecipeFrame.content.finishingReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.requiredSelectableReagentTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -65,
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_SPARK_LABEL), justifyOptions = { type = "H", align = "LEFT" }
    }


    ---@type CraftSim.CRAFTQ.EditRecipeFrame.OptionalReagentSelector[]
    editRecipeFrame.content.requiredSelectableReagentSelectors = {}
    CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.requiredSelectableReagentTitle.frame,
        editRecipeFrame.content.requiredSelectableReagentSelectors, OnSelectOptionalReagent)

    editRecipeFrame.content.professionGearTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optionalReagentsTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 20,
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL), justifyOptions = { type = "H", align = "LEFT" }
    }

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector : GGUI.ItemSelector
    ---@field professionGear CraftSim.ProfessionGear?

    ---@type CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector[]
    editRecipeFrame.content.professionGearSelectors = {}

    ---@param itemSelector CraftSim.CRAFTQ.EditRecipeFrame.ProfessionGearSelector
    ---@param item ItemMixin?
    local function OnSelectProfessionGear(itemSelector, item)
        print("on select professiongear: " .. tostring(item and item:GetItemLink()))
        if itemSelector and itemSelector.professionGear then
            if item then
                print("setting gear: " .. tostring(item:GetItemLink()))
                item:ContinueOnItemLoad(function()
                    itemSelector.professionGear:SetItem(item:GetItemLink())
                    editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                    editRecipeFrame.craftQueueItem.recipeData:Update()
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
                end)
            else
                print("setting gear to no gear")
                itemSelector.professionGear:SetItem(nil)
                editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    end

    for _ = 1, 3 do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.professionGearTitle.frame,
            editRecipeFrame.content.professionGearSelectors, OnSelectProfessionGear, "TOPRIGHT", "TOPLEFT", 0, -25)
    end

    editRecipeFrame.content.optimizeProfitButton = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.professionGearTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -50,
        label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON), sizeX = 150,
        clickCallback = function(optimizeButton)
            -- TODO: Refactor using RecipeData:Optimize
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                local recipeData = editRecipeFrame.craftQueueItem.recipeData
                local optimizeProfessionGear = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_PROFESSION_GEAR")
                local optimizeConcentration = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_CONCENTRATION")
                local optimizeFinishingReagents = CraftSim.DB.OPTIONS:Get(
                    "CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS")

                -- Never consider locked finishing slots in Craft Queue, but ALWAYS include soulbound
                -- when optimizing via Craft Queue.
                local includeLockedFinishing = false
                local includeSoulboundFinishing = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                local queueAmount = editRecipeFrame.craftQueueItem.amount or 1

                local function finalizeOptimize()
                    if includeSoulboundFinishing then
                        -- Ensure selected soulbound finishing reagents can cover the queued amount.
                        recipeData:AdjustSoulboundFinishingForAmount(queueAmount)
                    end
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
                    optimizeButton:SetEnabled(true)
                    optimizeButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON))
                end

                if optimizeProfessionGear then
                    recipeData:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
                end

                RunNextFrame(function()
                    recipeData:OptimizeReagents {
                        highestProfit = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY"),
                    }

                    if recipeData.supportsQualities and optimizeConcentration then
                        optimizeButton:SetEnabled(false)
                        recipeData:OptimizeConcentration {
                            finally = function()
                                if optimizeFinishingReagents then
                                    recipeData:OptimizeFinishingReagents {
                                        includeLocked = includeLockedFinishing,
                                        includeSoulbound = includeSoulboundFinishing,
                                        finally = function()
                                            finalizeOptimize()
                                        end,
                                        progressUpdateCallback = function(progress)
                                            optimizeButton:SetText(string.format("FIN: %.0f%%", progress))
                                        end
                                    }
                                else
                                    finalizeOptimize()
                                end
                            end,
                            progressUpdateCallback = function(progress)
                                optimizeButton:SetText(string.format("CON: %.0f%%", progress))
                            end
                        }
                    else
                        if optimizeFinishingReagents then
                            optimizeButton:SetEnabled(false)
                            recipeData:OptimizeFinishingReagents {
                                includeLocked = includeLockedFinishing,
                                includeSoulbound = includeSoulboundFinishing,
                                finally = function()
                                    finalizeOptimize()
                                end,
                                progressUpdateCallback = function(progress)
                                    optimizeButton:SetText(string.format("FIN: %.0f%%", progress))
                                end
                            }
                        else
                            finalizeOptimize()
                        end
                    end
                end)
            end
        end
    }

    editRecipeFrame.content.optimizeProfitButtonOptions = GGUI.Button {
        parent = editRecipeFrame.content, anchorPoints = { { anchorParent = editRecipeFrame.content.optimizeProfitButton.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5 } },
        buttonTextureOptions = CraftSim.CONST.BUTTON_TEXTURE_OPTIONS.OPTIONS, sizeX = 20, sizeY = 20,
        cleanTemplate = true,
        clickCallback = function(_, _)
            MenuUtil.CreateContextMenu(UIParent, function(ownerRegion, rootDescription)
                local recipeData = editRecipeFrame.craftQueueItem.recipeData
                if recipeData.supportsQualities then
                    rootDescription:CreateCheckbox(
                        "Optimize " .. f.g("Top Profit Quality"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_TOP_PROFIT_QUALITY", not value)
                        end)
                end
                rootDescription:CreateCheckbox(
                    "Optimize " .. f.bb("Profession Gear"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_PROFESSION_GEAR")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_PROFESSION_GEAR")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_PROFESSION_GEAR", not value)
                    end)
                if recipeData.supportsQualities then
                    rootDescription:CreateCheckbox(
                        "Optimize " .. f.gold("Concentration"),
                        function()
                            return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_CONCENTRATION")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_CONCENTRATION")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_CONCENTRATION", not value)
                        end)
                end
                rootDescription:CreateCheckbox(
                    "Optimize " .. f.bb("Finishing Reagents"),
                    function()
                        return CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS")
                    end, function()
                        local value = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS")
                        CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS", not value)
                    end)

                local includeSoulboundFRDB = rootDescription:CreateCheckbox(
                        "Include " .. f.e("Soulbound") .. f.bb(" Finishing Reagents"),
                        function()
                            return CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                        end, function()
                            local value = CraftSim.DB.OPTIONS:Get(
                                "CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS_INCLUDE_SOULBOUND")
                            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_EDIT_RECIPE_OPTIMIZE_FINISHING_REAGENTS_INCLUDE_SOULBOUND",
                                not value)
                        end)

                    includeSoulboundFRDB:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_AddInstructionLine(tooltip,
                            "If enabled, CraftSim will suggest soulbound finishing reagents during optimization");
                    end);
            end)
        end
    }

    editRecipeFrame.content.resultTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optimizeProfitButton.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -40, text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL),
    }

    editRecipeFrame.content.concentrationCB = GGUI.Checkbox {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "BOTTOMLEFT", anchorB = "TOPLEFT",
        offsetY = 5, scale = 2,
        labelOptions = {
            text = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) .. L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX)
        },
        clickCallback = function(_, checked)
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.concentrating = checked
                editRecipeFrame.craftQueueItem.concentrating = checked
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    do
        local cbFrame = editRecipeFrame.content.concentrationCB.frame
        cbFrame:SetScript("OnEnter", function()
            local frame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
            local craftQueueItem = frame.craftQueueItem
            if not craftQueueItem or not craftQueueItem.recipeData or not craftQueueItem.recipeData.supportsQualities then return end
            local recipeData = craftQueueItem.recipeData
            local concentrationData = recipeData.concentrationData
            local cost = recipeData.concentrationCost
            if not concentrationData or not cost or cost <= 0 then return end
            if recipeData:IsCrafter() then
                concentrationData:Update()
            end
            local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
            local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
            if concentrationData:GetCurrentAmount() < cost then
                local estimatedText = concentrationData:GetEstimatedTimeUntilEnoughText(cost, useUSFormat)
                if estimatedText then
                    GameTooltip:SetOwner(cbFrame, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetText(estimatedText)
                    GameTooltip:Show()
                end
            end
        end)
        cbFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    editRecipeFrame.content.resultList = GGUI.FrameList {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        hideScrollbar = true, offsetX = -10, sizeY = 100, rowHeight = 30,
        columnOptions = {
            {
                width = 40, -- icon
            },
        },
        rowConstructor = function(columns, row)
            local iconColumn = columns[1]

            ---@type QualityID
            row.qualityID = nil

            iconColumn.icon = GGUI.Icon {
                parent = iconColumn, anchorParent = iconColumn, sizeX = 30, sizeY = 30, anchorA = "LEFT", anchorB = "LEFT", offsetX = 3,
            }
        end
    }

    -- bottom stats block (4 rows, 2 columns), centered near the bottom of the window
    editRecipeFrame.content.statsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    editRecipeFrame.content.statsFrame:SetSize(320, 80)
    -- center horizontally on the whole content frame, with a fixed vertical offset from the bottom
    editRecipeFrame.content.statsFrame:SetPoint("BOTTOM", editRecipeFrame.content, "BOTTOM", 0, 5)
    local statsFrame = editRecipeFrame.content.statsFrame

    editRecipeFrame.content.craftingCostsTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = statsFrame,
        anchorA = "TOPLEFT", anchorB = "TOPLEFT",
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL),
    }
    editRecipeFrame.content.craftingCostsValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.craftingCostsTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.averageProfitTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.craftingCostsTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL),
    }
    editRecipeFrame.content.averageProfitValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.averageProfitTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.concentrationValueTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.averageProfitTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = "Concentration Value:",
    }
    editRecipeFrame.content.concentrationValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationValueTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = CraftSim.UTIL:FormatMoney(0, true),
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }
    editRecipeFrame.content.concentrationDateTitle = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationValueTitle.frame,
        anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -7,
        justifyOptions = { type = "H", align = "RIGHT" },
        fixedWidth = 150,
        text = string.gsub(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONCENTRATION_ESTIMATED_TIME_UNTIL), " %%s", ""),
    }
    editRecipeFrame.content.concentrationDateValue = GGUI.Text {
        parent = statsFrame,
        anchorParent = editRecipeFrame.content.concentrationDateTitle.frame,
        anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 5, offsetY = 1,
        text = "",
        justifyOptions = { type = "H", align = "LEFT" },
        scale = 0.9,
    }

    editRecipeFrame:Hide()
    return editRecipeFrame
end

function CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
    -- multiples should be possible (different reagent setup)
    -- but if there already is a configuration just increase the count?

    print("CraftQueue Update List", false, true)

    CraftSim.DEBUG:StartProfiling("FrameListUpdate")

    local queueTab = CraftSim.CRAFTQ.frame.content.queueTab --[[@as GGUI.BlizzardTab]]
    local craftList = queueTab.content.craftList --[[@as GGUI.FrameList]]

    local craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    craftQueue:UpdateSubRecipes()
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        craftQueueItem:CalculateCanCraft()
    end

    CraftSim.DEBUG:StartProfiling("- FrameListUpdate Sort Queue")
    craftQueue:FilterSortByPriority()
    CraftSim.DEBUG:StopProfiling("- FrameListUpdate Sort Queue")

    craftList:Remove()

    CraftSim.DEBUG:StartProfiling("- FrameListUpdate Add Rows")
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        craftList:Add(
            function(row)
                self:UpdateCraftQueueRowByCraftQueueItem(row, craftQueueItem)
            end)
    end

    CraftSim.DEBUG:StopProfiling("- FrameListUpdate Add Rows")

    --- sort by craftable status
    craftList:UpdateDisplay()

    self:UpdateCraftQueueTotalProfitDisplay()

    craftQueue:CacheQueueItems()


    CraftSim.DEBUG:StopProfiling("FrameListUpdate")
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTQ.UI:UpdateAddOpenRecipeButton(recipeData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local button = CraftSim.CRAFTQ.queueRecipeButton
    local buttonOptions = CraftSim.CRAFTQ.queueRecipeButtonOptions
    local buttonWO = CraftSim.CRAFTQ.queueRecipeButtonWO
    local buttonOptionsWO = CraftSim.CRAFTQ.queueRecipeButtonOptionsWO

    local isTradeSkillAllowed = not CraftSim.CONST.GATHERING_PROFESSIONS
        [recipeData.professionData.professionInfo.profession] and not C_TradeSkillUI.IsTradeSkillGuild() and
        not C_TradeSkillUI.IsTradeSkillLinked() and not C_TradeSkillUI.IsNPCCrafting() and
        not C_TradeSkillUI.IsRuneforging()

    local isRecipeAllowed = not recipeData.isSalvageRecipe and not recipeData.isRecraft and not recipeData
        .isBaseRecraftRecipe

    -- reset state if changed by anything
    button:SetEnabled(true)
    button:SetText("+ CraftQueue")
    buttonWO:SetEnabled(true)
    buttonWO:SetText("+ CraftQueue")

    button:SetVisible(isTradeSkillAllowed and isRecipeAllowed and exportMode == CraftSim.CONST.EXPORT_MODE
        .NON_WORK_ORDER)
    buttonOptions:SetVisible(isTradeSkillAllowed and isRecipeAllowed and exportMode == CraftSim.CONST.EXPORT_MODE
        .NON_WORK_ORDER)
    buttonWO:SetVisible(isTradeSkillAllowed and isRecipeAllowed and exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
    buttonOptionsWO:SetVisible(isTradeSkillAllowed and isRecipeAllowed and
        exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER)
end

function CraftSim.CRAFTQ.UI:UpdateQuickAccessBarDisplay()
    local quickBar = CraftSim.CRAFTQ.frame.content.quickBarFrame --[[@as GGUI.Frame]]
    local buttonList = quickBar.buttonList --[[@as GGUI.FrameList]]

    buttonList:Remove()
    -- add soulbound upcraft reagents first, then add shatter spell
    for upcraftReagent, data in pairs(CraftSim.CONST.SOULBOUND_UPCRAFT_REAGENTS_DATA) do
        local reagentItem = Item:CreateFromItemID(data.preItemID)
        reagentItem:ContinueOnItemLoad(function()
            buttonList:Add(function(row)
                local macroButton = row.columns[1].macroButton --[[@as GGUI.Button]]
                local recipeCraftButton = row.columns[1].recipeCraftButton --[[@as GGUI.Button]]
                macroButton:Show()
                recipeCraftButton:Hide()
                macroButton:SetMacroText("/use item:" .. data.preItemID)
                macroButton:SetTexture{
                    normal = reagentItem:GetItemIcon(),
                    pushed = reagentItem:GetItemIcon(),
                    highlight = reagentItem:GetItemIcon(),
                    highlightBlendmode = "ADD",
                }
                local itemCountPre = C_Item.GetItemCount(data.preItemID)
                macroButton:SetText(f.white("x" .. itemCountPre))

                if itemCountPre >= 5 then
                    macroButton:SetBorder(true, {0, 1, 0, 0.8})
                else
                    macroButton:SetBorder(true, {1, 0, 0, 0.8})
                end

                local items = { Item:CreateFromItemID(data.preItemID), Item:CreateFromItemID(upcraftReagent) }

                GUTIL:ContinueOnAllItemsLoaded(items, function()
                        local preItemLink = items[1]:GetItemLink()
                        local upcraftItemLink = items[2]:GetItemLink()
                        local missingDiff = 5 - itemCountPre
                        local missingText = itemCountPre >= 5 and "" or f.r("\nMissing " .. missingDiff .. "x " .. preItemLink)
                        macroButton.tooltipOptions = {
                            anchor = "ANCHOR_CURSOR_RIGHT",
                            text = f.bb("Convert 5x ") .. preItemLink .. "  -> " .. upcraftItemLink .. missingText
                        }
                    end)
            end)
        end)
    end

    -- if the current profession is midnight enchanting add shatter
    local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
    local midnightEnchantingID = CraftSim.CONST.TRADESKILLLINEIDS[Enum.Profession.Enchanting][CraftSim.CONST.EXPANSION_IDS.MIDNIGHT]
    if skillLineID == midnightEnchantingID then
        buttonList:Add(function(row)
            local recipeCraftButton = row.columns[1].recipeCraftButton --[[@as GGUI.Button]]
            local macroButton = row.columns[1].macroButton --[[@as GGUI.Button]]
            macroButton:Hide()
            recipeCraftButton:Show()

            local recipeData = CraftSim.RecipeData{recipeID = CraftSim.CONST.QUICK_ACCESS_RECIPE_IDS.MIDNIGHT_ENCHANTING_SHATTER}
            if recipeData then
                recipeCraftButton:SetTexture{
                    normal = recipeData.recipeIcon,
                    pushed = recipeData.recipeIcon,
                    highlight = recipeData.recipeIcon,
                    highlightBlendmode = "ADD",
                }

                local activeReagent = recipeData.reagentData.salvageReagentSlot:SetCheapestItem()
                recipeData:Update()
                local buffActive = recipeData.buffData:IsBuffActive(CraftSim.CONST.BUFF_IDS.SHATTERING_ESSENCE_MIDNIGHT)

                activeReagent:ContinueOnItemLoad(function()

                    if buffActive then
                        recipeCraftButton.tooltipOptions = {
                            anchor = "ANCHOR_CURSOR_RIGHT",
                            text = f.bb("Shatter Buff " .. f.g("active"))
                        }
                        recipeCraftButton:SetBorder(true, {1, 0, 0, 0.8})    
                    elseif recipeData:CanCraft(1) then
                            recipeCraftButton.tooltipOptions = {
                                anchor = "ANCHOR_CURSOR_RIGHT",
                                text = f.bb("Shatter " .. activeReagent:GetItemLink()) .. "\nCosts: " .. CraftSim.UTIL:FormatMoney(recipeData.priceData.craftingCosts, true) 
                            }
                             recipeCraftButton:SetBorder(true, {0, 1, 0, 0.8})
                        else
                            recipeCraftButton.tooltipOptions = {
                                anchor = "ANCHOR_CURSOR_RIGHT",
                                text = f.bb("Shatter " .. activeReagent:GetItemLink()) .. f.r(" (Missing)") .. "\nCosts: " .. CraftSim.UTIL:FormatMoney(recipeData.priceData.craftingCosts, true) 
                            }
                            recipeCraftButton:SetBorder(true, {1, 0, 0, 0.8})
                        end
                    end)
            end

            recipeCraftButton.clickCallback = function()
                if recipeData:CanCraft(1) then
                    recipeData:Craft()
                else
                    local activeReagent = recipeData.reagentData.salvageReagentSlot.activeItem
                    if activeReagent then
                        CraftSim.DEBUG:SystemPrint(f.l("CraftSim: " .. "Missing Shatter Reagent: " .. activeReagent:GetItemLink()))
                    end
                end
            end
        end)
    end

    buttonList:UpdateDisplay()
end

function CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
    --- use a cache to prevent multiple redundant calls of ItemCount thus increasing performance
    CraftSim.CRAFTQ.itemCountCache = {}

    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    local queueTab = craftQueueFrame.content.queueTab --[[@as CraftSim.CraftQueue.QueueTab]]

    --- update craft next button
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    if itemsPresent then
        -- set the craft next button to the same status as the button in the queue on pos 1
        -- if first item can be crafted (so if anything can be crafted cause the items are sorted by craftable status)
        local firstRow = queueTab.content.craftList.activeRows[1]
        local craftButton = firstRow.columns[11].craftButton --[[@as GGUI.Button]]
        local button = craftButton.frame --[[@as Button]]
        queueTab.content.craftNextButton:SetEnabled(button:IsEnabled())
        queueTab.content.craftNextButton.clickCallback = craftButton.clickCallback
        queueTab.content.craftNextButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NEXT) .. button:GetText(), 10,
            true)
    else
        queueTab.content.craftNextButton:SetEnabled(false)
        queueTab.content.craftNextButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NOTHING_QUEUED), 10, true)
    end

    if queueTab.content.createAuctionatorShoppingList then
        queueTab.content.createAuctionatorShoppingList:SetEnabled(CraftSim.CRAFTQ.craftQueue and
            #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0)
    end

    --- disable cache
    CraftSim.CRAFTQ.itemCountCache = nil
end

function CraftSim.CRAFTQ.UI:UpdateCraftQueueTotalProfitDisplay()
    local queueTab = CraftSim.CRAFTQ.frame.content.queueTab --[[@as GGUI.BlizzardTab]]
    local craftList = queueTab.content.craftList --[[@as GGUI.FrameList]]

    local totalAverageProfit = 0
    local totalCraftingCosts = 0

    for _, row in ipairs(craftList.activeRows) do
        local craftQueueItem = row.craftQueueItem --[[@as CraftSim.CraftQueueItem]]
        -- do not count subrecipes in the total profit or crafting costs
        if not craftQueueItem.recipeData:IsSubRecipe() then
            totalAverageProfit = totalAverageProfit + row.averageProfit
            totalCraftingCosts = totalCraftingCosts + row.craftingCosts
        end
    end

    queueTab.content.totalAverageProfit:SetText(CraftSim.UTIL:FormatMoney(totalAverageProfit, true, totalCraftingCosts))
    queueTab.content.totalCraftingCosts:SetText(f.r(CraftSim.UTIL:FormatMoney(totalCraftingCosts)))
end

function CraftSim.CRAFTQ.UI:UpdateDisplay()
    CraftSim.CRAFTQ.UI:UpdateQuickAccessBarDisplay()
    CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
end

---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(craftQueueItem)
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
    local recipeData = craftQueueItem.recipeData
    recipeData.reagentData:RefreshSlotStatus()
    craftQueueItem:CalculateCanCraft()
    editRecipeFrame.craftQueueItem = craftQueueItem
    ---@type CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName:SetText(GUTIL:IconToText(recipeData.recipeIcon, 15, 15) ..
        " " .. recipeData.recipeName)
    editRecipeFrame.content.averageProfitValue:SetText(CraftSim.UTIL:FormatMoney(recipeData.averageProfitCached, true,
        recipeData.priceData.craftingCosts))
    local concentrationCostText = ""
    if editRecipeFrame.craftQueueItem.concentrating then
        concentrationCostText = " + " ..
            GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 15, 15) ..
            " " .. f.gold(editRecipeFrame.craftQueueItem.recipeData.concentrationCost)
    end

    local craftingCosts
    if recipeData.orderData then
        craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents
    else
        craftingCosts = recipeData.priceData.craftingCosts
    end
    editRecipeFrame.content.craftingCostsValue:SetText(GUTIL:ColorizeText(
        CraftSim.UTIL:FormatMoney(craftingCosts), GUTIL.COLORS.RED) .. concentrationCostText)
    local concentrationValue = recipeData:GetConcentrationValue()
    editRecipeFrame.content.concentrationValue:SetText(CraftSim.UTIL:FormatMoney(concentrationValue, true))
    if recipeData.supportsQualities and recipeData.concentrationData and recipeData.concentrationCost > 0 then
        local concentrationData = recipeData.concentrationData
        if craftQueueItem.isCrafter then
            concentrationData:Update()
        end
        local requiredAmount = recipeData.concentrationCost * craftQueueItem.amount
        local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
        local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
        if concentrationData:GetCurrentAmount() < requiredAmount then
            editRecipeFrame.content.concentrationDateTitle:SetVisible(true)
            editRecipeFrame.content.concentrationDateValue:SetText(f.bb(concentrationData:GetFormattedDateUntil(requiredAmount, useUSFormat)))
            editRecipeFrame.content.concentrationDateValue:SetVisible(true)
        else
            editRecipeFrame.content.concentrationDateTitle:SetVisible(true)
            editRecipeFrame.content.concentrationDateValue:SetText(f.g("Ready"))
            editRecipeFrame.content.concentrationDateValue:SetVisible(true)
        end
    else
        editRecipeFrame.content.concentrationDateTitle:SetVisible(false)
        editRecipeFrame.content.concentrationDateValue:SetVisible(false)
    end

    -- required quality reagents
    if recipeData.hasQualityReagents then
        editRecipeFrame.content.reagentList:Populate(recipeData)
    else
        editRecipeFrame.content.reagentList:Hide()
    end

    -- optionals
    local optionalSelectors = editRecipeFrame.content.optionalReagentSelectors
    editRecipeFrame.content.optionalReagentsFrame:SetCollapsed(#recipeData.reagentData.optionalReagentSlots == 0)
    editRecipeFrame.content.optionalReagentsTitle:SetVisible(#recipeData.reagentData.optionalReagentSlots > 0)
    for selectorIndex, selector in pairs(optionalSelectors) do
        local optionalSlot = recipeData.reagentData.optionalReagentSlots[selectorIndex]
        if optionalSlot then
            selector.slot = optionalSlot
            selector:SetItems(optionalSlot:GetItemSelectorEntries())
            if optionalSlot.activeReagent then
                if optionalSlot.activeReagent:IsCurrency() then
                    selector:SetSelectedCurrency(optionalSlot.activeReagent.currencyID, optionalSlot.activeReagent.qualityID)
                else
                    selector:SetSelectedItem(optionalSlot.activeReagent.item)
                end
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:SetItems({})
            selector:Hide()
        end
    end

    -- finishing
    local finishingSelectors = editRecipeFrame.content.finishingReagentSelectors
    editRecipeFrame.content.finishingReagentsTitle:SetVisible(#recipeData.reagentData.finishingReagentSlots > 0)
    for selectorIndex, selector in pairs(finishingSelectors) do
        local finishingSlot = recipeData.reagentData.finishingReagentSlots[selectorIndex]
        if finishingSlot then
            selector.slot = finishingSlot
            selector:SetItems(finishingSlot:GetItemSelectorEntries())
            if finishingSlot.activeReagent then
                if finishingSlot.activeReagent:IsCurrency() then
                    selector:SetSelectedCurrency(finishingSlot.activeReagent.currencyID, finishingSlot.activeReagent.qualityID)
                else
                    selector:SetSelectedItem(finishingSlot.activeReagent.item)
                end
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:SetItems({})
            selector:Hide()
        end
    end

    -- Required Selectable
    local requiredSelectableReagentSelector = editRecipeFrame.content.requiredSelectableReagentSelectors[1]
    editRecipeFrame.content.requiredSelectableReagentTitle:SetVisible(recipeData.reagentData
        :HasRequiredSelectableReagent())
    local requiredSelectableReagentSlot = recipeData.reagentData.requiredSelectableReagentSlot
    if requiredSelectableReagentSlot then
        requiredSelectableReagentSelector.slot = requiredSelectableReagentSlot
        requiredSelectableReagentSelector:SetItems(requiredSelectableReagentSlot:GetItemSelectorEntries())
        if requiredSelectableReagentSlot.activeReagent then
            if requiredSelectableReagentSlot.activeReagent:IsCurrency() then
                requiredSelectableReagentSelector:SetSelectedCurrency(requiredSelectableReagentSlot.activeReagent.currencyID, requiredSelectableReagentSlot.activeReagent.qualityID)
            else
                requiredSelectableReagentSelector:SetSelectedItem(requiredSelectableReagentSlot.activeReagent.item)
            end
        else
            requiredSelectableReagentSelector:SetSelectedItem(nil)
        end
        requiredSelectableReagentSelector:Show()
    else
        requiredSelectableReagentSelector.slot = nil
        requiredSelectableReagentSelector:SetItems({})
        requiredSelectableReagentSelector:Hide()
    end

    local gearSelectors = editRecipeFrame.content.professionGearSelectors
    local professionGearSet = recipeData.professionGearSet
    -- profession gear  1 - gear 1, 2 - gear 2, 3 - tool
    if not recipeData.isCooking then
        gearSelectors[1]:SetSelectedItem(professionGearSet.gear1.item)
        gearSelectors[1].professionGear = professionGearSet.gear1
        gearSelectors[1]:Show()
        gearSelectors[2]:SetSelectedItem(professionGearSet.gear2.item)
        gearSelectors[2].professionGear = professionGearSet.gear2
        gearSelectors[3]:SetSelectedItem(professionGearSet.tool.item)
        gearSelectors[3].professionGear = professionGearSet.tool

        -- fill the selectors with profession items from the players bag but exclude for each selector all items that are selected
        local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
        local equippedGear = CraftSim.ProfessionGearSet(recipeData)
        equippedGear:LoadCurrentEquippedSet()
        local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(),
            function(gear) return gear and gear.item ~= nil end)
        ---@type CraftSim.ProfessionGear[]
        local allGear = CraftSim.GUTIL:Concat({ inventoryGear, equippedGearList })

        allGear = GUTIL:ToSet(allGear, function(gear)
            local compareLink = gear.item:GetItemLink():gsub("Player.':", "")
            return compareLink
        end)

        local gearSlotItems = GUTIL:Filter(allGear, function(gear)
            local isGearItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType
            if not isGearItem then
                return false
            end

            if gearSelectors[1].professionGear:Equals(gear) or gearSelectors[2].professionGear:Equals(gear) then
                return false
            end
            return true
        end)
        local toolSlotItems = GUTIL:Filter(allGear, function(gear)
            local isToolItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
            if not isToolItem then
                return false
            end

            if gearSelectors[3].professionGear:Equals(gear) then
                return false
            end
            return true
        end)

        gearSelectors[1]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[2]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[3]:SetItems(GUTIL:Map(toolSlotItems, function(g) return g.item end))
    else
        gearSelectors[1]:Hide()
        gearSelectors[1].professionGear = nil
        gearSelectors[2]:SetSelectedItem(professionGearSet.gear2.item)
        gearSelectors[2].professionGear = professionGearSet.gear2
        gearSelectors[3]:SetSelectedItem(professionGearSet.tool.item)
        gearSelectors[3].professionGear = professionGearSet.tool

        -- fill the selectors with profession items from the players bag but exclude for each selector all items that are selected
        local inventoryGear = CraftSim.TOPGEAR:GetProfessionGearFromInventory(recipeData)
        local equippedGear = CraftSim.ProfessionGearSet(recipeData)
        equippedGear:LoadCurrentEquippedSet()
        local equippedGearList = CraftSim.GUTIL:Filter(equippedGear:GetProfessionGearList(),
            function(gear) return gear and gear.item ~= nil end)
        local allGear = CraftSim.GUTIL:Concat({ inventoryGear, equippedGearList })

        local gearSlotItems = GUTIL:Filter(allGear, function(gear)
            local isGearItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionGearType
            if not isGearItem then
                return false
            end

            if gearSelectors[2].professionGear:Equals(gear) then
                return false
            end
            return true
        end)
        local toolSlotItems = GUTIL:Filter(allGear, function(gear)
            local isToolItem = gear.item:GetInventoryType() == Enum.InventoryType.IndexProfessionToolType
            if not isToolItem then
                return false
            end

            if gearSelectors[3].professionGear:Equals(gear) then
                return false
            end
            return true
        end)

        gearSelectors[2]:SetItems(GUTIL:Map(gearSlotItems, function(g) return g.item end))
        gearSelectors[3]:SetItems(GUTIL:Map(toolSlotItems, function(g) return g.item end))
    end

    local resultData = recipeData.resultData

    local resultList = editRecipeFrame.content.resultList --[[@as GGUI.FrameList]]

    resultList:Remove()

    resultList:Add(function(row, columns)
        local iconColumn = columns[1]
        row.qualityID = resultData.expectedQuality --[[@as QualityID]]

        iconColumn.icon:SetItem(resultData.expectedItem)
    end)

    resultList:UpdateDisplay()

    editRecipeFrame.content.concentrationCB:SetVisible(craftQueueItem.recipeData.supportsQualities)

    editRecipeFrame.content.concentrationCB:SetChecked(craftQueueItem.concentrating)
end

---@param row GGUI.FrameList.Row
---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.UI:UpdateCraftQueueRowByCraftQueueItem(row, craftQueueItem)
    local recipeData = craftQueueItem.recipeData
    local profilingID = "- FrameListUpdate Add Recipe: " .. craftQueueItem.recipeData.recipeName
    CraftSim.DEBUG:StartProfiling(profilingID)
    local columns = row.columns
    local crafterColumn = columns[1] --[[@as CraftSim.CraftQueue.CraftList.CrafterColumn]]
    local recipeColumn = columns[2] --[[@as CraftSim.CraftQueue.CraftList.RecipeColumn]]
    local resultColumn = columns[3] --[[@as CraftSim.CraftQueue.CraftList.ResultColumn]]
    local averageProfitColumn = columns[4] --[[@as CraftSim.CraftQueue.CraftList.AverageProfitColumn]]
    local craftingCostsColumn = columns[5] --[[@as CraftSim.CraftQueue.CraftList.CraftingCostColumn]]
    local concentrationColumn = columns[6] --[[@as CraftSim.CraftQueue.CraftList.ConcentrationColumn]]
    local topGearColumn = columns[7] --[[@as CraftSim.CraftQueue.CraftList.TopGearColumn]]
    local craftAbleColumn = columns[8] --[[@as CraftSim.CraftQueue.CraftList.CraftAbleColumn]]
    local craftAmountColumn = columns[9] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
    local statusColumn = columns[10] --[[@as CraftSim.CraftQueue.CraftList.StatusColumn]]
    local craftButtonColumn = columns[11] --[[@as CraftSim.CraftQueue.CraftList.CraftButtonColumn]]

    row.craftQueueItem = craftQueueItem

    crafterColumn.text:SetText(recipeData:GetFormattedCrafterText(false, true, 20, 20))

    -- update price data and profit?
    recipeData.priceData:Update()
    recipeData:GetAverageProfit()

    if recipeData.orderData then
        row.craftingCosts = recipeData.priceData.craftingCostsNoOrderReagents * craftQueueItem.amount
    else
        row.craftingCosts = recipeData.priceData.craftingCosts * craftQueueItem.amount
    end

    row.averageProfit = (recipeData.averageProfitCached or recipeData:GetAverageProfit()) *
        craftQueueItem.amount

    local upCraftText = ""
    if recipeData:IsSubRecipe() then
        local upgradeArrow = CreateAtlasMarkup(CraftSim.CONST.ATLAS_TEXTURES.UPGRADE_ARROW_2, 10, 10)
        upCraftText = " " ..
            upgradeArrow --.. "(" .. craftQueueItem.recipeData.subRecipeDepth .. ")"
    end
    if recipeData.orderData then
        upCraftText = upCraftText .. " " .. CraftSim.UTIL:GetOrderTypeText(recipeData.orderData.orderType)
    end
    recipeColumn.text:SetText(recipeData.recipeName .. upCraftText)

    resultColumn.icon:SetItem(recipeData.resultData.expectedItem)

    if craftQueueItem.recipeData:IsSubRecipe() then
        averageProfitColumn.text:SetText(f.g("-"))
        craftingCostsColumn.text:SetText(f.g("-"))
    else
        averageProfitColumn.text:SetText(CraftSim.UTIL:FormatMoney(select(1, row.averageProfit), true, row.craftingCosts))
        craftingCostsColumn.text:SetText(f.r(CraftSim.UTIL:FormatMoney(row.craftingCosts)))
    end

    local concentrationData = craftQueueItem.recipeData.concentrationData
    local concentrationTimeLine = ""
    if craftQueueItem.recipeData.concentrating and concentrationData then
        if craftQueueItem.isCrafter then
            concentrationData:Update() -- consider concentration usage on crafting before refresh
        end
        local concentrationCost = craftQueueItem.recipeData.concentrationCost * craftQueueItem.amount
        local currentAmount = concentrationData:GetCurrentAmount()
        if concentrationCost <= currentAmount then
            concentrationColumn.text:SetText(f.g(concentrationCost))
        elseif craftQueueItem.recipeData.concentrationCost < currentAmount then
            concentrationColumn.text:SetText(f.l(concentrationCost))
        else
            concentrationColumn.text:SetText(f.r(concentrationCost))
        end
        if concentrationCost > currentAmount then
            local formatMode = CraftSim.DB.OPTIONS:Get("CONCENTRATION_TRACKER_FORMAT_MODE")
            local useUSFormat = formatMode == CraftSim.CONCENTRATION_TRACKER.UI.FORMAT_MODE.AMERICA_MAX_DATE
            local estimatedText = concentrationData:GetEstimatedTimeUntilEnoughText(concentrationCost, useUSFormat)
            if estimatedText then
                concentrationTimeLine = "\n" .. estimatedText
            end
        end
    else
        concentrationColumn.text:SetText(f.g("-"))
    end

    local craftOrderInfoText = ""

    if recipeData.orderData then
        craftOrderInfoText = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_CUSTOMER) .. f.bb(recipeData.orderData.customerName or "<?>")

        if recipeData.orderData.orderType == Enum.CraftingOrderType.Npc then
            craftOrderInfoText = craftOrderInfoText .. f.grey(" (NPC)")
        end

        if recipeData.orderData.customerNotes and recipeData.orderData.customerNotes ~= "" then
            craftOrderInfoText = craftOrderInfoText .. f.grey("\n" .. recipeData.orderData.customerNotes)
        end

        if recipeData.orderData.minQuality then
            craftOrderInfoText = craftOrderInfoText ..
                L(CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_MINIMUM_QUALITY) ..
                GUTIL:GetQualityIconString(recipeData.orderData.minQuality, 15, 15)
        end
    end

    -- if we got npcOrderRewards than we need to delay the tooltip display data

    local tooltipHeader = recipeData:GetFormattedCrafterText(true, true, 20, 20) ..
        "\n" .. f.bb(recipeData.recipeName) .. "\n\n"

    if recipeData.orderData and recipeData.orderData.npcOrderRewards then
        craftOrderInfoText = craftOrderInfoText .. L(CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_REWARDS)
        local rewardItems = GUTIL:Map(recipeData.orderData.npcOrderRewards, function(reward)
            return {
                count = reward.count,
                item = reward.itemLink and Item:CreateFromItemLink(reward.itemLink) or nil,
                rawItemLink = reward.itemLink,
                currency = reward.currencyType,
            }
        end)
        GUTIL:ContinueOnAllItemsLoaded(GUTIL:Map(rewardItems, function(reward) return reward.item end), function()
            for _, reward in ipairs(rewardItems) do
                if reward.currency then
                    local currencyLink = C_CurrencyInfo.GetCurrencyLink(reward.currency, reward.count)
                    local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(reward.currency, reward.count)
                    if currencyInfo then
                        craftOrderInfoText = craftOrderInfoText ..
                            "\n- " ..
                            GUTIL:IconToText(currencyInfo.icon, 20, 20) ..
                            " " .. (currencyLink or currencyInfo.name or "<?>") .. " x" .. reward.count
                    end
                elseif reward.item then
                    local itemLink = reward.item:GetItemLink()
                    local itemName = reward.item:GetItemName()
                    local displayText = itemLink
                    if not displayText or displayText:match("%[%]") then
                        displayText = itemName and ("[" .. itemName .. "]") or reward.rawItemLink or "<?>"
                    end
                    craftOrderInfoText = craftOrderInfoText ..
                        "\n- " ..
                        GUTIL:IconToText(reward.item:GetItemIcon(), 20, 20) ..
                        " " .. displayText .. " x" .. reward.count
                end
            end

            -- Show gold reward under the Rewards section too
            if recipeData.orderData then
                local tipAmount = tonumber(recipeData.orderData.tipAmount) or 0
                local cutAmount = tonumber(recipeData.orderData.consortiumCut) or 0
                local commission = tipAmount - cutAmount
                if commission > 0 then
                    craftOrderInfoText = craftOrderInfoText ..
                        "\n- " .. CraftSim.UTIL:FormatMoney(commission, true) .. " (included in profit)"
                end
            end

            row.tooltipOptions = {
                text = tooltipHeader .. recipeData.reagentData:GetTooltipText(craftQueueItem.amount,
                        craftQueueItem.recipeData:GetCrafterUID()) ..
                    f.white(craftOrderInfoText) .. concentrationTimeLine,
                owner = row.frame,
                anchor = "ANCHOR_CURSOR",
            }
        end)
    else
        row.tooltipOptions = {
            text = tooltipHeader .. recipeData.reagentData:GetTooltipText(craftQueueItem.amount,
                    craftQueueItem.recipeData:GetCrafterUID()) ..
                f.white(craftOrderInfoText) .. concentrationTimeLine,
            owner = row.frame,
            anchor = "ANCHOR_CURSOR",
        }
    end

    topGearColumn.statusIcon:SetTools(craftQueueItem.recipeData.professionGearSet, craftQueueItem.gearEquipped)

    local craftAbleAmount = math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount)

    if craftAbleAmount == 0 or not craftQueueItem.allowedToCraft then
        craftAbleColumn.text:SetText(f.r(craftAbleAmount))
    elseif craftAbleAmount == craftQueueItem.amount then
        craftAbleColumn.text:SetText(f.g(craftAbleAmount))
    else
        craftAbleColumn.text:SetText(f.l(craftAbleAmount))
    end

    row.frame:SetSize(row:GetWidth(), row.frameList.rowHeight)
    craftAmountColumn.input.textInput:SetText(craftQueueItem.amount, false)
    craftAmountColumn.input.onEnterPressedCallback =
        function(_, value)
            craftQueueItem.amount = value or 1
            craftAmountColumn.unsavedMarker:Hide()
            CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
        end

    craftAmountColumn.input:SetVisible(not craftQueueItem.recipeData:IsSubRecipe())

    craftAmountColumn.inputText:SetVisible(craftQueueItem.recipeData:IsSubRecipe())
    craftAmountColumn.inputText:SetText(craftQueueItem.amount)

    craftButtonColumn.craftButton.clickCallback = nil

    local statusColumnTooltip = ""

    if not craftQueueItem.learned then
        local nL = (statusColumnTooltip ~= "" and "\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Not Learned")
    end
    if not craftQueueItem.notOnCooldown then
        local nL = (statusColumnTooltip ~= "" and "\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "On Cooldown")
    end
    if not craftQueueItem.isCrafter then
        local nL = (statusColumnTooltip ~= "" and "\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Alt Character")
    end
    if not craftQueueItem.canCraftOnce then
        local nL = (statusColumnTooltip ~= "" and "\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Missing Reagents")
    end
    if not craftQueueItem.gearEquipped then
        local nL = (statusColumnTooltip ~= "" and "\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Wrong Profession Tools")
    end
    if not craftQueueItem.correctProfessionOpen then
        local nL = (statusColumnTooltip ~= "" and "\n") or ""
        statusColumnTooltip = statusColumnTooltip .. f.r(nL .. "Wrong Profession")
    end

    statusColumn.statusIcon:SetStatus(craftQueueItem.allowedToCraft, statusColumnTooltip)

    craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT))

    if recipeData.orderData and craftQueueItem.isCrafter and craftQueueItem.correctProfessionOpen then
        local accessToOrders = C_TradeSkillUI.IsNearProfessionSpellFocus(recipeData.professionData.professionInfo
            .profession)

        if accessToOrders then
            local claimedOrder = C_CraftingOrders.GetClaimedOrder()

            if claimedOrder and claimedOrder.orderID == recipeData.orderData.orderID then
                if claimedOrder.isFulfillable then
                    craftButtonColumn.craftButton:SetEnabled(true)
                    craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_SUBMIT))

                    craftButtonColumn.craftButton.clickCallback = function()
                        C_CraftingOrders.FulfillOrder(recipeData.orderData.orderID, "",
                            recipeData.professionData.professionInfo.profession)
                        CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem)
                        self:UpdateDisplay()
                    end
                elseif claimedOrder.minQuality and (craftQueueItem.recipeData.resultData.expectedQuality < claimedOrder.minQuality) then
                    craftButtonColumn.craftButton:SetEnabled(false)
                    craftButtonColumn.craftButton:SetText(GUTIL:GetQualityIconString(claimedOrder.minQuality, 25, 25))
                elseif craftQueueItem.allowedToCraft then
                    craftButtonColumn.craftButton:SetEnabled(true)
                    craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT))
                    craftButtonColumn.craftButton.clickCallback = function()
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                        recipeData:Craft(math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount))
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                    end
                else
                    craftButtonColumn.craftButton:SetEnabled(false)
                    craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIMED))
                end
            elseif claimedOrder then
                craftButtonColumn.craftButton:SetEnabled(false)
                craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT))
            else
                craftButtonColumn.craftButton:SetEnabled(true)
                craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIM))
                craftButtonColumn.craftButton.clickCallback = function()
                    C_CraftingOrders.ClaimOrder(recipeData.orderData.orderID,
                        recipeData.professionData.professionInfo.profession)
                end
            end
        else
            craftButtonColumn.craftButton:SetEnabled(false) --[[@as GGUI.Button]]
            craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_ORDER))
        end
    else
        craftButtonColumn.craftButton:SetEnabled(craftQueueItem.allowedToCraft)
        if craftQueueItem.allowedToCraft then
            craftButtonColumn.craftButton:SetText(L(CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT))
            craftButtonColumn.craftButton.clickCallback = function()
                CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                recipeData:Craft(math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount))
                CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
            end
        end
    end

    CraftSim.DEBUG:StopProfiling(profilingID)
end
