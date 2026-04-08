---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.CraftList.Options
---@field enableConcentration boolean
---@field optimizeConcentration boolean
---@field smartConcentrationQueuing boolean
---@field offsetConcentrationCraftAmount boolean
---@field optimizeProfessionTools boolean
---@field autoselectTopProfitQuality boolean
---@field optimizeFinishingReagents boolean
---@field includeSoulboundFinishingReagents boolean
---@field onlyHighestQualitySoulboundFinishingReagents boolean
---@field finishingReagentsAlgorithm string one of CraftSim.WIDGETS.OptimizationOptions.FINISHING_REAGENTS_ALGORITHM
---@field fixedCrafterUID CrafterUID?
---@field restockAmount number
---@field offsetQueueAmount number
---@field reagentAllocation string reagent quality allocation mode: Q1, Q2, Q3, OPTIMIZE_HIGHEST, OPTIMIZE_MOST_PROFITABLE, or OPTIMIZE_TARGET_1..5
---@field enableUnlearned boolean if false, skip recipes the crafter has not learned
---@field useTSMRestockExpression boolean if true, use per-list TSM restock expression to determine restock amount
---@field tsmRestockExpression string TSM expression for restock quantity (per-list)
---@field restockModeEnabled boolean legacy; no longer used — per-recipe restock uses restockMaxAmount > 0

---@class CraftSim.CraftList
---@field id number unique incrementing ID
---@field name string
---@field isGlobal boolean
---@field recipeEntries CraftSim.CraftListRecipeEntry[]?
---@field recipeIDs RecipeID[]
---@field options CraftSim.CraftList.Options

---@class CraftSim.CraftListRecipeEntry
---@field recipeID RecipeID
---@field restockMaxAmount number target stock when > 0 (restock); 0 = use normal queue amount (TSM / 1 + offset)

---@class CraftSim.DB.CRAFT_LISTS : CraftSim.DB.Repository
CraftSim.DB.CRAFT_LISTS = CraftSim.DB:RegisterRepository("CraftListsDB")

local print = CraftSim.DEBUG:RegisterDebugID("Database.craftListsDB")

---@return CraftSim.CraftList.Options
local function DefaultOptions()
    return {
        enableConcentration = true,
        optimizeConcentration = true,
        smartConcentrationQueuing = false,
        offsetConcentrationCraftAmount = false,
        optimizeProfessionTools = true,
        autoselectTopProfitQuality = true,
        optimizeFinishingReagents = false,
        includeSoulboundFinishingReagents = false,
        onlyHighestQualitySoulboundFinishingReagents = false,
        finishingReagentsAlgorithm = "SIMPLE",
        fixedCrafterUID = nil,
        restockAmount = 1,
        offsetQueueAmount = 0,
        reagentAllocation = "OPTIMIZE_HIGHEST",
        enableUnlearned = false,
        useTSMRestockExpression = false,
        tsmRestockExpression = "1",
        restockModeEnabled = false,
    }
end

CraftSim.DB.CRAFT_LISTS.DefaultOptions = DefaultOptions

---@param recipeID RecipeID
---@return CraftSim.CraftListRecipeEntry
local function CreateDefaultRecipeEntry(recipeID)
    return {
        recipeID = recipeID,
        restockMaxAmount = 0,
    }
end

---@param list CraftSim.CraftList
local function NormalizeListRecipes(list)
    if not list then return end

    list.recipeEntries = list.recipeEntries or {}
    list.recipeIDs = list.recipeIDs or {}
    list.options = list.options or DefaultOptions()

    if #list.recipeEntries == 0 and #list.recipeIDs > 0 then
        for _, recipeID in ipairs(list.recipeIDs) do
            if not GUTIL:Find(list.recipeEntries, function(entry) return entry.recipeID == recipeID end) then
                tinsert(list.recipeEntries, CreateDefaultRecipeEntry(recipeID))
            end
        end
    end

    local normalizedRecipeIDs = {}
    for _, entry in ipairs(list.recipeEntries) do
        entry.restockMaxAmount = math.max(0, tonumber(entry.restockMaxAmount) or 0)
        if not tContains(normalizedRecipeIDs, entry.recipeID) then
            tinsert(normalizedRecipeIDs, entry.recipeID)
        end
    end
    list.recipeIDs = normalizedRecipeIDs
end

function CraftSim.DB.CRAFT_LISTS:Init()
    if not CraftSimDB.craftListsDB then
        ---@class CraftSimDB.CraftListsDB : CraftSimDB.Database
        CraftSimDB.craftListsDB = {
            version = 0,
            nextListID = 1,
            ---@type table<number, CraftSim.CraftList>
            globalLists = {},
            ---@type table<CrafterUID, table<number, CraftSim.CraftList>>
            characterLists = {},
            ---@type table<CrafterUID, table<number, boolean>>
            selectedForQueue = {},
        }
    end
    self.db = CraftSimDB.craftListsDB
    CraftSimDB.craftListsDB.version = CraftSimDB.craftListsDB.version or 0
    CraftSimDB.craftListsDB.nextListID = CraftSimDB.craftListsDB.nextListID or 1
    CraftSimDB.craftListsDB.globalLists = CraftSimDB.craftListsDB.globalLists or {}
    CraftSimDB.craftListsDB.characterLists = CraftSimDB.craftListsDB.characterLists or {}
    CraftSimDB.craftListsDB.selectedForQueue = CraftSimDB.craftListsDB.selectedForQueue or {}
end

---@return number newID
local function NextID()
    local id = CraftSimDB.craftListsDB.nextListID
    CraftSimDB.craftListsDB.nextListID = id + 1
    return id
end

---@param crafterUID CrafterUID
---@param listID number
---@return boolean
function CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, listID)
    CraftSimDB.craftListsDB.selectedForQueue[crafterUID] = CraftSimDB.craftListsDB.selectedForQueue[crafterUID] or {}
    return CraftSimDB.craftListsDB.selectedForQueue[crafterUID][listID] == true
end

---@param crafterUID CrafterUID
---@param listID number
---@param selected boolean
function CraftSim.DB.CRAFT_LISTS:SetSelectedForQueue(crafterUID, listID, selected)
    CraftSimDB.craftListsDB.selectedForQueue[crafterUID] = CraftSimDB.craftListsDB.selectedForQueue[crafterUID] or {}
    CraftSimDB.craftListsDB.selectedForQueue[crafterUID][listID] = selected or nil
end

---@param crafterUID? CrafterUID
---@return CraftSim.CraftList[]
function CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)
    local lists = {}
    for _, list in pairs(CraftSimDB.craftListsDB.globalLists) do
        NormalizeListRecipes(list)
        tinsert(lists, list)
    end
    if crafterUID then
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        for _, list in pairs(CraftSimDB.craftListsDB.characterLists[crafterUID]) do
            NormalizeListRecipes(list)
            tinsert(lists, list)
        end
    end
    return lists
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return CraftSim.CraftList new list
function CraftSim.DB.CRAFT_LISTS:CreateList(name, isGlobal, crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    local id = NextID()

    ---@type CraftSim.CraftList
    local newList = {
        id = id,
        name = name,
        isGlobal = isGlobal,
        recipeEntries = {},
        recipeIDs = {},
        options = DefaultOptions(),
    }

    if isGlobal then
        CraftSimDB.craftListsDB.globalLists[id] = newList
    else
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        CraftSimDB.craftListsDB.characterLists[crafterUID][id] = newList
    end

    return newList
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
function CraftSim.DB.CRAFT_LISTS:DeleteList(id, isGlobal, crafterUID)
    if isGlobal then
        CraftSimDB.craftListsDB.globalLists[id] = nil
        for _, selected in pairs(CraftSimDB.craftListsDB.selectedForQueue) do
            selected[id] = nil
        end
    else
        crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
        if CraftSimDB.craftListsDB.characterLists[crafterUID] then
            CraftSimDB.craftListsDB.characterLists[crafterUID][id] = nil
        end
        if CraftSimDB.craftListsDB.selectedForQueue[crafterUID] then
            CraftSimDB.craftListsDB.selectedForQueue[crafterUID][id] = nil
        end
    end
end

---@param id number
---@param newName string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
function CraftSim.DB.CRAFT_LISTS:RenameList(id, newName, isGlobal, crafterUID)
    local list = self:GetList(id, isGlobal, crafterUID)
    if list then
        list.name = newName
    end
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return CraftSim.CraftList?
function CraftSim.DB.CRAFT_LISTS:GetList(id, isGlobal, crafterUID)
    local list
    if isGlobal then
        list = CraftSimDB.craftListsDB.globalLists[id]
    else
        crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
        if CraftSimDB.craftListsDB.characterLists[crafterUID] then
            list = CraftSimDB.craftListsDB.characterLists[crafterUID][id]
        end
    end
    if list then
        NormalizeListRecipes(list)
    end
    return list
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param recipeID RecipeID
function CraftSim.DB.CRAFT_LISTS:AddRecipe(id, isGlobal, crafterUID, recipeID)
    local list = self:GetList(id, isGlobal, crafterUID)
    if not list then return end
    if not GUTIL:Find(list.recipeEntries, function(entry) return entry.recipeID == recipeID end) then
        tinsert(list.recipeEntries, CreateDefaultRecipeEntry(recipeID))
        tinsert(list.recipeIDs, recipeID)
    end
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param recipeID RecipeID
function CraftSim.DB.CRAFT_LISTS:RemoveRecipe(id, isGlobal, crafterUID, recipeID)
    local list = self:GetList(id, isGlobal, crafterUID)
    if not list then return end
    local _, entryIndex = GUTIL:Find(list.recipeEntries, function(entry) return entry.recipeID == recipeID end)
    if entryIndex then
        tremove(list.recipeEntries, entryIndex)
    end
    local _, index = GUTIL:Find(list.recipeIDs, function(rid) return rid == recipeID end)
    if index then
        tremove(list.recipeIDs, index)
    end
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param recipeID RecipeID
---@return CraftSim.CraftListRecipeEntry?
function CraftSim.DB.CRAFT_LISTS:GetRecipeEntry(id, isGlobal, crafterUID, recipeID)
    local list = self:GetList(id, isGlobal, crafterUID)
    if not list then return nil end
    local entry = GUTIL:Find(list.recipeEntries, function(re) return re.recipeID == recipeID end)
    return entry
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param recipeID RecipeID
---@param restockMaxAmount number
function CraftSim.DB.CRAFT_LISTS:SetRecipeRestockOptions(id, isGlobal, crafterUID, recipeID, restockMaxAmount)
    local list = self:GetList(id, isGlobal, crafterUID)
    if not list then return end
    local entry = GUTIL:Find(list.recipeEntries, function(re) return re.recipeID == recipeID end)
    if not entry then
        self:AddRecipe(id, isGlobal, crafterUID, recipeID)
        entry = GUTIL:Find(list.recipeEntries, function(re) return re.recipeID == recipeID end)
        if not entry then return end
    end
    entry.restockMaxAmount = math.max(0, tonumber(restockMaxAmount) or 0)
    NormalizeListRecipes(list)
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param enabled boolean
function CraftSim.DB.CRAFT_LISTS:SetListRestockModeEnabled(id, isGlobal, crafterUID, enabled)
    local list = self:GetList(id, isGlobal, crafterUID)
    if not list then return end
    list.options = list.options or DefaultOptions()
    -- Intentionally only toggle list-level mode; keep per-recipe restockMaxAmount untouched.
    list.options.restockModeEnabled = enabled == true
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param options CraftSim.CraftList.Options
function CraftSim.DB.CRAFT_LISTS:SaveOptions(id, isGlobal, crafterUID, options)
    local list = self:GetList(id, isGlobal, crafterUID)
    if list then
        list.options = options
    end
end

---@param id number
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return string exportString
function CraftSim.DB.CRAFT_LISTS:ExportList(id, isGlobal, crafterUID)
    local list = self:GetList(id, isGlobal, crafterUID)
    if not list then return "" end
    NormalizeListRecipes(list)
    local encoded = CraftSim.UTIL:EncodeTable(list)
    return encoded
end

---@param exportString string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return boolean success
function CraftSim.DB.CRAFT_LISTS:ImportList(exportString, isGlobal, crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    local listData = CraftSim.UTIL:DecodeTable(exportString) --[[@as CraftSim.CraftList]]

    ---@type CraftSim.CraftList
    local list = listData
    if not list or not list.name then return false end
    NormalizeListRecipes(list)

    -- Assign a fresh ID for this installation
    local newID = NextID()
    list.id = newID
    list.isGlobal = isGlobal

    if isGlobal then
        CraftSimDB.craftListsDB.globalLists[newID] = list
    else
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        CraftSimDB.craftListsDB.characterLists[crafterUID][newID] = list
    end

    return true
end

--- Migrations

function CraftSim.DB.CRAFT_LISTS.MIGRATION:M_0_1_Import_Character_Favorites_from_CrafterDB()
    if not CraftSimDB.crafterDB or not CraftSimDB.crafterDB.data then
        error("CrafterDB data not found, cannot import character favorites into CraftListsDB")
    end

    for crafterUID, crafterData in pairs(CraftSimDB.crafterDB.data) do
        if crafterData.favoriteRecipes then
            local allRecipeIDs = {}
            for _, recipeIDs in pairs(crafterData.favoriteRecipes) do
                for _, recipeID in ipairs(recipeIDs) do
                    if not tContains(allRecipeIDs, recipeID) then
                        tinsert(allRecipeIDs, recipeID)
                    end
                end
            end

            if #allRecipeIDs > 0 then
                local listName = crafterUID .. " Favorites"
                CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or
                {}
                local options = DefaultOptions()
                if CraftSimDB.optionsDB and CraftSimDB.optionsDB.data then
                    local od = CraftSimDB.optionsDB.data
                    if od["CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING"] ~= nil then
                        options.smartConcentrationQueuing = od
                        ["CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING"]
                    end
                    if od["CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT"] ~= nil then
                        options.offsetConcentrationCraftAmount = od
                        ["CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT"]
                    end
                    if od["CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"] ~= nil then
                        options.offsetQueueAmount = tonumber(od["CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"]) or 0
                    end
                    if od["CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND"] ~= nil then
                        options.includeSoulboundFinishingReagents = od
                        ["CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND"]
                    end
                end
                local newID = NextID()
                local recipeEntries = {}
                for _, recipeID in ipairs(allRecipeIDs) do
                    tinsert(recipeEntries, CreateDefaultRecipeEntry(recipeID))
                end
                CraftSimDB.craftListsDB.characterLists[crafterUID][newID] = {
                    id = newID,
                    name = listName,
                    isGlobal = false,
                    recipeEntries = recipeEntries,
                    recipeIDs = allRecipeIDs,
                    options = options,
                }
                -- Mark "Character Favorites" as selected for queue for this character
                CraftSimDB.craftListsDB.selectedForQueue[crafterUID] = CraftSimDB.craftListsDB.selectedForQueue
                [crafterUID] or {}
                CraftSimDB.craftListsDB.selectedForQueue[crafterUID][newID] = true
            end
        end
    end
end
