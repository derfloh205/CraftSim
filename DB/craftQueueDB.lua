---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.CRAFT_QUEUE : CraftSim.DB.Repository
CraftSim.DB.CRAFT_QUEUE = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:RegisterDebugID("Database.craftQueueDB")

function CraftSim.DB.CRAFT_QUEUE:Init()
    if not CraftSimDB.craftQueueDB then
        ---@class CraftSimDB.CraftQueueDB : CraftSimDB.Database
        CraftSimDB.craftQueueDB = {
            version = 0,
            ---@type CraftSim.CraftQueueItem.Serialized[]
            data = {},
        }
    end

    CraftSimDB.craftQueueDB.data = CraftSimDB.craftQueueDB.data or {}
end

function CraftSim.DB.CRAFT_QUEUE:Migrate()
    local migrate = CraftSim.DB:GetMigrateFunction(CraftSimDB.craftQueueDB)

    migrate(0, 1, function()
        if _G["CraftSimCraftQueueCache"] then
            CraftSimDB.craftQueueDB.data = _G["CraftSimCraftQueueCache"]
        end
    end)
    migrate(1, 2, function()
        CraftSim.DB.CRAFT_QUEUE:ClearAll()
    end)
    migrate(2, 3, function()
        CraftSim.DB.CRAFT_QUEUE:ClearAll()
    end)
    migrate(3, 4, function()
        CraftSim.DB.CRAFT_QUEUE:ClearAll()
    end)
    migrate(4, 5, function()
        CraftSim.DB.CRAFT_QUEUE:ClearAll()
    end)
    migrate(5, 6, function()
        CraftSim.DB.CRAFT_QUEUE:ClearAll()
    end)
    migrate(6, 7, function()
        CraftSim.DB.CRAFT_QUEUE:ClearAll()
    end)
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
