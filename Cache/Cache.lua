---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CACHE
CraftSim.CACHE = {}

---@alias CrafterUID string Name-Server
---@alias RecipeID number
---@alias CooldownDataSerializationID RecipeID | CraftSim.SHARED_PROFESSION_COOLDOWNS
---@alias ItemID number
---@alias QualityID number between 1 and 5

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE)

function CraftSim.CACHE:HandleCraftSimCacheUpdates()
    -- init default cache fields in case of cache field updates
    CraftSim.CACHE.RECIPE_DATA:HandleUpdates()
end

function CraftSim.CACHE:ClearAll()
    CraftSim.CACHE.RECIPE_DATA:ClearAll()
    CraftSim.CACHE.ITEM_COUNT:ClearAll()
    CraftSim.CACHE.CRAFT_QUEUE:ClearAll()
    CraftSim.PRICE_OVERRIDE:ClearAll()
end
