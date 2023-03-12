_, CraftSim = ...

---@class CraftSim.Statweights
CraftSim.Statweights = CraftSim.Object:extend()

---@param averageProfit number
---@param inspirationWeight number
---@param multicraftWeight number
---@param resourcefulnessWeight number
function CraftSim.Statweights:new(averageProfit, inspirationWeight, multicraftWeight, resourcefulnessWeight)
    self.averageProfit = averageProfit
    self.inspirationWeight = inspirationWeight
    self.multicraftWeight = multicraftWeight
    self.resourcefulnessWeight = resourcefulnessWeight
end