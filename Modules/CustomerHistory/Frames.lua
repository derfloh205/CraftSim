CraftSimAddonName, CraftSim = ...

CraftSim.CUSTOMER_HISTORY.FRAMES = {}
CraftSim.CUSTOMER_HISTORY.timeoutSeconds = 5

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_HISTORY)
local rawget = rawget

function CraftSim.CUSTOMER_HISTORY.FRAMES:Init()
    self.frame = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent=ProfessionsFrame.CraftingPage.SchematicForm,
        sizeX=600,sizeY=300,
        frameID=CraftSim.CONST.FRAMES.CUSTOMER_HISTORY,
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameStrata="DIALOG",
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCustomerHistory"),
        frameTable=CraftSim.MAIN.FRAMES,
        frameConfigTable=CraftSimGGUIConfig,
    })

    local function createContent(frame)
        self.frame:Hide()
        self.frame.content.customerDropdown = CraftSim.GGUI.Dropdown({
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", width=170, offsetX=-170, offsetY=-30,
            initialValue=nil,
            initialLabel="",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL),
            initialData={},
            clickCallback=function (_, _, item) CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(item) end
        })
        self.frame.content.deleteButton = CraftSim.GGUI.Button({
            parent=frame.content,anchorParent=self.frame.content.customerDropdown.frame, anchorA="LEFT", anchorB="RIGHT", offsetX=0, offsetY=2,
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON), sizeX=15, sizeY=20, adjustWidth=true,
            clickCallback=function ()
                CraftSim.CUSTOMER_HISTORY.db.realm[CraftSim.CUSTOMER_HISTORY.db.realm.lastCustomer] = nil
                self:ResetDropdown()
                self.frame.content.messageBox:Clear()
                self:LoadTotalTip()
                CraftSim.CUSTOMER_HISTORY.db.realm.lastCustomer = nil
                self.frame.content.deleteButton.frame:SetEnabled(false)
            end,
        })
        self.frame.content.deleteButton.frame:SetEnabled(false)

        self.frame.content.filterTextbox = CraftSim.FRAME:CreateInput("Search", self.frame.content, self.frame.content.customerDropdown.frame, "TOP", "BOTTOM", 0, 0, 170, 25,
        "",
        function(textInput, userInput)
            if not userInput then return end
            local input = textInput:GetText():gsub("^%s*(.-)%s*$", "%1") or ""
            self:ResetDropdown(CraftSim.CUSTOMER_HISTORY.db.realm.lastCustomer, input)
            if input ~= "" then
                if not _G["DropDownList"..1]:IsShown() then
                    ToggleDropDownMenu(1, nil, self.frame.content.customerDropdown.frame, self.frame.content.customerDropdown.frame.name, 170, 50, nil, nil)
                end
            elseif _G["DropDownList"..1]:IsShown() then
                ToggleDropDownMenu(1, nil, self.frame.content.customerDropdown.frame, self.frame.content.customerDropdown.frame.name, 170, 50, nil, nil)
            end
        end)

        self.frame.content.totalTip = CraftSim.GGUI.Text({
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", offsetX=200, offsetY=-36,
            text="",
            font="GameFontNormal",
            justifyOptions={
                type="H",
                align="RIGHT"
            }
        })
        self.frame.content.messageBox = CraftSim.GGUI.ScrollingMessageFrame({
            parent=self.frame.content, anchorParent=self.frame.content, anchorA="BOTTOMLEFT", anchorB="BOTTOMLEFT", offsetX=15, offsetY=15,
            sizeX=self.frame.originalX - 20, sizeY=self.frame.originalY - 130,
            enableScrolling=true,
            fading=false,
            justifyOptions={
                type="H",
                align="LEFT",
            },
            maxLines=50,
            font=GameFontNormal,
        })
        self.frame.content.messageBox:EnableHyperLinksForFrameAndChilds()
    end

    createContent(self.frame)
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(customer)
    customer = customer or CraftSim.CUSTOMER_HISTORY.db.realm.lastCustomer

    if C_TradeSkillUI.IsTradeSkillReady() then
        self.frame.content.deleteButton.frame:SetEnabled(customer ~= nil)
        self:ResetDropdown(customer, self.frame.content.filterTextbox:GetText() or nil)
        self:LoadHistory(customer)
    end
    CraftSim.CUSTOMER_HISTORY.db.realm.lastCustomer = customer
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:LoadTotalTip(customer)
    if customer then
        local totalTip = CraftSim.CUSTOMER_HISTORY.db.realm[customer].totalTip or 0
        self.frame.content.totalTip:SetText(string.format("%s%s", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP), CraftSim.GUTIL:FormatMoney(totalTip)))
    else
        self.frame.content.totalTip:SetText("")
    end
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:LoadHistory(customer)
    if not customer then
        return
    end
    print("Loading history for " .. customer)
    self:LoadTotalTip(customer)
    self.frame.content.messageBox:Clear()

    local info = ChatTypeInfo["WHISPER"]
    local fromText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM)
    local toText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO)
    local forText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR)
    local craftFormatText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT)
    for _, message in ipairs(CraftSim.CUSTOMER_HISTORY.db.realm[customer].history) do
        if message.from then
            self.frame.content.messageBox.frame:AddMessage(string.format("%s |Hplayer:%s:1:WHISPER|h[%s]|h|r: %s", fromText, customer, customer, message.from), info.r, info.g, info.b)
        elseif message.to then
            self.frame.content.messageBox.frame:AddMessage(string.format("%s |Hplayer:%s:1:WHISPER|h[%s]|h|r: %s", toText, customer, customer, message.to), info.r, info.g, info.b)
        else
            self.frame.content.messageBox.frame:AddMessage(string.format("%s |Hplayer:%s:1:WHISPER|h[%s]|h|r: ", forText, customer, customer) .. string.format(craftFormatText, message.crafted, CraftSim.GUTIL:FormatMoney(message.commission)))
        end
    end
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:ResetDropdown(customer, filter)
    local data = CraftSim.GUTIL:Map(CraftSim.CUSTOMER_HISTORY.db.realm, function(a, e)
        local valid, match = pcall(string.find, string.lower(e), string.lower(filter or ""))
        if (a.history and (not filter or not valid or match)) then
            return {label=e, value=e}
        end
    end)
    self.frame.content.customerDropdown:SetData({
        initialLabel=customer,
        initialValue=customer,
        initialData=data,
        data=data,
    })
end
