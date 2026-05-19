---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.SIMULATION_MODE : CraftSim.Module
CraftSim.SIMULATION_MODE = {}

CraftSim.MODULES:RegisterModule("MODULE_SIMULATION_MODE", CraftSim.SIMULATION_MODE)

GUTIL:RegisterCustomEvents(CraftSim.SIMULATION_MODE, {
    "CRAFTSIM_SIMULATION_MODE_ENABLED",
    "CRAFTSIM_SIMULATION_MODE_DISABLED",
    "CRAFTSIM_SIMULATION_MODE_INITIALIZED",
    "CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED",
    "CRAFTSIM_RECIPE_DATA_UPDATED",
})

CraftSim.SIMULATION_MODE.isActive = false
---@type CraftSim.RecipeData?
CraftSim.SIMULATION_MODE.recipeData = nil
---@type CraftSim.RecipeData?
CraftSim.SIMULATION_MODE.originalRecipeData = nil
---@type CraftSim.SpecializationData?
CraftSim.SIMULATION_MODE.specializationData = nil
--- Stores only the user's raw stat modifier inputs (without spec diff contribution)
--- so recreated modInput widgets are initialized with the correct value each update.
---@type {skill: number, multicraft: number, resourcefulness: number, ingenuity: number, recipeDifficulty: number}?
CraftSim.SIMULATION_MODE.userStatModifiers = nil

local Logger = CraftSim.DEBUG:RegisterLogger("SimulationMode")

---@param recipeData CraftSim.RecipeData?
---@return CraftSim.SpecializationData?
function CraftSim.SIMULATION_MODE:EnsureSimulationSpecializationData(recipeData)
    if not self.specializationData and recipeData and recipeData.specializationData then
        self.specializationData = recipeData.specializationData:Copy()
    end
    return self.specializationData
end

function CraftSim.SIMULATION_MODE:ResetSpecData()
    local recipeData = self.recipeData
    local originalRecipeData = self.originalRecipeData
    if not recipeData or not originalRecipeData then
        return
    end

    -- Reset only specialization simulation data; keep other simulation edits intact.
    if originalRecipeData.specializationData then
        self.specializationData = originalRecipeData.specializationData:Copy()
    else
        self.specializationData = nil
    end

    self:UpdateSimulationModeRecipeData()
end

function CraftSim.SIMULATION_MODE:MaxSpecData()
    local specializationData = self:EnsureSimulationSpecializationData(self.recipeData)
    if not specializationData then
        return
    end
    for _, nodeData in pairs(specializationData.nodeData) do
        nodeData.rank = nodeData.maxRank
    end

    specializationData:UpdateProfessionStats()
    self:UpdateSimulationModeRecipeData()
end

---@param userInput boolean
---@param numericInput GGUI.NumericInput
function CraftSim.SIMULATION_MODE:OnSpecModified(userInput, numericInput)
    local recipeData = self.recipeData
    if not userInput or not recipeData then
        return
    end

    local specializationData = self:EnsureSimulationSpecializationData(recipeData)
    if not specializationData then return end

    local inputNodeData = numericInput.nodeData --[[@as CraftSim.NodeData]]

    if not inputNodeData then return end

    local inputNumber = math.min(numericInput.currentValue, inputNodeData.maxRank)

    if inputNumber > inputNodeData.maxRank then
        -- adjust input number in input field
        numericInput.textInput:SetText(tonumber(inputNumber), false)
    end

    Logger:LogVerbose("startinput after validation: " .. inputNumber)

    -- update specdata
    ---@type CraftSim.NodeData
    local nodeData = GUTIL:Find(specializationData.nodeData,
        function(nodeData) return nodeData.nodeID == inputNodeData.nodeID end)

    if not nodeData then
        return
    end
    nodeData.rank = inputNumber

    Logger:LogVerbose("new rank: " .. nodeData.rank)
    Logger:LogVerbose("new active: " .. tostring(nodeData.active))

    specializationData:UpdateProfessionStats()
    self:UpdateSimulationModeRecipeData()
end

function CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
    if not userInput then
        return
    end
    GUTIL:TriggerCustomEvent("CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED")
end

function CraftSim.SIMULATION_MODE:OnInputAllocationChanged(inputBox, userInput)
    local recipeData = self.recipeData
    if not userInput or not recipeData then
        return
    end

    local inputNumber = CraftSim.UTIL:ValidateNumberInput(inputBox)
    inputBox.currentAllocation = inputNumber

    local totalAllocations = CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq1)
        + CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq2)
        + CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq3)

    -- if the total sum would be higher than the required quantity, force the smallest number to get the highest quantity
    if totalAllocations > inputBox.requiredQuantityValue then
        local otherAllocations = totalAllocations - inputNumber
        inputNumber = inputBox.requiredQuantityValue - otherAllocations
        inputBox:SetText(inputNumber)
    end

    GUTIL:TriggerCustomEvent("CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED")
end

function CraftSim.SIMULATION_MODE:AllocateAllByQuality(qualityID)
    self.recipeData.reagentData:SetReagentsMaxByQuality(qualityID)

    self:InitializeReagentList()

    GUTIL:TriggerCustomEvent("CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED")
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE:UpdateProfessionStatModifiersByInputs(recipeData)
    recipeData.professionStatModifiers:Clear()

    local baseProfessionStatsSpec = nil
    local professionStatsSpec = nil
    local professionStatsSpecDiff = nil
    local specializationData = self:EnsureSimulationSpecializationData(recipeData)
    if recipeData.specializationData and specializationData then
        specializationData:UpdateProfessionStats()
        baseProfessionStatsSpec = specializationData.professionStats
        professionStatsSpec = recipeData.specializationData.professionStats

        Logger:LogDebug("base stats spec multi: " .. baseProfessionStatsSpec.multicraft.value)
        Logger:LogDebug("profession stats spec multi: " .. professionStatsSpec.multicraft.value)

        professionStatsSpecDiff = baseProfessionStatsSpec:Copy()
        professionStatsSpecDiff:subtract(professionStatsSpec)
        recipeData.professionStatModifiers:add(professionStatsSpecDiff)
    end


    local frame = CraftSim.UTIL:IsWorkOrder() and self.frameWO or self.frame

    -- Read raw user inputs from modInput widgets (these widgets are recreated each update
    -- and must be initialized from userStatModifiers, not from professionStatModifiers which
    -- also includes spec diff -- otherwise spec diff gets double-counted each update cycle)

    -- update difficulty based on input
    local recipeDifficultyMod = frame.recipeDifficultyMod and
        frame.recipeDifficultyMod.currentValue or 0
    recipeData.professionStatModifiers.recipeDifficulty:addValue(recipeDifficultyMod)

    -- update skill based on input
    local skillMod = frame.baseSkillMod and frame.baseSkillMod.currentValue or 0
    recipeData.professionStatModifiers.skill:addValue(skillMod)

    -- update other stats
    local multicraftMod = 0
    if recipeData.supportsMulticraft then
        multicraftMod = frame.multicraftMod and frame.multicraftMod.currentValue or 0
        recipeData.professionStatModifiers.multicraft:addValue(multicraftMod)
    end

    local resourcefulnessMod = 0
    if recipeData.supportsResourcefulness then
        resourcefulnessMod = frame.resourcefulnessMod and
            frame.resourcefulnessMod.currentValue or 0
        recipeData.professionStatModifiers.resourcefulness:addValue(resourcefulnessMod)
    end

    local ingenuityMod = 0
    if recipeData.supportsIngenuity then
        ingenuityMod = frame.ingenuityMod and frame.ingenuityMod.currentValue or 0
        recipeData.professionStatModifiers.ingenuity:addValue(ingenuityMod)
    end

    -- Save the raw user inputs so UpdateCraftingDetailsPanel can initialize the
    -- recreated modInput widgets with the correct (non-spec-diff-contaminated) values
    if self.userStatModifiers then
        self.userStatModifiers.recipeDifficulty = recipeDifficultyMod
        self.userStatModifiers.skill = skillMod
        self.userStatModifiers.multicraft = multicraftMod
        self.userStatModifiers.resourcefulness = resourcefulnessMod
        self.userStatModifiers.ingenuity = ingenuityMod
    end

    recipeData.concentrating = frame.content.detailsFrame.content.concentrationToggleButton.isOn
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE:UpdateRequiredReagentsByInputs(recipeData)
    Logger:LogVerbose("Update Reagent Input Frames:")

    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local frame = exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER and self.frameWO or self.frame

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
        local slot = optionalReagentItemSelector.slot
        if slot and optionalReagentItemSelector.isCurrencySlot and optionalReagentItemSelector.selectedCurrencyID then
            slot:SetCurrencyReagent(optionalReagentItemSelector.selectedCurrencyID)
        else
            local itemID = optionalReagentItemSelector.selectedItem and
                optionalReagentItemSelector.selectedItem:GetItemID()
            if itemID then
                -- try to set required selectable if available else put to optional/finishing
                if slot == recipeData.reagentData.requiredSelectableReagentSlot or
                    tContains(possibleRequiredSelectableItemIDs, itemID) then
                    recipeData.reagentData.requiredSelectableReagentSlot:SetReagent(itemID)
                else
                    table.insert(itemIDs, itemID)
                end
            end
        end
    end

    recipeData:SetOptionalReagents(itemIDs)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE:UpdateRecipeDataBuffsBySimulatedBuffs(recipeData)
    local craftBuffsFrame = CraftSim.UTIL:IsWorkOrder() and CraftSim.CRAFT_BUFFS.frameWO or CraftSim.CRAFT_BUFFS.frame

    -- local simulateBuffSelector = craftBuffsFrame.content.simulateBuffSelector

    -- recipeData.buffData:SetBuffsByUIDToValueMap(simulateBuffSelector.savedVariablesTable)
    -- recipeData.buffData:UpdateProfessionStats()
end

function CraftSim.SIMULATION_MODE:UpdateSimulationModeRecipeData()
    local recipeData = self.recipeData
    if not recipeData then
        Logger:LogFatal("Cannot update simulation mode recipe data: no recipe data set")
        return
    end
    self:UpdateRecipeDataBuffsBySimulatedBuffs(recipeData)
    self:UpdateRequiredReagentsByInputs(recipeData)
    self:UpdateProfessionStatModifiersByInputs(recipeData)
    recipeData:Update() -- update recipe Data by modifiers/reagents and such

    if self.specializationData then
        -- Keep the base recipeData specialization intact for stat-diff math above.
        -- After the update math is done, expose simulated specialization data to listeners/UI.
        recipeData.specializationData = self.specializationData:Copy()
    end

    GUTIL:TriggerCustomEvent("CRAFTSIM_RECIPE_DATA_MODIFIED", recipeData)
end

function CraftSim.SIMULATION_MODE:InitializeSimulation(recipeData)
    self.originalRecipeData = recipeData:Copy()
    self.recipeData = recipeData:Copy()

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

    self:InitializeReagentList()

    local UI = self.UI --[[@as CraftSim.SIMULATION_MODE.UI]]
    UI:InitOptionalReagentItemSelectors(self.recipeData)
    UI:Update()
    self:UpdateSimulationModeRecipeData()
end

--- used by allocate button in reagent optimization module
---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE:AllocateReagents(recipeData)
    if not self.isActive then return end
    if not self.recipeData then return end

    if self.recipeData.recipeID ~= recipeData.recipeID then
        return
    end

    -- set simulation reagents to recipeData reagents
    self.recipeData:SetReagentsByCraftingReagentInfoTbl(recipeData.reagentData
        :GetCraftingReagentInfoTbl())
    self:InitializeReagentList()
    self:UpdateSimulationModeRecipeData()
end

--- Overhaul

function CraftSim.SIMULATION_MODE:InitializeReagentList()
    local recipeData = self.recipeData
    if not recipeData then return end
    local content
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        content = self.frameWO.content
    else
        content = self.frame.content
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

        local newMax = math.max(requiredQuantity - (q1Input.currentValue + q2Input.currentValue + q3Input.currentValue),
            0)
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
        GUTIL:TriggerCustomEvent("CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED")
    end
end

function CraftSim.SIMULATION_MODE:CRAFTSIM_SIMULATION_MODE_ENABLED()
    local recipeData = CraftSim.MODULES.recipeData

    if not recipeData then
        Logger:LogError("Cannot Enable Simulation Mode: No recipe data available")
        return
    end

    if recipeData.isSalvageRecipe or recipeData.recipeInfo.isRecraft then
        Logger:LogWarning("Cannot Enable Simulation Mode: Salvage and Recraft recipes are not supported")
        return
    end

    self:InitializeSimulation(recipeData)
end

function CraftSim.SIMULATION_MODE:CRAFTSIM_SIMULATION_MODE_DISABLED()
    self.recipeData = nil
    self.originalRecipeData = nil
    self.specializationData = nil
    self.userStatModifiers = nil
    self.isActive = false

    if self.frame then
        self.frame:Hide()
        self.frameWO:Hide()
    end

    -- reset buffs simulate selector
    --CraftSim.CRAFT_BUFFS.frame.content.simulateBuffSelector:SetSavedVariablesTable({})

    -- rebuild recipeData from default ui and fire initialized event
    local recipeData = CraftSim.MODULES:GetRecipeDataFromVisibleRecipe()

    if recipeData then
        GUTIL:TriggerCustomEvent("CRAFTSIM_RECIPE_DATA_UPDATED", recipeData)
    else
        Logger:LogWarning("No recipe data found to re-initialize after disabling simulation mode")
    end
end

function CraftSim.SIMULATION_MODE:CRAFTSIM_SIMULATION_MODE_ALLOCATION_CHANGED()
    self:UpdateSimulationModeRecipeData()
end

function CraftSim.SIMULATION_MODE:CRAFTSIM_RECIPE_DATA_UPDATED(recipeData)
    if not self.isActive then return end
    if not self.recipeData then return end

    if self.recipeData.recipeID ~= recipeData.recipeID then
        return
    end

    local UI = self.UI --[[@as CraftSim.SIMULATION_MODE.UI]]
    UI:UpdateCraftingDetailsPanel()
end
