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

local print = CraftSim.DEBUG:RegisterDebugID("Database")

---@class CraftSim.DB.Repository
---@field Init function
---@field ClearAll function
---@field Migrate function
---@field CleanUp function

---@class CraftSimDB.Database
---@field version number
---@field data table

---@class CraftSimDB
CraftSimDB = CraftSimDB or {}

---@type CraftSim.DB.Repository[]
CraftSim.DB.repositories = {}

---@return CraftSim.DB.Repository
function CraftSim.DB:RegisterRepository()
    ---@type CraftSim.DB.Repository
    local repository = {
        Init = function() end,
        Migrate = function() end,
        ClearAll = function() end,
        CleanUp = function() end,
    }
    tinsert(CraftSim.DB.repositories, repository)
    return repository
end

function CraftSim.DB:Init()
    for _, repository in ipairs(self.repositories) do
        repository:Init()
        repository:Migrate()
        repository:CleanUp()
    end

    CraftSim.DB:PostInitCleanUp()
end

function CraftSim.DB:PostInitCleanUp()
    if _G["CraftSimRecipeDataCache"] then
        _G["CraftSimRecipeDataCache"].cacheVersions = nil
        local empty = GUTIL:Count(_G["CraftSimRecipeDataCache"]) == 0
        if empty then
            _G["CraftSimRecipeDataCache"] = nil
        end
    end

    if _G["CraftSimDebugData"] then
        _G["CraftSimDebugData"] = nil
    end
end

function CraftSim.DB:ClearAll()
    for _, repository in ipairs(self.repositories) do
        repository:ClearAll()
    end
end

---@param db CraftSimDB.Database
---@return fun(from: number, to:number, migrate: function)
function CraftSim.DB:GetMigrateFunction(db)
    return function(from, to, migrate)
        if db.version == from then
            migrate()
            db.version = to
        end
    end
end
