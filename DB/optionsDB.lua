---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.OPTIONS
CraftSim.DB.OPTIONS = {}

function CraftSim.DB.OPTIONS:Init()
    if not CraftSimDB.optionsDB then
        CraftSimDB.optionsDB = {
            ---@type table<CraftSim.GENERAL_OPTIONS, any>
            data = {},
            version = 0,
        }
    end
end

function CraftSim.DB.OPTIONS:Migrate()
    -- 0 -> 1
    if CraftSimDB.optionsDB.version == 0 then
        -- move old saved variable to new db if it exists, otherwise init new table
        CraftSimDB.optionsDB.data = {}

        -- remap to new options enum
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PRICE_DEBUG] = CraftSimOptions.priceDebug
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PRICE_SOURCE] = CraftSimOptions.priceSource




        CraftSimDB.optionsDB.version = 1
    end
end

function CraftSim.DB.OPTIONS:CleanUp()
    if _G["CraftSimOptions"] then
        -- remove old
        --_G["CraftSimOptions"] = nil
    end
end

function CraftSim.DB.OPTIONS:ClearAll()
    wipe(CraftSimDB.optionsDB.data)
end

---@param option CraftSim.GENERAL_OPTIONS
---@return any optionValue
function CraftSim.DB.OPTIONS:Get(option)
    CraftSimDB.optionsDB.data[option] = CraftSimDB.optionsDB.data[option] or
        CraftSim.CONST.GENERAL_OPTIONS_DEFAULTS[option]
    return CraftSimDB.optionsDB.data[option]
end

---@param option CraftSim.GENERAL_OPTIONS
---@param value any
function CraftSim.DB.OPTIONS:Save(option, value)
    CraftSimDB.itemCountDB.data[option] = value
end
