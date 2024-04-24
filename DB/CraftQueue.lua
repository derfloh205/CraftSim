---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.CRAFT_QUEUE
CraftSim.DB.CRAFT_QUEUE = {}

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

---@type CraftSim.CraftQueueItem.Serialized[]
CraftSimCraftQueueCache = CraftSimCraftQueueCache or {}

function CraftSim.DB.CRAFT_QUEUE:ClearAll()
    wipe(CraftSimCraftQueueCache)
end
