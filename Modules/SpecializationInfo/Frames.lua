AddonName, CraftSim = ...

CraftSim.SPECIALIZATION_INFO.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

function CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
    local sizeX=310
    local sizeY=320
    local offsetX=260
    local offsetY=341

    local frameNO_WO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent=ProfessionsFrame, 
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.SPEC_INFO, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        anchorA="BOTTOMLEFT",anchorB="BOTTOMRIGHT",offsetX=offsetX,offsetY=offsetY,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesSpecInfo"),
    })
    local frameWO = CraftSim.GGUI.Frame({
        parent=ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent=ProfessionsFrame, 
        sizeX=sizeX,sizeY=sizeY,
        frameID=CraftSim.CONST.FRAMES.SPEC_INFO_WO, 
        title=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_TITLE),
        collapseable=true,
        closeable=true,
        moveable=true,
        anchorA="BOTTOMLEFT",anchorB="BOTTOMRIGHT",offsetX=offsetX,offsetY=offsetY,
        backdropOptions=CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback=CraftSim.FRAME:HandleModuleClose("modulesSpecInfo"),
    })

    local function createContent(frame)
        frame:Hide()
    
        frame.content.knowledgePointSimulationButton = CraftSim.GGUI.Button({
            parent=frame.content, anchorParent=frame.title.frame,anchorA="TOP",anchorB="TOP",offsetY=-20,
            sizeX=15,sizeY=20, adjustWidth=true,label=CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION),
            clickCallback=function ()
                local specSimFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM)
                CraftSim.FRAME:ToggleFrame(CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM), not specSimFrame:IsVisible())
            end
        })

        frame.content.knowledgePointSimulationButton:SetEnabled(false)

        frame.content.notImplementedText = CraftSim.FRAME:CreateText(CraftSim.GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS), CraftSim.GUTIL.COLORS.LEGENDARY),
        frame.content, frame.content.knowledgePointSimulationButton.frame, "CENTER", "CENTER", 0, 0)
    
        frame.content.notImplementedText:Hide()
    
        frame.content.nodeLines = {}
        local function createNodeLine(parent, anchorParent, offsetY)
            local nodeLine = CreateFrame("frame", nil, parent)
            nodeLine:SetSize(frame.content:GetWidth(), 25)
            nodeLine:SetPoint("TOP", anchorParent, "TOP", 0, offsetY)
    
            nodeLine.statTooltip = CraftSim.FRAME:CreateHelpIcon("No data", nodeLine, nodeLine, "LEFT", "LEFT", 20, 0)
    
            nodeLine.nodeName = nodeLine:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            nodeLine.nodeName:SetPoint("LEFT", nodeLine.statTooltip, "RIGHT", 10, 0)
            nodeLine.nodeName:SetText("NodeName")
            return nodeLine
        end
        -- TODO: how many do I need?
        local baseY = -60
        local nodeLineSpacingY = -20
        local maxNodeLines = 31
        frame.content.AddNodeLine = function()
            local numNodeLines = #frame.content.nodeLines
            table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title.frame, baseY + nodeLineSpacingY*(numNodeLines-1)))
        end
        
        for i = 1, maxNodeLines, 1 do
            frame.content.AddNodeLine()
        end
    end

    createContent(frameWO)
    createContent(frameNO_WO)
end

function CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local specInfoFrame = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO_WO)
    else
        specInfoFrame = CraftSim.GGUI:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)
    end

    local specializationData = recipeData.specializationData

    if not specializationData.isImplemented then
        table.foreach(specInfoFrame.content.nodeLines, function (_, nodeLine)
            nodeLine:Hide()
        end)
        specInfoFrame.content.notImplementedText:Show()
        specInfoFrame.content.knowledgePointSimulationButton:Hide()
    else
        specInfoFrame.content.knowledgePointSimulationButton:Show()
        specInfoFrame.content.notImplementedText:Hide()
    end

    if CraftSim.SIMULATION_MODE.isActive then
        specializationData = CraftSim.SIMULATION_MODE.specializationData
    end

    local affectedNodeDataList = CraftSim.GUTIL:Filter(specializationData.nodeData, function(nodeData) 
        return nodeData.affectsRecipe 
    end)

    if #affectedNodeDataList > #specInfoFrame.content.nodeLines then
        error("You need more nodeLines: " .. #affectedNodeDataList .. " / " .. #specInfoFrame.content.nodeLines)
    end
    for nodeLineIndex, nodeLine in pairs(specInfoFrame.content.nodeLines) do
        local affectedNodeData = affectedNodeDataList[nodeLineIndex]
        if affectedNodeData and affectedNodeData.active then
            nodeLine.nodeName:SetText(affectedNodeData.nodeName .. " (" .. tostring(affectedNodeData.rank) .. "/" .. tostring(affectedNodeData.maxRank) .. ")")

            local nodeProfessionStats = affectedNodeData.professionStats

            local tooltipText = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP) .. "\n\n";

            tooltipText = tooltipText .. nodeProfessionStats:GetTooltipText()

            nodeLine.statTooltip.SetTooltipText(tooltipText)
            nodeLine.statTooltip:Show()
            nodeLine:Show()
        elseif affectedNodeData and not affectedNodeData.active then
            local greyText = CraftSim.GUTIL:ColorizeText(affectedNodeData.nodeName .. " (-/" .. tostring(affectedNodeData.maxRank) .. ")", CraftSim.GUTIL.COLORS.GREY)
            nodeLine.nodeName:SetText(greyText)
            nodeLine.statTooltip:Hide()
            nodeLine:Show()
        else
            nodeLine:Hide()
        end
    end
end