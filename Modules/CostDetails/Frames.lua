_, CraftSim = ...


CraftSim.COST_DETAILS.FRAMES = {}

CraftSim.COST_DETAILS.frame = nil
CraftSim.COST_DETAILS.frameWO = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.COST_DETAILS)

function CraftSim.COST_DETAILS.FRAMES:Init()

    local sizeX=480
    local sizeY=270
    local offsetX=-5
    local offsetY=-120

    CraftSim.COST_DETAILS.frame = CraftSim.GGUI.Frame({
            parent=ProfessionsFrame.CraftingPage.SchematicForm, 
            anchorParent=ProfessionsFrame,
            anchorA="BOTTOM",anchorB="BOTTOM",
            sizeX=sizeX,sizeY=sizeY, offsetY=offsetY, offsetX=offsetX,
            frameID=CraftSim.CONST.FRAMES.COST_DETAILS, 
            title="CraftSim Cost Details",
            collapseable=true,
            closeable=true,
            moveable=true,
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCostDetails"),
        })
    CraftSim.COST_DETAILS.frameWO = CraftSim.GGUI.Frame({
            parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, 
            anchorParent=ProfessionsFrame,
            anchorA="BOTTOM",anchorB="BOTTOM",
            sizeX=sizeX,sizeY=sizeY, offsetY=offsetY, offsetX=offsetX,
            frameID=CraftSim.CONST.FRAMES.COST_DETAILS_WO, 
            title="CraftSim Cost Details " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
            collapseable=true,
            closeable=true,
            moveable=true,
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCostDetails"),
        })

    local function createContent(frame)
        frame.content.craftingCostsTitle = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.title.frame, anchorA="TOP", anchorB="BOTTOM",
            offsetX=-30, offsetY=-20, text="Crafting Costs: ",
        })
        frame.content.craftingCostsValue = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content.craftingCostsTitle.frame, anchorA="LEFT", anchorB="RIGHT",
            text=CraftSim.GUTIL:FormatMoney(123456789), justifyOptions={type="H",align="LEFT"}
        })

        CraftSim.GGUI.HelpIcon({
            parent=frame.content,anchorParent=frame.title.frame,
            anchorA="LEFT", anchorB="RIGHT", offsetX=5,
            text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.COST_DETAILS_EXPLANATION)
        })


        frame.content.reagentList = CraftSim.GGUI.FrameList({
            parent=frame.content, anchorParent=frame.content, anchorA="TOP", anchorB="TOP", offsetY=-100, 
            sizeY=150, showHeaderLine=true,
            columnOptions = {
                {
                    label="Item",
                    width=40,
                    justifyOptions={type="H", align="CENTER"}
                },
                {
                    label="AH Price",
                    width=110,
                },
                {
                    label="Override",
                    width=110,
                },
                {
                    label="CraftData",
                    width=110,
                },
                {
                    label="Used",
                    width=40,
                    justifyOptions={type="H", align="CENTER"}
                },
            },
            rowConstructor=function (columns)
                local itemColumn = columns[1]
                local ahPriceColumn = columns[2]
                local overrideColumn = columns[3]
                local craftDataColumn = columns[4]
                local usedPriceColumn = columns[5]

                itemColumn.itemIcon = CraftSim.GGUI.Icon({
                    parent=itemColumn,anchorParent=itemColumn,
                    sizeX=25,sizeY=25,
                    qualityIconScale=1.4
                })

                ahPriceColumn.text = CraftSim.GGUI.Text({
                    parent=ahPriceColumn,anchorParent=ahPriceColumn,
                    anchorA="LEFT",anchorB="LEFT",justifyOptions={type="H",align="LEFT"},
                    text=CraftSim.GUTIL:FormatMoney(123456789)
                })
                overrideColumn.text = CraftSim.GGUI.Text({
                    parent=overrideColumn,anchorParent=overrideColumn,
                    anchorA="LEFT",anchorB="LEFT",justifyOptions={type="H",align="LEFT"},
                    text=CraftSim.GUTIL:FormatMoney(123456789)
                })
                craftDataColumn.text = CraftSim.GGUI.Text({
                    parent=craftDataColumn,anchorParent=craftDataColumn,
                    anchorA="LEFT",anchorB="LEFT",justifyOptions={type="H",align="LEFT"},
                    text=CraftSim.GUTIL:FormatMoney(123456789)
                })
                usedPriceColumn.text = CraftSim.GGUI.Text({
                    parent=usedPriceColumn,anchorParent=usedPriceColumn,
                    text=CraftSim.GUTIL:ColorizeText("AH", CraftSim.GUTIL.COLORS.GREEN)
                })

                function usedPriceColumn:SetAH()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("AH", CraftSim.GUTIL.COLORS.GREEN))
                end
                function usedPriceColumn:SetOverride()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("OR", CraftSim.GUTIL.COLORS.LEGENDARY))
                end
                function usedPriceColumn:SetCraftData()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("CD", CraftSim.GUTIL.COLORS.BRIGHT_BLUE))
                end
                function usedPriceColumn:SetUnknown()
                    usedPriceColumn.text:SetText(CraftSim.GUTIL:ColorizeText("?", CraftSim.GUTIL.COLORS.RED))
                end
            end
        })
    end

    createContent(CraftSim.COST_DETAILS.frame)
    createContent(CraftSim.COST_DETAILS.frameWO)
end


---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.COST_DETAILS:UpdateDisplay(recipeData, exportMode)
    local costDetailsFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        costDetailsFrame = CraftSim.COST_DETAILS.frameWO
    else
        costDetailsFrame = CraftSim.COST_DETAILS.frame
    end

    costDetailsFrame.content.craftingCostsValue:SetText(CraftSim.GUTIL:FormatMoney(recipeData.priceData.craftingCosts))

    costDetailsFrame.content.reagentList:Remove()

    for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
        for _, reagentItem in pairs(reagent.items) do
            costDetailsFrame.content.reagentList:Add(function(row) 
                row.columns[1].itemIcon:SetItem(reagentItem.item)
                local price, priceInfo = CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true)
                row.columns[2].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice))
                if priceInfo.isOverride then
                    row.columns[3].text:SetText(CraftSim.GUTIL:FormatMoney(price))
                else
                    row.columns[3].text:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end
                if priceInfo.craftDataExpectedCosts then
                    row.columns[4].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.craftDataExpectedCosts))
                else
                    row.columns[4].text:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end

                if priceInfo.isAHPrice then
                    row.columns[5]:SetAH()
                elseif priceInfo.isOverride then
                    row.columns[5]:SetOverride()
                elseif priceInfo.isCraftData then
                    row.columns[5]:SetCraftData()
                else
                    row.columns[5]:SetUnknown()
                end
            end)
        end
    end

    local possibleOptionals = {}
    local slots = CraftSim.GUTIL:Concat({recipeData.reagentData.optionalReagentSlots, recipeData.reagentData.finishingReagentSlots})
    for _, slot in pairs(slots) do
        possibleOptionals = CraftSim.GUTIL:Concat({possibleOptionals, slot.possibleReagents})
    end

    for _, optionalReagent in pairs(possibleOptionals) do
        costDetailsFrame.content.reagentList:Add(function(row) 
            row.columns[1].itemIcon:SetItem(optionalReagent.item)
            local price, priceInfo = CraftSim.PRICEDATA:GetMinBuyoutByItemID(optionalReagent.item:GetItemID(), true)
            row.columns[2].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.ahPrice))
                if priceInfo.isOverride then
                    row.columns[3].text:SetText(CraftSim.GUTIL:FormatMoney(price))
                else
                    row.columns[3].text:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end
                if priceInfo.craftDataExpectedCosts then
                    row.columns[4].text:SetText(CraftSim.GUTIL:FormatMoney(priceInfo.craftDataExpectedCosts))
                else
                    row.columns[4].text:SetText(CraftSim.GUTIL:ColorizeText("-", CraftSim.GUTIL.COLORS.GREY))
                end

                if priceInfo.isAHPrice then
                    row.columns[5]:SetAH()
                elseif priceInfo.isOverride then
                    row.columns[5]:SetOverride()
                elseif priceInfo.isCraftData then
                    row.columns[5]:SetCraftData()
                else
                    row.columns[5]:SetUnknown()
                end
        end)
    end

    costDetailsFrame.content.reagentList:UpdateDisplay()
end
