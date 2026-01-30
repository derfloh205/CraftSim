---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.MULTICRAFT_PRELOAD : CraftSim.DB.Repository
CraftSim.DB.MULTICRAFT_PRELOAD = CraftSim.DB:RegisterRepository("MulticraftPreloadDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.multicraftPreloadDB")

function CraftSim.DB.MULTICRAFT_PRELOAD:Init()
    if not CraftSimDB.multicraftPreloadDB then
        ---@type CraftSimDB.Database
        CraftSimDB.multicraftPreloadDB = {
            version = 0,
            ---@type table<Enum.Profession, boolean>
            data = {},
        }
    end

    self.db = CraftSimDB.multicraftPreloadDB

    CraftSimDB.multicraftPreloadDB.data = CraftSimDB.multicraftPreloadDB.data or {}
end

function CraftSim.DB.MULTICRAFT_PRELOAD:ClearAll()
    wipe(CraftSimDB.multicraftPreloadDB.data)
end

---@param profession Enum.Profession
---@param preloaded boolean
function CraftSim.DB.MULTICRAFT_PRELOAD:Save(profession, preloaded)
    CraftSimDB.multicraftPreloadDB.data[profession] = preloaded
end

---@param profession Enum.Profession
---@return boolean preloaded
function CraftSim.DB.MULTICRAFT_PRELOAD:Get(profession)
    return CraftSimDB.multicraftPreloadDB.data[profession] == true -- to convert to boolean
end

function CraftSim.DB.MULTICRAFT_PRELOAD:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache and CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] then
        CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] = nil
    end
end

--- Migrations
function CraftSim.DB.MULTICRAFT_PRELOAD.MIGRATION:M_0_1_Import_from_CraftSimRecipeDataCache()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.multicraftPreloadDB.data = CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] or
                {}
        end
end