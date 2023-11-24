CraftSimAddonName, CraftSim = ...

CraftSim.FRAME = {}

CraftSim.FRAME.frames = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.FRAMES) 

--> in GGUI
function CraftSim.FRAME:GetFrame(frameID)
    local frameName = CraftSim.FRAME.frames[frameID]
    if not frameName then
        error("CraftSim Error: Frame not found: " .. tostring(frameID))
    end
    return _G[frameName]
end

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
    return sign .. CraftSim.GUTIL:Round(statDiff, roundTo) .. suffix
end

--> in GGUI in gFrame
function CraftSim.FRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

--> in GGUI.TabSystem
function CraftSim.FRAME:InitTabSystem(tabs)
    if #tabs == 0 then
        return
    end
    -- show first tab
    for _, tab in pairs(tabs) do
        tab:SetScript("OnClick", function(self) 
            for _, otherTab in pairs(tabs) do
                otherTab.content:Hide()
                otherTab:SetEnabled(otherTab.canBeEnabled)
            end
            tab.content:Show()
            tab:SetEnabled(false)
        end)
        tab.content:Hide()
    end
    tabs[1].content:Show()
    tabs[1]:SetEnabled(false)
end

--> in GGUI
function CraftSim.FRAME:makeFrameMoveable(frame)
	frame.hookFrame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, button)
		frame.hookFrame:StartMoving()
		end)
		frame:SetScript("OnMouseUp", function(self, button)
		frame.hookFrame:StopMovingOrSizing()
		end)
end

function CraftSim.FRAME:RestoreModulePositions()
    local controlPanel = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CONTROL_PANEL)
	local recipeScanFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.RECIPE_SCAN)
	local craftResultsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CRAFT_RESULTS)
	local customerServiceFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE)
	local customerHistoryFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CUSTOMER_HISTORY)
	local priceOverrideFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE)
	local priceOverrideFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.PRICE_OVERRIDE_WORK_ORDER)
	local specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO)
	local specInfoFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)
	local averageProfitFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS)
	local averageProfitFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STAT_WEIGHTS_WORK_ORDER)
	local topgearFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR)
	local topgearFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.TOP_GEAR_WORK_ORDER)
	local materialOptimizationFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS)
	local materialOptimizationFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.MATERIALS_WORK_ORDER)
    local debugFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.DEBUG)
    local infoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.INFO)
    local livePreviewFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.LIVE_PREVIEW)
    local statisticsFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STATISTICS)
    local statisticsFrameWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.STATISTICS_WORKORDER)
    local specsim = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM)
    local specsimWO = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO)

    specsim:RestoreSavedConfig(UIParent)
    specsimWO:RestoreSavedConfig(UIParent)
    statisticsFrame:RestoreSavedConfig(UIParent)
    statisticsFrameWO:RestoreSavedConfig(UIParent)
    livePreviewFrame:RestoreSavedConfig(UIParent)
    infoFrame:RestoreSavedConfig(UIParent)
    debugFrame:RestoreSavedConfig(UIParent)
    controlPanel:RestoreSavedConfig(ProfessionsFrame)
    recipeScanFrame:RestoreSavedConfig(ProfessionsFrame)
    craftResultsFrame:RestoreSavedConfig(ProfessionsFrame)
    customerServiceFrame:RestoreSavedConfig(ProfessionsFrame)
    customerHistoryFrame:RestoreSavedConfig(ProfessionsFrame)
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
    CraftSim.COST_DETAILS.frame:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.COST_DETAILS.frameWO:RestoreSavedConfig(ProfessionsFrame)
    materialOptimizationFrame:RestoreSavedConfig(ProfessionsFrame)
    materialOptimizationFrameWO:RestoreSavedConfig(ProfessionsFrame)
    CraftSim.CRAFTDATA.frame:RestoreSavedConfig(ProfessionsFrame)
end

function CraftSim.FRAME:ResetFrames()
    for _, frame in pairs(CraftSim.MAIN.FRAMES) do
        print("resetting frameID: " .. tostring(frame.frameID))
        frame:ResetPosition()
    end
end

local hooked = false
function CraftSim.FRAME:HandleAuctionatorOverlaps()
    if hooked then
        return
    end
    hooked = true
    if IsAddOnLoaded("Auctionator") then
        Auctionator.CraftingInfo._InitializeProfessionsFrame = Auctionator.CraftingInfo.InitializeProfessionsFrame
        Auctionator.CraftingInfo.InitializeProfessionsFrame = function(self) 
            Auctionator.CraftingInfo:_InitializeProfessionsFrame()
            AuctionatorCraftingInfoProfessionsFrame.SearchButton:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents, "TOPLEFT", 0, 25)
        end
    end
end

--> in GGUI.Button
function CraftSim.FRAME:CreateButton(label, parent, anchorParent, anchorA, anchorB, anchorX, anchorY, sizeX, sizeY, sizeToText, clickCallback)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetText(label)
    if sizeToText then
        button:SetSize(button:GetTextWidth() + sizeX, sizeY)
    else
        button:SetSize(sizeX, sizeY)
    end
    
    button:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
    button:SetScript("OnClick", function() 
        clickCallback(button)
    end)
    return button
end

--> in GGUI.Tab
function CraftSim.FRAME:CreateTab(label, parent, anchorParent, anchorA, anchorB, anchorX, anchorY, canBeEnabled, contentX, contentY, contentParent, contentAnchor, contentOffsetX, contentOffsetY)
    local tabExtraWidth = 15
    local tabButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    tabButton.canBeEnabled = canBeEnabled
    tabButton:SetText(label)
    tabButton:SetSize(tabButton:GetTextWidth() + tabExtraWidth, 30)
    tabButton.ResetWidth = function() 
        tabButton:SetSize(tabButton:GetTextWidth() + tabExtraWidth, 30)
    end
    tabButton:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)


    tabButton.content = CreateFrame("Frame", nil, contentParent)
    tabButton.content:SetPoint("TOP", contentAnchor, "TOP", contentOffsetX, contentOffsetY)
    tabButton.content:SetSize(contentX, contentY)

    return tabButton
end

--> in GGUI
function CraftSim.FRAME:MakeCollapsable(frame, originalX, originalY, frameID)
    frame.collapsed = false
    frame.collapseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    local offsetX = frame.closeButton and -43 or -23
	frame.collapseButton:SetPoint("TOP", frame, "TOPRIGHT", offsetX, -10)	
	frame.collapseButton:SetText(" - ")
    frame.originalX = originalX -- so it can be modified later
    frame.originalY = originalY
	frame.collapseButton:SetSize(frame.collapseButton:GetTextWidth() + 12, 20)
    frame.collapse = function(self) 
        frame.collapsed = true
        -- make smaller and hide content, only show frameTitle
        frame:SetSize(self.originalX, 40)
        frame.collapseButton:SetText("+")
        frame.content:Hide()
        if frame.scrollFrame then
            frame.scrollFrame:Hide()
        end
    end

    frame.decollapse = function(self) 
        -- restore
        frame.collapsed = false
        frame.collapseButton:SetText("-")
        frame:SetSize(self.originalX, self.originalY)
        frame.content:Show()
        if frame.scrollFrame then
            frame.scrollFrame:Show()
        end
    end

    frame.collapseButton:SetScript("OnClick", function(self) 
        if frame.collapsed then
            frame:decollapse()
        else
            frame:collapse()
        end
    end)
end

--> in GGUI
function CraftSim.FRAME:MakeCloseable(frame, moduleOption)
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.closeButton:SetPoint("TOP", frame, "TOPRIGHT", -20, -10)	
	frame.closeButton:SetText("X")
	frame.closeButton:SetSize(frame.closeButton:GetTextWidth()+15, 20)
    frame.closeButton:SetScript("OnClick", function(self) 
        frame:Hide()
        if moduleOption then
            CraftSimOptions[moduleOption] = false
            local controlPanel = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CONTROL_PANEL)

            controlPanel.content[moduleOption]:SetChecked(false)
        end
    end)
end


--> in GGUI.Text
function CraftSim.FRAME:CreateText(text, parent, anchorParent, anchorA, anchorB, anchorX, anchorY, scale, font, justifyData)
    scale = scale or 1
    font = font or "GameFontHighlight"

    local craftSimText = parent:CreateFontString(nil, "OVERLAY", font)
    craftSimText:SetText(text)
    craftSimText:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
    craftSimText:SetScale(scale)
    
    if justifyData then
        if justifyData.type == "V" then
            craftSimText:SetJustifyV(justifyData.value)
        elseif justifyData.type == "H" then
            craftSimText:SetJustifyH(justifyData.value)
        elseif justifyData.type == "HV" then
            craftSimText:SetJustifyH(justifyData.valueH)
            craftSimText:SetJustifyV(justifyData.valueV)
        end
    end

    return craftSimText
end

--> in GGUI.ScrollingMessageFrame
function CraftSim.FRAME:CreateScrollingMessageFrame(parent, anchorParent, anchorA, anchorB, anchorX, anchorY, maxLines, sizeX, sizeY)
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

--> in GGUI.Frame
function CraftSim.FRAME:CreateCraftSimFrame(name, title, parent, anchorFrame, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, 
    frameID, scrollable, closeable, frameStrata, moduleOption)
    local hookFrame = CreateFrame("frame", nil, parent)
    hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    local frame = CreateFrame("frame", name, hookFrame, "BackdropTemplate")
    frame.hookFrame = hookFrame
    hookFrame:SetSize(sizeX, sizeY)
    frame:SetSize(sizeX, sizeY)
    frame:SetFrameStrata(frameStrata or "HIGH")
    local currentFrameCount = CraftSim.GUTIL:Count(CraftSim.FRAME.frames)
    frame:SetFrameLevel(currentFrameCount) -- Prevent wierd overlap of craftsim frames?

    frame.resetPosition = function() 
        hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -15)
	frame.title:SetText(title)
    
    frame:SetPoint("TOP",  hookFrame, "TOP", 0, 0)
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})

    frame:SetBackdropColor(0, 0, 0 , 1)

    frame.SetTransparency = function(self, transparency) 
        frame:SetBackdropColor(0, 0, 0 , transparency)
    end

    if closeable then
        CraftSim.FRAME:MakeCloseable(frame, moduleOption)
    end

    CraftSim.FRAME:MakeCollapsable(frame, sizeX, sizeY, frameID)
    
    CraftSim.FRAME:makeFrameMoveable(frame)

    if scrollable then
        
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
        frame.content:SetSize(sizeX, sizeY)
    end
    
    CraftSim.FRAME.frames[frameID] = name
    return frame
end

--> in GGUI.Checkbox
function CraftSim.FRAME:CreateCheckboxCustomCallback(label, description, initialValue, clickCallback, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
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

--> in GGUI.Checkbox
function CraftSim.FRAME:CreateCheckbox(label, description, optionName, parent, anchorParent, anchorA, anchorB, offsetX, offsetY)
    local checkBox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkBox:SetHitRectInsets(0, 0, 0, 0); -- see https://wowpedia.fandom.com/wiki/API_Frame_SetHitRectInsets
	checkBox:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
	checkBox.Text:SetText(label)
    checkBox.tooltip = description
	-- there already is an existing OnClick script that plays a sound, hook it
    checkBox:SetChecked(CraftSimOptions[optionName])
	checkBox:HookScript("OnClick", function(_, btn, down)
		local checked = checkBox:GetChecked()
		CraftSimOptions[optionName] = checked
	end)

    return checkBox
end

--> in GGUI.Slider
function CraftSim.FRAME:CreateSlider(name, label, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, orientation, min, max, initialValue, lowText, highText, updateCallback)
    local newSlider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    newSlider:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
    newSlider:SetSize(sizeX, sizeY)
    newSlider:SetOrientation(orientation)
    newSlider:SetMinMaxValues(min, max)
    newSlider:SetValue(initialValue)
    _G[newSlider:GetName() .. 'Low']:SetText(lowText)        -- Sets the left-side slider text (default is "Low").
    _G[newSlider:GetName() .. 'High']:SetText(highText)     -- Sets the right-side slider text (default is "High").
    _G[newSlider:GetName() .. 'Text']:SetText(label)       -- Sets the "title" text (top-centre of slider).

    newSlider:SetScript("OnValueChanged", updateCallback)

    return newSlider
end

--> in GGUI.HelpIcon
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

function CraftSim.FRAME:InitDebugFrame()
    local debugFrame = CraftSim.GGUI.Frame({
        anchorA="BOTTOMRIGHT",anchorB="BOTTOMRIGHT",
        sizeX=400,sizeY=400,
        frameID=CraftSim.CONST.FRAMES.DEBUG, 
        title="CraftSim Debug",
        collapseable=true,
        closeable=true,
        moveable=true,
        scrollableContent=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        parent=UIParent,anchorParent=UIParent,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    CraftSim.FRAME:ToggleFrame(debugFrame, CraftSimOptions.debugVisible)

    debugFrame:HookScript("OnShow", function() CraftSimOptions.debugVisible = true end)
    debugFrame:HookScript("OnHide", function() CraftSimOptions.debugVisible = false end)

    debugFrame.content.debugBox = CreateFrame("EditBox", nil, debugFrame.content)
    debugFrame.content.debugBox:SetPoint("TOP", debugFrame.content, "TOP", 0, -20)
    debugFrame.content.debugBox:SetText("")
    debugFrame.content.debugBox:SetWidth(debugFrame.content:GetWidth() - 15)
    debugFrame.content.debugBox:SetHeight(20)
    debugFrame.content.debugBox:SetMultiLine(true)
    debugFrame.content.debugBox:SetAutoFocus(false)
    debugFrame.content.debugBox:SetFontObject("ChatFontNormal")
    debugFrame.content.debugBox:SetScript("OnEscapePressed", function() debugFrame.content.debugBox:ClearFocus() end)
    debugFrame.content.debugBox:SetScript("OnEnterPressed", function() debugFrame.content.debugBox:ClearFocus() end)

    debugFrame.addDebug = function(debugOutput, debugID, printLabel) 
        if debugFrame:IsVisible() then -- to not make it too bloated over time
            local currentOutput = debugFrame.content.debugBox:GetText()
            if printLabel then
                debugFrame.content.debugBox:SetText(currentOutput .. "\n\n- " .. debugID .. ":\n" .. tostring(debugOutput))
            else
                debugFrame.content.debugBox:SetText(currentOutput .. "\n" .. tostring(debugOutput))
            end
        end
    end

    debugFrame.frame.scrollFrame:HookScript("OnScrollRangeChanged", function() 
        if CraftSimOptions.debugAutoScroll then
            debugFrame.frame.scrollFrame:SetVerticalScroll(debugFrame.frame.scrollFrame:GetVerticalScrollRange())
        end
    end)

    local controlPanel = CraftSim.GGUI.Frame({
        parent=debugFrame.frame,anchorParent=debugFrame.frame,
        anchorA="TOPRIGHT",anchorB="TOPLEFT",title="Debug Control",
        offsetX=10,sizeX=300,sizeY=400,frameID=CraftSim.CONST.FRAMES.DEBUG_CONTROL,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    controlPanel.content.autoScrollCB = CraftSim.FRAME:CreateCheckbox("Autoscroll", "Toggle Log Autoscrolling", "debugAutoScroll", controlPanel.content,
    controlPanel.content, "TOP", "TOP", -120, -30)

    controlPanel.content.clearButton = CraftSim.GGUI.Button({
        label="Clear", parent=controlPanel.content,anchorParent=controlPanel.content.autoScrollCB,anchorA="TOP",anchorB="BOTTOM",sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function()
            debugFrame.content.debugBox:SetText("")
        end,
        offsetX=100,
    })

    controlPanel.content.reloadButton = CraftSim.GGUI.Button({
        label="Reload UI", parent=controlPanel.content,anchorParent=controlPanel.content.clearButton.frame,anchorA="RIGHT",anchorB="LEFT",sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function()
            C_UI.Reload()
        end,
        offsetX=-15,
    })

    controlPanel.content.nodeDebugInput = CraftSim.FRAME:CreateInput(
        "CraftSimDebugNodeIDInput", controlPanel.content, controlPanel.content.clearButton.frame, 
        "TOP", "TOP", -50, -25, 120, 20, "", function() end)


    controlPanel.content.debugNodeButton = CraftSim.GGUI.Button({
        label="Debug Node", parent=controlPanel.content,anchorParent=controlPanel.content.nodeDebugInput,anchorA="LEFT",anchorB="RIGHT",sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function ()
            local nodeIdentifier = CraftSimDebugNodeIDInput:GetText()
            CraftSim_DEBUG:CheckSpecNode(nodeIdentifier)
        end,
        offsetX=10,
    })


    controlPanel.content.compareData = CraftSim.GGUI.Button({
        label="Compare UI/Spec Data", parent=controlPanel.content,anchorParent=controlPanel.content.nodeDebugInput,anchorA="TOPLEFT",anchorB="TOPLEFT",sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function ()
            CraftSim_DEBUG:CompareStatData()
        end,
        offsetX=-5, offsetY=-25,
    })

    controlPanel.content.clearCacheButton = CraftSim.GGUI.Button({
        label="Clear Cache", parent=controlPanel.content,anchorParent=controlPanel.content.compareData.frame,anchorA="LEFT",anchorB="RIGHT",sizeX=15,sizeY=25,adjustWidth=true,
        clickCallback=function ()
            CraftSim.CACHE:ClearAll()
        end
    })

    controlPanel.content.debugIDScrollFrame, controlPanel.content.debugIDSFrame = CraftSim.FRAME:CreateScrollFrame(controlPanel.content, -130, 10, -40, 20)
    local checkBoxOffsetY = 0
    controlPanel.content.debugIDSFrame.checkBoxID_MAIN = CraftSim.FRAME:CreateCheckbox(
        " MAIN", "Enable MAIN Output", "enableDebugID_MAIN", controlPanel.content.debugIDSFrame, controlPanel.content.debugIDSFrame, "TOPLEFT", "TOPLEFT", 5, 0)
    
    local lastHook = controlPanel.content.debugIDSFrame.checkBoxID_MAIN
    for _, debugID in pairs(CraftSim.CONST.DEBUG_IDS) do
        if debugID ~= CraftSim.CONST.DEBUG_IDS.MAIN then
            controlPanel.content.debugIDSFrame["checkboxID_" .. debugID] = CraftSim.FRAME:CreateCheckbox(
        " " .. debugID, "Enable "..debugID.." Output", "enableDebugID_" .. debugID, controlPanel.content.debugIDSFrame, lastHook, "TOPLEFT", "BOTTOMLEFT", 0, checkBoxOffsetY)
        lastHook = controlPanel.content.debugIDSFrame["checkboxID_" .. debugID]
        end
    end
    local featureToggleTitle = CraftSim.FRAME:CreateText("Feature Toggles:", controlPanel.content.debugIDSFrame, lastHook, "TOPLEFT", "BOTTOMLEFT", 0, -10)

    local lastHook = featureToggleTitle

    for _, featureToggleID in pairs(CraftSim.CONST.FEATURE_TOGGLES) do
        controlPanel.content.debugIDSFrame["checkboxID_" .. featureToggleID] = CraftSim.FRAME:CreateCheckbox(
        " " .. featureToggleID, "Enable "..featureToggleID.." Output", "enablefeatureToggleID_" .. featureToggleID, controlPanel.content.debugIDSFrame, lastHook, "TOPLEFT", "BOTTOMLEFT", 0, checkBoxOffsetY)
        lastHook = controlPanel.content.debugIDSFrame["checkboxID_" .. featureToggleID]

        controlPanel.content.debugIDSFrame["checkboxID_" .. featureToggleID]:HookScript("OnClick", function ()
            CraftSim.MAIN:TriggerModulesErrorSafe()
        end)
    end


    CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(debugFrame.content)
end

function CraftSim.FRAME:InitOneTimeNoteFrame()
    local currentVersion = GetAddOnMetadata(CraftSimAddonName, "Version")

    local frame = CraftSim.GGUI.Frame({
        parent=UIParent,anchorParent=UIParent,sizeX=500,sizeY=300,frameID=CraftSim.CONST.FRAMES.INFO,
        closeable=true, scrollableContent=true, moveable=true,
        title=CraftSim.GUTIL:ColorizeText("CraftSim What's New? (" .. currentVersion .. ")", CraftSim.GUTIL.COLORS.GREEN),
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    frame.content.discordBox = CraftSim.FRAME:CreateInput(
        nil, frame.content, frame.content, "TOP", "TOP", 0, -20, 200, 30, CraftSim.CONST.DISCORD_INVITE_URL, function() 
            -- do not let the player remove the discord link.. lol
            frame.content.discordBox:SetText(CraftSim.CONST.DISCORD_INVITE_URL)
        end)
    frame.content.discordBox:SetScale(0.75)
    frame.content.discordBoxLabel = CraftSim.FRAME:CreateText(
        "Join the Discord!", frame.content, frame.content.discordBox, "BOTTOM", "TOP", 0, 0, 0.75)

    frame.content.infoText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.infoText:SetPoint("TOP", frame.content, "TOP", 10, -45)
    frame.content.infoText:SetText("No Info")
    frame.content.infoText:SetJustifyH("LEFT")

    frame.showInfo = function(infoText) 
        frame.content.infoText:SetText(infoText)
        frame:Show()
    end

    CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
    frame:Hide()
end

function CraftSim.FRAME:ShowOneTimeInfo(force)
    local infoText = CraftSim.NEWS:GET_NEWS()
    local versionID = CraftSim.CONST.currentInfoVersionID
    if CraftSimOptions.infoVersionID == versionID and not CraftSim.CONST.debugInfoText and not force then
        return
    end

    CraftSimOptions.infoVersionID = versionID

    local infoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.INFO)
    -- resize
    infoFrame:SetSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
    infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
    infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
    infoFrame.showInfo(infoText)
end

---> GGUI
function CraftSim.FRAME:CreateScrollFrame(parent, offsetTOP, offsetLEFT, offsetRIGHT, offsetBOTTOM)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame.scrollChild = CreateFrame("frame")
    local scrollChild = scrollFrame.scrollChild
    scrollFrame:SetSize(parent:GetWidth() , parent:GetHeight())
    scrollFrame:SetPoint("TOP", parent, "TOP", 0, offsetTOP)
    scrollFrame:SetPoint("LEFT", parent, "LEFT", offsetLEFT, 0)
    scrollFrame:SetPoint("RIGHT", parent, "RIGHT", offsetRIGHT, 0)
    scrollFrame:SetPoint("BOTTOM", parent, "BOTTOM", 0, offsetBOTTOM)
    scrollFrame:SetScrollChild(scrollFrame.scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1)
    return scrollFrame, scrollChild
end

--> in GGUI.CurrencyInput
function CraftSim.FRAME:CreateGoldInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, onValueValidCallback, onValidationChangedCallback, showFormatHelpIcon)
    local function validateMoneyString(moneyString)
        -- check if the string matches the pattern
        if not string.match(moneyString, "^%d*g?%d*s?%d*c?$") then
            return false
        end

        -- check if the string contains at least one of g, s, or c
        if not string.match(moneyString, "[gsc]") then
            return false
        end

        -- check if the string contains multiple g, s, or c
        if string.match(moneyString, "g.*g") then
            return false
        end
        if string.match(moneyString, "s.*s") then
            return false
        end
        if string.match(moneyString, "c.*c") then
            return false
        end

        -- check if it ends incorrectly
        if string.match(moneyString, "%d$") then
            return false
        end

        -- check if the string contains invalid characters
        if string.match(moneyString, "[^%dgsc]") then
            return false
        end

        -- all checks passed, the string is valid
        return true
    end

    local goldInput = CraftSim.FRAME:CreateInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, 
    function(self, userInput) 
        print("userinput: " .. tostring(userInput))
        if userInput then
            -- validate and color text, and adapt save button
            local input = self:GetText() or ""
            -- remove colorizations
            print(input)

            input = string.gsub(input, CraftSim.GUTIL.COLORS.GOLD, "")
            input = string.gsub(input, CraftSim.GUTIL.COLORS.SILVER, "")
            input = string.gsub(input, CraftSim.GUTIL.COLORS.COPPER, "")
            input = string.gsub(input, "|r", "")
            input = string.gsub(input, "|", "")

            local valid = validateMoneyString(input)
            self.isValid = valid

            print("money string valid: " .. tostring(valid))
            if valid then
                -- colorize
                print("colorize")
                local gold = tonumber(string.match(input, "(%d+)g")) or 0
                local silver = tonumber(string.match(input, "(%d+)s")) or 0
                local copper = tonumber(string.match(input, "(%d+)c")) or 0
                local gC = CraftSim.GUTIL:ColorizeText("g", CraftSim.GUTIL.COLORS.GOLD)
                local sC = CraftSim.GUTIL:ColorizeText("s", CraftSim.GUTIL.COLORS.SILVER)
                local cC = CraftSim.GUTIL:ColorizeText("c", CraftSim.GUTIL.COLORS.COPPER)
                local colorizedText = ((gold > 0 and (gold .. gC)) or "") .. ((silver > 0 and (silver .. sC)) or "") .. ((copper > 0 and (copper .. cC)) or "")
                self:SetText(colorizedText)

                local goldInputInfo = {
                    gold=gold,
                    silver=silver,
                    copper=copper,
                    total=gold*10000+silver*100+copper
                }
                if onValueValidCallback then
                    onValueValidCallback(goldInputInfo)
                end

                self.currentInfo = goldInputInfo
            end

            self.validationBorder:SetValid(valid)

            if onValidationChangedCallback then
                onValidationChangedCallback(valid)
            end
        end
    end)

    local validationBorder = CreateFrame("Frame", nil, goldInput, "BackdropTemplate")
    validationBorder:SetSize(goldInput:GetWidth()*1.3, goldInput:GetHeight()*1.6)
    validationBorder:SetPoint("CENTER", goldInput, "CENTER", -2, 0)
    validationBorder:SetBackdrop({
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
        edgeSize = 25,
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
    goldInput.validationBorder = validationBorder

    function goldInput:GetInfo()
        return goldInput.currentInfo
    end

    function goldInput:SetValue(total)
        local gold, silver, copper = CraftSim.GUTIL:GetMoneyValuesFromCopper(total)
        local gC = CraftSim.GUTIL:ColorizeText("g", CraftSim.GUTIL.COLORS.GOLD)
        local sC = CraftSim.GUTIL:ColorizeText("s", CraftSim.GUTIL.COLORS.SILVER)
        local cC = CraftSim.GUTIL:ColorizeText("c", CraftSim.GUTIL.COLORS.COPPER)
        local colorizedText = ((gold > 0 and (gold .. gC)) or "") .. ((silver > 0 and (silver .. sC)) or "") .. ((copper > 0 and (copper .. cC)) or "")
        self:SetText(colorizedText)
    end

    goldInput:SetValue(initialValue)

    if showFormatHelpIcon then
        CraftSim.FRAME:CreateHelpIcon("Format: 100g10s1c", goldInput, goldInput, "LEFT", "RIGHT", 5, 0)
    end

    return goldInput
end

--> in GGUI.TextInput
function CraftSim.FRAME:CreateInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, onTextChangedCallback)
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
function CraftSim.FRAME:CreateNumericInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, allowNegative, onTextChangedCallback)
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

function CraftSim.FRAME:HandleModuleClose(moduleOption)
    return function ()
        CraftSimOptions[moduleOption] = false
        CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.CONTROL_PANEL).content[moduleOption]:SetChecked(false)
    end
end