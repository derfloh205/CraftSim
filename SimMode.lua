CraftSimSIMULATION_MODE = {}

CraftSimSIMULATION_MODE.isActive = false
CraftSimSIMULATION_MODE.reagentOverwriteFrame = nil
CraftSimSIMULATION_MODE.craftingDetailsFrame = nil
CraftSimSIMULATION_MODE.recipeData = nil
CraftSimSIMULATION_MODE.baseSkill = nil
CraftSimSIMULATION_MODE.reagentSkillIncrease = nil

CraftSimSIMULATION_MODE.baseInspiration = nil
CraftSimSIMULATION_MODE.baseMulticraft = nil
CraftSimSIMULATION_MODE.baseResourcefulness = nil

function CraftSimSIMULATION_MODE:Init()

    CraftSimFRAME:InitSimModeFrames()
end

function CraftSimSIMULATION_MODE:OnInputAllocationChanged(userInput)
    if not userInput or not CraftSimSIMULATION_MODE.recipeData then
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
    --reagentData.itemsInfo[inputBox.qualityID].allocations = tonumber(inputNumber)

    CraftSimSIMULATION_MODE:UpdateSimulationMode()
    CraftSimMAIN:TriggerModulesByRecipeType()
end

function CraftSimSIMULATION_MODE:OnStatModifierChanged(userInput)
    if not userInput then
        return
    end
    CraftSimSIMULATION_MODE:UpdateSimulationMode()
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

    -- update other stats
    if CraftSimSIMULATION_MODE.recipeData.stats.inspiration then
        local inspirationMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeInspirationModInput, true)
        CraftSimSIMULATION_MODE.recipeData.stats.inspiration.value = CraftSimSIMULATION_MODE.baseInspiration.value + inspirationMod
        CraftSimSIMULATION_MODE.recipeData.stats.inspiration.percent = CraftSimUTIL:GetInspirationPercentByStat(CraftSimSIMULATION_MODE.recipeData.stats.inspiration.value) * 100
        if CraftSimSIMULATION_MODE.recipeData.stats.inspiration.percent > 100 then
            -- More than 100 is not possible and it does not make sense in the calculation and would inflate the worth
            CraftSimSIMULATION_MODE.recipeData.stats.inspiration.percent = 100
        end
    end

    if CraftSimSIMULATION_MODE.recipeData.stats.multicraft then
        local multicraftMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeMulticraftModInput, true)
        CraftSimSIMULATION_MODE.recipeData.stats.multicraft.value = CraftSimSIMULATION_MODE.baseMulticraft.value + multicraftMod
        CraftSimSIMULATION_MODE.recipeData.stats.multicraft.percent = CraftSimUTIL:GetMulticraftPercentByStat(CraftSimSIMULATION_MODE.recipeData.stats.multicraft.value) * 100
        if CraftSimSIMULATION_MODE.recipeData.stats.multicraft.percent > 100 then
            -- More than 100 is not possible and it does not make sense in the calculation and would inflate the worth
            CraftSimSIMULATION_MODE.recipeData.stats.multicraft.percent = 100
        end
    end

    if CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness then
        local resourcefulnessMod = CraftSimUTIL:ValidateNumberInput(CraftSimSimModeResourcefulnessModInput, true)
        CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.value = CraftSimSIMULATION_MODE.baseResourcefulness.value + resourcefulnessMod
        CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.percent = CraftSimUTIL:GetResourcefulnessPercentByStat(CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.value) * 100
        if CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.percent > 100 then
            -- More than 100 is not possible and it does not make sense in the calculation and would inflate the worth
            CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness.percent = 100
        end
    end

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
    
    CraftSimSIMULATION_MODE.baseInspiration = CopyTable(CraftSimSIMULATION_MODE.recipeData.stats.inspiration)
    CraftSimSIMULATION_MODE.baseMulticraft = CopyTable(CraftSimSIMULATION_MODE.recipeData.stats.multicraft)
    CraftSimSIMULATION_MODE.baseResourcefulness = CopyTable(CraftSimSIMULATION_MODE.recipeData.stats.resourcefulness)
    -- crafting speed... for later profit per time interval?

    -- update frame visiblity and initialize the input fields
    CraftSimFRAME:ToggleSimModeFrames()
    CraftSimFRAME:InitilizeSimModeReagentOverwrites()

    -- update simulation recipe data and frontend
    CraftSimSIMULATION_MODE:UpdateSimulationMode()

    -- recalculate modules
    CraftSimMAIN:TriggerModulesByRecipeType()
end