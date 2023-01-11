addonName, CraftSim = ...

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
        simModeDetailsFrame.content.multicraftBonusTitle:SetText("Multicraft Item Bonus: ")

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
        simModeDetailsFrame.content.resourcefulnessBonusTitle:SetText("Resourcefulness Item Bonus: ")

        simModeDetailsFrame.content.resourcefulnessBonusValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessBonusValue:SetPoint("TOP", simModeDetailsFrame.content.resourcefulnessMod, "BOTTOM", 0, -3)
        simModeDetailsFrame.content.resourcefulnessBonusValue:SetText("0%")

        -- skill

        simModeDetailsFrame.content.baseSkillTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.resourcefulnessBonusTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.baseSkillTitle:SetText("Skill:")

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
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetText("Material Quality Bonus:")
        simModeDetailsFrame.content.reagentSkillIncreaseTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP), 
            simModeDetailsFrame.content, simModeDetailsFrame.content.reagentSkillIncreaseTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.reagentSkillIncreaseValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetPoint("TOP", simModeDetailsFrame.content.baseSkillMod, "TOP", valueOffsetX - 15, offsetY - 5)
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetText("0")

        -- reagent max factor
        simModeDetailsFrame.content.reagentMaxFactorTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentMaxFactorTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.reagentSkillIncreaseTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.reagentMaxFactorTitle:SetText("Material Quality Maximum %:")
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
        qualityFrame.currentQualityTitle:SetText("Expected Quality:")

        qualityFrame.currentQualityIcon = CraftSim.FRAME:CreateQualityIcon(qualityFrame, 25, 25, qualityFrame, "TOPRIGHT", "TOPRIGHT", 0, 5)

        qualityFrame.currentQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityThreshold:SetPoint("RIGHT", qualityFrame.currentQualityIcon, "LEFT", -5, 0)
        qualityFrame.currentQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityTitle:SetPoint("TOPLEFT", qualityFrame.currentQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityTitle:SetText("Next Quality:")

        qualityFrame.nextQualityIcon = CraftSim.FRAME:CreateQualityIcon(qualityFrame, 25, 25, qualityFrame.currentQualityIcon, "TOP", "TOP", 0, offsetY)

        qualityFrame.nextQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityThreshold:SetPoint("RIGHT", qualityFrame.nextQualityIcon, "LEFT", -5, 0)
        qualityFrame.nextQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityMissingSkillTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillTitle:SetPoint("TOPLEFT", qualityFrame.nextQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillTitle:SetText("Missing Skill:")

        qualityFrame.nextQualityMissingSkillValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityThreshold, "TOPRIGHT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillValue:SetText("???")

        qualityFrame.nextQualityMissingSkillInspiration = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillInspiration:SetPoint("TOPLEFT", qualityFrame.nextQualityMissingSkillTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillInspiration:SetText("Missing Skill (Inspiration):")

        qualityFrame.nextQualityMissingSkillInspirationValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillInspirationValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityMissingSkillValue, "TOPRIGHT", 0, offsetY)
        qualityFrame.nextQualityMissingSkillInspirationValue:SetText("???")

        qualityFrame.skipQualityMissingSkillInspiration = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.skipQualityMissingSkillInspiration:SetPoint("TOPLEFT", qualityFrame.nextQualityMissingSkillInspiration, "TOPLEFT", 0, offsetY)
        qualityFrame.skipQualityMissingSkillInspiration:SetText("Missing Skill (Inspiration):")

        qualityFrame.skipQualityMissingSkillInspirationValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.skipQualityMissingSkillInspirationValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityMissingSkillInspirationValue, "TOPRIGHT", 0, offsetY)
        qualityFrame.skipQualityMissingSkillInspirationValue:SetText("???")

         -- warning
        -- simModeDetailsFrame.content.warningText = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        -- simModeDetailsFrame.content.warningText:SetPoint("BOTTOM", simModeDetailsFrame.content, "BOTTOM", 0, 30)
        -- simModeDetailsFrame.content.warningText:SetText(CraftSim.UTIL:ColorizeText("~ WORK IN PROGRESS ~", CraftSim.CONST.COLORS.RED))


        CraftSim.SIMULATION_MODE.craftingDetailsFrame = simModeDetailsFrame
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
        CraftSim.FRAME:initializeDropdownByData(currentDropdown, dropdownlist, nil)
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
        CraftSim.FRAME:initializeDropdownByData(currentDropdown, dropdownlist, nil)
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
    -- frame visiblities
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Reagents, not CraftSim.SIMULATION_MODE.isActive)

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

    local wasNotVisibleNowIs = not ProfessionsFrame.CraftingPage.SchematicForm.Details:IsVisible()
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Details, not CraftSim.SIMULATION_MODE.isActive)
    wasNotVisibleNowIs = wasNotVisibleNowIs and ProfessionsFrame.CraftingPage.SchematicForm.Details:IsVisible()
    if wasNotVisibleNowIs then
        -- try to reset it manually so blizz does not throw an operationInfo not found error
        ProfessionsFrame.CraftingPage.SchematicForm.Details.operationInfo = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeOperationInfo()
    end

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
            qualityFrame.nextQualityMissingSkillInspiration:SetText("Missing Skill (Inspiration) " .. nextQualityIconText)
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
                qualityFrame.skipQualityMissingSkillInspiration:SetText("Missing Skill (Inspiration) " .. skipQualityIconText)
            end
        end
    end
end