---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.TOOLTIP = {}

local hooked = false
function CraftSim.TOOLTIP:Init()
    if hooked then
        return
    end
    hooked = true
end
