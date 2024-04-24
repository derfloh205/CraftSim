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

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

---@class CraftSim.DB.Repository
---@field Init function
---@field ClearAll function
---@field Migrate function
---@field CleanUp function

---@class CraftSimDB.Database
---@field version number
---@field data table

---@class CraftSimDB
---@field itemCountDB CraftSimDB.Database
---@field optionsDB CraftSimDB.Database
---@field craftQueueDB CraftSimDB.Database
---@field itemRecipeDB CraftSimDB.Database
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
end

function CraftSim.DB:ClearAll()
    for _, repository in ipairs(self.repositories) do
        repository:ClearAll()
    end
end
