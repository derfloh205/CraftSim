---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_RECIPE : CraftSim.DB.Repository
CraftSim.DB.ITEM_RECIPE = CraftSim.DB:RegisterRepository()

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

    CraftSimDB.itemRecipeDB.data = CraftSimDB.itemRecipeDB.data or {}
end

function CraftSim.DB.ITEM_RECIPE:Migrate()
    -- 0 -> 1
    if CraftSimDB.itemRecipeDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.itemRecipeDB.data = CraftSimRecipeDataCache["itemRecipeCache"] or {}
        end
        CraftSimDB.itemRecipeDB.version = 1
    end

    -- 1 -> 2 (16.1.3)
    if CraftSimDB.itemRecipeDB.version == 1 then
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

        CraftSimDB.itemRecipeDB.version = 2
    end

    -- 2 -> 3 (16.1.5)
    if CraftSimDB.itemRecipeDB.version == 2 then
        -- restore data table if not existing
        CraftSimDB.itemCountDB.data = CraftSimDB.itemCountDB.data or {}
        CraftSimDB.itemRecipeDB.version = 3
    end

    --  TWW Refactor
    if CraftSimDB.itemRecipeDB.version == 3 then
        self:ClearAll()
        CraftSimDB.itemRecipeDB.version = 4
    end
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
