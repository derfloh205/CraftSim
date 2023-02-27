AddonName, CraftSim = ...

CraftSim.CONTROL_PANEL.FRAMES = {}

function CraftSim.CONTROL_PANEL.FRAMES:Init()
    local currentVersion = GetAddOnMetadata(AddonName, "Version")
    local frame = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimControlPanelFrame", 
        "CraftSim " .. currentVersion, 
        ProfessionsFrame, 
        ProfessionsFrame, 
        "BOTTOM", 
        "TOP", 
        0, 
        -8, 
        1120, 
        100,
        CraftSim.CONST.FRAMES.CONTROL_PANEL)

    

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
            CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG):Show()
        end
    })

    frame.content.exportButton = CraftSim.GGUI.Button({
        label="Export Recipe", parent=frame.content,anchorParent=frame.content.debugButton.frame,anchorA="RIGHT", anchorB="LEFT", sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function() 
            if CraftSim.MAIN.currentRecipeData then
                local json = CraftSim.MAIN.currentRecipeData:GetJSON()
                CraftSim.UTIL:KethoEditBox_Show(json)
            end
        end
    })

    frame.content.optionsButton  = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.optionsButton:SetPoint("RIGHT", frame.content.newsButton.frame, "LEFT", 0, 0)	
	frame.content.optionsButton:SetText("Options")
	frame.content.optionsButton:SetSize(frame.content.optionsButton:GetTextWidth()+15, 25)
    frame.content.optionsButton:SetScript("OnClick", function(self) 
        InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
    end)

    frame.content.resetFramesButton = CreateFrame("Button", "CraftSimResetFramesButton", frame.content, "UIPanelButtonTemplate")
	frame.content.resetFramesButton:SetPoint("RIGHT", frame.content.optionsButton, "LEFT", 0, 0)	
	frame.content.resetFramesButton:SetText("Reset Frame Positions")
	frame.content.resetFramesButton:SetSize(frame.content.resetFramesButton:GetTextWidth() + 20, 25)
    frame.content.resetFramesButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:ResetFrames()
    end)
    
    -- 1. Row
    frame.content.modulesMaterials = createModuleCheckbox("Material Optimization", 
    "Suggests the cheapest materials to reach the highest quality/inspiration threshold.",
    "TOPLEFT", frame.content, "TOPLEFT", cbBaseOffsetX, cbBaseOffsetY, "modulesMaterials")

    frame.content.modulesStatWeights = createModuleCheckbox("Average Profit",
    "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
    "TOP", frame.content.modulesMaterials, "TOP", 0, -20, "modulesStatWeights")
    
    -- 2. Row
    frame.content.modulesTopGear = createModuleCheckbox("Top Gear",
    "Shows the best available profession gear combination based on the selected mode",
    "LEFT", frame.content.modulesMaterials, "RIGHT", 150, 0, "modulesTopGear")

    frame.content.modulesCostOverview = createModuleCheckbox("Cost Overview", 
    "Shows a crafting cost and sell profit overview by resulting quality",
    "TOP", frame.content.modulesTopGear, "TOP", 0, -20, "modulesCostOverview")

    -- 3. Row
    frame.content.modulesSpecInfo = createModuleCheckbox("Specialization Info", 
    "Shows how your profession specializations affect this recipe and makes it possible to simulate any configuration!",
    "LEFT", frame.content.modulesTopGear, "RIGHT", 100, 0, "modulesSpecInfo")

    frame.content.modulesPriceOverride = createModuleCheckbox("Price Overrides", 
    "Override prices of any materials, optional materials and craft results for all recipes or for one recipe specifically.",
    "TOP", frame.content.modulesSpecInfo, "TOP", 0, -20, "modulesPriceOverride")

    -- 4. Row
    frame.content.modulesRecipeScan = createModuleCheckbox("Recipe Scan",
    "Module that scans your recipe list based on various options",
    "LEFT", frame.content.modulesTopGear, "RIGHT", 250, 0, "modulesRecipeScan")

    frame.content.modulesCraftResults = createModuleCheckbox("Craft Results", 
    "Show a crafting log and statistics about your crafts!",
    "TOP", frame.content.modulesRecipeScan, "TOP", 0, -20, "modulesCraftResults")

    -- 5. Row

    frame.content.modulesCustomerService = createModuleCheckbox("Customer Service",
    "Module that offers various options to interact with potential customers",
    "LEFT", frame.content.modulesRecipeScan, "RIGHT", 90, 0, "modulesCustomerService")

end