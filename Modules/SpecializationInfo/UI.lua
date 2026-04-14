---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.SPECIALIZATION_INFO.UI
CraftSim.SPECIALIZATION_INFO.UI = {}

local Logger = CraftSim.DEBUG:RegisterLogger("SpecializationInfo.UI")

function CraftSim.SPECIALIZATION_INFO.UI:Init()
    local sizeX = 390
    local sizeY = 420
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
        title = CraftSim.LOCAL:GetText("SPEC_INFO_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.MODULES:HandleModuleClose("MODULE_SPEC_INFO"),
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
        title = CraftSim.LOCAL:GetText("SPEC_INFO_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = CraftSim.MODULES:HandleModuleClose("MODULE_SPEC_INFO"),
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

        -- ── Onglets WoW natifs (PanelTopTabButtonTemplate) ──────────────
        local infoTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = frame.content,
                offsetY = -2,
                label = "Info",
            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = sizeX,
            sizeY = sizeY,
            canBeEnabled = true,
            offsetY = -30,
            initialTab = true,
            top = true,
        })
        -- Compat ascendante : UpdateInfo() lit frame.content.infoContent
        frame.content.infoContent = infoTab.content

        local optimizeTab = GGUI.BlizzardTab({
            buttonOptions = {
                parent = frame.content,
                anchorParent = infoTab.button,
                anchorA = "LEFT",
                anchorB = "RIGHT",
                label = "Optimize",
            },
            parent = frame.content,
            anchorParent = frame.content,
            sizeX = sizeX,
            sizeY = sizeY,
            canBeEnabled = true,
            offsetY = -30,
            top = true,
        })
        -- Compat ascendante : GetOptimizeContent() lit frame.content.optimizeContent
        frame.content.optimizeContent = optimizeTab.content

        -- ── Widgets de l'onglet Info ─────────────────────────────────────
        local ic = infoTab.content

        frame.content.notImplementedText = CraftSim.FRAME:CreateText(
            GUTIL:ColorizeText(CraftSim.LOCAL:GetText("SPEC_INFO_WORK_IN_PROGRESS"),
                GUTIL.COLORS.LEGENDARY),
            ic, ic, "CENTER", "CENTER", 0, 0)
        frame.content.notImplementedText:Hide()

        frame.content.statsText = GGUI.Text({
            parent = ic,
            anchorParent = ic,
            anchorA = "TOPLEFT",
            anchorB = "TOPLEFT",
            text = "",
            justifyOptions = { type = 'H', align = "LEFT" },
            offsetX = 20,
            offsetY = -35,
            wrap = true,
        })

        frame.content.nodeList = GGUI.FrameList {
            parent = ic, anchorParent = frame.content.statsText.frame, anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT",
            hideScrollbar = true, sizeY = 260, selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE },
            rowHeight = 20, offsetX = -5, offsetY = 0, scale = 1,
            columnOptions = {
                { label = "", width = 250 },
                { label = "", width = 100 },
            },
            rowConstructor = function(columns)
                local nameColumn = columns[1]
                local rankColumn = columns[2]

                local specIconSize = 20
                nameColumn.iconTexture = GGUI.Texture {
                    parent = nameColumn, anchorParent = nameColumn, anchorA = "LEFT", anchorB = "LEFT",
                    sizeX = specIconSize, sizeY = specIconSize,
                }
                nameColumn.text = GGUI.Text {
                    parent = nameColumn, anchorParent = nameColumn.iconTexture.frame, justifyOptions = { type = "H", align = "LEFT" },
                    anchorA = "LEFT", anchorB = "RIGHT", offsetX = 2, fixedWidth = 240,
                }

                rankColumn.text = GGUI.Text {
                    parent = rankColumn, anchorParent = rankColumn,
                }
                rankColumn.simInput = GGUI.NumericInput {
                    parent = rankColumn, anchorParent = rankColumn,
                    sizeX = 25, sizeY = 25, minValue = -1, anchorA = "LEFT", anchorB = "LEFT",
                    borderAdjustWidth = 1.5,
                    onEnterPressedCallback = function(input)
                        CraftSim.SIMULATION_MODE:OnSpecModified(true, input)
                    end
                }
                rankColumn.simText = GGUI.Text {
                    parent = rankColumn, anchorParent = rankColumn.simInput.textInput.frame,
                    anchorA = "LEFT", anchorB = "RIGHT", offsetX = 1, offsetY = 1
                }
            end
        }

        frame.content.simResetButton = GGUI.Button {
            parent = ic,
            anchorPoints = { { anchorParent = frame.content.nodeList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetY = -3, offsetX = -3 } },
            labelTextureOptions = { atlas = "talents-button-undo" },
            sizeX = 23, sizeY = 23,
            clickCallback = function() CraftSim.SIMULATION_MODE:ResetSpecData() end,
        }
        frame.content.simMaxButton = GGUI.Button {
            parent = ic,
            anchorPoints = { { anchorParent = frame.content.simResetButton.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -1 } },
            labelTextureOptions = { atlas = "LevelUp-Icon-Arrow" },
            sizeX = 23, sizeY = 23,
            clickCallback = function() CraftSim.SIMULATION_MODE:MaxSpecData() end,
        }

        -- ── Widgets de l'onglet Optimize ─────────────────────────────────
        ---@class CraftSim.SPEC_INFO.FRAME.OPTIMIZE_CONTENT : Frame
        local oc = optimizeTab.content

        oc.modeText = GGUI.Text {
            parent = oc, anchorParent = oc,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT",
            text = f.l("Select an action below"), justifyOptions = { type = "H", align = "LEFT" },
            offsetX = 15, offsetY = -32,
        }

        -- KP label + input : même ligne que les boutons, côté gauche
        oc.pointsLabel = GGUI.Text {
            parent = oc, anchorParent = oc,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT",
            text = f.white("KP:"), justifyOptions = { type = "H", align = "LEFT" },
            offsetX = 15, offsetY = -58,
        }
        -- GGUI.NumericInput utilise anchorParent/anchorA/anchorB (pas anchorPoints)
        oc.pointsInput = GGUI.NumericInput {
            parent = oc,
            anchorParent = oc.pointsLabel.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 4,
            sizeX = 38, sizeY = 22,
            minValue = 1, maxValue = 999,
            initialValue = 5,
            borderAdjustWidth = 1.5,
        }

        -- Boutons alignés à droite, même ligne que KP:
        oc.fullScanButton = GGUI.Button {
            parent = oc,
            anchorPoints = { { anchorParent = oc, anchorA = "TOPRIGHT", anchorB = "TOPRIGHT", offsetX = -10, offsetY = -54 } },
            label = "Full Scan", sizeX = 80, sizeY = 22,
            clickCallback = function()
                CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartFullScan(oc)
            end,
        }
        oc.fullScanButton.tooltipOptions = {
            anchor = "ANCHOR_CURSOR",
            text = f.white("Full Scan") .. "\n" ..
                "Calculates ROI per knowledge point for every node\n" ..
                "across all your cached recipes in this profession.\n\n" ..
                f.grey("Use once to build the value table.\n" ..
                "Processing is spread across multiple frames."),
        }

        oc.optimizeButton = GGUI.Button {
            parent = oc,
            anchorPoints = { { anchorParent = oc.fullScanButton.frame, anchorA = "TOPRIGHT", anchorB = "TOPLEFT", offsetX = -3 } },
            label = "Optimize", sizeX = 80, sizeY = 22,
            clickCallback = function()
                CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartOptimizePath(oc)
            end,
        }
        oc.optimizeButton.tooltipOptions = {
            anchor = "ANCHOR_CURSOR",
            text = f.white("Optimize") .. "\n" ..
                "Runs a full scan then greedily picks the highest-ROI\n" ..
                "node at each step to build an optimal spending path.\n\n" ..
                f.l("KP input") .. ": how many points to plan.\n" ..
                "Auto-detected from your unspent points (falls back to 5).\n\n" ..
                f.grey("The result is saved and can be reloaded instantly\n" ..
                "with " .. f.white("Load Plan") .. " without recalculating."),
        }

        oc.weeklyButton = GGUI.Button {
            parent = oc,
            anchorPoints = { { anchorParent = oc.optimizeButton.frame, anchorA = "TOPRIGHT", anchorB = "TOPLEFT", offsetX = -3 } },
            label = "Load Plan", sizeX = 70, sizeY = 22,
            clickCallback = function()
                CraftSim.KNOWLEDGE_POINT_VALUE.UI:StartWeeklyPlan(oc)
            end,
        }
        oc.weeklyButton.tooltipOptions = {
            anchor = "ANCHOR_CURSOR",
            text = f.white("Load Plan") .. "\n" ..
                "Displays the last saved plan instantly (no recalculation).\n\n" ..
                "If no plan has been saved yet, runs " .. f.white("Optimize") .. " automatically.\n\n" ..
                f.grey("Typical workflow:\n" ..
                "1. Click Optimize once per week.\n" ..
                "2. Use Load Plan to quickly review the saved path."),
        }

        oc.summaryText = GGUI.Text {
            parent = oc, anchorParent = oc,
            anchorA = "BOTTOMLEFT", anchorB = "BOTTOMLEFT",
            justifyOptions = { type = "H", align = "LEFT" },
            offsetX = 15, offsetY = 8, scale = 0.9,
        }

        oc.nodeList = GGUI.FrameList {
            parent = oc, anchorParent = oc,
            anchorA = "TOPLEFT", anchorB = "TOPLEFT",
            hideScrollbar = false, sizeY = 272,
            selectionOptions = { noSelectionColor = true, hoverRGBA = CraftSim.CONST.FRAME_LIST_SELECTION_COLORS.HOVER_LIGHT_WHITE },
            rowHeight = 26, offsetX = 10, offsetY = -103, scale = 1,
            columnOptions = {
                { label = "Node",    width = 165 },
                { label = "Rank",    width = 70,  justifyOptions = { type = "H", align = "CENTER" } },
                { label = "ROI/Pt",  width = 105, justifyOptions = { type = "H", align = "RIGHT" } },
            },
            showHeaderLine = true,
            rowConstructor = function(columns)
                local nameCol  = columns[1]
                local rankCol  = columns[2]
                local roiCol   = columns[3]

                nameCol.icon = GGUI.Texture {
                    parent = nameCol, anchorParent = nameCol, anchorA = "LEFT", anchorB = "LEFT",
                    sizeX = 20, sizeY = 20,
                }
                nameCol.text = GGUI.Text {
                    parent = nameCol, anchorParent = nameCol.icon.frame,
                    justifyOptions = { type = "H", align = "LEFT" },
                    anchorA = "LEFT", anchorB = "RIGHT", offsetX = 3, fixedWidth = 138,
                }
                rankCol.text = GGUI.Text { parent = rankCol, anchorParent = rankCol }
                roiCol.text = GGUI.Text {
                    parent = roiCol, anchorParent = roiCol,
                    anchorA = "RIGHT", anchorB = "RIGHT", offsetX = -5,
                    justifyOptions = { type = "H", align = "RIGHT" },
                }
                local rowFrame = nameCol:GetParent()
                local bg = rowFrame:CreateTexture(nil, "BACKGROUND")
                bg:SetTexture("Interface\\BUTTONS\\WHITE8X8")
                bg:SetAllPoints(rowFrame)
                bg:SetAlpha(0)
                rowFrame.roiBg = bg
            end,
        }

        GGUI.BlizzardTabSystem { infoTab, optimizeTab }
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

    content.simResetButton:SetVisible(CraftSim.SIMULATION_MODE.isActive)
    content.simMaxButton:SetVisible(CraftSim.SIMULATION_MODE.isActive)

    if CraftSim.SIMULATION_MODE.isActive then
        specializationData = CraftSim.SIMULATION_MODE.specializationData
    end

    if not specializationData then
        return
    end

    local nodeDataList = specializationData.nodeData

    for _, nodeData in pairs(nodeDataList) do
        if nodeData:HasRelevantStats(recipeData) then
            content.nodeList:Add(function(row)
                local columns = row.columns
                ---@class CraftSim.SPEC_INFO.NODE_LIST.NAME_COLUMN : Frame
                local nameColumn = columns[1]

                ---@class CraftSim.SPEC_INFO.NODE_LIST.RANK_COLUMN : Frame
                local rankColumn = columns[2]

                nameColumn.iconTexture:SetTexture(nodeData:GetIcon())
                rankColumn.text:SetVisible(not CraftSim.SIMULATION_MODE.isActive)
                rankColumn.simText:SetVisible(CraftSim.SIMULATION_MODE.isActive)
                rankColumn.simInput:SetVisible(CraftSim.SIMULATION_MODE.isActive)
                if CraftSim.SIMULATION_MODE.isActive then
                    rankColumn.simInput.nodeData = nodeData
                    rankColumn.simInput.textInput:SetText(nodeData.rank)
                    if nodeData.active then
                        nameColumn.text:SetText(nodeData.name)
                        rankColumn.simText:SetText(" / " .. tostring(nodeData.maxRank))
                    else
                        nameColumn.text:SetText(GUTIL:ColorizeText(nodeData.name, GUTIL.COLORS.GREY))
                        rankColumn.simText:SetText(GUTIL:ColorizeText(" / " .. tostring(nodeData.maxRank),
                            GUTIL.COLORS.GREY))
                    end
                else
                    if nodeData.active then
                        nameColumn.text:SetText(nodeData.name)
                        rankColumn.text:SetText("(" ..
                            tostring(nodeData.rank) .. "/" .. tostring(nodeData.maxRank) .. ")")
                    else
                        nameColumn.text:SetText(GUTIL:ColorizeText(nodeData.name, GUTIL.COLORS.GREY))
                        rankColumn.text:SetText(GUTIL:ColorizeText("(-/" .. tostring(nodeData.maxRank) .. ")",
                            GUTIL.COLORS.GREY))
                    end
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
    end

    -- sort only if sim mode not active
    if not CraftSim.SIMULATION_MODE.isActive then
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
    else
        content.nodeList:UpdateDisplay()
    end

    local filteredStats = specializationData.professionStats:Copy()
    local filteredMaxStats = specializationData.maxProfessionStats:Copy()
    if not recipeData.supportsMulticraft then
        filteredStats.multicraft:Clear()
        filteredMaxStats.multicraft:Clear()
    end
    if not recipeData.supportsResourcefulness then
        filteredStats.resourcefulness:Clear()
        filteredMaxStats.resourcefulness:Clear()
    end
    if not recipeData.supportsIngenuity then
        filteredStats.ingenuity:Clear()
        filteredMaxStats.ingenuity:Clear()
    end
    specInfoFrame.content.statsText:SetText(filteredStats:GetTooltipText(filteredMaxStats))

    -- Keep Optimize tab content up-to-date with single-recipe values
    CraftSim.KNOWLEDGE_POINT_VALUE.UI:UpdateDisplay(recipeData)
end

local specNodeTooltipHooked = false

function CraftSim.SPECIALIZATION_INFO.UI:HookSpecNodeTooltips()
    if specNodeTooltipHooked then return end
    specNodeTooltipHooked = true

    EventRegistry:RegisterCallback("ProfessionSpecs.SpecPathEntered", function(configID, pathID)
        local nodeID = pathID

        local playerUID = CraftSim.UTIL:GetPlayerCrafterUID()

        local label = CraftSim.LOCAL:GetText("SPECIALIZATION_INFO_TOOLTIP_LABEL")
        local crafterUIDRankMap = CraftSim.DB.CRAFTER:GetCrafterUIDsWithNodeActive(nodeID, playerUID)
        if next(crafterUIDRankMap) then
            ---@type CrafterUID[]
            local orderedUIDs = {}
            for crafterUID in pairs(crafterUIDRankMap) do
                tinsert(orderedUIDs, crafterUID)
            end
            table.sort(orderedUIDs)
            local nameCounts = CraftSim.UTIL:CountCrafterNamesByUIDList(orderedUIDs)

            GameTooltip:AddLine("\n" .. f.white(label) .. "\n")
            for _, crafterUID in ipairs(orderedUIDs) do
                local rank = crafterUIDRankMap[crafterUID]
                local display = CraftSim.UTIL:FormatCrafterUIDForPeerList(crafterUID, nameCounts)
                GameTooltip:AddLine(CraftSim.UTIL:ColorizeCrafterNameByUID(crafterUID, display) .. ": " .. rank)
            end

            GameTooltip:Show()
        end

        -- Knowledge Point Value tooltip injection
        local roiEntry = CraftSim.DB.KNOWLEDGE_POINT_VALUE:Get(playerUID, nodeID)
        if roiEntry and roiEntry.roiPerPoint ~= 0 then
            GameTooltip:AddLine(" ")
            local roiColor = roiEntry.roiPerPoint > 0 and "|cff00ff00" or "|cffff4444"
            GameTooltip:AddLine(roiColor .. "Knowledge Point Value: " .. CraftSim.UTIL:FormatMoney(roiEntry.roiPerPoint, true) .. " / pt|r")
            if roiEntry.totalRemainingROI and roiEntry.totalRemainingROI ~= 0 then
                GameTooltip:AddLine(roiColor .. "Total remaining: " .. CraftSim.UTIL:FormatMoney(roiEntry.totalRemainingROI, true) .. "|r")
            end
            if roiEntry.affectedRecipes and #roiEntry.affectedRecipes > 0 then
                local topCount = math.min(3, #roiEntry.affectedRecipes)
                for j = 1, topCount do
                    local impact = roiEntry.affectedRecipes[j]
                    if impact and impact.recipeName then
                        GameTooltip:AddLine("|cffaaaaaa  " .. impact.recipeName .. ": " ..
                            CraftSim.UTIL:FormatMoney(impact.profitDelta, true) .. "|r")
                    end
                end
            end
            GameTooltip:Show()
        end
    end)
end
