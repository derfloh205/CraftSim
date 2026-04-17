---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

-- Memoization cache for expensive WoW API calls
local concentrationCostCache = {}
local concentrationCacheStats = { hits = 0, misses = 0 }

local Logger = CraftSim.DEBUG:RegisterLogger("RecipeData")

-- Helper function to generate cache key for UpdateConcentrationCost
---@param recipeData CraftSim.RecipeData
local function generateConcentrationCacheKey(recipeData)
    local parts = { tostring(recipeData.recipeID) }

    -- Add reagent configuration to key
    local requiredTbl = recipeData.reagentData:GetCraftingReagentInfoTbl()
    for reagentID, quantity in pairs(requiredTbl) do
        -- Handle case where quantity might be a table
        local quantityStr = (type(quantity) == "table") and tostring(quantity.quantity or quantity[1] or "0") or
            tostring(quantity)
        table.insert(parts, reagentID .. ":" .. quantityStr)
    end

    -- Add allocation GUID if present
    if recipeData.allocationItemGUID then
        table.insert(parts, tostring(recipeData.allocationItemGUID))
    end

    -- Add order ID if present
    if recipeData.orderData then
        table.insert(parts, "order:" .. tostring(recipeData.orderData.orderID))
    end

    -- Add profession tools
    if recipeData.professionGearSet then
        for nr, gear in ipairs(recipeData.professionGearSet:GetProfessionGearList()) do
            if gear.item then
                table.insert(parts, "tool" .. tostring(nr) .. ":" .. gear.item:GetItemLink())
            else
                table.insert(parts, "tool" .. tostring(nr) .. ":nil")
            end
        end
    end

    -- Add effective skill and recipe difficulty so the cache is invalidated when
    -- simulated skill changes (e.g. spec node adjustments, buff changes, manual modifiers)
    if recipeData.professionStats then
        if recipeData.professionStats.skill then
            table.insert(parts, "skill:" .. tostring(recipeData.professionStats.skill.value))
        end
        if recipeData.professionStats.recipeDifficulty then
            table.insert(parts, "difficulty:" .. tostring(recipeData.professionStats.recipeDifficulty.value))
        end
    end

    return table.concat(parts, "_")
end

---@class CraftSim.RecipeData : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.RecipeData.ConstructorOptions): CraftSim.RecipeData
CraftSim.RecipeData = CraftSim.CraftSimObject:extend()

-- Function to clear the concentration cost cache
function CraftSim.RecipeData.ClearConcentrationCostCache()
    concentrationCostCache = {}
    concentrationCacheStats = { hits = 0, misses = 0 }
end

-- Function to get cache statistics
function CraftSim.RecipeData.GetConcentrationCacheStats()
    return concentrationCacheStats
end

-- Function to report cache diagnostics
local function reportCacheDiagnostics()
    local skillStats = CraftSim.ReagentData.GetSkillCacheStats()
    local concentrationStats = CraftSim.RecipeData.GetConcentrationCacheStats()

    local skillTotal = skillStats.hits + skillStats.misses
    local concentrationTotal = concentrationStats.hits + concentrationStats.misses

    if skillTotal > 0 or concentrationTotal > 0 then
        if skillTotal > 0 then
            local skillHitRate = (skillStats.hits / skillTotal) * 100
            Logger:LogDebug(string.format("GetSkillFromRequiredReagents cache: %d/%d hits (%.1f%%)",
                skillStats.hits, skillTotal, skillHitRate))
        end

        if concentrationTotal > 0 then
            local concentrationHitRate = (concentrationStats.hits / concentrationTotal) * 100
            Logger:LogDebug(string.format("UpdateConcentrationCost cache: %d/%d hits (%.1f%%)",
                concentrationStats.hits, concentrationTotal, concentrationHitRate))
        end

        local totalHits = skillStats.hits + concentrationStats.hits
        local totalCalls = skillTotal + concentrationTotal
        if totalCalls > 0 then
            local overallHitRate = (totalHits / totalCalls) * 100
            Logger:LogDebug(string.format("Overall cache performance: %d/%d hits (%.1f%%)", totalHits, totalCalls,
                overallHitRate))
        end
    end
end

---@class CraftSim.RecipeData.ConstructorOptions
---@field recipeID RecipeID
---@field isRecraft? boolean default: false
---@field isWorkOrder? boolean default: false
---@field orderData? CraftingOrderInfo
---@field crafterData? CraftSim.CrafterData default: current player character
---@field forceCache? boolean forces the use of all cached data (e.g. when restoring craft queue list)

---@class CraftSim.CrafterData
---@field name string
---@field realm string
---@field class ClassFile?

---@param options CraftSim.RecipeData.ConstructorOptions
---@return CraftSim.RecipeData?
function CraftSim.RecipeData:new(options)
    if not options or type(options) ~= 'table' then
        error("CraftSim Error: RecipeData -> No Constructor Options")
    end
    local recipeID = options.recipeID
    local isRecraft = options.isRecraft or false
    local isWorkOrder = options.isWorkOrder or false
    local orderData = options.orderData
    local forceCache = options.forceCache or false

    self.recipeID = recipeID --[[@as RecipeID]]
    self.craftListID = 0 -- default

    -- important to set first so self:IsCrafter() can be used
    self.crafterData = options.crafterData or CraftSim.UTIL:GetPlayerCrafterData()

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
    self.professionData = CraftSim.ProfessionData({ recipeData = self, forceCache = forceCache })
    self.professionInfoCached = self.professionData.professionInfoCached
    self.supportsSpecializations = C_ProfSpecs.SkillLineHasSpecialization(self.professionData.skillLineID)

    self.expansionID = CraftSim.UTIL:GetExpansionIDBySkillLineID(self.professionData.skillLineID)

    -- Delay setting order data until after reagent slots exist (reagentData is created later),
    -- so we can apply optional/finishing reagents from the order immediately.
    local pendingOrderData = orderData
    if isWorkOrder then
        ---@type CraftingOrderInfo
        pendingOrderData = ProfessionsFrame.OrdersPage.OrderView.order
        Logger:LogDebug("Craft Order Data:")
        Logger:LogDebug(pendingOrderData, true)
    end

    if self:IsCrafter() and not forceCache then
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
        Logger:LogDebug("Could not create recipeData: recipeInfo nil")
        return nil
    end

    self.isBaseRecraftRecipe = self.recipeInfo.isRecraft and not self.recipeInfo.hasSingleItemOutput
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
        Logger:LogDebug("No RecipeData created: SchematicInfo not found")
        return
    end

    ---@type CraftSim.ReagentData
    self.reagentData = CraftSim.ReagentData(self, schematicInfo)

    if pendingOrderData then
        self:SetOrder(pendingOrderData)
    end

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
        self.baseOperationInfo = self:GetCraftingOperationInfoForRecipeCrafter(forceCache)
    end
    CraftSim.DEBUG:StopProfiling("- RD: OperationInfo")

    ---@type CraftSim.ProfessionStats
    self.baseProfessionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.professionStats = CraftSim.ProfessionStats()
    ---@type CraftSim.ProfessionStats
    self.professionStatModifiers = CraftSim.ProfessionStats()

    self:ApplyBaseProfessionStatsFromOperationInfo(forceCache)

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
    -- Logger:LogDebug("RecipeData: " .. self.recipeName)
    -- Logger:LogDebug("- isCrafter: " .. tostring(isCrafter))
    -- Logger:LogDebug("- IsProfessionOpen: " .. tostring(IsProfessionOpen))
    CraftSim.DEBUG:StartProfiling("- RD: Cache Data")
    if isCrafter and IsProfessionOpen and self.learned then
        -- Logger:LogDebug("- Caching Recipe!")
        CraftSim.DB.CRAFTER:AddCachedRecipeID(crafterUID, self.professionData.professionInfo.profession, self.recipeID)

        CraftSim.DEBUG:StartProfiling("- RD: Cache Data ClassApi")
        CraftSim.DB.CRAFTER:SaveClass(crafterUID, select(2, UnitClass("player")))
        CraftSim.DEBUG:StopProfiling("- RD: Cache Data ClassApi")

        CraftSim.DEBUG:StopProfiling("- RD: Cache Data")
    end
end

--- Rebuild base profession stats from `self.baseOperationInfo` (gear/buff stripped, extras cleared),
--- salvage and work-order multicraft rules applied. Caller must set `baseOperationInfo` first.
---@param forceCache boolean? passed to GetProfessionGearFromInventory on first-style init
function CraftSim.RecipeData:ApplyBaseProfessionStatsFromOperationInfo(forceCache)
    if not self.baseProfessionStats or not self.baseOperationInfo then
        return
    end
    forceCache = forceCache or false

    self.supportsMulticraft = false
    self.supportsResourcefulness = false
    self.supportsIngenuity = false

    self.baseProfessionStats:Clear()
    self.baseProfessionStats:SetStatsByOperationInfo(self, self.baseOperationInfo)

    if self.supportsIngenuity and self.supportsSpecializations then
        self.concentrationData = self:GetConcentrationDataForCrafter()
    end

    if self.professionData:UsesGear() then
        CraftSim.DEBUG:StartProfiling("- RD: ProfessionGearCache")
        CraftSim.TOPGEAR:GetProfessionGearFromInventory(self, forceCache)
        CraftSim.DEBUG:StopProfiling("- RD: ProfessionGearCache")

        self.baseProfessionStats:subtract(self.professionGearSet.professionStats)
    end

    self.baseProfessionStats:subtract(self.buffData.professionStats)
    self.baseProfessionStats:ClearExtraValues()

    if self.isSalvageRecipe then
        self.supportsResourcefulness = true
        if self.specializationData then
            self.baseProfessionStats.resourcefulness.value = self.specializationData.professionStats.resourcefulness
                .value
        else
            self.baseProfessionStats.resourcefulness.value = 0
        end
    end

    if self.orderData then
        self.supportsMulticraft = false
        self.baseProfessionStats.multicraft:Clear()
    end
end

---@param orderData CraftingOrderInfo
function CraftSim.RecipeData:SetOrder(orderData)
    self.orderData = GUTIL:CopyTableDeep(orderData or {}) -- avoid taint
    self.isRecraft = self.orderData.isRecraft
    self.baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(self.recipeID, {},
        self.orderData.orderID, self.concentrating)
    self:ApplyOrderReagentsToSlots()
    if self.baseProfessionStats then
        self:ApplyBaseProfessionStatsFromOperationInfo(false)
        self:Update()
    end
end

---@param reagentInfo table
---@return number? dataSlotIndex
---@return number? itemID
---@return number? currencyID
function CraftSim.RecipeData:ExtractOrderReagentInfo(reagentInfo)
    local d = self:GetOrderReagentDescriptor(reagentInfo)
    return d.dataSlotIndex, d.itemID, d.currencyID
end

--- Applies optional/finishing/required-selectable reagents from `orderData.reagents` to the recipe's slots.
--- This ensures queued orders always reflect customer-provided optionals (guild/personal/work orders).
function CraftSim.RecipeData:ApplyOrderReagentsToSlots()
    if not (self.orderData and self.orderData.reagents and #self.orderData.reagents > 0) then
        return
    end

    local reagentData = self.reagentData
    if not reagentData then
        return
    end

    reagentData:ClearOptionalReagents()
    if reagentData:HasRequiredSelectableReagent() then
        reagentData.requiredSelectableReagentSlot.activeReagent = nil
    end

    local orderedSlots = reagentData:GetOrderedOptionalSlots()
    local slotsByDataSlotIndex = {}
    for _, slot in ipairs(orderedSlots) do
        if slot.dataSlotIndex then
            slotsByDataSlotIndex[slot.dataSlotIndex] = slot
        end
    end

    for i, reagentInfo in ipairs(self.orderData.reagents) do
        local dataSlotIndex, itemID, currencyID = self:ExtractOrderReagentInfo(reagentInfo)

        local slot = (dataSlotIndex and slotsByDataSlotIndex[dataSlotIndex]) or orderedSlots[i]
        if slot then
            slot:TryApplyOrderReagent(itemID, currencyID)
        end
    end
end

function CraftSim.RecipeData:SetSubRecipeCostsUsage(enabled)
    self.subRecipeCostsEnabled = enabled
end

---@param reagentList CraftSim.ReagentListItem[]
function CraftSim.RecipeData:SetReagents(reagentList)
    -- go through required reagents and set quantity accordingly

    self.reagentData:ClearRequiredReagents()
    self:SetNonQualityReagentsMax()

    for _, reagent in ipairs(self.reagentData.requiredReagents) do
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
    local optionalReagentIDs = {}
    local currencyReagentIDs = {}
    local requiredReagents = {}

    for _, craftingReagentInfo in ipairs(craftingReagentInfoTbl) do
        if craftingReagentInfo.reagent.currencyID then
            table.insert(currencyReagentIDs, craftingReagentInfo.reagent.currencyID)
        elseif craftingReagentInfo.reagent.itemID and CraftSim.OPTIONAL_REAGENT_DATA[craftingReagentInfo.reagent.itemID] then
            table.insert(optionalReagentIDs, craftingReagentInfo.reagent.itemID)
        else
            table.insert(requiredReagents, craftingReagentInfo)
        end
    end

    for _, currencyID in ipairs(currencyReagentIDs) do
        self.reagentData:SetOptionalCurrencyReagent(currencyID)
    end

    self:SetOptionalReagents(optionalReagentIDs)
    local reagentListItems = GUTIL:Map(requiredReagents, function(craftingReagentInfo)
        return CraftSim.ReagentListItem(craftingReagentInfo.reagent.itemID, craftingReagentInfo.quantity,
            craftingReagentInfo.reagent.currencyID)
    end)

    self:SetReagents(reagentListItems)
end

---@param itemID number
function CraftSim.RecipeData:SetSalvageItem(itemID)
    if self.isSalvageRecipe then
        self.reagentData.salvageReagentSlot:SetItem(itemID)
        local itemLocation = GUTIL:GetItemLocationFromItemID(itemID, true)
        if itemLocation then
            ---@cast itemLocation ItemLocation
            local item = Item:CreateFromItemLocation(itemLocation)
            if item then
                self.allocationItemGUID = Item:CreateFromItemLocation(itemLocation):GetItemGUID()
            end
        end
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
            self.allocationItemGUID = salvageAllocation:GetItemGUID()
            self.reagentData.salvageReagentSlot.requiredQuantity = schematicForm.salvageSlot.quantityRequired
        elseif not schematicForm.salvageSlot then
            error("CraftSim RecipeData Error: Salvage Recipe without salvageSlot")
        end
    end

    local currentOptionalReagent = 1
    local currentFinishingReagent = 1

    for slotIndex, currentSlot in pairs(schematicInfo.reagentSlotSchematics) do
        local reagentType = currentSlot.reagentType
        local hasCurrencyReagent = currentSlot.reagents[1] and currentSlot.reagents[1].currencyID ~= nil

        if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
            local slotAllocations = currentTransaction:GetAllocations(slotIndex)

            for i, reagent in pairs(currentSlot.reagents) do
                local reagentAllocation = (slotAllocations and slotAllocations:FindAllocationByReagent(reagent)) or nil
                local allocations = 0
                if reagentAllocation ~= nil then
                    allocations = reagentAllocation:GetQuantity()
                    Logger:LogDebug("reagent #" .. i .. " allocation:", false, true)
                    Logger:LogDebug(reagentAllocation, true)
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
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL or hasCurrencyReagent then
            if hasCurrencyReagent then
                local slotAllocations = currentTransaction:GetAllocations(slotIndex)
                if slotAllocations then
                    for _, reagent in pairs(currentSlot.reagents) do
                        if reagent.currencyID then
                            local allocation = slotAllocations:FindAllocationByReagent(reagent)
                            if allocation and allocation:GetQuantity() > 0 then
                                self.reagentData:SetOptionalCurrencyReagent(reagent.currencyID)
                                break
                            end
                        end
                    end
                end
                currentOptionalReagent = currentOptionalReagent + 1
            elseif currentSlot.required then
                local requiredSelectableReagentSlot = reagentSlots[1][1]
                local button = requiredSelectableReagentSlot.Button
                local allocatedItemID = button:GetItemID()
                if allocatedItemID then
                    self.reagentData.requiredSelectableReagentSlot:SetReagent(allocatedItemID)
                end
            elseif reagentSlots[reagentType] ~= nil then
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
    for _, itemID in pairs(itemIDList) do
        self:SetOptionalReagent(itemID)
    end
    self:Update()
end

--- also sets a requiredSelectionReagent if not yet set
function CraftSim.RecipeData:SetNonQualityReagentsMax()
    Logger:LogDebug("SetNonQualityReagentsMax", false, true)
    for _, reagent in pairs(self.reagentData.requiredReagents) do
        if not reagent.hasQuality then
            reagent.items[1].quantity = reagent.requiredQuantity
        end
    end

    if self.reagentData:HasRequiredSelectableReagent() then
        Logger:LogDebug("- HasRequiredSelectableReagent", false, false)
        if not self.reagentData.requiredSelectableReagentSlot.activeReagent then
            Logger:LogDebug("- No active reagent", false, false)
            if self.reagentData.requiredSelectableReagentSlot:IsCurrency() then
                local firstReagent = self.reagentData.requiredSelectableReagentSlot.possibleReagents[1]
                if firstReagent then
                    self.reagentData.requiredSelectableReagentSlot:SetCurrencyReagent(firstReagent.currencyID)
                end
            else
                local orderReagent = GUTIL:Find(self.reagentData.requiredSelectableReagentSlot.possibleReagents or {},
                    function(possibleOrderReagent)
                        if possibleOrderReagent:IsCurrency() then return false end
                        if possibleOrderReagent:IsOrderReagentIn(self) then
                            return true
                        end
                        return false
                    end)
                if orderReagent then
                    self.reagentData.requiredSelectableReagentSlot:SetReagent(orderReagent.item:GetItemID())
                else
                    local cheapestReagent
                    local cheapestPrice
                    local possibleReagents = GUTIL:Filter(
                        self.reagentData.requiredSelectableReagentSlot.possibleReagents or {}, function(optionalReagent)
                            if optionalReagent:IsCurrency() then return false end
                            return not GUTIL:isItemSoulbound(optionalReagent.item:GetItemID())
                        end)
                    -- if every possible reagent is soulbound, enforce first one
                    if #possibleReagents == 0 then
                        cheapestReagent = self.reagentData.requiredSelectableReagentSlot.possibleReagents[1]
                    else -- else search for cheapest
                        for _, optionalReagent in ipairs(possibleReagents) do
                            local reagentPrice = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(
                                optionalReagent.item:GetItemID(),
                                true, false, true)
                            if not cheapestReagent then
                                cheapestReagent = optionalReagent
                                cheapestPrice = reagentPrice
                            else
                                if reagentPrice < cheapestPrice then
                                    cheapestPrice = reagentPrice
                                    cheapestReagent = optionalReagent
                                end
                            end
                        end
                    end

                    if cheapestReagent then
                        self.reagentData.requiredSelectableReagentSlot:SetReagent(cheapestReagent.item:GetItemID())
                    end
                end
            end
        end
    end
end

---@return boolean hasRequiredSelectableReagent
function CraftSim.RecipeData:HasRequiredSelectableReagent()
    return self.reagentData:HasRequiredSelectableReagent()
end

--- Consideres Order Reagents
---@param nonAllocatedOnly boolean?
function CraftSim.RecipeData:SetCheapestQualityReagentsMax(nonAllocatedOnly)
    for _, reagent in ipairs(self.reagentData.requiredReagents) do
        local isOrderReagent = reagent:IsOrderReagentIn(self)
        if reagent.hasQuality then
            if not isOrderReagent then
                if not nonAllocatedOnly and reagent:GetTotalQuantity() < reagent.requiredQuantity then
                    reagent:SetCheapestQualityMax(self.subRecipeCostsEnabled)
                end
            elseif isOrderReagent then
                for _, reagentItem in ipairs(reagent.items) do
                    if reagentItem:IsOrderReagentIn(self) then
                        reagentItem.quantity = reagent.requiredQuantity
                    else
                        reagentItem.quantity = 0
                    end
                end
            end
        end
    end
end

---@param playerSkill number
---@param noRounding boolean?
function CraftSim.RecipeData:GetConcentrationCostForSkill(playerSkill, noRounding)
    -- get skill bracket and associated start and end skillCurveValues
    local recipeDifficulty = self.professionStats.recipeDifficulty.value
    playerSkill = math.min(playerSkill, recipeDifficulty) -- cap skill at max difficulty
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
        { lessConcentrationFactorSpecs, lessConcentrationFactorOptionals, lessConcentrationFactorGear }, noRounding)
end

---@return number concentrationCost
function CraftSim.RecipeData:UpdateConcentrationCost()
    if not self.baseOperationInfo then return 0 end

    local craftingDataID = self.baseOperationInfo.craftingDataID
    self.concentrationCurveData = CraftSim.CONCENTRATION_CURVE_DATA[craftingDataID]

    -- Check cache first
    local cacheKey = generateConcentrationCacheKey(self)
    local cachedResult = concentrationCostCache[cacheKey]
    if cachedResult then
        concentrationCacheStats.hits = concentrationCacheStats.hits + 1
        return cachedResult
    end

    concentrationCacheStats.misses = concentrationCacheStats.misses + 1

    -- try to only enable it for simulation mode or if its not the current character
    if self.concentrationCurveData and (CraftSim.SIMULATION_MODE.isActive or not self:IsCrafter()) then
        local result = self:GetConcentrationCostForSkill(self.professionStats.skill.value)

        -- Cache the result
        concentrationCostCache[cacheKey] = result

        return result
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

        local result = (operationInfo and operationInfo.concentrationCost) or 0
        -- Cache the result
        concentrationCostCache[cacheKey] = result
        return result
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
    self.professionStats.multicraft.value = math.min(self.professionStats.multicraft.percentDivisionFactor,
        self.professionStats.multicraft.value)

    if not self.supportsMulticraft then
        self.professionStats.multicraft:Clear()
    end

    if self.supportsQualities then
        self.concentrationCost = self:UpdateConcentrationCost()
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
    local copy = CraftSim.RecipeData({
        recipeID = self.recipeID,
        orderData = self.orderData,
        isRecraft = self.isRecraft,
        crafterData = self.crafterData,
    })

    copy.allocationItemGUID = self.allocationItemGUID
    copy.craftListID = self.craftListID

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

---@class CraftSim.RecipeData.OptimizeReagentOptions
---@field maxQuality number? default: max of recipe
---@field highestProfit boolean? default: false

--- Optimizes the recipeData's reagents for highest quality / cheapest reagents.
---@param options CraftSim.RecipeData.OptimizeReagentOptions?
function CraftSim.RecipeData:OptimizeReagents(options)
    -- Clear API call caches at the start of optimization
    CraftSim.RecipeData.ClearConcentrationCostCache()
    CraftSim.ReagentData.ClearSkillFromReagentsCache()

    options = options or {}
    options.maxQuality = options.maxQuality or self.maxQuality
    options.highestProfit = options.highestProfit or false

    -- do not optimize quest recipes
    if self.isQuestRecipe then
        -- Clear caches before early return
        CraftSim.RecipeData.ClearConcentrationCostCache()
        CraftSim.ReagentData.ClearSkillFromReagentsCache()
        return
    end

    if not self.supportsQualities then
        self:SetCheapestQualityReagentsMax()
        -- Clear caches before early return
        CraftSim.RecipeData.ClearConcentrationCostCache()
        CraftSim.ReagentData.ClearSkillFromReagentsCache()
        return
    end

    local optimizationResult

    if options.highestProfit then
        local optimizationResults = {}

        for i = 1, options.maxQuality, 1 do
            local qualityOptimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(self, i)

            self.reagentData:SetReagentsByOptimizationResult(qualityOptimizationResult)
            self:Update()

            tinsert(optimizationResults, {
                result = qualityOptimizationResult,
                averageProfit = self.averageProfitCached
            })
        end

        -- CraftSim.DEBUG:InspectTable(optimizationResults, "optimizationResults")

        local bestOptimizationResult = GUTIL:Fold(optimizationResults, optimizationResults[1],
            function(highestProfitResult, nextResult, qualityID)
                if highestProfitResult.averageProfit >= nextResult.averageProfit then
                    return highestProfitResult
                else
                    return nextResult
                end
            end)
        optimizationResult = bestOptimizationResult.result
    else
        optimizationResult = CraftSim.REAGENT_OPTIMIZATION:OptimizeReagentAllocation(self, options.maxQuality)
    end

    self.reagentData:SetReagentsByOptimizationResult(optimizationResult)
    self:Update()

    -- Report cache performance before clearing
    reportCacheDiagnostics()

    -- Clear API call caches at the end of optimization
    CraftSim.RecipeData.ClearConcentrationCostCache()
    CraftSim.ReagentData.ClearSkillFromReagentsCache()

    -- CraftSim.DEBUG:InspectTable({
    --     optimizationResult = optimizationResult,
    --     highestProfit = self.averageProfitCached,
    -- }, "qualityOptimizationResult CHOSEN")
end

---@return table<ItemID, number>
function CraftSim.RecipeData:GetSkillContributionMap()
    local skillContributionMap = {}
    local reagentDataCopy = self.reagentData:Copy(self)
    reagentDataCopy:SetReagentsMaxByQuality(1)
    local craftingReagentInfoTblQ1 = reagentDataCopy:GetRequiredCraftingReagentInfoTbl()
    local baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, craftingReagentInfoTblQ1,
        self.allocationItemGUID, false)

    --- Consider Midnight Recipe Reagent Quality Change
    local reagentsMaxQuality = self:IsSimplifiedQualityRecipe() and 2 or 3
    if not baseOperationInfo then return {} end

    for reagentIndexA, reagent in ipairs(self.reagentData.requiredReagents) do
        if reagent.hasQuality then
            skillContributionMap[reagent.items[1].item:GetItemID()] = 0

            for i = 2, reagentsMaxQuality, 1 do
                local craftingReagentInfoTbl = {}
                for reagentIndexB, r in ipairs(self.reagentData.requiredReagents) do
                    if r.hasQuality then
                        local craftingReagentInfos = r:GetCraftingReagentInfos()
                        craftingReagentInfos[1].quantity = r.requiredQuantity
                        for j = 2, reagentsMaxQuality, 1 do
                            craftingReagentInfos[j].quantity = 0
                        end

                        if reagentIndexA == reagentIndexB then
                            craftingReagentInfos[1].quantity = 0
                            craftingReagentInfos[i].quantity = r.requiredQuantity
                        end
                        tAppendAll(craftingReagentInfoTbl, craftingReagentInfos)
                    end
                end
                local operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.recipeID, craftingReagentInfoTbl,
                    self.allocationItemGUID, false)
                if operationInfo then
                    local currentSkill = baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill
                    local newSkill = operationInfo.baseSkill + operationInfo.bonusSkill
                    local skillDiff = newSkill - currentSkill
                    local skillPerItem = skillDiff / reagent.requiredQuantity

                    skillContributionMap[reagent.items[i].item:GetItemID()] = skillPerItem
                end
            end
        end
    end

    return skillContributionMap
end

---@class CraftSim.RecipeData.OptimizeConcentration.Options
---@field finally function callback will be called when finished
---@field progressUpdateCallback? fun(progress: number) if set, is called on progress updates during calculation process

--- Optimizes gold value per concentration point sync or async
---@async
---@param options CraftSim.RecipeData.OptimizeConcentration.Options?
function CraftSim.RecipeData:OptimizeConcentration(options)
    options = options or {}
    -- for each reagent, find its lowest "quality upgrade" costs per skill point

    if not self.supportsQualities then return end

    local skillContributionMap = self:GetSkillContributionMap()

    local qualityReagents = GUTIL:Filter(self.reagentData.requiredReagents, function(reagent)
        return reagent.hasQuality and not reagent:IsOrderReagentIn(self)
    end)

    local isSimplifiedQualityRecipe = self:IsSimplifiedQualityRecipe()

    -- Pre-calc total convertible units for progress: sum of q1 + q2 (since q3 is terminal)
    local totalConvertible = 0

    if isSimplifiedQualityRecipe then
        -- For simplified quality recipes, only q1->q2 upgrades are possible, so we only count q1 quantities
        for _, r in ipairs(qualityReagents) do
            totalConvertible = totalConvertible + r.items[1].quantity
        end
    else
        for _, r in ipairs(qualityReagents) do
            totalConvertible = totalConvertible + r.items[1].quantity + r.items[2].quantity
        end
    end
    --- used for progress update callback
    local convertedUnits = 0

    -- Helper to compute best upgrade (single unit) each selection
    local function findBestUpgrade()
        local skillPerConcentrationPoint = self:GetConcentrationPointsPerSkill()
        local best
        for _, reagent in ipairs(qualityReagents) do
            -- Q1->Q2
            local q1 = reagent.items[1].quantity
            if q1 > 0 then
                local itemID1 = reagent.items[1].item:GetItemID()
                local itemID2 = reagent.items[2].item:GetItemID()
                local price1 = self.priceData.reagentPriceInfos[itemID1].itemPrice
                local price2 = self.priceData.reagentPriceInfos[itemID2].itemPrice
                local skill1 = skillContributionMap[itemID1]
                local skill2 = skillContributionMap[itemID2]
                local skillDiff = skill2 - skill1
                local costDiff = price2 - price1
                local costPerSkill = costDiff / skillDiff
                local costPerConcPoint = costPerSkill * skillPerConcentrationPoint
                if not best or costPerConcPoint < best.costPerConcPoint then
                    best = {
                        reagent = reagent,
                        fromQ = 1,
                        toQ = 2,
                        costPerConcPoint = costPerConcPoint,
                        available = q1
                    }
                end
            end
            -- Q2->Q3
            local q2 = reagent.items[2].quantity
            local q3 = reagent.items[3].quantity
            if q2 > 0 and q3 < reagent.requiredQuantity then
                local itemID2 = reagent.items[2].item:GetItemID()
                local itemID3 = reagent.items[3].item:GetItemID()
                local price2 = self.priceData.reagentPriceInfos[itemID2].itemPrice
                local price3 = self.priceData.reagentPriceInfos[itemID3].itemPrice
                local skill2 = skillContributionMap[itemID2]
                local skill3 = skillContributionMap[itemID3]
                local skillDiff = skill3 - skill2
                local costDiff = price3 - price2
                local costPerSkill = costDiff / skillDiff
                local costPerConcPoint = costPerSkill * skillPerConcentrationPoint
                if not best or costPerConcPoint < best.costPerConcPoint then
                    best = {
                        reagent = reagent,
                        fromQ = 2,
                        toQ = 3,
                        costPerConcPoint = costPerConcPoint,
                        available = q2,
                        space = reagent.requiredQuantity - q3
                    }
                end
            end
        end
        return best
    end

    local function findBestUpgradeSimplified()
        local skillPerConcentrationPoint = self:GetConcentrationPointsPerSkill()
        local best
        for _, reagent in ipairs(qualityReagents) do
            -- Q1->Q2
            local q1 = reagent.items[1].quantity
            if q1 > 0 then
                local itemID1 = reagent.items[1].item:GetItemID()
                local itemID2 = reagent.items[2].item:GetItemID()
                local price1 = self.priceData.reagentPriceInfos[itemID1].itemPrice
                local price2 = self.priceData.reagentPriceInfos[itemID2].itemPrice
                local skill1 = skillContributionMap[itemID1]
                local skill2 = skillContributionMap[itemID2]
                local skillDiff = skill2 - skill1
                local costDiff = price2 - price1
                local costPerSkill = costDiff / skillDiff
                local costPerConcPoint = costPerSkill * skillPerConcentrationPoint
                if not best or costPerConcPoint < best.costPerConcPoint then
                    best = {
                        reagent = reagent,
                        fromQ = 1,
                        toQ = 2,
                        costPerConcPoint = costPerConcPoint,
                        available = q1
                    }
                end
            end
        end
        return best
    end

    CraftSim.DEBUG:StartProfiling("ConcentrationOptimization")

    local MAX_UNITS_PER_FRAME = 1

    GUTIL.FrameDistributor {
        --maxIterations = 1500,
        iterationsPerFrame = 1,
        finally = function()
            if options.finally then
                options.finally()
            end
            local ms = CraftSim.DEBUG:StopProfiling("ConcentrationOptimization")
            Logger:LogDebug("Concentration Optimization completed in " .. ms .. " ms", true, true)
        end,
        continue = function(frameDistributor, key, value, currentIteration)
            local concentrationValue = self:GetConcentrationValue()
            -- Save the pre-upgrade concentration value so we can detect whether a
            -- bracket-boundary crossing (concentration cost jump) was still beneficial.
            local lastConcentrationValue = concentrationValue
            local lastProfit = self.averageProfitCached
            local lastConcentrationCost = self:GetConcentrationCostForSkill(self.professionStats.skill.value, true)
            local lastCraftingReagentInfoTbl = self.reagentData:GetRequiredCraftingReagentInfoTbl()

            local function Rollback()
                self:SetReagentsByCraftingReagentInfoTbl(lastCraftingReagentInfoTbl)
                self:Update()
            end

            --local unitsBudget = MAX_UNITS_PER_FRAME
            -- used to check if any upgrade was performed this iteration
            local performed = 0

            Logger:LogDebug("Starting Concentration Optimization Iteration #" .. currentIteration)

            -- Shared helper: apply a reagent quality conversion and update tracking variables.
            local function applyConversion(upgrade, units)
                upgrade.reagent.items[upgrade.fromQ].quantity = upgrade.reagent.items[upgrade.fromQ].quantity - units
                upgrade.reagent.items[upgrade.toQ].quantity   = upgrade.reagent.items[upgrade.toQ].quantity + units
                performed                                     = performed + units
                convertedUnits                                = convertedUnits + units
            end

            local boughtConcentration = 0
            repeat
                local best
                if isSimplifiedQualityRecipe then
                    best = findBestUpgradeSimplified()
                    --CraftSim.DEBUG:InspectTable(best, "Best Upgrade Simplified #" .. currentIteration)
                else
                    best = findBestUpgrade()
                end

                -- Not able to upgrade anymore (all reagents max quality)
                if not best then break end

                local maxUnits = best.available
                if best.toQ == 3 and best.space then
                    maxUnits = math.min(maxUnits, best.space)
                end

                local units = 1

                Logger:LogDebug("- Converting " ..
                    math.min(best.available, units) ..
                    " x " .. best.reagent.items[1].item:GetItemLink() .. " It: #" .. currentIteration)
                applyConversion(best, units)
                -- update recipe stats based on new skill from reagent allocation after conversion
                -- so concentration costs are updated
                self:Update()
                local currentConcentrationCost = self:GetConcentrationCostForSkill(self.professionStats.skill.value, true)
                boughtConcentration = lastConcentrationCost - currentConcentrationCost
                Logger:LogDebug("-- BoughtConcentration: " .. boughtConcentration)
            until boughtConcentration >= 1

            -- update concentration value after conversion for 1 cost reduction was done
            local concentrationValue = self:GetConcentrationValue()

            -- For simplified quality recipes (Midnight), the greedy pre-upgrade concentration
            -- value check in the loop above can miss the last beneficial upgrade: each Q1->Q2
            -- conversion reduces concentration cost, raising the post-upgrade CV above the
            -- pre-upgrade CV used in the check. When no upgrade passed the pre-upgrade
            -- threshold, attempt the cheapest available upgrade as a threshold test and let
            -- the post-check below decide using the actual post-upgrade CV.
            if performed == 0 then
                local best
                if isSimplifiedQualityRecipe then
                    best = findBestUpgradeSimplified()
                else
                    best = findBestUpgrade()
                end
                if best then
                    Logger:LogDebug("- No upgrades passed pre-upgrade CV check, testing cheapest upgrade anyway")
                    applyConversion(best, math.min(best.available, MAX_UNITS_PER_FRAME))
                end
            end

            if performed == 0 then
                Logger:LogDebug("- No beneficial upgrades found, ending optimization")
                frameDistributor:Break()
                return
            end

            -- Post-check economic viability (average cost per concentration purchased this frame)
            if boughtConcentration <= 0 then
                -- Concentration cost increased rather than decreased.  This can happen when
                -- a skill-bracket boundary is crossed (the concentration curve has upward
                -- jumps at certain skill thresholds).  Check whether the upgrade still
                -- improved the overall concentration value (e.g. by enabling a higher output
                -- quality).  If it did, continue optimising in the new bracket; otherwise
                -- roll back and stop.
                if concentrationValue > lastConcentrationValue then
                    frameDistributor:Continue()
                else
                    Logger:LogDebug(
                        "- Upgrade crossed a concentration bracket boundary but did not improve concentration value, rolling back")
                    Rollback()
                    frameDistributor:Break()
                end
                return
            end

            -- if we did not decrease the cost by at least 1 roll back
            -- this can happen when the repeat until breaks early due to not being able to upgrade anymore
            -- or if the last possible upgrades are not enough to lessen concentration costs by at least 1
            if boughtConcentration < 1 then
                Logger:LogDebug("- Upgrade did not decrease concentration cost, rolling back (Bought: " ..
                    boughtConcentration .. ")")
                Rollback()
                frameDistributor:Break()
                return
            end

            -- if we did not increase the value, roll back
            if concentrationValue <= lastConcentrationValue then
                Logger:LogDebug("- Upgrade did not increase concentration value, rolling back (Value: " ..
                    concentrationValue .. ", Last: " .. lastConcentrationValue .. ")")
                Rollback()
                frameDistributor:Break()
                return
            end

            if options.progressUpdateCallback and totalConvertible > 0 then
                options.progressUpdateCallback(math.min(1, convertedUnits / totalConvertible))
            end
            frameDistributor:Continue()
        end
    }:Continue()
end

---@class CraftSim.RecipeData.OptimizeFinishingReagents.Options
---@field includeLocked? boolean
---@field includeSoulbound? boolean
---@field onlyHighestQualitySoulbound? boolean when true, only the highest-value soulbound reagent(s) available per slot are considered (requires includeSoulbound=true); value is determined by the sum of all profession stat values provided by the reagent
---@field finally? function callback will be called when finished
---@field progressUpdateCallback? fun(progress: number) if set, is called on progress updates during calculation process
---@field permutationBased? boolean when true, use permutation-based algorithm (all combinations)
---@field optimizeReagentOptions? CraftSim.RecipeData.OptimizeReagentOptions only used when permutationBased=true
---@field optimizeConcentration? boolean only used when permutationBased=true

---@param options CraftSim.RecipeData.OptimizeFinishingReagents.Options
function CraftSim.RecipeData:OptimizeFinishingReagents(options)
    options = options or {}

    local reagentData = self.reagentData

    if #reagentData.finishingReagentSlots == 0 then
        options.finally()
        return
    end

    for _, slot in ipairs(reagentData.finishingReagentSlots) do
        slot:SetReagent(nil)
    end
    self:Update()

    local totalPossibleItems = GUTIL:Fold(reagentData.finishingReagentSlots, 0, function(total, nextSlot)
        return total + #nextSlot.possibleReagents
    end)
    local currentItemCount = 0

    local percentStep = totalPossibleItems / 100

    -- workaround to first process the skill increase reagents
    local slotsReversed = {}
    if #reagentData.finishingReagentSlots == 2 then
        slotsReversed = {
            reagentData.finishingReagentSlots[2],
            reagentData.finishingReagentSlots[1],
        }
    else
        slotsReversed = reagentData.finishingReagentSlots
    end

    GUTIL.FrameDistributor {
        iterationTable = slotsReversed,
        iterationsPerFrame = 1,
        finally = function()
            options.finally()
        end,
        continue = function(frameDistributor, _, slot, _, _)
            ---@type CraftSim.OptionalReagentSlot
            local slot = slot

            if not options.includeLocked and slot.locked then
                frameDistributor:Continue()
                return
            end

            local possibleReagents = slot.possibleReagents

            if options.includeSoulbound and options.onlyHighestQualitySoulbound then
                -- fetch highest soulbounds per stat
                local reagentStatMap = {}
                for _, reagent in ipairs(possibleReagents) do
                    if GUTIL:isItemSoulbound(reagent.item:GetItemID()) then
                        for _, stat in pairs(reagent.professionStats:GetStatList()) do
                            local currentBest = reagentStatMap[stat.name]
                            local statValue = stat.value
                            if not currentBest or statValue > currentBest.value then
                                reagentStatMap[stat.name] = { reagent = reagent, value = statValue }
                            end
                        end
                    end
                end

                -- filter possible reagents to include only the highest soulbound per stat + non-soulbounds
                local filteredReagents = {}
                for _, reagent in ipairs(possibleReagents) do
                    if GUTIL:isItemSoulbound(reagent.item:GetItemID()) then
                        local isHighest = false
                        for _, stat in pairs(reagent.professionStats:GetStatList()) do
                            local bestForStat = reagentStatMap[stat.name]
                            if bestForStat and bestForStat.reagent == reagent then
                                isHighest = true
                                break
                            end
                        end
                        if isHighest then
                            table.insert(filteredReagents, reagent)
                        end
                    else
                        table.insert(filteredReagents, reagent)
                    end
                end

                possibleReagents = filteredReagents
            end

            -- set base
            local slotSimulationResults = { {
                averageProfit = self.averageProfitCached,
                concentrationValue = self:GetConcentrationValue(),
                itemID = nil,
            } }

            GUTIL.FrameDistributor {
                iterationTable = possibleReagents,
                iterationsPerFrame = 1,
                finally = function()
                    -- pick the best candidate for this slot and apply it
                    local bestResult = GUTIL:Fold(slotSimulationResults, slotSimulationResults[1],
                        function(bestResult, nextResult)
                            if self.concentrating then
                                if nextResult.concentrationValue > bestResult.concentrationValue then
                                    return nextResult
                                else
                                    return bestResult
                                end
                            else
                                if nextResult.averageProfit > bestResult.averageProfit then
                                    return nextResult
                                else
                                    return bestResult
                                end
                            end
                        end)

                    slot:SetReagent(bestResult.itemID)
                    self:Update()
                    frameDistributor:Continue()
                end,
                continue = function(frameDistributor2, _, reagent, _, _)
                    ---@type CraftSim.OptionalReagent
                    local finishingReagent = reagent

                    currentItemCount = currentItemCount + 1

                    -- Ownership / availability handling:
                    -- - Non-soulbound items: can always be considered (you can buy them).
                    -- - Soulbound items: only consider if the crafter actually owns them.
                    -- - Currencies: only consider if the crafter has some amount.
                    local hasOwned = false
                    if finishingReagent:IsCurrency() then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(finishingReagent.currencyID)
                        hasOwned = currencyInfo and currencyInfo.quantity and currencyInfo.quantity > 0
                    else
                        if finishingReagent.item then
                            local itemID = finishingReagent.item:GetItemID()
                            local crafterUID = self:GetCrafterUID()
                            local count = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID, true)
                            hasOwned = count and count > 0
                        end
                    end

                    local candidateItemID = nil

                    if finishingReagent:IsCurrency() then
                        -- currencies are always treated as zero-cost but can still change stats,
                        -- but only when the crafter actually has some of that currency
                        if not hasOwned then
                            frameDistributor2:Continue()
                            return
                        end

                        slot:SetCurrencyReagent(finishingReagent.currencyID)
                    else
                        local itemID = finishingReagent.item:GetItemID()
                        local isSoulbound = GUTIL:isItemSoulbound(itemID)

                        if isSoulbound then
                            -- Respect includeSoulbound flag and require ownership for soulbound finishers
                            if not options.includeSoulbound or not hasOwned then
                                frameDistributor2:Continue()
                                return
                            end
                        end

                        slot:SetReagent(itemID)
                        candidateItemID = itemID
                    end

                    self:Update()
                    tinsert(slotSimulationResults, {
                        itemID = candidateItemID,
                        averageProfit = self.averageProfitCached,
                        concentrationValue = self:GetConcentrationValue()
                    })

                    if options.progressUpdateCallback then
                        options.progressUpdateCallback(currentItemCount / percentStep)
                    end
                    frameDistributor2:Continue()
                end
            }:Continue()
        end
    }:Continue()
end

--- Tries every possible combination of finishing reagents across all slots and, for each
--- combination, optionally optimizes required reagents and/or concentration, then applies
--- the combination that yields the best profit (or highest concentration value when crafting
--- with concentration).
---@async
---@param options CraftSim.RecipeData.OptimizeFinishingReagents.Options
function CraftSim.RecipeData:OptimizeFinishingReagentsPermutation(options)
    options = options or {}
    local reagentData = self.reagentData
    local slots = reagentData.finishingReagentSlots

    local function callFinally()
        if options.finally then options.finally() end
    end

    if #slots == 0 then
        -- No finishing reagent slots – just run reagent and/or concentration optimisation.
        if options.optimizeReagentOptions then
            self:OptimizeReagents(options.optimizeReagentOptions)
        end
        if options.optimizeConcentration and self.concentrating and self.supportsQualities then
            self:OptimizeConcentration { finally = callFinally }
        else
            callFinally()
        end
        return
    end

    -- Build the list of viable reagent candidates for each slot.
    -- false represents "leave this slot empty" (nil cannot be stored in Lua tables).
    local crafterUID = self:GetCrafterUID()
    local slotCandidates = {}
    for _, slot in ipairs(slots) do
        local candidates = { false } -- always include the "empty" option (false = no reagent sentinel)

        if options.includeLocked or not slot.locked then
            -- When onlyHighestQualitySoulbound is set, pre-compute the max stat value among
            -- soulbound reagents in this slot that the player owns.

            local possibleReagents = slot.possibleReagents
            if options.includeSoulbound and options.onlyHighestQualitySoulbound then
                -- fetch highest soulbounds per stat
                local reagentStatMap = {}
                for _, reagent in ipairs(possibleReagents) do
                    if GUTIL:isItemSoulbound(reagent.item:GetItemID()) then
                        for _, stat in pairs(reagent.professionStats:GetStatList()) do
                            local currentBest = reagentStatMap[stat.name]
                            local statValue = stat.value
                            if not currentBest or statValue > currentBest.value then
                                reagentStatMap[stat.name] = { reagent = reagent, value = statValue }
                            end
                        end
                    end
                end

                -- filter possible reagents to include only the highest soulbound per stat + non-soulbounds
                local filteredReagents = {}
                for _, reagent in ipairs(possibleReagents) do
                    if GUTIL:isItemSoulbound(reagent.item:GetItemID()) then
                        local isHighest = false
                        for _, stat in pairs(reagent.professionStats:GetStatList()) do
                            local bestForStat = reagentStatMap[stat.name]
                            if bestForStat and bestForStat.reagent == reagent then
                                isHighest = true
                                break
                            end
                        end
                        if isHighest then
                            table.insert(filteredReagents, reagent)
                        end
                    else
                        table.insert(filteredReagents, reagent)
                    end
                end

                possibleReagents = filteredReagents
            end

            for _, reagent in ipairs(possibleReagents) do
                local isViable = false
                if reagent:IsCurrency() then
                    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID)
                    isViable = currencyInfo and currencyInfo.quantity and currencyInfo.quantity > 0
                else
                    local itemID = reagent.item:GetItemID()
                    local isSoulbound = GUTIL:isItemSoulbound(itemID)
                    if isSoulbound then
                        if options.includeSoulbound then
                            local count = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID, true)
                            isViable = count and count > 0
                        end
                    else
                        isViable = true
                    end
                end
                if isViable then
                    table.insert(candidates, reagent)
                end
            end
        end

        table.insert(slotCandidates, candidates)
    end

    -- Generate the cartesian product of all slot candidate lists.
    local combinations = { {} }
    for _, candidates in ipairs(slotCandidates) do
        local newCombinations = {}
        for _, existingCombo in ipairs(combinations) do
            for _, candidate in ipairs(candidates) do
                local newCombo = {}
                for _, r in ipairs(existingCombo) do
                    table.insert(newCombo, r)
                end
                table.insert(newCombo, candidate)
                table.insert(newCombinations, newCombo)
            end
        end
        combinations = newCombinations
    end

    ---@type {combo: table, averageProfit: number, concentrationValue: number}?
    local bestResult = nil
    local totalCombinations = #combinations
    local currentComboIndex = 0

    local function applyComboToSlots(combo)
        for slotIndex, slot in ipairs(slots) do
            local reagent = combo[slotIndex]
            if reagent then
                if reagent:IsCurrency() then
                    slot:SetCurrencyReagent(reagent.currencyID)
                else
                    slot:SetReagent(reagent.item:GetItemID())
                end
            else
                slot:SetReagent(nil)
            end
        end
    end

    GUTIL.FrameDistributor {
        iterationTable = combinations,
        iterationsPerFrame = 1,
        finally = function()
            -- Apply the best finishing reagent combination and re-run sub-optimisations
            -- so the final state is fully optimised for that combination.
            if bestResult then
                applyComboToSlots(bestResult.combo)
                self:Update()
            end

            if options.optimizeReagentOptions then
                self:OptimizeReagents(options.optimizeReagentOptions)
            end

            if options.optimizeConcentration and self.concentrating and self.supportsQualities then
                self:OptimizeConcentration { finally = callFinally }
            else
                callFinally()
            end
        end,
        continue = function(fd, _, combo, _, _)
            currentComboIndex = currentComboIndex + 1

            -- Apply this finishing reagent combination.
            applyComboToSlots(combo)
            self:Update()

            -- Optionally optimise required reagent quality allocation.
            if options.optimizeReagentOptions then
                self:OptimizeReagents(options.optimizeReagentOptions)
            end

            -- Optionally optimise concentration, then record the result.
            local function recordResult()
                local profit = self.averageProfitCached
                local concValue = self:GetConcentrationValue()

                if bestResult == nil or
                    (self.concentrating and concValue > bestResult.concentrationValue) or
                    (not self.concentrating and profit > bestResult.averageProfit) then
                    bestResult = {
                        combo = combo,
                        averageProfit = profit,
                        concentrationValue = concValue,
                    }
                end

                if options.progressUpdateCallback then
                    options.progressUpdateCallback(currentComboIndex / totalCombinations * 100)
                end

                fd:Continue()
            end

            if options.optimizeConcentration and self.concentrating and self.supportsQualities then
                self:OptimizeConcentration { finally = recordResult }
            else
                recordResult()
            end
        end,
    }:Continue()
end

--- Adjusts finishing reagents for batch crafting so that soulbound finishers are only used
--- when the crafter has enough quantity to cover all planned crafts. Non-soulbound finishers
--- (and currencies) may still be used even if not fully owned, as they can be bought.
---@param amount number number of crafts that will be queued
function CraftSim.RecipeData:AdjustSoulboundFinishingForAmount(amount)
    amount = amount or 0
    if amount <= 0 then return end

    local reagentData = self.reagentData
    if not reagentData or #reagentData.finishingReagentSlots == 0 then return end

    local crafterUID = self:GetCrafterUID()

    for _, slot in ipairs(reagentData.finishingReagentSlots) do
        local active = slot.activeReagent
        if active and not active:IsCurrency() and active.item then
            local itemID = active.item:GetItemID()
            if GUTIL:isItemSoulbound(itemID) then
                local owned = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID, true) or 0
                local perCraft = slot.maxQuantity or 1
                local neededTotal = perCraft * amount

                if owned < neededTotal then
                    -- Need to replace this soulbound finisher with the best non-soulbound (or currency) option
                    local bestCandidate = nil

                    -- start without any finishing reagent
                    for _, slot in ipairs(self.reagentData.finishingReagentSlots) do
                        slot.activeReagent = nil
                    end
                    self:Update()
                    local bestAverageProfit = self.averageProfitCached
                    local bestConcentrationValue = self:GetConcentrationValue()
                    local useConcentration = self.concentrating

                    local function considerCandidate(asCurrency, candidate)
                        if asCurrency then
                            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(candidate.currencyID)
                            if not (currencyInfo and currencyInfo.quantity and currencyInfo.quantity > 0) then
                                return
                            end
                            slot:SetCurrencyReagent(candidate.currencyID)
                        else
                            if not candidate.item then return end
                            local candID = candidate.item:GetItemID()
                            if GUTIL:isItemSoulbound(candID) then
                                -- For this adjustment pass we only want non-soulbound alternatives
                                return
                            end
                            slot:SetReagent(candID)
                        end

                        self:Update()
                        local avgProfit = self.averageProfitCached or select(1, self:GetAverageProfit())
                        local concValue = select(1, self:GetConcentrationValue())


                        local better = false
                        if useConcentration then
                            better = concValue > bestConcentrationValue
                        else
                            better = avgProfit > bestAverageProfit
                        end
                        if better then
                            bestCandidate = { asCurrency = asCurrency, reagent = candidate }
                            bestAverageProfit = avgProfit
                            bestConcentrationValue = concValue
                        end
                    end

                    -- Evaluate all possible non-soulbound / currency alternatives for this slot
                    for _, possible in ipairs(slot.possibleReagents) do
                        if possible:IsCurrency() then
                            considerCandidate(true, possible)
                        else
                            considerCandidate(false, possible)
                        end
                    end

                    -- Apply best alternative, or clear the slot if none is viable
                    if bestCandidate then
                        if bestCandidate.asCurrency then
                            slot:SetCurrencyReagent(bestCandidate.reagent.currencyID)
                        else
                            if bestCandidate.reagent.item then
                                slot:SetReagent(bestCandidate.reagent.item:GetItemID())
                            else
                                slot:SetReagent(nil)
                            end
                        end
                    else
                        slot:SetReagent(nil)
                    end
                end
            end
        end
    end

    self:Update()
end

---@return number concentrationValue
---@return number concentrationProfit
function CraftSim.RecipeData:GetConcentrationValue()
    if not self.supportsQualities or self.concentrationCost <= 0 then
        return 0, 0
    end

    local function calculateConcentrationValue(profit, cost)
        return profit / cost
    end

    local ingenuityChance = self.professionStats.ingenuity:GetPercent(true)
    local ingenuityRefund = 0.5 + self.professionStats.ingenuity:GetExtraValue()

    local averageConcentrationCost = self.concentrationCost -
        (self.concentrationCost * ingenuityChance * ingenuityRefund)

    if self.concentrating then
        local averageProfitConcentration = self.averageProfitCached
        self.concentrating = false
        self:Update()

        local concentrationValue = calculateConcentrationValue(averageProfitConcentration, averageConcentrationCost)

        self.concentrating = true
        self:Update()

        return concentrationValue, averageProfitConcentration
    else
        self.concentrating = true
        self:Update()

        local averageProfitConcentration = self.averageProfitCached
        local concentrationValue = calculateConcentrationValue(averageProfitConcentration, averageConcentrationCost)

        self.concentrating = false
        self:Update()

        return concentrationValue, averageProfitConcentration
    end
end

---@return number
function CraftSim.RecipeData:GetConcentrationPointsPerSkill()
    if not self.supportsQualities then return 0 end

    local concentrationCostNextSkillPoint = self:GetConcentrationCostForSkill(self.professionStats.skill.value + 1, true)
    local concentrationCostCurrentSkill = self:GetConcentrationCostForSkill(self.professionStats.skill.value, true)
    local concentrationCostPerSkill = concentrationCostCurrentSkill - concentrationCostNextSkillPoint
    local skillPerConcentrationPoint = 1 / concentrationCostPerSkill
    return skillPerConcentrationPoint
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
---@field optimizeReagentOptions? CraftSim.RecipeData.OptimizeReagentOptions

---@deprecated use CraftSim.RecipeData:Optimize
---Optimizes the recipeData's reagents and gear for highest profit and caches result for crafter
---@param options? CraftSim.RecipeData.OptimizeProfitOptions
function CraftSim.RecipeData:OptimizeProfit(options)
    options = options or {}
    if options.optimizeGear then
        self:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
    end
    if options.optimizeReagentOptions then
        self:OptimizeReagents(options.optimizeReagentOptions)
    end

    CraftSim.DB.ITEM_OPTIMIZED_COSTS:Add(self)
end

---@class CraftSim.RecipeData.Optimize.Options
---@field optimizeGear? boolean
---@field optimizeReagentOptions? CraftSim.RecipeData.OptimizeReagentOptions
---@field optimizeReagentProgressCallback? fun(progress: number)
---@field optimizeConcentration? boolean
---@field optimizeConcentrationProgressCallback? fun(progress: number)
---@field optimizeFinishingReagentsOptions? CraftSim.RecipeData.OptimizeFinishingReagents.Options
---@field optimizeFinishingReagentsProgressCallback? fun(progress: number)
---@field optimizeSubRecipesOptions? CraftSim.RecipeData.Optimize.Options
---@field finally? function callback when optimization is finished

---@async
---@param options CraftSim.RecipeData.Optimize.Options
function CraftSim.RecipeData:Optimize(options)
    options = options or {}

    -- When using permutation-based finishing reagent optimisation, reagent and concentration
    -- optimisation run per-permutation inside OptimizeFinishingReagentsPermutation, so we
    -- must skip them here to avoid running them twice.
    local usePermutation = options.optimizeFinishingReagentsOptions and
        options.optimizeFinishingReagentsOptions.permutationBased

    local optimizationTaskList = {
        options.optimizeGear and "GEAR",
        (not usePermutation) and options.optimizeReagentOptions and "REAGENTS",
        (not usePermutation) and self.concentrating and self.supportsQualities and options.optimizeConcentration and
        "CONCENTRATION",
        options.optimizeFinishingReagentsOptions and "FINISHING_REAGENTS",
        options.optimizeSubRecipesOptions and "SUB_RECIPES",
    }

    GUTIL.FrameDistributor {
        iterationTable = optimizationTaskList,
        finally = function()
            options.finally()
        end,
        continue = function(frameDistributorTasks, _, optimizationTask, _, _)
            if optimizationTask == "GEAR" then
                Logger:LogDebug("Optimizing Gear..")
                self:OptimizeGear(CraftSim.TOPGEAR:GetSimMode(CraftSim.TOPGEAR.SIM_MODES.PROFIT))
                frameDistributorTasks:Continue()
            elseif optimizationTask == "REAGENTS" then
                Logger:LogDebug("Optimizing Reagents..")
                self:OptimizeReagents(options.optimizeReagentOptions)
                frameDistributorTasks:Continue()
            elseif optimizationTask == "CONCENTRATION" then
                Logger:LogDebug("Optimizing Concentration..")

                self:OptimizeConcentration {
                    finally = function()
                        frameDistributorTasks:Continue()
                    end,
                    progressUpdateCallback = function(progress)
                        if options.optimizeConcentrationProgressCallback then
                            options.optimizeConcentrationProgressCallback(progress)
                        end
                    end
                }
            elseif optimizationTask == "FINISHING_REAGENTS" then
                local finOpts = options.optimizeFinishingReagentsOptions
                Logger:LogDebug("Optimizing Finishing Reagents.. (permutation: " ..
                tostring(finOpts.permutationBased) .. ")")
                Logger:LogDebug("- includeLocked: " .. tostring(finOpts.includeLocked))
                Logger:LogDebug("- includeSoulbound: " .. tostring(finOpts.includeSoulbound))
                Logger:LogDebug("- onlyHighestQualitySoulbound: " .. tostring(finOpts.onlyHighestQualitySoulbound))

                if usePermutation then
                    -- Permutation-based: try every combination of finishing reagents, running
                    -- reagent and concentration optimisation for each one.
                    self:OptimizeFinishingReagentsPermutation {
                        includeLocked = finOpts.includeLocked,
                        includeSoulbound = finOpts.includeSoulbound,
                        onlyHighestQualitySoulbound = finOpts.onlyHighestQualitySoulbound,
                        optimizeReagentOptions = options.optimizeReagentOptions,
                        optimizeConcentration = self.concentrating and self.supportsQualities and options.optimizeConcentration,
                        progressUpdateCallback = finOpts.progressUpdateCallback,
                        finally = function()
                            frameDistributorTasks:Continue()
                        end,
                    }
                else
                    -- Simple (original) approach: finishing reagents are optimised slot-by-slot
                    -- after reagent allocation and concentration have already run.
                    self:OptimizeFinishingReagents {
                        includeLocked = finOpts.includeLocked,
                        includeSoulbound = finOpts.includeSoulbound,
                        onlyHighestQualitySoulbound = finOpts.onlyHighestQualitySoulbound,
                        finally = function()
                            frameDistributorTasks:Continue()
                        end,
                        progressUpdateCallback = finOpts.progressUpdateCallback
                    }
                end
            elseif optimizationTask == "SUB_RECIPES" then
                self:SetSubRecipeCostsUsage(true)
                self:OptimizeSubRecipes({
                    optimizeGear = false,
                    optimizeReagentOptions = {
                        highestProfit = false,
                        maxQuality = self.maxQuality,
                    },
                })
                frameDistributorTasks:Continue()
            else
                frameDistributorTasks:Continue()
            end
        end
    }:Continue()
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

    if not item then
        return nil
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

---@return boolean
function CraftSim.RecipeData:IsWorkOrder()
    return self.orderData ~= nil
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
    -- Logger:LogDebug("--crafterDataEquals: " .. tostring(crafterDataEquals))
    -- Logger:LogDebug("--professionLearned: " .. tostring(professionLearned))
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
        Logger:LogDebug("json, adding skill: ")
        jb:Add("skill", self.professionStats.skill.value)
        -- skill without reagent bonus TODO: if single export, consider removing reagent bonus
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
        Logger:LogDebug("json, adding skill: ")
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

--- Helper function to safely extract itemID from reagentInfo (handles both basic and quality reagents)
---@param reagentInfo table The reagent info from orderData.reagents
---@param recipeData CraftSim.RecipeData The recipe data containing reagentData
---@return number? itemID The itemID if found, nil otherwise
function CraftSim.RecipeData:GetItemIDFromReagentInfo(reagentInfo)
    if not reagentInfo then
        return nil
    end

    -- Try various possible paths for quality reagents (handles different API structures)
    if reagentInfo.reagent then
        if reagentInfo.reagent.reagent and reagentInfo.reagent.reagent.itemID then
            return reagentInfo.reagent.reagent.itemID
        elseif reagentInfo.reagent.itemID then
            return reagentInfo.reagent.itemID
        end
    end

    if reagentInfo.reagentInfo and reagentInfo.reagentInfo.reagent and reagentInfo.reagentInfo.reagent.itemID then
        return reagentInfo.reagentInfo.reagent.itemID
    end

    -- Basic reagents (or any reagent without reagent field) use slotIndex to find the reagent in requiredReagents
    if reagentInfo.slotIndex and self.reagentData then
        local matchingReagent = CraftSim.GUTIL:Find(self.reagentData.requiredReagents, function(reagent)
            return reagent.dataSlotIndex == reagentInfo.slotIndex
        end)

        if matchingReagent and matchingReagent.items and #matchingReagent.items > 0 then
            return matchingReagent.items[1].item:GetItemID()
        end
    end

    return nil
end

--- Normalizes an order reagent entry into a simple descriptor.
--- Blizzard's `orderData.reagents` shape differs between contexts; keep all extraction logic in one place.
---@param reagentInfo table The reagent info from orderData.reagents
---@return { dataSlotIndex: number?, itemID: number?, currencyID: number? } descriptor
function CraftSim.RecipeData:GetOrderReagentDescriptor(reagentInfo)
    if not reagentInfo then
        return { dataSlotIndex = nil, itemID = nil, currencyID = nil }
    end

    local dataSlotIndex = nil
    if reagentInfo.reagent and reagentInfo.reagent.dataSlotIndex then
        dataSlotIndex = reagentInfo.reagent.dataSlotIndex
    elseif reagentInfo.reagentInfo and reagentInfo.reagentInfo.dataSlotIndex then
        dataSlotIndex = reagentInfo.reagentInfo.dataSlotIndex
    elseif reagentInfo.dataSlotIndex then
        dataSlotIndex = reagentInfo.dataSlotIndex
    elseif reagentInfo.slotIndex then
        dataSlotIndex = reagentInfo.slotIndex
    end

    local currencyID = nil
    if reagentInfo.reagent then
        if reagentInfo.reagent.reagent and reagentInfo.reagent.reagent.currencyID then
            currencyID = reagentInfo.reagent.reagent.currencyID
        elseif reagentInfo.reagent.currencyID then
            currencyID = reagentInfo.reagent.currencyID
        end
    end
    if not currencyID and reagentInfo.reagentInfo and reagentInfo.reagentInfo.reagent and reagentInfo.reagentInfo.reagent.currencyID then
        currencyID = reagentInfo.reagentInfo.reagent.currencyID
    end

    local itemID = self:GetItemIDFromReagentInfo(reagentInfo)

    return { dataSlotIndex = dataSlotIndex, itemID = itemID, currencyID = currencyID }
end

--- Requires a hardware event
---@param amount number? default: 1, how many crafts should be queued
function CraftSim.RecipeData:Craft(amount)
    amount = amount or 1
    -- TODO: maybe check if crafting is possible (correct profession window open?)
    -- Also what about recipe requirements
    local craftingReagentInfoTbl = self.reagentData:GetCraftingReagentInfoTbl()

    if self.isSalvageRecipe then
        if self.reagentData.salvageReagentSlot.activeItem then
            local salvageLocation = GUTIL:GetItemLocationFromItemID(self.reagentData.salvageReagentSlot.activeItem
                :GetItemID(), true)
            if salvageLocation then
                ---@cast salvageLocation ItemLocation
                C_TradeSkillUI.CraftSalvage(self.recipeID, amount, salvageLocation, craftingReagentInfoTbl,
                    self.concentrating)
            end
        end
    elseif self.isEnchantingRecipe then
        local vellumLocation = GUTIL:GetItemLocationFromItemID(CraftSim.CONST.ENCHANTING_VELLUM_ID)
        if vellumLocation then
            ---@cast vellumLocation ItemLocation
            C_TradeSkillUI.CraftEnchant(self.recipeID, amount, craftingReagentInfoTbl, vellumLocation, self
                .concentrating)
        end
    else
        if self.orderData then
            local suppliedIDs = GUTIL:Map(self.orderData.reagents or {}, function(reagentInfo)
                return self:GetItemIDFromReagentInfo(reagentInfo)
            end)

            craftingReagentInfoTbl = GUTIL:Filter(craftingReagentInfoTbl, function(craftingReagentInfo)
                return not tContains(suppliedIDs, craftingReagentInfo.reagent.itemID)
            end)
        end

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

    -- check amount of reagents in players inventory + bank
    local hasEnoughReagents = self.reagentData:HasEnough(amount, self:GetCrafterUID())

    local craftAbleAmount = self.reagentData:GetCraftableAmount(self:GetCrafterUID())

    local isChargeRecipe = self.cooldownData.maxCharges > 0

    local concentrationAmount = math.huge
    if self.concentrating and self.concentrationCost > 0 then
        concentrationAmount = math.floor(self.concentrationData:GetCurrentAmount() / (self.concentrationCost * amount))
    end

    craftAbleAmount = math.min(craftAbleAmount, concentrationAmount)

    -- CraftSim.DEBUG:SystemPrint("CanCraft")
    -- CraftSim.DEBUG:SystemPrint("hasEnoughReagents: " .. tostring(hasEnoughReagents))
    -- CraftSim.DEBUG:SystemPrint("craftAbleAmount: " .. tostring(craftAbleAmount))


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
---@param forceCache? boolean
---@return CraftingOperationInfo
function CraftSim.RecipeData:GetCraftingOperationInfoForRecipeCrafter(forceCache)
    ---@type CraftingOperationInfo
    local operationInfo = nil
    local crafterUID = self:GetCrafterUID()
    if not self:IsCrafter() or forceCache then
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

    -- Prefer live C_TradeSkillUI.GetRecipeCooldown whenever this recipe belongs to the logged-in crafter.
    -- The API is most reliable with the matching profession open, but we still call Update() first so we
    -- do not skip it when another profession tab is visible (the old IsProfessionOpen gate left
    -- isCooldownRecipe false with no DB row, so queue/scan logic misclassified cooldown recipes).
    if self:IsCrafter() then
        cooldownData = CraftSim.CooldownData(self.recipeID)
        cooldownData:Update()

        if not cooldownData.isCooldownRecipe and CraftSim.DB.CRAFTER:IsRecipeCooldownRecipe(crafterUID, self.recipeID) then
            cooldownData = CraftSim.CooldownData:DeserializeForCrafter(crafterUID, self.recipeID)
        elseif cooldownData.isCooldownRecipe and self.recipeInfo.learned then -- and not self.isOldWorldRecipe then
            cooldownData:Save(crafterUID)
        end
    else
        cooldownData = CraftSim.CooldownData:DeserializeForCrafter(crafterUID, self.recipeID)
    end

    return cooldownData
end

--- Re-query cooldown/charges from the trade skill UI when the crafter has this recipe's profession open (keeps queue and edit UI accurate after a craft).
function CraftSim.RecipeData:RefreshCooldownDataIfProfessionOpen()
    if not self:IsCrafter() or not self:IsProfessionOpen() then
        return
    end
    local currentCooldown, isDayCooldown, _, maxCharges = C_TradeSkillUI.GetRecipeCooldown(self.recipeID)
    currentCooldown = currentCooldown or 0
    local mightBeCD = self.cooldownData.isCooldownRecipe or
        CraftSim.DB.CRAFTER:IsRecipeCooldownRecipe(self:GetCrafterUID(), self.recipeID) or
        (maxCharges and maxCharges > 0) or
        isDayCooldown or
        currentCooldown > 0
    if mightBeCD then
        self.cooldownData = self:GetCooldownDataForRecipeCrafter()
    end
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
    local recipeExpansionID = self.professionData.expansionID
    if recipeExpansionID == "BASE" then return true end
    return recipeExpansionID < CraftSim.CONST.EXPANSION_IDS.DRAGONFLIGHT
end

---@return boolean simplified
function CraftSim.RecipeData:IsSimplifiedQualityRecipe()
    local recipeExpansionID = self.professionData.expansionID
    if recipeExpansionID == "BASE" then return true end
    return recipeExpansionID >= CraftSim.CONST.EXPANSION_IDS.MIDNIGHT
end

---@return boolean simplified
function CraftSim.RecipeData:HasSimplifiedQualityResult()
    return self.supportsQualities and self.maxQuality == 2
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
        if not activeReagent:IsCurrency() then
            local craftingInfo = CraftSim.DB.ITEM_RECIPE:Get(activeReagent.item:GetItemID())
            if craftingInfo then
                tinsert(craftingInfos, craftingInfo)
            end
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
    optimizeOptions = optimizeOptions or {}
    subRecipeDepth = subRecipeDepth or 0
    visitedRecipeIDs = visitedRecipeIDs or {}

    Logger:LogDebug("Optimize SubRecipes for " .. self.recipeName .. " C: " .. tostring(self.concentrating))
    Logger:LogDebug("- Depth: " .. subRecipeDepth)

    if subRecipeDepth > CraftSim.DB.OPTIONS:Get("COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH") then
        Logger:LogDebug("Cancel Sub Recipe Optimization due to max depth")
        return false
    end

    --- DEBUG

    local subRecipeData = self:GetSubRecipeCraftingInfos()

    -- used to show what is reachable
    wipe(self.optimizedSubRecipes)

    -- TODO: Maybe introduce optimizing via caching again here at some point

    -- optimize recipes and map itemIDs
    for _, data in pairs(subRecipeData) do
        Logger:LogDebug("looping subrecipeData: " .. data.itemID .. " - q" .. data.qualityID)
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
                    local recipeData = CraftSim.RecipeData({
                        recipeID = recipeID,
                        crafterData = crafterData,
                    })
                    local ignoreCooldownRecipe = not CraftSim.DB.OPTIONS:Get(
                            "COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWNS") and
                        recipeData.cooldownData.isCooldownRecipe

                    if not ignoreCooldownRecipe then
                        recipeData.subRecipeDepth = subRecipeDepth + 1
                        Logger:LogDebug("- Checking SubRecipe: " ..
                            recipeData.recipeName .. "( q" .. tostring(data.qualityID) .. ")")
                        -- go deep!
                        local success = recipeData:OptimizeSubRecipes(optimizeOptions, visitedRecipeIDs,
                            subRecipeDepth + 1)
                        if success then
                            recipeData:SetSubRecipeCostsUsage(true)

                            -- caches the expect costs info automatically
                            -- TODO replace call to deprecated method
                            recipeData:OptimizeProfit(optimizeOptions)
                            local profit = recipeData.averageProfitCached or recipeData:GetAverageProfit()
                            Logger:LogDebug("- Profit: " ..
                                CraftSim.UTIL:FormatMoney(profit, true, nil))

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

                            Logger:LogDebug("- Quality Reachable: " ..
                                tostring(reagentQualityReachable) .. " C: " .. tostring(concentrationOnly))
                            if reagentQualityReachable then
                                self.optimizedSubRecipes[data.itemID] = recipeData
                            end
                        end
                    end
                end
            end
        else
            Logger:LogDebug("Break Inf Loop!")
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
        finalText = finalText .. " " .. classColor:WrapTextInColorCode(crafterData.name .. "-" .. crafterData.realm)
    else
        finalText = finalText .. " " .. classColor:WrapTextInColorCode(crafterData.name)
    end

    return finalText
end

---@param showIcon boolean
---@param showBrackets boolean adds "[]"
---@param iconSize number? default: 17
function CraftSim.RecipeData:GetFormattedRecipeName(showIcon, showBrackets, iconSize)
    iconSize = iconSize or 17
    local recipeRarity = self.resultData.expectedItem and self.resultData.expectedItem:GetItemQualityColor()
    local recipeIcon = (showIcon and GUTIL:IconToText(self.recipeIcon, iconSize, iconSize, 0, -1)) or ""
    local colorEscapeHex = (recipeRarity and recipeRarity.hex) or ""
    local colorEscapeEnd = (recipeRarity and "|r") or ""
    local startBracket = (showBrackets and "[") or ""
    local endBracket = (showBrackets and "]") or ""
    return string.format("%s %s%s%s%s%s", recipeIcon, colorEscapeHex, startBracket, self.recipeName, endBracket,
        colorEscapeEnd)
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

--- Returns itemID and perCraft for the first active soulbound finishing reagent, or nil if none.
---@return number? itemID
---@return number? perCraft
function CraftSim.RecipeData:GetSoulboundFinishingReagentInfo()
    local reagentData = self.reagentData
    if not reagentData or #reagentData.finishingReagentSlots == 0 then return nil, nil end
    for _, slot in ipairs(reagentData.finishingReagentSlots) do
        local active = slot.activeReagent
        if active and not active:IsCurrency() and active.item then
            local itemID = active.item:GetItemID()
            if GUTIL:isItemSoulbound(itemID) then
                return itemID, (slot.maxQuantity or 1)
            end
        end
    end
    return nil, nil
end

--- Returns true if any active finishing reagent slot contains a soulbound item
---@return boolean
function CraftSim.RecipeData:IsUsingSoulboundFinishingReagent()
    local itemID = self:GetSoulboundFinishingReagentInfo()
    return itemID ~= nil
end

---@alias RecipeCraftQueueUID string

--- Returns a unique id for the recipe within the craftqueue
--- Unique in recipeID, depth, crafter, concentration usage, craft list and soulbound finishing reagent usage
---@return RecipeCraftQueueUID
function CraftSim.RecipeData:GetRecipeCraftQueueUID()
    return self:GetCrafterUID() ..
        ":" ..
        self.recipeID ..
        ":" .. self.subRecipeDepth .. ":" .. tostring((self.orderData and self.orderData.orderID) or 0) ..
        ":" .. tostring(self.craftListID or 0) ..
        ":" .. tostring(self:IsUsingSoulboundFinishingReagent())
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

--- returns a unique string based on used reagents
---@return string
function CraftSim.RecipeData:GetReagentUID()
    local craftingReagentInfoTbl = self.reagentData:GetCraftingReagentInfoTbl()

    local uid = ""
    for _, craftingReagentInfo in ipairs(craftingReagentInfoTbl) do
        local reagentKey = craftingReagentInfo.reagent.itemID or craftingReagentInfo.reagent.currencyID or 0
        uid = uid .. reagentKey .. craftingReagentInfo.quantity
    end

    return uid
end
