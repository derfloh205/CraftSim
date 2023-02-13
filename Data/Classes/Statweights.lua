_, CraftSim = ...

---@class CraftSim.Statweights
---@field averageProfit number
---@field inspirationWeight number
---@field multicraftWeight number
---@field resourcefulnessWeight number

CraftSim.Statweights = CraftSim.Object:extend()

function CraftSim.Statweights:new(averageProfit, inspirationWeight, multicraftWeight, resourcefulnessWeight)
    self.averageProfit = averageProfit
    self.inspirationWeight = inspirationWeight
    self.multicraftWeight = multicraftWeight
    self.resourcefulnessWeight = resourcefulnessWeight
end