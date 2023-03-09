_, CraftSim = ...

CraftSim.RECIPE_SCAN.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)

function CraftSim.RECIPE_SCAN.FRAMES:Init()

    CraftSim.RECIPE_SCAN.frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent=ProfessionsFrame.CraftingPage.SchematicForm, 
        sizeX=700,sizeY=400,
        frameID=CraftSim.CONST.FRAMES.RECIPE_SCAN, 
        title="CraftSim Recipe Scan",
        collapseable=true,
        closeable=true,
        moveable=true,
        frameStrata="DIALOG",
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesRecipeScan"),
    })

    local function createContent(frame)
        frame:Hide()

        frame.content.scanMode = CraftSim.GGUI.Dropdown({
            parent=frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP", offsetY=-30, width=170,
            initialValue=CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I,
            initialLabel=CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I, -- TODO: save and use last selected saved in CraftSimOptions
            label="Scan Mode",
            initialData=CraftSim.GUTIL:Map(CraftSim.RECIPE_SCAN.SCAN_MODES, function(e) return {label=e, value=e} end)
        })

        frame.content.scanButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.scanMode.frame,label="Scan Recipes", anchorA="TOP", anchorB="TOP",offsetY=-30,sizeX=15,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.RECIPE_SCAN:StartScan()
            end
        })

        
        frame.content.exportForgeFinderButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent = frame.content.scanButton.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=135, adjustWidth = true,
            label=CraftSim.GUTIL:ColorizeText("ForgeFinder", CraftSim.GUTIL.COLORS.LEGENDARY) .. " Export",
            clickCallback=CraftSim.RECIPE_SCAN.ForgeFinderExport
        })
        frame.content.exportForgeFinderButton:SetEnabled(false)

        frame.content.includeSoulboundCB = CraftSim.FRAME:CreateCheckbox(
            " Include Soulbound", "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items", 
        "recipeScanIncludeSoulbound", frame.content, frame.content.scanMode.frame, "RIGHT", "LEFT", -190, 0)

        frame.content.includeNotLearnedCB = CraftSim.FRAME:CreateCheckbox(
            " Include not learned", "Include recipes you do not have learned in the recipe scan", 
        "recipeScanIncludeNotLearned", frame.content, frame.content.includeSoulboundCB, "BOTTOMLEFT", "TOPLEFT", 0, 0)

        frame.content.includeGearCB = CraftSim.FRAME:CreateCheckbox(" Include Gear", "Include all form of gear recipes in the recipe scan", 
        "recipeScanIncludeGear", frame.content, frame.content.includeSoulboundCB, "TOPLEFT", "BOTTOMLEFT", 0, 0)

        frame.content.optimizeProfessionToolsCB = CraftSim.FRAME:CreateCheckbox(" Optimize Profession Tools", "For each recipe optimize your profession tools for profit\n\n" .. 
                                                                                CraftSim.GUTIL:ColorizeText("Might lower performance during scanning\nif you have a lot of tools in your inventory", CraftSim.GUTIL.COLORS.RED), 
        "recipeScanOptimizeProfessionTools", frame.content, frame.content.scanMode.frame, "LEFT", "RIGHT", 10, 0)

        local columnOptions = {
            {
                -- switch to recipe button
                width=30,
            },
            {
                label="Learned",
                width=60,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="Guaranteed",
                width=80,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="Highest Result", -- icon + upgrade chance
                width=110,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="Average Profit",
                width=110,
            },
            {
                label="Top Gear",
                width=120,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label="Inv/AH",
                width=80,
                justifyOptions={type="H", align="CENTER"}
            }
        }

        ---@type GGUI.FrameList | GGUI.Widget
        frame.content.resultList = CraftSim.GGUI.FrameList({
            parent = frame.content, anchorParent=frame.content.scanButton.frame, anchorA="TOP", anchorB="BOTTOM",
            showHeaderLine=true,
            sizeY=250, offsetY=-25,
            columnOptions=columnOptions,
            rowConstructor=function (columns)
                local switchToRecipeColumn = columns[1] 
                local learnedColumn = columns[2]
                local expectedResultColumn = columns[3] 
                local highestResultColumn = columns[4] 
                local averageProfitColumn = columns[5] 
                local topGearColumn = columns[6] 
                local countColumn = columns[7]

                switchToRecipeColumn.switchButton = CraftSim.GGUI.Button({
                    parent=switchToRecipeColumn,anchorParent=switchToRecipeColumn, sizeX=25, sizeY=25,
                    label="->", clickCallback=function (gButton) 
                        C_TradeSkillUI.OpenRecipe(gButton.recipeID)
                    end
                })
                
                learnedColumn.text = CraftSim.GGUI.Text({
                    parent=learnedColumn,anchorParent=learnedColumn,justifyOptions={type="H",align="CENTER"},
                })

                function learnedColumn:SetLearned(learned)
                    if learned then
                        learnedColumn.text:SetText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.TRUE, 0.125))
                    else
                        learnedColumn.text:SetText(CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.125))
                    end
                end

                local iconSize = 23

                ---@type GGUI.Icon | GGUI.Widget
                expectedResultColumn.itemIcon = CraftSim.GGUI.Icon({
                    parent=expectedResultColumn,anchorParent=expectedResultColumn, sizeX=iconSize, sizeY=iconSize, qualityIconScale=1.4,
                })

                ---@type GGUI.Icon | GGUI.Widget
                highestResultColumn.itemIcon = CraftSim.GGUI.Icon({
                    parent=highestResultColumn,anchorParent=highestResultColumn, sizeX=iconSize, sizeY=iconSize, qualityIconScale=1.4,
                    offsetX=-25
                })

                ---@type GGUI.Text | GGUI.Widget
                highestResultColumn.noneText = CraftSim.GGUI.Text({
                    parent=highestResultColumn,anchorParent=highestResultColumn, text=CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY)
                })

                ---@type GGUI.Text | GGUI.Widget
                highestResultColumn.chance = CraftSim.GGUI.Text({
                    parent=highestResultColumn, anchorParent=highestResultColumn.itemIcon.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=10,
                })

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

                countColumn.text = CraftSim.GGUI.Text({
                    parent=countColumn, anchorParent=countColumn
                })

            end
        })
    end

    createContent(CraftSim.RECIPE_SCAN.frame)
    CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(CraftSim.RECIPE_SCAN.frame.content)
end

function CraftSim.RECIPE_SCAN:ResetResults()
    CraftSim.RECIPE_SCAN.frame.content.resultList:Remove()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_SCAN.FRAMES:AddRecipe(recipeData)
    
    CraftSim.RECIPE_SCAN.frame.content.resultList:Add(
    function(row) 
        local columns = row.columns

        local switchToRecipeColumn = columns[1] 
        local learnedColumn = columns[2]
        local expectedResultColumn = columns[3] 
        local highestResultColumn = columns[4] 
        local averageProfitColumn = columns[5] 
        local topGearColumn = columns[6] 
        local countColumn = columns[7]

        switchToRecipeColumn.switchButton.recipeID = recipeData.recipeID
        learnedColumn:SetLearned(recipeData.learned)

        expectedResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItem)

        if recipeData.resultData.canUpgradeQuality then
            highestResultColumn.itemIcon:Show()
            highestResultColumn.chance:Show()
            highestResultColumn.noneText:Hide()
            highestResultColumn.itemIcon:SetItem(recipeData.resultData.expectedItemUpgrade)
            highestResultColumn.chance:SetText(CraftSim.GUTIL:Round(recipeData.resultData.chanceUpgrade*100, 1) .. "%")
        else
            highestResultColumn.noneText:Show()
            highestResultColumn.itemIcon:Hide()
            highestResultColumn.chance:Hide()
        end
        local averageProfit = recipeData:GetAverageProfit()
        averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(averageProfit, true))
        row.averageProfit = averageProfit

        if CraftSim.RECIPE_SCAN.frame.content.optimizeProfessionToolsCB:GetChecked() then
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
            totalCountInv = totalCountInv + GetItemCount(resultItem:GetItemLink(), true, false, true)
            local countAH = CraftSim.PRICEDATA:GetAuctionAmount(resultItem:GetItemLink())

            if countAH then
                totalCountAH = (totalCountAH or 0) + countAH
            end
        end
        
        local countText = tostring(totalCountInv)

        if totalCountAH then
            countText = countText .. " / " .. totalCountAH
        end

        countColumn.text:SetText(countText)

    end)

    CraftSim.RECIPE_SCAN.frame.content.resultList:UpdateDisplay(function (rowA, rowB)
        return rowA.averageProfit > rowB.averageProfit
    end)
end