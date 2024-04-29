---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_COUNT : CraftSim.DB.Repository
CraftSim.DB.ITEM_COUNT = CraftSim.DB:RegisterRepository()

function CraftSim.DB.ITEM_COUNT:Init()
    if not CraftSimDB.itemCountDB then
        ---@type CraftSimDB.Database
        CraftSimDB.itemCountDB = {
            ---@type table<string, table<number, number>> table<crafterUID, table<itemID, count>>
            data = {},
            version = 0,
        }
    end

    CraftSimDB.itemCountDB.data = CraftSimDB.itemCountDB.data or {}
end

function CraftSim.DB.ITEM_COUNT:Migrate()
    -- 0 -> 1
    if CraftSimDB.itemCountDB.version == 0 then
        -- move old saved variable to new db if it exists, otherwise init new table
        CraftSimDB.itemCountDB.data = CraftSimItemCountCache or {}
        CraftSimDB.itemCountDB.version = 1
    end

    -- 1 -> 2 (16.1.2 -> 16.1.3)
    if CraftSimDB.itemCountDB.version == 1 then
        -- remove any crafter entries with colored names...
        for crafterUID, _ in pairs(CraftSimDB.itemCountDB.data or {}) do
            if string.find(crafterUID, '\124c') then
                CraftSimDB.itemCountDB.data[crafterUID] = nil
            end
        end

        CraftSimDB.itemCountDB.version = 2
    end
end

function CraftSim.DB.ITEM_COUNT:CleanUp()
    if _G["CraftSimItemCountCache"] then
        -- remove it
        _G["CraftSimItemCountCache"] = nil
    end
end

function CraftSim.DB.ITEM_COUNT:ClearAll()
    wipe(CraftSimDB.itemCountDB.data)
end

---@param crafterUID CrafterUID
---@param itemID number
---@return number itemCount
function CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID)
    CraftSimDB.itemCountDB.data[crafterUID] = CraftSimDB.itemCountDB.data[crafterUID] or {}
    CraftSimDB.itemCountDB.data[crafterUID][itemID] = CraftSimDB.itemCountDB.data[crafterUID][itemID] or 0
    return CraftSimDB.itemCountDB.data[crafterUID][itemID]
end

---@param crafterUID CrafterUID
---@param itemID number
---@param count number
function CraftSim.DB.ITEM_COUNT:Save(crafterUID, itemID, count)
    CraftSimDB.itemCountDB.data[crafterUID] = CraftSimDB.itemCountDB.data[crafterUID] or {}
    CraftSimDB.itemCountDB.data[crafterUID][itemID] = count
end
