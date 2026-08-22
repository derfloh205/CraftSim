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

function CraftSim.FRAME:RestoreModulePositions()
    for _, frame in ipairs(self:GetResettableFrames()) do
        if frame.RestoreSavedConfig then
            frame:RestoreSavedConfig(frame.originalAnchorParent or UIParent)
        end
    end
end

---@return GGUI.Frame[]
function CraftSim.FRAME:GetResettableFrames()
    local seen = {}
    local frames = {}

    local function add(frame)
        if not frame or type(frame) ~= "table" or not frame.ResetPosition then
            return
        end
        if seen[frame] then
            return
        end
        seen[frame] = true
        tinsert(frames, frame)
    end

    for _, frame in pairs(CraftSim.INIT.FRAMES or {}) do
        add(frame)
    end

    for _, module in pairs(CraftSim.MODULES.modules or {}) do
        add(module.frame)
        add(module.frameWO)
    end

    add(CraftSim.CRAFTQ and CraftSim.CRAFTQ.frame)
    add(CraftSim.CRAFTQ and CraftSim.CRAFTQ.patronRewardValuesFrame)
    add(CraftSim.CRAFTQ.EditRecipe and CraftSim.CRAFTQ.EditRecipe.editor)
    add(CraftSim.CRAFT_LOG and CraftSim.CRAFT_LOG.frame)
    add(CraftSim.CRAFT_LOG and CraftSim.CRAFT_LOG.advFrame)
    add(CraftSim.CRAFT_BUFFS and CraftSim.CRAFT_BUFFS.frame)
    add(CraftSim.COOLDOWNS and CraftSim.COOLDOWNS.frame)
    add(CraftSim.CONCENTRATION_TRACKER and CraftSim.CONCENTRATION_TRACKER.frame)
    add(CraftSim.CONCENTRATION_TRACKER and CraftSim.CONCENTRATION_TRACKER.trackerFrame)
    add(CraftSim.CONTROL_PANEL and CraftSim.CONTROL_PANEL.frame)
    add(CraftSim.DEBUG and CraftSim.DEBUG.frame)
    add(CraftSim.PATCH_NOTES and CraftSim.PATCH_NOTES.frame)
    add(CraftSim.SHOPPING and CraftSim.SHOPPING.frame)

    return frames
end

function CraftSim.FRAME:ResetFrames()
    for _, frame in ipairs(self:GetResettableFrames()) do
        Logger:LogDebug(CraftSim.LOCAL:GetText("FRAMES_RESETTING") .. tostring(frame.frameID))
        local ok, err = pcall(function()
            frame:ResetPosition()
        end)
        if not ok then
            Logger:LogDebug("ResetPosition failed for " .. tostring(frame.frameID) .. ": " .. tostring(err))
        end
    end
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
