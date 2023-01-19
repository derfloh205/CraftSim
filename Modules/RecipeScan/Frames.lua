_, CraftSim = ...

CraftSim.RECIPE_SCAN.FRAMES = {}

local PROFIT_ROW_WIDTH  = 100
local INSPIRATION_ROW_WIDTH = 35
local CHECKMARK_ROW_WIDTH = 15

function CraftSim.RECIPE_SCAN.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimRecipeScan", 
        "CraftSim Recipe Scan", 
        ProfessionsFrame.CraftingPage.SchematicForm, 
        ProfessionsFrame.CraftingPage.SchematicForm, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        700, 
        400,
        CraftSim.CONST.FRAMES.RECIPE_SCAN, false, true, "DIALOG", "modulesRecipeScan")

    local function createContent(frame)
        frame:Hide()

        frame.content.scanMode = CraftSim.FRAME:initDropdownMenu(nil, frame.content, frame.title, "Scan Mode", 0, -30, 180, 
        CraftSim.UTIL:Map(CraftSim.RECIPE_SCAN.SCAN_MODES, function(e) return e end), function(arg1) 
            frame.content.scanMode.currentMode = arg1
        end, CraftSim.RECIPE_SCAN.SCAN_MODES.Q1)
        frame.content.scanMode.currentMode = CraftSim.RECIPE_SCAN.SCAN_MODES.Q1

        frame.content.scanButton = CraftSim.FRAME:CreateButton("Scan Recipes", frame.content, frame.content.scanMode, "TOP", "TOP", 0, -30, 15, 25, true, function() 
            CraftSim.RECIPE_SCAN:StartScan()
        end)

        frame.content.includeSoulboundCB = CraftSim.FRAME:CreateCheckbox(
            " Include Soulbound", "Include soulbound recipes in the recipe scan.\n\nIt is recommended to set a price override (e.g. to simulate a target comission)\nin the Price Override Module for that recipe's crafted items", 
        "recipeScanIncludeSoulbound", frame.content, frame.content.scanMode, "RIGHT", "LEFT", -190, 0)

        frame.content.includeNotLearnedCB = CraftSim.FRAME:CreateCheckbox(
            " Include not learned", "Include recipes you do not have learned in the recipe scan", 
        "recipeScanIncludeNotLearned", frame.content, frame.content.includeSoulboundCB, "BOTTOMLEFT", "TOPLEFT", 0, 0)

        frame.content.includeGearCB = CraftSim.FRAME:CreateCheckbox(" Include Gear", "Include all form of gear recipes in the recipe scan", 
        "recipeScanIncludeGear", frame.content, frame.content.includeSoulboundCB, "TOPLEFT", "BOTTOMLEFT", 0, 0)

        -- scrollFrame for results
         -- scrollframe
         frame.content.scrollFrame = CreateFrame("ScrollFrame", nil, frame.content, "UIPanelScrollFrameTemplate")
         frame.content.scrollFrame.scrollChild = CreateFrame("frame")
         local scrollFrame = frame.content.scrollFrame
         local scrollChild = scrollFrame.scrollChild
         scrollFrame:SetSize(frame.content:GetWidth() , frame.content:GetHeight())
         scrollFrame:SetPoint("TOP", frame.content.scanButton, "TOP", 0, -30)
         scrollFrame:SetPoint("LEFT", frame.content, "LEFT", 20, 0)
         scrollFrame:SetPoint("RIGHT", frame.content, "RIGHT", -35, 0)
         scrollFrame:SetPoint("BOTTOM", frame.content, "BOTTOM", 0, 20)
         scrollFrame:SetScrollChild(scrollFrame.scrollChild)
         scrollChild:SetWidth(scrollFrame:GetWidth())
         scrollChild:SetHeight(1) -- ??
 
         frame.content.resultFrame = scrollChild

         frame.content.resultFrame.createResultRowFrame = function()
            local resultRowFrame = CreateFrame("Frame", nil, frame.content.resultFrame)
            resultRowFrame:SetSize(frame.content.resultFrame:GetWidth()-10, 30)
            resultRowFrame.isActive = false
            resultRowFrame.recipeID = nil

            local columnSpacingX = 5
            resultRowFrame.recipeButton = CraftSim.FRAME:CreateButton("->", resultRowFrame, resultRowFrame, "LEFT", "LEFT", 0, 0, 5, 15, true, function() 
                if resultRowFrame.recipeID then
                    C_TradeSkillUI.OpenRecipe(resultRowFrame.recipeID)
                end
            end)
            resultRowFrame.learnedText = CraftSim.FRAME:CreateText("", resultRowFrame, resultRowFrame.recipeButton, "LEFT", "RIGHT", columnSpacingX, 0, nil, nil, {type="H", value="RIGHT"})
            resultRowFrame.learnedText:SetSize(CHECKMARK_ROW_WIDTH, 25)
            resultRowFrame.profitText = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(1000000000) , resultRowFrame, resultRowFrame.learnedText, "LEFT", "RIGHT", columnSpacingX, 0, nil, nil, {type="H", value="RIGHT"})
            resultRowFrame.profitText:SetSize(PROFIT_ROW_WIDTH, 25) -- so the justify does something!
            resultRowFrame.inspirationChanceText = CraftSim.FRAME:CreateText("100%" , resultRowFrame, resultRowFrame.profitText, "LEFT", "RIGHT", columnSpacingX, 0, nil, nil, {type="H", value="RIGHT"})
            resultRowFrame.inspirationChanceText:SetSize(INSPIRATION_ROW_WIDTH, 25) -- so the justify does something!
            resultRowFrame.recipeResultText = CraftSim.FRAME:CreateText("Recipe #" .. #frame.content.resultRowFrames, resultRowFrame, resultRowFrame.inspirationChanceText, "LEFT", "RIGHT", columnSpacingX*2, 0, nil, nil, {type="H", value="LEFT"})
            
            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(resultRowFrame)
            return resultRowFrame
         end

         frame.content.resultRowFrames = {}

         local numRowFrames = 100
         
         for i = 1, numRowFrames, 1 do
            table.insert(frame.content.resultRowFrames, frame.content.resultFrame.createResultRowFrame())
         end
    end

    createContent(frameNO_WO)
    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frameNO_WO)
end

function CraftSim.RECIPE_SCAN:ResetResults()
    local RecipeScanFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.RECIPE_SCAN)

    for _, resultRowFrame in pairs(RecipeScanFrame.content.resultRowFrames) do
        resultRowFrame:Hide()
        resultRowFrame:SetPoint("TOP", RecipeScanFrame.content, "TOP", 0, 0) -- "save" somewhere
        resultRowFrame.isActive = false
        resultRowFrame.recipeID = nil
    end
end

function CraftSim.RECIPE_SCAN:AddRecipeToRecipeRow(recipeData, priceData, meanProfit)
    local RecipeScanFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.RECIPE_SCAN)
    -- get first non active row
    local availableRow = CraftSim.UTIL:Find(RecipeScanFrame.content.resultRowFrames, function(frame) return not frame.isActive end)
    local numActiveFrames = CraftSim.UTIL:Count(RecipeScanFrame.content.resultRowFrames, function(frame) return frame.isActive end)

    if not availableRow or numActiveFrames == #RecipeScanFrame.content.resultRowFrames then
        -- too few rows.. create dynamically
        local newRow = RecipeScanFrame.content.resultFrame.createResultRowFrame()
        table.insert(RecipeScanFrame.content.resultRowFrames, newRow)
        availableRow = newRow
    end

    -- fill content
    availableRow.recipeID = recipeData.recipeID
    local outputInfo = CraftSim.DATAEXPORT:GetOutputInfoByRecipeData(recipeData)
    if outputInfo.inspirationCanUpgrade then
        if not outputInfo.inspiration then
            -- not loaded yet, do some makeshift thingy
            outputInfo.inspiration = "[" .. recipeData.recipeName .. " " .. CraftSim.UTIL:GetQualityIconAsText(outputInfo.expectedQualityInspiration, 15, 15) .. "]"
        end
        availableRow.recipeResultText:SetText(outputInfo.inspiration)
        outputInfo.inspirationPercent = CraftSim.UTIL:round(outputInfo.inspirationPercent)
        availableRow.inspirationChanceText:SetText(CraftSim.UTIL:ColorizeText(outputInfo.inspirationPercent .. "%", CraftSim.CONST.COLORS.GREEN))
    else
        if not outputInfo.expected then
            -- not loaded yet, do some makeshift thingy
            outputInfo.expected = "[" .. recipeData.recipeName .. " " .. CraftSim.UTIL:GetQualityIconAsText(outputInfo.expectedQuality, 15, 15) .. "]"
        end
        availableRow.recipeResultText:SetText(outputInfo.expected)
        if recipeData.expectedQuality == recipeData.maxQuality then
            availableRow.inspirationChanceText:SetText(CraftSim.UTIL:ColorizeText("max", CraftSim.CONST.COLORS.GREEN))
        else
            availableRow.inspirationChanceText:SetText(CraftSim.UTIL:ColorizeText("0%", CraftSim.CONST.COLORS.RED))
        end
    end

    local profitText = CraftSim.UTIL:FormatMoney(CraftSim.UTIL:round(meanProfit / 10000) * 10000, true, priceData.craftingCostPerCraft) -- round to gold
    availableRow.profitText:SetText(profitText)

    availableRow.learnedText:SetText((recipeData.learned and CraftSim.UTIL:ColorizeText("L", CraftSim.CONST.COLORS.GREEN)) or 
                                                            CraftSim.UTIL:ColorizeText("L", CraftSim.CONST.COLORS.RED))

    -- update visibility

    availableRow.isActive = true
    availableRow:Show()
    local baseOffsetY = -30
    local spacingY = -20
    local totalOffsetY = baseOffsetY + spacingY*(numActiveFrames - 1)
    availableRow:SetPoint("TOP", RecipeScanFrame.content.resultFrame, "TOP", 0, totalOffsetY)

end