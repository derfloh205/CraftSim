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
        title="TEST", -- CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE),
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
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", offsetY=-30, width=170,
            initialValue=nil,
            initialLabel="",
            label="Choose a customer",
            initialData={},
            clickCallback=function (_, _, item) CraftSim.CUSTOMER_HISTORY.FRAMES:SetCustomer(item) end
        })
        self.frame.content.messageBox = CraftSim.GGUI.ScrollingMessageFrame({
            parent=self.frame.content, anchorParent=self.frame.title.frame, anchorA="TOP", anchorB="TOP", offsetX=0, offsetY=-70,
            sizeX=self.frame.originalX - 20, sizeY=self.frame.originalY - 100,
            enableScrolling=true,
            fading=false,
            justifyOptions={
                type="HV",
                alignH="LEFT",
                alignV="BOTTOM"
            },
            maxLines=50,
            font=GameFontHighlight,
        })
        self.frame.content.messageBox:EnableHyperLinksForFrameAndChilds()
        -- self.frame.content.messageBox:SetTextColor(ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b, 1)
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

    -- if customer ~= self.frame.content.customerDropdown.selectedValue then
    self:ResetDropdown(customer)
    self.frame.content.messageBox:Clear()
    for _, message in pairs(CraftSim.CUSTOMER_HISTORY.db.realm[customer].history) do
        if rawget(message, "from") then
            self.frame.content.messageBox.frame:AddMessage(string.format("From |Hplayer:%s:1:WHISPER|h[%s]|h|r: %s", customer, customer, message.from), ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b)
        elseif rawget(message, "to") then
            self.frame.content.messageBox.frame:AddMessage(string.format("To |Hplayer:%s:1:WHISPER|h[%s]|h|r: %s", customer, customer, message.to), ChatTypeInfo["WHISPER"].r, ChatTypeInfo["WHISPER"].g, ChatTypeInfo["WHISPER"].b)
        end
    end
end

function CraftSim.CUSTOMER_HISTORY.FRAMES:ResetDropdown(customer)
    k, v = next(CraftSim.CUSTOMER_HISTORY.db.realm)
    self.frame.content.customerDropdown:SetData({
        initialLabel=customer or k,
        initialValue=customer or k,
        initialData=CraftSim.GUTIL:Map(CraftSim.CUSTOMER_HISTORY.db.realm, function(_, e) return {label=e, value=e} end),
        data=CraftSim.GUTIL:Map(CraftSim.CUSTOMER_HISTORY.db.realm, function(_, e) return {label=e, value=e} end),
    })
end