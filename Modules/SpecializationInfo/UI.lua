---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

---@class CraftSim.SPECIALIZATION_INFO.UI
CraftSim.SPECIALIZATION_INFO.UI = {}

local print = CraftSim.DEBUG:SetDebugPrint("SPECDATA")

function CraftSim.SPECIALIZATION_INFO.UI:Init()
    local sizeX = 290
    local sizeY = 370
    local offsetX = 260
    local offsetY = 341

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

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
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_SPEC_INFO"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
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
        onCloseCallback = CraftSim.CONTROL_PANEL:HandleModuleClose("MODULE_SPEC_INFO"),
        frameTable = CraftSim.INIT.FRAMES,
        frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        raiseOnInteraction = true,
        frameLevel = frameLevel
    })

    local function createContent(frame)
        ---@class CraftSim.SPEC_INFO.FRAME : GGUI.Frame
        frame = frame
        ---@class CraftSim.SPEC_INFO.FRAME.CONTENT : Frame
        frame.content = frame.content

        frame:Hide()

        frame.content.notImplementedText = CraftSim.FRAME:CreateText(
            GUTIL:ColorizeText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS),
                GUTIL.COLORS.LEGENDARY),
            frame.content, frame.content, "CENTER", "CENTER", 0, 0)

        frame.content.notImplementedText:Hide()

        frame.content.statsText = GGUI.Text({
            parent = frame.content,
            anchorParent = frame.content,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            text = "",
            justifyOptions = { type = 'H', align = "LEFT" },
            offsetX = 20,
            offsetY = -35,
        })

        frame.content.nodeList = GGUI.FrameList {
            parent = frame.content, anchorParent = frame.content.statsText.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
            hideScrollbar = true, sizeY = 250, selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE },
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
function CraftSim.SPECIALIZATION_INFO.UI:UpdateInfo(recipeData)
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    ---@type CraftSim.SPEC_INFO.FRAME
    local specInfoFrame
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        specInfoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO_WO) --[[@as CraftSim.SPEC_INFO.FRAME]]
    else
        specInfoFrame = GGUI:GetFrame(CraftSim.INIT.FRAMES, CraftSim.CONST.FRAMES.SPEC_INFO) --[[@as CraftSim.SPEC_INFO.FRAME]]
    end

    local specializationData = recipeData.specializationData
    local content = specInfoFrame.content --[[@as CraftSim.SPEC_INFO.FRAME.CONTENT]]

    content.nodeList:Remove()

    if not specializationData or not specializationData.isImplemented then
        content.nodeList:Hide()
        content.notImplementedText:Show()
        content.statsText:Hide()
    else
        content.nodeList:Show()
        content.statsText:Show()
        content.notImplementedText:Hide()
    end

    if CraftSim.SIMULATION_MODE.isActive then
        specializationData = CraftSim.SIMULATION_MODE.specializationData
    end

    if not specializationData then
        return
    end

    local nodeDataList = specializationData.nodeData

    for _, nodeData in pairs(nodeDataList) do
        content.nodeList:Add(function(row)
            local columns = row.columns
            ---@class CraftSim.SPEC_INFO.NODE_LIST.NAME_COLUMN : Frame
            local nameColumn = columns[1]

            ---@class CraftSim.SPEC_INFO.NODE_LIST.RANK_COLUMN : Frame
            local rankColumn = columns[2]

            nameColumn.iconTexture:SetTexture(nodeData.icon)

            if nodeData.active then
                nameColumn.text:SetText(nodeData.name)
                rankColumn.text:SetText("(" ..
                    tostring(nodeData.rank) .. "/" .. tostring(nodeData.maxRank) .. ")")
            else
                nameColumn.text:SetText(GUTIL:ColorizeText(nodeData.name, GUTIL.COLORS.GREY))
                rankColumn.text:SetText(GUTIL:ColorizeText("(-/" .. tostring(nodeData.maxRank) .. ")",
                    GUTIL.COLORS.GREY))
            end

            row.tooltipOptions = {
                text = nodeData:GetTooltipText(),
                textWrap = true,
                owner = row.frame,
                anchor = "ANCHOR_RIGHT",
            }

            -- used to sort
            row.active = nodeData.active
            row.rank = nodeData.rank
            row.isMax = nodeData.maxRank == nodeData.rank
        end)
    end

    content.nodeList:UpdateDisplay(function(rowA, rowB)
        if rowA.active and not rowB.active then
            return true
        elseif not rowA.active and rowB.active then
            return false
        end

        if rowA.isMax and not rowB.isMax then
            return true
        elseif not rowA.isMax and rowB.isMax then
            return false
        end

        return rowA.rank > rowB.rank
    end)

    specInfoFrame.content.statsText:SetText(specializationData.professionStats:GetTooltipText(specializationData
        .maxProfessionStats))
end
