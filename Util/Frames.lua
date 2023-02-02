AddonName, CraftSim = ...

CraftSim.FRAME = {}

CraftSim.FRAME.frames = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.FRAMES) 

function CraftSim.FRAME:GetFrame(frameID)
    local frameName = CraftSim.FRAME.frames[frameID]
    if not frameName then
        error("CraftSim Error: Frame not found: " .. tostring(frameID))
    end
    return _G[frameName]
end

function CraftSim.FRAME:CreateIcon(parent, offsetX, offsetY, texture, sizeX, sizeY, anchorA, anchorB, anchorParent)
    anchorParent = anchorParent or parent
    if anchorA == nil then
        anchorA = "CENTER"
    end
    if anchorB == nil then
        anchorB = "CENTER"
    end
    local newIcon = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    newIcon:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
	newIcon:SetSize(sizeX, sizeY)
	newIcon:SetNormalFontObject("GameFontNormalLarge")
	newIcon:SetHighlightFontObject("GameFontHighlightLarge")
	newIcon:SetNormalTexture(texture)

    newIcon.SetItem = function(itemIDOrLink, tooltipOwner, tooltipAnchor, byLink)
        if itemIDOrLink then

            local item = nil
            if byLink then
                item = Item:CreateFromItemLink(itemIDOrLink)
            else
                item = Item:CreateFromItemID(itemIDOrLink)
            end

            item:ContinueOnItemLoad(function ()
                newIcon:SetNormalTexture(item:GetItemIcon())
                newIcon:SetScript("OnEnter", function(self) 
                    local itemName, ItemLink = GameTooltip:GetItem()
                    GameTooltip:SetOwner(tooltipOwner or newIcon, tooltipAnchor or "ANCHOR_RIGHT");
                    if ItemLink ~= item:GetItemLink() then
                        -- to not set it again and hide the tooltip..
                        GameTooltip:SetHyperlink(item:GetItemLink())
                    end
                    GameTooltip:Show();
                end)
                newIcon:SetScript("OnLeave", function(self) 
                    GameTooltip:Hide();
                end)
            end)
        else
            newIcon:SetScript("OnEnter", nil)
            newIcon:SetScript("OnLeave", nil)
        end
    end

    return newIcon
end

function CraftSim.FRAME:FormatStatDiffpercentText(statDiff, roundTo, suffix)
    if statDiff == nil then
        statDiff = 0
    end
    local sign = "+"
    if statDiff < 0 then
        sign = ""
    end
    if suffix == nil then
        suffix = ""
    end
    return sign .. CraftSim.UTIL:round(statDiff, roundTo) .. suffix
end

function CraftSim.FRAME:ToggleFrame(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

function CraftSim.FRAME:initDropdownMenu(frameName, parent, anchorFrame, label, offsetX, offsetY, width, list, clickCallback, defaultValue, byData)
	local dropDown = CreateFrame("Frame", frameName, parent, "UIDropDownMenuTemplate")
    dropDown.clickCallback = clickCallback
	dropDown:SetPoint("TOP", anchorFrame, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, width)
	
    if byData then
        CraftSim.FRAME:initializeDropdownByData(dropDown, list, defaultValue)
    else
        CraftSim.FRAME:initializeDropdown(dropDown, list, defaultValue)
    end

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)

    dropDown.SetLabel = function(label) 
        dd_title:SetText(label)
    end

    dropDown.SetLabel(label)

    return dropDown
end

-- anchor: e.g. "ANCHOR_RIGHT"
-- if itemLink is nil it removes the tooltip
function CraftSim.FRAME:SetItemTooltip(frame, itemLink, owner, anchor)
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

--- @param showCount? boolean if enabled, item tooltips show how many the player possesses
--- @param showItemTooltips? boolean requires the label to be an itemLink
--- @param concatCallback? function takes one argument which is the itemlink and returns a string that is added to the items tooltip
function CraftSim.FRAME:initializeDropdownByData(dropDown, list, defaultValue, showItemTooltips, showCount, concatCallback)
    print("Init Dropdown By Data", false, true)
    print("showItemTooltips: " .. tostring(showItemTooltips))
    local function initMainMenu(self, level, menulist) 
        local info = UIDropDownMenu_CreateInfo()
        if level == 1 then
            for _, v in pairs(list) do
                local label = v.label
                local value = v.value
                local hasSublist = type(value) == 'table'
                if not hasSublist then
                    info.func = function(self, arg1, arg2, checked) 
                        UIDropDownMenu_SetText(dropDown, self.value) -- value should contain the selected text..
                        dropDown.clickCallback(dropDown, arg1)
                    end
                end
                info.text = label
                info.arg1 = value
                info.hasArrow = hasSublist
                info.menuList = hasSublist and label
                if showItemTooltips then
                    print("initializeDropdownByData: Set Item Tooltip: " .. tostring(label), false, true)
                    info.tooltipText = CraftSim.UTIL:GetItemTooltipText(label, showCount)
                    -- cut first line as it is the name of the item
                    info.tooltipTitle, info.tooltipText = string.match(info.tooltipText, "^(.-)\n(.*)$")
                    if concatCallback then
                    info.tooltipTitle = info.tooltipTitle .. "\n" .. tostring(concatCallback(label))
                    end
                    info.tooltipOnButton = true
                end
                UIDropDownMenu_AddButton(info)
            end
        elseif menulist then
            for _, currentMenulist in pairs(list) do
                if currentMenulist.label == menulist then
                    for _, v in pairs(currentMenulist.value) do
                        local label = v.label
                        local value = v.value
                        info.func = function(self, arg1, arg2, checked) 
                            UIDropDownMenu_SetText(dropDown, self.value) -- value should contain the selected text..
                            dropDown.clickCallback(dropDown, arg1)
                            CloseDropDownMenus()
                        end
                        info.text = label
                        info.arg1 = value
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        end
	end

	UIDropDownMenu_Initialize(dropDown, initMainMenu, "DROPDOWN_MENU_LEVEL")
	UIDropDownMenu_SetText(dropDown, defaultValue)
end

function CraftSim.FRAME:initializeDropdown(dropDown, list, defaultValue)
	UIDropDownMenu_Initialize(dropDown, function(self) 
		for k, v in pairs(list) do
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(self, arg1, arg2, checked) 
                UIDropDownMenu_SetText(dropDown, arg1)
                dropDown.clickCallback(arg1)
            end
			info.text = v
			info.arg1 = v
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetText(dropDown, defaultValue)
end

function CraftSim.FRAME:CreateQualityIcon(frame, x, y, anchorFrame, anchorSelf, anchorParent, offsetX, offsetY, initialQuality)
    initialQuality = initialQuality or 1
    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(x, y)
    icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    icon:SetAtlas("Professions-Icon-Quality-Tier" .. initialQuality)
    icon:SetPoint(anchorSelf, anchorFrame, anchorParent, offsetX, offsetY)

    icon.SetQuality = function(qualityID) 
        if qualityID > 5 then
            qualityID = 5
        end
        icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
        icon:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
    end

    return icon
end

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

function CraftSim.FRAME:makeFrameMoveable(frame)
	frame.hookFrame:SetMovable(true)
	frame:SetScript("OnMouseDown", function(self, button)
		frame.hookFrame:StartMoving()
		end)
		frame:SetScript("OnMouseUp", function(self, button)
		frame.hookFrame:StopMovingOrSizing()
		end)
end

function CraftSim.FRAME:ResetFrames()
    for _, frameName in pairs(CraftSim.FRAME.frames) do
        local frame = _G[frameName]
        frame.hookFrame:ClearAllPoints()
        frame.resetPosition()
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
        CraftSimCollapsedFrames[frameID] = true
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
        CraftSimCollapsedFrames[frameID] = false
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

function CraftSim.FRAME:MakeCloseable(frame, moduleOption)
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.closeButton:SetPoint("TOP", frame, "TOPRIGHT", -20, -10)	
	frame.closeButton:SetText("X")
	frame.closeButton:SetSize(frame.closeButton:GetTextWidth()+15, 20)
    frame.closeButton:SetScript("OnClick", function(self) 
        frame:Hide()
        if moduleOption then
            CraftSimOptions[moduleOption] = false
            local controlPanel = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.CONTROL_PANEL)

            controlPanel.content[moduleOption]:SetChecked(false)
        end
    end)
end

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

function CraftSim.FRAME:CreateCraftSimFrame(name, title, parent, anchorFrame, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, 
    frameID, scrollable, closeable, frameStrata, moduleOption)
    local hookFrame = CreateFrame("frame", nil, parent)
    hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    local frame = CreateFrame("frame", name, hookFrame, "BackdropTemplate")
    frame.hookFrame = hookFrame
    hookFrame:SetSize(sizeX, sizeY)
    frame:SetSize(sizeX, sizeY)
    frame:SetFrameStrata(frameStrata or "HIGH")
    frame:SetFrameLevel(frameID) -- Prevent wierd overlap of craftsim frames

    frame.resetPosition = function() 
        hookFrame:SetPoint(anchorA, anchorFrame, anchorB, offsetX, offsetY)
    end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -15)
	frame.title:SetText(title)
    
    frame:SetPoint("TOP",  hookFrame, "TOP", 0, 0)
	--frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
	frame:SetBackdrop({
		--bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
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

function CraftSim.FRAME:UpdateStatDetailsByExtraItemFactors(recipeData)
    local lines = ProfessionsFrame.CraftingPage.SchematicForm.Details.statLinePool
	local activeObjects = lines.activeObjects

    local specData = recipeData.specNodeData

    local multicraftExtraItemsFactor = 1
    local resourcefulnessExtraItemsFactor = 1

    if specData then
        multicraftExtraItemsFactor = recipeData.stats.multicraft ~= nil and recipeData.stats.multicraft.bonusItemsFactor
        resourcefulnessExtraItemsFactor = recipeData.stats.resourcefulness ~= nil and recipeData.stats.resourcefulness.bonusItemsFactor
    else
        multicraftExtraItemsFactor = recipeData.extraItemFactors.multicraftExtraItemsFactor
        resourcefulnessExtraItemsFactor = recipeData.extraItemFactors.resourcefulnessExtraItemsFactor
    end
    
	for statLine, _ in pairs(activeObjects) do 
        local multicraftText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_MULTICRAFT)
        local resourcefulnessText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS)
		if string.find(statLine.LeftLabel:GetText(), multicraftText) and (multicraftExtraItemsFactor or 0) > 1 then
			local baseText = multicraftText .. " "
			local formatted = CraftSim.UTIL:FormatFactorToPercent(multicraftExtraItemsFactor)
			local text = baseText .. CraftSim.UTIL:ColorizeText("" .. formatted .. " Items", CraftSim.CONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
		if string.find(statLine.LeftLabel:GetText(), resourcefulnessText) and (resourcefulnessExtraItemsFactor or 0) > 1 then
			local baseText = resourcefulnessText .. " " 
			local formatted = CraftSim.UTIL:FormatFactorToPercent(resourcefulnessExtraItemsFactor)
			local text = baseText .. CraftSim.UTIL:ColorizeText("" .. formatted .. " Items", CraftSim.CONST.COLORS.GREEN)
			statLine.LeftLabel:SetText(text)
		end
	end
end

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
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimDebugFrame", "CraftSim Debug", 
    UIParent, 
    UIParent, 
    "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, 400, 400, CraftSim.CONST.FRAMES.DEBUG, true, true)
    CraftSim.FRAME:ToggleFrame(frame, CraftSimOptions.debugVisible)

    frame:HookScript("OnShow", function() CraftSimOptions.debugVisible = true end)
    frame:HookScript("OnHide", function() CraftSimOptions.debugVisible = false end)

    frame.content.debugBox = CreateFrame("EditBox", nil, frame.content)
    frame.content.debugBox:SetPoint("TOP", frame.content, "TOP", 0, -20)
    frame.content.debugBox:SetText("")
    frame.content.debugBox:SetWidth(frame.content:GetWidth() - 15)
    frame.content.debugBox:SetHeight(20)
    frame.content.debugBox:SetMultiLine(true)
    frame.content.debugBox:SetAutoFocus(false)
    frame.content.debugBox:SetFontObject("ChatFontNormal")
    frame.content.debugBox:SetScript("OnEscapePressed", function() frame.content.debugBox:ClearFocus() end)
    frame.content.debugBox:SetScript("OnEnterPressed", function() frame.content.debugBox:ClearFocus() end)

    frame.addDebug = function(debugOutput, debugID, printLabel) 
        if frame:IsVisible() then -- to not make it too bloated over time
            local currentOutput = frame.content.debugBox:GetText()
            if printLabel then
                frame.content.debugBox:SetText(currentOutput .. "\n\n- " .. debugID .. ":\n" .. tostring(debugOutput))
            else
                frame.content.debugBox:SetText(currentOutput .. "\n" .. tostring(debugOutput))
            end
        end
    end

    frame.scrollFrame:HookScript("OnScrollRangeChanged", function() 
        if CraftSimOptions.debugAutoScroll then
            frame.scrollFrame:SetVerticalScroll(frame.scrollFrame:GetVerticalScrollRange())
        end
    end)

    local controlPanel = CraftSim.FRAME:CreateCraftSimFrame("CraftSimDebugControlFrame", "Debug Control", 
    frame, 
    frame, 
    "TOPRIGHT", "TOPLEFT", 10, 0, 300, 400, CraftSim.CONST.FRAMES.DEBUG_CONTROL)

    controlPanel.content.autoScrollCB = CraftSim.FRAME:CreateCheckbox("Autoscroll", "Toggle Log Autoscrolling", "debugAutoScroll", controlPanel.content,
    controlPanel.content, "TOP", "TOP", -120, -30)

    controlPanel.content.clearButton = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.clearButton:SetPoint("TOP", controlPanel.content.autoScrollCB, "BOTTOM", 100, 0)	
	controlPanel.content.clearButton:SetText("Clear")
	controlPanel.content.clearButton:SetSize(controlPanel.content.clearButton:GetTextWidth()+15, 25)
    controlPanel.content.clearButton:SetScript("OnClick", function(self) 
        frame.content.debugBox:SetText("")
    end)

    controlPanel.content.reloadButton = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.reloadButton:SetPoint("RIGHT", controlPanel.content.clearButton, "LEFT", -15, 0)	
	controlPanel.content.reloadButton:SetText("Reload UI")
	controlPanel.content.reloadButton:SetSize(controlPanel.content.reloadButton:GetTextWidth()+15, 25)
    controlPanel.content.reloadButton:SetScript("OnClick", function(self) 
        C_UI.Reload()
    end)

    controlPanel.content.nodeDebugInput = CraftSim.FRAME:CreateInput(
        "CraftSimDebugNodeIDInput", controlPanel.content, controlPanel.content.clearButton, 
        "TOP", "TOP", -50, -25, 120, 20, "", function() end)

    controlPanel.content.debugNodeButton = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.debugNodeButton:SetPoint("LEFT", controlPanel.content.nodeDebugInput, "RIGHT", 10, 0)	
	controlPanel.content.debugNodeButton:SetText("Debug Node")
	controlPanel.content.debugNodeButton:SetSize(controlPanel.content.debugNodeButton:GetTextWidth()+15, 25)
    controlPanel.content.debugNodeButton:SetScript("OnClick", function(self) 
        local nodeIdentifier = CraftSimDebugNodeIDInput:GetText()
        CraftSim_DEBUG:CheckSpecNode(nodeIdentifier)
    end)

    controlPanel.content.compareData = CreateFrame("Button", nil, controlPanel.content, "UIPanelButtonTemplate")
	controlPanel.content.compareData:SetPoint("TOPLEFT", controlPanel.content.nodeDebugInput, "TOPLEFT", -5, -25)	
	controlPanel.content.compareData:SetText("Compare UI/Spec Data")
	controlPanel.content.compareData:SetSize(controlPanel.content.compareData:GetTextWidth()+15, 25)
    controlPanel.content.compareData:SetScript("OnClick", function(self) 
        CraftSim_DEBUG:CompareStatData()
    end)

    controlPanel.content.clearCacheButton = CraftSim.FRAME:CreateButton("Clear Cache",
    controlPanel.content, controlPanel.content.compareData, "LEFT", "RIGHT", 0, 0, 15, 25, true, function(self) 
        CraftSim.CACHE:ClearAll()
    end)

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

    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
end

function CraftSim.FRAME:InitWarningFrame()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimWarningFrame", 
    CraftSim.UTIL:ColorizeText("CraftSim Warning", CraftSim.CONST.COLORS.RED), 
    UIParent, 
    UIParent, 
    "CENTER", "CENTER", 0, 0, 500, 500, CraftSim.CONST.FRAMES.WARNING, true, true)

    frame.content.warningText = frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.content.warningText:SetPoint("TOP", frame.content, "TOP", 0, -20)
    frame.content.warningText:SetText("No Warning")

    frame.content.doNotShowAgainButton = CraftSim.FRAME:CreateButton("I know, do not show this again!", frame.content, frame.content, "TOP", "TOP", 0, -200, 15, 25, true,
    function()
            StaticPopup_Show("CRAFT_SIM_ACCEPT_NO_PRICESOURCE_WARNING")
        end
    )

    frame.content.errorBox = CreateFrame("EditBox", nil, frame.content)
    frame.content.errorBox:SetPoint("TOP", frame.content, "TOP", 0, -20)
    frame.content.errorBox:SetText("No Warning")
    frame.content.errorBox:SetWidth(frame.content:GetWidth() - 15)
    frame.content.errorBox:SetHeight(20)
    frame.content.errorBox:SetMultiLine(true)
    frame.content.errorBox:SetAutoFocus(false)
    frame.content.errorBox:SetFontObject("ChatFontNormal")
    
    frame.content.errorBox:SetScript("OnEscapePressed", function() frame.content.errorBox:ClearFocus() end)
    frame.content.errorBox:SetScript("OnEnterPressed", function() frame.content.errorBox:ClearFocus() end)

    frame.content.warningText:Hide()
    frame.content.errorBox:Hide()

    frame.showWarning = function(warningText, optionalTitle, hideDoNotShowButton) 
        CraftSim.FRAME:ToggleFrame(frame.content.doNotShowAgainButton, not hideDoNotShowButton)
        optionalTitle = optionalTitle or "CraftSim Warning"
        local wrapped = CraftSim.UTIL:WrapText(warningText, 50)
        frame.title:SetText(CraftSim.UTIL:ColorizeText(optionalTitle, CraftSim.CONST.COLORS.RED))
        frame.content.warningText:SetText(wrapped)
        frame.content.warningText:Show()
        frame.content.errorBox:Hide()
        frame.content.errorBox:SetText("")
        frame:Raise()
        frame:Show()
    end

    frame.showError = function(errorText, optionalTitle) 
        optionalTitle = optionalTitle or "CraftSim Warning"
        frame.title:SetText(CraftSim.UTIL:ColorizeText(optionalTitle, CraftSim.CONST.COLORS.RED))
        frame.content.errorBox:SetText(errorText)
        frame.content.errorBox:Show()
        frame.content.warningText:Hide()
        frame.content.warningText:SetText("")
        frame:Raise()
        frame:Show()
    end

    frame:Hide()
end

function CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
    if type(frame) == "table" and frame.SetHyperlinksEnabled and not frame.enabledLinks then -- prevent inf loop by references
        frame.enabledLinks = true
        frame:SetHyperlinksEnabled(true)
        frame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)

        for possibleFrame1, possibleFrame2 in pairs(frame) do
            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(possibleFrame1)
            CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(possibleFrame2)
        end
    end
end

function CraftSim.FRAME:InitOneTimeNoteFrame()
    local currentVersion = GetAddOnMetadata(AddonName, "Version")

    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimOneTimeNoteFrame", 
    CraftSim.UTIL:ColorizeText("CraftSim What's New? (" .. currentVersion .. ")", CraftSim.CONST.COLORS.GREEN), 
    UIParent, 
    UIParent, 
    "CENTER", "CENTER", 0, 0, 500, 300, CraftSim.CONST.FRAMES.INFO, true, true)

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

    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
    frame:Hide()
end

function CraftSim.FRAME:ShowOneTimeInfo(force)
    local infoText = CraftSim.NEWS:GET_NEWS()
    local versionID = CraftSim.CONST.currentInfoVersionID
    if CraftSimOptions.infoVersionID == versionID and not CraftSim.CONST.debugInfoText and not force then
        return
    end

    CraftSimOptions.infoVersionID = versionID

    local infoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.INFO)
    -- resize
    infoFrame.UpdateSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
    infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
    infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
    infoFrame.showInfo(infoText)
end

function CraftSim.FRAME:ShowWarning(warningText, optionalTitle, hideBtn)
    local warningFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.WARNING)
    warningFrame.showWarning(warningText, optionalTitle, hideBtn)
end

function CraftSim.FRAME:ShowError(errorText, optionalTitle)
    local warningFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.WARNING)
    warningFrame.showError(errorText, optionalTitle)
end

function CraftSim.FRAME:CreateGoldIcon(parent, anchorParent, anchorA, anchorB, anchorX, anchorY)
    local startLine = "\124T"
    local endLine = "\124t"
    local goldCoin = startLine .. "Interface\\Icons\\INV_Misc_Coin_01:16" .. endLine

    local goldIcon = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    goldIcon:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
    goldIcon:SetText(goldCoin)

    return goldIcon
end

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

function CraftSim.FRAME:CreateGoldInput(name, parent, anchorParent, anchorA, anchorB, offsetX, offsetY, sizeX, sizeY, initialValue, onTextChangedCallback)
    local goldInput = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
        goldInput:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        goldInput:SetSize(sizeX, sizeY)
        goldInput:SetAutoFocus(false) -- dont automatically focus
        goldInput:SetFontObject("ChatFontNormal")
        goldInput:SetText(initialValue)
        goldInput:SetScript("OnEscapePressed", function() goldInput:ClearFocus() end)
        goldInput:SetScript("OnEnterPressed", function() goldInput:ClearFocus() end)
        goldInput:SetScript("OnTextChanged", function(self, userInput) 
            local moneyValue = goldInput.getMoneyValue()
            onTextChangedCallback(userInput, moneyValue)
        end)

        goldInput.getMoneyValue = function()
            local inputText = goldInput:GetNumber()
            local totalCopper = inputText*10000

            --print("total value: " .. CraftSim.UTIL:FormatMoney(totalCopper))  
            return totalCopper
        end


    return goldInput
end

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