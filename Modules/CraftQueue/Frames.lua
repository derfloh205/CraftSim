_, CraftSim = ...

CraftSim.CRAFTQ.FRAMES = {}

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)


function  CraftSim.CRAFTQ.FRAMES:Init()
    local sizeX=930
    local sizeY=420

    ---@class CraftSim.CraftQueue.Frame : GGUI.Frame
    CraftSim.CRAFTQ.frame = CraftSim.GGUI.Frame({
            parent=ProfessionsFrame.CraftingPage.SchematicForm, 
            anchorParent=ProfessionsFrame.CraftingPage.SchematicForm,
            sizeX=sizeX,sizeY=sizeY,
            frameID=CraftSim.CONST.FRAMES.CRAFT_QUEUE, 
            title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE),
            collapseable=true,
            closeable=true,
            moveable=true,
            frameStrata="DIALOG",
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCraftQueue"),
            frameTable=CraftSim.MAIN.FRAMES,
            frameConfigTable=CraftSimGGUIConfig,
        })

        ---@param frame CraftSim.CraftQueue.Frame
    local function createContent(frame)

        ---@type GGUI.Tab
        frame.content.queueTab = CraftSim.GGUI.Tab({
            buttonOptions={parent=frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="BOTTOM", offsetX=-62, offsetY=-20, 
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL), adjustWidth=true},
            parent=frame.content,anchorParent=frame.content, sizeX=930, sizeY=400, canBeEnabled=true, offsetY=-30,
        })
        ---@type GGUI.Tab
        frame.content.restockOptionsTab = CraftSim.GGUI.Tab({
            buttonOptions={parent=frame.content, anchorParent=frame.content.queueTab.button.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=5, 
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL), adjustWidth=true},
            parent=frame.content,anchorParent=frame.content, sizeX=930, sizeY=400, canBeEnabled=true, offsetY=-30,
        })
        local restockOptionsTab = frame.content.restockOptionsTab
        local queueTab = frame.content.queueTab

        CraftSim.GGUI.TabSystem({queueTab, restockOptionsTab})

        local columnOptions = {
            {
                label="", -- jump to recipe button
                width=50,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
                width=150,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
                width=140,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_REAGENT_INFO_HEADER),
                width=100,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER), -- here a button is needed to switch to the top gear for this recipe
                width=150,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT),
                width=80,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER),
                width=80,
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
        queueTab.content.craftList = CraftSim.GGUI.FrameList({
            parent = queueTab.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP",
            showHeaderLine=true, scale=0.95,
            sizeY=230, offsetY=-90,
            columnOptions=columnOptions,
            rowConstructor=function (columns)
                local switchToRecipeColumn = columns[1]
                local recipeColumn = columns[2] 
                local averageProfitColumn = columns[3]
                local reagentInfoColumn = columns[4]
                local topGearColumn = columns[5]
                local craftableColumn = columns[6]
                local craftAmountColumn = columns[7] 
                local craftButtonColumn = columns[8]
                local removeRowColumn = columns[9]

                switchToRecipeColumn.switchButton = CraftSim.GGUI.Button({
                    parent=switchToRecipeColumn,anchorParent=switchToRecipeColumn, sizeX=25, sizeY=25,
                    label="->", clickCallback=function (gButton) 
                        C_TradeSkillUI.OpenRecipe(gButton.recipeID)
                    end
                })

                recipeColumn.text = CraftSim.GGUI.Text({
                    parent=recipeColumn,anchorParent=recipeColumn,anchorA="LEFT",anchorB="LEFT", justifyOptions={type="H",align="LEFT"}, scale=0.9,
                    fixedWidth=recipeColumn:GetWidth(), wrap=true,
                })

                local iconSize = 23
                
                ---@type GGUI.Text | GGUI.Widget
                averageProfitColumn.text = CraftSim.GGUI.Text(
                { 
                    parent=averageProfitColumn,anchorParent=averageProfitColumn, anchorA="LEFT", anchorB="LEFT", scale = 0.9,

                })

                reagentInfoColumn.reagentInfoButton = CraftSim.GGUI.HelpIcon({
                    parent=reagentInfoColumn, anchorParent=reagentInfoColumn,
                    text="No Data", label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_REAGENT_INFO_BUTTON_LABEL)
                })

                topGearColumn.gear2Icon = CraftSim.GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn, sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.2,
                })

                topGearColumn.gear1Icon = CraftSim.GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn.gear2Icon.frame, anchorA="RIGHT", anchorB="LEFT", sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.2, offsetX=-5,
                })
                topGearColumn.toolIcon = CraftSim.GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn.gear2Icon.frame, anchorA="LEFT", anchorB="RIGHT", sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.2, offsetX=5
                })
                topGearColumn.equippedText = CraftSim.GGUI.Text({
                    parent=topGearColumn, anchorParent=topGearColumn
                })

                topGearColumn.equipButton = CraftSim.GGUI.Button({
                    parent=topGearColumn, anchorParent=topGearColumn.toolIcon.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=2,
                    label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_EQUIP), clickCallback = nil, -- will be set in Add dynamically
                    adjustWidth=true,
                })

                function topGearColumn.equippedText:SetEquipped()
                    topGearColumn.equippedText:SetText(CraftSim.GUTIL:ColorizeText("Equipped", CraftSim.GUTIL.COLORS.GREEN))
                end
                function topGearColumn.equippedText:SetIrrelevant()
                    topGearColumn.equippedText:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end

                craftableColumn.text = CraftSim.GGUI.Text({
                    parent=craftableColumn, anchorParent=craftableColumn
                })

                craftAmountColumn.input = CraftSim.GGUI.NumericInput({
                    parent=craftAmountColumn, anchorParent = craftAmountColumn, sizeX=50, borderAdjustWidth=1.13,
                    minValue=1, initialValue=1, onNumberValidCallback=nil -- set dynamically on Add
                })

                craftButtonColumn.craftButton = CraftSim.GGUI.Button({
                    parent=craftButtonColumn, anchorParent=craftButtonColumn,
                    label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL),
                    adjustWidth=true, secure=true,
                })

                removeRowColumn.removeButton = CraftSim.GGUI.Button({
                    parent=removeRowColumn, anchorParent=removeRowColumn,
                    label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.1),
                    sizeX=25, clickCallback = nil -- set dynamically in Add
                })
            end
        })

        ---@type GGUI.Button
        queueTab.content.importRecipeScanButton = CraftSim.GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.craftList.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0, offsetX=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:ImportRecipeScan()
            end
        })

        ---@type GGUI.Button
        queueTab.content.addCurrentRecipeButton = CraftSim.GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.importRecipeScanButton.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL), clickCallback=function ()
                if CraftSim.SIMULATION_MODE.isActive then
                    if CraftSim.SIMULATION_MODE.recipeData then
                        CraftSim.CRAFTQ:AddRecipe(CraftSim.SIMULATION_MODE.recipeData:Copy()) -- need a copy or changes in simulation mode just overwrite it
                    end
                else
                    if CraftSim.MAIN.currentRecipeData then
                        CraftSim.CRAFTQ:AddRecipe(CraftSim.MAIN.currentRecipeData)
                    end
                end
            end
        })

        ---@type GGUI.Button
        queueTab.content.clearAllButton = CraftSim.GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.addCurrentRecipeButton.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:ClearAll()
            end
        })

        ---@type GGUI.Button
        queueTab.content.craftNextButton = CraftSim.GGUI.Button({
            parent=queueTab.content, anchorParent=queueTab.content.craftList.frame, anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=0, offsetX=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL), clickCallback=nil
        })


        if select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
            ---@type GGUI.Button
            queueTab.content.createAuctionatorShoppingList = CraftSim.GGUI.Button({
                parent=queueTab.content, anchorParent=queueTab.content.craftList.frame, anchorA="TOP", anchorB="BOTTOM", adjustWidth=true,
                clickCallback=function ()
                    CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
                end,
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL)
            })
        end

        -- restock Options

        restockOptionsTab.content.generalOptionsFrame = CreateFrame("frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.generalOptionsFrame:SetSize(150, 50)
        restockOptionsTab.content.generalOptionsFrame:SetPoint("TOP", restockOptionsTab.content, "TOP", 0, -50)
        local generalOptionsFrame = restockOptionsTab.content.generalOptionsFrame

        generalOptionsFrame.title = CraftSim.GGUI.Text{
            parent=generalOptionsFrame, anchorParent=generalOptionsFrame, anchorA="TOP", anchorB="TOP",
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL), scale=1.2,
        }

        local profitMarginLabel = CraftSim.GGUI.Text({parent=generalOptionsFrame, anchorParent=generalOptionsFrame, 
            anchorA="TOP", anchorB="TOP", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL), 
            offsetX=-25, offsetY=-30})

        generalOptionsFrame.profitMarginThresholdInput = CraftSim.GGUI.NumericInput({
            parent=generalOptionsFrame, anchorParent=profitMarginLabel.frame, initialValue = CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold or 0, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
            allowDecimals=true,minValue=-math.huge,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=function (numberInput)
                print("Updating craftQueueGeneralRestockProfitMarginThreshold: " .. tostring(numberInput.currentValue))
                CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold = tonumber(numberInput.currentValue or 0)
            end
        })
        -- %
        CraftSim.GGUI.Text({parent=generalOptionsFrame, anchorParent=generalOptionsFrame.profitMarginThresholdInput.textInput.frame, 
            anchorA="LEFT", anchorB="RIGHT", text="%", offsetX=2})        

        generalOptionsFrame.restockAmountLabel = CraftSim.GGUI.Text({parent=generalOptionsFrame, anchorParent=profitMarginLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY=-10,
        })

        generalOptionsFrame.restockAmountInput = CraftSim.GGUI.NumericInput{
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
            return CraftSim.GGUI.Checkbox{
                parent=p, anchorParent=a, 
                anchorA="LEFT", anchorB="RIGHT", offsetX=qualityCheckboxBaseOffsetX+qualityCheckboxSpacingX*(qualityID-1), 
                label=CraftSim.GUTIL:GetQualityIconString(qualityID, qualityIconSize, qualityIconSize, oX, oY)}
        end

        -- always create the inputs and such but only show when tsm is loaded
        generalOptionsFrame.saleRateTitle = CraftSim.GGUI.Text{parent=generalOptionsFrame, anchorParent=generalOptionsFrame.restockAmountLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=-10,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        generalOptionsFrame.saleRateInput = CraftSim.GGUI.NumericInput{
            parent=generalOptionsFrame, anchorParent=generalOptionsFrame.saleRateTitle.frame, initialValue = 0, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
            allowDecimals=true,minValue=0,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=function (input)
                local value = input.currentValue
                CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold = tonumber(value)
            end
        }

        generalOptionsFrame.saleRateHelpIcon = CraftSim.GGUI.HelpIcon{parent=generalOptionsFrame, anchorParent=generalOptionsFrame.saleRateTitle.frame, 
            anchorA="RIGHT", anchorB="LEFT", offsetX=-2, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL)
        }
        
        restockOptionsTab.content.recipeOptionsFrame = CreateFrame("Frame", nil, restockOptionsTab.content)
        restockOptionsTab.content.recipeOptionsFrame:SetSize(150, 50)
        restockOptionsTab.content.recipeOptionsFrame:SetPoint("TOP", generalOptionsFrame, "BOTTOM", 0, -60)

        ---@class CraftSim.CraftQueue.RestockOptions.RecipeOptionsFrame : Frame
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame

        ---@type number | nil
        recipeOptionsFrame.recipeID = nil

        recipeOptionsFrame.recipeTitle = CraftSim.GGUI.Text({parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame,
            anchorA="TOP", anchorB="TOP", justifyOptions={type='H', align="LEFT"}, scale=1.2})

        local enableRecipeLabel = CraftSim.GGUI.Text{parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame, 
        anchorA="TOP", anchorB="BOTTOM", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL), 
        offsetY=10, offsetX=0}

        recipeOptionsFrame.enableRecipeCheckbox = CraftSim.GGUI.Checkbox{
            parent=recipeOptionsFrame, anchorParent=enableRecipeLabel.frame, anchorA="LEFT", anchorB="RIGHT", 
            tooltip=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP), offsetX=15,
        }
        local recipeProfitMarginLabel = CraftSim.GGUI.Text({parent=recipeOptionsFrame, anchorParent=enableRecipeLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL),
            offsetY=-10, 
            })

        recipeOptionsFrame.profitMarginThresholdInput = CraftSim.GGUI.NumericInput({
        parent=recipeOptionsFrame, anchorParent=recipeProfitMarginLabel.frame, initialValue = 0, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        allowDecimals=true,minValue=-math.huge,
        sizeX=40, borderAdjustWidth=1.2})

        -- %
        CraftSim.GGUI.Text({parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame.profitMarginThresholdInput.textInput.frame, 
            anchorA="LEFT", anchorB="RIGHT", text="%", offsetX=2})  

        recipeOptionsFrame.restockAmountLabel = CraftSim.GGUI.Text{parent=recipeOptionsFrame, anchorParent=recipeProfitMarginLabel.frame,
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL),
            offsetY=-10,
        }
        CraftSim.GGUI.HelpIcon{parent=recipeOptionsFrame, anchorParent=recipeOptionsFrame.restockAmountLabel.frame, 
            anchorA="RIGHT", anchorB="LEFT", offsetX=-2, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP)
        }

        recipeOptionsFrame.restockAmountInput = CraftSim.GGUI.NumericInput{
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
        tsmSaleRateFrame.saleRateTitle = CraftSim.GGUI.Text{parent=tsmSaleRateFrame, anchorParent=recipeOptionsFrame.restockAmountLabel.frame, 
            anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=-10,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL)
        }

        tsmSaleRateFrame.saleRateInput = CraftSim.GGUI.NumericInput{
            parent=tsmSaleRateFrame, anchorParent=tsmSaleRateFrame.saleRateTitle.frame, initialValue = 0, 
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
            allowDecimals=true,minValue=0,
            sizeX=40, borderAdjustWidth=1.2, onNumberValidCallback=nil -- set dynamically
        }

        tsmSaleRateFrame.helpIcon = CraftSim.GGUI.HelpIcon{parent=tsmSaleRateFrame, anchorParent=tsmSaleRateFrame.saleRateTitle.frame, 
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

function CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    -- multiples should be possible (different reagent setup)
    -- but if there already is a configuration just increase the count?

    CraftSim.UTIL:StartProfiling("FrameListUpdate")

    ---@type GGUI.FrameList
    local craftList = CraftSim.CRAFTQ.frame.content.queueTab.content.craftList

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

    CraftSim.UTIL:StartProfiling("- FrameListUpdate Add Rows")
    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        local recipeData = craftQueueItem.recipeData
        craftList:Add(
        function (row)
            local profilingID = "- FrameListUpdate Add Recipe: " .. craftQueueItem.recipeData.recipeName
            CraftSim.UTIL:StartProfiling(profilingID)
            local columns = row.columns
            local switchToRecipeColumn = columns[1]
            local recipeColumn = columns[2] 
            local averageProfitColumn = columns[3]
            local reagentInfoColumn = columns[4]
            local topGearColumn = columns[5]
            local craftAbleColumn = columns[6]
            local craftAmountColumn = columns[7] 
            local craftButtonColumn = columns[8]
            local removeRowColumn  = columns[9]

            switchToRecipeColumn.switchButton:SetEnabled(craftQueueItem.correctProfessionOpen)
            switchToRecipeColumn.switchButton.recipeID = recipeData.recipeID

            local averageProfit = recipeData.averageProfitCached or recipeData:GetAverageProfit()
            recipeColumn.text:SetText(recipeData.recipeName)
            averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(select(1, averageProfit), true, recipeData.priceData.craftingCosts))

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
        local restockOptionsTab = CraftSim.CRAFTQ.FRAMES.frame.content.restockOptionsTab
        local recipeOptionsFrame = restockOptionsTab.content.recipeOptionsFrame
        recipeOptionsFrame:Hide()
    end
end

function CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
    CraftSim.CRAFTQ.FRAMES:UpdateQueueDisplay()
    CraftSim.CRAFTQ.FRAMES:UpdateRestockOptionsDisplay()
end