_, CraftSim = ...

CraftSim.CRAFTQ.FRAMES = {}

local print=CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

function  CraftSim.CRAFTQ.FRAMES:Init()
    local sizeX=900
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
                label="",
                width=120,
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
                local recipeColumn = columns[1] 
                local averageProfitColumn = columns[2]
                local reagentInfoColumn = columns[3]
                local topGearColumn = columns[4]
                local craftableColumn = columns[5]
                local craftAmountColumn = columns[6] 
                local craftButtonColumn = columns[7]

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
    end

    createContent(CraftSim.CRAFTQ.frame)
end

function CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    -- multiples should be possible (different reagent setup)
    -- but if there already is a configuration just increase the count?

    ---@type GGUI.FrameList
    local craftList = CraftSim.CRAFTQ.frame.content.craftList

    local craftQueue = CraftSim.CRAFTQ.craftQueue or CraftSim.CraftQueue({})

    -- sort queue items by craftable status TODO: (and maybe other factors like quantity and profit?)

    craftQueue.craftQueueItems = CraftSim.GUTIL:Sort(craftQueue.craftQueueItems, 
    function (craftQueueItemA, craftQueueItemB)
        local allowedToCraftA = craftQueueItemA:CanCraft()
        local allowedToCraftB = craftQueueItemB:CanCraft()
        if allowedToCraftA and not allowedToCraftB then
            return true
        end
        if not allowedToCraftA and allowedToCraftB then
            return false
        end
        return false
    end)

    craftList:Remove()

    for _, craftQueueItem in pairs(craftQueue.craftQueueItems) do
        local recipeData = craftQueueItem.recipeData
        craftList:Add(
        ---@param row GGUI.FrameList.Row    
        function (row)
            local columns = row.columns
            local recipeColumn = columns[1] 
            local averageProfitColumn = columns[2]
            local reagentInfoColumn = columns[3]
            local topGearColumn = columns[4]
            local craftAbleColumn = columns[5]
            local craftAmountColumn = columns[6] 
            local craftButtonColumn = columns[7]

            local allowedToCraft, canCraftOnce, gearEquipped, correctProfessionOpen = craftQueueItem:CanCraft()


            local averageProfit = recipeData.averageProfitCached or recipeData:GetAverageProfit()
            recipeColumn.text:SetText(recipeData.recipeName)
            averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(select(1, averageProfit), true))

            reagentInfoColumn.reagentInfoButton:SetText(recipeData.reagentData:GetTooltipText(craftQueueItem.amount))
    
            if gearEquipped then
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
    
            local craftAbleAmount = math.min(select(2, craftQueueItem.recipeData:CanCraft()), craftQueueItem.amount)
            local f = CraftSim.UTIL:GetFormatter()

            if craftAbleAmount == 0 or not allowedToCraft then
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
                CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue() -- I think UpdateDisplay would be overkill?
            end

            craftButtonColumn.craftButton.clickCallback = nil
            craftButtonColumn.craftButton:SetEnabled(allowedToCraft)
            
            if allowedToCraft then
                craftButtonColumn.craftButton.clickCallback = function ()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                    recipeData:Craft()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                end
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL), nil, true)
            elseif not correctProfessionOpen then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION), nil, true)
            elseif not canCraftOnce then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_MATS), nil, true)
            elseif not gearEquipped then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR), nil, true)
            end
        end)
    end


    --- sort by craftable status
    craftList:UpdateDisplay()
end

function CraftSim.CRAFTQ.FRAMES:UpdateDisplay()
    CraftSim.CRAFTQ.FRAMES:UpdateFrameListByCraftQueue()
    local craftQueueFrame = CraftSim.CRAFTQ.frame

    craftQueueFrame.content.importRecipeScanButton:SetEnabled(CraftSim.GUTIL:Count(CraftSim.RECIPE_SCAN.currentResults) > 0)
    local itemsPresent = CraftSim.CRAFTQ.craftQueue and #CraftSim.CRAFTQ.craftQueue.craftQueueItems > 0
    print("update display")
    if itemsPresent then
        -- if first item can be crafted (so if anything can be crafted cause the items are sorted by craftable status)
        local firstQueueItem = CraftSim.CRAFTQ.craftQueue.craftQueueItems[1]
        local enableCraftNext = firstQueueItem:CanCraft()
        craftQueueFrame.content.craftNextButton:SetEnabled(enableCraftNext)
        
        if enableCraftNext then
            -- set callback to craft the recipe of the top row
            craftQueueFrame.content.craftNextButton.clickCallback =
                function ()
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = true
                    local craftAbleAmount = firstQueueItem.recipeData.reagentData:GetCraftableAmount()
                    firstQueueItem.recipeData:Craft(craftAbleAmount)
                    CraftSim.CRAFTQ.CraftSimCalledCraftRecipe = false
                end
        else
            craftQueueFrame.content.craftNextButton.clickCallback = nil
        end
    end

    local currentRecipeData = CraftSim.MAIN.currentRecipeData

    if currentRecipeData then
        -- disable addCurrentRecipeButton if the currently open recipe is not suitable for queueing
        craftQueueFrame.content.addCurrentRecipeButton:SetEnabled(
            not currentRecipeData.isRecraft and
            not currentRecipeData.isSalvageRecipe and
            not currentRecipeData.isBaseRecraftRecipe
        )
    else
        craftQueueFrame.content.addCurrentRecipeButton:SetEnabled(false)
    end
end