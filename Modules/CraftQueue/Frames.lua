---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI

---@class CraftSim.CRAFTQ
CraftSim.CRAFTQ = CraftSim.CRAFTQ

---@class CraftSim.CRAFTQ.FRAMES
CraftSim.CRAFTQ.FRAMES = {}

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)


function CraftSim.CRAFTQ.FRAMES:Init()
    local sizeX=1000
    local sizeY=420

    ---@class CraftSim.CraftQueue.Frame : GGUI.Frame
    CraftSim.CRAFTQ.frame = GGUI.Frame({
            parent=ProfessionsFrame.CraftingPage.SchematicForm, 
            anchorParent=ProfessionsFrame.CraftingPage.SchematicForm,
            sizeX=sizeX,sizeY=sizeY,
            frameID=CraftSim.CONST.FRAMES.CRAFT_QUEUE, 
            title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE),
            collapseable=true,
            closeable=true,
            moveable=true,
            frameStrata="HIGH",
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCraftQueue"),
            frameTable=CraftSim.MAIN.FRAMES,
            frameConfigTable=CraftSimGGUIConfig,
        })

        ---@param frame CraftSim.CraftQueue.Frame
    local function createContent(frame)

        local tabContentSizeX = 930
        local tabContentSizeY = 330

        ---@class CraftSim.CraftQueue.Frame.Content : Frame
        frame.content = frame.content

        ---@type GGUI.Tab
        frame.content.queueTab = GGUI.Tab({
            buttonOptions={parent=frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="BOTTOM", offsetX=-62, offsetY=-20, 
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL), adjustWidth=true},
            parent=frame.content,anchorParent=frame.content, sizeX=tabContentSizeX, sizeY=tabContentSizeY, canBeEnabled=true, offsetY=-30,
        })
        ---@type GGUI.Tab
        frame.content.restockOptionsTab = GGUI.Tab({
            buttonOptions={parent=frame.content, anchorParent=frame.content.queueTab.button.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=5, 
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL), adjustWidth=true},
            parent=frame.content,anchorParent=frame.content, sizeX=tabContentSizeX, sizeY=tabContentSizeY, canBeEnabled=true, offsetY=-30,
        })
        local restockOptionsTab = frame.content.restockOptionsTab
        local queueTab = frame.content.queueTab

        GGUI.TabSystem({queueTab, restockOptionsTab})

        local columnOptions = {
            {
                label="", -- edit button
                width=35,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
                width=150,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
                width=120,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER),
                width=100,
                justifyOptions={type="H", align="RIGHT"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_REAGENT_INFO_HEADER),
                width=75,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER), -- here a button is needed to switch to the top gear for this recipe
                width=110,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT),
                width=100,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER),
                width=60,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="", -- craftButtonColumn
                width=120,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="", -- remove row column
                width=30,
                justifyOptions={type="H", align="CENTER"}
            }
        }

        ---@type GGUI.FrameList
        queueTab.content.craftList = GGUI.FrameList({
            parent = queueTab.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP",
            showHeaderLine=true, scale=0.95, showBorder=true,
            selectionOptions = {
                hoverRGBA={1, 1, 1, 0.1},
                noSelectionColor=true,
                selectionCallback=function (row)
                    ---@type CraftSim.CraftQueueItem
                    local craftQueueItem = row.craftQueueItem
                    if craftQueueItem then
                        if craftQueueItem.correctProfessionOpen and craftQueueItem.recipeData then
                            C_TradeSkillUI.OpenRecipe(craftQueueItem.recipeData.recipeID)
                        end
                    end
                end
            },
            sizeY=230, offsetY=-90,
            columnOptions=columnOptions,
            rowConstructor=function (columns)
                local editButtonColumn = columns[1]
                local recipeColumn = columns[2] 
                local averageProfitColumn = columns[3]
                local craftingCostsColumn = columns[4]
                local reagentInfoColumn = columns[5]
                local topGearColumn = columns[6]
                local craftAbleColumn = columns[7]
                local craftAmountColumn = columns[8] 
                local craftButtonColumn = columns[9]
                local removeRowColumn = columns[10]

                editButtonColumn.editButton = GGUI.Button({
                    parent=editButtonColumn, anchorParent=editButtonColumn, sizeX=25, sizeY=25,
                    label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.EDIT_PEN, 0.7),
                })

                recipeColumn.text = GGUI.Text({
                    parent=recipeColumn,anchorParent=recipeColumn,anchorA="LEFT",anchorB="LEFT", justifyOptions={type="H",align="LEFT"}, scale=0.9,
                    fixedWidth=recipeColumn:GetWidth(), wrap=true,
                })

                local iconSize = 23
                
                ---@type GGUI.Text | GGUI.Widget
                averageProfitColumn.text = GGUI.Text(
                { 
                    parent=averageProfitColumn,anchorParent=averageProfitColumn, anchorA="LEFT", anchorB="LEFT", scale = 0.9,

                })
                ---@type GGUI.Text | GGUI.Widget
                craftingCostsColumn.text = GGUI.Text(
                { 
                    parent=craftingCostsColumn,anchorParent=craftingCostsColumn, anchorA="RIGHT", anchorB="RIGHT", scale = 0.9, justifyOptions={type="H",align="RIGHT"}

                })

                reagentInfoColumn.reagentInfoButton = GGUI.HelpIcon({
                    parent=reagentInfoColumn, anchorParent=reagentInfoColumn,
                    text="No Data", label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_REAGENT_INFO_BUTTON_LABEL)
                })

                topGearColumn.gear2Icon = GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn, sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.2,
                })

                topGearColumn.gear1Icon = GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn.gear2Icon.frame, anchorA="RIGHT", anchorB="LEFT", sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.2, offsetX=-5,
                })
                topGearColumn.toolIcon = GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn.gear2Icon.frame, anchorA="LEFT", anchorB="RIGHT", sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.2, offsetX=5
                })
                topGearColumn.equippedText = GGUI.Text({
                    parent=topGearColumn, anchorParent=topGearColumn
                })

                topGearColumn.equipButton = GGUI.Button({
                    parent=topGearColumn, anchorParent=topGearColumn.toolIcon.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=2,
                    label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_EQUIP), clickCallback = nil, -- will be set in Add dynamically
                    adjustWidth=true,
                })

                function topGearColumn.equippedText:SetEquipped()
                    topGearColumn.equippedText:SetText(CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED), CraftSim.GUTIL.COLORS.GREEN))
                end
                function topGearColumn.equippedText:SetIrrelevant()
                    topGearColumn.equippedText:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end

                craftAbleColumn.text = GGUI.Text({
                    parent=craftAbleColumn, anchorParent=craftAbleColumn
                })

                craftAmountColumn.input = GGUI.NumericInput({
                    parent=craftAmountColumn, anchorParent = craftAmountColumn, sizeX=50, borderAdjustWidth=1.13,
                    minValue=1, initialValue=1, onNumberValidCallback=nil -- set dynamically on Add
                })

                craftButtonColumn.craftButton = GGUI.Button({
                    parent=craftButtonColumn, anchorParent=craftButtonColumn,
                    label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL),
                    adjustWidth=true, secure=true,
                })

                removeRowColumn.removeButton = GGUI.Button({
                    parent=removeRowColumn, anchorParent=removeRowColumn,
                    label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.1),
                    sizeX=25, clickCallback = nil -- set dynamically in Add
                })
            end
        })

        local craftQueueButtonsOffsetY=-5

        ---@type GGUI.Button
        queueTab.content.importRecipeScanButton = GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.craftList.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=craftQueueButtonsOffsetY, offsetX=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:ImportRecipeScan()
            end
        })

        ---@type GGUI.Button
        queueTab.content.addCurrentRecipeButton = GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.importRecipeScanButton.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:AddOpenRecipe()
            end
        })

        ---@type GGUI.Button
        queueTab.content.clearAllButton = GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.addCurrentRecipeButton.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:ClearAll()
            end
        })

        ---@type GGUI.Button
        queueTab.content.craftNextButton = GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.craftList.frame, anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=craftQueueButtonsOffsetY, offsetX=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL), clickCallback=nil
        })


        if select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
            ---@type GGUI.Button
            queueTab.content.createAuctionatorShoppingList = GGUI.Button({
                parent=queueTab.content, anchorParent=queueTab.content, anchorA="BOTTOM", anchorB="BOTTOM", adjustWidth=true, offsetY=0,
                clickCallback=function ()
                    CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
                end,
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL)
            })
        end

        -- summaries

        queueTab.content.totalAverageProfitLabel = GGUI.Text({parent=queueTab.content, anchorParent=queueTab.content.importRecipeScanButton.frame,
            scale=0.9*0.9, anchorA="LEFT", anchorB="RIGHT", offsetX=10, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL),
            justifyOptions={type="H", align="RIGHT"}
        })
        queueTab.content.totalAverageProfit = GGUI.Text({parent=queueTab.content, anchorParent=queueTab.content.totalAverageProfitLabel.frame,
            scale=0.9*0.9, anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.GUTIL:FormatMoney(0, true),
            justifyOptions={type="H", align="LEFT"}
        })
        queueTab.content.totalCraftingCostsLabel = GGUI.Text({parent=queueTab.content, anchorParent=queueTab.content.totalAverageProfitLabel.frame,
            scale=0.9*0.9, anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=-19, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL),
            justifyOptions={type="H", align="RIGHT"}
        })
        queueTab.content.totalCraftingCosts = GGUI.Text({parent=queueTab.content, anchorParent=queueTab.content.totalCraftingCostsLabel.frame,
            scale=0.9*0.9, anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.GUTIL:FormatMoney(0, true),
            justifyOptions={type="H", align="RIGHT"}
        })

        
        queueTab.content.editRecipeFrame = CraftSim.CRAFTQ.FRAMES:InitEditRecipeFrame(queueTab.content, frame.content)

        -- restock Options

        restockOptionsTab.content.generalOptionsFrame = CreateFrame("frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.generalOptionsFrame:SetSize(150, 50)
        restockOptionsTab.content.generalOptionsFrame:SetPoint("TOP", restockOptionsTab.content, "TOP", 0, -50)
        local generalOptionsFrame = restockOptionsTab.content.generalOptionsFrame

        generalOptionsFrame.title = GGUI.Text{
            parent=generalOptionsFrame, anchorParent=generalOptionsFrame, anchorA="TOP", anchorB="TOP",
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL), scale=1.2,
        }

        local profitMarginLabel = GGUI.Text({parent=generalOptionsFrame, anchorParent=generalOptionsFrame, 
            anchorA="TOP", anchorB="TOP", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL), 
            offsetX=-25, offsetY=-30})

        generalOptionsFrame.profitMarginThresholdInput = GGUI.NumericInput({
            parent=generalOptionsFrame, anchorParent=profitMarginLabel.frame, initialValue = CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold or 0, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
            allowDecimals=true,minValue=-math.huge,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=function (numberInput)
                print("Updating craftQueueGeneralRestockProfitMarginThreshold: " .. tostring(numberInput.currentValue))
                CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold = tonumber(numberInput.currentValue or 0)
            end
        })
        -- %
        GGUI.Text({parent=generalOptionsFrame, anchorParent=generalOptionsFrame.profitMarginThresholdInput.textInput.frame, 
            anchorA="LEFT", anchorB="RIGHT", text="%", offsetX=2})        

        generalOptionsFrame.restockAmountLabel = GGUI.Text({parent=generalOptionsFrame, anchorParent=profitMarginLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY=-10,
        })

        generalOptionsFrame.restockAmountInput = GGUI.NumericInput{
            parent=generalOptionsFrame, anchorParent=generalOptionsFrame.restockAmountLabel.frame, 
            initialValue = tonumber(CraftSimOptions.craftQueueGeneralRestockRestockAmount) or 1, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10, minValue=1,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=function (input)
                local value = tostring(input.currentValue)
                CraftSimOptions.craftQueueGeneralRestockRestockAmount = value or 1
            end
        }

        local qualityIconSize = 20
        local qualityCheckboxBaseOffsetX=10
        local qualityCheckboxSpacingX=50
        local function createQualityCheckbox(p, a, qualityID, oX, oY)
            oX = oX or -2
            oY = oY or -2.8
            return GGUI.Checkbox{
                parent=p, anchorParent=a, 
                anchorA="LEFT", anchorB="RIGHT", offsetX=qualityCheckboxBaseOffsetX+qualityCheckboxSpacingX*(qualityID-1), 
                label=CraftSim.GUTIL:GetQualityIconString(qualityID, qualityIconSize, qualityIconSize, oX, oY)}
        end

        -- always create the inputs and such but only show when tsm is loaded
        generalOptionsFrame.saleRateTitle = GGUI.Text{parent=generalOptionsFrame, anchorParent=generalOptionsFrame.restockAmountLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=-10,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        generalOptionsFrame.saleRateInput = GGUI.NumericInput{
            parent=generalOptionsFrame, anchorParent=generalOptionsFrame.saleRateTitle.frame, initialValue = CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold or 0, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
            allowDecimals=true,minValue=0,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=function (input)
                local value = input.currentValue
                CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold = tonumber(value)
            end
        }

        generalOptionsFrame.saleRateHelpIcon = GGUI.HelpIcon{parent=generalOptionsFrame, anchorParent=generalOptionsFrame.saleRateTitle.frame, 
            anchorA="RIGHT", anchorB="LEFT", offsetX=-2, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL)
        }
        
        restockOptionsTab.content.recipeOptionsFrame = CreateFrame("Frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.recipeOptionsFrame:SetSize(150, 50)
        restockOptionsTab.content.recipeOptionsFrame:SetPoint("TOP", generalOptionsFrame, "BOTTOM", 0, -60)

        ---@class CraftSim.CraftQueue.RestockOptions.RecipeOptionsFrame : Frame
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame

        ---@type number | nil
        recipeOptionsFrame.recipeID = nil

        recipeOptionsFrame.recipeTitle = GGUI.Text({parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame,
            anchorA="TOP", anchorB="TOP", justifyOptions={type='H', align="LEFT"}, scale=1.2})

        local enableRecipeLabel = GGUI.Text{parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame, 
        anchorA="TOP", anchorB="BOTTOM", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL), 
        offsetY=10, offsetX=0}

        recipeOptionsFrame.enableRecipeCheckbox = GGUI.Checkbox{
            parent=recipeOptionsFrame, anchorParent=enableRecipeLabel.frame, anchorA="LEFT", anchorB="RIGHT", 
            tooltip=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP), offsetX=15,
        }
        local recipeProfitMarginLabel = GGUI.Text({parent=recipeOptionsFrame, anchorParent=enableRecipeLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL),
            offsetY=-10, 
            })

        recipeOptionsFrame.profitMarginThresholdInput = GGUI.NumericInput({
        parent=recipeOptionsFrame, anchorParent=recipeProfitMarginLabel.frame, initialValue = 0, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        allowDecimals=true,minValue=-math.huge,
        sizeX=40, borderAdjustWidth=1.2})

        -- %
        GGUI.Text({parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame.profitMarginThresholdInput.textInput.frame, 
            anchorA="LEFT", anchorB="RIGHT", text="%", offsetX=2})  

        recipeOptionsFrame.restockAmountLabel = GGUI.Text{parent=recipeOptionsFrame, anchorParent=recipeProfitMarginLabel.frame,
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY=-10,
        }
        GGUI.HelpIcon{parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame.restockAmountLabel.frame, 
            anchorA="RIGHT", anchorB="LEFT", offsetX=-2, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP)
        }

        recipeOptionsFrame.restockAmountInput = GGUI.NumericInput{
            parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame.restockAmountLabel.frame, initialValue = 1, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10, minValue=1,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=nil -- set dynamically
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
        recipeOptionsFrame.tsmSaleRateFrame:SetPoint("TOP", recipeOptionsFrame.restockAmountInput.textInput.frame, "BOTTOM", 0, -10)
        ---@class CraftSim.CraftQueue.RestockOptions.TSMSaleRateFrame : Frame
        local tsmSaleRateFrame = recipeOptionsFrame.tsmSaleRateFrame

        -- always create the inputs and such but only show when tsm is loaded
        tsmSaleRateFrame.saleRateTitle = GGUI.Text{parent=tsmSaleRateFrame, anchorParent=recipeOptionsFrame.restockAmountLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=-10,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        tsmSaleRateFrame.saleRateInput = GGUI.NumericInput{
            parent=tsmSaleRateFrame, anchorParent=tsmSaleRateFrame.saleRateTitle.frame, initialValue = 0, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
            allowDecimals=true,minValue=0,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=nil -- set dynamically
        }

        tsmSaleRateFrame.helpIcon = GGUI.HelpIcon{parent=tsmSaleRateFrame, anchorParent=tsmSaleRateFrame.saleRateTitle.frame, 
            anchorA="RIGHT", anchorB="LEFT", offsetX=-2, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP)
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
    local editFrameX = 500
    local editFrameY = 300
    ---@class CraftSim.CRAFTQ.EditRecipeFrame : GGUI.Frame
    local editRecipeFrame = GGUI.Frame{
        parent=parent, anchorParent=anchorParent,
        sizeX=editFrameX, sizeY=editFrameY, backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS, 
        frameID=CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE, frameTable=CraftSim.MAIN.FRAMES,
        title= CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE),
        frameStrata="DIALOG", closeable=true,
    }

    editRecipeFrame.content.saveButton = GGUI.Button{
        parent=editRecipeFrame.content, anchorParent=editRecipeFrame.content, 
        anchorA="BOTTOM", anchorB="BOTTOM", label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_SAVE), adjustWidth=true,
        offsetY=30,
        clickCallback=function ()
            CraftSim.CRAFTQ:OnRecipeEditSave()
        end
    }

    editRecipeFrame.content.optimizeReagents = GGUI.Button{
        parent=editRecipeFrame.content, anchorParent=editRecipeFrame.content, anchorA="RIGHT", anchorB="RIGHT", offsetX=-20,
        offsetX=10, label="Optimize Reagents", adjustWidth=true,
        clickCallback=function ()
            if editRecipeFrame.recipeData then
                editRecipeFrame.recipeData:OptimizeReagents(true)
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
            end
        end
    }

    --- the current recipe data that is edited
    ---@type CraftSim.RecipeData
    editRecipeFrame.recipeData = nil
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

    local craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})

    --- precalculate craftable status before sorting to increase performance
    table.foreach(craftQueue.craftQueueItems, 
    ---@param _ any
    ---@param craftQueueItem CraftSim.CraftQueueItem
    function (_, craftQueueItem)
        craftQueueItem:CalculateCanCraft()
    end)

    CraftSim.UTIL:StartProfiling("- FrameListUpdate Sort Queue")
    craftQueue.craftQueueItems = CraftSim.GUTIL:Sort(craftQueue.craftQueueItems, 
    ---@param craftQueueItemA CraftSim.CraftQueueItem
    ---@param craftQueueItemB CraftSim.CraftQueueItem
    function (craftQueueItemA, craftQueueItemB)
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
        function (row)
            
            local profilingID = "- FrameListUpdate Add Recipe: " .. craftQueueItem.recipeData.recipeName
            CraftSim.UTIL:StartProfiling(profilingID)
            local columns = row.columns
            local editButtonColumn = columns[1]
            local recipeColumn = columns[2] 
            local averageProfitColumn = columns[3]
            local craftingCostsColumn = columns[4]
            local reagentInfoColumn = columns[5]
            local topGearColumn = columns[6]
            local craftAbleColumn = columns[7]
            local craftAmountColumn = columns[8] 
            local craftButtonColumn = columns[9]
            local removeRowColumn = columns[10]

            row.craftQueueItem = craftQueueItem

            editButtonColumn.editButton.clickCallback = function ()
                print("show edit recipe frame")
                CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrame(craftQueueItem)
                CraftSim.CRAFTQ.frame.content.queueTab.content.editRecipeFrame:Show()
            end

            editButtonColumn.editButton:Hide() -- temp

            -- update price data and profit?
            recipeData.priceData:Update()
            recipeData:GetAverageProfit()
            local craftingCosts = recipeData.priceData.craftingCosts * craftQueueItem.amount
            totalCraftingCosts = totalCraftingCosts + craftingCosts

            local averageProfit = (recipeData.averageProfitCached or recipeData:GetAverageProfit()) * craftQueueItem.amount
            totalAverageProfit = totalAverageProfit + averageProfit
            recipeColumn.text:SetText(recipeData.recipeName)
            averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(select(1, averageProfit), true, craftingCosts))

            craftingCostsColumn.text:SetText(f.r(CraftSim.GUTIL:FormatMoney(craftingCosts)))

            reagentInfoColumn.reagentInfoButton:SetText(recipeData.reagentData:GetTooltipText(craftQueueItem.amount))
    
            if craftQueueItem.gearEquipped then
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
                topGearColumn.equipButton:Show()
                topGearColumn.equipButton.clickCallback = function ()
                    recipeData.professionGearSet:Equip()
                end
            end
    
            local craftAbleAmount = math.min(craftQueueItem.craftAbleAmount, craftQueueItem.amount)
            local f = CraftSim.UTIL:GetFormatter()

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
            function (numericInput)
                craftQueueItem.amount = tonumber(numericInput.currentValue) or 1
                CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
            end

            craftButtonColumn.craftButton.clickCallback = nil
            craftButtonColumn.craftButton:SetEnabled(craftQueueItem.allowedToCraft)
            
            if craftQueueItem.allowedToCraft then
                craftButtonColumn.craftButton.clickCallback = function ()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                    recipeData:Craft()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                end
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL), nil, true)
            elseif not craftQueueItem.correctProfessionOpen then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION), nil, true)
            elseif not craftQueueItem.notOnCooldown then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN), nil, true)
            elseif not craftQueueItem.canCraftOnce then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_MATS), nil, true)
            elseif not craftQueueItem.gearEquipped then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR), nil, true)
            end

            removeRowColumn.removeButton.clickCallback = function ()
                CraftSim.CRAFTQ.craftQueue:SetAmount(craftQueueItem.recipeData, 0) -- to delete it
                CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
            end

            CraftSim.UTIL:StopProfiling(profilingID)
        end)
    end

    CraftSim.UTIL:StopProfiling("- FrameListUpdate Add Rows")


    --- sort by craftable status
    craftList:UpdateDisplay()

    queueTab.content.totalAverageProfit:SetText(CraftSim.GUTIL:FormatMoney(totalAverageProfit, true, totalCraftingCosts))
    queueTab.content.totalCraftingCosts:SetText(f.r(CraftSim.GUTIL:FormatMoney(totalCraftingCosts)))
    

    CraftSim.UTIL:StopProfiling("FrameListUpdate")
end

function CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
    --- use a cache to prevent multiple redundant calls of ItemCount thus increasing performance
    CraftSim.CRAFTQ.itemCountCache = {}

    CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame
    ---@type GGUI.Tab
    local queueTab = craftQueueFrame.content.queueTab

    queueTab.content.importRecipeScanButton:SetEnabled(CraftSim.GUTIL:Count(CraftSim.RECIPE_SCAN.currentResults) > 0)
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    print("update display")
    if itemsPresent then
        -- if first item can be crafted (so if anything can be crafted cause the items are sorted by craftable status)
        local firstQueueItem = CraftSim.CRAFTQ.craftQueue.craftQueueItems[1]
        queueTab.content.craftNextButton:SetEnabled(firstQueueItem.allowedToCraft)
        
        if firstQueueItem.allowedToCraft then
            -- set callback to craft the recipe of the top row
            queueTab.content.craftNextButton.clickCallback =
                function ()
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
        queueTab.content.createAuctionatorShoppingList:SetEnabled(CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0)
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

        local recipeIconText = CraftSim.GUTIL:IconToText(recipeData.recipeIcon, 25, 25)
        recipeOptionsFrame.recipeTitle:SetText(recipeIconText .. " " .. recipeData.recipeName)

        CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID] = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID] or CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)
        --- only use for setting of initial values of checkboxes and such
        local initialRestockOptions = CraftSim.CRAFTQ:GetRestockOptionsForRecipe(recipeData.recipeID)
        
        ---@type CraftSim.CraftQueue.RestockOptions.TSMSaleRateFrame
        local tsmSaleRateFrame = recipeOptionsFrame.tsmSaleRateFrame
        
        -- adjust Quality Checkboxes Visibility, initialValue and Callbacks
        for qualityID=1, 5 do
            local restockCB = recipeOptionsFrame.restockQualityCheckboxes[qualityID]
            local tsmSaleRateCB = tsmSaleRateFrame.qualityCheckboxes[qualityID]
            local hasQualityID = recipeData.resultData.itemsByQuality[qualityID] ~= nil
            restockCB:SetVisible(hasQualityID)
            restockCB:SetChecked(initialRestockOptions.restockPerQuality[qualityID])
            restockCB.clickCallback = function (_, checked)
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockPerQuality = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockPerQuality or {}
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockPerQuality[qualityID] = checked
            end
            
            tsmSaleRateCB:SetVisible(hasQualityID)
            tsmSaleRateCB:SetChecked(initialRestockOptions.saleRatePerQuality[qualityID])
            tsmSaleRateCB.clickCallback = function (_, checked)
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRatePerQuality = CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRatePerQuality or {}
                CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].saleRatePerQuality[qualityID] = checked
            end
        end
        recipeOptionsFrame.enableRecipeCheckbox:SetChecked(initialRestockOptions.enabled or false)
        recipeOptionsFrame.enableRecipeCheckbox.clickCallback = function (_, checked)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].enabled = checked
        end

        -- adjust numericInputs Visibility, initialValue and Callbacks
        recipeOptionsFrame.restockAmountInput.textInput:SetText(initialRestockOptions.restockAmount or 0)
        recipeOptionsFrame.restockAmountInput.onNumberValidCallback = function (input)
            local inputValue = tonumber(input.currentValue)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].restockAmount = inputValue
        end
        recipeOptionsFrame.profitMarginThresholdInput.textInput:SetText(initialRestockOptions.profitMarginThreshold or 0)
        recipeOptionsFrame.profitMarginThresholdInput.onNumberValidCallback = function (input)
            local inputValue = tonumber(input.currentValue)
            CraftSimOptions.craftQueueRestockPerRecipeOptions[recipeData.recipeID].profitMarginThreshold = inputValue
        end
        -- Only show Sale Rate Input Stuff if TSM is loaded
        
        tsmSaleRateFrame.saleRateInput.textInput:SetText(initialRestockOptions.saleRateThreshold)
        tsmSaleRateFrame.saleRateInput.onNumberValidCallback = function (input)
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
function CraftSim.CRAFTQ.FRAMES:UpdateEditRecipeFrame(craftQueueItem)
    ---@type CraftSim.CRAFTQ.EditRecipeFrame
    local editRecipeFrame = GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_QUEUE_EDIT_RECIPE)
    editRecipeFrame.recipeData = craftQueueItem.recipeData
end