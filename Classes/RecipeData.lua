---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.RecipeData : CraftSim.CraftSimObject
---@overload fun(recipeID: number, isRecraft:boolean?, isWorkOrder:boolean?, crafterData:CraftSim.CrafterData?): CraftSim.RecipeData
CraftSim.RecipeData = CraftSim.CraftSimObject:extend()

local systemPrint = print
local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)


---@class CraftSim.CrafterData
---@field name string
---@field realm string
---@field class ClassFile?

---@param recipeID number
---@param isRecraft? boolean
---@param isWorkOrder? boolean
---@param crafterData? CraftSim.CrafterData
---@return CraftSim.RecipeData?
function CraftSim.RecipeData:new(recipeID, isRecraft, isWorkOrder, crafterData)
    self.recipeID = recipeID --[[@as RecipeID]]
    -- important to set first so self:IsCrafter() can be used
    self.crafterData = crafterData or CraftSim.UTIL:GetPlayerCrafterData()

    local crafterUID = self:GetCrafterUID()

    self.concentrating = false
    self.concentrationCost = 0

    ---@class CraftSim.ConcentrationCurveData
    ---@field costConstantData table<number, number>
    ---@field curveData table<number, number>
    self.concentrationCurveData = nil

    -- important for recipedata of alts to check if data was cached (and for any recipe data creation b4 tradeskill is ready)
    self.specializationDataCached = false
    self.operationInfoCached = false
    self.professionGearCached = false
    self.recipeInfoCached = false
    self.professionInfoCached = false
    --- map of itemID of reagent to the recipe used for crafting cost optimization
    ---@type table<ItemID, CraftSim.RecipeData>
    self.optimizedSubRecipes = {}
    self.subRecipeCostsEnabled = false
    self.subRecipeDepth = 0

    --- instead of direct reference to easier find it after (de)serialization. Also needs everything to display in tooltip
    ---@class CraftSim.RecipeData.ParentRecipeInfo
    ---@field recipeID RecipeID
    ---@field crafterUID CrafterUID
    ---@field crafterClass ClassFile
    ---@field profession Enum.Profession
    ---@field recipeName string
    ---@field subRecipeDepth number
    ---@field concentrating boolean
    --- recipeData references for which the recipeData is used as subRecipe
    ---@type CraftSim.RecipeData.ParentRecipeInfo[]
    self.parentRecipeInfo = {}

    if not recipeID then
        return -- e.g. when deserializing
    end

    ---@type CraftSim.ProfessionData
    self.professionData = CraftSim.ProfessionData(self, recipeID)
    self.professionInfoCached = self.professionData.professionInfoCached
    self.supportsSpecializations = C_ProfSpecs.SkillLineHasSpecialization(self.professionData.skillLineID)

    self.expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(self.professionData.skillLineID)

    if isWorkOrder then
        ---@type CraftingOrderInfo
        self.orderData = ProfessionsFrame.OrdersPage.OrderView.order

        print("Craft Order Data:")
        print(self.orderData, true)
    end

    if self:IsCrafter() then
        self.recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID) -- only partial info is returned when not the crafter, so we need to cache it

        -- if we are here too early for recipeInfo to be loaded, use the one from db
        if self.recipeInfo and self.recipeInfo.categoryID == 0 then
            self.recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, self.recipeID)
        else
            -- otherwise save to db
            CraftSim.DB.CRAFTER:SaveRecipeInfo(crafterUID, recipeID, self.recipeInfo)
        end
    else
        self.recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, self.recipeID)
        if not self.recipeInfo then
            self.recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
            self.recipeInfoCached = false
        else
            self.recipeInfoCached = true
        end
    end

    if not self.recipeInfo then
        print("Could not create recipeData: recipeInfo nil")
        return nil
    end

    self.isBaseRecraftRecipe = GUTIL:Some(CraftSim.CONST.BASE_RECRAFT_RECIPE_IDS,
        function(id) return id == recipeID end)
    self.categoryID = self.recipeInfo.categoryID
    --- Will be set when something calculates the average profit of this recipe or updates the whole recipe, can be used to access it without recalculating everything
    ---@type number | nil
    self.averageProfitCached = nil
    ---@type number | nil
    self.relativeProfitCached = nil
    self.isQuestRecipe = tContains(CraftSim.CONST.QUEST_RECIPE_IDS, recipeID)

    self.isGear = false

    self.isEnchantingRecipe = self.recipeInfo.isEnchantingRecipe or false


    if self.recipeInfo.hyperlink and not self.isEnchantingRecipe then
        local itemInfoInstant = { C_Item.GetItemInfoInstant(self.recipeInfo.hyperlink) }
        -- 4th return value is item equip slot, so if its of non type its not equipable, otherwise its gear
        self.isGear = not tContains(CraftSim.CONST.INVENTORY_TYPES_NON_GEAR, itemInfoInstant[4])
    end

    self.isOldWorldRecipe = self:IsOldWorldRecipe()
    self.isRecraft = isRecraft or false
    if self.orderData then
        self.isRecraft = self.orderData.isRecraft
    end
    self.isSimulationModeData = false
    self.learned = self.recipeInfo.learned or false
    self.numSkillUps = self.recipeInfo.numSkillUps
    self.recipeIcon = self.recipeInfo.icon
    self.recipeName = self.recipeInfo.name
    self.supportsQualities = self.recipeInfo.supportsQualities or false
    self.supportsCraftingStats = self.recipeInfo.supportsCraftingStats or false
    self.isCooking = self.professionData.professionInfo.profession == Enum.Profession.Cooking
    self.isSalvageRecipe = self.recipeInfo.isSalvageRecipe or false
    self.isAlchemicalExperimentation = tContains(CraftSim.CONST.ALCHEMICAL_EXPERIMENTATION_RECIPE_IDS, recipeID)
    ---@type string?
    self.allocationItemGUID = nil
    self.maxQuality = self.recipeInfo.maxQuality

    self.supportsMulticraft = false
    self.supportsResourcefulness = false
    self.supportsIngenuity = false
    self.supportsCraftingspeed = true -- this is always supported (but does not show in details UI when 0)

    self.cooldownData = self:GetCooldownDataForRecipeCrafter()

    local schematicInfo = C_TradeSkillUI.GetRecipeSchematic(self.recipeID, self.isRecraft) -- is working even if profession is not learned on the character!
    if not schematicInfo then
        print("No RecipeData created: SchematicInfo not found")
        return
    end

    ---@type CraftSim.ReagentData
    self.reagentData = CraftSim.ReagentData(self, schematicInfo)

    local qualityReagents = GUTIL:Count(self.reagentData.requiredReagents, function(reagent)
        return reagent.hasQuality
    end)

    self.hasQualityReagents = qualityReagents > 0

    self.hasReagents = #self.reagentData.requiredReagents > 0

    self.baseItemAmount = (schematicInfo.quantityMin + schematicInfo.quantityMax) / 2
    self.minItemAmount = schematicInfo.quantityMin
    self.maxItemAmount = schematicInfo.quantityMax

    -- needs to load before spec data
    ---@type CraftSim.BuffData
    self.buffData = CraftSim.BuffData(self)
    -- no need to search for craft buffs when I am not even the crafter
    if self:IsCrafter() then
        self.buffData:Update()
    end

    if self.supportsSpecializations then
        ---@type CraftSim.SpecializationData?
        self.specializationData = self:GetSpecializationDataForRecipeCrafter()
    end

    -- EXCEPTION for Dragonflight - Sturdy Expedition Shovel - 388279
    -- Due to a blizzard bug the recipe's baseItemAmount is 2 although it only produces 1
    if self.recipeID == 388279 then
        self.baseItemAmount = 1
    end

    self.isSoulbound = (schematicInfo.outputItemID and GUTIL:isItemSoulbound(schematicInfo.outputItemID)) or
        false

    ---@type CraftSim.ProfessionGearSet
    self.professionGearSet = CraftSim.ProfessionGearSet(self)
    self.professionGearSet:LoadCurrentEquippedSet()

    CraftSim.DEBUG:StartProfiling("- RD: OperationInfo")
    self.baseOperationInfo = nil
    if self.orderData then
        self.baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(self.recipeID, {},
            self.orderData.orderID, self.concentrating)
    else
        self.baseOperationInfo = self:GetCraftingOperationInfoForRecipeCrafter()
    end

    ---@type CraftSim.ProfessionStats
    self.baseProfessionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.professionStatModifiers = CraftSim.ProfessionStats()

    self.baseProfessionStats:SetStatsByOperationInfo(self, self.baseOperationInfo)
    CraftSim.DEBUG:StopProfiling("- RD: OperationInfo")

    if self.supportsIngenuity and self.supportsSpecializations then
        self.concentrationData = self:GetConcentrationDataForCrafter()
    end

    -- exception: when salvage recipe, then resourcefulness is supported!
    if self.isSalvageRecipe then
        self.supportsResourcefulness = true
    end

    if self.professionData:UsesGear() then
        CraftSim.DEBUG:StartProfiling("- RD: ProfessionGearCache")
        -- cache available profession gear by calling this once
        CraftSim.TOPGEAR:GetProfessionGearFromInventory(self)
        CraftSim.DEBUG:StopProfiling("- RD: ProfessionGearCache")

        self.baseProfessionStats:subtract(self.professionGearSet.professionStats)
    end

    self.baseProfessionStats:subtract(self.buffData.professionStats)
    -- As we dont know in this case what the factors are without gear and reagents and such
    -- we set them to 0 and let them accumulate in UpdateProfessionStats
    self.baseProfessionStats:ClearExtraValues()

    self:UpdateProfessionStats()

    ---@type CraftSim.ResultData
    self.resultData = CraftSim.ResultData(self)
    self.resultData:Update()

    ---@type CraftSim.PriceData
    self.priceData = CraftSim.PriceData(self)
    self.priceData:Update()

    self.isCrafterInfoCached = self:IsCrafterInfoCached()

    -- only cache if this character is the crafter and the profession is open
    local isCrafter = self:IsCrafter()
    local IsProfessionOpen = self:IsProfessionOpen()

    -- local print = CraftSim.DEBUG:SetDebugPrint("RECIPE_SCAN")
    -- print("RecipeData: " .. self.recipeName)
    -- print("- isCrafter: " .. tostring(isCrafter))
    -- print("- IsProfessionOpen: " .. tostring(IsProfessionOpen))
    CraftSim.DEBUG:StartProfiling("- RD: Cache Data")
    if isCrafter and IsProfessionOpen then
        -- print("- Caching Recipe!")
        CraftSim.DB.CRAFTER:AddCachedRecipeID(crafterUID, self.professionData.professionInfo.profession, self.recipeID)

        CraftSim.DEBUG:StartProfiling("- RD: Cache Data ClassApi")
        CraftSim.DB.CRAFTER:SaveClass(crafterUID, select(2, UnitClass("player")))
        CraftSim.DEBUG:StopProfiling("- RD: Cache Data ClassApi")

        CraftSim.DEBUG:StopProfiling("- RD: Cache Data")
    end
end

function CraftSim.RecipeData:SetSubRecipeCostsUsage(enabled)
    self.subRecipeCostsEnabled = enabled
end

---@param reagentList CraftSim.ReagentListItem[]
function CraftSim.RecipeData:SetReagents(reagentList)
    -- go through required reagents and set quantity accordingly

    for _, reagent in pairs(self.reagentData.requiredReagents) do
        local totalQuantity = 0
        for _, reagentItem in pairs(reagent.items) do
            local listReagent = GUTIL:Find(reagentList,
                function(listReagent) return listReagent.itemID == reagentItem.item:GetItemID() end)
            if listReagent then
                reagentItem.quantity = listReagent.quantity
                totalQuantity = totalQuantity + listReagent.quantity
            end
        end
        if totalQuantity > reagent.requiredQuantity then
            error("CraftSim: RecipeData SetReagents Error: total set quantity > requiredQuantity -> " ..
                totalQuantity .. " / " .. reagent.requiredQuantity)
        end
    end
end

---@param craftingReagentInfoTbl CraftingReagentInfo[]
function CraftSim.RecipeData:SetReagentsByCraftingReagentInfoTbl(craftingReagentInfoTbl)
    ---@type CraftingReagentInfo[], CraftingReagentInfo[]
    local optionalReagents, requiredReagents = GUTIL:Split(craftingReagentInfoTbl,
        ---@param craftingReagentInfo CraftingReagentInfo
        function(craftingReagentInfo)
            return CraftSim.OPTIONAL_REAGENT_DATA[craftingReagentInfo.itemID] ~= nil
        end)

    local optionalReagentIDs = GUTIL:Map(optionalReagents,
        function(optionalReagentInfo) return optionalReagentInfo.itemID end)

    self:SetOptionalReagents(optionalReagentIDs)
    self:SetReagents(requiredReagents) -- 'type conversion' to ReagentListItem should be fine, both have itemID and quantity
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
                    print("reagent #" .. i .. " allocation:", false, true)
                    print(reagentAllocation, true)
                end
                local craftSimReagentItem = nil
                for _, craftSimReagent in pairs(self.reagentData.requiredReagents) do
                    -- consider possible exception mappings
                    local itemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[reagent.itemID] or reagent.itemID
                    craftSimReagentItem = GUTIL:Find(craftSimReagent.items,
                        function(cr) return cr.item:GetItemID() == itemID end)
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

function CraftSim.RecipeData:SetConcentrationBySchematicForm()
    local schematicForm = CraftSim.UTIL:GetSchematicFormByVisibility()
    if not schematicForm then
        return
    end

    local currentTransaction = schematicForm:GetTransaction()
    self.concentrating = currentTransaction:IsApplyingConcentration()
end

---@param itemID number
function CraftSim.RecipeData:SetOptionalReagent(itemID)
    self.reagentData:SetOptionalReagent(itemID)
end

---@param itemIDList number[]
function CraftSim.RecipeData:SetOptionalReagents(itemIDList)
    table.foreach(itemIDList, function(_, itemID)
        self:SetOptionalReagent(itemID)
    end)
    self:Update()
end

--- also sets a sparkReagentItem if not yet set
function CraftSim.RecipeData:SetNonQualityReagentsMax()
    for _, reagent in pairs(self.reagentData.requiredReagents) do
        if not reagent.hasQuality then
            reagent.items[1].quantity = reagent.requiredQuantity
        end
    end

    if self.reagentData:HasSparkSlot() then
        if not self.reagentData.sparkReagentSlot.activeReagent then
            local firstPossibleSparkItem = self.reagentData.sparkReagentSlot.possibleReagents[1]
            if firstPossibleSparkItem then
                self.reagentData.sparkReagentSlot:SetReagent(firstPossibleSparkItem.item:GetItemID())
            end
        end
    end
end

---@return number concentrationCost
function CraftSim.RecipeData:GetConcentrationCost()
    if not self.baseOperationInfo then return 0 end
    local craftingDataID = self.baseOperationInfo.craftingDataID

    self.concentrationCurveData = CraftSim.CONCENTRATION_CURVE_DATA[craftingDataID]

    -- try to only enable it for simulation mode?
    if self.concentrationCurveData and CraftSim.SIMULATION_MODE.isActive then
        -- get skill bracket and associated start and end skillCurveValues
        local recipeDifficulty = self.professionStats.recipeDifficulty.value
        local playerSkill = math.min(self.professionStats.skill.value, recipeDifficulty) -- cap skill at max difficulty
        local playerSkillFactor = (playerSkill / (recipeDifficulty / 100)) / 100
        local specExtraValues = self.specializationData:GetExtraValues()
        local lessConcentrationFactorSpecs = specExtraValues.ingenuity:GetExtraValue(2)
        local optionalReagentStats = self.reagentData:GetProfessionStatsByOptionals()
        local professionGearStats = self.professionGearSet.professionStats
        local lessConcentrationFactorOptionals = optionalReagentStats.ingenuity:GetExtraValue(2)
        local lessConcentrationFactorGear = professionGearStats.ingenuity:GetExtraValue(2)

        local curveConstantData, nextCurveConstantData = CraftSim.UTIL:FindBracketData(playerSkill,
            self.concentrationCurveData.costConstantData)
        local curveData, nextCurveData = CraftSim.UTIL:FindBracketData(playerSkillFactor,
            self.concentrationCurveData.curveData)

        local curveConstant = CraftSim.UTIL:CalculateCurveConstant(recipeDifficulty, curveConstantData,
            nextCurveConstantData)
        local recipeDifficultyFactor = (curveData and curveData.index) or 0
        local nextRecipeDifficultyFactor = (nextCurveData and nextCurveData.index) or 1
        local skillCurveValueStart = (curveData and curveData.data) or 0
        local skillCurveValueEnd = (nextCurveData and nextCurveData.data) or 1
        local skillStart = recipeDifficulty * recipeDifficultyFactor
        local skillEnd = recipeDifficulty * nextRecipeDifficultyFactor

        return CraftSim.UTIL:CalculateConcentrationCost(
            curveConstant,
            playerSkill,
            skillStart,
            skillEnd,
            skillCurveValueStart,
            skillCurveValueEnd,
            { lessConcentrationFactorSpecs, lessConcentrationFactorOptionals, lessConcentrationFactorGear })
    else
        -- if by any chance the data for this recipe is not mapped in the db2 data, get a good guess via the api
        -- or if we are not in the current beta (08.08.2024)
        -- this works for reagent skill but not for any custom skill changes like in simulation mode or when simming different skill from profession tools...

        -- includes required and optionals
        local allReagentsTbl = self.reagentData:GetCraftingReagentInfoTbl()
        -- on purpose do not use concentration so we will always get the costs
        local operationInfo
        if self.orderData then
            operationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(self.recipeID, allReagentsTbl,
                self.orderData.orderID,
                false)
        else
            operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, allReagentsTbl,
                self.allocationItemGUID,
                false)
        end

        return (operationInfo and operationInfo.concentrationCost) or 0
    end
end

-- Update the professionStats property of the RecipeData according to set reagents and gearSet (and any stat modifiers)
function CraftSim.RecipeData:UpdateProfessionStats()
    local skillRequiredReagents = self.reagentData:GetSkillFromRequiredReagents()
    local optionalStats = self.reagentData:GetProfessionStatsByOptionals()
    local itemStats = self.professionGearSet.professionStats
    local buffStats = self.buffData.professionStats

    self.professionStats:Clear()

    self.professionStats:add(self.baseProfessionStats)

    self.professionStats:add(buffStats)

    self.professionStats.skill:addValue(skillRequiredReagents)

    self.professionStats:add(optionalStats)

    self.professionStats:add(itemStats)

    -- this should cover each case of non specialization data implemented professions
    if self.specializationData then
        local specExtraValues = self.specializationData:GetExtraValues()
        self.professionStats:add(specExtraValues)
    end

    -- finally add any custom modifiers
    self.professionStats:add(self.professionStatModifiers)

    -- since ooey gooey chocolate gives us math.huge on multicraft we need to limit it to 100%
    self.professionStats.multicraft.value = math.min(1 / self.professionStats.multicraft.percentMod,
        self.professionStats.multicraft.value)

    if self.supportsQualities then
        self.concentrationCost = self:GetConcentrationCost()
    end
end

--- Updates professionStats based on reagentData and professionGearSet -> Then updates resultData based on professionStats -> Then updates priceData based on resultData
function CraftSim.RecipeData:Update()
    self:UpdateProfessionStats()
    self.resultData:Update()
    self.priceData:Update()
    self:GetAverageProfit()
end

--- We need copy constructors or CopyTable will run into references of recipeData
---@return CraftSim.RecipeData recipeDataCopy
function CraftSim.RecipeData:Copy()
    ---@type CraftSim.RecipeData
    local copy = CraftSim.RecipeData(self.recipeID, self.isRecraft, self.orderData ~= nil, self.crafterData)
    copy.concentrating = self.concentrating
    copy.concentrationCost = self.concentrationCost
    copy.concentrationData = self.concentrationData and self.concentrationData:Copy()
    copy.reagentData = self.reagentData:Copy(copy)
    copy.cooldownData = self.cooldownData:Copy()
    copy.professionGearSet = self.professionGearSet:Copy()
    copy.professionStats = self.professionStats:Copy()
    copy.baseProfessionStats = self.baseProfessionStats:Copy()
    copy.professionStatModifiers = self.professionStatModifiers:Copy()
    copy.priceData = self.priceData:Copy(copy)
    copy.resultData = self.resultData:Copy(copy)
    copy.orderData = self.orderData
    copy.crafterData = self.crafterData
    copy.subRecipeCostsEnabled = self.subRecipeCostsEnabled
    copy.subRecipeDepth = self.subRecipeDepth
    copy.optimizedSubRecipes = {}
    copy.averageProfitCached = self.averageProfitCached
    copy.relativeProfitCached = self.relativeProfitCached

    copy.parentRecipeInfo = CopyTable(self.parentRecipeInfo)

    for itemID, recipeData in pairs(self.optimizedSubRecipes) do
        copy.optimizedSubRecipes[itemID] = recipeData:Copy()
    end

    copy:Update()
    return copy
end

--- Optimizes the recipeData's reagents for highest quality / cheapest reagents.
function CraftSim.RecipeData:OptimizeReagents()
    -- do not optimize quest recipes
    if self.isQuestRecipe then
        return
    end
    local optimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(self)
    self.reagentData:SetReagentsByOptimizationResult(optimizationResult)
    self:Update()
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
    self.averageProfitCached = averageProfit
    self.relativeProfitCached = GUTIL:GetPercentRelativeTo(averageProfit, self.priceData.craftingCosts)
    return averageProfit, probabilityTable
end

---@class CraftSim.RecipeData.OptimizeProfitOptions
---@field optimizeGear? boolean
---@field optimizeReagents? boolean

---Optimizes the recipeData's reagents and gear for highest profit and caches result for crafter
---@param options? CraftSim.RecipeData.OptimizeProfitOptions
function CraftSim.RecipeData:OptimizeProfit(options)
    options = options or {}
    if options.optimizeReagents then
        self:OptimizeReagents()
    end
    if options.optimizeGear then -- TEMPORARY: ALWAYS OPTIMIZE IF PARAM IS NOT GIVEN
        self:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
    end
    if options.optimizeReagents and options.optimizeGear then
        -- need another because it could be that the optimized gear makes it possible to use cheaper reagents
        self:OptimizeReagents()
    end

    CraftSim.DB.ITEM_OPTIMIZED_COSTS:Add(self)
end

---Optimizes the recipeData's reagents and gear for highest quality
function CraftSim.RecipeData:OptimizeQuality()
    self:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.SKILL))
    self:OptimizeReagents()
end

---@param idLinkOrMixin number | string | ItemMixin
---@return number? qualityID
function CraftSim.RecipeData:GetResultQuality(idLinkOrMixin)
    local item = nil

    if type(idLinkOrMixin) == 'number' then
        ---@diagnostic disable-next-line: param-type-mismatch
        item = Item:CreateFromItemID(idLinkOrMixin)
    elseif type(idLinkOrMixin) == 'string' then
        ---@diagnostic disable-next-line: param-type-mismatch
        item = Item:CreateFromItemLink(idLinkOrMixin)
    elseif type(idLinkOrMixin) == 'table' and idLinkOrMixin.ContinueOnItemLoad then
        item = idLinkOrMixin
    end

    for qualityID, _item in pairs(self.resultData.itemsByQuality) do
        local itemLinkA = _item:GetItemLink()
        local itemLinkB = item:GetItemLink()
        if itemLinkA and itemLinkB then
            if _item:GetItemLink() == item:GetItemLink() then
                return qualityID
            end
        elseif _item:GetItemID() == item:GetItemID() then
            return qualityID
        end
    end

    return nil
end

function CraftSim.RecipeData:IsResult(idLinkOrMixin)
    return self:GetResultQuality(idLinkOrMixin) ~= nil
end

function CraftSim.RecipeData:GetJSON(indent)
    indent = indent or 0

    local jb = CraftSim.JSONBuilder(indent)

    jb:Begin()
    jb:Add("recipeID", self.recipeID)
    jb:Add("categoryID", self.categoryID)
    jb:Add("concentrating", self.concentrating)
    jb:Add("learned", self.learned)
    jb:Add("numSkillUps", self.numSkillUps)
    jb:Add("recipeIcon", self.recipeIcon)
    jb:Add("recipeName", self.recipeName)
    jb:Add("isSimulationModeData", self.isSimulationModeData)
    jb:Add("hasQualityReagents", self.hasQualityReagents)
    jb:Add("supportsQualities", self.supportsQualities)
    jb:Add("supportsCraftingStats", self.supportsCraftingStats)
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

---@return boolean
function CraftSim.RecipeData:IsCrafter()
    local crafterDataEquals = self:CrafterDataEquals(CraftSim.UTIL:GetPlayerCrafterData())
    local professionLearned = C_TradeSkillUI.IsRecipeProfessionLearned(self.recipeID)
    -- local print = CraftSim.DEBUG:SetDebugPrint("RECIPE_SCAN")
    -- print("--crafterDataEquals: " .. tostring(crafterDataEquals))
    -- print("--professionLearned: " .. tostring(professionLearned))
    return crafterDataEquals and professionLearned
end

function CraftSim.RecipeData:GetForgeFinderExport(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)

    jb:Begin()
    jb:AddList("itemIDs", GUTIL:Map(self.resultData.itemsByQuality, function(item)
        return item:GetItemID()
    end))
    local reagents = {}
    for _, reagent in pairs(self.reagentData.requiredReagents) do
        for _, reagentItem in pairs(reagent.items) do
            reagents[reagentItem.item:GetItemID()] = reagent.requiredQuantity
        end
    end

    local professionStatsForExport = self.professionStats:Copy()
    professionStatsForExport:subtract(self.buffData.professionStats)

    jb:Add("reagents", reagents) -- itemID mapped to required quantity
    if self.supportsQualities then
        print("json, adding skill: ")
        jb:Add("skill", self.professionStats.skill.value)                               -- skill without reagent bonus TODO: if single export, consider removing reagent bonus
        if self.supportsMulticraft or self.supportsResourcefulness then
            jb:Add("difficulty", self.baseProfessionStats.recipeDifficulty.value)       -- base difficulty (without optional reagents)
        else
            jb:Add("difficulty", self.baseProfessionStats.recipeDifficulty.value, true) -- base difficulty (without optional reagents)
        end
    end
    if self.supportsCraftingStats then
        if self.supportsMulticraft then
            if not self.supportsResourcefulness then
                jb:Add("multicraft", professionStatsForExport.multicraft:GetPercent(true), true)
            else
                jb:Add("multicraft", professionStatsForExport.multicraft:GetPercent(true))
            end
        end
        if self.supportsResourcefulness then
            jb:Add("resourcefulness", professionStatsForExport.resourcefulness:GetPercent(true), true)
        end
    end
    jb:End()

    return jb.json
end

function CraftSim.RecipeData:GetEasycraftExport(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)

    jb:Begin()
    jb:AddList("itemIDs", GUTIL:Map(self.resultData.itemsByQuality, function(item)
        return item:GetItemID()
    end))

    local optionalReagentsSlotStatus = {}
    for _, reagent in pairs(self.reagentData.optionalReagentSlots) do
        if reagent.mcrSlotID then
            optionalReagentsSlotStatus[reagent.mcrSlotID] = reagent.locked
        end
    end
    jb:Add("optionalReagentsSlotStatus", optionalReagentsSlotStatus)

    local reagents = {}
    for _, reagent in pairs(self.reagentData.requiredReagents) do
        for _, reagentItem in pairs(reagent.items) do
            reagents[reagentItem.item:GetItemID()] = reagent.requiredQuantity
        end
    end
    jb:Add("reagents", reagents) -- itemID mapped to required quantity

    local professionStatsForExport = self.professionStats:Copy()
    professionStatsForExport:subtract(self.buffData.professionStats)

    jb:Add("expectedQuality", self.resultData.expectedQuality)
    jb:Add("expectedQualityConcentration", self.resultData.expectedQualityConcentration)
    if self.supportsQualities then
        print("json, adding skill: ")
        jb:Add("skill", self.professionStats.skill.value)                     -- skill without reagent bonus TODO: if single export, consider removing reagent bonus
        jb:Add("difficulty", self.baseProfessionStats.recipeDifficulty.value) -- base difficulty (without optional reagents)
        jb:Add("concentration", self.concentrationCost)
        jb:Add("ingenuity", self.professionStats.ingenuity.value)
    end
    if self.supportsCraftingStats then
        if self.supportsMulticraft then
            if not self.supportsResourcefulness then
                jb:Add("multicraft", professionStatsForExport.multicraft:GetPercent(true))
            else
                jb:Add("multicraft", professionStatsForExport.multicraft:GetPercent(true))
            end
        end
        if self.supportsResourcefulness then
            jb:Add("resourcefulness", professionStatsForExport.resourcefulness:GetPercent(true))
        end
    end
    jb:Add("spellID", self.recipeID, true)
    jb:End()

    return jb.json
end

--- Requires a hardware event
---@param amount number? default: 1, how many crafts should be queued
function CraftSim.RecipeData:Craft(amount)
    amount = amount or 1
    -- TODO: maybe check if crafting is possible (correct profession window open?)
    -- Also what about recipe requirements
    local craftingReagentInfoTbl = self.reagentData:GetCraftingReagentInfoTbl()

    if self.isEnchantingRecipe then
        local vellumLocation = GUTIL:GetItemLocationFromItemID(CraftSim.CONST.ENCHANTING_VELLUM_ID)
        if vellumLocation then
            C_TradeSkillUI.CraftEnchant(self.recipeID, amount, craftingReagentInfoTbl, vellumLocation, self
                .concentrating)
        end
    else
        C_TradeSkillUI.CraftRecipe(self.recipeID, amount, craftingReagentInfoTbl, nil,
            self.orderData and self.orderData.orderID,
            self.concentrating)
    end
end

--- Returns wether the recipe can be crafted with the set reagents a specified amount of times
---@param amount number
---@return boolean craftAble is the given amount craftable
---@return number canCraftAmount how many can be crafted
function CraftSim.RecipeData:CanCraft(amount)
    -- check if the player fits the requirements to craft the given amount of the recipe

    -- check: learned, maybe area?, other?
    if not self.learned then
        return false, 0
    end

    -- check amount of materials in players inventory + bank
    local hasEnoughReagents = self.reagentData:HasEnough(amount, self:GetCrafterUID())

    local craftAbleAmount = self.reagentData:GetCraftableAmount(self:GetCrafterUID())

    local isChargeRecipe = self.cooldownData.maxCharges > 0

    local concentrationAmount = math.huge
    if self.concentrating and self.concentrationCost > 0 then
        concentrationAmount = math.floor(self.concentrationData:GetCurrentAmount() / (self.concentrationCost * amount))
    end

    craftAbleAmount = math.min(craftAbleAmount, concentrationAmount)

    if not isChargeRecipe then
        return hasEnoughReagents, craftAbleAmount
    else
        -- limit by current charge amount
        return hasEnoughReagents, math.min(craftAbleAmount, self.cooldownData:GetCurrentCharges())
    end
end

---@return boolean true of the profession the recipe belongs to is opened
function CraftSim.RecipeData:IsProfessionOpen()
    if not ProfessionsFrame:IsVisible() then
        return false
    end
    if not ProfessionsFrame.professionInfo then
        return false
    end

    local openProfessionID = ProfessionsFrame.professionInfo.profession
    return openProfessionID == self.professionData.professionInfo.profession
end

---@return boolean onCooldown
function CraftSim.RecipeData:OnCooldown()
    return self.cooldownData:OnCooldown()
end

--- Returns either the current characters CraftingOperationInfo or the cached info from the recipe's crafter
---@return CraftingOperationInfo
function CraftSim.RecipeData:GetCraftingOperationInfoForRecipeCrafter()
    ---@type CraftingOperationInfo
    local operationInfo = nil
    local crafterUID = self:GetCrafterUID()
    if not self:IsCrafter() then
        operationInfo = CraftSim.DB.CRAFTER:GetOperationInfoForRecipe(crafterUID, self.recipeID)

        if operationInfo then
            self.operationInfoCached = true
        else
            operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, {}, self.allocationItemGUID,
                self.concentrating)
        end
    else
        operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, {}, self.allocationItemGUID,
            self.concentrating)

        -- check for too early access?
        CraftSim.DB.CRAFTER:SaveOperationInfoForRecipe(crafterUID, self.recipeID, operationInfo)
    end

    return operationInfo
end

---@return CraftSim.SpecializationData
function CraftSim.RecipeData:GetSpecializationDataForRecipeCrafter()
    local crafterUID = self:GetCrafterUID()

    if not self:IsCrafter() then
        local specializationData = CraftSim.DB.CRAFTER:GetSpecializationData(crafterUID, self)
        if specializationData then
            self.specializationDataCached = true
            return specializationData
        end
        return CraftSim.SpecializationData(self) -- will initialize without stats and nodeinfo
    else
        local specializationData = CraftSim.SpecializationData(self)

        -- if too early, use from db
        if not self.isOldWorldRecipe and #specializationData.nodeData == 0 then
            specializationData = CraftSim.DB.CRAFTER:GetSpecializationData(crafterUID, self)
            return specializationData
        else
            CraftSim.DB.CRAFTER:SaveSpecializationData(crafterUID, specializationData)
            return specializationData
        end
    end
end

---@return CraftSim.CooldownData
function CraftSim.RecipeData:GetCooldownDataForRecipeCrafter()
    local crafterUID = self:GetCrafterUID()
    local cooldownData

    -- the C_TradeSkillUI.GetRecipeCooldown api only works if the actual profession is open
    if self:IsCrafter() and self:IsProfessionOpen() then
        cooldownData = CraftSim.CooldownData(self.recipeID)
        cooldownData:Update()

        -- cache only learned recipes from current expac that can be on cooldown
        if cooldownData.isCooldownRecipe and self.recipeInfo.learned then -- and not self.isOldWorldRecipe then
            cooldownData:Save(crafterUID)
        end
    else
        cooldownData = CraftSim.CooldownData:DeserializeForCrafter(crafterUID, self.recipeID)
    end

    return cooldownData
end

---@return CraftSim.ConcentrationData?
function CraftSim.RecipeData:GetConcentrationDataForCrafter()
    local crafterUID = self:GetCrafterUID()
    local concentrationData
    if self:IsCrafter() and self.supportsSpecializations then
        local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(self.professionData.skillLineID)
        concentrationData = CraftSim.ConcentrationData(currencyID)
        concentrationData:Update()
        -- save in crafterDB
        CraftSim.DB.CRAFTER:SaveCrafterConcentrationData(crafterUID, self.professionData.professionInfo.profession,
            self.expansionID,
            concentrationData)
    else
        concentrationData =
            CraftSim.DB.CRAFTER:GetCrafterConcentrationData(crafterUID, self.professionData.professionInfo.profession,
                self.expansionID)
    end

    return concentrationData
end

function CraftSim.RecipeData:IsCrafterInfoCached()
    if self:IsCrafter() then
        return true
    end

    if not self.isOldWorldRecipe then
        return self.professionGearCached and self.specializationDataCached and self.operationInfoCached and
            self.recipeInfoCached and self.professionInfoCached
    else
        return self.recipeInfoCached and self.professionInfoCached
    end
end

---@return CraftSim.CrafterData
function CraftSim.RecipeData:GetCrafterData()
    return self.crafterData
end

---@return CrafterUID
function CraftSim.RecipeData:GetCrafterUID()
    local crafterUID = self.crafterData.name .. "-" .. self.crafterData.realm --[[@as CrafterUID]]
    return crafterUID
end

---compares the given crafterData with the one from the recipe
---@param crafterData CraftSim.CrafterData
---@return boolean equals
function CraftSim.RecipeData:CrafterDataEquals(crafterData)
    local nameEquals = self.crafterData.name == crafterData.name
    local realmEquals = self.crafterData.realm == crafterData.realm
    local classEquals = self.crafterData.class == crafterData.class
    return nameEquals and realmEquals and classEquals
end

function CraftSim.RecipeData:IsOldWorldRecipe()
    return self.professionData.expansionID < CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT
end

---@param expansionID CraftSim.EXPANSION_IDS
function CraftSim.RecipeData:IsExpansionRecipe(expansionID)
    if self.professionData and self.professionData.skillLineID then
        return self.professionData.skillLineID ==
            CraftSim.CONST.TRADESKILLLINEIDS[self.professionData.professionInfo.profession][expansionID]
    end

    return false
end

function CraftSim.RecipeData:IsSpecializationInfoImplemented()
    return tContains(CraftSim.CONST.IMPLEMENTED_SPECIALIZATION_DATA[self.professionData.expansionID],
        self.professionData.professionInfo.profession)
end

--- returns recipe crafting info for all required and all active optional reagents
---@return CraftSim.ItemRecipeData[]
function CraftSim.RecipeData:GetSubRecipeCraftingInfos()
    local print = CraftSim.DEBUG:SetDebugPrint("SUB_RECIPE_DATA")
    local craftingInfos = {}
    for _, reagent in ipairs(self.reagentData.requiredReagents) do
        for _, reagentItem in ipairs(reagent.items) do
            local craftingInfo = CraftSim.DB.ITEM_RECIPE:Get(reagentItem.item:GetItemID())
            if craftingInfo then
                tinsert(craftingInfos, craftingInfo)
            end
        end
    end
    for _, activeReagent in ipairs(self.reagentData:GetActiveOptionalReagents()) do
        local craftingInfo = CraftSim.DB.ITEM_RECIPE:Get(activeReagent.item:GetItemID())
        if craftingInfo then
            tinsert(craftingInfos, craftingInfo)
        end
    end
    return craftingInfos
end

---@class CraftSim.RecipeData.VisitedRecipeData
---@field recipeID RecipeID
---@field subRecipeDepth number

--- optimizes cached subrecipes and updates priceData
---@param optimizeOptions? CraftSim.RecipeData.OptimizeProfitOptions
---@param visitedRecipeIDs? CraftSim.RecipeData.VisitedRecipeData[] blank in initial call - used to break potential infinite loops
---@param subRecipeDepth? number
---@return boolean success
function CraftSim.RecipeData:OptimizeSubRecipes(optimizeOptions, visitedRecipeIDs, subRecipeDepth)
    local printD = CraftSim.DEBUG:SetDebugPrint("SUB_RECIPE_DATA")
    optimizeOptions = optimizeOptions or {}
    subRecipeDepth = subRecipeDepth or 0
    visitedRecipeIDs = visitedRecipeIDs or {}

    local print = function(t, r, l)
        if true then --self.recipeID == 376556 then
            printD(t, r, l, subRecipeDepth)
        end
    end

    print("Optimize SubRecipes for " .. self.recipeName .. " C: " .. tostring(self.concentrating))
    print("- Depth: " .. subRecipeDepth)

    if subRecipeDepth > CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH") then
        print("Cancel Sub Recipe Optimization due to max depth")
        return false
    end

    --- DEBUG

    local subRecipeData = self:GetSubRecipeCraftingInfos()

    -- used to show what is reachable
    wipe(self.optimizedSubRecipes)

    -- TODO: Maybe introduce optimizing via caching again here at some point

    -- optimize recipes and map itemIDs
    for _, data in pairs(subRecipeData) do
        print("looping subrecipeData: " .. data.itemID .. " - q" .. data.qualityID)
        local recipeID = data.recipeID
        -- fall back to the first crafter if nothing is set?
        local crafterUID = CraftSim.DB.RECIPE_SUB_CRAFTER:GetCrafter(data.recipeID) or
            data.crafters[1]

        -- a infinite loop occurs if we try to optimize a recipe we already visited in a previous subRecipe depth
        -- if that happens we do not want to optimize that recipe again but just stop optimizing
        -- this might lead to this reagent not being marked as self crafted but I guess thats ok cause its a very special case
        -- and does not make sense to resolve
        local infLoop = GUTIL:Some(visitedRecipeIDs,
            function(visitedRecipeData)
                return visitedRecipeData.subRecipeDepth < subRecipeDepth and visitedRecipeData.recipeID == recipeID
            end)
        -- inf loop breaker
        if not infLoop then
            local crafterData = CraftSim.UTIL:GetCrafterDataFromCrafterUID(crafterUID)
            -- local reagentRecipeData = GUTIL:Find(optimized, function(recipeData)
            --     return recipeData.recipeID == recipeID
            -- end)
            if recipeID and crafterData then
                -- only continue of the recipe in question is learned by the target crafter
                local recipeInfo = CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, recipeID)

                tinsert(visitedRecipeIDs, {
                    recipeID = recipeID,
                    subRecipeDepth = subRecipeDepth,
                })

                if recipeInfo then --and recipeInfo.learned then
                    local recipeData = CraftSim.RecipeData(recipeID, false, false, crafterData)
                    local ignoreCooldownRecipe = not CraftSim.DB.OPTIONS:Get(
                            "COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWNS") and
                        recipeData.cooldownData.isCooldownRecipe

                    if not ignoreCooldownRecipe then
                        recipeData.subRecipeDepth = subRecipeDepth + 1
                        print("- Checking SubRecipe: " ..
                            recipeData.recipeName .. "( q" .. tostring(data.qualityID) .. ")")
                        -- go deep!
                        local success = recipeData:OptimizeSubRecipes(optimizeOptions, visitedRecipeIDs,
                            subRecipeDepth + 1)
                        if success then
                            recipeData:SetSubRecipeCostsUsage(true)

                            -- caches the expect costs info automatically
                            recipeData:OptimizeProfit(optimizeOptions)
                            print("- Profit: " ..
                                CraftSim.UTIL:FormatMoney(recipeData.averageProfitCached, true, nil, true))

                            -- if the necessary item quality is reachable, map it to the recipe
                            local reagentQualityReachable, concentrationOnly = recipeData.resultData
                                :IsMinimumQualityReachable(data
                                    .qualityID)

                            if concentrationOnly then
                                recipeData.concentrating = true
                                recipeData:Update()
                                -- post update concentration flag in pri info in sub recipes of this item quality
                                for _, subRecipeData in pairs(recipeData.optimizedSubRecipes) do
                                    for _, prI in pairs(subRecipeData.parentRecipeInfo) do
                                        prI.concentrating = true
                                    end
                                end
                            end

                            recipeData:AddParentRecipe(self)

                            print("- Quality Reachable: " ..
                                tostring(reagentQualityReachable) .. " C: " .. tostring(concentrationOnly))
                            if reagentQualityReachable then
                                self.optimizedSubRecipes[data.itemID] = recipeData
                            end
                        end
                    end
                end
            end
        else
            print("Break Inf Loop!")
        end
    end

    -- update pricedata
    self.priceData:Update()

    return true
end

---@param includeProfessionIcon? boolean
---@param includeRealm? boolean
---@param professionIconX? number = 20
---@param professionIconY? number = 20
---@return string
function CraftSim.RecipeData:GetFormattedCrafterText(includeRealm, includeProfessionIcon, professionIconX,
                                                     professionIconY)
    local finalText = ""
    if includeProfessionIcon then
        finalText = finalText .. GUTIL:IconToText(
            CraftSim.CONST.PROFESSION_ICONS[self.professionData.professionInfo.profession],
            professionIconY, professionIconX)
    end

    local crafterData = self:GetCrafterData()
    local classColor = C_ClassColor.GetClassColor(crafterData.class)
    if includeRealm then
        finalText = finalText .. classColor:WrapTextInColorCode(crafterData.name .. "-" .. crafterData.realm)
    else
        finalText = finalText .. classColor:WrapTextInColorCode(crafterData.name)
    end

    return finalText
end

---@param itemID ItemID
function CraftSim.RecipeData:IsSelfCraftedReagent(itemID)
    return self.priceData:IsSelfCraftedReagent(itemID)
end

---@param itemID ItemID
---@return number
function CraftSim.RecipeData:GetReagentQuantityByItemID(itemID)
    return self.reagentData:GetReagentQuantityByItemID(itemID)
end

---@param subRecipeData CraftSim.RecipeData
function CraftSim.RecipeData:IsParentRecipeOf(subRecipeData)
    return subRecipeData:HasParentRecipeInfo(self:CreateParentRecipeInfo())
end

---@param prI CraftSim.RecipeData.ParentRecipeInfo
function CraftSim.RecipeData:HasParentRecipeInfo(prI)
    return GUTIL:Some(self.parentRecipeInfo, function(parentRecipeInfo)
        return parentRecipeInfo.recipeID == prI.recipeID and parentRecipeInfo.crafterUID == prI.crafterUID and
            parentRecipeInfo.subRecipeDepth == prI.subRecipeDepth and parentRecipeInfo.concentrating == prI
            .concentrating
    end)
end

---@return CraftSim.RecipeData.ParentRecipeInfo
function CraftSim.RecipeData:CreateParentRecipeInfo()
    ---@type CraftSim.RecipeData.ParentRecipeInfo
    local pri = {
        recipeID = self.recipeID,
        crafterUID = self:GetCrafterUID(),
        crafterClass = self.crafterData.class,
        profession = self.professionData.professionInfo.profession,
        recipeName = self.recipeName,
        subRecipeDepth = self.subRecipeDepth,
        concentrating = self.concentrating,
    }
    return pri
end

---@param prI CraftSim.RecipeData.ParentRecipeInfo
function CraftSim.RecipeData:AddParentRecipeInfo(prI)
    if not self:HasParentRecipeInfo(prI) then
        tinsert(self.parentRecipeInfo, prI)
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RecipeData:AddParentRecipe(recipeData)
    self:AddParentRecipeInfo(recipeData:CreateParentRecipeInfo())
end

---@param recipeData CraftSim.RecipeData
function CraftSim.RecipeData:AddParentRecipeInfosFrom(recipeData)
    for _, parentRecipesInfo in ipairs(recipeData.parentRecipeInfo) do
        self:AddParentRecipeInfo(parentRecipesInfo)
    end
end

function CraftSim.RecipeData:HasActiveSubRecipeInCraftQueue()
    return CraftSim.CRAFTQ.craftQueue:RecipeHasActiveSubRecipesInQueue(self)
end

---@alias RecipeCraftQueueUID string

--- Returns a unique id for the recipe within the craftqueue
--- Unique in recipeID, depth, crafter and concentration usage
---@return RecipeCraftQueueUID
function CraftSim.RecipeData:GetRecipeCraftQueueUID()
    return self:GetCrafterUID() ..
        ":" .. self.recipeID .. ":" .. self.subRecipeDepth .. ":" .. tostring(self.concentrating)
end

---@return boolean hasActiveSubRecipes
function CraftSim.RecipeData:HasActiveSubRecipes()
    return GUTIL:Count(self.optimizedSubRecipes) > 0 and GUTIL:Count(self.priceData.selfCraftedReagents) > 0
end

---@return boolean IsSubRecipe
function CraftSim.RecipeData:IsSubRecipe()
    return self.subRecipeDepth > 0
end

function CraftSim.RecipeData:HasParentsInCraftQueue()
    return GUTIL:Some(self.parentRecipeInfo, function(prI)
        return CraftSim.CRAFTQ.craftQueue:FindRecipeByParentRecipeInfo(prI) ~= nil
    end)
end
