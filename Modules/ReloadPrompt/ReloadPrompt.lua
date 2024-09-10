---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.RELOAD_PROMPT
CraftSim.RELOAD_PROMPT = {}

---@class CraftSim.RELOAD_PROMPT.FRAME : GGUI.Frame
CraftSim.RELOAD_PROMPT.frame = nil

function CraftSim.RELOAD_PROMPT:ReloadPrompt()
    CraftSim.RELOAD_PROMPT.frame:Show();
end