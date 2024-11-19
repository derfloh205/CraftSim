---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.DEBUG
CraftSim.DEBUG = {}

---@type table<string, number>
CraftSim.DEBUG.profilings = {}
CraftSim.DEBUG.isMute = false
CraftSim.DEBUG.registeredDebugIDs = {}

---@class CraftSim.DEBUG.FRAME
CraftSim.DEBUG.frame = nil

local GUTIL = CraftSim.GUTIL

local systemPrint = print

---@param debugID string Format: Category.(...).ID
---@return fun(text: string, recursiveTablePrint: boolean?, printLabel: boolean?, intent: number?)
function CraftSim.DEBUG:RegisterDebugID(debugID)
    -- check for each subID
    local splitIDs = strsplittable(".", debugID)
    local fullID = ""
    for i, splitID in ipairs(splitIDs) do
        if i == 1 then
            fullID = splitID
        else
            fullID = string.format("%s.%s", fullID, splitID)
        end
        if not tContains(self.registeredDebugIDs, fullID) then
            tinsert(self.registeredDebugIDs, fullID)
        end
    end
    local function print(text, recursive, l, level)
        if CraftSim.DEBUG and CraftSim.DEBUG.frame then
            CraftSim.DEBUG:print(text, debugID, recursive, l, level)
        else
            systemPrint(text)
        end
    end

    return print
end

---@return string[]
function CraftSim.DEBUG:GetRegisteredDebugIDs()
    return self.registeredDebugIDs
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

function CraftSim.DEBUG:print(debugOutput, debugID, recursive, printLabel, level)
    local debugIDsDB = CraftSim.DB.OPTIONS:Get("DEBUG_IDS")
    if debugIDsDB[debugID] and not CraftSim.DEBUG.isMute then
        if type(debugOutput) == "table" then
            CraftSim.DEBUG:PrintTable(debugOutput, debugID, recursive, level)
        else
            local debugFrame = CraftSim.GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG)
            debugFrame.addDebug(debugOutput, debugID, printLabel)
        end
    end
end

-- for debug purposes
function CraftSim.DEBUG:PrintTable(t, debugID, recursive, level)
    level = level or 0
    local levelString = ""
    for i = 1, level, 1 do
        levelString = levelString .. "-"
    end

    if t.Debug then
        for _, line in pairs(t:Debug()) do
            CraftSim.DEBUG:print(levelString .. tostring(line), debugID, false)
        end
        return
    end

    for k, v in pairs(t) do
        if type(v) == 'function' then
            CraftSim.DEBUG:print(levelString .. tostring(k) .. ": function", debugID, false)
        elseif not recursive or type(v) ~= "table" then
            CraftSim.DEBUG:print(levelString .. tostring(k) .. ": " .. tostring(v), debugID, false)
        elseif type(v) == "table" then
            CraftSim.DEBUG:print(levelString .. tostring(k) .. ": ", debugID, false)
            CraftSim.DEBUG:PrintTable(v, debugID, recursive, level + 1)
        end
    end
end

function CraftSim.DEBUG:ProfilingUpdate(label)
    local print = CraftSim.DEBUG:RegisterDebugID("Profiling")
    local time = debugprofilestop()
    local diff = time - CraftSim.DEBUG.profilings[label]
    print(label .. ": " .. CraftSim.GUTIL:Round(diff) .. " ms (u)")
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
        print("Util Profiling Label not found on Stop: " .. tostring(label))
        return 0
    end
    local time = debugprofilestop()
    local diff = CraftSim.GUTIL:Round(time - startTime)
    CraftSim.DEBUG.profilings[label] = nil
    CraftSim.DEBUG:print(label .. ": " .. diff .. " ms", "Profiling")
    return diff
end

---@deprecated
function CraftSim.DEBUG:GetCacheGlobalsList()
    return {
    }
end

function CraftSim.DEBUG:ShowOutdatedSpecNodes()
    local specializationData = CraftSim.INIT.currentRecipeData.specializationData
    if not specializationData then return end

    local sortedNodes = GUTIL:Sort(specializationData.nodeData, function(a, b)
        if a.name > b.name then
            return true
        elseif a.name < b.name then
            return false
        end

        return a.nodeID < b.nodeID
    end)

    ---@type CraftSim.NodeData[]
    local outliers = {}

    for i = 1, #sortedNodes do
        local nodeData = sortedNodes[i]
        local nextData = sortedNodes[i + 1]
        if nodeData and nextData then
            if nodeData.name == nextData.name then
                tinsert(outliers, nodeData)
            end
        end
    end

    if #outliers == 0 then return end

    local currentName = outliers[1].name
    local text = "## " .. currentName .. "\n"

    for _, nodeData in ipairs(outliers) do
        if currentName ~= nodeData.name then
            text = text .. "\n## " .. nodeData.name .. "\n"
            currentName = nodeData.name
        end
        text = text .. nodeData.nodeID .. ", "
    end

    CraftSim.UTIL:ShowTextCopyBox(text)
end
