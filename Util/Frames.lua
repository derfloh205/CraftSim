---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.FRAME
CraftSim.FRAME = {}

local GUTIL = CraftSim.GUTIL

CraftSim.FRAME.frames = {}

local Logger = CraftSim.DEBUG:RegisterLogger("Frames")

function CraftSim.FRAME:FormatStatDiffpercentText(statDiff, roundTo, suffix)
    if statDiff == nil then
        statDiff = 0
    end
    local sign = "+"
    if statDiff <= 0 then
        sign = ""
    end
    if suffix == nil then
        suffix = ""
    end
    return sign .. GUTIL:Round(statDiff, roundTo) .. suffix
end

--> in GGUI in gFrame
function CraftSim.FRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

--- Movable windows register themselves via `frameTable = CraftSim.INIT.FRAMES`.
---@param callback fun(frame: GGUI.Frame)
function CraftSim.FRAME:ForEachRegisteredFrame(callback)
    for _, frame in pairs(CraftSim.INIT.FRAMES or {}) do
        if frame and frame.ResetPosition then
            callback(frame)
        end
    end
end

function CraftSim.FRAME:RestoreModulePositions()
    self:ForEachRegisteredFrame(function(frame)
        if frame.RestoreSavedConfig then
            frame:RestoreSavedConfig(frame.originalAnchorParent or UIParent)
        end
    end)
end

function CraftSim.FRAME:ResetFrames()
    self:ForEachRegisteredFrame(function(frame)
        Logger:LogDebug(CraftSim.LOCAL:GetText("FRAMES_RESETTING") .. tostring(frame.frameID))
        local ok, err = pcall(frame.ResetPosition, frame)
        if not ok then
            Logger:LogDebug("ResetPosition failed for " .. tostring(frame.frameID) .. ": " .. tostring(err))
        end
    end)
end

--> in GGUI.Text
---@deprecated
function CraftSim.FRAME:CreateText(text, parent, anchorParent, anchorA, anchorB, anchorX, anchorY, scale, font,
                                   justifyData)
    scale = scale or 1
    font = font or "GameFontHighlight"

    local craftSimText = parent:CreateFontString(nil, "OVERLAY", font)
    craftSimText:SetText(text)
    craftSimText:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
    craftSimText:SetScale(scale)

    if justifyData then
        if justifyData.type == "V" then
            -- retroactive compatible fix for 10.2.7
            justifyData.value = justifyData.value == "CENTER" and "MIDDLE" or justifyData.value
            craftSimText:SetJustifyV(justifyData.value)
        elseif justifyData.type == "H" then
            craftSimText:SetJustifyH(justifyData.value)
        elseif justifyData.type == "HV" then
            craftSimText:SetJustifyH(justifyData.valueH)
            justifyData.valueV = justifyData.valueV == "CENTER" and "MIDDLE" or justifyData.valueV
            craftSimText:SetJustifyV(justifyData.valueV)
        end
    end

    return craftSimText
end

--> in GGUI.TextInput
---@deprecated
function CraftSim.FRAME:CreateInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY,
                                    initialValue, onTextChangedCallback)
    local numericInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    numericInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    numericInput:SetSize(sizeX, sizeY)
    numericInput:SetAutoFocus(false) -- dont automatically focus
    numericInput:SetFontObject("ChatFontNormal")
    numericInput:SetText(initialValue)
    numericInput:SetScript("OnEscapePressed", function() numericInput:ClearFocus() end)
    numericInput:SetScript("OnEnterPressed", function() numericInput:ClearFocus() end)
    if onTextChangedCallback then
        numericInput:SetScript("OnTextChanged", onTextChangedCallback)
    end

    return numericInput
end
