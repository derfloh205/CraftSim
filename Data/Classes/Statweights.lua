---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.Statweights : CraftSim.CraftSimObject
CraftSim.Statweights = CraftSim.CraftSimObject:extend()

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
