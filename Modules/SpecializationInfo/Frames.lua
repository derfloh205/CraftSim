AddonName, CraftSim = ...

CraftSim.SPECIALIZATION_INFO.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

function CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimSpecInfoFrame", 
    "CraftSim Specialization Info", 
    ProfessionsFrame.CraftingPage.SchematicForm, 
    CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR), 
    "TOPLEFT", "TOPRIGHT", -10, 0, 310, 300, CraftSim.CONST.FRAMES.SPEC_INFO, true, true, nil, "modulesSpecInfo")

    frame:Hide()

    frame.content.notImplementedText = CraftSim.FRAME:CreateText(CraftSim.UTIL:ColorizeText("This profession's specialization data\nis not mapped yet!\nIf you want to help, feel free to ask\nin the discord!", CraftSim.CONST.COLORS.LEGENDARY),
    frame.content, frame.content, "TOP", "TOP", -25, -100)

    frame.content.notImplementedText:Hide()

    frame.content.knowledgePointSimulationButton =  CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
	frame.content.knowledgePointSimulationButton:SetPoint("TOP", frame.title, "TOP", 0, -20)	
	frame.content.knowledgePointSimulationButton:SetText("Simulate Knowledge Distribution")
	frame.content.knowledgePointSimulationButton:SetSize(frame.content.knowledgePointSimulationButton:GetTextWidth()+5, 20)
    frame.content.knowledgePointSimulationButton:SetScript("OnClick", function(self) 
        local specSimFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM)
        CraftSim.FRAME:ToggleFrame(CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_SIM), not specSimFrame:IsVisible())
    end)
    frame.content.knowledgePointSimulationButton:SetEnabled(false)

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
        table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title, baseY + nodeLineSpacingY*(numNodeLines-1)))
    end
    
    for i = 1, maxNodeLines, 1 do
        frame.content.AddNodeLine()
    end
end

function CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
    local specInfoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)

    local specializationData = recipeData.specializationData

    if not specializationData.isImplemented then
        table.foreach(specInfoFrame.content.nodeLines, function (_, nodeLine)
            nodeLine:Hide()
        end)
        specInfoFrame.content.notImplementedText:Show()
        specInfoFrame.content.knowledgePointSimulationButton:Hide()
        return
    end
    specInfoFrame.content.knowledgePointSimulationButton:Show()
    specInfoFrame.content.notImplementedText:Hide()

    if CraftSim.SIMULATION_MODE.isActive then
        specializationData = CraftSim.SIMULATION_MODE.specializationData
    end

    local affectedNodeDataList = CraftSim.UTIL:FilterTable(specializationData.nodeData, function(nodeData) 
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

            local tooltipText = "This node grants you following stats for this recipe:\n\n"

            tooltipText = tooltipText .. nodeProfessionStats:GetTooltipText()

            nodeLine.statTooltip.SetTooltipText(tooltipText)
            nodeLine.statTooltip:Show()
            nodeLine:Show()
        elseif affectedNodeData and not affectedNodeData.active then
            local greyText = CraftSim.UTIL:ColorizeText(affectedNodeData.nodeName .. " (-/" .. tostring(affectedNodeData.maxRank) .. ")", CraftSim.CONST.COLORS.GREY)
            nodeLine.nodeName:SetText(greyText)
            nodeLine.statTooltip:Hide()
            nodeLine:Show()
        else
            nodeLine:Hide()
        end
    end
end