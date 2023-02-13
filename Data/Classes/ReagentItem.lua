_, CraftSim = ...

---@class CraftSim.ReagentItem
---@field qualityID number
---@field quantity number
---@field item ItemMixin

CraftSim.ReagentItem = CraftSim.Object:extend()

function CraftSim.ReagentItem:new(itemID, qualityID)
    self.qualityID = qualityID
    self.quantity = 0
    self.item = Item:CreateFromItemID(itemID)
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