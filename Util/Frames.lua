---@class CraftSim
local CraftSim = select(2, ...)
local CraftSimAddonName = select(1, ...)

---@class CraftSim.FRAME
CraftSim.FRAME = {}

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

CraftSim.FRAME.frames = {}

local print = CraftSim.DEBUG:RegisterDebugID("Util.Frames")

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
    local recipeScanFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.RECIPE_SCAN)
    local customerHistoryFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
    local priceOverrideFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
    local priceOverrideFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
    local specInfoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
    local specInfoFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
    local averageProfitFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.AVERAGE_PROFIT)
    local averageProfitFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.AVERAGE_PROFIT_WO)
    local topgearFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
    local topgearFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
    local reagentOptimizationFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION)
    local reagentOptimizationFrameWO = GGUI:GetFrame(CraftSim.INIT.FRAMES,
        CraftSim.CONST.FRAMES.REAGENT_OPTIMIZATION_WORK_ORDER)
    local debugFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.DEBUG)
    local infoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.INFO)

    infoFrame:RestoreSavedConfig(UIParent)
    debugFrame:RestoreSavedConfig(UIParent)
    CraftSim.RECIPE_SCAN.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.CRAFT_LOG.logFrame:RestoreSavedConfig(UIParent)
    CraftSim.CRAFT_LOG.advFrame:RestoreSavedConfig(UIParent)
    CraftSim.CUSTOMER_HISTORY.frame:RestoreSavedConfig(ProfessionsFrame)
    priceOverrideFrame:RestoreSavedConfig(ProfessionsFrame)
    priceOverrideFrameWO:RestoreSavedConfig(ProfessionsFrame)
    specInfoFrame:RestoreSavedConfig(ProfessionsFrame)
    specInfoFrameWO:RestoreSavedConfig(ProfessionsFrame)
    averageProfitFrame:RestoreSavedConfig(ProfessionsFrame)
    averageProfitFrameWO:RestoreSavedConfig(ProfessionsFrame)
    topgearFrame:RestoreSavedConfig(ProfessionsFrame)
    topgearFrameWO:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.PRICE_DETAILS.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.PRICE_DETAILS.frameWO:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.COST_OPTIMIZATION.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.COST_OPTIMIZATION.frameWO:RestoreSavedConfig(ProfessionsFrame)
    reagentOptimizationFrame:RestoreSavedConfig(ProfessionsFrame)
    reagentOptimizationFrameWO:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.CRAFTQ.frame:RestoreSavedConfig(ProfessionsFrame)

    CraftSim.CRAFT_BUFFS.frame:RestoreSavedConfig(ProfessionsFrame.CraftingPage)
    CraftSim.CRAFT_BUFFS.frameWO:RestoreSavedConfig(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
    CraftSim.STATISTICS.frameNO_WO:RestoreSavedConfig(ProfessionsFrame.CraftingPage)
    CraftSim.STATISTICS.frameWO:RestoreSavedConfig(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
    CraftSim.EXPLANATIONS.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.COOLDOWNS.frame:RestoreSavedConfig(ProfessionsFrame)

    CraftSim.CONCENTRATION_TRACKER.trackerFrame:RestoreSavedConfig(CraftSim.CONCENTRATION_TRACKER.frame.frame)
end

function CraftSim.FRAME:ResetFrames()
    for _, frame in pairs(CraftSim.INIT.FRAMES) do
        print(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.FRAMES_RESETTING) .. tostring(frame.frameID))
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

--> in GGUI.ScrollingMessageFrame
---@deprecated
function CraftSim.FRAME:CreateScrollingMessageFrame(parent, anchorParent, anchorA, anchorB, anchorX, anchorY, maxLines,
                                                    sizeX, sizeY)
    local scrollingFrame = CreateFrame("ScrollingMessageFrame", nil, parent)
    scrollingFrame:SetSize(sizeX, sizeY)
    scrollingFrame:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
    scrollingFrame:SetFontObject(GameFontHighlight)
    if maxLines then
        scrollingFrame:SetMaxLines(maxLines)
    end
    scrollingFrame:SetFading(false) -- make optional
    scrollingFrame:SetJustifyH("LEFT")
    scrollingFrame:EnableMouseWheel(true)

    scrollingFrame:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            scrollingFrame:ScrollUp()
        elseif delta < 0 then
            scrollingFrame:ScrollDown()
        end
    end)

    return scrollingFrame
end

--> in GGUI.Checkbox
---@deprecated
function CraftSim.FRAME:CreateCheckboxCustomCallback(label, description, initialValue, clickCallback, parent,
                                                     anchorParent, anchorA, anchorB, offsetX, offsetY)
    local checkBox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkBox:SetHitRectInsets(0, 0, 0, 0); -- see https://wowpedia.fandom.com/wiki/API_Frame_SetHitRectInsets
    checkBox:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    checkBox.Text:SetText(label)
    checkBox.tooltip = description
    -- there already is an existing OnClick script that plays a sound, hook it
    checkBox:SetChecked(false)
    checkBox:HookScript("OnClick", function()
        clickCallback(checkBox) -- "self"
    end)

    if initialValue then
        checkBox:Click()
    end

    return checkBox
end

--> in GGUI.HelpIcon
---@deprecated
function CraftSim.FRAME:CreateHelpIcon(text, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local helpButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    helpButton.tooltipText = text
    helpButton:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    helpButton:SetText("?")
    helpButton:SetSize(helpButton:GetTextWidth() + 15, 15)

    helpButton.SetTooltipText = function(newText)
        helpButton.tooltipText = newText
    end

    helpButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(self.tooltipText)
        GameTooltip:Show()
    end)
    helpButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    return helpButton
end

function CraftSim.FRAME:InitOneTimeNoteFrame()
    local currentVersion = C_AddOns.GetAddOnMetadata(CraftSimAddonName, "Version")

    local f = GUTIL:GetFormatter()

    local frame = GGUI.Frame({
        parent = UIParent,
        anchorParent = UIParent,
        sizeX = 500,
        sizeY = 300,
        frameID = CraftSim.CONST.FRAMES.INFO,
        closeable = true,
        scrollableContent = true,
        moveable = true,
        title = GUTIL:ColorizeText(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.FRAMES_WHATS_NEW) .. " (" .. currentVersion .. ")",
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
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.FRAMES_JOIN_DISCORD), frame.content, frame.content.discordBox,
        "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.donateBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", 120, -20, 250, 30, CraftSim.CONST.KOFI_URL, function()
            -- do not let the player remove the link
            frame.content.donateBox:SetText(CraftSim.CONST.KOFI_URL)
        end)
    frame.content.donateBox:SetScale(0.75)
    frame.content.donateBoxLabel = CraftSim.FRAME:CreateText(
        f.patreon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.FRAMES_DONATE_KOFI)), frame.content, frame.content
        .donateBox, "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.infoText:SetPoint("TOP", frame.content, "TOP", 10, -45)
    frame.content.infoText:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.FRAMES_NO_INFO))
    frame.content.infoText:SetJustifyH("LEFT")

    frame.showInfo = function(infoText)
        frame.content.infoText:SetText(infoText)
        frame:Show()
    end

    GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
    frame:Hide()
end

---> GGUI
---@deprecated
function CraftSim.FRAME:CreateScrollFrame(parent, offsetTOP, offsetLEFT, offsetRIGHT, offsetBOTTOM)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame.scrollChild = CreateFrame("frame")
    local scrollChild = scrollFrame.scrollChild
    scrollFrame:SetSize(parent:GetWidth(), parent:GetHeight())
    scrollFrame:SetPoint("TOP", parent, "TOP", 0, offsetTOP)
    scrollFrame:SetPoint("LEFT", parent, "LEFT", offsetLEFT, 0)
    scrollFrame:SetPoint("RIGHT", parent, "RIGHT", offsetRIGHT, 0)
    scrollFrame:SetPoint("BOTTOM", parent, "BOTTOM", 0, offsetBOTTOM)
    scrollFrame:SetScrollChild(scrollFrame.scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1)
    return scrollFrame, scrollChild
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

--> in GGUI.NumericInput
---@deprecated
function CraftSim.FRAME:CreateNumericInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY,
                                           initialValue, allowNegative, onTextChangedCallback)
    local numericInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    numericInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    numericInput:SetSize(sizeX, sizeY)
    numericInput:SetAutoFocus(false) -- dont automatically focus
    numericInput:SetFontObject("ChatFontNormal")
    numericInput:SetText(initialValue)
    numericInput:SetScript("OnEscapePressed", function() numericInput:ClearFocus() end)
    numericInput:SetScript("OnEnterPressed", function() numericInput:ClearFocus() end)
    numericInput:SetScript("OnTextChanged", onTextChangedCallback)

    -- blizzard's NumericInputSpinnerTemplate is ugly and not configurable enough, so I make my own duh!

    local buttonWidth = 5
    local buttonHeight = sizeY / 2 - 1
    local buttonOffsetX = 0
    local buttonOffsetY = -1
    numericInput.plusButton = CreateFrame("Button", nil, numericInput, "UIPanelButtonTemplate")
    numericInput.plusButton:SetPoint("TOPLEFT", numericInput, "TOPRIGHT", buttonOffsetX, buttonOffsetY)
    numericInput.plusButton:SetText("+")
    numericInput.plusButton:SetSize(numericInput.plusButton:GetTextWidth() + buttonWidth, buttonHeight) -- make it smol
    numericInput.plusButton:SetScript("OnClick", function(self)
        local currentValue = CraftSim.UTIL:ValidateNumberInput(numericInput, allowNegative)
        numericInput:SetText(currentValue + 1)
        onTextChangedCallback(numericInput, true) -- is the input "self" now? .. yes it is :D
    end)

    numericInput.minusButton = CreateFrame("Button", nil, numericInput, "UIPanelButtonTemplate")
    numericInput.minusButton:SetPoint("TOP", numericInput.plusButton, "BOTTOM", 0, 0)
    numericInput.minusButton:SetText("-")
    numericInput.minusButton:SetSize(numericInput.minusButton:GetTextWidth() + buttonWidth, buttonHeight) -- make it smol
    numericInput.minusButton:SetScript("OnClick", function(self)
        local currentValue = CraftSim.UTIL:ValidateNumberInput(numericInput, allowNegative)
        numericInput:SetText(currentValue - 1)
        onTextChangedCallback(numericInput, true) -- is the input "self" now? .. yes it is :D
    end)

    return numericInput
end
