_, CraftSim = ...

---@class CraftSim.ReagentItem
CraftSim.ReagentItem = CraftSim.Object:extend()

---@param itemID number
---@param qualityID number?
function CraftSim.ReagentItem:new(itemID, qualityID)

    -- consider possible exception mappings
    itemID = CraftSim.CONST.REAGENT_ID_EXCEPTION_MAPPING[itemID] or itemID

    self.qualityID = qualityID
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
        tostring(((self.item and (self.item:GetItemLink() or self.item:GetItemID())) or "None") .. " x " .. self.quantity),
    }
end

function CraftSim.ReagentItem:Clear()
    self.quantity = 0
end

function CraftSim.ReagentItem:HasItem()
    if not self.item then
        return false
    end
    local itemCount = GetItemCount(self.item:GetItemID(), true, true, true)

    return itemCount >= self.quantity
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
    local deserialized = CraftSim.ReagentItem(tonumber(serializedReagentItem.itemID), tonumber(serializedReagentItem.qualityID))
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