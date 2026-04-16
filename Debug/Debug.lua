---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DEBUG
CraftSim.DEBUG = {}

---@type table<string, number>
CraftSim.DEBUG.profilings = {}
CraftSim.DEBUG.isMute = false

---@type LibLog-1.0.Logger[]
CraftSim.DEBUG.registeredLogger = {}

---@class CraftSim.DEBUG.FRAME
CraftSim.DEBUG.frame = nil

local GUTIL = CraftSim.GUTIL
local LibLog = CraftSim.LibLog

local systemPrint = print

---@param loggerID string
---@return LibLog-1.0.Logger
function CraftSim.DEBUG:RegisterLogger(loggerID)
    local newLogger = { name = loggerID }
    CraftSim.LibLog:Embed(newLogger)
    table.insert(self.registeredLogger, newLogger)
    return newLogger
end

local profiling = CraftSim.DEBUG:RegisterLogger("CraftSim Profiling")

---@return string[]
---@deprecated
function CraftSim.DEBUG:GetRegisteredLoggerIDs()
    return GUTIL:Map(self.registeredLogger, function(logger)
        return logger.name
    end)
end

function CraftSim.DEBUG:SystemPrint(text)
    print(text)
end

---@param t table
---@param label string?
---@param openDevTool boolean?
function CraftSim.DEBUG:InspectTable(t, label, openDevTool)
    if DevTool then
        if openDevTool then
            DevTool.MainWindow:Show()
        end
        DevTool:AddData(t, label)
    end
end

function CraftSim.DEBUG:ProfilingUpdate(label)
    local print = CraftSim.DEBUG:RegisterLogger("Profiling")
    local time = debugprofilestop()
    local diff = time - CraftSim.DEBUG.profilings[label]
    print:LogDebug("{label}: {diff} ms (u)", label, CraftSim.GUTIL:Round(diff))
end

---@param label string
function CraftSim.DEBUG:StartProfiling(label)
    local time = debugprofilestop();
    CraftSim.DEBUG.profilings[label] = time
end

---@param label string
---@return number milliseconds since StartProfiling was called
function CraftSim.DEBUG:StopProfiling(label)
    local startTime = CraftSim.DEBUG.profilings[label]
    if not startTime then
        profiling:LogError("Util Profiling Label not found on Stop: {label}", label)
        return 0
    end
    local time = debugprofilestop()
    local diff = CraftSim.GUTIL:Round(time - startTime)
    CraftSim.DEBUG.profilings[label] = nil
    profiling:LogDebug("{label}: {diff} ms", label, diff)
    return diff
end

---@deprecated
function CraftSim.DEBUG:DisableAllLogIDs()
    local debugIDs = self:GetRegisteredLoggerIDs()
    local debugIDsDB = CraftSim.DB.OPTIONS:Get("DEBUG_IDS")
    for _, debugID in ipairs(debugIDs) do
        debugIDsDB[debugID] = false
    end
    CraftSim.DB.OPTIONS:Save("DEBUG_IDS", debugIDsDB)
end
