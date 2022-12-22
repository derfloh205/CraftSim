CraftSimSIMULATION_MODE = {}

CraftSimSIMULATION_MODE.isActive = false
CraftSimSIMULATION_MODE.reagentOverwriteFrame = nil
CraftSimSIMULATION_MODE.craftingDetailsFrame = nil
CraftSimSIMULATION_MODE.recipeData = nil
CraftSimSIMULATION_MODE.baseSkill = nil
CraftSimSIMULATION_MODE.reagentSkillIncrease = nil

function CraftSimSIMULATION_MODE:Init()

    CraftSimFRAME:InitSimModeFrames()
end

function CraftSimSIMULATION_MODE:OnInputAllocationChanged()
    if not CraftSimSIMULATION_MODE.recipeData then
        return
    end
    local inputBox = self
    local reagentData = CraftSimSIMULATION_MODE.recipeData.reagents[inputBox.reagentIndex]

    local inputNumber = CraftSimUTIL:ValidateNumberInput(inputBox)
    inputBox.currentAllocation = inputNumber

    local totalAllocations = CraftSimUTIL:ValidateNumberInput(inputBox:GetParent().inputq1)
    local totalAllocations = totalAllocations + CraftSimUTIL:ValidateNumberInput(inputBox:GetParent().inputq2)
    local totalAllocations = totalAllocations + CraftSimUTIL:ValidateNumberInput(inputBox:GetParent().inputq3)

    -- if the total sum would be higher than the required quantity, force the smallest number to get the highest quantity
    if totalAllocations > reagentData.requiredQuantity then
        local otherAllocations = totalAllocations - inputNumber
        inputNumber = reagentData.requiredQuantity - otherAllocations
        inputBox:SetText(inputNumber)
    end

    reagentData.itemsInfo[inputBox.qualityID].allocations = tonumber(inputNumber)

    -- recalculate the skill increase by reagents and adjust skill
    local reagentSkillIncrease = CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSimSIMULATION_MODE.recipeData)
    CraftSimSIMULATION_MODE.reagentSkillIncrease = reagentSkillIncrease

    -- Update Stats -> TODO: gather stats somewhere and update in one method? .. always update everything..?
    local skillMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeSkillModInput, true)
    CraftSimSIMULATION_MODE.recipeData.stats.skill = CraftSimSIMULATION_MODE.baseSkill + reagentSkillIncrease + skillMod

    CraftSimMAIN:TriggerModulesByRecipeType()
end

function CraftSimSIMULATION_MODE:OnStatModifierChanged()
    if not CraftSimSIMULATION_MODE.isActive then
        -- This could be triggered on init when some values are set
        return
    end
    local inputNumber = CraftSimUTIL:ValidateNumberInput(self, true)
    local stat = self.stat

    if stat == CraftSimCONST.STAT_MAP.CRAFTING_DETAILS_RECIPE_DIFFICULTY then
        CraftSimSIMULATION_MODE.recipeData.recipeDifficulty = CraftSimSIMULATION_MODE.baseRecipeDifficulty + inputNumber
    elseif stat == CraftSimCONST.STAT_MAP.CRAFTING_DETAILS_SKILL then
        CraftSimSIMULATION_MODE.recipeData.stats.skill = CraftSimSIMULATION_MODE.baseSkill + CraftSimSIMULATION_MODE.reagentSkillIncrease + inputNumber
    end

    CraftSimMAIN:TriggerModulesByRecipeType()
end

function CraftSimSIMULATION_MODE:UpdateReagentAllocationsByInput()
    -- update item allocations based on inputfields
    for _, overwriteInput in pairs(CraftSimSIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
        if overwriteInput.isActive then
            local reagentIndex = overwriteInput.inputq1.reagentIndex
            local reagentData = CraftSimSIMULATION_MODE.recipeData.reagents[reagentIndex]

            reagentData.itemsInfo[1].allocations = overwriteInput.inputq1:GetNumber()
            if reagentData.differentQualities then
                reagentData.itemsInfo[2].allocations = overwriteInput.inputq2:GetNumber()
                reagentData.itemsInfo[3].allocations = overwriteInput.inputq3:GetNumber()
            end
        end
    end
end

function CraftSimSIMULATION_MODE:UpdateSimModeRecipeDataByInputs()
    -- update reagent skill increase by material allocation
    local reagentSkillIncrease = CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSimSIMULATION_MODE.recipeData)
    CraftSimSIMULATION_MODE.reagentSkillIncrease = reagentSkillIncrease

    -- update skill by input modifier and reagent skill increase
    local skillMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeSkillModInput, true)
    CraftSimSIMULATION_MODE.recipeData.stats.skill = CraftSimSIMULATION_MODE.baseSkill + reagentSkillIncrease + skillMod

    -- adjust expected quality by skill if quality recipe
    if not CraftSimSIMULATION_MODE.recipeData.result.isNoQuality then
        CraftSimSIMULATION_MODE.recipeData.expectedQuality = CraftSimSTATS:GetExpectedQualityBySkill(CraftSimSIMULATION_MODE.recipeData, CraftSimSIMULATION_MODE.recipeData.stats.skill, CraftSimOptions.breakPointOffset)
    end
end

function CraftSimSIMULATION_MODE:UpdateSimulationMode()
    CraftSimSIMULATION_MODE:UpdateReagentAllocationsByInput()
    CraftSimSIMULATION_MODE:UpdateSimModeRecipeDataByInputs()
    CraftSimFRAME:UpdateSimModeStatDisplay()
end

function CraftSimSIMULATION_MODE:InitializeSimulationMode(recipeData)
    CraftSimSIMULATION_MODE.recipeData = CopyTable(recipeData)   
    CraftSimSIMULATION_MODE.recipeData.isSimModeData = true

    -- initialize base values based on original recipeData
    local OldReagentSkillIncrease = CraftSimREAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSimSIMULATION_MODE.recipeData)
    CraftSimSIMULATION_MODE.baseSkill = CraftSimSIMULATION_MODE.recipeData.stats.skill - OldReagentSkillIncrease
    CraftSimSIMULATION_MODE.baseRecipeDifficulty = CraftSimSIMULATION_MODE.recipeData.baseDifficulty

    -- update frame visiblity and initialize the input fields
    CraftSimFRAME:ToggleSimModeFrames()
    CraftSimFRAME:InitilizeSimModeReagentOverwrites()

    -- -- update simulation recipe data and frontend
    -- CraftSimSIMULATION_MODE:UpdateSimulationMode()
end