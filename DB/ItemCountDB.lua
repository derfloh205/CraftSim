---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Database.ItemCountDB")

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB


---@class CraftSim.DB.ITEM_COUNT.CharacterItemCountData
---@field bank table<string, number>
---@field inventory table<string, number>

---@class CraftSim.DB.ITEM_COUNT : CraftSim.DB.Repository
CraftSim.DB.ITEM_COUNT = CraftSim.DB:RegisterRepository("ItemCountDB")

function CraftSim.DB.ITEM_COUNT:Init()
    if not CraftSimDB.itemCountDB then
        ---@type CraftSimDB.Database
        CraftSimDB.itemCountDB = {
            data = {
                ---@type table<string, number>
                accountBank = {},
                ---@type table<CrafterUID, CraftSim.DB.ITEM_COUNT.CharacterItemCountData>
                characters = {}
            },
            version = 0,
        }
    end
    self.db = CraftSimDB.itemCountDB

    CraftSimDB.itemCountDB.data = CraftSimDB.itemCountDB.data or {}
end

--- Returns the composite DB key for an item with a given quality.
--- For non-gear items each quality has its own itemID so qualityID defaults to 1.
--- For gear items all qualities share the same itemID; pass the actual qualityID.
---@param itemID number
---@param qualityID? number defaults to 1
---@return string key
function CraftSim.DB.ITEM_COUNT:GetKey(itemID, qualityID)
    qualityID = qualityID or 1
    return tostring(itemID) .. ":" .. tostring(qualityID)
end

function CraftSim.DB.ITEM_COUNT:CleanUp()
    if _G["CraftSimItemCountCache"] then
        -- remove it
        _G["CraftSimItemCountCache"] = nil
    end
end

function CraftSim.DB.ITEM_COUNT:ClearAll()
    wipe(CraftSimDB.itemCountDB.data)
end

---@param crafterUID CrafterUID
---@param itemID number
---@param includeBank? boolean -- reagentBank + bank
---@param includeAccountBank? boolean
---@param qualityID? number defaults to 1; for gear items pass the specific quality to count
---@return number itemCount
function CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID, includeBank, includeAccountBank, qualityID)
    local key = self:GetKey(itemID, qualityID)
    CraftSimDB.itemCountDB.data.characters = CraftSimDB.itemCountDB.data.characters or {}
    CraftSimDB.itemCountDB.data.characters[crafterUID] = CraftSimDB.itemCountDB.data.characters[crafterUID] or {
        bank = {},
        inventory = {}
    }
    local itemCount = CraftSimDB.itemCountDB.data.characters[crafterUID].inventory[key] or 0

    if includeBank then
        itemCount = itemCount + (CraftSimDB.itemCountDB.data.characters[crafterUID].bank[key] or 0)
    end

    if includeAccountBank then
        itemCount = itemCount + self:GetAccountBankCount(itemID, qualityID)
    end

    return itemCount
end

---@param crafterUID CrafterUID
---@param itemID number
---@param count number
---@param qualityID? number defaults to 1
function CraftSim.DB.ITEM_COUNT:SaveInventoryCount(crafterUID, itemID, count, qualityID)
    local key = self:GetKey(itemID, qualityID)
    CraftSimDB.itemCountDB.data.characters = CraftSimDB.itemCountDB.data.characters or {}
    CraftSimDB.itemCountDB.data.characters[crafterUID] = CraftSimDB.itemCountDB.data.characters[crafterUID] or {
        bank = {},
        inventory = {}
    }
    CraftSimDB.itemCountDB.data.characters[crafterUID].inventory[key] = count
end

---@param crafterUID CrafterUID
---@param itemID number
---@param count number
---@param qualityID? number defaults to 1
function CraftSim.DB.ITEM_COUNT:SaveBankCount(crafterUID, itemID, count, qualityID)
    local key = self:GetKey(itemID, qualityID)
    CraftSimDB.itemCountDB.data.characters = CraftSimDB.itemCountDB.data.characters or {}
    CraftSimDB.itemCountDB.data.characters[crafterUID] = CraftSimDB.itemCountDB.data.characters[crafterUID] or {
        bank = {},
        inventory = {}
    }
    CraftSimDB.itemCountDB.data.characters[crafterUID].bank[key] = count
end

---@param itemID number
---@param count number
---@param qualityID? number defaults to 1
function CraftSim.DB.ITEM_COUNT:SaveAccountBankCount(itemID, count, qualityID)
    local key = self:GetKey(itemID, qualityID)
    CraftSimDB.itemCountDB.data.accountBank = CraftSimDB.itemCountDB.data.accountBank or {}
    CraftSimDB.itemCountDB.data.accountBank[key] = count
end

---@param crafterUID CrafterUID
---@param itemID number
---@param inventory number
---@param bank number
---@param accountBank number
---@param qualityID? number defaults to 1
function CraftSim.DB.ITEM_COUNT:UpdateItemCounts(crafterUID, itemID, inventory, bank, accountBank, qualityID)
    self:SaveInventoryCount(crafterUID, itemID, inventory, qualityID)
    self:SaveBankCount(crafterUID, itemID, bank, qualityID)
    self:SaveAccountBankCount(itemID, accountBank, qualityID)
end

---@param itemID number
---@param qualityID? number defaults to 1
---@return number count
function CraftSim.DB.ITEM_COUNT:GetAccountBankCount(itemID, qualityID)
    local key = self:GetKey(itemID, qualityID)
    CraftSimDB.itemCountDB.data.accountBank = CraftSimDB.itemCountDB.data.accountBank or {}
    return CraftSimDB.itemCountDB.data.accountBank[key] or 0
end

--- Migrations
function CraftSim.DB.ITEM_COUNT.MIGRATION:M_0_1_Import_from_CraftSimRecipeDataCache()
    CraftSimDB.itemCountDB.data = CraftSimItemCountCache or {}
end

function CraftSim.DB.ITEM_COUNT.MIGRATION:M_1_2_Remove_colored_crafter_names()
    -- remove any crafter entries with colored names...
        for crafterUID, _ in pairs(CraftSimDB.itemCountDB.data or {}) do
            if string.find(crafterUID, '\124c') then
                CraftSimDB.itemCountDB.data[crafterUID] = nil
            end
        end
end

function CraftSim.DB.ITEM_COUNT.MIGRATION:M_2_3_Remove_fishing_from_concentrationData()
    -- rebuild database
    CraftSim.DB.ITEM_COUNT:ClearAll()
    CraftSimDB.itemCountDB.data = {
        accountBank = {},
        characters = {}
    }
end

function CraftSim.DB.ITEM_COUNT.MIGRATION:M_3_4_Add_QualityID_to_keys()
    -- Keys changed from plain itemID numbers to "itemID:qualityID" composite strings.
    -- Migrate existing data by appending ":1" to every key (all existing data was quality 1).
    -- Note: this migration only executes once because the DB version gate (version == 3)
    -- prevents re-running. The ':' presence check below is just a safety guard within
    -- the migration logic itself to avoid double-suffixing if data is unexpectedly mixed.
    local data = CraftSimDB.itemCountDB.data
    if not data then return end

    for _, charData in pairs(data.characters or {}) do
        local newInventory = {}
        for k, count in pairs(charData.inventory or {}) do
            local key = tostring(k)
            if not string.find(key, ":", 1, true) then
                newInventory[key .. ":1"] = count
            else
                newInventory[key] = count
            end
        end
        charData.inventory = newInventory

        local newBank = {}
        for k, count in pairs(charData.bank or {}) do
            local key = tostring(k)
            if not string.find(key, ":", 1, true) then
                newBank[key .. ":1"] = count
            else
                newBank[key] = count
            end
        end
        charData.bank = newBank
    end

    local newAccountBank = {}
    for k, count in pairs(data.accountBank or {}) do
        local key = tostring(k)
        if not string.find(key, ":", 1, true) then
            newAccountBank[key .. ":1"] = count
        else
            newAccountBank[key] = count
        end
    end
    data.accountBank = newAccountBank
end
