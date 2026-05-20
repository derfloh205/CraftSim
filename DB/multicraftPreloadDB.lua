---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.MULTICRAFT_PRELOAD : CraftSim.DB.Repository
CraftSim.DB.MULTICRAFT_PRELOAD = CraftSim.DB:RegisterRepository("MulticraftPreloadDB")

local L = CraftSim.LOCAL:GetLocalizer()
local Logger = CraftSim.DEBUG:RegisterLogger("multicraftPreloadDB")

local PRELOAD_OPERATIONS_PER_FRAME = 100
local PRELOAD_EARLY_BREAK_PERCENT_LIMIT = 20
local MULTICRAFT_LOCALIZED_NAME = string.lower(L("STAT_MULTICRAFT"))

function CraftSim.DB.MULTICRAFT_PRELOAD:Init()
    if not CraftSimDB.multicraftPreloadDB then
        ---@type CraftSimDB.Database
        CraftSimDB.multicraftPreloadDB = {
            version = 0,
            ---@type table<Enum.Profession, boolean>
            data = {},
        }
    end

    self.db = CraftSimDB.multicraftPreloadDB

    CraftSimDB.multicraftPreloadDB.data = CraftSimDB.multicraftPreloadDB.data or {}
end

function CraftSim.DB.MULTICRAFT_PRELOAD:ClearAll()
    wipe(CraftSimDB.multicraftPreloadDB.data)
end

---@param profession Enum.Profession
---@param preloaded boolean
function CraftSim.DB.MULTICRAFT_PRELOAD:Save(profession, preloaded)
    if not profession then
        return
    end
    CraftSimDB.multicraftPreloadDB.data = CraftSimDB.multicraftPreloadDB.data or {}
    CraftSimDB.multicraftPreloadDB.data[profession] = preloaded
end

---@param profession Enum.Profession
---@return boolean preloaded
function CraftSim.DB.MULTICRAFT_PRELOAD:Get(profession)
    if not profession then
        return false
    end
    CraftSimDB.multicraftPreloadDB.data = CraftSimDB.multicraftPreloadDB.data or {}
    return CraftSimDB.multicraftPreloadDB.data[profession] == true -- to convert to boolean
end

function CraftSim.DB.MULTICRAFT_PRELOAD:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache and CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] then
        CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] = nil
    end
end

---@param professions Enum.Profession[]
function CraftSim.DB.MULTICRAFT_PRELOAD:InitializeRecipes(professions)
    local prof1, prof2 = unpack(professions)
    local mcData = CraftSim.MULTICRAFT_SUPPORT_DATA
    if not mcData[prof1] and not mcData[prof2] then return end

    local preloaded1 = self:Get(prof1)
    local preloaded2 = self:Get(prof2)

    if preloaded1 and preloaded2 then
        Logger:LogInfo("Multicraft information already preloaded for professions: {prof1}, {prof2}", prof1, prof2)
        return
    end

    local recipes1 = {}
    local recipes2 = {}

    if not preloaded1 and mcData[prof1] then
        recipes1 = GUTIL:Concat({ recipes1, mcData[prof1] })
    end

    if not preloaded2 and mcData[prof2] then
        recipes2 = GUTIL:Concat({ recipes2, mcData[prof2] })
    end

    Logger:LogInfo("Preloading multicraft information for professions: {prof1}: {recipes1}, {prof2}: {recipes2}", prof1,
        #recipes1, prof2, #recipes2)

    CraftSim.DEBUG:StartProfiling("MulticraftPreloadDB:InitializeRecipes")

    local preloadedCount = 0 -- for early break metric
    local total = #recipes1

    local continueFunc =
    ---@param frameDistributor GUTIL.FrameDistributor
    ---@param key any
    ---@param value any
    ---@param currentIteration number
    ---@param progress number
        function(frameDistributor, key, value, currentIteration, progress)
            local recipeID = value
            local operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {}, nil, false)

            if operationInfo and operationInfo.bonusStats then
                local preloaded = GUTIL:Find(operationInfo.bonusStats, function(stat)
                    return string.lower(stat.bonusStatName) == MULTICRAFT_LOCALIZED_NAME
                end)

                if preloaded then
                    Logger:LogDebug("Recipe already has mc: {recipeID}, progress: {currentIteration}/{total}",
                        recipeID, currentIteration, total)
                    preloadedCount = preloadedCount + 1
                end
            end
            if preloadedCount / total >= PRELOAD_EARLY_BREAK_PERCENT_LIMIT / 100 then
                Logger:LogDebug(
                    "Early break due to already preloaded recipes: {preloadedCount}/{total}",
                    preloadedCount, total)
                frameDistributor:Break()
                return
            end

            frameDistributor:Continue()
        end

    GUTIL.FrameDistributor {
        iterationTable = recipes1,
        iterationsPerFrame = PRELOAD_OPERATIONS_PER_FRAME,
        continue = continueFunc,
        finally = function()
            self:Save(prof1, true)
            preloadedCount = 0
            total = #recipes2
            GUTIL.FrameDistributor {
                iterationTable = recipes2,
                iterationsPerFrame = PRELOAD_OPERATIONS_PER_FRAME,
                continue = continueFunc,
                finally = function()
                    self:Save(prof2, true)
                    CraftSim.DEBUG:StopProfiling("MulticraftPreloadDB:InitializeRecipes")
                    Logger:LogInfo("Finished preloading multicraft information for professions")
                end,
            }:Continue()
        end
    }:Continue()
end

--- Migrations
function CraftSim.DB.MULTICRAFT_PRELOAD.MIGRATION:M_0_1_Import_from_CraftSimRecipeDataCache()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache then
        CraftSimDB.multicraftPreloadDB.data = CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] or
            {}
    end
end
