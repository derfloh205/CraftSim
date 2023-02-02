AddonName, CraftSim = ...

CraftSim.REAGENT_OPTIMIZATION.FRAMES = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.FRAMES, recursive, l)
    else
        print(text)
    end
end

function CraftSim.REAGENT_OPTIMIZATION.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimMaterialOptimizationFrame", 
        "CraftSim Material Optimization", 
        ProfessionsFrame.CraftingPage.SchematicForm, 
        CraftSimCostOverviewFrame, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -10, 
        0, 
        280, 
        250,
        CraftSim.CONST.FRAMES.MATERIALS, false, true, nil, "modulesMaterials")

    local frameWO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimMaterialOptimizationWOFrame", 
        "CraftSim Material Optimization " .. CraftSim.UTIL:ColorizeText("WO", CraftSim.CONST.COLORS.GREY), 
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails, 
        CraftSimCostOverviewFrame, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -10, 
        0, 
        280, 
        250,
        CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER, false, true, nil, "modulesMaterials")

    local function createContent(frame)

        local contentOffsetY = -15
    
        frame.content.inspirationCheck = CreateFrame("CheckButton", nil, frame.content, "ChatConfigCheckButtonTemplate")
        frame.content.inspirationCheck:SetPoint("TOP", frame.title, -90, -20)
        frame.content.inspirationCheck.Text:SetText(" Reach Inspiration Breakpoint")
        frame.content.inspirationCheck.tooltip = "Try to reach the skill breakpoint where an inspiration proc upgrades to the next higher quality with the cheapest material combination"
        frame.content.inspirationCheck:SetChecked(CraftSimOptions.materialSuggestionInspirationThreshold)
        frame.content.inspirationCheck:HookScript("OnClick", function(_, btn, down)
            local checked = frame.content.inspirationCheck:GetChecked()
            CraftSimOptions.materialSuggestionInspirationThreshold = checked
            CraftSim.MAIN:TriggerModulesErrorSafe() -- TODO: if this is not performant enough, try to only recalc the material stuff not all, lazy solution for now
        end)
    
        frame.content.qualityText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.qualityText:SetPoint("TOP", frame.title, "TOP", 0, -45)
        frame.content.qualityText:SetText("Reachable Quality: ")
    
        frame.content.qualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content, 25, 25, frame.content.qualityText, "LEFT", "RIGHT", 3, 0)
    
        frame.content.allocateButton = CreateFrame("Button", "CraftSimMaterialAllocateButton", frame.content, "UIPanelButtonTemplate")
        frame.content.allocateButton:SetSize(50, 25)
        frame.content.allocateButton:SetPoint("TOP", frame.content.qualityText, "TOP", 0, -20)	
        frame.content.allocateButton:SetText("Assign")
    
        frame.content.allocateText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.allocateText:SetPoint("TOP", frame.content.qualityText, "TOP", 0, -20)	
        frame.content.allocateText:SetText("")
    
        frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.infoText:SetPoint("CENTER", frame.content, "CENTER", 0, 0)
        frame.content.infoText.NoCombinationFound = "No combination found \nto increase quality"
        frame.content.infoText.SameCombination = "Best combination assigned"
        frame.content.infoText:SetText(frame.content.infoText.NoCombinationFound)
    
        local iconsOffsetY = -25
        local iconsSpacingY = 25
    
        frame.content.reagentFrames = {}
        frame.content.reagentFrames.rows = {}
        frame.content.reagentFrames.numReagents = 0
        local baseX = -20
        local iconSize = 30
        table.insert(frame.content.reagentFrames.rows, CraftSim.REAGENT_OPTIMIZATION.FRAMES:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY, iconSize))
        table.insert(frame.content.reagentFrames.rows, CraftSim.REAGENT_OPTIMIZATION.FRAMES:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY, iconSize))
        table.insert(frame.content.reagentFrames.rows, CraftSim.REAGENT_OPTIMIZATION.FRAMES:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*2, iconSize))
        table.insert(frame.content.reagentFrames.rows, CraftSim.REAGENT_OPTIMIZATION.FRAMES:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*3, iconSize))
        table.insert(frame.content.reagentFrames.rows, CraftSim.REAGENT_OPTIMIZATION.FRAMES:CreateReagentFrame(frame.content, frame.content.allocateButton, iconsOffsetY - iconsSpacingY*4, iconSize))
    
        frame:Hide()
    end

    createContent(frameNO_WO)
    createContent(frameWO)
end

function CraftSim.REAGENT_OPTIMIZATION.FRAMES:CreateReagentFrame(parent, hookFrame, y, iconSize)
    local reagentFrame = CreateFrame("frame", nil, parent)
    reagentFrame:SetSize(parent:GetWidth(), iconSize)
    reagentFrame:SetPoint("TOP", hookFrame, "TOP", 10, y)
    
    local qualityIconSize = 20
    local qualityIconX = 3
    local qualityIconY = -3

    local qualityAmountTextX = 5
    local qualityAmountTextSpacingX = 40

    local reagentRowOffsetX = 40
    local reagentIconsOffsetX = 70

    reagentFrame.q1Icon = reagentFrame:CreateTexture()
    reagentFrame.q1Icon:SetSize(25, 25)
    reagentFrame.q1Icon:SetPoint("LEFT", reagentFrame, "LEFT", reagentRowOffsetX, 0)

    reagentFrame.q2Icon = reagentFrame:CreateTexture()
    reagentFrame.q2Icon:SetSize(25, 25)
    reagentFrame.q2Icon:SetPoint("LEFT", reagentFrame, "LEFT", reagentRowOffsetX + reagentIconsOffsetX, 0)

    reagentFrame.q3Icon = reagentFrame:CreateTexture()
    reagentFrame.q3Icon:SetSize(25, 25)
    reagentFrame.q3Icon:SetPoint("LEFT", reagentFrame, "LEFT", reagentRowOffsetX + reagentIconsOffsetX*2, 0)
    
    reagentFrame.q1qualityIcon = CraftSim.FRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q1Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 1)
    reagentFrame.q2qualityIcon = CraftSim.FRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q2Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 2)
    reagentFrame.q3qualityIcon = CraftSim.FRAME:CreateQualityIcon(reagentFrame, qualityIconSize, qualityIconSize, reagentFrame.q3Icon, "CENTER", "TOPLEFT", qualityIconX, qualityIconY, 3)

    reagentFrame.q1text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q1text:SetPoint("LEFT", reagentFrame.q1Icon, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q1text:SetText("x ?")

    reagentFrame.q2text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q2text:SetPoint("LEFT", reagentFrame.q2Icon, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q2text:SetText("x ?")

    reagentFrame.q3text = reagentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reagentFrame.q3text:SetPoint("LEFT", reagentFrame.q3Icon, "RIGHT", qualityAmountTextX, 0)
    reagentFrame.q3text:SetText("x ?")

    reagentFrame:Hide()
    return reagentFrame
end

function CraftSim.REAGENT_OPTIMIZATION.FRAMES:UpdateReagentDisplay(recipeData, recipeType, priceData, bestAllocation, hasItems, isSameAllocation, exportMode)
    local materialFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        materialFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)
    else
        materialFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.MATERIALS)
    end
    hasItems = hasItems or CraftSim.SIMULATION_MODE.isActive
    if bestAllocation == nil or isSameAllocation then
        materialFrame.content.infoText:Show()
        if isSameAllocation then
            materialFrame.content.infoText:SetText(materialFrame.content.infoText.SameCombination)
        else
            materialFrame.content.infoText:SetText(materialFrame.content.infoText.NoCombinationFound)
        end

        materialFrame.content.qualityIcon:Hide()
        materialFrame.content.qualityText:Hide()
        materialFrame.content.allocateButton:Hide()

        for i = 1, 5, 1 do
            materialFrame.content.reagentFrames.rows[i]:Hide()
        end

        return
    else
        materialFrame.content.allocateText:Hide()
        materialFrame.content.infoText:Hide()
        materialFrame.content.qualityIcon:Show()
        materialFrame.content.qualityText:Show()
        materialFrame.content.allocateButton:Show()
        materialFrame.content.allocateButton:SetEnabled(CraftSim.SIMULATION_MODE.isActive)
        if CraftSim.SIMULATION_MODE.isActive then
            materialFrame.content.allocateButton:SetText("Assign")
            materialFrame.content.allocateButton:SetScript("OnClick", function(self) 
                -- uncheck best quality box if checked
                local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
                if bestQBox:GetChecked() then
                    bestQBox:Click()
                end
                CraftSim.REAGENT_OPTIMIZATION:AssignBestAllocation(recipeData, recipeType, priceData, bestAllocation)
            end)
        else
            materialFrame.content.allocateText:Show()
            materialFrame.content.allocateButton:Hide()
            if hasItems then
                materialFrame.content.allocateText:SetText(CraftSim.UTIL:ColorizeText("Materials available", CraftSim.CONST.COLORS.GREEN))
            else
                materialFrame.content.allocateText:SetText(CraftSim.UTIL:ColorizeText("Materials missing", CraftSim.CONST.COLORS.RED))
            end
        end
        materialFrame.content.allocateButton:SetSize(materialFrame.content.allocateButton:GetTextWidth() + 15, 25)
    end
    local itemsToLoad = {}
    foreach(bestAllocation.allocations, function (_, allocation)
        if allocation then
            local item = Item:CreateFromItemID(allocation.allocations[1].itemID)
            table.insert(itemsToLoad, item)
        end
    end)
    CraftSim.UTIL:ContinueOnAllItemsLoaded(itemsToLoad, function() 
        materialFrame.content.qualityIcon.SetQuality(bestAllocation.qualityReached)
        for frameIndex = 1, 5, 1 do
            local allocation = bestAllocation.allocations[frameIndex]
            if allocation ~= nil then
                --local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(allocation.allocations[1].itemID) 
                local item = CraftSim.UTIL:Find(itemsToLoad, function (item) return item:GetItemID() == allocation.allocations[1].itemID end)
                if item then
                    local itemTexture = item:GetItemIcon()
                    materialFrame.content.reagentFrames.rows[frameIndex].q1Icon:SetTexture(itemTexture)
                    materialFrame.content.reagentFrames.rows[frameIndex].q2Icon:SetTexture(itemTexture)
                    materialFrame.content.reagentFrames.rows[frameIndex].q3Icon:SetTexture(itemTexture)
                    materialFrame.content.reagentFrames.rows[frameIndex].q1text:SetText(allocation.allocations[1].allocations)
                    materialFrame.content.reagentFrames.rows[frameIndex].q2text:SetText(allocation.allocations[2].allocations)
                    materialFrame.content.reagentFrames.rows[frameIndex].q3text:SetText(allocation.allocations[3].allocations)
        
                    materialFrame.content.reagentFrames.rows[frameIndex]:Show()
                end
            else
                materialFrame.content.reagentFrames.rows[frameIndex]:Hide()
            end
            
        end
    end)
end