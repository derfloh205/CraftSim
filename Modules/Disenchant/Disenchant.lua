---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local f = GUTIL:GetFormatter()

---@class CraftSim.DISENCHANT : CraftSim.Module
CraftSim.DISENCHANT = GUTIL:CreateRegistreeForEvents({ "BAG_UPDATE_DELAYED", "BANKFRAME_OPENED", "BANKFRAME_CLOSED" })

CraftSim.MODULES:RegisterModule("MODULE_DISENCHANT", CraftSim.DISENCHANT)

---@type table<string, boolean>
CraftSim.DISENCHANT.sessionBlacklist = {}

local Logger = CraftSim.DEBUG:RegisterLogger("Disenchant")
function CraftSim.DISENCHANT:Init()
end

---@return ItemMixin[] items
---@return table<string, number> countMap
function CraftSim.DISENCHANT:LoadItems()
    -- loop inventory, bank and warbank and load all itemlocations that could be disenchanted
    local items = {}
    local countMap = {}
    local function GetItemLocationsFromBag(bag)
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
                table.insert(items, Item:CreateFromItemLocation(itemLocation))
                countMap[itemLink] = (countMap[itemLink] or 0) + 1
            end
        end
    end

    -- Load items from player's bags
    for bag = Enum.BagIndex.Backpack, Enum.BagIndex.Bag_4 do
        GetItemLocationsFromBag(bag)
    end

    -- Load items from bank
    for bag = Enum.BagIndex.CharacterBankTab_1, Enum.BagIndex.CharacterBankTab_6 do
        GetItemLocationsFromBag(bag)
    end

    -- Load items from account bank
    for bag = Enum.BagIndex.AccountBankTab_1, Enum.BagIndex.AccountBankTab_5 do
        GetItemLocationsFromBag(bag)
    end

    return items, countMap
end

function CraftSim.DISENCHANT:BAG_UPDATE_DELAYED()
    local frame = self.frame
    if not frame or not frame:IsVisible() then return end
    CraftSim.DISENCHANT.UI:Update()
end

function CraftSim.DISENCHANT:BANKFRAME_OPENED()
    local frame = self.frame
    if not frame or not frame:IsVisible() then return end
    CraftSim.DISENCHANT.UI:Update()
end

function CraftSim.DISENCHANT:BANKFRAME_CLOSED()
    local frame = self.frame
    if not frame or not frame:IsVisible() then return end
    RunNextFrame(function()
        CraftSim.DISENCHANT.UI:Update()
    end)
end

---@param items ItemMixin[]
---@return ItemMixin[] filteredItems
function CraftSim.DISENCHANT:FilterItems(items)
    local minimumItemLevel = CraftSim.DB.OPTIONS:Get("DISENCHANT_MIN_ILVL")

    return GUTIL:Filter(items, function(item)
        local itemLink = item:GetItemLink()
        Logger:LogDebug("Filter Items: " .. itemLink)
        -- not an equipment item
        if item:GetInventoryType() == 0 then return false end

        local itemInfo = { C_Item.GetItemInfo(itemLink) }
        local itemLevel = itemInfo[4]
        local itemQuality = itemInfo[3]
        local itemSubType = itemInfo[7]
        local itemClass = itemInfo[12]

        Logger:LogDebug("- ItemClass: " ..
            tostring(itemClass) .. " ItemSubType: " .. tostring(itemSubType) .. " ItemQuality: " .. tostring(itemQuality))

        if itemClass == Enum.ItemClass.Container then return false end

        if itemSubType == Enum.ItemArmorSubclass.Cosmetic then return false end

        if itemQuality < Enum.ItemQuality.Uncommon or itemQuality > Enum.ItemQuality.Epic then return false end

        if itemLevel < minimumItemLevel then return false end

        if self:IsBlacklisted(itemLink) then return false end

        return true
    end)
end

---@param itemLink string
function CraftSim.DISENCHANT:IsBlacklisted(itemLink)
    return CraftSim.DISENCHANT.sessionBlacklist[itemLink] or CraftSim.DB.OPTIONS:Get("DISENCHANT_BLACKLIST")[itemLink]
end
