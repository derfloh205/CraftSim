AddonName, CraftSim = ...

CraftSim.PRICE_DETAILS.FRAMES = {}

CraftSim.PRICE_DETAILS.frame = nil
CraftSim.PRICE_DETAILS.frameWO = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_DETAILS)

function CraftSim.PRICE_DETAILS.FRAMES:Init()
    local sizeX=370
    local sizeY=200
    local offsetX=-5
    local offsetY=140

    CraftSim.PRICE_DETAILS.frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm, 
        anchorParent=ProfessionsFrame,
        anchorA="BOTTOMLEFT",anchorB="BOTTOMRIGHT",
        offsetX=offsetX,offsetY=offsetY,
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.PRICE_DETAILS, 
        title="CraftSim Price Details",
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesPriceDetails"),
    })
    
    CraftSim.PRICE_DETAILS.frameWO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, 
        anchorParent=ProfessionsFrame,
        anchorA="BOTTOMLEFT",anchorB="BOTTOMRIGHT",
        offsetX=offsetX,offsetY=offsetY,
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.PRICE_DETAILS_WORK_ORDER, 
        title="CraftSim Price Details " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesPriceDetails"),
    })

    local function createContent(frame)

        ---@type GGUI.FrameList | GGUI.Widget
        frame.content.priceDetailsList = CraftSim.GGUI.FrameList({
            parent=frame.content,anchorParent=frame.title.frame,anchorA="TOP",anchorB="BOTTOM",offsetY=-30, offsetX=-10,
            sizeY=140, showHeaderLine=true,
            columnOptions={
                {
                    label="Inv/AH",
                    width=60,
                    justifyOptions={type="H",align="CENTER"}
                },
                {
                    label="Item",
                    width=40,
                    justifyOptions={type="H",align="CENTER"}
                },
                {
                    label="Price / Item",
                    width=110,
                },
                {
                    label="Profit / Item",
                    width=110,
                }
            },
            rowConstructor=function (columns)
                local invColumn = columns[1]
                local itemColumn = columns[2]
                local priceColumn = columns[3]
                local profitColumn = columns[4]

                invColumn.text = CraftSim.GGUI.Text({
                    parent=invColumn,anchorParent=invColumn
                })

                itemColumn.icon = CraftSim.GGUI.Icon({
                    parent=itemColumn,anchorParent=itemColumn,
                    sizeX=25,sizeY=25,qualityIconScale=1.4
                })

                priceColumn.text = CraftSim.GGUI.Text({
                    parent=priceColumn,anchorParent=priceColumn,
                    justifyOptions={type="H",align="LEFT"}, fixedWidth=priceColumn:GetWidth()
                })
                profitColumn.text = CraftSim.GGUI.Text({
                    parent=profitColumn,anchorParent=profitColumn,
                    justifyOptions={type="H",align="LEFT"}, fixedWidth=profitColumn:GetWidth()
                })
            end
        })
        
    
        CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
        frame:Hide()
    end

    createContent(CraftSim.PRICE_DETAILS.frame)
    createContent(CraftSim.PRICE_DETAILS.frameWO)
end


---@param recipeData CraftSim.RecipeData
---@param profitPerQuality number[]
---@param currentQuality number
---@param exportMode number
function CraftSim.PRICE_DETAILS.FRAMES:UpdateDisplay(recipeData, profitPerQuality, currentQuality, exportMode)
    local priceDetailsFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        priceDetailsFrame = CraftSim.PRICE_DETAILS.frameWO
    else
        priceDetailsFrame = CraftSim.PRICE_DETAILS.frame
    end

    local priceData = recipeData.priceData
    local resultData = recipeData.resultData

    local itemQualityList = resultData.itemsByQuality
    if not recipeData.supportsQualities then
        itemQualityList = {itemQualityList[1]} -- force one of an item (illustrious insight e.g. has always 3 items in it for whatever reason)
    end

    priceDetailsFrame.content.priceDetailsList:Remove()

    for _, resultItem in pairs(itemQualityList) do
        resultItem:ContinueOnItemLoad(function ()
            priceDetailsFrame.content.priceDetailsList:Add(function(row) 
                local invColumn = row.columns[1]
                local itemColumn = row.columns[2]
                local priceColumn = row.columns[3]
                local profitColumn = row.columns[4]

                local itemLink = resultItem:GetItemLink()
                itemColumn.icon:SetItem(resultItem)
                local price = CraftSim.PRICEDATA:GetMinBuyoutByItemLink(itemLink)
                local profit = (price*CraftSim.CONST.AUCTION_HOUSE_CUT) - (priceData.craftingCosts / recipeData.baseItemAmount)
                priceColumn.text:SetText(CraftSim.GUTIL:FormatMoney(price))
                profitColumn.text:SetText(CraftSim.GUTIL:FormatMoney(profit, true))

                local itemCount = GetItemCount(itemLink, true, false, true)
                local ahCount = CraftSim.PRICEDATA:GetAuctionAmount(itemLink)

                if ahCount then
                    invColumn.text:SetText((itemCount or 0) .. "/" .. ahCount)
                else
                    invColumn.text:SetText(itemCount or 0)
                end
            end)
        end)
    end

    priceDetailsFrame.content.priceDetailsList:UpdateDisplay()
end