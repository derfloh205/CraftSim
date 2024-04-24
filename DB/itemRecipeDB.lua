---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_RECIPE : CraftSim.DB.Repository
CraftSim.DB.ITEM_RECIPE = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

---@class CraftSim.ItemRecipeData
---@field recipeID RecipeID
---@field itemID ItemID
---@field qualityID QualityID
---@field crafters CrafterUID[]

function CraftSim.DB.ITEM_RECIPE:Init()
    if not CraftSimDB.itemRecipeDB then
        CraftSimDB.itemRecipeDB = {
            version = 0,
            ---@type table<ItemID, CraftSim.ItemRecipeData>
            data = {},
        }
    end
end

function CraftSim.DB.ITEM_RECIPE:Migrate()
    -- 0 -> 1
    if CraftSimDB.itemRecipeDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.itemRecipeDB.data = CraftSimRecipeDataCache["itemRecipeCache"]
        end
        CraftSimDB.itemRecipeDB.version = 1
    end
end

function CraftSim.DB.ITEM_RECIPE:ClearAll()
    wipe(CraftSimDB.itemRecipeDB.data)
end

function CraftSim.DB.ITEM_RECIPE:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache["itemRecipeCache"] then
        CraftSimRecipeDataCache["itemRecipeCache"] = nil
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

        -- TODO: move responsibility to subRecipeCrafterCache?
        -- if the first and only crafter, enable in subRecipeCrafterCache
        -- if #CraftSimRecipeDataCache.itemRecipeCache[itemID].crafters == 1 then
        --     CraftSimRecipeDataCache.subRecipeCrafterCache[recipeID] = crafterUID
        -- end
    end

    CraftSimDB.itemRecipeDB.data[itemID] = itemRecipeData
end
