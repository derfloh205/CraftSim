---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.CRAFT_QUEUE : CraftSim.DB.Repository
CraftSim.DB.CRAFT_QUEUE = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

function CraftSim.DB.CRAFT_QUEUE:Init()
    if not CraftSimDB.craftQueueDB then
        CraftSimDB.craftQueueDB = {
            version = 0,
            ---@type CraftSim.CraftQueueItem.Serialized[]
            data = {},
        }
    end
end

function CraftSim.DB.CRAFT_QUEUE:Migrate()
    -- 0 -> 1
    if CraftSimDB.craftQueueDB.version == 0 then
        CraftSimDB.craftQueueDB.data = _G["CraftSimCraftQueueCache"] or {}
        CraftSimDB.craftQueueDB.version = 1
    end
end

function CraftSim.DB.CRAFT_QUEUE:ClearAll()
    wipe(CraftSimDB.craftQueueDB.data)
end

function CraftSim.DB.CRAFT_QUEUE:CleanUp()
    if _G["CraftSimCraftQueueCache"] then
        _G["CraftSimCraftQueueCache"] = nil
    end
end

function CraftSim.DB.CRAFT_QUEUE:GetAll()
    return CraftSimDB.craftQueueDB.data
end

---@param craftQueueItemSerialized CraftSim.CraftQueueItem.Serialized
function CraftSim.DB.CRAFT_QUEUE:Add(craftQueueItemSerialized)
    tinsert(CraftSimDB.craftQueueDB.data, craftQueueItemSerialized)
end
