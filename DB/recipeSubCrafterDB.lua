---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.RECIPE_SUB_CRAFTER : CraftSim.DB.Repository
CraftSim.DB.RECIPE_SUB_CRAFTER = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

function CraftSim.DB.RECIPE_SUB_CRAFTER:Init()
    if not CraftSimDB.recipeSubCrafterDB then
        ---@type CraftSimDB.Database
        CraftSimDB.recipeSubCrafterDB = {
            version = 0,
            ---@type table<RecipeID, CrafterUID>
            data = {},
        }
    end
end

function CraftSim.DB.RECIPE_SUB_CRAFTER:Migrate()
    -- 0 -> 1
    if CraftSimDB.recipeSubCrafterDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.recipeSubCrafterDB.data = CraftSimRecipeDataCache["subRecipeCrafterCache"]
        end
        CraftSimDB.recipeSubCrafterDB.version = 1
    end
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
