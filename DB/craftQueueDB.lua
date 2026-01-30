---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.CRAFT_QUEUE : CraftSim.DB.Repository
CraftSim.DB.CRAFT_QUEUE = CraftSim.DB:RegisterRepository("CraftQueueDB")

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
    self.db = CraftSimDB.craftQueueDB

    CraftSimDB.craftQueueDB.data = CraftSimDB.craftQueueDB.data or {}
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


--- Migrations
function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_0_1_Import_from_CraftSimRecipeDataCache()
    if _G["CraftSimCraftQueueCache"] then
            CraftSimDB.craftQueueDB.data = _G["CraftSimCraftQueueCache"]
        end
end

function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_1_2()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
end

function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_2_3()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
end

function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_3_4()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
end

function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_4_5()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
end

function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_5_6()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
end

function CraftSim.DB.CRAFT_QUEUE.MIGRATION:M_6_7()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
end


