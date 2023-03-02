_, CraftSim = ...


---@class CraftSim.CraftResultSavedReagent
CraftSim.CraftResultSavedReagent = CraftSim.Object:extend()

---@param recipeData CraftSim.RecipeData
---@param itemID number
---@param quantity number
function CraftSim.CraftResultSavedReagent:new(recipeData, itemID, quantity)
    self.item = Item:CreateFromItemID(itemID)
    self.quantity = quantity
    self.savedCosts = CraftSim.PRICEDATA:GetMinBuyoutByItemID(itemID, true) * self.quantity
    self.qualityID = recipeData.reagentData:GetReagentQualityIDByItemID(itemID)
end

function CraftSim.CraftResultSavedReagent:Debug()
    return {
        "Q" .. self.qualityID .. " " .. (self.item:GetItemLink() or self.item:GetItemID()) .. " x " .. self.quantity,
        "Saved Costs: " .. CraftSim.GUTIL:FormatMoney(self.savedCosts),
    }
end

function CraftSim.CraftResultSavedReagent:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("itemID", self.item:GetItemID())
    jb:Add("itemString", CraftSim.GUTIL:GetItemStringFromLink(self.item:GetItemLink() or ""))
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("savedCosts", self.savedCosts, true)
    jb:End()
    return jb.json
end