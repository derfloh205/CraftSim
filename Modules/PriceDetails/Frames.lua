AddonName, CraftSim = ...

CraftSim.PRICE_DETAILS.FRAMES = {}

CraftSim.PRICE_DETAILS.frame = nil
CraftSim.PRICE_DETAILS.frameWO = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_DETAILS)

function CraftSim.PRICE_DETAILS.FRAMES:Init()
    local sizeX=270
    local sizeY=220
    local offsetX=-5
    local offsetY=130

    local sizeYQ1 = 100
    local sizeYQ3 = 165
    local sizeYQ5 = 225

    local function restoreStatus(self) 
        self:SetStatus(self.activeStatusID)
    end

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
        initialStatusID="Q5",
        onCollapseOpenCallback=restoreStatus,
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
        initialStatusID="Q5",
        onCollapseOpenCallback=restoreStatus,
    })

    local function createContent(frame)
        frame.content.resultProfitsTitle = CraftSim.GGUI.Text({
            parent=frame.content, anchorParent=frame.title.frame, offsetY=-5,
            text="Price/Profit By Quality", anchorA="TOP", anchorB="BOTTOM"
        })

        local profitFrameBaseX=40
    
        local function createProfitFrame(offsetY, parent, anchorParent)
            local profitFrame = CreateFrame("frame", nil, parent)
            profitFrame:SetSize(parent:GetWidth(), 25)
            profitFrame:SetPoint("TOP", anchorParent, "TOP", profitFrameBaseX, offsetY)
            local iconSize=26
            profitFrame.itemIcon = CraftSim.GGUI.Icon({
                parent=profitFrame, anchorParent=profitFrame, anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=10,
                sizeX=iconSize, sizeY=iconSize,qualityIconScale=1.4,
            })

            profitFrame.countAHTitle = CraftSim.GGUI.Text({
                parent=profitFrame, anchorParent=profitFrame.itemIcon.frame, anchorA="RIGHT", anchorB="LEFT",
                justifyOptions={type="H", align="LEFT"}, scale=0.8, offsetX=-26, fixedWidth=25, text="AH:", offsetY=5
            })
            profitFrame.countAHValue = CraftSim.GGUI.Text({
                parent=profitFrame, anchorParent=profitFrame.countAHTitle.frame, anchorA="LEFT", anchorB="RIGHT",
                justifyOptions={type="H", align="LEFT"}, scale=0.8
            })
            profitFrame.countTitle = CraftSim.GGUI.Text({
                parent=profitFrame, anchorParent=profitFrame.countAHTitle.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT",
                justifyOptions={type="H", align="LEFT"}, scale=0.8, fixedWidth=25, text="Inv:",
            })
            profitFrame.countValue = CraftSim.GGUI.Text({
                parent=profitFrame, anchorParent=profitFrame.countTitle.frame, anchorA="LEFT", anchorB="RIGHT",
                justifyOptions={type="H", align="LEFT"}, scale=0.8
            })

            profitFrame.price = CraftSim.GGUI.Text({
                parent=profitFrame, anchorParent=profitFrame.itemIcon.frame, anchorA="TOPLEFT", anchorB="TOPRIGHT", offsetX=5,
                text=CraftSim.GUTIL:FormatMoney(123456789, true)
            })

            profitFrame.profit = CraftSim.GGUI.Text({
                parent=profitFrame, anchorParent=profitFrame.price.frame, anchorA="TOPLEFT", anchorB="BOTTOMLEFT",
                text=CraftSim.GUTIL:FormatMoney(-123456789, true)
            })

            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(profitFrame)
            return profitFrame
        end
    
        local baseY = -20
        local profitFramesSpacingY = -30
        frame.content.profitFrames = {}
        table.insert(frame.content.profitFrames, createProfitFrame(baseY, frame.content, frame.content.resultProfitsTitle.frame))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY, frame.content, frame.content.resultProfitsTitle.frame))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*2, frame.content, frame.content.resultProfitsTitle.frame))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*3, frame.content, frame.content.resultProfitsTitle.frame))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*4, frame.content, frame.content.resultProfitsTitle.frame))
        
    
        CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
        frame:Hide()

        frame:SetStatusList({
            {
                statusID="Q1",
                sizeY=sizeYQ1,
            },
            {
                statusID="Q3",
                sizeY=sizeYQ3,
            },
            {
                statusID="Q5",
                sizeY=sizeYQ5,
            },
        })
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

    local numResults = math.max(1, recipeData.maxQuality or 1)
    -- adjust frame with status
    priceDetailsFrame:SetStatus("Q" .. numResults)

    for qualityID = 1, 5, 1 do
        local profitFrame = priceDetailsFrame.content.profitFrames[qualityID]
        local resultItem = resultData.itemsByQuality[qualityID]

        if resultItem and not (not recipeData.supportsQualities and qualityID > 1) then
            resultItem:ContinueOnItemLoad(function ()
                local itemLink = resultItem:GetItemLink()
                profitFrame.itemIcon:SetItem(resultItem)
                local price = CraftSim.PRICEDATA:GetMinBuyoutByItemLink(itemLink)
                local profit = (price*CraftSim.CONST.AUCTION_HOUSE_CUT) - priceData.craftingCosts
                profitFrame.price:SetText("Price: " .. CraftSim.GUTIL:FormatMoney(price, true))
                profitFrame.profit:SetText("Profit: " .. CraftSim.GUTIL:FormatMoney(profit, true))

                local itemCount = GetItemCount(itemLink, true, false, true)
                local ahCount = CraftSim.PRICEDATA:GetAuctionAmount(itemLink)

                profitFrame.countValue:SetText(itemCount or 0)

                if ahCount then
                    profitFrame.countAHValue:SetText(ahCount)
                    profitFrame.countAHValue:Show()
                else
                    profitFrame.countAHValue:Hide()
                end

            end)
            profitFrame:Show()
        else
            profitFrame:Hide()
        end
    end
end