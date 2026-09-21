---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.LOCAL:GetLocalizer()

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
        frameID = CraftSim.CONST.FRAMES.PATCH_NOTES,
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = "FULLSCREEN",
    })

    CraftSim.PATCH_NOTES.frame = frame

    local function pinUrlBox(editBox, url)
        editBox:SetText(url)
        if editBox.SetCursorPosition then
            editBox:SetCursorPosition(0)
        end
    end

    local TEXT_PAD_X = 8
    local TEXT_OFFSET_Y = -55
    local TEXT_BOTTOM_PAD = 20

    frame.content.discordBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", -120, -20, 200, 30, CraftSim.CONST.DISCORD_INVITE_URL,
        function(_, userInput)
            if userInput then
                pinUrlBox(frame.content.discordBox, CraftSim.CONST.DISCORD_INVITE_URL)
            end
        end)
    frame.content.discordBox:SetScale(0.75)
    pinUrlBox(frame.content.discordBox, CraftSim.CONST.DISCORD_INVITE_URL)
    frame.content.discordBoxLabel = CraftSim.FRAME:CreateText(
        L("FRAMES_JOIN_DISCORD"), frame.content, frame.content.discordBox,
        "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.donateBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", 120, -20, 250, 30, CraftSim.CONST.KOFI_URL,
        function(_, userInput)
            if userInput then
                pinUrlBox(frame.content.donateBox, CraftSim.CONST.KOFI_URL)
            end
        end)
    frame.content.donateBox:SetScale(0.75)
    pinUrlBox(frame.content.donateBox, CraftSim.CONST.KOFI_URL)
    frame.content.donateBoxLabel = CraftSim.FRAME:CreateText(
        f.patreon(L("FRAMES_DONATE_KOFI")), frame.content, frame.content.donateBox,
        "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.infoText:SetPoint("TOPLEFT", frame.content, "TOPLEFT", TEXT_PAD_X, TEXT_OFFSET_Y)
    frame.content.infoText:SetJustifyH("LEFT")
    frame.content.infoText:SetJustifyV("TOP")
    frame.content.infoText:SetWordWrap(true)
    frame.content.infoText:SetNonSpaceWrap(true)
    frame.content.infoText:SetText(L("FRAMES_NO_INFO"))

    local function layoutInfoText()
        local infoText = frame.content.infoText
        local contentWidth = frame.content:GetWidth()
        if not contentWidth or contentWidth <= 1 then
            contentWidth = CraftSim.CONST.infoBoxSizeX - 55
        end
        infoText:SetWidth(math.max(contentWidth - (TEXT_PAD_X * 2), 50))
        local textHeight = infoText:GetStringHeight() or 0
        frame.content:SetHeight(math.max(math.abs(TEXT_OFFSET_Y) + textHeight + TEXT_BOTTOM_PAD, 1))
    end

    layoutInfoText()

    frame.showInfo = function(infoText)
        frame.content.infoText:SetText(infoText)
        layoutInfoText()
        pinUrlBox(frame.content.discordBox, CraftSim.CONST.DISCORD_INVITE_URL)
        pinUrlBox(frame.content.donateBox, CraftSim.CONST.KOFI_URL)
        frame:Show()
        layoutInfoText()
    end

    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
    frame:Hide()

    if CraftSim.DB.OPTIONS:Get("SHOW_NEWS") then
        CraftSim.PATCH_NOTES:ShowPatchNotes(false)
    end
end

function CraftSim.PATCH_NOTES.UI:Update()

end

function CraftSim.PATCH_NOTES.UI:RestoreFrameConfig()
    CraftSim.PATCH_NOTES.frame:RestoreSavedConfig(UIParent)
end
