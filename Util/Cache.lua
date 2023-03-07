AddonName, CraftSim = ...

CraftSim.CACHE = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.CACHE, recursive, l)
    else
        print(text)
    end
end

-- SavedVars
CraftSimRecipeIDs = CraftSimRecipeIDs or {}
CraftSimProfessionInfoCache = CraftSimProfessionInfoCache or {}
CraftSimProfessionSkillLineIDCache = CraftSimProfessionSkillLineIDCache or {}

---@class CraftSim.RecipeMap
---@field itemToRecipe? number[]
---@field recipeToProfession? number[]

---@type CraftSim.RecipeMap
CraftSimRecipeMap = CraftSimRecipeMap or {}

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
    CraftSimRecipeIDs = {}
    CraftSimProfessionInfoCache = {}
    CraftSim.CACHE.SpecDataStatsByRecipeID = {}
    CraftSimProfessionSkillLineIDCache = {}
end

---@return any?
function CraftSim.CACHE:GetCacheEntryByVersion(cache, entryID)
    local currentVersion = GetAddOnMetadata(AddonName, "Version")
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
    local addonVersion = GetAddOnMetadata(AddonName, "Version")
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

---@param professionInfo ProfessionInfo
---@param recipeID number
function CraftSim.CACHE:BuildRecipeMap(professionInfo, recipeID)
    local professionID = professionInfo.profession
    if professionInfo and professionID then
        
        --- only need to check one of the lists
        local recipeToProfession = CraftSim.CACHE:GetCacheEntryByGameVersion(CraftSimRecipeMap, "recipeToProfession")
        if not recipeToProfession or not recipeToProfession[recipeID] then
            -- build maps for profession
            print("Build RecipeMap")
            CraftSim.UTIL:StartProfiling("RECIPE_MAPPING")
            local recipeMapForItems = {}
            local recipeMapForProfession = {}
            local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
            table.foreach(recipeIDs, function (_, recipeID)
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                recipeMapForProfession[recipeID] = professionID

                if recipeInfo and not recipeInfo.isEnchantingRecipe and not recipeInfo.isGatheringRecipe and not tContains(CraftSim.CONST.QUEST_PLAN_CATEGORY_IDS, recipeInfo.categoryID) then
                    local itemIDs = CraftSim.DATAEXPORT:GetDifferentQualityIDsByCraftingReagentTbl(recipeID, {})
                    itemIDs = CraftSim.GUTIL:ToSet(itemIDs) -- to consider gear where all qualities have the same itemID

                    table.foreach(itemIDs, function (_, itemID)
                        recipeMapForItems[itemID] = recipeID
                    end)
                end
            end)
            CraftSim.CACHE:AddCacheEntryByGameVersion(CraftSimRecipeMap, "itemToRecipe", recipeMapForItems)
            CraftSim.CACHE:AddCacheEntryByGameVersion(CraftSimRecipeMap, "recipeToProfession", recipeMapForProfession)
            CraftSim.UTIL:StopProfiling("RECIPE_MAPPING")
        else
            print("RecipeMap already cached")
        end
    end
end