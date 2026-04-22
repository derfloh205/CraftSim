---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.PATCH_NOTES : CraftSim.Module
CraftSim.PATCH_NOTES = CraftSim.PATCH_NOTES

---@class CraftSim.PATCH_NOTES.UI : CraftSim.Module.UI
CraftSim.PATCH_NOTES.UI = {}

---@class CraftSim.PATCH_NOTES.FRAME : GGUI.Frame
CraftSim.PATCH_NOTES.frame = nil

function CraftSim.PATCH_NOTES.UI:Init()
    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")

    ---@class CraftSim.PATCH_NOTES.FRAME : GGUI.Frame
    local frame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = 500,
        sizeY = 300,
        closeable = true,
        scrollableContent = true,
        moveable = true,
        title = GUTIL:ColorizeText(
            L("PATCH_NOTES_TITLE") .. " " .. currentVersion,
            GUTIL.COLORS.GREEN),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = "FULLSCREEN",
    })

    CraftSim.PATCH_NOTES.frame = frame

    frame.content.discordBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", -120, -20, 200, 30, CraftSim.CONST.DISCORD_INVITE_URL,
        function()
            frame.content.discordBox:SetText(CraftSim.CONST.DISCORD_INVITE_URL)
        end)
    frame.content.discordBox:SetScale(0.75)
    frame.content.discordBoxLabel = CraftSim.FRAME:CreateText(
        L("FRAMES_JOIN_DISCORD"), frame.content, frame.content.discordBox,
        "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.donateBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", 120, -20, 250, 30, CraftSim.CONST.KOFI_URL, function()
            frame.content.donateBox:SetText(CraftSim.CONST.KOFI_URL)
        end)
    frame.content.donateBox:SetScale(0.75)
    frame.content.donateBoxLabel = CraftSim.FRAME:CreateText(
        f.patreon(L("FRAMES_DONATE_KOFI")), frame.content, frame.content.donateBox,
        "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.infoText:SetPoint("TOP", frame.content, "TOP", 10, -45)
    frame.content.infoText:SetText(L("FRAMES_NO_INFO"))
    frame.content.infoText:SetJustifyH("LEFT")

    frame.showInfo = function(infoText)
        frame.content.infoText:SetText(infoText)
        frame:Show()
    end

    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
    frame:Hide()

    if CraftSim.DB.OPTIONS:Get("SHOW_NEWS") then
        CraftSim.PATCH_NOTES:ShowPatchNotes(false)
    end
end

function CraftSim.PATCH_NOTES.UI:Update()

end
