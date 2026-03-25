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
---@field useCurrentCharacter boolean
---@field fixedCrafterUID CrafterUID?
---@field restockAmount number
---@field offsetQueueAmount number

---@class CraftSim.CraftList
---@field name string
---@field recipeIDs RecipeID[]
---@field options CraftSim.CraftList.Options

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
        useCurrentCharacter = true,
        fixedCrafterUID = nil,
        restockAmount = 1,
        offsetQueueAmount = 0,
    }
end

CraftSim.DB.CRAFT_LISTS.DefaultOptions = DefaultOptions

function CraftSim.DB.CRAFT_LISTS:Init()
    if not CraftSimDB.craftListsDB then
        ---@class CraftSimDB.CraftListsDB : CraftSimDB.Database
        CraftSimDB.craftListsDB = {
            version = 0,
            ---@type table<string, CraftSim.CraftList>
            globalLists = {},
            ---@type table<CrafterUID, table<string, CraftSim.CraftList>>
            characterLists = {},
            ---@type table<CrafterUID, table<string, boolean>>
            selectedForQueue = {},
        }
    end
    self.db = CraftSimDB.craftListsDB
    CraftSimDB.craftListsDB.globalLists = CraftSimDB.craftListsDB.globalLists or {}
    CraftSimDB.craftListsDB.characterLists = CraftSimDB.craftListsDB.characterLists or {}
    CraftSimDB.craftListsDB.selectedForQueue = CraftSimDB.craftListsDB.selectedForQueue or {}
end

---@param crafterUID CrafterUID
---@param listName string
---@return boolean
function CraftSim.DB.CRAFT_LISTS:IsSelectedForQueue(crafterUID, listName)
    CraftSimDB.craftListsDB.selectedForQueue[crafterUID] = CraftSimDB.craftListsDB.selectedForQueue[crafterUID] or {}
    return CraftSimDB.craftListsDB.selectedForQueue[crafterUID][listName] == true
end

---@param crafterUID CrafterUID
---@param listName string
---@param selected boolean
function CraftSim.DB.CRAFT_LISTS:SetSelectedForQueue(crafterUID, listName, selected)
    CraftSimDB.craftListsDB.selectedForQueue[crafterUID] = CraftSimDB.craftListsDB.selectedForQueue[crafterUID] or {}
    CraftSimDB.craftListsDB.selectedForQueue[crafterUID][listName] = selected or nil
end

---@param crafterUID? CrafterUID
---@return CraftSim.CraftList[]
function CraftSim.DB.CRAFT_LISTS:GetAllLists(crafterUID)
    local lists = {}
    for _, list in pairs(CraftSimDB.craftListsDB.globalLists) do
        tinsert(lists, list)
    end
    if crafterUID then
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        for _, list in pairs(CraftSimDB.craftListsDB.characterLists[crafterUID]) do
            tinsert(lists, list)
        end
    end
    return lists
end

---@param crafterUID? CrafterUID
---@return table<string, boolean> listNames map of list name -> isGlobal
function CraftSim.DB.CRAFT_LISTS:GetAllListNames(crafterUID)
    local names = {}
    for name, _ in pairs(CraftSimDB.craftListsDB.globalLists) do
        names[name] = true
    end
    if crafterUID then
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        for name, _ in pairs(CraftSimDB.craftListsDB.characterLists[crafterUID]) do
            names[name] = false
        end
    end
    return names
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return CraftSim.CraftList? list nil if name already taken
function CraftSim.DB.CRAFT_LISTS:CreateList(name, isGlobal, crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    local allNames = self:GetAllListNames(crafterUID)
    if allNames[name] ~= nil then
        return nil -- name already taken
    end

    ---@type CraftSim.CraftList
    local newList = {
        name = name,
        recipeIDs = {},
        options = DefaultOptions(),
    }

    if isGlobal then
        CraftSimDB.craftListsDB.globalLists[name] = newList
    else
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        CraftSimDB.craftListsDB.characterLists[crafterUID][name] = newList
    end

    return newList
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
function CraftSim.DB.CRAFT_LISTS:DeleteList(name, isGlobal, crafterUID)
    if isGlobal then
        CraftSimDB.craftListsDB.globalLists[name] = nil
        -- Clean up per-character selectedForQueue for all characters
        for uid, selected in pairs(CraftSimDB.craftListsDB.selectedForQueue) do
            selected[name] = nil
        end
    else
        crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
        if CraftSimDB.craftListsDB.characterLists[crafterUID] then
            CraftSimDB.craftListsDB.characterLists[crafterUID][name] = nil
        end
        if CraftSimDB.craftListsDB.selectedForQueue[crafterUID] then
            CraftSimDB.craftListsDB.selectedForQueue[crafterUID][name] = nil
        end
    end
end

---@param oldName string
---@param newName string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return boolean success false if newName already taken
function CraftSim.DB.CRAFT_LISTS:RenameList(oldName, newName, isGlobal, crafterUID)
    if oldName == newName then return true end
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()

    local allNames = self:GetAllListNames(crafterUID)
    if allNames[newName] ~= nil then
        return false -- name already taken
    end

    if isGlobal then
        local listData = CraftSimDB.craftListsDB.globalLists[oldName]
        if listData then
            listData.name = newName
            CraftSimDB.craftListsDB.globalLists[newName] = listData
            CraftSimDB.craftListsDB.globalLists[oldName] = nil
        end
        -- Update selectedForQueue for all characters
        for _, selected in pairs(CraftSimDB.craftListsDB.selectedForQueue) do
            if selected[oldName] ~= nil then
                selected[newName] = selected[oldName]
                selected[oldName] = nil
            end
        end
    else
        if CraftSimDB.craftListsDB.characterLists[crafterUID] then
            local listData = CraftSimDB.craftListsDB.characterLists[crafterUID][oldName]
            if listData then
                listData.name = newName
                CraftSimDB.craftListsDB.characterLists[crafterUID][newName] = listData
                CraftSimDB.craftListsDB.characterLists[crafterUID][oldName] = nil
            end
        end
        -- Update selectedForQueue for the owning character
        if CraftSimDB.craftListsDB.selectedForQueue[crafterUID] then
            local sel = CraftSimDB.craftListsDB.selectedForQueue[crafterUID]
            if sel[oldName] ~= nil then
                sel[newName] = sel[oldName]
                sel[oldName] = nil
            end
        end
    end

    return true
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return CraftSim.CraftList?
function CraftSim.DB.CRAFT_LISTS:GetList(name, isGlobal, crafterUID)
    if isGlobal then
        return CraftSimDB.craftListsDB.globalLists[name]
    else
        crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
        if CraftSimDB.craftListsDB.characterLists[crafterUID] then
            return CraftSimDB.craftListsDB.characterLists[crafterUID][name]
        end
    end
    return nil
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param recipeID RecipeID
function CraftSim.DB.CRAFT_LISTS:AddRecipe(name, isGlobal, crafterUID, recipeID)
    local list = self:GetList(name, isGlobal, crafterUID)
    if not list then return end
    if not tContains(list.recipeIDs, recipeID) then
        tinsert(list.recipeIDs, recipeID)
    end
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param recipeID RecipeID
function CraftSim.DB.CRAFT_LISTS:RemoveRecipe(name, isGlobal, crafterUID, recipeID)
    local list = self:GetList(name, isGlobal, crafterUID)
    if not list then return end
    local _, index = GUTIL:Find(list.recipeIDs, function(id) return id == recipeID end)
    if index then
        tremove(list.recipeIDs, index)
    end
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@param options CraftSim.CraftList.Options
function CraftSim.DB.CRAFT_LISTS:SaveOptions(name, isGlobal, crafterUID, options)
    local list = self:GetList(name, isGlobal, crafterUID)
    if list then
        list.options = options
    end
end

---@param name string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return string exportString
function CraftSim.DB.CRAFT_LISTS:ExportList(name, isGlobal, crafterUID)
    local list = self:GetList(name, isGlobal, crafterUID)
    if not list then return "" end
    local serialized = CraftSim.COMM:Serialize(list)
    local compressed = CraftSim.LibCompress:Compress(serialized)
    local encoded = CraftSim.LibCompress:GetAddonEncodeTable():Encode(compressed)
    return encoded
end

---@param exportString string
---@param isGlobal boolean
---@param crafterUID? CrafterUID
---@return boolean success
function CraftSim.DB.CRAFT_LISTS:ImportList(exportString, isGlobal, crafterUID)
    crafterUID = crafterUID or CraftSim.UTIL:GetPlayerCrafterUID()
    local decoded = CraftSim.LibCompress:GetAddonEncodeTable():Decode(exportString)
    local decompressed, err = CraftSim.LibCompress:Decompress(decoded)
    if not decompressed then
        print("CraftListsDB Import Error: " .. tostring(err))
        return false
    end
    local success, listData = CraftSim.COMM:Deserialize(decompressed)
    if not success then
        print("CraftListsDB Import Error: Could not deserialize")
        return false
    end

    ---@type CraftSim.CraftList
    local list = listData
    if not list or not list.name then return false end

    -- Ensure unique name
    local targetName = list.name
    local counter = 1
    local allNames = self:GetAllListNames(crafterUID)
    while allNames[targetName] ~= nil do
        targetName = list.name .. " (" .. counter .. ")"
        counter = counter + 1
    end
    list.name = targetName

    if isGlobal then
        CraftSimDB.craftListsDB.globalLists[targetName] = list
    else
        CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
        CraftSimDB.craftListsDB.characterLists[crafterUID][targetName] = list
    end

    return true
end

--- Migrations

function CraftSim.DB.CRAFT_LISTS.MIGRATION:M_0_1_Import_Character_Favorites_from_CrafterDB()
    if not CraftSimDB.crafterDB or not CraftSimDB.crafterDB.data then
        return
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
                local listName = "Character Favorites"
                CraftSimDB.craftListsDB.characterLists[crafterUID] = CraftSimDB.craftListsDB.characterLists[crafterUID] or {}
                local options = DefaultOptions()
                if CraftSimDB.optionsDB and CraftSimDB.optionsDB.data then
                    local od = CraftSimDB.optionsDB.data
                    if od["CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING"] ~= nil then
                        options.smartConcentrationQueuing = od["CRAFTQUEUE_RESTOCK_FAVORITES_SMART_CONCENTRATION_QUEUING"]
                    end
                    if od["CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT"] ~= nil then
                        options.offsetConcentrationCraftAmount = od["CRAFTQUEUE_RESTOCK_FAVORITES_OFFSET_CONCENTRATION_CRAFT_AMOUNT"]
                    end
                    if od["CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"] ~= nil then
                        options.offsetQueueAmount = tonumber(od["CRAFTQUEUE_QUEUE_FAVORITES_OFFSET_QUEUE_AMOUNT"]) or 0
                    end
                    if od["CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND"] ~= nil then
                        options.includeSoulboundFinishingReagents = od["CRAFTQUEUE_RESTOCK_FAVORITES_FINISHING_REAGENTS_INCLUDE_SOULBOUND"]
                    end
                end
                CraftSimDB.craftListsDB.characterLists[crafterUID][listName] = {
                    name = listName,
                    recipeIDs = allRecipeIDs,
                    options = options,
                }
                -- Mark "Character Favorites" as selected for queue for this character
                CraftSimDB.craftListsDB.selectedForQueue[crafterUID] = CraftSimDB.craftListsDB.selectedForQueue[crafterUID] or {}
                CraftSimDB.craftListsDB.selectedForQueue[crafterUID][listName] = true
            end
        end
    end
end
