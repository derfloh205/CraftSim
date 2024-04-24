---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.RECIPE_DATA
CraftSim.DB.RECIPE_DATA = {}

---@class CraftSim.DB.SUB_RECIPE_CRAFTER_CACHE
CraftSim.DB.RECIPE_DATA.SUB_RECIPE_CRAFTER_CACHE = {}

---@class CraftSim.DB.RECIPE_DATA.COOLDOWN_CACHE
CraftSim.DB.RECIPE_DATA.COOLDOWN_CACHE = {}

---@class CraftSim.DB.RECIPE_DATA.EXPECTED_COSTS
CraftSim.DB.RECIPE_DATA.EXPECTED_COSTS = {}

---@class CraftSim.ProfessionGearCacheData
---@field cached boolean
---@field equippedGear CraftSim.ProfessionGearSet.Serialized?
---@field availableProfessionGear CraftSim.ProfessionGear.Serialized[]

---@class CraftSim.ExpectedCraftingCostsData
---@field qualityID QualityID
---@field crafter CrafterUID
---@field expectedCosts number
---@field expectedCostsMin number
---@field craftingChance number
---@field craftingChanceMin number
---@field expectedCrafts number
---@field expectedCraftsMin number
---@field profession Enum.Profession

-- TODO create 1 db for crafterUID -> infos
---@class CraftSim.RecipeDataCache
---@field cachedRecipeIDs table<CrafterUID, table<Enum.Profession, RecipeID[]>>
---@field recipeInfoCache table<CrafterUID, table<RecipeID, TradeSkillRecipeInfo>>
---@field professionInfoCache table<CrafterUID, table<RecipeID, ProfessionInfo>>
---@field operationInfoCache table<CrafterUID, table<RecipeID, CraftingOperationInfo>>
---@field specializationDataCache table<CrafterUID, table<RecipeID, CraftSim.SpecializationData.Serialized>?>
---@field professionGearCache table<CrafterUID, table<Enum.Profession, CraftSim.ProfessionGearCacheData>>
---@field altClassCache table<CrafterUID, ClassFile>
---@field postLoadedMulticraftInformationProfessions table<Enum.Profession, boolean>
---@field cooldownCache table<CrafterUID, table<CooldownDataSerializationID, CraftSim.CooldownData.Serialized>>
---@field itemOptimizedCostsDataCache table<ItemID, table<CrafterUID, CraftSim.ExpectedCraftingCostsData>>
---@field subRecipeCrafterCache table<RecipeID, CrafterUID>
CraftSimRecipeDataCache = CraftSimRecipeDataCache or {
    cachedRecipeIDs = {},
    recipeInfoCache = {},
    professionInfoCache = {},
    operationInfoCache = {},
    specializationDataCache = {},
    professionGearCache = {},
    altClassCache = {},
    postLoadedMulticraftInformationProfessions = {},
    cooldownCache = {},
    subRecipeCrafterCache = {},
    itemOptimizedCostsDataCache = {},
    cacheVersions = {
        cachedRecipeIDs = 1,
        recipeInfoCache = 1,
        professionInfoCache = 1,
        operationInfoCache = 1,
        specializationDataCache = 1,
        professionGearCache = 1,
        altClassCache = 1,
        postLoadedMulticraftInformationProfessions = 1,
        cooldownCache = 1,
        subRecipeCrafterCache = 1,
        itemOptimizedCostsDataCache = 1,
    },
}

CraftSim.DB.RECIPE_DATA.DEFAULT_PROFESSION_GEAR_CACHE_DATA = {
    cached = false,
    equippedGear = nil,
    availableProfessionGear = {},
}

--- TODO: move to init
---@deprecated
function CraftSim.DB.RECIPE_DATA:HandleUpdates()
    if CraftSimRecipeDataCache then
        CraftSimRecipeDataCache.cachedRecipeIDs = CraftSimRecipeDataCache.cachedRecipeIDs or {}
        CraftSimRecipeDataCache.recipeInfoCache = CraftSimRecipeDataCache.recipeInfoCache or {}
        CraftSimRecipeDataCache.professionInfoCache = CraftSimRecipeDataCache.professionInfoCache or {}
        CraftSimRecipeDataCache.operationInfoCache = CraftSimRecipeDataCache.operationInfoCache or {}
        CraftSimRecipeDataCache.specializationDataCache = CraftSimRecipeDataCache.specializationDataCache or {}
        CraftSimRecipeDataCache.professionGearCache = CraftSimRecipeDataCache.professionGearCache or {}
        CraftSimRecipeDataCache.altClassCache = CraftSimRecipeDataCache.altClassCache or {}
        CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions = CraftSimRecipeDataCache
            .postLoadedMulticraftInformationProfessions or {}
        CraftSimRecipeDataCache.cooldownCache = CraftSimRecipeDataCache.cooldownCache or {}
        CraftSimRecipeDataCache.subRecipeCrafterCache = CraftSimRecipeDataCache.subRecipeCrafterCache or {}
        CraftSimRecipeDataCache.itemOptimizedCostsDataCache = CraftSimRecipeDataCache.itemOptimizedCostsDataCache or {}
        CraftSimRecipeDataCache.cacheVersions = CraftSimRecipeDataCache.cacheVersions or {}

        CraftSim.DB.RECIPE_DATA:HandleMigrations()
    end
end

--- Since Multicraft seems to be missing on operationInfo on the first call after a fresh login, and seems to be loaded in after the first call,
--- trigger it for all recipes on purpose when the profession is opened the first time in this session
function CraftSim.DB.RECIPE_DATA:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs, professionID)
    if not professionID then return end
    if CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions[professionID] then return end
    if not professionRecipeIDs then
        return
    end
    print("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

    CraftSim.DEBUG:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
    for _, recipeID in ipairs(professionRecipeIDs) do
        C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {})
    end

    CraftSim.DEBUG:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

    CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions[professionID] = true
end

function CraftSim.DB.RECIPE_DATA:ClearAll()
    wipe(CraftSimRecipeDataCache.cachedRecipeIDs)
    wipe(CraftSimRecipeDataCache.recipeInfoCache)
    wipe(CraftSimRecipeDataCache.professionInfoCache)
    wipe(CraftSimRecipeDataCache.specializationDataCache)
    wipe(CraftSimRecipeDataCache.professionGearCache)
    wipe(CraftSimRecipeDataCache.altClassCache)
    wipe(CraftSimRecipeDataCache.postLoadedMulticraftInformationProfessions)
end

function CraftSim.DB.RECIPE_DATA:HandleMigrations()
    -- cooldownCache 0 -> 1
    if not CraftSimRecipeDataCache.cacheVersions.cooldownCache then
        CraftSim.DB.RECIPE_DATA:MigrateCooldownCache_0_1()
        CraftSimRecipeDataCache.cacheVersions.cooldownCache = 1
    end

    -- itemOptimizedCostsDataCache 0 -> 1
    if not CraftSimRecipeDataCache.cacheVersions.itemOptimizedCostsDataCache then
        wipe(CraftSimRecipeDataCache.itemOptimizedCostsDataCache)
        CraftSimRecipeDataCache.cacheVersions.itemOptimizedCostsDataCache = 1
    end

    -- subRecipeCrafterCache 0 -> 1
    if not CraftSimRecipeDataCache.cacheVersions.subRecipeCrafterCache then
        CraftSimRecipeDataCache.cacheVersions.subRecipeCrafterCache = 1
    end
end

function CraftSim.DB.RECIPE_DATA:MigrateCooldownCache_0_1()
    local newCache = {}

    for crafterUID, cooldownDataByRecipeID in pairs(CraftSimRecipeDataCache.cooldownCache) do
        newCache[crafterUID] = newCache[crafterUID] or {}

        for recipeID, serializedCooldownData in pairs(cooldownDataByRecipeID) do
            local sharedCD = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID]
            local serializationID = sharedCD or recipeID
            if not newCache[crafterUID][serializationID] then
                serializedCooldownData.sharedCD = sharedCD
                newCache[crafterUID][serializationID] = serializedCooldownData
            end
        end
    end

    CraftSimRecipeDataCache.cooldownCache = newCache
end

---@param recipeID RecipeID
---@return CrafterUID crafterUID?
function CraftSim.DB.RECIPE_DATA.SUB_RECIPE_CRAFTER_CACHE:GetCrafter(recipeID)
    return CraftSimRecipeDataCache.subRecipeCrafterCache[recipeID]
end

---@param recipeID RecipeID
---@param crafterUID CrafterUID
---@return boolean
function CraftSim.DB.RECIPE_DATA.SUB_RECIPE_CRAFTER_CACHE:IsCrafter(recipeID, crafterUID)
    return crafterUID == CraftSimRecipeDataCache.subRecipeCrafterCache[recipeID]
end

---@param recipeID RecipeID
---@param crafterUID CrafterUID
function CraftSim.DB.RECIPE_DATA.SUB_RECIPE_CRAFTER_CACHE:SetCrafter(recipeID, crafterUID)
    CraftSimRecipeDataCache.subRecipeCrafterCache[recipeID] = crafterUID
end

---@param recipeID RecipeID
---@param crafterUID? CrafterUID
function CraftSim.DB.RECIPE_DATA.COOLDOWN_CACHE:IsCooldownRecipe(recipeID, crafterUID)
    -- if crafterUID was given get directly otherwise check for any crafter
    if crafterUID then
        local serializationID = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID] or
            recipeID
        CraftSimRecipeDataCache.cooldownCache[crafterUID] = CraftSimRecipeDataCache.cooldownCache[crafterUID] or {}
        ---@type CraftSim.CooldownData.Serialized?
        local cooldownDataSerialized = CraftSimRecipeDataCache.cooldownCache[crafterUID][serializationID]
        return cooldownDataSerialized ~= nil
    else
        for crafterUID, _ in pairs(CraftSimRecipeDataCache.cooldownCache) do
            if self:IsCooldownRecipe(recipeID, crafterUID) then
                return true
            end
        end

        return false
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.DB.RECIPE_DATA.EXPECTED_COSTS:Save(recipeData)
    -- cache the results if not gear and if its learned only
    if not recipeData.isGear and recipeData.learned then
        --print("Caching Optimized Costs Data for: " .. self.recipeName)

        -- only if reachable
        for qualityID, item in ipairs(recipeData.resultData.itemsByQuality) do
            local chance = recipeData.resultData.chanceByQuality[qualityID] or 0
            local minChance = recipeData.resultData.chancebyMinimumQuality[qualityID] or 0
            if minChance > 0 then
                print("Caching Optimized Costs Data for: " .. recipeData.recipeName)
                local itemID = item:GetItemID()
                CraftSimRecipeDataCache.itemOptimizedCostsDataCache[itemID] = CraftSimRecipeDataCache
                    .itemOptimizedCostsDataCache[itemID] or {}

                CraftSimRecipeDataCache.itemOptimizedCostsDataCache[itemID][recipeData:GetCrafterUID()] = {
                    crafter = recipeData:GetCrafterUID(),
                    qualityID = qualityID,
                    craftingChance = chance,
                    craftingChanceMin = minChance,
                    expectedCosts = recipeData.priceData.expectedCostsByQuality[qualityID],
                    expectedCostsMin = recipeData.priceData.expectedCostsByMinimumQuality[qualityID],
                    expectedCrafts = recipeData.resultData.expectedCraftsByQuality[qualityID],
                    expectedCraftsMin = recipeData.resultData.expectedCraftsByMinimumQuality[qualityID],
                    profession = recipeData.professionData.professionInfo.profession,
                }
            end
        end
    end
end

---@param itemID ItemID
---@param crafterUID CrafterUID
---@return CraftSim.ExpectedCraftingCostsData?
function CraftSim.DB.RECIPE_DATA.EXPECTED_COSTS:Get(itemID, crafterUID)
    CraftSimRecipeDataCache.itemOptimizedCostsDataCache[itemID] = CraftSimRecipeDataCache
        .itemOptimizedCostsDataCache[itemID] or {}

    return CraftSimRecipeDataCache.itemOptimizedCostsDataCache[itemID][crafterUID]
end
