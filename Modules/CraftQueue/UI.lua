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

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

function CraftSim.CRAFTQ.UI:Init()
    local sizeX = 1200
    local sizeY = 420

    ---@class CraftSim.CraftQueue.Frame : GGUI.Frame
    CraftSim.CRAFTQ.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
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
        ---@type GGUI.BlizzardTab
        frame.content.restockOptionsTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content.queueTab.button,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL),
                tooltipOptions = {
                    owner = frame.content,
                    anchor = "ANCHOR_CURSOR",
                    text = f.white("Configure the restock behaviour when importing from Recipe Scan"),
                    textWrap = true,
                },
            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = tabContentSizeX,
            sizeY = tabContentSizeY,
            canBeEnabled = true,
            offsetY = -30,
            top = true,
        })
        local restockOptionsTab = frame.content.restockOptionsTab
        ---@class CraftSim.CraftQueue.QueueTab : GGUI.BlizzardTab
        local queueTab = frame.content.queueTab
        ---@class CraftSim.CraftQueue.QueueTab.Content
        queueTab.content = queueTab.content

        GGUI.BlizzardTabSystem({ queueTab, restockOptionsTab })

        ---@type GGUI.FrameList.ColumnOption[]
        local columnOptions = {
            {
                label = "", -- edit button
                width = 30,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER),
                width = 130,
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
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER), -- here a button is needed to switch to the top gear for this recipe
                width = 110,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT),
                width = 100,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER),
                width = 100,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER), -- Status Icon List
                width = 130,
                justifyOptions = { type = "H", align = "CENTER" },
                tooltipOptions = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    anchor = nil,
                    owner = nil,
                    text = f.white("All Requirements need to be fulfilled in order to craft a recipe"),
                    textWrap = true,
                },
            },
            {
                label = "", -- craftButtonColumn
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = "", -- remove row column
                width = 30,
                justifyOptions = { type = "H", align = "CENTER" }
            }
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
                        if craftQueueItem.recipeData then
                            C_TradeSkillUI.OpenRecipe(craftQueueItem.recipeData.recipeID)
                        end
                    end
                end
            },
            sizeY = 232,
            offsetY = -70,
            offsetX = -10,
            columnOptions = columnOptions,
            rowConstructor = function(columns, row)
                ---@class CraftSim.CraftQueue.CraftList.EditButtonColumn : Frame
                local editButtonColumn = columns[1]
                ---@class CraftSim.CraftQueue.CraftList.CrafterColumn : Frame
                local crafterColumn = columns[2]
                ---@class CraftSim.CraftQueue.CraftList.RecipeColumn : Frame
                local recipeColumn = columns[3]
                ---@class CraftSim.CraftQueue.CraftList.ResultColumn : Frame
                local resultColumn = columns[4]
                ---@class CraftSim.CraftQueue.CraftList.AverageProfitColumn : Frame
                local averageProfitColumn = columns[5]
                ---@class CraftSim.CraftQueue.CraftList.CraftingCostColumn : Frame
                local craftingCostsColumn = columns[6]
                ---@class CraftSim.CraftQueue.CraftList.ConcentrationColumn : Frame
                local concentrationColumn = columns[7]
                ---@class CraftSim.CraftQueue.CraftList.TopGearColumn : Frame
                local topGearColumn = columns[8]
                ---@class CraftSim.CraftQueue.CraftList.CraftAbleColumn : Frame
                local craftAbleColumn = columns[9]
                ---@class CraftSim.CraftQueue.CraftList.CraftAmountColumn : Frame
                local craftAmountColumn = columns[10]
                ---@class CraftSim.CraftQueue.CraftList.StatusColumn : Frame
                local statusColumn = columns[11]
                ---@class CraftSim.CraftQueue.CraftList.CraftButtonColumn : Frame
                local craftButtonColumn = columns[12]
                ---@class CraftSim.CraftQueue.CraftList.RemoveRowColumn : Frame
                local removeRowColumn = columns[13]

                editButtonColumn.editButton = GGUI.Button({
                    parent = editButtonColumn,
                    anchorParent = editButtonColumn,
                    sizeX = 25,
                    sizeY = 25,
                    label = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.EDIT_PEN, 0.7),
                    tooltipOptions = {
                        text = "Edit",
                        anchor = "ANCHOR_CURSOR_RIGHT",
                    },
                })

                crafterColumn.text = GGUI.Text {
                    parent = crafterColumn, anchorParent = crafterColumn,
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

                topGearColumn.gear2Icon = GGUI.Icon({
                    parent = topGearColumn, anchorParent = topGearColumn, sizeX = iconSize, sizeY = iconSize, qualityIconScale = 1.2,
                })

                topGearColumn.gear1Icon = GGUI.Icon({
                    parent = topGearColumn,
                    anchorParent = topGearColumn.gear2Icon.frame,
                    anchorA = "RIGHT",
                    anchorB =
                    "LEFT",
                    sizeX = iconSize,
                    sizeY = iconSize,
                    qualityIconScale = 1.2,
                    offsetX = -5,
                })
                topGearColumn.toolIcon = GGUI.Icon({
                    parent = topGearColumn,
                    anchorParent = topGearColumn.gear2Icon.frame,
                    anchorA = "LEFT",
                    anchorB =
                    "RIGHT",
                    sizeX = iconSize,
                    sizeY = iconSize,
                    qualityIconScale = 1.2,
                    offsetX = 5
                })
                topGearColumn.equippedText = GGUI.Text({
                    parent = topGearColumn, anchorParent = topGearColumn
                })

                topGearColumn.equipButton = GGUI.Button({
                    parent = topGearColumn,
                    anchorParent = topGearColumn.toolIcon.frame,
                    anchorA = "LEFT",
                    anchorB = "RIGHT",
                    offsetX = 2,
                    label = L(CraftSim.CONST.TEXT.TOP_GEAR_EQUIP),
                    clickCallback = nil, -- will be set in Add dynamically
                    adjustWidth = true,
                })

                function topGearColumn.equippedText:SetEquipped()
                    topGearColumn.equippedText:SetText(GUTIL:ColorizeText(
                        L(CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED), GUTIL.COLORS.GREEN))
                end

                function topGearColumn.equippedText:SetIrrelevant()
                    topGearColumn.equippedText:SetText(GUTIL:ColorizeText("-", GUTIL.COLORS.GREY))
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
                    sizeX = 100,
                    borderAdjustWidth = 0.95,
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
                                    [8] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
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

                local statusIconsOffsetX = 8
                local statusIconsSpacingX = 0
                local statusIconSize = 20
                statusColumn.learned = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn, anchorA = "LEFT", anchorB = "LEFT",
                    offsetX = statusIconsOffsetX, sizeX = statusIconSize * 1.1, sizeY = statusIconSize * 1.1,
                    atlas = CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.LEARNED.texture,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = L("CRAFT_QUEUE_STATUSBAR_LEARNED"),
                    },
                }
                statusColumn.cooldown = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn.learned.frame, anchorA = "LEFT", anchorB = "RIGHT",
                    offsetX = statusIconsSpacingX, sizeX = statusIconSize * 0.8, sizeY = statusIconSize * 0.8,
                    atlas = CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.COOLDOWN.texture,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = L("CRAFT_QUEUE_STATUSBAR_COOLDOWN"),
                    },
                }
                statusColumn.reagents = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn.cooldown.frame, anchorA = "LEFT", anchorB = "RIGHT",
                    offsetX = statusIconsSpacingX, sizeX = statusIconSize * 0.9, sizeY = statusIconSize * 0.9,
                    atlas = CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.REAGENTS.texture,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = L("CRAFT_QUEUE_STATUSBAR_MATERIALS"),
                    },
                }
                statusColumn.tools = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn.reagents.frame, anchorA = "LEFT", anchorB = "RIGHT",
                    offsetX = statusIconsSpacingX, sizeX = statusIconSize, sizeY = statusIconSize,
                    atlas = CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.TOOLS.texture,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = L("CRAFT_QUEUE_STATUSBAR_GEAR"),
                    },
                }
                statusColumn.crafter = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn.tools.frame, anchorA = "LEFT", anchorB = "RIGHT",
                    offsetX = statusIconsSpacingX, sizeX = statusIconSize, sizeY = statusIconSize,
                    atlas = CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.CRAFTER.texture,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = L("CRAFT_QUEUE_STATUSBAR_CRAFTER"),
                    },
                }
                statusColumn.profession = GGUI.Texture {
                    parent = statusColumn, anchorParent = statusColumn.crafter.frame, anchorA = "LEFT", anchorB = "RIGHT",
                    offsetX = statusIconsSpacingX, sizeX = statusIconSize, sizeY = statusIconSize,
                    atlas = CraftSim.CONST.CRAFT_QUEUE_STATUS_TEXTURES.PROFESSION.texture,
                    tooltipOptions = {
                        anchor = "ANCHOR_CURSOR_RIGHT",
                        text = L("CRAFT_QUEUE_STATUSBAR_PROFESSION"),
                    },
                }

                craftButtonColumn.craftButton = GGUI.Button({
                    parent = craftButtonColumn,
                    anchorParent = craftButtonColumn,
                    label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL),
                    adjustWidth = true,
                    secure = true,
                })

                removeRowColumn.removeButton = GGUI.Button({
                    parent = removeRowColumn,
                    anchorParent = removeRowColumn,
                    label = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.1),
                    sizeX = 25,
                    clickCallback = nil -- set dynamically in Add
                })
            end
        })

        local craftQueueButtonsOffsetY = -5

        ---@type GGUI.Button
        queueTab.content.importRecipeScanButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.craftList.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = craftQueueButtonsOffsetY,
            offsetX = 0,
            adjustWidth = true,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL),
            initialStatusID = "Ready",
            clickCallback = function()
                CraftSim.CRAFTQ:ImportRecipeScan()
            end
        })

        queueTab.content.importRecipeScanButton:SetStatusList {
            {
                statusID = "Ready",
                enabled = true,
                adjustWidth = true,
                sizeX = 15,
                label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL),
            },
        }

        queueTab.content.importAllProfessionsCB = GGUI.Checkbox {
            parent = queueTab.content, anchorParent = queueTab.content.importRecipeScanButton.frame,
            label = L(CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL),
            offsetX = 5, anchorA = "LEFT", anchorB = "RIGHT",
            initialValue = CraftSim.DB.OPTIONS:Get("RECIPESCAN_IMPORT_ALL_PROFESSIONS"),
            clickCallback = function(_, checked)
                CraftSim.DB.OPTIONS:Save("RECIPESCAN_IMPORT_ALL_PROFESSIONS", checked)
            end,
            tooltip = L(CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP)
        }

        ---@type GGUI.Button
        queueTab.content.addCurrentRecipeButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.importRecipeScanButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            adjustWidth = true,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL),
            clickCallback = function()
                CraftSim.CRAFTQ:AddOpenRecipe()
            end
        })

        queueTab.content.addAllFirstCraftsButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addCurrentRecipeButton.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetY = 0,
            adjustWidth = true,
            label = "Add First Crafts",
            clickCallback = function()
                CraftSim.CRAFTQ:AddFirstCrafts()
            end
        })

        queueTab.content.ignoreAcuityRecipesCB = GGUI.Checkbox {
            parent = queueTab.content, anchorParent = queueTab.content.addAllFirstCraftsButton.frame,
            scale = 0.9, anchorA = "LEFT", anchorB = "RIGHT", labelOptions = { text = "Ignore Acuity Recipes" },
            offsetX = 5,
            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES"),
            clickCallback = function(_, checked)
                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_FIRST_CRAFTS_IGNORE_ACUITY_RECIPES", checked)
            end,
            tooltip = "Do not queue first crafts that use " .. f.bb("Artisan's Acuity") .. " for crafting",
        }

        ---@type GGUI.Button
        queueTab.content.clearAllButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addCurrentRecipeButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            adjustWidth = true,
            label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL),
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
                offsetY = 0,
                clickCallback = function()
                    CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
                end,
                label = L(CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL)
            })

            queueTab.content.shoppingListPerCharacterCB = GGUI.Checkbox({
                parent = queueTab.content,
                anchorParent = queueTab.content.createAuctionatorShoppingList.frame,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                offsetX = 5,
                labelOptions = {
                    text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX),
                },
                tooltip = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP),
                initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_SHOPPING_LIST_PER_CHARACTER"),
                clickCallback = function(_, checked)
                    CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_SHOPPING_LIST_PER_CHARACTER", checked)
                end
            })
        end

        -- summaries

        queueTab.content.totalAverageProfitLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.importRecipeScanButton.frame,
            scale = 1,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 300,
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
            scale = 1,
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

        -- restock Options

        restockOptionsTab.content.generalOptionsFrame = CreateFrame("frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.generalOptionsFrame:SetSize(150, 70)
        restockOptionsTab.content.generalOptionsFrame:SetPoint("TOP", restockOptionsTab.content, "TOP", 0, -10)
        local generalOptionsFrame = restockOptionsTab.content.generalOptionsFrame

        generalOptionsFrame.title = GGUI.Text {
            parent = generalOptionsFrame, anchorParent = generalOptionsFrame, anchorA = "TOP", anchorB = "TOP",
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL), scale = 1.2,
        }

        local profitMarginLabel = GGUI.Text({
            parent = generalOptionsFrame,
            anchorParent = generalOptionsFrame,
            anchorA = "TOP",
            anchorB = "TOP",
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL),
            offsetX = -25,
            offsetY = -30
        })

        generalOptionsFrame.profitMarginThresholdInput = GGUI.NumericInput({
            parent = generalOptionsFrame,
            anchorParent = profitMarginLabel.frame,
            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_PROFIT_MARGIN_THRESHOLD"),
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 10,
            allowDecimals = true,
            minValue = -math.huge,
            sizeX = 40,
            borderAdjustWidth = 1.2,
            onNumberValidCallback = function(numberInput)
                CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_GENERAL_RESTOCK_PROFIT_MARGIN_THRESHOLD",
                    tonumber(numberInput.currentValue or 0))
            end
        })
        -- %
        GGUI.Text({
            parent = generalOptionsFrame,
            anchorParent = generalOptionsFrame.profitMarginThresholdInput.textInput.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            text = "%",
            offsetX = 2
        })

        generalOptionsFrame.restockAmountLabel = GGUI.Text({
            parent = generalOptionsFrame,
            anchorParent = profitMarginLabel.frame,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY = -10,
        })

        generalOptionsFrame.restockAmountInput = GGUI.NumericInput {
            parent = generalOptionsFrame, anchorParent = generalOptionsFrame.restockAmountLabel.frame,
            initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT"),
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10, minValue = 1,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = function(input)
            local value = tostring(input.currentValue)
            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT", tonumber(value) or 1)
        end,
        }

        local qualityIconSize = 20
        local qualityCheckboxBaseOffsetX = 10
        local qualityCheckboxSpacingX = 50
        local function createQualityCheckbox(p, a, qualityID, oX, oY)
            oX = oX or -2
            oY = oY or -2.8
            return GGUI.Checkbox {
                parent = p, anchorParent = a,
                anchorA = "LEFT", anchorB = "RIGHT", offsetX = qualityCheckboxBaseOffsetX + qualityCheckboxSpacingX * (qualityID - 1),
                label = GUTIL:GetQualityIconString(qualityID, qualityIconSize, qualityIconSize, oX, oY) }
        end

        -- always create the inputs and such but only show when tsm is loaded
        generalOptionsFrame.saleRateTitle = GGUI.Text { parent = generalOptionsFrame, anchorParent = generalOptionsFrame.restockAmountLabel.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", offsetY = -10,
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        generalOptionsFrame.saleRateInput = GGUI.NumericInput {
            parent = generalOptionsFrame, anchorParent = generalOptionsFrame.saleRateTitle.frame, initialValue = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_GENERAL_RESTOCK_SALE_RATE_THRESHOLD"),
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10,
            allowDecimals = true, minValue = 0,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = function(input)
            local value = input.currentValue
            CraftSim.DB.OPTIONS:Save("CRAFTQUEUE_GENERAL_RESTOCK_SALE_RATE_THRESHOLD", tonumber(value))
        end
        }

        generalOptionsFrame.saleRateHelpIcon = GGUI.HelpIcon { parent = generalOptionsFrame, anchorParent = generalOptionsFrame.saleRateTitle.frame,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -2, text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL)
        }

        restockOptionsTab.content.recipeOptionsFrame = CreateFrame("Frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.recipeOptionsFrame:SetSize(150, 50)
        restockOptionsTab.content.recipeOptionsFrame:SetPoint("TOP", generalOptionsFrame, "BOTTOM", 0, -60)

        ---@class CraftSim.CraftQueue.RestockOptions.RecipeOptionsFrame : Frame
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame

        ---@type number | nil
        recipeOptionsFrame.recipeID = nil

        recipeOptionsFrame.recipeTitle = GGUI.Text({
            parent = recipeOptionsFrame,
            anchorParent = recipeOptionsFrame,
            anchorA = "TOP",
            anchorB = "TOP",
            justifyOptions = { type = 'H', align = "LEFT" },
            scale = 1.2
        })

        local enableRecipeLabel = GGUI.Text { parent = recipeOptionsFrame, anchorParent = recipeOptionsFrame,
            anchorA = "TOP", anchorB = "BOTTOM", text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL),
            offsetY = 10, offsetX = 0 }

        recipeOptionsFrame.enableRecipeCheckbox = GGUI.Checkbox {
            parent = recipeOptionsFrame, anchorParent = enableRecipeLabel.frame, anchorA = "LEFT", anchorB = "RIGHT",
            tooltip = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP), offsetX = 15,
        }
        local recipeProfitMarginLabel = GGUI.Text({
            parent = recipeOptionsFrame,
            anchorParent = enableRecipeLabel.frame,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL),
            offsetY = -10,
        })

        recipeOptionsFrame.profitMarginThresholdInput = GGUI.NumericInput({
            parent = recipeOptionsFrame,
            anchorParent = recipeProfitMarginLabel.frame,
            initialValue = 0,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 10,
            allowDecimals = true,
            minValue = -math.huge,
            sizeX = 40,
            borderAdjustWidth = 1.2
        })

        -- %
        GGUI.Text({
            parent = recipeOptionsFrame,
            anchorParent = recipeOptionsFrame.profitMarginThresholdInput.textInput.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            text = "%",
            offsetX = 2
        })

        recipeOptionsFrame.restockAmountLabel = GGUI.Text { parent = recipeOptionsFrame, anchorParent = recipeProfitMarginLabel.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY = -10,
        }
        GGUI.HelpIcon { parent = recipeOptionsFrame, anchorParent = recipeOptionsFrame.restockAmountLabel.frame,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -2, text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP)
        }

        recipeOptionsFrame.restockAmountInput = GGUI.NumericInput {
            parent = recipeOptionsFrame, anchorParent = recipeOptionsFrame.restockAmountLabel.frame, initialValue = 1,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10, minValue = 1,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = nil -- set dynamically
        }

        recipeOptionsFrame.restockQualityCheckboxes = {
            createQualityCheckbox(recipeOptionsFrame, recipeOptionsFrame.restockAmountInput.textInput.frame, 1, 0, -3),
            createQualityCheckbox(recipeOptionsFrame, recipeOptionsFrame.restockAmountInput.textInput.frame, 2, 0, -3),
            createQualityCheckbox(recipeOptionsFrame, recipeOptionsFrame.restockAmountInput.textInput.frame, 3),
            createQualityCheckbox(recipeOptionsFrame, recipeOptionsFrame.restockAmountInput.textInput.frame, 4),
            createQualityCheckbox(recipeOptionsFrame, recipeOptionsFrame.restockAmountInput.textInput.frame, 5),
        }

        recipeOptionsFrame.tsmSaleRateFrame = CreateFrame("Frame", nil, recipeOptionsFrame)
        recipeOptionsFrame.tsmSaleRateFrame:SetSize(150, 30)
        recipeOptionsFrame.tsmSaleRateFrame:SetPoint("TOP", recipeOptionsFrame.restockAmountInput.textInput.frame,
            "BOTTOM", 0, -10)
        ---@class CraftSim.CraftQueue.RestockOptions.TSMSaleRateFrame : Frame
        local tsmSaleRateFrame = recipeOptionsFrame.tsmSaleRateFrame

        -- always create the inputs and such but only show when tsm is loaded
        tsmSaleRateFrame.saleRateTitle = GGUI.Text { parent = tsmSaleRateFrame, anchorParent = recipeOptionsFrame.restockAmountLabel.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", offsetY = -10,
            text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        tsmSaleRateFrame.saleRateInput = GGUI.NumericInput {
            parent = tsmSaleRateFrame, anchorParent = tsmSaleRateFrame.saleRateTitle.frame, initialValue = 0,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10,
            allowDecimals = true, minValue = 0,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = nil -- set dynamically
        }

        tsmSaleRateFrame.helpIcon = GGUI.HelpIcon { parent = tsmSaleRateFrame, anchorParent = tsmSaleRateFrame.saleRateTitle.frame,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -2, text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP)
        }

        tsmSaleRateFrame.qualityCheckboxes = {
            createQualityCheckbox(tsmSaleRateFrame, tsmSaleRateFrame.saleRateInput.textInput.frame, 1, 0, -3),
            createQualityCheckbox(tsmSaleRateFrame, tsmSaleRateFrame.saleRateInput.textInput.frame, 2, 0, -3),
            createQualityCheckbox(tsmSaleRateFrame, tsmSaleRateFrame.saleRateInput.textInput.frame, 3),
            createQualityCheckbox(tsmSaleRateFrame, tsmSaleRateFrame.saleRateInput.textInput.frame, 4),
            createQualityCheckbox(tsmSaleRateFrame, tsmSaleRateFrame.saleRateInput.textInput.frame, 5),
        }
    end

    createContent(CraftSim.CRAFTQ.frame)
end

---@param parent frame
---@param anchorParent Region
---@return CraftSim.CRAFTQ.EditRecipeFrame editRecipeFrame
function CraftSim.CRAFTQ.UI:InitEditRecipeFrame(parent, anchorParent)
    local editFrameX = 600
    local editFrameY = 330
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
    local qButtonSize = 20
    local qButtonSpacingX = 25
    local qButtonBaseOffsetX = 50
    local qButtonBaseOffsetY = -70

    editRecipeFrame.content.q1Button = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = qButtonBaseOffsetX, offsetY = qButtonBaseOffsetY,
        label = GUTIL:GetQualityIconString(1, qIconSize, qIconSize), sizeX = qButtonSize, sizeY = qButtonSize,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.reagentData:SetReagentsMaxByQuality(1)
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    editRecipeFrame.content.q2Button = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.q1Button.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = qButtonSpacingX,
        label = GUTIL:GetQualityIconString(2, qIconSize, qIconSize), sizeX = qButtonSize, sizeY = qButtonSize,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.reagentData:SetReagentsMaxByQuality(2)
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    editRecipeFrame.content.q3Button = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.q2Button.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = qButtonSpacingX,
        label = GUTIL:GetQualityIconString(3, qIconSize, qIconSize, 1), sizeX = qButtonSize, sizeY = qButtonSize,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.reagentData:SetReagentsMaxByQuality(3)
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }

    editRecipeFrame.ValidateReagentQuantities = function()
        for _, reagentFrame in pairs(editRecipeFrame.content.reagentFrames) do
            if reagentFrame.isActive then
                if reagentFrame:GetTotalQuantity() ~= reagentFrame.reagent.requiredQuantity then
                    return false
                end
            end
        end
        return true
    end

    editRecipeFrame.UpdateReagentQuantities = function()
        for _, reagentFrame in pairs(editRecipeFrame.content.reagentFrames) do
            if reagentFrame.isActive then
                reagentFrame.reagent.items[1].quantity = reagentFrame.q1Input.currentValue
                reagentFrame.reagent.items[2].quantity = reagentFrame.q2Input.currentValue
                reagentFrame.reagent.items[3].quantity = reagentFrame.q3Input.currentValue
            end
        end
        return true
    end


    local numReagentFrames = 6
    local reagentFramesBaseOffsetX = 51
    local reagentFramesBaseOffsetY = -5
    local reagentFramesSpacingY = -25
    local reagentFramesInputSpacingX = 20
    local function createReagentFrame(i)
        ---@class CraftSim.CRAFTQ.UI.ReagentFrame : Frame
        ---@field reagent CraftSim.Reagent?
        ---@field isActive? boolean
        local reagentFrame = CreateFrame("frame", nil, editRecipeFrame.content)
        reagentFrame:SetSize(200, 25)
        reagentFrame:SetScale(0.9)
        reagentFrame:SetPoint("TOP", editRecipeFrame.content.q1Button.frame, "BOTTOM", reagentFramesBaseOffsetX,
            reagentFramesBaseOffsetY + reagentFramesSpacingY * i)

        reagentFrame.icon = GGUI.Icon { parent = reagentFrame, anchorParent = reagentFrame, anchorA = "LEFT", anchorB = "LEFT",
            qualityIconScale = 2, texturePath = CraftSim.CONST.EMPTY_SLOT_TEXTURE, sizeX = 25, sizeY = 25, hideQualityIcon = true }

        reagentFrame.GetTotalQuantity = function()
            local q1 = tonumber(reagentFrame.q1Input.currentValue)
            local q2 = tonumber(reagentFrame.q2Input.currentValue)
            local q3 = tonumber(reagentFrame.q3Input.currentValue)

            return q1 + q2 + q3
        end

        reagentFrame.IsRequiredQuantity = function()
            local total = reagentFrame:GetTotalQuantity()
            if reagentFrame.reagent then
                return total == reagentFrame.reagent.requiredQuantity
            else
                return false
            end
        end

        ---@param reagentInput CraftSim.CRAFTQ.UI.ReagentInput
        local function onReagentInput(reagentInput)
            if reagentFrame:IsRequiredQuantity() then
                -- reagentFrame.maxQuantityLabel:SetText("test")
                reagentFrame.maxQuantityLabel:SetColor(GUTIL.COLORS.WHITE)

                -- if all reagentFrames are valid, update recipe
                if editRecipeFrame:ValidateReagentQuantities() then
                    editRecipeFrame:UpdateReagentQuantities()
                    editRecipeFrame.craftQueueItem.recipeData:Update()
                    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
                end
            else
                -- adapt input if its too much
                local total = reagentFrame:GetTotalQuantity()
                local max = reagentFrame.reagent.requiredQuantity
                if total > max then
                    local newQuantity = reagentInput.currentValue - (total - max)
                    reagentInput.textInput:SetText(newQuantity)
                    reagentInput.currentValue = newQuantity
                    reagentFrame.maxQuantityLabel:SetColor(GUTIL.COLORS.WHITE)
                else
                    reagentFrame.maxQuantityLabel:SetColor(GUTIL.COLORS.RED)
                end
            end
        end

        ---@class CraftSim.CRAFTQ.UI.ReagentInput : GGUI.NumericInput
        ---@field reagentItem CraftSim.ReagentItem?
        reagentFrame.q1Input = GGUI.NumericInput {
            parent = reagentFrame, anchorParent = reagentFrame.icon.frame, minValue = 0, incrementOneButtons = true, sizeX = 30, anchorA = "LEFT", anchorB = "RIGHT",
            offsetX = 10, onNumberValidCallback = onReagentInput, borderAdjustWidth = 1.3,
        }

        ---@class CraftSim.CRAFTQ.UI.ReagentInput
        reagentFrame.q2Input = GGUI.NumericInput {
            parent = reagentFrame, anchorParent = reagentFrame.q1Input.textInput.frame, minValue = 0, incrementOneButtons = true, sizeX = 30, anchorA = "LEFT", anchorB = "RIGHT",
            offsetX = reagentFramesInputSpacingX, onNumberValidCallback = onReagentInput, borderAdjustWidth = 1.3,
        }

        ---@class CraftSim.CRAFTQ.UI.ReagentInput
        reagentFrame.q3Input = GGUI.NumericInput {
            parent = reagentFrame, anchorParent = reagentFrame.q2Input.textInput.frame, minValue = 0, incrementOneButtons = true, sizeX = 30, anchorA = "LEFT", anchorB = "RIGHT",
            offsetX = reagentFramesInputSpacingX, onNumberValidCallback = onReagentInput, borderAdjustWidth = 1.3,
        }
        reagentFrame.maxQuantity = 0
        reagentFrame.maxQuantityLabel = GGUI.Text {
            parent = reagentFrame, anchorParent = reagentFrame.q3Input.textInput.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 20,
            text = "/ " .. reagentFrame.maxQuantity, justifyOptions = { type = "H", align = "LEFT" }
        }
        return reagentFrame
    end
    ---@type CraftSim.CRAFTQ.UI.ReagentFrame[]
    editRecipeFrame.content.reagentFrames = {}

    for i = 0, numReagentFrames - 1 do table.insert(editRecipeFrame.content.reagentFrames, createReagentFrame(i)) end

    local oRFrameX = 100
    local oRFrameY = 65
    local optionalReagentsFrame = CreateFrame("frame", nil, editRecipeFrame.content)
    optionalReagentsFrame:SetSize(oRFrameX, oRFrameY)
    optionalReagentsFrame:SetPoint("TOPLEFT", editRecipeFrame.content.q3Button.frame, "TOPRIGHT", 60, -2)

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
    ---@param item ItemMixin?
    local function OnSelectOptionalReagent(itemSelector, item)
        if itemSelector and itemSelector.slot then
            print("setting reagent: " .. tostring(item and item:GetItemLink()))
            itemSelector.slot:SetReagent((item and item:GetItemID()) or nil)
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
        label = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON), adjustWidth = true,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData:OptimizeProfit({
                    optimizeGear = true,
                    optimizeReagents = true,
                })
                CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }

    editRecipeFrame.content.craftingCostsTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content, anchorA = "BOTTOM", anchorB = "BOTTOM", offsetX = -30,
        offsetY = 40, text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL),
    }
    editRecipeFrame.content.craftingCostsValue = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.craftingCostsTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        text = CraftSim.UTIL:FormatMoney(0, true), justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9, offsetY = -1,
    }
    editRecipeFrame.content.averageProfitTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.craftingCostsTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -5, text = L(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL),
    }
    editRecipeFrame.content.averageProfitValue = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.averageProfitTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        text = CraftSim.UTIL:FormatMoney(0, true), justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9, offsetY = -1,
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

    --- precalculate craftable status and subrecipetargetcounts before sorting to increase performance
    table.foreach(craftQueue.craftQueueItems,
        ---@param _ any
        ---@param craftQueueItem CraftSim.CraftQueueItem
        function(_, craftQueueItem)
            craftQueueItem:CalculateCanCraft()
        end)

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

function CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
    --- use a cache to prevent multiple redundant calls of ItemCount thus increasing performance
    CraftSim.CRAFTQ.itemCountCache = {}

    CraftSim.CRAFTQ.UI:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    local queueTab = craftQueueFrame.content.queueTab --[[@as CraftSim.CraftQueue.QueueTab]]

    --- update craft next button
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    if itemsPresent then
        -- if first item can be crafted (so if anything can be crafted cause the items are sorted by craftable status)
        local firstQueueItem = CraftSim.CRAFTQ.craftQueue.craftQueueItems[1]
        queueTab.content.craftNextButton:SetEnabled(firstQueueItem.allowedToCraft)

        if firstQueueItem.allowedToCraft then
            -- set callback to craft the recipe of the top row
            queueTab.content.craftNextButton.clickCallback =
                function()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                    firstQueueItem.recipeData:Craft(math.min(firstQueueItem.craftAbleAmount, firstQueueItem.amount))
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                end
        else
            queueTab.content.craftNextButton.clickCallback = nil
        end
    else
        queueTab.content.craftNextButton:SetEnabled(false)
    end

    local currentRecipeData = CraftSim.INIT.currentRecipeData

    if currentRecipeData then
        -- disable addCurrentRecipeButton if the currently open recipe is not suitable for queueing
        queueTab.content.addCurrentRecipeButton:SetEnabled(CraftSim.CRAFTQ:IsRecipeQueueable(currentRecipeData))
    else
        queueTab.content.addCurrentRecipeButton:SetEnabled(false)
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

--- called when switching tab or when ending scan on selected row
---@param activeTabResults CraftSim.RecipeData[]
function CraftSim.CRAFTQ.UI:UpdateRecipeScanRestockButton(activeTabResults)
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    local queueTab = craftQueueFrame.content.queueTab --[[@as CraftSim.CraftQueue.QueueTab]]
    local resultsPresent = #activeTabResults > 0
    queueTab.content.importRecipeScanButton:SetEnabled(resultsPresent)
end

function CraftSim.CRAFTQ.UI:UpdateRestockOptionsDisplay()
    if not CraftSim.CRAFTQ.frame then
        return
    end
    if CraftSim.INIT.currentRecipeData then
        local recipeData = CraftSim.INIT.currentRecipeData
        local restockOptionsTab = CraftSim.CRAFTQ.frame.content.restockOptionsTab
        ---@type CraftSim.CraftQueue.RestockOptions.RecipeOptionsFrame
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame
        local restockOptions = CraftSim.DB.OPTIONS:Get("CRAFTQUEUE_RESTOCK_PER_RECIPE_OPTIONS")

        if not CraftSim.CRAFTQ:IsRecipeQueueable(recipeData) then
            recipeOptionsFrame:Hide()
            return
        end

        local tsmLoaded = select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[1]))

        recipeOptionsFrame:Show()

        local generalOptionsFrame = restockOptionsTab.content.generalOptionsFrame
        generalOptionsFrame.saleRateTitle:SetVisible(tsmLoaded)
        generalOptionsFrame.saleRateInput:SetVisible(tsmLoaded)
        generalOptionsFrame.saleRateHelpIcon:SetVisible(tsmLoaded)

        local recipeIconText = GUTIL:IconToText(recipeData.recipeIcon, 25, 25)
        recipeOptionsFrame.recipeTitle:SetText(recipeIconText .. " " .. recipeData.recipeName)

        local initialRestockOptions = CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)

        ---@type CraftSim.CraftQueue.RestockOptions.TSMSaleRateFrame
        local tsmSaleRateFrame = recipeOptionsFrame.tsmSaleRateFrame

        -- adjust Quality Checkboxes Visibility, initialValue and Callbacks
        for qualityID = 1, 5 do
            local restockCB = recipeOptionsFrame.restockQualityCheckboxes[qualityID]
            local tsmSaleRateCB = tsmSaleRateFrame.qualityCheckboxes[qualityID]
            local hasQualityID = recipeData.resultData.itemsByQuality[qualityID] ~= nil
            restockCB:SetVisible(hasQualityID)
            restockCB:SetChecked(initialRestockOptions.restockPerQuality[qualityID])
            restockCB.clickCallback = function(_, checked)
                restockOptions[recipeData.recipeID].restockPerQuality = restockOptions[recipeData.recipeID]
                    .restockPerQuality or {}
                restockOptions[recipeData.recipeID].restockPerQuality[qualityID] = checked
            end

            tsmSaleRateCB:SetVisible(hasQualityID)
            tsmSaleRateCB:SetChecked(initialRestockOptions.saleRatePerQuality[qualityID])
            tsmSaleRateCB.clickCallback = function(_, checked)
                restockOptions[recipeData.recipeID].saleRatePerQuality =
                    restockOptions[recipeData.recipeID].saleRatePerQuality or {}
                restockOptions[recipeData.recipeID].saleRatePerQuality[qualityID] = checked
            end
        end
        recipeOptionsFrame.enableRecipeCheckbox:SetChecked(initialRestockOptions.enabled or false)
        recipeOptionsFrame.enableRecipeCheckbox.clickCallback = function(_, checked)
            restockOptions[recipeData.recipeID].enabled = checked
        end

        -- adjust numericInputs Visibility, initialValue and Callbacks
        recipeOptionsFrame.restockAmountInput.textInput:SetText(initialRestockOptions.restockAmount or 0)
        recipeOptionsFrame.restockAmountInput.onNumberValidCallback = function(input)
            local inputValue = tonumber(input.currentValue)
            restockOptions[recipeData.recipeID].restockAmount = inputValue
        end
        recipeOptionsFrame.profitMarginThresholdInput.textInput:SetText(initialRestockOptions.profitMarginThreshold or 0)
        recipeOptionsFrame.profitMarginThresholdInput.onNumberValidCallback = function(input)
            local inputValue = tonumber(input.currentValue)
            restockOptions[recipeData.recipeID].profitMarginThreshold = inputValue
        end
        -- Only show Sale Rate Input Stuff if TSM is loaded

        tsmSaleRateFrame.saleRateInput.textInput:SetText(initialRestockOptions.saleRateThreshold)
        tsmSaleRateFrame.saleRateInput.onNumberValidCallback = function(input)
            local inputValue = tonumber(input.currentValue)
            restockOptions[recipeData.recipeID].saleRateThreshold = inputValue
        end
        if tsmLoaded then
            tsmSaleRateFrame:Show()
        else
            tsmSaleRateFrame:Hide()
        end
    else
        local restockOptionsTab = CraftSim.CRAFTQ.frame.content.restockOptionsTab
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame
        recipeOptionsFrame:Hide()
    end
end

function CraftSim.CRAFTQ.UI:UpdateDisplay()
    CraftSim.CRAFTQ.UI:UpdateQueueDisplay()
    CraftSim.CRAFTQ.UI:UpdateRestockOptionsDisplay()
end

---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(craftQueueItem)
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
    local recipeData = craftQueueItem.recipeData
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
    editRecipeFrame.content.craftingCostsValue:SetText(GUTIL:ColorizeText(
        CraftSim.UTIL:FormatMoney(recipeData.priceData.craftingCosts), GUTIL.COLORS.RED) .. concentrationCostText)

    local reagentFrames = editRecipeFrame.content.reagentFrames

    -- required quality reagents
    if recipeData.hasQualityReagents then
        editRecipeFrame.content.q1Button:Show()
        editRecipeFrame.content.q2Button:Show()
        editRecipeFrame.content.q3Button:Show()

        -- show quality buttons and boxes
        ---@type CraftSim.Reagent[]
        local qualityReagents = GUTIL:Filter(recipeData.reagentData.requiredReagents, function(r) return r.hasQuality end)

        for index, reagentFrame in pairs(reagentFrames) do
            local reagent = qualityReagents[index]
            if reagent then
                reagentFrame.isActive = true
                reagentFrame.reagent = reagent
                reagentFrame:Show()
                reagentFrame.icon:SetItem(reagent.items[1].item)

                reagentFrame.maxQuantity = reagent.requiredQuantity
                reagentFrame.maxQuantityLabel:SetText("/ " .. reagentFrame.maxQuantity)

                reagentFrame.q1Input.textInput:SetText(reagent.items[1].quantity)
                reagentFrame.q2Input.textInput:SetText(reagent.items[2].quantity)
                reagentFrame.q3Input.textInput:SetText(reagent.items[3].quantity)
                reagentFrame.q1Input.currentValue = reagent.items[1].quantity
                reagentFrame.q2Input.currentValue = reagent.items[2].quantity
                reagentFrame.q3Input.currentValue = reagent.items[3].quantity
                reagentFrame.q1Input.reagentItem = reagent.items[1]
                reagentFrame.q2Input.reagentItem = reagent.items[2]
                reagentFrame.q3Input.reagentItem = reagent.items[3]
            else
                reagentFrame.isActive = false
                reagentFrame:Hide()
            end
        end
    else
        -- hide all boxes and quality buttons
        editRecipeFrame.content.q1Button:Hide()
        editRecipeFrame.content.q2Button:Hide()
        editRecipeFrame.content.q3Button:Hide()

        table.foreach(reagentFrames, function(_, reagentFrame)
            reagentFrame:Hide()
        end)
    end

    -- optionals
    local optionalSelectors = editRecipeFrame.content.optionalReagentSelectors
    editRecipeFrame.content.optionalReagentsFrame:SetCollapsed(#recipeData.reagentData.optionalReagentSlots == 0)
    editRecipeFrame.content.optionalReagentsTitle:SetVisible(#recipeData.reagentData.optionalReagentSlots > 0)
    for selectorIndex, selector in pairs(optionalSelectors) do
        local optionalSlot = recipeData.reagentData.optionalReagentSlots[selectorIndex]
        if optionalSlot then
            selector.slot = optionalSlot
            selector:SetItems(GUTIL:Map(optionalSlot.possibleReagents, function(pR) return pR.item end))
            if optionalSlot.activeReagent then
                selector:SetSelectedItem(optionalSlot.activeReagent.item)
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
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
            selector:SetItems(GUTIL:Map(finishingSlot.possibleReagents, function(pR) return pR.item end))
            if finishingSlot.activeReagent then
                selector:SetSelectedItem(finishingSlot.activeReagent.item)
            else
                selector:SetSelectedItem(nil)
            end
            selector:Show()
        else
            selector.slot = nil
            selector:Hide()
        end
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
    local editButtonColumn = columns[1] --[[@as CraftSim.CraftQueue.CraftList.EditButtonColumn]]
    local crafterColumn = columns[2] --[[@as CraftSim.CraftQueue.CraftList.CrafterColumn]]
    local recipeColumn = columns[3] --[[@as CraftSim.CraftQueue.CraftList.RecipeColumn]]
    local resultColumn = columns[4] --[[@as CraftSim.CraftQueue.CraftList.ResultColumn]]
    local averageProfitColumn = columns[5] --[[@as CraftSim.CraftQueue.CraftList.AverageProfitColumn]]
    local craftingCostsColumn = columns[6] --[[@as CraftSim.CraftQueue.CraftList.CraftingCostColumn]]
    local concentrationColumn = columns[7] --[[@as CraftSim.CraftQueue.CraftList.ConcentrationColumn]]
    local topGearColumn = columns[8] --[[@as CraftSim.CraftQueue.CraftList.TopGearColumn]]
    local craftAbleColumn = columns[9] --[[@as CraftSim.CraftQueue.CraftList.CraftAbleColumn]]
    local craftAmountColumn = columns[10] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
    local statusColumn = columns[11] --[[@as CraftSim.CraftQueue.CraftList.StatusColumn]]
    local craftButtonColumn = columns[12] --[[@as CraftSim.CraftQueue.CraftList.CraftButtonColumn]]
    local removeRowColumn = columns[13] --[[@as CraftSim.CraftQueue.CraftList.RemoveRowColumn]]

    row.craftQueueItem = craftQueueItem

    editButtonColumn.editButton.clickCallback = function()
        print("show edit recipe frame")
        CraftSim.CRAFTQ.UI:UpdateEditRecipeFrameDisplay(craftQueueItem)
        if not CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:IsVisible() then
            CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:Show()
        end
    end

    editButtonColumn.editButton:SetVisible(not row.craftQueueItem.recipeData:IsSubRecipe())

    crafterColumn.text:SetText(recipeData:GetFormattedCrafterText(true, true, 20, 20))

    -- update price data and profit?
    recipeData.priceData:Update()
    recipeData:GetAverageProfit()

    row.craftingCosts = recipeData.priceData.craftingCosts * craftQueueItem.amount


    row.averageProfit = (recipeData.averageProfitCached or recipeData:GetAverageProfit()) *
        craftQueueItem.amount

    local upCraftText = ""
    if craftQueueItem.recipeData:IsSubRecipe() then
        local upgradeArrow = CreateAtlasMarkup(CraftSim.CONST.ATLAS_TEXTURES.UPGRADE_ARROW_2, 10, 10)
        upCraftText = " " ..
            upgradeArrow --.. "(" .. craftQueueItem.recipeData.subRecipeDepth .. ")"
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
    else
        concentrationColumn.text:SetText(f.g("-"))
    end


    local craftAmountTooltipText = ""
    craftAmountTooltipText = "\n\nQueued Crafts: " .. craftQueueItem.amount

    row.tooltipOptions = {
        text = recipeData.reagentData:GetTooltipText(craftQueueItem.amount,
            craftQueueItem.recipeData:GetCrafterUID()) .. f.white(craftAmountTooltipText),
        owner = row.frame,
        anchor = "ANCHOR_CURSOR",
    }

    if craftQueueItem.gearEquipped and craftQueueItem:IsCrafter() then
        topGearColumn.equippedText:Show()
        topGearColumn.equippedText:SetEquipped()

        topGearColumn.gear1Icon:Hide()
        topGearColumn.gear2Icon:Hide()
        topGearColumn.toolIcon:Hide()
        topGearColumn.equipButton:Hide()
        topGearColumn.equipButton.clickCallback = nil
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
        if craftQueueItem:IsCrafter() then
            topGearColumn.equipButton:Show()
            topGearColumn.equipButton.clickCallback = function()
                recipeData.professionGearSet:Equip()
            end
        else
            topGearColumn.equipButton:Hide()
            topGearColumn.equipButton.clickCallback = nil
        end
    end

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
    craftButtonColumn.craftButton:SetEnabled(craftQueueItem.allowedToCraft)

    local statusIconDesaturationAlpha = 0.3

    if craftQueueItem.learned then
        statusColumn.learned:SetDesatured(false)
        statusColumn.learned:SetAlpha(1)
    else
        statusColumn.learned:SetDesatured(true)
        statusColumn.learned:SetAlpha(statusIconDesaturationAlpha)
    end
    if craftQueueItem.notOnCooldown then
        statusColumn.cooldown:SetDesatured(false)
        statusColumn.cooldown:SetAlpha(1)
    else
        statusColumn.cooldown:SetDesatured(true)
        statusColumn.cooldown:SetAlpha(statusIconDesaturationAlpha)
    end
    if craftQueueItem.isCrafter then
        statusColumn.crafter:SetDesatured(false)
        statusColumn.crafter:SetAlpha(1)
    else
        statusColumn.crafter:SetDesatured(true)
        statusColumn.crafter:SetAlpha(statusIconDesaturationAlpha)
    end
    if craftQueueItem.canCraftOnce then
        statusColumn.reagents:SetDesatured(false)
        statusColumn.reagents:SetAlpha(1)
    else
        statusColumn.reagents:SetDesatured(true)
        statusColumn.reagents:SetAlpha(statusIconDesaturationAlpha)
    end
    if craftQueueItem.gearEquipped then
        statusColumn.tools:SetDesatured(false)
        statusColumn.tools:SetAlpha(1)
    else
        statusColumn.tools:SetDesatured(true)
        statusColumn.tools:SetAlpha(statusIconDesaturationAlpha)
    end
    if craftQueueItem.correctProfessionOpen then
        statusColumn.profession:SetDesatured(false)
        statusColumn.profession:SetAlpha(1)
    else
        statusColumn.profession:SetDesatured(true)
        statusColumn.profession:SetAlpha(statusIconDesaturationAlpha)
    end

    if craftQueueItem.allowedToCraft then
        craftButtonColumn.craftButton.clickCallback = function()
            CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
            recipeData:Craft(craftQueueItem.amount)
            CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
        end
    end

    removeRowColumn.removeButton.clickCallback = function()
        CraftSim.CRAFTQ.craftQueue:Remove(craftQueueItem, true)
        CraftSim.CRAFTQ.UI:UpdateDisplay()
    end

    CraftSim.DEBUG:StopProfiling(profilingID)
end
