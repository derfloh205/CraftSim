---@class CraftSim
local CraftSim = select(2, ...)

--- Base Class for CraftSim Classes
---@class CraftSim.CraftSimObject : CraftSim.Object
CraftSim.CraftSimObject = CraftSim.Object:extend()

function CraftSim.CraftSimObject:new()
end

--- Adds the object to DevTool if DevTool is loaded
---@param label string
function CraftSim.CraftSimObject:DebugInspect(label)
    if DevTool then
        DevTool:AddData(self, label)
    end
end
