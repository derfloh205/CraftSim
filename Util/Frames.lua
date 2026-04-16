---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.FRAME
CraftSim.FRAME = {}

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.FRAME.frames = {}

local print = CraftSim.DEBUG:RegisterLogger("Util.Frames")

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

function CraftSim.FRAME:ResetFrames()
    for _, frame in pairs(CraftSim.INIT.FRAMES) do
        print(CraftSim.LOCAL:GetText("FRAMES_RESETTING") .. tostring(frame.frameID))
        frame:ResetPosition()
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

function CraftSim.FRAME:InitNewsUI()
    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")

    local f = GUTIL:GetFormatter()

    local frame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = 500,
        sizeY = 300,
        closeable = true,
        scrollableContent = true,
        moveable = true,
        title = GUTIL:ColorizeText(
            CraftSim.LOCAL:GetText("FRAMES_WHATS_NEW") .. " (" .. currentVersion .. ")",
            GUTIL.COLORS.GREEN),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = "FULLSCREEN",
    })

    frame.content.discordBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", -120, -20, 200, 30, CraftSim.CONST.DISCORD_INVITE_URL,
        function()
            -- do not let the player remove the link
            frame.content.discordBox:SetText(CraftSim.CONST.DISCORD_INVITE_URL)
        end)
    frame.content.discordBox:SetScale(0.75)
    frame.content.discordBoxLabel = CraftSim.FRAME:CreateText(
        CraftSim.LOCAL:GetText("FRAMES_JOIN_DISCORD"), frame.content, frame.content.discordBox,
        "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.donateBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", 120, -20, 250, 30, CraftSim.CONST.KOFI_URL, function()
            -- do not let the player remove the link
            frame.content.donateBox:SetText(CraftSim.CONST.KOFI_URL)
        end)
    frame.content.donateBox:SetScale(0.75)
    frame.content.donateBoxLabel = CraftSim.FRAME:CreateText(
        f.patreon(CraftSim.LOCAL:GetText("FRAMES_DONATE_KOFI")), frame.content, frame.content
        .donateBox, "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.infoText:SetPoint("TOP", frame.content, "TOP", 10, -45)
    frame.content.infoText:SetText(CraftSim.LOCAL:GetText("FRAMES_NO_INFO"))
    frame.content.infoText:SetJustifyH("LEFT")

    frame.showInfo = function(infoText)
        frame.content.infoText:SetText(infoText)
        frame:Show()
    end

    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
    frame:Hide()
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
