AddonName, CraftSim = ...

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
    })

    local function createContent(frame)
        self.frame:Hide()
        self.frame.content.customerDropdown = CraftSim.GGUI.Dropdown({
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", offsetY=-30, width=170, offsetX=-170,
            initialValue=nil,
            initialLabel="",
            label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL),
            initialData={},
            clickCallback=function (_, _, item) CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(item) end
        })
        self.frame.content.totalTip = CraftSim.GGUI.Text({
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", offsetX=200, offsetY=-30,
            text="",
            font="GameFontNormal",
            justifyOptions={
                type="H",
                align="RIGHT"
            }
        })
        self.frame.content.messageBox = CraftSim.GGUI.ScrollingMessageFrame({
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", offsetX=0, offsetY=-70,
            sizeX=self.frame.originalX - 20, sizeY=self.frame.originalY - 100,
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

local function GetFallbackCustomer()
    if CraftSim.CUSTOMER_HISTORY.FRAMES.lastCustomer then
        return CraftSim.CUSTOMER_HISTORY.FRAMES.lastCustomer
    end
    for k, v in pairs(CraftSim.CUSTOMER_HISTORY.db.realm) do
        if type(v) == "table" then
            return k
        end
    end
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(customer)
    customer = customer or GetFallbackCustomer()
    if not customer then
        return
    end

    if C_TradeSkillUI.IsTradeSkillReady() then
        self:ResetDropdown(customer)
        self:LoadHistory(customer)
    end
    self.lastCustomer = customer
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:LoadTotalTip(customer)
    self.frame.content.totalTip:SetText(string.format("%s%s", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP), CraftSim.GUTIL:FormatMoney(CraftSim.CUSTOMER_HISTORY.db.realm[customer].totalTip or 0)))
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:LoadHistory(customer)
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

function CraftSim.CUSTOMER_HISTORY.FRAMES:ResetDropdown(customer)
    local data = CraftSim.GUTIL:Map(CraftSim.CUSTOMER_HISTORY.db.realm, function(a, e) if (a.history) then return {label=e, value=e} end end)
    self.frame.content.customerDropdown:SetData({
        initialLabel=customer,
        initialValue=customer,
        initialData=data,
        data=data,
    })
end