CraftSimAddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE.FRAMES = {}
CraftSim.CUSTOMER_SERVICE.timeoutSeconds = 5

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_SERVICE)

function CraftSim.CUSTOMER_SERVICE.FRAMES:Init()
    local frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame, 
        sizeX=400,sizeY=300,
        frameID=CraftSim.CONST.FRAMES.CUSTOMER_SERVICE, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCustomerService"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local function createContent(frame)
        frame:Hide()
        local recipeWhisperTab = CraftSim.FRAME:CreateTab(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RECIPE_WHISPER), frame.content, frame.title.frame, "TOP", "BOTTOM", -90, -15, true, 300, 250, frame.content, frame.title.frame, 0, -50)
        local autoResultTab = CraftSim.FRAME:CreateTab(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW), frame.content, recipeWhisperTab, "LEFT", "RIGHT", 0, 0, true, 300, 250, frame.content, frame.title.frame, 0, -50)

        recipeWhisperTab.content.customerCharacterInput = CraftSim.FRAME:CreateInput(nil, recipeWhisperTab.content, recipeWhisperTab.content, "TOPLEFT", "TOPLEFT", 10, -30, 150, 25, 
        "", 
        function() 
        end)

        recipeWhisperTab.content.whisperButton = CraftSim.GGUI.Button({
            parent=recipeWhisperTab.content,anchorParent=recipeWhisperTab.content.customerCharacterInput,anchorA="LEFT",anchorB="RIGHT", offsetX=10,sizeX=15,sizeY=25,adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_WHISPER),
            clickCallback=function ()
                local whisperTarget = recipeWhisperTab.content.customerCharacterInput:GetText()
                CraftSim.CUSTOMER_SERVICE:WhisperRecipeDetails(whisperTarget)
            end
        })

        recipeWhisperTab.content.msgFormatScrollFrame, recipeWhisperTab.content.msgFrameContent =
         CraftSim.FRAME:CreateScrollFrame(recipeWhisperTab.content, -90, 10, -10, 40)

        recipeWhisperTab.content.msgFrameContent.msgFormatBox = CreateFrame("EditBox", nil, recipeWhisperTab.content.msgFrameContent)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetPoint("TOP", recipeWhisperTab.content.msgFrameContent, "TOP", 0, -5)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetText(CraftSimOptions.customerServiceRecipeWhisperFormat)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetWidth(recipeWhisperTab.content.msgFrameContent:GetWidth() - 15)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetHeight(20)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetMultiLine(true)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetAutoFocus(false)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetFontObject("ChatFontNormal")
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetScript("OnEscapePressed", function() recipeWhisperTab.content.msgFrameContent.msgFormatBox:ClearFocus() end)
        recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetScript("OnTextChanged", function() 
            CraftSimOptions.customerServiceRecipeWhisperFormat = recipeWhisperTab.content.msgFrameContent.msgFormatBox:GetText()
        end)

        recipeWhisperTab.content.messageFormatTitle = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_MESSAGE_FORMAT), 
            recipeWhisperTab.content, recipeWhisperTab.content.msgFormatScrollFrame, "BOTTOMLEFT", "TOPLEFT", 8, 5)

        recipeWhisperTab.content.messageFormatHelp = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION), 
            recipeWhisperTab.content, recipeWhisperTab.content.messageFormatTitle, "LEFT", "RIGHT", 10, 0)

        recipeWhisperTab.content.resetDefaults = CraftSim.GGUI.Button({
            parent=recipeWhisperTab.content,anchorParent=recipeWhisperTab.content.messageFormatHelp,anchorA="LEFT",anchorB="RIGHT", offsetX=10,sizeX=15,sizeY=25,adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RESET_TO_DEFAULT),
            clickCallback=function ()
                local defaultFormat = 
                "Highest Result: %gc\n" ..
                "with Inspiration: %ic (%insp)\n" ..
                "Crafting Costs: %cc\n" ..
                "%ccd"
                CraftSimOptions.customerServiceRecipeWhisperFormat = defaultFormat
                recipeWhisperTab.content.msgFrameContent.msgFormatBox:SetText(defaultFormat)
            end
        })

        autoResultTab.content.enableConnections = CraftSim.FRAME:CreateCheckbox(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_ALLOW_CONNECTIONS), 
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION),
            "customerServiceAllowAutoResult", autoResultTab.content, autoResultTab.content, "TOPLEFT", "TOPLEFT", 10, -10)

        autoResultTab.content.browserInviteInput = CraftSim.FRAME:CreateInput(nil, autoResultTab.content, autoResultTab.content.enableConnections, "TOPLEFT", "BOTTOMLEFT", 0, 0, 150, 25, 
        "", 
        function() 
        end)

        recipeWhisperTab.content.resetDefaults = CraftSim.GGUI.Button({
            parent=autoResultTab.content,anchorParent=autoResultTab.content.browserInviteInput,anchorA="LEFT",anchorB="RIGHT", offsetX=5,sizeX=15,sizeY=25,adjustWidth=true,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_SEND_INVITE),
            clickCallback=function ()
                local whisperTarget = autoResultTab.content.browserInviteInput:GetText()
                CraftSim.CUSTOMER_SERVICE:WhisperInvite(whisperTarget)
            end
        })
        
        frame.tabs = {recipeWhisperTab, autoResultTab}
        CraftSim.FRAME:InitTabSystem(frame.tabs)
    end

    createContent(frame)
end

function CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreview()
    local frame = CraftSim.GGUI.Frame({
        parent=UIParent,anchorParent=UIParent,sizeX=500,sizeY=500,frameID=CraftSim.CONST.FRAMES.LIVE_PREVIEW, frameStrata="DIALOG",
        closeable=true,collapseable=true, moveable=true,
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_TITLE),
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local function createContent(frame)
        frame:Hide()

        local function onRecipeSelected(_, _, recipeID)
            print("Selected RecipeID: " .. tostring(recipeID))
            frame.currentRecipeID = recipeID
            CraftSim.CUSTOMER_SERVICE.SendRecipeUpdateRequest(recipeID, true) 
        end

        frame.content.previewTitle = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTER_PROFESSION), 
            frame.content, frame.title.frame, "TOP", "BOTTOM", 0, -10)

        frame.content.recipeDropdown = CraftSim.GGUI.Dropdown({
            parent=frame.content, anchorParent=frame.content.previewTitle, anchorA="TOP", anchorB="TOP",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES), 
            offsetY=-30, sizeX=200, clickCallback=onRecipeSelected, 
            initialValue=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES_INITIAL),
        })

        local requestingUpdate = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REQUESTING_UPDATE)
        frame.content.loadingText = CraftSim.FRAME:CreateText(requestingUpdate, frame.content, frame.content.recipeDropdown.frame, "LEFT", "RIGHT", -20, 5, 0.8, nil, {type="H", value="LEFT"})
        frame.content.isUpdating = false
        frame.content.updates = {}
        local function checkForTimeOut(updateID)
            if tContains(frame.content.updates, updateID) then
                frame.content.loadingText:SetText(CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TIMEOUT), CraftSim.GUTIL.COLORS.RED))
                frame.content.StopUpdate(true)
            end
        end
        frame.content.StartUpdate = function()
            local updateID = CraftSim.GUTIL:Round(debugprofilestop())
            table.insert(frame.content.updates, updateID)
            frame.SetEnabled(false)
            frame.content.isUpdating = true
            frame.content.loadingText:Show()
            frame.content.loadingText:SetText(requestingUpdate)
            local function updateText()
                if frame.content.isUpdating then
                    local _, numPoints = string.gsub(frame.content.loadingText:GetText(), "%.", "")
                    if numPoints < 5 then
                        frame.content.loadingText:SetText(frame.content.loadingText:GetText() .. ".")
                    else
                        frame.content.loadingText:SetText(requestingUpdate)
                    end
                    C_Timer.After(0.2, updateText)                   
                end
            end

            updateText()
            C_Timer.After(CraftSim.CUSTOMER_SERVICE.timeoutSeconds, function() checkForTimeOut(updateID) end)
        end

        frame.content.StopUpdate = function (timedOut)
            frame.content.isUpdating = false
            if not timedOut then
                frame.content.loadingText:Hide()
            end
            frame.SetEnabled(true)
            frame.content.updates = {}
        end
        local function onOptionalReagentSelected(_, _, itemID) 
            print("selected optional Reagent: " .. tostring(itemID))
            CraftSim.CUSTOMER_SERVICE.SendRecipeUpdateRequest(frame.currentRecipeID) 
        end

        local function onCheckboxChecked()
            CraftSim.CUSTOMER_SERVICE.SendRecipeUpdateRequest(frame.currentRecipeID)
        end

        frame.content.guaranteeCB = CraftSim.FRAME:CreateCheckboxCustomCallback(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX_EXPLANATION),
            false, onCheckboxChecked, frame.content, frame.content.recipeDropdown.frame, "TOPLEFT", "BOTTOMLEFT", 17, 0)

        local dropdownWidth = 120
        local dropdownOffsetX = 70
        local dropdownBaseY = 0
        local dropdownSpacingY = -40
        frame.content.optionalDropdownGroup = CreateFrame("frame", nil, frame.content)
        frame.content.optionalDropdownGroup:SetSize(dropdownWidth*2 + dropdownOffsetX, -1*dropdownBaseY + -1*dropdownSpacingY*2 + 25)
        frame.content.optionalDropdownGroup:SetPoint("TOP", frame.content.recipeDropdown.frame, "BOTTOM", 0, -35)

        frame.content.optionalDropdownGroup.SetCollapsed = function(collapsed)
            if collapsed then
                frame.content.optionalDropdownGroup:Hide()
                frame.content.optionalDropdownGroup:SetSize(0, 0)
            else
                frame.content.optionalDropdownGroup:SetSize(dropdownWidth*2 + dropdownOffsetX, -1*dropdownBaseY + -1*dropdownSpacingY*2 + 10)
                frame.content.optionalDropdownGroup:Show()
            end
        end

        frame.content.optionalDropdownGroup.SetCollapsed(true)
        frame.content.optionalDropdownGroup:Hide()

        local function CreateReagentInputDropdown(label, offsetX, offsetY)
            local optionalReagentDropdown = CraftSim.GGUI.Dropdown({
                parent=frame.content.optionalDropdownGroup, anchorParent=frame.content.optionalDropdownGroup, anchorA="TOP",anchorB="TOP",
                label=label, offsetX=offsetX,offsetY=offsetY, width=dropdownWidth, clickCallback=onOptionalReagentSelected,
            })
            return optionalReagentDropdown
        end

        
        frame.content.optionalDropdowns = {
            CreateReagentInputDropdown(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_OPTIONAL) .. " 1", - dropdownOffsetX, dropdownBaseY),
            CreateReagentInputDropdown(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_OPTIONAL) .. " 2", - dropdownOffsetX, dropdownBaseY + dropdownSpacingY),
            CreateReagentInputDropdown(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_OPTIONAL) .. " 3", - dropdownOffsetX, dropdownBaseY + dropdownSpacingY*2),

            CreateReagentInputDropdown(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_FINISHING) .. " 1", dropdownOffsetX, dropdownBaseY),
            CreateReagentInputDropdown(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_FINISHING) .. " 2", dropdownOffsetX, dropdownBaseY + dropdownSpacingY),
        } 
        
        frame.content.craftingCosts = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTING_COSTS) .. "\n" .. CraftSim.GUTIL:FormatMoney(0), 
            frame.content, frame.content.optionalDropdownGroup, "TOP", "BOTTOM", 0, -20)
        
        frame.content.expectedResultTitle = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_RESULTS), 
            frame.content, frame.content.craftingCosts, "TOP", "BOTTOM", -80, -10, nil, nil)
        
        frame.content.expectedResultIcon = CraftSim.GGUI.Icon({
            parent=frame.content,anchorParent=frame.content.expectedResultTitle,
            sizeX=40, sizeY=40, offsetY=-10, anchorA="TOP", anchorB="BOTTOM"
        })
        
        frame.content.expectedInspirationPercent = CraftSim.FRAME:CreateText("100% " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_INSPIRATION),
            frame.content, frame.content.craftingCosts, "TOP", "BOTTOM", 80, -10, nil, nil)
        
        frame.content.expectedInspirationIcon = CraftSim.GGUI.Icon({
            parent=frame.content,anchorParent=frame.content.expectedInspirationPercent,
            sizeX=40, sizeY=40, offsetY=-10, anchorA="TOP", anchorB="BOTTOM"
        })
        
        frame.content.reagentDetailsTitle = CraftSim.FRAME:CreateText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REQUIRED_MATERIALS),
            frame.content, frame.content.craftingCosts, "TOP", "BOTTOM", 0, -80)
        
        local function createReagentFrame(anchorA, anchorParent, anchorB, anchorX, anchorY)
            local iconSize = 30
            local reagentFrame = CreateFrame("frame", nil, frame.content)
            reagentFrame:SetSize(iconSize, iconSize)
            reagentFrame:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
            
            reagentFrame.icon = CraftSim.GGUI.Icon({
                parent=reagentFrame, sizeX=iconSize, sizeY=iconSize, anchorA="LEFT", anchorB="LEFT", anchorParent=reagentFrame,
                hideQualityIcon=true,
            })
            reagentFrame.countTextNoQ = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon.frame, "LEFT", "RIGHT", 5, 0, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            
            reagentFrame.countTextQ1 = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon.frame, "LEFT", "RIGHT", 5, 12, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            reagentFrame.countTextQ2 = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon.frame, "LEFT", "RIGHT", 5, 0, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            reagentFrame.countTextQ3 = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon.frame, "LEFT", "RIGHT", 5, -12, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            reagentFrame.SetReagent = function (itemID, isQuality, countq1, countq2, countq3)
                reagentFrame.icon:SetItem(itemID)
                if not itemID then
                    reagentFrame:Hide()
                    return
                end
                reagentFrame:Show()
                local countText = ""
                if not isQuality then
                    countText = " x " .. countq1
                    reagentFrame.countTextNoQ:Show()
                    reagentFrame.countTextQ1:Hide()
                    reagentFrame.countTextQ2:Hide()
                    reagentFrame.countTextQ3:Hide()
                    reagentFrame.countTextNoQ:SetText(countText)
                else 
                    local qualityIconSize = 15
                    local q1Icon = CraftSim.GUTIL:GetQualityIconString(1, qualityIconSize, qualityIconSize, 0, 0)
                    local q2Icon = CraftSim.GUTIL:GetQualityIconString(2, qualityIconSize, qualityIconSize, 0, 0)
                    local q3Icon = CraftSim.GUTIL:GetQualityIconString(3, qualityIconSize, qualityIconSize, 0, 0)
                    reagentFrame.countTextNoQ:Hide()
                    reagentFrame.countTextQ1:SetText(q1Icon .. " x " .. countq1)
                    reagentFrame.countTextQ2:SetText(q2Icon .. " x " .. countq2)
                    reagentFrame.countTextQ3:SetText(q3Icon .. " x " .. countq3)
                    reagentFrame.countTextQ1:Show()
                    reagentFrame.countTextQ2:Show()
                    reagentFrame.countTextQ3:Show()
                end
            end
            
            return reagentFrame
        end
        local spacingX = 80
        local baseX = -45
        local baseY = -10
        local spacingY = -40
        frame.content.reagentFrames = {
            createReagentFrame("TOPLEFT", frame.content.reagentDetailsTitle, "BOTTOMLEFT", baseX, baseY),
            createReagentFrame("TOPLEFT", frame.content.reagentDetailsTitle, "BOTTOMLEFT", baseX + spacingX, baseY),
            createReagentFrame("TOPLEFT", frame.content.reagentDetailsTitle, "BOTTOMLEFT", baseX + spacingX*2, baseY),
            createReagentFrame("TOPLEFT", frame.content.reagentDetailsTitle, "BOTTOMLEFT", baseX, baseY + spacingY),
            createReagentFrame("TOPLEFT", frame.content.reagentDetailsTitle, "BOTTOMLEFT", baseX + spacingX, baseY + spacingY),
            createReagentFrame("TOPLEFT", frame.content.reagentDetailsTitle, "BOTTOMLEFT", baseX + spacingX*2, baseY + spacingY),
        }

        frame.SetEnabled = function(value)
            -- disable/enable all childs
            frame.content.recipeDropdown:SetEnabled(value)
            frame.content.guaranteeCB:SetEnabled(value)
        end

    end

    createContent(frame)
    CraftSim.GGUI:EnableHyperLinksForFrameAndChilds(frame.content)
end

function CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreviewSession(payload)
    local recipes = payload.recipes
    local crafter = payload.crafter
    local professionName = payload.professionName
    local previewFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.LIVE_PREVIEW)

    previewFrame.professionID = payload.professionID
    previewFrame.crafter = crafter
    previewFrame.recipeList = recipes

    -- convert recipes to dropdown data
    local function convertToDropdownListData(data)
        local dropDownListData = {}
        for categoryName, recipes in pairs(data) do
            local dropdownEntry = {
                label = categoryName,
                value = {},
                isCategory=true,
            }
            for _, recipeEntry in pairs(recipes) do
                table.insert(dropdownEntry.value, {
                    label = recipeEntry.recipeName,
                    value = recipeEntry.recipeID,
                })
            end

            table.insert(dropDownListData, dropdownEntry)
            
        end
        return dropDownListData
    end

    previewFrame.content.previewTitle:SetText(crafter .. " " .. professionName)
    for _, reagentFrame in pairs(previewFrame.content.reagentFrames) do
        reagentFrame:Hide()
    end
    previewFrame.content.craftingCosts:Hide()
    previewFrame.content.expectedResultTitle:Hide()
    previewFrame.content.expectedResultIcon:Hide()
    previewFrame.content.expectedInspirationPercent:Hide()
    previewFrame.content.expectedInspirationIcon:Hide()
    previewFrame.content.reagentDetailsTitle:Hide()
    previewFrame.content.optionalDropdownGroup:Hide()
    previewFrame.content.guaranteeCB:Hide()


    previewFrame.content.recipeDropdown:SetData({data=convertToDropdownListData(recipes), initialValue=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES_INITIAL)})

    previewFrame:Show()
end

function CraftSim.CUSTOMER_SERVICE.FRAMES:UpdateRecipe(payload)
    local previewFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.LIVE_PREVIEW)
    local resultData = payload.resultData
    local reagents = payload.reagents
    local optionalReagents = payload.optionalReagents
    local finishingReagents = payload.finishingReagents
    local supportsQualities = payload.supportsQualities

    if resultData.canUpgradeQuality then
        local upgradeChanceText = payload.upgradeChance .. "% "
        previewFrame.content.expectedInspirationPercent:SetText(upgradeChanceText .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_INSPIRATION))
        previewFrame.content.expectedInspirationIcon:SetItem(resultData.expectedItemUpgrade, nil, nil, true)
        previewFrame.content.expectedInspirationIcon:Show()
        previewFrame.content.expectedInspirationPercent:Show()
    else
        previewFrame.content.expectedInspirationIcon:Hide()
        previewFrame.content.expectedInspirationPercent:Hide()
    end
    
    previewFrame.content.reagentDetailsTitle:Show()
    previewFrame.content.expectedResultTitle:Show()
    previewFrame.content.expectedResultIcon:Show()
    previewFrame.content.expectedResultIcon:SetItem(resultData.expectedItem, nil, nil, true)
    if supportsQualities then
        previewFrame.content.guaranteeCB:Show()
    else
        previewFrame.content.guaranteeCB:Hide()
    end

    local craftingCosts = 0

    for i, reagent in pairs(reagents) do
        for _, reagentItem in pairs(reagent.items) do
            local reagentCost = reagentItem.quantity * CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true)
            print("reagentCost #" .. i .. ": " .. CraftSim.GUTIL:FormatMoney(reagentCost))
            print(reagentItem.quantity .. " x " .. CraftSim.PRICEDATA:GetMinBuyoutByItemID(reagentItem.item:GetItemID(), true))
            craftingCosts = craftingCosts + reagentCost
        end
    end

    for _, dropdown in pairs(previewFrame.content.optionalDropdowns) do
        if dropdown.selectedID then
            local reagentCost = CraftSim.PRICEDATA:GetMinBuyoutByItemID(dropdown.selectedID, true)
            craftingCosts = craftingCosts + reagentCost
        end
    end

    for index, reagentFrame in pairs(previewFrame.content.reagentFrames) do
        local currentReagent = reagents[index]
        if currentReagent then
            local itemID = tonumber(currentReagent.items[1].item:GetItemID())
            if currentReagent.hasQuality then
                reagentFrame.SetReagent(itemID, true,
                currentReagent.items[1].quantity, 
                currentReagent.items[2].quantity, 
                currentReagent.items[3].quantity)
            else
                reagentFrame.SetReagent(itemID, false, currentReagent.items[1].quantity)
            end
        else
            reagentFrame.SetReagent(nil)
        end
    end

    if payload.isInit then
        previewFrame.currentOptionalReagentSlots = optionalReagents
        previewFrame.currentFinishingReagentSlots = finishingReagents
        previewFrame.content.optionalDropdownGroup.SetCollapsed(#optionalReagents + #finishingReagents == 0)

        ---@param optionalReagentList CraftSim.OptionalReagent[]
        local function convertOptionalReagentsToDropdownListData(optionalReagentList)
            local dropDownListData = {{label = "None", value = nil}}
            for _, optionalReagent in pairs(optionalReagentList) do
                table.insert(dropDownListData, {
                    label = optionalReagent.item:GetItemLink(),
                    value = optionalReagent.item:GetItemID(),
                })
            end
            return dropDownListData
        end

        local dropdownIndex = 1
        for i = 1, 5, 1 do
            local dropdown = previewFrame.content.optionalDropdowns[i]
            local optionalReagentSlot = nil
            if i < 4 then
                optionalReagentSlot = optionalReagents[i]
            else
                optionalReagentSlot = finishingReagents[i-3]
            end

            if optionalReagentSlot then
                dropdown:Show()
                if not optionalReagentSlot.locked then
                    local dropdownListData = convertOptionalReagentsToDropdownListData(optionalReagentSlot.possibleReagents)
                    dropdown:SetData({data=dropdownListData, initialValue=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENTS_NONE)})
                    --CraftSim.FRAME:initializeDropdownByData(dropdown, dropdownListData, "None", true)
                    dropdown.selectedValue = nil
                else
                    dropdown:SetData({data={}, initialValue=CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENTS_LOCKED), CraftSim.GUTIL.COLORS.RED)})
                    --CraftSim.FRAME:initializeDropdownByData(dropdown, {}, CraftSim.GUTIL:ColorizeText("Locked", CraftSim.GUTIL.COLORS.RED))
                    dropdown.selectedValue = nil
                end
            else
                dropdown:Hide()
            end

            dropdownIndex = dropdownIndex + 1
        end
    else

    end

    previewFrame.content.craftingCosts:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTING_COSTS) .. "\n" .. CraftSim.GUTIL:FormatMoney(craftingCosts))
    previewFrame.content.craftingCosts:Show()
end