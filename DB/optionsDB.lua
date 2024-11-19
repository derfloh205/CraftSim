---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Database.optionsDB")

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.OPTIONS : CraftSim.DB.Repository
CraftSim.DB.OPTIONS = CraftSim.DB:RegisterRepository()

function CraftSim.DB.OPTIONS:Init()
    if not CraftSimDB.optionsDB then
        ---@type CraftSimDB.Database
        CraftSimDB.optionsDB = {
            ---@type table<CraftSim.GENERAL_OPTIONS, any>
            data = {},
            version = 0,
        }
    end

    CraftSimDB.optionsDB.data = CraftSimDB.optionsDB.data or {}
end

function CraftSim.DB.OPTIONS:Migrate()
    local migrate = CraftSim.DB:GetMigrateFunction(CraftSimDB.optionsDB)


    migrate(0, 1, function()
        CraftSimDB.optionsDB.data = {}
        local CraftSimOptions = _G["CraftSimOptions"]
        if CraftSimOptions then
            -- remap to new options enum
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PRICE_SOURCE_REMINDER_DISABLED] = CraftSimOptions
                .doNotRemindPriceSource
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PRICE_DEBUG] = CraftSimOptions.priceDebug
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PRICE_SOURCE] = CraftSimOptions.priceSource
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_REAGENTS] = CraftSimOptions
                .tsmPriceKeyMaterials
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.TSM_PRICE_KEY_ITEMS] = CraftSimOptions
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
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.MODULE_CRAFT_LOG] = CraftSimOptions
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

            -- CUSTOMER HISTORY
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT] =
                CraftSimOptions
                .maxHistoryEntriesPerClient
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CUSTOMER_HISTORY_AUTO_PURGE_INTERVAL] =
                CraftSimOptions
                .customerHistoryAutoPurgeInterval
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CUSTOMER_HISTORY_AUTO_PURGE_LAST_PURGE] =
                CraftSimOptions
                .customerHistoryAutoPurgeLastPurge

            -- RECIPE SCAN
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_INCLUDE_SOULBOUND] = CraftSimOptions
                .recipeScanIncludeSoulbound
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_INCLUDE_GEAR] = CraftSimOptions
                .recipeScanIncludeGear
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_INCLUDE_NOT_LEARNED] = CraftSimOptions
                .recipeScanIncludeNotLearned
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_ONLY_FAVORITES] = CraftSimOptions
                .recipeScanOnlyFavorites
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_OPTIMIZE_PROFESSION_TOOLS] =
                CraftSimOptions
                .recipeScanOptimizeProfessionTools
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_SCAN_MODE] = CraftSimOptions
                .recipeScanScanMode
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_FILTERED_EXPANSIONS] = CraftSimOptions
                .recipeScanFilteredExpansions
            CraftSimDB.optionsDB.data["RECIPESCAN_IMPORT_ALL_PROFESSIONS"] = CraftSimOptions
                .recipeScanImportAllProfessions
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_OPTIMIZE_SUBRECIPES] = CraftSimOptions
                .recipeScanOptimizeSubRecipes
            CraftSimDB.optionsDB.data["RECIPESCAN_SORT_BY_PROFIT_MARGIN"] = CraftSimOptions
                ["recipeScanSortByProfitMargin"]
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_USE_INSIGHT] = CraftSimOptions
                .recipeScanUseInsight
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.RECIPESCAN_INCLUDED_PROFESSIONS] = CraftSimOptions
                .recipeScanIncludedProfessions


            -- PROFIT CALCULATION
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PROFIT_CALCULATION_MULTICRAFT_CONSTANT] =
                CraftSimOptions
                .customMulticraftConstant
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] =
                CraftSimOptions
                .customResourcefulnessConstant

            -- CUSTOMER SERVICE (legacy)
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CUSTOMER_SERVICE_WHISPER_FORMAT] =
                CraftSimOptions
                .customerServiceRecipeWhisperFormat
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CUSTOMER_SERVICE_ALLOW_LIVE_PREVIEW] =
                CraftSimOptions
                .customerServiceAllowAutoResult
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CUSTOMER_SERVICE_ACTIVE_PREVIEW_IDS] =
                CraftSimOptions
                .customerServiceActivePreviewIDs

            -- CRAFTING
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CRAFTING_GARBAGE_COLLECTION_ENABLED] =
                CraftSimOptions
                .craftGarbageCollectEnabled
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CRAFTING_GARBAGE_COLLECTION_CRAFTS] =
                CraftSimOptions
                .craftGarbageCollectCrafts

            -- CRAFT LOG
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CRAFT_LOG_DISABLE] =
                CraftSimOptions
                .craftResultsDisable

            -- CRAFT QUEUE
            CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_PROFIT_MARGIN_THRESHOLD"] =
                CraftSimOptions.craftQueueGeneralRestockProfitMarginThreshold
            CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT"] =
                CraftSimOptions.craftQueueGeneralRestockRestockAmount
            CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_SALE_RATE_THRESHOLD"] =
                CraftSimOptions.craftQueueGeneralRestockSaleRateThreshold
            CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_TARGET_MODE_CRAFTOFFSET"] =
                CraftSimOptions.craftQueueGeneralRestockTargetModeCraftOffset
            CraftSimDB.optionsDB.data["CRAFTQUEUE_RESTOCK_PER_RECIPE_OPTIONS"] =
                CraftSimOptions.craftQueueRestockPerRecipeOptions
            CraftSimDB.optionsDB.data["CRAFTQUEUE_SHOPPING_LIST_TARGET_MODE"] =
                CraftSimOptions.craftQueueShoppingListTargetMode
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.CRAFTQUEUE_FLASH_TASKBAR_ON_CRAFT_FINISHED] =
                CraftSimOptions.craftQueueFlashTaskbarOnCraftFinished

            -- COST OPTIMIZATION
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.COST_OPTIMIZATION_AUTOMATIC_SUB_RECIPE_OPTIMIZATION] =
                CraftSimOptions.costOptimizationAutomaticSubRecipeOptimization
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH] =
                CraftSimOptions.costOptimizationSubRecipeMaxDepth
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWNS] =
                CraftSimOptions.costOptimizationSubRecipesIncludeCooldowns

            -- DEBUG
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.DEBUG_VISIBLE] =
                CraftSimOptions.debugVisible
            CraftSimDB.optionsDB.data[CraftSim.CONST.GENERAL_OPTIONS.DEBUG_AUTO_SCROLL] =
                CraftSimOptions.debugAutoScroll
        end
    end)

    migrate(1, 2, function()
        if _G["CraftSimGGUIConfig"] then
            self:Save("GGUI_CONFIG", _G["CraftSimGGUIConfig"])
        end
        if _G["CraftSimLibIconDB"] then
            self:Save("LIB_ICON_DB", _G["CraftSimLibIconDB"])
        end
    end)

    migrate(2, 3, function()
        CraftSimDB.optionsDB.data["MODULE_CUSTOMER_SERVICE"] = nil
        CraftSimDB.optionsDB.data["CUSTOMER_SERVICE_WHISPER_FORMAT"] = nil
        CraftSimDB.optionsDB.data["CUSTOMER_SERVICE_ALLOW_LIVE_PREVIEW"] = nil
        CraftSimDB.optionsDB.data["CUSTOMER_SERVICE_ACTIVE_PREVIEW_IDS"] = nil
    end)

    migrate(3, 4, function()
        CraftSimDB.optionsDB.data["RECIPESCAN_SORT_MODE"] = "PROFIT"
        CraftSimDB.optionsDB.data["RECIPESCAN_SORT_BY_PROFIT_MARGIN"] = nil
    end)
    migrate(4, 5, function()
        CraftSimDB.optionsDB.data["CRAFTQUEUE_SHOPPING_LIST_TARGET_MODE"] = nil
        CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_TARGET_MODE_CRAFTOFFSET"] = nil
    end)

    migrate(5, 6, function()
        if CraftSimDB.optionsDB.data["PROFIT_CALCULATION_MULTICRAFT_CONSTANT"] == 2.5 then
            CraftSimDB.optionsDB.data["PROFIT_CALCULATION_MULTICRAFT_CONSTANT"] = 2.5
        end
    end)
    migrate(6, 7, function()
        if CraftSimDB.optionsDB.data["PROFIT_CALCULATION_MULTICRAFT_CONSTANT"] == 2.2 then
            CraftSimDB.optionsDB.data["PROFIT_CALCULATION_MULTICRAFT_CONSTANT"] = 2.5
        end
    end)
    migrate(7, 8, function()
        CraftSimDB.optionsDB.data["PROFIT_CALCULATION_MULTICRAFT_CONSTANT"] = nil
    end)
    migrate(8, 9, function()
        CraftSimDB.optionsDB.data["CRAFTQUEUE_SHOPPING_LIST_PER_CHARACTER"] = nil
        CraftSimDB.optionsDB.data["TSM_PRICE_KEY_REAGENTS"] = CraftSimDB.optionsDB.data["TSM_PRICE_KEY_MATERIALS"]
        CraftSimDB.optionsDB.data["MODULE_REAGENT_OPTIMIZATION"] = CraftSimDB.optionsDB.data["MODULE_MATERIALS"]
    end)
    migrate(9, 10, function()
        CraftSimDB.optionsDB.data["RECIPESCAN_IMPORT_ALL_PROFESSIONS"] = nil
        CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_RESTOCK_AMOUNT"] = nil
        CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_PROFIT_MARGIN_THRESHOLD"] = nil
        CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_SALE_RATE_THRESHOLD"] = nil
        CraftSimDB.optionsDB.data["CRAFTQUEUE_GENERAL_RESTOCK_TARGET_MODE_CRAFTOFFSET"] = nil
        CraftSimDB.optionsDB.data["CRAFTQUEUE_RESTOCK_PER_RECIPE_OPTIONS"] = nil
    end)

    migrate(10, 11, function()
        CraftSimDB.optionsDB.data["CRAFTQUEUE_WORK_ORDERS_FORCE_CONCENTRATION"] = CraftSimDB.optionsDB.data
            ["CRAFTQUEUE_PATRON_ORDERS_FORCE_CONCENTRATION"]
        CraftSimDB.optionsDB.data["CRAFTQUEUE_PATRON_ORDERS_FORCE_CONCENTRATION"] = nil

        CraftSimDB.optionsDB.data["CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION"] = CraftSimDB.optionsDB.data
            ["CRAFTQUEUE_PATRON_ORDERS_ALLOW_CONCENTRATION"]
        CraftSimDB.optionsDB.data["CRAFTQUEUE_PATRON_ORDERS_ALLOW_CONCENTRATION"] = nil

        CraftSimDB.optionsDB.data["CRAFTQUEUE_WORK_ORDERS_ALLOW_CONCENTRATION"] = CraftSimDB.optionsDB.data
            ["CRAFTQUEUE_PATRON_ORDERS_ALLOW_CONCENTRATION"]
        CraftSimDB.optionsDB.data["CRAFTQUEUE_PATRON_ORDERS_ALLOW_CONCENTRATION"] = nil
    end)

    migrate(11, 12, function()
        CraftSimDB.optionsDB.data["CRAFTQUEUE_PATRON_ORDERS_EXCLUDE_WARBANK"] = nil
    end)

    migrate(12, 13, function()
        if CraftSimDB.optionsDB.data["RECIPESCAN_SEND_TO_CRAFTQUEUE_TSM_SALERATE_THRESHOLD"] == 1 then
            CraftSimDB.optionsDB.data["RECIPESCAN_SEND_TO_CRAFTQUEUE_TSM_SALERATE_THRESHOLD"] = 0
        end
    end)
    migrate(13, 14, function()
        --- option removal
        CraftSimDB.optionsDB.data["CRAFTQUEUE_WORK_ORDERS_ORDER_TYPE"] = nil
    end)
end

function CraftSim.DB.OPTIONS:CleanUp()
    if _G["CraftSimOptions"] then
        _G["CraftSimOptions"] = nil
    end
    if _G["CraftSimGGUIConfig"] then
        _G["CraftSimGGUIConfig"] = nil
    end
    if _G["CraftSimLibIconDB"] then
        _G["CraftSimLibIconDB"] = nil
    end
end

function CraftSim.DB.OPTIONS:ClearAll()
    wipe(CraftSimDB.optionsDB.data)
end

---@param option CraftSim.GENERAL_OPTIONS
---@return any optionValue
function CraftSim.DB.OPTIONS:Get(option)
    if CraftSimDB.optionsDB.data[option] == nil then
        CraftSimDB.optionsDB.data[option] = CraftSim.CONST.GENERAL_OPTIONS_DEFAULTS[option]
    end
    return CraftSimDB.optionsDB.data[option]
end

---@param option CraftSim.GENERAL_OPTIONS
---@param value any
function CraftSim.DB.OPTIONS:Save(option, value)
    CraftSimDB.optionsDB.data[option] = value
end
