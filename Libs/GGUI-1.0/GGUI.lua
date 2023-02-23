

local GGUI = LibStub:NewLibrary("GGUI", 1)

GGUI.numFrames = 0
GGUI.frames = {}

if not GGUI then return end

---@param frameID string The ID string you gave the frame
function GGUI:GetFrame(frameID)
    if not GGUI.frames[frameID] then
        error("GGUI Error: Frame not found: " .. frameID)
    end
    return GGUI.frames[frameID]
end

---@class GGUI.createFrameOptions
---@field globalName? string
---@field title? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field frameID? string
---@field scrollableContent? boolean
---@field closeable? boolean
---@field collapseable? boolean
---@field moveable? boolean
---@field frameStrata? FrameStrata
---@field onCloseCallback? function
---@field backdropOptions GGUI.BackdropOptions

---@class GGUI.BackdropOptions
---@field colorR? number
---@field colorG? number
---@field colorB? number
---@field colorA? number
---@field bgFile? string
---@field borderOptions? GGUI.BorderOptions

---@class GGUI.BorderOptions
---@field colorR? number
---@field colorG? number
---@field colorB? number
---@field colorA? number
---@field edgeSize? number
---@field edgeFile? string
---@field insets? backdropInsets

---@param options GGUI.createFrameOptions
function GGUI:CreateFrame(options)
    options = options or {}
    GGUI.numFrames = GGUI.numFrames + 1
    -- handle defaults
    options.title = options.title or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 100
    options.frameID = options.frameID or ("GGUIFrame" .. (GGUI.numFrames))
    options.scrollableContent = options.scrollableContent or false
    options.closeable = options.closeable or false
    options.collapseable = options.collapseable or false
    options.moveable = options.moveable or false
    options.frameStrata = options.frameStrata or "HIGH"

    local hookFrame = CreateFrame("frame", nil, options.parent)
    hookFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    local frame = CreateFrame("frame", options.globalName, hookFrame, "BackdropTemplate")
    frame.hookFrame = hookFrame
    hookFrame:SetSize(options.sizeX, options.sizeY)
    frame:SetSize(options.sizeX, options.sizeY)
    frame:SetFrameStrata(options.frameStrata or "HIGH")
    frame:SetFrameLevel(GGUI.numFrames)

    frame.resetPosition = function() 
        hookFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -15)
	frame.title:SetText(options.title)
    
    frame:SetPoint("TOP",  hookFrame, "TOP", 0, 0)

    if options.backdropOptions then
        local backdropOptions = options.backdropOptions
        backdropOptions.colorR = backdropOptions.colorR or 0
        backdropOptions.colorG = backdropOptions.colorG or 0
        backdropOptions.colorB = backdropOptions.colorB or 0
        backdropOptions.colorA = backdropOptions.colorA or 1
        backdropOptions.bgFile = backdropOptions.bgFile or "Interface\\CharacterFrame\\UI-Party-Background"
        backdropOptions.borderOptions = backdropOptions.borderOptions or {}
        local borderOptions = backdropOptions.borderOptions
        borderOptions.colorR = borderOptions.colorR or 0
        borderOptions.colorG = borderOptions.colorG or 0
        borderOptions.colorB = borderOptions.colorB or 0
        borderOptions.colorA = borderOptions.colorA or 1
        borderOptions.edgeFile = borderOptions.edgeFile or "Interface\\PVPFrame\\UI-Character-PVP-Highlight"
        borderOptions.edgeSize = borderOptions.edgeSize or 0
        frame:SetBackdropColor(backdropOptions.colorR, backdropOptions.colorG, backdropOptions.colorB, backdropOptions.colorA)
        frame:SetBackdropBorderColor(borderOptions.colorR, borderOptions.colorG, borderOptions.colorB, borderOptions.colorA)
        frame:SetBackdrop({
            bgFile = backdropOptions.bgFile,
            edgeFile = borderOptions.edgeFile,
            edgeSize = borderOptions.edgeSize,
            insets = borderOptions.insets,
        })    
    end

    frame.closeable = options.closeable or false
    if options.closeable then
        CraftSim.FRAME:MakeCloseable(frame, options.onCloseCallback)
    end

    frame.collapseable = options.collapseable or false
    if options.collapseable then
        CraftSim.FRAME:MakeCollapsable(frame, options.sizeX, options.sizeY, options.frameID)
    end
    
    frame.moveable = options.moveable or false
    if options.moveable then
        CraftSim.FRAME:makeFrameMoveable(frame)
    end

    frame.scrollableContent = options.scrollableContent or false
    if options.scrollableContent then
        -- scrollframe
        frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        frame.scrollFrame.scrollChild = CreateFrame("frame")
        local scrollFrame = frame.scrollFrame
        local scrollChild = scrollFrame.scrollChild
        scrollFrame:SetSize(frame:GetWidth() , frame:GetHeight())
        scrollFrame:SetPoint("TOP", frame, "TOP", 0, -30)
        scrollFrame:SetPoint("LEFT", frame, "LEFT", 20, 0)
        scrollFrame:SetPoint("RIGHT", frame, "RIGHT", -35, 0)
        scrollFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
        scrollFrame:SetScrollChild(scrollFrame.scrollChild)
        scrollChild:SetWidth(scrollFrame:GetWidth())
        scrollChild:SetHeight(1) -- ??

        frame.content = scrollChild

        frame.UpdateSize = function(x, y) 
            frame:SetSize(x, y)
            scrollFrame:SetSize(frame:GetWidth() , frame:GetHeight())
            scrollFrame:SetPoint("TOP", frame, "TOP", 0, -30)
            scrollFrame:SetPoint("LEFT", frame, "LEFT", 20, 0)
            scrollFrame:SetPoint("RIGHT", frame, "RIGHT", -35, 0)
            scrollFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
            scrollChild:SetWidth(scrollFrame:GetWidth())
        end
    else
        frame.content = CreateFrame("frame", nil, frame)
        frame.content:SetPoint("TOP", frame, "TOP")
        frame.content:SetSize(options.sizeX, options.sizeY)
    end
    frame.frameID = options.frameID
    GGUI.frames[options.frameID] = frame
    return frame
end
