CraftSimAddonName, CraftSim = ...

CraftSim.SIMULATION_MODE.FRAMES = {}

CraftSim.SIMULATION_MODE.FRAMES.WORKORDER = {}
CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SIMULATION_MODE)

function CraftSim.SIMULATION_MODE.FRAMES:Init()

    local function createSimulationModeFrames(schematicForm, workOrder)
        local frames = {}
        -- CHECK BUTTON
        local clickCallback = function(self) 
            print("sim mode click callback")
            CraftSim.SIMULATION_MODE.isActive = self:GetChecked()
            local bestQBox = schematicForm.AllocateBestQualityCheckBox
            if bestQBox:GetChecked() and CraftSim.SIMULATION_MODE.isActive then
                bestQBox:Click()
            end
            if CraftSim.SIMULATION_MODE.isActive then
                CraftSim.SIMULATION_MODE:InitializeSimulationMode(CraftSim.MAIN.currentRecipeData)
            end
    
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end
        frames.toggleButton = CraftSim.FRAME:CreateCheckboxCustomCallback(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL), CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP), false, clickCallback, 
            schematicForm, schematicForm.Details, "BOTTOM", "TOP", -65, 40)
        
        frames.toggleButton:Hide()
    
        -- REAGENT OVERWRITE FRAMES
        local reagentOverwriteFrame = CreateFrame("frame", nil, schematicForm)
        reagentOverwriteFrame:SetPoint("TOPLEFT", schematicForm.Reagents, "TOPLEFT", -40, -35)
        reagentOverwriteFrame:SetSize(200, 400)
        reagentOverwriteFrame:Hide()
    
        local baseX = 10
        local inputOffsetX = 50
    
        reagentOverwriteFrame.qualityIcon1 = CraftSim.GGUI.QualityIcon({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame,sizeX=20,sizeY=20,anchorA="TOP",anchorB="TOP",
            offsetX=baseX-15,offsetY=15, initialQuality=1,
        })
        reagentOverwriteFrame.quality1Button = CraftSim.GGUI.Button({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame.qualityIcon1.frame,anchorA="BOTTOM", anchorB="TOP",
            sizeX=20,sizeY=20,label="->",
            clickCallback=function() 
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(1)
            end
        })
        reagentOverwriteFrame.qualityIcon2 = CraftSim.GGUI.QualityIcon({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame,sizeX=20,sizeY=20,anchorA="TOP",anchorB="TOP",
            offsetX=baseX+inputOffsetX - 15,offsetY=15, initialQuality=2,
        })
        reagentOverwriteFrame.quality2Button = CraftSim.GGUI.Button({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame.qualityIcon2.frame,anchorA="BOTTOM", anchorB="TOP",
            sizeX=20,sizeY=20,label="->",
            clickCallback=function() 
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(2)
            end
        })
        reagentOverwriteFrame.qualityIcon3 = CraftSim.GGUI.QualityIcon({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame,sizeX=20,sizeY=20,anchorA="TOP",anchorB="TOP",
            offsetX=baseX+inputOffsetX*2 - 15,offsetY=15, initialQuality=3,
        })
        reagentOverwriteFrame.quality3Button = CraftSim.GGUI.Button({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame.qualityIcon3.frame,anchorA="BOTTOM", anchorB="TOP",
            sizeX=20,sizeY=20,label="->",
            clickCallback=function() 
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(3)
            end
        })
        reagentOverwriteFrame.clearAllocationsButton = CraftSim.GGUI.Button({
            parent=reagentOverwriteFrame, anchorParent=reagentOverwriteFrame.quality3Button.frame, anchorA="LEFT", anchorB="RIGHT",
            offsetX=inputOffsetX - 30, label="Clear", adjustWidth=true, sizeX=0,sizeY=20,
            clickCallback=function() 
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(0)
            end
        })
    
        reagentOverwriteFrame.reagentOverwriteInputs = {}
    
        local offsetY = -45
    
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, 0, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*2, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*3, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*4, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs, CraftSim.SIMULATION_MODE.FRAMES:CreateReagentOverwriteFrame(reagentOverwriteFrame, 0, offsetY*5, baseX, inputOffsetX))
        
        frames.reagentOverwriteFrame = reagentOverwriteFrame
    
        local function CreateReagentInputDropdown(offsetY)
            local optionalReagentDropdown = CraftSim.GGUI.Dropdown({
                parent=reagentOverwriteFrame, anchorParent=schematicForm.OptionalReagents, anchorA="TOPLEFT",anchorB="TOPLEFT",
                offsetX=30, offsetY=offsetY + 20, width=120,
                clickCallback=function (_, _, value)
                    CraftSim.MAIN:TriggerModulesErrorSafe()
                end
            })
            return optionalReagentDropdown
        end
    
        reagentOverwriteFrame.optionalReagentFrames = {}
        local dropdownSpacingY = -38
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(0))
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY))
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*2))
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*3))
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*4))
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*5))
        table.insert(reagentOverwriteFrame.optionalReagentFrames, CreateReagentInputDropdown(dropdownSpacingY*6))

        
        -- DETAILS FRAME
        local simModeDetailsFrame = CraftSim.GGUI.Frame({
            parent=schematicForm, anchorParent=ProfessionsFrame, anchorA="TOPRIGHT", anchorB="TOPRIGHT", offsetX=-5, offsetY=-155,
            sizeX=350, sizeY=355, frameID=(workOrder and CraftSim.CONST.FRAMES.CRAFTING_DETAILS_WO) or CraftSim.CONST.FRAMES.CRAFTING_DETAILS,
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS, collapseable=true, moveable=true,
            title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE),
            frameTable=CraftSim.MAIN.FRAMES,
            frameConfigTable=CraftSimGGUIConfig,
        })
    
        simModeDetailsFrame:Hide()

        frames.detailsFrame = simModeDetailsFrame

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
            "TOPRIGHT", "TOPRIGHT", modOffsetX - 30, offsetY - 20 + 3.5, 30, 20, 0, true, 
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)

        frames.recipeDifficultyMod = simModeDetailsFrame.content.recipeDifficultyMod

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
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true, 
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.inspirationMod = simModeDetailsFrame.content.inspirationMod
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
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true, 
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.inspirationSkillMod = simModeDetailsFrame.content.inspirationSkillMod
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
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true, 
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.multicraftMod = simModeDetailsFrame.content.multicraftMod
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
            "TOPRIGHT", "TOPRIGHT", 0, offsetY*2, 30, 20, 0, true, 
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.resourcefulnessMod = simModeDetailsFrame.content.resourcefulnessMod
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
            "TOPRIGHT", "TOPRIGHT", 0, offsetY*2, 30, 20, 0, true, 
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.baseSkillMod = simModeDetailsFrame.content.baseSkillMod
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

        qualityFrame.currentQualityIcon = CraftSim.GGUI.QualityIcon({
            parent=qualityFrame,anchorParent=qualityFrame,sizeX=25,sizeY=25,anchorA="TOPRIGHT",anchorB="TOPRIGHT",offsetY=5
        })

        qualityFrame.currentQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityThreshold:SetPoint("RIGHT", qualityFrame.currentQualityIcon.frame, "LEFT", -5, 0)
        qualityFrame.currentQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityTitle:SetPoint("TOPLEFT", qualityFrame.currentQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL))

        qualityFrame.nextQualityIcon = CraftSim.GGUI.QualityIcon({
            parent=qualityFrame,anchorParent=qualityFrame.currentQualityIcon.frame,anchorA="TOP",anchorB="TOP",offsetY=offsetY,
            sizeX=25,sizeY=25,
        })

        qualityFrame.nextQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityThreshold:SetPoint("RIGHT", qualityFrame.nextQualityIcon.frame, "LEFT", -5, 0)
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

        return frames
    end

    CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER = createSimulationModeFrames(ProfessionsFrame.CraftingPage.SchematicForm)
    CraftSim.SIMULATION_MODE.FRAMES.WORKORDER = createSimulationModeFrames(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
end

function CraftSim.SIMULATION_MODE.FRAMES:InitSpecModifier()
    local sizeX=1000
    local sizeY=700

    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm,anchorParent=UIParent,sizeX=sizeX,sizeY=sizeY,frameID=CraftSim.CONST.FRAMES.SPEC_SIM, frameStrata="FULLSCREEN",
        closeable=true,collapseable=true, moveable=true,
        title="CraftSim Knowledge Simulation",
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })
    local frameWO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,anchorParent=UIParent,sizeX=sizeX,sizeY=sizeY,frameID=CraftSim.CONST.FRAMES.SPEC_SIM_WO, frameStrata="FULLSCREEN",
        closeable=true,collapseable=true, moveable=true,
        title="CraftSim Knowledge Simulation",
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })
    
    local function createContent(frame)
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

        frame.content.resetButton = CraftSim.GGUI.Button({
            label="Reset", parent=frame.content,anchorParent=spec4,anchorA="LEFT",anchorB="RIGHT", offsetX=40,sizeX=15,sizeY=25,adjustWidth=true,
            clickCallback=function ()
                CraftSim.SIMULATION_MODE:ResetSpecData()   
            end
        })

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
                        thresholdText:SetText(CraftSim.GUTIL:ColorizeText(threshold.originalText or "", CraftSim.GUTIL.COLORS.GREEN))
                        thresholdRankText:SetText(CraftSim.GUTIL:ColorizeText(threshold.rank or "", CraftSim.GUTIL.COLORS.GREEN))
                    else
                        --print("color grey")
                        thresholdText:SetText(CraftSim.GUTIL:ColorizeText(threshold.originalText or "", CraftSim.GUTIL.COLORS.GREY))
                        thresholdRankText:SetText(CraftSim.GUTIL:ColorizeText(threshold.rank or "", CraftSim.GUTIL.COLORS.GREY))
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
        
                -- last row is either 11, 9, 8, 5, 4, 2, 0
                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*5, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 1),
                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*4, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 2),
                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*3, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 3),
                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 4),
                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 5),
                createNodeModFrame(parent, parent, "TOP", "TOP", 0, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 6),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 7),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 8),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*3, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 9),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*4, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 10),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*5, baseOffsetY+nodeFrameOffsetY*3, 3, 11, tabNr, 11),

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

                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 5, tabNr, 1),
                createNodeModFrame(parent, parent, "TOP", "TOP", -nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 5, tabNr, 2),
                createNodeModFrame(parent, parent, "TOP", "TOP", 0, baseOffsetY+nodeFrameOffsetY*3, 3, 5, tabNr, 3),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX, baseOffsetY+nodeFrameOffsetY*3, 3, 5, tabNr, 4),
                createNodeModFrame(parent, parent, "TOP", "TOP", nodeFrameSpacingX*2, baseOffsetY+nodeFrameOffsetY*3, 3, 5, tabNr, 5),
        
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

    createContent(frameWO)
    createContent(frameNO_WO)

    
    
end

function CraftSim.SIMULATION_MODE.FRAMES:ResetAllNodeModFramesForTab(tab)
    for _, nodeModFrame in pairs(tab.content.nodeModFrames) do
        nodeModFrame:Hide()
        nodeModFrame.showParentLine:Hide()
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:GetSpecNodeModFramesByTabAndLayerAndLayerMax(tabIndex, layer, layerMaxNodes)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local specSimFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        specSimFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM_WO)
    else
        specSimFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM)
    end

    local tab = specSimFrame.content.specializationTabs[tabIndex]

    if tab then
        local nodeModFrames = tab.content.nodeModFrames
        local relevantModFrames = CraftSim.GUTIL:Filter(nodeModFrames, function(nodeModFrame) 
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
    
    overwriteInput.icon = CraftSim.GGUI.Icon({
        parent=overwriteInput, anchorParent=overwriteInput,
        sizeX=40,sizeY=40,anchorA="RIGHT", anchorB="LEFT",
    })

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
        nil, overwriteInputFrame, overwriteInputFrame.icon.frame, "LEFT", "RIGHT", offsetX, 0, inputWidth, 20, 0, false, 
        function (input, userInput)
            CraftSim.SIMULATION_MODE:OnInputAllocationChanged(input, userInput)
        end)
    inputBox.qualityID = qualityID
    return inputBox
end

function CraftSim.SIMULATION_MODE.FRAMES:UpdateCraftingDetailsPanel()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then
        return
    end

    local baseProfessionStats = recipeData.baseProfessionStats
    local professionStats = recipeData.professionStats
    local professionStatsMod = recipeData.professionStatModifiers

    local simModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()
    local detailsFrame = simModeFrames.detailsFrame


    -- Inspiration Display
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationTitle, recipeData.supportsInspiration)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationTitle.helper, recipeData.supportsInspiration)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationValue, recipeData.supportsInspiration)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationMod, recipeData.supportsInspiration)
    if recipeData.supportsInspiration then
        local baseInspiration = professionStats.inspiration.value - professionStatsMod.inspiration.value
        local percentText = CraftSim.GUTIL:Round(professionStats.inspiration:GetPercent(), 1) .. "%"
        detailsFrame.content.inspirationValue:SetText(professionStats.inspiration.value .. " (" .. baseInspiration .."+"..professionStatsMod.inspiration.value .. ") " .. percentText)
    end

    -- Inspiration Skill Display
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationSkillTitle, recipeData.supportsInspiration)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationSkillTitle.helper, recipeData.supportsInspiration)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationSkillValue, recipeData.supportsInspiration)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.inspirationSkillMod, recipeData.supportsInspiration)
    if recipeData.supportsInspiration then
        local baseInspirationSkill = professionStats.inspiration.extraValue
        detailsFrame.content.inspirationSkillValue:SetText(CraftSim.GUTIL:Round(professionStats.inspiration:GetExtraValueByFactor(), 1) .. " (" .. CraftSim.GUTIL:Round(baseInspirationSkill, 1) ..
        "*" .. CraftSim.GUTIL:Round(1+professionStats.inspiration.extraFactor, 2) .."+"..professionStatsMod.inspiration.extraValueAfterFactor .. ")")
    end

    -- Multicraft Display
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftTitle, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftTitle.helper, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftValue, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftMod, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftBonusTitle, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftBonusValue, recipeData.supportsMulticraft)
    if recipeData.supportsMulticraft then
        local baseMulticraft = professionStats.multicraft.value - professionStatsMod.multicraft.value
        local percentText = CraftSim.GUTIL:Round(professionStats.multicraft:GetPercent(), 1) .. "%"
        detailsFrame.content.multicraftValue:SetText(professionStats.multicraft.value .. " (" .. baseMulticraft .."+"..professionStatsMod.multicraft.value .. ") " .. percentText)

        detailsFrame.content.multicraftBonusValue:SetText(professionStats.multicraft.extraFactor*100 .. "%")
    end
    
    -- Resourcefulness Display
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessTitle, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessTitle.helper, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessValue, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessMod, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessBonusTitle, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessBonusValue, recipeData.supportsResourcefulness)
    if recipeData.supportsResourcefulness then
        local baseResourcefulness = professionStats.resourcefulness.value - professionStatsMod.resourcefulness.value
        local percentText = CraftSim.GUTIL:Round(professionStats.resourcefulness:GetPercent(), 1) .. "%"
        detailsFrame.content.resourcefulnessValue:SetText(CraftSim.GUTIL:Round(professionStats.resourcefulness.value) .. " (" .. CraftSim.GUTIL:Round(baseResourcefulness) .."+".. CraftSim.GUTIL:Round(professionStatsMod.resourcefulness.value) .. ") " .. percentText)
        
        detailsFrame.content.resourcefulnessBonusValue:SetText(professionStats.resourcefulness.extraFactor*100 .. "%")
    end

    local qualityFrame = detailsFrame.content.qualityFrame
    CraftSim.FRAME:ToggleFrame(qualityFrame, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.baseSkillTitle, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.baseSkillValue, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.baseSkillMod, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.recipeDifficultyTitle, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.recipeDifficultyValue, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.recipeDifficultyMod, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentSkillIncreaseTitle,  recipeData.supportsQualities and recipeData.hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentSkillIncreaseValue, recipeData.supportsQualities and recipeData.hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentMaxFactorTitle, recipeData.supportsQualities and recipeData.hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentMaxFactorValue, recipeData.supportsQualities and recipeData.hasQualityReagents)
    if recipeData.supportsQualities then
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality, professionStats.recipeDifficulty.value, CraftSimOptions.breakPointOffset)
        qualityFrame.currentQualityIcon:SetQuality(recipeData.resultData.expectedQuality)
        qualityFrame.currentQualityThreshold:SetText("> " .. (thresholds[recipeData.resultData.expectedQuality - 1] or 0))
        
        local hasNextQuality = recipeData.resultData.expectedQuality < recipeData.maxQuality
        local canSkipQuality = recipeData.resultData.expectedQuality < (recipeData.maxQuality - 1)
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
            local nextQualityThreshold = thresholds[recipeData.resultData.expectedQuality]
            local missingSkill = nextQualityThreshold - professionStats.skill.value
            local missingSkillInspiration = nextQualityThreshold - (professionStats.skill.value + professionStats.inspiration:GetExtraValueByFactor())
            missingSkill = missingSkill > 0 and missingSkill or 0
            missingSkillInspiration = missingSkillInspiration > 0 and missingSkillInspiration or 0
            qualityFrame.nextQualityMissingSkillValue:SetText(CraftSim.GUTIL:Round(missingSkill, 1))
            local missingSkillText = CraftSim.GUTIL:ColorizeText(CraftSim.GUTIL:Round(missingSkillInspiration, 1), 
            missingSkillInspiration == 0 and CraftSim.GUTIL.COLORS.GREEN or CraftSim.GUTIL.COLORS.RED)
            local nextQualityIconText = CraftSim.GUTIL:GetQualityIconString(recipeData.resultData.expectedQuality + 1, 20, 20)
            qualityFrame.nextQualityMissingSkillInspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL) .. " " .. nextQualityIconText)
            qualityFrame.nextQualityMissingSkillInspirationValue:SetText(missingSkillText)
            qualityFrame.nextQualityIcon:SetQuality(recipeData.resultData.expectedQuality + 1)
            qualityFrame.nextQualityThreshold:SetText("> " .. thresholds[recipeData.resultData.expectedQuality])
            
            if canSkipQuality then
                local skipQualityIconText = CraftSim.GUTIL:GetQualityIconString(recipeData.resultData.expectedQuality + 2, 20, 20)
                local skipQualityThreshold = thresholds[recipeData.resultData.expectedQuality + 1]
                local missingSkillInspirationSkip = skipQualityThreshold - (professionStats.skill.value + professionStats.inspiration:GetExtraValueByFactor())
                missingSkillInspirationSkip = missingSkillInspirationSkip > 0 and missingSkillInspirationSkip or 0
                local missinSkillText = CraftSim.GUTIL:ColorizeText(CraftSim.GUTIL:Round(missingSkillInspirationSkip, 1), 
                missingSkillInspirationSkip == 0 and CraftSim.GUTIL.COLORS.GREEN or CraftSim.GUTIL.COLORS.RED)
                qualityFrame.skipQualityMissingSkillInspirationValue:SetText(missinSkillText)
                qualityFrame.skipQualityMissingSkillInspiration:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL) .. " " .. skipQualityIconText)
            end
        end

            -- Skill
        local reagentSkillIncrease = recipeData.reagentData:GetSkillFromRequiredReagents()
        local skillNoReagents = professionStats.skill.value - reagentSkillIncrease
        local professionStatsOptionals = recipeData.reagentData:GetProfessionStatsByOptionals()
        local fullRecipeDifficulty = recipeData.professionStats.recipeDifficulty.value
        detailsFrame.content.recipeDifficultyValue:SetText(CraftSim.GUTIL:Round(fullRecipeDifficulty, 1) .. " (" .. baseProfessionStats.recipeDifficulty.value .. "+" .. professionStatsOptionals.recipeDifficulty.value .. "+" .. professionStatsMod.recipeDifficulty.value  .. ")")
        detailsFrame.content.baseSkillValue:SetText(CraftSim.GUTIL:Round(professionStats.skill.value, 1) .. " (" .. CraftSim.GUTIL:Round(skillNoReagents, 1) .. "+" .. CraftSim.GUTIL:Round(reagentSkillIncrease, 1) .. "+" .. professionStatsMod.skill.value ..")")
        
        if recipeData.hasQualityReagents then
            local maxSkillFactor = recipeData.reagentData:GetMaxSkillFactor()
            local maxReagentSkillIncrease = baseProfessionStats.recipeDifficulty.value * maxSkillFactor
            detailsFrame.content.reagentSkillIncreaseValue:SetText(CraftSim.GUTIL:Round(reagentSkillIncrease, 0) .. " / " .. CraftSim.GUTIL:Round(maxReagentSkillIncrease, 0))
            detailsFrame.content.reagentMaxFactorValue:SetText(CraftSim.GUTIL:Round(maxSkillFactor*100, 1) .. " %")
        end
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:InitSpecModBySpecData()
    local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)
    local specializationData = CraftSim.SIMULATION_MODE.specializationData
    
    if not specializationData then
        return
    end
    
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local specModFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        specModFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM_WO)
    else
        specModFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM)
    end
    -- save copy of original in frame
    specModFrame.content.activeNodeModFrames = {}

    -- init tabs
    ---@param tabNr number
    ---@param specTab any
    ---@param specTabName string
    ---@param baseNodeData CraftSim.NodeData
    local function initTab(tabNr, specTab, specTabName, baseNodeData, numNodesPerLayer) 
        specTab:SetText(specTabName)
        specTab:ResetWidth()

        local currentNodeOnLayer = {1, 1, 1}

        local function initNode(nodeData, layer, layerCount, parentNodeModFrame)
           
            print("init node: " .. tostring(nodeData.nodeName))
            local nodesOnLayer = layerCount[layer]
            print("getnodemodframes: " .. tabNr .. "," .. layer .. "," .. nodesOnLayer)
            local nodeModFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSpecNodeModFramesByTabAndLayerAndLayerMax(tabNr, layer, nodesOnLayer)
            --print("found nodemodframes on this layer: " .. tostring(#nodeModFrames) .. " expected: " .. tostring(layerCount[layer]))
            print("current node on layer: " .. tostring(currentNodeOnLayer[layer]))
            local nodeModFrame = nodeModFrames[currentNodeOnLayer[layer]]
            print("debugID: " .. tostring(nodeModFrame.debugID))
            -- make name break and smaller
            local adaptedName = string.gsub(nodeData.nodeName, " ", "\n", 1)
            nodeModFrame.nodeName:SetText(adaptedName)
            -- Fill relevant data for nodeModFrame
            nodeModFrame.nodeID = nodeData.nodeID
            nodeModFrame.nodeProgressBar.maxValue = nodeData.maxRank
            nodeModFrame.input:SetText(nodeData.rank)

            table.insert(specModFrame.content.activeNodeModFrames, nodeModFrame) -- for later easier reference

            -- init the threshold display
            local thresholdLabels = {}
            local nodeRules = nodeData.nodeRules
            for _, nodeRule in pairs(nodeRules) do
                if nodeRule.threshold and not (nodeRule.threshold == -42) then
                    local professionStats = nodeRule.professionStats
                    local label = ""
                    if professionStats.skill.value > 0 then
                        label = label .. "SK+" .. professionStats.skill.value .. " "
                    end
                    if professionStats.inspiration.value > 0 then
                        label = label .. "IN+" .. professionStats.inspiration.value .. " "
                    end
                    if professionStats.inspiration.extraFactor > 0 then
                        label = label .. "ISK+" .. (professionStats.inspiration.extraFactor*100) .. "% "
                    end
                    if professionStats.multicraft.value > 0 then
                        label = label .. "MC+" .. professionStats.multicraft.value .. " "
                    end
                    if professionStats.multicraft.extraFactor > 0 then
                        label = label .. "MCI+" .. (professionStats.multicraft.extraFactor*100) .. "% "
                    end
                    if professionStats.resourcefulness.value > 0 then
                        label = label .. "R+" .. CraftSim.GUTIL:Round(professionStats.resourcefulness.value) .. " "
                    end
                    if professionStats.resourcefulness.extraFactor > 0 then
                        label = label .. "RI+" .. (professionStats.resourcefulness.extraFactor*100) .. "% "
                    end
                    if professionStats.craftingspeed.extraFactor > 0 then
                        label = label .. "CS+" .. (professionStats.craftingspeed.extraFactor*100) .. "% "
                    end
                    if professionStats.potionExperimentationFactor.extraFactor > 0 then
                        label = label .. "PB+" .. (professionStats.potionExperimentationFactor.extraFactor*100) .. "% "
                    end
                    if professionStats.phialExperimentationFactor.extraFactor > 0 then
                        label = label .. "PB+" .. (professionStats.phialExperimentationFactor.extraFactor*100) .. "% "
                    end
    
                    table.insert(thresholdLabels, {
                        label = label,
                        threshold = nodeRule.threshold
                    })
                end
            end
            print("thresholdLabels:")
            print(thresholdLabels, true)
            nodeModFrame.InitThresholds(nodeData.maxRank , thresholdLabels)
            -- adapt to set values
            nodeModFrame.nodeProgressBar.UpdateValueByInput()
            nodeModFrame.updateThresholdsByValue()
            --
            nodeModFrame:Show()
            if parentNodeModFrame then
                nodeModFrame.SetParentNode(parentNodeModFrame)
            end

            for _, childNodeData in pairs(nodeData.childNodes or {}) do
                initNode(childNodeData, layer + 1, layerCount, nodeModFrame)
            end

            currentNodeOnLayer[layer] = currentNodeOnLayer[layer] + 1
        end

        -- init nodes recursively
        initNode(baseNodeData, 1, numNodesPerLayer) 
    end

    local baseNodeNames = CraftSim.GUTIL:Map(specializationData.baseNodeData, function(baseNodeData) return baseNodeData.nodeName end)

    for i = 1, 4, 1 do
        local specTabName = baseNodeNames[i]
        local specTab = specModFrame.content.specializationTabs[i]
        CraftSim.SIMULATION_MODE.FRAMES:ResetAllNodeModFramesForTab(specTab)
        if specTabName then
            specTab:Show()
            initTab(i, specTab, specTabName, specializationData.baseNodeData[i], specializationData.numNodesPerLayer[i])
        else
            specTab:Hide()
        end
    end

end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE.FRAMES:InitOptionalReagentDropdowns(recipeData)
    local optionalReagentSlots = recipeData.reagentData.optionalReagentSlots
    local finishingReagentSlots = recipeData.reagentData.finishingReagentSlots

    local function convertReagentListToDropdownListData(optionalReagentsList)
        local dropDownListData = {{label = "None", value = nil}}
        for _, optionalReagent in pairs(optionalReagentsList) do
            table.insert(dropDownListData, {
                label = optionalReagent.item:GetItemLink(),
                value = optionalReagent.item:GetItemID(),
            })
        end
        return dropDownListData
    end

    local simModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()

    local reagentOverwriteFrame = simModeFrames.reagentOverwriteFrame

    -- init dropdowns
    for _, dropdown in pairs(reagentOverwriteFrame.optionalReagentFrames) do
        dropdown.isOptional = false
        dropdown.isFinishing = false
        dropdown.slotIndex = nil
        dropdown.selectedValue = nil
        dropdown:Hide()
    end

    local dropdownIndex = 1

    -- optionals
    for slotIndex, optionalReagentSlot in pairs(optionalReagentSlots) do
        local currentDropdown = reagentOverwriteFrame.optionalReagentFrames[dropdownIndex]
        local dropdownlist = convertReagentListToDropdownListData(optionalReagentSlot.possibleReagents)
        currentDropdown:Show()
        currentDropdown.slotIndex = slotIndex
        currentDropdown.isOptional = true
        currentDropdown:SetLabel("Optional #" .. slotIndex)
        dropdownIndex = dropdownIndex + 1
        currentDropdown.selectedValue = optionalReagentSlot.activeReagent and optionalReagentSlot.activeReagent.item:GetItemID()
        if currentDropdown.selectedValue then
            currentDropdown:SetData({data=dropdownlist, initialValue=optionalReagentSlot.activeReagent.item:GetItemLink()})
        else
            currentDropdown:SetData({data=dropdownlist, initialValue="None"})
        end
    end
    -- finishing
    for slotIndex, optionalReagentSlot in pairs(finishingReagentSlots) do
        local currentDropdown = reagentOverwriteFrame.optionalReagentFrames[dropdownIndex]
        local dropdownlist = convertReagentListToDropdownListData(optionalReagentSlot.possibleReagents)
        currentDropdown:Show()
        currentDropdown.slotIndex = slotIndex 
        currentDropdown.isFinishing = true
        currentDropdown:SetLabel("Finishing #" .. slotIndex)
        dropdownIndex = dropdownIndex + 1
        currentDropdown.selectedValue = optionalReagentSlot.activeReagent and optionalReagentSlot.activeReagent.item:GetItemID()
        if currentDropdown.selectedValue then
            currentDropdown:SetData({data=dropdownlist, initialValue=optionalReagentSlot.activeReagent.item:GetItemLink()})
        else
            currentDropdown:SetData({data=dropdownlist, initialValue="None"})
        end
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility()
    local recipeData = CraftSim.MAIN.currentRecipeData
    if not recipeData then
        return -- In what case is this nil?
    end


    print("Update Visibility: hasQualityReagents " .. tostring(recipeData.hasQualityReagents))

    -- frame visiblities
    
    local hasOptionalReagents = recipeData.reagentData:HasOptionalReagents()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local specializationInfoFrame = nil
    local simModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()
    local bestQBox = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        bestQBox = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.AllocateBestQualityCheckBox
        specializationInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Reagents, not CraftSim.SIMULATION_MODE.isActive)
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.OptionalReagents, not CraftSim.SIMULATION_MODE.isActive and hasOptionalReagents)
    else
        bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Reagents, not CraftSim.SIMULATION_MODE.isActive)
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, not CraftSim.SIMULATION_MODE.isActive and hasOptionalReagents)
        specializationInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
    end
    specializationInfoFrame.content.knowledgePointSimulationButton:SetEnabled(CraftSim.SIMULATION_MODE.isActive)
    if not CraftSim.SIMULATION_MODE.isActive then
        CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM):Hide()
    end

    local reagentOverwriteFrame = simModeFrames.reagentOverwriteFrame
    print("reagentOverwriteFrame: " .. tostring(reagentOverwriteFrame))
    local craftingDetailsFrame = simModeFrames.detailsFrame
    print("craftingDetailsFrame: " .. tostring(craftingDetailsFrame))

    -- only if recipe has optionalReagents
    local hasQualityReagents = recipeData.hasQualityReagents
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.quality1Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.quality2Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.quality3Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.qualityIcon1, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.qualityIcon2, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.qualityIcon3, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.clearAllocationsButton, hasQualityReagents)

    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame, CraftSim.SIMULATION_MODE.isActive)

    if not CraftSim.SIMULATION_MODE.isActive then
        -- only hide, they will be shown automatically if available
        for _, dropdown in pairs(reagentOverwriteFrame.optionalReagentFrames) do
            print("hide dropdown: " .. tostring(dropdown))
            CraftSim.FRAME:ToggleFrame(dropdown, false)
        end
    end
    

    CraftSim.FRAME:ToggleFrame(craftingDetailsFrame, CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(bestQBox, not CraftSim.SIMULATION_MODE.isActive)
    
    -- also toggle the blizzard create all buttons and so on so that a user does not get the idea to press create when in sim mode..
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateAllButton, not CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateMultipleInputBox, not CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateButton, not CraftSim.SIMULATION_MODE.isActive)
end
---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE.FRAMES:InitReagentOverwriteFrames(recipeData)
    local simModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()
    local reagentOverwriteFrame = simModeFrames.reagentOverwriteFrame

    -- set non quality reagents to max allocations

    -- filter out non quality reagents
    local qualityReagents = CraftSim.GUTIL:Filter(recipeData.reagentData.requiredReagents, function(reagent) 
        return reagent.hasQuality
    end)
    -- reagent overwrites
    for index, inputFrame in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do
        local qualityReagent = qualityReagents and qualityReagents[index] or nil

        CraftSim.FRAME:ToggleFrame(inputFrame, CraftSim.SIMULATION_MODE.isActive and qualityReagent)

        if qualityReagent then
            inputFrame.requiredQuantity:SetText("/ " .. qualityReagent.requiredQuantity)
            -- CraftSim.FRAME:ToggleFrame(inputFrame.inputq2, reagentData.differentQualities)
            -- CraftSim.FRAME:ToggleFrame(inputFrame.inputq3, reagentData.differentQualities)
            inputFrame.inputq1.itemID = qualityReagent.items[1].item:GetItemID()
            inputFrame.inputq1.requiredQuantityValue = qualityReagent.requiredQuantity
            inputFrame.inputq1:SetText(qualityReagent.items[1].quantity)
            inputFrame.inputq2.itemID = qualityReagent.items[2].item:GetItemID()
            inputFrame.inputq2.requiredQuantityValue = qualityReagent.requiredQuantity
            inputFrame.inputq2:SetText(qualityReagent.items[2].quantity)
            inputFrame.inputq3.itemID = qualityReagent.items[3].item:GetItemID()
            inputFrame.inputq3.requiredQuantityValue = qualityReagent.requiredQuantity
            inputFrame.inputq3:SetText(qualityReagent.items[3].quantity)

            inputFrame.isActive = true
            inputFrame.icon:SetItem(qualityReagent.items[1].item)
            inputFrame.icon.qualityIcon:Hide() -- we show the qualities elsewhere
        else
            inputFrame.icon:SetItem(nil)
            inputFrame.isActive = false
        end
    end
end

function CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local simModeFrames = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        simModeFrames = CraftSim.SIMULATION_MODE.FRAMES.WORKORDER
    else
        simModeFrames = CraftSim.SIMULATION_MODE.FRAMES.NO_WORKORDER
    end

    return simModeFrames
end