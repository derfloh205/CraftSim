---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.SPECIALIZATION_INFO.FRAMES
CraftSim.SPECIALIZATION_INFO.FRAMES = {}

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.SPECDATA)

function CraftSim.SPECIALIZATION_INFO.FRAMES:Init()
    local sizeX = 290
    local sizeY = 340
    local offsetX = 260
    local offsetY = 341

    ---@class CraftSim.SPEC_INFO.FRAME : GGUI.Frame
    local frameNO_WO = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.SPEC_INFO,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesSpecInfo"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    ---@class CraftSim.SPEC_INFO.FRAME : GGUI.Frame
    local frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = CraftSim.CONST.FRAMES.SPEC_INFO_WO,
        title = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_TITLE),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.FRAME:HandleModuleClose("modulesSpecInfo"),
        frameTable = CraftSim.MAIN.FRAMES,
        frameConfigTable = CraftSimGGUIConfig,
    })

    local function createContent(frame)
        ---@class CraftSim.SPEC_INFO.FRAME : GGUI.Frame
        frame = frame
        ---@class CraftSim.SPEC_INFO.FRAME.CONTENT : Frame
        frame.content = frame.content

        frame:Hide()

        frame.content.knowledgePointSimulationButton = GGUI.Button({
            parent = frame.content,
            anchorParent = frame.title.frame,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = -20,
            sizeX = 15,
            sizeY = 20,
            adjustWidth = true,
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION),
            clickCallback = function()
                local specSimFrame = GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM)
                CraftSim.FRAME:ToggleFrame(GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_SIM),
                    not specSimFrame:IsVisible())
            end
        })

        frame.content.knowledgePointSimulationButton:SetEnabled(false)

        frame.content.notImplementedText = CraftSim.FRAME:CreateText(
            GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS),
                GUTIL.COLORS.LEGENDARY),
            frame.content, frame.content.knowledgePointSimulationButton.frame, "CENTER", "CENTER", 0, 0)

        frame.content.notImplementedText:Hide()

        frame.content.statsText = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content.knowledgePointSimulationButton.frame,
            anchorA = "TOPLEFT",
            anchorB = "BOTTOMLEFT",
            text = "",
            justifyOptions = { type = 'H', align = "LEFT" },
            offsetX = 5,
            offsetY = -10
        })

        frame.content.nodeList = GGUI.FrameList {
            parent = frame.content, anchorParent = frame.content.statsText.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
            hideScrollbar = true, sizeY = 250, selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.JUST_HOVER_FRAMELIST_HOVERRGBA },
            rowHeight = 20, offsetX = -5, offsetY = 0, scale = 1,
            columnOptions = {
                {
                    label = "", -- node name
                    width = 180,
                },
                {
                    label = "", -- node ranks
                    width = 60,
                }
            },
            rowConstructor = function(columns)
                ---@class CraftSim.SPEC_INFO.NODE_LIST.NAME_COLUMN : Frame
                local nameColumn = columns[1]

                ---@class CraftSim.SPEC_INFO.NODE_LIST.RANK_COLUMN : Frame
                local rankColumn = columns[2]

                local specIconSize = 20
                nameColumn.iconTexture = GGUI.Texture {
                    parent = nameColumn, anchorParent = nameColumn, anchorA = "LEFT", anchorB = "LEFT",
                    sizeX = specIconSize, sizeY = specIconSize,
                }
                nameColumn.text = GGUI.Text {
                    parent = nameColumn, anchorParent = nameColumn.iconTexture.frame, justifyOptions = { type = "H", align = "LEFT" },
                    anchorA = "LEFT", anchorB = "RIGHT", offsetX = 2,
                }

                rankColumn.text = GGUI.Text {
                    parent = rankColumn, anchorParent = rankColumn,
                }
            end
        }
    end

    createContent(frameWO)
    createContent(frameNO_WO)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SPECIALIZATION_INFO.FRAMES:UpdateInfo(recipeData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    ---@type CraftSim.SPEC_INFO.FRAME
    local specInfoFrame
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        specInfoFrame = GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO) --[[@as CraftSim.SPEC_INFO.FRAME]]
    else
        specInfoFrame = GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO) --[[@as CraftSim.SPEC_INFO.FRAME]]
    end

    local specializationData = recipeData.specializationData
    local content = specInfoFrame.content --[[@as CraftSim.SPEC_INFO.FRAME.CONTENT]]

    content.nodeList:Remove()

    if not specializationData or not specializationData.isImplemented then
        content.nodeList:Hide()
        content.notImplementedText:Show()
        content.knowledgePointSimulationButton:Hide()
        content.statsText:Hide()
    else
        content.nodeList:Show()
        content.knowledgePointSimulationButton:Show()
        content.statsText:Show()
        content.notImplementedText:Hide()
    end

    if CraftSim.SIMULATION_MODE.isActive then
        specializationData = CraftSim.SIMULATION_MODE.specializationData
    end

    if not specializationData then
        return
    end

    local affectedNodeDataList = GUTIL:Filter(specializationData.nodeData, function(nodeData)
        return nodeData.affectsRecipe
    end)

    for _, affectedNodeData in pairs(affectedNodeDataList) do
        content.nodeList:Add(function(row)
            local columns = row.columns
            ---@class CraftSim.SPEC_INFO.NODE_LIST.NAME_COLUMN : Frame
            local nameColumn = columns[1]

            ---@class CraftSim.SPEC_INFO.NODE_LIST.RANK_COLUMN : Frame
            local rankColumn = columns[2]

            nameColumn.iconTexture:SetTexture(affectedNodeData.icon)

            if affectedNodeData.active then
                nameColumn.text:SetText(affectedNodeData.nodeName)
                rankColumn.text:SetText("(" ..
                    tostring(affectedNodeData.rank) .. "/" .. tostring(affectedNodeData.maxRank) .. ")")
            else
                nameColumn.text:SetText(GUTIL:ColorizeText(affectedNodeData.nodeName, GUTIL.COLORS.GREY))
                rankColumn.text:SetText(GUTIL:ColorizeText("(-/" .. tostring(affectedNodeData.maxRank) .. ")",
                    GUTIL.COLORS.GREY))
            end
            local nodeProfessionStats = affectedNodeData.professionStats

            row.tooltipOptions = {
                text = affectedNodeData:GetTooltipText(),
                textWrap = true,
                owner = row.frame,
                anchor = "ANCHOR_RIGHT",
            }

            -- used to sort
            row.active = affectedNodeData.active
        end)
    end

    content.nodeList:UpdateDisplay(function(rowA, rowB)
        if rowA.active and not rowB.active then
            return true
        end
        if not rowA.active and rowB.active then
            return false
        end
        return false
    end)

    specInfoFrame.content.statsText:SetText(specializationData.professionStats:GetTooltipText(specializationData
        .maxProfessionStats))
end
