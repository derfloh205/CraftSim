_, CraftSim = ...

---@class CraftSim.CraftResultItem
---@field item ItemMixin
---@field qualityID number
---@field quantity number
---@field quantityMulticraft number

CraftSim.CraftResultItem = CraftSim.Object:extend()

---@param itemLink string   
---@param quantity number
---@param quantityMulticraft number
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
    jb:Add("itemString", CraftSim.UTIL:GetItemStringFromLink(self.item:GetItemLink()))
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("quantityMulticraft", self.quantityMulticraft, true)
    jb:End()
    return jb.json
end