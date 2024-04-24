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
---@field cooldowns table<CooldownDataSerializationID, CraftSim.CooldownData.Serialized>

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

---@return table<CrafterUID, CraftSim.DB.CrafterDBData>
function CraftSim.DB.CRAFTER:GetAll()
    return CraftSimDB.crafterDB.data
end

function CraftSim.DB.CRAFTER:ClearAll()
    wipe(CraftSimDB.crafterDB.data)
end

function CraftSim.DB.CRAFTER:CleanUp()
    local CraftSimRecipeDataCache = _G["CraftSimRecipeDataCache"]
    if CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] then
        CraftSimRecipeDataCache["postLoadedMulticraftInformationProfessions"] = nil
    end
end
