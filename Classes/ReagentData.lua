---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL


local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)
local f = GUTIL:GetFormatter()

---@class CraftSim.ReagentData : CraftSim.CraftSimObject
CraftSim.ReagentData = CraftSim.CraftSimObject:extend()

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
    self.sparkReagentSlot = nil
    ---@type CraftSim.SalvageReagentSlot
    self.salvageReagentSlot = CraftSim.SalvageReagentSlot(self.recipeData)

    if not schematicInfo then
        return
    end
    for _, reagentSlotSchematic in pairs(schematicInfo.reagentSlotSchematics) do
        local reagentType = reagentSlotSchematic.reagentType

        if reagentType == CraftSim.CONST.REAGENT_TYPE.REQUIRED then
            table.insert(self.requiredReagents, CraftSim.Reagent(reagentSlotSchematic))
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.OPTIONAL then
            if reagentSlotSchematic.required then
                -- spark
                self.sparkReagentSlot = CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic)
            else
                table.insert(self.optionalReagentSlots,
                    CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic))
            end
        elseif reagentType == CraftSim.CONST.REAGENT_TYPE.FINISHING_REAGENT then
            table.insert(self.finishingReagentSlots, CraftSim.OptionalReagentSlot(self.recipeData, reagentSlotSchematic))
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
            end
        end)

    table.foreach(optionalStats, function(_, stat)
        totalStats:add(stat)
    end)

    if self:HasSparkSlot() then
        if self.sparkReagentSlot.activeReagent then
            totalStats:add(self.sparkReagentSlot.activeReagent.professionStats)
        end
    end

    -- TODO
    local statPercentModTable = CraftSim.CONST.PERCENT_MODS[CraftSim.CONST.EXPANSION_IDS.THE_WAR_WITHIN]

    -- since ooey gooey chocolate gives us math.huge on multicraft we need to limit it to 100%
    totalStats.multicraft.value = math.min(1 / statPercentModTable.MULTICRAFT, totalStats.multicraft.value)


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

    if self:HasSparkSlot() then
        if self.sparkReagentSlot.activeReagent then
            tinsert(craftingReagentInfoTbl, self.sparkReagentSlot:GetCraftingReagentInfo())
        end
    end

    return craftingReagentInfoTbl
end

---@return CraftSim.OptionalReagent[] activeReagents
function CraftSim.ReagentData:GetActiveOptionalReagents()
    local activeReagents = {}

    local allSlots = GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })

    table.foreach(allSlots, function(_, slot)
        if slot.activeReagent then
            table.insert(activeReagents, slot.activeReagent)
        end
    end)

    return activeReagents
end

--- Sets a optional Reagent active in a recipe if supported, if not does nothing
---@param itemID number
function CraftSim.ReagentData:SetOptionalReagent(itemID)
    for _, slot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
        local optionalReagent = GUTIL:Find(slot.possibleReagents,
            function(optionalReagent)
                return optionalReagent.item:GetItemID() == itemID
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

---Wether the recipe has slots for optional or finishing reagents
function CraftSim.ReagentData:HasOptionalReagents()
    if self.optionalReagentSlots[1] or self.finishingReagentSlots[1] then
        return true
    end

    return false
end

function CraftSim.ReagentData:HasSparkSlot()
    return self.sparkReagentSlot ~= nil
end

---@param itemID ItemID
function CraftSim.ReagentData:SetSparkItem(itemID)
    if self:HasSparkSlot() then
        self.sparkReagentSlot:SetReagent(itemID)
    end
end

function CraftSim.ReagentData:GetMaxSkillFactor()
    local maxQualityReagentsCraftingTbl = GUTIL:Map(self.requiredReagents, function(rr)
        return rr:GetCraftingReagentInfoByQuality(3, true)
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

    local recipeID = self.recipeData.recipeID

    -- explicitly do not u use concentration here

    local baseOperationInfo = nil
    local operationInfoWithReagents = nil
    if self.recipeData.orderData then
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, {},
            self.recipeData.orderData.orderID, false)
        operationInfoWithReagents = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, requiredTbl,
            self.recipeData.orderData.orderID, false)
    else
        baseOperationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, self.recipeData.allocationItemGUID,
            false)
        operationInfoWithReagents = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, requiredTbl,
            self.recipeData.allocationItemGUID, false)
    end

    if baseOperationInfo and operationInfoWithReagents then
        local baseSkill = baseOperationInfo.baseSkill + baseOperationInfo.bonusSkill
        local skillWithReagents = operationInfoWithReagents.baseSkill + operationInfoWithReagents.bonusSkill

        return skillWithReagents - baseSkill
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
    table.foreach(self.requiredReagents, function(_, reagent)
        if reagent.hasQuality then
            reagent:Clear()
            reagent.items[qualityID].quantity = reagent.requiredQuantity
        else
            reagent.items[1].quantity = reagent.requiredQuantity
        end
    end)
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
    local hasSparkReagent = true
    if self:HasSparkSlot() then
        hasSparkReagent = self.sparkReagentSlot:HasItem(multiplier, crafterUID)
    end
    -- update item cache for all possible optional reagents if I am the crafter
    if crafterUID == CraftSim.UTIL:GetPlayerCrafterUID() then
        for _, slot in pairs(GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })) do
            ---@type CraftSim.OptionalReagentSlot
            slot = slot
            for _, possibleReagent in pairs(slot.possibleReagents) do
                local itemID = possibleReagent.item:GetItemID()
                CraftSim.ITEM_COUNT:UpdateAllCountsForItemID(itemID)
            end
        end
        if self:HasSparkSlot() and hasSparkReagent then
            for _, possibleSparkReagent in pairs(self.sparkReagentSlot.possibleReagents or {}) do
                local itemID = possibleSparkReagent.item:GetItemID()
                CraftSim.ITEM_COUNT:UpdateAllCountsForItemID(itemID)
            end
        end
    end



    local hasVellumIfneeded = true

    if self.recipeData.isEnchantingRecipe then
        local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, CraftSim.CONST
            .ENCHANTING_VELLUM_ID)
        hasVellumIfneeded = itemCount >= multiplier
    end


    return hasRequiredReagents and hasOptionalReagents and hasSparkReagent and hasVellumIfneeded
end

function CraftSim.ReagentData:GetCraftableAmount(crafterUID)
    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)

    print("getCraftable amount", false, true)

    local currentMinimumReagentFit = math.huge
    for _, requiredReagent in pairs(self.requiredReagents) do
        if not requiredReagent:HasItems(1, crafterUID) then
            return 0
        end
        currentMinimumReagentFit = math.min(requiredReagent:HasQuantityXTimes(crafterUID), currentMinimumReagentFit)
    end

    if self:HasSparkSlot() then
        if self.sparkReagentSlot.activeReagent then
            currentMinimumReagentFit = math.min(self.sparkReagentSlot:HasQuantityXTimes(crafterUID),
                currentMinimumReagentFit)
        else
            currentMinimumReagentFit = 0
        end
    end

    print("minimum required fit: " .. tostring(currentMinimumReagentFit))

    local currentMinimumReagentFitOptional = math.huge
    ---@type CraftSim.OptionalReagentSlot[]
    local optionalReagentSlots = GUTIL:Concat({ self.optionalReagentSlots, self.finishingReagentSlots })
    for _, optionalReagentSlot in pairs(optionalReagentSlots) do
        if not optionalReagentSlot:HasItem(1, crafterUID) then
            return 0
        end
        currentMinimumReagentFitOptional = math.min(optionalReagentSlot:HasQuantityXTimes(crafterUID),
            currentMinimumReagentFitOptional)
    end
    print("minimum optional fit: " .. tostring(currentMinimumReagentFitOptional))

    local vellumMinimumFit = math.huge
    if self.recipeData.isEnchantingRecipe then
        local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID, CraftSim.CONST
            .ENCHANTING_VELLUM_ID)
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
    local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CRAFTQ)
    multiplier = multiplier or 1
    local iconSize = 25
    local text = ""
    for _, requiredReagent in pairs(self.requiredReagents) do
        local reagentIcon = requiredReagent.items[1].item:GetItemIcon()
        local inlineIcon = GUTIL:IconToText(reagentIcon, iconSize, iconSize)
        text = text .. inlineIcon
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

            if itemCount >= (requiredReagent.requiredQuantity * multiplier) then
                quantityText = f.g(tostring(requiredReagent.requiredQuantity * multiplier))
            end

            local crafterText = ""
            -- add crafterInfo text if reagent is supposed to be crafted by the player
            -- check for quantity not needed for non quality items
            if self.recipeData:IsSelfCraftedReagent(itemID) then
                local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes
                    [itemID]
                if optimizedReagentRecipeData then
                    crafterText = f.white(" (" ..
                        optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
                end
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

                if itemCount >= reagentItem.quantity * multiplier or (reagentItem.quantity == 0 and totalCountOK) then
                    quantityText = f.g(tostring(reagentItem.quantity * multiplier))
                end
                local qualityIcon = GUTIL:GetQualityIconString(qualityID, 20, 20)
                local crafterText = ""
                -- add crafterInfo text if reagent is supposed to be crafted by the player
                if self.recipeData:IsSelfCraftedReagent(itemID) and reagentItem.quantity > 0 then
                    local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes[itemID]
                    if optimizedReagentRecipeData then
                        crafterText = f.white(" (" ..
                            optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
                    end
                end
                text = text .. qualityIcon .. quantityText .. crafterText .. "   "
            end
            text = text .. "\n"
        end
    end

    if self:HasSparkSlot() then
        if self.sparkReagentSlot.activeReagent then
            local reagentIcon = self.sparkReagentSlot.activeReagent.item:GetItemIcon()
            local inlineIcon = GUTIL:IconToText(reagentIcon, iconSize, iconSize)
            text = text .. inlineIcon
            local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(crafterUID,
                self.sparkReagentSlot.activeReagent.item:GetItemID())
            local quantityText = f.r(tostring(multiplier) .. "(" .. tostring(itemCount) .. ")")
            if itemCount >= multiplier then
                quantityText = f.g(tostring(multiplier))
            end
            local crafterText = ""
            -- add crafterInfo text if reagent is supposed to be crafted by the player
            local optimizedReagentRecipeData = self.recipeData.optimizedSubRecipes
                [self.sparkReagentSlot.activeReagent.item:GetItemID()]
            if optimizedReagentRecipeData then
                crafterText = f.white(" (" ..
                    optimizedReagentRecipeData:GetFormattedCrafterText(false, true, 12, 12) .. ")")
            end
            text = text .. quantityText .. crafterText .. "   "
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
            local qualityID = GUTIL:GetQualityIDFromLink(optionalReagentSlot.activeReagent.item:GetItemLink())
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
        local itemCount = C_Item.GetItemCount(craftingReagentInfo.itemID, true, false, true)
        CraftSim.DB.ITEM_COUNT:Save(crafterUID, craftingReagentInfo.itemID, itemCount)
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
    copy.sparkReagentSlot = self.sparkReagentSlot and self.sparkReagentSlot:Copy(recipeData)

    return copy
end

function CraftSim.ReagentData:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:AddList("requiredReagents", self.requiredReagents)
    jb:AddList("optionalReagentSlots", self.optionalReagentSlots)
    jb:AddList("finishingReagentSlots", self.finishingReagentSlots)
    jb:Add("sparkReagentSlot", self.sparkReagentSlot)
    jb:Add("salvageReagentSlot", self.salvageReagentSlot, true)
    jb:End()
    return jb.json
end
