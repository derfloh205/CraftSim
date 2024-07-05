---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.Statweights : CraftSim.CraftSimObject
CraftSim.Statweights = CraftSim.CraftSimObject:extend()

---@param averageProfit number
---@param multicraftWeight number
---@param resourcefulnessWeight number
function CraftSim.Statweights:new(averageProfit, multicraftWeight, resourcefulnessWeight)
    self.averageProfit = averageProfit
    self.multicraftWeight = multicraftWeight
    self.resourcefulnessWeight = resourcefulnessWeight
end
