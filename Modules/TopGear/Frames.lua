AddonName, CraftSim = ...

CraftSim.TOPGEAR.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOP_GEAR)

function CraftSim.TOPGEAR.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimSimFrame", 
        "CraftSim Top Gear", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CloseButton, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -5, 
        3, 
        250, 
        320,
        CraftSim.CONST.FRAMES.TOP_GEAR, false, true, nil, "modulesTopGear")

    local frameWO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimSimWOFrame", 
        "CraftSim Top Gear " .. CraftSim.UTIL:ColorizeText("WO", CraftSim.CONST.COLORS.GREY), 
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        ProfessionsFrame.CloseButton, 
        "TOPLEFT", 
        "TOPRIGHT", 
        -5, 
        3, 
        250, 
        320,
        CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER, false, true, nil, "modulesTopGear")

    local function createContent(frame)
    
        local contentOffsetY = -40
        local iconsOffsetY = 90
        frame.content.autoUpdateCB = CraftSim.FRAME:CreateCheckbox("Automatic", "Automatically simulate Top Gear for your selected mode whenever a recipe updates.\n\nTurning this off may increase performance",
            "topGearAutoUpdate", frame.content, frame.content, "TOP", "TOP", -40, -33)
            frame.content.autoUpdateCB:HookScript("OnClick", function() 
                CraftSim.MAIN:TriggerModulesErrorSafe(false)
            end)
        frame.content.gear1Icon = CraftSim.FRAME:CreateIcon(frame.content, -45, contentOffsetY + iconsOffsetY, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40)
        frame.content.gear2Icon = CraftSim.FRAME:CreateIcon(frame.content,  -0, contentOffsetY + iconsOffsetY, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40)
        frame.content.toolIcon = CraftSim.FRAME:CreateIcon(frame.content, 50, contentOffsetY + iconsOffsetY, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40)
    
        frame.content.equipButton = CreateFrame("Button", "CraftSimTopGearEquipButton", frame.content, "UIPanelButtonTemplate")
        frame.content.equipButton:SetSize(50, 25)
        frame.content.equipButton:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY + 50)	
        frame.content.equipButton:SetText("Equip")
        frame.content.equipButton:SetScript("OnClick", function(self) 
            CraftSim.TOPGEAR:EquipTopGear()
        end)
    
        frame.content.simulateButton = CraftSim.FRAME:CreateButton(
            "Simulate Top Gear", frame.content, frame.content.equipButton, "CENTER", "CENTER", 0, 0, 5, 25, true, function(self) 
                CraftSim.TOPGEAR:OptimizeAndDisplay(CraftSim.MAIN.currentRecipeData)
            end)
        
    
        frame.content.simModeDropdown = 
        CraftSim.FRAME:initDropdownMenu("CraftSimTopGearSimMode", frame.content, frame.title, "", 0, contentOffsetY, 120, {"Placeholder"}, function(arg1) 
            CraftSimOptions.topGearMode = arg1
            CraftSim.TOPGEAR:OptimizeAndDisplay(CraftSim.MAIN.currentRecipeData)
        end, "Placeholder")
        frame.content.profitText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.profitText:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY + 10)
    
        frame.content.statDiff = CreateFrame("frame", nil, frame.content)
        frame.content.statDiff:SetSize(200, 100)
        frame.content.statDiff:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY - 50)
    
        local statTxtSpacingY = -15
        frame.content.statDiff.inspiration = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.inspiration:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*1)
        frame.content.statDiff.inspiration:SetText("Inspiration: ")
    
        frame.content.statDiff.multicraft = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.multicraft:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*2)
        frame.content.statDiff.multicraft:SetText("Multicraft: ")
    
        frame.content.statDiff.resourcefulness = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.resourcefulness:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*3)
        frame.content.statDiff.resourcefulness:SetText("Resourcefulness: ")
    
        frame.content.statDiff.craftingspeed = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.craftingspeed:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*4)
        frame.content.statDiff.craftingspeed:SetText("Crafting Speed: ")
    
        frame.content.statDiff.skill = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.skill:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*5)
        frame.content.statDiff.skill:SetText("Skill: ")
    
        frame.content.statDiff.quality = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.quality:SetPoint("TOP", frame.content.statDiff, "TOP", -5, statTxtSpacingY*6)
        frame.content.statDiff.quality:SetText("Quality: ")
    
        frame.content.statDiff.qualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content, 20, 20, frame.content.statDiff.quality, "LEFT", "RIGHT", 3, 0)
    
        frame:Hide()
    end

    createContent(frameNO_WO)
    createContent(frameWO)
end

function CraftSim.TOPGEAR.FRAMES:ClearTopGearDisplay(recipeData, isClear, exportMode)
    local topGearFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
        return
    elseif exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    else
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    end

    local emptyProfessionGearSet = CraftSim.ProfessionGearSet(recipeData.professionData.professionInfo.profession)
    CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(emptyProfessionGearSet, exportMode)

    topGearFrame.content.equipButton:SetEnabled(false)
    topGearFrame.content.profitText:SetText(isClear and "" or "Top Gear equipped")

    CraftSim.FRAME:ToggleFrame(topGearFrame.content.simulateButton, isClear)
    CraftSim.FRAME:ToggleFrame(topGearFrame.content.equipButton, not isClear)

    topGearFrame.content.statDiff.inspiration:SetText("")
    topGearFrame.content.statDiff.multicraft:SetText("")
    topGearFrame.content.statDiff.resourcefulness:SetText("")
    topGearFrame.content.statDiff.craftingspeed:SetText("")
    topGearFrame.content.statDiff.skill:SetText("")
    topGearFrame.content.statDiff.quality:Hide()
    topGearFrame.content.statDiff.qualityIcon:Hide()
end

---@param professionGearSet CraftSim.ProfessionGearSet
---@param exportMode number
---@param iconButtonsOverride? table
function CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(professionGearSet, exportMode, iconButtonsOverride)
    local topGearFrame = nil
    local iconButtons
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
        iconButtons = {topGearFrame.content.toolIcon, topGearFrame.content.gear1Icon, topGearFrame.content.gear2Icon}
    elseif exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
        iconButtons = {topGearFrame.content.toolIcon, topGearFrame.content.gear1Icon, topGearFrame.content.gear2Icon}
    end

    iconButtons = iconButtonsOverride or iconButtons

    for _, button in pairs(iconButtons) do
        button:Hide() -- only to consider cooking ...
    end
    if professionGearSet.isCooking and not iconButtonsOverride then
        iconButtons = {iconButtons[2], iconButtons[3]}
    end

    local professionGearList = professionGearSet:GetProfessionGearList()

    for index, iconButton in pairs(iconButtons) do
        iconButton:Show()
        local professionGear = professionGearList[index]
        if professionGear and professionGear.item then
            professionGear.item:ContinueOnItemLoad(function ()
                iconButton:SetNormalTexture(professionGear.item:GetItemIcon())
                iconButton:SetScript("OnEnter", function(self) 
                    local _, ItemLink = GameTooltip:GetItem()
                    if exportMode ~= CraftSim.CONST.EXPORT_MODE.SCAN then
                        GameTooltip:SetOwner(topGearFrame.content, "ANCHOR_RIGHT");
                    else
                        GameTooltip:SetOwner(iconButton, "ANCHOR_RIGHT");
                    end
                    if ItemLink ~= professionGear.item:GetItemLink() then
                        -- to not set it again and hide the tooltip..
                        GameTooltip:SetHyperlink(professionGear.item:GetItemLink())
                    end
                    GameTooltip:Show();
                end)
                iconButton:SetScript("OnLeave", function(self) 
                    GameTooltip:Hide();
                end)
            end)
        else
            -- show empty slot texture
            iconButton:SetNormalTexture(CraftSim.CONST.EMPTY_SLOT_TEXTURE)
            iconButton:SetScript("OnEnter", nil)
            iconButton:SetScript("OnLeave", nil)
        end
    end
end

---@param results CraftSim.TopGearResult[]
---@param topGearMode string
---@param exportMode number
function CraftSim.TOPGEAR.FRAMES:UpdateTopGearDisplay(results, topGearMode, exportMode)
    local topGearFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.SCAN then
        return
    elseif exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    else
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    end
    local topResult = results[1] -- as they are already sorted 
    CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(topResult.professionGearSet, exportMode)
    if not CraftSim.TOPGEAR.IsEquipping then
        topGearFrame.currentTopResult = topResult
    end

    if topGearMode == CraftSim.CONST.GEAR_SIM_MODES.PROFIT then
        topGearFrame.content.profitText:SetText("Ø Profit Difference\n".. CraftSim.UTIL:FormatMoney(topResult.relativeProfit, true))
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.MULTICRAFT then
        topGearFrame.content.profitText:SetText("New Multicraft\n".. CraftSim.GUTIL:Round(topResult.relativeStats.multicraft:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.CRAFTING_SPEED then
        topGearFrame.content.profitText:SetText("New Crafting Speed\n".. CraftSim.GUTIL:Round(topResult.relativeStats.craftingspeed:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.RESOURCEFULNESS then
        topGearFrame.content.profitText:SetText("New Resourcefulness\n".. CraftSim.GUTIL:Round(topResult.relativeStats.resourcefulness:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.INSPIRATION then
        topGearFrame.content.profitText:SetText("New Inspiration\n".. CraftSim.GUTIL:Round(topResult.relativeStats.inspiration:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.CONST.GEAR_SIM_MODES.SKILL then
        topGearFrame.content.profitText:SetText("New Skill\n".. topResult.relativeStats.skill.value)
    else
        topGearFrame.content.profitText:SetText("Unhandled Sim Mode")
    end
    topGearFrame.content.equipButton:SetEnabled(true)
    topGearFrame.content.equipButton:Show()
    topGearFrame.content.simulateButton:Hide()

    local inspirationBonusSkillText = ""
    if topResult.relativeStats.inspiration.extraFactor ~= 0 then
        local prefix = "+" 
        if topResult.relativeStats.inspiration.extraFactor <= 0 then
            prefix = ""
        end
        inspirationBonusSkillText = " (" .. prefix .. CraftSim.GUTIL:Round(topResult.relativeStats.inspiration.extraFactor*100, 0) .. " % Skill)"
    end

    topGearFrame.content.statDiff.inspiration:SetText("Inspiration: " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.inspiration:GetPercent(), 2, "%") .. inspirationBonusSkillText)
    topGearFrame.content.statDiff.multicraft:SetText("Multicraft: " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.multicraft:GetPercent(), 2, "%"))
    topGearFrame.content.statDiff.resourcefulness:SetText("Resourcefulness: " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.resourcefulness:GetPercent(), 2, "%"))
    topGearFrame.content.statDiff.craftingspeed:SetText("Crafting Speed: " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.craftingspeed:GetPercent(), 2, "%"))
    topGearFrame.content.statDiff.skill:SetText("Skill: " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.skill.value, 0))

    if CraftSim.MAIN.currentRecipeData.supportsQualities then
        topGearFrame.content.statDiff.qualityIcon.SetQuality(topResult.expectedQuality)
        topGearFrame.content.statDiff.quality:Show()
        topGearFrame.content.statDiff.qualityIcon:Show()
    else
        topGearFrame.content.statDiff.quality:Hide()
        topGearFrame.content.statDiff.qualityIcon:Hide()
    end
end

---@param recipeData CraftSim.RecipeData
---@param exportMode number
function CraftSim.TOPGEAR.FRAMES:UpdateModeDropdown(recipeData, exportMode)

    local topGearFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    else
        topGearFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR)
    end


    local availableModes = CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndType(recipeData)
    if #availableModes > 0 and not tContains(availableModes, CraftSimOptions.topGearMode) then
        CraftSimOptions.topGearMode = availableModes[1]
    end
    
    CraftSim.FRAME:initializeDropdown(topGearFrame.content.simModeDropdown, availableModes, CraftSimOptions.topGearMode)
end