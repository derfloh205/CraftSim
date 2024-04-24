---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.CRAFTER : CraftSim.DB.Repository
CraftSim.DB.CRAFTER = CraftSim.DB:RegisterRepository()

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DB)

---@class CraftSim.DB.CrafterDBData.ProfessionGearData
---@field cached boolean
---@field equippedGear CraftSim.ProfessionGearSet.Serialized?
---@field availableProfessionGear CraftSim.ProfessionGear.Serialized[]

---@class CraftSim.DB.CrafterDBData
---@field cachedRecipeIDs table<Enum.Profession, RecipeID[]>
---@field recipeInfos table<RecipeID, TradeSkillRecipeInfo>
---@field professionInfos table<RecipeID, ProfessionInfo>
---@field operationInfos table<RecipeID, CraftingOperationInfo>
---@field specializationData table<RecipeID, CraftSim.SpecializationData.Serialized>
---@field professionGear table<Enum.Profession, CraftSim.DB.CrafterDBData.ProfessionGearData>
---@field class ClassFile
---@field cooldownData table<CooldownDataSerializationID, CraftSim.CooldownData.Serialized>

function CraftSim.DB.CRAFTER:Init()
    if not CraftSimDB.crafterDB then
        CraftSimDB.crafterDB = {
            version = 0,
            ---@type table<CrafterUID, CraftSim.DB.CrafterDBData>
            data = {},
        }
    end
end

function CraftSim.DB.CRAFTER:Migrate()
    -- 0 -> 1
    if CraftSimDB.crafterDB.version == 0 then
        local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
        if CraftSimRecipeDataCache then
            for crafterUID, cachedProfessionRecipes in pairs(CraftSimRecipeDataCache["cachedRecipeIDs"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs = cachedProfessionRecipes
            end

            for crafterUID, recipeInfos in pairs(CraftSimRecipeDataCache["recipeInfoCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].recipeInfos = recipeInfos
            end

            for crafterUID, professionInfos in pairs(CraftSimRecipeDataCache["professionInfoCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].professionInfos = professionInfos
            end

            for crafterUID, operationInfos in pairs(CraftSimRecipeDataCache["operationInfoCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].operationInfos = operationInfos
            end

            for crafterUID, specializationData in pairs(CraftSimRecipeDataCache["specializationDataCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].specializationData = specializationData
            end

            for crafterUID, professionGear in pairs(CraftSimRecipeDataCache["professionGearCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].professionGear = professionGear
            end

            for crafterUID, class in pairs(CraftSimRecipeDataCache["altClassCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].class = class
            end

            for crafterUID, cooldownData in pairs(CraftSimRecipeDataCache["cooldownCache"] or {}) do
                CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
                CraftSimDB.crafterDB.data[crafterUID].cooldownData = cooldownData
            end
        end
        CraftSimDB.crafterDB.version = 1
    end
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@param recipeID RecipeID
function CraftSim.DB.CRAFTER:AddCachedRecipeID(crafterUID, profession, recipeID)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs = CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs or {}

    if not tContains(CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs[profession], recipeID) then
        tinsert(CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs[profession], recipeID)
    end
end

---@return CrafterUID[]
function CraftSim.DB.CRAFTER:GetCrafterUIDs()
    return GUTIL:Map(CraftSimDB.crafterDB.data, function(_, crafterUID)
        return crafterUID
    end)
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return RecipeID[] cachedRecipeIDs?
function CraftSim.DB.CRAFTER:GetCachedRecipeIDs(crafterUID, profession)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs = CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs or {}
    return CraftSimDB.crafterDB.data[crafterUID].cachedRecipeIDs[profession]
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return TradeSkillRecipeInfo?
function CraftSim.DB.CRAFTER:GetRecipeInfo(crafterUID, recipeID)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].recipeInfos = CraftSimDB.crafterDB.data[crafterUID].recipeInfos or {}
    return CraftSimDB.crafterDB.data[crafterUID].recipeInfos[recipeID]
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@param recipeInfo TradeSkillRecipeInfo
function CraftSim.DB.CRAFTER:SaveRecipeInfo(crafterUID, recipeID, recipeInfo)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].recipeInfos = CraftSimDB.crafterDB.data[crafterUID].recipeInfos or {}
    CraftSimDB.crafterDB.data[crafterUID].recipeInfos[recipeID] = recipeInfo
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return ProfessionInfo?
function CraftSim.DB.CRAFTER:GetProfessionInfoForRecipe(crafterUID, recipeID)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].professionInfos = CraftSimDB.crafterDB.data[crafterUID].professionInfos or {}
    return CraftSimDB.crafterDB.data[crafterUID].professionInfos[recipeID]
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@param professionInfo ProfessionInfo
function CraftSim.DB.CRAFTER:SaveProfessionInfoForRecipe(crafterUID, recipeID, professionInfo)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].professionInfos = CraftSimDB.crafterDB.data[crafterUID].professionInfos or {}
    CraftSimDB.crafterDB.data[crafterUID].professionInfos[recipeID] = professionInfo
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return CraftingOperationInfo?
function CraftSim.DB.CRAFTER:GetOperationInfoForRecipe(crafterUID, recipeID)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].operationInfos = CraftSimDB.crafterDB.data[crafterUID].operationInfos or {}
    return CraftSimDB.crafterDB.data[crafterUID].operationInfos[recipeID]
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@param operationInfo CraftingOperationInfo
function CraftSim.DB.CRAFTER:SaveOperationInfoForRecipe(crafterUID, recipeID, operationInfo)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].operationInfos = CraftSimDB.crafterDB.data[crafterUID].operationInfos or {}
    CraftSimDB.crafterDB.data[crafterUID].operationInfos[recipeID] = operationInfo
end

--- returns the data serialized
---@param crafterUID CrafterUID
---@param recipeData CraftSim.RecipeData
---@return CraftSim.SpecializationData?
function CraftSim.DB.CRAFTER:GetSpecializationData(crafterUID, recipeData)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].specializationData = CraftSimDB.crafterDB.data[crafterUID].specializationData or
        {}
    local specializationDataSerialized = CraftSimDB.crafterDB.data[crafterUID].specializationData[recipeData.recipeID]

    if specializationDataSerialized then
        return CraftSim.SpecializationData:Deserialize(specializationDataSerialized, recipeData)
    end

    return nil
end

---@param crafterUID CrafterUID
---@param specializationData CraftSim.SpecializationData
function CraftSim.DB.CRAFTER:SaveSpecializationData(crafterUID, specializationData)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].specializationData = CraftSimDB.crafterDB.data[crafterUID].specializationData or
        {}
    CraftSimDB.crafterDB.data[crafterUID].specializationData[specializationData.recipeData.recipeID] = specializationData
        :Serialize()
end

--- returns the data serialized
---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return CraftSim.DB.CrafterDBData.ProfessionGearData professionGearData
function CraftSim.DB.CRAFTER:GetProfessionGearData(crafterUID, profession)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].professionGear = CraftSimDB.crafterDB.data[crafterUID].professionGear or {}
    CraftSimDB.crafterDB.data[crafterUID].professionGear[profession] = CraftSimDB.crafterDB.data[crafterUID]
        .professionGear[profession] or
        {
            cached = false,
            equippedGear = nil,
            availableProfessionGear = {},
        }
    return CraftSimDB.crafterDB.data[crafterUID].professionGear[profession]
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@param professionGearSet CraftSim.ProfessionGearSet
function CraftSim.DB.CRAFTER:SaveProfessionGearEquipped(crafterUID, profession, professionGearSet)
    local professionGearData = self:GetProfessionGearData(crafterUID, profession)
    professionGearData.equippedGear = professionGearSet:Serialize()
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@param professionGear CraftSim.ProfessionGear
function CraftSim.DB.CRAFTER:SaveProfessionGearAvailable(crafterUID, profession, professionGear)
    local professionGearData = self:GetProfessionGearData(crafterUID, profession)

    local alreadyListed = GUTIL:Find(professionGearData.availableProfessionGear, function(g)
        return g.itemLink ==
            professionGear.item:GetItemLink()
    end)
    if not alreadyListed then
        table.insert(professionGearData.availableProfessionGear, professionGear:Serialize())
    end
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return CraftSim.ProfessionGear[] professionGear
function CraftSim.DB.CRAFTER:GetProfessionGearAvailable(crafterUID, profession)
    local professionGearData = self:GetProfessionGearData(crafterUID, profession)

    return GUTIL:Map(professionGearData.availableProfessionGear, function(professionGearSerialized)
        return CraftSim.ProfessionGear:Deserialize(professionGearSerialized)
    end)
end

--- returns data serialized
---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return CraftSim.ProfessionGearSet.Serialized?
function CraftSim.DB.CRAFTER:GetProfessionGearEquipped(crafterUID, profession)
    local professionGearData = self:GetProfessionGearData(crafterUID, profession)
    return professionGearData.equippedGear
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
function CraftSim.DB.CRAFTER:FlagProfessionGearCached(crafterUID, profession)
    local professionGearData = self:GetProfessionGearData(crafterUID, profession)
    professionGearData.cached = true
end

---@param crafterUID CrafterUID
---@param profession Enum.Profession
---@return boolean cached
function CraftSim.DB.CRAFTER:GetProfessionGearCached(crafterUID, profession)
    local professionGearData = self:GetProfessionGearData(crafterUID, profession)
    return professionGearData.cached
end

---@param crafterUID CrafterUID
---@return ClassFile?
function CraftSim.DB.CRAFTER:GetClass(crafterUID)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    return CraftSimDB.crafterDB.data[crafterUID].class
end

---@param class ClassFile
function CraftSim.DB.CRAFTER:SaveClass(crafterUID, class)
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].class = class
end

--- returns data serialized
---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return CraftSim.CooldownData.Serialized?
function CraftSim.DB.CRAFTER:GetRecipeCooldownData(crafterUID, recipeID)
    local serializationID = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID] or
        recipeID
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].cooldownData = CraftSimDB.crafterDB.data[crafterUID].cooldownData or {}
    return CraftSimDB.crafterDB.data[crafterUID].cooldownData[serializationID]
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@param cooldownData CraftSim.CooldownData
function CraftSim.DB.CRAFTER:SaveRecipeCooldownData(crafterUID, recipeID, cooldownData)
    local serializationID = CraftSim.CONST.SHARED_PROFESSION_COOLDOWNS_RECIPE_ID_MAP[recipeID] or
        recipeID
    CraftSimDB.crafterDB.data[crafterUID] = CraftSimDB.crafterDB.data[crafterUID] or {}
    CraftSimDB.crafterDB.data[crafterUID].cooldownData = CraftSimDB.crafterDB.data[crafterUID].cooldownData or {}
    CraftSimDB.crafterDB.data[crafterUID].cooldownData[serializationID] = cooldownData:Serialize()
end

---@param crafterUID CrafterUID
---@param recipeID RecipeID
---@return boolean IsCooldownRecipe
function CraftSim.DB.CRAFTER:IsRecipeCooldownRecipe(crafterUID, recipeID)
    return self:GetRecipeCooldownData(crafterUID, recipeID) ~= nil
end

---@return table<CrafterUID, CraftSim.CooldownData.Serialized[]> crafterCooldownData
function CraftSim.DB.CRAFTER:GetCrafterCooldownData()
    local crafterCooldownData = {}

    for crafterUID, crafterDBData in pairs(CraftSimDB.crafterDB.data) do
        crafterCooldownData[crafterUID] = crafterDBData.cooldownData
    end

    return crafterCooldownData
end

---@return table<CrafterUID, CraftSim.DB.CrafterDBData>
function CraftSim.DB.CRAFTER:GetAll()
    return CraftSimDB.crafterDB.data
end

function CraftSim.DB.CRAFTER:ClearAll()
    wipe(CraftSimDB.crafterDB.data)
end

function CraftSim.DB.CRAFTER:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache then
        CraftSimRecipeDataCache["cachedRecipeIDs"] = nil
        CraftSimRecipeDataCache["recipeInfoCache"] = nil
        CraftSimRecipeDataCache["professionInfoCache"] = nil
        CraftSimRecipeDataCache["operationInfoCache"] = nil
        CraftSimRecipeDataCache["specializationDataCache"] = nil
        CraftSimRecipeDataCache["professionGearCache"] = nil
        CraftSimRecipeDataCache["altClassCache"] = nil
        CraftSimRecipeDataCache["cooldownCache"] = nil
    end
end
