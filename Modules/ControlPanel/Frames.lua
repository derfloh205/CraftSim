CraftSimAddonName, CraftSim = ...

CraftSim.CONTROL_PANEL.FRAMES = {}

function CraftSim.CONTROL_PANEL.FRAMES:Init()
    local currentVersion = GetAddOnMetadata(CraftSimAddonName, "Version")

    local frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame, anchorParent=ProfessionsFrame,anchorA="BOTTOM",anchorB="TOP",offsetY=-5,
        sizeX=950,sizeY=125,frameID=CraftSim.CONST.FRAMES.CONTROL_PANEL, 
        title="CraftSim " .. currentVersion .. " - " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE),
        collapseable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    CraftSim.CONTROL_PANEL.frame = frame

    local createModuleCheckbox = function(label, description, anchorA, anchorParent, anchorB, offsetX, offsetY, optionVariable)
        local cb = CraftSim.FRAME:CreateCheckbox(" " .. label, 
        description, 
        optionVariable,
        frame.content, 
        anchorParent, 
        anchorA, 
        anchorB, 
        offsetX, 
        offsetY)
        cb:HookScript("OnClick", function() 
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end)
        return cb
    end

    frame:Hide()

    local cbBaseOffsetX = 20
    local cbBaseOffsetY = -35

    frame.content.newsButton = CraftSim.GGUI.Button({
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS),
        parent=frame.content, anchorParent=frame.content,anchorA="TOPRIGHT",anchorB="TOPRIGHT",offsetX=-30,offsetY=cbBaseOffsetY+5,
        sizeX=15,sizeY=25, adjustWidth=true,
        clickCallback=function() 
            CraftSim.FRAME:ShowOneTimeInfo(true)
        end
    })

    frame.content.debugButton = CraftSim.GGUI.Button({
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG),
        parent=frame.content,anchorParent=frame.content.newsButton.frame,anchorA="TOPLEFT",anchorB="BOTTOMLEFT",
        sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function() 
            CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.DEBUG):Show()
        end
    })

    frame.content.exportForgeFinderButton = CraftSim.GGUI.Button({
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT),
        parent=frame.content,anchorParent=frame.content.debugButton.frame,anchorA="RIGHT", anchorB="LEFT", sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function() 
            CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
        end,
        initialStatusID = "READY",
    })

    frame.content.exportForgeFinderButton:SetStatusList({
        {
            statusID = "READY",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT),
            enabled=true,
        }
    })

    CraftSim.GGUI.HelpIcon({
        parent=frame.content,anchorParent=frame.content.exportForgeFinderButton.frame, anchorA="RIGHT", anchorB="LEFT", offsetX=-3,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPLANATION)
    })

    local pixelHeart = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PIXEL_HEART, 0.2)
    frame.content.supportersButton = CraftSim.GGUI.Button({parent=frame.content,anchorParent=frame.content.debugButton.frame, anchorA="TOPRIGHT", anchorB="BOTTOMRIGHT",
        label=pixelHeart .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON) .. pixelHeart, sizeX=25,sizeY=25,adjustWidth=true,
    clickCallback=function() 
        CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SUPPORTERS):Show()
    end})

    frame.content.optionsButton = CraftSim.GGUI.Button({
        parent=frame.content, anchorParent=frame.content.newsButton.frame, anchorA="RIGHT", anchorB="LEFT",
        sizeX=15, sizeY=25, adjustWidth=true,
        clickCallback=function() 
            InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
        end,
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS)
    })

    frame.content.resetFramesButton = CraftSim.GGUI.Button({
        parent=frame.content, anchorParent=frame.content.optionsButton.frame, anchorA="RIGHT", anchorB="LEFT",
        sizeX=20, sizeY=25, adjustWidth=true,
        clickCallback=function() 
            CraftSim.FRAME:ResetFrames()
        end,
        label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES)
    })
    
    -- 1. Column

    frame.content.modulesMaterials = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_MATERIAL_OPTIMIZATION_LABEL), 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_MATERIAL_OPTIMIZATION_TOOLTIP),
        "TOPLEFT", frame.content, "TOPLEFT", cbBaseOffsetX, cbBaseOffsetY, "modulesMaterials")

    frame.content.modulesStatWeights = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP),
        "TOP", frame.content.modulesMaterials, "TOP", 0, -20, "modulesStatWeights")

    frame.content.modulesTopGear = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP),
        "TOP", frame.content.modulesStatWeights, "TOP", 0, -20, "modulesTopGear")
    
    -- 2. Column

    frame.content.modulesPriceDetails = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_DETAILS_LABEL), 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_DETAILS_TOOLTIP),
        "LEFT", frame.content.modulesMaterials, "RIGHT", 155, 0, "modulesPriceDetails")

    frame.content.modulesPriceOverride = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP),
        "TOP", frame.content.modulesPriceDetails, "TOP", 0, -20, "modulesPriceOverride")

    frame.content.modulesCraftData = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_LABEL), 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_TOOLTIP),
        "TOP", frame.content.modulesPriceOverride, "TOP", 0, -20, "modulesCraftData")

    -- 3. Column

    frame.content.modulesSpecInfo = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL), 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP),
        "LEFT", frame.content.modulesPriceDetails, "RIGHT", 125, 0, "modulesSpecInfo")

    frame.content.modulesCraftResults = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL), 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP),
        "TOP", frame.content.modulesSpecInfo, "TOP", 0, -20, "modulesCraftResults")

    frame.content.modulesCostDetails = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_DETAILS_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_DETAILS_TOOLTIP),
        "TOP", frame.content.modulesCraftResults, "TOP", 0, -20, "modulesCostDetails")

    -- 4. Column

    frame.content.modulesRecipeScan = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP),
        "LEFT", frame.content.modulesSpecInfo, "RIGHT", 125, 0, "modulesRecipeScan")

    frame.content.modulesCustomerService = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_TOOLTIP),
        "TOP", frame.content.modulesRecipeScan, "TOP", 0, -20, "modulesCustomerService")

    frame.content.modulesCustomerHistory = createModuleCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL),
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP),
        "TOP", frame.content.modulesCustomerService, "TOP", 0, -20, "modulesCustomerHistory")

end