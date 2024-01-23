---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.ReagentItem
CraftSim.ReagentItem = CraftSim.Object:extend()

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)

---@param itemID number
---@param qualityID number?
function CraftSim.ReagentItem:new(itemID, qualityID)
    -- consider possible exception mappings
    itemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID] or itemID

    self.qualityID = qualityID
    --- how much of that reagentItem has been allocated for this recipe
    self.quantity = 0
    self.item = Item:CreateFromItemID(itemID)
end

---@return CraftSim.ReagentListItem
function CraftSim.ReagentItem:GetAsReagentListItem()
    return {
        itemID = self.item:GetItemID(),
        quantity = self.quantity,
    }
end

function CraftSim.ReagentItem:Copy()
    local copy = CraftSim.ReagentItem(self.item:GetItemID(), self.qualityID)
    copy.quantity = self.quantity

    return copy
end

function CraftSim.ReagentItem:Debug()
    return {
        tostring(((self.item and (self.item:GetItemLink() or self.item:GetItemID())) or "None") .. " x " .. self
            .quantity),
    }
end

function CraftSim.ReagentItem:Clear()
    self.quantity = 0
end

--- returns wether the player has enough of the given required item's allocations (times the multiplier)
---@param multiplier number? default: 1
---@param crafterUID string
function CraftSim.ReagentItem:HasItem(multiplier, crafterUID)
    multiplier = multiplier or 1
    if not self.item then
        return false
    end
    local itemCount = CraftSim.CRAFTQ:GetItemCountFromCraftQueueCache(self.item:GetItemID(), true, false, true,
        crafterUID)
    return itemCount >= (self.quantity * multiplier)
end

---@class CraftSim.ReagentItem.Serialized
---@field qualityID number
---@field quantity number
---@field itemID number

function CraftSim.ReagentItem:Serialize()
    local serizalized = {}
    serizalized.qualityID = self.qualityID
    serizalized.quantity = self.quantity
    serizalized.itemID = self.item:GetItemID()
    return serizalized
end

--- STATIC
---@param serializedReagentItem CraftSim.ReagentItem.Serialized
function CraftSim.ReagentItem:Deserialize(serializedReagentItem)
    local deserialized = CraftSim.ReagentItem(tonumber(serializedReagentItem.itemID),
        tonumber(serializedReagentItem.qualityID))
    deserialized.quantity = tonumber(serializedReagentItem.quantity)
    return deserialized
end

function CraftSim.ReagentItem:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("itemID", self.item:GetItemID(), true)
    jb:End()
    return jb.json
end
