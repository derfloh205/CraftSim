AddonName, CraftSim = ...

CraftSim.CONTROL_PANEL.FRAMES = {}

function CraftSim.CONTROL_PANEL.FRAMES:Init()
    local currentVersion = GetAddOnMetadata(AddonName, "Version")

    local frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame, anchorParent=ProfessionsFrame,anchorA="BOTTOM",anchorB="TOP",offsetY=-5,
        sizeX=950,sizeY=125,frameID=CraftSim.CONST.FRAMES.CONTROL_PANEL, 
        title="CraftSim " .. currentVersion .. " - Control Panel",
        collapseable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
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
        label="News", parent=frame.content, anchorParent=frame.content,anchorA="TOPRIGHT",anchorB="TOPRIGHT",offsetX=-50,offsetY=cbBaseOffsetY+5,
        sizeX=15,sizeY=25, adjustWidth=true,
        clickCallback=function() 
            CraftSim.FRAME:ShowOneTimeInfo(true)
        end
    })

    frame.content.debugButton = CraftSim.GGUI.Button({
        label="Debug",parent=frame.content,anchorParent=frame.content.newsButton.frame,anchorA="TOPLEFT",anchorB="BOTTOMLEFT",
        sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function() 
            CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.DEBUG):Show()
        end
    })

    frame.content.exportForgeFinderButton = CraftSim.GGUI.Button({
        label=CraftSim.GUTIL:ColorizeText("ForgeFinder", CraftSim.GUTIL.COLORS.LEGENDARY) .. " Export", parent=frame.content,anchorParent=frame.content.debugButton.frame,anchorA="RIGHT", anchorB="LEFT", sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function() 
            CraftSim.CONTROL_PANEL:ForgeFinderExportAll()
        end,
        initialStatusID = "READY",
    })

    frame.content.exportForgeFinderButton:SetStatusList({
        {
            statusID = "READY",
            label=CraftSim.GUTIL:ColorizeText("ForgeFinder", CraftSim.GUTIL.COLORS.LEGENDARY) .. " Export",
            enabled=true,
        }
    })

    CraftSim.GGUI.HelpIcon({
        parent=frame.content,anchorParent=frame.content.exportForgeFinderButton.frame, anchorA="RIGHT", anchorB="LEFT", offsetX=-3,
        text=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.FORGEFINDER_EXPLANATION)
    })

    frame.content.optionsButton = CraftSim.GGUI.Button({
        parent=frame.content, anchorParent=frame.content.newsButton.frame, anchorA="RIGHT", anchorB="LEFT",
        sizeX=15, sizeY=25, adjustWidth=true,
        clickCallback=function() 
            InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
        end,
        label="Options"
    })

    frame.content.resetFramesButton = CraftSim.GGUI.Button({
        parent=frame.content, anchorParent=frame.content.optionsButton.frame, anchorA="RIGHT", anchorB="LEFT",
        sizeX=20, sizeY=25, adjustWidth=true,
        clickCallback=function() 
            CraftSim.FRAME:ResetFrames()
        end,
        label="Reset Frame Positions"
    })
    
    -- 1. Row
    frame.content.modulesMaterials = createModuleCheckbox("Material Optimization", 
    "Suggests the cheapest materials to reach the highest quality/inspiration threshold.",
    "TOPLEFT", frame.content, "TOPLEFT", cbBaseOffsetX, cbBaseOffsetY, "modulesMaterials")

    frame.content.modulesStatWeights = createModuleCheckbox("Average Profit",
    "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
    "TOP", frame.content.modulesMaterials, "TOP", 0, -20, "modulesStatWeights")

    frame.content.modulesTopGear = createModuleCheckbox("Top Gear",
    "Shows the best available profession gear combination based on the selected mode",
    "TOP", frame.content.modulesStatWeights, "TOP", 0, -20, "modulesTopGear")
    
    -- 2. Row

    frame.content.modulesPriceDetails = createModuleCheckbox("Price Details", 
    "Shows a sell price and profit overview by resulting item quality",
    "LEFT", frame.content.modulesMaterials, "RIGHT", 150, 0, "modulesPriceDetails")

    frame.content.modulesPriceOverride = createModuleCheckbox("Price Overrides", 
    "Override prices of any materials, optional materials and craft results for all recipes or for one recipe specifically. You can also set an item to use Craft Data as price.",
    "TOP", frame.content.modulesPriceDetails, "TOP", 0, -20, "modulesPriceOverride")

    frame.content.modulesCraftData = createModuleCheckbox("Craft Data", 
    "Edit the saved configurations for crafting commodities of different qualities to show in tooltips and to calculate crafting costs",
    "TOP", frame.content.modulesPriceOverride, "TOP", 0, -20, "modulesCraftData")

    -- 3. Row
    frame.content.modulesSpecInfo = createModuleCheckbox("Specialization Info", 
    "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
    "LEFT", frame.content.modulesPriceDetails, "RIGHT", 100, 0, "modulesSpecInfo")

    frame.content.modulesCraftResults = createModuleCheckbox("Craft Results", 
    "Show a crafting log and statistics about your crafts!",
    "TOP", frame.content.modulesSpecInfo, "TOP", 0, -20, "modulesCraftResults")

    frame.content.modulesCostDetails = createModuleCheckbox("Cost Details",
    "Module that shows detailed information about crafting costs",
    "TOP", frame.content.modulesCraftResults, "TOP", 0, -20, "modulesCostDetails")

    -- 4. Row
    frame.content.modulesRecipeScan = createModuleCheckbox("Recipe Scan",
    "Module that scans your recipe list based on various options",
    "LEFT", frame.content.modulesSpecInfo, "RIGHT", 125, 0, "modulesRecipeScan")

    frame.content.modulesCustomerService = createModuleCheckbox("Customer Service",
    "Module that offers various options to interact with potential customers",
    "TOP", frame.content.modulesRecipeScan, "TOP", 0, -20, "modulesCustomerService")

end