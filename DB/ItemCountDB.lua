---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_COUNT : Frame
CraftSim.DB.ITEM_COUNT = {}

---@type table<string, table<number, number>> table<crafterUID, table<itemID, count>>
CraftSimItemCountCache = {}

function CraftSim.DB.ITEM_COUNT:ClearAll()
    wipe(CraftSimItemCountCache)
end

---@param crafterUID CrafterUID
---@param itemID number
---@return number itemCount
function CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID)
    CraftSimItemCountCache[crafterUID] = CraftSimItemCountCache[crafterUID] or {}
    CraftSimItemCountCache[crafterUID][itemID] = CraftSimItemCountCache[crafterUID][itemID] or 0
    return CraftSimItemCountCache[crafterUID][itemID]
end

---@param crafterUID CrafterUID
---@param itemID number
---@param count number
function CraftSim.DB.ITEM_COUNT:Save(crafterUID, itemID, count)
    CraftSimItemCountCache[crafterUID] = CraftSimItemCountCache[crafterUID] or {}
    CraftSimItemCountCache[crafterUID][itemID] = count
end