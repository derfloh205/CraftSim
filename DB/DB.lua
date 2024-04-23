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

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE)

---@class CraftSimDB.Database
---@field version number
---@field data table

---@class CraftSimDB
---@field itemCountDB CraftSimDB.Database
---@field optionsDB CraftSimDB.Database
CraftSimDB = CraftSimDB or {}

function CraftSim.DB:Init()
    self.ITEM_COUNT:Init()
    self.OPTIONS:Init()

    CraftSim.DB:Migrate()
    CraftSim.DB:CleanUp()
end

function CraftSim.DB:Migrate()
    self.OPTIONS:Migrate()
    self.ITEM_COUNT:Migrate()
end

function CraftSim.DB:CleanUp()
    self.ITEM_COUNT:CleanUp()
    self.OPTIONS:CleanUp()
end

function CraftSim.DB:ClearAll()
    CraftSim.DB.RECIPE_DATA:ClearAll()
    CraftSim.DB.ITEM_COUNT:ClearAll()
    CraftSim.DB.CRAFT_QUEUE:ClearAll()
    CraftSim.PRICE_OVERRIDE:ClearAll()
    CraftSim.DB.OPTIONS:ClearAll()
end
