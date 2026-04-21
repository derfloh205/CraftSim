---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.SPECIALIZATION_INFO.UI
---@field simulationModeEnabled boolean set only from :UpdateSimulationMode; drives sim controls in :UpdateInfo
CraftSim.SPECIALIZATION_INFO.UI = {
    simulationModeEnabled = false,
    recipeData = nil,
}

local Logger = CraftSim.DEBUG:RegisterLogger("SpecializationInfo.UI")

function CraftSim.SPECIALIZATION_INFO.UI:Init()
    local sizeX = 290
    local sizeY = 370
    local offsetX = 260
    local offsetY = 341

    local frameLevel = CraftSim.UTIL:NextFrameLevel()

    local frameIDs = CraftSim.CONST and CraftSim.CONST.FRAMES
    local function onCloseModule()
        CraftSim.DB.OPTIONS:Save("MODULE_SPEC_INFO", false)
        CraftSim.MODULES:UpdateVisibilityByContext()
        GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_CLOSED", "MODULE_SPEC_INFO")
    end

    local function onCollapseModule()
        GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_MINIMIZED", "MODULE_SPEC_INFO")
    end

    local function onCollapseOpenCallback()
        GUTIL:TriggerCustomEvent("CRAFTSIM_MODULE_MAXIMIZED", "MODULE_SPEC_INFO")
    end

    ---@class CraftSim.SPEC_INFO.FRAME : GGUI.Frame
    local specFrame = GGUI.Frame({
        parent = ProfessionsFrame,
        anchorParent = ProfessionsFrame,
        sizeX = sizeX,
        sizeY = sizeY,
        frameID = frameIDs and frameIDs.SPEC_INFO,
        title = CraftSim.LOCAL:GetText("SPEC_INFO_TITLE"),
        collapseable = true,
        closeable = true,
        moveable = true,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMRIGHT",
        offsetX = offsetX,
        offsetY = offsetY,
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        onCloseCallback = onCloseModule,
        onCollapseCallback = onCollapseModule,
        onCollapseOpenCallback = onCollapseOpenCallback,
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
            GUTIL:ColorizeText(CraftSim.LOCAL:GetText("SPEC_INFO_WORK_IN_PROGRESS"),
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
            wrap = true,
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
                    fixedWidth = 170,
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
            parent = frame.content, anchorPoints = { { anchorParent = frame.content.nodeList.frame, anchorA = "TOPLEFT", anchorB = "TOPRIGHT", offsetY = -3, offsetX = -3 } },
            labelTextureOptions = {
                atlas = "talents-button-undo"
            },
            sizeX = 23, sizeY = 23,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:ResetSpecData()
            end
        }

        frame.content.simMaxButton = GGUI.Button {
            parent = frame.content, anchorPoints = { { anchorParent = frame.content.simResetButton.frame, anchorA = "TOP", anchorB = "BOTTOM", offsetY = -1 } },
            labelTextureOptions = {
                atlas = "LevelUp-Icon-Arrow"
            },
            sizeX = 23, sizeY = 23,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:MaxSpecData()
            end
        }
    end

    self.module.frame = specFrame

    createContent(specFrame)

    self:HookSpecNodeTooltips()
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SPECIALIZATION_INFO.UI:UpdateInfo(recipeData)
    ---@type CraftSim.SPEC_INFO.FRAME
    local specInfoFrame = self.module.frame --[[@as CraftSim.SPEC_INFO.FRAME]]

    if not specInfoFrame then
        return
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

    content.simResetButton:SetVisible(self.simulationModeEnabled)
    content.simMaxButton:SetVisible(self.simulationModeEnabled)

    if self.simulationModeEnabled and CraftSim.SIMULATION_MODE.specializationData then
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
                rankColumn.text:SetVisible(not self.simulationModeEnabled)
                rankColumn.simText:SetVisible(self.simulationModeEnabled)
                rankColumn.simInput:SetVisible(self.simulationModeEnabled)
                if self.simulationModeEnabled then
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

    -- sort only if sim mode UI not active
    if not self.simulationModeEnabled then
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
end

--- Whether the spec info module frame should show (only self.recipeData; never CraftSim.MODULES.recipeData).
function CraftSim.SPECIALIZATION_INFO.UI:VisibleByContext()
    local recipeData = self.recipeData

    if not recipeData then
        return false
    end

    -- Only show while a recipe schematic is actually visible (hide on Specializations/other tabs
    -- without destroying the last stored recipe snapshot).
    if not CraftSim.UTIL:GetSchematicFormByContext() then
        return false
    end

    if recipeData.isCooking or recipeData.isOldWorldRecipe then
        return false
    end

    return CraftSim.DB.OPTIONS:Get("MODULE_SPEC_INFO")
end

--- Clears stored recipe and reapplies module visibility (frame hides when no recipe; see :VisibleByContext()).
function CraftSim.SPECIALIZATION_INFO.UI:ClearStoredRecipeAndRefreshVisibility()
    self.recipeData = nil
    CraftSim.MODULES:UpdateVisibilityByContext()
end

--- When recipeData is provided, stores it on self; then refreshes module visibility and repaints from self.recipeData.
---@param recipeData CraftSim.RecipeData? omit to keep the last stored recipe (re-run visibility + UpdateInfo)
function CraftSim.SPECIALIZATION_INFO.UI:UpdateRecipeData(recipeData)
    if recipeData then
        self.recipeData = recipeData
    end
    CraftSim.MODULES:UpdateVisibilityByContext()
    if not self.recipeData or not self:VisibleByContext() then
        return
    end
    self:UpdateInfo(self.recipeData)
end

---@param enabled boolean whether this module shows simulation controls and sim specialization data
---@param recipeData CraftSim.RecipeData? when provided, replaces stored recipe before refresh (e.g. sim session recipe)
function CraftSim.SPECIALIZATION_INFO.UI:UpdateSimulationMode(enabled, recipeData)
    self.simulationModeEnabled = not not enabled
    if recipeData then
        self.recipeData = recipeData
    end
    self:UpdateRecipeData()
end

function CraftSim.SPECIALIZATION_INFO.UI:Update()
    self:UpdateSimulationMode(CraftSim.SIMULATION_MODE.isActive)
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
    end)
end
