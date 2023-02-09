_, CraftSim = ...

---@class CraftSim.RecipeData
---@field recipeID number 
---@field recipeType number
---@field learned boolean
---@field numSkillUps? number
---@field recipeIcon? string
---@field recipeName? string
---@field supportsQualities boolean
---@field supportsCraftingStats boolean
---@field supportsInspiration boolean
---@field supportsMulticraft boolean
---@field supportsResourcefulness boolean
---@field supportsCraftingspeed boolean
---@field isGear boolean
---@field isSoulbound boolean
---@field isEnchantingRecipe boolean
---@field baseItemAmount number
---@field maxQuality number
---@field allocationItemGUID? string
---@field professionData CraftSim.ProfessionData
---@field reagentData CraftSim.ReagentData
---@field professionGearSet CraftSim.ProfessionGearSet
---@field professionStats CraftSim.ProfessionStats The ProfessionStats of that recipe considering gear, reagents, buffs.. etc
---@field baseProfessionStats CraftSim.ProfessionStats The ProfessionStats of that recipe without gear or reagents
---@field resultData CraftSim.ResultData

CraftSim.RecipeData = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.EXPORT_V2)

---@return CraftSim.RecipeData?
function CraftSim.RecipeData:new(recipeID, isRecraft)
    self.professionData = CraftSim.ProfessionData(recipeID)

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
    self.isRecraft = isRecraft or false
    self.recipeType = CraftSim.UTIL:GetRecipeType(recipeInfo)
    self.learned = recipeInfo.learned or false
	self.numSkillUps = recipeInfo.numSkillUps
	self.recipeIcon = recipeInfo.icon
	self.recipeName = recipeInfo.name
	self.supportsQualities = recipeInfo.supportsQualities or false
	self.supportsCraftingStats = recipeInfo.supportsCraftingStats or false
    self.isEnchantingRecipe = recipeInfo.isEnchantingRecipe or false
    self.isSalvageRecipe = recipeInfo.isSalvageRecipe or false
    self.allocationItemGUID = nil
    self.maxQuality = recipeInfo.maxQuality
    self.isGear = recipeInfo.hasSingleItemOutput and recipeInfo.qualityIlvlBonuses ~= nil

    self.supportsInspiration = false
    self.supportsMulticraft = false
    self.supportsResourcefulness = false
    self.supportsCraftingspeed = true -- this is always supported (but does not show in details UI when 0)

    -- fetch possible required/optional/finishing reagents, if possible categorize by quality?

    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(self.recipeID, self.isRecraft)
    self.reagentData = CraftSim.ReagentData(self, schematicInfo)

    self.baseItemAmount = (schematicInfo.quantityMin + schematicInfo.quantityMax) / 2
    self.isSoulbound = CraftSim.UTIL:isItemSoulbound(schematicInfo.outputItemID)

    print("Set fresh reagentdata")
    print(self.reagentData)

    self.professionGearSet = CraftSim.ProfessionGearSet(self.professionData.professionInfo.profession)
    self.professionGearSet:LoadCurrentEquippedSet()

    local baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, {}, self.allocationItemGUID)

    self.baseProfessionStats = CraftSim.ProfessionStats()
    self.professionStats = CraftSim.ProfessionStats()

    self.baseProfessionStats:SetStatsByOperationInfo(self, baseOperationInfo)
    self.professionStats:SetStatsByOperationInfo(self, baseOperationInfo)

    self.baseProfessionStats:subtract(self.professionGearSet.professionStats)

    self.resultData = CraftSim.ResultData(self)

    -- print("baseProfessionStats:")
    -- print(self.baseProfessionStats, true, false, 1)

    -- print("professionStats:")
    -- print(self.professionStats, true, false, 1)
end

---@class CraftSim.ReagentListItem
---@field itemID number
---@field quantity number

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

function CraftSim.RecipeData:SetAllReagentsBySchematicForm()
    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(self.recipeID, self.isRecraft)
    local schematicForm = nil
    if ProfessionsFrame.CraftingPage.SchematicForm:IsVisible() then
        -- No Work Order
        schematicForm = ProfessionsFrame.CraftingPage.SchematicForm
    elseif ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:IsVisible() then
        schematicForm = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm
    end

    local reagentSlots = schematicForm.reagentSlots
    local currentTransaction = schematicForm:GetTransaction()

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

-- Update the professionStats property of the RecipeData according to set reagents and gearSet
function CraftSim.RecipeData:UpdateProfessionStats()
    local craftingReagentInfoTbl = self.reagentData:GetCraftingReagentInfoTbl()

    local updatedOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, craftingReagentInfoTbl, self.allocationItemGUID)

    
    -- TODO: Check if it makes sense to just parse all stats again?
    -- this would also set the recipeDifficulty based on the operationInfo and other things based on optional reagents..

    -- but what would that mean for simulationmode....?
    self.professionStats:SetStatsByOperationInfo(self, updatedOperationInfo)
end