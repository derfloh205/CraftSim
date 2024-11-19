---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.RECIPE_SUB_CRAFTER : CraftSim.DB.Repository
CraftSim.DB.RECIPE_SUB_CRAFTER = CraftSim.DB:RegisterRepository()

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
    CraftSimDB.recipeSubCrafterDB.data = CraftSimDB.recipeSubCrafterDB.data or {}
end

function CraftSim.DB.RECIPE_SUB_CRAFTER:Migrate()
    -- 0 -> 1
    if CraftSimDB.recipeSubCrafterDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.recipeSubCrafterDB.data = CraftSimRecipeDataCache["subRecipeCrafterCache"] or {}
        end
        CraftSimDB.recipeSubCrafterDB.version = 1
    end

    -- 1 -> 2 (16.1.2 -> 16.1.3)
    if CraftSimDB.recipeSubCrafterDB.version == 1 then
        -- remove any crafter entries with colored names...
        for itemID, crafterUID in pairs(CraftSimDB.recipeSubCrafterDB.data or {}) do
            if string.find(crafterUID, '\124c') then
                CraftSimDB.recipeSubCrafterDB.data[itemID] = nil
            end
        end

        CraftSimDB.recipeSubCrafterDB.version = 2
    end

    -- reset for tww refactor
    if CraftSimDB.recipeSubCrafterDB.version == 2 then
        self:ClearAll()
        CraftSimDB.recipeSubCrafterDB.version = 3
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
