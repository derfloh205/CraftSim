_, CraftSim = ...

---@class CraftSim.RecipeData
---@field recipeID number 
---@field categoryID number
---@field subtypeID number
---@field recipeType number
---@field learned boolean
---@field numSkillUps? number
---@field recipeIcon? string
---@field recipeName? string
---@field isSimulationModeData boolean
---@field hasQualityReagents boolean
---@field supportsQualities boolean
---@field supportsCraftingStats boolean
---@field supportsInspiration boolean
---@field supportsMulticraft boolean
---@field supportsResourcefulness boolean
---@field supportsCraftingspeed boolean
---@field isGear boolean
---@field isSoulbound boolean
---@field isEnchantingRecipe boolean
---@field isSalvageRecipe boolean
---@field isCooking boolean
---@field isOldWorldRecipe boolean
---@field baseItemAmount number
---@field maxQuality number
---@field allocationItemGUID? string
---@field professionData CraftSim.ProfessionData
---@field reagentData CraftSim.ReagentData
---@field specializationData CraftSim.SpecializationData
---@field buffData CraftSim.BuffData
---@field professionGearSet CraftSim.ProfessionGearSet
---@field professionStats CraftSim.ProfessionStats The ProfessionStats of that recipe considering gear, reagents, buffs.. etc
---@field baseProfessionStats CraftSim.ProfessionStats The ProfessionStats of that recipe without gear or reagents
---@field professionStatModifiers CraftSim.ProfessionStats Will add/subtract to final stats (Used in Simulation Mode, usually 0)
---@field priceData CraftSim.PriceData
---@field resultData CraftSim.ResultData
---@field orderData CraftingOrderInfo

CraftSim.RecipeData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@param recipeID number
---@param isRecraft? boolean
---@param isWorkOrder? boolean
---@return CraftSim.RecipeData?
function CraftSim.RecipeData:new(recipeID, isRecraft, isWorkOrder)
    self.professionData = CraftSim.ProfessionData(recipeID)

    if isWorkOrder then
        self.orderData = ProfessionsFrame.OrdersPage.OrderView.order

        print("Craft Order Data:")
        print(self.orderData, true)
    end

    if not self.professionData.isLoaded then
        print("Could not create recipeData: professionData not loaded")
        return nil
    end

    
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
    
	if not recipeInfo then
		print("Could not create recipeData: recipeInfo nil")
		return nil
	end
    
    self.recipeID = recipeID
    self.categoryID = recipeInfo.categoryID

    if recipeInfo.hyperlink then
        local subclassID = select(7, GetItemInfoInstant(recipeInfo.hyperlink))
        self.subtypeID = subclassID
    end

    

---@diagnostic disable-next-line: missing-parameter
    local recipeCategoryInfo = C_TradeSkillUI.GetCategoryInfo(recipeInfo.categoryID)
    self.isOldWorldRecipe = not tContains(CraftSim.CONST.DRAGON_ISLES_CATEGORY_IDS, recipeCategoryInfo.parentCategoryID)
    self.isRecraft = isRecraft or false
    self.isSimulationModeData = false
    self.recipeType = CraftSim.UTIL:GetRecipeType(recipeInfo) -- TODO: remove
    self.learned = recipeInfo.learned or false
	self.numSkillUps = recipeInfo.numSkillUps
	self.recipeIcon = recipeInfo.icon
	self.recipeName = recipeInfo.name
	self.supportsQualities = recipeInfo.supportsQualities or false
	self.supportsCraftingStats = recipeInfo.supportsCraftingStats or false
    self.isEnchantingRecipe = recipeInfo.isEnchantingRecipe or false
    self.isCooking = self.professionData.professionInfo.profession == Enum.Profession.Cooking
    self.isSalvageRecipe = recipeInfo.isSalvageRecipe or false
    self.allocationItemGUID = nil
    self.maxQuality = recipeInfo.maxQuality
    self.isGear = recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil

    self.supportsInspiration = false
    self.supportsMulticraft = false
    self.supportsResourcefulness = false
    self.supportsCraftingspeed = true -- this is always supported (but does not show in details UI when 0)

    -- fetch possible required/optional/finishing reagents, if possible categorize by quality?

    if not self.isCooking then
        self.specializationData = CraftSim.SpecializationData(self)
    end

    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(self.recipeID, self.isRecraft)
    if not schematicInfo then
        print("No RecipeData created: SchematicInfo not found")
        return
    end
    self.buffData = CraftSim.BuffData()
    self.buffData:Update()
    self.reagentData = CraftSim.ReagentData(self, schematicInfo)

    local qualityReagents = CraftSim.UTIL:Count(self.reagentData.requiredReagents, function (reagent)
        return reagent.hasQuality
    end)

    self.hasQualityReagents = qualityReagents > 0

    self.baseItemAmount = (schematicInfo.quantityMin + schematicInfo.quantityMax) / 2
    self.isSoulbound = (schematicInfo.outputItemID and CraftSim.UTIL:isItemSoulbound(schematicInfo.outputItemID)) or false

    self.professionGearSet = CraftSim.ProfessionGearSet(self.professionData.professionInfo.profession)
    
    local baseOperationInfo = nil
    if self.orderData then
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(self.recipeID, {}, self.orderData.orderID)
    else
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, {}, self.allocationItemGUID)
    end
    
    self.baseProfessionStats = CraftSim.ProfessionStats()
    self.professionStats = CraftSim.ProfessionStats()
    self.professionStatModifiers = CraftSim.ProfessionStats()
    
    self.baseProfessionStats:SetStatsByOperationInfo(self, baseOperationInfo)

    self.baseProfessionStats:SetInspirationBaseBonusSkill(self.baseProfessionStats.recipeDifficulty.value, self.maxQuality)

    -- subtract stats from current set to get base stats
    local equippedProfessionGearSet = CraftSim.ProfessionGearSet(self.professionData.professionInfo.profession)
    equippedProfessionGearSet:LoadCurrentEquippedSet()
    
    self.baseProfessionStats:subtract(equippedProfessionGearSet.professionStats)
    self.baseProfessionStats:subtract(self.buffData.professionStats)
    -- As we dont know in this case what the factors are without gear and reagents and such
    -- we set them to 0 and let them accumulate in UpdateProfessionStats
    self.baseProfessionStats:ClearFactors()

    self:UpdateProfessionStats()
    
    self.resultData = CraftSim.ResultData(self)
    self.resultData:Update()

    self.priceData = CraftSim.PriceData(self)
    self.priceData:Update()
end

---@param reagentList CraftSim.ReagentListItem[]
function CraftSim.RecipeData:SetReagents(reagentList)
    -- go through required reagents and set quantity accordingly

    for _, reagent in pairs(self.reagentData.requiredReagents) do
        local totalQuantity = 0
        for _, reagentItem in pairs(reagent.items) do
            local listReagent = CraftSim.UTIL:Find(reagentList, function(listReagent) return listReagent.itemID == reagentItem.item:GetItemID() end)
            if listReagent then
                reagentItem.quantity = listReagent.quantity
                totalQuantity = totalQuantity + listReagent.quantity
            end
        end
        if totalQuantity > reagent.requiredQuantity then
            error("CraftSim: RecipeData SetReagents Error: total set quantity > requiredQuantity -> " .. totalQuantity .. " / " .. reagent.requiredQuantity)
        end
    end
end

---@param itemID number
function CraftSim.RecipeData:SetSalvageItem(itemID)
    if self.isSalvageRecipe then
        self.reagentData.salvageReagentSlot:SetItem(itemID)
    else
        error("CraftSim Error: Trying to set salvage item on non salvage recipe")
    end
end

function CraftSim.RecipeData:SetEquippedProfessionGearSet()
    self.professionGearSet:LoadCurrentEquippedSet()
    self:Update()
end

function CraftSim.RecipeData:SetAllReagentsBySchematicForm()
    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(self.recipeID, self.isRecraft)
    local schematicForm = CraftSim.UTIL:GetSchematicFormByVisibility()

    if not schematicForm then
        return
    end
    
    local reagentSlots = schematicForm.reagentSlots
    local currentTransaction = schematicForm:GetTransaction()

    if self.isRecraft then
        self.allocationItemGUID = currentTransaction:GetRecraftAllocation()
    end

    if self.isSalvageRecipe then
        local salvageAllocation = currentTransaction:GetSalvageAllocation()
		if salvageAllocation and schematicForm.salvageSlot then
            self.reagentData.salvageReagentSlot:SetItem(salvageAllocation:GetItemID())
            self.reagentData.salvageReagentSlot.requiredQuantity = schematicForm.salvageSlot.quantityRequired
        elseif not schematicForm.salvageSlot then
            error("CraftSim RecipeData Error: Salvage Recipe without salvageSlot")
        end
    end

    local currentOptionalReagent = 1
	local currentFinishingReagent = 1

    for slotIndex, currentSlot in pairs(schematicInfo.reagentSlotSchematics) do
        local reagentType = currentSlot.reagentType
        if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
            local slotAllocations = currentTransaction:GetAllocations(slotIndex)
            
            for i, reagent in pairs(currentSlot.reagents) do
                local reagentAllocation = (slotAllocations and slotAllocations:FindAllocationByReagent(reagent)) or nil
                local allocations = 0
                if reagentAllocation ~= nil then
                    allocations = reagentAllocation:GetQuantity()
                end
                local craftSimReagentItem = nil
                for _, craftSimReagent in pairs(self.reagentData.requiredReagents) do
                    craftSimReagentItem = CraftSim.UTIL:Find(craftSimReagent.items, function(cr) return cr.item:GetItemID() == reagent.itemID end)
                    if craftSimReagentItem then
                        break
                    end
                end
                if not craftSimReagentItem then
                    error("Error: Open Recipe Reagent not included in recipeData")
                end
                craftSimReagentItem.quantity = allocations
            end
            
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL then
            if reagentSlots[reagentType] ~= nil then
                local optionalSlots = reagentSlots[reagentType][currentOptionalReagent]
                if not optionalSlots then
                    return
                end
                local button = optionalSlots.Button
                local allocatedItemID = button:GetItemID()
                if allocatedItemID then
                    self:SetOptionalReagent(allocatedItemID)
                end
                
                currentOptionalReagent = currentOptionalReagent + 1
            end

        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT then
            if reagentSlots[reagentType] ~= nil then
                local optionalSlots = reagentSlots[reagentType][currentFinishingReagent]
                if not optionalSlots then
                    return
                end
                local button = optionalSlots.Button
                local allocatedItemID = button:GetItemID()
                if allocatedItemID then
                    self:SetOptionalReagent(allocatedItemID)
                end
                
                currentFinishingReagent = currentFinishingReagent + 1
            end
        end
    end
end

---@param itemID number
function CraftSim.RecipeData:SetOptionalReagent(itemID)
    self.reagentData:SetOptionalReagent(itemID)
end

---@param itemIDList number[]
function CraftSim.RecipeData:SetOptionalReagents(itemIDList)
    table.foreach(itemIDList, function (_, itemID)
        self:SetOptionalReagent(itemID)
    end)
    self:Update()
end

-- Update the professionStats property of the RecipeData according to set reagents and gearSet (and any stat modifiers)
function CraftSim.RecipeData:UpdateProfessionStats()
    local skillRequiredReagents = self.reagentData:GetSkillFromRequiredReagents()
    local optionalStats = self.reagentData:GetProfessionStatsByOptionals()
    local itemStats = self.professionGearSet.professionStats
    local buffStats = self.buffData.professionStats
    
    self.professionStats:Clear()

    -- Dont forget to set this.. cause it is ignored by add/subtract
    self.professionStats:SetInspirationBaseBonusSkill(self.baseProfessionStats.recipeDifficulty.value, self.maxQuality)

    self.professionStats:add(self.baseProfessionStats)

    self.professionStats:add(buffStats)

    self.professionStats.skill:addValue(skillRequiredReagents)

    self.professionStats:add(optionalStats)

    self.professionStats:add(itemStats)

    if not self.isCooking then
        local specExtraFactors = self.specializationData:GetExtraFactors()
        self.professionStats:add(specExtraFactors)
    end

    -- finally add any custom modifiers
    self.professionStats:add(self.professionStatModifiers)
    -- its the only one which uses "extraValueAfterFactor"
end

--- Updates professionStats based on reagentData and professionGearSet -> Then updates resultData based on professionStats -> Then updates priceData based on resultData
function CraftSim.RecipeData:Update()
    self:UpdateProfessionStats()
    self.resultData:Update()
    self.priceData:Update()
end

--- We need copy constructors or CopyTable will run into references of recipeData
---@return CraftSim.RecipeData recipeDataCopy
function CraftSim.RecipeData:Copy()
    local copy = CraftSim.RecipeData(self.recipeID, self.isRecraft)
    copy.reagentData = self.reagentData:Copy(copy)
    copy.professionGearSet = self.professionGearSet:Copy()
    copy.professionStats = self.professionStats:Copy()
    copy.baseProfessionStats = self.baseProfessionStats:Copy()
    copy.professionStatModifiers = self.professionStatModifiers:Copy()
    copy.priceData = self.priceData:Copy(copy) -- Is this needed or covered by constructor?
    copy.resultData = self.resultData:Copy(copy) -- Is this needed or covered by constructor?
    -- copy spec data or already handled in constructor?

    copy:Update()
    return copy
end

--- Optimizes the recipeData's reagents for highest quality / cheapest reagents.
---@param optimizeInspiration boolean
function CraftSim.RecipeData:OptimizeReagents(optimizeInspiration)
    local optimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(self, optimizeInspiration)
    self.reagentData:SetReagentsByOptimizationResult(optimizationResult)
    self:Update() -- TODO: only update if reagents have changed
end

---Optimizes the recipeData's professionGearSet by the given mode.
---@param topGearMode string
function CraftSim.RecipeData:OptimizeGear(topGearMode)
    local optimizedGear = CraftSim.TOPGEAR:OptimizeTopGear(self, topGearMode)
    local bestResult = optimizedGear[1]
    if bestResult then
        if not bestResult.professionGearSet:Equals(self.professionGearSet) then
            self.professionGearSet = bestResult.professionGearSet
            self:Update()
        end
    end
end

---Returns the average profit and the probability table of the recipe. Make sure the recipeData's results are updated beforehand
---@return number averageProfit
---@return table probabilityTable
function CraftSim.RecipeData:GetAverageProfit()
    local averageProfit, probabilityTable = CraftSim.CALC:GetAverageProfit(self)
    return averageProfit, probabilityTable
end

---Optimizes the recipeData's reagents and gear for highest profit
---@param optimizeInspiration boolean
function CraftSim.RecipeData:OptimizeProfit(optimizeInspiration)
    self:OptimizeReagents(optimizeInspiration)
    self:OptimizeGear(CraftSim.CONST.GEAR_SIM_MODES.PROFIT)
    -- need another because it could be that the optimized gear makes it possible to use cheaper reagents
    self:OptimizeReagents(optimizeInspiration) 
end

---Optimizes the recipeData's reagents and gear for highest quality
---@param optimizeInspiration boolean
function CraftSim.RecipeData:OptimizeQuality(optimizeInspiration)
    self:OptimizeGear(CraftSim.CONST.GEAR_SIM_MODES.SKILL)
    self:OptimizeReagents(optimizeInspiration)
end

function CraftSim.RecipeData:GetJSON(indent)
    indent = indent or 0

    local jb = CraftSim.JSONBuilder(indent)

    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("categoryID", self.categoryID)
    jb:Add("subtypeID", self.subtypeID)
    jb:Add("learned", self.learned)
    jb:Add("numSkillUps", self.numSkillUps)
    jb:Add("recipeIcon", self.recipeIcon)
    jb:Add("recipeName", self.recipeName)
    jb:Add("isSimulationModeData", self.isSimulationModeData)
    jb:Add("hasQualityReagents", self.hasQualityReagents)
    jb:Add("supportsQualities", self.supportsQualities)
    jb:Add("supportsCraftingStats", self.supportsCraftingStats)
    jb:Add("supportsInspiration", self.supportsInspiration)
    jb:Add("supportsMulticraft", self.supportsMulticraft)
    jb:Add("supportsResourcefulness", self.supportsResourcefulness)
    jb:Add("supportsCraftingspeed", self.supportsCraftingspeed)
    jb:Add("isGear", self.isGear)
    jb:Add("isSoulbound", self.isSoulbound)
    jb:Add("isEnchantingRecipe", self.isEnchantingRecipe)
    jb:Add("isSalvageRecipe", self.isSalvageRecipe)
    jb:Add("isCooking", self.isCooking)
    jb:Add("isOldWorldRecipe", self.isOldWorldRecipe)
    jb:Add("baseItemAmount", self.baseItemAmount)
    jb:Add("maxQuality", self.maxQuality)
    jb:Add("allocationItemGUID", self.allocationItemGUID)
    jb:Add("professionData", self.professionData)
    jb:Add("reagentData", self.reagentData)
    jb:Add("specializationData", self.specializationData)
    jb:Add("buffData", self.buffData)
    jb:Add("professionGearSet", self.professionGearSet)
    jb:Add("professionStats", self.professionStats)
    jb:Add("baseProfessionStats", self.baseProfessionStats)
    jb:Add("professionStatModifiers", self.professionStatModifiers)
    jb:Add("priceData", self.priceData)
    jb:Add("resultData", self.resultData)
    jb:Add("orderData", self.orderData, true)
    jb:End()

    return jb.json
end