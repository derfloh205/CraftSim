CraftSimAccountSync = LibStub("AceAddon-3.0"):NewAddon("CraftSimAccountSync", "AceComm-3.0", "AceSerializer-3.0")
local TOOLTIP_SYNC_PREFIX = "CSTooltipSync"
local OPTIONS_SYNC_PREFIX = "CSOptionsSync"

function CraftSimAccountSync:HandleTooltipSync(data)
    -- append/replace data
    for index, entry in pairs(data) do
        CraftSimTooltipData[index] = entry
    end

    print("CraftSim AccountSync: Tooltip Data updated!")
end

function CraftSimAccountSync:HandleOptionsSync(data)
    print("CraftSim AccountSync: Options updated!")
    CraftSimOptions = data
end

function CraftSimAccountSync:OnCommReceived(prefix, payload)
    local dialog = StaticPopup_Show("CRAFT_SIM_ACCEPT_TOOLTIP_SYNC")     -- dialog contains the frame object
    if (dialog) then
        dialog.data  = prefix                        -- set the frame's data field to the value you want
        dialog.data2 = payload
    end
end

function CraftSimAccountSync:HandleIncomingSync(prefix, payload)
    local decodedData = LibCompress:GetAddonEncodeTable():Decode(payload)
    local decompressedData, error = LibCompress:Decompress(decodedData)

    if not decompressedData then
        print("CraftSim AccountSync Error: " .. tostring(error))
        return
    end

    local success, deserializedData = CraftSimAccountSync:Deserialize(decompressedData)

    if not success then
        print("CraftSim AccountSync Error: Could not deserialize incoming data")
    end
    print("CraftSim AccountSync: Data Received")

    if prefix == TOOLTIP_SYNC_PREFIX then
        CraftSimAccountSync:HandleTooltipSync(deserializedData)
    elseif prefix == OPTIONS_SYNC_PREFIX then
        CraftSimAccountSync:HandleOptionsSync(deserializedData)
    end
end

function CraftSimAccountSync:Init()
    CraftSimAccountSync:RegisterComm(TOOLTIP_SYNC_PREFIX)
    CraftSimAccountSync:RegisterComm(OPTIONS_SYNC_PREFIX)

    StaticPopupDialogs["CRAFT_SIM_ACCEPT_TOOLTIP_SYNC"] = {
        text = "Incoming Craft Sim Account Sync: Do you accept?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function(self, data1, data2)
            CraftSimAccountSync:HandleIncomingSync(data1, data2)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
      }
end

function CraftSimAccountSync:SynchronizeAccounts()
    local target = CraftSimOptions.syncTarget
    CraftSimAccountSync:SendData(TOOLTIP_SYNC_PREFIX, CraftSimTooltipData, target)
end

function CraftSimAccountSync:SynchronizeOptions()
    local target = CraftSimOptions.syncTarget
    CraftSimAccountSync:SendData(OPTIONS_SYNC_PREFIX, CraftSimOptions, target)
end

function CraftSimAccountSync:SendData(prefix, data, target)
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
    local payload = CraftSimAccountSync:DigestDataForSync(data)

    CraftSimAccountSync:SendCommMessage(prefix, payload, "WHISPER", target, "NORMAL", function(arg1, arg2, arg3) 
        local percent = arg2 / (arg3 / 100)
        if percent % 10 > 1 then
            return
        end
        local percentProgress = CraftSimUTIL:round(percent, 0)
        if tonumber(percentProgress) < 100 then
            CraftSimAccountSyncSendingProgress:SetText("Sending.. " .. tostring(CraftSimUTIL:round(percent, 0)) .. "%")
        else
            CraftSimAccountSyncSendingProgress:SetText("Sync Finished!")
        end
    end)
end

function CraftSimAccountSync:DigestDataForSync(data)
    local serializedData = CraftSimAccountSync:Serialize(data)
	local compressedData, compressError = LibCompress:Compress(serializedData)
	local encodedData = LibCompress:GetAddonEncodeTable():Encode(compressedData)
	return encodedData
end

function CraftSimAccountSync:RecoverDataAfterSync(payload)
    local decodedData = LibCompress:GetAddonEncodeTable():Decode(payload)
    local decompressedData, error = LibCompress:Decompress(decodedData)

    if not decompressedData then
        print("CraftSim AccountSync Error: " .. tostring(error))
        return
    end

    local success, deserializedData = CraftSimAccountSync:Deserialize(decompressedData)

    if not success then
        print("CraftSim AccountSync Error: Could not deserialize incoming data")
    end

    return deserializedData
end

