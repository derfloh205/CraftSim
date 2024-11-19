---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Database.ItemCountDB")

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB


---@class CraftSim.DB.ITEM_COUNT.CharacterItemCountData
---@field bank table<ItemID, number>
---@field inventory table<ItemID, number>

---@class CraftSim.DB.ITEM_COUNT : CraftSim.DB.Repository
CraftSim.DB.ITEM_COUNT = CraftSim.DB:RegisterRepository()

function CraftSim.DB.ITEM_COUNT:Init()
    if not CraftSimDB.itemCountDB then
        ---@type CraftSimDB.Database
        CraftSimDB.itemCountDB = {
            data = {
                ---@type table<ItemID, number>
                accountBank = {},
                ---@type table<CrafterUID, CraftSim.DB.ITEM_COUNT.CharacterItemCountData>
                characters = {}
            },
            version = 0,
        }
    end

    CraftSimDB.itemCountDB.data = CraftSimDB.itemCountDB.data or {}
end

function CraftSim.DB.ITEM_COUNT:Migrate()
    -- 0 -> 1
    if CraftSimDB.itemCountDB.version == 0 then
        CraftSimDB.itemCountDB.data = CraftSimItemCountCache or {}
        CraftSimDB.itemCountDB.version = 1
    end

    -- 1 -> 2 (16.1.2 -> 16.1.3)
    if CraftSimDB.itemCountDB.version == 1 then
        -- remove any crafter entries with colored names...
        for crafterUID, _ in pairs(CraftSimDB.itemCountDB.data or {}) do
            if string.find(crafterUID, '\124c') then
                CraftSimDB.itemCountDB.data[crafterUID] = nil
            end
        end

        CraftSimDB.itemCountDB.version = 2
    end

    -- 2 -> 3 rebuild
    if CraftSimDB.itemCountDB.version == 2 then
        self:ClearAll()
        CraftSimDB.itemCountDB.data = {
            accountBank = {},
            characters = {}
        }
        CraftSimDB.itemCountDB.version = 3
    end
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
---@return number itemCount
function CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID, includeBank, includeAccountBank)
    CraftSimDB.itemCountDB.data.characters = CraftSimDB.itemCountDB.data.characters or {}
    CraftSimDB.itemCountDB.data.characters[crafterUID] = CraftSimDB.itemCountDB.data.characters[crafterUID] or {
        bank = {},
        inventory = {}
    }
    local itemCount = CraftSimDB.itemCountDB.data.characters[crafterUID].inventory[itemID] or 0

    if includeBank then
        itemCount = itemCount + (CraftSimDB.itemCountDB.data.characters[crafterUID].bank[itemID] or 0)
    end

    if includeAccountBank then
        itemCount = itemCount + self:GetAccountBankCount(itemID)
    end

    return itemCount
end

---@param crafterUID CrafterUID
---@param itemID number
---@param count number
function CraftSim.DB.ITEM_COUNT:SaveInventoryCount(crafterUID, itemID, count)
    CraftSimDB.itemCountDB.data.characters = CraftSimDB.itemCountDB.data.characters or {}
    CraftSimDB.itemCountDB.data.characters[crafterUID] = CraftSimDB.itemCountDB.data.characters[crafterUID] or {
        bank = {},
        inventory = {}
    }
    CraftSimDB.itemCountDB.data.characters[crafterUID].inventory[itemID] = count
end

---@param crafterUID CrafterUID
---@param itemID number
---@param count number
function CraftSim.DB.ITEM_COUNT:SaveBankCount(crafterUID, itemID, count)
    CraftSimDB.itemCountDB.data.characters = CraftSimDB.itemCountDB.data.characters or {}
    CraftSimDB.itemCountDB.data.characters[crafterUID] = CraftSimDB.itemCountDB.data.characters[crafterUID] or {
        bank = {},
        inventory = {}
    }
    CraftSimDB.itemCountDB.data.characters[crafterUID].bank[itemID] = count
end

---@param itemID number
---@param count number
function CraftSim.DB.ITEM_COUNT:SaveAccountBankCount(itemID, count)
    CraftSimDB.itemCountDB.data.accountBank = CraftSimDB.itemCountDB.data.accountBank or {}
    CraftSimDB.itemCountDB.data.accountBank[itemID] = count
end

---@param crafterUID CrafterUID
---@param itemID number
---@param inventory number
---@param bank number
---@param accountBank number
function CraftSim.DB.ITEM_COUNT:UpdateItemCounts(crafterUID, itemID, inventory, bank, accountBank)
    self:SaveInventoryCount(crafterUID, itemID, inventory)
    self:SaveBankCount(crafterUID, itemID, bank)
    self:SaveAccountBankCount(itemID, accountBank)
end

---@param itemID number
---@return number count
function CraftSim.DB.ITEM_COUNT:GetAccountBankCount(itemID)
    CraftSimDB.itemCountDB.data.accountBank = CraftSimDB.itemCountDB.data.accountBank or {}
    return CraftSimDB.itemCountDB.data.accountBank[itemID] or 0
end
