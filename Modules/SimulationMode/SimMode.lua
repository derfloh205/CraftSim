AddonName, CraftSim = ...

CraftSim.SIMULATION_MODE = {}

CraftSim.SIMULATION_MODE.isActive = false
CraftSim.SIMULATION_MODE.reagentOverwriteFrame = nil
CraftSim.SIMULATION_MODE.craftingDetailsFrame = nil
CraftSim.SIMULATION_MODE.recipeData = nil
CraftSim.SIMULATION_MODE.baseSpecNodeData = nil
CraftSim.SIMULATION_MODE.reagentSkillIncrease = nil

CraftSim.SIMULATION_MODE.baseInspiration = nil
CraftSim.SIMULATION_MODE.baseMulticraft = nil
CraftSim.SIMULATION_MODE.baseResourcefulness = nil

CraftSim.SIMULATION_MODE.baseSkillNoReagentsOrOptionalReagents = nil

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.SIMULATION_MODE, recursive, l)
    else
        print(text)
    end
end

function CraftSim.SIMULATION_MODE:OnSpecModified(userInput, nodeModFrame)
    if not userInput or not CraftSim.SIMULATION_MODE.recipeData then
        return
    end
    print("assigned node: " .. tostring(nodeModFrame.nodeID))
    print("max value: " .. tostring(nodeModFrame.nodeProgressBar.maxValue))
    
    local inputNumber = CraftSim.UTIL:ValidateNumberInput(nodeModFrame.input, true)

    if inputNumber > nodeModFrame.nodeProgressBar.maxValue then
        inputNumber = nodeModFrame.nodeProgressBar.maxValue
    elseif inputNumber < -1 then
        inputNumber = -1
    end
    print("inputNumber: " .. inputNumber)
    nodeModFrame.Update(inputNumber)

    -- update specdata
    local nodeInSpecData = CraftSim.UTIL:Find(CraftSim.SIMULATION_MODE.recipeData.specNodeData, function(nodeData) return nodeData.nodeID == nodeModFrame.nodeID end)
 
    nodeInSpecData.activeRank = inputNumber + 1

    print("new spec data node:")
    print(nodeInSpecData, true)

    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:ResetSpecData()
    CraftSim.SIMULATION_MODE.recipeData.specNodeData = CopyTable(CraftSim.SIMULATION_MODE.baseSpecNodeData)

    local specModFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM)
    for _, activeNodeModFrame in pairs(specModFrame.content.activeNodeModFrames) do
        local nodeData = CraftSim.UTIL:Find(CraftSim.SIMULATION_MODE.recipeData.specNodeData, function(entry) return activeNodeModFrame.nodeID == entry.nodeID end)
        activeNodeModFrame.Update(nodeData.activeRank - 1)
    end

    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:OnInputAllocationChanged(userInput)
    if not userInput or not CraftSim.SIMULATION_MODE.recipeData then
        return
    end
    local inputBox = self
    local reagentData = CraftSim.SIMULATION_MODE.recipeData.reagents[inputBox.reagentIndex]

    local inputNumber = CraftSim.UTIL:ValidateNumberInput(inputBox)
    inputBox.currentAllocation = inputNumber

    local totalAllocations = CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq1)
    local totalAllocations = totalAllocations + CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq2)
    local totalAllocations = totalAllocations + CraftSim.UTIL:ValidateNumberInput(inputBox:GetParent().inputq3)

    -- if the total sum would be higher than the required quantity, force the smallest number to get the highest quantity
    if totalAllocations > reagentData.requiredQuantity then
        local otherAllocations = totalAllocations - inputNumber
        inputNumber = reagentData.requiredQuantity - otherAllocations
        inputBox:SetText(inputNumber)
    end
    --reagentData.itemsInfo[inputBox.qualityID].allocations = tonumber(inputNumber)

    CraftSim.SIMULATION_MODE:UpdateSimulationMode()
    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:AllocateAllByQuality(qualityID)
    for _, currentInput in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
        local reagentIndex = currentInput.inputq1.reagentIndex
        local reagentData = CraftSim.SIMULATION_MODE.recipeData.reagents[reagentIndex]

        if currentInput.isActive and reagentData.differentQualities then
            for i = 1, 3, 1 do
                local allocationForQuality = 0
                if i == qualityID then 
                    allocationForQuality = reagentData.requiredQuantity
                elseif qualityID == 0 then
                    allocationForQuality = 0
                end

                reagentData.itemsInfo[i].allocations = allocationForQuality
                currentInput["inputq" .. i]:SetText(allocationForQuality)
            end
        end
    end

    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
    if not userInput then
        return
    end
    --print("stat mod changed: " .. self.stat)
    CraftSim.SIMULATION_MODE:UpdateSimulationMode()
    CraftSim.MAIN:TriggerModulesErrorSafe()
end

function CraftSim.SIMULATION_MODE:UpdateReagentAllocationsByInput()
    -- should not happen but nil check anyway
    if not CraftSim.SIMULATION_MODE.recipeData then
        return
    end
    print("Update Reagent Input Frames:")
    print("reagents:")
    for reagentIndex, reagentData in pairs(CraftSim.SIMULATION_MODE.recipeData.reagents) do
        print(reagentIndex .. " -> " .. tostring(reagentData.name))
    end
    -- update item allocations based on inputfields
    for i, overwriteInput in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.reagentOverwriteInputs) do
        if overwriteInput.isActive then
            local reagentIndex = overwriteInput.inputq1.reagentIndex
            print("- Set reagentInput #" .. tostring(i))
            print("- Access reagent #: " .. tostring(reagentIndex))
            local reagentData = CraftSim.SIMULATION_MODE.recipeData.reagents[reagentIndex]


            reagentData.itemsInfo[1].allocations = overwriteInput.inputq1:GetNumber()
            if reagentData.differentQualities then
                reagentData.itemsInfo[2].allocations = overwriteInput.inputq2:GetNumber()
                reagentData.itemsInfo[3].allocations = overwriteInput.inputq3:GetNumber()
            end
        end
    end
end

function CraftSim.SIMULATION_MODE:GetStatsFromOptionalReagents()
    local stats = {	
		recipeDifficulty = 0,
        inspiration = 0,
        inspirationBonusSkillFactor = 1,
        multicraft = 0,
        multicraftExtraItemsFactor = 1,
        resourcefulness = 0,
        resourcefulnessExtraItemsFactor = 1,
        craftingspeed = 0,
		craftingspeedBonusFactor = 1,
        skill = 0
    } 

    for _, dropdown in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames) do
        local itemStats = CraftSim.OPTIONAL_REAGENT_DATA[dropdown.selectedItemID]
        if itemStats then
            for statName, _ in pairs(stats) do
                if itemStats[statName] then
                    stats[statName] = stats[statName] + itemStats[statName]
                end
            end
        end
    end

    return stats
end

function CraftSim.SIMULATION_MODE:UpdateSimModeRecipeDataByInputs()
    local statsByOptionalInputs = CraftSim.SIMULATION_MODE:GetStatsFromOptionalReagents()
    local specNodeStats = nil
    if CraftSim.SIMULATION_MODE.recipeData.specNodeData then
        local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[CraftSim.SIMULATION_MODE.recipeData.professionID]
        specNodeStats = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(CraftSim.SIMULATION_MODE.recipeData, ruleNodes)
    end

    print("SimModeStatsByOptionals: ")
    print(statsByOptionalInputs)

    -- update reagent skill increase by material allocation
    local reagentSkillIncrease = CraftSim.REAGENT_OPTIMIZATION:GetCurrentReagentAllocationSkillIncrease(CraftSim.SIMULATION_MODE.recipeData)
    CraftSim.SIMULATION_MODE.reagentSkillIncrease = reagentSkillIncrease

    -- update skill by input modifier and reagent skill increase
    local skillMod = CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeSkillModInput, true)
    CraftSim.SIMULATION_MODE.recipeData.stats.skill = CraftSim.SIMULATION_MODE.baseSkillNoReagentsOrOptionalReagents + reagentSkillIncrease + skillMod + statsByOptionalInputs.skill + (specNodeStats and specNodeStats.skill or 0)
    CraftSim.SIMULATION_MODE.recipeData.stats.skillNoReagents = CraftSim.SIMULATION_MODE.baseSkillNoReagentsOrOptionalReagents + skillMod + statsByOptionalInputs.skill + (specNodeStats and specNodeStats.skill or 0)

    -- update difficulty based on input
    local recipeDifficultyMod = CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeRecipeDifficultyModInput, true)
    CraftSim.SIMULATION_MODE.recipeData.recipeDifficulty = CraftSim.SIMULATION_MODE.baseRecipeDifficulty + recipeDifficultyMod + statsByOptionalInputs.recipeDifficulty

    -- update other stats
    if CraftSim.SIMULATION_MODE.recipeData.stats.inspiration then
        local inspirationMod = CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeInspirationModInput, true)
        local inspirationSkillMod = CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeInspirationSkillModInput, true)
        local inspirationBonusSkillFactor = statsByOptionalInputs.inspirationBonusSkillFactor % 1
        local specNodeBonusSkillFactor = (specNodeStats and (specNodeStats.inspirationBonusSkillFactor % 1)) or 0
        CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.value = CraftSim.SIMULATION_MODE.baseInspiration.value + inspirationMod + statsByOptionalInputs.inspiration + (specNodeStats and specNodeStats.inspiration or 0)
        print("bonusskillfactornospecs: " .. CraftSim.SIMULATION_MODE.baseInspiration.bonusSkillFactorNoSpecs)
        print("inspirationBonusSkillFactorReagents: " .. inspirationBonusSkillFactor)
        CraftSim.SIMULATION_MODE.recipeData.stats.inspirationBonusSkillFactor =  CraftSim.SIMULATION_MODE.baseInspiration.bonusSkillFactorNoSpecs + inspirationBonusSkillFactor + specNodeBonusSkillFactor
        CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.percent = (CraftSim.UTIL:GetInspirationPercentByStat(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.value) * 100)
        if CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.percent > 100 then
            -- More than 100 is not possible and it does not make sense in the calculation and would inflate the worth
            CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.percent = 100
        end

        CraftSim.SIMULATION_MODE.recipeData.stats.inspiration.bonusskill =
         (CraftSim.SIMULATION_MODE.baseInspiration.baseBonusSkill * (1+CraftSim.SIMULATION_MODE.recipeData.stats.inspirationBonusSkillFactor)) + inspirationSkillMod
        print("BaseBonusSkill: " .. tostring(CraftSim.SIMULATION_MODE.baseInspiration.baseBonusSkill))
        print("bonusskillfactor: " .. tostring(CraftSim.SIMULATION_MODE.recipeData.stats.inspirationBonusSkillFactor))
    end

    if CraftSim.SIMULATION_MODE.recipeData.stats.multicraft then
        local multicraftMod = CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeMulticraftModInput, true)
        CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.value = CraftSim.SIMULATION_MODE.baseMulticraft.value + multicraftMod + statsByOptionalInputs.multicraft + (specNodeStats and specNodeStats.multicraft or 0)
        CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.percent = CraftSim.UTIL:GetMulticraftPercentByStat(CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.value) * 100
        if CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.percent > 100 then
            -- More than 100 is not possible and it does not make sense in the calculation and would inflate the worth
            CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.percent = 100
        end
        CraftSim.SIMULATION_MODE.recipeData.stats.multicraft.bonusItemsFactor = CraftSim.SIMULATION_MODE.baseMulticraft.bonusItemsFactorNoSpecs + (specNodeStats and (specNodeStats.multicraftExtraItemsFactor % 1) or 0)
    end
    
    if CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness then
        local resourcefulnessMod = CraftSim.UTIL:ValidateNumberInput(CraftSimSimModeResourcefulnessModInput, true)
        CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.value = CraftSim.SIMULATION_MODE.baseResourcefulness.value + resourcefulnessMod + statsByOptionalInputs.resourcefulness + (specNodeStats and specNodeStats.resourcefulness or 0)
        CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.percent = CraftSim.UTIL:GetResourcefulnessPercentByStat(CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.value) * 100
        if CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.percent > 100 then
            -- More than 100 is not possible and it does not make sense in the calculation and would inflate the worth
            CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.percent = 100
        end
        CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness.bonusItemsFactor = CraftSim.SIMULATION_MODE.baseResourcefulness.bonusItemsFactorNoSpecs + (specNodeStats and (specNodeStats.resourcefulnessExtraItemsFactor % 1) or 0)
    end

    -- adjust expected quality by skill if quality recipe
    if not CraftSim.SIMULATION_MODE.recipeData.result.isNoQuality then
        CraftSim.SIMULATION_MODE.recipeData.expectedQuality = CraftSim.AVERAGEPROFIT:GetExpectedQualityBySkill(CraftSim.SIMULATION_MODE.recipeData, CraftSim.SIMULATION_MODE.recipeData.stats.skill, CraftSimOptions.breakPointOffset)
    end
end

function CraftSim.SIMULATION_MODE:UpdateSimulationMode()
    CraftSim.SIMULATION_MODE:UpdateReagentAllocationsByInput()
    CraftSim.SIMULATION_MODE:UpdateSimModeRecipeDataByInputs()
    CraftSim.SIMULATION_MODE:UpdateGearResultItemsByInputs()
    CraftSim.SIMULATION_MODE.FRAMES:UpdateCraftingDetailsPanel()
end

function CraftSim.SIMULATION_MODE:UpdateGearResultItemsByInputs()
    local recipeType = CraftSim.SIMULATION_MODE.recipeData.recipeType
    if recipeType == CraftSim.CONST.RECIPE_TYPES.GEAR or recipeType == CraftSim.CONST.RECIPE_TYPES.SOULBOUND_GEAR then
        -- add optional reagents to craftingreagentTbl
        local craftingReagentInfoTbl = {}
        for _, dropdown in pairs(CraftSim.SIMULATION_MODE.reagentOverwriteFrame.optionalReagentFrames) do
            local allocatedReagentID = dropdown.selectedItemID
            if allocatedReagentID then
                local optionalReagent = nil
                for slotIndex, reagentList in pairs(CraftSim.SIMULATION_MODE.recipeData.possibleOptionalReagents) do
                    optionalReagent = CraftSim.UTIL:Find(reagentList, function(reagent) return reagent.itemID == allocatedReagentID end)
                    if optionalReagent then break end;
                end
                local finishingReagent = nil
                for slotIndex, reagentList in pairs(CraftSim.SIMULATION_MODE.recipeData.possibleFinishingReagents) do
                    finishingReagent = CraftSim.UTIL:Find(reagentList, function(reagent) return reagent.itemID == allocatedReagentID end)
                    if finishingReagent then break end;
                end
                            
                local reagentData = optionalReagent or finishingReagent

                if reagentData then
                    table.insert(craftingReagentInfoTbl, {
                        itemID = reagentData.itemID,
                        quantity = 1,
                        dataSlotIndex = reagentData.dataSlotIndex
                    })
                else
                    error("CraftSim Error: Assigned Reagent not found in possible reagents list. What happened here?")
                end
            end
        end
        CraftSim.SIMULATION_MODE.recipeData.result.itemQualityLinks = CraftSim.DATAEXPORT:GetDifferentQualitiesByCraftingReagentTbl(
            CraftSim.SIMULATION_MODE.recipeData.recipeID, craftingReagentInfoTbl, CraftSim.SIMULATION_MODE.recipeData.allocationItemGUID)

        print("Sim Mode Quality Links: ")
        print(CraftSim.SIMULATION_MODE.recipeData.result.itemQualityLinks, true)
    end
end

function CraftSim.SIMULATION_MODE:InitializeSimulationMode(recipeData)
    CraftSim.SIMULATION_MODE.recipeData = CopyTable(recipeData)   

    CraftSim.SIMULATION_MODE.recipeData.isSimModeData = true
    local statsByOptionalInputs = CraftSim.DATAEXPORT:GetStatsFromOptionalReagents(recipeData)
    CraftSim.SIMULATION_MODE.baseSkillNoReagentsOrOptionalReagents = 0 -- to prevent nil errors

    

    -- initialize base values based on original recipeData and based on spec data implemented
    if not CraftSim.UTIL:IsSpecImplemented(recipeData.professionID) then
        CraftSim.SIMULATION_MODE.baseRecipeDifficulty = CraftSim.SIMULATION_MODE.recipeData.baseDifficulty
        
        if CraftSim.SIMULATION_MODE.recipeData.stats.inspiration then
            CraftSim.SIMULATION_MODE.baseInspiration = CopyTable(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
            CraftSim.SIMULATION_MODE.baseInspiration.value = CraftSim.SIMULATION_MODE.baseInspiration.value - statsByOptionalInputs.inspiration
            CraftSim.SIMULATION_MODE.baseInspiration.bonusSkillFactorNoSpecs = CraftSim.SIMULATION_MODE.baseInspiration.bonusSkillFactorNoSpecs - (statsByOptionalInputs.inspirationBonusSkillFactor % 1)

            CraftSim.SIMULATION_MODE.baseSkillNoReagentsOrOptionalReagents = CraftSim.SIMULATION_MODE.recipeData.stats.skillNoReagents - statsByOptionalInputs.skill
        end
        
        if CraftSim.SIMULATION_MODE.recipeData.stats.multicraft then
            CraftSim.SIMULATION_MODE.baseMulticraft = CopyTable(CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
            CraftSim.SIMULATION_MODE.baseMulticraft.value = CraftSim.SIMULATION_MODE.baseMulticraft.value - statsByOptionalInputs.multicraft
        end
        
        if CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness then
            CraftSim.SIMULATION_MODE.baseResourcefulness = CopyTable(CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
            CraftSim.SIMULATION_MODE.baseResourcefulness.value = CraftSim.SIMULATION_MODE.baseResourcefulness.value - statsByOptionalInputs.resourcefulness
        end
        -- crafting speed... for later profit per time interval?
    else
        CraftSim.SIMULATION_MODE.baseSpecNodeData = CopyTable(CraftSim.SIMULATION_MODE.recipeData.specNodeData) -- to make a reset possible
        print("copied specnode data: " .. tostring(CraftSim.SIMULATION_MODE.baseSpecNodeData))
        CraftSim.SIMULATION_MODE.baseRecipeDifficulty = CraftSim.SIMULATION_MODE.recipeData.baseDifficulty

        -- to subtract the incense buff inspiration if it exists
        local statsByBuffs = CraftSim.DATAEXPORT:GetStatsFromBuffs(recipeData.buffData)
        
        local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[CraftSim.SIMULATION_MODE.recipeData.professionID]

        -- need to deduct specnode stats, for later update by specnode stats
        local specNodeStats = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(CraftSim.SIMULATION_MODE.recipeData, ruleNodes)
        
        if CraftSim.SIMULATION_MODE.recipeData.stats.inspiration then
            CraftSim.SIMULATION_MODE.baseInspiration = CopyTable(CraftSim.SIMULATION_MODE.recipeData.stats.inspiration)
            CraftSim.SIMULATION_MODE.baseInspiration.value = CraftSim.SIMULATION_MODE.baseInspiration.value - statsByOptionalInputs.inspiration - specNodeStats.inspiration - statsByBuffs.inspiration
            --CraftSim.SIMULATION_MODE.baseInspiration.bonusSkillFactorNoSpecs = CraftSim.SIMULATION_MODE.baseInspiration.bonusSkillFactorNoSpecs
            CraftSim.SIMULATION_MODE.baseSkillNoReagentsOrOptionalReagents = CraftSim.SIMULATION_MODE.recipeData.stats.skillNoReagents - statsByOptionalInputs.skill - specNodeStats.skill
        end
        
        if CraftSim.SIMULATION_MODE.recipeData.stats.multicraft then
            CraftSim.SIMULATION_MODE.baseMulticraft = CopyTable(CraftSim.SIMULATION_MODE.recipeData.stats.multicraft)
            CraftSim.SIMULATION_MODE.baseMulticraft.value = CraftSim.SIMULATION_MODE.baseMulticraft.value - statsByOptionalInputs.multicraft - specNodeStats.multicraft
        end
        
        if CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness then
            CraftSim.SIMULATION_MODE.baseResourcefulness = CopyTable(CraftSim.SIMULATION_MODE.recipeData.stats.resourcefulness)
            CraftSim.SIMULATION_MODE.baseResourcefulness.value = CraftSim.SIMULATION_MODE.baseResourcefulness.value - statsByOptionalInputs.resourcefulness - specNodeStats.resourcefulness
        end
    end
    
    -- update frame visiblity and initialize the input fields
    CraftSim.SIMULATION_MODE.FRAMES:UpdateVisibility()
    CraftSim.SIMULATION_MODE.FRAMES:InitReagentOverwriteFrames()
    CraftSim.SIMULATION_MODE.FRAMES:InitOptionalReagentDropdowns()
    CraftSim.SIMULATION_MODE.FRAMES:InitSpecModBySpecData()

    -- update simulation recipe data and frontend
    CraftSim.SIMULATION_MODE:UpdateSimulationMode()

    -- recalculate modules
    CraftSim.MAIN:TriggerModulesErrorSafe()
end