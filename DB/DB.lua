---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = {}

---@alias CrafterUID string Name-Server
---@alias RecipeID number
---@alias CooldownDataSerializationID RecipeID | CraftSim.SHARED_PROFESSION_COOLDOWNS
---@alias ItemID number
---@alias QualityID number between 1 and 5

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE)

function CraftSim.DB:HandleCraftSimCacheUpdates()
    -- init default cache fields in case of cache field updates
    CraftSim.DB.RECIPE_DATA:HandleUpdates()
end

function CraftSim.DB:ClearAll()
    CraftSim.DB.RECIPE_DATA:ClearAll()
    CraftSim.DB.ITEM_COUNT:ClearAll()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
    CraftSim.PRICE_OVERRIDE:ClearAll()
end
