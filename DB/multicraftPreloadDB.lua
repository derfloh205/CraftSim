---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.MULTICRAFT_PRELOAD : CraftSim.DB.Repository
CraftSim.DB.MULTICRAFT_PRELOAD = CraftSim.DB:RegisterRepository()

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

    CraftSimDB.multicraftPreloadDB.data = CraftSimDB.multicraftPreloadDB.data or {}
end

function CraftSim.DB.MULTICRAFT_PRELOAD:Migrate()
    -- 0 -> 1
    if CraftSimDB.multicraftPreloadDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            CraftSimDB.multicraftPreloadDB.data = CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] or
                {}
        end
        CraftSimDB.multicraftPreloadDB.version = 1
    end
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
