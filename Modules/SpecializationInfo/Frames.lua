AddonName, CraftSim = ...

CraftSim.SPECIALIZATION_INFO.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA_OOP)

function CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimSpecInfoFrame", 
    "CraftSim Specialization Info", 
    ProfessionsFrame.CraftingPage.SchematicForm, 
    CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR), 
    "TOPLEFT", "TOPRIGHT", -10, 0, 310, 300, CraftSim.CONST.FRAMES.SPEC_INFO, true, true, nil, "modulesSpecInfo")

    frame:Hide()

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
    local professionID = recipeData.professionID

    local professionNodes = CraftSim.SPEC_DATA:GetNodes(professionID)

    local specInfoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)

    local ruleNodes = CraftSim.SPEC_DATA.RULE_NODES()[recipeData.professionID]

    local function nodeStatsToTooltip(nodeStats)
        local tooltipText = ""
        for statName, statValue in pairs(nodeStats) do
            local translatedStatName = CraftSim.LOCAL:TranslateStatName(statName)
            local includeStat = statValue > 0
            local isPercent = false
            if string.match(statName, "Factor")  then
                isPercent = true
                if statValue == 1 then
                    includeStat = false
                end
            end 
            if includeStat then
                if isPercent then
                    local displayValue = CraftSim.UTIL:FormatFactorToPercent(statValue)
                    tooltipText = tooltipText .. tostring(translatedStatName) .. ": " .. tostring(displayValue) .. "\n"
                else
                    tooltipText = tooltipText .. tostring(translatedStatName) .. ": +" .. tostring(statValue) .. "\n"
                end
            end
        end

        return tooltipText
    end

    local affectedNodes = {}
    for name, nodeData in pairs(ruleNodes) do
        local nodeInfo = recipeData.specNodeData[nodeData.nodeID]

        -- minus one cause its always 1 more than the ui rank to know wether it was learned or not (learned with 0 has 1 rank)
            -- only increase if the current recipe has a matching category AND Subtype (like weapons -> one handed axes)
        local nodeRank = nodeInfo.activeRank
        local nodeActualValue = nodeInfo.activeRank - 1

        -- fetch all subtypeIDs, categoryIDs and exceptionRecipeIDs recursively
        local IDs = CraftSim.SPEC_DATA:GetIDsFromChildNodesCached(nodeData, ruleNodes)
        
        local affectedNoRank = CraftSim.SPEC_DATA:affectsRecipeByIDs(recipeData, IDs)
        local nodeAffectsRecipe = nodeRank > 0 and affectedNoRank

        local alreadyInserted = CraftSim.UTIL:Find(affectedNodes, function(aN) return aN.nodeID == nodeData.nodeID end)
        
        if not alreadyInserted then
            if affectedNoRank and not nodeAffectsRecipe then

                local nodeNameData = CraftSim.UTIL:FilterTable(professionNodes, function(node) 
                    return nodeData.nodeID == node.nodeID
                end)[1]
    
                if nodeNameData.name == "Short Blades" then
                    print("SpecInfo: NodeActive: " .. nodeNameData.name)
                    print("nodeData.nodeID: " .. nodeData.nodeID)
                    print("nodeData: ")
                    print(nodeData, true)
                    print("IDs:")
                    print(IDs, true)
                end

                local nodeStats = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes, nodeData.nodeID)
    
                local nodeName = nodeNameData.name
                table.insert(affectedNodes, {
                    nodeID = nodeData.nodeID,
                    name = nodeName,
                    isActive = false,
                    value = nodeActualValue,
                    maxValue = nodeInfo.maxRanks - 1,
                    nodeStats = nodeStats
                })
            elseif nodeAffectsRecipe then
                local nodeNameData = CraftSim.UTIL:FilterTable(professionNodes, function(node) 
                    return nodeData.nodeID == node.nodeID
                end)[1]
    
                local nodeStats = CraftSim.SPEC_DATA:GetStatsFromSpecNodeData(recipeData, ruleNodes, nodeData.nodeID)
    
                local nodeName = nodeNameData.name
                table.insert(affectedNodes, {
                    nodeID = nodeData.nodeID,
                    name = nodeName,
                    isActive = true,
                    value = nodeActualValue,
                    maxValue = nodeInfo.maxRanks - 1,
                    nodeStats = nodeStats
                })
            end
            -- else it does not affect the recipe in any case
        end
    end

    print("Affecting Nodes: " .. tostring(#affectedNodes))
    if #affectedNodes > #specInfoFrame.content.nodeLines then
        error("You need more nodeLines: " .. #affectedNodes .. " / " .. #specInfoFrame.content.nodeLines)
    end
    for nodeLineIndex, nodeLine in pairs(specInfoFrame.content.nodeLines) do
        local affectedNode = affectedNodes[nodeLineIndex]
        if affectedNode and affectedNode.isActive then
            nodeLine.nodeName:SetText(affectedNode.name .. " (" .. tostring(affectedNode.value) .. "/" .. tostring(affectedNode.maxValue) .. ")")

            local nodeStats = affectedNode.nodeStats

            local tooltipText = "This node grants you following stats for this recipe:\n\n"

            tooltipText = tooltipText .. nodeStatsToTooltip(nodeStats)

            nodeLine.statTooltip.SetTooltipText(tooltipText)
            nodeLine.statTooltip:Show()
            nodeLine:Show()
        elseif affectedNode and not affectedNode.isActive then
            local greyText = CraftSim.UTIL:ColorizeText(affectedNode.name .. " (-/" .. tostring(affectedNode.maxValue) .. ")", CraftSim.CONST.COLORS.GREY)
            nodeLine.nodeName:SetText(greyText)
            nodeLine.statTooltip:Hide()
            nodeLine:Show()
        else
            nodeLine:Hide()
        end
    end
end

-- OOP Refactor

function CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfoOOP(recipeData)
    local specInfoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)

    local affectedNodeDataList = CraftSim.UTIL:FilterTable(recipeData.specializationData.nodeData, function(nodeData) 
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