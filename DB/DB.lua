---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local systemPrint = print
local f = GUTIL:GetFormatter()

---@class CraftSim.DB
CraftSim.DB = {}

---@alias CrafterUID string Name-Server
---@alias RecipeID number
---@alias CooldownDataSerializationID RecipeID | CraftSim.SHARED_PROFESSION_COOLDOWNS
---@alias ItemID number
---@alias CurrencyID number
---@alias QualityID number between 1 and 5

local print = CraftSim.DEBUG:RegisterDebugID("Database")

---@class CraftSim.DB.Repository
---@field name string
---@field MIGRATION table<string, function>
---@field db CraftSimDB.Database?
---@field Init function
---@field ClearAll function
---@field CleanUp function

---@class CraftSimDB.Database
---@field version number
---@field data table

---@class CraftSimDB.Migration
---@field from number
---@field to number
---@field migrate function
---@field msg? string

---@class CraftSimDB
CraftSimDB = CraftSimDB or {}

---@type CraftSim.DB.Repository[]
CraftSim.DB.repositories = {}

---@param name string
---@return CraftSim.DB.Repository
function CraftSim.DB:RegisterRepository(name)
    ---@type CraftSim.DB.Repository
    local repository = {
        name = name,
        Init = function() end,
        ClearAll = function() end,
        CleanUp = function() end,
        MIGRATION = {},
    }
    tinsert(CraftSim.DB.repositories, repository)
    return repository
end

function CraftSim.DB:Init()
    for _, repository in ipairs(self.repositories) do
        repository:Init()
        if not self:Migrate(repository)then 
            self:ReportMigrationError()
            return
        end
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

function CraftSim.DB:ReportMigrationError()
    systemPrint(f.r("CraftSimDB Update failed! Please report any Lua Errors to the Dev"))
end

---@param repository CraftSim.DB.Repository
---@return boolean success
function CraftSim.DB:Migrate(repository)
    local migrations = self:GetMigrationFunctionsFromRepository(repository)
    table.sort(migrations, function(a, b) return a.from < b.from end)

    for _, migration in ipairs(migrations) do
        if repository.db.version == migration.from then
            if migration.msg then
                systemPrint(f.l("CraftSimDB Updating ") .. f.bb(repository.name) .. " " .. f.g(migration.msg))
            end
            if not pcall(migration.migrate) then
                return false
            else
                repository.db.version = migration.to
            end
        end
    end
    return true
end

---@param repository CraftSim.DB.Repository
---@return CraftSimDB.Migration[] migrations
function CraftSim.DB:GetMigrationFunctionsFromRepository(repository)
    ---@type CraftSimDB.Migration[]
    local migrations = {}
    --- extract migration functions from .MIGRATION repostory field by function name
    --- function names will be M_<from>_<to>_<description> and any _ in description will be replaced with spaces
    for funcName, func in pairs(repository.MIGRATION) do
        local from, to, description = string.match(funcName, "^M_(%d+)_(%d+)_(.+)$")
        if from and to then
            tinsert(migrations, {
                from = tonumber(from),
                to = tonumber(to),
                migrate = func,
                msg = description:gsub("_", " "),
            })
        end
    end
    return migrations
end