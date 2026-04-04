---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.Statweights : CraftSim.CraftSimObject
CraftSim.Statweights = CraftSim.CraftSimObject:extend()

---@param averageProfit number
---@param multicraftWeight number
---@param resourcefulnessWeight number
---@param concentrationWeight number
function CraftSim.Statweights:new(averageProfit, multicraftWeight, resourcefulnessWeight, concentrationWeight)
    self.averageProfit = averageProfit
    self.multicraftWeight = multicraftWeight
    self.resourcefulnessWeight = resourcefulnessWeight
    self.concentrationWeight = concentrationWeight
end
