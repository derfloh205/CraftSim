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
--- Stores only the user's raw stat modifier inputs (without spec diff contribution)
--- so recreated modInput widgets are initialized with the correct value each update.
---@type {skill: number, multicraft: number, resourcefulness: number, ingenuity: number, recipeDifficulty: number}?
CraftSim.SIMULATION_MODE.userStatModifiers = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.SimulationMode")

function CraftSim.SIMULATION_MODE:ResetSpecData()
    CraftSim.SIMULATION_MODE.specializationData = CraftSim.SIMULATION_MODE.recipeData.specializationData:Copy()

    CraftSim.MODULES:UpdateUI()
end

function CraftSim.SIMULATION_MODE:MaxSpecData()
    if not CraftSim.SIMULATION_MODE.specializationData then
        return
    end
    for _, nodeData in pairs(CraftSim.SIMULATION_MODE.specializationData.nodeData) do
        nodeData.rank = nodeData.maxRank
    end

    CraftSim.SIMULATION_MODE.specializationData:UpdateProfessionStats()
    CraftSim.MODULES:UpdateUI()
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

    CraftSim.MODULES:UpdateUI()
end

function CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
    if not userInput then
        return
    end
    CraftSim.MODULES:UpdateUI()
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

    CraftSim.MODULES:UpdateUI()
end

function CraftSim.SIMULATION_MODE:AllocateAllByQuality(qualityID)
    self.recipeData.reagentData:SetReagentsMaxByQuality(qualityID)

    self:InitializeReagentList()

    CraftSim.MODULES:UpdateUI()
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

    -- Read raw user inputs from modInput widgets (these widgets are recreated each update
    -- and must be initialized from userStatModifiers, not from professionStatModifiers which
    -- also includes spec diff -- otherwise spec diff gets double-counted each update cycle)

    -- update difficulty based on input
    local recipeDifficultyMod = simulationModeFrames.recipeDifficultyMod and simulationModeFrames.recipeDifficultyMod.currentValue or 0
    recipeData.professionStatModifiers.recipeDifficulty:addValue(recipeDifficultyMod)

    -- update skill based on input
    local skillMod = simulationModeFrames.baseSkillMod and simulationModeFrames.baseSkillMod.currentValue or 0
    recipeData.professionStatModifiers.skill:addValue(skillMod)

    -- update other stats
    local multicraftMod = 0
    if recipeData.supportsMulticraft then
        multicraftMod = simulationModeFrames.multicraftMod and simulationModeFrames.multicraftMod.currentValue or 0
        recipeData.professionStatModifiers.multicraft:addValue(multicraftMod)
    end

    local resourcefulnessMod = 0
    if recipeData.supportsResourcefulness then
        resourcefulnessMod = simulationModeFrames.resourcefulnessMod and simulationModeFrames.resourcefulnessMod.currentValue or 0
        recipeData.professionStatModifiers.resourcefulness:addValue(resourcefulnessMod)
    end

    local ingenuityMod = 0
    if recipeData.supportsIngenuity then
        ingenuityMod = simulationModeFrames.ingenuityMod and simulationModeFrames.ingenuityMod.currentValue or 0
        recipeData.professionStatModifiers.ingenuity:addValue(ingenuityMod)
    end

    -- Save the raw user inputs so UpdateCraftingDetailsPanel can initialize the
    -- recreated modInput widgets with the correct (non-spec-diff-contaminated) values
    if CraftSim.SIMULATION_MODE.userStatModifiers then
        CraftSim.SIMULATION_MODE.userStatModifiers.recipeDifficulty = recipeDifficultyMod
        CraftSim.SIMULATION_MODE.userStatModifiers.skill = skillMod
        CraftSim.SIMULATION_MODE.userStatModifiers.multicraft = multicraftMod
        CraftSim.SIMULATION_MODE.userStatModifiers.resourcefulness = resourcefulnessMod
        CraftSim.SIMULATION_MODE.userStatModifiers.ingenuity = ingenuityMod
    end

    recipeData.concentrating = simulationModeFrames.concentrationToggleMod.isOn
end

function CraftSim.SIMULATION_MODE:UpdateRequiredReagentsByInputs()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    -- should not happen but nil check anyway
    if not recipeData then
        return
    end
    print("Update Reagent Input Frames:")

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local frame = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER and CraftSim.SIMULATION_MODE.frameWO or CraftSim.SIMULATION_MODE.frame

    -- optional/finishing
    recipeData.reagentData:ClearOptionalReagents()

    local possibleRequiredSelectableItemIDs = {}
    if recipeData.reagentData:HasRequiredSelectableReagent() and not recipeData.reagentData.requiredSelectableReagentSlot:IsCurrency() then
        possibleRequiredSelectableItemIDs = GUTIL:Map(
            recipeData.reagentData.requiredSelectableReagentSlot.possibleReagents,
            function(reagent)
                return reagent.item and reagent.item:GetItemID()
            end)
    end

    local optionalReagentItemSelectors = frame.optionalReagentItemSelectors --[[@as GGUI.ItemSelector[] ]]

    local itemIDs = {}
    for _, optionalReagentItemSelector in pairs(optionalReagentItemSelectors) do
        if optionalReagentItemSelector.isCurrencySlot and optionalReagentItemSelector.selectedCurrencyID then
            recipeData.reagentData:SetOptionalCurrencyReagent(optionalReagentItemSelector.selectedCurrencyID)
        else
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

    -- Reset user stat modifier inputs for the new simulation session
    self.userStatModifiers = {
        skill = 0,
        multicraft = 0,
        resourcefulness = 0,
        ingenuity = 0,
        recipeDifficulty = 0,
    }

    -- update frame visiblity and initialize the input fields
    UI:UpdateVisibility()
    self:InitializeReagentList()
    UI:InitOptionalReagentItemSelectors(self.recipeData)

    -- update simulation recipe data and UI
    self:UpdateSimulationMode()

    CraftSim.MODULES:UpdateUI()
end

--- used by allocate button in reagent optimization module
---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE:AllocateReagents(recipeData)
    if not CraftSim.SIMULATION_MODE.isActive then return end
    if not CraftSim.SIMULATION_MODE.recipeData then return end

    if not CraftSim.SIMULATION_MODE.recipeData.recipeID == recipeData.recipeID then
        return
    end

    -- set simulation reagents to recipeData reagents
    CraftSim.SIMULATION_MODE.recipeData:SetReagentsByCraftingReagentInfoTbl(recipeData.reagentData:GetCraftingReagentInfoTbl())
    CraftSim.SIMULATION_MODE:InitializeReagentList()
    CraftSim.MODULES:UpdateUI()
end


--- Overhaul

function CraftSim.SIMULATION_MODE:InitializeReagentList()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then return end
    local content
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        content = CraftSim.SIMULATION_MODE.frameWO.content
    else
        content = CraftSim.SIMULATION_MODE.frame.content
    end

    if not recipeData then return end

    content.reagentList:Populate(recipeData)
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

        local newMax = math.max(requiredQuantity - (q1Input.currentValue + q2Input.currentValue), 0)
        q1Input.maxValue = q1Input.currentValue + newMax
        q2Input.maxValue = q2Input.currentValue + newMax
    end

    local quantityFulfilled = recipeData.reagentData:SetRequiredReagent(itemID, quantity)

    if quantityFulfilled then
        CraftSim.MODULES:UpdateUI()
    end
end
