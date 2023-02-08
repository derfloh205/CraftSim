AddonName, CraftSim = ...

CraftSim.CACHE = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.CACHE, recursive, l)
    else
        print(text)
    end
end

-- SavedVars
CraftSimSpecNodeCache = CraftSimSpecNodeCache or {}
CraftSimRecipeIDs = CraftSimRecipeIDs or {}
CraftSimProfessionInfoCache = CraftSimProfessionInfoCache or {}
CraftSimProfessionSkillLineIDCache = CraftSimProfessionSkillLineIDCache or {}

-- session caches
CraftSim.CACHE.SpecDataStatsByRecipeID = {}

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
    CraftSimSpecNodeCache = {}
    CraftSimRecipeIDs = {}
    CraftSimProfessionInfoCache = {}
    CraftSim.CACHE.SpecDataStatsByRecipeID = {}
    CraftSimProfessionSkillLineIDCache = {}
end

function CraftSim.CACHE:GetCacheEntryByVersion(cache, entryID)
    local currentVersion = GetAddOnMetadata(AddonName, "Version")
    print("Cache by version " .. tostring(currentVersion) .. " id: " .. tostring(entryID), false, true)
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

function CraftSim.CACHE:AddCacheEntryByVersion(cache, entryID, data)
    local currentVersion = GetAddOnMetadata(AddonName, "Version")
    -- reset if version changed
    if not next(cache) or cache.version ~= currentVersion then
        print("reset version cache add")
        wipe(cache)
        cache.version = currentVersion
        cache.data = {}
        print("cache now:")
        print(cache, true)
    end

    cache.data[entryID] = data
end