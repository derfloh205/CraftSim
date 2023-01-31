AddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_SERVICE)

function CraftSim.CUSTOMER_SERVICE.FRAMES:Init()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimCustomerServiceFrame", "CraftSim Customer Service",
    ProfessionsFrame, UIParent, "CENTER", "CENTER", 0, 0, 
    400, 300, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE, false, true, "DIALOG", "modulesCustomerService")

    local function createContent(frame)
        frame:Hide()
        local autoReplyTab = CraftSim.FRAME:CreateTab("Auto Reply", frame.content, frame.title, "TOP", "BOTTOM", -70, -15, true, 300, 250, frame.content, frame.title, 0, -50)
        local autoResultTab = CraftSim.FRAME:CreateTab("Live Preview", frame.content, autoReplyTab, "LEFT", "RIGHT", 0, 0, true, 300, 250, frame.content, frame.title, 0, -50)

        autoReplyTab.content.enableReplyCB = CraftSim.FRAME:CreateCheckbox("Enable Auto Reply", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_EXPLANATION), 
        "customerServiceEnableAutoReply", autoReplyTab.content, autoReplyTab.content, "TOPLEFT", "TOPLEFT", 10, -10)

        autoReplyTab.content.whisperCommandTitle = CraftSim.FRAME:CreateText("Command:", autoReplyTab.content, autoReplyTab.content.enableReplyCB, "TOPLEFT", "BOTTOMLEFT", 0, -10)
        autoReplyTab.content.whisperCommandInput = CraftSim.FRAME:CreateInput(nil, autoReplyTab.content, autoReplyTab.content.whisperCommandTitle, "LEFT", "RIGHT", 5, 0, 100, 25, 
        CraftSimOptions.customerServiceAutoReplyCommand, 
        function() 
            CraftSimOptions.customerServiceAutoReplyCommand = autoReplyTab.content.whisperCommandInput:GetText()
            autoReplyTab.content.commandPreview:SetText("Example: " .. CraftSimOptions.customerServiceAutoReplyCommand .. " <itemLink> <ilvl>")
        end)
        autoReplyTab.content.commandPreview = CraftSim.FRAME:CreateText("Example: " .. CraftSimOptions.customerServiceAutoReplyCommand .. " <itemLink> <ilvl>", 
        autoReplyTab.content, autoReplyTab.content.whisperCommandTitle, "TOPLEFT", "BOTTOMLEFT", 0, -15, nil, nil, {type="H", value="LEFT"})
        autoReplyTab.content.resetDefaults = CraftSim.FRAME:CreateButton("Reset to Defaults", autoReplyTab.content, autoReplyTab.content.whisperCommandInput, "LEFT", "RIGHT", 15, 0, 15, 25, true, function() 
            local defaultFormat = 
            "Highest Result: %gc\n" ..
            "with Inspiration: %ic (%insp)\n" ..
            "Crafting Costs: %cc\n" ..
            "%ccd"
            local defaultCommand = "!craft"
            CraftSimOptions.customerServiceAutoReplyFormat = defaultFormat
            autoReplyTab.content.msgFrameContent.msgFormatBox:SetText(defaultFormat)

            autoReplyTab.content.whisperCommandInput:SetText(defaultCommand)
            CraftSimOptions.customerServiceAutoReplyCommand = defaultCommand
        end)

        autoReplyTab.content.messageFormatTitle = CraftSim.FRAME:CreateText("Message Format", 
        autoReplyTab.content, autoReplyTab.content.commandPreview, "TOPLEFT", "BOTTOMLEFT", 80, -15)

        autoReplyTab.content.messageFormatHelp = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION), autoReplyTab.content, autoReplyTab.content.messageFormatTitle, "LEFT", "RIGHT", 10, 0)


        autoReplyTab.content.msgFormatScrollFrame, autoReplyTab.content.msgFrameContent =
         CraftSim.FRAME:CreateScrollFrame(autoReplyTab.content, -110, 10, -10, 40)

        autoReplyTab.content.msgFrameContent.msgFormatBox = CreateFrame("EditBox", nil, autoReplyTab.content.msgFrameContent)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetPoint("TOP", autoReplyTab.content.msgFrameContent, "TOP", 0, -5)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetText(CraftSimOptions.customerServiceAutoReplyFormat)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetWidth(autoReplyTab.content.msgFrameContent:GetWidth() - 15)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetHeight(20)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetMultiLine(true)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetAutoFocus(false)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetFontObject("ChatFontNormal")
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetScript("OnEscapePressed", function() autoReplyTab.content.msgFrameContent.msgFormatBox:ClearFocus() end)
        autoReplyTab.content.msgFrameContent.msgFormatBox:SetScript("OnTextChanged", function() 
            CraftSimOptions.customerServiceAutoReplyFormat = autoReplyTab.content.msgFrameContent.msgFormatBox:GetText()
        end)

        autoResultTab.content.enableConnections = CraftSim.FRAME:CreateCheckbox("Allow Connections", 
        CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION), "customerServiceAllowAutoResult", 
        autoResultTab.content, autoResultTab.content, "TOPLEFT", "TOPLEFT", 10, -10)

        autoResultTab.content.browserInviteInput = CraftSim.FRAME:CreateInput(nil, autoResultTab.content, autoResultTab.content.enableConnections, "TOPLEFT", "BOTTOMLEFT", 0, 0, 150, 25, 
        "", 
        function() 
        end)

        autoResultTab.content.inviteButton = CraftSim.FRAME:CreateButton("Send Invite", autoResultTab.content.browserInviteInput, autoResultTab.content.browserInviteInput, "LEFT", "RIGHT", 5, 0, 15, 25, true, function()
            local whisperTarget = autoResultTab.content.browserInviteInput:GetText()
            CraftSim.CUSTOMER_SERVICE:WhisperInvite(whisperTarget)
        end)
        
        frame.tabs = {autoReplyTab, autoResultTab}
        CraftSim.FRAME:InitTabSystem(frame.tabs)
    end

    createContent(frame)
end

function CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreview()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimLivePreviewFrame", "CraftSim Live Preview", UIParent, UIParent,
    "CENTER", "CENTER", 0, 0, 500, 400, CraftSim.CONST.FRAMES.LIVE_PREVIEW, false, true, "DIALOG")

    local function createContent(frame)
        frame:Hide()

        local function onRecipeSelected(_, recipeID)
            print("Selected RecipeID: " .. tostring(recipeID))
            CraftSim.CUSTOMER_SERVICE.SendRecipeUpdateRequest(recipeID) 
        end

        frame.content.previewTitle = CraftSim.FRAME:CreateText("Crafter's Profession", frame.content, frame.title, "TOP", "BOTTOM", 0, -10)

        frame.content.recipeDropdown = CraftSim.FRAME:initDropdownMenu(nil, frame.content, frame.content.previewTitle, "Learned Recipes", 0, -30, 200, {}, onRecipeSelected, "Select Recipe", true)

        frame.content.craftingCosts = CraftSim.FRAME:CreateText("Crafting Costs\n" .. CraftSim.UTIL:FormatMoney(0), frame.content, frame.content.recipeDropdown, "TOP", "BOTTOM", 0, -15)
        
        frame.content.expectedResultTitle = CraftSim.FRAME:CreateText("Expected Result", frame.content, frame.content.craftingCosts, "TOP", "BOTTOM", -80, -10, nil, nil)
        
        local resultQualityIconSize = 20
        frame.content.expectedResultIcon = CraftSim.FRAME:CreateIcon(frame.content, 0, -10, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40, "TOP", "BOTTOM", frame.content.expectedResultTitle)
        frame.content.expectedResultQualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content.expectedResultIcon, resultQualityIconSize, resultQualityIconSize, frame.content.expectedResultIcon, "TOPLEFT", "TOPLEFT", -3, 3, 1)
        
        frame.content.expectedInspirationPercent = CraftSim.FRAME:CreateText("100% Chance for", frame.content, frame.content.craftingCosts, "TOP", "BOTTOM", 80, -10, nil, nil)
        frame.content.expectedInspirationIcon = CraftSim.FRAME:CreateIcon(frame.content, 0, -10, CraftSim.CONST.EMPTY_SLOT_TEXTURE, 40, 40, "TOP", "BOTTOM", frame.content.expectedInspirationPercent)
        frame.content.expectedInspirationQualityIcon = CraftSim.FRAME:CreateQualityIcon(frame.content.expectedInspirationIcon, resultQualityIconSize, resultQualityIconSize, frame.content.expectedInspirationIcon, "TOPLEFT", "TOPLEFT", -3, 3, 1)
        
        frame.content.reagentDetailsTitle = CraftSim.FRAME:CreateText("Required Materials", frame.content, frame.content.craftingCosts, "TOP", "BOTTOM", 0, -80)
        
        local function createReagentFrame(anchorA, anchorParent, anchorB, anchorX, anchorY)
            local iconSize = 30
            local reagentFrame = CreateFrame("frame", nil, frame.content)
            reagentFrame:SetSize(iconSize, iconSize)
            reagentFrame:SetPoint(anchorA, anchorParent, anchorB, anchorX, anchorY)
            
            reagentFrame.icon = CraftSim.FRAME:CreateIcon(reagentFrame, 0, 0, CraftSim.CONST.EMPTY_SLOT_TEXTURE, iconSize, iconSize, "LEFT", "LEFT", reagentFrame)
            reagentFrame.countTextNoQ = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon, "LEFT", "RIGHT", 5, 0, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            
            reagentFrame.countTextQ1 = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon, "LEFT", "RIGHT", 5, 12, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            reagentFrame.countTextQ2 = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon, "LEFT", "RIGHT", 5, 0, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            reagentFrame.countTextQ3 = CraftSim.FRAME:CreateText(" x ???", reagentFrame, reagentFrame.icon, "LEFT", "RIGHT", 5, -12, 0.9, nil, {type="HV", valueH="LEFT", valueV="CENTER"})
            reagentFrame.SetReagent = function (itemID, isQuality, countq1, countq2, countq3)
                print("set reagent: " .. tostring(itemID) .. " - " .. tostring(type(itemID)))
                print("qualities? " .. tostring(isQuality))
                reagentFrame.icon.SetItem(itemID, frame.content)
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
                    local q1Icon = CraftSim.UTIL:GetQualityIconAsText(1, qualityIconSize, qualityIconSize, 0, 0)
                    local q2Icon = CraftSim.UTIL:GetQualityIconAsText(2, qualityIconSize, qualityIconSize, 0, 0)
                    local q3Icon = CraftSim.UTIL:GetQualityIconAsText(3, qualityIconSize, qualityIconSize, 0, 0)
                    print("quality Icons:")
                    print(q1Icon)
                    print(q2Icon)
                    print(q3Icon)
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

    end

    createContent(frame)
    CraftSim.FRAME:EnableHyperLinksForFrameAndChilds(frame)
end

function CraftSim.CUSTOMER_SERVICE.FRAMES:InitLivePreviewSession(payload)
    local recipes = payload.recipes
    local crafter = payload.crafter
    local professionName = payload.professionName
    local previewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.LIVE_PREVIEW)

    previewFrame.professionID = payload.professionID
    previewFrame.crafter = crafter
    previewFrame.recipeList = recipes

    -- convert recipes to dropdown data
    local function convertToDropdownListData(data)
        local dropDownListData = {}
        for _, recipeEntry in pairs(data) do
            table.insert(dropDownListData, {
                label = recipeEntry.recipeName,
                value = recipeEntry.recipeID,
            })
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
    CraftSim.FRAME:initializeDropdownByData(previewFrame.content.recipeDropdown, convertToDropdownListData(recipes), "Select a Recipe")

    previewFrame:Show()
end

function CraftSim.CUSTOMER_SERVICE.FRAMES:UpdateRecipe(payload)
    local previewFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.LIVE_PREVIEW)
    local outputInfo = payload.outputInfo
    local reagents = payload.reagents

    -- load reagents, then continue
    local itemsToLoad = {}
    for _, reagent in pairs(reagents) do
        for _, itemInfo in pairs(reagent.itemsInfo) do
            local itemID = tonumber(itemInfo.itemID)
            local item = Item:CreateFromItemID(itemID)
            table.insert(itemsToLoad, item)
            itemInfo.item = item
        end
    end

    CraftSim.UTIL:ContinueOnAllItemsLoaded(itemsToLoad, function ()
        if outputInfo.inspirationCanUpgrade then
            local inspirationText = payload.inspirationPercent .. "%"
            previewFrame.content.expectedInspirationPercent:SetText(inspirationText .. " Chance for")
            previewFrame.content.expectedInspirationIcon.SetItem(outputInfo.inspiration, nil, nil, true)
            previewFrame.content.expectedInspirationQualityIcon.SetQuality(outputInfo.expectedQualityInspiration)
            previewFrame.content.expectedInspirationIcon:Show()
            previewFrame.content.expectedInspirationPercent:Show()
            previewFrame.content.expectedInspirationQualityIcon:Show()
        else
            previewFrame.content.expectedInspirationIcon:Hide()
            previewFrame.content.expectedInspirationPercent:Hide()
            previewFrame.content.expectedInspirationQualityIcon:Hide()
        end
    
        previewFrame.content.reagentDetailsTitle:Show()
        previewFrame.content.expectedResultTitle:Show()
        previewFrame.content.expectedResultIcon:Show()
        previewFrame.content.expectedResultIcon.SetItem(outputInfo.expected, nil, nil, true)
        if not outputInfo.isNoQuality then
            previewFrame.content.expectedResultQualityIcon.SetQuality(outputInfo.expectedQuality)
            previewFrame.content.expectedResultQualityIcon:Show()
        else
            previewFrame.content.expectedResultQualityIcon:Hide()
        end
    
        local craftingCosts = 0
    
        for _, reagent in pairs(reagents) do
            for _, itemInfo in pairs(reagent.itemsInfo) do
                local reagentCost = tonumber(itemInfo.allocations) + CraftSim.PRICEDATA:GetMinBuyoutByItemID(tonumber(itemInfo.itemID), true)
                craftingCosts = craftingCosts + reagentCost
            end
        end

        for index, reagentFrame in pairs(previewFrame.content.reagentFrames) do
            local currentReagent = reagents[index]
            if currentReagent then
                local itemID = tonumber(currentReagent.itemsInfo[1].itemID)
                if currentReagent.differentQualities then
                    reagentFrame.SetReagent(itemID, true,
                    currentReagent.itemsInfo[1].allocations, 
                    currentReagent.itemsInfo[2].allocations, 
                    currentReagent.itemsInfo[3].allocations)
                else
                    reagentFrame.SetReagent(itemID, false, currentReagent.itemsInfo[1].allocations)
                end
            else
                reagentFrame.SetReagent(nil)
            end
        end

        --previewFrame.content.materialDetails:SetText(materialDetailText)
        previewFrame.content.craftingCosts:SetText("Crafting Costs\n" .. CraftSim.UTIL:FormatMoney(craftingCosts))
        previewFrame.content.craftingCosts:Show()
    end)
end