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

    local cbBaseOffsetX = 20
    local cbBaseOffsetY = -20
    
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


end