addonName, CraftSim = ...

CraftSim.SPECIALIZATION_INFO.FRAMES = {}

local function print(text, recursive, l) -- override
    if CraftSim_DEBUG and CraftSim.FRAME.GetFrame and CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.DEBUG) then
        CraftSim_DEBUG:print(text, CraftSim.CONST.DEBUG_IDS.FRAMES, recursive, l)
    else
        print(text)
    end
end

function CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
    local frame = CraftSim.FRAME:CreateCraftSimFrame("CraftSimSpecInfoFrame", 
    "CraftSim Specialization Info", 
    ProfessionsFrame.CraftingPage.SchematicForm, 
    CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.TOP_GEAR), 
    "TOPLEFT", "TOPRIGHT", -10, 0, 250, 300, CraftSim.CONST.FRAMES.SPEC_INFO)

    frame:Hide()

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
    local baseY = -20
    local nodeLineSpacingY = -20
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title, baseY))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*2))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*3))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*4))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*5))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*6))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*7))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*8))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*9))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*10))
    table.insert(frame.content.nodeLines, createNodeLine(frame.content, frame.title,baseY + nodeLineSpacingY*11))
end

function CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
    local professionID = recipeData.professionID

    local professionNodes = CraftSim.SPEC_DATA:GetNodes(professionID)

    
    local specInfoFrame = CraftSim.FRAME:GetFrame(CraftSim.CONST.FRAMES.SPEC_INFO)
    if recipeData.specNodeData and recipeData.specNodeData.affectedNodes and #recipeData.specNodeData.affectedNodes > 0 then
        --print("Affecting Nodes: " .. tostring(#recipeData.specNodeData.affectedNodes))
        for nodeLineIndex, nodeLine in pairs(specInfoFrame.content.nodeLines) do
            local affectedNode = recipeData.specNodeData.affectedNodes[nodeLineIndex]

            if affectedNode then
                local nodeNameData = CraftSim.UTIL:FilterTable(professionNodes, function(node) 
                    return affectedNode.nodeID == node.nodeID
                end)[1]

                local nodeName = nodeNameData.name

                nodeLine.nodeName:SetText(nodeName .. " (" .. tostring(affectedNode.nodeActualValue) .. "/" .. tostring(affectedNode.maxRanks-1) .. ")")

                local nodeStats = affectedNode.nodeStats

                local tooltipText = "This node grants you following stats for this recipe:\n\n"

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

                nodeLine.statTooltip.SetTooltipText(tooltipText)
                nodeLine:Show()
            else
                nodeLine:Hide()
            end
        end
    elseif recipeData.specNodeData and recipeData.specNodeData.affectedNodes and #recipeData.specNodeData.affectedNodes == 0 then
        --specInfoFrame.content.nodeList:SetText("Recipe not affected by specializations")
    else
        --specInfoFrame.content.nodeList:SetText("Profession not implemented yet")
    end
end