---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.CACHE
CraftSim.CACHE = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE)

---@class CraftSim.ProfessionGearCacheData
---@field cached boolean
---@field equippedGear CraftSim.ProfessionGearSet.Serialized?
---@field availableProfessionGear CraftSim.ProfessionGear.Serialized[]

---@class CraftSim.RecipeDataCache
---@field cachedRecipeIDs table<string, table<number, number[]>> table<crafterGUID, table<profession, recipeID[]>
---@field recipeInfoCache table<string, table<number, TradeSkillRecipeInfo>> table<crafterGUID, table<recipeID, TradeSkillRecipeInfo>
---@field professionInfoCache table<string, table<number, ProfessionInfo>> table<crafterGUID, table<recipeID, TradeSkillRecipeInfo>
---@field operationInfoCache table<string, table<number, CraftingOperationInfo>> table<crafterGUID, table<recipeID, CraftingOperationInfo>>
---@field specializationDataCache table<string, table<number, CraftSim.SpecializationData.Serialized>?> table<crafterGUID, table<recipeID, CraftSim.SpecializationData.Serialized>>
---@field professionGearCache table<string, table<number, CraftSim.ProfessionGearCacheData>> table<crafterGUID, table<profession, CraftSim.ProfessionGearCacheData>>
---@field altClassCache table<string, ClassFile> table<crafterUID, ClassFile>
CraftSimRecipeDataCache = CraftSimRecipeDataCache or {
    cachedRecipeIDs = {},
    recipeInfoCache = {},
    professionInfoCache = {},
    operationInfoCache = {},
    specializationDataCache = {},
    professionGearCache = {},
    altClassCache = {}
}

CraftSim.CACHE.DEFAULT_PROFESSION_GEAR_CACHE_DATA = {
    cached = false,
    equippedGear = nil,
    availableProfessionGear = {},
}

---@type CraftSim.CraftQueueItem.Serialized[]
CraftSimCraftQueueCache = CraftSimCraftQueueCache or {}

function CraftSim.CACHE:HandleCraftSimCacheUpdates()
    -- init default cache fields in case of cache field updates
    if CraftSimRecipeDataCache then
        CraftSimRecipeDataCache.cachedRecipeIDs = CraftSimRecipeDataCache.cachedRecipeIDs or {}
        CraftSimRecipeDataCache.recipeInfoCache = CraftSimRecipeDataCache.recipeInfoCache or {}
        CraftSimRecipeDataCache.professionInfoCache = CraftSimRecipeDataCache.professionInfoCache or {}
        CraftSimRecipeDataCache.operationInfoCache = CraftSimRecipeDataCache.operationInfoCache or {}
        CraftSimRecipeDataCache.specializationDataCache = CraftSimRecipeDataCache.specializationDataCache or {}
        CraftSimRecipeDataCache.professionGearCache = CraftSimRecipeDataCache.professionGearCache or {}
        CraftSimRecipeDataCache.altClassCache = CraftSimRecipeDataCache.altClassCache or {}
    end
end

function CraftSim.CACHE:GetFromCache(cache, entryID)
    return cache[entryID]
end

function CraftSim.CACHE:AddToCache(cache, entryID, data)
    cache[entryID] = data
end

function CraftSim.CACHE:ClearCache(cache)
    cache = {}
end

function CraftSim.CACHE:ClearAll()
end

---@return any?
function CraftSim.CACHE:GetCacheEntryByVersion(cache, entryID)
    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")
    print("get cache entry by addon version " .. tostring(currentVersion) .. " id: " .. tostring(entryID), false, true)
    -- reset if version changed
    if not next(cache) or cache.version ~= currentVersion then
        print("reset version cache get")
        wipe(cache)
        cache.version = currentVersion
        cache.data = {}
        print("cache now:")
        print(cache, true)
    end

    if cache.data[entryID] then
        print("return from cache")
        return cache.data[entryID]
    end
    print("cache entry not found")

    return nil
end

---@return any?
function CraftSim.CACHE:GetCacheEntryByGameVersion(cache, entryID)
    local gameVersion = select(4, GetBuildInfo())
    print("get cache entry by game version " .. tostring(gameVersion) .. " id: " .. tostring(entryID), false, true)
    -- reset if version changed
    if not next(cache) or cache.version ~= gameVersion then
        print("reset version cache get")
        wipe(cache)
        cache.version = gameVersion
        cache.data = {}
    end

    if cache.data[entryID] then
        print("return from cache")
        return cache.data[entryID]
    end
    print("cache entry not found")

    return nil
end

--- By Addon Version
function CraftSim.CACHE:AddCacheEntryByVersion(cache, entryID, data)
    local addonVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")
    -- reset if version changed
    if not next(cache) or cache.version ~= addonVersion then
        print("reset addon version cache add")
        wipe(cache)
        cache.version = addonVersion
        cache.data = {}
    end

    cache.data[entryID] = data
end

--- By Game Version
function CraftSim.CACHE:AddCacheEntryByGameVersion(cache, entryID, data)
    local gameVersion = select(4, GetBuildInfo())
    -- reset if version changed
    if not next(cache) or cache.version ~= gameVersion then
        print("reset game version cache add")
        wipe(cache)
        cache.version = gameVersion
        cache.data = {}
    end

    cache.data[entryID] = data
end

local professionTriggered = {}
--- Since Multicraft seems to be missing on operationInfo on the first call after a fresh login, and seems to be loaded in after the first call,
--- trigger it for all recipes on purpose when the profession is opened the first time in this session
function CraftSim.CACHE:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs, professionID)
    if professionTriggered[professionID] then return end
    if not professionRecipeIDs then
        return
    end
    print("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

    CraftSim.UTIL:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
    for _, recipeID in ipairs(professionRecipeIDs) do
        --if CraftSim.UTIL:IsDragonflightRecipe(recipeID) then
        if recipeID == 367713 then
            print("triggering debug recipe")
        end
        C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {})
        --end
    end

    CraftSim.UTIL:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

    professionTriggered[professionID] = true
end
