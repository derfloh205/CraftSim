---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CACHE_ITEM_COUNT)

---@class CraftSim.ITEM_COUNT : Frame
CraftSim.ITEM_COUNT = GUTIL:CreateRegistreeForEvents({ "BAG_UPDATE_DELAYED", "BANKFRAME_OPENED" })

---@param crafterUID string
---@param itemID ItemInfo
---@return number count
---@return ItemID? alternativeItemID
---@return number? alternativeCount
function CraftSim.ITEM_COUNT:Get(crafterUID, itemID)
    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    crafterUID = crafterUID or playerCrafterUID
    local isPlayer = crafterUID == playerCrafterUID

    local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID]

    if isPlayer then
        -- always from api and then save
        local count = C_Item.GetItemCount(itemID, true, false, true)
        local altCount = nil
        if alternativeItemID then
            altCount = C_Item.GetItemCount(alternativeItemID, true, false, true)
            CraftSim.DB.ITEM_COUNT:Save(crafterUID, alternativeItemID, altCount)
        end
        CraftSim.DB.ITEM_COUNT:Save(crafterUID, itemID, count)
        return count, alternativeItemID, altCount
    end


    local count = CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID)
    local altCount = nil
    if alternativeItemID then
        altCount = CraftSim.DB.ITEM_COUNT:Get(crafterUID, alternativeItemID)
    end
    if not count then
        return 0 -- not cached yet
    else
        return count, alternativeItemID, altCount
    end
end

function CraftSim.ITEM_COUNT:BAG_UPDATE_DELAYED()
    CraftSim.ITEM_COUNT:UpdateItemCountForCharacter()
end

function CraftSim.ITEM_COUNT:BANKFRAME_OPENED()
    CraftSim.ITEM_COUNT:UpdateItemCountForCharacter()
end

--- loops all of a players inventory+bank bags and updates all tradegoods item count
function CraftSim.ITEM_COUNT:UpdateItemCountForCharacter()
    local alreadyUpdated = {} -- small map to cache already updated IDs to not double update them
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
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
                        local itemCount = C_Item.GetItemCount(itemID, true, false, true)
                        CraftSim.DB.ITEM_COUNT:Save(crafterUID, itemID, itemCount)
                    end
                end
            end
        end
    end
    for bagID = REAGENTBANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        countBagItems(bagID)
    end
end
