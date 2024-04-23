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
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_MATERIALS] = CraftSimOptions
            .tsmPriceKeyMaterials
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_RESULTS] = CraftSimOptions
            .tsmPriceKeyItems
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.QUALITY_BREAKPOINT_OFFSET] = CraftSimOptions
            .breakPointOffset
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.TOP_GEAR_MODE] = CraftSimOptions
            .topGearMode
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.TOP_GEAR_AUTO_UPDATE] = CraftSimOptions
            .topGearAutoUpdate
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.SHOW_PROFIT_PERCENTAGE] = CraftSimOptions
            .showProfitPercentage
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.OPEN_LAST_RECIPE] = CraftSimOptions
            .openLastRecipe
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.SHOW_NEWS] = CraftSimOptions
            .optionsShowNews
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MINIMAP_BUTTON_HIDE] = CraftSimOptions
            .optionsHideMinimapButton
        -- TODO
        -- MODULE VISIBILITIES
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_REAGENT_OPTIMIZATION] = CraftSimOptions
            .moduleMaterials
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_AVERAGE_PROFIT] = CraftSimOptions
            .moduleStatWeights
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_TOP_GEAR] = CraftSimOptions
            .moduleTopGear
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_COST_OVERVIEW] = CraftSimOptions
            .modulePriceDetails
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_SPEC_INFO] = CraftSimOptions
            .moduleSpecInfo
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_PRICE_OVERRIDE] = CraftSimOptions
            .modulePriceOverride
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_RECIPE_SCAN] = CraftSimOptions
            .moduleRecipeScan
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_CRAFT_RESULTS] = CraftSimOptions
            .moduleCraftResults
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_CUSTOMER_SERVICE] = CraftSimOptions
            .moduleCustomerService
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_CUSTOMER_HISTORY] = CraftSimOptions
            .moduleCustomerHistory
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_COST_OPTIMIZATION] = CraftSimOptions
            .moduleCostOptimization
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_CRAFT_QUEUE] = CraftSimOptions
            .moduleCraftQueue
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_CRAFT_BUFFS] = CraftSimOptions
            .moduleCraftBuffs
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_COOLDOWNS] = CraftSimOptions
            .moduleCooldowns
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_EXPLANATIONS] = CraftSimOptions
            .moduleExplanations
        CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_STATISTICS] = CraftSimOptions
            .moduleStatistics




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
