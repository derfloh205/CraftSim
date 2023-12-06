_, CraftSim = ...

CraftSim.CRAFTQ.FRAMES = {}

function  CraftSim.CRAFTQ.FRAMES:Init()
    local sizeX=850
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

        ---@type GGUI.Button
        frame.content.addCurrentRecipeButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent=frame.content, anchorA="TOP", anchorB="TOP", offsetY=-30,
            adjustWidth=true,
            label="Add Open Recipe to Queue", clickCallback=function ()
                if CraftSim.MAIN.currentRecipeData then
                    CraftSim.CRAFTQ:AddRecipe(CraftSim.MAIN.currentRecipeData)
                end
            end
        })

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
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER), -- here a button is needed to switch to the top gear for this recipe
                width=150,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER),
                width=80,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="",
                width=80,
                justifyOptions={type="H", align="CENTER"}
            }
        }

        ---@type GGUI.FrameList
        frame.content.craftList = CraftSim.GGUI.FrameList({
            parent = frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP",
            showHeaderLine=true,
            sizeY=250, offsetY=-100,
            columnOptions=columnOptions,
            rowConstructor=function (columns)
                local recipeColumn = columns[1] 
                local averageProfitColumn = columns[2]
                local topGearColumn = columns[3]
                local craftAmountColumn = columns[4] 
                local craftButtonColumn = columns[5]

                recipeColumn.text = CraftSim.GGUI.Text({
                    parent=recipeColumn,anchorParent=recipeColumn,anchorA="LEFT",anchorB="LEFT", justifyOptions={type="H",align="LEFT"}, scale=0.9,
                    fixedWidth=recipeColumn:GetWidth(), wrap=true,
                })

                local iconSize = 23

                ---@type GGUI.Text | GGUI.Widget
                averageProfitColumn.text = CraftSim.GGUI.Text({
                    parent=averageProfitColumn,anchorParent=averageProfitColumn, anchorA="LEFT", anchorB="LEFT"
                })

                topGearColumn.gear2Icon = CraftSim.GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn, sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.4,
                })

                topGearColumn.gear1Icon = CraftSim.GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn.gear2Icon.frame, anchorA="RIGHT", anchorB="LEFT", sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.4, offsetX=-10,
                })
                topGearColumn.toolIcon = CraftSim.GGUI.Icon({
                    parent=topGearColumn, anchorParent=topGearColumn.gear2Icon.frame, anchorA="LEFT", anchorB="RIGHT", sizeX=iconSize,sizeY=iconSize, qualityIconScale=1.4, offsetX=10
                })
                topGearColumn.equippedText = CraftSim.GGUI.Text({
                    parent=topGearColumn, anchorParent=topGearColumn
                })

                function topGearColumn.equippedText:SetEquipped()
                    topGearColumn.equippedText:SetText(CraftSim.GUTIL:ColorizeText("Equipped", CraftSim.GUTIL.COLORS.GREEN))
                end
                function topGearColumn.equippedText:SetIrrelevant()
                    topGearColumn.equippedText:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end

                -- TODO: not a text but a number input to modify count
                craftAmountColumn.text = CraftSim.GGUI.Text({
                    parent=craftAmountColumn, anchorParent=craftAmountColumn
                })

                craftButtonColumn.craftButton = CraftSim.GGUI.Button({
                    parent=craftButtonColumn, anchorParent=craftButtonColumn,
                    label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL),
                    adjustWidth=true, secure=true,
                })
            end
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

    craftList:Remove()

    for _, craftQueueItem in pairs(craftQueue.craftItems) do
        local recipeData = craftQueueItem.recipeData
        craftList:Add(
        ---@param row GGUI.FrameList.Row    
        function (row)
            local columns = row.columns
            local recipeColumn = columns[1] 
            local averageProfitColumn = columns[2]
            local topGearColumn = columns[3]
            local craftAmountColumn = columns[4] 
            local craftButtonColumn = columns[5]

            local canCraftOnce = recipeData:CanCraft(1)
            local gearEquipped = recipeData.professionGearSet:IsEquipped()

            local allowedToCraft = canCraftOnce and gearEquipped


    
            recipeColumn.text:SetText(recipeData.recipeName)
            averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(select(1, recipeData:GetAverageProfit()), true))
    
            if gearEquipped then
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
    
            craftAmountColumn.text:SetText(craftQueueItem.amount)
            craftButtonColumn.craftButton.clickCallback = nil
            craftButtonColumn.craftButton:SetEnabled(allowedToCraft)
            if allowedToCraft then
                craftButtonColumn.craftButton.clickCallback = function ()
                    CraftSim.CRAFTQ.currentlyCraftedQueueItem = craftQueueItem
                    recipeData:Craft()
                end
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL), nil, true)
            elseif not gearEquipped then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR), nil, true)
            elseif not canCraftOnce then
                craftButtonColumn.craftButton:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_MATS), nil, true)
            end
        end)
    end


    craftList:UpdateDisplay()
end