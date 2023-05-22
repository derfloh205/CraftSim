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

function CraftSim.CUSTOMER_HISTORY.FRAMES:AddCustomer(customer)
    self:ResetDropdown(customer)
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(customer)
    if not customer and next(CraftSim.CUSTOMER_HISTORY.db.realm) then
        customer = next(CraftSim.CUSTOMER_HISTORY.db.realm)
    elseif not customer then
        return
    end

    self:ResetDropdown(customer)
    self.frame.content.totalTip:SetText(string.format("%s%s", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP), CraftSim.GUTIL:FormatMoney(CraftSim.CUSTOMER_HISTORY.db.realm[customer].totalTip or 0)))
    self.frame.content.messageBox:Clear()

    for _, message in ipairs(CraftSim.CUSTOMER_HISTORY.db.realm[customer].history or {}) do
        if message.from then
            self.frame.content.messageBox.frame:AddMessage(string.format("%s |Hplayer:%s:1:WHISPER|h[%s]|h|r: %s", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM), customer, customer, message.from), ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b)
        elseif message.to then
            self.frame.content.messageBox.frame:AddMessage(string.format("%s |Hplayer:%s:1:WHISPER|h[%s]|h|r: %s", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO), customer, customer, message.to), ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b)
        else
            self.frame.content.messageBox.frame:AddMessage(string.format("%s |Hplayer:%s:1:WHISPER|h[%s]|h|r: ", CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR), customer, customer) .. string.format(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT), message.crafted, CraftSim.GUTIL:FormatMoney(message.commission)))
        end
    end
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:ResetDropdown(customer)
    k, v = next(CraftSim.CUSTOMER_HISTORY.db.realm)
    data = CraftSim.GUTIL:Map(CraftSim.CUSTOMER_HISTORY.db.realm, function(a, e) if (a.history) then return {label=e, value=e} end end)
    self.frame.content.customerDropdown:SetData({
        initialLabel=customer or k,
        initialValue=customer or k,
        initialData=data,
        data=data,
    })
end