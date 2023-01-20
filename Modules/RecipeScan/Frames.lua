_, CraftSim = ...

CraftSim.RECIPE_SCAN.FRAMES = {}

local PROFIT_ROW_WIDTH  = 120
local INSPIRATION_ROW_WIDTH = 55
local LEARNED_ROW_WIDTH = 35

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

        frame.content.scanMode = CraftSim.FRAME:initDropdownMenu(nil, frame.content, frame.title, "Scan Mode", 0, -30, 170, 
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

        frame.content.optimizeProfessionToolsCB = CraftSim.FRAME:CreateCheckbox(" Optimize Profession Tools", "For each recipe optimize your profession tools for profit\n\n" .. 
                                                                                CraftSim.UTIL:ColorizeText("Might lower performance during scanning\nif you have a lot of tools in your inventory", CraftSim.CONST.COLORS.RED), 
        "recipeScanOptimizeProfessionTools", frame.content, frame.content.scanMode, "LEFT", "RIGHT", 10, 0)

        -- scrollFrame for results
         -- scrollframe
         frame.content.scrollFrame = CreateFrame("ScrollFrame", nil, frame.content, "UIPanelScrollFrameTemplate")
         frame.content.scrollFrame.scrollChild = CreateFrame("frame")
         local scrollFrame = frame.content.scrollFrame
         local scrollChild = scrollFrame.scrollChild
         scrollFrame:SetSize(frame.content:GetWidth() , frame.content:GetHeight())
         scrollFrame:SetPoint("TOP", frame.content.scanButton, "TOP", 0, -50)
         scrollFrame:SetPoint("LEFT", frame.content, "LEFT", 20, 0)
         scrollFrame:SetPoint("RIGHT", frame.content, "RIGHT", -35, 0)
         scrollFrame:SetPoint("BOTTOM", frame.content, "BOTTOM", 0, 20)
         scrollFrame:SetScrollChild(scrollFrame.scrollChild)
         scrollChild:SetWidth(scrollFrame:GetWidth())
         scrollChild:SetHeight(1) -- ??
 
         frame.content.resultFrame = scrollChild

         local columnSpacingX = 5

         frame.content.header = CreateFrame("Frame", nil, frame.content)
         frame.content.header:SetSize(frame.content:GetWidth(), 25)
         frame.content.header:SetPoint("BOTTOMLEFT", frame.content.scrollFrame, "TOPLEFT", 0, 0)

        ---@diagnostic disable-next-line: undefined-field
         frame.content.header.line = frame.content.header:CreateLine()
         frame.content.header.line:SetStartPoint("BOTTOMLEFT", 0, 0)
         frame.content.header.line:SetEndPoint("BOTTOMRIGHT", -60, 0)
         frame.content.header.line:SetThickness(0.5)
         frame.content.header.line:SetColorTexture(1,1,1,1)

         frame.content.header.learnedTitle = CraftSim.FRAME:CreateText("Learned?", frame.content.header, frame.content.header, "LEFT", "LEFT", 30, 0, nil, nil, {type="H", value="RIGHT"})
         frame.content.header.learnedTitle:SetSize(60, 25)

         frame.content.header.profitTitle = CraftSim.FRAME:CreateText("Profit", frame.content.header, frame.content.header.learnedTitle, "LEFT", "RIGHT", 38, 0, nil, nil, {type="H", value="RIGHT"})
         frame.content.header.profitTitle:SetSize(60, 25)

         frame.content.header.inspirationTitle = CraftSim.FRAME:CreateText("Insp%", frame.content.header, frame.content.header.profitTitle, "LEFT", "RIGHT", 20, 0, nil, nil, {type="H", value="RIGHT"})
         frame.content.header.inspirationTitle:SetSize(40, 25)

         frame.content.header.topGearTitle = CraftSim.FRAME:CreateText("Top Gear", frame.content.header, frame.content.header.inspirationTitle, "LEFT", "RIGHT", 17, 0, nil, nil, {type="H", value="RIGHT"})
         frame.content.header.topGearTitle:SetSize(60, 25)

         frame.content.header.highestResultTitle = CraftSim.FRAME:CreateText("Highest Result", frame.content.header, frame.content.header.topGearTitle, "LEFT", "RIGHT", 5, 0, nil, nil, {type="H", value="RIGHT"})
         frame.content.header.highestResultTitle:SetSize(100, 25)

         frame.content.resultFrame.createResultRowFrame = function()
            local resultRowFrame = CreateFrame("Frame", nil, frame.content.resultFrame)
            resultRowFrame:SetSize(frame.content.resultFrame:GetWidth()-10, 30)
            resultRowFrame.isActive = false
            resultRowFrame.recipeID = nil

            resultRowFrame.recipeButton = CraftSim.FRAME:CreateButton("->", resultRowFrame, resultRowFrame, "LEFT", "LEFT", 0, 0, 5, 15, true, function() 
                if resultRowFrame.recipeID then
                    C_TradeSkillUI.OpenRecipe(resultRowFrame.recipeID)
                end
            end)
            resultRowFrame.learnedText = CraftSim.FRAME:CreateText("", resultRowFrame, resultRowFrame.recipeButton, "LEFT", "RIGHT", columnSpacingX, 0, nil, nil, {type="H", value="RIGHT"})
            resultRowFrame.learnedText:SetSize(LEARNED_ROW_WIDTH, 25)
            resultRowFrame.profitText = CraftSim.FRAME:CreateText(CraftSim.UTIL:FormatMoney(1000000000) , resultRowFrame, resultRowFrame.learnedText, "LEFT", "RIGHT", columnSpacingX, 0, nil, nil, {type="H", value="RIGHT"})
            resultRowFrame.profitText:SetSize(PROFIT_ROW_WIDTH, 25) -- so the justify does something!
            resultRowFrame.inspirationChanceText = CraftSim.FRAME:CreateText("100%" , resultRowFrame, resultRowFrame.profitText, "LEFT", "RIGHT", columnSpacingX, 0, nil, nil, {type="H", value="RIGHT"})
            resultRowFrame.inspirationChanceText:SetSize(INSPIRATION_ROW_WIDTH, 25) -- so the justify does something!
            local iconSize = 20
            resultRowFrame.tool1Icon = CraftSim.FRAME:CreateIcon(resultRowFrame, columnSpacingX, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, iconSize, iconSize, "LEFT", "RIGHT", resultRowFrame.inspirationChanceText)
            resultRowFrame.tool2Icon = CraftSim.FRAME:CreateIcon(resultRowFrame, columnSpacingX, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, iconSize, iconSize, "LEFT", "RIGHT", resultRowFrame.tool1Icon)
            resultRowFrame.tool3Icon = CraftSim.FRAME:CreateIcon(resultRowFrame, columnSpacingX, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, iconSize, iconSize, "LEFT", "RIGHT", resultRowFrame.tool2Icon)
            resultRowFrame.noTopGearText = CraftSim.FRAME:CreateText(CraftSim.UTIL:ColorizeText("Top Gear Equipped", CraftSim.CONST.COLORS.GREEN), 
            resultRowFrame, resultRowFrame.inspirationChanceText, "LEFT", "RIGHT", columnSpacingX, 0)
            resultRowFrame.noTopGearText:SetSize(iconSize*3 + columnSpacingX*2, 25)

            resultRowFrame.recipeResultText = CraftSim.FRAME:CreateText("Recipe #" .. #frame.content.resultRowFrames, resultRowFrame, resultRowFrame.tool3Icon, "LEFT", "RIGHT", columnSpacingX*3, 0, nil, nil, {type="H", value="LEFT"})
            
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

function CraftSim.RECIPE_SCAN:AddRecipeToRecipeRow(recipeData, priceData, meanProfit, bestSimulation)
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
            if recipeData.result.isNoQuality then
                availableRow.inspirationChanceText:SetText("-")
            else
                availableRow.inspirationChanceText:SetText(CraftSim.UTIL:ColorizeText("0%", CraftSim.CONST.COLORS.RED))
            end
        end
    end

    local profitText = CraftSim.UTIL:FormatMoney(CraftSim.UTIL:round(meanProfit / 10000) * 10000, true, priceData.craftingCostPerCraft) -- round to gold
    availableRow.profitText:SetText(profitText)

    availableRow.learnedText:SetText((recipeData.learned and CraftSim.UTIL:ColorizeText("T", CraftSim.CONST.COLORS.GREEN)) or 
                                                            CraftSim.UTIL:ColorizeText("F", CraftSim.CONST.COLORS.RED))

    if not CraftSimOptions.recipeScanOptimizeProfessionTools then
        availableRow.tool1Icon:Hide()
        availableRow.tool2Icon:Hide()
        availableRow.tool3Icon:Hide()
        availableRow.noTopGearText:Show()
        availableRow.noTopGearText:SetText("-")
    elseif bestSimulation then
        CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(bestSimulation.combo, recipeData.professiosID == Enum.Profession.Cooking, CraftSim.CONST.EXPORT_MODE.SCAN, {
            availableRow.tool1Icon,
            availableRow.tool2Icon,
            availableRow.tool3Icon,
        })
        availableRow.noTopGearText:Hide()
    else
        availableRow.tool1Icon:Hide()
        availableRow.tool2Icon:Hide()
        availableRow.tool3Icon:Hide()
        availableRow.noTopGearText:Show()
        availableRow.noTopGearText:SetText(CraftSim.UTIL:ColorizeText("Equipped", CraftSim.CONST.COLORS.GREEN))
    end

    -- update visibility

    availableRow.isActive = true
    availableRow:Show()
    local baseOffsetY = -30
    local spacingY = -20
    local totalOffsetY = baseOffsetY + spacingY*(numActiveFrames - 1)
    availableRow:SetPoint("TOP", RecipeScanFrame.content.resultFrame, "TOP", 0, totalOffsetY)

end