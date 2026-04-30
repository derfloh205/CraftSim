---@class CraftSim
local CraftSim = select(2, ...)

--- Player-scoped precraft inputs (class, shapeshift, identity), refreshed once per queue evaluation pass.
--- Same lifecycle pattern as CraftSim.ProfessionStats: build shared state once, then many consumers read it.
---@class CraftSim.PrecraftUserConditions : CraftSim.PrecraftConditionSet
CraftSim.PrecraftUserConditions = CraftSim.PrecraftConditionSet:extend()

function CraftSim.PrecraftUserConditions:new()
    CraftSim.PrecraftConditionSet.new(self)
    ---@type CraftSim.PrecraftUserContext
    self.context = CraftSim.PrecraftUserContext()
end

---@param force? boolean
function CraftSim.PrecraftUserConditions:Refresh(force)
    self.context:Refresh(force)
end

---@return CraftSim.PrecraftUserContext
function CraftSim.PrecraftUserConditions:GetContext()
    return self.context
end
