

---@class GGUI
local GGUI = LibStub:NewLibrary("GGUI", 1)

local GUTIL = GGUI_GUTIL

local configName = nil

--- CLASSICS insert
---@class Object
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

GGUI.numFrames = 0
GGUI.frames = {}

if not GGUI then return end

-- GGUI CONST
GGUI.CONST = {}
GGUI.CONST.EMPTY_TEXTURE = "Interface\\containerframe\\bagsitemslot2x"

-- GGUI Configuration Methods
    function GGUI:SetConfigSavedVariable(variableName)
        configName = variableName
        _G[configName] = _G[configName] or {} 
    end

    function GGUI:GetConfig(key)
        if configName then
            return _G[configName][key]
        else
            error("GGUI Get Config Error: Config not set!")
        end
    end

    function GGUI:SaveConfig(key, value)
        if configName then
            _G[configName][key] = value
        else
            error("GGUI Set Config Error: Config not set!")
        end
    end

-- GGUI UTILS
function GGUI:MakeFrameCloseable(frame, onCloseCallback)
    frame.closeButton = GGUI.Button({
        parent=frame,anchorParent=frame,offsetX=-20,offsetY=-10,label="X",
        anchorA="TOP",anchorB="TOPRIGHT",
        sizeX=15,sizeY=20,adjustWidth=true,
        clickCallback=function ()
            frame:Hide()
            if onCloseCallback then
                onCloseCallback(frame)
            end
        end
    })
end
function GGUI:MakeFrameMoveable(gFrame)
    gFrame.frame.hookFrame:SetMovable(true)
    gFrame.frame:SetScript("OnMouseDown", function(self, button)
        local anchorParent = select(2, gFrame.frame.hookFrame:GetPoint())
        gFrame.preMoveAnchorParent = anchorParent
        gFrame.frame.hookFrame:StartMoving()
        end)
        gFrame.frame:SetScript("OnMouseUp", function(self, button)
            gFrame.frame.hookFrame:StopMovingOrSizing()
            local x, y = gFrame.frame.hookFrame:GetCenter()
            local relativeX, relativeY = gFrame.preMoveAnchorParent:GetCenter()
        
            -- Calculate the offset between the original anchor parent and the new position
            local offsetX = x - relativeX
            local offsetY = y - relativeY
    
            -- Reapply the anchor point with the offset
            gFrame.frame.hookFrame:ClearAllPoints()
            gFrame.frame.hookFrame:SetPoint("CENTER", gFrame.preMoveAnchorParent, "CENTER", offsetX, offsetY)

            gFrame:SavePosition(offsetX, offsetY)
    end)
end
function GGUI:SetItemTooltip(frame, itemLink, owner, anchor)
    local function onEnter()
        local _, ItemLink = GameTooltip:GetItem()
        GameTooltip:SetOwner(owner, anchor);

        if ItemLink ~= itemLink then
            -- to not set it again and hide the tooltip..
            GameTooltip:SetHyperlink(itemLink)
        end
        GameTooltip:Show();
    end
    local function onLeave()
        GameTooltip:Hide();
    end
    if itemLink then
        frame:SetScript("OnEnter", onEnter)
        frame:SetScript("OnLeave", onLeave)
    else
        frame:SetScript("OnEnter", nil)
        frame:SetScript("OnLeave", nil)
    end
end

function GGUI:EnableHyperLinksForFrameAndChilds(frame)
    if type(frame) == "table" and frame.SetHyperlinksEnabled and not frame.enabledLinks then -- prevent inf loop by references
        frame.enabledLinks = true
        frame:SetHyperlinksEnabled(true)
        frame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)

        for possibleFrame1, possibleFrame2 in pairs(frame) do
            GGUI:EnableHyperLinksForFrameAndChilds(possibleFrame1)
            GGUI:EnableHyperLinksForFrameAndChilds(possibleFrame2)
        end
    end
end

---- GGUI Widgets

--- GGUI Widget

---@class GGUI.Widget
GGUI.Widget = GGUI.Object:extend()

function GGUI.Widget:new(frame)
    self.frame=frame
    self.isGGUI = true
end
--- forward common frame/region methods to original frame
function GGUI.Widget:SetScript(...)
    self.frame:SetScript(...)
end
function GGUI.Widget:HookScript(...)
    self.frame:HookScript(...)
end
function GGUI.Widget:Show()
    self.frame:Show()
end
function GGUI.Widget:Hide()
    self.frame:Hide()
end
function GGUI.Widget:SetEnabled(enabled)
    self.frame:SetEnabled(enabled)
end
function GGUI.Widget:SetVisible(visible)
    if visible then
        self:Show()
    else
        self:Hide()
    end
end
function GGUI.Widget:GetHeight()
    return self.frame:GetHeight()
end
function GGUI.Widget:GetWidth()
    return self.frame:GetWidth()
end
function GGUI.Widget:SetTransparency(transparency)
    self.frame:SetBackdropColor(0, 0, 0 , transparency) -- TODO: with current color
end
function GGUI.Widget:IsVisible()
    return self.frame:IsVisible()
end
function GGUI.Widget:SetPoint(...)
    return self.frame:SetPoint(...)
end
function GGUI.Widget:Raise()
    self.frame:Raise()
end
function GGUI.Widget:Lower()
    self.frame:Lower()
end
function GGUI.Widget:SetFrameLevel(...)
    self.frame:SetFrameLevel(...)
end

--- GGUI Frame

---@class GGUI.FrameStatus[]
---@field statusID string
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field title? string
---@field activationCallback? function

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
---@field onCollapseCallback? function
---@field onCollapseOpenCallback? function
---@field backdropOptions GGUI.BackdropOptions
---@field initialStatusID? string

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

---@param frameID string The ID string you gave the frame
---@return GGUI.Frame | GGUI.Widget
function GGUI:GetFrame(frameID)
    if not GGUI.frames[frameID] then
        error("GGUI Error: Frame not found: " .. frameID)
    end
    return GGUI.frames[frameID]
end

---@class GGUI.Frame
GGUI.Frame = GGUI.Widget:extend()

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
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    self.originalX = options.sizeX
    self.originalY = options.sizeY
    self.originalOffsetX = options.offsetX
    self.originalOffsetY = options.offsetY
    self.originalAnchorParent = options.anchorParent
    self.originalAnchorA = options.anchorA
    self.originalAnchorB = options.anchorB
    self.frameID = options.frameID or ("GGUIFrame" .. (GGUI.numFrames))
    self.scrollableContent = options.scrollableContent or false
    self.closeable = options.closeable or false
    self.collapseable = options.collapseable or false
    self.moveable = options.moveable or false
    self.frameStrata = options.frameStrata or "HIGH"
    self.collapsed = false
    self.activeStatusID = options.initialStatusID
    ---@type GGUI.FrameStatus[]
    self.statusList = {}
    self.onCollapseCallback = options.onCollapseCallback
    self.onCollapseOpenCallback = options.onCollapseOpenCallback

    local hookFrame = CreateFrame("frame", nil, options.parent)
    hookFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    local frame = CreateFrame("frame", options.globalName, hookFrame, "BackdropTemplate")
    GGUI.Frame.super.new(self, frame)
    frame.hookFrame = hookFrame
    hookFrame:SetSize(options.sizeX, options.sizeY)
    frame:SetSize(options.sizeX, options.sizeY)
    frame:SetScale(options.scale)
    frame:SetFrameStrata(options.frameStrata or "HIGH")
    frame:SetFrameLevel(GGUI.numFrames)

    self.title = GGUI.Text({
        parent=frame,anchorParent=frame,text=options.title,offsetY=-15,
        anchorA="TOP",anchorB="TOP"
    })
    
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
        GGUI:MakeFrameMoveable(self)
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
    else
        frame.content = CreateFrame("frame", nil, frame)
        frame.content:SetPoint("TOP", frame, "TOP")
        frame.content:SetSize(options.sizeX, options.sizeY)
    end
    self.content = frame.content
    GGUI.frames[self.frameID] = self
    return frame
end

function GGUI.Frame:SetSize(x, y)
    self.frame:SetSize(x, y)
    if self.frame.scrollFrame then
        self.frame.scrollFrame:SetSize(self.frame:GetWidth() , self.frame:GetHeight())
        self.frame.scrollFrame:SetPoint("TOP", self.frame, "TOP", 0, -30)
        self.frame.scrollFrame:SetPoint("LEFT", self.frame, "LEFT", 20, 0)
        self.frame.scrollFrame:SetPoint("RIGHT", self.frame, "RIGHT", -35, 0)
        self.frame.scrollFrame:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 20)
        self.frame.scrollFrame.scrollChild:SetWidth(self.frame.scrollFrame:GetWidth())
    end
end

function GGUI.Frame:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.frame)
end

---@param gFrame GGUI.Frame
function GGUI:MakeFrameCollapsable(gFrame)
    local frame = gFrame.frame
    local offsetX = frame.closeButton and -43 or -23

    frame.collapseButton = GGUI.Button({
        parent=frame,anchorParent=frame,anchorA="TOP",anchorB="TOPRIGHT",offsetX=offsetX,offsetY=-10,
        label=" - ", sizeX=12,sizeY=20,adjustWidth=true,
        clickCallback=function ()
            if gFrame.collapsed then
                gFrame:Decollapse()
            else
                gFrame:Collapse()
            end
        end
    })
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

        if self.onCollapseCallback then
            self.onCollapseCallback(self)
        end

        GGUI:SaveConfig("collapsed_" .. self.frameID, true)
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

        if self.onCollapseOpenCallback then
            self.onCollapseOpenCallback(self)
        end

        GGUI:SaveConfig("collapsed_" .. self.frameID, false)
    end
end

function GGUI.Frame:ResetPosition()
    self.frame.hookFrame:ClearAllPoints()
    self.frame.hookFrame:SetPoint(self.originalAnchorA, self.originalAnchorParent, self.originalAnchorB, self.originalOffsetX, self.originalOffsetY)

    local x, y = self.frame.hookFrame:GetCenter()
    local relativeX, relativeY = self.originalAnchorParent:GetCenter()

    -- Calculate the offset between the original anchor parent and the new position
    local offsetX = x - relativeX
    local offsetY = y - relativeY

    self:SavePosition(offsetX, offsetY)
end

--- Set a list of predefined GGUI.ButtonStatus
---@param statusList GGUI.FrameStatus[]
function GGUI.Frame:SetStatusList(statusList)
    -- map statuslist to their ids
    table.foreach(statusList, function (_, status)
        if not status.statusID then
            error("GGUI: FrameStatus without statusID")
        end
        self.statusList[status.statusID] = status
    end)
end

function GGUI.Frame:SetStatus(statusID)
    local frameStatus = self.statusList[statusID]
    self.activeStatusID = statusID

    if frameStatus then
        if frameStatus.sizeX then
            self.frame:SetWidth(frameStatus.sizeX)
        end
        if frameStatus.sizeY then
            self.frame:SetHeight(frameStatus.sizeY)
        end
        if frameStatus.title then
            self.frame.title:SetText(frameStatus.title)
        end
        if frameStatus.offsetX or frameStatus.offsetY or frameStatus.anchorParent or frameStatus.anchorA or frameStatus.anchorB then
            local offsetX = frameStatus.offsetX or self.originalOffsetX
            local offsetY = frameStatus.offsetY or self.originalOffsetY
            local anchorParent = frameStatus.anchorParent or self.originalAnchorParent
            local anchorA = frameStatus.anchorA or self.originalAnchorA
            local anchorB = frameStatus.anchorB or self.originalAnchorB

            self.frame:ClearAllPoints()
            self.frame:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        end
        if frameStatus.activationCallback then
            frameStatus.activationCallback(self, statusID)
        end

        -- if collapsed, restore collapse height
        if self.collapseable and self.collapsed then
            self:Collapse()
        end
    end
end

---@return string statusID
function GGUI.Frame:GetStatus()
    return tostring(self.activeStatusID)
end

function GGUI.Frame:RestoreSavedConfig(relativeTo)
    local savedPosInfo = GGUI:GetConfig("savedPos_" .. self.frameID)

    if savedPosInfo then
        relativeTo = relativeTo or UIParent
        self.frame.hookFrame:ClearAllPoints()
        self.frame.hookFrame:SetPoint("CENTER", relativeTo, "CENTER", savedPosInfo.offsetX, savedPosInfo.offsetY)
    end

    if self.collapseable then
        if GGUI:GetConfig("collapsed_" .. self.frameID) then
            self:Collapse()
        end
    end
end

function GGUI.Frame:SavePosition(offsetX, offsetY)
    GGUI:SaveConfig("savedPos_" .. self.frameID, {
        offsetX = offsetX,
        offsetY = offsetY,
    })
end

--- GGUI Icon

---@class GGUI.IconConstructorOptions
---@field parent? Frame
---@field offsetX? number
---@field offsetY? number
---@field texturePath? string
---@field sizeX? number
---@field sizeY? number
---@field qualityIconScale? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field anchorParent? Region
---@field hideQualityIcon? boolean

---@class GGUI.Icon
GGUI.Icon = GGUI.Widget:extend()
function GGUI.Icon:new(options)
    options = options or {}
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.texturePath = options.texturePath or GGUI.CONST.EMPTY_TEXTURE -- empty slot texture
    options.sizeX = options.sizeX or 40
    options.sizeY = options.sizeY or 40
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.qualityIconScale = options.qualityIconScale or 1
    self.hideQualityIcon = options.hideQualityIcon or false
    ---@type ItemMixin?
    self.item = nil

    local newIcon = CreateFrame("Button", nil, options.parent, "GameMenuButtonTemplate")
    GGUI.Icon.super.new(self, newIcon)
    newIcon:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
	newIcon:SetSize(options.sizeX, options.sizeY)
	newIcon:SetNormalFontObject("GameFontNormalLarge")
	newIcon:SetHighlightFontObject("GameFontHighlightLarge")
	newIcon:SetNormalTexture(options.texturePath)
    newIcon.qualityIcon = GGUI.QualityIcon({
        parent=self.frame,
        sizeX=options.sizeX*0.50*options.qualityIconScale,
        sizeY=options.sizeY*0.50*options.qualityIconScale,
        anchorParent=newIcon,
        anchorA="TOPLEFT",
        anchorB="TOPLEFT",
        offsetX=-options.sizeX*0.10*options.qualityIconScale,
        offsetY=options.sizeY*0.10*options.qualityIconScale,
    })
    newIcon.qualityIcon:Hide()
    self.qualityIcon = newIcon.qualityIcon

    self.frame:HookScript("OnClick", function ()
        if IsShiftKeyDown() and self.item then
            self.item:ContinueOnItemLoad(function ()
                ChatEdit_InsertLink(self.item:GetItemLink())
            end)
        end
    end)
end

---@class GGUI.IconSetItemOptions
---@field tooltipOwner? Frame
---@field tooltipAnchor? TooltipAnchor
---@field overrideQuality? number

---@param idLinkOrMixin number | string | ItemMixin
function GGUI.Icon:SetItem(idLinkOrMixin, options)
    options = options or {}

    local gIcon = self
    if not idLinkOrMixin then
        gIcon.frame:SetScript("OnEnter", nil)
        gIcon.frame:SetScript("OnLeave", nil)
        gIcon.qualityIcon:Hide()
        GGUI:SetItemTooltip(gIcon.frame, nil)
        gIcon.frame:SetNormalTexture(GGUI.CONST.EMPTY_TEXTURE)
        return
    end
    local item = nil
    if type(idLinkOrMixin) == 'number' then
        item = Item:CreateFromItemID(idLinkOrMixin)
    elseif type(idLinkOrMixin) == 'string' then
        item = Item:CreateFromItemLink(idLinkOrMixin)
    elseif type(idLinkOrMixin) == 'table' and idLinkOrMixin.ContinueOnItemLoad then -- some small test if its a mixing
        item = idLinkOrMixin
    end

    self.item = item
    item:ContinueOnItemLoad(function ()
        gIcon.frame:SetNormalTexture(item:GetItemIcon())
        GGUI:SetItemTooltip(gIcon.frame, item:GetItemLink(), options.tooltipOwner or gIcon.frame, options.tooltipAnchor or "ANCHOR_RIGHT")

        if options.overrideQuality then
            gIcon.qualityIcon:SetQuality(options.overrideQuality)
        else
            local qualityID = GUTIL:GetQualityIDFromLink(item:GetItemLink())
            gIcon.qualityIcon:SetQuality(qualityID)
        end

        if self.hideQualityIcon then
            gIcon.qualityIcon:Hide()
        end
    end)
end

---@param qualityID number
function GGUI.Icon:SetQuality(qualityID)
    if qualityID then
        self.qualityIcon:SetQuality(qualityID)
        self.qualityIcon:Show()
    else
        self.qualityIcon:Hide()
    end
end

--- GGUI.QualityIcon

---@class GGUI.QualityIconConstructorOptions
---@field parent Frame
---@field sizeX? number
---@field sizeY? number
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field initialQuality? number

---@class GGUI.QualityIcon
GGUI.QualityIcon = GGUI.Widget:extend()
function GGUI.QualityIcon:new(options)
    options = options or {}
    options.parent = options.parent or UIParent
    options.sizeX = options.sizeX or 30
    options.sizeY = options.sizeY or 30
    options.anchorParent = options.anchorParent
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.initialQuality = options.initialQuality or 1

    local icon = options.parent:CreateTexture(nil, "OVERLAY")
    GGUI.QualityIcon.super.new(self, icon)
    icon:SetSize(options.sizeX, options.sizeY)
    icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    icon:SetAtlas("Professions-Icon-Quality-Tier" .. options.initialQuality)
    icon:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
end

---@param qualityID number
function GGUI.QualityIcon:SetQuality(qualityID)
    if not qualityID or type(qualityID) ~= 'number' then
        self.frame:Hide()
        return
    end
    self.frame:Show()
    if qualityID > 5 then
        qualityID = 5
    elseif qualityID < 1 then
        qualityID = 1
    end
    self.frame:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    self.frame:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
end

--- GGUI.Dropdown

---@class GGUI.DropdownConstructorOptions
---@field globalName? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field label? string
---@field offsetX? number
---@field offsetY? number
---@field width? number
---@field initialData? GGUI.DropdownData[]
---@field clickCallback? function
---@field initialValue? any
---@field initialLabel? string

---@class GGUI.DropdownData
---@field isCategory? boolean
---@field label string
---@field value any
---@field tooltipItemLink? string
---@field tooltipConcatText? string

---@class GGUI.Dropdown
GGUI.Dropdown = GGUI.Widget:extend()

---@param options GGUI.DropdownConstructorOptions
function GGUI.Dropdown:new(options)
    options = options or {}
    options.label = options.label or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.width = options.width or 150
    options.initialData = options.initialData or {}
    options.initialValue = options.initialValue or ""
    options.initialLabel = options.initialLabel or ""
	local dropDown = CreateFrame("Frame", options.globalName, options.parent, "UIDropDownMenuTemplate")
    GGUI.Dropdown.super.new(self, dropDown)
    self.clickCallback = options.clickCallback
	dropDown:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
	UIDropDownMenu_SetWidth(dropDown, options.width)
    self.selectedValue = nil
	
    self:SetData({
        data=options.initialData, 
        initialValue=options.initialValue, initialLabel=options.initialLabel})

    self.title = dropDown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    self.title:SetPoint("TOP", 0, 10)

    self:SetLabel(options.label)

end

function GGUI.Dropdown:SetLabel(label)
    self.title:SetText(label)
end

---@class GGUI.DropdownSetDataOptions
---@field data GGUI.DropdownData
---@field initialValue? any
---@field initialLabel? string

---@param options GGUI.DropdownSetDataOptions
function GGUI.Dropdown:SetData(options)
    options = options or {}
    options.data = options.data or {}
    options.initialValue = options.initialValue or nil
    options.initialLabel = options.initialLabel or ""

    local dropDown = self.frame
    local gDropdown = self
    local function initMainMenu(self, level, menulist) 
        local info = UIDropDownMenu_CreateInfo()
        if level == 1 then
            for _, data in pairs(options.data) do
                -- print("GGUI dropdown: data")
                -- print("isCategory: " .. tostring(data.isCategory))
                -- print("label: " .. tostring(data.label))
                -- print("value: " .. tostring(data.value))
                -- print("isCategory: " .. tostring(data.isCategory))
                -- print("tooltipItemLink: " .. tostring(data.tooltipItemLink))
                -- print("tooltipConcatText: " .. tostring(data.tooltipConcatText))
                info.text = data.label
                info.arg1 = data.value
                if not data.isCategory then
                    info.func = function(self, arg1, arg2, checked) 
                        UIDropDownMenu_SetText(dropDown, data.label) -- value should contain the selected text..
                        gDropdown.selectedValue = data.value
                        if gDropdown.clickCallback then
                            gDropdown.clickCallback(self, data.label, data.value)
                        end
                    end
                end
                
                info.hasArrow = data.isCategory
                info.menuList = data.isCategory and data.label
                if data.tooltipItemLink then
                    local concatText = data.tooltipConcatText or ""
                    info.tooltipText = GUTIL:GetItemTooltipText(data.tooltipItemLink)
                    -- cut first line as it is the name of the item
                    info.tooltipTitle, info.tooltipText = string.match(info.tooltipText, "^(.-)\n(.*)$")
                    info.tooltipTitle = info.tooltipTitle .. "\n" .. concatText
                    info.tooltipOnButton = true
                end
                UIDropDownMenu_AddButton(info)
            end
        elseif menulist then
            for _, currentMenulist in pairs(options.data) do
                if currentMenulist.label == menulist then
                    for _, data in pairs(currentMenulist.value) do
                        info.text = data.label
                        info.arg1 = data.value
                        info.func = function(self, arg1, arg2, checked) 
                            UIDropDownMenu_SetText(dropDown, self.value) -- value should contain the selected text..
                            gDropdown.selectedValue = self.value
                            if gDropdown.clickCallback then
                                gDropdown.clickCallback(self, data.label, data.value)
                            end
                            CloseDropDownMenus()
                        end
                        
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        end
	end

    
	UIDropDownMenu_Initialize(dropDown, initMainMenu, "DROPDOWN_MENU_LEVEL")
	UIDropDownMenu_SetText(dropDown, options.initialLabel)

    self.selectedValue = options.initialValue
end

function GGUI.Dropdown:SetEnabled(enabled)
    if enabled then
        UIDropDownMenu_EnableDropDown(self.frame)
    else
        UIDropDownMenu_DisableDropDown(self.frame)
    end
end

--- GGUI.Text

---@class GGUI.TextConstructorOptions
---@field text? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field font? string
---@field scale? number
---@field justifyOptions? GGUI.JustifyOptions
---@field fixedWidth? number

---@class GGUI.JustifyOptions
---@field type "H" | "V" | "HV"
---@field align string
---@field alignH string
---@field alignV string

---@class GGUI.Text
GGUI.Text = GGUI.Widget:extend()
---@param options GGUI.TextConstructorOptions
function GGUI.Text:new(options)
    options = options or {}
    options.text = options.text or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.font = options.font or "GameFontHighlight"
    options.scale = options.scale or 1

    local text = options.parent:CreateFontString(nil, "OVERLAY", options.font)
    GGUI.Text.super.new(self, text)
    text:SetText(options.text)
    text:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    text:SetScale(options.scale)

    if options.wrap then
        text:SetWordWrap(true)
    end

    if options.fixedWidth then
        text:SetWidth(options.fixedWidth)
    end
    
    if options.justifyOptions then
        if options.justifyOptions.type == "V" and options.justifyOptions.align then
            text:SetJustifyV(options.justifyOptions.align)
        elseif options.justifyOptions.type == "H" and options.justifyOptions.align then
            text:SetJustifyH(options.justifyOptions.align)
        elseif options.justifyOptions.type == "HV" and options.justifyOptions.alignH and options.justifyOptions.alignV then
            text:SetJustifyH(options.justifyOptions.alignH)
            text:SetJustifyV(options.justifyOptions.alignV)
        end
    end
end

function GGUI.Text:GetText()
    self.frame:GetText()
end

function GGUI.Text:SetText(text)
    self.frame:SetText(text)
end

function GGUI.Text:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.frame)
end

--- GGUI.ScrollingMessageFrame

---@class GGUI.ScrollingMessageFrameConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field maxLines? number
---@field sizeX? number
---@field sizeY? number
---@field font? string
---@field fading? boolean
---@field enableScrolling? boolean
---@field justifyOptions? GGUI.JustifyOptions

---@class GGUI.ScrollingMessageFrame
GGUI.ScrollingMessageFrame = GGUI.Widget:extend()
---@param options GGUI.ScrollingMessageFrameConstructorOptions
function GGUI.ScrollingMessageFrame:new(options)
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 150
    options.sizeY = options.sizeY or 100
    options.font = options.font or "GameFontHighlight"
    options.fading = options.fading or false
    options.enableScrolling = options.enableScrolling or false
    local scrollingFrame = CreateFrame("ScrollingMessageFrame", nil, options.parent)
    GGUI.ScrollingMessageFrame.super.new(self, scrollingFrame)
    scrollingFrame:SetSize(options.sizeX, options.sizeY)
    scrollingFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    scrollingFrame:SetFontObject(options.font)
    if options.maxLines then
        scrollingFrame:SetMaxLines(options.maxLines)
    end
    scrollingFrame:SetFading(options.fading)
    if options.justifyOptions then
        if options.justifyOptions.type == "V" and options.justifyOptions.align then
            scrollingFrame:SetJustifyV(options.justifyOptions.align)
        elseif options.justifyOptions.type == "H" and options.justifyOptions.align then
            scrollingFrame:SetJustifyH(options.justifyOptions.align)
        elseif options.justifyOptions.type == "HV" and options.justifyOptions.alignH and options.justifyOptions.alignV then
            scrollingFrame:SetJustifyH(options.justifyOptions.alignH)
            scrollingFrame:SetJustifyV(options.justifyOptions.alignV)
        end
    end
    scrollingFrame:EnableMouseWheel(options.enableScrolling)

    scrollingFrame:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
          scrollingFrame:ScrollUp()
        elseif delta < 0 then
          scrollingFrame:ScrollDown()
        end
      end)
end

function GGUI.ScrollingMessageFrame:AddMessage(message)
    self.frame:AddMessage(message)
end
function GGUI.ScrollingMessageFrame:Clear(message)
    self.frame:Clear(message)
end

function GGUI.ScrollingMessageFrame:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.frame)
end


--- GGUI.Button

---@class GGUI.ButtonStatus[]
---@field statusID string
---@field sizeX? number
---@field sizeY? number
---@field adjustWidth? boolean
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field label? string
---@field enabled? boolean
---@field activationCallback? function

---@class GGUI.ButtonConstructorOptions
---@field label? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field adjustWidth? boolean
---@field clickCallback? function
---@field initialStatusID? string

---@class GGUI.Button
GGUI.Button = GGUI.Widget:extend()
---@param options GGUI.ButtonConstructorOptions
function GGUI.Button:new(options)
    self.statusList = {}
    options = options or {}
    options.label = options.label or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    self.originalAnchorA = options.anchorA
    self.originalAnchorB = options.anchorB
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    self.originalOffsetX = options.offsetX
    self.originalOffsetY = options.offsetY
    options.sizeX = options.sizeX or 15
    options.sizeY = options.sizeY or 25
    self.originalX = options.sizeX
    self.originalY = options.sizeY
    self.originalText = options.label
    options.adjustWidth = options.adjustWidth or false
    self.originalParent = options.parent or UIParent
    self.originalAnchorParent = options.anchorParent or UIParent
    self.activeStatusID = options.initialStatusID

    local button = CreateFrame("Button", nil, options.parent, "UIPanelButtonTemplate")
    GGUI.Button.super.new(self, button)
    button:SetText(options.label)
    if options.adjustWidth then
        button:SetSize(button:GetTextWidth() + options.sizeX, options.sizeY)
    else
        button:SetSize(options.sizeX, options.sizeY)
    end
    
    button:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)

    self.clickCallback = options.clickCallback

    button:SetScript("OnClick", function() 
        if self.clickCallback then
            self.clickCallback(self)
        end
    end)
end

---@param text string
---@param width? number
---@param adjustWidth? boolean
function GGUI.Button:SetText(text, width, adjustWidth)
    self.frame:SetText(text)
    if width then
        if adjustWidth then
            self.frame:SetSize(self.frame:GetTextWidth() + width, self.originalY)
        else
            self.frame:SetSize(width, self.originalY)
        end
    elseif adjustWidth then
        width = self.originalX
        self.frame:SetSize(self.frame:GetTextWidth() + width, self.originalY)
    end
end

--- Set a list of predefined GGUI.ButtonStatus
---@param statusList GGUI.ButtonStatus[]
function GGUI.Button:SetStatusList(statusList)
    -- map statuslist to their ids
    table.foreach(statusList, function (_, status)
        if not status.statusID then
            error("GGUI: ButtonStatus without statusID")
        end
        self.statusList[status.statusID] = status
    end)
end

function GGUI.Button:SetStatus(statusID)
    local buttonStatus = self.statusList[statusID]
    self.activeStatusID = statusID

    if buttonStatus then
        if buttonStatus.adjustWidth then
            if buttonStatus.sizeX then
                self.frame:SetWidth(self.frame:GetTextWidth() + buttonStatus.sizeX)
            else
                self.frame:SetWidth(self.frame:GetTextWidth() + self.originalX)
            end
        elseif buttonStatus.sizeX then
            self.frame:SetWidth(buttonStatus.sizeX)
        end
        if buttonStatus.sizeY then
            self.frame:SetHeight(buttonStatus.sizeY)
        end
        if buttonStatus.label then
            self.frame:SetText(buttonStatus.label)
        end
        if buttonStatus.enabled ~= nil then
            self.frame:SetEnabled(buttonStatus.enabled)
        end
        if buttonStatus.offsetX or buttonStatus.offsetY or buttonStatus.anchorParent or buttonStatus.anchorA or buttonStatus.anchorB then
            local offsetX = buttonStatus.offsetX or self.originalOffsetX
            local offsetY = buttonStatus.offsetY or self.originalOffsetY
            local anchorParent = buttonStatus.anchorParent or self.originalAnchorParent
            local anchorA = buttonStatus.anchorA or self.originalAnchorA
            local anchorB = buttonStatus.anchorB or self.originalAnchorB

            self.frame:ClearAllPoints()
            self.frame:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        end
        if buttonStatus.activationCallback then
            buttonStatus.activationCallback(self, statusID)
        end
    end
end

---@return string statusID
function GGUI.Button:GetStatus()
    return tostring(self.activeStatusID)
end

--- GGUI.Tab

---@class GGUI.TabConstructorOptions
---@field buttonOptions? GGUI.ButtonConstructorOptions
---@field canBeEnabled? boolean
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region

---@class GGUI.Tab
GGUI.Tab = GGUI.Object:extend()
---@param options GGUI.TabConstructorOptions
function GGUI.Tab:new(options)
    options = options or {}
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 100
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    self.isGGUI = true

    self.button = GGUI.Button(options.buttonOptions)
    self.button.canBeEnabled = options.canBeEnabled or false

    self.content = CreateFrame("Frame", nil, options.parent)
    self.content:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    self.content:SetSize(options.sizeX, options.sizeY)
end

function GGUI.Tab:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.content)
end

--- GGUI.TabSystem

---@class GGUI.TabSystem
GGUI.TabSystem = GGUI.Object:extend()

---@param tabList GGUI.Tab[]
function GGUI.TabSystem:new(tabList)
    self.isGGUI = true
    self.tabs = tabList
    if #tabList == 0 then
        return
    end
    -- show first tab in list
    for _, tab in pairs(tabList) do
        tab.button.frame:SetScript("OnClick", function(self) 
            for _, otherTab in pairs(tabList) do
                otherTab.content:Hide()
                otherTab.button:SetEnabled(otherTab.canBeEnabled)
            end
            tab.content:Show()
            tab.button:SetEnabled(false)
        end)
        tab.content:Hide()
    end
    tabList[1].content:Show()
    tabList[1].button:SetEnabled(false)
end

function GGUI.TabSystem:EnableHyperLinksForFrameAndChilds()
    table.foreach(self.tabs, function (_, tab)
        GGUI:EnableHyperLinksForFrameAndChilds(tab.content)
    end)
end

--- GGUI.Checkbox
---@class GGUI.Checkbox
GGUI.Checkbox = GGUI.Widget:extend()

---@class GGUI.CheckboxConstructorOptions
---@field label? string
---@field tooltip? string
---@field initialValue? boolean
---@field clickCallback? function
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number

---@param options GGUI.CheckboxConstructorOptions
function GGUI.Checkbox:new(options)
    options = options or {}
    options.label = options.label or ""
    options.initialValue = options.initialValue or false
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    self.clickCallback = options.clickCallback

    local checkBox = CreateFrame("CheckButton", nil, options.parent, "ChatConfigCheckButtonTemplate")
    GGUI.Checkbox.super.new(self, checkBox)
    checkBox:SetHitRectInsets(0, 0, 0, 0); -- see https://wowpedia.fandom.com/wiki/API_Frame_SetHitRectInsets
	checkBox:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
	checkBox.Text:SetText(options.label)
    checkBox.tooltip = options.tooltip
	-- there already is an existing OnClick script that plays a sound, hook it
    checkBox:SetChecked(options.initialValue)
	checkBox:HookScript("OnClick", function() 
        if self.clickCallback then
            self.clickCallback(self, self.frame:GetChecked())
        end
    end)
end

function GGUI.Checkbox:GetChecked()
    return self.frame:GetChecked()
end
function GGUI.Checkbox:SetChecked(value)
    return self.frame:SetChecked(value)
end


--- GGUI.Slider

---@class GGUI.SliderConstructorOptions
---@field label? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field orientation? string
---@field minValue? number
---@field maxValue? number
---@field initialValue? number
---@field lowText? string
---@field highText? string
---@field onValueChangedCallback? function

---@class GGUI.Slider
GGUI.Slider = GGUI.Widget:extend()
---@param options GGUI.SliderConstructorOptions
function GGUI.Slider:new(options)
    options = options or {}
    options.label = options.label or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 150
    options.sizeY = options.sizeY or 25
    options.orientation = options.orientation or "HORIZONTAL"
    options.minValue = options.minValue or 0
    options.maxValue = options.maxValue or 1
    options.initialValue = options.initialValue or 0
    options.lowText = options.lowText or ""
    options.highText = options.highText or ""

    local newSlider = CreateFrame("Slider", nil, options.parent, "OptionsSliderTemplate")
    GGUI.Slider.super.new(self, newSlider)
    newSlider:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    newSlider:SetSize(options.sizeX, options.sizeY)
    newSlider:SetOrientation(options.orientation)
    newSlider:SetMinMaxValues(options.minValue, options.maxValue)
    newSlider:SetValue(options.initialValue)
    _G[newSlider:GetName() .. 'Low']:SetText(options.lowText)        -- Sets the left-side slider text (default is "Low").
    _G[newSlider:GetName() .. 'High']:SetText(options.highText)     -- Sets the right-side slider text (default is "High").
    _G[newSlider:GetName() .. 'Text']:SetText(options.label)       -- Sets the "title" text (top-centre of slider).

    newSlider:SetScript("OnValueChanged", 
    function (...)
        if self.onValueChangedCallback then
            self.onValueChangedCallback(...)
        end
    end)
end

--- GGUI.HelpIcon
---@class GGUI.HelpIconConstructorOptions
---@field text? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number

---@class GGUI.HelpIcon
GGUI.HelpIcon = GGUI.Widget:extend()

---@param options GGUI.HelpIconConstructorOptions
function GGUI.HelpIcon:new(options)
    options = options or {}
    options.text = options.text or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0

    local helpButton = CreateFrame("Button", nil, options.parent, "UIPanelButtonTemplate")
    GGUI.HelpIcon.super.new(self, helpButton)
    helpButton.tooltipText = options.text
    helpButton:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)	
    helpButton:SetText("?")
    helpButton:SetSize(helpButton:GetTextWidth() + 15, 15)

    helpButton:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:ClearLines() 
        GameTooltip:SetText(self.tooltipText)
        GameTooltip:Show()
    end)
    helpButton:SetScript("OnLeave", function(self) 
        GameTooltip:Hide()
    end)
end

function GGUI.HelpIcon:SetText(text)
    self.frame.tooltipText = text
end


--- GGUI.ScrollFrame

---@class GGUI.ScrollFrameConstructorOptions
---@field parent? Frame
---@field offsetTOP? number
---@field offsetLEFT? number
---@field offsetRIGHT? number
---@field offsetBOTTOM? number

---@class GGUI.ScrollFrame
GGUI.ScrollFrame = GGUI.Object:extend()
---@param options GGUI.ScrollFrameConstructorOptions
function GGUI.ScrollFrame:new(options)
    self.isGGUI = true
    options = options or {}
    options.offsetTOP = options.offsetTOP or 0
    options.offsetLEFT = options.offsetLEFT or 0
    options.offsetRIGHT = options.offsetRIGHT or 0
    options.offsetBOTTOM = options.offsetBOTTOM or 0

    local scrollFrame = CreateFrame("ScrollFrame", nil, options.parent, "UIPanelScrollFrameTemplate")
    scrollFrame.scrollChild = CreateFrame("frame")
    local scrollChild = scrollFrame.scrollChild
    scrollFrame:SetSize(options.parent:GetWidth() , options.parent:GetHeight())
    scrollFrame:SetPoint("TOP", options.parent, "TOP", 0, options.offsetTOP)
    scrollFrame:SetPoint("LEFT", options.parent, "LEFT", options.offsetLEFT, 0)
    scrollFrame:SetPoint("RIGHT", options.parent, "RIGHT", options.offsetRIGHT, 0)
    scrollFrame:SetPoint("BOTTOM", options.parent, "BOTTOM", 0, options.offsetBOTTOM)
    scrollFrame:SetScrollChild(scrollFrame.scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1)

    self.scrollFrame = scrollFrame
    self.content = scrollChild
end

function GGUI.ScrollFrame:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.content)
end

--- GGUI.TextInput

---@class GGUI.TextInputConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field initialValue? string
---@field autoFocus? boolean
---@field font? string
---@field onTextChangedCallback? function
---@field onEnterCallback? function Default: Clear Focus
---@field onEscapeCallback? function Default: Clear Focus

---@class GGUI.TextInput
GGUI.TextInput = GGUI.Widget:extend()
---@param options GGUI.TextInputConstructorOptions
function GGUI.TextInput:new(options)
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 25
    options.autoFocus = options.autoFocus or false
    options.font = options.font or "ChatFontNormal"
    options.initialValue = options.initialValue or ""
    self.onTextChangedCallback = options.onTextChangedCallback
    self.onEnterCallback = options.onEnterCallback
    self.onEscapeCallback = options.onEscapeCallback

    local textInput = CreateFrame("EditBox", nil, options.parent, "InputBoxTemplate")
    GGUI.TextInput.super.new(self, textInput)
    textInput:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    textInput:SetSize(options.sizeX, options.sizeY)
    textInput:SetAutoFocus(options.autoFocus) -- dont automatically focus
    textInput:SetFontObject(options.font)
    textInput:SetText(options.initialValue)
    textInput:SetScript("OnEscapePressed", function() 
        if self.oneEnterCallback then
            self.onEnterCallback(self)
        else
            textInput:ClearFocus() 
        end
    end)
    textInput:SetScript("OnEnterPressed", function() 
        if self.onEscapeCallback then
            self.onEscapeCallback(self)
        else
            textInput:ClearFocus() 
        end
    end)

    textInput:SetScript("OnTextChanged", function(_, userInput) 
        if self.onTextChangedCallback then
            self.onTextChangedCallback(self, self:GetText(), userInput)
        end
    end)
end

function GGUI.TextInput:GetText()
    return self.frame:GetText()
end
function GGUI.TextInput:SetText(text, userInput)
    self.frame:SetText(text)

    if self.onTextChangedCallback then
        self.onTextChangedCallback(self, self:GetText(), userInput)
    end
end

--- GGUI.CurrencyInput

---@class GGUI.CurrencyInputConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field initialValue? number
---@field onValueValidCallback? function
---@field onValidationChangedCallback? function
---@field showFormatHelpIcon? boolean
---@field borderAdjustWidth? number
---@field borderAdjustHeight? number
---@field borderWidth? number

---@class GGUI.CurrencyInput
GGUI.CurrencyInput = GGUI.Object:extend()

---@param options GGUI.CurrencyInputConstructorOptions
function GGUI.CurrencyInput:new(options)
    self.isGGUI = true
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 25
    options.initialValue = options.initialValue or 0
    options.borderAdjustWidth = options.borderAdjustWidth or 1
    options.borderAdjustHeight = options.borderAdjustHeight or 1
    options.borderWidth = options.borderWidth or 25
    options.showFormatHelpIcon = options.showFormatHelpIcon or false

    self.onValidationChangedCallback = options.onValidationChangedCallback
    self.onValueValidCallback = options.onValueValidCallback

    local currencyInput = self

    currencyInput.isValid = true

    currencyInput.total = 0
    currencyInput.gold = 0
    currencyInput.silver = 0
    currencyInput.copper = 0

    local textInput = GGUI.TextInput({
        parent=options.parent,
        anchorParent=options.anchorParent,
        anchorA=options.anchorA,
        anchorB=options.anchorB,
        offsetX=options.offsetX,
        offsetY=options.offsetY,
        sizeX=options.sizeX,
        sizeY=options.sizeY,
        initialValue=options.initialValue,
        onTextChangedCallback= function(self, input, userInput)             
            if userInput then
                -- validate and color text, and adapt save button
                input = input or ""
                -- remove colorizations    
                input = string.gsub(input, GUTIL.COLORS.GOLD, "")
                input = string.gsub(input, GUTIL.COLORS.SILVER, "")
                input = string.gsub(input, GUTIL.COLORS.COPPER, "")
                input = string.gsub(input, "|r", "")
                input = string.gsub(input, "|c", "")
    
                local valid = GUTIL:ValidateMoneyString(input)
                currencyInput.isValid = valid
    
                if valid then
                    -- colorize
                    local gold = tonumber(string.match(input, "(%d+)g")) or 0
                    local silver = tonumber(string.match(input, "(%d+)s")) or 0
                    local copper = tonumber(string.match(input, "(%d+)c")) or 0
                    local gC = GUTIL:ColorizeText("g", GUTIL.COLORS.GOLD)
                    local sC = GUTIL:ColorizeText("s", GUTIL.COLORS.SILVER)
                    local cC = GUTIL:ColorizeText("c", GUTIL.COLORS.COPPER)
                    local colorizedText = ((gold > 0 and (gold .. gC)) or "") .. ((silver > 0 and (silver .. sC)) or "") .. ((copper > 0 and (copper .. cC)) or "")
                    currencyInput.textInput:SetText(colorizedText)
    
    
                    currencyInput.gold = gold
                    currencyInput.silver = silver
                    currencyInput.copper = copper
                    currencyInput.total = gold*10000+silver*100+copper
                    if currencyInput.onValueValidCallback then
                        currencyInput.onValueValidCallback(currencyInput)
                    end    
                end

                
                currencyInput.border:SetValid(valid)
                
                if currencyInput.onValidationChangedCallback then
                    currencyInput.onValidationChangedCallback(valid)
                end
            end
        end,
    })

    self.textInput = textInput

    local validationBorder = CreateFrame("Frame", nil, textInput.frame, "BackdropTemplate")
    self.border = validationBorder
    validationBorder:SetSize(textInput:GetWidth()*1.3*options.borderAdjustWidth, textInput:GetHeight()*1.6*options.borderAdjustHeight)
    validationBorder:SetPoint("CENTER", textInput.frame, "CENTER", -2, 0)
    validationBorder:SetBackdrop({
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
        edgeSize = options.borderWidth,
    })
    function validationBorder:SetValid(valid) 
        if valid then
            validationBorder:Hide()
        else
            validationBorder:Show()
            validationBorder:SetBackdropBorderColor(1, 0, 0, 0.5)
        end
    end
    validationBorder:Hide()
    textInput.validationBorder = validationBorder

    self:SetValue(options.initialValue)

    if options.showFormatHelpIcon then
        self.helpIcon = GGUI.HelpIcon({
            parent=options.parent,
            text="Format: 100g10s1c", textInput.frame, anchorParent=textInput.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=5,
        })
    end
end

function GGUI.CurrencyInput:SetValue(total)
    local gold, silver, copper = GUTIL:GetMoneyValuesFromCopper(total)
    local gC = GUTIL:ColorizeText("g", GUTIL.COLORS.GOLD)
    local sC = GUTIL:ColorizeText("s", GUTIL.COLORS.SILVER)
    local cC = GUTIL:ColorizeText("c", GUTIL.COLORS.COPPER)
    local colorizedText = ((gold > 0 and (gold .. gC)) or "") .. ((silver > 0 and (silver .. sC)) or "") .. ((copper > 0 and (copper .. cC)) or "")
    self.textInput:SetText(colorizedText)

    self.gold = gold
    self.silver = silver
    self.copper = copper
    self.total = gold*10000+silver*100+copper
end

function GGUI.CurrencyInput:Show()
    self.textInput:Show()
    if self.helpIcon then
        self.helpIcon:Show()
    end
end
function GGUI.CurrencyInput:Hide()
    self.textInput:Hide()
    if self.helpIcon then
        self.helpIcon:Hide()
    end
end

--- GGUI.NumericInput

---@class GGUI.NumericInputConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field initialValue? number
---@field allowDecimals? boolean
---@field minValue? number
---@field maxValue? number
---@field autoFocus? boolean
---@field font? string
---@field onNumberValidCallback? function
---@field onValidationChangedCallback? function
---@field incrementOneButtons? boolean
---@field incrementFiveButtons? boolean
---@field borderAdjustWidth? number
---@field borderAdjustHeight? number
---@field borderWidth? number

---@class GGUI.NumericInput
GGUI.NumericInput = GGUI.Object:extend()
---@param options GGUI.NumericInputConstructorOptions
function GGUI.NumericInput:new(options)
    self.isGGUI = true
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100    
    options.sizeY = options.sizeY or 25
    options.initialValue = options.initialValue or 0 
    options.allowDecimals = options.allowDecimals or false
    options.autoFocus = options.autoFocus or false
    options.font = options.font or "ChatFontNormal"
    options.incrementOneButtons = options.incrementOneButtons or false
    options.incrementFiveButtons = options.incrementFiveButtons or false
    options.borderAdjustWidth = options.borderAdjustWidth or 1
    options.borderAdjustHeight = options.borderAdjustHeight or 1
    options.borderWidth = options.borderWidth or 25
    self.onNumberValidCallback = options.onNumberValidCallback
    self.onValidationChangedCallback = options.onValidationChangedCallback
    self.allowDecimals = options.allowDecimals
    self.autoFocus = options.autoFocus
    self.minValue = options.minValue
    self.maxValue = options.maxValue

    local numericInput = self

    self.textInput = GGUI.TextInput({
        parent=options.parent,
        anchorParent=options.anchorParent,
        anchorA=options.anchorA,
        anchorB=options.anchorB,
        offsetX=options.offsetX,
        offsetY=options.offsetY,
        sizeX=options.sizeX,
        sizeY=options.sizeY,
        initialValue=options.initialValue,
        autoFocus=options.autoFocus,
        onTextChangedCallback=function (textInput, input, userInput)
            if userInput then
                local valid = GUTIL:ValidateNumberString(input, self.minValue, self.maxValue, self.allowDecimals)
                if valid then
                    textInput:SetText(input)
                    if numericInput.onNumberValidCallback then
                        numericInput.onNumberValidCallback(numericInput)
                    end
                else
                end
                numericInput.validationBorder:SetValid(valid)
                if numericInput.onValidationChangedCallback then
                    numericInput.onValidationChangedCallback(valid)
                end
            end
        end,
    })

    if options.incrementOneButtons then
        local buttonWidth = 5
        local buttonHeight = options.sizeY / 2 - 1
        local buttonOffsetX = 0
        local buttonOffsetY = -1
        self.textInput.frame.plusButton = GGUI.Button({
            parent=self.textInput.frame,
            anchorParent=self.textInput.frame,
            anchorA="TOPLEFT",
            anchorB="TOPRIGHT",
            offsetX=buttonOffsetX,
            offsetY=buttonOffsetY,
            label="+",
            sizeX=buttonWidth,
            sizeY=buttonHeight,
            adjustWidth=true,
            clickCallback=function ()
                local input = tonumber(numericInput.textInput:GetText())
                if input then
                    local valid = GUTIL:ValidateNumberString(tostring(input + 1), self.minValue, self.maxValue, self.allowDecimals)   
                    
                    if valid then
                        numericInput.textInput:SetText(input + 1)
                        if numericInput.onNumberValidCallback then
                            numericInput.onNumberValidCallback(numericInput)
                        end
                    end

                    if numericInput.onValidationChangedCallback then
                        numericInput.onValidationChangedCallback(valid)
                    end
                end
            end,
        })
        self.textInput.frame.minusButton = GGUI.Button({
            parent=self.textInput.frame,
            anchorParent=self.textInput.frame.plusButton.frame,
            anchorA="TOP",
            anchorB="BOTTOM",
            label="-",
            sizeX=buttonWidth,
            sizeY=buttonHeight,
            adjustWidth=true,
            clickCallback=function ()
                local input = tonumber(numericInput.textInput:GetText())
                if input then
                    local valid = GUTIL:ValidateNumberString(tostring(input - 1), self.minValue, self.maxValue, self.allowDecimals)   
                    
                    if valid then
                        numericInput.textInput:SetText(input - 1)
                        if numericInput.onNumberValidCallback then
                            numericInput.onNumberValidCallback(numericInput)
                        end
                    end

                    if numericInput.onValidationChangedCallback then
                        numericInput.onValidationChangedCallback(valid)
                    end
                end
            end,
        })
    end

    local validationBorder = CreateFrame("Frame", nil, self.textInput.frame, "BackdropTemplate")
    self.border = validationBorder
    validationBorder:SetSize(self.textInput.frame:GetWidth()*1.3*options.borderAdjustWidth, self.textInput.frame:GetHeight()*1.6*options.borderAdjustHeight)
    validationBorder:SetPoint("CENTER", self.textInput.frame, "CENTER", -2, 0)
    validationBorder:SetBackdrop({
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
        edgeSize = options.borderWidth,
    })
    function validationBorder:SetValid(valid) 
        if valid then
            validationBorder:Hide()
        else
            validationBorder:Show()
            validationBorder:SetBackdropBorderColor(1, 0, 0, 0.5)
        end
    end
    validationBorder:Hide()
    self.validationBorder = validationBorder
end

--- GGUI.FrameList

---@class GGUI.FrameList
GGUI.FrameList = GGUI.Widget:extend()

---@class GGUI.FrameListConstructorOptions
---@field parent? Frame
---@field rowHeight? number
---@field columnOptions GGUI.FrameList.ColumnOption[]
---@field rowConstructor function used to construct the rows and fill the column frames with content, columns are forwarded as params (...)
---@field showHeaderLine? boolean
---@field showBorder? boolean
---@field headerLineRGBA? table
---@field borderLinesRGBA? table
---@field anchorParent? Frame
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number if omitted will adjust to row width
---@field sizeY? number
---@field headerOffsetX? number

---@class GGUI.FrameList.ColumnOption
---@field width? number
---@field label? string
---@field justifyOptions? GGUI.JustifyOptions

function GGUI.FrameList:new(options)
    self.isGGUI = true
    ---@type GGUI.FrameListConstructorOptions
    options = options or {}
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    options.sizeY = options.sizeY or 100
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.rowHeight = options.rowHeight or 25
    options.headerOffsetX = options.headerOffsetX or 5
    self.rowHeight = options.rowHeight
    
    if not options.columnOptions or #options.columnOptions == 0 then
        error("GGUI Error: FrameList needs a least one column! (columnOptions)")
    end
    
    if not options.rowConstructor then
        error("GGUI Error: FrameList needs a rowConstructor function!")
        end
        
        local firstColumnOffsetX = 0
        local rowWidth = firstColumnOffsetX
        
        table.foreach(options.columnOptions, function (_, columnOption)
            if not columnOption.width then
                error("GGUI Error: All columnOptions need a width property!")
            end
            rowWidth = rowWidth + columnOption.width
        end)
    self.rowWidth = rowWidth
    self.columnOptions = options.columnOptions
    self.rowConstructor = options.rowConstructor 

    local mainFrame = CreateFrame("Frame", nil, options.parent) 
    mainFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    mainFrame:SetSize(options.sizeX or (rowWidth + 10), options.sizeY)
    
    ---@type GGUI.ScrollFrame
    self.scrollFrame = GGUI.ScrollFrame({
        parent=mainFrame,
        offsetTOP=-5,
        offsetLEFT=5,
        offsetRIGHT=-5,
        offsetBOTTOM=5,
    })
    
    self.rows = {}
    
    local header = CreateFrame("Frame", nil, mainFrame)
    header:SetPoint("BOTTOMLEFT", mainFrame, "TOPLEFT")
    header:SetSize(rowWidth, 25)
    
    local lastHeaderColumn = nil
    for index, columnOption in pairs(options.columnOptions) do
        local headerColumn = CreateFrame("Frame", nil, header)
        headerColumn:SetSize(columnOption.width, 25)
        
        headerColumn.text = GGUI.Text({
            fixedWidth=columnOption.width, text=columnOption.label or "",
            parent=headerColumn, anchorParent=headerColumn, justifyOptions=columnOption.justifyOptions or {type="H", align="LEFT"},
        })
        
        if index == 1 then
            headerColumn:SetPoint("TOPLEFT", header ,"TOPLEFT", options.headerOffsetX, 0)
        else
            headerColumn:SetPoint("LEFT", lastHeaderColumn ,"RIGHT")
        end
        
        lastHeaderColumn = headerColumn
    end

    if options.showHeaderLine or options.showBorder then
        local headerRGBA = options.headerLineRGBA or {1, 1, 1, 1} -- Default: white
        local left = mainFrame:CreateLine()
        left:SetColorTexture(headerRGBA[1],headerRGBA[2],headerRGBA[3],headerRGBA[4]) -- TODO: create option
        left:SetThickness(1) -- TODO: as option
        left:SetStartPoint("TOPLEFT", 0, 0)
        left:SetEndPoint("TOPRIGHT", 0, 0)
    end

    if options.showBorder then
        local borderRGBA = options.borderLinesRGBA or {1, 1, 1, 1} -- Default: white
        -- left
        local left = mainFrame:CreateLine()
        left:SetColorTexture(borderRGBA[1],borderRGBA[2],borderRGBA[3],borderRGBA[4]) -- TODO: create option
        left:SetThickness(1) -- TODO: as option
        left:SetStartPoint("TOPLEFT", 0, 0)
        left:SetEndPoint("BOTTOMLEFT", 0, 0)

        -- right
        local right = mainFrame:CreateLine()
        right:SetColorTexture(borderRGBA[1],borderRGBA[2],borderRGBA[3],borderRGBA[4]) -- TODO: create option
        right:SetThickness(1) -- TODO: as option
        right:SetStartPoint("TOPRIGHT", 0, 0)
        right:SetEndPoint("BOTTOMRIGHT", 0, 0)

        -- bottom
        local right = mainFrame:CreateLine()
        right:SetColorTexture(borderRGBA[1],borderRGBA[2],borderRGBA[3],borderRGBA[4]) -- TODO: create option
        right:SetThickness(1) -- TODO: as option
        right:SetStartPoint("BOTTOMLEFT", 0, 0)
        right:SetEndPoint("BOTTOMRIGHT", 0, 0)
    end

    GGUI.FrameList.super.new(self, mainFrame)
end

--- GGUI.FrameList.Row

---@class GGUI.FrameList.Row
GGUI.FrameList.Row = GGUI.Widget:extend()

---@param rowFrame Frame
---@param columns Frame[]
---@param rowConstructor function
function GGUI.FrameList.Row:new(rowFrame, columns, rowConstructor)
    GGUI.FrameList.Row.super.new(self, rowFrame)
    self.columns = columns
    self.active=false
    rowConstructor(self.columns)
    self:Hide()
end

function GGUI.FrameList:CreateRow()

    local rowFrame = CreateFrame("Frame", nil, self.scrollFrame.content)
    rowFrame:SetSize(self.rowWidth, self.rowHeight)
    if #self.rows == 0 then
        rowFrame:SetPoint("TOPLEFT", self.scrollFrame.content, "TOPLEFT")
    else
        rowFrame:SetPoint("TOPLEFT", self.rows[#self.rows].frame, "BOTTOMLEFT")
    end
    
    local columns = {}
    local lastColumn = nil
    for index, columnOption in pairs(self.columnOptions) do
        local columnFrame = CreateFrame("Frame", nil, rowFrame)
        columnFrame:SetSize(columnOption.width, self.rowHeight)

        if index == 1 then
            columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
        else
            columnFrame:SetPoint("LEFT", lastColumn, "RIGHT")
        end

        table.insert(columns, columnFrame)

        lastColumn = columnFrame
    end

    local newRow = GGUI.FrameList.Row(rowFrame, columns, self.rowConstructor)

    table.insert(self.rows, newRow)

    return newRow
end

---Add row data into the list
---@param fillFunc? function function that receives a free row to add to the list
function GGUI.FrameList:Add(fillFunc)
    -- get an inactive row from the list of rows, call fillFunc on it
    local freeRow = GUTIL:Find(self.rows, function(row) return not row.active end)

    if not freeRow then
        -- create a new row if no row is free
        freeRow = self:CreateRow()
    end
    if fillFunc then
        fillFunc(freeRow)
    end
    freeRow.active = true
end

---@param updateFunc function -- receives the found row as parameter
---@param filterFunc function -- receives a row as parameter to filter
---@param limit? number -- optional limit of max updates
function GGUI.FrameList:UpdateRows(updateFunc, filterFunc, limit)
    local count = 0
    for _, row in pairs(self.rows) do
        if row.active then
            count = count + 1
            if filterFunc(row) then
                updateFunc(row)
            end

            if limit and count >= limit then
                return
            end
        end
    end
end

function GGUI.FrameList:GetRow(filterFunc)
    for _, row in pairs(self.rows) do
        if row.active and filterFunc(row) then
            return row
        end
    end
end

--- removes all (up to the limit) rows where filterFunc is true from the list
---@param filterFunc? function -- param: row
---@param limit? number
function GGUI.FrameList:Remove(filterFunc, limit)
    local currentRemoveCount = 0
    for _, row in pairs(self.rows) do
        if row.active then
            if (filterFunc and filterFunc(row)) or (not filterFunc) then
                row.active = false
                currentRemoveCount = currentRemoveCount + 1

                if limit and currentRemoveCount >= limit then
                    return
                end
            end
        end
    end
end

--- Update the list display, optionally filter then show all active rows
---@param sortFunc? function -- sortFunc(rowA, rowB) optional sorting before updating the display
function GGUI.FrameList:UpdateDisplay(sortFunc)
    -- filter and show active rows and hide all inactive
    ---@type GGUI.FrameList.Row[] | GGUI.Widget[]
    local activeRows = GUTIL:Filter(self.rows, function(row) 
        if row.active then
            row:Show()
            return true
        else
            row:Hide()
            return false
        end
    end)

    if #activeRows == 0 then
        return
    end

    if #activeRows > 1 and sortFunc then
        activeRows = GUTIL:Sort(activeRows, sortFunc)
    end

    local lastRow = nil
    for index, row in pairs(activeRows) do
        if index == 1 then
            row:SetPoint("TOPLEFT", self.scrollFrame.content, "TOPLEFT")
        else
            row:SetPoint("TOPLEFT", lastRow.frame, "BOTTOMLEFT")
        end
        lastRow = row
    end
end


---@class GGUI.ShowPopupOptions
---@field title? string
---@field text? string
---@field acceptButtonLabel? string
---@field declineButtonLabel? string
---@field onAccept? function
---@field onDecline? function
---@field sizeX? number
---@field sizeY? number
---@field parent? Frame
---@field anchorParent? Region
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint

local popupFrame = nil
---@param options GGUI.ShowPopupOptions
function GGUI:ShowPopup(options)
    if not popupFrame then
        error("GGUI Error: Popup Frame not initialized")
    end
    options.title = options.title or nil
    options.text = options.text or ""
    options.acceptButtonLabel = options.acceptButtonLabel or "Accept"
    options.declineButtonLabel = options.declineButtonLabel or "Decline"
    options.width = options.width or 300
    options.height = options.height or 300
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"

    if options.title then
        popupFrame.title:SetText(options.title)
    end
    popupFrame.content.text:SetText(options.text)
    popupFrame.onAccept = options.onAccept
    popupFrame.content.acceptButton.frame:SetText(options.acceptButtonLabel)
    popupFrame.content.acceptButton.frame:SetWidth(popupFrame.content.acceptButton.frame:GetTextWidth() + 15)
    popupFrame.onDecline = options.onDecline
    popupFrame.content.declineButton.frame:SetText(options.declineButtonLabel)
    popupFrame.content.declineButton.frame:SetWidth(popupFrame.content.declineButton.frame:GetTextWidth() + 15)

    if options.sizeX then
        popupFrame.frame:SetWidth(options.sizeX)
    end
    if options.sizeY then
        popupFrame.frame:SetHeight(options.sizeY)
    end

    popupFrame.frame:ClearAllPoints()
    popupFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)

    popupFrame:Show()
end

---@class GGUI.InitPopupOptions
---@field backdropOptions GGUI.BackdropOptions
---@field title? string
---@field sizeX? number
---@field sizeY? number
---@field frameID? string

---@param options GGUI.InitPopupOptions
function GGUI:InitializePopup(options)
    ---@type GGUI.Frame | GGUI.Widget
        popupFrame = CraftSim.GGUI.Frame({
            backdropOptions = options.backdropOptions,
            sizeX=options.sizeX or 300, sizeY=options.sizeY or 300, moveable=true, frameStrata="DIALOG", frameID=options.frameID,
            title=options.title or "", closeable=true,
        })

        popupFrame.content.text = CraftSim.GGUI.Text({
            parent=popupFrame.content, anchorParent=popupFrame.title.frame, anchorA="TOP", anchorB="BOTTOM", offsetY=-20,
        })

        popupFrame.content.acceptButton = CraftSim.GGUI.Button({
            parent=popupFrame.content, anchorParent=popupFrame.frame, anchorA="BOTTOMLEFT", anchorB="BOTTOMLEFT", offsetX=10, offsetY=10,
            label="Accept", clickCallback=function ()
                if popupFrame.onAccept then
                    popupFrame.onAccept()
                end
                popupFrame:Hide()
            end
        })
        popupFrame.content.declineButton = CraftSim.GGUI.Button({
            parent=popupFrame.content, anchorParent=popupFrame.frame, anchorA="BOTTOMRIGHT", anchorB="BOTTOMRIGHT", offsetX=-10, offsetY=10,
            label="Decline", clickCallback=function ()
                if popupFrame.onDecline then
                    popupFrame.onDecline()
                end
                popupFrame:Hide()
            end
        })

        popupFrame:Hide()

        CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(popupFrame.content)
end