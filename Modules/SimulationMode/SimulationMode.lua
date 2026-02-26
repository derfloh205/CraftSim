---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SIMULATION_MODE
CraftSim.SIMULATION_MODE = {}

CraftSim.SIMULATION_MODE.isActive = false
---@type CraftSim.RecipeData?
CraftSim.SIMULATION_MODE.recipeData = nil
---@type CraftSim.SpecializationData?
CraftSim.SIMULATION_MODE.specializationData = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.SimulationMode")

function CraftSim.SIMULATION_MODE:ResetSpecData()
    CraftSim.SIMULATION_MODE.specializationData = CraftSim.SIMULATION_MODE.recipeData.specializationData:Copy()

    CraftSim.INIT:TriggerModuleUpdate()
end

function CraftSim.SIMULATION_MODE:MaxSpecData()
    if not CraftSim.SIMULATION_MODE.specializationData then
        return
    end
    for _, nodeData in pairs(CraftSim.SIMULATION_MODE.specializationData.nodeData) do
        nodeData.rank = nodeData.maxRank
    end

    CraftSim.SIMULATION_MODE.specializationData:UpdateProfessionStats()
    CraftSim.INIT:TriggerModuleUpdate()
end

---@param userInput boolean
---@param numericInput GGUI.NumericInput
function CraftSim.SIMULATION_MODE:OnSpecModified(userInput, numericInput)
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not userInput or not recipeData then
        return
    end

    local inputNodeData = numericInput.nodeData --[[@as CraftSim.NodeData]]

    if not inputNodeData then return end

    local inputNumber = math.min(numericInput.currentValue, inputNodeData.maxRank)

    if inputNumber > inputNodeData.maxRank then
        -- adjust input number in input field
        numericInput.textInput:SetText(tonumber(inputNumber), false)
    end

    print("startinput after validation: " .. inputNumber)

    -- update specdata
    ---@type CraftSim.NodeData
    local nodeData = GUTIL:Find(CraftSim.SIMULATION_MODE.specializationData.nodeData,
        function(nodeData) return nodeData.nodeID == inputNodeData.nodeID end)

    if not nodeData then
        return
    end
    nodeData.rank = inputNumber

    print("new rank: " .. nodeData.rank)
    print("new active: " .. tostring(nodeData.active))

    CraftSim.SIMULATION_MODE.specializationData:UpdateProfessionStats()

    CraftSim.INIT:TriggerModuleUpdate()
end

function CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
    if not userInput then
        return
    end
    CraftSim.INIT:TriggerModuleUpdate()
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

    CraftSim.INIT:TriggerModuleUpdate()
end

function CraftSim.SIMULATION_MODE:AllocateAllByQuality(qualityID)
    local simulationModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
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

    CraftSim.INIT:TriggerModuleUpdate()
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
    if recipeData.specializationData then
        CraftSim.SIMULATION_MODE.specializationData:UpdateProfessionStats()
        baseProfessionStatsSpec = CraftSim.SIMULATION_MODE.specializationData.professionStats
        professionStatsSpec = recipeData.specializationData.professionStats

        print("base stats spec multi: " .. baseProfessionStatsSpec.multicraft.value)
        print("profession stats spec multi: " .. professionStatsSpec.multicraft.value)

        professionStatsSpecDiff = baseProfessionStatsSpec:Copy()
        professionStatsSpecDiff:subtract(professionStatsSpec)
        recipeData.professionStatModifiers:add(professionStatsSpecDiff)
    end


    local simulationModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()

    -- update difficulty based on input
    local recipeDifficultyMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.recipeDifficultyMod, true)
    recipeData.professionStatModifiers.recipeDifficulty:addValue(recipeDifficultyMod)

    -- update skill based on input
    local skillMod = simulationModeFrames.baseSkillMod.currentValue
    recipeData.professionStatModifiers.skill:addValue(skillMod)

    -- update other stats
    if recipeData.supportsMulticraft then
        local multicraftMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.multicraftMod, true)
        recipeData.professionStatModifiers.multicraft:addValue(multicraftMod)
    end

    if recipeData.supportsResourcefulness then
        local resourcefulnessMod = CraftSim.UTIL:ValidateNumberInput(simulationModeFrames.resourcefulnessMod, true)
        recipeData.professionStatModifiers.resourcefulness:addValue(resourcefulnessMod)
    end

    recipeData.concentrating = simulationModeFrames.concentrationToggleMod:GetChecked()
end

function CraftSim.SIMULATION_MODE:UpdateRequiredReagentsByInputs()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    -- should not happen but nil check anyway
    if not recipeData then
        return
    end
    print("Update Reagent Input Frames:")

    local simulationModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()

    ---@type CraftSim.SimulationMode.ReagentOverwriteFrame
    local reagentOverwriteFrame = simulationModeFrames.reagentOverwriteFrame

    -- reagentOverwriteFrame:SetStatus(tostring(GUTIL:Count(recipeData.reagentData.requiredReagents,
    --     function(r) return r.hasQuality end)))

    -- --required
    -- local reagentList = {}
    -- -- update item allocations based on inputfields
    -- for _, overwriteInput in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do
    --     if overwriteInput.isActive then
    --         table.insert(reagentList,
    --             CraftSim.ReagentListItem(overwriteInput.inputq1.itemID, overwriteInput.inputq1:GetNumber()))
    --         table.insert(reagentList,
    --             CraftSim.ReagentListItem(overwriteInput.inputq2.itemID, overwriteInput.inputq2:GetNumber()))
    --         table.insert(reagentList,
    --             CraftSim.ReagentListItem(overwriteInput.inputq3.itemID, overwriteInput.inputq3:GetNumber()))
    --     end
    -- end

    --recipeData:SetReagents(reagentList)

    -- optional/finishing
    recipeData.reagentData:ClearOptionalReagents()

    local possibleRequiredSelectableItemIDs = {}
    if recipeData.reagentData:HasRequiredSelectableReagent() then
        possibleRequiredSelectableItemIDs = GUTIL:Map(
            recipeData.reagentData.requiredSelectableReagentSlot.possibleReagents,
            function(reagent)
                return reagent.item:GetItemID()
            end)
    end

    local itemIDs = {}
    for _, optionalReagentItemSelector in pairs(reagentOverwriteFrame.optionalReagentItemSelectors) do
        local itemID = optionalReagentItemSelector.selectedItem and optionalReagentItemSelector.selectedItem:GetItemID()
        if itemID then
            -- try to set required selectable if available else put to optional/finishing
            if tContains(possibleRequiredSelectableItemIDs, itemID) then
                recipeData.reagentData.requiredSelectableReagentSlot:SetReagent(itemID)
            else
                table.insert(itemIDs, itemID)
            end
        end
    end

    recipeData:SetOptionalReagents(itemIDs)
end

function CraftSim.SIMULATION_MODE:UpdateSimulationMode()
    CraftSim.SIMULATION_MODE:UpdateRecipeDataBuffsBySimulatedBuffs()
    CraftSim.SIMULATION_MODE:UpdateRequiredReagentsByInputs()
    CraftSim.SIMULATION_MODE:UpdateProfessionStatModifiersByInputs()
    CraftSim.SIMULATION_MODE.recipeData:Update() -- update recipe Data by modifiers/reagents and such
    CraftSim.SIMULATION_MODE.UI:UpdateCraftingDetailsPanel()
end

function CraftSim.SIMULATION_MODE:UpdateRecipeDataBuffsBySimulatedBuffs()
    local print = CraftSim.DEBUG:RegisterDebugID("Modules.SimulationMode.UpdateRecipeDataBuffsBySimulatedBuffs")
    local recipeData = CraftSim.SIMULATION_MODE.recipeData

    if not recipeData then return end

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    local craftBuffsFrame
    if exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER then
        craftBuffsFrame = CraftSim.CRAFT_BUFFS.frame
    else
        craftBuffsFrame = CraftSim.CRAFT_BUFFS.frameWO
    end

    if not craftBuffsFrame then return end

    local simulateBuffSelector = craftBuffsFrame.content.simulateBuffSelector

    recipeData.buffData:SetBuffsByUIDToValueMap(simulateBuffSelector.savedVariablesTable)
    recipeData.buffData:UpdateProfessionStats()
end

function CraftSim.SIMULATION_MODE:InitializeSimulationMode(recipeData)
    ---@type CraftSim.SIMULATION_MODE.UI
    local UI = self.UI
    self.recipeData = recipeData

    if recipeData.specializationData then
        self.specializationData = recipeData.specializationData:Copy()
    end

    -- update frame visiblity and initialize the input fields
    UI:UpdateVisibility()
    UI:InitReagentOverwriteFrames(self.recipeData)
    UI:InitOptionalReagentItemSelectors(self.recipeData)

    --- overhaul
    self:InitializeReagentList()

    -- -- update simulation recipe data and frontend
    self:UpdateSimulationMode()

    -- recalculate modules
    CraftSim.INIT:TriggerModuleUpdate()
end

--- used by allocate button in reagent optimization module
---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE:AllocateReagents(recipeData)
    if not CraftSim.SIMULATION_MODE.isActive then return end
    if not CraftSim.SIMULATION_MODE.recipeData then return end

    local simulationModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local reagentOverwriteFrame = simulationModeFrames.reagentOverwriteFrame

    for _, currentInput in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do
        if currentInput.isActive then
            for i = 1, 3, 1 do
                local input = currentInput["inputq" .. i]
                input:SetText(recipeData.reagentData:GetReagentQuantityByItemID(input.itemID))
            end
        end
    end

    for _, finishingSlot in ipairs(recipeData.reagentData.finishingReagentSlots) do
        for _, optionalReagentItemSelector in pairs(reagentOverwriteFrame.optionalReagentItemSelectors) do
            ---@type GGUI.ItemSelector
            local optionalReagentItemSelector = optionalReagentItemSelector

            if #optionalReagentItemSelector.selectionFrame.itemSlots > 0 then
                -- if same slot
                local sameSlot = optionalReagentItemSelector.selectionFrame.itemSlots[1].item:GetItemID() ==
                    finishingSlot.possibleReagents[1].item:GetItemID()

                if sameSlot then
                    optionalReagentItemSelector:SetSelectedItem(finishingSlot.activeReagent and
                        finishingSlot.activeReagent.item)
                end
            end
        end
    end

    CraftSim.INIT:TriggerModuleUpdate()
end


--- Overhaul

function CraftSim.SIMULATION_MODE:InitializeReagentList()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    local content
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        content = CraftSim.SIMULATION_MODE.frameWO.content
    else
        content = CraftSim.SIMULATION_MODE.frame.content
    end
    if not recipeData then return end

    local simplified = recipeData:IsSimplifiedQualityRecipe()

    local reagentFrameList
    if simplified then
        reagentFrameList = content.reagentListSimplified --[[@as GGUI.FrameList]]
    else
        reagentFrameList = content.reagentList --[[@as GGUI.FrameList]]
    end

    reagentFrameList:Remove()

    for _, reagent in pairs(recipeData.reagentData.requiredReagents) do
        if reagent.hasQuality then
            reagentFrameList:Add(function(row, columns)
                local icon = columns[1].icon --[[@as GGUI.Icon]] 
                local q1Input = columns[2].input --[[@as GGUI.NumericInput]]
                local q2Input = columns[3].input --[[@as GGUI.NumericInput]]

                columns[2].itemID = reagent.items[1].item:GetItemID()
                columns[3].itemID = reagent.items[2].item:GetItemID()
                
                icon:SetItem(columns[2].itemID) 
    
                q1Input:SetValue(reagent.items[1].quantity)
                q1Input.maxValue = reagent.requiredQuantity
                q2Input:SetValue(reagent.items[2].quantity)
                q2Input.maxValue = reagent.requiredQuantity
                if not simplified then
                    local q3Input = columns[4].input --[[@as GGUI.NumericInput]]
                    columns[4].itemID = reagent.items[3].item:GetItemID()
                    q3Input:SetValue(reagent.items[3].quantity)
                    q3Input.maxValue = reagent.requiredQuantity
                    columns[5].text:SetText("/" .. reagent.requiredQuantity)
                else
                    columns[4].text:SetText("/" .. reagent.requiredQuantity)
                end
            end)
        end
    end

    reagentFrameList:UpdateDisplay()
end

---@param itemID ItemID
---@param quantity number
---@param row GGUI.FrameList.Row
function CraftSim.SIMULATION_MODE:UpdateRequiredReagent(itemID, quantity, row)
    local recipeData = self.recipeData
    if not recipeData then return end

    local columns = row.columns
    if not recipeData:IsSimplifiedQualityRecipe() then
        local requiredQuantity = recipeData.reagentData:GetRequiredQuantityByItemID(itemID)
        local q1Input = columns[2].input --[[@as GGUI.NumericInput]]
        local q2Input = columns[3].input --[[@as GGUI.NumericInput]]
        local q3Input = columns[4].input --[[@as GGUI.NumericInput]]

        local newMax = math.max(requiredQuantity - (q1Input.currentValue + q2Input.currentValue + q3Input.currentValue), 0)
        q1Input.maxValue = q1Input.currentValue + newMax
        q2Input.maxValue = q2Input.currentValue + newMax
        q3Input.maxValue = q3Input.currentValue + newMax

    else
        local requiredQuantity = recipeData.reagentData:GetRequiredQuantityByItemID(itemID)
        local q1Input = columns[2].input --[[@as GGUI.NumericInput]]
        local q2Input = columns[3].input --[[@as GGUI.NumericInput]]

        local newMax = math.max((q1Input.currentValue + q2Input.currentValue) - requiredQuantity, 0)
        q1Input.maxValue = q1Input.currentValue + newMax
        q2Input.maxValue = q2Input.currentValue + newMax
    end

    local quantityFulfilled = recipeData.reagentData:SetRequiredReagent(itemID, quantity)

    if quantityFulfilled then
        CraftSim.INIT:TriggerModuleUpdate()
    end
end
