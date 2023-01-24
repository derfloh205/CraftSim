AddonName, CraftSim = ...

CraftSim.ACCOUNTSYNC = LibStub("AceAddon-3.0"):NewAddon("CraftSim.ACCOUNTSYNC", "AceComm-3.0", "AceSerializer-3.0")
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

function CraftSim.ACCOUNTSYNC:OnCommReceived(prefix, payload)
    local dialog = StaticPopup_Show("CRAFT_SIM_ACCEPT_TOOLTIP_SYNC")     -- dialog contains the frame object
    if (dialog) then
        dialog.data  = prefix                        -- set the frame's data field to the value you want
        dialog.data2 = payload
    end
end

function CraftSim.ACCOUNTSYNC:HandleIncomingSync(prefix, payload)
    local decodedData = LibCompress:GetAddonEncodeTable():Decode(payload)
    local decompressedData, error = LibCompress:Decompress(decodedData)

    if not decompressedData then
        print("CraftSim AccountSync Error: " .. tostring(error))
        return
    end

    local success, deserializedData = CraftSim.ACCOUNTSYNC:Deserialize(decompressedData)

    if not success then
        print("CraftSim AccountSync Error: Could not deserialize incoming data")
    end
    print("CraftSim AccountSync: Data Received")

    if prefix == TOOLTIP_SYNC_PREFIX then
        CraftSim.ACCOUNTSYNC:HandleTooltipSync(deserializedData)
    elseif prefix == OPTIONS_SYNC_PREFIX then
        CraftSim.ACCOUNTSYNC:HandleOptionsSync(deserializedData)
    end
end

function CraftSim.ACCOUNTSYNC:Init()
    CraftSim.ACCOUNTSYNC:RegisterComm(TOOLTIP_SYNC_PREFIX)
    CraftSim.ACCOUNTSYNC:RegisterComm(OPTIONS_SYNC_PREFIX)
end

function CraftSim.ACCOUNTSYNC:SynchronizeAccounts()
    local target = CraftSimOptions.syncTarget
    CraftSim.ACCOUNTSYNC:SendData(TOOLTIP_SYNC_PREFIX, CraftSimTooltipData, target)
end

function CraftSim.ACCOUNTSYNC:SynchronizeOptions()
    local target = CraftSimOptions.syncTarget
    CraftSim.ACCOUNTSYNC:SendData(OPTIONS_SYNC_PREFIX, CraftSimOptions, target)
end

function CraftSim.ACCOUNTSYNC:SendData(prefix, data, target)
    if not target then
        return
    end
    local isOnline = false
    -- set target as friend
    C_FriendList.AddFriend(target, "CraftSim AccountSync")
    -- check if online with and without server
    local friendInfo = C_FriendList.GetFriendInfo(target)
    if not friendInfo then
        targetNoServer = strsplit("-", target)[1] -- remove server name
        friendInfo = C_FriendList.GetFriendInfo(targetNoServer)
    end

    if not friendInfo or not friendInfo.connected then
        print("CraftSim AccountSync: Character not online (" .. tostring(target) .. ")")
        return
    end
    local payload = CraftSim.ACCOUNTSYNC:DigestDataForSync(data)

    CraftSim.ACCOUNTSYNC:SendCommMessage(prefix, payload, "WHISPER", target, "NORMAL", function(arg1, arg2, arg3) 
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
    end)
end

function CraftSim.ACCOUNTSYNC:DigestDataForSync(data)
    local serializedData = CraftSim.ACCOUNTSYNC:Serialize(data)
	local compressedData, compressError = LibCompress:Compress(serializedData)
	local encodedData = LibCompress:GetAddonEncodeTable():Encode(compressedData)
	return encodedData
end

function CraftSim.ACCOUNTSYNC:RecoverDataAfterSync(payload)
    local decodedData = LibCompress:GetAddonEncodeTable():Decode(payload)
    local decompressedData, error = LibCompress:Decompress(decodedData)

    if not decompressedData then
        print("CraftSim AccountSync Error: " .. tostring(error))
        return
    end

    local success, deserializedData = CraftSim.ACCOUNTSYNC:Deserialize(decompressedData)

    if not success then
        print("CraftSim AccountSync Error: Could not deserialize incoming data")
    end

    return deserializedData
end

