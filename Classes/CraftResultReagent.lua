---@class CraftSim
local CraftSim = select(2, ...)


---@class CraftSim.CraftResultReagent : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, itemID: ItemID, quantity: number, isOrderReagent: boolean?) : CraftSim.CraftResultReagent
CraftSim.CraftResultReagent = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param itemID number
---@param quantity number
---@param isOrderReagent boolean?
function CraftSim.CraftResultReagent:new(recipeData, itemID, quantity, isOrderReagent)
    isOrderReagent = isOrderReagent or false
    if not recipeData then return end
    self.isOrderReagent = isOrderReagent
    self.item = Item:CreateFromItemID(itemID)
    self.quantity = quantity
    self.costs = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true) * self.quantity
    self.qualityID = recipeData.reagentData:GetReagentQualityIDByItemID(itemID)
end

---@return CraftSim.CraftResultReagent
function CraftSim.CraftResultReagent:Copy()
    local copy = CraftSim.CraftResultReagent()
    copy.item = self.item
    copy.isOrderReagent = self.isOrderReagent
    copy.quantity = self.quantity
    copy.costs = self.costs
    copy.qualityID = self.qualityID
    return copy
end

function CraftSim.CraftResultReagent:Debug()
    return {
        "Q" .. self.qualityID .. " " .. (self.item:GetItemLink() or self.item:GetItemID()) .. " x " .. self.quantity,
        "Costs: " .. CraftSim.UTIL:FormatMoney(self.costs),
    }
end

function CraftSim.CraftResultReagent:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    jb:Add("itemID", self.item:GetItemID())
    jb:Add("itemString", CraftSim.GUTIL:GetItemStringFromLink(self.item:GetItemLink() or ""))
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("costs", self.costs, true)
    jb:End()
    return jb.json
end
