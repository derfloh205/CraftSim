---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local print = CraftSim.DEBUG:RegisterDebugID("Data.ItemCount")

---@class CraftSim.ITEM_COUNT : Frame
CraftSim.ITEM_COUNT = GUTIL:CreateRegistreeForEvents({ "BAG_UPDATE_DELAYED", "BANKFRAME_OPENED" })

---@param crafterUID string
---@param itemID ItemInfo
---@param excludeWarbank? boolean
---@return number count
---@return ItemID? alternativeItemID
---@return number? alternativeCount
function CraftSim.ITEM_COUNT:Get(crafterUID, itemID, excludeWarbank)
    local playerCrafterUID = CraftSim.UTIL:GetPlayerCrafterUID()
    crafterUID = crafterUID or playerCrafterUID
    local isPlayer = crafterUID == playerCrafterUID

    local alternativeItemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID]

    if isPlayer then
        -- always from api and then save
        self:UpdateAllCountsForItemID(itemID)

        local altCount = nil
        -- if player then return inclusive accountBankCount
        local itemCount = CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID, true, not excludeWarbank)
        if alternativeItemID then
            self:UpdateAllCountsForItemID(alternativeItemID)
            altCount = CraftSim.DB.ITEM_COUNT:Get(crafterUID, alternativeItemID, true, not excludeWarbank)
        end
        return itemCount, alternativeItemID, altCount
    end

    -- for alts do not include accountBank
    local count = CraftSim.DB.ITEM_COUNT:Get(crafterUID, itemID, true, false)
    local altCount = nil
    if alternativeItemID then
        altCount = CraftSim.DB.ITEM_COUNT:Get(crafterUID, alternativeItemID, true, false)
    end
    if not count then
        return 0 -- not cached yet
    else
        return count, alternativeItemID, altCount
    end
end

---@param itemID ItemID
function CraftSim.ITEM_COUNT:UpdateAllCountsForItemID(itemID)
    local crafterUID = CraftSim.UTIL:GetPlayerCrafterUID()

    local inventoryCount = C_Item.GetItemCount(itemID, false, false, false, false)
    local bankCount = math.max(0, C_Item.GetItemCount(itemID, true, false, true, false) - inventoryCount)
    local accountBankCount = math.max(0, C_Item.GetItemCount(itemID, false, false, false, true) - inventoryCount)

    CraftSim.DB.ITEM_COUNT:UpdateItemCounts(crafterUID, itemID, inventoryCount, bankCount, accountBankCount)
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
                        self:UpdateAllCountsForItemID(itemID)
                    end
                end
            end
        end
    end
    -- +6 to account for accountBank / warband bank
    for bagID = REAGENTBANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS + 6 do
        countBagItems(bagID)
    end
end
