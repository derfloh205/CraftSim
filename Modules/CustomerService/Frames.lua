AddonName, CraftSim = ...

CraftSim.CUSTOMER_SERVICE.FRAMES = {}

function CraftSim.CUSTOMER_SERVICE.FRAMES:Init()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimCustomerServiceFrame", "CraftSim Customer Service",
    ProfessionsFrame, UIParent, "CENTER", "CENTER", 0, 0, 
    400, 300, CraftSim.CONST.FRAMES.CUSTOMER_SERVICE, false, true, "DIALOG", "modulesCustomerService")

    local function createContent(frame)
        local autoReplyTab = CraftSim.FRAME:CreateTab("Auto Reply", frame.content, frame.title, "TOP", "BOTTOM", -70, -15, true, 300, 250, frame.content, frame.title, 0, -50)
        local autoResultTab = CraftSim.FRAME:CreateTab("Live Preview", frame.content, autoReplyTab, "LEFT", "RIGHT", 0, 0, true, 300, 250, frame.content, frame.title, 0, -50)

        autoReplyTab.content.enableReplyCB = CraftSim.FRAME:CreateCheckbox("Enable Auto Reply", "Enable the automatic answering with the highest possible results and material costs when someone whispers you the command and an item link for an item you can craft!", 
        "customerServiceEnableAutoReply", autoReplyTab.content, autoReplyTab.content, "TOPLEFT", "TOPLEFT", 10, -10)

        autoReplyTab.content.whisperCommandTitle = CraftSim.FRAME:CreateText("Command:", autoReplyTab.content, autoReplyTab.content.enableReplyCB, "TOPLEFT", "BOTTOMLEFT", 0, -10)
        autoReplyTab.content.whisperCommandInput = CraftSim.FRAME:CreateInput(nil, autoReplyTab.content, autoReplyTab.content.whisperCommandTitle, "LEFT", "RIGHT", 5, 0, 100, 25, 
        CraftSimOptions.customerServiceAutoReplyCommand, 
        function() 
            CraftSimOptions.customerServiceAutoReplyCommand = autoReplyTab.content.whisperCommandInput:GetText()
        end)
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
        autoReplyTab.content, autoReplyTab.content.whisperCommandInput, "TOPLEFT", "BOTTOMLEFT", 5, -15)

        autoReplyTab.content.messageFormatHelp = CraftSim.FRAME:CreateHelpIcon(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION), autoReplyTab.content, autoReplyTab.content.messageFormatTitle, "LEFT", "RIGHT", 10, 0)


        autoReplyTab.content.msgFormatScrollFrame, autoReplyTab.content.msgFrameContent =
         CraftSim.FRAME:CreateScrollFrame(autoReplyTab.content, -90, 10, -10, 50)

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
        "Enable live crafting preview connections to you via CraftSim Preview Links.\nAnyone who has CraftSim and clicks the shared link can live connect to your crafting information to check out your crafting abilities", "customerServiceAllowAutoResult", 
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