---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

-- Memoization cache for expensive WoW API calls
local skillFromReagentsCache = {}
local skillCacheStats = { hits = 0, misses = 0 }

-- Helper function to generate cache key for GetSkillFromRequiredReagents
local function generateSkillCacheKey(recipeData, requiredTbl)
    local parts = {tostring(recipeData.recipeID)}
    
    -- Add reagent configuration to key
    for reagentID, quantity in pairs(requiredTbl) do
        -- Handle case where quantity might be a table
        local quantityStr = (type(quantity) == "table") and tostring(quantity.quantity or quantity[1] or "0") or tostring(quantity)
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
    
    return table.concat(parts, "_")
end

local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ReagentData")
local f = GUTIL:GetFormatter()

---@class CraftSim.ReagentData : CraftSim.CraftSimObject
CraftSim.ReagentData = CraftSim.CraftSimObject:extend()

-- Function to clear the skill cache
function CraftSim.ReagentData.ClearSkillFromReagentsCache()
    skillFromReagentsCache = {}
    skillCacheStats = { hits = 0, misses = 0 }
end

-- Function to get cache statistics
function CraftSim.ReagentData.GetSkillCacheStats()
    return skillCacheStats
end

---@param recipeData CraftSim.RecipeData
---@param schematicInfo CraftingRecipeSchematic
function CraftSim.ReagentData:new(recipeData, schematicInfo)
    self.recipeData = recipeData
    ---@type CraftSim.Reagent[]
    self.requiredReagents = {}
    ---@type CraftSim.OptionalReagentSlot[]
    self.optionalReagentSlots = {}
    ---@type CraftSim.OptionalReagentSlot[]
    self.finishingReagentSlots = {}
    ---@type CraftSim.OptionalReagentSlot?
    self.requiredSelectableReagentSlot = nil
    ---@type CraftSim.SalvageReagentSlot
    self.salvageReagentSlot = CraftSim.SalvageReagentSlot(self.recipeData)

    if not schematicInfo then
        return
    end

    if self.recipeData.isSalvageRecipe then
        -- https://www.townlong-yak.com/framexml/live/Blizzard_ProfessionsTemplates/Blizzard_ProfessionsRecipeSchematicForm.lua#1136
        self.salvageReagentSlot.requiredQuantity = schematicInfo.quantityMax
    end

    for _, reagentSlotSchematic in pairs(schematicInfo.reagentSlotSchematics) do
        local reagentType = reagentSlotSchematic.reagentType

        if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
            table.insert(self.requiredReagents, CraftSim.Reagent(reagentSlotSchematic))
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL then
            if reagentSlotSchematic.required then
                self.requiredSelectableReagentSlot = CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic)
            else
                table.insert(self.optionalReagentSlots,
                    CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic))
            end
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT then
            table.insert(self.finishingReagentSlots, CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic))
        end
    end
end

---@param itemID ItemID
function CraftSim.ReagentData:IsOrderReagent(itemID)
    if not self.recipeData.orderData then return false end

    for _, reagentInfo in ipairs(self.recipeData.orderData.reagents or {}) do
        local reagentItemID = CraftSim.RecipeData.GetItemIDFromReagentInfo(reagentInfo, self.recipeData)
        if reagentItemID == itemID then
            if reagentInfo.source == Enum.CraftingOrderReagentSource.Customer then
                return true
            end
        end
    end
end

---@return CraftSim.Reagent.Serialized[]
function CraftSim.ReagentData:SerializeRequiredReagents()
    return GUTIL:Map(self.requiredReagents, function(reagent)
        return reagent:Serialize()
    end)
end

function CraftSim.ReagentData:GetProfessionStatsByOptionals()
    local totalStats = CraftSim.ProfessionStats()

    local optionalStats = GUTIL:Map(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots }),
        function(slot)
            if slot.activeReagent then
                return slot.activeReagent.professionStats
            else
                return nil
            end
        end)

    for _, stat in ipairs(optionalStats) do
        totalStats:add(stat)
    end

    if self:HasRequiredSelectableReagent() then
        if self.requiredSelectableReagentSlot.activeReagent then
            totalStats:add(self.requiredSelectableReagentSlot.activeReagent.professionStats)
        end
    end

    -- TODO
    local percentDivisionFactors = CraftSim.CONST.PERCENT_DIVISION_FACTORS[CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN]

    -- since ooey gooey chocolate gives us math.huge on multicraft we need to limit it to 100%
    totalStats.multicraft.value = math.min(percentDivisionFactors.MULTICRAFT, totalStats.multicraft.value)


    return totalStats
end

--- circumvents itemLink loading
---@param itemID number
function CraftSim.ReagentData:GetReagentQualityIDByItemID(itemID)
    local qualityID = 0
    for _, reagent in pairs(self.requiredReagents) do
        local reagentItem = GUTIL:Find(reagent.items, function(reagentItem)
            return reagentItem.item:GetItemID() == itemID
        end)
        if reagentItem then
            return reagentItem.qualityID
        end
    end
    return qualityID
end

---@return CraftingReagentInfo[]
function CraftSim.ReagentData:GetCraftingReagentInfoTbl()
    local required = self:GetRequiredCraftingReagentInfoTbl()
    local optionals = self:GetOptionalCraftingReagentInfoTbl()

    return GUTIL:Concat({ required, optionals })
end

---@return CraftingReagentInfo[]
function CraftSim.ReagentData:GetOptionalCraftingReagentInfoTbl()
    local craftingReagentInfoTbl = {}

    -- optional/finishing
    for _, slot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
        local craftingReagentInfo = slot:GetCraftingReagentInfo()
        if craftingReagentInfo then
            table.insert(craftingReagentInfoTbl, craftingReagentInfo)
        end
    end

    return craftingReagentInfoTbl
end

---@return CraftingReagentInfo[]
function CraftSim.ReagentData:GetRequiredCraftingReagentInfoTbl()
    ---@type CraftingReagentInfo[]
    local craftingReagentInfoTbl = {}

    -- required
    for _, reagent in pairs(self.requiredReagents) do
        local craftingReagentInfos = reagent:GetCraftingReagentInfos()
        craftingReagentInfoTbl = GUTIL:Concat({ craftingReagentInfoTbl, craftingReagentInfos })
    end

    if self:HasRequiredSelectableReagent() then
        if self.requiredSelectableReagentSlot.activeReagent then
            tinsert(craftingReagentInfoTbl, self.requiredSelectableReagentSlot:GetCraftingReagentInfo())
        end
    end

    return craftingReagentInfoTbl
end

---@return CraftSim.OptionalReagent[] activeReagents
function CraftSim.ReagentData:GetActiveOptionalReagents()
    local activeReagents = {}

    local allSlots = GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })

    for _, slot in pairs(allSlots) do
        if slot.activeReagent then
            table.insert(activeReagents, slot.activeReagent)
        end
    end

    return activeReagents
end

-- Sets an optional Reagent active in a recipe if supported, if not does nothing
---@param itemID number
function CraftSim.ReagentData:SetOptionalReagent(itemID)
    for _, slot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
        local optionalReagent = GUTIL:Find(slot.possibleReagents,
            function(optionalReagent)
                return not optionalReagent:IsCurrency() and optionalReagent.item:GetItemID() == itemID
            end)

        if optionalReagent then
            slot.activeReagent = optionalReagent
            return
        end
    end
end

-- Sets an optional currency Reagent active in a recipe if supported, if not does nothing
---@param currencyID number
function CraftSim.ReagentData:SetOptionalCurrencyReagent(currencyID)
    for _, slot in pairs(self.optionalReagentSlots) do
        local optionalReagent = GUTIL:Find(slot.possibleReagents,
            function(optionalReagent)
                return optionalReagent:IsCurrency() and optionalReagent.currencyID == currencyID
            end)

        if optionalReagent then
            slot.activeReagent = optionalReagent
            return
        end
    end
end

function CraftSim.ReagentData:ClearOptionalReagents()
    for _, slot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
        slot.activeReagent = nil
    end
end

function CraftSim.ReagentData:ClearRequiredReagents()
    for _, reagent in ipairs(self.requiredReagents) do
        reagent:Clear()
    end
end

---Wether the recipe has slots for optional or finishing reagents
function CraftSim.ReagentData:HasOptionalReagents()
    if self.optionalReagentSlots[1] or self.finishingReagentSlots[1] then
        return true
    end

    return false
end

function CraftSim.ReagentData:HasRequiredSelectableReagent()
    return self.requiredSelectableReagentSlot ~= nil
end

---@param itemID ItemID
function CraftSim.ReagentData:SetRequiredSelectableReagent(itemID)
    if self:HasRequiredSelectableReagent() then
        self.requiredSelectableReagentSlot:SetReagent(itemID)
    end
end

function CraftSim.ReagentData:GetMaxSkillFactor()
    local maxQualityReagentsCraftingTbl = GUTIL:Map(self.requiredReagents, function(rr)
        return rr:GetCraftingReagentInfoByQuality(self.recipeData:IsSimplifiedQualityRecipe() and 2 or 3, true)
    end)

    -- explicitly do not use concentration flag here

    print("max quality reagents crafting tbl:")
    print(maxQualityReagentsCraftingTbl, true)

    local recipeID = self.recipeData.recipeID
    local baseOperationInfo = nil
    local operationInfoWithReagents = nil
    if self.recipeData.orderData then
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, {},
            self.recipeData.orderData.orderID, false)
        operationInfoWithReagents = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID,
            maxQualityReagentsCraftingTbl, self.recipeData.orderData.orderID, false)
    else
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, self.recipeData.allocationItemGUID,
            false)
        operationInfoWithReagents = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, maxQualityReagentsCraftingTbl,
            self.recipeData.allocationItemGUID, false)
    end

    if baseOperationInfo and operationInfoWithReagents then
        local baseSkill = baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill
        local skillWithReagents = operationInfoWithReagents.baseSkill + operationInfoWithReagents.bonusSkill

        local maxSkill = skillWithReagents - baseSkill

        if maxSkill == 0 then
            -- division by zero not possible so just configure that reagents do not influence skill at all by returning a factor of 0
            return 0
        end
        local maxReagentIncreaseFactor = self.recipeData.baseProfessionStats.recipeDifficulty.value / maxSkill

        print("ReagentData: maxReagentIncreaseFactor: " .. tostring(maxReagentIncreaseFactor))

        local percentFactor = (100 / maxReagentIncreaseFactor) / 100

        print("ReagentData: maxReagentIncreaseFactor % of difficulty: " .. tostring(percentFactor) .. " %")

        return percentFactor
    end

    print("ReagentData: Could not determine max reagent skill factor: operationInfos nil")
end

---@return number skillWithReagents
function CraftSim.ReagentData:GetSkillFromRequiredReagents()
    local requiredTbl = self:GetRequiredCraftingReagentInfoTbl()
    
    -- Check cache first
    local cacheKey = generateSkillCacheKey(self.recipeData, requiredTbl)
    local cachedResult = skillFromReagentsCache[cacheKey]
    if cachedResult then
        skillCacheStats.hits = skillCacheStats.hits + 1
        return cachedResult
    end
    
    skillCacheStats.misses = skillCacheStats.misses + 1

    local recipeID = self.recipeData.recipeID

    -- explicitly do not use concentration here

    local baseOperationInfo = nil
    local operationInfoWithReagents = nil
    
    if self.recipeData.orderData then
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, {},
            self.recipeData.orderData.orderID, false)
    else
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, self.recipeData.allocationItemGUID,
            false)
    end
    
    if self.recipeData.orderData then
        operationInfoWithReagents = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, requiredTbl,
            self.recipeData.orderData.orderID, false)
    else
        operationInfoWithReagents = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, requiredTbl,
            self.recipeData.allocationItemGUID, false)
    end

    if baseOperationInfo and operationInfoWithReagents then
        local baseSkill = baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill
        local skillWithReagents = operationInfoWithReagents.baseSkill + operationInfoWithReagents.bonusSkill
        
        local result = skillWithReagents - baseSkill
        
        -- Cache the result
        skillFromReagentsCache[cacheKey] = result
        
        return result
    end
    print("ReagentData: Could not determine required reagent skill: operationInfos nil")
    return 0
end

---@param reagents CraftSim.Reagent[]
function CraftSim.ReagentData:EqualsQualityReagents(reagents)
    print("EqualsQualityReagents ?")
    print(reagents, true)
    -- order can be different?
    local qualityReagents = GUTIL:Filter(self.requiredReagents, function(reagent) return reagent.hasQuality end)
    for index, reagentA in pairs(qualityReagents) do
        local reagentB = reagents[index]
        for itemIndex, reagentItemA in pairs(reagentA.items) do
            local reagentItemB = reagentB.items[itemIndex]

            print("compare items: " ..
                tostring(reagentItemA.item:GetItemLink()) .. " - " .. tostring(reagentItemB.item:GetItemLink()))
            print("quantities: " .. tostring(reagentItemA.quantity) .. " - " .. tostring(reagentItemB.quantity))

            if reagentItemA.item:GetItemID() ~= reagentItemB.item:GetItemID() then
                print("different itemids...")
                return false
            elseif reagentItemA.quantity ~= reagentItemB.quantity then
                print("different quantities")
                return false
            end
        end
    end

    print("equals!")
    return true
end

---@param qualityID number
function CraftSim.ReagentData:SetReagentsMaxByQuality(qualityID)
    if not qualityID or qualityID < 1 or qualityID > 3 then
        error("CraftSim.ReagentData:SetReagentsMaxByQuality(qualityID) -> qualityID has to be between 1 and 3")
    end
    if self.recipeData:IsSimplifiedQualityRecipe() and qualityID == 3 then
        error("Recipes added in Midnight do not have reagents with 3 quality tiers")
    end
    for _, reagent in pairs(self.requiredReagents) do
        if reagent.hasQuality then
            reagent:Clear()
            reagent.items[qualityID].quantity = reagent.requiredQuantity
        else
            reagent.items[1].quantity = reagent.requiredQuantity
        end
    end
end

---@param optimizationResult? CraftSim.ReagentOptimizationResult
function CraftSim.ReagentData:SetReagentsByOptimizationResult(optimizationResult)
    if not optimizationResult then
        return
    end
    local reagentItemList = optimizationResult:GetReagentItemList()
    self.recipeData:SetReagents(reagentItemList)

    -- always set nonquality reagents to max
    self.recipeData:SetNonQualityReagentsMax()
end

---comment
---@param multiplier number?
---@param crafterUID string
---@return boolean
function CraftSim.ReagentData:HasEnough(multiplier, crafterUID)
    multiplier = multiplier or 1
    -- check required, optional and finished reagents if the player has enough times multiplier in his inventory and bank

    local hasRequiredReagents = GUTIL:Every(self.requiredReagents,
        ---@param requiredReagent CraftSim.Reagent
        function(requiredReagent)
            return requiredReagent:HasItems(multiplier, crafterUID)
        end)

    local hasOptionalReagents = GUTIL:Every(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots }),
        ---@param optionalReagentSlot CraftSim.OptionalReagentSlot
        function(optionalReagentSlot)
            return optionalReagentSlot:HasItem(multiplier, crafterUID)
        end)

    -- CraftSim.DEBUG:SystemPrint("Has Enough:")
    -- CraftSim.DEBUG:SystemPrint("hasRequiredReagents: " .. tostring(hasRequiredReagents))
    -- CraftSim.DEBUG:SystemPrint("hasOptionalReagents: " .. tostring(hasOptionalReagents))
    local hasrequiredSelectableReagent = true
    if self:HasRequiredSelectableReagent() then
        hasrequiredSelectableReagent = self.requiredSelectableReagentSlot:HasItem(multiplier, crafterUID)
    end
    -- update item cache for all possible optional reagents if I am the crafter
    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        for _, slot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
            if not slot:IsCurrency() then
                ---@type CraftSim.OptionalReagentSlot
                slot = slot
                for _, possibleReagent in pairs(slot.possibleReagents) do
                    local itemID = possibleReagent.item:GetItemID()
                    CraftSim.ITEM_COUNT:UpdateAllCountsForItemID(itemID)
                end
            end
        end
        if self:HasRequiredSelectableReagent() and hasrequiredSelectableReagent then
            for _, possiblerequiredSelectableReagent in pairs(self.requiredSelectableReagentSlot.possibleReagents or {}) do
                local itemID = possiblerequiredSelectableReagent.item:GetItemID()
                CraftSim.ITEM_COUNT:UpdateAllCountsForItemID(itemID)
            end
        end
    end



    local hasVellumIfneeded = true

    if self.recipeData.isEnchantingRecipe then
        local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, CraftSim.CONST
            .ENCHANTING_VELLUM_ID, true)
        hasVellumIfneeded = itemCount >= multiplier
    end

    return hasRequiredReagents and hasOptionalReagents and hasrequiredSelectableReagent and hasVellumIfneeded
end

---@param crafterUID CrafterUID
function CraftSim.ReagentData:GetCraftableAmount(crafterUID)
    local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ReagentData.GetCraftableAmount")

    print("getCraftable amount", false, true)

    local currentMinimumReagentFit = math.huge
    for _, requiredReagent in pairs(self.requiredReagents) do
        if not requiredReagent:IsOrderReagentIn(self.recipeData) then
            if not requiredReagent:HasItems(1, crafterUID) then
                return 0
            end
            currentMinimumReagentFit = math.min(requiredReagent:HasQuantityXTimes(crafterUID),
                currentMinimumReagentFit)
        end
    end

    if self:HasRequiredSelectableReagent() then
        if self.requiredSelectableReagentSlot.activeReagent then
            if not self.requiredSelectableReagentSlot.activeReagent:IsOrderReagentIn(self.recipeData) then
                currentMinimumReagentFit = math.min(
                    self.requiredSelectableReagentSlot:HasQuantityXTimes(crafterUID),
                    currentMinimumReagentFit)
            end
        else
            currentMinimumReagentFit = 0
        end
    end

    print("minimum required fit: " .. tostring(currentMinimumReagentFit))

    local currentMinimumReagentFitOptional = math.huge
    ---@type CraftSim.OptionalReagentSlot[]
    local optionalReagentSlots = GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })
    for _, optionalReagentSlot in pairs(optionalReagentSlots) do
        if optionalReagentSlot.activeReagent and not optionalReagentSlot.activeReagent:IsOrderReagentIn(self.recipeData) then
            if not optionalReagentSlot:HasItem(1, crafterUID) then
                return 0
            end
            currentMinimumReagentFitOptional = math.min(
                optionalReagentSlot:HasQuantityXTimes(crafterUID),
                currentMinimumReagentFitOptional)
        end
    end
    print("minimum optional fit: " .. tostring(currentMinimumReagentFitOptional))

    local vellumMinimumFit = math.huge
    if self.recipeData.isEnchantingRecipe then
        local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, CraftSim.CONST
            .ENCHANTING_VELLUM_ID, true)
        vellumMinimumFit = itemCount
        print("minimum vellum fit: " .. tostring(vellumMinimumFit))
    end

    local minFit = math.min(currentMinimumReagentFit, currentMinimumReagentFitOptional, vellumMinimumFit)

    print("minimum total fit: " .. tostring(minFit))
    return minFit
end

--- if one of the given item ids is a reagent used in the recipe, this returns true
---@param reagentItemIDs number[]
---@return boolean
function CraftSim.ReagentData:HasOneOfReagents(reagentItemIDs)
    return GUTIL:Some(self.requiredReagents,
        function(reagent)
            return tContains(reagentItemIDs, reagent.items[1].item:GetItemID())
        end)
end

--- convert required and finished reagents to string that is displayable in a tooltip
---@param multiplier number? default: 1
function CraftSim.ReagentData:GetTooltipText(multiplier, crafterUID)
    local print = CraftSim.DEBUG:RegisterDebugID("Classes.RecipeData.ReagentData.GetTooltipText")
    multiplier = multiplier or 1
    local iconSize = 25
    local text = ""

    for _, requiredReagent in pairs(self.requiredReagents) do
        local reagentIcon = requiredReagent.items[1].item:GetItemIcon()
        local inlineIcon = GUTIL:IconToText(reagentIcon, iconSize, iconSize)
        text = text .. inlineIcon
        local isOrderReagent = requiredReagent:IsOrderReagentIn(self.recipeData)
        if not requiredReagent.hasQuality then
            local reagentItem = requiredReagent.items[1]
            local itemID = reagentItem.item:GetItemID()
            -- crafting tooltip should show original item
            if reagentItem.originalItem then
                itemID = reagentItem.originalItem:GetItemID()
            end
            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
            local quantityText = f.r(tostring(requiredReagent.requiredQuantity * multiplier) ..
                "(" .. tostring(itemCount) .. ")")

            if itemCount >= (requiredReagent.requiredQuantity * multiplier) or isOrderReagent then
                quantityText = f.g(tostring(requiredReagent.requiredQuantity * multiplier))
            end

            local crafterText = ""
            -- add crafterInfo text if reagent is supposed to be crafted by the player
            -- check for quantity not needed for non quality items
            if not isOrderReagent and self.recipeData:IsSelfCraftedReagent(itemID) then
                local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes
                    [itemID]
                if optimizedReagentRecipeData then
                    crafterText = f.white(" (" ..
                        optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
                end
            end

            if isOrderReagent then
                crafterText = " " .. CreateAtlasMarkup("UI-ChatIcon-App", 20, 20)
            end

            text = text .. " x " .. quantityText .. crafterText .. "\n"
        else
            local totalCount = requiredReagent:GetTotalQuantity()
            local totalCountOK = totalCount * multiplier >= requiredReagent.requiredQuantity * multiplier
            for qualityID, reagentItem in pairs(requiredReagent.items) do
                local itemID = reagentItem.item:GetItemID()
                -- crafting tooltip should show original item
                if reagentItem.originalItem then
                    itemID = reagentItem.originalItem:GetItemID()
                end
                local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
                local quantityText = f.r(
                    tostring(reagentItem.quantity * multiplier) .. "(" .. tostring(itemCount) .. ")")

                if itemCount >= reagentItem.quantity * multiplier or (reagentItem.quantity == 0 and totalCountOK) or isOrderReagent then
                    quantityText = f.g(tostring(reagentItem.quantity * multiplier))
                end
                local qualityIcon = GUTIL:GetQualityIconString(qualityID, 20, 20)
                local crafterText = ""
                -- add crafterInfo text if reagent is supposed to be crafted by the player
                if not isOrderReagent and self.recipeData:IsSelfCraftedReagent(itemID) and reagentItem.quantity > 0 then
                    local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes[itemID]
                    if optimizedReagentRecipeData then
                        crafterText = f.white(" (" ..
                            optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
                    end
                end

                if isOrderReagent and reagentItem.quantity > 0 then
                    crafterText = " " .. CreateAtlasMarkup("UI-ChatIcon-App", 20, 20)
                end

                text = text .. qualityIcon .. quantityText .. crafterText .. "   "
            end
            text = text .. "\n"
        end
    end

    if self:HasRequiredSelectableReagent() then
        if self.requiredSelectableReagentSlot.activeReagent then
            local itemID = self.requiredSelectableReagentSlot.activeReagent.item:GetItemID()
            local isOrderReagent = self.requiredSelectableReagentSlot.activeReagent:IsOrderReagentIn(self.recipeData)
            local reagentIcon = self.requiredSelectableReagentSlot.activeReagent.item:GetItemIcon()
            local inlineIcon = GUTIL:IconToText(reagentIcon, iconSize, iconSize)
            text = text .. inlineIcon
            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, itemID)
            local requiredQuantity = self.requiredSelectableReagentSlot.maxQuantity * multiplier
            local quantityText = f.r(tostring(requiredQuantity) .. "(" .. tostring(itemCount) .. ")")
            if itemCount >= requiredQuantity or isOrderReagent then
                quantityText = f.g(tostring(requiredQuantity))
            end
            local crafterText = ""
            -- add crafterInfo text if reagent is supposed to be crafted by the player
            local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes
                [itemID]
            if not isOrderReagent and optimizedReagentRecipeData then
                crafterText = f.white(" (" ..
                    optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
            end

            if isOrderReagent then
                crafterText = " " .. CreateAtlasMarkup("UI-ChatIcon-App", 20, 20)
            end

            text = text .. " " .. quantityText .. crafterText .. "   "
        end
    end

    for _, optionalReagentSlot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
        ---@type CraftSim.OptionalReagentSlot
        optionalReagentSlot = optionalReagentSlot
        if optionalReagentSlot.activeReagent then
            local reagentIcon = optionalReagentSlot.activeReagent.item:GetItemIcon()
            local inlineIcon = GUTIL:IconToText(reagentIcon, iconSize, iconSize)
            text = text .. inlineIcon
            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID,
                optionalReagentSlot.activeReagent.item:GetItemID())
            local quantityText = f.r(tostring(multiplier) .. "(" .. tostring(itemCount) .. ")")
            if itemCount >= multiplier then
                quantityText = f.g(tostring(multiplier))
            end
            local qualityID = C_TradeSkillUI.GetItemReagentQualityByItemInfo(optionalReagentSlot.activeReagent.item
                :GetItemID())
            qualityID = qualityID or 0
            local qualityIcon = GUTIL:GetQualityIconString(qualityID, 20, 20)
            local crafterText = ""
            -- add crafterInfo text if reagent is supposed to be crafted by the player
            local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes
                [optionalReagentSlot.activeReagent.item:GetItemID()]
            if optimizedReagentRecipeData then
                crafterText = f.white(" (" ..
                    optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
            end
            text = text .. qualityIcon .. quantityText .. crafterText .. "   "
        end
    end
    if crafterUID ~= CraftSim.UTIL:GetPlayerCrafterUID() then
        local crafterName = self.recipeData:GetFormattedCrafterText(true)
        text = text .. f.white("\n(Inventory of " .. crafterName .. ")")
    end

    -- add parent recipe info
    if #self.recipeData.parentRecipeInfo > 0 then
        text = text .. f.white("\n\nPrerequisite of:")
        ---@type CraftSim.RecipeData.ParentRecipeInfo[]
        local sortedInfo = GUTIL:Sort(self.recipeData.parentRecipeInfo, function(infoA, infoB)
            return infoA.crafterUID > infoB.crafterUID
        end)
        for _, info in ipairs(sortedInfo) do
            text = text ..
                "\n- " ..
                C_ClassColor.GetClassColor(info.crafterClass):WrapTextInColorCode(info.crafterUID) ..
                ": " .. f.white(info.recipeName)
        end
    end
    return text
end

--- called when recipe was successfully crafted and reagent bank was updated as a result (to update reagent bank item count)
function CraftSim.ReagentData:UpdateItemCountCacheForAllocatedReagents()
    -- only if I am the crafter!
    if not self.recipeData:IsCrafter() then
        return
    end

    local crafterUID = self.recipeData:GetCrafterUID()

    local craftingReagentInfoTbl = self:GetCraftingReagentInfoTbl()

    for _, craftingReagentInfo in pairs(craftingReagentInfoTbl) do
        local itemCount = C_Item.GetItemCount(craftingReagentInfo.reagent.itemID, true, false, true)
        -- TODO requires update: Save() doesn't exist, only per-location values exist but this is the sum of inventory and bank
        CraftSim.DB.ITEM_COUNT:Save(crafterUID, craftingReagentInfo.reagent.itemID, itemCount)
    end
end

---@param itemID ItemID
---@return number count
function CraftSim.ReagentData:GetReagentQuantityByItemID(itemID)
    for i, reagent in ipairs(self.requiredReagents) do
        for q, reagentItem in ipairs(reagent.items) do
            local reagentItemID = reagentItem.item:GetItemID()
            if reagentItemID == itemID then
                return reagentItem.quantity
            end
        end
    end

    return 0
end

function CraftSim.ReagentData:Debug()
    local debugLines = {}
    for _, reagent in pairs(self.requiredReagents) do
        local q1 = reagent.items[1].quantity
        local q2 = 0
        local q3 = 0
        if reagent.hasQuality then
            q1 = reagent.items[1].quantity
            q2 = reagent.items[2].quantity
            q3 = reagent.items[3].quantity
            table.insert(debugLines,
                (reagent.items[1].item:GetItemLink() or reagent.items[1].item:GetItemID()) ..
                " " .. q1 .. " | " .. q2 .. " | " .. q3 .. " / " .. reagent.requiredQuantity)
        else
            table.insert(debugLines,
                (reagent.items[1].item:GetItemLink() or reagent.items[1].item:GetItemID()) ..
                " " .. q1 .. " / " .. reagent.requiredQuantity)
        end
    end

    table.insert(debugLines, "Optional Reagent Slots: " .. tostring(#self.optionalReagentSlots))
    for i, slot in pairs(self.optionalReagentSlots) do
        debugLines = GUTIL:Concat({ debugLines, slot:Debug() })
    end
    table.insert(debugLines, "Finishing Reagent Slots: " .. tostring(#self.finishingReagentSlots))
    for i, slot in pairs(self.finishingReagentSlots) do
        debugLines = GUTIL:Concat({ debugLines, slot:Debug() })
    end

    table.insert(debugLines, "Salvage Reagent Slot: " .. tostring(#self.salvageReagentSlot.possibleItems))
    debugLines = GUTIL:Concat({ debugLines, self.salvageReagentSlot:Debug() })

    return debugLines
end

function CraftSim.ReagentData:Copy(recipeData)
    ---@type CraftSim.ReagentData
    local copy = CraftSim.ReagentData(recipeData)

    copy.requiredReagents = GUTIL:Map(self.requiredReagents, function(r) return r:Copy() end)
    copy.optionalReagentSlots = GUTIL:Map(self.optionalReagentSlots, function(r) return r:Copy(recipeData) end)
    copy.finishingReagentSlots = GUTIL:Map(self.finishingReagentSlots, function(r) return r:Copy(recipeData) end)
    copy.requiredSelectableReagentSlot = self.requiredSelectableReagentSlot and
        self.requiredSelectableReagentSlot:Copy(recipeData)
    copy.salvageReagentSlot = self.salvageReagentSlot:Copy()

    return copy
end

function CraftSim.ReagentData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:AddList("requiredReagents", self.requiredReagents)
    jb:AddList("optionalReagentSlots", self.optionalReagentSlots)
    jb:AddList("finishingReagentSlots", self.finishingReagentSlots)
    jb:Add("requiredSelectableReagentSlot", self.requiredSelectableReagentSlot)
    jb:Add("salvageReagentSlot", self.salvageReagentSlot, true)
    jb:End()
    return jb.json
end
