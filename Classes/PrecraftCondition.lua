---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.PrecraftCondition.Options
---@field id string
---@field priority number
---@field blocksCraft boolean
---@field blocksClaim boolean
---@field evaluate fun(self: CraftSim.PrecraftCondition, craftQueueItem: CraftSim.CraftQueueItem)

--- One queue precraft gate, similar in spirit to CraftSim.ProfessionStat: fixed identity,
--- mutable evaluated state (`isMet`, `reason`) refreshed from a CraftQueueItem.
---@class CraftSim.PrecraftCondition : CraftSim.CraftSimObject
---@overload fun(options: CraftSim.PrecraftCondition.Options): CraftSim.PrecraftCondition
CraftSim.PrecraftCondition = CraftSim.CraftSimObject:extend()

---@param options CraftSim.PrecraftCondition.Options
function CraftSim.PrecraftCondition:new(options)
    self.id = options.id
    self.priority = options.priority
    self.blocksCraft = options.blocksCraft
    self.blocksClaim = options.blocksClaim
    ---@type fun(self: CraftSim.PrecraftCondition, craftQueueItem: CraftSim.CraftQueueItem)
    self.evaluateHandler = options.evaluate
    self.isMet = false
    self.reason = nil
end

--- Recompute `isMet` / `reason` from the given queue row (like ProfessionStat values updated from recipe context).
---@param craftQueueItem CraftSim.CraftQueueItem
function CraftSim.PrecraftCondition:Evaluate(craftQueueItem)
    self.evaluateHandler(self, craftQueueItem)
end
