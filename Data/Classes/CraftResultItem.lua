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
        "Q" .. self.qualityID .. " " .. self.item:GetItemLink() .. " x " .. self.quantity - self.quantityMulticraft,
    }
    if self.quantityMulticraft > 0 then
        table.insert(debugLines, "Multicraft: " .. self.quantityMulticraft)
    end
    return debugLines 
end