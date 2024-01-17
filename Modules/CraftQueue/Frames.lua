---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.CRAFTQ
CraftSim.CRAFTQ = CraftSim.CRAFTQ

---@class CraftSim.CRAFTQ.FRAMES
CraftSim.CRAFTQ.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)


function CraftSim.CRAFTQ.FRAMES:Init()
    local sizeX = 1000
    local sizeY = 420

    ---@class CraftSim.CraftQueue.Frame : GGUI.Frame
    CraftSim.CRAFTQ.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        frameStrata = "HIGH",
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesCraftQueue"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    ---@param frame CraftSim.CraftQueue.Frame
    local function createContent(frame)
        local tabContentSizeX = 930
        local tabContentSizeY = 330

        ---@class CraftSim.CraftQueue.Frame.Content : Frame
        frame.content = frame.content

        ---@type GGUI.BlizzardTab
        frame.content.queueTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                offsetY = -2,
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL),
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
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL)
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

        local columnOptions = {
            {
                label = "", -- edit button
                width = 35,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER),
                width = 130,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
                width = 150,
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
                width = 120,
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER),
                width = 100,
                justifyOptions = { type = "H", align = "RIGHT" }
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER), -- here a button is needed to switch to the top gear for this recipe
                width = 110,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT),
                width = 100,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER),
                width = 60,
                justifyOptions = { type = "H", align = "CENTER" }
            },
            {
                label = "", -- craftButtonColumn
                width = 120,
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
                        if craftQueueItem.correctProfessionOpen and craftQueueItem.recipeData then
                            C_TradeSkillUI.OpenRecipe(craftQueueItem.recipeData.recipeID)
                        end
                    end
                end
            },
            sizeY = 232,
            offsetY = -70,
            columnOptions = columnOptions,
            rowConstructor = function(columns)
                ---@class CraftSim.CraftQueue.CraftList.EditButtonColumn : Frame
                local editButtonColumn = columns[1]
                ---@class CraftSim.CraftQueue.CraftList.CrafterColumn : Frame
                local crafterColumn = columns[2]
                ---@class CraftSim.CraftQueue.CraftList.RecipeColumn : Frame
                local recipeColumn = columns[3]
                ---@class CraftSim.CraftQueue.CraftList.AverageProfitColumn : Frame
                local averageProfitColumn = columns[4]
                ---@class CraftSim.CraftQueue.CraftList.CraftingCostColumn : Frame
                local craftingCostsColumn = columns[5]
                ---@class CraftSim.CraftQueue.CraftList.TopGearColumn : Frame
                local topGearColumn = columns[6]
                ---@class CraftSim.CraftQueue.CraftList.CraftAbleColumn : Frame
                local craftAbleColumn = columns[7]
                ---@class CraftSim.CraftQueue.CraftList.CraftAmountColumn : Frame
                local craftAmountColumn = columns[8]
                ---@class CraftSim.CraftQueue.CraftList.CraftButtonColumn : Frame
                local craftButtonColumn = columns[9]
                ---@class CraftSim.CraftQueue.CraftList.RemoveRowColumn : Frame
                local removeRowColumn = columns[10]

                editButtonColumn.editButton = GGUI.Button({
                    parent = editButtonColumn,
                    anchorParent = editButtonColumn,
                    sizeX = 25,
                    sizeY = 25,
                    label = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.EDIT_PEN, 0.7),
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
                ---@type GGUI.Text | GGUI.Widget
                craftingCostsColumn.text = GGUI.Text(
                    {
                        parent = craftingCostsColumn,
                        anchorParent = craftingCostsColumn,
                        anchorA = "RIGHT",
                        anchorB =
                        "RIGHT",
                        scale = 0.9,
                        justifyOptions = { type = "H", align = "RIGHT" }

                    })

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
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_EQUIP),
                    clickCallback = nil, -- will be set in Add dynamically
                    adjustWidth = true,
                })

                function topGearColumn.equippedText:SetEquipped()
                    topGearColumn.equippedText:SetText(GUTIL:ColorizeText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED), GUTIL.COLORS.GREEN))
                end

                function topGearColumn.equippedText:SetIrrelevant()
                    topGearColumn.equippedText:SetText(GUTIL:ColorizeText("-", GUTIL.COLORS.GREY))
                end

                craftAbleColumn.text = GGUI.Text({
                    parent = craftAbleColumn, anchorParent = craftAbleColumn
                })

                craftAmountColumn.input = GGUI.NumericInput({
                    parent = craftAmountColumn,
                    anchorParent = craftAmountColumn,
                    sizeX = 50,
                    borderAdjustWidth = 1.13,
                    minValue = 1,
                    initialValue = 1,
                    onNumberValidCallback = nil -- set dynamically on Add
                })

                craftButtonColumn.craftButton = GGUI.Button({
                    parent = craftButtonColumn,
                    anchorParent = craftButtonColumn,
                    label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL),
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
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL),
            clickCallback = function()
                CraftSim.CRAFTQ:ImportRecipeScan()
            end
        })

        ---@type GGUI.Button
        queueTab.content.addCurrentRecipeButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.importRecipeScanButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            adjustWidth = true,
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL),
            clickCallback = function()
                CraftSim.CRAFTQ:AddOpenRecipe()
            end
        })

        ---@type GGUI.Button
        queueTab.content.clearAllButton = GGUI.Button({
            parent = queueTab.content,
            anchorParent = queueTab.content.addCurrentRecipeButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            offsetY = 0,
            adjustWidth = true,
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL),
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
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL),
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
                label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL)
            })
        end

        -- summaries

        queueTab.content.totalAverageProfitLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.importRecipeScanButton.frame,
            scale = 0.9 * 0.9,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 10,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL),
            justifyOptions = { type = "H", align = "RIGHT" }
        })
        queueTab.content.totalAverageProfit = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalAverageProfitLabel.frame,
            scale = 0.9 * 0.9,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = GUTIL:FormatMoney(0, true),
            justifyOptions = { type = "H", align = "LEFT" }
        })
        queueTab.content.totalCraftingCostsLabel = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalAverageProfitLabel.frame,
            scale = 0.9 * 0.9,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            offsetY = -19,
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL),
            justifyOptions = { type = "H", align = "RIGHT" }
        })
        queueTab.content.totalCraftingCosts = GGUI.Text({
            parent = queueTab.content,
            anchorParent = queueTab.content.totalCraftingCostsLabel.frame,
            scale = 0.9 * 0.9,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
            text = GUTIL:FormatMoney(0, true),
            justifyOptions = { type = "H", align = "RIGHT" }
        })


        queueTab.content.editRecipeFrame = CraftSim.CRAFTQ.FRAMES:InitEditRecipeFrame(queueTab.content, frame.content)

        -- restock Options

        restockOptionsTab.content.generalOptionsFrame = CreateFrame("frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.generalOptionsFrame:SetSize(150, 50)
        restockOptionsTab.content.generalOptionsFrame:SetPoint("TOP", restockOptionsTab.content, "TOP", 0, -10)
        local generalOptionsFrame = restockOptionsTab.content.generalOptionsFrame

        generalOptionsFrame.title = GGUI.Text {
            parent = generalOptionsFrame, anchorParent = generalOptionsFrame, anchorA = "TOP", anchorB = "TOP",
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL), scale = 1.2,
        }

        local profitMarginLabel = GGUI.Text({
            parent = generalOptionsFrame,
            anchorParent = generalOptionsFrame,
            anchorA = "TOP",
            anchorB = "TOP",
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL),
            offsetX = -25,
            offsetY = -30
        })

        generalOptionsFrame.profitMarginThresholdInput = GGUI.NumericInput({
            parent = generalOptionsFrame,
            anchorParent = profitMarginLabel.frame,
            initialValue = CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold or 0,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 10,
            allowDecimals = true,
            minValue = -math.huge,
            sizeX = 40,
            borderAdjustWidth = 1.2,
            onNumberValidCallback = function(numberInput)
                print("Updating craftQueueGeneralRestockProfitMarginThreshold: " .. tostring(numberInput.currentValue))
                CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold = tonumber(numberInput.currentValue or 0)
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
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY = -10,
        })

        generalOptionsFrame.restockAmountInput = GGUI.NumericInput {
            parent = generalOptionsFrame, anchorParent = generalOptionsFrame.restockAmountLabel.frame,
            initialValue = tonumber(CraftSimOptions.craftQueueGeneralRestockRestockAmount) or 1,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10, minValue = 1,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = function(input)
            local value = tostring(input.currentValue)
            CraftSimOptions.craftQueueGeneralRestockRestockAmount = value or 1
        end
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
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        generalOptionsFrame.saleRateInput = GGUI.NumericInput {
            parent = generalOptionsFrame, anchorParent = generalOptionsFrame.saleRateTitle.frame, initialValue = CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold or 0,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10,
            allowDecimals = true, minValue = 0,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = function(input)
            local value = input.currentValue
            CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold = tonumber(value)
        end
        }

        generalOptionsFrame.saleRateHelpIcon = GGUI.HelpIcon { parent = generalOptionsFrame, anchorParent = generalOptionsFrame.saleRateTitle.frame,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -2, text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL)
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
            anchorA = "TOP", anchorB = "BOTTOM", text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL),
            offsetY = 10, offsetX = 0 }

        recipeOptionsFrame.enableRecipeCheckbox = GGUI.Checkbox {
            parent = recipeOptionsFrame, anchorParent = enableRecipeLabel.frame, anchorA = "LEFT", anchorB = "RIGHT",
            tooltip = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP), offsetX = 15,
        }
        local recipeProfitMarginLabel = GGUI.Text({
            parent = recipeOptionsFrame,
            anchorParent = enableRecipeLabel.frame,
            anchorA = "TOPRIGHT",
            anchorB = "BOTTOMRIGHT",
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL),
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
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY = -10,
        }
        GGUI.HelpIcon { parent = recipeOptionsFrame, anchorParent = recipeOptionsFrame.restockAmountLabel.frame,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -2, text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP)
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
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        tsmSaleRateFrame.saleRateInput = GGUI.NumericInput {
            parent = tsmSaleRateFrame, anchorParent = tsmSaleRateFrame.saleRateTitle.frame, initialValue = 0,
            anchorA = "LEFT", anchorB = "RIGHT", offsetX = 10,
            allowDecimals = true, minValue = 0,
            sizeX = 40, borderAdjustWidth = 1.2, onNumberValidCallback = nil -- set dynamically
        }

        tsmSaleRateFrame.helpIcon = GGUI.HelpIcon { parent = tsmSaleRateFrame, anchorParent = tsmSaleRateFrame.saleRateTitle.frame,
            anchorA = "RIGHT", anchorB = "LEFT", offsetX = -2, text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP)
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
function CraftSim.CRAFTQ.FRAMES:InitEditRecipeFrame(parent, anchorParent)
    local editFrameX = 600
    local editFrameY = 330
    ---@class CraftSim.CRAFTQ.EditRecipeFrame : GGUI.Frame
    local editRecipeFrame = GGUI.Frame {
        parent = parent, anchorParent = anchorParent,
        sizeX = editFrameX, sizeY = editFrameY, backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameID = CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE, frameTable = CraftSim.MAIN.FRAMES,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE),
        frameStrata = "DIALOG", closeable = true, closeOnClickOutside = true, moveable = true, frameConfigTable = CraftSimGGUIConfig,
    }

    ---@type CraftSim.CraftQueueItem?
    editRecipeFrame.craftQueueItem = nil

    ---@class CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.title.frame, anchorA = "TOP", anchorB = "BOTTOM",
        text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL), scale = 1.5, offsetY = -10,
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
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    editRecipeFrame.content.q2Button = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.q1Button.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = qButtonSpacingX,
        label = GUTIL:GetQualityIconString(2, qIconSize, qIconSize), sizeX = qButtonSize, sizeY = qButtonSize,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.reagentData:SetReagentsMaxByQuality(2)
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }
    editRecipeFrame.content.q3Button = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.q2Button.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = qButtonSpacingX,
        label = GUTIL:GetQualityIconString(3, qIconSize, qIconSize, 1), sizeX = qButtonSize, sizeY = qButtonSize,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData.reagentData:SetReagentsMaxByQuality(3)
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
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
        ---@class CraftSim.CRAFTQ.FRAMES.ReagentFrame : Frame
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

        ---@param reagentInput CraftSim.CRAFTQ.FRAMES.ReagentInput
        local function onReagentInput(reagentInput)
            if reagentFrame:IsRequiredQuantity() then
                -- reagentFrame.maxQuantityLabel:SetText("test")
                reagentFrame.maxQuantityLabel:SetColor(GUTIL.COLORS.WHITE)

                -- if all reagentFrames are valid, update recipe
                if editRecipeFrame:ValidateReagentQuantities() then
                    editRecipeFrame:UpdateReagentQuantities()
                    editRecipeFrame.craftQueueItem.recipeData:Update()
                    CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
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

        ---@class CraftSim.CRAFTQ.FRAMES.ReagentInput : GGUI.NumericInput
        ---@field reagentItem CraftSim.ReagentItem?
        reagentFrame.q1Input = GGUI.NumericInput {
            parent = reagentFrame, anchorParent = reagentFrame.icon.frame, minValue = 0, incrementOneButtons = true, sizeX = 30, anchorA = "LEFT", anchorB = "RIGHT",
            offsetX = 10, onNumberValidCallback = onReagentInput, borderAdjustWidth = 1.3,
        }

        ---@class CraftSim.CRAFTQ.FRAMES.ReagentInput
        reagentFrame.q2Input = GGUI.NumericInput {
            parent = reagentFrame, anchorParent = reagentFrame.q1Input.textInput.frame, minValue = 0, incrementOneButtons = true, sizeX = 30, anchorA = "LEFT", anchorB = "RIGHT",
            offsetX = reagentFramesInputSpacingX, onNumberValidCallback = onReagentInput, borderAdjustWidth = 1.3,
        }

        ---@class CraftSim.CRAFTQ.FRAMES.ReagentInput
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
    ---@type CraftSim.CRAFTQ.FRAMES.ReagentFrame[]
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
        text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL), justifyOptions = { type = "H", align = "LEFT" }
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
            title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL), anchorA = anchorA, anchorB = anchorB, offsetX = offsetX, offsetY = offsetY
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
            CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
            CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
        end
    end

    local numOptionalReagentSelectors = 3
    for _ = 1, numOptionalReagentSelectors do
        CreateItemSelector(optionalReagentsFrame, editRecipeFrame.content.optionalReagentsTitle.frame,
            editRecipeFrame.content.optionalReagentSelectors, OnSelectOptionalReagent)
    end

    editRecipeFrame.content.finishingReagentsTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = optionalReagentsFrame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL), justifyOptions = { type = "H", align = "LEFT" }
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
        text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL), justifyOptions = { type = "H", align = "LEFT" }
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
                    CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                    CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
                end)
            else
                print("setting gear to no gear")
                itemSelector.professionGear:SetItem(nil)
                editRecipeFrame.craftQueueItem.recipeData.professionGearSet:UpdateProfessionStats()
                editRecipeFrame.craftQueueItem.recipeData:Update()
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    end

    for _ = 1, 3 do
        CreateItemSelector(editRecipeFrame.content, editRecipeFrame.content.professionGearTitle.frame,
            editRecipeFrame.content.professionGearSelectors, OnSelectProfessionGear, "TOPRIGHT", "TOPLEFT", 0, -25)
    end

    editRecipeFrame.content.optimizeReagents = GGUI.Button {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.professionGearTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -50,
        label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON), adjustWidth = true,
        clickCallback = function()
            if editRecipeFrame.craftQueueItem and editRecipeFrame.craftQueueItem.recipeData then
                editRecipeFrame.craftQueueItem.recipeData:OptimizeProfit(true)
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
                CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(editRecipeFrame.craftQueueItem)
            end
        end
    }

    editRecipeFrame.content.craftingCostsTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content, anchorA = "BOTTOM", anchorB = "BOTTOM", offsetX = -30,
        offsetY = 40, text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL),
    }
    editRecipeFrame.content.craftingCostsValue = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.craftingCostsTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        text = GUTIL:FormatMoney(0, true), justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9, offsetY = -1,
    }
    editRecipeFrame.content.averageProfitTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.craftingCostsTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -5, text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL),
    }
    editRecipeFrame.content.averageProfitValue = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.averageProfitTitle.frame, anchorA = "LEFT", anchorB = "RIGHT", offsetX = 5,
        text = GUTIL:FormatMoney(0, true), justifyOptions = { type = "H", align = "LEFT" }, scale = 0.9, offsetY = -1,
    }

    editRecipeFrame.content.resultTitle = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.optimizeReagents.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -5, text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL),
    }
    local resultItemSize = 25
    editRecipeFrame.content.expectedItemIcon = GGUI.Icon {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.resultTitle.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -5, sizeX = resultItemSize, sizeY = resultItemSize,
    }
    editRecipeFrame.content.expectedItemChance = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.expectedItemIcon.frame, anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 10, text = "?? %"
    }
    editRecipeFrame.content.firstUpgradeItemIcon = GGUI.Icon {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.expectedItemIcon.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -5, sizeX = resultItemSize, sizeY = resultItemSize,
    }
    editRecipeFrame.content.firstUpgradeItemChance = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.firstUpgradeItemIcon.frame, anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 10, text = "?? %"
    }
    editRecipeFrame.content.secondUpgradeItemIcon = GGUI.Icon {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.firstUpgradeItemIcon.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
        offsetY = -5, sizeX = resultItemSize, sizeY = resultItemSize,
    }
    editRecipeFrame.content.secondUpgradeItemChance = GGUI.Text {
        parent = editRecipeFrame.content, anchorParent = editRecipeFrame.content.secondUpgradeItemIcon.frame, anchorA = "LEFT", anchorB = "RIGHT",
        offsetX = 10, text = "?? %"
    }

    editRecipeFrame:Hide()
    return editRecipeFrame
end

function CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    local f = CraftSim.UTIL:GetFormatter()
    -- multiples should be possible (different reagent setup)
    -- but if there already is a configuration just increase the count?

    CraftSim.UTIL:StartProfiling("FrameListUpdate")

    ---@type GGUI.Tab
    local queueTab = CraftSim.CRAFTQ.frame.content.queueTab
    ---@type GGUI.FrameList
    local craftList = queueTab.content.craftList

    local craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue()

    --- precalculate craftable status before sorting to increase performance
    table.foreach(craftQueue.craftQueueItems,
        ---@param _ any
        ---@param craftQueueItem CraftSim.CraftQueueItem
        function(_, craftQueueItem)
            craftQueueItem:CalculateCanCraft()
        end)

    CraftSim.UTIL:StartProfiling("- FrameListUpdate Sort Queue")
    craftQueue.craftQueueItems = GUTIL:Sort(craftQueue.craftQueueItems,
        ---@param craftQueueItemA CraftSim.CraftQueueItem
        ---@param craftQueueItemB CraftSim.CraftQueueItem
        function(craftQueueItemA, craftQueueItemB)
            local allowedToCraftA = craftQueueItemA.allowedToCraft
            local allowedToCraftB = craftQueueItemB.allowedToCraft

            -- if both are same, sort by average profit of recipe
            if allowedToCraftA == allowedToCraftB then
                return craftQueueItemA.recipeData.averageProfitCached > craftQueueItemB.recipeData.averageProfitCached
            end

            if allowedToCraftA and not allowedToCraftB then
                CraftSim.UTIL:ProfilingUpdate("- FrameListUpdate Sort Queue")
                return true
            end
            if not allowedToCraftA and allowedToCraftB then
                CraftSim.UTIL:ProfilingUpdate("- FrameListUpdate Sort Queue")
                return false
            end
            CraftSim.UTIL:ProfilingUpdate("- FrameListUpdate Sort Queue")
            return false
        end)
    CraftSim.UTIL:StopProfiling("- FrameListUpdate Sort Queue")

    craftList:Remove()

    local totalAverageProfit = 0
    local totalCraftingCosts = 0

    CraftSim.UTIL:StartProfiling("- FrameListUpdate Add Rows")
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        local recipeData = craftQueueItem.recipeData
        craftList:Add(
            function(row)
                local profilingID = "- FrameListUpdate Add Recipe: " .. craftQueueItem.recipeData.recipeName
                CraftSim.UTIL:StartProfiling(profilingID)
                local columns = row.columns
                local editButtonColumn = columns[1] --[[@as CraftSim.CraftQueue.CraftList.EditButtonColumn]]
                local crafterColumn = columns[2] --[[@as CraftSim.CraftQueue.CraftList.CrafterColumn]]
                local recipeColumn = columns[3] --[[@as CraftSim.CraftQueue.CraftList.RecipeColumn]]
                local averageProfitColumn = columns[4] --[[@as CraftSim.CraftQueue.CraftList.AverageProfitColumn]]
                local craftingCostsColumn = columns[5] --[[@as CraftSim.CraftQueue.CraftList.CraftingCostColumn]]
                local topGearColumn = columns[6] --[[@as CraftSim.CraftQueue.CraftList.TopGearColumn]]
                local craftAbleColumn = columns[7] --[[@as CraftSim.CraftQueue.CraftList.CraftAbleColumn]]
                local craftAmountColumn = columns[8] --[[@as CraftSim.CraftQueue.CraftList.CraftAmountColumn]]
                local craftButtonColumn = columns[9] --[[@as CraftSim.CraftQueue.CraftList.CraftButtonColumn]]
                local removeRowColumn = columns[10] --[[@as CraftSim.CraftQueue.CraftList.RemoveRowColumn]]

                row.craftQueueItem = craftQueueItem

                editButtonColumn.editButton.clickCallback = function()
                    print("show edit recipe frame")
                    CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(craftQueueItem)
                    if not CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:IsVisible() then
                        CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:Show()
                    end
                end

                local classColor = C_ClassColor.GetClassColor(craftQueueItem.crafterData.class)
                crafterColumn.text:SetText(classColor:WrapTextInColorCode(craftQueueItem.recipeData:GetCrafterUID()))

                -- update price data and profit?
                recipeData.priceData:Update()
                recipeData:GetAverageProfit()
                local craftingCosts = recipeData.priceData.craftingCosts * craftQueueItem.amount
                totalCraftingCosts = totalCraftingCosts + craftingCosts

                local averageProfit = (recipeData.averageProfitCached or recipeData:GetAverageProfit()) *
                    craftQueueItem.amount
                totalAverageProfit = totalAverageProfit + averageProfit
                recipeColumn.text:SetText(recipeData.recipeName)
                averageProfitColumn.text:SetText(GUTIL:FormatMoney(select(1, averageProfit), true, craftingCosts))

                craftingCostsColumn.text:SetText(f.r(GUTIL:FormatMoney(craftingCosts)))

                row.tooltipOptions = {
                    text = recipeData.reagentData:GetTooltipText(craftQueueItem.amount),
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

                craftAmountColumn.input.textInput:SetText(craftQueueItem.amount, false)
                craftAmountColumn.input.onNumberValidCallback =
                ---@param numericInput GGUI.NumericInput
                    function(numericInput)
                        craftQueueItem.amount = tonumber(numericInput.currentValue) or 1
                        CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
                    end

                craftButtonColumn.craftButton.clickCallback = nil
                craftButtonColumn.craftButton:SetEnabled(craftQueueItem.allowedToCraft)

                if craftQueueItem.allowedToCraft then
                    craftButtonColumn.craftButton.clickCallback = function()
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                        recipeData:Craft()
                        CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                    end
                    craftButtonColumn.craftButton:SetText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL), nil, true)
                elseif not craftQueueItem.isCrafter then
                    craftButtonColumn.craftButton:SetText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER),
                        nil,
                        true)
                elseif not craftQueueItem.correctProfessionOpen then
                    craftButtonColumn.craftButton:SetText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION),
                        nil,
                        true)
                elseif not craftQueueItem.notOnCooldown then
                    craftButtonColumn.craftButton:SetText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN), nil,
                        true)
                elseif not craftQueueItem.canCraftOnce then
                    craftButtonColumn.craftButton:SetText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_MATS), nil, true)
                elseif not craftQueueItem.gearEquipped then
                    craftButtonColumn.craftButton:SetText(
                        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR), nil,
                        true)
                end

                removeRowColumn.removeButton.clickCallback = function()
                    CraftSim.CRAFTQ.craftQueue:SetAmount(craftQueueItem.recipeData, 0) -- to delete it
                    CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
                end

                CraftSim.UTIL:StopProfiling(profilingID)
            end)
    end

    CraftSim.UTIL:StopProfiling("- FrameListUpdate Add Rows")


    --- sort by craftable status
    craftList:UpdateDisplay()

    queueTab.content.totalAverageProfit:SetText(GUTIL:FormatMoney(totalAverageProfit, true, totalCraftingCosts))
    queueTab.content.totalCraftingCosts:SetText(f.r(GUTIL:FormatMoney(totalCraftingCosts)))

    craftQueue:CacheQueueItems() -- Is this a good time to cache it?


    CraftSim.UTIL:StopProfiling("FrameListUpdate")
end

function CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
    --- use a cache to prevent multiple redundant calls of ItemCount thus increasing performance
    CraftSim.CRAFTQ.itemCountCache = {}

    CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    ---@type GGUI.Tab
    local queueTab = craftQueueFrame.content.queueTab

    queueTab.content.importRecipeScanButton:SetEnabled(GUTIL:Count(CraftSim.RECIPE_SCAN.currentResults) > 0)
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    print("update display")
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

    local currentRecipeData = CraftSim.MAIN.currentRecipeData

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

function CraftSim.CRAFTQ.FRAMES:UpdateRestockOptionsDisplay()
    if not CraftSim.CRAFTQ.frame then
        return
    end
    if CraftSim.MAIN.currentRecipeData then
        local recipeData = CraftSim.MAIN.currentRecipeData
        local restockOptionsTab = CraftSim.CRAFTQ.frame.content.restockOptionsTab
        ---@type CraftSim.CraftQueue.RestockOptions.RecipeOptionsFrame
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame

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

        CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID] = CraftSimOptions
            .craftQueueRestockPerRecipeOptions[recipeData.recipeID] or
            CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)
        --- only use for setting of initial values of checkboxes and such
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
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockPerQuality =
                    CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockPerQuality or {}
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockPerQuality[qualityID] =
                    checked
            end

            tsmSaleRateCB:SetVisible(hasQualityID)
            tsmSaleRateCB:SetChecked(initialRestockOptions.saleRatePerQuality[qualityID])
            tsmSaleRateCB.clickCallback = function(_, checked)
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRatePerQuality =
                    CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRatePerQuality or {}
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRatePerQuality[qualityID] =
                    checked
            end
        end
        recipeOptionsFrame.enableRecipeCheckbox:SetChecked(initialRestockOptions.enabled or false)
        recipeOptionsFrame.enableRecipeCheckbox.clickCallback = function(_, checked)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].enabled = checked
        end

        -- adjust numericInputs Visibility, initialValue and Callbacks
        recipeOptionsFrame.restockAmountInput.textInput:SetText(initialRestockOptions.restockAmount or 0)
        recipeOptionsFrame.restockAmountInput.onNumberValidCallback = function(input)
            local inputValue = tonumber(input.currentValue)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockAmount = inputValue
        end
        recipeOptionsFrame.profitMarginThresholdInput.textInput:SetText(initialRestockOptions.profitMarginThreshold or 0)
        recipeOptionsFrame.profitMarginThresholdInput.onNumberValidCallback = function(input)
            local inputValue = tonumber(input.currentValue)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].profitMarginThreshold = inputValue
        end
        -- Only show Sale Rate Input Stuff if TSM is loaded

        tsmSaleRateFrame.saleRateInput.textInput:SetText(initialRestockOptions.saleRateThreshold)
        tsmSaleRateFrame.saleRateInput.onNumberValidCallback = function(input)
            local inputValue = tonumber(input.currentValue)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRateThreshold = inputValue
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

function CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
    CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
    CraftSim.CRAFTQ.FRAMES:UpdateRestockOptionsDisplay()
end

---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrameDisplay(craftQueueItem)
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
    local recipeData = craftQueueItem.recipeData
    editRecipeFrame.craftQueueItem = craftQueueItem
    ---@type CraftSim.CRAFTQ.EditRecipeFrame.Content
    editRecipeFrame.content = editRecipeFrame.content

    editRecipeFrame.content.recipeName:SetText(GUTIL:IconToText(recipeData.recipeIcon, 15, 15) ..
        " " .. recipeData.recipeName)
    editRecipeFrame.content.averageProfitValue:SetText(GUTIL:FormatMoney(recipeData.averageProfitCached, true,
        recipeData.priceData.craftingCosts))
    editRecipeFrame.content.craftingCostsValue:SetText(GUTIL:ColorizeText(
        GUTIL:FormatMoney(recipeData.priceData.craftingCosts), GUTIL.COLORS.RED))

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

    editRecipeFrame.content.expectedItemIcon:SetItem(resultData.expectedItem)
    if resultData.chanceByQuality[resultData.expectedQuality] then
        editRecipeFrame.content.expectedItemChance:SetText(GUTIL:Round(
            resultData.chanceByQuality[resultData.expectedQuality] * 100, 1) .. " %")
    else
        editRecipeFrame.content.expectedItemChance:SetText("100 %")
    end

    if resultData.chanceByQuality[resultData.expectedQuality + 1] and resultData.chanceByQuality[resultData.expectedQuality + 1] > 0 then
        editRecipeFrame.content.firstUpgradeItemIcon.frame:SetSize(25, 25)
        editRecipeFrame.content.firstUpgradeItemIcon:Show()
        editRecipeFrame.content.firstUpgradeItemChance:Show()
        editRecipeFrame.content.firstUpgradeItemIcon:SetItem(resultData.itemsByQuality[resultData.expectedQuality + 1])
        editRecipeFrame.content.firstUpgradeItemChance:SetText(GUTIL:Round(
            resultData.chanceByQuality[resultData.expectedQuality + 1] * 100, 1) .. " %")
    else
        editRecipeFrame.content.firstUpgradeItemIcon:Hide()
        editRecipeFrame.content.firstUpgradeItemIcon.frame:SetSize(25, 0.01)
        editRecipeFrame.content.firstUpgradeItemChance:Hide()
    end

    if resultData.chanceByQuality[resultData.expectedQuality + 2] and resultData.chanceByQuality[resultData.expectedQuality + 2] > 0 then
        editRecipeFrame.content.secondUpgradeItemIcon:Show()
        editRecipeFrame.content.secondUpgradeItemChance:Show()
        editRecipeFrame.content.secondUpgradeItemIcon:SetItem(resultData.itemsByQuality[resultData.expectedQuality + 2])
        editRecipeFrame.content.secondUpgradeItemChance:SetText(GUTIL:Round(
            resultData.chanceByQuality[resultData.expectedQuality + 2] * 100, 1) .. " %")
    else
        editRecipeFrame.content.secondUpgradeItemIcon:Hide()
        editRecipeFrame.content.secondUpgradeItemChance:Hide()
    end
end
