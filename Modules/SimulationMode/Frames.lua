AddonName, CraftSim = ...

CraftSim.SIMULATION_MODE.FRAMES = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SIMULATION_MODE, recursive, l)
    else
        print(text)
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:Init()
    -- CHECK BUTTON
    local clickCallback = function(self) 
        CraftSim.SIMULATION_MODE.isActive = self:GetChecked()
        local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
        if bestQBox:GetChecked() and CraftSim.SIMULATION_MODE.isActive then
            bestQBox:Click()
        end
        if CraftSim.SIMULATION_MODE.isActive then
            CraftSim.SIMULATION_MODE:InitializeSimulationMode(CraftSim.MAIN.currentRecipeData)
        end

        CraftSim.MAIN:TriggerModulesErrorSafe()
    end
    local toggleButton = CraftSim.FRAME:CreateCheckboxCustomCallback(
        " Simulation Mode", "CraftSim's Simulation Mode makes it possible to play around with a recipe without restrictions", false, clickCallback, 
        ProfessionsFrame.CraftingPage.SchematicForm, ProfessionsFrame.CraftingPage.SchematicForm.Details, "BOTTOM", "TOP", -65, 0)

    CraftSim.SIMULATION_MODE.toggleButton = toggleButton

    toggleButton:Hide()

    -- REAGENT OVERWRITE FRAMES
    local reagentOverwriteFrame = CreateFrame("frame", nil, ProfessionsFrame.CraftingPage.SchematicForm)
    reagentOverwriteFrame:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.SchematicForm.Reagents, "TOPLEFT", -40, -35)
    reagentOverwriteFrame:SetSize(200, 400)
    reagentOverwriteFrame:Hide()

    local baseX = 10
    local inputOffsetX = 50

    reagentOverwriteFrame.qualityIcon1 = CraftSim.FRAME:CreateQualityIcon(reagentOverwriteFrame, 20, 20, reagentOverwriteFrame, "TOP", "TOP", baseX - 15, 15, 1)
    reagentOverwriteFrame.quality1Button = CreateFrame("Button", nil, reagentOverwriteFrame, "UIPanelButtonTemplate")
    reagentOverwriteFrame.quality1Button:SetPoint("BOTTOM", reagentOverwriteFrame.qualityIcon1, "TOP", 0, 0)	
    reagentOverwriteFrame.quality1Button:SetText("->")
    reagentOverwriteFrame.quality1Button:SetSize(reagentOverwriteFrame.qualityIcon1:GetSize())
    reagentOverwriteFrame.quality1Button:SetScript("OnClick", function(self) 
        CraftSim.SIMULATION_MODE:AllocateAllByQuality(1)
    end)
    reagentOverwriteFrame.qualityIcon2 = CraftSim.FRAME:CreateQualityIcon(reagentOverwriteFrame, 20, 20, reagentOverwriteFrame, "TOP", "TOP", baseX+inputOffsetX - 15, 15, 2)
    reagentOverwriteFrame.quality2Button = CreateFrame("Button", nil, reagentOverwriteFrame, "UIPanelButtonTemplate")
    reagentOverwriteFrame.quality2Button:SetPoint("BOTTOM", reagentOverwriteFrame.qualityIcon2, "TOP", 0, 0)	
    reagentOverwriteFrame.quality2Button:SetText("->")
    reagentOverwriteFrame.quality2Button:SetSize(reagentOverwriteFrame.qualityIcon2:GetSize())
    reagentOverwriteFrame.quality2Button:SetScript("OnClick", function(self) 
        CraftSim.SIMULATION_MODE:AllocateAllByQuality(2)
    end)
    reagentOverwriteFrame.qualityIcon3 = CraftSim.FRAME:CreateQualityIcon(reagentOverwriteFrame, 20, 20, reagentOverwriteFrame, "TOP", "TOP", baseX+inputOffsetX*2 - 15, 15, 3)
    reagentOverwriteFrame.quality3Button = CreateFrame("Button", nil, reagentOverwriteFrame, "UIPanelButtonTemplate")
    reagentOverwriteFrame.quality3Button:SetPoint("BOTTOM", reagentOverwriteFrame.qualityIcon3, "TOP", 0, 0)	
    reagentOverwriteFrame.quality3Button:SetText("->")
    reagentOverwriteFrame.quality3Button:SetSize(reagentOverwriteFrame.qualityIcon3:GetSize())
    reagentOverwriteFrame.quality3Button:SetScript("OnClick", function(self) 
        CraftSim.SIMULATION_MODE:AllocateAllByQuality(3)
    end)

    reagentOverwriteFrame.clearAllocationsButton = CreateFrame("Button", nil, reagentOverwriteFrame, "UIPanelButtonTemplate")
    reagentOverwriteFrame.clearAllocationsButton:SetPoint("LEFT", reagentOverwriteFrame.quality3Button, "RIGHT", inputOffsetX - 30, 0)	
    reagentOverwriteFrame.clearAllocationsButton:SetText("Clear")
    reagentOverwriteFrame.clearAllocationsButton:SetSize(reagentOverwriteFrame.clearAllocationsButton:GetTextWidth(), 20)
    reagentOverwriteFrame.clearAllocationsButton:SetScript("OnClick", function(self) 
        CraftSim.SIMULATION_MODE:AllocateAllByQuality(0) -- Clear
    end)

    reagentOverwriteFrame.reagentOverwriteInputs = {}

    local offsetY = -45

    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, 0, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*2, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*3, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*4, baseX, inputOffsetX))
    table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*5, baseX, inputOffsetX))
    
    CraftSim.SIMULATION_MODE.reagentOverwriteFrame = reagentOverwriteFrame

    local function CreateReagentInputDropdown(offsetY)
        local optionalReagentDropdown = CraftSim.FRAME:initDropdownMenu(nil, reagentOverwriteFrame, ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, "Optional", -20, offsetY + 3, 120, {"Placeholder"}, function(self, arg1) 
            self.selectedItemID = arg1
            CraftSim.SIMULATION_MODE:UpdateSimulationMode()
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end, "None")
        return optionalReagentDropdown
    end

    reagentOverwriteFrame.optionalReagentFrames = {}
    local dropdownSpacingY = -40
    table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(0))
    table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY))
    table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*2))
    table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*3))
    table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*4))

    -- DETAILS FRAME
    local simModeDetailsFrame = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimSimModeDetailsFrame", 
        "CraftSim Simulation Mode", 
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.CraftingPage.SchematicForm.Details, 
        "TOPRIGHT", 
        "TOPRIGHT", 
        30, 
        0, 
        350, 
        355, 
        CraftSim.CONST.FRAMES.CRAFTING_DETAILS)

        simModeDetailsFrame:Hide()

        local offsetY = -20
        local modOffsetX = 5
        local valueOffsetX = -5
        local valueOffsetY = 0.5

        -- recipe difficulty
        simModeDetailsFrame.content.recipeDifficultyTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.recipeDifficultyTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content, "TOPLEFT", 20, offsetY - 20)
        simModeDetailsFrame.content.recipeDifficultyTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL))
        simModeDetailsFrame.content.recipeDifficultyTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.recipeDifficultyTitle, "RIGHT", "LEFT", -20, 0)


        simModeDetailsFrame.content.recipeDifficultyMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeRecipeDifficultyModInput", simModeDetailsFrame.content, simModeDetailsFrame.content, 
            "TOPRIGHT", "TOPRIGHT", modOffsetX - 30, offsetY - 20 + 3.5, 30, 20, 0, true, CraftSim.SIMULATION_MODE.OnStatModifierChanged)

        simModeDetailsFrame.content.recipeDifficultyMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RECIPE_DIFFICULTY

        simModeDetailsFrame.content.recipeDifficultyValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.recipeDifficultyValue:SetPoint("RIGHT", simModeDetailsFrame.content.recipeDifficultyMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.recipeDifficultyValue:SetText("0")

        -- Inspiration
        simModeDetailsFrame.content.inspirationTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.inspirationTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.recipeDifficultyTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.inspirationTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_LABEL))
        simModeDetailsFrame.content.inspirationTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.inspirationTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.inspirationMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeInspirationModInput", simModeDetailsFrame.content, simModeDetailsFrame.content.recipeDifficultyMod, 
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true, CraftSim.SIMULATION_MODE.OnStatModifierChanged)
        simModeDetailsFrame.content.inspirationMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_INSPIRATION

        simModeDetailsFrame.content.inspirationValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.inspirationValue:SetPoint("RIGHT", simModeDetailsFrame.content.inspirationMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.inspirationValue:SetText("0")

        -- Inspiration Skill
        simModeDetailsFrame.content.inspirationSkillTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.inspirationSkillTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.inspirationTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.inspirationSkillTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL))
        simModeDetailsFrame.content.inspirationSkillTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.INSPIRATION_SKILL_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.inspirationTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.inspirationSkillMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeInspirationSkillModInput", simModeDetailsFrame.content, simModeDetailsFrame.content.inspirationMod, 
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true, CraftSim.SIMULATION_MODE.OnStatModifierChanged)
        simModeDetailsFrame.content.inspirationSkillMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_INSPIRATION_SKILL

        simModeDetailsFrame.content.inspirationSkillValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.inspirationSkillValue:SetPoint("RIGHT", simModeDetailsFrame.content.inspirationSkillMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.inspirationSkillValue:SetText("0")

        -- Multicraft
        simModeDetailsFrame.content.multicraftTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.multicraftTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.inspirationSkillTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.multicraftTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL))
        simModeDetailsFrame.content.multicraftTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.multicraftTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.multicraftMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeMulticraftModInput", simModeDetailsFrame.content, simModeDetailsFrame.content.inspirationSkillMod, 
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true, CraftSim.SIMULATION_MODE.OnStatModifierChanged)
        simModeDetailsFrame.content.multicraftMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_MULTICRAFT

        simModeDetailsFrame.content.multicraftValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.multicraftValue:SetPoint("RIGHT", simModeDetailsFrame.content.multicraftMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.multicraftValue:SetText("0")

        -- Multicraft BonusItemsFactor
        simModeDetailsFrame.content.multicraftBonusTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.multicraftBonusTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.multicraftTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.multicraftBonusTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL))

        simModeDetailsFrame.content.multicraftBonusValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.multicraftBonusValue:SetPoint("TOP", simModeDetailsFrame.content.multicraftMod, "BOTTOM", 0, -3)
        simModeDetailsFrame.content.multicraftBonusValue:SetText("0%")

        -- Resourcefulness
        simModeDetailsFrame.content.resourcefulnessTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.multicraftBonusTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.resourcefulnessTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL))
        simModeDetailsFrame.content.resourcefulnessTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.resourcefulnessTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.resourcefulnessMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeResourcefulnessModInput", simModeDetailsFrame.content, simModeDetailsFrame.content.multicraftMod, 
            "TOPRIGHT", "TOPRIGHT", 0, offsetY*2, 30, 20, 0, true, CraftSim.SIMULATION_MODE.OnStatModifierChanged)
        simModeDetailsFrame.content.resourcefulnessMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RESOURCEFULNESS

        simModeDetailsFrame.content.resourcefulnessValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessValue:SetPoint("RIGHT", simModeDetailsFrame.content.resourcefulnessMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.resourcefulnessValue:SetText("0")

        -- Resourcefulness BonusItemsFactor
        simModeDetailsFrame.content.resourcefulnessBonusTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessBonusTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.resourcefulnessTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.resourcefulnessBonusTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL))

        simModeDetailsFrame.content.resourcefulnessBonusValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessBonusValue:SetPoint("TOP", simModeDetailsFrame.content.resourcefulnessMod, "BOTTOM", 0, -3)
        simModeDetailsFrame.content.resourcefulnessBonusValue:SetText("0%")

        -- skill

        simModeDetailsFrame.content.baseSkillTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.resourcefulnessBonusTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.baseSkillTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SKILL_LABEL))

        simModeDetailsFrame.content.baseSkillMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeSkillModInput", simModeDetailsFrame.content, simModeDetailsFrame.content.resourcefulnessMod, 
            "TOPRIGHT", "TOPRIGHT", 0, offsetY*2, 30, 20, 0, true, CraftSim.SIMULATION_MODE.OnStatModifierChanged)
        simModeDetailsFrame.content.baseSkillMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_SKILL

        simModeDetailsFrame.content.baseSkillValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillValue:SetPoint("RIGHT", simModeDetailsFrame.content.baseSkillMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.baseSkillValue:SetText("0")

        -- reagent skill

        simModeDetailsFrame.content.reagentSkillIncreaseTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.baseSkillTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIAL_QUALITY_BONUS_LABEL))
        simModeDetailsFrame.content.reagentSkillIncreaseTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.reagentSkillIncreaseTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.reagentSkillIncreaseValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetPoint("TOP", simModeDetailsFrame.content.baseSkillMod, "TOP", valueOffsetX - 15, offsetY - 5)
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetText("0")

        -- reagent max factor
        simModeDetailsFrame.content.reagentMaxFactorTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentMaxFactorTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.reagentSkillIncreaseTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.reagentMaxFactorTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MATERIAL_QUALITY_MAXIMUM_LABEL))
        simModeDetailsFrame.content.reagentMaxFactorTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.reagentMaxFactorTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.reagentMaxFactorValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentMaxFactorValue:SetPoint("TOP", simModeDetailsFrame.content.baseSkillMod, "TOP", valueOffsetX - 15, offsetY*2 - 5)
        simModeDetailsFrame.content.reagentMaxFactorValue:SetText("0")

        simModeDetailsFrame.content.qualityFrame = CreateFrame("frame", nil, simModeDetailsFrame.content)
        simModeDetailsFrame.content.qualityFrame:SetSize(simModeDetailsFrame:GetWidth() - 40, 230)
        simModeDetailsFrame.content.qualityFrame:SetPoint("TOP", simModeDetailsFrame.content, "TOP", 0, offsetY*12)
        local qualityFrame = simModeDetailsFrame.content.qualityFrame
        qualityFrame.currentQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityTitle:SetPoint("TOPLEFT", qualityFrame, "TOPLEFT", 0, 0)
        qualityFrame.currentQualityTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL))

        qualityFrame.currentQualityIcon = CraftSim.FRAME:CreateQualityIcon(qualityFrame, 25, 25, qualityFrame, "TOPRIGHT", "TOPRIGHT", 0, 5)

        qualityFrame.currentQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityThreshold:SetPoint("RIGHT", qualityFrame.currentQualityIcon, "LEFT", -5, 0)
        qualityFrame.currentQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityTitle:SetPoint("TOPLEFT", qualityFrame.currentQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL))

        qualityFrame.nextQualityIcon = CraftSim.FRAME:CreateQualityIcon(qualityFrame, 25, 25, qualityFrame.currentQualityIcon, "TOP", "TOP", 0, offsetY)

        qualityFrame.nextQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityThreshold:SetPoint("RIGHT", qualityFrame.nextQualityIcon, "LEFT", -5, 0)
        qualityFrame.nextQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityMissingSkillTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillTitle:SetPoint("TOPLEFT", qualityFrame.nextQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_LABEL))

        qualityFrame.nextQualityMissingSkillValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityThreshold, "TOPRIGHT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillValue:SetText("???")

        qualityFrame.nextQualityMissingSkillInspiration = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillInspiration:SetPoint("TOPLEFT", qualityFrame.nextQualityMissingSkillTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillInspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL) .. ":")

        qualityFrame.nextQualityMissingSkillInspirationValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillInspirationValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityMissingSkillValue, "TOPRIGHT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillInspirationValue:SetText("???")

        qualityFrame.skipQualityMissingSkillInspiration = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.skipQualityMissingSkillInspiration:SetPoint("TOPLEFT", qualityFrame.nextQualityMissingSkillInspiration, "TOPLEFT", 0, offsetY)
        qualityFrame.skipQualityMissingSkillInspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL) .. ":")

        qualityFrame.skipQualityMissingSkillInspirationValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.skipQualityMissingSkillInspirationValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityMissingSkillInspirationValue, "TOPRIGHT", 0, offsetY)
        qualityFrame.skipQualityMissingSkillInspirationValue:SetText("???")

         -- warning
        -- simModeDetailsFrame.content.warningText = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        -- simModeDetailsFrame.content.warningText:SetPoint("BOTTOM", simModeDetailsFrame.content, "BOTTOM", 0, 30)
        -- simModeDetailsFrame.content.warningText:SetText(CraftSim.UTIL:ColorizeText("~ WORK IN PROGRESS ~", CraftSim.CONST.COLORS.RED))


        CraftSim.SIMULATION_MODE.craftingDetailsFrame = simModeDetailsFrame
end

function CraftSim.SIMULATION_MODE.FRAMES:InitSpecModifier()
    print("init spec mod frame")
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimSpecSimFrame", 
    "CraftSim Knowledge Simulation", 
    ProfessionsFrame.CraftingPage.SchematicForm, 
    UIParent, 
    "CENTER", "CENTER", 0, 0, 1000, 700, CraftSim.CONST.FRAMES.SPEC_SIM, false, true)

    
    local spec2 = CraftSim.FRAME:CreateTab(
        "Specialization 2", frame.content, frame.content, "TOP", "TOP", -50, -30, true, 400, 400, frame.content, frame.content, 0, -20)
    local spec3 = CraftSim.FRAME:CreateTab(
        "Specialization 3", frame.content, spec2, "LEFT", "RIGHT", 0, 0, true, 400, 400, frame.content, frame.content, 0, -20)
    local spec1 = CraftSim.FRAME:CreateTab(
        "Specialization 1", frame.content, spec2, "RIGHT", "LEFT", 0, 0, true, 400, 400, frame.content, frame.content, 0, -20)
    local spec4 = CraftSim.FRAME:CreateTab(
        "Specialization 4", frame.content, spec3, "LEFT", "RIGHT", 0, 0, true, 400, 400, frame.content, frame.content, 0, -20)
                
    frame.content.specializationTabs = {spec1, spec2, spec3, spec4}
    frame.content.activeNodeModFrames = {}

    CraftSim.FRAME:InitTabSystem(frame.content.specializationTabs)

    frame.content.resetButton = CraftSim.FRAME:CreateButton("Reset", 
    frame.content, spec4, "LEFT", "RIGHT", 40, 0, 15, 25, true, function(self) 
        CraftSim.SIMULATION_MODE:ResetSpecData()
    end)

    frame.content.legendText = CraftSim.FRAME:CreateText(
        [[
            Legend:

            IN ..... Inspiration
            MC ... Multicraft
            MCI .. Multicraft Extra Items
            R ....... Resourcefulness
            RI ...... Resourcefulness Extra Items
            CS ..... CraftingSpeed
            SK ..... Skill
            PB ..... Potion/Phial Breakthrough Chance

        ]], 
        frame.content, spec1, "RIGHT", "LEFT", -50, -30, 0.8, nil, {type="H", value="LEFT"})

    local function createNodeModFrame(parent, anchorParent, anchorA, anchorB, offsetX, offsetY, layer, layerMaxNodes, tabNr, numOnLayer)
        local nodeModFrame = CreateFrame("frame", nil, parent)
        nodeModFrame:SetSize(100, 100)
        nodeModFrame:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        nodeModFrame.layer = layer
        nodeModFrame.tabNr = tabNr
        nodeModFrame.debugID = numOnLayer .. "-" .. tabNr .. "-" .. layer .. "-" .. layerMaxNodes
        nodeModFrame.layerMaxNodes = layerMaxNodes
        nodeModFrame.nodeName = nodeModFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        nodeModFrame.nodeName:SetPoint("TOP", nodeModFrame, "TOP", 0, 0)
        nodeModFrame.nodeName:SetText("Test Node")

        nodeModFrame.showParentLine = parent:CreateLine()
        nodeModFrame.showParentLine:SetThickness(2)
        nodeModFrame.showParentLine:SetColorTexture(1,1,1,1)
        local startPointOffsetY = 10
        nodeModFrame.showParentLine:SetStartPoint(anchorA, offsetX, offsetY + startPointOffsetY)
        --nodeModFrame.showParentLine:SetEndPoint("BOTTOM",0,-20)
        nodeModFrame:Hide()
        nodeModFrame.SetParentNode = function(parentNode)
            local endPointOffsetY = -160
            if parentNode then
                local point, relativeTo, relativePoint, offX, offY = parentNode:GetPoint()
                nodeModFrame.showParentLine:SetEndPoint(point, offX, offY + endPointOffsetY)
                nodeModFrame.showParentLine:Show()
            else
                nodeModFrame.showParentLine:Hide()
            end
        end

        nodeModFrame.Update = function(newValue)
            nodeModFrame.input:SetText(newValue)
            nodeModFrame.nodeProgressBar:UpdateValueByInput()
            nodeModFrame.updateThresholdsByValue()
        end

        local offsetX = 0
        local offsetY = -15
        local originalSizeY = 80

         -- border
         local edgeSize = 2
         nodeModFrame.nodeProgressBorderLEFT = nodeModFrame:CreateLine()
         nodeModFrame.nodeProgressBorderLEFT:SetColorTexture(0.42,0.48,0.55,1)
         nodeModFrame.nodeProgressBorderLEFT:SetThickness(edgeSize)
         nodeModFrame.nodeProgressBorderLEFT:SetStartPoint("BOTTOM", offsetX - (7/2)-1, offsetY-1)
         nodeModFrame.nodeProgressBorderLEFT:SetEndPoint("BOTTOM", offsetX - (7/2)-1, offsetY + originalSizeY + 1)
         nodeModFrame.nodeProgressBorderRIGHT = nodeModFrame:CreateLine()
         nodeModFrame.nodeProgressBorderRIGHT:SetColorTexture(0.42,0.48,0.55,1)
         nodeModFrame.nodeProgressBorderRIGHT:SetThickness(edgeSize)
         nodeModFrame.nodeProgressBorderRIGHT:SetStartPoint("BOTTOM", offsetX + (7/2)+1, offsetY-1)
         nodeModFrame.nodeProgressBorderRIGHT:SetEndPoint("BOTTOM", offsetX + (7/2)+1, offsetY + originalSizeY + 1)
         nodeModFrame.nodeProgressBorderBOTTOM = nodeModFrame:CreateLine()
         nodeModFrame.nodeProgressBorderBOTTOM:SetColorTexture(0.42,0.48,0.55,1)
         nodeModFrame.nodeProgressBorderBOTTOM:SetThickness(edgeSize)
         nodeModFrame.nodeProgressBorderBOTTOM:SetStartPoint("BOTTOM", offsetX - (7/2)-1, offsetY-1)
         nodeModFrame.nodeProgressBorderBOTTOM:SetEndPoint("BOTTOM", offsetX + (7/2)+1, offsetY-1)
         nodeModFrame.nodeProgressBorderTOP = nodeModFrame:CreateLine()
         nodeModFrame.nodeProgressBorderTOP:SetColorTexture(0.42,0.48,0.55,1)
         nodeModFrame.nodeProgressBorderTOP:SetThickness(edgeSize)
         nodeModFrame.nodeProgressBorderTOP:SetStartPoint("BOTTOM", offsetX - (7/2)-1, offsetY + originalSizeY + 1)
         nodeModFrame.nodeProgressBorderTOP:SetEndPoint("BOTTOM", offsetX + (7/2)+1, offsetY + originalSizeY + 1)

        -- Node Progress Display
        nodeModFrame.nodeProgressBar = nodeModFrame:CreateLine()
        nodeModFrame.nodeProgressBar.originalSizeY = originalSizeY
        nodeModFrame.nodeProgressBar.maxValue = 50 -- the max rank of the node
        
        nodeModFrame.nodeProgressBar:SetColorTexture(0.05,0.55,0.23,1)
        nodeModFrame.nodeProgressBar:SetThickness(7)
        nodeModFrame.nodeProgressBar:SetStartPoint("BOTTOM", offsetX, offsetY)
        nodeModFrame.nodeProgressBar:SetEndPoint("BOTTOM", offsetX, offsetY + nodeModFrame.nodeProgressBar.originalSizeY)

        local progressBarDrawlayer, progressBarDrawSublayer = nodeModFrame.nodeProgressBar:GetDrawLayer()

        nodeModFrame.nodeProgressBar.UpdateValueByInput = function()
            local maxRank = nodeModFrame.nodeProgressBar.maxValue
            local stepYPerRank = nodeModFrame.nodeProgressBar.originalSizeY / nodeModFrame.nodeProgressBar.maxValue
            local currentValue = nodeModFrame.input:GetNumber()
            if currentValue < 0 then
                currentValue = 0
            end
            nodeModFrame.nodeProgressBar:SetEndPoint("BOTTOM", offsetX, offsetY + stepYPerRank*currentValue)
        end

        nodeModFrame.updateThresholdsByValue = function()
            local currentValue = nodeModFrame.input:GetNumber()
            for _, threshold in pairs(nodeModFrame.nodeProgressBar.thresholds) do
                local thresholdText = threshold[2]
                local thresholdRankText = threshold[3]
                --print("update threshold: ")
                --print("rank: " .. tostring(threshold.rank))
                --print("currentValue: " .. tostring(currentValue))
                if threshold.rank and threshold.rank <= currentValue then
                   -- print("color green")
                    thresholdText:SetText(CraftSim.UTIL:ColorizeText(threshold.originalText or "", CraftSim.CONST.COLORS.GREEN))
                    thresholdRankText:SetText(CraftSim.UTIL:ColorizeText(threshold.rank or "", CraftSim.CONST.COLORS.GREEN))
                else
                    --print("color grey")
                    thresholdText:SetText(CraftSim.UTIL:ColorizeText(threshold.originalText or "", CraftSim.CONST.COLORS.GREY))
                    thresholdRankText:SetText(CraftSim.UTIL:ColorizeText(threshold.rank or "", CraftSim.CONST.COLORS.GREY))
                end
            end
        end

        local plusButtonSizeX = 10
        local plusButtonSizeY = 15
        nodeModFrame.input = CraftSim.FRAME:CreateNumericInput(
            nil, nodeModFrame, nodeModFrame, "BOTTOM", "BOTTOM", offsetX + 5, offsetY - 30, 20, 20, 0, true, function(self, userInput) 
                CraftSim.SIMULATION_MODE:OnSpecModified(userInput, nodeModFrame)
            end)
        nodeModFrame.plusFiveButton = CraftSim.FRAME:CreateButton(
            "+5", nodeModFrame, nodeModFrame.input, "LEFT", "RIGHT", 10, 0, plusButtonSizeX, plusButtonSizeY, true, function(self) 
                local currentNumber = nodeModFrame.input:GetNumber()
                nodeModFrame.input:SetText(currentNumber + 5)
                CraftSim.SIMULATION_MODE:OnSpecModified(true, nodeModFrame)
            end)
        nodeModFrame.minusFiveButton = CraftSim.FRAME:CreateButton(
        "-5", nodeModFrame, nodeModFrame.input, "RIGHT", "LEFT", -7, 0, plusButtonSizeX, plusButtonSizeY, true, function(self) 
            local currentNumber = nodeModFrame.input:GetNumber()
            nodeModFrame.input:SetText(currentNumber - 5)
            CraftSim.SIMULATION_MODE:OnSpecModified(true, nodeModFrame)
        end)

        -- all possible thresholds in steps of 5 (Max ?) with 50 max ranks and 0 included its 11
        nodeModFrame.nodeProgressBar.thresholds = {
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
            {nodeModFrame:CreateLine(), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight"), nodeModFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")},
        }

        nodeModFrame.InitThresholds = function(maxRank, thresholdValues)
            nodeModFrame.nodeProgressBar.maxValue = maxRank
            local numThresholds = maxRank / 5 + 1 -- thresholds are always per 5 points, and there is one at 0 and one at max

            -- reset
            for index, threshold in pairs(nodeModFrame.nodeProgressBar.thresholds) do
                threshold.isActive = false
                threshold[1]:SetDrawLayer(progressBarDrawlayer, progressBarDrawSublayer+1)
            end

            -- first fill relevant thresholds
            for index, thresholdValue in pairs(thresholdValues) do
                if thresholdValue.threshold then
                    local thresholdIndex = thresholdValue.threshold / 5 + 1 -- could be 0, 5, 10..
                    local threshold = nodeModFrame.nodeProgressBar.thresholds[thresholdIndex]
                    threshold.originalText = thresholdValue.label
                    threshold.isActive = true
                    threshold[2]:SetText(threshold.originalText)
                    threshold[3]:SetText(thresholdValue.threshold)
                end
            end

            -- then adjust position and visibility
            for index, threshold in pairs(nodeModFrame.nodeProgressBar.thresholds) do
                local thresholdLine = threshold[1]
                local thresholdText = threshold[2]
                local thresholdRankText = threshold[3]

                CraftSim.FRAME:ToggleFrame(thresholdLine, threshold.isActive)
                CraftSim.FRAME:ToggleFrame(thresholdText, threshold.isActive)
                CraftSim.FRAME:ToggleFrame(thresholdRankText, threshold.isActive)

                if index <= numThresholds then
                    threshold.rank = 5*(index-1)
                    thresholdLine:SetColorTexture(1,1,1,1)
                    thresholdLine:SetThickness(1)
                    local stepYPerValue = nodeModFrame.nodeProgressBar.originalSizeY / (numThresholds - 1)
                    local thresholdOffsetStartX = offsetX-(7/2)
                    local thresholdOffsetEndX = offsetX+(7/2) -- Make it show a bit more on the right
                    local thresholdOffsetY = offsetY + stepYPerValue*(index-1)
                    thresholdLine:SetStartPoint("BOTTOM", thresholdOffsetStartX,  thresholdOffsetY)
                    thresholdLine:SetEndPoint("BOTTOM", thresholdOffsetEndX, thresholdOffsetY)

                    local textWidth = thresholdText:GetStringWidth()
                    thresholdText:SetScale(0.7)
                    thresholdText:SetPoint("BOTTOM", nodeModFrame, "BOTTOM", ((textWidth / 2) + (thresholdOffsetStartX + 30)*1.4) - 20, (thresholdOffsetY-2.5)*1.4)
                    thresholdRankText:SetScale(0.7)
                    thresholdRankText:SetPoint("BOTTOM", nodeModFrame, "BOTTOM", (thresholdOffsetStartX - 10)*1.4, (thresholdOffsetY-2.5)*1.4)
                else
                    threshold.rank = nil
                end
            end
        end

        return nodeModFrame
    end

    local baseOffsetY = 120
    local nodeFrameOffsetY = -190
    local nodeFrameSpacingX = 100

    local function createNodeFrameCombinationsForTab(parent, tabNr)
        return {
            -- First row is always 1
            createNodeModFrame(parent, parent, "TOP", "TOP", 0, baseOffsetY+nodeFrameOffsetY, 1, 1, tabNr, 1),
    
            -- Second row is either 5, 4, 3, 2
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*2, 2, 5, tabNr, 2),
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*2, 2, 5, tabNr,2 ),
            createNodeModFrame(parent, parent, "TOP", "TOP", 0, baseOffsetY+nodeFrameOffsetY*2, 2, 5, tabNr, 3),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*2, 2, 5, tabNr, 4),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*2, 2, 5, tabNr, 5),

            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2)-nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*2, 2, 4, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2), baseOffsetY+nodeFrameOffsetY*2, 2, 4, tabNr, 2),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX / 2, baseOffsetY+nodeFrameOffsetY*2, 2, 4, tabNr, 3),
            createNodeModFrame(parent, parent, "TOP", "TOP", (nodeFrameSpacingX / 2)+nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*2, 2, 4, tabNr, 4),
    
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*2, 2, 3, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", 0, baseOffsetY+nodeFrameOffsetY*2, 2, 3, tabNr, 2),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*2, 2, 3, tabNr, 3),
    
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2), baseOffsetY+nodeFrameOffsetY*2, 2, 2, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX / 2, baseOffsetY+nodeFrameOffsetY*2, 2, 2, tabNr, 2),
    
            -- last row is either 9, 8, 4, 2, 0
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*4, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*3, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 2),
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 3),
            createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 4),
            createNodeModFrame(parent, parent, "TOP", "TOP", 0, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 5),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 6),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 7),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*3, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 8),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*4, baseOffsetY+nodeFrameOffsetY*3, 3, 9, tabNr, 9),
    
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2) - nodeFrameSpacingX*3, baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2) - nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 2),
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2) - nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 3),
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2), baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 4),
            createNodeModFrame(parent, parent, "TOP", "TOP", (nodeFrameSpacingX / 2), baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 5),
            createNodeModFrame(parent, parent, "TOP", "TOP", (nodeFrameSpacingX / 2) + nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 6),
            createNodeModFrame(parent, parent, "TOP", "TOP", (nodeFrameSpacingX / 2) + nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 7),
            createNodeModFrame(parent, parent, "TOP", "TOP", (nodeFrameSpacingX / 2) + nodeFrameSpacingX*3, baseOffsetY+nodeFrameOffsetY*3, 3, 8, tabNr, 8),
    
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2)-nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 4, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2), baseOffsetY+nodeFrameOffsetY*3, 3, 4, tabNr, 2),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX / 2, baseOffsetY+nodeFrameOffsetY*3, 3, 4, tabNr, 3),
            createNodeModFrame(parent, parent, "TOP", "TOP", (nodeFrameSpacingX / 2)+nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 4, tabNr, 4),
    
            createNodeModFrame(parent, parent, "TOP", "TOP", -(nodeFrameSpacingX / 2), baseOffsetY+nodeFrameOffsetY*3, 3, 2, tabNr, 1),
            createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX / 2, baseOffsetY+nodeFrameOffsetY*3, 3, 2, tabNr, 2),
        }
    end

    spec1.content.nodeModFrames = createNodeFrameCombinationsForTab(spec1.content, 1)
    spec2.content.nodeModFrames = createNodeFrameCombinationsForTab(spec2.content, 2)
    spec3.content.nodeModFrames = createNodeFrameCombinationsForTab(spec3.content, 3)
    spec4.content.nodeModFrames = createNodeFrameCombinationsForTab(spec4.content, 4)

    frame:Hide()
end

function CraftSim.SIMULATION_MODE.FRAMES:ResetAllNodeModFramesForTab(tab)
    for _, nodeModFrame in pairs(tab.content.nodeModFrames) do
        nodeModFrame:Hide()
        nodeModFrame.showParentLine:Hide()
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:InitSpecModBySpecData()
    local specNodeData = CraftSim.SIMULATION_MODE.recipeData.specNodeData

    if not specNodeData then
        return
    end
    print("Init Spec Data:", false, true)
    --print(specNodeData, true)

    local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[CraftSim.SIMULATION_MODE.recipeData.professionID]
    local professionNodeNameMap = CraftSim.SPEC_DATA:GetNodes(CraftSim.SIMULATION_MODE.recipeData.professionID)
    -- get the baseNodes
    local baseRuleNodeNames = CraftSim.SPEC_DATA.BASE_RULE_NODES()[CraftSim.SIMULATION_MODE.recipeData.professionID]
    print("baseRuleNodeNames: ")
    print(baseRuleNodeNames, true)
    local baseRuleNodes = CraftSim.UTIL:Map(baseRuleNodeNames, function(ruleNodeName) 
        return ruleNodes[ruleNodeName]
    end)

    print("found base rule nodes: " .. #baseRuleNodes)

    local baseNodeNames = CraftSim.UTIL:Map(baseRuleNodes, function(baseRuleNode) 
        local foundEntry = CraftSim.UTIL:Find(professionNodeNameMap, function(nameEntry) return nameEntry.nodeID == baseRuleNode.nodeID end)
        return foundEntry.name
    end)

    local specModFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM)
    specModFrame.content.activeNodeModFrames = {}

    -- init tabs
    local function initTab(tabNr, specTab, specTabName, baseNode) 
        specTab:SetText(specTabName)
        specTab:ResetWidth()

        local currentNodeOnLayer = {1, 1, 1}

        

        local function initNode(node, layer, layerCount, parentNodeModFrame)
           
            local nodeNameData = CraftSim.UTIL:Find(professionNodeNameMap, function(entry) return entry.nodeID == node.nodeID end)
            print("init node: " .. tostring(nodeNameData.name))
            local nodesOnLayer = layerCount[layer]
            print("getnodemodframes: " .. tabNr .. "," .. layer .. "," .. nodesOnLayer)
            local nodeModFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSpecNodeModFramesByTabAndLayerAndLayerMax(tabNr, layer, nodesOnLayer)
            --print("found nodemodframes on this layer: " .. tostring(#nodeModFrames) .. " expected: " .. tostring(layerCount[layer]))
            print("current node on layer: " .. tostring(currentNodeOnLayer[layer]))
            local nodeModFrame = nodeModFrames[currentNodeOnLayer[layer]]
            print("debugID: " .. tostring(nodeModFrame.debugID))
            -- make name break and smaller
            local adaptedName = string.gsub(nodeNameData.name, " ", "\n", 1)
            nodeModFrame.nodeName:SetText(adaptedName)
            -- Fill relevant data for nodeModFrame
            nodeModFrame.nodeID = node.nodeID
            local nodeData = CraftSim.UTIL:Find(specNodeData, function(specNode) return specNode.nodeID == node.nodeID end)
            nodeModFrame.nodeProgressBar.maxValue = nodeData.maxRanks - 1
            nodeModFrame.input:SetText(nodeData.activeRank - 1)

            table.insert(specModFrame.content.activeNodeModFrames, nodeModFrame) -- for later easier reference

            -- init the threshold display
            local thresholdLabels = {}
            local nodeRules = CraftSim.UTIL:FilterTable(ruleNodes, function(rule) return rule.nodeID == node.nodeID end)
            for _, rule in pairs(nodeRules) do
                local label = ""
                if rule.skill then
                    label = label .. "SK+" .. rule.skill .. " "
                end
                if rule.inspiration then
                    label = label .. "IN+" .. rule.inspiration .. " "
                end
                if rule.inspirationBonusSkillFactor then
                    label = label .. "ISK+" .. (rule.inspirationBonusSkillFactor*100) .. "% "
                end
                if rule.multicraft then
                    label = label .. "MC+" .. rule.multicraft .. " "
                end
                if rule.multicraftExtraItemsFactor then
                    label = label .. "MCI+" .. (rule.multicraftExtraItemsFactor*100) .. "% "
                end
                if rule.resourcefulness then
                    label = label .. "R+" .. rule.resourcefulness .. " "
                end
                if rule.resourcefulnessExtraItemsFactor then
                    label = label .. "RI+" .. (rule.resourcefulnessExtraItemsFactor*100) .. "% "
                end
                if rule.craftingspeedBonusFactor then
                    label = label .. "CS+" .. (rule.craftingspeedBonusFactor*100) .. "% "
                end
                if rule.potionExperimentationChanceFactor then
                    label = label .. "PB+" .. (rule.potionExperimentationChanceFactor*100) .. "% "
                end
                if rule.phialExperimentationChanceFactor then
                    label = label .. "PB+" .. (rule.phialExperimentationChanceFactor*100) .. "% "
                end

                table.insert(thresholdLabels, {
                    label = label,
                    threshold = rule.threshold
                })
            end
            print("thresholds:")
            print(thresholdLabels, true)
            nodeModFrame.InitThresholds(nodeData.maxRanks - 1, thresholdLabels)
            -- adapt to set values
            nodeModFrame.nodeProgressBar.UpdateValueByInput()
            nodeModFrame.updateThresholdsByValue()
            --
            nodeModFrame:Show()
            if parentNodeModFrame then
                nodeModFrame.SetParentNode(parentNodeModFrame)
            end

            for _, childNodeID in pairs(node.childNodeIDs or {}) do
                -- 
                local childNode = ruleNodes[childNodeID]
                initNode(childNode, layer + 1, layerCount, nodeModFrame)
            end

            currentNodeOnLayer[layer] = currentNodeOnLayer[layer] + 1
        end

        -- get how many nodes there are per layer
        local function countNodes(node)
            local layer1Count = 1
            local layer2Count = (node.childNodeIDs and #node.childNodeIDs) or 0
            local layer3Count = 0
            for _, childNodeID in pairs(node.childNodeIDs or {}) do
                -- 
                local childNode = ruleNodes[childNodeID]
                
                layer3Count = layer3Count + ((childNode.childNodeIDs and #childNode.childNodeIDs) or 0)
            end

            return layer1Count, layer2Count, layer3Count
        end

        local count1, count2, count3 = countNodes(baseNode)

        -- init nodes recursively
        initNode(baseNode, 1, {count1, count2, count3}) 
    end

    for i = 1, 4, 1 do
        local specTabName = baseNodeNames[i]
        local specTab = specModFrame.content.specializationTabs[i]
        CraftSim.SIMULATION_MODE.FRAMES:ResetAllNodeModFramesForTab(specTab)
        if specTabName then
            specTab:Show()
            initTab(i, specTab, specTabName, baseRuleNodes[i])
        else
            specTab:Hide()
        end
    end

end

function CraftSim.SIMULATION_MODE.FRAMES:GetSpecNodeModFramesByTabAndLayerAndLayerMax(tabIndex, layer, layerMaxNodes)
    local specSimFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM)

    local tab = specSimFrame.content.specializationTabs[tabIndex]

    if tab then
        local nodeModFrames = tab.content.nodeModFrames
        local relevantModFrames = CraftSim.UTIL:FilterTable(nodeModFrames, function(nodeModFrame) 
            return nodeModFrame.layer == layer and nodeModFrame.layerMaxNodes == layerMaxNodes
        end)

        return relevantModFrames
    end

    return {}
end

function CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, offsetX, offsetY, baseX, inputOffsetX)
    local overwriteInput = CreateFrame("frame", nil, reagentOverwriteFrame)
    overwriteInput:SetPoint("TOP", reagentOverwriteFrame, "TOP", offsetX, offsetY)
    overwriteInput:SetSize(50, 50)
    
    overwriteInput.icon = CraftSim.FRAME:CreateIcon(overwriteInput, 0, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40, "RIGHT", "LEFT")

    overwriteInput.inputq1 = CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteInput(overwriteInput, baseX, 1)
    overwriteInput.inputq2 = CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteInput(overwriteInput, baseX+inputOffsetX, 2)
    overwriteInput.inputq3 = CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteInput(overwriteInput, baseX+inputOffsetX*2, 3)

    overwriteInput.requiredQuantity = overwriteInput:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	overwriteInput.requiredQuantity:SetPoint("LEFT", overwriteInput.inputq3, "RIGHT", 20, 2)
	overwriteInput.requiredQuantity:SetText("/ ?")

    return overwriteInput
end

function CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteInput(overwriteInputFrame, offsetX, qualityID)
    local inputWidth = 30
    local inputBox = CraftSim.FRAME:CreateNumericInput(
        nil, overwriteInputFrame, overwriteInputFrame.icon, "LEFT", "RIGHT", offsetX, 0, inputWidth, 20, 0, false, CraftSim.SIMULATION_MODE.OnInputAllocationChanged)
    inputBox.qualityID = qualityID
    return inputBox
end

function CraftSim.SIMULATION_MODE.FRAMES:InitOptionalReagentDropdowns()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    local possibleOptionalReagents = recipeData.possibleOptionalReagents
    local optionalReagents = recipeData.optionalReagents
    local possibleFinishingReagents = recipeData.possibleFinishingReagents
    local finishingReagents = recipeData.finishingReagents

    local function convertReagentListToDropdownListData(reagentList)
        local dropDownListData = {{label = "None", value = nil}}
        for _, reagent in pairs(reagentList) do
            local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(reagent.itemID)
            table.insert(dropDownListData, {
                label = itemData.link or "Loading...",
                value = reagent.itemID,
            })
        end
        return dropDownListData
    end

    -- init dropdowns
    for index, dropdown in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames) do
        dropdown.isOptional = false
        dropdown.isFinishing = false
        dropdown.slotIndex = nil
        dropdown.selectedItemID = nil
        dropdown:Hide()
        print("hide dropdown: " .. tostring(index))
    end

    local dropdownIndex = 1

    print("possibleFinishingReagents: " .. tostring(#possibleFinishingReagents), false, true)

    -- optionals
    for slotIndex, reagentList in pairs(possibleOptionalReagents) do
        local currentDropdown = CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames[dropdownIndex]
        local dropdownlist = convertReagentListToDropdownListData(reagentList)
        CraftSim.FRAME:initializeDropdownByData(currentDropdown, dropdownlist, nil, true, true)
        currentDropdown:Show()
        currentDropdown.slotIndex = slotIndex
        currentDropdown.isOptional = true
        currentDropdown.SetLabel("Optional #" .. slotIndex)
        dropdownIndex = dropdownIndex + 1
        for _ , optionalReagent in pairs(optionalReagents) do
            local foundReagent = CraftSim.UTIL:Find(reagentList, function(reagent) return reagent.itemID == optionalReagent.itemID end)
            if foundReagent then
                print("found reagent: " .. optionalReagent.itemData.link)
                UIDropDownMenu_SetText(currentDropdown, optionalReagent.itemData.link)
                currentDropdown.selectedItemID = optionalReagent.itemID
            end
        end
    end
    -- finishing
    for slotIndex, reagentList in pairs(possibleFinishingReagents) do
        print("Init Finishing Dropdown: " .. tostring(slotIndex))
        local currentDropdown = CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames[dropdownIndex]
        local dropdownlist = convertReagentListToDropdownListData(reagentList)
        print("DropdownList")
        print(dropdownlist, true)
        CraftSim.FRAME:initializeDropdownByData(currentDropdown, dropdownlist, nil, true, true)
        currentDropdown:Show()
        currentDropdown.slotIndex = slotIndex
        currentDropdown.isFinishing = true
        currentDropdown.SetLabel("Finishing #" .. slotIndex)
        dropdownIndex = dropdownIndex + 1
        for _ , finishingReagent in pairs(finishingReagents) do
            local foundReagent = CraftSim.UTIL:Find(reagentList, function(reagent) return reagent.itemID == finishingReagent.itemID end)
            if foundReagent then
                print("found reagent: " .. finishingReagent.itemData.link)
                UIDropDownMenu_SetText(currentDropdown, finishingReagent.itemData.link)
                currentDropdown.selectedItemID = finishingReagent.itemID
            end
        end
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:InitReagentOverwriteFrames()
    -- set non quality reagents to max allocations
    local numNonQualityReagents = 0
    for _, reagentData in pairs(CraftSim.SIMULATION_MODE.recipeData.reagents) do
        if not reagentData.differentQualities then
            reagentData.itemsInfo[1].allocations = reagentData.requiredQuantity
            numNonQualityReagents = numNonQualityReagents + 1
        end
    end
    -- filter out non quality reagents
    local filteredReagents = CraftSim.UTIL:FilterTable(CraftSim.SIMULATION_MODE.recipeData.reagents, function(reagentData) 
        return reagentData.differentQualities
    end)
    -- reagent overwrites
    for index, inputFrame in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
        local reagentData = filteredReagents and filteredReagents[index] or nil

        CraftSim.FRAME:ToggleFrame(inputFrame, CraftSim.SIMULATION_MODE.isActive and reagentData)

        if reagentData then
            inputFrame.requiredQuantity:SetText("/ " .. reagentData.requiredQuantity)
            -- CraftSim.FRAME:ToggleFrame(inputFrame.inputq2, reagentData.differentQualities)
            -- CraftSim.FRAME:ToggleFrame(inputFrame.inputq3, reagentData.differentQualities)
            inputFrame.inputq1.reagentIndex = index + numNonQualityReagents
            inputFrame.inputq2.reagentIndex = index + numNonQualityReagents
            inputFrame.inputq3.reagentIndex = index + numNonQualityReagents

            inputFrame.isActive = true

            local itemData = CraftSim.DATAEXPORT:GetItemFromCacheByItemID(reagentData.itemsInfo[1].itemID)
            inputFrame.icon:SetNormalTexture(itemData.itemTexture)
            inputFrame.icon:SetScript("OnEnter", function(self) 
                local itemName, ItemLink = GameTooltip:GetItem()
                GameTooltip:SetOwner(inputFrame, "ANCHOR_RIGHT");
                if ItemLink ~= itemData.link then
                    -- to not set it again and hide the tooltip..
                    GameTooltip:SetHyperlink(itemData.link)
                end
                GameTooltip:Show();
            end)
            inputFrame.icon:SetScript("OnLeave", function(self) 
                GameTooltip:Hide();
            end)
        else
            inputFrame.icon:SetScript("OnEnter", nil)
            inputFrame.icon:SetScript("OnLeave", nil)
            inputFrame.isActive = false
        end
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility()
    if not CraftSim.MAIN.currentRecipeData then
        return -- In what case is this nil?
    end
    -- frame visiblities
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Reagents, not CraftSim.SIMULATION_MODE.isActive)

    local specInfoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)
    specInfoFrame.content.knowledgePointSimulationButton:SetEnabled(CraftSim.SIMULATION_MODE.isActive)
    if not CraftSim.SIMULATION_MODE.isActive then
        CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM):Hide()
    end
    --specInfoFrame.content.knowledgePointSimulationButton:Hide() -- TODO: REMOVE WHEN READY
    -- only if recipe has optionalReagents
    local hasOptionalReagents = ProfessionsFrame.CraftingPage.SchematicForm.reagentSlots[0] ~= nil
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, not CraftSim.SIMULATION_MODE.isActive and hasOptionalReagents)
    local hasQualityReagents = CraftSim.MAIN.currentRecipeData.hasReagentsWithQuality
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.quality1Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.quality2Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.quality3Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.qualityIcon1, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.qualityIcon2, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.qualityIcon3, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.clearAllocationsButton, hasQualityReagents)

    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.reagentOverwriteFrame, CraftSim.SIMULATION_MODE.isActive)

    -- local wasNotVisibleNowIs = not ProfessionsFrame.CraftingPage.SchematicForm.Details:IsVisible()
    -- CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Details, not CraftSim.SIMULATION_MODE.isActive)
    -- wasNotVisibleNowIs = wasNotVisibleNowIs and ProfessionsFrame.CraftingPage.SchematicForm.Details:IsVisible()
    -- if wasNotVisibleNowIs then
    --     -- try to reset it manually so blizz does not throw an operationInfo not found error
    --     ProfessionsFrame.CraftingPage.SchematicForm.Details.operationInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeOperationInfo()
    -- end

    if not CraftSim.SIMULATION_MODE.isActive then
        -- only hide, they will be shown automatically if available
        for _, dropdown in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames) do
            CraftSim.FRAME:ToggleFrame(dropdown, false)
        end
    end
    

    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame, CraftSim.SIMULATION_MODE.isActive)

    local bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
    CraftSim.FRAME:ToggleFrame(bestQBox, not CraftSim.SIMULATION_MODE.isActive)
    
    -- also toggle the blizzard create all buttons and so on so that a user does not get the idea to press create when in sim mode..
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateAllButton, not CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateMultipleInputBox, not CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateButton, not CraftSim.SIMULATION_MODE.isActive)
end

function CraftSim.SIMULATION_MODE.FRAMES:UpdateCraftingDetailsPanel()
    -- stat details
    local reagentSkillIncrease = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSim.SIMULATION_MODE.recipeData)
    local recipeDifficultyMod = CraftSim.UTIL:round(CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeRecipeDifficultyModInput, true), 1)
    local skillMod = CraftSim.UTIL:round(CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeSkillModInput, true), 1)
    local statsByOptionalInputs = CraftSim.SIMULATION_MODE:GetStatsFromOptionalReagents()
    local fullRecipeDifficulty = CraftSim.SIMULATION_MODE.baseRecipeDifficulty + recipeDifficultyMod + statsByOptionalInputs.recipeDifficulty
    CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.recipeDifficultyValue:SetText(CraftSim.UTIL:round(fullRecipeDifficulty, 1) .. " (" .. CraftSim.SIMULATION_MODE.baseRecipeDifficulty .. " + " .. statsByOptionalInputs.recipeDifficulty .. "+" .. recipeDifficultyMod  .. ")")
    CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.baseSkillValue:SetText(CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.skill, 1) .. " (" .. CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.skillNoReagents, 1) .. "+" .. CraftSim.UTIL:round(reagentSkillIncrease, 1) .. "+" .. skillMod ..")")
    -- I assume its always from base..? Wouldnt make sense to give the materials more skill contribution if you artificially make the recipe harder
    local maxReagentSkillIncrease = CraftSim.SIMULATION_MODE.recipeData.maxReagentSkillIncreaseFactor * CraftSim.SIMULATION_MODE.baseRecipeDifficulty
    CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.reagentSkillIncreaseValue:SetText(CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.reagentSkillIncrease, 0) .. " / " .. CraftSim.UTIL:round(maxReagentSkillIncrease, 0))
    CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.reagentMaxFactorValue:SetText(CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.maxReagentSkillIncreaseFactor*100, 1) .. " %")


    -- Inspiration Display
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationTitle, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationTitle.helper, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationValue, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationMod, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    if CraftSim.SIMULATION_MODE.recipeData.stats.inspiration then
        local inspirationDiff = CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.value - CraftSim.SIMULATION_MODE.baseInspiration.value
        local percentText = CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.percent, 1) .. "%"
        CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationValue:SetText(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.value .. " (" .. CraftSim.SIMULATION_MODE.baseInspiration.value .."+"..inspirationDiff .. ") " .. percentText)
    end

    -- Inspiration Skill Display
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationSkillTitle, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationSkillTitle.helper, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationSkillValue, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationSkillMod, CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
    if CraftSim.SIMULATION_MODE.recipeData.stats.inspiration then
        local inspirationSkillDiff = CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.bonusskill - CraftSim.SIMULATION_MODE.baseInspiration.baseBonusSkill, 1)
        CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.inspirationSkillValue:SetText(CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.bonusskill, 1) .. " (" .. CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.baseInspiration.baseBonusSkill, 1) ..
        "*" .. CraftSim.UTIL:round(1+CraftSim.SIMULATION_MODE.recipeData.stats.inspirationBonusSkillFactor, 2) .."+"..inspirationSkillDiff .. ")")
    end

    -- Multicraft Display
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftTitle, CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftTitle.helper, CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftValue, CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftMod, CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftBonusTitle, CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftBonusValue, CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
    if CraftSim.SIMULATION_MODE.recipeData.stats.multicraft then
        local multicraftDiff = CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.value - CraftSim.SIMULATION_MODE.baseMulticraft.value
        local percentText = CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.percent, 1) .. "%"
        CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftValue:SetText(CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.value .. " (" .. CraftSim.SIMULATION_MODE.baseMulticraft.value .."+"..multicraftDiff .. ") " .. percentText)
        
        local specData = CraftSim.SIMULATION_MODE.recipeData.specNodeData
        local multicraftExtraItemsFactor = 1

        if specData then
            multicraftExtraItemsFactor = CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.bonusItemsFactor
        else
            multicraftExtraItemsFactor = CraftSim.SIMULATION_MODE.recipeData.extraItemFactors.multicraftExtraItemsFactor % 1
        end
        CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.multicraftBonusValue:SetText((multicraftExtraItemsFactor * 100) .. "%")
    end
    
    -- Resourcefulness Display
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessTitle, CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessTitle.helper, CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessValue, CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessMod, CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessBonusTitle, CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
    CraftSim.FRAME:ToggleFrame(CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessBonusValue, CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
    if CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness then
        local resourcefulnessDiff = CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.value - CraftSim.SIMULATION_MODE.baseResourcefulness.value
        local percentText = CraftSim.UTIL:round(CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.percent, 1) .. "%"
        CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessValue:SetText(CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.value .. " (" .. CraftSim.SIMULATION_MODE.baseResourcefulness.value .."+"..resourcefulnessDiff .. ") " .. percentText)
        
        local specData = CraftSim.SIMULATION_MODE.recipeData.specNodeData
        local resourcefulnessExtraItemsFactor = 1

        if specData then
            resourcefulnessExtraItemsFactor = CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.bonusItemsFactor
        else
            resourcefulnessExtraItemsFactor = CraftSim.SIMULATION_MODE.recipeData.extraItemFactors.resourcefulnessExtraItemsFactor % 1
        end
        CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.resourcefulnessBonusValue:SetText((resourcefulnessExtraItemsFactor * 100) .. "%")
    end

    local qualityFrame = CraftSim.SIMULATION_MODE.craftingDetailsFrame.content.qualityFrame
    CraftSim.FRAME:ToggleFrame(qualityFrame, not CraftSim.SIMULATION_MODE.recipeData.result.isNoQuality)
    if not CraftSim.SIMULATION_MODE.recipeData.result.isNoQuality then
        --print("getting thresholds with difficulty: " .. CraftSim.SIMULATION_MODE.recipeData.recipeDifficulty)
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(CraftSim.SIMULATION_MODE.recipeData.maxQuality, CraftSim.SIMULATION_MODE.recipeData.recipeDifficulty, CraftSimOptions.breakPointOffset)
        qualityFrame.currentQualityIcon.SetQuality(CraftSim.SIMULATION_MODE.recipeData.expectedQuality)
        qualityFrame.currentQualityThreshold:SetText("> " .. (thresholds[CraftSim.SIMULATION_MODE.recipeData.expectedQuality - 1] or 0))
        
        local hasNextQuality = CraftSim.SIMULATION_MODE.recipeData.expectedQuality < CraftSim.SIMULATION_MODE.recipeData.maxQuality
        local canSkipQuality = CraftSim.SIMULATION_MODE.recipeData.expectedQuality < (CraftSim.SIMULATION_MODE.recipeData.maxQuality - 1)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityIcon, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityThreshold, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityTitle, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillTitle, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillInspiration, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillValue, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillInspirationValue, hasNextQuality)

        CraftSim.FRAME:ToggleFrame(qualityFrame.skipQualityMissingSkillInspiration, canSkipQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.skipQualityMissingSkillInspirationValue, canSkipQuality)
        if hasNextQuality then
            local nextQualityThreshold = thresholds[CraftSim.SIMULATION_MODE.recipeData.expectedQuality]
            local missingSkill = nextQualityThreshold - CraftSim.SIMULATION_MODE.recipeData.stats.skill
            local missingSkillInspiration = nextQualityThreshold - (CraftSim.SIMULATION_MODE.recipeData.stats.skill + CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.bonusskill)
            missingSkill = missingSkill > 0 and missingSkill or 0
            missingSkillInspiration = missingSkillInspiration > 0 and missingSkillInspiration or 0
            qualityFrame.nextQualityMissingSkillValue:SetText(CraftSim.UTIL:round(missingSkill, 1))
            local missinSkillText = CraftSim.UTIL:ColorizeText(CraftSim.UTIL:round(missingSkillInspiration, 1), 
            missingSkillInspiration == 0 and CraftSim.CONST.COLORS.GREEN or CraftSim.CONST.COLORS.RED)
            local nextQualityIconText = CraftSim.UTIL:GetQualityIconAsText(CraftSim.SIMULATION_MODE.recipeData.expectedQuality + 1, 20, 20)
            qualityFrame.nextQualityMissingSkillInspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL) .. " " .. nextQualityIconText)
            qualityFrame.nextQualityMissingSkillInspirationValue:SetText(missinSkillText)
            qualityFrame.nextQualityIcon.SetQuality(CraftSim.SIMULATION_MODE.recipeData.expectedQuality + 1)
            qualityFrame.nextQualityThreshold:SetText("> " .. thresholds[CraftSim.SIMULATION_MODE.recipeData.expectedQuality])
            
            if canSkipQuality then
                local skipQualityIconText = CraftSim.UTIL:GetQualityIconAsText(CraftSim.SIMULATION_MODE.recipeData.expectedQuality + 2, 20, 20)
                local skipQualityThreshold = thresholds[CraftSim.SIMULATION_MODE.recipeData.expectedQuality + 1]
                local missingSkillInspirationSkip = skipQualityThreshold - (CraftSim.SIMULATION_MODE.recipeData.stats.skill + CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.bonusskill)
                missingSkillInspirationSkip = missingSkillInspirationSkip > 0 and missingSkillInspirationSkip or 0
                local missinSkillText = CraftSim.UTIL:ColorizeText(CraftSim.UTIL:round(missingSkillInspirationSkip, 1), 
                missingSkillInspirationSkip == 0 and CraftSim.CONST.COLORS.GREEN or CraftSim.CONST.COLORS.RED)
                qualityFrame.skipQualityMissingSkillInspirationValue:SetText(missinSkillText)
                qualityFrame.skipQualityMissingSkillInspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL) .. " " .. skipQualityIconText)
            end
        end
    end
end
