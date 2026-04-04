---@class CraftSim
local CraftSim = select(2, ...)


---@class CraftSim.CraftResultReagent : CraftSim.CraftSimObject
---@overload fun(recipeData: CraftSim.RecipeData, itemID: ItemID?, quantity: number, isOrderReagent: boolean?, currencyID: number?) : CraftSim.CraftResultReagent
---@overload fun(): CraftSim.CraftResultReagent
CraftSim.CraftResultReagent = CraftSim.CraftSimObject:extend()

---@param recipeData CraftSim.RecipeData
---@param itemID number?
---@param quantity number
---@param isOrderReagent boolean?
---@param currencyID number?
function CraftSim.CraftResultReagent:new(recipeData, itemID, quantity, isOrderReagent, currencyID)
    isOrderReagent = isOrderReagent or false
    if not recipeData then return end
    self.isOrderReagent = isOrderReagent
    self.quantity = quantity

    if currencyID then
        self.currencyID = currencyID
        self.item = nil
        self.costs = 0
        local reagentData = CraftSim.OPTIONAL_CURRENCY_REAGENT_DATA[currencyID]
        self.qualityID = reagentData and reagentData.qualityID or 0
        self.currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        self.currencyName = self.currencyInfo and self.currencyInfo.name
    else
        self.item = Item:CreateFromItemID(itemID)
        self.costs = CraftSim.PRICE_SOURCE:GetMinBuyoutByItemID(itemID, true) * self.quantity
        self.qualityID = recipeData.reagentData:GetReagentQualityIDByItemID(itemID)
    end
end

function CraftSim.CraftResultReagent:IsCurrency()
    return self.currencyID ~= nil
end

---@return CraftSim.CraftResultReagent
function CraftSim.CraftResultReagent:Copy()
    local copy = CraftSim.CraftResultReagent()
    copy.item = self.item
    copy.isOrderReagent = self.isOrderReagent
    copy.quantity = self.quantity
    copy.costs = self.costs
    copy.qualityID = self.qualityID
    copy.currencyID = self.currencyID
    copy.currencyInfo = self.currencyInfo
    copy.currencyName = self.currencyName
    return copy
end

function CraftSim.CraftResultReagent:Debug()
    if self:IsCurrency() then
        return {
            "Q" .. tostring(self.qualityID) .. " Currency:" .. tostring(self.currencyID) .. " (" .. tostring(self.currencyName) .. ") x " .. self.quantity,
            "Costs: " .. CraftSim.UTIL:FormatMoney(self.costs),
        }
    end
    return {
        "Q" .. self.qualityID .. " " .. (self.item:GetItemLink() or self.item:GetItemID()) .. " x " .. self.quantity,
        "Costs: " .. CraftSim.UTIL:FormatMoney(self.costs),
    }
end

function CraftSim.CraftResultReagent:GetJSON(indent)
    indent = indent or 0
    local jb = CraftSim.JSONBuilder(indent)
    jb:Begin()
    if self:IsCurrency() then
        jb:Add("currencyID", self.currencyID)
        jb:Add("currencyName", self.currencyName)
    else
        jb:Add("itemID", self.item:GetItemID())
        jb:Add("itemString", CraftSim.GUTIL:GetItemStringFromLink(self.item:GetItemLink() or ""))
    end
    jb:Add("qualityID", self.qualityID)
    jb:Add("quantity", self.quantity)
    jb:Add("costs", self.costs, true)
    jb:End()
    return jb.json
end
