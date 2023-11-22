_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_DATA)

CraftSim.CRAFTDATA.FRAMES = {}

CraftSim.CRAFTDATA.frame = nil

function CraftSim.CRAFTDATA.FRAMES:Init()
    local sizeYRetracted = 420
    local sizeYExpanded = 650
    local sizeX=600

    ---@type GGUI.Frame | GGUI.Widget
    local craftDataFrame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame,anchorFrame=UIParent,
        sizeX=sizeX,sizeY=sizeYRetracted,
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_TITLE),
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        collapseable=true,moveable=true,closeable=true,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCraftData"),
        frameID=CraftSim.CONST.FRAMES.CRAFT_DATA,
        frameStrata="FULLSCREEN",
        initialStatusID="RETRACTED",
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    ---@type CraftSim.CraftData
    craftDataFrame.activeData = nil

    craftDataFrame:SetStatusList({
        {
            statusID="RETRACTED",
            sizeY=sizeYRetracted,
        },
        {
            statusID="EXPANDED",
            sizeY=sizeYExpanded,
        },
    })

    CraftSim.GGUI.HelpIcon({parent=craftDataFrame.content, anchorParent=craftDataFrame.title.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_EXPLANATION)})

    ---@type GGUI.Dropdown | GGUI.Widget
    craftDataFrame.content.resultsDropdown = CraftSim.GGUI.Dropdown({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.title.frame, 
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_RECIPE_ITEMS),
        anchorA="TOP", anchorB="BOTTOM", offsetY=-30, width=200,
        clickCallback=function (_, _, item)
            CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(item)
        end
    })

    ---@type GGUI.Button | GGUI.Widget
    craftDataFrame.content.clearDataAll = CraftSim.GGUI.Button({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.content, anchorA="TOPLEFT", anchorB="TOPLEFT", 
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_DELETE_ALL),
        offsetX=10, offsetY=-10, adjustWidth=true,
        clickCallback=function ()
            CraftSim.CRAFTDATA:DeleteAll()
            CraftSim.MAIN:TriggerModulesErrorSafe() -- refresh all modules since it may be possible that we delete craftdata that is used here
        end
    })
    ---@type GGUI.Button | GGUI.Widget
    craftDataFrame.content.clearDataRecipe = CraftSim.GGUI.Button({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.content.clearDataAll.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", 
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_DELETE_RECIPE), adjustWidth=true,
        clickCallback=function ()
            CraftSim.CRAFTDATA:DeleteForRecipe()

            local selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
            if selectedItem then
                CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(selectedItem)
            end
        end
    })

    craftDataFrame.expandListButton = CraftSim.GGUI.Button({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.frame, anchorA="BOTTOM", anchorB="BOTTOM",
        label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4), sizeX=15, sizeY=20, offsetY=10, adjustWidth = true,
        initialStatusID="DOWN",
        clickCallback=function ()
            if craftDataFrame:GetStatus() == "RETRACTED" then
                craftDataFrame:SetStatus("EXPANDED")
                craftDataFrame.expandListButton:SetStatus("UP")
                craftDataFrame.content.expandFrame:Show()
            elseif craftDataFrame:GetStatus() == "EXPANDED" then
                craftDataFrame:SetStatus("RETRACTED")
                craftDataFrame.expandListButton:SetStatus("DOWN")
                craftDataFrame.content.expandFrame:Hide()
            end
        end
    })

    craftDataFrame.expandListButton:SetStatusList({
        {
            statusID="UP",
            label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_UP, 0.4),
        },
        {
            statusID="DOWN",
            label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4),
        }
    })

    local dataFrame = CreateFrame("Frame", nil, craftDataFrame.content)
    dataFrame:SetSize(350,300)
    dataFrame:SetPoint("TOP", craftDataFrame.content.resultsDropdown.frame, "BOTTOM", 0, -20)
    craftDataFrame.content.dataFrame = dataFrame


    ---@type GGUI.Icon | GGUI.Widget
    dataFrame.itemIcon = CraftSim.GGUI.Icon({
        parent=dataFrame, anchorParent=dataFrame,
        anchorA="TOPLEFT",anchorB="TOPLEFT",
        offsetX=50,
        sizeX=60,sizeY=60,
    })

    local sideTextSpacing = -3

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.crafterTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.itemIcon.frame,
        anchorA="TOPLEFT", anchorB="TOPRIGHT", offsetX=15, offsetY=3,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_CRAFTER), justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.crafterValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.crafterTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=1, justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCraftsTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.crafterTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=sideTextSpacing,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_CRAFTS), justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCraftsValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCraftsTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=1, justifyOptions={type="H", align="LEFT"},
    })
    CraftSim.GGUI.HelpIcon({parent=dataFrame, anchorParent=dataFrame.expectedCraftsValue.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_CRAFTS_EXPLANATION)})

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.chanceTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCraftsTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=sideTextSpacing,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_CRAFTING_CHANCE), justifyOptions={type="H", align="LEFT"},
    })

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.chanceValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.chanceTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text="100%", justifyOptions={type="H", align="LEFT"},
    })

    CraftSim.GGUI.HelpIcon({parent=dataFrame, anchorParent=dataFrame.chanceValue.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_UPGRADE_CHANCE_EXPLANATION)})

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCostsTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.chanceTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT",offsetY=sideTextSpacing,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_COSTS), justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCostsValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCostsTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=CraftSim.GUTIL:FormatMoney(1234567000), justifyOptions={type="H", align="LEFT"},
    })

    CraftSim.GGUI.HelpIcon({parent=dataFrame, anchorParent=dataFrame.expectedCostsValue.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_COSTS_EXPLANATION)})

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.minimumCostsTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCostsTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT",offsetY=sideTextSpacing,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_MINIMUM_COST), justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.minimumCostsValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.minimumCostsTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=CraftSim.GUTIL:FormatMoney(1234567000), justifyOptions={type="H", align="LEFT"},
    })

    ---@type GGUI.Button | GGUI.Widget
    dataFrame.saveButton = CraftSim.GGUI.Button({
        parent=dataFrame, anchorParent=dataFrame, label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_SAVE),
        anchorA="TOP", anchorB="TOP", offsetX=-70, offsetY=-80, sizeX=60,
        clickCallback=function() 
            local selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
            if selectedItem then
                print("Save Button: selectedItem: " .. tostring(selectedItem:GetItemLink()))
                CraftSim.CRAFTDATA:UpdateCraftData(selectedItem)
                --CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(selectedItem)

                CraftSim.MAIN:TriggerModulesErrorSafe()
            end
        end,
        initialStatus="SAVE",
    })

    dataFrame.saveButton:SetStatusList({
        {
            statusID="SAVE",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_SAVE),
            enabled=true,
            sizeX=60,
        },
        {
            statusID="UPDATE",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_UPDATE),
            enabled=true,
            sizeX=60,
        },
        {
            statusID="UNREACHABLE",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_UNREACHABLE),
            enabled=false,
            sizeX=100,
        }
    })

    ---@type GGUI.Button | GGUI.Widget
    dataFrame.deleteCraftDataButton = CraftSim.GGUI.Button({
        parent=dataFrame,anchorParent=dataFrame.saveButton.frame, anchorA="LEFT", anchorB="RIGHT", 
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_DELETE), adjustWidth=true,
        clickCallback=function ()
            local selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
            if selectedItem then
                CraftSim.CRAFTDATA:DeleteForItem(selectedItem)
                CraftSim.MAIN:TriggerModulesErrorSafe()
            end
        end
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.savedConfigurationTitle = CraftSim.GGUI.Text({
        parent=dataFrame, anchorParent=dataFrame, anchorA="TOP", anchorB="TOP",
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_SAVED_MATERIALS), offsetY=-120
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.noDataText = CraftSim.GGUI.Text({
        parent=dataFrame, anchorParent=dataFrame, anchorA="TOP", anchorB="TOP",
        text=CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_NO_DATA), CraftSim.GUTIL.COLORS.RED), offsetY=-120
    })

    local function createReagentFrame(anchorA, anchorParent, anchorB, anchorX, anchorY)
        local iconSize = 30
        local reagentFrame = CreateFrame("frame", nil, dataFrame)
        reagentFrame:SetSize(iconSize, iconSize)
        reagentFrame:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
        
        reagentFrame.icon = CraftSim.GGUI.Icon({
            parent=reagentFrame, sizeX=iconSize, sizeY=iconSize, anchorA="LEFT", anchorB="LEFT", anchorParent=reagentFrame,
            hideQualityIcon=true,
        })
        reagentFrame.countTextNoQ = CraftSim.GGUI.Text({
            parent=reagentFrame, anchorParent=reagentFrame.icon.frame, anchorA="LEFT",anchorB="RIGHT", 
            offsetX=5,
            scale=0.9,
            justifyOptions={type="HV", alignH="LEFT", alignV="CENTER"}, text=" x ???"
        })
        reagentFrame.countTextQ1 = CraftSim.GGUI.Text({
            parent=reagentFrame, anchorParent=reagentFrame.icon.frame, anchorA="LEFT",anchorB="RIGHT", 
            offsetX=5, offsetY=12,
            scale=0.9,
            justifyOptions={type="HV", alignH="LEFT", alignV="CENTER"}, text=" x ???"
        })
        reagentFrame.countTextQ2 = CraftSim.GGUI.Text({
            parent=reagentFrame, anchorParent=reagentFrame.icon.frame, anchorA="LEFT",anchorB="RIGHT", 
            offsetX=5,
            scale=0.9,
            justifyOptions={type="HV", alignH="LEFT", alignV="CENTER"}, text=" x ???"
        })
        reagentFrame.countTextQ3 = CraftSim.GGUI.Text({
            parent=reagentFrame, anchorParent=reagentFrame.icon.frame, anchorA="LEFT",anchorB="RIGHT",
            offsetX=5, offsetY=-12,
            scale=0.9,
            justifyOptions={type="HV", alignH="LEFT", alignV="CENTER"}, text=" x ???"
        })
        
        function reagentFrame:SetReagent(itemID, isQuality, countq1, countq2, countq3)
            reagentFrame.icon:SetItem(itemID)
            if not itemID then
                reagentFrame:Hide()
                return
            end
            reagentFrame:Show()
            local countText = ""
            if not isQuality then
                countText = " x " .. countq1
                reagentFrame.countTextNoQ:Show()
                reagentFrame.countTextQ1:Hide()
                reagentFrame.countTextQ2:Hide()
                reagentFrame.countTextQ3:Hide()
                reagentFrame.countTextNoQ:SetText(countText)
            else 
                local qualityIconSize = 15
                local q1Icon = CraftSim.GUTIL:GetQualityIconString(1, qualityIconSize, qualityIconSize, 0, 0)
                local q2Icon = CraftSim.GUTIL:GetQualityIconString(2, qualityIconSize, qualityIconSize, 0, 0)
                local q3Icon = CraftSim.GUTIL:GetQualityIconString(3, qualityIconSize, qualityIconSize, 0, 0)
                reagentFrame.countTextNoQ:Hide()
                reagentFrame.countTextQ1:SetText(q1Icon .. " x " .. countq1)
                reagentFrame.countTextQ2:SetText(q2Icon .. " x " .. countq2)
                reagentFrame.countTextQ3:SetText(q3Icon .. " x " .. countq3)
                reagentFrame.countTextQ1:Show()
                reagentFrame.countTextQ2:Show()
                reagentFrame.countTextQ3:Show()
            end
        end
        
        return reagentFrame
    end

    local spacingX = 80
    local baseX = -15
    local baseY = -10
    local spacingY = -40

    dataFrame.reagentFrames = {
        createReagentFrame("TOPLEFT", dataFrame.savedConfigurationTitle.frame, "BOTTOMLEFT", baseX, baseY),
        createReagentFrame("TOPLEFT", dataFrame.savedConfigurationTitle.frame, "BOTTOMLEFT", baseX + spacingX, baseY),
        createReagentFrame("TOPLEFT", dataFrame.savedConfigurationTitle.frame, "BOTTOMLEFT", baseX + spacingX*2, baseY),
        createReagentFrame("TOPLEFT", dataFrame.savedConfigurationTitle.frame, "BOTTOMLEFT", baseX, baseY + spacingY),
        createReagentFrame("TOPLEFT", dataFrame.savedConfigurationTitle.frame, "BOTTOMLEFT", baseX + spacingX, baseY + spacingY),
        createReagentFrame("TOPLEFT", dataFrame.savedConfigurationTitle.frame, "BOTTOMLEFT", baseX + spacingX*2, baseY + spacingY),
    }

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.optionalReagentsTitle = CraftSim.GGUI.Text({
        parent = dataFrame, anchorParent=dataFrame.noDataText.frame, anchorA="TOP", anchorB="BOTTOM",
        offsetY= -90,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_OPTIONAL_MATERIALS)
    })

    local iconSize = 30
    local function creationOptionalReagentIcon(offsetX)
        return CraftSim.GGUI.Icon({
            parent=dataFrame, anchorParent=dataFrame.optionalReagentsTitle.frame, anchorA="TOP", anchorB="BOTTOM", offsetY=-10,
            offsetX=offsetX, sizeX=iconSize, sizeY=iconSize
        })
    end

    local iconOffsetX = 5

    ---@type GGUI.Icon[] | GGUI.Widget[]
    dataFrame.optionalReagentIcons = {
        [1] = {
            creationOptionalReagentIcon(0)
        },
        [2] = {
            creationOptionalReagentIcon(-(iconOffsetX/2 + iconSize/2)),
            creationOptionalReagentIcon(iconOffsetX/2 + iconSize/2),
        },
        [3] = {
            creationOptionalReagentIcon(-(iconOffsetX + iconSize)),
            creationOptionalReagentIcon(0),
            creationOptionalReagentIcon(iconOffsetX + iconSize),
        },
        [4] = {
            creationOptionalReagentIcon(-(iconOffsetX/2 + iconSize*1.5 + iconOffsetX)),
            creationOptionalReagentIcon(-(iconOffsetX/2 + iconSize/2)),
            creationOptionalReagentIcon(iconOffsetX/2 + iconSize/2),
            creationOptionalReagentIcon(iconOffsetX/2 + iconSize*1.5 + iconOffsetX),
        },
        [5] = {
            creationOptionalReagentIcon(-(iconOffsetX + iconSize*2 + iconOffsetX)),
            creationOptionalReagentIcon(-(iconOffsetX + iconSize)),
            creationOptionalReagentIcon(0),
            creationOptionalReagentIcon(iconOffsetX + iconSize),
            creationOptionalReagentIcon(iconOffsetX + iconSize*2 + iconOffsetX),
        },
    }

    craftDataFrame.content.expandFrame = CreateFrame("Frame", nil, craftDataFrame.content)
    local expandFrame = craftDataFrame.content.expandFrame
    expandFrame:SetSize(craftDataFrame:GetWidth(), sizeYExpanded - sizeYRetracted)
    expandFrame:SetPoint("TOP", dataFrame, "BOTTOM")
    expandFrame:Hide()

    ---@type GGUI.FrameList | GGUI.Widget
    expandFrame.dataList = CraftSim.GGUI.FrameList({
        parent=expandFrame, 
        sizeY=170, anchorA="TOP", anchorB="TOP", anchorParent=expandFrame,
        showHeaderLine = true,
        columnOptions={
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_ITEM_HEADER),
                width=60,
                justifyOptions={type="H", align="CENTER"},
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_CRAFTER_HEADER),
                width=90
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_EXPECTED_COST_HEADER),
                width=130
            },
            {
                label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_CHANCE_HEADER),
                width=80,
            },
            {
                width=65,
            },
            {
                width=25,
            },
        },
        rowConstructor=function (columns)
            local itemColumn = columns[1]
            local crafterColumn = columns[2]
            local expectedCostColumn = columns[3]
            local chanceColumn = columns[4]
            local loadButtonColumn = columns[5]
            local deleteButtonColumn = columns[6]

            ---@type GGUI.Icon | GGUI.Widget
            itemColumn.itemIcon = CraftSim.GGUI.Icon({
                parent=itemColumn, anchorParent=itemColumn,
                sizeX=25,sizeY=25, qualityIconScale=1.4,
            })

            ---@type GGUI.Text | GGUI.Widget
            crafterColumn.text = CraftSim.GGUI.Text({
                parent=crafterColumn, anchorParent=crafterColumn,
                text="Abcdefghijkl", justifyOptions={type="H", align="LEFT"},
                fixedWidth=crafterColumn:GetWidth(),
            })

            ---@type GGUI.Text | GGUI.Widget
            expectedCostColumn.text = CraftSim.GGUI.Text({
                parent=expectedCostColumn, anchorParent=expectedCostColumn,
                text=CraftSim.GUTIL:FormatMoney(10000000), justifyOptions={type="H", align="LEFT"},
                fixedWidth=expectedCostColumn:GetWidth(),
            })

            ---@type GGUI.Text | GGUI.Widget
            chanceColumn.text = CraftSim.GGUI.Text({
                parent=chanceColumn, anchorParent=chanceColumn,
                text="100%", justifyOptions={type="H", align="LEFT"},
                fixedWidth=chanceColumn:GetWidth(),
            })

            ---@type GGUI.Button | GGUI.Widget
            loadButtonColumn.loadButton = CraftSim.GGUI.Button({
                parent=loadButtonColumn, anchorParent=loadButtonColumn,
                label="Load", sizeX=60,
                initialStatusID="LOAD",
                clickCallback=function (gButton)
                    ---@type CraftSim.CraftData
                    local craftData = gButton.craftData
                    craftData:SetActive()
                    CraftSim.MAIN:TriggerModulesErrorSafe()
                end
            })

            loadButtonColumn.loadButton:SetStatusList({
                {
                    statusID="LOAD",
                    enabled=true,
                    label="Activate",
                },
                {
                    statusID="LOADED",
                    enabled=false,
                    label="Active",
                },
            })

            ---@type GGUI.Button | GGUI.Widget
            deleteButtonColumn.deleteButton = CraftSim.GGUI.Button({
                parent=deleteButtonColumn, anchorParent=deleteButtonColumn,
                label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.FALSE, 0.1), sizeX=25,
                clickCallback=function(gButton)
                    ---@type CraftSim.CraftData
                    gButton.craftData:Delete()
                    CraftSim.MAIN:TriggerModulesErrorSafe()
                end
            })
        end,
    })

    ---@param craftData CraftSim.CraftData
    function craftDataFrame:AddCraftDataToList(craftData)
        expandFrame.dataList:Add(function (row) 
            row.expectedCosts = craftData:GetExpectedCosts()
            row.crafter = craftData.crafterName
            row.craftingChance = craftData.chance
            row.craftData = craftData
            local classColor = C_ClassColor.GetClassColor(craftData.crafterClass)
            row.columns[1].itemIcon:SetItem(craftData.itemLink)
            row.columns[2].text:SetText(classColor:WrapTextInColorCode(row.crafter))
            row.columns[3].text:SetText(CraftSim.GUTIL:FormatMoney(row.expectedCosts))
            row.columns[4].text:SetText(row.craftingChance*100 .. "%")
            row.columns[5].loadButton.craftData = craftData
            row.columns[6].deleteButton.craftData = craftData

            if craftData:IsActive() then
                row.columns[5].loadButton:SetStatus("LOADED")
            else
                row.columns[5].loadButton:SetStatus("LOAD")
            end
        end)
    end

    function craftDataFrame:RemoveCraftDataFromList(craftData)
        local itemStringA = CraftSim.GUTIL:GetItemStringFromLink(craftData.itemLink)
        itemStringA = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemStringA)
        craftDataFrame.content.expandFrame.dataList:Remove(function (row) 
            local itemStringB = CraftSim.GUTIL:GetItemStringFromLink(row.craftData.itemLink)
            itemStringB = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemStringB)
            -- if crafter and item string equal, remove it from the craft data list
            return row.crafter == craftData.crafterName and itemStringA == itemStringB
        end, 1)
    end

    ---@type GGUI.TextInput | GGUI.Widget
    dataFrame.sendDataInput = CraftSim.GGUI.TextInput({
        parent=dataFrame, anchorParent=dataFrame.deleteCraftDataButton.frame,
        sizeX=100, anchorA="LEFT", anchorB="RIGHT", offsetX=10,
    })

    dataFrame.sendDataButton = CraftSim.GGUI.Button({
        parent=dataFrame, anchorParent=dataFrame.sendDataInput.frame,
        anchorA="LEFT",anchorB="RIGHT", label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CRAFT_DATA_SEND), adjustWidth=true,
        clickCallback=function ()
            local activeData = craftDataFrame.activeData
            local target = dataFrame.sendDataInput:GetText()
            if activeData and target ~= "" then
                CraftSim.CRAFTDATA:SendCraftData(activeData, target)
            end
        end,
        initialStatusID="READY"
    })

    dataFrame.sendDataButton:SetStatusList({
        {
            statusID="READY",
            enabled=true,
        },
        {
            statusID="DISABLED",
            enabled=false,
        },
    })

    dataFrame:Hide()

    CraftSim.CRAFTDATA.frame = craftDataFrame
end

---@param recipeData CraftSim.RecipeData
function CraftSim.CRAFTDATA.FRAMES:UpdateDisplay(recipeData)

    local craftDataFrame = CraftSim.CRAFTDATA.frame

    print("Update Display")
    local selectedItem = nil
    -- set current recipeID, only populate dropdown if recipeID is different from the previous one
    if craftDataFrame.recipeID ~= recipeData.recipeID then
        craftDataFrame.recipeID = recipeData.recipeID
        craftDataFrame.content.dataFrame:Hide()
    else
        selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
    end

    CraftSim.GUTIL:ContinueOnAllItemsLoaded(recipeData.resultData.itemsByQuality, function ()
        local dropdownData = {}
        if recipeData.supportsQualities then
            table.foreach(recipeData.resultData.itemsByQuality, function (_, item)
                table.insert(dropdownData, {
                    label = item:GetItemLink(),
                    value = item,
                })
            end)
        else
            local item = recipeData.resultData.itemsByQuality[1]
            if item then
                table.insert(dropdownData, {
                    label = item:GetItemLink(),
                    value = item,
                })
            end
        end
        local label = nil
        local value = nil
        if selectedItem then
            local selectedQuality = CraftSim.GUTIL:GetQualityIDFromLink(selectedItem:GetItemLink()) or 1
            value = recipeData.resultData.itemsByQuality[selectedQuality]
            label = value:GetItemLink()
        end

        craftDataFrame.content.resultsDropdown:SetData({data=dropdownData, initialValue=value, initialLabel=label})

        if value then
            CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(value)
        end
    end)

    CraftSim.CRAFTDATA.FRAMES:UpdateCraftDataList()
end

---@param item ItemMixin
function CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(item)
    local craftDataFrame = CraftSim.CRAFTDATA.frame
    local dataFrame = craftDataFrame.content.dataFrame

    dataFrame.itemIcon:SetItem(item)
    dataFrame:Show()

    local recipeData = CraftSim.MAIN.currentRecipeData

    if not recipeData or not recipeData:IsResult(item) then
        return
    end

    local craftDataSerialized = CraftSim.CraftData:GetActiveCraftDataByItem(item)


    CraftSim.FRAME:ToggleFrame(dataFrame.savedConfigurationTitle, craftDataSerialized)
    CraftSim.FRAME:ToggleFrame(dataFrame.noDataText, not craftDataSerialized)
    dataFrame.optionalReagentsTitle:Hide()
    -- hide all optional icons per default
    table.foreach(dataFrame.optionalReagentIcons, function (_, icons)
        table.foreach(icons, function (_, icon)
            icon:Hide()
        end)
    end)

    local qualityID = recipeData:GetResultQuality(item)

    if craftDataSerialized then
        local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
        craftDataFrame.activeData = craftData
        dataFrame.saveButton:SetStatus("UPDATE")
        dataFrame.deleteCraftDataButton:SetEnabled(true)
        print("deserializeddata:")
        print(craftData, true)
        local expectedCosts = craftData:GetExpectedCosts()
        local minimumCosts = craftData:GetCraftingCosts()
        local classColor = C_ClassColor.GetClassColor(craftData.crafterClass)
        local crafterText = classColor:WrapTextInColorCode(craftData.crafterName)
    
        dataFrame.crafterValue:SetText(crafterText)
        dataFrame.expectedCostsValue:SetText(CraftSim.GUTIL:FormatMoney(expectedCosts))
        dataFrame.minimumCostsValue:SetText(CraftSim.GUTIL:FormatMoney(minimumCosts))
        dataFrame.expectedCraftsValue:SetText(CraftSim.GUTIL:Round(craftData.expectedCrafts, 2))
        dataFrame.chanceValue:SetText(CraftSim.GUTIL:Round(craftData.chance*100,2) .. "%")
    
        table.foreach(dataFrame.reagentFrames, function (reagentIndex, reagentFrame)
            local reagent = craftData.requiredReagents[reagentIndex]
    
            if reagent then
                if reagent.hasQuality then
                    reagentFrame:SetReagent(reagent.items[1].item:GetItemID(), true, 
                    reagent.items[1].quantity,
                    reagent.items[2].quantity,
                    reagent.items[3].quantity)
                else
                    reagentFrame:SetReagent(reagent.items[1].item:GetItemID(), false, reagent.items[1].quantity)
                end
                reagentFrame:Show()
            else
                reagentFrame:Hide()
            end
        end)

        local numOptionals = #craftData.optionalReagents

        if numOptionals > 0 then
            dataFrame.optionalReagentsTitle:Show()
            local icons = dataFrame.optionalReagentIcons[numOptionals]

            for iconIndex, icon in pairs(icons) do
                local optionalReagent = craftData.optionalReagents[iconIndex]
                icon:SetItem(optionalReagent.item)
                icon:Show()
            end
        end
        dataFrame.sendDataButton:SetStatus("READY")
    else
        craftDataFrame.activeData = nil
        dataFrame.saveButton:SetStatus("SAVE")
        dataFrame.deleteCraftDataButton:SetEnabled(false)
        dataFrame.expectedCostsValue:SetText("?")
        dataFrame.minimumCostsValue:SetText("?")
        dataFrame.expectedCraftsValue:SetText("?")
        dataFrame.chanceValue:SetText("?")
        dataFrame.crafterValue:SetText("?")
        dataFrame.sendDataButton:SetStatus("DISABLED")
        
        table.foreach(dataFrame.reagentFrames, function (_, reagentFrame)
            reagentFrame:Hide()
        end)
    end    

    if recipeData.supportsQualities then
        -- if unreachable
        if not recipeData.resultData.expectedCraftsByQuality[qualityID] then
            dataFrame.saveButton:SetStatus("UNREACHABLE")
        end
    end
end

function CraftSim.CRAFTDATA.FRAMES:UpdateCraftDataList()
    -- --- update craftData list
    local craftDataFrame = CraftSim.CRAFTDATA.frame
    local expandFrame = craftDataFrame.content.expandFrame
    expandFrame.dataList:Remove() -- clear all

    for _, recipeItemList in pairs(CraftSimCraftData) do
        for _, itemData in pairs(recipeItemList) do
            for _, craftDataSerialized in pairs(itemData.dataPerCrafter) do
                local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
                craftDataFrame:AddCraftDataToList(craftData)
            end
        end
    end

    local recipeData = CraftSim.MAIN.currentRecipeData

    if recipeData then
        expandFrame.dataList:UpdateDisplay(function (rowA, rowB)
            return rowA.craftData.recipeID == recipeData.recipeID
        end)
    else
        expandFrame.dataList:UpdateDisplay()
    end
end
