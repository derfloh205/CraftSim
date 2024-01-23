---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.CACHE
CraftSim.CACHE = CraftSim.CACHE

---@class CraftSim.CACHE.CRAFT_QUEUE
CraftSim.CACHE.CRAFT_QUEUE = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE)

---@type CraftSim.CraftQueueItem.Serialized[]
CraftSimCraftQueueCache = CraftSimCraftQueueCache or {}

function CraftSim.CACHE.CRAFT_QUEUE:ClearAll()
    wipe(CraftSimCraftQueueCache)
end
