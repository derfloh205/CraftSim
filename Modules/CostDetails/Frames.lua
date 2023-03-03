_, CraftSim = ...


CraftSim.COST_DETAILS.FRAMES = {}

CraftSim.COST_DETAILS.frame = nil
CraftSim.COST_DETAILS.frameWO = nil

function CraftSim.COST_DETAILS.FRAMES:Init()

    local sizeX=300
    local sizeY=250

    CraftSim.COST_DETAILS.frame = CraftSim.GGUI.Frame({
            parent=ProfessionsFrame.CraftingPage.SchematicForm, 
            anchorParent=CraftSim.PRICE_DETAILS.frame.frame,
            anchorA="TOP",anchorB="BOTTOM",
            sizeX=sizeX,sizeY=sizeY, offsetY=10,
            frameID=CraftSim.CONST.FRAMES.COST_DETAILS, 
            title="CraftSim Cost Details",
            collapseable=true,
            closeable=true,
            moveable=true,
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCostDetails"),
        })
    CraftSim.COST_DETAILS.frameWO = CraftSim.GGUI.Frame({
            parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, 
            anchorParent=CraftSim.PRICE_DETAILS.frameWO.frame,
            anchorA="TOP",anchorB="BOTTOM",
            sizeX=sizeX,sizeY=sizeY, offsetY=10,
            frameID=CraftSim.CONST.FRAMES.COST_DETAILS, 
            title="CraftSim Cost Details " .. CraftSim.GUTIL:ColorizeText("WO", CraftSim.GUTIL.COLORS.GREY),
            collapseable=true,
            closeable=true,
            moveable=true,
            backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
            onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesCostDetails"),
        })

    local function createContent(frame)
        frame.content.craftingCostsTitle = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content, anchorA="TOPLEFT", anchorB="TOPLEFT",
            offsetX=20, offsetY=-40, text="Crafting Costs: ",
        })
        frame.content.craftingCostsValue = CraftSim.GGUI.Text({
            parent=frame.content,anchorParent=frame.content.craftingCostsTitle.frame, anchorA="LEFT", anchorB="RIGHT",
            text=CraftSim.GUTIL:FormatMoney(123456789), justifyOptions={type="H",align="LEFT"}
        })
    end

    createContent(CraftSim.COST_DETAILS.frame)
    createContent(CraftSim.COST_DETAILS.frameWO)
end
