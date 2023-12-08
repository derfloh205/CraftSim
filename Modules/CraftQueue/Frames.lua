_, CraftSim = ...

CraftSim.CRAFTQ.FRAMES = {}

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)


function  CraftSim.CRAFTQ.FRAMES:Init()
    local sizeX=930
    local sizeY=400

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
        frame.content.craftList = CraftSim.GGUI.FrameList({
            parent = frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP",
            showHeaderLine=true, scale=0.95,
            sizeY=230, offsetY=-55,
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
                averageProfitColumn.text = CraftSim.GGUI.Text({
                    parent=averageProfitColumn,anchorParent=averageProfitColumn, anchorA="LEFT", anchorB="LEFT"
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
        frame.content.importRecipeScanButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent=frame.content.craftList.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0, offsetX=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:ImportRecipeScan()
            end
        })

        ---@type GGUI.Button
        frame.content.addCurrentRecipeButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent=frame.content.importRecipeScanButton.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0,
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
        frame.content.clearAllButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent=frame.content.addCurrentRecipeButton.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL), clickCallback=function ()
                CraftSim.CRAFTQ:ClearAll()
            end
        })

        ---@type GGUI.Button
        frame.content.craftNextButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent=frame.content.craftList.frame, anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT", offsetY=0, offsetX=0,
            adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL), clickCallback=nil
        })

        if select(2, C_AddOns.IsAddOnLoaded(CraftSim.CONST.SUPPORTED_PRICE_API_ADDONS[2])) then
            ---@type GGUI.Button
            frame.content.createAuctionatorShoppingList = CraftSim.GGUI.Button({
                parent=frame.content, anchorParent=frame.content.craftList.frame, anchorA="TOP", anchorB="BOTTOM", adjustWidth=true,
                clickCallback=function ()
                    CraftSim.CRAFTQ:CreateAuctionatorShoppingList()
                end,
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL)
            })
        end
    end

    createContent(CraftSim.CRAFTQ.frame)
end

function CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    -- multiples should be possible (different reagent setup)
    -- but if there already is a configuration just increase the count?

    CraftSim.UTIL:StartProfiling("FrameListUpdate")

    ---@type GGUI.FrameList
    local craftList = CraftSim.CRAFTQ.frame.content.craftList

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
            averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(select(1, averageProfit), true))

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
                CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
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

function CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
    --- use a cache to prevent multiple redundant calls of ItemCount thus increasing performance
    CraftSim.CRAFTQ.itemCountCache = {}

    CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame

    craftQueueFrame.content.importRecipeScanButton:SetEnabled(CraftSim.GUTIL:Count(CraftSim.RECIPE_SCAN.currentResults) > 0)
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    print("update display")
    if itemsPresent then
        -- if first item can be crafted (so if anything can be crafted cause the items are sorted by craftable status)
        local firstQueueItem = CraftSim.CRAFTQ.craftQueue.craftQueueItems[1]
        craftQueueFrame.content.craftNextButton:SetEnabled(firstQueueItem.allowedToCraft)
        
        if firstQueueItem.allowedToCraft then
            -- set callback to craft the recipe of the top row
            craftQueueFrame.content.craftNextButton.clickCallback =
                function ()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                    firstQueueItem.recipeData:Craft(firstQueueItem.craftAbleAmount)
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                end
        else
            craftQueueFrame.content.craftNextButton.clickCallback = nil
        end
    else
        craftQueueFrame.content.craftNextButton:SetEnabled(false)
    end

    local currentRecipeData = CraftSim.MAIN.currentRecipeData

    if currentRecipeData then
        -- disable addCurrentRecipeButton if the currently open recipe is not suitable for queueing
        craftQueueFrame.content.addCurrentRecipeButton:SetEnabled(
            currentRecipeData.learned and
            not currentRecipeData.isRecraft and
            not currentRecipeData.isSalvageRecipe and
            not currentRecipeData.isBaseRecraftRecipe
        )
    else
        craftQueueFrame.content.addCurrentRecipeButton:SetEnabled(false)
    end

    if craftQueueFrame.content.createAuctionatorShoppingList then
        craftQueueFrame.content.createAuctionatorShoppingList:SetEnabled(CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0)
    end

    --- disable cache
    CraftSim.CRAFTQ.itemCountCache = nil
end