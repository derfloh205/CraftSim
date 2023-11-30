_, CraftSim = ...


local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

---@class CraftSim.IDMapping
CraftSim.IDMapping = CraftSim.Object:extend()

---@param idMappingData table
---@param exceptionRecipeIDs number[]
---@param recipeData CraftSim.RecipeData
function CraftSim.IDMapping:new(recipeData, idMappingData, exceptionRecipeIDs)
    self.recipeData = recipeData
    ---@type CraftSim.IDCategory[]
    self.categories = {}
    self.exceptionRecipeIDs = exceptionRecipeIDs or {}

    for categoryID, subtypeIDs in pairs(idMappingData or {}) do
        table.insert(self.categories, CraftSim.IDCategory(categoryID, subtypeIDs))
    end
end

function CraftSim.IDMapping:Debug()
    local debugLines = {}

    for _, idCategory in pairs(self.categories) do
        table.insert(debugLines, "Category: " .. tostring(idCategory.categoryID))

        for _, subtypeID in pairs(idCategory.subtypeIDs) do
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

function CraftSim.IDMapping:AffectsRecipe()
    local recipeData = self.recipeData

    -- print("ID Mapping affect?")
    -- print("categoryID: " .. tostring(recipeData.categoryID))
    -- print("subtypeID: " .. tostring(recipeData.subtypeID))

    -- an exception always matches
    if tContains(self.exceptionRecipeIDs, recipeData.recipeID) then
        return true
    end
    -- if it matches all categories it matches all items
    if CraftSim.GUTIL:Find(self.categories, function(c) return c.categoryID == CraftSim.CONST.RECIPE_CATEGORIES.ALL end) then
        return true
    end
    
    -- for all categories check if its subtypes contain the recipesubtype or all
    -- if the specific categoryID to subtypeIDs combination matches it matches
    for _, idCategory in pairs(self.categories) do
        if recipeData.categoryID == idCategory.categoryID then
            if tContains(idCategory.subtypeIDs, CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALL) then
                return true
            elseif tContains(idCategory.subtypeIDs, recipeData.subtypeID) then
                return true
            end
        end
    end

    return false
end