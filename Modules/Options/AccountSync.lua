AddonName, CraftSim = ...

CraftSim.ACCOUNTSYNC = {}
local TOOLTIP_SYNC_PREFIX = "CSTooltipSync"
local OPTIONS_SYNC_PREFIX = "CSOptionsSync"

function CraftSim.ACCOUNTSYNC:HandleTooltipSync(data)
    -- append/replace data
    for index, entry in pairs(data) do
        CraftSimTooltipData[index] = entry
    end

    print("CraftSim AccountSync: Tooltip Data updated!")
end

function CraftSim.ACCOUNTSYNC:HandleOptionsSync(data)
    print("CraftSim AccountSync: Options updated!")
    CraftSimOptions = data
end

function CraftSim.ACCOUNTSYNC:Init()
    CraftSim.COMM:RegisterPrefix(TOOLTIP_SYNC_PREFIX, CraftSim.ACCOUNTSYNC.HandleTooltipSync)
    CraftSim.COMM:RegisterPrefix(OPTIONS_SYNC_PREFIX, CraftSim.ACCOUNTSYNC.HandleOptionsSync)
end

function CraftSim.ACCOUNTSYNC:UpdateSendingProgress(arg1, arg2, arg3)
    local percent = arg2 / (arg3 / 100)
    if percent % 10 > 1 then
        return
    end
    local percentProgress = CraftSim.UTIL:round(percent, 0)
    if tonumber(percentProgress) < 100 then
        CraftSimACCOUNTSYNCSendingProgress:SetText("Sending.. " .. tostring(CraftSim.UTIL:round(percent, 0)) .. "%")
    else
        CraftSimACCOUNTSYNCSendingProgress:SetText("Sync Finished!")
    end
end

function CraftSim.ACCOUNTSYNC:SynchronizeAccounts()
    local target = CraftSimOptions.syncTarget
    CraftSim.COMM:SendData(TOOLTIP_SYNC_PREFIX, CraftSimTooltipData, "WHISPER", target, CraftSim.ACCOUNTSYNC.UpdateSendingProgress)
end

function CraftSim.ACCOUNTSYNC:SynchronizeOptions()
    local target = CraftSimOptions.syncTarget
    CraftSim.COMM:SendData(OPTIONS_SYNC_PREFIX, CraftSimOptions, "WHISPER", target, CraftSim.ACCOUNTSYNC.UpdateSendingProgress)
end

