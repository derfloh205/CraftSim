---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.CACHE
CraftSim.CACHE = CraftSim.CACHE

---@class CraftSim.CACHE.ITEM_COUNT : Frame
CraftSim.CACHE.ITEM_COUNT = GUTIL:CreateRegistreeForEvents({ "BAG_UPDATE_DELAYED", "BANKFRAME_OPENED" })

---@type table<string, table<number, number>> table<crafterUID, table<itemID, count>>
CraftSimItemCountCache = {}

---@param itemID ItemInfo
---@param count number?
function CraftSim.CACHE.ITEM_COUNT:Update(itemID, count)
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    CraftSimItemCountCache[crafterUID] = CraftSimItemCountCache[crafterUID] or {}
    if count then
        CraftSimItemCountCache[crafterUID][itemID] = count
        return
    else
        CraftSimItemCountCache[crafterUID][itemID] = GetItemCount(itemID, true, false, true)
    end
end

---@param itemID ItemInfo
---@param crafterUID string
function CraftSim.CACHE.ITEM_COUNT:Get(itemID, bank, uses, reagentBank, crafterUID)
    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    crafterUID = crafterUID or playerCrafterUID
    local isPlayer = crafterUID == playerCrafterUID

    -- print("GetItemCount for crafterUID: " .. tostring(crafterUID))
    -- print("playerCrafterUID: " .. tostring(playerCrafterUID))
    -- print("isPlayer: " .. tostring(isPlayer))

    CraftSimItemCountCache[crafterUID] = CraftSimItemCountCache[crafterUID] or {}

    if isPlayer then
        -- always from api and then cache
        local count = GetItemCount(itemID, bank, uses, reagentBank)
        CraftSim.CACHE.ITEM_COUNT:Update(itemID, count)
        return count
    end


    local count = CraftSimItemCountCache[crafterUID][itemID]
    if not count then
        return 0 -- not cached yet
    else
        return count
    end
end

function CraftSim.CACHE.ITEM_COUNT:ClearAll()
    wipe(CraftSimItemCountCache)
end

function CraftSim.CACHE.ITEM_COUNT:BAG_UPDATE_DELAYED()
    CraftSim.CACHE.ITEM_COUNT:UpdateItemCountForCharacter()
end

function CraftSim.CACHE.ITEM_COUNT:BANKFRAME_OPENED()
    CraftSim.CACHE.ITEM_COUNT:UpdateItemCountForCharacter()
end

--- loops all of a players inventory+bank bags and updates all tradegoods item count
function CraftSim.CACHE.ITEM_COUNT:UpdateItemCountForCharacter()
    local alreadyUpdated = {} -- small map to cache already updated IDs to not double update them
    print("Start Bag Update..")
    local function countBagItems(bagID)
        for slot = 1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slot)

            if itemID ~= nil then
                local itemInfoInstant = { GetItemInfoInstant(itemID) }
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
