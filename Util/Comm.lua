---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.COMM : AceAddon
CraftSim.COMM = LibStub("AceAddon-3.0"):NewAddon("CraftSim.COMM", "AceComm-3.0", "AceSerializer-3.0")

CraftSim.COMM.registeredPrefixes = {}

local print = CraftSim.DEBUG:RegisterDebugID("Util.Comm")

local function encodeData(data)
    local serializedData = CraftSim.COMM:Serialize(data)
    local compressedData, compressError = CraftSim.LibCompress:Compress(serializedData)
    local encodedData = CraftSim.LibCompress:GetAddonEncodeTable():Encode(compressedData)
    return encodedData
end

local function decodeData(payload)
    local decodedData = CraftSim.LibCompress:GetAddonEncodeTable():Decode(payload)
    local decompressedData, error = CraftSim.LibCompress:Decompress(decodedData)

    if not decompressedData then
        print("CraftSim COMM Error: " .. tostring(error))
        return
    end

    local success, deserializedData = CraftSim.COMM:Deserialize(decompressedData)

    if not success then
        print("CraftSim COMM Error: Could not deserialize incoming data")
    end

    return deserializedData
end

function CraftSim.COMM:RegisterPrefix(prefix, callback)
    CraftSim.COMM:RegisterComm(prefix)
    CraftSim.COMM.registeredPrefixes[prefix] = callback
end

function CraftSim.COMM:OnCommReceived(prefix, payload)
    print("CraftSim.COMM: Receive " .. tostring(prefix))
    if CraftSim.COMM.registeredPrefixes[prefix] then
        CraftSim.COMM.registeredPrefixes[prefix](decodeData(payload))
    else
        error("CraftSim COMM Error: Prefix not registered: " .. tostring(prefix))
    end
end

function CraftSim.COMM:SendData(prefix, data, channel, target, progressCallback)
    if channel == "WHISPER" and not target then
        print("CraftSim COMM: No target for WHISPER provided")
        return
    end

    local payload = encodeData(data)

    print("CraftSim.COMM: Send " .. tostring(prefix))
    CraftSim.COMM:SendCommMessage(prefix, payload, channel, target, "NORMAL", progressCallback)
end
