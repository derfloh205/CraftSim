---@class CraftSim
local CraftSim = select(2, ...)

local GGUI = CraftSim.GGUI
local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()
local L = CraftSim.UTIL:GetLocalizer()

---@class CraftSim.SIMULATION_MODE.UI
CraftSim.SIMULATION_MODE.UI = {}

---@class CraftSim.SIMULATION_MODE.UI.WORKORDER : GGUI.Frame
CraftSim.SIMULATION_MODE.UI.WORKORDER = nil

---@class CraftSim.SIMULATION_MODE.UI.NO_WORKORDER : GGUI.Frame
CraftSim.SIMULATION_MODE.UI.NO_WORKORDER = nil

local print = CraftSim.DEBUG:RegisterDebugID("Modules.SimulationMode.UI")

function CraftSim.SIMULATION_MODE.UI:Init()

    local x, y = ProfessionsFrame.CraftingPage.SchematicForm:GetSize()
    local woX, woY = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm:GetSize()
    local sizeOffsetX = 135
    local sizeOffsetY = 55
    local offsetY = -30

    CraftSim.SIMULATION_MODE.frame = GGUI.Frame({
        parent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorParent = ProfessionsFrame.CraftingPage.SchematicForm,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = x - sizeOffsetX, sizeY = y - sizeOffsetY,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.SIMULATION_MODE,
        title = L("SIMULATION_MODE_LABEL"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetFrameLevel() + 10,
        hide = true,
    })
    CraftSim.SIMULATION_MODE.frameWO = GGUI.Frame({
        parent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorParent = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMLEFT",
        sizeX = woX - sizeOffsetX, sizeY = woY - sizeOffsetY,
        offsetY = offsetY,
        frameID = CraftSim.CONST.FRAMES.SIMULATION_MODE_WO,
        title = L("SIMULATION_MODE_LABEL"),
        backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
        frameTable = CraftSim.INIT.FRAMES,
        frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
        frameLevel = ProfessionsFrame.CraftingPage.SchematicForm:GetFrameLevel() + 10,
        hide = true,
    })

    local function createContent(frame)
        local reagentListQualityIconOffsetY = -15
        local reagentListQualityIconOffsetX = -2
        local reagentListQualityIconHeaderSize = 25
        local reagentListQualityColumnWidth = 50
        frame.content.reagentList = GGUI.FrameList {
            parent = frame.content,
            anchorPoints = { { anchorParent = frame.content, offsetX = 10, offsetY = -20, anchorA = "TOPLEFT", anchorB = "TOPLEFT" } },
            sizeY = 150, hideScrollbar = true,
            rowHeight = 35,
            autoAdjustHeight = true,
            columnOptions = {
                {
                    width = 35, -- reagentIcon
                },
                {
                    label = GUTIL:GetQualityIconString(1, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, reagentListQualityIconOffsetX, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q1
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = GUTIL:GetQualityIconString(2, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, reagentListQualityIconOffsetX, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q2
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    label = GUTIL:GetQualityIconString(3, reagentListQualityIconHeaderSize, reagentListQualityIconHeaderSize, reagentListQualityIconOffsetX, reagentListQualityIconOffsetY),
                    width = reagentListQualityColumnWidth, -- q3
                    justifyOptions = { type = "H", align = "CENTER" },
                },
                {
                    width = 20, justifyOptions = { type = "H", align = "CENTER" } -- required quantity
                },
            },
            rowConstructor = function(columns, row)
                local iconColumn = columns[1]
                local q1Column = columns[2]
                local q2Column = columns[3]
                local q3Column = columns[4]
                local q4Column = columns[5]

                iconColumn.icon = GGUI.Icon {
                    parent = iconColumn, anchorParent = iconColumn,
                    anchorA = "LEFT", anchorB = "LEFT", sizeX = 30, sizeY = 30,
                    hideQualityIcon = true,
                }
                q1Column.itemID = nil
                q1Column.input = GGUI.NumericInput {
                    mouseWheelStep = 1,
                    parent = q1Column, anchorParent = q1Column,
                    sizeX = reagentListQualityColumnWidth * 0.8, anchorA = "CENTER", anchorB = "CENTER",
                    minValue = 0, allowDecimals = false, onNumberValidCallback = function()
                        CraftSim.SIMULATION_MODE:UpdateRequiredReagent(q1Column.itemID, q1Column.input.currentValue, row)
                    end
                }
                q2Column.itemID = nil
                q2Column.input = GGUI.NumericInput {
                    mouseWheelStep = 1,
                    parent = q2Column, anchorParent = q2Column,
                    sizeX = reagentListQualityColumnWidth * 0.8, anchorA = "CENTER", anchorB = "CENTER",
                    minValue = 0, allowDecimals = false, onNumberValidCallback = function()
                        CraftSim.SIMULATION_MODE:UpdateRequiredReagent(q2Column.itemID, q2Column.input.currentValue, row)
                    end
                }
                q3Column.itemID = nil
                q3Column.input = GGUI.NumericInput {
                    mouseWheelStep = 1,
                    parent = q3Column, anchorParent = q3Column,
                    sizeX = reagentListQualityColumnWidth * 0.8, anchorA = "CENTER", anchorB = "CENTER",
                    minValue = 0, allowDecimals = false, onNumberValidCallback = function()
                        CraftSim.SIMULATION_MODE:UpdateRequiredReagent(q3Column.itemID, q3Column.input.currentValue, row)
                    end
                }

                q4Column.text = GGUI.Text {
                    parent = q4Column, anchorParent = q4Column, anchorA = "CENTER", anchorB = "CENTER",
                    justifyOptions = { type = "H", align = "CENTER" }
                }

                for _, qColumn in ipairs({ q1Column, q2Column, q3Column }) do
                    qColumn:EnableMouse(true)
                    ---@type ItemMixin?
                    qColumn.item = nil
                    GGUI:SetTooltipsByTooltipOptions(qColumn, qColumn)

                    qColumn:SetScript("OnMouseDown", function()
                        if IsShiftKeyDown() and qColumn.item then
                            qColumn.item:ContinueOnItemLoad(function()
                                ChatEdit_InsertLink(qColumn.item:GetItemLink())
                            end)
                        end
                    end)
                end
            end
        }
    end

    createContent(CraftSim.SIMULATION_MODE.frame)
    createContent(CraftSim.SIMULATION_MODE.frameWO)

    local function createSimulationModeFrames(schematicForm, workOrder)
        local frames = {}
        -- CHECK BUTTON
        local clickCallback = function(self)
            print("sim mode click callback")
            CraftSim.SIMULATION_MODE.isActive = self:GetChecked()
            local bestQBox = schematicForm.AllocateBestQualityCheckbox
            if bestQBox:GetChecked() and CraftSim.SIMULATION_MODE.isActive then
                bestQBox:Click()
            end
            if CraftSim.SIMULATION_MODE.isActive then
                CraftSim.SIMULATION_MODE:InitializeSimulationMode(CraftSim.INIT.currentRecipeData)
            end

            CraftSim.INIT:TriggerModuleUpdate()
        end
        frames.toggleButton = CraftSim.FRAME:CreateCheckboxCustomCallback(
            " " .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL),
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP), false, clickCallback,
            schematicForm, schematicForm.Details, "BOTTOM", "TOP", -65, 40)

        frames.toggleButton:Hide()



        local baseSizeY = 50
        local spacingY = 50
        local sizeY_1 = baseSizeY
        local sizeY_2 = baseSizeY + spacingY
        local sizeY_3 = baseSizeY + spacingY * 2
        local sizeY_4 = baseSizeY + spacingY * 3
        local sizeY_5 = baseSizeY + spacingY * 4
        local sizeY_6 = baseSizeY + spacingY * 5

        -- REAGENT OVERWRITE FRAMES
        ---@class CraftSim.SimulationMode.ReagentOverwriteFrame : GGUI.Frame
        local reagentOverwriteFrame = GGUI.Frame {
            parent = schematicForm, anchorParent = schematicForm.Reagents, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = 0, offsetY = 0,
            sizeX = 250, sizeY = baseSizeY,
            initialStatusID = "0",
        }
        reagentOverwriteFrame:SetStatusList({
            {
                statusID = "0",
                sizeY = sizeY_1,
            },
            {
                statusID = "1",
                sizeY = sizeY_1,
            },
            {
                statusID = "2",
                sizeY = sizeY_2,
            },
            {
                statusID = "3",
                sizeY = sizeY_3,
            },
            {
                statusID = "4",
                sizeY = sizeY_4,
            },
            {
                statusID = "5",
                sizeY = sizeY_5,
            },
            {
                statusID = "6",
                sizeY = sizeY_6,
            },
        })
        reagentOverwriteFrame:Hide()

        local baseX = 15
        local inputOffsetX = 50

        ---@class CraftSim.SimulationMode.ReagentOverwriteFrame.Content
        reagentOverwriteFrame.content = reagentOverwriteFrame.content


        reagentOverwriteFrame.content.quality1Button = GGUI.Button({
            parent = reagentOverwriteFrame.content,
            anchorParent = reagentOverwriteFrame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            sizeX = 25,
            sizeY = 25,
            label = GUTIL:GetQualityIconString(1, 20, 20),
            offsetX = baseX - 63,
            offsetY = 15,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(1)
            end,
            tooltipOptions = {
                owner = reagentOverwriteFrame.content,
                anchor = "ANCHOR_CURSOR",
                textWrap = true,
                text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP) ..
                    GUTIL:GetQualityIconString(1, 20, 20),
            },
        })
        reagentOverwriteFrame.content.quality2Button = GGUI.Button({
            parent = reagentOverwriteFrame.content,
            anchorParent = reagentOverwriteFrame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            sizeX = 25,
            sizeY = 25,
            label = GUTIL:GetQualityIconString(2, 20, 20),
            offsetX = baseX + inputOffsetX - 63,
            offsetY = 15,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(2)
            end,
            tooltipOptions = {
                owner = reagentOverwriteFrame.content,
                anchor = "ANCHOR_CURSOR",
                textWrap = true,
                text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP) ..
                    GUTIL:GetQualityIconString(2, 20, 20),
            },
        })

        reagentOverwriteFrame.content.quality3Button = GGUI.Button({
            parent = reagentOverwriteFrame.content,
            anchorParent = reagentOverwriteFrame.content,
            anchorA = "TOP",
            anchorB = "TOP",
            sizeX = 25,
            sizeY = 25,
            label = GUTIL:GetQualityIconString(3, 20, 20),
            offsetX = baseX + inputOffsetX * 2 - 63,
            offsetY = 15,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(3)
            end,
            tooltipOptions = {
                owner = reagentOverwriteFrame.content,
                anchor = "ANCHOR_CURSOR",
                textWrap = true,
                text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP) ..
                    GUTIL:GetQualityIconString(3, 20, 20),
            },
        })
        reagentOverwriteFrame.content.clearAllocationsButton = GGUI.Button({
            parent = reagentOverwriteFrame.content,
            anchorParent = reagentOverwriteFrame.content.quality3Button.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = inputOffsetX - 30,
            label = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON),
            adjustWidth = true,
            sizeX = 10,
            sizeY = 25,
            clickCallback = function()
                CraftSim.SIMULATION_MODE:AllocateAllByQuality(0)
            end
        })

        reagentOverwriteFrame.reagentOverwriteInputs = {}

        local reagentOverwriteFrameOffsetX = 50
        local offsetY = -45

        table.insert(reagentOverwriteFrame.reagentOverwriteInputs,
            CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame.content,
                reagentOverwriteFrameOffsetX, 0, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs,
            CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame.content,
                reagentOverwriteFrameOffsetX, offsetY, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs,
            CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame.content,
                reagentOverwriteFrameOffsetX, offsetY * 2, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs,
            CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame.content,
                reagentOverwriteFrameOffsetX, offsetY * 3, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs,
            CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame.content,
                reagentOverwriteFrameOffsetX, offsetY * 4, baseX, inputOffsetX))
        table.insert(reagentOverwriteFrame.reagentOverwriteInputs,
            CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame.content,
                reagentOverwriteFrameOffsetX, offsetY * 5, baseX, inputOffsetX))

        frames.reagentOverwriteFrame = reagentOverwriteFrame

        local function CreateOptionalReagentItemSelector(offsetX)
            local optionalReagentDropdown = GGUI.ItemSelector({
                parent = workOrder and CraftSim.SIMULATION_MODE.frameWO.frame or CraftSim.SIMULATION_MODE.frame.frame,
                anchorParent = workOrder and CraftSim.SIMULATION_MODE.frameWO.frame or CraftSim.SIMULATION_MODE.frame.frame,
                anchorA = "BOTTOMLEFT",
                anchorB = "BOTTOMLEFT",
                offsetX = 10 + offsetX,
                offsetY = 30,
                sizeX = 30,
                sizeY = 30,
                emptyIcon = CraftSim.CONST.ATLAS_TEXTURES.TRADESKILL_ICON_ADD,
                selectionFrameOptions = {
                    backdropOptions = CraftSim.CONST.DEFAULT_BACKDROP_OPTIONS,
                    scale = 1.2,
                },
                onSelectCallback = function()
                    CraftSim.INIT:TriggerModuleUpdate()
                end
            })
            return optionalReagentDropdown
        end

        ---@type GGUI.ItemSelector[]
        reagentOverwriteFrame.optionalReagentItemSelectors = {}
        local dropdownSpacingX = 35
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors, CreateOptionalReagentItemSelector(0))
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX))
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 2))
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 3))
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 4))
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 5))
        table.insert(reagentOverwriteFrame.optionalReagentItemSelectors,
            CreateOptionalReagentItemSelector(dropdownSpacingX * 6))


        -- DETAILS FRAME
        local simModeDetailsFrame = GGUI.Frame({
            parent = workOrder and CraftSim.SIMULATION_MODE.frameWO.frame or CraftSim.SIMULATION_MODE.frame.frame,
            anchorParent = ProfessionsFrame,
            anchorA = "TOPRIGHT",
            anchorB = "TOPRIGHT",
            offsetX = -5,
            offsetY = -155,
            sizeX = 350,
            sizeY = 355,
            frameID = (workOrder and CraftSim.CONST.FRAMES.CRAFTING_DETAILS_WO) or CraftSim.CONST.FRAMES
                .CRAFTING_DETAILS,
            frameTable = CraftSim.INIT.FRAMES,
            frameConfigTable = CraftSim.DB.OPTIONS:Get("GGUI_CONFIG"),
            frameStrata = CraftSim.CONST.MODULES_FRAME_STRATA,
            frameLevel = 50,
            raiseOnInteraction = true,
        })

        simModeDetailsFrame:Hide()

        frames.detailsFrame = simModeDetailsFrame

        local offsetY = -20
        local modOffsetX = 5
        local valueOffsetX = -5
        local valueOffsetY = 0.5

        -- recipe difficulty
        simModeDetailsFrame.content.recipeDifficultyTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.recipeDifficultyTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content, "TOPLEFT", 20,
            offsetY - 20)
        simModeDetailsFrame.content.recipeDifficultyTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .RECIPE_DIFFICULTY_LABEL))
        simModeDetailsFrame.content.recipeDifficultyTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP),
            simModeDetailsFrame.content, simModeDetailsFrame.content.recipeDifficultyTitle, "RIGHT", "LEFT", -20, 0)


        simModeDetailsFrame.content.recipeDifficultyMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeRecipeDifficultyModInput", simModeDetailsFrame.content, simModeDetailsFrame.content,
            "TOPRIGHT", "TOPRIGHT", modOffsetX - 30, offsetY - 20 + 3.5, 30, 20, 0, true,
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)

        frames.recipeDifficultyMod = simModeDetailsFrame.content.recipeDifficultyMod

        simModeDetailsFrame.content.recipeDifficultyMod.stat = CraftSim.CONST.STAT_MAP
            .CRAFTING_DETAILS_RECIPE_DIFFICULTY

        simModeDetailsFrame.content.recipeDifficultyValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.recipeDifficultyValue:SetPoint("RIGHT",
            simModeDetailsFrame.content.recipeDifficultyMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.recipeDifficultyValue:SetText("0")

        -- Multicraft
        simModeDetailsFrame.content.multicraftTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.multicraftTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content
            .recipeDifficultyTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.multicraftTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_LABEL))
        simModeDetailsFrame.content.multicraftTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP),
            simModeDetailsFrame.content, simModeDetailsFrame.content.multicraftTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.multicraftMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeMulticraftModInput", simModeDetailsFrame.content,
            simModeDetailsFrame.content.recipeDifficultyMod,
            "TOPRIGHT", "TOPRIGHT", 0, offsetY, 30, 20, 0, true,
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.multicraftMod = simModeDetailsFrame.content.multicraftMod
        simModeDetailsFrame.content.multicraftMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_MULTICRAFT

        simModeDetailsFrame.content.multicraftValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.multicraftValue:SetPoint("RIGHT", simModeDetailsFrame.content.multicraftMod, "LEFT",
            valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.multicraftValue:SetText("0")

        -- Multicraft BonusItemsFactor
        simModeDetailsFrame.content.multicraftBonusTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.multicraftBonusTitle:SetPoint("TOPLEFT", simModeDetailsFrame.content.multicraftTitle,
            "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.multicraftBonusTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .MULTICRAFT_BONUS_LABEL))

        simModeDetailsFrame.content.multicraftBonusValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.multicraftBonusValue:SetPoint("TOP", simModeDetailsFrame.content.multicraftMod,
            "BOTTOM", 0, -3)
        simModeDetailsFrame.content.multicraftBonusValue:SetText("0%")

        -- Resourcefulness
        simModeDetailsFrame.content.resourcefulnessTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessTitle:SetPoint("TOPLEFT",
            simModeDetailsFrame.content.multicraftBonusTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.resourcefulnessTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .RESOURCEFULNESS_LABEL))
        simModeDetailsFrame.content.resourcefulnessTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP),
            simModeDetailsFrame.content, simModeDetailsFrame.content.resourcefulnessTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.resourcefulnessMod = CraftSim.FRAME:CreateNumericInput(
            "CraftSimSimModeResourcefulnessModInput", simModeDetailsFrame.content,
            simModeDetailsFrame.content.multicraftMod,
            "TOPRIGHT", "TOPRIGHT", 0, offsetY * 2, 30, 20, 0, true,
            function(_, userInput)
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(userInput)
            end)
        frames.resourcefulnessMod = simModeDetailsFrame.content.resourcefulnessMod
        simModeDetailsFrame.content.resourcefulnessMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_RESOURCEFULNESS

        simModeDetailsFrame.content.resourcefulnessValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessValue:SetPoint("RIGHT", simModeDetailsFrame.content
            .resourcefulnessMod, "LEFT", valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.resourcefulnessValue:SetText("0")

        -- Resourcefulness BonusItemsFactor
        simModeDetailsFrame.content.resourcefulnessBonusTitle = simModeDetailsFrame.content:CreateFontString(nil,
            'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessBonusTitle:SetPoint("TOPLEFT",
            simModeDetailsFrame.content.resourcefulnessTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.resourcefulnessBonusTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .RESOURCEFULNESS_BONUS_LABEL))

        simModeDetailsFrame.content.resourcefulnessBonusValue = simModeDetailsFrame.content:CreateFontString(nil,
            'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.resourcefulnessBonusValue:SetPoint("TOP",
            simModeDetailsFrame.content.resourcefulnessMod, "BOTTOM", 0, -3)
        simModeDetailsFrame.content.resourcefulnessBonusValue:SetText("0%")

        -- skill

        simModeDetailsFrame.content.baseSkillTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillTitle:SetPoint("TOPLEFT",
            simModeDetailsFrame.content.resourcefulnessBonusTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.baseSkillTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SKILL_LABEL))

        simModeDetailsFrame.content.baseSkillMod = GGUI.NumericInput {
            parent = simModeDetailsFrame.content, anchorParent = simModeDetailsFrame.content.resourcefulnessMod,
            anchorA = "TOPRIGHT", anchorB = "TOPRIGHT", allowDecimals = false, offsetX = 0, offsetY = offsetY * 2, sizeX = 30, sizeY = 20,
            initialValue = 0, incrementOneButtons = true, onNumberValidCallback = function(input)
            CraftSim.SIMULATION_MODE:OnStatModifierChanged(true)
        end,
            borderAdjustHeight = 1.2, borderAdjustWidth = 1.3,
        }
        frames.baseSkillMod = simModeDetailsFrame.content.baseSkillMod
        simModeDetailsFrame.content.baseSkillMod.stat = CraftSim.CONST.STAT_MAP.CRAFTING_DETAILS_SKILL

        simModeDetailsFrame.content.baseSkillValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.baseSkillValue:SetPoint("RIGHT",
            simModeDetailsFrame.content.baseSkillMod.textInput.frame,
            "LEFT",
            valueOffsetX, valueOffsetY)
        simModeDetailsFrame.content.baseSkillValue:SetText("0")

        -- reagent skill

        simModeDetailsFrame.content.reagentSkillIncreaseTitle = simModeDetailsFrame.content:CreateFontString(nil,
            'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetPoint("TOPLEFT",
            simModeDetailsFrame.content.baseSkillTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.reagentSkillIncreaseTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .REAGENT_QUALITY_BONUS_LABEL))
        simModeDetailsFrame.content.reagentSkillIncreaseTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP),
            simModeDetailsFrame.content, simModeDetailsFrame.content.reagentSkillIncreaseTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.reagentSkillIncreaseValue = simModeDetailsFrame.content:CreateFontString(nil,
            'OVERLAY', 'GameFontHighlight')
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetPoint("TOP",
            simModeDetailsFrame.content.baseSkillMod.textInput.frame,
            "TOP", valueOffsetX - 15, offsetY - 5)
        simModeDetailsFrame.content.reagentSkillIncreaseValue:SetText("0")

        -- reagent max factor
        simModeDetailsFrame.content.reagentMaxFactorTitle = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.reagentMaxFactorTitle:SetPoint("TOPLEFT",
            simModeDetailsFrame.content.reagentSkillIncreaseTitle, "TOPLEFT", 0, offsetY)
        simModeDetailsFrame.content.reagentMaxFactorTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT
            .REAGENT_QUALITY_MAXIMUM_LABEL))
        simModeDetailsFrame.content.reagentMaxFactorTitle.helper = CraftSim.FRAME:CreateHelpIcon(
            CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP),
            simModeDetailsFrame.content, simModeDetailsFrame.content.reagentMaxFactorTitle, "RIGHT", "LEFT", -20, 0)

        simModeDetailsFrame.content.reagentMaxFactorValue = simModeDetailsFrame.content:CreateFontString(nil, 'OVERLAY',
            'GameFontHighlight')
        simModeDetailsFrame.content.reagentMaxFactorValue:SetPoint("TOP",
            simModeDetailsFrame.content.baseSkillMod.textInput.frame, "TOP",
            valueOffsetX - 15, offsetY * 2 - 5)
        simModeDetailsFrame.content.reagentMaxFactorValue:SetText("0")

        simModeDetailsFrame.content.concentrationCB = GGUI.Checkbox {
            parent = simModeDetailsFrame.content,
            anchorParent = simModeDetailsFrame.content.reagentMaxFactorValue,
            anchorA = "TOP", anchorB = "BOTTOM", offsetY = -5,
            labelOptions = {
                text = GUTIL:IconToText(CraftSim.CONST.CONCENTRATION_ICON, 20, 20) .. CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION),
                anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -7,
                anchorParent = simModeDetailsFrame.content.reagentMaxFactorTitle
            },
            clickCallback = function()
                CraftSim.SIMULATION_MODE:OnStatModifierChanged(true)
            end
        }

        frames.concentrationToggleMod = simModeDetailsFrame.content.concentrationCB

        simModeDetailsFrame.content.concentrationCostTitle = GGUI.Text {
            parent = simModeDetailsFrame.content,
            anchorParent = simModeDetailsFrame.content.concentrationCB.labelText.frame,
            anchorA = "TOPLEFT", anchorB = "BOTTOMLEFT", offsetY = -7,
            justifyOptions = { type = "H", align = "LEFT" },
            text = CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST),
        }

        simModeDetailsFrame.content.concentrationCostValue = GGUI.Text {
            parent = simModeDetailsFrame.content,
            anchorParent = simModeDetailsFrame.content.concentrationCB.frame,
            anchorA = "TOPRIGHT", anchorB = "BOTTOMRIGHT", offsetY = -2, offsetX = -2,
            justifyOptions = { type = "H", align = "RIGHT" },
            text = "0",
        }

        simModeDetailsFrame.content.qualityFrame = CreateFrame("frame", nil, simModeDetailsFrame.content)
        simModeDetailsFrame.content.qualityFrame:SetSize(simModeDetailsFrame:GetWidth() - 40, 230)
        simModeDetailsFrame.content.qualityFrame:SetPoint("TOP", simModeDetailsFrame.content, "TOP", 0, offsetY * 13)
        local qualityFrame = simModeDetailsFrame.content.qualityFrame
        qualityFrame.currentQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityTitle:SetPoint("TOPLEFT", qualityFrame, "TOPLEFT", 0, 0)
        qualityFrame.currentQualityTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL))

        qualityFrame.currentQualityIcon = GGUI.QualityIcon({
            parent = qualityFrame,
            anchorParent = qualityFrame,
            sizeX = 25,
            sizeY = 25,
            anchorA = "TOPRIGHT",
            anchorB =
            "TOPRIGHT",
            offsetY = 5
        })

        qualityFrame.currentQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.currentQualityThreshold:SetPoint("RIGHT", qualityFrame.currentQualityIcon.frame, "LEFT", -5, 0)
        qualityFrame.currentQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityTitle:SetPoint("TOPLEFT", qualityFrame.currentQualityTitle, "TOPLEFT", 0, offsetY)
        qualityFrame.nextQualityTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL))

        qualityFrame.nextQualityIcon = GGUI.QualityIcon({
            parent = qualityFrame,
            anchorParent = qualityFrame.currentQualityIcon.frame,
            anchorA = "TOP",
            anchorB = "TOP",
            offsetY = offsetY,
            sizeX = 25,
            sizeY = 25,
        })

        qualityFrame.nextQualityThreshold = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityThreshold:SetPoint("RIGHT", qualityFrame.nextQualityIcon.frame, "LEFT", -5, 0)
        qualityFrame.nextQualityThreshold:SetText("> ???")

        qualityFrame.nextQualityMissingSkillTitle = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillTitle:SetPoint("TOPLEFT", qualityFrame.nextQualityTitle, "TOPLEFT", 0,
            offsetY)
        qualityFrame.nextQualityMissingSkillTitle:SetText(CraftSim.LOCAL:GetText(CraftSim.CONST.TEXT.MISSING_SKILL_LABEL))

        qualityFrame.nextQualityMissingSkillValue = qualityFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        qualityFrame.nextQualityMissingSkillValue:SetPoint("TOPRIGHT", qualityFrame.nextQualityThreshold, "TOPRIGHT", 0,
            offsetY)
        qualityFrame.nextQualityMissingSkillValue:SetText("???")

        return frames
    end

    CraftSim.SIMULATION_MODE.UI.NO_WORKORDER =
        createSimulationModeFrames(ProfessionsFrame.CraftingPage.SchematicForm)
    CraftSim.SIMULATION_MODE.UI.WORKORDER =
        createSimulationModeFrames(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm)
end

function CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteFrame(reagentOverwriteFrame, offsetX, offsetY, baseX,
                                                                 inputOffsetX)
    local overwriteInput = CreateFrame("frame", nil, reagentOverwriteFrame)
    overwriteInput:SetPoint("TOPLEFT", reagentOverwriteFrame, "TOPLEFT", offsetX, offsetY)
    overwriteInput:SetSize(50, 50)

    overwriteInput.icon = GGUI.Icon({
        parent = overwriteInput,
        anchorParent = overwriteInput,
        sizeX = 40,
        sizeY = 40,
        anchorA = "RIGHT",
        anchorB = "LEFT",
    })

    overwriteInput.inputq1 = CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteInput(overwriteInput, baseX, 1)
    overwriteInput.inputq2 = CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteInput(overwriteInput,
        baseX + inputOffsetX, 2)
    overwriteInput.inputq3 = CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteInput(overwriteInput,
        baseX + inputOffsetX * 2, 3)

    overwriteInput.requiredQuantity = overwriteInput:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    overwriteInput.requiredQuantity:SetPoint("LEFT", overwriteInput.inputq3, "RIGHT", 20, 2)
    overwriteInput.requiredQuantity:SetText("/ ?")

    return overwriteInput
end

function CraftSim.SIMULATION_MODE.UI:CreateReagentOverwriteInput(overwriteInputFrame, offsetX, qualityID)
    local inputWidth = 30
    local inputBox = CraftSim.FRAME:CreateNumericInput(
        nil, overwriteInputFrame, overwriteInputFrame.icon.frame, "LEFT", "RIGHT", offsetX, 0, inputWidth, 20, 0, false,
        function(input, userInput)
            CraftSim.SIMULATION_MODE:OnInputAllocationChanged(input, userInput)
        end)
    inputBox.qualityID = qualityID
    return inputBox
end

function CraftSim.SIMULATION_MODE.UI:UpdateCraftingDetailsPanel()
    local recipeData = CraftSim.SIMULATION_MODE.recipeData
    if not recipeData then
        return
    end

    local baseProfessionStats = recipeData.baseProfessionStats
    local professionStats = recipeData.professionStats
    local professionStatsMod = recipeData.professionStatModifiers

    local simModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local detailsFrame = simModeFrames.detailsFrame

    -- Multicraft Display
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftTitle, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftTitle.helper, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftValue, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftMod, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftBonusTitle, recipeData.supportsMulticraft)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.multicraftBonusValue, recipeData.supportsMulticraft)
    if recipeData.supportsMulticraft then
        local baseMulticraft = GUTIL:Round(professionStats.multicraft.value - professionStatsMod.multicraft.value, 1)
        local percentText = GUTIL:Round(professionStats.multicraft:GetPercent(), 1) .. "%"
        detailsFrame.content.multicraftValue:SetText(GUTIL:Round(professionStats.multicraft.value, 1) ..
            " (" .. baseMulticraft .. "+" .. professionStatsMod.multicraft.value .. ") " .. percentText)

        detailsFrame.content.multicraftBonusValue:SetText(professionStats.multicraft:GetExtraValue() * 100 .. "%")
    end

    -- Resourcefulness Display
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessTitle, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessTitle.helper, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessValue, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessMod, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessBonusTitle, recipeData.supportsResourcefulness)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.resourcefulnessBonusValue, recipeData.supportsResourcefulness)
    if recipeData.supportsResourcefulness then
        local baseResourcefulness = professionStats.resourcefulness.value - professionStatsMod.resourcefulness.value
        local percentText = GUTIL:Round(professionStats.resourcefulness:GetPercent(), 1) .. "%"
        detailsFrame.content.resourcefulnessValue:SetText(GUTIL:Round(professionStats.resourcefulness.value) ..
            " (" ..
            GUTIL:Round(baseResourcefulness) ..
            "+" .. GUTIL:Round(professionStatsMod.resourcefulness.value) .. ") " .. percentText)

        detailsFrame.content.resourcefulnessBonusValue:SetText(professionStats.resourcefulness:GetExtraValue() * 100 ..
            "%")
    end

    local qualityFrame = detailsFrame.content.qualityFrame
    CraftSim.FRAME:ToggleFrame(qualityFrame, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.baseSkillTitle, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.baseSkillValue, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.baseSkillMod, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.recipeDifficultyTitle, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.recipeDifficultyValue, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.recipeDifficultyMod, recipeData.supportsQualities)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentSkillIncreaseTitle,
        recipeData.supportsQualities and recipeData.hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentSkillIncreaseValue,
        recipeData.supportsQualities and recipeData.hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentMaxFactorTitle,
        recipeData.supportsQualities and recipeData.hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(detailsFrame.content.reagentMaxFactorValue,
        recipeData.supportsQualities and recipeData.hasQualityReagents)
    simModeFrames.concentrationToggleMod.labelText:SetVisible(recipeData.supportsQualities)
    simModeFrames.concentrationToggleMod:SetVisible(recipeData.supportsQualities)
    detailsFrame.content.concentrationCostTitle:SetVisible(recipeData.supportsQualities)
    detailsFrame.content.concentrationCostValue:SetVisible(recipeData.supportsQualities)
    if recipeData.supportsQualities then
        local thresholds = CraftSim.AVERAGEPROFIT:GetQualityThresholds(recipeData.maxQuality,
            professionStats.recipeDifficulty.value, CraftSim.DB.OPTIONS:Get("QUALITY_BREAKPOINT_OFFSET"))
        qualityFrame.currentQualityIcon:SetQuality(recipeData.resultData.expectedQuality)
        qualityFrame.currentQualityThreshold:SetText("> " .. (thresholds[recipeData.resultData.expectedQuality - 1] or 0))

        local hasNextQuality = recipeData.resultData.expectedQuality < recipeData.maxQuality
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityIcon, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityThreshold, hasNextQuality)
        CraftSim.FRAME:ToggleFrame(qualityFrame.nextQualityMissingSkillValue, hasNextQuality)
        if hasNextQuality then
            qualityFrame.nextQualityIcon:SetQuality(recipeData.resultData.expectedQuality + 1)
            qualityFrame.nextQualityThreshold:SetText("> " .. (thresholds[recipeData.resultData.expectedQuality] or 0))
            qualityFrame.nextQualityMissingSkillValue:SetText(math.max(
                (thresholds[recipeData.resultData.expectedQuality] or 0) - recipeData.professionStats.skill.value, 0))
        end



        -- Skill
        local reagentSkillIncrease = recipeData.reagentData
            :GetSkillFromRequiredReagents()
        local skillNoReagents = professionStats.skill.value - reagentSkillIncrease
        local professionStatsOptionals = recipeData.reagentData:GetProfessionStatsByOptionals()
        local fullRecipeDifficulty = recipeData.professionStats.recipeDifficulty.value
        detailsFrame.content.recipeDifficultyValue:SetText(GUTIL:Round(fullRecipeDifficulty, 1) ..
            " (" ..
            baseProfessionStats.recipeDifficulty.value ..
            "+" ..
            professionStatsOptionals.recipeDifficulty.value .. "+" .. professionStatsMod.recipeDifficulty.value .. ")")
        detailsFrame.content.baseSkillValue:SetText(GUTIL:Round(professionStats.skill.value, 1) ..
            " (" ..
            GUTIL:Round(skillNoReagents, 1) ..
            "+" .. GUTIL:Round(reagentSkillIncrease, 1) .. "+" .. professionStatsMod.skill.value .. ")")

        if recipeData.hasQualityReagents then
            local maxSkillFactor = recipeData.reagentData:GetMaxSkillFactor()
            local maxReagentSkillIncrease = baseProfessionStats.recipeDifficulty.value * maxSkillFactor
            detailsFrame.content.reagentSkillIncreaseValue:SetText(GUTIL:Round(reagentSkillIncrease, 0) ..
                " / " .. GUTIL:Round(maxReagentSkillIncrease, 0))
            detailsFrame.content.reagentMaxFactorValue:SetText(GUTIL:Round(maxSkillFactor * 100, 1) .. " %")
        end

        -- Concentration

        if recipeData.supportsQualities then
            simModeFrames.concentrationToggleMod:SetChecked(recipeData.concentrating)
            detailsFrame.content.concentrationCostValue:SetText(f.gold(recipeData.concentrationCost))
        end
    end
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE.UI:InitOptionalReagentItemSelectors(recipeData)
    local optionalReagentSlots = recipeData.reagentData.optionalReagentSlots
    local finishingReagentSlots = recipeData.reagentData.finishingReagentSlots

    local simModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()

    ---@type CraftSim.SimulationMode.ReagentOverwriteFrame
    local reagentOverwriteFrame = simModeFrames.reagentOverwriteFrame

    -- init dropdowns
    for _, itemSelector in pairs(reagentOverwriteFrame.optionalReagentItemSelectors) do
        itemSelector:SetItems(nil)
        itemSelector:SetSelectedItem(nil)
        itemSelector:Hide()
    end

    local selectorIndex = 1

    local requiredSelectableReagentSlot = recipeData.reagentData.requiredSelectableReagentSlot

    for _, optionalReagentSlot in pairs(GUTIL:Concat({ { requiredSelectableReagentSlot }, optionalReagentSlots, finishingReagentSlots })) do
        local currentSelector = reagentOverwriteFrame.optionalReagentItemSelectors[selectorIndex]
        local possibleReagents = GUTIL:Map(optionalReagentSlot.possibleReagents, function(reagent)
            return reagent.item
        end)
        currentSelector:Show()
        selectorIndex = selectorIndex + 1
        currentSelector:SetItems(possibleReagents)
        currentSelector:SetSelectedItem(optionalReagentSlot.activeReagent and optionalReagentSlot.activeReagent.item)
    end
end

function CraftSim.SIMULATION_MODE.UI:UpdateVisibility()
    local recipeData = CraftSim.INIT.currentRecipeData
    if not recipeData then
        return -- In what case is this nil?
    end


    print("Update Visibility: hasQualityReagents " .. tostring(recipeData.hasQualityReagents))

    -- frame visiblities
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()

    CraftSim.SIMULATION_MODE.frame:SetVisible(CraftSim.SIMULATION_MODE.isActive and (exportMode == CraftSim.CONST.EXPORT_MODE.NON_WORK_ORDER))
    CraftSim.SIMULATION_MODE.frameWO:SetVisible(CraftSim.SIMULATION_MODE.isActive and (exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER))

    local hasOptionalReagents = recipeData.reagentData:HasOptionalReagents()
    local simModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local bestQBox = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        bestQBox = ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.AllocateBestQualityCheckbox
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Reagents,
            not CraftSim.SIMULATION_MODE.isActive and recipeData.hasReagents)
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.OptionalReagents,
            not CraftSim.SIMULATION_MODE.isActive and hasOptionalReagents)
    else
        bestQBox = ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckbox
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.Reagents,
            not CraftSim.SIMULATION_MODE.isActive and
            (recipeData.hasReagents or recipeData.isSalvageRecipe))
        CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents,
            not CraftSim.SIMULATION_MODE.isActive and hasOptionalReagents)
    end
    CraftSim.CRAFT_BUFFS.frame.content.simulateBuffSelector:SetEnabled(CraftSim.SIMULATION_MODE.isActive)

    ---@type CraftSim.SimulationMode.ReagentOverwriteFrame
    local reagentOverwriteFrame = simModeFrames.reagentOverwriteFrame
    print("reagentOverwriteFrame: " .. tostring(reagentOverwriteFrame))
    local craftingDetailsFrame = simModeFrames.detailsFrame
    print("craftingDetailsFrame: " .. tostring(craftingDetailsFrame))

    -- only if recipe has optionalReagents
    local hasQualityReagents = recipeData.hasQualityReagents
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.content.quality1Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.content.quality2Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.content.quality3Button, hasQualityReagents)
    CraftSim.FRAME:ToggleFrame(reagentOverwriteFrame.content.clearAllocationsButton, hasQualityReagents)

    reagentOverwriteFrame:SetVisible(CraftSim.SIMULATION_MODE.isActive)

    if not CraftSim.SIMULATION_MODE.isActive then
        -- only hide, they will be shown automatically if available
        for _, dropdown in pairs(reagentOverwriteFrame.optionalReagentItemSelectors) do
            print("hide dropdown: " .. tostring(dropdown))
            CraftSim.FRAME:ToggleFrame(dropdown, false)
        end
    end


    CraftSim.FRAME:ToggleFrame(craftingDetailsFrame, CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(bestQBox, not CraftSim.SIMULATION_MODE.isActive)

    -- also toggle the blizzard create all buttons and so on so that a user does not get the idea to press create when in sim mode..
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateAllButton, not CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateMultipleInputBox,
        not CraftSim.SIMULATION_MODE.isActive)
    CraftSim.FRAME:ToggleFrame(ProfessionsFrame.CraftingPage.CreateButton, not CraftSim.SIMULATION_MODE.isActive)
end

---@param recipeData CraftSim.RecipeData
function CraftSim.SIMULATION_MODE.UI:InitReagentOverwriteFrames(recipeData)
    local simModeFrames = CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()

    ---@type CraftSim.SimulationMode.ReagentOverwriteFrame
    local reagentOverwriteFrame = simModeFrames.reagentOverwriteFrame

    -- set non quality reagents to max allocations

    -- filter out non quality reagents
    local qualityReagents = GUTIL:Filter(recipeData.reagentData.requiredReagents, function(reagent)
        return reagent.hasQuality
    end)
    -- reagent overwrites
    for index, inputFrame in pairs(reagentOverwriteFrame.reagentOverwriteInputs) do
        local qualityReagent = qualityReagents and qualityReagents[index] or nil

        CraftSim.FRAME:ToggleFrame(inputFrame, CraftSim.SIMULATION_MODE.isActive and qualityReagent)

        if qualityReagent then
            inputFrame.requiredQuantity:SetText("/ " .. qualityReagent.requiredQuantity)
            -- CraftSim.FRAME:ToggleFrame(inputFrame.inputq2, reagentData.differentQualities)
            -- CraftSim.FRAME:ToggleFrame(inputFrame.inputq3, reagentData.differentQualities)
            inputFrame.inputq1.itemID = qualityReagent.items[1].item:GetItemID()
            inputFrame.inputq1.requiredQuantityValue = qualityReagent.requiredQuantity
            inputFrame.inputq1:SetText(qualityReagent.items[1].quantity)
            inputFrame.inputq2.itemID = qualityReagent.items[2].item:GetItemID()
            inputFrame.inputq2.requiredQuantityValue = qualityReagent.requiredQuantity
            inputFrame.inputq2:SetText(qualityReagent.items[2].quantity)
            if qualityReagent.items[3] then
                inputFrame.inputq3.itemID = qualityReagent.items[3].item:GetItemID()
                inputFrame.inputq3.requiredQuantityValue = qualityReagent.requiredQuantity
                inputFrame.inputq3:SetText(qualityReagent.items[3].quantity)
            end

            inputFrame.isActive = true
            inputFrame.icon:SetItem(qualityReagent.items[1].item)
            inputFrame.icon.qualityIcon:Hide() -- we show the qualities elsewhere
        else
            inputFrame.icon:SetItem(nil)
            inputFrame.isActive = false
        end
    end
end

function CraftSim.SIMULATION_MODE.UI:GetSimulationModeFramesByVisibility()
    local exportMode = CraftSim.UTIL:GetExportModeByVisibility()
    local simModeFrames = nil
    if exportMode == CraftSim.CONST.EXPORT_MODE.WORK_ORDER then
        simModeFrames = CraftSim.SIMULATION_MODE.UI.WORKORDER
    else
        simModeFrames = CraftSim.SIMULATION_MODE.UI.NO_WORKORDER
    end

    return simModeFrames
end
