addonName, CraftSim = ...

CraftSim.CONTROL_PANEL.FRAMES = {}

function CraftSim.CONTROL_PANEL.FRAMES:Init()
    local currentVersion = GetAddOnMetadata(addonName, "Version")
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
        80,
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
    local cbBaseOffsetY = -20

    frame.content.newsButton  = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.newsButton:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", -50, -15)	
	frame.content.newsButton:SetText("News")
	frame.content.newsButton:SetSize(frame.content.newsButton:GetTextWidth()+15, 25)
    frame.content.newsButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:ShowOneTimeInfo(true)
    end)

    frame.content.debugButton  = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.debugButton:SetPoint("TOPLEFT", frame.content.newsButton, "BOTTOMLEFT", 0, 0)	
	frame.content.debugButton:SetText("Debug")
	frame.content.debugButton:SetSize(frame.content.debugButton:GetTextWidth()+15, 25)
    frame.content.debugButton:SetScript("OnClick", function(self) 
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG):Show()
    end)

    frame.content.optionsButton  = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.optionsButton:SetPoint("RIGHT", frame.content.newsButton, "LEFT", 0, 0)	
	frame.content.optionsButton:SetText("Options")
	frame.content.optionsButton:SetSize(frame.content.optionsButton:GetTextWidth()+15, 25)
    frame.content.optionsButton:SetScript("OnClick", function(self) 
        InterfaceOptionsFrame_OpenToCategory(CraftSim.OPTIONS.optionsPanel)
    end)
    
    -- 1. Row
    frame.content.materialSuggestionsCB = createModuleCheckbox("Material Optimization", 
    "Suggests the cheapest materials to reach the highest quality/inspiration threshold.",
    "TOPLEFT", frame.content, "TOPLEFT", cbBaseOffsetX, cbBaseOffsetY, "modulesMaterials")

    frame.content.averageProfitCB = createModuleCheckbox("Average Profit",
    "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
    "TOP", frame.content.materialSuggestionsCB, "TOP", 0, -20, "modulesStatWeights")
    
    -- 2. Row
    frame.content.topGearCB = createModuleCheckbox("Top Gear",
    "Shows the best available profession gear combination based on the selected mode",
    "LEFT", frame.content.materialSuggestionsCB, "RIGHT", 150, 0, "modulesTopGear")

    frame.content.costOverviewCB = createModuleCheckbox("Cost Overview", 
    "Shows a crafting cost and sell profit overview by resulting quality",
    "TOP", frame.content.topGearCB, "TOP", 0, -20, "modulesCostOverview")

    -- 3. Row
    frame.content.specInfoCB = createModuleCheckbox("Specialization Info", 
    "Shows how your profession specializations affect this recipe\nDISCLAIMER: This shows up only for professions with experimental spec data turned on.",
    "LEFT", frame.content.topGearCB, "RIGHT", 100, 0, "modulesSpecInfo")

    frame.content.priceOverrideCB = createModuleCheckbox("Price Overrides", 
    "Override prices of any materials, optional materials and craft results for all recipes or for one recipe specifically.",
    "TOP", frame.content.specInfoCB, "TOP", 0, -20, "modulesPriceOverride")


end