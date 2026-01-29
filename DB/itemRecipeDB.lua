---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_RECIPE : CraftSim.DB.Repository
CraftSim.DB.ITEM_RECIPE = CraftSim.DB:RegisterRepository("ItemRecipeDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.itemRecipeDB")

---@class CraftSim.ItemRecipeData
---@field recipeID RecipeID
---@field itemID ItemID
---@field qualityID QualityID
---@field crafters CrafterUID[]

function CraftSim.DB.ITEM_RECIPE:Init()
    if not CraftSimDB.itemRecipeDB then
        ---@type CraftSimDB.Database
        CraftSimDB.itemRecipeDB = {
            version = 0,
            ---@type table<ItemID, CraftSim.ItemRecipeData>
            data = {},
        }
    end

    self.db = CraftSimDB.itemRecipeDB

    CraftSimDB.itemRecipeDB.data = CraftSimDB.itemRecipeDB.data or {}
end

function CraftSim.DB.ITEM_RECIPE:ClearAll()
    wipe(CraftSimDB.itemRecipeDB.data)
end

function CraftSim.DB.ITEM_RECIPE:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache then
        if CraftSimRecipeDataCache["itemRecipeCache"] then
            CraftSimRecipeDataCache["itemRecipeCache"] = nil
        end
    end
end

---@param itemID ItemID
---@return CraftSim.ItemRecipeData itemRecipeData
function CraftSim.DB.ITEM_RECIPE:Get(itemID)
    return CraftSimDB.itemRecipeDB.data[itemID]
end

---@return CraftSim.ItemRecipeData[]
function CraftSim.DB.ITEM_RECIPE:GetAll()
    return CraftSimDB.itemRecipeDB.data
end

---@param recipeID RecipeID
---@param qualityID QualityID
---@param itemID ItemID
---@param crafterUID CrafterUID
function CraftSim.DB.ITEM_RECIPE:Add(recipeID, qualityID, itemID, crafterUID)
    ---@type CraftSim.ItemRecipeData
    local itemRecipeData = CraftSimDB.itemRecipeDB.data[itemID] or {
        recipeID = recipeID,
        qualityID = qualityID,
        itemID = itemID,
        crafters = {}
    }

    if not tContains(itemRecipeData.crafters, crafterUID) then
        tinsert(itemRecipeData.crafters, crafterUID)

        if #itemRecipeData.crafters == 1 then
            CraftSim.DB.RECIPE_SUB_CRAFTER:SetCrafter(recipeID, crafterUID)
        end
    end

    CraftSimDB.itemRecipeDB.data[itemID] = itemRecipeData
end

--- Migrations

function CraftSim.DB.ITEM_RECIPE.MIGRATION:M_0_1_Import_from_CraftSimRecipeDataCache()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.itemRecipeDB.data = CraftSimRecipeDataCache["itemRecipeCache"] or {}
        end
end

function CraftSim.DB.ITEM_RECIPE.MIGRATION:M_1_2_Remove_colored_crafter_names()
    -- remove any crafter entries with colored names...
        for _, data in pairs(CraftSimDB.itemRecipeDB.data or {}) do
            local correctedCrafterUIDs = {}
            for _, crafterUID in pairs(data.crafters) do
                if not string.find(crafterUID, '\124c') then
                    tinsert(correctedCrafterUIDs, crafterUID)
                end
            end
            data.crafters = correctedCrafterUIDs
        end
end

function CraftSim.DB.ITEM_RECIPE.MIGRATION:M_2_3_Restore_data_table_if_missing()
    -- restore data table if not existing
        CraftSimDB.itemCountDB.data = CraftSimDB.itemCountDB.data or {}
end

function CraftSim.DB.ITEM_RECIPE.MIGRATION:M_3_4_TWW_Refactor()
     CraftSim.DB.ITEM_RECIPE:ClearAll()
end