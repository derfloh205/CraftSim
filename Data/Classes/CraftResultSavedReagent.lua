_, CraftSim = ...

---@class CraftSim.CraftResultSavedReagent
---@field item ItemMixin
---@field qualityID number
---@field quantity number
---@field savedCosts number

CraftSim.CraftResultSavedReagent = CraftSim.Object:extend()

function CraftSim.CraftResultSavedReagent:new(recipeData, itemID, quantity)
    self.item = Item:CreateFromItemID(itemID)
    self.quantity = quantity
    self.savedCosts = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true) * self.quantity
    self.qualityID = recipeData.reagentData:GetReagentQualityIDByItemID(itemID)
end

function CraftSim.CraftResultSavedReagent:Debug()
    return {
        "Q" .. self.qualityID .. " " .. (self.item:GetItemLink() or self.item:GetItemID()) .. " x " .. self.quantity,
        "Saved Costs: " .. CraftSim.UTIL:FormatMoney(self.savedCosts),
    }
end