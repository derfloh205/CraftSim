_, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFT_DATA)

CraftSim.CRAFTDATA.FRAMES = {}

CraftSim.CRAFTDATA.frame = nil

function CraftSim.CRAFTDATA.FRAMES:Init()
    local sizeYRetracted = 400
    local sizeYExpanded = 600

    ---@type GGUI.Frame | GGUI.Widget
    local craftDataFrame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame,anchorFrame=UIParent,
        sizeX=500,sizeY=sizeYRetracted,
        title="CraftSim Craft Data",
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        collapseable=true,moveable=true,closeable=true,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCraftData"),
        frameID=CraftSim.CONST.FRAMES.CRAFT_DATA,
        frameStrata="DIALOG",
        initialStatusID="RETRACTED",
    })

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
        anchorA="TOP", anchorB="BOTTOM", offsetY=-30, width=200,
        clickCallback=function (_, _, item)
            CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(item)
        end
    })

    ---@type GGUI.Button | GGUI.Widget
    craftDataFrame.content.clearDataAll = CraftSim.GGUI.Button({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.content, anchorA="TOPLEFT", anchorB="TOPLEFT", 
        offsetX=10, offsetY=-10, adjustWidth=true,
        label="Delete for all Recipes",
        clickCallback=function ()
            CraftSim.CRAFTDATA:DeleteAll()

            local selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
            if selectedItem then
                CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(selectedItem)
            end
        end
    })
    ---@type GGUI.Button | GGUI.Widget
    craftDataFrame.content.clearDataRecipe = CraftSim.GGUI.Button({
        parent=craftDataFrame.content,anchorParent=craftDataFrame.content.clearDataAll.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT", 
        label="Delete for Recipe", adjustWidth=true,
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
                craftDataFrame.content.dataFrame.dataList:Show()
            elseif craftDataFrame:GetStatus() == "EXPANDED" then
                craftDataFrame:SetStatus("RETRACTED")
                craftDataFrame.expandListButton:SetStatus("DOWN")
                craftDataFrame.content.dataFrame.dataList:Hide()
            end
        end
    })

    craftDataFrame.expandListButton:SetStatusList({
        {
            statusID="UP",
            label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_UP, 0.4)
        },
        {
            statusID="DOWN",
            label=CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.ARROW_DOWN, 0.4)
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
        text="Crafter: ", justifyOptions={type="H", align="LEFT"},
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
        text="Expected Crafts: ", justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCraftsValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCraftsTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=1, justifyOptions={type="H", align="LEFT"},
    })
    CraftSim.GGUI.HelpIcon({parent=dataFrame, anchorParent=dataFrame.expectedCraftsValue.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.EXPECTED_CRAFTS_EXPLANATION)})

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.chanceTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCraftsTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT", offsetY=sideTextSpacing,
        text="Crafting Chance: ", justifyOptions={type="H", align="LEFT"},
    })

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.chanceValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.chanceTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text="100%", justifyOptions={type="H", align="LEFT"},
    })

    CraftSim.GGUI.HelpIcon({parent=dataFrame, anchorParent=dataFrame.chanceValue.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.UPGRADE_CHANCE_EXPLANATION)})

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCostsTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.chanceTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT",offsetY=sideTextSpacing,
        text="Expected Costs: ", justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.expectedCostsValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCostsTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=CraftSim.GUTIL:FormatMoney(1234567000), justifyOptions={type="H", align="LEFT"},
    })

    CraftSim.GGUI.HelpIcon({parent=dataFrame, anchorParent=dataFrame.expectedCostsValue.frame, 
        anchorA="LEFT", anchorB="RIGHT", offsetX=5, text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.EXPECTED_COSTS_EXPLANATION)})

    ---@type GGUI.Text | GGUI.Widget
    dataFrame.minimumCostsTitle = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.expectedCostsTitle.frame,
        anchorA="TOPLEFT", anchorB="BOTTOMLEFT",offsetY=sideTextSpacing,
        text="Minimum Costs: ", justifyOptions={type="H", align="LEFT"},
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.minimumCostsValue = CraftSim.GGUI.Text({
        parent=dataFrame,anchorParent=dataFrame.minimumCostsTitle.frame,
        anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        text=CraftSim.GUTIL:FormatMoney(1234567000), justifyOptions={type="H", align="LEFT"},
    })

    ---@type GGUI.Button | GGUI.Widget
    dataFrame.saveButton = CraftSim.GGUI.Button({
        parent=dataFrame, anchorParent=dataFrame, label="Save",
        anchorA="TOP", anchorB="TOP", offsetX=-30, offsetY=-70, sizeX=60,
        clickCallback=function() 
            local selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
            if selectedItem then
                print("Save Button: selectedItem: " .. tostring(selectedItem:GetItemLink()))
                CraftSim.CRAFTDATA:UpdateCraftData(selectedItem)
                CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(selectedItem)
            end
        end,
        initialStatus="SAVE",
    })

    dataFrame.saveButton:SetStatusList({
        {
            statusID="SAVE",
            label="Save",
            enabled=true,
            sizeX=60,
        },
        {
            statusID="UPDATE",
            label="Update",
            enabled=true,
            sizeX=60,
        },
        {
            statusID="UNREACHABLE",
            label="Unreachable",
            enabled=false,
            sizeX=100,
        }
    })

    ---@type GGUI.Button | GGUI.Widget
    dataFrame.deleteDataItem = CraftSim.GGUI.Button({
        parent=dataFrame,anchorParent=dataFrame.saveButton.frame, anchorA="LEFT", anchorB="RIGHT", 
        label="Delete", adjustWidth=true,
        clickCallback=function ()
            local selectedItem = craftDataFrame.content.resultsDropdown.selectedValue
            if selectedItem then
                CraftSim.CRAFTDATA:DeleteForItem(selectedItem)
                CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(selectedItem)
            end
        end
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.savedConfigurationTitle = CraftSim.GGUI.Text({
        parent=dataFrame, anchorParent=dataFrame, anchorA="TOP", anchorB="TOP",
        text="Saved Material Configuration", offsetY=-100
    })
    ---@type GGUI.Text | GGUI.Widget
    dataFrame.noDataText = CraftSim.GGUI.Text({
        parent=dataFrame, anchorParent=dataFrame, anchorA="TOP", anchorB="TOP",
        text=CraftSim.GUTIL:ColorizeText("No data found for this item", CraftSim.GUTIL.COLORS.RED), offsetY=-100
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
        text="Optional Reagents"
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

    ---@type GGUI.FrameList | GGUI.Widget
    dataFrame.dataList = CraftSim.GGUI.FrameList({
        parent=dataFrame, 
        sizeY=150, anchorA="TOP", anchorB="BOTTOM", anchorParent=dataFrame,
        showHeaderLine = true,
        columnOptions={
            {
                label="Crafter",
                width=90
            },
            {
                label="Expected Cost",
                width=130
            },
            {
                label="Chance",
                width=80,
            },
            {
                width=90,
            },
        },
        rowConstructor=function (columns)
            local crafterColumn = columns[1]
            local expectedCostColumn = columns[2]
            local chanceColumn = columns[3]
            local loadButtonColumn = columns[4]

            print("row constructor called")

            crafterColumn.text = CraftSim.GGUI.Text({
                parent=crafterColumn, anchorParent=crafterColumn,
                text="Abcdefghijkl", justifyOptions={type="H", align="LEFT"},
                fixedWidth=crafterColumn:GetWidth(),
            })
            expectedCostColumn.text = CraftSim.GGUI.Text({
                parent=expectedCostColumn, anchorParent=expectedCostColumn,
                text=CraftSim.GUTIL:FormatMoney(10000000), justifyOptions={type="H", align="LEFT"},
                fixedWidth=expectedCostColumn:GetWidth(),
            })

            chanceColumn.text = CraftSim.GGUI.Text({
                parent=chanceColumn, anchorParent=chanceColumn,
                text="100%", justifyOptions={type="H", align="LEFT"},
                fixedWidth=chanceColumn:GetWidth(),
            })

            loadButtonColumn.loadButton = CraftSim.GGUI.Button({
                parent=loadButtonColumn, anchorParent=loadButtonColumn,
                label="Load", sizeX=40,
                initialStatusID="LOAD"
            })

            loadButtonColumn.loadButton:SetStatusList({
                {
                    statusID="LOAD",
                    enabled=true,
                    label="Load",
                    sizeX=40,
                },
                {
                    statusID="LOADED",
                    enabled=false,
                    label="Loaded",
                    sizeX=60,
                },
            })
        end,
    })

    -- dataFrame.dataList:UpdateDisplay(function (rowA, rowB)
    --     return rowA.chance > rowB.chance
    -- end)

    dataFrame.dataList:Hide()

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
        table.foreach(recipeData.resultData.itemsByQuality, function (_, item)
            table.insert(dropdownData, {
                label = item:GetItemLink(),
                value = item,
            })
        end)
        local label = nil
        local value = nil
        if selectedItem then
            local selectedQuality = CraftSim.GUTIL:GetQualityIDFromLink(selectedItem:GetItemLink())
            value = recipeData.resultData.itemsByQuality[selectedQuality]
            label = value:GetItemLink()
        end

        craftDataFrame.content.resultsDropdown:SetData({data=dropdownData, initialValue=value, initialLabel=label})

        if value then
            CraftSim.CRAFTDATA.FRAMES:UpdateDataFrame(value)
        end
    end)
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

    -- link should be loaded here cause we need to wait for it anyway to populate the dropdown
    local itemString = CraftSim.GUTIL:GetItemStringFromLink(item:GetItemLink())
    itemString = CraftSim.UTIL:RemoveLevelSpecBonusIDStringFromItemString(itemString)
    print("Fetch Craft Data for: " .. tostring(itemString))
    print("link: " .. item:GetItemLink())

    if not itemString then
        return
    end

    CraftSimCraftData[recipeData.recipeID] = CraftSimCraftData[recipeData.recipeID] or {}
    CraftSimCraftData[recipeData.recipeID][itemString] = CraftSimCraftData[recipeData.recipeID][itemString] or {
        activeData = nil,
        dataPerCrafter = {},
    }
    local craftDataSerialized = CraftSimCraftData[recipeData.recipeID][itemString].activeData

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
        dataFrame.saveButton:SetStatus("UPDATE")
        dataFrame.deleteDataItem:SetEnabled(true)
        local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
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
    else
        dataFrame.saveButton:SetStatus("SAVE")
        dataFrame.deleteDataItem:SetEnabled(false)
        dataFrame.expectedCostsValue:SetText("?")
        dataFrame.minimumCostsValue:SetText("?")
        dataFrame.expectedCraftsValue:SetText("?")
        dataFrame.chanceValue:SetText("?")
        dataFrame.crafterValue:SetText("?")
        
        table.foreach(dataFrame.reagentFrames, function (_, reagentFrame)
            reagentFrame:Hide()
        end)
    end    

    -- if unreachable
    if not recipeData.resultData.expectedCraftsByQuality[qualityID] then
        dataFrame.saveButton:SetStatus("UNREACHABLE")
    end

    --- update craftData list
    dataFrame.dataList:Remove() -- clear all

    for _, craftDataSerialized in pairs(CraftSimCraftData[recipeData.recipeID][itemString].dataPerCrafter) do
        local craftData = CraftSim.CraftData:Deserialize(craftDataSerialized)
        dataFrame.dataList:Add(function (row)
            row.expectedCost = craftData:GetExpectedCosts()
            row.crafter = craftData.crafterName
            row.craftingChance = craftData.chance
            local classColor = C_ClassColor.GetClassColor(craftData.crafterClass)
            row.columns[1].text:SetText(classColor:WrapTextInColorCode(row.crafter))
            row.columns[2].text:SetText(CraftSim.GUTIL:FormatMoney(row.expectedCost))
            row.columns[3].text:SetText(row.craftingChance*100 .. "%")

            local dataLoaded = false
            if CraftSimCraftData[recipeData.recipeID][itemString].activeData then
                if CraftSimCraftData[recipeData.recipeID][itemString].activeData.crafterName == craftData.crafterName then
                    dataLoaded = true
                end
            end

            if dataLoaded then
                row.columns[4].loadButton:SetStatus("LOADED")
            else
                row.columns[4].loadButton:SetStatus("LOAD")
            end
        end)
    end

    dataFrame.dataList:UpdateDisplay(function (rowA, rowB)
        return rowA.expectedCosts < rowB.expectedCosts
    end)
end
