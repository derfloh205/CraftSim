---@class CraftSim
local CraftSim = select(2, ...)


---@class CraftSim.CraftResultSavedReagent : CraftSim.CraftSimObject
CraftSim.CraftResultSavedReagent = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param itemID number
---@param quantity number
function CraftSim.CraftResultSavedReagent:new(recipeData, itemID, quantity)
    if not recipeData then return end

    self.item = Item:CreateFromItemID(itemID)
    self.quantity = quantity
    self.savedCosts = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true) * self.quantity
    self.qualityID = recipeData.reagentData:GetReagentQualityIDByItemID(itemID)
end

function CraftSim.CraftResultSavedReagent:Copy()
    local copy = CraftSim.CraftResultSavedReagent()
    copy.item = self.item
    copy.quantity = self.quantity
    copy.savedCosts = self.savedCosts
    copy.qualityID = self.qualityID
end

function CraftSim.CraftResultSavedReagent:Debug()
    return {
        "Q" .. self.qualityID .. " " .. (self.item:GetItemLink() or self.item:GetItemID()) .. " x " .. self.quantity,
        "Saved Costs: " .. CraftSim.UTIL:FormatMoney(self.savedCosts),
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
