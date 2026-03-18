---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local L = CraftSim.UTIL:GetLocalizer()
local f = GUTIL:GetFormatter()

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---@class CraftSim.WIDGETS.QualityMeter.ConstructorOptions
---@field parent Frame
---@field anchorParent Frame?
---@field anchorA string?
---@field anchorB string?
---@field anchorPoints GGUI.AnchorPoint[]?
---@field offsetX number?
---@field offsetY number?
---@field sizeX number?

---@class CraftSim.WIDGETS.QualityMeter : CraftSim.Object
---@overload fun(options: CraftSim.WIDGETS.QualityMeter.ConstructorOptions): CraftSim.WIDGETS.QualityMeter
---@field frame Frame
CraftSim.WIDGETS.QualityMeter = CraftSim.Object:extend()

local ICON_SIZE = 30
local BAR_HEIGHT = 16
local WIDGET_HEIGHT = 80
local BAR_OFFSET_X = 7
local BAR_OFFSET_Y = -4
local SKILL_TEXT_OFFSET_Y = 2
local LABEL_TEXT_OFFSET_Y = -4
local QUALITY_ICON_SCALE = 1.5
local BAR_COLOR_NORMAL = { r = 0.0, g = 0.7, b = 0.0, a = 0.9 }
local BAR_COLOR_CONCENTRATION = { r = 1.0, g = 0.8, b = 0.0, a = 1.0 }

---@param options CraftSim.WIDGETS.QualityMeter.ConstructorOptions
function CraftSim.WIDGETS.QualityMeter:new(options)
    options = options or {}

    local sizeX = options.sizeX or 260
    local parent = options.parent

    local frame = CreateFrame("Frame", nil, parent)
    self.frame = frame
    frame:SetSize(sizeX, WIDGET_HEIGHT)
    if options.anchorPoints then
        GGUI:SetPointsByAnchorPoints(frame, options.anchorPoints)
    else
        local anchorParent = options.anchorParent or parent
        frame:SetPoint(
            options.anchorA or "CENTER",
            anchorParent,
            options.anchorB or "CENTER",
            options.offsetX or 0,
            options.offsetY or 0
        )
    end

    local barWidth = sizeX - ICON_SIZE * 2 - 14

    -- Current quality item icon (left side)
    frame.currentQualityIcon = GGUI.Icon {
        parent = frame,
        anchorParent = frame,
        anchorA = "LEFT",
        anchorB = "LEFT",
        sizeX = ICON_SIZE,
        sizeY = ICON_SIZE,
        offsetX = 0,
        offsetY = -4,
        qualityIconScale = QUALITY_ICON_SCALE,
    }

    -- Next quality item icon (right side)
    frame.nextQualityIcon = GGUI.Icon {
        parent = frame,
        anchorParent = frame,
        anchorA = "RIGHT",
        anchorB = "RIGHT",
        sizeX = ICON_SIZE,
        sizeY = ICON_SIZE,
        offsetX = 0,
        offsetY = -4,
        qualityIconScale = QUALITY_ICON_SCALE,
    }

    -- Bar background texture
    local barBg = frame:CreateTexture(nil, "BACKGROUND")
    barBg:SetPoint("LEFT", frame.currentQualityIcon.frame, "RIGHT", BAR_OFFSET_X, BAR_OFFSET_Y)
    barBg:SetSize(barWidth, BAR_HEIGHT)
    barBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    barBg:SetVertexColor(0.2, 0.2, 0.2, 0.9)
    frame.barBg = barBg

    -- The actual status bar (fill)
    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetPoint("LEFT", frame.currentQualityIcon.frame, "RIGHT", BAR_OFFSET_X, BAR_OFFSET_Y)
    bar:SetSize(barWidth, BAR_HEIGHT)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(BAR_COLOR_NORMAL.r, BAR_COLOR_NORMAL.g, BAR_COLOR_NORMAL.b, BAR_COLOR_NORMAL.a)
    frame.bar = bar
    frame.barWidth = barWidth

    -- Bar border
    local barBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    barBorder:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 1)
    barBorder:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
    barBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 4,
    })
    barBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)

    -- Current skill text (positioned above the fill level during Update)
    frame.currentSkillText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.currentSkillText:SetPoint("BOTTOM", bar, "BOTTOMLEFT", 0, BAR_HEIGHT + SKILL_TEXT_OFFSET_Y)
    frame.currentSkillText:SetText("")

    -- "Needed: X" text (below bar left)
    frame.neededSkillText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.neededSkillText:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, LABEL_TEXT_OFFSET_Y)
    frame.neededSkillText:SetText("")

    -- "Missing: X" text (below bar right)
    frame.missingSkillText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.missingSkillText:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, LABEL_TEXT_OFFSET_Y)
    frame.missingSkillText:SetText("")

    frame:Hide()
end

--- Update the quality meter with current recipe data
---@param recipeData CraftSim.RecipeData
---@param thresholds number[]
function CraftSim.WIDGETS.QualityMeter:Update(recipeData, thresholds)
    if not recipeData or not recipeData.supportsQualities then
        self.frame:Hide()
        return
    end

    self.frame:Show()

    local currentQuality = recipeData.resultData.expectedQuality
    local maxQuality = recipeData.maxQuality
    local currentSkill = GUTIL:Round(recipeData.professionStats.skill.value, 0)
    local hasNextQuality = currentQuality < maxQuality
    local isConcentrating = recipeData.concentrating

    -- Update item icons with actual result items
    local currentItem = recipeData.resultData.itemsByQuality[currentQuality]
    if currentItem then
        self.frame.currentQualityIcon:SetItem(currentItem)
    end

    if hasNextQuality then
        local nextItem = recipeData.resultData.itemsByQuality[currentQuality + 1]
        if nextItem then
            self.frame.nextQualityIcon:SetItem(nextItem)
        end
        self.frame.nextQualityIcon.frame:Show()
    else
        -- Show max quality item on right side too
        local maxItem = recipeData.resultData.itemsByQuality[maxQuality]
        if maxItem then
            self.frame.nextQualityIcon:SetItem(maxItem)
        end
        self.frame.nextQualityIcon.frame:Show()
    end

    if isConcentrating then
        -- When concentration is active: fill bar fully with gold color, hide skill text
        local c = BAR_COLOR_CONCENTRATION
        self.frame.bar:SetStatusBarColor(c.r, c.g, c.b, c.a)
        self.frame.bar:SetMinMaxValues(0, 1)
        self.frame.bar:SetValue(1)

        self.frame.currentSkillText:SetText("")

        self.frame.neededSkillText:SetText("")
        self.frame.missingSkillText:SetText(f.gold(L(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_METER_MAX)))
        return
    end

    -- Normal mode: green bar
    local c = BAR_COLOR_NORMAL
    self.frame.bar:SetStatusBarColor(c.r, c.g, c.b, c.a)

    if hasNextQuality then
        local nextThreshold = thresholds[currentQuality] or 0
        local missingSkill = math.max(nextThreshold - currentSkill, 0)

        -- Update bar
        self.frame.bar:SetMinMaxValues(0, math.max(nextThreshold, 1))
        self.frame.bar:SetValue(math.min(currentSkill, nextThreshold))

        -- Position current skill text above the fill endpoint on the bar
        local barWidth = self.frame.barWidth
        local fillFraction = math.min(currentSkill / math.max(nextThreshold, 1), 1)
        local fillX = math.max(barWidth * fillFraction, 0)

        self.frame.currentSkillText:ClearAllPoints()
        self.frame.currentSkillText:SetPoint("BOTTOM", self.frame.bar, "BOTTOMLEFT", fillX, BAR_HEIGHT + SKILL_TEXT_OFFSET_Y)
        self.frame.currentSkillText:SetText(f.l(currentSkill))

        -- Update bottom labels
        self.frame.neededSkillText:SetText(L(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_METER_NEEDED) ..
            f.bb(nextThreshold))
        if missingSkill > 0 then
            self.frame.missingSkillText:SetText(L(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_METER_MISSING) ..
                f.r(missingSkill))
        else
            self.frame.missingSkillText:SetText(f.g(L(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_METER_MAX)))
        end
    else
        -- At max quality: full green bar
        local maxThreshold = (thresholds and thresholds[maxQuality - 1]) or currentSkill
        local barMax = math.max(maxThreshold, currentSkill, 1)
        self.frame.bar:SetMinMaxValues(0, barMax)
        self.frame.bar:SetValue(math.min(currentSkill, barMax))

        local barWidth = self.frame.barWidth
        local fillFraction = math.min(currentSkill / barMax, 1)
        local fillX = math.max(barWidth * fillFraction, 0)

        self.frame.currentSkillText:ClearAllPoints()
        self.frame.currentSkillText:SetPoint("BOTTOM", self.frame.bar, "BOTTOMLEFT", fillX, BAR_HEIGHT + SKILL_TEXT_OFFSET_Y)
        self.frame.currentSkillText:SetText(f.l(currentSkill))

        self.frame.neededSkillText:SetText("")
        self.frame.missingSkillText:SetText(f.g(L(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_METER_MAX)))
    end
end
