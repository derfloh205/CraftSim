AddonName, CraftSim = ...

CraftSim.PRICE_DETAILS.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.PRICE_DETAILS)

function CraftSim.PRICE_DETAILS.FRAMES:Init()
    local sizeX=350
    local sizeY=400
    local offsetX=50
    local offsetY=10

    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm, 
        anchorParent=CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR).frame,
        anchorA="TOP",anchorB="BOTTOM",
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

    local frameWO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, 
        anchorParent=CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR).frame,
        anchorA="TOP",anchorB="BOTTOM",
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
    
        local textSpacingY = -20
    
        frame.content.craftingCostsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.craftingCostsTitle:SetPoint("TOP", frame.title.frame, "TOP", 0, textSpacingY)
        frame.content.craftingCostsTitle:SetText("Crafting Costs")
    
        frame.content.craftingCosts = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.craftingCosts:SetPoint("TOPLEFT", frame.content.craftingCostsTitle, "TOPLEFT", 20, textSpacingY)
        frame.content.craftingCosts:SetText("???")

        frame.content.resultProfitsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.resultProfitsTitle:SetPoint("TOP", frame.content.craftingCostsTitle, "TOP", 0, textSpacingY - 20)
        frame.content.resultProfitsTitle:SetText("Profit By Quality")
    
        local function createProfitFrame(offsetY, parent, newHookFrame, qualityID)
            local profitFrame = CreateFrame("frame", nil, parent)
            profitFrame:SetSize(parent:GetWidth(), 25)
            profitFrame:SetPoint("TOP", newHookFrame, "TOP", 0, offsetY)
            
            profitFrame.itemLinkText = profitFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            profitFrame.itemLinkText:SetPoint("CENTER", profitFrame, "CENTER", 0, 0)
            profitFrame.itemLinkText:SetText("")
    
            profitFrame.text = profitFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            profitFrame.text:SetPoint("TOP", profitFrame.itemLinkText, "BOTTOM", 0, -7)
            profitFrame.text:SetText("")

            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(profitFrame)
            profitFrame:Hide()
            return profitFrame
        end
    
        local baseY = -20
        local profitFramesSpacingY = -45
        frame.content.profitFrames = {}
        table.insert(frame.content.profitFrames, createProfitFrame(baseY, frame.content, frame.content.resultProfitsTitle, 1))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY, frame.content, frame.content.resultProfitsTitle, 2))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*2, frame.content, frame.content.resultProfitsTitle, 3))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*3, frame.content, frame.content.resultProfitsTitle, 4))
        table.insert(frame.content.profitFrames, createProfitFrame(baseY + profitFramesSpacingY*4, frame.content, frame.content.resultProfitsTitle, 5))
        
    
        CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
        frame:Hide()
    end

    createContent(frameWO)
    createContent(frameNO_WO)
end

function CraftSim.PRICE_DETAILS.FRAMES:UpdateDisplay(recipeData, profitPerQuality, currentQuality, exportMode)
    local costOverviewFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        costOverviewFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.PRICE_DETAILS_WORK_ORDER)
    else
        costOverviewFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.PRICE_DETAILS)
    end

    local priceData = recipeData.priceData
    local resultData = recipeData.resultData

    costOverviewFrame.content.craftingCosts:SetText(CraftSim.GUTIL:FormatMoney(priceData.craftingCosts))

    print("#profitPerQuality: " .. tostring(#profitPerQuality))
    CraftSim.FRAME:ToggleFrame(costOverviewFrame.content.resultProfitsTitle, #profitPerQuality > 0)    

    for index, profitFrame in pairs(costOverviewFrame.content.profitFrames) do
        if profitPerQuality[index] ~= nil then
            local qualityID = currentQuality + index - 1

            if resultData.itemsByQuality[qualityID] then
                local item = resultData.itemsByQuality[qualityID]
                item:ContinueOnItemLoad(function ()
                    local itemCount = GetItemCount(item:GetItemLink(), true, false, true)
                    profitFrame.itemLinkText:SetText(item:GetItemLink() .. " x " .. itemCount)
                end)
            else
                -- if no item recipe e.g. show quality icon
                local qualityText = CraftSim.GUTIL:GetQualityIconString(qualityID, 20, 20)
                profitFrame.itemLinkText:SetText(qualityText)
            end
            profitFrame.qualityID = qualityID
            local relativeValue = CraftSimOptions.showProfitPercentage and priceData.craftingCosts or nil
            local comissionProfit = (recipeData.orderData and ((recipeData.orderData.tipAmount or 0) - (recipeData.orderData.consortiumCut or 0))) or 0
            profitFrame.text:SetText(CraftSim.GUTIL:FormatMoney(profitPerQuality[index] + comissionProfit, true, relativeValue))
            profitFrame:Show()
        else
            profitFrame:Hide()
        end
    end
end