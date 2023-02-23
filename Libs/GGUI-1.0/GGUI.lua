

local GGUI = LibStub:NewLibrary("GGUI", 1)

--- CLASSICS insert
local Object = {}
Object.__index = Object

GGUI.Object = Object

function Object:new()
end

function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end


function Object:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


function Object:__tostring()
  return "Object"
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

--- CLASSICS END

--- GGUI CLASS DEFINITIONS
---@class GGUI.Frame
---@field frame Frame
---@field content Frame
---@field frameID string
---@field scrollableContent boolean
---@field closeable boolean
---@field collapseable boolean
---@field moveable boolean
---@field originalX number
---@field originalY number

---@class GGUI.FrameConstructorOptions
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
---@field scale? number
---@field frameID? string
---@field scrollableContent? boolean
---@field closeable? boolean
---@field collapseable? boolean
---@field collapsed? boolean
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
--- GGUI CLASS DEFINITIONS END

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

GGUI.Frame = GGUI.Object:extend()
---@param options GGUI.FrameConstructorOptions
function GGUI.Frame:new(options)
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
    options.scale = options.scale or 1
    self.originalX = options.sizeX
    self.originalY = options.sizeY
    self.frameID = options.frameID or ("GGUIFrame" .. (GGUI.numFrames))
    self.scrollableContent = options.scrollableContent or false
    self.closeable = options.closeable or false
    self.collapseable = options.collapseable or false
    self.moveable = options.moveable or false
    self.frameStrata = options.frameStrata or "HIGH"
    self.collapsed = false

    local hookFrame = CreateFrame("frame", nil, options.parent)
    hookFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    local frame = CreateFrame("frame", options.globalName, hookFrame, "BackdropTemplate")
    self.frame = frame
    frame.hookFrame = hookFrame
    hookFrame:SetSize(options.sizeX, options.sizeY)
    frame:SetSize(options.sizeX, options.sizeY)
    frame:SetScale(options.scale)
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
        backdropOptions.borderOptions = backdropOptions.borderOptions or {}
        local borderOptions = backdropOptions.borderOptions
        borderOptions.colorR = borderOptions.colorR or 0
        borderOptions.colorG = borderOptions.colorG or 0
        borderOptions.colorB = borderOptions.colorB or 0
        borderOptions.colorA = borderOptions.colorA or 1
        borderOptions.edgeSize = borderOptions.edgeSize or 16
        borderOptions.insets = borderOptions.insets or { left = 8, right = 6, top = 8, bottom = 8 }
        frame:SetBackdropBorderColor(borderOptions.colorR, borderOptions.colorG, borderOptions.colorB, borderOptions.colorA)
        frame:SetBackdrop({
            bgFile = backdropOptions.bgFile,
            edgeFile = borderOptions.edgeFile,
            edgeSize = borderOptions.edgeSize,
            insets = borderOptions.insets,
        })    
        frame:SetBackdropColor(backdropOptions.colorR, backdropOptions.colorG, backdropOptions.colorB, backdropOptions.colorA)
    end

    if self.closeable then
        GGUI:MakeFrameCloseable(frame, options.onCloseCallback)
    end

    if self.collapseable then
        GGUI:MakeFrameCollapsable(self)
    end
    
    if self.moveable then
        GGUI:MakeFrameMoveable(frame)
    end

    if self.scrollableContent then
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
    self.content = frame.content
    GGUI.frames[self.frameID] = frame
    return frame
end

---@param gFrame GGUI.Frame
function GGUI:MakeFrameCollapsable(gFrame)
    local frame = gFrame.frame
    frame.collapseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    local offsetX = frame.closeButton and -43 or -23
	frame.collapseButton:SetPoint("TOP", frame, "TOPRIGHT", offsetX, -10)	
	frame.collapseButton:SetText(" - ")
	frame.collapseButton:SetSize(frame.collapseButton:GetTextWidth() + 12, 20)

    frame.collapseButton:SetScript("OnClick", function(self) 
        if gFrame.collapsed then
            gFrame:Decollapse()
        else
            gFrame:Collapse()
        end
    end)
end

function GGUI.Frame:Collapse()
    if self.collapseable and self.frame.collapseButton then
        self.collapsed = true
        -- make smaller and hide content, only show frameTitle
        self.frame:SetSize(self.originalX, 40)
        self.frame.collapseButton:SetText("+")
        self.frame.content:Hide()
        if self.frame.scrollFrame then
            self.frame.scrollFrame:Hide()
        end
    end
end

function GGUI.Frame:Decollapse()
    if self.collapseable and self.frame.collapseButton then
        -- restore
        self.collapsed = false
        self.frame.collapseButton:SetText("-")
        self.frame:SetSize(self.originalX, self.originalY)
        self.frame.content:Show()
        if self.frame.scrollFrame then
            self.frame.scrollFrame:Show()
        end
    end
end

function GGUI:MakeFrameCloseable(frame, onCloseCallback)
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.closeButton:SetPoint("TOP", frame, "TOPRIGHT", -20, -10)	
	frame.closeButton:SetText("X")
	frame.closeButton:SetSize(frame.closeButton:GetTextWidth()+15, 20)
    frame.closeButton:SetScript("OnClick", function(self) 
        frame:Hide()
        if onCloseCallback then
            onCloseCallback(frame)
        end
    end)
end

function GGUI:MakeFrameMoveable(frame)
	frame.hookFrame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, button)
		frame.hookFrame:StartMoving()
		end)
		frame:SetScript("OnMouseUp", function(self, button)
		frame.hookFrame:StopMovingOrSizing()
		end)
end