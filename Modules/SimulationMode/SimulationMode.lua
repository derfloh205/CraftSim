CraftSimAddonName, CraftSim = ...

CraftSim.SIMULATION_MODE = {}

CraftSim.SIMULATION_MODE.isActive = false
---@type CraftSim.RecipeData?
CraftSim.SIMULATION_MODE.recipeData = nil
---@type CraftSim.SpecializationData?
CraftSim.SIMULATION_MODE.specializationData = nil

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SIMULATION_MODE)

function CraftSim.SIMULATION_MODE:ResetSpecData()
    CraftSim.SIMULATION_MODE.specializationData = CraftSim.SIMULATION_MODE.recipeData.specializationData:Copy()

    CraftSim.SIMULATION_MODE.FRAMES:InitSpecModBySpecData() -- revert
    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:OnSpecModified(userInput, nodeModFrame)
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not userInput or not recipeData then
        return
    end
    
    local inputNumber = CraftSim.UTIL:ValidateNumberInput(nodeModFrame.input, true)

    print("startinput after validation: " .. inputNumber)

    if inputNumber > nodeModFrame.nodeProgressBar.maxValue then
        inputNumber = nodeModFrame.nodeProgressBar.maxValue
    elseif inputNumber < -1 then
        inputNumber = -1
    end
    nodeModFrame.Update(inputNumber)

    print("inputNumber after update: " .. inputNumber)

    -- update specdata
    ---@type CraftSim.NodeData
    local nodeData = CraftSim.GUTIL:Find(CraftSim.SIMULATION_MODE.specializationData.nodeData, function(nodeData) return nodeData.nodeID == nodeModFrame.nodeID end)
    if not nodeData then
        return
    end
    nodeData.rank = inputNumber
    nodeData.active = inputNumber > -1

    print("new rank: " .. nodeData.rank)
    print("new active: " .. tostring(nodeData.active))

    nodeData:UpdateProfessionStats()

    print("nodeData stats: ")
    print(nodeData.professionStats, true, false, 2)

    CraftSim.SIMULATION_MODE.specializationData:UpdateProfessionStats()

    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
    if not userInput then
        return
    end
    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:OnInputAllocationChanged(inputBox, userInput)
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not userInput or not recipeData then
        return
    end

    local inputNumber = CraftSim.UTIL:ValidateNumberInput(inputBox)
    inputBox.currentAllocation = inputNumber

    local totalAllocations = CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq1)
    local totalAllocations = totalAllocations + CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq2)
    local totalAllocations = totalAllocations + CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq3)

    -- if the total sum would be higher than the required quantity, force the smallest number to get the highest quantity
    if totalAllocations > inputBox.requiredQuantityValue then
        local otherAllocations = totalAllocations - inputNumber
        inputNumber = inputBox.requiredQuantityValue - otherAllocations
        inputBox:SetText(inputNumber)
    end

    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:AllocateAllByQuality(qualityID)
    local simulationModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()
    local reagentOverwriteFrame = simulationModeFrames.reagentOverwriteFrame

    for _, currentInput in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do

        if currentInput.isActive then
            for i = 1, 3, 1 do
                local allocationForQuality = 0
                if i == qualityID then 
                    allocationForQuality = currentInput["inputq" .. i].requiredQuantityValue
                elseif qualityID == 0 then
                    allocationForQuality = 0
                end

                currentInput["inputq" .. i]:SetText(allocationForQuality)
            end
        end
    end

    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:UpdateProfessionStatModifiersByInputs()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then
        return
    end
    recipeData.professionStatModifiers:Clear()

    local baseProfessionStatsSpec = nil
    local professionStatsSpec = nil
    local professionStatsSpecDiff = nil
    if not recipeData.isCooking then
        baseProfessionStatsSpec = CraftSim.SIMULATION_MODE.specializationData.professionStats
        professionStatsSpec = recipeData.specializationData.professionStats
        professionStatsSpecDiff = baseProfessionStatsSpec:Copy()
        professionStatsSpecDiff:subtract(professionStatsSpec)
        recipeData.professionStatModifiers:add(professionStatsSpecDiff)
    end


    local simulationModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()

    -- update difficulty based on input
    local recipeDifficultyMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.recipeDifficultyMod, true)
    recipeData.professionStatModifiers.recipeDifficulty:addValue(recipeDifficultyMod)

    -- update skill based on input
    local skillMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.baseSkillMod, true)
    recipeData.professionStatModifiers.skill:addValue(skillMod)

    -- update other stats
    if recipeData.supportsInspiration then
        local inspirationMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.inspirationMod, true)
        local inspirationSkillMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.inspirationSkillMod, true)

        recipeData.professionStatModifiers.inspiration:addValue(inspirationMod)
        recipeData.professionStatModifiers.inspiration:addExtraValueAfterFactor(inspirationSkillMod)
    end

    if recipeData.supportsMulticraft then
        local multicraftMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.multicraftMod, true)
        recipeData.professionStatModifiers.multicraft:addValue(multicraftMod)
    end
    
    if recipeData.supportsResourcefulness then
        local resourcefulnessMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.resourcefulnessMod, true)
        recipeData.professionStatModifiers.resourcefulness:addValue(resourcefulnessMod)
    end
end

function CraftSim.SIMULATION_MODE:UpdateRequiredReagentsByInputs()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    -- should not happen but nil check anyway
    if not recipeData then
        return
    end
    print("Update Reagent Input Frames:")

    local simulationModeFrames = CraftSim.SIMULATION_MODE.FRAMES:GetSimulationModeFramesByVisibility()
    local reagentOverwriteFrame = simulationModeFrames.reagentOverwriteFrame

    --required
    local reagentList = {}
    -- update item allocations based on inputfields
    for _, overwriteInput in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do
        if overwriteInput.isActive then
            table.insert(reagentList, CraftSim.ReagentListItem(overwriteInput.inputq1.itemID, overwriteInput.inputq1:GetNumber()))
            table.insert(reagentList, CraftSim.ReagentListItem(overwriteInput.inputq2.itemID, overwriteInput.inputq2:GetNumber()))
            table.insert(reagentList, CraftSim.ReagentListItem(overwriteInput.inputq3.itemID, overwriteInput.inputq3:GetNumber()))
        end
    end

    recipeData:SetReagents(reagentList)

    -- optional/finishing
    recipeData.reagentData:ClearOptionalReagents()

    local itemIDs = {}
    for _, dropdown in pairs(reagentOverwriteFrame.optionalReagentFrames) do
        local itemID = dropdown.selectedValue
        if itemID then
            table.insert(itemIDs, itemID)
        end
    end

    recipeData:SetOptionalReagents(itemIDs)
end

function CraftSim.SIMULATION_MODE:UpdateSimulationMode()
    CraftSim.SIMULATION_MODE:UpdateRequiredReagentsByInputs()
    CraftSim.SIMULATION_MODE:UpdateProfessionStatModifiersByInputs()
    CraftSim.SIMULATION_MODE.recipeData:Update() -- update recipe Data by modifiers/reagents and such
    CraftSim.SIMULATION_MODE.FRAMES:UpdateCraftingDetailsPanel()
end

function CraftSim.SIMULATION_MODE:InitializeSimulationMode(recipeData)
    CraftSim.SIMULATION_MODE.recipeData = recipeData

    if not recipeData.isCooking and not recipeData.isOldWorldRecipe then
        CraftSim.SIMULATION_MODE.specializationData = recipeData.specializationData:Copy()
    end
    
    -- update frame visiblity and initialize the input fields
    CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility()
    CraftSim.SIMULATION_MODE.FRAMES:InitReagentOverwriteFrames(CraftSim.SIMULATION_MODE.recipeData)
    CraftSim.SIMULATION_MODE.FRAMES:InitOptionalReagentDropdowns(CraftSim.SIMULATION_MODE.recipeData)
    CraftSim.SIMULATION_MODE.FRAMES:InitSpecModBySpecData()

    -- -- update simulation recipe data and frontend
    CraftSim.SIMULATION_MODE:UpdateSimulationMode()

    -- recalculate modules
    CraftSim.MAIN:TriggerModulesErrorSafe()
end