_, CraftSim = ...

CraftSim.RECIPE_SCAN.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.RECIPE_SCAN)

function CraftSim.RECIPE_SCAN.FRAMES:Init()

    CraftSim.RECIPE_SCAN.frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent=ProfessionsFrame.CraftingPage.SchematicForm, 
        sizeX=850,sizeY=400,
        frameID=CraftSim.CONST.FRAMES.RECIPE_SCAN, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        frameStrata="DIALOG",
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesRecipeScan"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local function createContent(frame)
        frame:Hide()

        frame.content.scanMode = CraftSim.GGUI.Dropdown({
            parent=frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP", offsetY=-30, width=170,
            initialValue=CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I,
            initialLabel=CraftSim.RECIPE_SCAN.SCAN_MODES.OPTIMIZE_I, -- TODO: save and use last selected saved in CraftSimOptions
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_MODE),
            initialData=CraftSim.GUTIL:Map(CraftSim.RECIPE_SCAN.SCAN_MODES, function(e) return {label=e, value=e} end)
        })

        frame.content.scanButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.scanMode.frame,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES), 
            anchorA="TOP", anchorB="TOP",offsetY=-30,sizeX=15,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.RECIPE_SCAN:StartScan()
            end
        })

        frame.content.cancelScanButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.scanButton.frame,label="Cancel", anchorA="LEFT", anchorB="RIGHT",sizeX=15,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.RECIPE_SCAN:EndScan()
            end
        })

        frame.content.cancelScanButton:Hide()

        frame.content.includeSoulboundCB = CraftSim.FRAME:CreateCheckbox(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP),
            "recipeScanIncludeSoulbound", frame.content, frame.content.scanMode.frame, "RIGHT", "LEFT", -250, 0)

        frame.content.includeNotLearnedCB = CraftSim.FRAME:CreateCheckbox(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP),
            "recipeScanIncludeNotLearned", frame.content, frame.content.includeSoulboundCB, "BOTTOMLEFT", "TOPLEFT", 0, 0)

        frame.content.includeGearCB = CraftSim.FRAME:CreateCheckbox(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP),
            "recipeScanIncludeGear", frame.content, frame.content.includeSoulboundCB, "TOPLEFT", "BOTTOMLEFT", 0, 0)

        frame.content.optimizeProfessionToolsCB = CraftSim.FRAME:CreateCheckbox(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP) ..
            CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING), CraftSim.GUTIL.COLORS.RED), 
            "recipeScanOptimizeProfessionTools", frame.content, frame.content.scanMode.frame, "LEFT", "RIGHT", 90, 20)

        frame.content.sortByProfitMarginCB = CraftSim.FRAME:CreateCheckbox(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP), 
            "recipeScanSortByProfitMargin", frame.content, frame.content.optimizeProfessionToolsCB, "TOPLEFT", "BOTTOMLEFT", 0, 5)

        frame.content.useInsightCB = CraftSim.FRAME:CreateCheckbox(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP), 
            "recipeScanUseInsight", frame.content, frame.content.sortByProfitMarginCB, "TOPLEFT", "BOTTOMLEFT", 0, 5)

        local columnOptions = {
            {
                -- switch to recipe button
                width=40,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER),
                width=150,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER),
                width=60,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_GUARANTEED_HEADER),
                width=80,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_HIGHEST_RESULT_HEADER), -- icon + upgrade chance
                width=110,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER),
                width=140,
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER),
                width=120,
                justifyOptions={type="H", align="CENTER"}
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER),
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
                local recipeColumn = columns[2]
                local learnedColumn = columns[3]
                local expectedResultColumn = columns[4] 
                local highestResultColumn = columns[5] 
                local averageProfitColumn = columns[6] 
                local topGearColumn = columns[7] 
                local countColumn = columns[8]

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
        local recipeColumn = columns[2]
        local learnedColumn = columns[3]
        local expectedResultColumn = columns[4] 
        local highestResultColumn = columns[5] 
        local averageProfitColumn = columns[6] 
        local topGearColumn = columns[7] 
        local countColumn = columns[8]

        switchToRecipeColumn.switchButton.recipeID = recipeData.recipeID

        local recipeRarity = recipeData.resultData.expectedItem:GetItemQualityColor()

        recipeColumn.text:SetText(recipeRarity.hex .. recipeData.recipeName .. "|r")

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
        local relativeTo = nil
        if CraftSimOptions.showProfitPercentage then
            relativeTo = recipeData.priceData.craftingCosts
        end
        averageProfitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(averageProfit, true, relativeTo))
        row.averageProfit = averageProfit
        row.relativeProfit = CraftSim.GUTIL:GetPercentRelativeTo(averageProfit, recipeData.priceData.craftingCosts)

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

    if CraftSimOptions.recipeScanSortByProfitMargin then
        CraftSim.RECIPE_SCAN.frame.content.resultList:UpdateDisplay(function (rowA, rowB)
            return rowA.relativeProfit > rowB.relativeProfit
        end)
    else
        CraftSim.RECIPE_SCAN.frame.content.resultList:UpdateDisplay(function (rowA, rowB)
            return rowA.averageProfit > rowB.averageProfit
        end)
    end
    
end