---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.CraftResultItem : CraftSim.CraftSimObject
CraftSim.CraftResultItem = CraftSim.CraftSimObject:extend()

---@param itemLink string
---@param quantity number
---@param quantityMulticraft number
---@param qualityID number?
function CraftSim.CraftResultItem:new(itemLink, quantity, quantityMulticraft, qualityID)
    self.qualityID = qualityID
    self.item = Item:CreateFromItemLink(itemLink)
    self.quantity = quantity - quantityMulticraft
    self.quantityMulticraft = quantityMulticraft
end

function CraftSim.CraftResultItem:Debug()
    local debugLines = {
        "Q" .. tostring(self.qualityID) .. " " .. tostring(self.item:GetItemLink()) .. " x " .. self.quantity,
    }
    if self.quantityMulticraft > 0 then
        table.insert(debugLines, "Multicraft: " .. self.quantityMulticraft)
    end
    return debugLines
end

function CraftSim.CraftResultItem:GetJSON(intent)
    intent = intent or 0
    local jb = CraftSim.JSONBuilder(intent)
    jb:Begin()
    jb:Add("itemID", self.item:GetItemID())
    jb:Add("itemString", CraftSim.GUTIL:GetItemStringFromLink(self.item:GetItemLink()))
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("quantityMulticraft", self.quantityMulticraft, true)
    jb:End()
    return jb.json
end

---@return CraftSim.CraftResultItem
function CraftSim.CraftResultItem:Copy()
    return CraftSim.CraftResultItem(self.item:GetItemLink(), self.quantity, self.quantityMulticraft, self.qualityID)
end
