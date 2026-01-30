---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.RECIPE_SUB_CRAFTER : CraftSim.DB.Repository
CraftSim.DB.RECIPE_SUB_CRAFTER = CraftSim.DB:RegisterRepository("RecipeSubCrafterDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.recipeSubCrafterDB")

function CraftSim.DB.RECIPE_SUB_CRAFTER:Init()
    if not CraftSimDB.recipeSubCrafterDB then
        ---@type CraftSimDB.Database
        CraftSimDB.recipeSubCrafterDB = {
            version = 0,
            ---@type table<RecipeID, CrafterUID>
            data = {},
        }
    end
    self.db = CraftSimDB.recipeSubCrafterDB

    CraftSimDB.recipeSubCrafterDB.data = CraftSimDB.recipeSubCrafterDB.data or {}
end

function CraftSim.DB.RECIPE_SUB_CRAFTER:ClearAll()
    wipe(CraftSimDB.recipeSubCrafterDB.data)
end

function CraftSim.DB.RECIPE_SUB_CRAFTER:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache and CraftSimRecipeDataCache["subRecipeCrafterCache"] then
        CraftSimRecipeDataCache["subRecipeCrafterCache"] = nil
    end
end

---@param recipeID RecipeID
---@return CrafterUID crafterUID?
function CraftSim.DB.RECIPE_SUB_CRAFTER:GetCrafter(recipeID)
    return CraftSimDB.recipeSubCrafterDB.data[recipeID]
end

---@param recipeID RecipeID
---@param crafterUID CrafterUID
---@return boolean
function CraftSim.DB.RECIPE_SUB_CRAFTER:IsCrafter(recipeID, crafterUID)
    return crafterUID == CraftSimDB.recipeSubCrafterDB.data[recipeID]
end

---@param recipeID RecipeID
---@param crafterUID CrafterUID
function CraftSim.DB.RECIPE_SUB_CRAFTER:SetCrafter(recipeID, crafterUID)
    CraftSimDB.recipeSubCrafterDB.data[recipeID] = crafterUID
end

--- Migrations

function CraftSim.DB.RECIPE_SUB_CRAFTER.MIGRATION:M_0_1_Initial_Migration_from_old_cache()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.recipeSubCrafterDB.data = CraftSimRecipeDataCache["subRecipeCrafterCache"] or {}
        end
end

function CraftSim.DB.RECIPE_SUB_CRAFTER.MIGRATION:M_1_2_Remove_colored_crafter_names()
    -- remove any crafter entries with colored names...
        for itemID, crafterUID in pairs(CraftSimDB.recipeSubCrafterDB.data or {}) do
            if string.find(crafterUID, '\124c') then
                CraftSimDB.recipeSubCrafterDB.data[itemID] = nil
            end
        end
end

function CraftSim.DB.RECIPE_SUB_CRAFTER.MIGRATION:M_2_3_TWW_Refactor_Reset()
    CraftSim.DB.RECIPE_SUB_CRAFTER:ClearAll()
end
