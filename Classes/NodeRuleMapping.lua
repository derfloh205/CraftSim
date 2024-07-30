---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

---@class CraftSim.IDMapping : CraftSim.CraftSimObject
CraftSim.NodeRuleMapping = CraftSim.CraftSimObject:extend()

---@param idMapping table
---@param exceptionRecipeIDs number[]
---@param affectedReagentIDs number[]
---@param recipeData CraftSim.RecipeData
function CraftSim.NodeRuleMapping:new(recipeData, idMapping, locMapping, idLocMapping, exceptionRecipeIDs,
                                      affectedReagentIDs,
                                      activationBuffIDs)
    self.recipeData = recipeData
    ---@type CategoryMapping[]
    self.idMapping = {}
    ---@type CategoryMapping[]
    self.locMapping = {}
    ---@type CategoryMapping[]
    self.idLocMapping = {}
    self.exceptionRecipeIDs = exceptionRecipeIDs or {}
    self.affectedReagentIDs = affectedReagentIDs or {}
    self.activationBuffIDs = activationBuffIDs or {}

    for categoryID, subtypeIDs in pairs(idMapping or {}) do
        tinsert(self.idMapping, CraftSim.CategoryMapping(categoryID, subtypeIDs))
    end

    for categoryID, inventoryEquipLocations in pairs(locMapping or {}) do
        tinsert(self.locMapping, CraftSim.CategoryMapping(categoryID, inventoryEquipLocations))
    end

    for categoryID, idLocMappings in pairs(idLocMapping or {}) do
        tinsert(self.idLocMapping, CraftSim.CategoryMapping(categoryID, idLocMappings))
    end
end

function CraftSim.NodeRuleMapping:Debug()
    local debugLines = {}

    for _, idCategory in pairs(self.idMapping) do
        table.insert(debugLines, "Category: " .. tostring(idCategory.categoryID))

        for _, subtypeID in pairs(idCategory.subIDs) do
            table.insert(debugLines, "-ST: " .. tostring(subtypeID))
        end
    end

    if #self.exceptionRecipeIDs > 0 then
        table.insert(debugLines, "ExceptionRecipeIDs: ")
    end
    for _, recipeID in pairs(self.exceptionRecipeIDs) do
        table.insert(debugLines, "-E: " .. tostring(recipeID))
    end
    return debugLines
end

function CraftSim.NodeRuleMapping:AffectsRecipe()
    local recipeData = self.recipeData

    -- print("ID Mapping affect?")
    -- print("categoryID: " .. tostring(recipeData.categoryID))
    -- print("subtypeID: " .. tostring(recipeData.subtypeID))

    if #self.activationBuffIDs > 0 then
        local atLeastOneActive = GUTIL:Some(self.activationBuffIDs, function(buffID)
            return recipeData.buffData:IsBuffActive(buffID)
        end)
        if not atLeastOneActive then
            return false
        end
    end

    -- an exception always matches
    if tContains(self.exceptionRecipeIDs, recipeData.recipeID) then
        return true
    end
    -- if it matches all categories it matches all items
    if CraftSim.GUTIL:Find(self.idMapping, function(c) return c.categoryID == CraftSim.CONST.RECIPE_CATEGORIES.ALL end) then
        return true
    end

    -- for all categories check if its subtypes contain the recipesubtype or all
    -- if the specific categoryID to subtypeIDs combination matches it matches
    for _, categoryMapping in pairs(self.idMapping) do
        if recipeData.categoryID == categoryMapping.categoryID then
            if tContains(categoryMapping.subIDs, CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL) then
                return true
            elseif tContains(categoryMapping.subIDs, recipeData.subtypeID) then
                return true
            end
        end
    end

    -- inventory type id is also a possibility
    for _, categoryMapping in pairs(self.locMapping) do
        if recipeData.categoryID == categoryMapping.categoryID then
            if recipeData.itemEquipLocation and tContains(categoryMapping.subIDs, recipeData.itemEquipLocation) then
                return true
            end
        end
    end

    -- last but not least the idLocMapping
    for _, categoryMapping in pairs(self.idLocMapping or {}) do
        if recipeData.categoryID == categoryMapping.categoryID then
            for subtypeID, itemEquipLocation in pairs(categoryMapping.subIDs) do
                if recipeData.subtypeID == subtypeID and recipeData.itemEquipLocation and recipeData.itemEquipLocation == itemEquipLocation then
                    return true
                end
            end
        end
    end

    -- if recipe uses an affected reagent it automatically is affected by this rule
    if #self.affectedReagentIDs > 0 and recipeData.reagentData:HasOneOfReagents(self.affectedReagentIDs) then
        return true
    end

    return false
end
