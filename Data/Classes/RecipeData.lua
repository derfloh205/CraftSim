---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.RecipeData
---@overload fun(recipeID: number, isRecraft:boolean?, isWorkOrder:boolean?, crafterData:CraftSim.CrafterData?): CraftSim.RecipeData
CraftSim.RecipeData = CraftSim.Object:extend()

local systemPrint = print
local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)


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
    self.recipeID = recipeID
    -- important to set first so self:IsCrafter() can be used
    self.crafterData = crafterData or CraftSim.UTIL:GetPlayerCrafterData()

    local crafterUID = self:GetCrafterUID()

    -- important for recipedata of alts to check if data was cached (and for any recipe data creation b4 tradeskill is ready)
    self.specializationDataCached = false
    self.operationInfoCached = false
    self.professionGearCached = false
    self.recipeInfoCached = false
    self.professionInfoCached = false

    if not recipeID then
        return -- e.g. when deserializing
    end

    ---@type CraftSim.ProfessionData
    self.professionData = CraftSim.ProfessionData(self, recipeID)
    self.professionInfoCached = self.professionData.professionInfoCached


    if isWorkOrder then
        ---@type CraftingOrderInfo
        self.orderData = ProfessionsFrame.OrdersPage.OrderView.order

        print("Craft Order Data:")
        print(self.orderData, true)
    end

    CraftSimRecipeDataCache.recipeInfoCache[crafterUID] = CraftSimRecipeDataCache.recipeInfoCache[crafterUID] or {}
    if self:IsCrafter() then
        self.recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID) -- only partial info is returned when not the crafter, so we need to cache it

        -- if we are here too early for recipeInfo to be loaded, use the cached one
        if self.recipeInfo and self.recipeInfo.categoryID == 0 then
            self.recipeInfo = CraftSimRecipeDataCache.recipeInfoCache[crafterUID][self.recipeID]
        else
            -- otherwise save to cache
            CraftSimRecipeDataCache.recipeInfoCache[crafterUID][self.recipeID] = self.recipeInfo
        end
    else
        self.recipeInfo = CraftSimRecipeDataCache.recipeInfoCache[crafterUID][self.recipeID]
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

    if self.recipeInfo.hyperlink then
        local subclassID = select(7, GetItemInfoInstant(self.recipeInfo.hyperlink))
        ---@type number?
        self.subtypeID = subclassID
    end

    self.isOldWorldRecipe = not self:IsDragonflightRecipe()
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
    self.isEnchantingRecipe = self.recipeInfo.isEnchantingRecipe or false
    self.isCooking = self.professionData.professionInfo.profession == Enum.Profession.Cooking
    self.isSalvageRecipe = self.recipeInfo.isSalvageRecipe or false
    self.isAlchemicalExperimentation = tContains(CraftSim.CONST.ALCHEMICAL_EXPERIMENTATION_RECIPE_IDS, recipeID)
    ---@type string?
    self.allocationItemGUID = nil
    self.maxQuality = self.recipeInfo.maxQuality
    self.isGear = self.recipeInfo.hasSingleItemOutput and self.recipeInfo.qualityIlvlBonuses ~= nil

    self.supportsInspiration = false
    self.supportsMulticraft = false
    self.supportsResourcefulness = false
    self.supportsCraftingspeed = true -- this is always supported (but does not show in details UI when 0)

    if not self.isCooking then
        ---@type CraftSim.SpecializationData?
        self.specializationData = self:GetSpecializationDataForRecipeCrafter()
    end

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

    -- EXCEPTION for Sturdy Expedition Shovel - 388279
    -- Due to a blizzard bug the recipe's baseItemAmount is 2 although it only produces 1
    if self.recipeID == 388279 then
        self.baseItemAmount = 1
    end

    self.isSoulbound = (schematicInfo.outputItemID and GUTIL:isItemSoulbound(schematicInfo.outputItemID)) or
        false

    ---@type CraftSim.ProfessionGearSet
    self.professionGearSet = CraftSim.ProfessionGearSet(self)
    self.professionGearSet:LoadCurrentEquippedSet()

    CraftSim.UTIL:StartProfiling("- RD: OperationInfo")
    self.baseOperationInfo = nil
    if self.orderData then
        self.baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(self.recipeID, {},
            self.orderData.orderID)
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
    CraftSim.UTIL:StopProfiling("- RD: OperationInfo")

    -- exception: when salvage recipe, then resourcefulness is supported!
    if self.isSalvageRecipe then
        self.supportsResourcefulness = true
    end

    self.baseProfessionStats:SetInspirationBaseBonusSkill(self.baseProfessionStats.recipeDifficulty.value,
        self.maxQuality)

    CraftSim.UTIL:StartProfiling("- RD: ProfessionGearCache")
    -- cache available profession gear by calling this once
    CraftSim.TOPGEAR:GetProfessionGearFromInventory(self)
    CraftSim.UTIL:StopProfiling("- RD: ProfessionGearCache")

    self.baseProfessionStats:subtract(self.professionGearSet.professionStats)

    ---@type CraftSim.BuffData
    self.buffData = CraftSim.BuffData(self)
    -- no need to search for craft buffs when I am not even the crafter
    if self:IsCrafter() then
        self.buffData:Update()
    end

    self.baseProfessionStats:subtract(self.buffData.professionStats)
    -- As we dont know in this case what the factors are without gear and reagents and such
    -- we set them to 0 and let them accumulate in UpdateProfessionStats
    self.baseProfessionStats:ClearFactors()

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

    -- local print = CraftSim.UTIL:SetDebugPrint("RECIPE_SCAN")
    -- print("RecipeData: " .. self.recipeName)
    -- print("- isCrafter: " .. tostring(isCrafter))
    -- print("- IsProfessionOpen: " .. tostring(IsProfessionOpen))
    CraftSim.UTIL:StartProfiling("- RD: Cache Data")
    if isCrafter and IsProfessionOpen then
        -- print("- Caching Recipe!")
        CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID] = CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID] or {}
        CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID][self.professionData.professionInfo.profession] =
            CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID][self.professionData.professionInfo.profession] or {}
        table.insert(CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID][self.professionData.professionInfo.profession],
            self.recipeID)
        CraftSim.UTIL:StartProfiling("- RD: Cache Data To Set")
        CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID][self.professionData.professionInfo.profession] = GUTIL:ToSet(
            CraftSimRecipeDataCache.cachedRecipeIDs[crafterUID][self.professionData.professionInfo.profession])
        CraftSim.UTIL:StopProfiling("- RD: Cache Data To Set")

        CraftSim.UTIL:StartProfiling("- RD: Cache Data ClassApi")
        CraftSimRecipeDataCache.altClassCache[crafterUID] = select(2, UnitClass("player"))
        CraftSim.UTIL:StopProfiling("- RD: Cache Data ClassApi")

        CraftSim.UTIL:StopProfiling("- RD: Cache Data")
    end
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

function CraftSim.RecipeData:SetNonQualityReagentsMax()
    for _, reagent in pairs(self.reagentData.requiredReagents) do
        if not reagent.hasQuality then
            reagent.items[1].quantity = reagent.requiredQuantity
        end
    end
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

    -- since ooey gooey chocolate gives us math.huge on multicraft we need to limit it to 100%
    self.professionStats.multicraft.value = math.min(1 / CraftSim.CONST.PERCENT_MODS.MULTICRAFT,
        self.professionStats.multicraft.value)
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
    local copy = CraftSim.RecipeData(self.recipeID, self.isRecraft)
    copy.reagentData = self.reagentData:Copy(copy)
    copy.professionGearSet = self.professionGearSet:Copy()
    copy.professionStats = self.professionStats:Copy()
    copy.baseProfessionStats = self.baseProfessionStats:Copy()
    copy.professionStatModifiers = self.professionStatModifiers:Copy()
    copy.priceData = self.priceData:Copy(copy)   -- Is this needed or covered by constructor?
    copy.resultData = self.resultData:Copy(copy) -- Is this needed or covered by constructor?
    -- copy spec data or already handled in constructor?
    copy.orderData = self.orderData
    copy.crafter = self.crafter
    copy.crafterClass = self.crafterClass
    copy.crafterRealm = self.crafterRealm

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

---Optimizes the recipeData's reagents and gear for highest profit
function CraftSim.RecipeData:OptimizeProfit()
    self:OptimizeReagents()
    self:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
    -- need another because it could be that the optimized gear makes it possible to use cheaper reagents
    self:OptimizeReagents()
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

---@return boolean
function CraftSim.RecipeData:IsCrafter()
    local crafterDataEquals = self:CrafterDataEquals(CraftSim.UTIL:GetPlayerCrafterData())
    local professionLearned = C_TradeSkillUI.IsRecipeProfessionLearned(self.recipeID)
    -- local print = CraftSim.UTIL:SetDebugPrint("RECIPE_SCAN")
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
        jb:Add("skill", self.professionStats.skill.value)                     -- skill without reagent bonus TODO: if single export, consider removing reagent bonus
        jb:Add("difficulty", self.baseProfessionStats.recipeDifficulty.value) -- base difficulty (without optional reagents)
    end
    if self.supportsCraftingStats then
        if self.supportsMulticraft then
            if not self.supportsInspiration and not self.supportsResourcefulness then
                jb:Add("multicraft", professionStatsForExport.multicraft:GetPercent(true), true)
            else
                jb:Add("multicraft", professionStatsForExport.multicraft:GetPercent(true))
            end
        end
        if self.supportsInspiration then
            jb:Add("inspiration", professionStatsForExport.inspiration:GetPercent(true))
            if not self.supportsMulticraft and not self.supportsResourcefulness then
                jb:Add("inspirationSkill", self.professionStats.inspiration:GetExtraValueByFactor(), true)
            else
                jb:Add("inspirationSkill", self.professionStats.inspiration:GetExtraValueByFactor())
            end
        end
        if self.supportsResourcefulness then
            jb:Add("resourcefulness", professionStatsForExport.resourcefulness:GetPercent(true), true)
        end
    end
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
            C_TradeSkillUI.CraftEnchant(self.recipeID, amount, craftingReagentInfoTbl, vellumLocation)
        end
    else
        C_TradeSkillUI.CraftRecipe(self.recipeID, amount, craftingReagentInfoTbl)
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
    CraftSimRecipeDataCache.operationInfoCache[crafterUID] = CraftSimRecipeDataCache.operationInfoCache[crafterUID] or {}
    if not self:IsCrafter() then
        operationInfo = CraftSimRecipeDataCache.operationInfoCache[crafterUID][self.recipeID]

        if operationInfo then
            self.operationInfoCached = true
        else
            operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, {}, self.allocationItemGUID)
        end
    else
        operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, {}, self.allocationItemGUID)

        -- check for too early access?
        CraftSimRecipeDataCache.operationInfoCache[crafterUID][self.recipeID] = operationInfo
    end

    return operationInfo
end

---@return CraftSim.SpecializationData
function CraftSim.RecipeData:GetSpecializationDataForRecipeCrafter()
    local crafterUID = self:GetCrafterUID()

    CraftSimRecipeDataCache.specializationDataCache[crafterUID] = CraftSimRecipeDataCache.specializationDataCache
        [crafterUID] or {}

    if not self:IsCrafter() then
        local specializationDataSerialized = CraftSimRecipeDataCache.specializationDataCache[crafterUID][self.recipeID]
        if specializationDataSerialized then
            self.specializationDataCached = true
            return CraftSim.SpecializationData:Deserialize(specializationDataSerialized, self)
        end
        return CraftSim.SpecializationData(self) -- will initialize without stats and nodeinfo
    else
        local specializationData = CraftSim.SpecializationData(self)

        -- if too early, use cache
        if not self.isOldWorldRecipe and #specializationData.nodeData == 0 then
            local specializationDataSerialized = CraftSimRecipeDataCache.specializationDataCache[crafterUID]
                [self.recipeID]
            if specializationDataSerialized then
                specializationData = CraftSim.SpecializationData:Deserialize(specializationDataSerialized, self)
            end
        else
            -- cache it
            CraftSimRecipeDataCache.specializationDataCache[crafterUID][self.recipeID] = specializationData:Serialize()
        end

        return specializationData
    end
end

---@return CraftSim.CooldownData
function CraftSim.RecipeData:GetCooldownDataForRecipeCrafter()
    local crafterUID = self:GetCrafterUID()
    local cooldownData

    if self:IsCrafter() then
        cooldownData = CraftSim.CooldownData(self.recipeID)
        cooldownData:Update()

        -- cache only learned recipes from current expac that can be on cooldown
        if cooldownData.isCooldownRecipe and self.recipeInfo.learned and not self.isOldWorldRecipe then
            cooldownData:Save(crafterUID)
        end
    else
        cooldownData = CraftSim.CooldownData:DeserializeForCrafter(crafterUID, self.recipeID)
    end

    return cooldownData
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

function CraftSim.RecipeData:GetCrafterUID()
    return self.crafterData.name .. "-" .. self.crafterData.realm
end

---compares the given crafterData with the one from the recipe
---@param crafterData CraftSim.CrafterData
---@return boolean equals
function CraftSim.RecipeData:CrafterDataEquals(crafterData)
    local nameEquals = self.crafterData.name == crafterData.name
    local realmEquals = self.crafterData.realm == crafterData.realm
    local classEquals = self.crafterData.class == crafterData.class
    -- local print = CraftSim.UTIL:SetDebugPrint("RECIPE_SCAN")
    -- print("---nameEquals: " .. tostring(nameEquals))
    -- print("---realmEquals: " .. tostring(realmEquals))
    -- print("---classEquals: " .. tostring(classEquals))
    return nameEquals and realmEquals and classEquals
end

function CraftSim.RecipeData:IsDragonflightRecipe()
    local recipeInfo = self.recipeInfo
    if recipeInfo then
        local professionInfo = self.professionData.professionInfo
        local isDragonflightRecipe = professionInfo.professionID ==
            CraftSim.CONST.TRADESKILLLINEIDS[professionInfo.profession][CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT]
        return isDragonflightRecipe
    end

    return false
end
