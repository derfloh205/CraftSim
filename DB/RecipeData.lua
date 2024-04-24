---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.RECIPE_DATA
CraftSim.DB.RECIPE_DATA = {}

---@class CraftSim.DB.RECIPE_DATA.COOLDOWN_CACHE
CraftSim.DB.RECIPE_DATA.COOLDOWN_CACHE = {}

-- TODO create 1 db for crafterUID -> infos
---@class CraftSim.RecipeDataCache
---@field specializationDataCache table<CrafterUID, table<RecipeID, CraftSim.SpecializationData.Serialized>?>
---@field professionGearCache table<CrafterUID, table<Enum.Profession, CraftSim.DB.CrafterDBData.ProfessionGearData>>
---@field altClassCache table<CrafterUID, ClassFile>
---@field cooldownCache table<CrafterUID, table<CooldownDataSerializationID, CraftSim.CooldownData.Serialized>>
CraftSimRecipeDataCache = CraftSimRecipeDataCache or {
}

CraftSim.DB.RECIPE_DATA.DEFAULT_PROFESSION_GEAR_CACHE_DATA = {
    cached = false,
    equippedGear = nil,
    availableProfessionGear = {},
}

--- Since Multicraft seems to be missing on operationInfo on the first call after a fresh login, and seems to be loaded in after the first call,
--- trigger it for all recipes on purpose when the profession is opened the first time in this session
function CraftSim.DB.RECIPE_DATA:TriggerRecipeOperationInfoLoadForProfession(professionRecipeIDs, professionID)
    if not professionID then return end
    if CraftSim.DB.MULTICRAFT_PRELOAD:Get(professionID) then return end
    if not professionRecipeIDs then
        return
    end
    print("Trigger operationInfo prefetch for: " .. #professionRecipeIDs .. " recipes")

    CraftSim.DEBUG:StartProfiling("FORCE_RECIPE_OPERATION_INFOS")
    for _, recipeID in ipairs(professionRecipeIDs) do
        C_TradeSkillUI.GetCraftingOperationInfo(recipeID, {})
    end

    CraftSim.DEBUG:StopProfiling("FORCE_RECIPE_OPERATION_INFOS")

    CraftSim.DB.MULTICRAFT_PRELOAD:Save(professionID, true)
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
