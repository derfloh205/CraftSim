---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.DB
CraftSim.DB = CraftSim.DB

---@class CraftSim.DB.ITEM_COUNT : Frame
CraftSim.DB.ITEM_COUNT = GUTIL:CreateRegistreeForEvents({ "BAG_UPDATE_DELAYED", "BANKFRAME_OPENED" })

---@type table<string, table<number, number>> table<crafterUID, table<itemID, count>>
CraftSimItemCountCache = {}

---@param itemID ItemInfo
---@param count number?
function CraftSim.DB.ITEM_COUNT:Update(itemID, count)
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSimItemCountCache[crafterUID] = CraftSimItemCountCache[crafterUID] or {}
    if count then
        CraftSimItemCountCache[crafterUID][itemID] = count
        return
    else
        CraftSimItemCountCache[crafterUID][itemID] = C_Item.GetItemCount(itemID, true, false, true)
    end
end

---@param itemID ItemInfo
---@param crafterUID string
---@return number count
---@return ItemID? alternativeItemID
---@return number? alternativeCount
function CraftSim.DB.ITEM_COUNT:Get(itemID, bank, uses, reagentBank, crafterUID)
    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    crafterUID = crafterUID or playerCrafterUID
    local isPlayer = crafterUID == playerCrafterUID

    -- print("C_Item.GetItemCount for crafterUID: " .. tostring(crafterUID))
    -- print("playerCrafterUID: " .. tostring(playerCrafterUID))
    -- print("isPlayer: " .. tostring(isPlayer))

    CraftSimItemCountCache[crafterUID] = CraftSimItemCountCache[crafterUID] or {}

    local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID]

    if isPlayer then
        -- always from api and then cache
        local count = C_Item.GetItemCount(itemID, bank, uses, reagentBank)
        local altCount = nil
        if alternativeItemID then
            altCount = C_Item.GetItemCount(alternativeItemID, bank, uses, reagentBank)
            CraftSim.DB.ITEM_COUNT:Update(alternativeItemID, altCount)
        end
        CraftSim.DB.ITEM_COUNT:Update(itemID, count)
        return count, alternativeItemID, altCount
    end


    local count = CraftSimItemCountCache[crafterUID][itemID]
    local altCount = nil
    if alternativeItemID then
        altCount = CraftSimItemCountCache[crafterUID][alternativeItemID]
    end
    if not count then
        return 0 -- not cached yet
    else
        return count, alternativeItemID, altCount
    end
end

function CraftSim.DB.ITEM_COUNT:GetRest(itemID,
                                           quantity, crafterUID)
    local itemCount = self:Get(itemID, true, false, true, crafterUID)

    return math.max(0, quantity - itemCount)
end

function CraftSim.DB.ITEM_COUNT:ClearAll()
    wipe(CraftSimItemCountCache)
end

function CraftSim.DB.ITEM_COUNT:BAG_UPDATE_DELAYED()
    CraftSim.DB.ITEM_COUNT:UpdateItemCountForCharacter()
end

function CraftSim.DB.ITEM_COUNT:BANKFRAME_OPENED()
    CraftSim.DB.ITEM_COUNT:UpdateItemCountForCharacter()
end

--- loops all of a players inventory+bank bags and updates all tradegoods item count
function CraftSim.DB.ITEM_COUNT:UpdateItemCountForCharacter()
    local alreadyUpdated = {} -- small map to cache already updated IDs to not double update them
    print("Start Bag Update..")
    local function countBagItems(bagID)
        for slot = 1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slot)

            if itemID ~= nil then
                local itemInfoInstant = { C_Item.GetItemInfoInstant(itemID) }
                local itemClassID = itemInfoInstant[6]
                local itemIcon = itemInfoInstant[5]
                if Enum.ItemClass.Tradegoods == itemClassID then
                    if not alreadyUpdated[itemID] then
                        print("Updating Count: " .. GUTIL:IconToText(itemIcon, 20, 20))
                        alreadyUpdated[itemID] = true
                        self:Update(itemID)
                    end
                end
            end
        end
    end
    for bagID = REAGENTBANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        countBagItems(bagID)
    end
end
