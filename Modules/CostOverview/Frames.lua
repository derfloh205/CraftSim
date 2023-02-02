AddonName, CraftSim = ...

CraftSim.COSTOVERVIEW.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.COST_OVERVIEW)

function CraftSim.COSTOVERVIEW.FRAMES:Fill(craftingCosts, minCraftingCosts, profitPerQuality, currentQuality, exportMode)
    local costOverviewFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        costOverviewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.COST_OVERVIEW_WORK_ORDER)
    else
        costOverviewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.COST_OVERVIEW)
    end
    local recipeData = nil
    -- main should be sim mode data here anyway? TODO: check if the condition can be removed
    if CraftSim.SIMULATION_MODE.isActive then
        recipeData = CraftSim.SIMULATION_MODE.recipeData
    else
        recipeData = CraftSim.MAIN.currentRecipeData
    end

    if not recipeData then return end

    if craftingCosts == minCraftingCosts then
        costOverviewFrame.content.craftingCosts:SetText(CraftSim.UTIL:FormatMoney(craftingCosts))
        costOverviewFrame.content.craftingCostsTitle.SwitchAnchor(costOverviewFrame.title)
        costOverviewFrame.content.minCraftingCosts:Hide()
        costOverviewFrame.content.minCraftingCostsTitle:Hide()
    else
        costOverviewFrame.content.craftingCosts:SetText(CraftSim.UTIL:FormatMoney(craftingCosts))
        costOverviewFrame.content.minCraftingCosts:SetText(CraftSim.UTIL:FormatMoney(minCraftingCosts))
        costOverviewFrame.content.craftingCostsTitle.SwitchAnchor(costOverviewFrame.content.minCraftingCosts)
        costOverviewFrame.content.minCraftingCosts:Show()
        costOverviewFrame.content.minCraftingCostsTitle:Show()
    end

    print("#profitPerQuality: " .. tostring(#profitPerQuality))
    CraftSim.FRAME:ToggleFrame(costOverviewFrame.content.resultProfitsTitle, #profitPerQuality > 0)    

    for index, profitFrame in pairs(costOverviewFrame.content.profitFrames) do
        if profitPerQuality[index] ~= nil then
            local qualityID = currentQuality + index - 1
            if recipeData.result.itemIDs then
                local itemCount = GetItemCount(recipeData.result.itemIDs[qualityID], true, false, true)
                local item = Item:CreateFromItemID(recipeData.result.itemIDs[qualityID])
                item:ContinueOnItemLoad(function ()
                    profitFrame.itemLinkText:SetText((item:GetItemLink() .. " x "..itemCount))
                end)
            elseif recipeData.result.itemQualityLinks then
                local item = Item:CreateFromItemLink(recipeData.result.itemQualityLinks[qualityID])
                item:ContinueOnItemLoad(function ()
                    profitFrame.itemLinkText:SetText((item:GetItemLink()))
                end)
            elseif recipeData.result.itemID then
                local item = Item:CreateFromItemID(recipeData.result.itemID)
                item:ContinueOnItemLoad(function ()
                    profitFrame.itemLinkText:SetText((item:GetItemLink()))
                end)
            else
                -- if no item recipe e.g. show quality icon
                local qualityText = CraftSim.UTIL:GetQualityIconAsText(qualityID, 20, 20)
                profitFrame.itemLinkText:SetText(qualityText)
            end
            profitFrame.qualityID = qualityID
            local relativeValue = CraftSimOptions.showProfitPercentage and craftingCosts or nil
            profitFrame.text:SetText(CraftSim.UTIL:FormatMoney(profitPerQuality[index], true, relativeValue))
            profitFrame:Show()
        else
            profitFrame:Hide()
        end
    end
end

function CraftSim.COSTOVERVIEW.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimCostOverviewFrame", 
        "CraftSim Cost Overview", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        CraftSimSimFrame, 
        "TOP", 
        "BOTTOM", 
        50, 
        10, 
        350, 
        400,
        CraftSim.CONST.FRAMES.COST_OVERVIEW, false, true, nil, "modulesCostOverview")

    local frameWO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimCostOverviewWOFrame", 
        "CraftSim Cost Overview " .. CraftSim.UTIL:ColorizeText("WO", CraftSim.CONST.COLORS.GREY), 
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        CraftSimSimFrame, 
        "TOP", 
        "BOTTOM", 
        50, 
        10, 
        350, 
        400,
        CraftSim.CONST.FRAMES.COST_OVERVIEW_WORK_ORDER, false, true, nil, "modulesCostOverview")

    local function createContent(frame)
    
        local contentOffsetY = -20
        local textSpacingY = -20
    
        frame.content.minCraftingCostsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.minCraftingCostsTitle:SetPoint("TOP", frame.title, "TOP", 0, textSpacingY)
        frame.content.minCraftingCostsTitle:SetText("Min Crafting Costs")
    
        frame.content.minCraftingCosts = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.minCraftingCosts:SetPoint("TOP", frame.content.minCraftingCostsTitle, "TOP", 0, textSpacingY)
        frame.content.minCraftingCosts:SetText("???")
    
        frame.content.craftingCostsTitle = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.craftingCostsTitle:SetPoint("TOP", frame.content.minCraftingCosts, "TOP", 0, textSpacingY)
        frame.content.craftingCostsTitle:SetText("Current Crafting Costs")
        frame.content.craftingCostsTitle.SwitchAnchor = function(newAnchor) 
            frame.content.craftingCostsTitle:SetPoint("TOP", newAnchor, "TOP", 0, textSpacingY)
        end
    
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