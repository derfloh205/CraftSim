CraftSimAddonName, CraftSim = ...

CraftSim.TOPGEAR.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.TOP_GEAR)

function CraftSim.TOPGEAR.FRAMES:Init()
    local sizeX=270
    local sizeY=320
    local offsetX=-5
    local offsetY=3

    local frameWO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent=ProfessionsFrame, 
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_TITLE) .. " " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
        collapseable=true,
        closeable=true,
        moveable=true,
        anchorA="TOPLEFT",anchorB="TOPRIGHT",offsetX=offsetX,offsetY=offsetY,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesTopGear"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })
    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent=ProfessionsFrame, 
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.TOP_GEAR, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        anchorA="TOPLEFT",anchorB="TOPRIGHT",offsetX=offsetX,offsetY=offsetY,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesTopGear"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local function createContent(frame)
    
        local contentOffsetY = -40
        local iconsOffsetY = 90
        frame.content.autoUpdateCB = CraftSim.FRAME:CreateCheckbox(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP),
            "topGearAutoUpdate", frame.content, frame.content, "TOP", "TOP", -40, -33)
            frame.content.autoUpdateCB:HookScript("OnClick", function() 
                CraftSim.MAIN:TriggerModulesErrorSafe(false)
            end)
        frame.content.gear1Icon = CraftSim.GGUI.Icon({
            parent=frame.content,
            anchorParent=frame.content,
            sizeX=40,
            sizeY=40,
            offsetX=-45,
            offsetY=contentOffsetY + iconsOffsetY,
        })
        frame.content.gear2Icon = CraftSim.GGUI.Icon({
            parent=frame.content,
            anchorParent=frame.content,
            sizeX=40,
            sizeY=40,
            offsetX=0,
            offsetY=contentOffsetY + iconsOffsetY,
        })
        frame.content.toolIcon = CraftSim.GGUI.Icon({
            parent=frame.content,
            anchorParent=frame.content,
            sizeX=40,
            sizeY=40,
            offsetX=50,
            offsetY=contentOffsetY + iconsOffsetY,
        })

        frame.content.equipButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content, offsetY=contentOffsetY + 50,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_EQUIP), sizeX=15, sizeY=25, adjustWidth=true,
            clickCallback=function ()
                CraftSim.TOPGEAR:EquipTopGear()
            end
        })
    
        frame.content.simulateButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=frame.content.equipButton.frame,label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE), sizeX=20,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.TOPGEAR:OptimizeAndDisplay(CraftSim.MAIN.currentRecipeData)
            end
        })
        
        frame.content.simModeDropdown = CraftSim.GGUI.Dropdown({
            parent=frame.content, anchorParent=frame.title.frame, anchorA="TOP", anchorB="TOP", offsetY=contentOffsetY, width=120,
            clickCallback=function(_, _, value) 
                CraftSimOptions.topGearMode = value
                CraftSim.TOPGEAR:OptimizeAndDisplay(CraftSim.MAIN.currentRecipeData)
            end
        }) 

        frame.content.profitText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.profitText:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY + 10)
    
        frame.content.statDiff = CreateFrame("frame", nil, frame.content)
        frame.content.statDiff:SetSize(200, 100)
        frame.content.statDiff:SetPoint("CENTER", frame.content, "CENTER", 0, contentOffsetY - 50)
    
        local statTxtSpacingY = -15
        frame.content.statDiff.inspiration = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.inspiration:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*1)
        frame.content.statDiff.inspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_LABEL))
    
        frame.content.statDiff.multicraft = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.multicraft:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*2)
        frame.content.statDiff.multicraft:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL))
    
        frame.content.statDiff.resourcefulness = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.resourcefulness:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*3)
        frame.content.statDiff.resourcefulness:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL))
    
        frame.content.statDiff.craftingspeed = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.craftingspeed:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*4)
        frame.content.statDiff.craftingspeed:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED) .. ": ")
    
        frame.content.statDiff.skill = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.skill:SetPoint("TOP", frame.content.statDiff, "TOP", 0, statTxtSpacingY*5)
        frame.content.statDiff.skill:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL) .. ": ")
    
        frame.content.statDiff.quality = frame.content.statDiff:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.content.statDiff.quality:SetPoint("TOP", frame.content.statDiff, "TOP", -5, statTxtSpacingY*6)
        frame.content.statDiff.quality:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY) .. ": ")
    
        frame.content.statDiff.qualityIcon = CraftSim.GGUI.QualityIcon({
            parent=frame.content,anchorParent=frame.content.statDiff.quality,anchorA="LEFT",anchorB="RIGHT",offsetX=3,
            sizeX=20,sizeY=20,
        })
    
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
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    else
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    end

    local emptyProfessionGearSet = CraftSim.ProfessionGearSet(recipeData.professionData.professionInfo.profession)
    CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(emptyProfessionGearSet, exportMode)

    topGearFrame.content.equipButton:SetEnabled(false)
    topGearFrame.content.profitText:SetText(isClear and "" or CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED))

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
---@param gIconsOverride? table
function CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(professionGearSet, exportMode, gIconsOverride)
    local topGearFrame
    local gIcons
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
        gIcons = {topGearFrame.content.toolIcon, topGearFrame.content.gear1Icon, topGearFrame.content.gear2Icon}
    elseif exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
        gIcons = {topGearFrame.content.toolIcon, topGearFrame.content.gear1Icon, topGearFrame.content.gear2Icon}
    end

    gIcons = gIconsOverride or gIcons

    for _, button in pairs(gIcons) do
        button:Hide() -- only to consider cooking ...
    end
    if professionGearSet.isCooking and not gIconsOverride then
        gIcons = {gIcons[1], gIcons[3]}
    end

    local professionGearList = professionGearSet:GetProfessionGearList()

    for index, gIcon in pairs(gIcons) do
        gIcon:Show()
        local professionGear = professionGearList[index]
        gIcon:SetItem(professionGear.item)
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
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    else
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    end
    local topResult = results[1] -- as they are already sorted 
    CraftSim.TOPGEAR.FRAMES:UpdateCombinationIcons(topResult.professionGearSet, exportMode)
    if not CraftSim.TOPGEAR.IsEquipping then
        topGearFrame.currentTopResult = topResult
    end

    if topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT) then
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE) .. CraftSim.GUTIL:FormatMoney(topResult.relativeProfit, true))
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.MULTICRAFT) then
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT) .. CraftSim.GUTIL:Round(topResult.relativeStats.multicraft:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.CRAFTING_SPEED) then
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED) .. CraftSim.GUTIL:Round(topResult.relativeStats.craftingspeed:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.RESOURCEFULNESS) then
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS) .. CraftSim.GUTIL:Round(topResult.relativeStats.resourcefulness:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.INSPIRATION) then
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_INSPIRATION) .. CraftSim.GUTIL:Round(topResult.relativeStats.inspiration:GetPercent(), 2) .. "%")
    elseif topGearMode == CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL) then
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL) .. topResult.relativeStats.skill.value)
    else
        topGearFrame.content.profitText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED))
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
        inspirationBonusSkillText = " (" .. prefix .. CraftSim.GUTIL:Round(topResult.relativeStats.inspiration.extraFactor*100, 0) .. " % " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL) .. ")"
    end

    topGearFrame.content.statDiff.inspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_LABEL) .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.inspiration:GetPercent(), 2, "%") .. inspirationBonusSkillText)
    topGearFrame.content.statDiff.multicraft:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL) .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.multicraft:GetPercent(), 2, "%"))
    topGearFrame.content.statDiff.resourcefulness:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL) .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.resourcefulness:GetPercent(), 2, "%"))
    topGearFrame.content.statDiff.craftingspeed:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED) .. ": " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.craftingspeed:GetPercent(), 2, "%"))
    topGearFrame.content.statDiff.skill:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_SKILL) .. ": " .. CraftSim.FRAME:FormatStatDiffpercentText(topResult.relativeStats.skill.value, 0))

    if CraftSim.MAIN.currentRecipeData.supportsQualities then
        topGearFrame.content.statDiff.qualityIcon:SetQuality(topResult.expectedQuality)
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
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    else
        topGearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    end


    local availableModes = CraftSim.TOPGEAR:GetAvailableTopGearModesByRecipeDataAndType(recipeData)
    if #availableModes > 0 and not tContains(availableModes, CraftSimOptions.topGearMode) then
        CraftSimOptions.topGearMode = availableModes[1]
    end

    availableModes = CraftSim.GUTIL:Map(availableModes, function(mode) return {label=mode, value=mode} end)
    
    topGearFrame.content.simModeDropdown:SetData({data=availableModes, initialValue=CraftSimOptions.topGearMode, initialLabel=CraftSimOptions.topGearMode})
end